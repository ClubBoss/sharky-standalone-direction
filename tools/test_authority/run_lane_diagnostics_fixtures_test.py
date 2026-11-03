#!/usr/bin/env python3
"""Tiny deterministic subprocess fixtures for CI diagnostic behavior."""

import contextlib
import io
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parent))

import run_lane_diagnostics_v1 as diagnostics
import run_lane_v1


class LaneDiagnosticsFixturesTest(unittest.TestCase):
    def python(self, code):
        return [sys.executable, "-c", code]

    def test_success_keeps_zero_exit_and_pass(self):
        result = run_lane_v1._run_command("success", self.python("print('ok')"), 3)
        self.assertEqual((result["status"], result["exit_code"]), ("pass", 0))

    def test_failure_keeps_exit_and_prints_diagnostic(self):
        result = run_lane_v1._run_command(
            "failure", self.python("import sys; print('fixture diagnostic'); sys.exit(7)"), 3
        )
        self.assertEqual((result["status"], result["exit_code"]), ("fail", 7))
        self.assertIn("fixture diagnostic", "\n".join(diagnostics.failure_log_lines(result)))

    def test_timeout_keeps_timeout_status_and_partial_output(self):
        result = run_lane_v1._run_command(
            "timeout", self.python("import time; print('before timeout', flush=True); time.sleep(2)"), 0.1
        )
        self.assertEqual(result["status"], "timeout")
        self.assertIn("before timeout", result["output_tail"])

    def test_missing_executable_is_explicit_error_without_output(self):
        result = run_lane_v1._run_command(
            "missing", ["sharky-fixture-command-that-does-not-exist"], 1
        )
        self.assertEqual((result["status"], result["exit_code"]), ("error", None))
        self.assertTrue(result["output_tail"])

    def test_cancellation_is_not_reported_as_pass(self):
        with mock.patch.object(run_lane_v1.subprocess, "run", side_effect=KeyboardInterrupt):
            result = run_lane_v1._run_command("cancel", self.python("pass"), 1)
        self.assertEqual((result["status"], result["exit_code"]), ("cancelled", None))

    def test_redaction_workflow_command_neutralization_and_truncation(self):
        value = (
            "prefix\naccess_token=fixture-secret\nBearer abc.def\n"
            "AKIA1234567890ABCDEF\n::notice::unsafe\n" + "x" * 5000
        )
        suffix, truncated, length = diagnostics.tail(value)
        self.assertTrue(truncated)
        self.assertEqual(length, len(value))
        self.assertEqual(len(suffix), diagnostics.TAIL_LIMIT)
        safe = diagnostics.sanitize_output(value)
        self.assertNotIn("fixture-secret", safe)
        self.assertNotIn("abc.def", safe)
        self.assertNotIn("AKIA1234567890ABCDEF", safe)
        self.assertNotIn("\n::notice::", safe)
        long_failure = run_lane_v1._run_command(
            "long failure",
            self.python("import sys; print('x' * 5001); sys.exit(4)"),
            3,
        )
        self.assertTrue(long_failure["output_truncated"])
        self.assertIn("output truncated", "\n".join(diagnostics.failure_log_lines(long_failure)))

    def test_job_summary_is_metadata_only(self):
        result = {
            "name": "fixture failure",
            "status": "fail",
            "exit_code": 9,
            "duration_seconds": 0.2,
            "output_tail": "API_KEY=fixture-secret\nactual failure\nopaque-private-value",
            "cmd": ["private-command-argument"],
        }
        summary = {"lane": "fixture", "results": [result]}
        with tempfile.TemporaryDirectory() as temp_dir:
            path = Path(temp_dir) / "summary.md"
            with mock.patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(path)}):
                diagnostics.append_job_summary(summary)
            body = path.read_text()
        self.assertIn("command-001 | fail | 9 | 0.200 | Normal step log", body)
        for value in ("fixture failure", "actual failure", "fixture-secret",
                      "opaque-private-value", "private-command-argument"):
            self.assertNotIn(value, body)

    def test_job_summary_rejects_free_text_in_metadata(self):
        result = dict(name="private-name", status="private-status",
                      exit_code="private-exit", duration_seconds="private-duration",
                      output_tail="private-output")
        with tempfile.TemporaryDirectory() as temp_dir:
            path = Path(temp_dir) / "summary.md"
            with mock.patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(path)}):
                diagnostics.append_job_summary({"lane": "private-lane", "results": [result]})
            body = path.read_text()
        self.assertNotIn("private-", body)
        self.assertIn("command-001 | unknown | unknown | unknown", body)

    def check_summary_write_failure(self, status, lane, expected_exit):
        result = dict(name="fixture", status=status, exit_code=0 if status == "pass" else 7,
                      duration_seconds=0.1, output_tail="")
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            error_log = io.StringIO()
            with mock.patch.object(run_lane_v1, "ROOT", root), \
                 mock.patch.object(run_lane_v1, "SUMMARY_DIR", root / "build"), \
                 mock.patch.object(run_lane_v1, "_run_tier_a", return_value=[result]), \
                 mock.patch.object(run_lane_v1, "_run_manifest_lane", return_value=[result]), \
                 mock.patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(root)}), \
                 mock.patch.object(sys, "argv", ["run_lane_v1.py", lane]), \
                 contextlib.redirect_stdout(io.StringIO()), \
                 contextlib.redirect_stderr(error_log):
                self.assertEqual(run_lane_v1.main(), expected_exit)
            self.assertIn("Job Summary unavailable; lane verdict unchanged.", error_log.getvalue())
            self.assertNotIn(str(root), error_log.getvalue())

    def test_summary_write_failure_preserves_passing_lane(self):
        self.check_summary_write_failure("pass", "tier-a", 0)

    def test_summary_write_failure_preserves_blocking_failure(self):
        self.check_summary_write_failure("fail", "tier-a", 1)

    def test_summary_write_failure_preserves_nonblocking_failure(self):
        self.check_summary_write_failure("fail", "tier-c", 0)

    def test_summary_write_failure_preserves_cancellation(self):
        self.check_summary_write_failure("cancelled", "tier-a", 130)


    def check_missing_executable_lane(self, lane, summary_write_failure=False):
        def missing_command(*args, **kwargs):
            return [run_lane_v1._run_command(
                "missing", ["sharky-fixture-command-that-does-not-exist"], 1
            )]

        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            summary_path = root if summary_write_failure else root / "job-summary.md"
            error_log = io.StringIO()
            with mock.patch.object(run_lane_v1, "ROOT", root), \
                 mock.patch.object(run_lane_v1, "SUMMARY_DIR", root / "build"), \
                 mock.patch.object(run_lane_v1, "_run_tier_a", side_effect=missing_command), \
                 mock.patch.object(run_lane_v1, "_run_manifest_lane", side_effect=missing_command), \
                 mock.patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(summary_path)}), \
                 mock.patch.object(sys, "argv", ["run_lane_v1.py", lane]), \
                 contextlib.redirect_stdout(io.StringIO()), \
                 contextlib.redirect_stderr(error_log):
                self.assertEqual(run_lane_v1.main(), 1)
            if summary_write_failure:
                self.assertIn("Job Summary unavailable; lane verdict unchanged.", error_log.getvalue())
            else:
                self.assertIn("command-001 | error | unknown", summary_path.read_text())

    def test_missing_executable_is_fatal_in_every_lane(self):
        for lane in ("tier-a", "tier-b", "tier-c", "tier-d"):
            with self.subTest(lane=lane):
                self.check_missing_executable_lane(lane)

    def test_summary_write_failure_preserves_infrastructure_error_in_every_lane(self):
        for lane in ("tier-a", "tier-b", "tier-c", "tier-d"):
            with self.subTest(lane=lane):
                self.check_missing_executable_lane(lane, summary_write_failure=True)

    def test_summary_write_failure_preserves_ordinary_failure_and_cancel_in_every_lane(self):
        for lane in ("tier-a", "tier-b", "tier-c", "tier-d"):
            with self.subTest(lane=lane, status="fail"):
                self.check_summary_write_failure("fail", lane, 1 if lane in ("tier-a", "tier-b") else 0)
            with self.subTest(lane=lane, status="cancelled"):
                self.check_summary_write_failure("cancelled", lane, 130)


if __name__ == "__main__":
    unittest.main(verbosity=2)
