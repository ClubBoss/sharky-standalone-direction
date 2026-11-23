"""Report the five-run F1 median and enforce the three-minute budget."""
import json
import sys
from pathlib import Path
from statistics import median


def main(samples):
    if len(samples) != 5 or any(sample <= 0 for sample in samples):
        raise SystemExit("F1 requires five positive simulator timings")
    result = median(samples)
    budget = 180_000
    passed = result <= budget
    report = {
        "samples_ms": samples,
        "median_ms": result,
        "threshold_ms": budget,
        "passed": passed,
    }
    Path("build/p1_first_decision_gate.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8"
    )
    print(f"[F1] median of 5: {result} ms (limit {budget} ms)")
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main([int(value) for value in sys.argv[1:]]))
