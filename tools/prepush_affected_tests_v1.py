#!/usr/bin/env python3
"""Preview with python3 -I tools/prepush_affected_tests_v1.py [--base origin/main].
Add --run to check Dart formatting and run the selected Flutter tests.
Run from anywhere inside the worktree before pushing.
Stage new files to include them. Selection uses changed lines and literal test references.
"""

import argparse
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys


TEST_LIMIT = 40
IDENTIFIER = r"[A-Za-z_$][\w$]*"
DART_TYPE = rf"{IDENTIFIER}(?:\.{IDENTIFIER})?(?:<[^=;()]+>)?\??"
DECLARATIONS = (
    re.compile(rf"^(?:(?:abstract|base|final|interface|sealed|mixin)\s+)*"
               rf"(?:class|enum)\s+({IDENTIFIER})"),
    re.compile(rf"^const\s+(?:{DART_TYPE}\s+)?({IDENTIFIER})\s*(?=[=,;]|$)"),
    re.compile(rf"^(?:external\s+)?(?:{DART_TYPE}\s+)?"
               rf"({IDENTIFIER})(?:<[^=;()]+>)?\s*\("),
)
KEY = re.compile(r"(?P<quote>['\"])([a-z][a-z0-9]*(?:[_.][a-z0-9]+)+)(?P=quote)")
LIB_DART = ":(glob)lib/**/*.dart"


def git(*args):
    return subprocess.check_output(["git", "-c", "core.fsmonitor=false", *args])


def changed_lines(patch):
    in_hunk = False
    for line in patch.decode("utf-8", errors="replace").splitlines():
        if line.startswith("diff --git "):
            in_hunk = False
        elif line.startswith("@@ "):
            in_hunk = True
        elif in_hunk and line.startswith(("+", "-")):
            yield line[1:]


def collect_changes(base):
    paths, symbols, keys = set(), set(), set()
    patch_args = ("--no-ext-diff", "--no-textconv", "--no-renames", "--no-color", "-U0")
    for revision in ((f"{base}...HEAD",), ("--cached",), ()):
        names = git("diff", "--no-renames", "--name-only", "-z", *revision, "--")
        paths.update(os.fsdecode(name) for name in names.split(b"\0") if name)
        dart_patch = git("diff", *patch_args, *revision, "--", LIB_DART)
        for line in changed_lines(dart_patch):
            for pattern in DECLARATIONS:
                match = pattern.match(line)
                if match:
                    name = match.group(1)
                    if len(name) >= 6:
                        symbols.add(name)
                    break
            keys.update(match.group(2) for match in KEY.finditer(line))
        other_patch = git("diff", *patch_args, *revision, "--", "lib/", "assets/",
                          ":(exclude,glob)lib/**/*.dart")
        for line in changed_lines(other_patch):
            keys.update(match.group(2) for match in KEY.finditer(line))
    return paths, symbols, keys


def select_tests(changed_paths, terms):
    scores = {}
    for path in Path("test").rglob("*_test.dart"):
        if not path.is_file():
            continue
        name = path.as_posix()
        contents = path.read_text(encoding="utf-8") if terms else ""
        matches = sum(contents.count(term) for term in terms)
        if matches or name in changed_paths:
            scores[name] = matches
    ranked = sorted(scores, key=lambda name: (-scores[name], name))
    return sorted(ranked[:TEST_LIMIT]), len(ranked)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--base", default="origin/main", help="comparison ref (default: origin/main)")
    parser.add_argument("--run", action="store_true", help="execute the printed commands")
    args = parser.parse_args()

    os.chdir(os.fsdecode(git("rev-parse", "--show-toplevel").rstrip(b"\n")))
    base = git("rev-parse", "--verify", "--end-of-options", f"{args.base}^{{commit}}").decode().strip()
    changed_paths, symbols, keys = collect_changes(base)
    tests, total = select_tests(changed_paths, symbols | keys)
    dart_files = sorted(
        path for path in changed_paths if path.endswith(".dart") and Path(path).is_file()
    )
    print("Symbols:", ", ".join(sorted(symbols)) or "(none)")
    print("Keys:", ", ".join(sorted(keys)) or "(none)")
    if total > TEST_LIMIT:
        print(f"Warning: {total} test files matched. Selected the top {TEST_LIMIT} by match count.")
    print(f"Matched test files: {total} ({len(tests)} selected)")
    for path in tests:
        print(f"  {path}")

    commands = []
    if dart_files:
        format_paths = [f"./{path}" if path.startswith("-") else path for path in dart_files]
        commands.append(["dart", "format", "--output=none", "--set-exit-if-changed", *format_paths])
    if tests:
        commands.append(["flutter", "test", "--no-pub", *tests])
    for command in commands:
        print(shlex.join(command), flush=True)
    if args.run:
        exit_code = 0
        for command in commands:
            status = subprocess.run(command).returncode
            exit_code = exit_code or (status if status >= 0 else 128 - status)
        return exit_code
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except subprocess.CalledProcessError as error:
        sys.exit(error.returncode if error.returncode > 0 else 128 - error.returncode)
    except OSError as error:
        sys.exit(str(error))
