#!/usr/bin/env python3
"""Classify the vol2 D6 baseline using the checked-in catalog snapshots.

Run with python3 -I; --json emits the same ranked groups as REPORT.md.
This is a shape census, not a certification of history legality or support.
"""

import argparse
from collections import Counter, defaultdict
import json
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "test/fixtures"
BASELINE = FIXTURES / "act0_catalog_vol2_baseline_v1.json"
SNAPSHOTS = [
    FIXTURES / f"act0_catalog_snapshot_w{n}_w{n + 1}_v1.txt"
    for n in range(13, 24, 2)
]
REPORT = ROOT / "build/d6_residue/REPORT.md"
STREETS = ("preflop", "flop", "turn", "river")
D6 = "D6.history_support"
ALL_IN = re.compile(r"\ball[ -]in\b|\b(?:jams|shoves)\b")
ACTIONS = {
    "posts": "p", "blind": "p", "ante": "ante", "antes": "ante",
    "folds": "f", "checks": "x", "bets": "b", "calls": "c",
    "raises": "r", "limps": "l", "straddles": "s",
    "all-in": "a", "jams": "a", "shoves": "a", "declares": "a",
}


def baseline_rows(path):
    data = json.loads(path.read_text(encoding="utf-8"))
    return [
        (world, row.split("|", 1)[0])
        for world, groups in data.items()
        for row in groups.get(D6, [])
    ]


def snapshot_tasks(paths, wanted):
    tasks = {}
    for path in paths:
        world = task = None
        for line in path.read_text(encoding="utf-8").splitlines():
            if match := re.match(r"===== WORLD (\d+)\b", line):
                world, task = f"W{match[1]}", None
            elif match := re.match(r"TASK (\S+)", line):
                key = (world, match[1])
                task = None
                if key in wanted:
                    if key in tasks:
                        raise ValueError(f"Duplicate snapshot task: {world}/{match[1]}")
                    task = tasks[key] = {}
            elif task is not None and line.startswith(("TABLE:", "SEATS:", "TRAIL:")):
                field, _, value = line.partition(":")
                if field in task:
                    raise ValueError(f"Duplicate {field} in {world}/{key[1]}")
                task[field] = value.strip()
    return tasks


def shape_key(task):
    table = task.get("TABLE", "")
    if table == "Facts no applicable hand facts" and not task.get("TRAIL"):
        # Explanatory rows have no observable seats or history; do not invent a hand.
        return "no-history|seats:unknown|saw-flop:unknown"
    table_street = table.split(" | ", 1)[0].lower()
    if table_street not in STREETS or not task.get("SEATS"):
        raise ValueError("Expected a hand TABLE street and SEATS")
    seats = {part.split()[0].lower() for part in task["SEATS"].split(" | ")}
    actions = defaultdict(list)
    preflop_folds = set()
    markers = set()
    raised = False
    street = "preflop"
    for event in filter(None, (task.get("TRAIL", "").split(" · "))):
        event = event.strip().lower()
        if ":" in event:
            street, event = (part.strip() for part in event.split(":", 1))
        if street not in STREETS:
            raise ValueError(f"Unknown street: {street}")
        actor, _, action = event.partition(" ")
        if actor not in seats or not action:
            raise ValueError(f"Unknown actor/action: {event}")
        verb = action.split()[0]
        code = ACTIONS.get(verb)
        if re.search(r"\bstraddl(?:e|es)\b", action):
            code = "s"
            markers.add("straddle")
        elif verb == "posts" and re.search(r"\bante\b", action):
            code = "ante"
        if code is None or (verb == "declares" and not ALL_IN.search(action)):
            raise ValueError(f"Unknown action: {event}")
        if street == "preflop":
            if code == "f":
                preflop_folds.add(actor)
            if code == "l" or (code == "c" and not raised):
                code = "l"
                markers.add("limp")
            if code in ("b", "r", "a"):
                raised = True
        if ALL_IN.search(action):
            markers.add("all-in")
            if code != "a":
                code += "!"
        actions[street].append(code)

    # TABLE can show the first decision on a street before any recorded action.
    last = max(STREETS.index(s) for s in (table_street, *actions))
    saw_flop = len(seats - preflop_folds) if last >= 1 and task.get("TRAIL") else 0
    ways = f"{saw_flop}way" if last == 0 or task.get("TRAIL") else "unknown-way"
    parts = [ways, f"{len(seats)}seats"]
    parts.extend(f"{s}:{'-'.join(actions[s]) or '-'}" for s in STREETS[:last + 1])
    parts.extend(marker for marker in ("straddle", "limp", "all-in") if marker in markers)
    return "|".join(parts)


