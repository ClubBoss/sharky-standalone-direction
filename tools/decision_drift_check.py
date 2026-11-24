#!/usr/bin/env python3
"""Report retired decisions in plan documents and executor briefs."""

import argparse
import os
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = "docs/plan/RETIRED_DECISIONS_v1.md"
DEFAULT_GLOBS = (
    "docs/plan/*.md",
    "../l0-audit/reasoning/design_brief/*.md",
    "../l0-audit/reasoning/value_index/screen_vision_v1.md",
    "../l0-audit/lead/b*.md",
)
HEADING = re.compile(r"^ {0,3}(#{1,6})[ \t]+(.*?)(?:[ \t]+#+)?[ \t]*$")
SETEXT_UNDERLINE = re.compile(r"^ {0,3}(=+|-+)[ \t]*$")
FENCE = re.compile(r"^ {0,3}(`{3,}|~{3,})(.*)$")


def load_rules(registry):
    for number, line in enumerate(registry.read_text(encoding="utf-8").splitlines(), 1):
        if not line.startswith("|") or line.startswith(("| id |", "|---")):
            continue
        cells = [cell.strip() for cell in re.split(r"(?<!\\)\|", line)[1:-1]]
        if len(cells) != 5:
            raise ValueError(f"{registry}:{number} | expected five table cells")
        decision_id, pattern, replacement, _, scope = cells
        pattern = re.compile(pattern.strip("`").replace(r"\|", "|"))
        globs = []
        for item in scope.split(","):
            glob = item.strip().strip("`")
            globs.extend(DEFAULT_GLOBS if glob == "default" else (glob,))
        yield decision_id, pattern, replacement, globs


def active_lines(path):
    history_level = None
    fence = None
    lines = path.read_text(encoding="utf-8").splitlines()
    for number, line in enumerate(lines, 1):
        marker = FENCE.match(line)
        if marker:
            run, tail = marker.groups()
            if fence is None:
                fence = run
            elif run.startswith(fence) and not tail.strip():
                fence = None
        if fence is None:
            heading = HEADING.match(line)
            if heading:
                marks, title = heading.groups()
                level = len(marks)
            else:
                underline = (
                    SETEXT_UNDERLINE.fullmatch(lines[number])
                    if line.strip() and number < len(lines)
                    else None
                )
                title = line.strip()
                level = (1 if underline[1][0] == "=" else 2) if underline else None
            if level is not None:
                if history_level is not None and level <= history_level:
                    history_level = None
                if history_level is None and title == "History":
                    history_level = level
        if history_level is None and "RETIRED:" not in line:
            yield number, line


def find_hits(root):
    registry = root / REGISTRY
    rules_by_path = {}
    for decision_id, pattern, replacement, globs in load_rules(registry):
        paths = {path.resolve() for glob in globs for path in root.glob(glob)}
        for path in paths:
            if path != registry and path.is_file():
                rules_by_path.setdefault(path, []).append((decision_id, pattern, replacement))

    for path in sorted(rules_by_path):
        for number, line in active_lines(path):
            for decision_id, pattern, replacement in rules_by_path[path]:
                if pattern.search(line):
                    yield f"{os.path.relpath(path, root)}:{number} | {decision_id} | {replacement}"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT, help="repository root")
    args = parser.parse_args()
    try:
        hits = list(find_hits(args.root.resolve()))
    except (OSError, ValueError, re.error) as error:
        print(error, file=sys.stderr)
        return 2
    for hit in hits:
        print(hit)
    return int(bool(hits))


if __name__ == "__main__":
    sys.exit(main())
