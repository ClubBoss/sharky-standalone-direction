#!/usr/bin/env python3
"""Validate a B32/B104 designer pack, then apply only its allowed values/files."""

import argparse
import json
import math
import re
import struct
import sys
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path('lib/ui_v2/act0_shell/skin/act0_skin_tokens_v1.dart')
CONTRACT = Path('docs/plan/SKIN_LAYER_v1.md')
SLOTS = Path('assets/skin_v1')
# B104's exact canvases. The three felt constants belong to the table, even
# though the B32 contract lists them; a pack must echo but cannot change them.
ASSETS = {'app_icon.png': 1024, **{
    f'sharky_{name}.png': 360
    for name in ('neutral', 'happy', 'thinking', 'concerned')
}}
FROZEN = {'feltCenter', 'feltMid', 'feltEdge'}
CURVES = {'linear', 'ease', 'easeIn', 'easeOut', 'easeInOut', 'easeOutCubic',
          'easeInCubic', 'easeInOutCubic'}
ICONS = {'expand_more', 'expand_less', 'chevron_right', 'check_rounded', 'close_rounded'}
DECLARATION = re.compile(r'^  static const (?:[\w<>]+ )?(\w+)\s*=\s*(.*?);', re.M | re.S)
NUMBER = r'-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?'


def token_names(root=ROOT):
    table = (root / CONTRACT).read_text().split('### Tokens\n', 1)[1].split('### Components', 1)[0]
    names = re.findall(r'^\| `(\w+)` \|', table, re.M)
    if not names or len(names) != len(set(names)):
        raise ValueError('invalid B32 token contract')
    return names


def declarations(source):
    return {match[1]: match for match in DECLARATION.finditer(source)}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def number(value):
    return type(value) in (int, float) and math.isfinite(float(value))


def font(value):
    # Font names, not Dart fragments; support spaces and international names.
    return isinstance(value, str) and bool(re.fullmatch(r'[\w .-]+', value))


def split_args(expression):
    """Split the small, known const initializer grammar, not arbitrary Dart."""
    parts, start, depth, quote = [], 0, 0, None
    for i, char in enumerate(expression):
        if quote:
            if char == quote:
                quote = None
        elif char in "'\"":
            quote = char
        elif char in '([':
            depth += 1
        elif char in ')]':
            depth -= 1
        elif char == ',' and depth == 0:
            parts.append(expression[start:i].strip())
            start = i + 1
    require(depth == 0 and quote is None, 'unsupported initializer')
    if expression[start:].strip():
        parts.append(expression[start:].strip())
    return parts


class Spec:
    def __init__(self, kind, current, accepts, emit, expression):
        self.kind, self.current = kind, current
        self.accepts, self.emit, self.expression = accepts, emit, expression

    def render(self, value):
        require(self.accepts(value), f'expected {self.kind}')
        # Preserve existing formatting, ratios and aliases for unchanged values.
        if value == self.current:
            return self.expression
        return self.emit(value)


