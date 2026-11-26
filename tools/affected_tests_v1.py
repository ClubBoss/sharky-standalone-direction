#!/usr/bin/env python3
"""Select affected Dart tests from a git diff (default base: origin/main).

Before reporting done, list the affected tests with affected_tests_v1.py
Use --run to execute every selected test in bounded chunks before pushing.
This is a lexical, conservative guard, not a full Dart dependency analyzer.
"""

import argparse
import os
from pathlib import Path
import posixpath
import re
import signal
import subprocess
import sys
import tempfile


CONTENT_GUARDS = (
    "test/ui_v2/act0_daily_practice_queue_v1_test.dart",
    "test/ui_v2/act0_copy_error_classes_v1_test.dart",
    "test/ui_v2/act0_catalog_truth_guards_v1_test.dart",
    "test/guards/act0_atlas_dod_v1_test.dart",
    "test/guards/concept_error_repair_integrity_v1_test.dart",
    "test/guards/learning_content_integrity_census_v1_test.dart",
)
CHUNK_SIZE = 10
CHUNK_TIMEOUT_SECONDS = 300
DART_KEYWORDS = set("""
abstract as assert async augment await base break case catch class const continue
covariant default deferred do dynamic else enum export extends extension external
factory false final finally for Function get hide if implements import in interface
is late library mixin new null of on operator part required rethrow return sealed
set show static super switch sync this throw true try type typedef var void when
while with yield
""".split())
IDENTIFIER = re.compile(r"[A-Za-z_$][\w$]*")
LITERAL = re.compile(r"(['\"])((?:\\.|(?!\1)[^\\\r\n])*)\1")
DIRECTIVE = re.compile(r"(?:^|(?<=;))\s*(import|export|part)\s+(['\"][^;]+);", re.MULTILINE)


def git(*args):
    return subprocess.check_output(["git", "-c", "core.fsmonitor=false", *args])


def git_paths(*args):
    return {os.fsdecode(path) for path in git(*args).split(b"\0") if path}


def changed_lines(patch):
    in_hunk = False
    for line in patch.decode("utf-8", errors="replace").splitlines():
        if line.startswith("diff --git "):
            in_hunk = False
        elif line.startswith("@@ "):
            in_hunk = True
        elif in_hunk and line.startswith(("+", "-")):
            yield line[1:]


def terms(text):
    """Include public words and exact string values (including dashed/dotted IDs)."""
    identifiers = {
        word for word in IDENTIFIER.findall(text)
        if len(word) >= 6 and not word.startswith("_") and word not in DART_KEYWORDS
    }
    strings = {match[2] for match in LITERAL.finditer(text) if len(match[2]) >= 6}
    return identifiers | strings


def collect_changes(base):
    # Include committed, staged and unstaged changes separately, including
    # staged edits that have subsequently been reverted in the working tree.
    base = git("rev-parse", "--verify", "--end-of-options", f"{base}^{{commit}}").decode().strip()
    paths, changed_terms = set(), set()
    patch_options = ("--no-ext-diff", "--no-textconv", "--no-renames", "--no-color", "-U0")
    for revision in ((f"{base}...HEAD",), ("--cached",), ()):
        paths.update(git_paths("diff", "--no-renames", "--name-only", "-z", *revision, "--"))
        for line in changed_lines(git("diff", *patch_options, *revision, "--")):
            changed_terms.update(terms(line))
    # New files are not present in git diff until staged.
    untracked = git_paths("ls-files", "--others", "--exclude-standard", "-z", "--", "lib/", "test/", "assets/")
    paths.update(untracked)
    for name in untracked:
        path = Path(name)
        if path.is_file() and path.suffix in {".dart", ".json", ".yaml", ".yml", ".txt"}:
            changed_terms.update(terms(path.read_text(encoding="utf-8", errors="replace")))
    return paths, changed_terms


def package_name():
    pubspec = Path("pubspec.yaml")
    if pubspec.is_file():
        match = re.search(r"^name:\s*['\"]?([\w]+)", pubspec.read_text(encoding="utf-8"), re.MULTILINE)
        if match:
            return match[1]
    return None


