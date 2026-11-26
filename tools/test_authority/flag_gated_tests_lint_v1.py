#!/usr/bin/env python3
"""E41: require a CI dart-define for compile-time gated Dart tests.

Source lint, not a Dart/YAML interpreter: recognizes skip expressions,
conditional registration and early returns, with local/directly imported
consts. Checks define presence, not its value or the lane's test selection.
"""

import argparse
import json
import re
import tokenize
from functools import lru_cache
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
ALLOWLIST = "tools/test_authority/flag_gated_tests_allowlist_v1.json"
TOKEN = re.compile(
    r"//[^\n]*|/\*.*?\*/|r?(?:'''[\s\S]*?'''|\"\"\"[\s\S]*?\"\"\"|"
    r"'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\")|[\w$]+|[^\s]",
    re.DOTALL,
)
IDENTIFIER = re.compile(r"[a-zA-Z_$][\w$]*\Z")
DEFINE = re.compile(r"--dart-define=([\w.-]+)=")
OPEN = {"(": ")", "[": "]", "{": "}"}


def dart_tokens(source):
    return [t for t in TOKEN.findall(source) if not t.startswith(("//", "/*"))]


def literal(token):
    if token.startswith("r"):
        token = token[1:]
    if len(token) >= 2 and token[0] in "\"'" and token[-1] == token[0]:
        return token[1:-1]
    return None


def expression_end(tokens, start, stops):
    """Stop at a delimiter at the current nesting depth."""
    stack = []
    for i in range(start, len(tokens)):
        token = tokens[i]
        if not stack and token in stops:
            return i
        if token in OPEN:
            stack.append(OPEN[token])
        elif stack and token == stack[-1]:
            stack.pop()
    return len(tokens)


def direct_defines(tokens):
    found = set()
    for i in range(len(tokens) - 4):
        if (tokens[i] in ("bool", "String")
                and tokens[i + 1:i + 4] == [".", "fromEnvironment", "("]):
            name = literal(tokens[i + 4])
            if name:
                found.add(name)
    return found


def const_expressions(tokens):
    result = {}
    for i, token in enumerate(tokens):
        if token != "const":
            continue
        # Inferred or explicitly typed scalar const declarations.
        for name in (i + 1, i + 2):
            if (name + 1 < len(tokens) and IDENTIFIER.fullmatch(tokens[name])
                    and tokens[name + 1] == "="):
                end = expression_end(tokens, name + 2, {";", "}"})
                result[tokens[name]] = tokens[name + 2:end]
                break
    return result


def resolve_constants(expressions):
    resolved = {name: direct_defines(expr) for name, expr in expressions.items()}
    # Propagate simple const aliases and compound compile-time expressions.
    changed = True
    while changed:
        changed = False
        for name, expr in expressions.items():
            dependencies = set().union(*(resolved.get(t, set()) for t in expr))
            if not dependencies <= resolved[name]:
                resolved[name].update(dependencies)
                changed = True
    return resolved


@lru_cache(maxsize=None)
def read_constants(imported):
    if not imported.is_file():
        return {}
    text = imported.read_text(encoding="utf-8")
    if "fromEnvironment" not in text:
        return {}
    return const_expressions(dart_tokens(text))


def imported_constants(root, path, tokens, package_name):
    result = {}
    for i, token in enumerate(tokens[:-1]):
        if token != "import":
            continue
        uri = literal(tokens[i + 1])
        if not uri:
            continue
        if uri.startswith(f"package:{package_name}/"):
            imported = root / "lib" / uri.split("/", 1)[1]
        elif ":" not in uri:
            imported = path.parent / uri
        else:
            continue
        result.update({name: expr for name, expr in read_constants(imported.resolve()).items()
                       if not name.startswith("_")})
    return result


def statement_end(tokens, start):
    if tokens[start] == "{":
        return expression_end(tokens, start + 1, {"}"})
    return expression_end(tokens, start, {";", "}", ","})


