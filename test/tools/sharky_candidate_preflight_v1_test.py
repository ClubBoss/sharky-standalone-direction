"""Offline tests for opt-in SHA-pinned preflight; no Flutter SDK."""
from __future__ import annotations

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "sharky_candidate_preflight_v1.sh"


class ExactCandidatePreflightTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.parent = Path(self.tmp.name)
        self.repo = self.parent / "repo"
        self.repo.mkdir()
        self.bin = self.parent / "bin"
        self.bin.mkdir()
        self.trace = self.parent / "trace"
        self.git("init", "-q", "-b", "main")
        self.git("config", "user.email", "pilot@example.invalid")
        self.git("config", "user.name", "Pilot")
        (self.repo / "tools").mkdir()
        (self.repo / "lib").mkdir()
        shutil.copy2(SCRIPT, self.repo / "tools" / SCRIPT.name)
        (self.repo / "tools" / "sharky_compact_evidence_v1.sh").write_text(
            '#!/usr/bin/env bash\n'
            'set -euo pipefail\n'
            'id=""\n'
            'dir=""\n'
            'while [[ "$1" != "--" ]]; do\n'
            '  case "$1" in\n'
            '    --id) id="$2"; shift 2 ;;\n'
            '    --dir) dir="$2"; shift 2 ;;\n'
            '    *) exit 2 ;;\n'
            '  esac\n'
            'done\n'
            'shift\n'
            'mkdir -p "$dir"\n'
            'set +e\n'
            '"$@" > "$dir/$id.raw.log" 2>&1\n'
            'status=$?\n'
            'set -e\n'
            'printf "exit=%s\\n" "$status" > "$dir/$id.summary.log"\n'
            'exit "$status"\n',
            encoding="utf-8",
        )
        (self.repo / "lib" / "example.dart").write_text("void main() {}\n")
        (self.repo / ".gitignore").write_text("output/\n")
        self.git("add", ".")
        self.git("commit", "-qm", "base")
        self.base_sha = self.git("rev-parse", "HEAD").stdout.strip()
        self.git("switch", "-qc", "pilot/isolated")
        (self.repo / "lib" / "example.dart").write_text(
            "void main() { print(1); }\n"
        )
        self.git("add", ".")
        self.git("commit", "-qm", "candidate")
        self.head_sha = self.git("rev-parse", "HEAD").stdout.strip()
        for name in ("dart", "flutter"):
            executable = self.bin / name
            executable.write_text(
                '#!/usr/bin/env bash\n'
                'echo "' + name + ' $*" >> "$TRACE"\n'
                'if [[ "$MOCK_FAIL" == "' + name + '" ]]; then exit 17; fi\n'
                'exit 0\n'
            )
            executable.chmod(0o755)

    def git(self, *args):
        return subprocess.run(
            ["git", *args], cwd=self.repo, capture_output=True,
            text=True, check=True
        )

    def run_preflight(self, *extra, fail=""):
        env = os.environ.copy()
        env["PATH"] = str(self.bin) + os.pathsep + env["PATH"]
        env["TRACE"] = str(self.trace)
        env["MOCK_FAIL"] = fail
        return subprocess.run(
            ["bash", str(self.repo / "tools" / SCRIPT.name),
             "--base", self.base_sha, "--head", self.head_sha, *extra],
            cwd=self.repo, env=env, text=True, capture_output=True,
        )

    def test_default_is_read_only_plan(self):
        result = self.run_preflight()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("MODE=PLAN_ONLY", result.stdout)
        self.assertIn("SOURCE_TESTS=NOT_RUN", result.stdout)
        self.assertIn("CHANGED_DART_COUNT=1", result.stdout)
        self.assertFalse(self.trace.exists())

    def test_static_orders_format_before_analyze(self):
        result = self.run_preflight("--run-static")
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertIn("STATIC_PREFLIGHT=PASS_SCOPED", result.stdout)
        lines = self.trace.read_text().splitlines()
        self.assertEqual(len(lines), 2)
        self.assertTrue(lines[0].startswith(
            "dart format --output=none --set-exit-if-changed "
        ))
        self.assertEqual(lines[1], "flutter analyze")

    def test_wrong_head_fails_closed(self):
        self.head_sha = "0" * 40
        result = self.run_preflight("--run-static")
        self.assertEqual(result.returncode, 3)
        self.assertIn("HEAD_MISMATCH", result.stderr)
        self.assertFalse(self.trace.exists())

    def test_dirty_checkout_rejected(self):
        (self.repo / "foreign.txt").write_text("unowned\n")
        result = self.run_preflight("--run-static")
        self.assertEqual(result.returncode, 4)
        self.assertIn("DIRTY_CHECKOUT", result.stderr)
        self.assertFalse(self.trace.exists())

    def test_formatter_failure_blocks_analyze(self):
        result = self.run_preflight("--run-static", fail="dart")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("FORMAT=RUNNING", result.stdout)
        self.assertNotIn("ANALYZE=RUNNING", result.stdout)
        self.assertEqual(len(self.trace.read_text().splitlines()), 1)

    def test_main_branch_rejected(self):
        self.git("switch", "-q", "main")
        (self.repo / "lib" / "example.dart").write_text(
            "void main() { print(2); }\n"
        )
        self.git("add", ".")
        self.git("commit", "-qm", "main commit")
        self.head_sha = self.git("rev-parse", "HEAD").stdout.strip()
        result = self.run_preflight("--run-static")
        self.assertEqual(result.returncode, 4)
        self.assertIn("OWNED_NON_MAIN_BRANCH_REQUIRED", result.stderr)
        self.assertFalse(self.trace.exists())

    def test_only_non_dart_changes_explicit_skip(self):
        (self.repo / "README.md").write_text("docs\n")
        self.git("add", ".")
        self.git("commit", "-qm", "docs")
        self.base_sha = self.head_sha
        self.head_sha = self.git("rev-parse", "HEAD").stdout.strip()
        result = self.run_preflight("--run-static")
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertIn("FORMAT=SKIPPED_NO_EXISTING_DART_FILES", result.stdout)
        self.assertIn("ANALYZE=SKIPPED_NO_DART_CHANGES", result.stdout)
        self.assertFalse(self.trace.exists())

    def test_sparse_checkout_discloses_missing_files_and_stops(self):
        self.git("sparse-checkout", "init", "--no-cone")
        self.git("sparse-checkout", "set", "tools/*")
        plan = self.run_preflight()
        self.assertEqual(plan.returncode, 0, plan.stderr)
        self.assertIn("CHANGED_DART_COUNT=1", plan.stdout)
        self.assertIn("CHECKOUT_COVERAGE=INCOMPLETE", plan.stdout)
        result = self.run_preflight("--run-static")
        self.assertEqual(result.returncode, 4)
        self.assertIn("INCOMPLETE_CHANGED_FILE_CHECKOUT", result.stderr)
        self.assertFalse(self.trace.exists())

    def test_analyze_failure_never_claims_success(self):
        result = self.run_preflight("--run-static", fail="flutter")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("FORMAT=PASS", result.stdout)
        self.assertIn("ANALYZE=RUNNING", result.stdout)
        self.assertNotIn("STATIC_PREFLIGHT=PASS_SCOPED", result.stdout)


    def test_deletion_only_runs_analyzer_and_cannot_hide_red(self):
        self.git("rm", "lib/example.dart")
        self.git("commit", "-qm", "delete only dart source")
        self.base_sha = self.head_sha
        self.head_sha = self.git("rev-parse", "HEAD").stdout.strip()
        plan = self.run_preflight()
        self.assertEqual(plan.returncode, 0, plan.stderr)
        self.assertIn("CHANGED_DART_COUNT=1", plan.stdout)
        self.assertIn("DELETED_DART_COUNT=1", plan.stdout)
        self.assertIn("CHECKOUT_COVERAGE=COMPLETE_FOR_CHANGED_DART", plan.stdout)
        result = self.run_preflight("--run-static", fail="flutter")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("FORMAT=SKIPPED_NO_EXISTING_DART_FILES", result.stdout)
        self.assertIn("ANALYZE=RUNNING", result.stdout)
        self.assertNotIn("STATIC_PREFLIGHT=PASS_SCOPED", result.stdout)
        self.assertEqual(self.trace.read_text().splitlines(), ["flutter analyze"])

    def test_two_attempts_preserve_first_failure_evidence(self):
        first = self.run_preflight("--run-static", fail="dart")
        self.assertNotEqual(first.returncode, 0)
        self.assertIn("FORMAT=RUNNING", first.stdout)
        second = self.run_preflight("--run-static")
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertIn("STATIC_PREFLIGHT=PASS_SCOPED", second.stdout)
        evidence_root = self.repo / "output" / "context-economy"
        attempts = sorted(evidence_root.glob("preflight-" + self.head_sha[:12] + "-*"))
        self.assertEqual(len(attempts), 2)
        self.assertNotEqual(attempts[0], attempts[1])
        statuses = sorted((folder / "format.summary.log").read_text().strip()
                          for folder in attempts)
        self.assertEqual(statuses, ["exit=0", "exit=17"])
        for folder in attempts:
            identity = (folder / "identity.txt").read_text()
            self.assertIn("HEAD=" + self.head_sha, identity)
            self.assertIn("BASE=" + self.base_sha, identity)
            self.assertIn("STARTED_UTC=", identity)
            self.assertTrue((folder / "diff-check.raw.log").exists())
            self.assertTrue((folder / "format.raw.log").exists())
        self.assertTrue(any((folder / "analyze.raw.log").exists()
                            for folder in attempts))
        self.assertTrue(any(not (folder / "analyze.raw.log").exists()
                            for folder in attempts))

if __name__ == "__main__":
    unittest.main()
