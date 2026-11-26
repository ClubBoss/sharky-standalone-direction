#!/usr/bin/env python3
"""Quiet-test table; UI performance samples alone cannot prove learner outcomes."""

import argparse
import csv
import json
from decimal import Decimal, InvalidOperation
from pathlib import Path

UNKNOWN = "N/A"
OBS_FIELDS = (
    "tester", "app_open_s", "first_decision_s", "end_s",
    "w1_tasks_done", "repairs_taken", "drop_off",
)


def read_metrics(path):
    """Validate raw JSONL, not the lossy ui_metrics.json aggregate."""
    with path.open(encoding="utf-8") as stream:
        for number, line in enumerate(stream, 1):
            if not line.strip():
                continue
            try:
                row = json.loads(line)
            except ValueError as exc:
                raise ValueError(f"{path.name}:{number}: invalid JSONL") from exc
            if not isinstance(row, dict) or not (
                ("t" in row and "ms" in row)
                or row.get("event") in ("ui_metrics", "ui_anim", "ui_nav")
            ):
                raise ValueError(f"{path.name}:{number}: not a UI metrics record")


def elapsed_field(row, key):
    value = row[key].strip()
    if not value:
        return None
    try:
        amount = Decimal(value)
    except InvalidOperation as exc:
        raise ValueError(f"invalid {key}") from exc
    if not amount.is_finite() or amount < 0:
        raise ValueError(f"invalid {key}")
    return amount


def count_field(row, key):
    value = row[key].strip()
    if not value:
        return UNKNOWN
    if not value.isascii() or not value.isdecimal():
        raise ValueError(f"invalid {key}")
    return str(int(value))


def read_observations(path):
    """Separate owner observations from telemetry; never infer a missing value."""
    observations = {}
    with path.open(newline="", encoding="utf-8-sig") as stream:
        reader = csv.DictReader(stream)
        if tuple(reader.fieldnames or ()) != OBS_FIELDS:
            raise ValueError("unexpected observation CSV header")
        for row in reader:
            if None in row or any(value is None for value in row.values()):
                raise ValueError(f"observation line {reader.line_num}: wrong field count")
            tester = row["tester"].strip()
            if not tester or tester in observations:
                raise ValueError("empty or duplicate tester ID")
            start, decision, end = (
                elapsed_field(row, key)
                for key in ("app_open_s", "first_decision_s", "end_s")
            )
            if (
                (start is not None and end is not None and end < start)
                or (decision is not None and (
                    start is None or end is None or not start <= decision <= end
                ))
            ):
                raise ValueError(f"{tester}: inconsistent recording offsets")
            seconds = decision - start if decision is not None else None
            if seconds is not None:
                status = "PASS" if seconds <= 180 else "LATE"
                display = format(seconds, "f")
            elif start is not None and end is not None:
                status = "NOT REACHED"
                display = status
            else:
                status = "UNKNOWN"
                display = UNKNOWN
            observations[tester] = (
                display, count_field(row, "w1_tasks_done"),
                count_field(row, "repairs_taken"),
                row["drop_off"].strip() or UNKNOWN, status,
            )
    return observations


def report(metrics, observations=None):
    testers = {}
    for path in metrics:
        tester = path.stem
        if tester in testers:
            raise ValueError(f"duplicate tester filename stem: {tester}")
        read_metrics(path)
        testers[tester] = (UNKNOWN, UNKNOWN, UNKNOWN, UNKNOWN, "UNKNOWN")
    if observations is not None:
        testers.update(read_observations(observations))
    if not testers:
        raise ValueError("provide at least one tester")
    rows = [("Tester", "First decision (s)", "W1 tasks done", "Repairs taken",
             "Drop-off point", "F1M")]
    rows.extend((tester, *values) for tester, values in sorted(testers.items()))
    # Keep the table single-line per participant even if CSV text contains newlines.
    rows = [tuple(" ".join(cell.split()) for cell in row) for row in rows]
    widths = [max(len(row[i]) for row in rows) for i in range(len(rows[0]))]
    lines = [" | ".join(cell.ljust(width) for cell, width in zip(row, widths)).rstrip()
             for row in rows]
    passed = sum(values[-1] == "PASS" for values in testers.values())
    unknown = sum(values[-1] == "UNKNOWN" for values in testers.values())
    lines.append(f"Unknown timing: {unknown} (included in denominator; not a pass)")
    lines.append(f"F1M pass {passed}/{len(testers)} (≤180 s)")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("metrics", nargs="*", type=Path,
                        help="one raw ui_metrics JSONL per tester, named by tester ID")
    parser.add_argument("--observations", type=Path,
                        help="optional separate CSV of recording-based observations")
    args = parser.parse_args()
    try:
        print(report(args.metrics, args.observations))
    except (OSError, ValueError, csv.Error) as exc:
        parser.error(str(exc))


if __name__ == "__main__":
    main()