def references(source, contents, kind, package):
    for match in DIRECTIVE.finditer(contents):
        if match[1] != kind:
            continue
        # Also consider every URI in a conditional import/export.
        for literal in LITERAL.finditer(match[2]):
            uri = literal[2]
            if package and uri.startswith(f"package:{package}/"):
                yield posixpath.normpath("lib/" + uri.split("/", 1)[1])
            elif ":" not in uri and not uri.startswith("/"):
                yield posixpath.normpath(posixpath.join(posixpath.dirname(source), uri))


def read_dart(path):
    return path.read_text(encoding="utf-8", errors="replace")


def is_content_path(name):
    return name.startswith(("lib/", "assets/")) and (
        "catalog" in name.lower() or "lesson" in name.lower()
        or Path(name).name == "act0_shell_state_v1.dart"
    )


def select_tests(paths, changed_terms):
    package = package_name()
    changed_lib = {name for name in paths if name.startswith("lib/") and name.endswith(".dart")}
    lib_sources = {path.as_posix(): read_dart(path) for path in Path("lib").rglob("*.dart")}
    # Part files are members of their owning Dart library, not standalone imports.
    owners = {
        name for name, contents in lib_sources.items()
        if changed_lib.intersection(references(name, contents, "part", package))
    }
    direct = changed_lib | owners
    # Exactly one re-export level; use the original set, not a growing closure.
    barrels = {
        name for name, contents in lib_sources.items()
        if direct.intersection(references(name, contents, "export", package))
    }
    affected_lib = direct | barrels
    selected = set()
    for path in Path("test").rglob("*_test.dart"):
        name = path.as_posix()
        contents = read_dart(path)
        if (name in paths
                or affected_lib.intersection(references(name, contents, "import", package))
                or changed_terms.intersection(terms(contents))):
            selected.add(name)
    if any(is_content_path(name) for name in paths | owners):
        # Do not silently omit a missing guard; Flutter should report it as a failure.
        selected.update(CONTENT_GUARDS)
    return sorted(selected)


def positive_int(value):
    number = int(value)
    if number <= 0:
        raise argparse.ArgumentTypeError("must be positive")
    return number


def run_tests(tests, chunk_size, timeout):
    """Return nonzero if any chunk failed; continue through all chunks."""
    failed = False
    for start in range(0, len(tests), chunk_size):
        chunk = tests[start:start + chunk_size]
        command = ["flutter", "test", "--no-pub", *chunk]
        with tempfile.TemporaryFile() as output:
            try:
                process = subprocess.Popen(command, stdout=output, stderr=subprocess.STDOUT,
                                           start_new_session=True)
            except OSError as error:
                print(f"FAIL: cannot start Flutter: {error}", file=sys.stderr)
                return 1
            try:
                status = process.wait(timeout=timeout)
                reason = f"exit {status}"
            except subprocess.TimeoutExpired:
                # Stop Flutter and its test workers, not just the launcher.
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                process.wait()
                status = 124
                reason = f"timeout after {timeout}s"
            if status:
                failed = True
                print(f"FAIL ({reason}): {', '.join(chunk)}", file=sys.stderr)
                output.seek(0)
                print(output.read().decode("utf-8", errors="replace"), end="", file=sys.stderr)
    return int(failed)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("base", nargs="?", help="git base ref (default: origin/main)")
    parser.add_argument("--base", dest="named_base", help="alternative to positional base ref")
    parser.add_argument("--run", action="store_true", help="run selected tests; output failures only")
    parser.add_argument("--chunk-size", type=positive_int, default=CHUNK_SIZE)
    parser.add_argument("--timeout", type=positive_int, default=CHUNK_TIMEOUT_SECONDS,
                        help="hard timeout per chunk in seconds")
    args = parser.parse_args()
    if args.base and args.named_base:
        parser.error("specify the base ref only once")
    os.chdir(os.fsdecode(git("rev-parse", "--show-toplevel").rstrip(b"\n")))
    tests = select_tests(*collect_changes(args.base or args.named_base or "origin/main"))
    if args.run:
        return run_tests(tests, args.chunk_size, args.timeout)
    for name in tests:
        print(name)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
