#!/usr/bin/env python3
"""Bounded no-SDK regression for checkpoint full-suite terminal truth."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
BASH = Path("/opt/homebrew/bin/bash")
if not BASH.exists():
    BASH = Path(shutil.which("bash") or "/bin/bash")

FAKE_FLUTTER = """#!/usr/bin/env bash
set -eu
if [ "$1" != "test" ]; then exit 77; fi
case "$MOCK_FULL_SUITE" in
  good)
    echo '00:03 +2: All tests passed!'
    ;;
  good_with_skip)
    echo '00:03 +2 ~1: All tests passed!'
    ;;
  interrupted_zero)
    echo '00:03 +2 -1: failing testcase [E]'
    exit 0
    ;;
  errors_then_success_zero)
    echo '00:03 +2 -1: failing testcase [E]'
    echo '00:03 +2: All tests passed!'
    exit 0
    ;;
  negative_count_zero)
    echo '00:03 +2 -1: bad testcase'
    echo '00:03 +2: All tests passed!'
    exit 0
    ;;
  incomplete_zero)
    echo '00:03 +2: loading some more tests'
    exit 0
    ;;
  nonzero)
    echo '00:03 +2 -1: failure [E]'
    exit 42
    ;;
  *)
    echo 'unexpected test mode' >&2
    exit 77
    ;;
esac
"""


class ReleaseGateFullSuiteCompletionFixtures(unittest.TestCase):
    def invoke(self, mode: str):
        with tempfile.TemporaryDirectory(prefix="sharky-checkpoint-contract-") as tmp:
            base = Path(tmp)
            (base / "tools").mkdir()
            (base / "mockbin").mkdir()
            (base / "pubspec.yaml").write_text("name: synthetic_only\n")
            for name in ("release_gate_world1.sh", "_test_policy_v1.sh",
                         "_fast_loop_test_tiers_v1.sh", "collect_changeset_v1.py"):
                shutil.copy2(ROOT / "tools" / name, base / "tools" / name)
            stub = base / "tools" / "fast_loop_world1_v1.sh"
            stub.write_text("#!/usr/bin/env bash\nexit 0\n")
            stub.chmod(0o755)
            flutter_stub = base / "mockbin" / "flutter"
            flutter_stub.write_text(FAKE_FLUTTER)
            flutter_stub.chmod(0o755)
            subprocess.run(
                ["git", "init", "-q"], cwd=base, check=True, capture_output=True
            )
            subprocess.run(
                ["git", "-c", "user.name=fixture", "-c",
                 "user.email=fixture@example.invalid", "commit", "-q",
                 "--allow-empty", "-m", "synthetic root"],
                cwd=base, check=True, capture_output=True
            )
            head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=base, text=True).strip()
            # The synthetic repo owns its event context; ambient CI must not select a real PR.
            clean = {k: v for k, v in os.environ.items() if not k.startswith(
                ("GITHUB_", "SHARKY_", "FAST_LOOP_", "TEST_POLICY_", "GIT_"))}
            env = {
                **clean,
                "GIT_CONFIG_GLOBAL": os.devnull, "GIT_CONFIG_NOSYSTEM": "1",
                "SHARKY_CHANGE_MODE": "pr", "SHARKY_CHANGE_BASE": head,
                "SHARKY_CHANGE_HEAD": head, "SHARKY_CHANGE_CANDIDATE": head,
                "PATH": str(base / "mockbin") + os.pathsep + os.environ["PATH"],
                "MOCK_FULL_SUITE": mode,
                "CHECKPOINT": "1",
            }
            # Production policy in this fixture uses exactly the same --checkpoint.
            run = subprocess.run(
                [str(BASH), "tools/release_gate_world1.sh", "--checkpoint"],
                cwd=base, env=env, capture_output=True, text=True, timeout=20
            )
            saved = list((base / "build" / "test_authority").glob("world1_full_suite.*"))
            self.assertEqual(len(saved), 1, (mode, run.stdout, run.stderr))
            return run

    def test_complete_pass_with_no_failures(self):
        r = self.invoke("good")
        self.assertEqual(r.returncode, 0, (r.stdout, r.stderr))
        self.assertIn("verified COMPLETE", r.stdout)

    def test_complete_with_a_skipped_test_not_fabricated_as_failure(self):
        r = self.invoke("good_with_skip")
        self.assertEqual(r.returncode, 0, (r.stdout, r.stderr))
        self.assertIn("verified COMPLETE", r.stdout)

    def test_interrupted_runner_that_exits_zero_fails_closed(self):
        r = self.invoke("interrupted_zero")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("terminal PASS receipt missing", r.stderr)

    def test_error_markers_block_fake_terminal_pass(self):
        r = self.invoke("errors_then_success_zero")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("failures present despite command exit 0", r.stderr)

    def test_failure_counter_blocks_fabricated_terminal_pass(self):
        r = self.invoke("negative_count_zero")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("failures present despite command exit 0", r.stderr)

    def test_unfinished_output_exit_zero_is_not_pass(self):
        r = self.invoke("incomplete_zero")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("terminal PASS receipt missing", r.stderr)

    def test_actual_nonzero_exit_is_retained(self):
        r = self.invoke("nonzero")
        self.assertEqual(r.returncode, 42)
        self.assertIn("full-suite command exit=42", r.stderr)


if __name__ == "__main__":
    unittest.main()
