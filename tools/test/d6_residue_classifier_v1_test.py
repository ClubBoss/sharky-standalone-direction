"""Run: python3 -I -m unittest tools/test/d6_residue_classifier_v1_test.py."""

from collections import Counter
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools/d6_residue_classifier_v1.py"
BASELINE = ROOT / "test/fixtures/act0_catalog_vol2_baseline_v1.json"
D6 = "D6.history_support"
TINY_BASELINE = {
    "W13": {D6: ["first|choreography/applicability|unsupported",
                "third|choreography/applicability|unsupported"],
            "other.check": ["not-in-snapshot|unrelated"]},
    "W14": {D6: ["second|choreography/applicability|unsupported"]},
}
TINY_SNAPSHOT = """===== WORLD 13 · LESSON example · Example =====
TASK first [drill] First
TABLE: Flop | Board Ac Kd 2s
SEATS: BTN stack 97 BB | SB folded stack 99.5 BB | BB stack 97 BB
TRAIL: preflop: SB posts 0.5 BB · preflop: BB posts 1 BB · preflop: BTN raises to 3 BB · preflop: SB folds · preflop: BB calls 2 BB more · flop: BB checks
    FEEDBACK TABLE: River | Board Ac Kd 2s 3h 4c
TASK third [drill] Third
TABLE: Turn | Board Ac Kd 2s 3h
SEATS: BTN stack 0 BB | SB folded stack 99.5 BB | BB stack 93 BB | UTG stack 98 BB
TRAIL: preflop: SB posts 0.5 BB · preflop: BB posts 1 BB · preflop: UTG posts straddle 2 BB · preflop: BTN calls 2 BB · preflop: SB calls 1.5 BB more · preflop: BB calls 1 BB more · preflop: UTG checks · flop: SB checks · flop: BB bets 5 BB · flop: UTG calls 5 BB · flop: BTN raises to 7 BB (all-in) · flop: SB folds · flop: BB calls 2 BB more · flop: UTG calls 2 BB more
===== WORLD 14 · LESSON example · Example =====
TASK second [drill] Second
TABLE: Flop | Board Qc Jd 2s
SEATS: BTN dealer stack 92 BB | SB folded stack 99.5 BB | BB stack 92 BB
TRAIL: preflop: SB posts 0.5 · preflop: BB posts 1 · preflop: BTN raises to 8 · preflop: SB folds · preflop: BB calls 7 · flop: BB checks
"""


class ResidueClassifierTest(unittest.TestCase):
    def setUp(self):
        build = ROOT / "build/d6_residue"
        build.mkdir(parents=True, exist_ok=True)
        directory = tempfile.TemporaryDirectory(dir=build)
        self.addCleanup(directory.cleanup)
        self.temp = Path(directory.name)
        self.report = self.temp / "REPORT.md"

    def invoke(self, *args):
        return subprocess.run(
            [sys.executable, "-I", str(SCRIPT), "--report", str(self.report),
             "--json", *args], capture_output=True, text=True, check=False,
            cwd=self.temp,
        )

    def fixture(self, baseline, snapshot):
        base = self.temp / "base.json"
        base.write_text(json.dumps(baseline), encoding="utf-8")
        snap = self.temp / "snapshot.txt"
        snap.write_text(snapshot, encoding="utf-8")
        return self.invoke("--baseline", str(base), "--snapshots", str(snap))

    def result(self, process):
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual(process.stderr, "")
        self.assertTrue(self.report.is_file())
        return json.loads(process.stdout)

    def test_three_tasks_two_shapes(self):
        result = self.result(self.fixture(TINY_BASELINE, TINY_SNAPSHOT))
        self.assertEqual(result["total_rows"], 3)
        self.assertEqual(result["missing_ids"], [])
        self.assertEqual(result["shape_count"], 2)
        first, third = result["shapes"]
        self.assertEqual(first, {
            "shape": "2way|3seats|preflop:p-p-r-f-c|flop:x",
            "count": 2, "worlds": {"W13": 1, "W14": 1},
            "samples": [{"world": "W13", "task_id": "first"},
                        {"world": "W14", "task_id": "second"}],
        })
        # SB folded on the flop, so four saw it. Turn is reached but has no action.
        self.assertEqual(third["shape"],
                         "4way|4seats|preflop:p-p-s-l-l-l-x|flop:x-b-c-r!-f-c-c|turn:-"
                         "|straddle|limp|all-in")
        self.assertEqual(third["count"], 1)
        self.assertEqual(result["coverage_80"], {"shape_count": 2, "rows": 3,
                                                "percent": 100.0})
        report = self.report.read_text(encoding="utf-8")
        self.assertIn("Rows: 3 · Missing IDs: 0", report)
        self.assertIn("W13: 1, W14: 1", report)
        self.assertIn("`W13/first`, `W14/second`", report)

    def test_missing_ids_fail_with_world_qualified_ids(self):
        result = self.fixture(TINY_BASELINE, TINY_SNAPSHOT.split("===== WORLD 14")[0])
        self.assertEqual(result.returncode, 1)
        self.assertIn("Missing D6 IDs (1): W14/second", result.stderr)
        self.assertFalse(self.report.exists())

    def test_no_applicable_hand_is_not_a_played_history(self):
        result = self.result(self.fixture(
            {"W13": {D6: ["teach|unsupported"]}},
            "===== WORLD 13 · LESSON example =====\nTASK teach [theory] Teach\n"
            "TABLE: Facts no applicable hand facts\n",
        ))
        self.assertEqual(result["shapes"][0]["shape"],
                         "no-history|seats:unknown|saw-flop:unknown")

    def test_real_fixtures(self):
        baseline = json.loads(BASELINE.read_text(encoding="utf-8"))
        expected_worlds = Counter({w: len(groups[D6]) for w, groups in baseline.items()
                                   if groups.get(D6)})
        expected = sum(expected_worlds.values())
        result = self.result(self.invoke())
        self.assertGreater(expected, 0)
        self.assertEqual(result["total_rows"], expected)
        self.assertEqual(result["missing_ids"], [])
        shapes = result["shapes"]
        counts = [g["count"] for g in shapes]
        self.assertEqual(sum(counts), expected)
        self.assertEqual(counts, sorted(counts, reverse=True))
        actual_worlds = Counter()
        for group in shapes:
            actual_worlds.update(group["worlds"])
            self.assertEqual(sum(group["worlds"].values()), group["count"])
            self.assertEqual(len(group["samples"]), min(2, group["count"]))
        self.assertEqual(actual_worlds, expected_worlds)
        coverage = result["coverage_80"]
        n = coverage["shape_count"]
        self.assertEqual(coverage["rows"], sum(counts[:n]))
        self.assertGreaterEqual(coverage["rows"] * 5, expected * 4)
        self.assertLess(sum(counts[:n - 1]) * 5, expected * 4)
        self.assertEqual(result["top3"]["rows"], sum(counts[:3]))


if __name__ == "__main__":
    unittest.main()
