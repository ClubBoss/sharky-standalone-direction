#!/usr/bin/env python3
"""Write a standalone designer preview without applying a skin pack."""

import argparse
import base64
import html
import json
import re
import sys
from pathlib import Path

import skin_pack_apply_v1 as importer

# B112 pair inventory: test/ui_v2/skin_contrast_guard_v1_test.dart,
# _currentPairs(). Keep the roles, alpha-blended fills and thresholds in sync.
PAIR_SOURCE = 'test/ui_v2/skin_contrast_guard_v1_test.dart (_currentPairs)'
DARK = ('background', 'surface', 'raised')
NORMAL, LARGE_OR_ICON = 4.5, 3.0


def pairs():
    for surface in DARK:
        for role in ('onSurface', 'muted', 'caption', 'accent', 'ok', 'bad'):
            yield role, surface, None, NORMAL
    yield 'onAccent', 'accent', None, NORMAL
    for base in DARK:
        for role, fill in (('accent', 'accentSoft'), ('ok', 'okSoft'),
                           ('bad', 'badSoft'), ('onSurface', 'okSoft'),
                           ('onSurface', 'badSoft')):
            yield role, fill, base, NORMAL
    for surface in ('editorialPageSurface', 'editorialCardSurface'):
        for role in ('editorialInk', 'editorialInkMuted', 'editorialFocus',
                     'editorialNeedsReviewFg'):
            yield role, surface, None, NORMAL
    yield 'editorialOnPrimaryAction', 'editorialPrimaryAction', None, NORMAL
    yield 'editorialNeedsReviewFg', 'editorialNeedsReviewBg', None, NORMAL
    yield 'editorialCorrectFg', 'editorialCorrectBg', None, NORMAL
    for surface in (*DARK, 'academyBackground', 'academyRaised'):
        yield 'academyOnSurface', surface, None, LARGE_OR_ICON
        yield 'academyMuted', surface, None, NORMAL
    for surface in ('navyRaised', 'navySurface', 'surface'):
        yield 'navyOnSurface', surface, None, NORMAL
        yield 'navyMuted', surface, None, NORMAL
    yield 'academyAccent', 'background', None, LARGE_OR_ICON
    yield 'academyOnSurface', 'academyTeal', None, LARGE_OR_ICON
    yield 'muted', 'track', None, LARGE_OR_ICON
    yield 'courseProgressFill', 'courseProgressTrack', None, LARGE_OR_ICON


def resolve_color(value, values):
    seen = set()
    while isinstance(value, str):
        if re.fullmatch(r'#[0-9a-fA-F]{8}', value):
            return value.upper()
        if value in seen or value not in values:
            break
        seen.add(value)
        value = values[value]
    raise ValueError('missing or invalid ARGB color')


def rgba(color):
    a, r, g, b = (int(color[i:i + 2], 16) / 255 for i in (1, 3, 5, 7))
    return r, g, b, a


def blend(foreground, background):
    """Source-over alpha blending using fractional sRGB channels, as in B112."""
    alpha = foreground[3]
    if background[3] == 1:
        return tuple(f * alpha + b * (1 - alpha)
                     for f, b in zip(foreground[:3], background[:3])) + (1.0,)
    back_alpha = background[3] * (1 - alpha)
    total = alpha + back_alpha
    if total == 0:
        return (0.0, 0.0, 0.0, 0.0)
    return tuple((f * alpha + b * back_alpha) / total
                 for f, b in zip(foreground[:3], background[:3])) + (total,)


def luminance(color):
    def linear(channel):
        return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4

    return sum(weight * linear(channel)
               for weight, channel in zip((0.2126, 0.7152, 0.0722), color))


def contrast(foreground, background):
    if background[3] != 1:
        raise ValueError('Contrast requires an opaque backing surface')
    a, b = luminance(blend(foreground, background)), luminance(background)
    return (max(a, b) + 0.05) / (min(a, b) + 0.05)


def css(color):
    # CSS eight-digit hex is RRGGBBAA, unlike the pack's AARRGGBB.
    return '#' + color[3:] + color[1:3]


def token_card(name, values):
    value = values.get(name)
    display = html.escape(json.dumps(value, ensure_ascii=False)) if name in values else 'missing'
    swatch = ''
    try:
        color = resolve_color(value.get('color') if isinstance(value, dict) else value, values)
        swatch = (f'<div class="checker"><div class="swatch" style="background:{css(color)}">'
                  f'</div></div><code>{color}</code>')
    except ValueError:
        pass  # Spacing, typography without color, motion and other non-color tokens.
    return f'<article><strong>{html.escape(name)}</strong>{swatch}<code>{display}</code></article>'


