#!/usr/bin/env python3
"""No-SDK check of checkpoint routing and exact explicit legacy boundaries."""
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

STUB = """#!/usr/bin/env bash
set -euo pipefail
printf '%s %s\n' "__LABEL__" "$*" >> "$TRACE_FILE"
exit "$MOCK_RC"
"""


class CheckpointCanonicalRoutingFixtures(unittest.TestCase):
    def invoke(self, args=(), extra_env=None, rc=0, remove_canonical=False):
        with tempfile.TemporaryDirectory(prefix="sharky-checkpoint-route-") as tmp:
            work = Path(tmp)
            (work / "tools").mkdir()
            (work / "pubspec.yaml").write_text("name: synthetic_fixture\n")
            shutil.copy2(ROOT / "tools/checkpoint_world1_v1.sh",
                         work / "tools/checkpoint_world1_v1.sh")
            for path, label in (
                ("test_authority_canonical_lane_v1.sh", "canonical"),
                ("release_gate_world1.sh", "legacy-global"),
                ("checkpoint_world1_v1_capture.sh", "capture"),
            ):
                if remove_canonical and label == "canonical":
                    continue
                dest = work / "tools" / path
                dest.write_text(STUB.replace("__LABEL__", label).replace("$", "$"))
                dest.chmod(0o755)
            trace = work / "trace.txt"
            env = dict(os.environ)
            for key in ("CAPTURE", "CHECKPOINT"):
                env.pop(key, None)
            env.update(TRACE_FILE=str(trace), MOCK_RC=str(rc))
            if extra_env:
                env.update(extra_env)
            proc = subprocess.run(
                [str(BASH), "tools/checkpoint_world1_v1.sh", *args],
                cwd=work, env=env, text=True,
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=10
            )
            return proc, trace.read_text().splitlines() if trace.exists() else []

    def test_default_runs_existing_canonical_authority_only(self):
        result, trace = self.invoke()
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(trace, ["canonical "])
        self.assertIn("Tier A + terminal Tier B", result.stdout)

    def test_failing_canonical_authority_blocks(self):
        result, trace = self.invoke(rc=9)
        self.assertEqual(result.returncode, 9)
        self.assertEqual(trace, ["canonical "])

    def test_missing_canonical_does_not_fallback_to_legacy_or_pass(self):
        result, trace = self.invoke(remove_canonical=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(trace, [])

    def test_explicit_legacy_global_flag_runs_unshortened_old_gate(self):
        result, trace = self.invoke(args=("--legacy-global",))
        self.assertEqual(result.returncode, 0)
        self.assertEqual(trace, ["legacy-global --checkpoint"])

    def test_explicit_checkpoint_preserves_old_full_suite(self):
        result, trace = self.invoke(args=("--checkpoint",), rc=3)
        self.assertEqual(result.returncode, 3)
        self.assertEqual(trace, ["legacy-global --checkpoint"])

    def test_explicit_environment_checkpoint_preserves_old_full_suite(self):
        result, trace = self.invoke(extra_env={"CHECKPOINT": "1"})
        self.assertEqual(result.returncode, 0)
        self.assertEqual(trace, ["legacy-global --checkpoint"])

    def test_capture_diagnostic_retains_original_repeat_flag(self):
        result, trace = self.invoke(args=("--repeat", "2"),
                                    extra_env={"CAPTURE": "1"})
        self.assertEqual(result.returncode, 0)
        self.assertEqual(trace, ["capture --repeat 2"])

    def test_unknown_arguments_cannot_invoke_any_gate(self):
        result, trace = self.invoke(args=("--no-tests",))
        self.assertEqual(result.returncode, 2)
        self.assertEqual(trace, [])

    def test_explicit_full_with_extra_args_fails_closed(self):
        result, trace = self.invoke(args=("--full", "--no-tests"))
        self.assertEqual(result.returncode, 2)
        self.assertEqual(trace, [])

    def test_real_canonical_shell_retains_tier_a_and_b_execution(self):
        canonical = (ROOT / "tools/test_authority_canonical_lane_v1.sh").read_text()
        self.assertIn("./tools/test_authority_validate_v1.sh", canonical)
        self.assertIn("./tools/test_authority_tier_a_v1.sh", canonical)
        self.assertIn("./tools/test_authority_tier_b_v1.sh", canonical)


if __name__ == "__main__":
    unittest.main()