def spec(expression):
    expression = expression.strip()

    def make(kind, current, accepts, emit):
        return Spec(kind, current, accepts, emit, expression)

    if match := re.fullmatch(r'Color\(0x([0-9a-fA-F]{8})\)', expression):
        return make('ARGB color (#AARRGGBB)', '#' + match[1].upper(),
                    lambda v: isinstance(v, str) and bool(re.fullmatch(r'#[0-9a-fA-F]{8}', v)),
                    lambda v: f'Color(0x{v[1:].upper()})')
    if re.fullmatch(NUMBER, expression):
        return make('finite number', float(expression), number, lambda v: repr(float(v)))
    if match := re.fullmatch(rf'({NUMBER}) / ({NUMBER})', expression):
        return make('finite number', float(match[1]) / float(match[2]), number,
                    lambda v: repr(float(v)))
    if match := re.fullmatch(r'Duration\(milliseconds: (\d+)\)', expression):
        return make('milliseconds (nonnegative integer)', int(match[1]),
                    lambda v: type(v) is int and 0 <= v <= 9223372036854,
                    lambda v: f'Duration(milliseconds: {v})')
    if match := re.fullmatch(r'(Curves|Icons)\.(\w+)', expression):
        choices = CURVES if match[1] == 'Curves' else ICONS
        require(match[2] in choices, f'unsupported {match[1]} value')
        return make(match[1] + ' name', match[2], lambda v: isinstance(v, str) and v in choices,
                    lambda v: f'{match[1]}.{v}')
    if match := re.fullmatch(r'FontWeight\.w([1-9]00)', expression):
        return make('font weight (100–900, step 100)', int(match[1]),
                    lambda v: type(v) is int and v in range(100, 1000, 100),
                    lambda v: f'FontWeight.w{v}')
    if match := re.fullmatch(r"'([^']+)'", expression):
        require(font(match[1]), 'unsupported font name')
        return make('font name', match[1], font, lambda v: f"'{v}'")
    if expression == '[FontFeature.tabularFigures()]':
        return make('fixed tabular font feature', ['tabularFigures'],
                    lambda v: v == ['tabularFigures'], lambda v: expression)
    if expression.startswith('[') and expression.endswith(']'):
        names = [spec(part).current for part in split_args(expression[1:-1])]
        require(all(font(name) for name in names), 'unsupported font fallback list')
        return make('font name list', names,
                    lambda v: isinstance(v, list) and all(font(item) for item in v),
                    lambda v: '[' + ', '.join(f"'{item}'" for item in v) + ']')
    if match := re.fullmatch(r'Offset\((.*)\)', expression, re.S):
        parts = [spec(part) for part in split_args(match[1])]
        require(len(parts) == 2, 'unsupported Offset')
        return make('two-number offset', [part.current for part in parts],
                    lambda v: isinstance(v, list) and len(v) == 2 and all(number(x) for x in v),
                    lambda v: 'Offset(' + ', '.join(p.render(x) for p, x in zip(parts, v)) + ')')
    if match := re.fullmatch(r'(TextStyle|BorderSide|BoxShadow)\((.*)\)', expression, re.S):
        fields = {}
        for arg in split_args(match[2]):
            name, value = arg.split(':', 1)
            fields[name] = spec(value)

        def emit(value):
            rendered = [f'{name}: {field.render(value[name])}' for name, field in fields.items()]
            if len(rendered) == 1:
                return f'{match[1]}({rendered[0]})'
            return f'{match[1]}(\n    ' + ',\n    '.join(rendered) + ',\n  )'

        current = {name: field.current for name, field in fields.items()}
        return make(match[1] + ' object with fields ' + ', '.join(fields), current,
                    lambda v: isinstance(v, dict) and v.keys() == fields.keys()
                    and all(field.accepts(v[name]) for name, field in fields.items()), emit)
    if re.fullmatch(r'\w+', expression):
        # Preserve semantic dependencies instead of baking in duplicate values.
        return make('fixed token reference ' + expression, expression,
                    lambda v: isinstance(v, str) and v == expression, lambda v: expression)
    raise ValueError(f'unsupported token initializer: {expression}')


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, f'duplicate key: {key}')
        result[key] = value
    return result


def png_info(data):
    require(data.startswith(b'\x89PNG\r\n\x1a\n'), 'not a PNG')
    position, size, has_data, has_alpha = 8, None, False, False
    while position + 12 <= len(data):
        length, kind = struct.unpack_from('>I4s', data, position)
        end = position + 12 + length
        require(end <= len(data), 'truncated PNG chunk')
        payload = data[position + 8:end - 4]
        require(zlib.crc32(kind + payload) == struct.unpack_from('>I', data, end - 4)[0],
                'invalid PNG chunk checksum')
        if size is None:
            require(kind == b'IHDR' and length == 13, 'invalid PNG header')
            size = struct.unpack_from('>II', payload)
            require(payload[9] in (0, 2, 3, 4, 6), 'invalid PNG color type')
            has_alpha = payload[9] in (4, 6)
        elif kind == b'IDAT':
            has_data = True
        elif kind == b'tRNS':
            has_alpha = True
        elif kind == b'IEND':
            require(length == 0 and end == len(data) and has_data, 'incomplete PNG')
            return size[0], size[1], has_alpha
        position = end
    raise ValueError('missing PNG end')