def asset_card(pack, name, assets):
    if name in assets:
        encoded = base64.b64encode(assets[name]).decode('ascii')
        content = f'<div class="checker"><img src="data:image/png;base64,{encoded}" alt="{name}"></div>'
    elif not (pack / 'assets' / name).exists():
        content = '<p class="fail">missing</p>'
    else:
        content = '<p class="fail">invalid asset (see validation errors)</p>'
    side = importer.ASSETS[name]
    return f'<article><strong>{name}</strong><p>{side} × {side} px</p>{content}</article>'


def contrast_rows(values):
    rows, failures = [], 0
    for role, surface, base, minimum in pairs():
        pair = f'{role}/{surface}' + (f'@{base}' if base else '')
        try:
            foreground = rgba(resolve_color(values.get(role), values))
            background = rgba(resolve_color(values.get(surface), values))
            if base:
                background = blend(background, rgba(resolve_color(values.get(base), values)))
            ratio = contrast(foreground, background)
            passed = ratio >= minimum  # Never round before deciding.
            measured = f'{ratio:.4f}:1'
        except ValueError as exc:
            passed, measured = False, html.escape(str(exc))
        failures += not passed
        status = 'PASS' if passed else 'FAIL'
        rows.append(f'<tr><th scope="row">{pair}</th><td>{measured}</td>'
                    f'<td>{minimum:g}:1</td><td class="{status.lower()}">{status}</td></tr>')
    return rows, failures


def preview(pack):
    errors, _, assets = importer.check(pack)
    # Read submitted values rather than the importer's proposed Dart source:
    # invalid/missing tokens must not silently fall back to production values.
    try:
        values = json.loads((pack / 'tokens.json').read_text(), object_pairs_hook=importer.unique_object)
        if not isinstance(values, dict):
            values = {}
    except (OSError, ValueError):
        values = {}
    names = importer.token_names()
    tokens = ''.join(token_card(name, values) for name in names)
    images = ''.join(asset_card(pack, name, assets) for name in importer.ASSETS)
    rows, failures = contrast_rows(values)
    passed = not errors and not failures
    status = 'PASS' if passed else 'FAIL'
    diagnostics = ('<ul>' + ''.join(f'<li>{html.escape(error)}</li>' for error in errors) + '</ul>'
                   if errors else '<p>PASS — pack structure and assets validated.</p>')
    document = f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Skin pack preview</title><style>
body {{ font: 15px/1.5 system-ui, sans-serif; color: #182230; background: #f5f6f8; margin: 2rem auto; padding: 0 1rem; max-width: 1200px; }}
.grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 220px), 1fr)); gap: 12px; }}
article {{ padding: 12px; border: 1px solid #cfd5dc; border-radius: 8px; background: white; overflow-wrap: anywhere; }}
article strong, code {{ display: block; }} code {{ font-size: 12px; }}
.checker {{ background: repeating-conic-gradient(#ddd 0% 25%, white 0% 50%) 0 0 / 16px 16px; margin: 8px 0; }}
.swatch {{ height: 64px; }} img {{ display: block; width: 100%; height: 180px; object-fit: contain; }}
.table-wrap {{ overflow-x: auto; }} table {{ width: 100%; border-collapse: collapse; background: white; }}
th, td {{ text-align: left; padding: 8px; border-bottom: 1px solid #cfd5dc; }}
.pass {{ color: #17613c; font-weight: bold; }} .fail {{ color: #a51e25; font-weight: bold; }}
</style></head><body>
<h1>Skin pack preview: {html.escape(pack.name)}</h1>
<p class="{status.lower()}">{status} — {len(errors)} validation errors; {len(rows) - failures}/{len(rows)} contrast pairs passed.</p>
<h2>Validation (B111)</h2>{diagnostics}
<h2>Tokens ({len(names)})</h2><p>Colors are shown in pack format (#AARRGGBB), including resolved color references. Non-color tokens show their values.</p>
<div class="grid">{tokens}</div>
<h2>Asset slots ({len(importer.ASSETS)})</h2><div class="grid">{images}</div>
<h2>WCAG AA contrast (B112)</h2><p>Pair source: <code>{PAIR_SOURCE}</code>Alpha fills are composited over the surface after @; translucent text is composited before measuring. This is a token check, not visual approval.</p>
<div class="table-wrap"><table><thead><tr><th>Pair</th><th>Ratio</th><th>Minimum</th><th>Result</th></tr></thead>
<tbody>{''.join(rows)}</tbody></table></div></body></html>
'''
    return document, passed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('pack_dir', type=Path)
    parser.add_argument('--out', type=Path, default=Path('skin_pack_preview.html'))
    args = parser.parse_args()
    try:
        document, passed = preview(args.pack_dir)
        args.out.write_text(document, encoding='utf-8')
    except (OSError, ValueError) as exc:
        print(f'skin pack preview: {exc}', file=sys.stderr)
        return 1
    print(f'{"PASS" if passed else "FAIL"}: {args.out}')
    return 0 if passed else 1


if __name__ == '__main__':
    sys.exit(main())
