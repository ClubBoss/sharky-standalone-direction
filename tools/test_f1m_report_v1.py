"""Synthetic fixtures only; no actual participant data."""
import tempfile
import unittest
from pathlib import Path

from f1m_report_v1 import report

RAW = """{"t":"2026-01-01T12:00:00Z","ms":16}
{"event":"ui_nav","route":"/home","ms":25}
{"event":"ui_metrics","screen":"Home","avgFps":60,"avgFrameMs":16,"samples":4}
"""
CSV = """tester,app_open_s,first_decision_s,end_s,w1_tasks_done,repairs_taken,drop_off
T01,5,185,1000,12,2,W1 complete
T02,1,181.001,300,3,1,lesson 2
T03,2,,120,0,0,first lesson
T04,,,,,,missing recording
"""


class F1mReportTest(unittest.TestCase):
    def test_ui_metrics_cannot_prove_a_decision_or_progress(self):
        with tempfile.TemporaryDirectory() as temp:
            metrics = Path(temp) / "T01.jsonl"
            metrics.write_text(RAW)
            result = report([metrics])
            self.assertIn("F1M pass 0/1 (≤180 s)", result)
            self.assertIn("Unknown timing: 1", result)
            self.assertEqual(result.splitlines()[1].count("N/A"), 4)

    def test_boundary_no_decision_missing_and_multiple_testers(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            metrics = [root / f"T0{i}.jsonl" for i in (1, 2, 5)]
            for path in metrics:
                path.write_text(RAW)
            observations = root / "observations.csv"
            observations.write_text(CSV)
            result = report(metrics, observations)
            rows = {line.split("|")[0].strip(): line for line in result.splitlines()}
            self.assertIn("PASS", rows["T01"])
            self.assertIn("180", rows["T01"])
            self.assertIn("12", rows["T01"])
            self.assertIn("W1 complete", rows["T01"])
            self.assertIn("180.001", rows["T02"])
            self.assertIn("LATE", rows["T02"])
            self.assertIn("NOT REACHED", rows["T03"])
            self.assertIn("UNKNOWN", rows["T04"])
            self.assertIn("UNKNOWN", rows["T05"])
            self.assertIn("F1M pass 1/5 (≤180 s)", result)
            self.assertIn("Unknown timing: 2", result)

    def test_inconsistent_observation_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "observations.csv"
            path.write_text(CSV.replace("5,185,1000", "5,4,1000"))
            with self.assertRaisesRegex(ValueError, "inconsistent recording offsets"):
                report([], path)

    def test_aggregate_is_not_raw_jsonl(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "T01.jsonl"
            path.write_text('{"screens":{},"updatedAt":"2026-01-01"}\n')
            with self.assertRaisesRegex(ValueError, "not a UI metrics record"):
                report([path])


if __name__ == "__main__":
    unittest.main()
