#!/usr/bin/env python3
"""Summarize the generated W13–W24 G1 census for the world-pair fix packages."""

import argparse
import json
from collections import Counter
from pathlib import Path

BASELINE = Path(__file__).resolve().parents[1] / "test/fixtures/act0_catalog_vol2_baseline_v1.json"
WORLDS = tuple(f"W{n}" for n in range(13, 25))


def report(baseline):
    if set(baseline) != set(WORLDS):
        raise ValueError("Generate the full W13–W24 baseline first (see the census test TODO).")
    rules = sorted({rule for findings in baseline.values() for rule in findings})
    totals = Counter()
    tasks = Counter()
    # One row per world; compact rule identifiers are retained verbatim.
    print("| World | " + " | ".join([*rules, "Total"]) + " |")
    print("| " + " | ".join(["---"] * (len(rules) + 2)) + " |")
    for world in WORLDS:
        counts = []
        for rule in rules:
            findings = baseline[world].get(rule, [])
            count = len(findings)
            counts.append(count)
            totals[rule] += count
            for finding in findings:
                task, _, _ = finding.partition("|")
                if not task.startswith(("@lesson:", "@world:")):
                    tasks[world, task] += 1
        print("| " + " | ".join([world, *map(str, counts), str(sum(counts))]) + " |")
    print("| " + " | ".join(["Total", *(str(totals[r]) for r in rules), str(sum(totals.values()))]) + " |")
    print("\nTop 10 tasks by finding count (excluding lesson/world aggregates):")
    for (world, task), count in sorted(tasks.items(), key=lambda item: (-item[1], item[0]))[:10]:
        print(f"{count:4}  {world}  {task}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, default=BASELINE)
    args = parser.parse_args()
    try:
        report(json.loads(args.baseline.read_text(encoding="utf-8")))
    except (OSError, ValueError) as error:
        parser.error(str(error))


if __name__ == "__main__":
    main()