def check(pack, root=ROOT):
    errors, replacements, assets = [], [], {}
    source = (root / SOURCE).read_text()
    names = set(token_names(root))
    fields = declarations(source)
    if not names <= fields.keys():
        raise ValueError('B32 source missing keys: ' + ', '.join(sorted(names - fields.keys())))
    try:
        values = json.loads((pack / 'tokens.json').read_text(), object_pairs_hook=unique_object)
        require(isinstance(values, dict), 'tokens.json must be an object')
    except (OSError, ValueError) as exc:
        errors.append(f'tokens.json: {exc}')
        values = {}
    for name in sorted(values.keys() - names):
        errors.append(f'unknown token key: {name}')
    for name in sorted(names - values.keys()):
        errors.append(f'missing token key: {name}')
    for name in sorted(names & values.keys()):
        field = fields[name]
        try:
            schema = spec(field[2])
            rendered = schema.render(values[name])
            require(name not in FROZEN or rendered == schema.expression,
                    'protected table token cannot change')
            if rendered != schema.expression:
                replacements.append((field.start(2), field.end(2), rendered))
        except (ValueError, OverflowError) as exc:
            errors.append(f'token {name}: {exc}')
    directory = pack / 'assets'
    entries = {p.name: p for p in directory.iterdir()} if directory.is_dir() else {}
    for name in sorted(entries.keys() - ASSETS.keys()):
        errors.append(f'unknown asset file: {name}')
    for name in sorted(ASSETS.keys() - entries.keys()):
        errors.append(f'missing asset file: {name}')
    for name in sorted(ASSETS.keys() & entries.keys()):
        try:
            require(entries[name].is_file(), 'expected a PNG file')
            data = entries[name].read_bytes()
            width, height, has_alpha = png_info(data)
            side = ASSETS[name]
            require((width, height) == (side, side),
                    f'wrong image size {width}x{height}; expected {side}x{side}')
            require(not has_alpha if name == 'app_icon.png' else has_alpha,
                    'app icon must not have alpha' if name == 'app_icon.png'
                    else 'mascot PNG must support transparency')
            assets[name] = data
        except (OSError, ValueError) as exc:
            errors.append(f'asset {name}: {exc}')
    for start, end, replacement in sorted(replacements, reverse=True):
        source = source[:start] + replacement + source[end:]
    return errors, source, assets


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--check', type=Path, metavar='PACK')
    mode.add_argument('--apply', type=Path, metavar='PACK')
    args = parser.parse_args()
    try:
        errors, source, assets = check(args.check or args.apply)
        if errors:
            print('\n'.join(errors), file=sys.stderr)
            return 1
        if args.apply:
            # All validation and input reads finish before the first write.
            for relative in (SOURCE, SLOTS, *(SLOTS / name for name in assets)):
                destination = ROOT / relative
                require(destination.resolve() == destination,
                        f'refusing redirected destination: {relative}')
            (ROOT / SOURCE).write_text(source)
            for name, data in assets.items():
                (ROOT / SLOTS / name).write_bytes(data)
            print(f'Applied {len(assets)} assets and B32 token values. Review git diff.')
        else:
            print(f'Valid skin pack: {len(token_names())} tokens, {len(assets)} assets.')
        return 0
    except (OSError, ValueError) as exc:
        print(f'skin pack: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