def gated_defines(tokens, constants):
    def defines_in(expr):
        return direct_defines(expr) | set().union(
            *(constants.get(t, set()) for t in expr)
        )

    registrations = {"test", "testWidgets", "group"}
    test_scopes = []
    for i, token in enumerate(tokens[:-1]):
        if token in registrations | {"main"} and tokens[i + 1] == "(":
            end = expression_end(tokens, i + 2, {")"})
            if token == "main" and tokens[end + 1:end + 2] == ["{"]:
                end = expression_end(tokens, end + 2, {"}"})
            test_scopes.append((i, end))

    found = set()
    for i, token in enumerate(tokens[:-1]):
        if token == "skip" and tokens[i + 1] == ":":
            end = expression_end(tokens, i + 2, {",", ")", "}"})
            found.update(defines_in(tokens[i + 2:end]))
        elif token == "if" and tokens[i + 1] == "(":
            end = expression_end(tokens, i + 2, {")"})
            defines = defines_in(tokens[i + 2:end])
            if not defines or end + 1 >= len(tokens):
                continue
            start = end + 1
            body_end = statement_end(tokens, start)
            body = tokens[start:body_end]
            # Either branch may contain the conditional registration.
            if tokens[body_end + 1:body_end + 2] == ["else"] and body_end + 2 < len(tokens):
                else_start = body_end + 2
                body += tokens[else_start:statement_end(tokens, else_start)]
            # A conditional test/group registration or a guard that returns
            # before the test can execute. Ordinary conditional assertions
            # (e.g. comparing behavior under both modes) are not gates.
            if ("return" in body and any(a < i < b for a, b in test_scopes)) or any(
                (t in registrations
                 or t.lstrip("_").startswith("register")) and n == "("
                for t, n in zip(body, body[1:])
            ):
                found.update(defines)
    return found


def ci_defines(root):
    found = set()
    for path in (root / ".github/workflows").glob("*.yml"):
        for line in path.read_text(encoding="utf-8").splitlines():
            found.update(DEFINE.findall(re.split(r"(?:^|\s)#", line, 1)[0]))
    for path in (root / "tools/test_authority").glob("*.py"):
        # Fixture assertions are not CI commands. Ignore comments as well.
        if path.name.endswith("_test.py") or path.name.startswith("test_"):
            continue
        with path.open("rb") as source:
            for token in tokenize.tokenize(source.readline):
                if tokenize.tok_name[token.type] in {"STRING", "FSTRING_MIDDLE"}:
                    found.update(DEFINE.findall(token.string))
    return found


def lint(root):
    read_constants.cache_clear()
    configured = ci_defines(root)
    allowlist_path = root / ALLOWLIST
    allowlist = {entry["define"]: entry for entry in json.loads(
        allowlist_path.read_text(encoding="utf-8")
    )} if allowlist_path.exists() else {}
    pubspec = root / "pubspec.yaml"
    package = re.search(r"^name:\s*(\w+)", pubspec.read_text(encoding="utf-8"), re.M) if pubspec.exists() else None
    package_name = package.group(1) if package else "poker_analyzer"
    failed = False
    for path in sorted((root / "test").rglob("*_test.dart")):
        source = path.read_text(encoding="utf-8")
        if "skip" not in source and "if" not in source:
            continue
        tokens = dart_tokens(source)
        expressions = imported_constants(root, path, tokens, package_name)
        expressions.update(const_expressions(tokens))
        constants = resolve_constants(expressions)
        for name in sorted(gated_defines(tokens, constants) - configured):
            message = f"E41 {path.relative_to(root)} {name}"
            if name in allowlist:
                entry = allowlist[name]
                print(f"WARN {message}: {entry['reason']} (until {entry['until']})")
            else:
                print(f"FAIL {message}")
                failed = True
    if not failed:
        print("E41 flag-gated tests: PASS")
    return int(failed)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    return lint(parser.parse_args().root.resolve())


if __name__ == "__main__":
    raise SystemExit(main())
