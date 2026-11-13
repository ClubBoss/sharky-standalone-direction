"""Portable, isolated process composition regressions. No Dart/Flutter SDK runs."""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

# Isolate synthetic children from CI, policy/receipt controls and Git overrides.
# Evidence destination is captured separately and never passed as execution authority.
EVIDENCE_DESTINATION = os.environ.get("SHARKY_FIXTURE_EVIDENCE_DIR")
def fixture_environment(source):
 clean = {k:v for k,v in source.items() if not k.startswith(
  ("GITHUB_", "SHARKY_", "FAST_LOOP_", "TEST_AUTHORITY_", "TEST_POLICY_", "GIT_", "MOCK_"))
  and k not in {"CHECKPOINT", "CAPTURE", "TRACE"}}
 clean.update(GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")
 return clean
BASE_ENV = fixture_environment(os.environ)

SOURCE = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(SOURCE / "tools/test_authority"))
import run_lane_v1 as runner

def capable_bash():
    for value in [shutil.which("bash"), "/opt/homebrew/bin/bash", "/usr/local/bin/bash", "/bin/bash"]:
        if value and Path(value).is_file():
            q = subprocess.run([value, "-c", "type mapfile >/dev/null 2>&1"], capture_output=True, env=BASE_ENV)
            if q.returncode == 0:
                return value
    raise RuntimeError("BLOCKED: Bash with mapfile required (no software is installed by fixture)")

class CompositionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.bash = capable_bash()
        cls.git_executable = shutil.which("git")
        if not cls.git_executable:
            raise RuntimeError("BLOCKED: git unavailable")

    def setUp(self):
        self.evidence = EVIDENCE_DESTINATION
        self.directory = tempfile.TemporaryDirectory(prefix="sharky-process-regression-")
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.trace = self.root / "trace"
        self.env = BASE_ENV.copy()
        self.env.update(TRACE=str(self.trace), CHECKPOINT="0", CI="true",
                        GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")
        def git(*args):
            subprocess.run([self.git_executable, "-C", str(self.root), *args],
                           env=self.env, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        git("init", "-q")
        git("config", "user.email", "fixture@example.invalid")
        git("config", "user.name", "Fixture")
        self.put("pubspec.yaml", "name: fixture\n")
        self.put("content/example/v1/fixture.yaml", "fixture\n")
        self.put("lib/fixture.dart", "fixture\n")
        git("add", ".")
        git("commit", "-qm", "fixture seed")
        for name in ["release_gate_world1.sh", "fast_loop_world1_v1.sh",
                     "_fast_loop_test_tiers_v1.sh", "_test_policy_v1.sh",
                     "_world1_selected_tests_v1.sh", "_fast_loop_cache_v1.sh",
                     "collect_changeset_v1.py"]:
            self.put("tools/"+name, (SOURCE / "tools" / name).read_text(), executable=name.endswith(".sh"))
        self.put("tools/lint_tools_v1.sh", '#!/bin/sh\nprintf "lint\\n" >> "$TRACE"\n', True)
        (self.root/"mockbin").mkdir()
        (self.root/"mockbin/bash").symlink_to(self.bash)
        # Wrapper preserves real git except the explicit hygiene failure injection.
        import shlex
        self.put("mockbin/git", '#!/bin/sh\nif [ "$*" = "diff --check" ]; then printf "hygiene\\n" >> "$TRACE"; exit "${MOCK_PRE_RC:-0}"; fi\nexec '+shlex.quote(self.git_executable)+' "$@"\n', True)
        self.put("mockbin/dart", '#!/bin/sh\nprintf "dart %s\\n" "$*" >> "$TRACE"\nif [ "$1" = run ]; then exit "${MOCK_CONTENT_RC:-0}"; fi\nexit 0\n', True)
        self.put("mockbin/flutter", '''#!/bin/sh
printf "flutter %s\\n" "$*" >> "$TRACE"
if [ "$1" = gen-l10n ]; then exit "${MOCK_POST_RC:-0}"; fi
if [ "${MOCK_FAST_RC:-0}" != 0 ]; then
  printf 'test/fixture.dart: early failure [E]\\napi_key: |\\n  fixture_private\\n\\n  fixture_remainder [E]\\n'
  python3 -c 'print("x"*10000)'
fi
exit "${MOCK_FAST_RC:-0}"
''', True)
        self.env["PATH"] = str(self.root/"mockbin")+os.pathsep+self.env.get("PATH", "")
        self.root_patch = patch.object(runner, "ROOT", self.root)
        self.root_patch.start()
        self.addCleanup(self.root_patch.stop)

    def put(self, name, text, executable=False):
        file = self.root/name
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_text(text)
        if executable:
            file.chmod(0o755)

    def run_gate(self, extra):
        with patch.dict(os.environ, {**self.env, **extra}, clear=True):
            result = runner._run_world1_gate("World 1 release gate", ["./tools/release_gate_world1.sh"], 20)
        lines = self.trace.read_text().splitlines() if self.trace.exists() else []
        return result, lines

    def test_actual_composition_outcomes(self):
        cases = [
            ("success", {}, "PASS", 0, "pass", 1, 1),
            ("pre_failure", {"MOCK_PRE_RC":"5"}, "NOT_EXECUTED", 5, "fail", 0, 0),
            ("content_failure", {"MOCK_CONTENT_RC":"9"}, "NOT_EXECUTED", 9, "fail", 0, 1),
            ("fast_failure", {"MOCK_FAST_RC":"7"}, "FAIL", 7, "fail", 1, 1),
            ("post_failure", {"MOCK_POST_RC":"11"}, "PASS", 11, "fail", 1, 1),
            ("nested_noop", {"FAST_LOOP_ALREADY_RAN":"1"}, "SKIPPED", 0, "error", 0, 1),
            ("child_interrupt_exit", {"MOCK_FAST_RC":"130"}, "FAIL", 130, "fail", 1, 1),
            ("unknown_context", {"GITHUB_ACTIONS":"true"}, "NOT_EXECUTED", 75, "fail", 0, 0),
        ]
        for name, env, state, code, status, tests, validations in cases:
            with self.subTest(name=name):
                self.trace.unlink(missing_ok=True)
                result, lines = self.run_gate(env)
                if self.evidence:
                    evidence = Path(self.evidence)/"composition"
                    evidence.mkdir(parents=True, exist_ok=True)
                    (evidence/(name+".json")).write_text(json.dumps(result, indent=2))
                    (evidence/(name+".trace")).write_text("\n".join(lines)+"\n")
                self.assertEqual(result["nested_steps"][0]["execution_state"], state)
                self.assertEqual(result["exit_code"], code)
                self.assertEqual(result["status"], status)
                self.assertEqual(sum(x.startswith("flutter test ") for x in lines), tests)
                self.assertEqual(lines.count("dart run tools/validate_training_content.dart"), validations)
                if name in ("fast_failure", "child_interrupt_exit"):
                    self.assertTrue(any("early failure" in x for x in result["flutter_failure_cases"]))
                    self.assertNotIn("fixture_remainder", str(result))
                    self.assertNotIn("fixture_private", str(result))
                if name == "success":
                    # Full-scope guards really select every declared family.
                    import re
                    text = "".join((SOURCE/"tools"/f).read_text() for f in
                        ["_world1_selected_tests_v1.sh", "_fast_loop_test_tiers_v1.sh"])
                    declared = set(re.findall(r"(?m)^\s+(test/[^\s]+\.dart)\s*$", text))
                    self.assertTrue(declared)
                    self.assertTrue(all(name in "\n".join(lines) for name in declared))
                    self.assertIn("flutter gen-l10n", lines)

    def test_invalid_receipt_never_pass(self):
        for kind in ["missing", "foreign", "partial", "malformed", "wrong-command", "not-executed"]:
            with self.subTest(kind=kind):
                def fake(name, command, timeout, env):
                    file = Path(env["SHARKY_WORLD1_STEP_RECEIPT"])
                    receipt = json.loads(file.read_text())
                    if kind == "missing":
                        file.unlink()
                    elif kind == "malformed":
                        file.write_text("{")
                    else:
                        if kind == "foreign":
                            receipt.update(token="other", state="PASS", exit_code=0)
                        if kind == "partial":
                            receipt["state"] = "STARTED"
                        if kind == "wrong-command":
                            receipt.update(cmd=["true"], state="PASS", exit_code=0)
                        file.write_text(json.dumps(receipt))
                    return {"status":"pass", "exit_code":0, "name":name, "cmd":command}
                with patch.object(runner, "_run_command", side_effect=fake):
                    result = runner._run_world1_gate("gate", ["./tools/release_gate_world1.sh"], 20)
                self.assertEqual(result["status"], "error")

    def test_poisoned_ambient_child_suites(self):
        poison = dict(os.environ, GITHUB_ACTIONS="true", GITHUB_SHA="9"*40,
                      GITHUB_EVENT_NAME="pull_request", GITHUB_REF="refs/pull/999/merge",
                      GITHUB_REPOSITORY="poison/repo", GITHUB_EVENT_PATH="/nonexistent/fixture-event",
                      FAST_LOOP_ALREADY_RAN="1", FAST_LOOP_RUN_WORLD1_CONTRACTS_V1="1",
                      SHARKY_WORLD1_STEP_RECEIPT="/nonexistent/fixture-receipt",
                      SHARKY_WORLD1_STEP_TOKEN="poison", SHARKY_CONTENT_OWNER_V1="invalid",
                      SHARKY_CHANGE_MODE="invalid", CHECKPOINT="1", CAPTURE="1",
                      MOCK_VALIDATOR_RC="99", MOCK_FAST_RC="99",
                      GIT_DIR="/nonexistent/fixture-git", GIT_WORK_TREE="/nonexistent/fixture-work",
                      GIT_INDEX_FILE="/nonexistent/fixture-index", GIT_CONFIG_COUNT="1",
                      GIT_CONFIG_KEY_0="core.worktree", GIT_CONFIG_VALUE_0="/nonexistent/override")
        if self.evidence:
            poison["SHARKY_FIXTURE_EVIDENCE_DIR"] = str(Path(self.evidence)/"poisoned")
        for name in ["changeset_base_fixtures_test.py", "changeset_context_fixtures_test.py"]:
            with self.subTest(name=name):
                q = subprocess.run([sys.executable, str(SOURCE/"tools/test_authority"/name)],
                                   env=poison, capture_output=True, text=True, timeout=60)
                self.assertEqual(q.returncode, 0, q.stdout+q.stderr)
                if self.evidence:
                    (Path(self.evidence)/(name+".poisoned.txt")).write_text(q.stdout+q.stderr)

    def test_single_dispatch(self):
        self.assertFalse(any(x["cmd"] == runner.FAST_LOOP_ARGV for x in runner.TIER_A_COMMANDS))
        with patch.object(runner, "_run_command", return_value={"status":"pass"}) as direct:
            with patch.object(runner, "_run_world1_gate", return_value={"status":"pass"}) as gate:
                runner._run_tier_a(20, False)
        self.assertEqual(gate.call_count, 1)
        self.assertEqual(direct.call_count, len(runner.TIER_A_COMMANDS)-1)

if __name__ == "__main__":
    unittest.main(verbosity=2)
