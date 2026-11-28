#!/usr/bin/env python3
"""Deterministic fixtures for Dart test JSON per-file timing diagnostics."""

import contextlib
import io
import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import json_file_timings_v1 as timings


def events(*values):
    return [json.dumps(value) for value in values]


def start():
    return {
        "type": "start",
        "time": 0,
        "protocolVersion": "0.1.1",
        "runnerVersion": "1.25.8",
        "pid": 123,
    }


def suite(identifier, path, time):
    return {
        "type": "suite",
        "time": time,
        "suite": {"id": identifier, "platform": "vm", "path": path},
    }


def test_start(identifier, suite_id, time):
    return {
        "type": "testStart",
        "time": time,
        "test": {"id": identifier, "suiteID": suite_id, "name": "fixture"},
    }


def test_done(identifier, time, *, result="success", skipped=False, hidden=False):
    return {
        "type": "testDone",
        "time": time,
        "testID": identifier,
        "result": result,
        "skipped": skipped,
        "hidden": hidden,
    }


class JsonFileTimingsFixturesTest(unittest.TestCase):
    def test_reports_complete_sequential_file_windows(self):
        report = timings.parse_events(
            events(
                start(),
                {"type": "allSuites", "time": 0, "count": 2},
                suite(1, "a_test.dart", 100),
                test_start(2, 1, 100),
                test_done(2, 1000, hidden=True),
                test_start(5, 1, 1000),
                test_done(5, 3100),
                suite(3, "b_test.dart", 3100),
                test_start(4, 3, 3100),
                test_done(4, 5100, skipped=True),
                {"type": "done", "time": 5200, "success": True},
            )
        )

        self.assertEqual(report["run"]["observed_wall_seconds"], 5.2)
        self.assertFalse(report["run"]["has_overlapping_file_windows"])
        rows = {row["path"]: row for row in report["files"]}
        self.assertEqual(rows["a_test.dart"]["observed_window_seconds"], 3.0)
        self.assertEqual(rows["a_test.dart"]["status"], "pass")
        self.assertEqual(rows["a_test.dart"]["visible_test_count"], 1)
        self.assertEqual(rows["a_test.dart"]["hidden_test_count"], 1)
        self.assertEqual(rows["b_test.dart"]["status"], "skipped")

    def test_marks_concurrent_windows_and_does_not_sum_them(self):
        report = timings.parse_events(
            events(
                start(),
                suite(1, "slow_test.dart", 10),
                test_start(2, 1, 10),
                suite(3, "fast_test.dart", 20),
                test_start(4, 3, 20),
                test_done(4, 2020),
                test_done(2, 4020),
                {"type": "done", "time": 4100, "success": True},
            )
        )

        rows = {row["path"]: row for row in report["files"]}
        self.assertEqual(rows["slow_test.dart"]["observed_window_seconds"], 4.01)
        self.assertEqual(rows["fast_test.dart"]["observed_window_seconds"], 2.0)
        self.assertEqual(rows["slow_test.dart"]["overlaps_with_suite_ids"], [3])
        self.assertEqual(rows["fast_test.dart"]["overlaps_with_suite_ids"], [1])
        self.assertEqual(report["run"]["observed_wall_seconds"], 4.1)

    def test_incomplete_run_exposes_only_a_lower_bound(self):
        report = timings.parse_events(
            events(
                start(),
                {"type": "allSuites", "time": 0, "count": 2},
                suite(1, "partial_test.dart", 100),
                test_start(2, 1, 100),
                test_done(2, 900),
            )
        )

        row = report["files"][0]
        self.assertEqual(row["status"], "incomplete")
        self.assertIsNone(row["observed_window_seconds"])
        self.assertEqual(row["observed_lower_bound_seconds"], 0.8)
        self.assertEqual(report["run"]["missing_suite_count"], 1)

    def test_failed_file_is_distinct_from_other_passing_file(self):
        report = timings.parse_events(
            events(
                start(),
                suite(1, "pass_test.dart", 0),
                test_start(2, 1, 0),
                test_done(2, 100),
                suite(3, "fail_test.dart", 100),
                test_start(4, 3, 100),
                test_done(4, 200, result="failure"),
                {"type": "done", "time": 210, "success": False},
            )
        )

        rows = {row["path"]: row for row in report["files"]}
        self.assertEqual(rows["pass_test.dart"]["status"], "pass")
        self.assertEqual(rows["fail_test.dart"]["status"], "fail")

    def test_hidden_only_suite_is_not_reported_as_passing_visible_tests(self):
        report = timings.parse_events(
            events(
                start(),
                suite(1, "load_only_test.dart", 10),
                test_start(2, 1, 10),
                test_done(2, 1010, hidden=True),
                {"type": "done", "time": 1020, "success": True},
            )
        )

        row = report["files"][0]
        self.assertEqual(row["status"], "no_visible_tests")
        self.assertEqual(row["observed_window_seconds"], 1.0)
        self.assertEqual(row["visible_test_count"], 0)
        self.assertEqual(row["hidden_test_count"], 1)

    def test_rejects_mixed_runs_and_unknown_protocol(self):
        with self.assertRaisesRegex(timings.TimingInputError, "multiple start"):
            timings.parse_events(events(start(), start()))
        unsupported = start() | {"protocolVersion": "9.9.9"}
        with self.assertRaisesRegex(timings.TimingInputError, "unsupported"):
            timings.parse_events(events(unsupported))

        for malformed in ({"unexpected": "object"}, ["unexpected", "list"]):
            with self.subTest(protocol=malformed), self.assertRaisesRegex(
                timings.TimingInputError, "unsupported"
            ):
                timings.parse_events(events(start() | {"protocolVersion": malformed}))

    def test_rejects_unknown_test_result(self):
        with self.assertRaisesRegex(timings.TimingInputError, "result.*invalid"):
            timings.parse_events(
                events(
                    start(),
                    suite(1, "unknown_result_test.dart", 0),
                    test_start(2, 1, 0),
                    test_done(2, 100, result="cancelled"),
                    {"type": "done", "time": 110, "success": False},
                )
            )

    def test_cli_fails_closed_for_non_json_input(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            path = Path(temp_dir) / "events.jsonl"
            path.write_text("ordinary console output\n", encoding="utf-8")
            stderr = io.StringIO()
            with contextlib.redirect_stderr(stderr):
                result = timings.main([str(path)])
        self.assertEqual(result, 2)
        self.assertIn("not a JSON event", stderr.getvalue())


if __name__ == "__main__":
    unittest.main()
