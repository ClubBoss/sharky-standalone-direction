"""M3C bounded integration tests. Model subprocess mocked; never calls Codex."""
from pathlib import Path
from tempfile import TemporaryDirectory
import json
import plistlib
import unittest
from unittest import mock

import m3c_autostart_probe as a
from durable_queue import M3C_TASK, connect, snapshot

MARKER = "SHARKY_M3C_UNATTENDED_READONLY_QUEUE_OK"


class FakeChild:
    pid = 41234
    returncode = 0

    def __init__(self, command, **kwargs):
        self.command = command

    def wait(self, timeout=None):
        p = Path(self.command[self.command.index("--output-last-message") + 1])
        p.write_text(MARKER)
        return 0

    def poll(self):
        return 0


class M3CContractTests(unittest.TestCase):
    def setUp(self):
        self.tmp = TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        (self.home / "Sharky_Autopilot_Pilot").mkdir()
        for p in (
            mock.patch("m3c_autostart_probe.Path.home", return_value=self.home),
            mock.patch("m3c_autostart_probe._root", return_value=Path(__file__).resolve().parents[2]),
            mock.patch("codex_readonly_pilot._source_preflight"),
            mock.patch("codex_readonly_pilot._codex_binary", return_value="/opt/mock/codex"),
            mock.patch("codex_readonly_pilot._session_gone", return_value=True),
        ):
            p.start()
            self.addCleanup(p.stop)

    def test_arm_and_run_once(self):
        receipt = a.prepare_plist()
        self.assertEqual(receipt["action"], "ARMED_NOT_STARTED")
        job = plistlib.loads(Path(receipt["plist"]).read_bytes())
        self.assertTrue(job["RunAtLoad"])
        self.assertFalse(job["KeepAlive"])
        self.assertNotIn("StartInterval", job)
        with mock.patch("codex_readonly_pilot.subprocess.Popen", side_effect=FakeChild) as child:
            result = a.run_once()
            child.assert_called_once()
        self.assertEqual(result["action"], "PASS_SCOPED")
        self.assertEqual(result["model_calls"], 1)
        state = self.home / "Sharky_Autopilot_Pilot/m3c_state"
        db = connect(state / a.DATABASE)
        s = snapshot(db)
        db.close()
        self.assertEqual(s["tasks"][0]["id"], M3C_TASK)
        self.assertEqual(s["tasks"][0]["attempts"], 1)
        self.assertEqual(s["tasks"][0]["status"], "STOPPED")
        self.assertEqual(s["leases"][0]["status"], "CLOSED")
        self.assertEqual([e["action"] for e in s["events"]], ["ADMITTED", "LEASED", "STOPPED"])
        self.assertEqual(json.loads((state / a.STOP_FILENAME).read_text())["model_calls"], 1)
        with mock.patch("codex_readonly_pilot.subprocess.Popen") as child:
            again = a.run_once()
            child.assert_not_called()
        self.assertEqual(again["action"], "NOOP")
        self.assertEqual(again["model_calls"], 0)

    def test_unarmed_stop(self):
        with self.assertRaises(Exception):
            a.run_once()

    def test_exact_source_gate(self):
        with mock.patch("m3c_autostart_probe._root", side_effect=RuntimeError("STOP")):
            with self.assertRaises(RuntimeError):
                a.prepare_plist()


    def test_inflight_lease_blocks_model_launch(self):
        from durable_queue import M3C_ADMISSION, admit_m3c_readonly_once, lease_once
        a.prepare_plist()
        state = self.home / "Sharky_Autopilot_Pilot/m3c_state"
        db = connect(state / a.DATABASE, initialize=True)
        admit_m3c_readonly_once(db, owner_admission=M3C_ADMISSION, at=1)
        lease_once(db, worker_id="other-worker", at=2)
        db.close()
        with mock.patch("codex_readonly_pilot.subprocess.Popen") as child:
            result = a.run_once()
            child.assert_not_called()
        self.assertEqual(result["action"], "BUSY")
        self.assertEqual(result["model_calls"], 0)

    def test_model_nonzero_exit_is_one_attempt_no_fallback(self):
        a.prepare_plist()
        class FailingChild(FakeChild):
            def wait(self, timeout=None):
                self.returncode = 42
                return 42
        with mock.patch("codex_readonly_pilot.subprocess.Popen", side_effect=FailingChild) as model:
            self.assertEqual(a.run_once()["action"], "STOP_FAILED")
            model.assert_called_once()
        with mock.patch("codex_readonly_pilot.subprocess.Popen") as model:
            self.assertEqual(a.run_once()["action"], "NOOP")
            model.assert_not_called()

    def test_stop_uncertain_retains_exclusive_lease(self):
        a.prepare_plist()
        with mock.patch("codex_readonly_pilot._session_gone", return_value=False):
            with mock.patch("codex_readonly_pilot.subprocess.Popen", side_effect=FakeChild):
                with self.assertRaises(Exception):
                    a.run_once()
        state = self.home / "Sharky_Autopilot_Pilot/m3c_state"
        db = connect(state / a.DATABASE)
        self.assertEqual(snapshot(db)["leases"][0]["status"], "ACTIVE")
        db.close()

    def test_source_profile_exact_identity(self):
        a.prepare_plist()
        with mock.patch("codex_readonly_pilot.subprocess.Popen", side_effect=FakeChild):
            with mock.patch("codex_readonly_pilot._source_preflight") as source:
                a.run_once()
        source.assert_called_once_with(
            branch_name="infra/autopilot-m3c-readonly-20261102",
            base_sha="9dd166568b12758bd6c797a38dae5b8758f61c54")


if __name__ == "__main__":
    unittest.main()