def classify(baseline, snapshots):
    rows = baseline_rows(baseline)
    tasks = snapshot_tasks(snapshots, set(rows))
    missing = sorted(set(rows) - tasks.keys())
    if missing:
        raise ValueError("Missing D6 IDs ({}): {}".format(
            len(missing), ", ".join(f"{w}/{t}" for w, t in missing)))

    grouped = defaultdict(list)
    for world, task_id in rows:
        try:
            key = shape_key(tasks[world, task_id])
        except ValueError as exc:
            raise ValueError(f"{world}/{task_id}: {exc}") from exc
        grouped[key].append((world, task_id))

    groups = []
    for key, members in sorted(grouped.items(), key=lambda pair: (-len(pair[1]), pair[0])):
        members.sort(key=lambda pair: (int(pair[0][1:]), pair[1]))
        groups.append({
            "shape": key,
            "count": len(members),
            "worlds": dict(Counter(w for w, _ in members)),
            "samples": [{"world": w, "task_id": t} for w, t in members[:2]],
        })
    count_80 = rows_80 = 0
    while rows_80 * 5 < len(rows) * 4:
        rows_80 += groups[count_80]["count"]
        count_80 += 1
    top3 = sum(group["count"] for group in groups[:3])
    return {
        "total_rows": len(rows), "missing_ids": [], "shape_count": len(groups),
        "shapes": groups,
        "top3": {"rows": top3, "percent": 100 * top3 / len(rows) if rows else 0},
        "coverage_80": {"shape_count": count_80, "rows": rows_80,
                        "percent": 100 * rows_80 / len(rows) if rows else 0},
    }


def render_report(result):
    coverage = result["coverage_80"]
    lines = ["# D6 history-support residue", "",
             f"Rows: {result['total_rows']} · Missing IDs: {len(result['missing_ids'])} · "
             f"Shapes: {result['shape_count']}", "",
             f"Top 3: {result['top3']['rows']} rows ({result['top3']['percent']:.1f}%).",
             f"80% coverage: first {coverage['shape_count']} shapes, "
             f"{coverage['rows']} rows ({coverage['percent']:.1f}%).", "",
             "`no-history` rows have no applicable hand facts in the snapshot; they are not "
             "evidence for extending a played-history parser. `0way` means the flop was not reached. "
             "The flop count uses seats minus preflop folds, not folds on later streets. "
             "`p` post/blind, `f` fold, `x` check, `b` bet, `c` call, `r` raise, "
             "`l` limp, `s` straddle, `a` all-in, `!` all-in modifier, `-` no recorded actions. "
             "Amounts and actor identities are omitted; preflop action order is preserved.", "",
             "| Rank | Shape | Rows | Worlds (rows) | Sample task IDs | Top 80% |",
             "| ---: | --- | ---: | --- | --- | --- |"]
    for rank, group in enumerate(result["shapes"], 1):
        shape = group["shape"].replace("|", r"\|")
        worlds = ", ".join(f"{w}: {n}" for w, n in group["worlds"].items())
        samples = ", ".join(f"`{s['world']}/{s['task_id']}`" for s in group["samples"])
        lines.append(f"| {rank} | `{shape}` | {group['count']} | {worlds} | {samples} | "
                     f"{'yes' if rank <= coverage['shape_count'] else ''} |")
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, default=BASELINE)
    parser.add_argument("--snapshots", type=Path, nargs="+", default=SNAPSHOTS)
    parser.add_argument("--report", type=Path, default=REPORT)
    parser.add_argument("--json", action="store_true", help="Emit ranked census as JSON on stdout")
    args = parser.parse_args()
    try:
        result = classify(args.baseline, args.snapshots)
        report = render_report(result)
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(report, encoding="utf-8")
    except (OSError, ValueError) as exc:
        print(f"D6 classifier: {exc}", file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2) if args.json else report, end="\n" if args.json else "")
    return 0


if __name__ == "__main__":
    sys.exit(main())
