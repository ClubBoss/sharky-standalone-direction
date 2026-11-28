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
    def test_failed_batch_blocks_without_reexecuting_the_manifest(self):
        for status in ("fail", "error", "timeout", "cancelled"):
            with self.subTest(status=status), \
                 mock.patch.dict(os.environ, {"TEST_AUTHORITY_SHARD": ""}), \
                 mock.patch.object(run_lane_v1, "_read_manifest", return_value=["a_test.dart", "b_test.dart"]), \
                 mock.patch.object(run_lane_v1, "_run_command", return_value={
                     "name": "tier-b batch", "status": status, "exit_code": 1,
                     "duration_seconds": 1, "output_tail": "original failure",
                 }) as command:
                result = run_lane_v1.run_lane("tier-b", 120, False)
                self.assertEqual(result["blocking_verdict"], "BLOCK")
                self.assertEqual(result["files_attempted"], 2)
                self.assertEqual(result["results"][0]["output_tail"], "original failure")
                self.assertEqual(command.call_count, 1)

    def test_tier_b_shards_batch_the_full_manifest_once(self):
        files = run_lane_v1._read_manifest(run_lane_v1.LANES["tier-b"]["manifest"])
        assigned = []
        for index in range(2):
            with mock.patch.dict(os.environ, {"TEST_AUTHORITY_SHARD": f"{index}/2"}), \
                 mock.patch.object(run_lane_v1, "_run_command", return_value={
                     "status": "pass", "duration_seconds": 1,
                 }) as command:
                result = run_lane_v1.run_lane("tier-b", 120, False)

            command.assert_called_once()
            batch_files = command.call_args.args[1][2:-2]
            self.assertEqual(batch_files, [entry for entry in files if entry in batch_files])
            self.assertEqual([entry["name"] for entry in result["results"]], batch_files)
            assigned.append(batch_files)

        self.assertCountEqual(assigned[0] + assigned[1], files)
        full_route = "test/ui_v2/act0_main01_app_root_cycle_v1_test.dart"
        self.assertIn(full_route, min(assigned, key=len))

    def test_vol2_census_runs_with_truth_guards_but_in_separate_process(self):
        commands = run_lane_v1.TIER_A_COMMANDS
        for count in (1, 2, 3, 4):
            shards = [run_lane_v1._tier_a_shard(commands, index, count)
                      for index in range(count)]
            for shard in shards:
                names = {c["name"] for c in shard}
                self.assertEqual("repair intent" in names, "Vol2 pilot G1 census" in names)
        truth = next(c["cmd"] for c in commands if c["name"] == "repair intent")
        census = next(c["cmd"] for c in commands if c["name"] == "Vol2 pilot G1 census")
        self.assertNotIn("--dart-define=SHARKY_W13_PLUS_PILOT=true", truth)
        self.assertIn("--dart-define=SHARKY_W13_PLUS_PILOT=true", census)

    def test_tier_a_measured_weights_cover_and_balance_every_shard_owner(self):
        primary_names = {
            command["name"]
            for command in run_lane_v1.TIER_A_COMMANDS
            if "shard_with" not in command
        }
        self.assertEqual(primary_names, set(run_lane_v1.TIER_A_WEIGHTS))

        owners = run_lane_v1._shard_owners(
            list(primary_names),
            3,
            run_lane_v1.TIER_A_WEIGHTS,
            default_weight=10,
            pinned_shard_zero=run_lane_v1.TIER_A_SHARD0,
        )
        loads = [
            sum(
                run_lane_v1.TIER_A_WEIGHTS[name]
                for name, owner in owners.items()
                if owner == index
            )
            for index in range(3)
        ]

        self.assertLessEqual(max(loads) - min(loads), 15)
        self.assertEqual(
            owners["durable learner truth and assessment interaction (LDR-01)"],
            0,
        )

    def test_long_session_budgets_are_scoped_and_larger_overrides_still_apply(self):
        names = (
            "Long-session focused save and replay cases",
            "W1-W3 long session across restarts",
            "W4-W7 long session across restarts",
        )
        courses = [c for c in run_lane_v1.TIER_A_COMMANDS if c["name"] in names]
        self.assertEqual([c["name"] for c in courses], list(names))
        self.assertIn("--dart-define=ACT0_LONG_SESSION_FOCUSED_ONLY=true", courses[0]["cmd"])
        shards = [
            [c["name"] for c in run_lane_v1._tier_a_shard(run_lane_v1.TIER_A_COMMANDS, index, 3)]
            for index in range(3)
        ]
        early, late = (next(index for index, shard in enumerate(shards) if name in shard)
                       for name in names[1:])
        self.assertNotEqual(early, late)

        ordinary = {"name": "fixture ordinary command", "cmd": ["fixture"]}
        for requested, expected in ((120, [120, 180, 420, 420]), (600, [600] * 4)):
            with self.subTest(requested=requested), \
                 mock.patch.dict(os.environ, {"TEST_AUTHORITY_SHARD": ""}), \
                 mock.patch.object(run_lane_v1, "TIER_A_COMMANDS", [ordinary, *courses]), \
                 mock.patch.object(run_lane_v1, "_run_command", return_value={"status": "pass"}) as command:
                results = run_lane_v1._run_tier_a(requested, False)
                self.assertEqual([call.args[2] for call in command.call_args_list], expected)
                self.assertEqual(len(results), 4)

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
        for lane in ("tier-a", "tier-b"):
            with self.subTest(lane=lane):
                self.check_missing_executable_lane(lane)

    def test_summary_write_failure_preserves_infrastructure_error_in_every_lane(self):
        for lane in ("tier-a", "tier-b"):
            with self.subTest(lane=lane):
                self.check_missing_executable_lane(lane, summary_write_failure=True)

    def test_summary_write_failure_preserves_ordinary_failure_and_cancel_in_every_lane(self):
        for lane in ("tier-a", "tier-b"):
            with self.subTest(lane=lane, status="fail"):
                self.check_summary_write_failure("fail", lane, 1)
            with self.subTest(lane=lane, status="cancelled"):
                self.check_summary_write_failure("cancelled", lane, 130)


if __name__ == "__main__":
    unittest.main(verbosity=2)
