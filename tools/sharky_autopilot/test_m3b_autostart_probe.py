"""M3B unattended OFFLINE local cycle safety tests: model dispatch always OFF."""
from pathlib import Path
from tempfile import TemporaryDirectory
import json
import os
import plistlib
import unittest
from unittest import mock

import m3b_autostart_probe as pilot
from durable_queue import QueueStop, connect, snapshot


class AutoStartTests(unittest.TestCase):
    def setUp(self):
        self.tmp = TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        self.parent = self.home / "Sharky_Autopilot_Pilot"
        self.parent.mkdir(mode=0o700)
        self.h = mock.patch("m3b_autostart_probe.Path.home", return_value=self.home)
        self.root = mock.patch("m3b_autostart_probe._root",
                               return_value=Path(__file__).resolve().parents[2])
        self.h.start()
        self.root.start()
        self.addCleanup(self.h.stop)
        self.addCleanup(self.root.stop)

    def _arm(self):
        return pilot.prepare_plist()

    def test_prepare_creates_job_but_does_not_register(self):
        with mock.patch("m3b_autostart_probe.subprocess.run") as run:
            out = self._arm()
            run.assert_not_called()
        self.assertEqual(out["action"], "ARMED_NOT_STARTED")
        path = Path(out["plist"])
        self.assertTrue(path.is_file())
        data = plistlib.loads(path.read_bytes())
        self.assertTrue(data["RunAtLoad"])
        self.assertFalse(data["KeepAlive"])
        self.assertEqual(data["ProgramArguments"][-1], "--run")
        self.assertIn("-E", data["ProgramArguments"])
        self.assertIn("-s", data["ProgramArguments"])
        self.assertNotIn("codex", " ".join(data["ProgramArguments"]).lower())
        self.assertTrue(data["StandardOutPath"].startswith(str(self.home)))
        self.assertEqual(path.stat().st_mode & 0o077, 0)
        self.assertFalse((path.parent / pilot.DATABASE).exists())

    def test_initial_arming_is_never_duplicated(self):
        self._arm()
        with self.assertRaises(QueueStop):
            self._arm()

    def test_unarmed_invocation_hard_stops(self):
        with self.assertRaises(QueueStop):
            pilot.run_once()

    def test_real_offline_child_and_durable_lease(self):
        self._arm()
        result = pilot.run_once()
        self.assertEqual(result["action"], "PROBE_COMPLETE")
        self.assertEqual(result["model_calls"], 0)
        self.assertEqual(result["autonomous_model_dispatch"], "OFF")
        state = self.parent / "m3b_state"
        evidence = json.loads((state / pilot.STOP_FILENAME).read_text())
        self.assertEqual(evidence["action"], "OFFLINE_CYCLE_PASS")
        self.assertEqual(evidence["model_calls"], 0)
        db = connect(state / pilot.DATABASE)
        data = snapshot(db)
        self.assertEqual(data["tasks"][0]["status"], "STOPPED")
        self.assertEqual(data["tasks"][0]["attempts"], 1)
        self.assertEqual(data["leases"][0]["status"], "CLOSED")
        self.assertEqual([e["action"] for e in data["events"]],
                         ["ADMITTED", "LEASED", "STOPPED"])
        db.close()

    def test_restart_noop_prevents_second_child(self):
        self._arm()
        self.assertEqual(pilot.run_once()["action"], "PROBE_COMPLETE")
        with mock.patch("process_pilot.subprocess.Popen") as child:
            replay = pilot.run_once()
            child.assert_not_called()
        self.assertEqual(replay["action"], "NOOP")
        self.assertEqual(replay["model_calls"], 0)

    def test_busy_lease_prevents_child(self):
        self._arm()
        state = self.parent / "m3b_state"
        from durable_queue import ADMISSION, admit, lease_once
        from process_pilot import TASK, EVENT, BRANCH, BASE_SHA
        db = connect(state / pilot.DATABASE, initialize=True)
        admit(db, task_id=TASK, event_id=EVENT,
              branch=BRANCH, base_sha=BASE_SHA,
              owner_admission=ADMISSION, at=1)
        lease_once(db, worker_id="other-worker", at=2)
        db.close()
        with mock.patch("process_pilot.subprocess.Popen") as child:
            r = pilot.run_once()
            child.assert_not_called()
        self.assertEqual(r["action"], "BUSY")

    def test_missing_or_symlinked_state_denied(self):
        outside=Path(self.tmp.name)/"outside"
        outside.mkdir()
        (self.parent/"m3b_state").symlink_to(outside, target_is_directory=True)
        with self.assertRaises(QueueStop):
            self._arm()

    def test_symlinked_db_denied(self):
        self._arm()
        state=self.parent/"m3b_state"
        (state/pilot.DATABASE).symlink_to("/tmp/target-do-not-write")
        with self.assertRaises(QueueStop):
            pilot.run_once()

    def test_private_state_required(self):
        self._arm()
        state=self.parent/"m3b_state"
        os.chmod(state, 0o755)
        with self.assertRaises(QueueStop):
            pilot.run_once()

    def test_not_prepared_without_exact_provenance(self):
        with mock.patch("m3b_autostart_probe._root", side_effect=QueueStop("bad SHA")):
            with self.assertRaises(QueueStop):
                self._arm()
        self.assertFalse((self.parent/"m3b_state").exists())

    def test_readback_before_and_after_run(self):
        self._arm()
        self.assertEqual(pilot.status()["action"], "ARMED_NO_EXECUTION")
        pilot.run_once()
        data=pilot.status()
        self.assertEqual(data["action"], "READBACK")
        self.assertEqual(data["leases"], ["CLOSED"])
        self.assertEqual(data["events"], ["ADMITTED","LEASED","STOPPED"])


if __name__ == "__main__":
    unittest.main()
