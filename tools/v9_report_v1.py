#!/usr/bin/env python3
"""Render fresh V9 rows; missing/invalid rows fail closed (stdlib only)."""
import argparse
import json
from pathlib import Path


def render(root: Path, last_world: int) -> bool:
    lines = []
    for world in range(1, last_world + 1):
        folder = root / f"w{world:02d}"
        try:
            row = json.loads((folder / "row.json").read_text())
            if row["world"] != world or type(row["tasks"]) is not int or type(row["xp_delta"]) is not int:
                raise ValueError("invalid world/task/XP fields")
            for key in ("screens", "overflow_errors", "exceptions"):
                if not isinstance(row[key], list) or not all(isinstance(s, str) for s in row[key]):
                    raise ValueError(f"invalid {key}")
            if row["wrong_answer_repair"] not in ("ok", "missing"):
                raise ValueError("invalid repair status")
            required = {"lesson_start.png", "wrong_feedback.png", "repair.png", "result.png", "final_result.png"}
            missing = required - set(row["screens"])
            for name in row["screens"]:
                if Path(name).name != name or not name.endswith(".png") or not (folder / name).is_file() or not (folder / name).stat().st_size:
                    missing.add(name)
            failed = (row["tasks"] <= 0 or row["xp_delta"] < 0 or row["wrong_answer_repair"] != "ok"
                      or bool(missing or row["overflow_errors"] or row["exceptions"]))
            detail = (f'{row["tasks"]} tasks · {len(row["screens"])} screens · repair {row["wrong_answer_repair"]} '
                      f'· {len(row["overflow_errors"])} overflows · {len(row["exceptions"])} exceptions · XP +{row["xp_delta"]}')
            if missing:
                detail += " · missing screenshots: " + ", ".join(sorted(missing))
            for error in (row["overflow_errors"] + row["exceptions"])[:1]:
                detail += " · " + " ".join(error.split())[:220]
        except (OSError, ValueError, KeyError, TypeError) as error:
            failed, detail = True, f"missing/invalid row: {error}"
        lines.append((failed, f"- {'FAIL' if failed else 'PASS'} W{world:02d}: {detail}"))
    root.mkdir(parents=True, exist_ok=True)
    (root / "REPORT.md").write_text(
        "# V9 walkthrough (widget renderer, reference phone viewport)\n\n"
        "W2+ use seeded prerequisite credit; this is not physical-device acceptance.\n\n"
        + "\n".join(line for _, line in sorted(lines, key=lambda item: not item[0])) + "\n"
    )
    return not any(failed for failed, _ in lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path("build/v9"))
    parser.add_argument("--last-world", type=int, choices=range(1, 13), default=12)
    args = parser.parse_args()
    passed = render(args.root, args.last_world)
    print(args.root / "REPORT.md")
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
