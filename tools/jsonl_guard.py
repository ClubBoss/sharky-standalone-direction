#!/usr/bin/env python3
"""Minimal JSONL guard for drills files.

Supports:
  python3 tools/jsonl_guard.py --check 'content/*/*/drills.jsonl'

Also exposes validate_paths(paths, fix=False) for callers like tools/allowlists_sync.py.
"""

from __future__ import annotations

import argparse
import glob
import json
import sys
from pathlib import Path
from typing import Iterable, Sequence


def _iter_nonempty_lines(path: Path) -> Iterable[tuple[int, str]]:
    with path.open("r", encoding="utf-8") as fh:
        for lineno, raw in enumerate(fh, start=1):
            line = raw.strip()
            if not line:
                continue
            yield lineno, line


def _validate_file(path: Path) -> int:
    for lineno, line in _iter_nonempty_lines(path):
        try:
            obj = json.loads(line)
        except json.JSONDecodeError as exc:
            col = getattr(exc, "colno", 1) or 1
            print(f"{path}:{lineno}:{col}: invalid JSON: {exc.msg}", file=sys.stderr)
            return 1
        if not isinstance(obj, dict):
            print(f"{path}:{lineno}:1: expected JSON object per line", file=sys.stderr)
            return 1
    return 0


def validate_paths(paths: Sequence[str], fix: bool = False) -> int:
    del fix  # Compatibility placeholder; this guard validates only.
    for raw_path in sorted(set(paths)):
        path = Path(raw_path)
        if not path.exists():
            print(f"{path}:1:1: file not found", file=sys.stderr)
            return 1
        rc = _validate_file(path)
        if rc != 0:
            return rc
    return 0


def _expand_patterns(patterns: Sequence[str]) -> list[str]:
    matches: list[str] = []
    for pattern in patterns:
        for path in sorted(glob.glob(pattern)):
            matches.append(path)
    return matches


def _parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate JSONL files (JSON object per non-empty line).")
    parser.add_argument("--check", nargs="+", metavar="GLOB", help="Glob pattern(s) to validate.")
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = _parse_args(argv or sys.argv[1:])
    if not args.check:
        print("No --check pattern provided.", file=sys.stderr)
        return 2
    paths = _expand_patterns(args.check)
    if not paths:
        return 0
    return validate_paths(paths, fix=False)


if __name__ == "__main__":
    sys.exit(main())
