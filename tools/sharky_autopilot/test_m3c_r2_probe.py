"""M3C R2 one-shot diagnostic falsifiers; all model calls are mocked."""
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest import mock
import json
import plistlib
import subprocess
import unittest

import m3c_autostart_probe as launcher
from durable_queue import M3C_TASK, M3C_R2_TASK, QueueStop, connect, snapshot

OLD_MARKER = "SHARKY_M3C_UNATTENDED_READONLY_QUEUE_OK"
NEW_MARKER = "SHARKY_M3C_R2_UNATTENDED_READONLY_OK"


class FakeOldChild:
    pid = 77121
    returncode = 42

    def __init__(self, cmd, **kw):
        self.cmd = cmd

    def wait(self, timeout=None):
        return self.returncode

    def poll(self):
        return self.returncode


class FakeR2Child:
    pid = 77122
    returncode = 0

    def __init__(self, cmd, **kw):
        self.cmd = cmd
        self.calls = 0

    def communicate(self, timeout=None):
        self.calls += 1
        out = Path(self.cmd[self.cmd.index("--output-last-message") + 1])
        out.write_text(NEW_MARKER, encoding="utf-8")
        lines = (
            '{"type":"thread.started","thread_id":"irrelevant"}\n'
            '{"type":"turn.started"}\n'
            '{"type":"turn.completed","usage":{"input_tokens":3}}\n'
        )
        return lines.encode("utf-8"), b""

    def poll(self):
        return self.returncode


class FakeR2Timeout(FakeR2Child):
    def communicate(self, timeout=None):
        self.calls += 1
        if self.calls == 1:
            raise subprocess.TimeoutExpired("codex", timeout)
        self.returncode = -9
        return b'{"type":"thread.started"}\n', b""

class R2Tests(unittest.TestCase):
    def setUp(self):
        self.tmp = TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name)
        (self.home/"Sharky_Autopilot_Pilot").mkdir()
        for p in (
            mock.patch("m3c_autostart_probe.Path.home", return_value=self.home),
            mock.patch("m3c_autostart_probe._root", return_value=Path(__file__).resolve().parents[2]),
            mock.patch("codex_readonly_pilot._source_preflight"),
            mock.patch("codex_readonly_pilot._codex_binary", return_value="/opt/mock/codex"),
            mock.patch("codex_readonly_pilot._session_gone", return_value=True),
        ):
            p.start()
            self.addCleanup(p.stop)

    def consume_original(self):
        launcher.prepare_plist()
        with mock.patch("codex_readonly_pilot.subprocess.Popen", side_effect=FakeOldChild) as popen:
            old = launcher.run_once()
            popen.assert_called_once()
        self.assertEqual(old["action"], "STOP_FAILED")
        return self.home/"Sharky_Autopilot_Pilot/m3c_state"

    def test_r2_cannot_arm_without_original_consumed(self):
        launcher.prepare_plist()
        with self.assertRaises(QueueStop):
            launcher.prepare_r2_plist()

    def test_r2_one_model_then_replay_noop_same_db(self):
        state=self.consume_original()
        result=launcher.prepare_r2_plist()
        self.assertEqual(result["action"], "R2_ARMED_NOT_STARTED")
        plist=plistlib.loads(Path(result["plist"]).read_bytes())
        self.assertEqual(plist["ProgramArguments"][-1], "--run-r2")
        self.assertFalse(plist["KeepAlive"])
        self.assertTrue(plist["RunAtLoad"])
        with mock.patch("codex_readonly_pilot.subprocess.Popen", side_effect=FakeR2Child) as child:
            x=launcher.run_r2_once()
            child.assert_called_once()
            args=child.call_args.args[0]
            self.assertIn("--json",args)
            self.assertIn("read-only",args)
        self.assertEqual(x["action"],"PASS_SCOPED")
        receipt=json.loads((state/launcher.R2_STOP_FILENAME).read_text())
        self.assertEqual(receipt["failure_class"],"NONE")
        self.assertEqual(receipt["stderr_class"],"NONE")
        self.assertTrue(receipt["progress"]["thread_started"])
        self.assertTrue(receipt["progress"]["turn_started"])
        self.assertTrue(receipt["progress"]["turn_completed"])
        self.assertFalse(receipt["progress"]["error_event"])
        self.assertNotIn(NEW_MARKER,repr(receipt))
        db=connect(state/launcher.DATABASE)
        snap=snapshot(db)
        db.close()
        self.assertEqual([t["id"] for t in snap["tasks"]], [M3C_TASK,M3C_R2_TASK])
        self.assertEqual([t["attempts"] for t in snap["tasks"]],[1,1])
        self.assertEqual([l["status"] for l in snap["leases"]],["CLOSED","CLOSED"])
        with mock.patch("codex_readonly_pilot.subprocess.Popen") as child:
            replay=launcher.run_r2_once()
            child.assert_not_called()
        self.assertEqual(replay["action"],"NOOP")
        self.assertEqual(replay["model_calls"],0)

    def test_r2_timeout_consumes_only_new_attempt(self):
        state=self.consume_original()
        launcher.prepare_r2_plist()
        with mock.patch("codex_readonly_pilot.os.killpg") as killed:
            with mock.patch("codex_readonly_pilot.subprocess.Popen",side_effect=FakeR2Timeout) as child:
                x=launcher.run_r2_once()
                child.assert_called_once()
            killed.assert_called_once()
        self.assertEqual(x["action"],"STOP_FAILED")
        receipt=json.loads((state/launcher.R2_STOP_FILENAME).read_text())
        self.assertEqual(receipt["failure_class"],"TIMEOUT")
        self.assertTrue(receipt["timed_out"])
        self.assertTrue(receipt["progress"]["thread_started"])
        with mock.patch("codex_readonly_pilot.subprocess.Popen") as child:
            self.assertEqual(launcher.run_r2_once()["action"],"NOOP")
            child.assert_not_called()

    def test_r2_no_rearming_or_fresh_queue(self):
        self.consume_original()
        launcher.prepare_r2_plist()
        with self.assertRaises(QueueStop):
            launcher.prepare_r2_plist()

    def test_r2_stop_uncertain_never_reclaimed(self):
        state=self.consume_original()
        launcher.prepare_r2_plist()
        with mock.patch("codex_readonly_pilot._session_gone",return_value=False):
            with mock.patch("codex_readonly_pilot.subprocess.Popen",side_effect=FakeR2Child):
                with self.assertRaises(QueueStop):
                    launcher.run_r2_once()
        db=connect(state/launcher.DATABASE)
        data=snapshot(db)
        db.close()
        self.assertEqual(data["leases"][-1]["status"],"ACTIVE")


if __name__=="__main__":
    unittest.main()
