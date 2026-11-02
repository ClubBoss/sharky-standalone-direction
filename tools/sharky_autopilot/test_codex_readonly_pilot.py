"""M3A fixed subscription Codex pilot security tests; NEVER run an AI model."""
from pathlib import Path
import sqlite3
from tempfile import TemporaryDirectory
import unittest
from unittest import mock

from durable_queue import (
    ADMISSION, CODEX_ADMISSION, CODEX_BASE_SHA, CODEX_BRANCH, CODEX_PROVIDER,
    CODEX_TASK, QueueStop, admit_codex_readonly_once, connect, lease_once,
    snapshot,
)
from codex_readonly_pilot import MARKER, MODEL, run_once


class MockCodexProcess:
    def __init__(self, command, *, marker=MARKER, exit_code=0, **_):
        self.command = command
        self.pid = 43210
        self.returncode = exit_code
        self._marker = marker
        self.wait_count = 0

    def wait(self, timeout=None):
        self.wait_count += 1
        if self._marker is not None:
            path = Path(self.command[self.command.index("--output-last-message") + 1])
            path.write_text(self._marker, encoding="utf-8")
        return self.returncode

    def poll(self):
        return self.returncode


class CodexPilotTests(unittest.TestCase):
    def setUp(self):
        self.folder = TemporaryDirectory()
        self.path = Path(self.folder.name) / "codex-once.db"
        self.source = mock.patch("codex_readonly_pilot._source_preflight")
        self.binary = mock.patch("codex_readonly_pilot._codex_binary", return_value="/opt/mock/codex")
        self.gone = mock.patch("codex_readonly_pilot._session_gone", return_value=True)
        self.source.start()
        self.binary.start()
        self.gone.start()
        self.addCleanup(self.source.stop)
        self.addCleanup(self.binary.stop)
        self.addCleanup(self.gone.stop)

    def tearDown(self):
        self.folder.cleanup()

    def _model_call(self, *, marker=MARKER, exit_code=0):
        recorded = []
        def fake_popen(command, **kw):
            recorded.append((command,kw))
            return MockCodexProcess(command, marker=marker, exit_code=exit_code)
        with mock.patch("codex_readonly_pilot.subprocess.Popen", side_effect=fake_popen):
            result = run_once(self.path, owner_admission=CODEX_ADMISSION, initialize=True)
        return result, recorded

    def test_no_owner_no_model_or_database(self):
        with mock.patch("codex_readonly_pilot.subprocess.Popen") as popen:
            with self.assertRaises(QueueStop):
                run_once(self.path, owner_admission="", initialize=True)
            popen.assert_not_called()
        self.assertFalse(self.path.exists())

    def test_real_queue_lease_model_mock_pass_receipt(self):
        result, recorded = self._model_call()
        self.assertEqual(result["action"], "PASS_SCOPED")
        self.assertEqual(result["model_calls"], 1)
        self.assertTrue(result["lease_closed"])
        self.assertEqual(len(result["receipt_sha256"]), 64)
        self.assertEqual(len(recorded), 1)
        cmd,options = recorded[0]
        self.assertEqual(cmd[0:2], ["/opt/mock/codex", "exec"])
        self.assertEqual(cmd[cmd.index("--model")+1], MODEL)
        self.assertEqual(cmd[cmd.index("--sandbox")+1], "read-only")
        for arg in ("--ephemeral", "--ignore-user-config", "--skip-git-repo-check"):
            self.assertIn(arg, cmd)
        self.assertIs(options["stdin"], __import__("subprocess").DEVNULL)
        self.assertIs(options["stdout"], __import__("subprocess").DEVNULL)
        self.assertTrue(options["start_new_session"])
        self.assertNotIn("GITHUB_TOKEN", options["env"])
        db = connect(self.path)
        data = snapshot(db)
        self.assertEqual([e["action"] for e in data["events"]],
                         ["ADMITTED","LEASED","STOPPED"])
        self.assertEqual(data["tasks"][0]["provider"], CODEX_PROVIDER)
        self.assertEqual(data["tasks"][0]["max_attempts"], 1)
        db.close()

    def test_replay_no_second_model_call(self):
        self._model_call()
        with mock.patch("codex_readonly_pilot.subprocess.Popen") as popen:
            result = run_once(self.path, owner_admission=CODEX_ADMISSION)
            self.assertEqual(result["action"], "NOOP")
            self.assertEqual(result["model_calls"], 0)
            popen.assert_not_called()

    def test_wrong_answer_stops_without_retry(self):
        result, _ = self._model_call(marker="incorrect")
        self.assertEqual(result["action"], "STOP_FAILED")
        self.assertTrue(result["lease_closed"])
        with mock.patch("codex_readonly_pilot.subprocess.Popen") as popen:
            self.assertEqual(run_once(self.path, owner_admission=CODEX_ADMISSION)["action"], "NOOP")
            popen.assert_not_called()

    def test_quota_or_model_failure_no_fallback(self):
        result, records = self._model_call(marker=None, exit_code=42)
        self.assertEqual(result["action"], "STOP_FAILED")
        self.assertEqual(len(records), 1)
        self.assertEqual(result["model"], MODEL)
        self.assertEqual(result["additional_paid_usd"], 0)

    def test_group_not_gone_preserves_active_lease(self):
        with mock.patch("codex_readonly_pilot._session_gone", return_value=False):
            with mock.patch("codex_readonly_pilot.subprocess.Popen",
                            side_effect=lambda command,**kw: MockCodexProcess(command)):
                with self.assertRaises(QueueStop):
                    run_once(self.path, owner_admission=CODEX_ADMISSION, initialize=True)
        db = connect(self.path)
        self.assertEqual(snapshot(db)["leases"][0]["status"], "ACTIVE")
        db.close()

    def test_lease_busy_no_spawn(self):
        db=connect(self.path, initialize=True)
        admit_codex_readonly_once(db, owner_admission=CODEX_ADMISSION, at=1)
        lease_once(db, worker_id="other-worker", at=2)
        db.close()
        with mock.patch("codex_readonly_pilot.subprocess.Popen") as popen:
            self.assertEqual(run_once(self.path, owner_admission=CODEX_ADMISSION)["action"], "BUSY")
            popen.assert_not_called()

    def test_same_resource_other_queue_task_is_not_codex(self):
        db=connect(self.path, initialize=True)
        from durable_queue import admit
        admit(db, task_id="m2c-standard-a", event_id="a"*64,
              branch="infra/autopilot-m2c-test", base_sha="b"*40,
              owner_admission=ADMISSION, at=1)
        claim=lease_once(db, worker_id="noncodex", at=2)
        self.assertIs(claim["codex_readonly_probe_permitted"], False)
        self.assertEqual(claim["provider"], "NONE")
        db.close()

    def test_codex_owner_gate_and_fixed_source_identity(self):
        db=connect(self.path, initialize=True)
        with self.assertRaises(QueueStop):
            admit_codex_readonly_once(db, owner_admission=ADMISSION, at=1)
        admit_codex_readonly_once(db, owner_admission=CODEX_ADMISSION, at=2)
        state=snapshot(db)["tasks"][0]
        self.assertEqual(state["branch"], CODEX_BRANCH)
        self.assertEqual(state["base_sha"], CODEX_BASE_SHA)
        self.assertEqual(state["incremental_spend_cents"], 0)
        self.assertEqual(state["provider"], CODEX_PROVIDER)
        self.assertEqual(state["max_attempts"], 1)
        db.close()

    def test_model_admission_duplicate_is_noop(self):
        db=connect(self.path, initialize=True)
        self.assertEqual(admit_codex_readonly_once(db, owner_admission=CODEX_ADMISSION, at=1)["action"], "ADMITTED")
        self.assertEqual(admit_codex_readonly_once(db, owner_admission=CODEX_ADMISSION, at=2)["action"], "NOOP")
        self.assertEqual(len(snapshot(db)["events"]), 1)
        db.close()

    def test_old_schema_version_fail_closed(self):
        db=connect(self.path, initialize=True)
        db.execute("PRAGMA user_version=1")
        db.close()
        with self.assertRaises(QueueStop):
            connect(self.path)

    def test_uninitialized_db_cannot_trigger_model(self):
        with mock.patch("codex_readonly_pilot.subprocess.Popen") as popen:
            with self.assertRaises(QueueStop):
                run_once(self.path, owner_admission=CODEX_ADMISSION)
            popen.assert_not_called()

    def test_too_long_output_is_never_success(self):
        result,_=self._model_call(marker="X"*900)
        self.assertEqual(result["action"], "STOP_FAILED")
        self.assertEqual(result["model_calls"], 1)


    def test_source_provenance_failure_before_queue_creation(self):
        with mock.patch("codex_readonly_pilot._source_preflight",
                        side_effect=QueueStop("source mismatch")):
            with mock.patch("codex_readonly_pilot.subprocess.Popen") as popen:
                with self.assertRaises(QueueStop):
                    run_once(self.path, owner_admission=CODEX_ADMISSION, initialize=True)
                popen.assert_not_called()
        self.assertFalse(self.path.exists())

    def test_missing_cli_before_queue_creation(self):
        with mock.patch("codex_readonly_pilot._codex_binary",
                        side_effect=QueueStop("unavailable")):
            with mock.patch("codex_readonly_pilot.subprocess.Popen") as popen:
                with self.assertRaises(QueueStop):
                    run_once(self.path, owner_admission=CODEX_ADMISSION, initialize=True)
                popen.assert_not_called()
        self.assertFalse(self.path.exists())

    def test_process_spawn_failure_leaves_active_lease(self):
        with mock.patch("codex_readonly_pilot.subprocess.Popen",
                        side_effect=OSError("mocked spawn unavailable")):
            with self.assertRaises(QueueStop):
                run_once(self.path, owner_admission=CODEX_ADMISSION, initialize=True)
        db = connect(self.path)
        self.assertEqual(snapshot(db)["leases"][0]["status"], "ACTIVE")
        db.close()

    def test_timeout_kills_group_and_consumes_one_attempt(self):
        import subprocess
        class TimedOutProcess:
            pid = 123456
            returncode = None
            waits = 0
            def wait(self, timeout=None):
                self.waits += 1
                if self.waits == 1:
                    raise subprocess.TimeoutExpired("codex",timeout)
                self.returncode = -9
                return -9
            def poll(self):
                return self.returncode
        proc = TimedOutProcess()
        with mock.patch("codex_readonly_pilot.subprocess.Popen",return_value=proc):
            with mock.patch("codex_readonly_pilot.os.killpg") as kill:
                result=run_once(self.path,owner_admission=CODEX_ADMISSION, initialize=True)
                kill.assert_called_once()
        self.assertEqual(result["action"],"STOP_FAILED")
        self.assertTrue(result["stop_verified"])
        self.assertEqual(result["model_calls"],1)
        db=connect(self.path)
        self.assertEqual(snapshot(db)["tasks"][0]["attempts"],1)
        db.close()

    def test_env_prunes_api_keys(self):
        from codex_readonly_pilot import _safe_env
        with mock.patch.dict("codex_readonly_pilot.os.environ",
                             {"OPENAI_API_KEY":"do-not-pass",
                              "GITHUB_TOKEN":"secret",
                              "ANTHROPIC_API_KEY":"not-for-child",
                              "PATH":"/usr/bin:/bin"}, clear=True):
            env=_safe_env()
            self.assertEqual(env["PATH"],"/usr/bin:/bin")
            self.assertNotIn("OPENAI_API_KEY",env)
            self.assertNotIn("GITHUB_TOKEN",env)
            self.assertNotIn("ANTHROPIC_API_KEY",env)


if __name__ == "__main__":
    unittest.main()
