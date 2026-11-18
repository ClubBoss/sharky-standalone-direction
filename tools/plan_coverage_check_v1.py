#!/usr/bin/env python3
"""Check that every pre-beta Roadmap 2.0 criterion is assigned to a plan block.

Reads the stage map (docs/plan/ROADMAP_STAGE_MAP_v1.md) and lists every ID of
the pre-beta stages S1-S5 that does not appear in docs/PLAN.md. Exit code 1 if
any is missing. Run it after changing the route in PLAN.md.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
STAGE_MAP = ROOT / "docs/plan/ROADMAP_STAGE_MAP_v1.md"
PLAN = ROOT / "docs/PLAN.md"
PRE_BETA = ("## S1 ", "## S2 ", "## S3 ", "## S4 ", "## S5 ")


def pre_beta_ids():
    ids, active = [], False
    for line in STAGE_MAP.read_text().splitlines():
        if line.startswith("## "):
            active = line.startswith(PRE_BETA)
            continue
        m = re.match(r"^\| ([A-Z]{3}-\d{2}(?:\.[a-z])?) \|", line)
        if active and m:
            ids.append(m.group(1))
    return ids


def main():
    plan = PLAN.read_text()
    ids = pre_beta_ids()
    missing = [i for i in ids if not re.search(r"(?<![\w.-])" + re.escape(i) + r"(?![\w-])", plan)]
    print(f"pre-beta criteria: {len(ids)}, assigned: {len(ids) - len(missing)}")
    if missing:
        print("missing from PLAN.md:", ", ".join(missing))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
