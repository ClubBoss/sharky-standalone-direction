#!/usr/bin/env bash
set -euo pipefail

exec python3 - "$@" <<'PY'
import argparse
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys


def git(*args):
    return subprocess.check_output(["git", *args])


def git_paths(*args):
    return [Path(os.fsdecode(path)) for path in git(*args).split(b"\0") if path]


def check(command, failure_code):
    try:
        return failure_code if subprocess.call(command) else 0
    except OSError as error:
        print(f"Could not run {command[0]}: {error}", file=sys.stderr)
        return failure_code


def map_tests(changed):
    sources = {path for path in changed if path.parts[0] == "lib"}
    tests = {
        path for path in changed
        if path.parts[0] == "test" and path.name.endswith("_test.dart")
    }
    if not sources:
        return tests

    pubspec = Path("pubspec.yaml").read_text(encoding="utf-8")
    package = re.search(r"^name:\s*(\w+)", pubspec, re.MULTILINE).group(1)
    package_prefix = f"package:{package}/"
    stems = {}
    for source in sources:
        stems.setdefault(f"{source.stem}_test.dart", set()).add(source)

    matched = set()
    for test in Path("test").rglob("*_test.dart"):
        matches = set(stems.get(test.name, ()))
        for uri in re.findall(
            r"""^[ \t]*import\s+['"]([^'"]+)['"]""",
            test.read_text(encoding="utf-8"),
            re.MULTILINE,
        ):
            if uri.startswith(package_prefix):
                imported = Path("lib", uri[len(package_prefix):])
            elif ":" not in uri:
                imported = Path(os.path.normpath(test.parent / uri))
            else:
                continue
            if imported in sources:
                matches.add(imported)
        if matches:
            tests.add(test)
            matched.update(matches)

    for source in sorted(sources - matched):
        print(f"WARNING [4] No mapped test for {source}", flush=True)
    return tests


def main():
    parser = argparse.ArgumentParser(
        usage="tools/pre_push_gate.sh [--run | --sandbox] [BASE]",
        description="Check changed Dart files against the merge base (default origin/main).",
        epilog="Checks exit 1 for format, 2 for analyze, or 3 for tests. "
               "Mapping warning 4 does not change the exit status.",
    )
    parser.add_argument("base", nargs="?", default="origin/main")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--run", action="store_true", help="run the mapped Flutter tests")
    mode.add_argument("--sandbox", action="store_true", help="leave tests to the tick")
    args = parser.parse_args()

    os.chdir(os.fsdecode(git("rev-parse", "--show-toplevel")).rstrip("\n"))
    base = os.fsdecode(git("merge-base", "--", args.base, "HEAD")).strip()
    changed = set(git_paths("diff", "--name-only", "-z", "--diff-filter=ACMRT",
                            base, "--", "*.dart"))
    if args.sandbox:
        changed.update(git_paths("ls-files", "--others", "--exclude-standard", "-z",
                                 "--", "*.dart"))
    files = sorted(map(str, changed))
    print(f"Changed Dart files ({len(files)}, base {args.base}):", flush=True)
    for file in files:
        print(f"  {file}", flush=True)

    if files:
        status = check(["dart", "format", "--output=none", "--set-exit-if-changed",
                        *files], 1)
        if status:
            return status
        status = check(["dart", "analyze", *files], 2)
        if status:
            return status
    else:
        print("Dart format and analyze skipped.")

    tests = sorted(map(str, map_tests(changed)))
    if tests:
        command = ["flutter", "test", *tests]
        print(" ".join(map(shlex.quote, command)), flush=True)
        if args.run:
            status = check(command, 3)
            if status:
                return status
    else:
        print("No mapped Flutter tests.")
    if args.sandbox:
        print("tests left to the tick")
    print("Pre-push gate passed.")
    return 0


try:
    sys.exit(main())
except (OSError, subprocess.CalledProcessError) as error:
    sys.exit(f"Pre-push gate could not complete: {error}")
PY
