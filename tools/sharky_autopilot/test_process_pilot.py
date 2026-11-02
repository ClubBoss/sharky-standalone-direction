"""M2D real-child offline pilot: process exit and lease closure proof."""
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest import mock
import sqlite3
import subprocess
import sys
import unittest

from durable_queue import (
    ADMISSION, acknowledge_stopped, admit, connect, lease_once, snapshot,
)
from process_pilot import (
    BASE_SHA, BRANCH, EVENT, TASK, _session_gone, run_offline_process_probe,
)


class ProcessPilotTests(unittest.TestCase):
    def setUp(self):
        self.temp = TemporaryDirectory()
        self.path = Path(self.temp.name) / "m2d.db"

    def tearDown(self):
        self.temp.cleanup()

    def test_real_child_stopped_and_resource_closed(self):
        receipt = run_offline_process_probe(self.path, initialize=True)
        self.assertEqual(receipt["action"], "PROBE_COMPLETE")
        self.assertEqual(receipt["process_exit"], 0)
        self.assertTrue(receipt["process_reaped"])
        self.assertEqual(len(receipt["witness_sha256"]), 64)
        db = connect(self.path)
        data = snapshot(db)
        self.assertEqual([x["action"] for x in data["events"]],
                         ["ADMITTED", "LEASED", "STOPPED"])
        self.assertEqual(data["leases"][0]["status"], "CLOSED")
        self.assertEqual(data["tasks"][0]["provider"], "NONE")
        db.close()

    def test_second_launch_is_noop_no_second_process(self):
        run_offline_process_probe(self.path, initialize=True)
        with mock.patch("process_pilot.subprocess.Popen") as popen:
            result = run_offline_process_probe(self.path)
            self.assertEqual(result["action"], "NOOP")
            popen.assert_not_called()

    def test_missing_db_cannot_be_recreated(self):
        with self.assertRaises(RuntimeError):
            run_offline_process_probe(self.path)
        self.assertFalse(self.path.exists())

    def test_existing_db_initialization_denied(self):
        run_offline_process_probe(self.path, initialize=True)
        with self.assertRaises(RuntimeError):
            run_offline_process_probe(self.path, initialize=True)

    def test_busy_lease_prevents_child_process(self):
        db = connect(self.path, initialize=True)
        admit(db, task_id=TASK, event_id=EVENT, branch=BRANCH,
              base_sha=BASE_SHA, owner_admission=ADMISSION, at=1)
        lease_once(db, worker_id="someone-else", at=2)
        db.close()
        with mock.patch("process_pilot.subprocess.Popen") as popen:
            result = run_offline_process_probe(self.path)
            self.assertEqual(result["action"], "BUSY")
            popen.assert_not_called()

    def test_living_child_never_has_valid_stop_proof(self):
        proc = subprocess.Popen(
            [sys.executable, "-I", "-c", "import time;time.sleep(10)"],
            start_new_session=True, stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        try:
            self.assertFalse(_session_gone(proc))
        finally:
            import os
            os.killpg(proc.pid, 9)
            proc.wait(timeout=3)
        self.assertTrue(_session_gone(proc))

    def test_wrong_output_leaves_lease_busy(self):
        with mock.patch("process_pilot.EXPECTED", b"not-the-real-output"):
            with self.assertRaises(RuntimeError):
                run_offline_process_probe(self.path, initialize=True)
        db = connect(self.path)
        self.assertEqual(snapshot(db)["leases"][0]["status"], "ACTIVE")
        db.close()

    def test_output_identity_and_test_scope_only(self):
        self.assertEqual(BRANCH, "infra/autopilot-m2d-process-20261102")
        self.assertEqual(len(BASE_SHA), 40)
        self.assertEqual(len(EVENT), 64)
        self.assertNotEqual(TASK, "m2c-product-writer")


if __name__ == "__main__":
    unittest.main()
