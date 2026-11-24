"""Check Dart changes before pushing, using Python and an optional Dart SDK."""

import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys


NON_CODE = re.compile(
    r"//[^\n]*|/\*.*?\*/"
    r"|r?(?P<quote>'''|\"\"\"|'|\")(?:\\.|(?!(?P=quote)).)*(?P=quote)",
    re.DOTALL,
)
TEARDOWN = re.compile(r"(?<![\w$])addTearDown\s*\(")
PARENTHESIS = re.compile(r"[()]")
FORMAT_ERROR = re.compile(r"^line (\d+), column \d+ of (.+?): (.*)$", re.MULTILINE)


def semantics_teardown_lines(source):
    # Preserve offsets while ignoring examples in comments and strings.
    code = NON_CODE.sub(lambda match: re.sub(r"[^\n]", " ", match[0]), source)
    for call in TEARDOWN.finditer(code):
        depth = 1
        for paren in PARENTHESIS.finditer(code, call.end()):
            depth += 1 if paren[0] == "(" else -1
            if depth == 0:
                argument = code[call.end():paren.start()].lower()
                if "semantics" in argument and "dispose" in argument:
                    yield source.count("\n", 0, call.start()) + 1
                break


def git(*args):
    return subprocess.check_output(
        ["git", "-c", "core.fsmonitor=false", *args], stderr=subprocess.PIPE
    )


def git_paths(*args):
    return [Path(os.fsdecode(path)) for path in git(*args).split(b"\0") if path]


def check_format(paths):
    if not paths:
        return False
    dart = shutil.which("dart")
    if dart is None:
        print("TL2 skip: dart is missing")
        return False

    # Flutter's launcher can update its SDK cache even for a format check.
    bundled_dart = Path(dart).resolve().parent / "cache/dart-sdk/bin/dart"
    if bundled_dart.is_file():
        dart = str(bundled_dart)
    result = subprocess.run(
        [dart, "--suppress-analytics", "format", "--output=none",
         "--set-exit-if-changed", *(str(path.absolute()) for path in paths)],
        capture_output=True,
        text=True,
    )
    if result.returncode == 0:
        return False

    changed = {
        Path(line.removeprefix("Changed ")).resolve()
        for line in result.stdout.splitlines()
        if line.startswith("Changed ")
    }
    for path in paths:
        if path.resolve() in changed:
            print(f"{path}:1: TL2 fail: run dart format")
    errors = FORMAT_ERROR.findall(result.stderr)
    for line, path, message in errors:
        print(f"{path}:{line}: TL2 fail: dart format could not parse this file. {message}")
    if not errors and (result.returncode != 1 or not changed):
        details = (result.stderr or result.stdout).strip()
        print(f"{paths[0]}:1: TL2 fail: dart format exited {result.returncode}")
        if details:
            print(details, file=sys.stderr)
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", help="Git ref to compare with the working tree")
    parser.add_argument("paths", nargs="*", type=Path, help="explicit file paths")
    args = parser.parse_args()
    if bool(args.base) == bool(args.paths):
        parser.error("provide either --base or explicit paths")
    try:
        if args.base:
            merge_base = git(
                "merge-base", "--", args.base, "HEAD"
            ).strip().decode("ascii")
            candidates = git_paths(
                "diff", "--name-only", "-z", "--diff-filter=ACMRT", merge_base, "--"
            )
        else:
            candidates = args.paths
        untracked = git_paths(
            "ls-files", "-z", "--others", "--exclude-standard", "--", "test/"
        )
        paths = sorted({path for path in candidates if path.suffix == ".dart"})
        failed = False
        for path in paths:
            for line in semantics_teardown_lines(path.read_text(encoding="utf-8")):
                print(f"{path}:{line}: TL1 fail: call semantics.dispose() in the test body")
                failed = True
        for path in sorted(untracked):
            if path.name.endswith(("_goldens.dart", "_test.dart")):
                print(f"{path}:1: TL3 warn: untracked test file; commit or delete")
        format_failed = check_format(paths)
        return int(failed or format_failed)
    except subprocess.CalledProcessError as error:
        print(os.fsdecode(error.stderr).strip(), file=sys.stderr)
        return 1
    except (OSError, UnicodeError) as error:
        print(error, file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
