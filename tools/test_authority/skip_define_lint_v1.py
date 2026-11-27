#!/usr/bin/env python3
"""E41: flag skip expressions whose dart-define is absent from run_lane_v1.py.

This is a static presence check, not proof that a lane selects the test or
supplies the value needed to un-skip it. No Dart or lane commands are executed.
"""
import argparse
import ast
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
IDENTIFIER = re.compile(r"[A-Za-z_$][\w$]*")
# Keep quoted strings atomic and ignore comments, including skip examples in
# source-truth tests. Positions are retained for actionable diagnostics.
TOKEN = re.compile(
    r"//[^\n]*|/\*|r?(?:"
    r'"{3}[\s\S]*?"{3}|\'{3}[\s\S]*?\'{3}'
    r"""|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')"""
    r"|[A-Za-z_$][\w$]*|[^\s]"
)
BLOCK_COMMENT = re.compile(r"/\*|\*/")
OPEN = {"(": ")", "[": "]", "{": "}"}


def tokens(source):
    """Yield (token, source offset), omitting whitespace and Dart comments."""
    position = 0
    while match := TOKEN.search(source, position):
        value = match.group()
        position = match.end()
        if value == "/*":
            depth = 1
            while depth and (end := BLOCK_COMMENT.search(source, position)):
                position = end.end()
                depth += 1 if end.group() == "/*" else -1
            if depth:
                return
        elif not value.startswith("//"):
            yield value, match.start()


def expression(values, start):
    """Read a named argument/initializer up to its enclosing delimiter."""
    stack = []
    for index in range(start, len(values)):
        value = values[index]
        if not stack and value in (",", ";", ")", "]", "}"):
            return values[start:index]
        if value in OPEN:
            stack.append(OPEN[value])
        elif stack and value == stack[-1]:
            stack.pop()
    return values[start:]


def string_literal(value):
    return value.startswith(("'", '"', "r'", 'r"'))


def environment_defines(values):
    names = set()
    for index in range(len(values) - 4):
        if (
            values[index] in ("bool", "String")
            and values[index + 1:index + 4] == [".", "fromEnvironment", "("]
            and string_literal(values[index + 4])
        ):
            literal = values[index + 4]
            if literal.startswith("r"):
                literal = literal[1:]
            names.add(literal.strip("'\""))
    return names


def collect_constants(root):
    local = defaultdict(dict)
    public = defaultdict(set)
    for directory in ("lib", "test"):
        for path in sorted((root / directory).rglob("*.dart")):
            source = path.read_text(encoding="utf-8")
            if "fromEnvironment" not in source:
                continue
            values = [value for value, _ in tokens(source)]
            for index, value in enumerate(values):
                if value != "const":
                    continue
                # Typed and inferred declarations, including static consts.
                name_index = index + 1
                if values[name_index:name_index + 1] in (["bool"], ["String"]):
                    name_index += 1
                if (name_index + 1 >= len(values)
                        or not IDENTIFIER.fullmatch(values[name_index])
                        or values[name_index + 1] != "="):
                    continue
                name = values[name_index]
                defines = environment_defines(expression(values, name_index + 2))
                local[path][name] = defines
                if not name.startswith("_"):
                    public[name].update(defines)
    return local, public


def lane_defines(root):
    # Read command data statically instead of importing the runner (and its
    # diagnostics dependency). Fall back to literal argument strings for a
    # runner with no command dictionaries. Comments never count.
    path = root / "tools/test_authority/run_lane_v1.py"
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    commands = [
        value
        for node in ast.walk(tree) if isinstance(node, ast.Dict)
        for key, value in zip(node.keys, node.values)
        if isinstance(key, ast.Constant) and key.value == "cmd"
    ]
    prefix = "--dart-define="
    return {
        node.value[len(prefix):].split("=", 1)[0]
        for command in commands or [tree]
        for node in ast.walk(command)
        if isinstance(node, ast.Constant)
        and isinstance(node.value, str)
        and node.value.startswith(prefix)
        and "=" in node.value[len(prefix):]
    }


def lint(root):
    configured = lane_defines(root)
    local, public = collect_constants(root)
    failures, warnings = [], []
    for path in sorted((root / "test").rglob("*_test.dart")):
        source = path.read_text(encoding="utf-8")
        if "skip" not in source:
            continue
        scanned = list(tokens(source))
        values = [value for value, _ in scanned]
        for index, value in enumerate(values[:-1]):
            if value != "skip" or values[index + 1] != ":":
                continue
            expr = expression(values, index + 2)
            line = source.count("\n", 0, scanned[index][1]) + 1
            location = f"{path.relative_to(root)}:{line}"
            if len(expr) == 1 and (expr[0] == "true" or string_literal(expr[0])):
                warnings.append(f"WARN {location} · literal skip: {expr[0]}")
                continue
            defines = environment_defines(expr)
            for name in expr:
                if IDENTIFIER.fullmatch(name):
                    defines.update(local[path].get(name, public.get(name, set())))
            for define in sorted(defines - configured):
                failures.append(f"{location} · {define} · lanes that set it: none")
    for warning in warnings:
        print(warning)
    for failure in failures:
        print(failure)
    print(f"{'FAIL' if failures else 'PASS'}: {len(failures)} unset define skip(s), "
          f"{len(warnings)} literal skip warning(s)")
    return int(bool(failures))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT, help="Repository root")
    return lint(parser.parse_args().root.resolve())


if __name__ == "__main__":
    raise SystemExit(main())
