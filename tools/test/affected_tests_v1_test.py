#!/usr/bin/env python3
"""Run: python3 -B tools/test/affected_tests_v1_test.py."""

import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "affected_tests_v1.py"
SPEC = importlib.util.spec_from_file_location("affected_tests", SCRIPT)
GUARD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GUARD)


class AffectedTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.repo = Path(directory.name)
        self.git("init", "-q")
        self.write("pubspec.yaml", "name: fixture_app\n")
        self.write("lib/counter.dart", "int x = 1;\n")
        self.write("test/unrelated_test.dart", "void main() {}\n")

    def git(self, *args):
        subprocess.run([
            "git", "-c", "core.fsmonitor=false", "-c", "core.hooksPath=/dev/null",
            "-c", "commit.gpgsign=false", "-c", "user.name=Fixture",
            "-c", "user.email=fixture@example.invalid", *args,
        ], cwd=self.repo, check=True, capture_output=True)

    def write(self, name, text):
        path = self.repo / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")

    def baseline(self):
        self.git("add", ".")
        self.git("commit", "-qm", "baseline")
        self.git("update-ref", "refs/remotes/origin/main", "HEAD")

    def invoke(self, *args, env=None):
        return subprocess.run([sys.executable, "-I", str(SCRIPT), *args], cwd=self.repo / "test",
                              env=env, text=True, capture_output=True, timeout=15)

    def selected(self, *args):
        result = self.invoke(*args)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        selected = result.stdout.splitlines()
        self.assertEqual(selected, sorted(set(selected)))
        self.assertNotIn("test/unrelated_test.dart", selected)
        return set(selected)

    def test_changed_test_committed_staged_unstaged_and_untracked(self):
        self.write("test/committed_test.dart", "void main() {}\n")
        self.write("test/staged_test.dart", "void main() {}\n")
        self.write("test/unstaged_test.dart", "void main() {}\n")
        self.write("test/deleted_test.dart", "void main() {}\n")
        self.baseline()
        self.write("test/committed_test.dart", "void main() { }\n")
        self.git("add", "test/committed_test.dart")
        self.git("commit", "-qm", "changed test")
        self.write("test/staged_test.dart", "void main() { }\n")
        self.git("add", "test/staged_test.dart")
        self.write("test/unstaged_test.dart", "void main() { }\n")
        self.write("test/new_test.dart", "void main() {}\n")
        (self.repo / "test/deleted_test.dart").unlink()
        self.assertEqual(self.selected("origin/main"), {
            "test/committed_test.dart", "test/staged_test.dart", "test/unstaged_test.dart",
            "test/new_test.dart",
        })

    def test_direct_imports_one_reexport_and_part_owner(self):
        files = {
            "lib/barrel.dart": "export 'counter.dart' show x;\n",
            "lib/outer.dart": "export 'barrel.dart';\n",
            "lib/owner.dart": "part 'counter.dart';\n",
            "test/pkg_test.dart": "import 'package:fixture_app/counter.dart';\n",
            "test/nested/relative_test.dart": "import '../../lib/counter.dart';\n",
            "test/barrel_test.dart": "import\n 'package:fixture_app/barrel.dart';\n",
            "test/part_test.dart": "import '../lib/owner.dart';\n",
            "test/too_deep_test.dart": "import '../lib/outer.dart';\n",
            "test/foreign_test.dart": "import 'package:other_app/counter.dart';\n",
        }
        for path, text in files.items():
            self.write(path, text)
        self.baseline()
        self.write("lib/counter.dart", "int x = 2;\n")
        self.assertEqual(self.selected(), {
            "test/pkg_test.dart", "test/nested/relative_test.dart", "test/barrel_test.dart",
            "test/part_test.dart",
        })

    def test_added_removed_terms_and_no_substring_matches(self):
        self.write("lib/counter.dart", """class RemovedCounter {}
const x = 'old-key';
const y = 'w1_day7_old';
const z = 'a.b-cd';
""")
        for name, term in {
            "removed_symbol": "RemovedCounter()", "added_symbol": "AddedCounter()",
            "removed_key": "'old-key'", "added_key": '"new-key"',
            "removed_id": "'w1_day7_old'", "added_id": "'w1_day7_new'",
            "punctuated_key": '"a.b-cd"', "near_match": "AddedCounterExtra()",
            "ignored": "return const Tiny; _secret();",
        }.items():
            self.write(f"test/{name}_test.dart", term + "\n")
        self.baseline()
        self.write("lib/counter.dart", """class AddedCounter {}
const x = "new-key";
const y = 'w1_day7_new';
class Tiny {}
void _secret() { return; }
""")
        self.assertEqual(self.selected("--base", "origin/main"), {
            f"test/{name}_test.dart" for name in (
                "removed_symbol", "added_symbol", "removed_key", "added_key",
                "removed_id", "added_id", "punctuated_key",
            )
        })

    def test_catalog_and_lesson_changes_always_include_six_guards(self):
        self.assertEqual(len(GUARD.CONTENT_GUARDS), 6)
        self.assertEqual(len(set(GUARD.CONTENT_GUARDS)), 6)
        for name in (*GUARD.CONTENT_GUARDS, "lib/act0_shell_state_v1.dart", "lib/catalog.dart", "lib/lesson.dart"):
            self.write(name, "int x = 1;\n")
        self.baseline()
        for name in ("lib/catalog.dart", "lib/lesson.dart", "lib/act0_shell_state_v1.dart"):
            with self.subTest(name=name):
                self.write(name, "int x = 2;\n")
                self.assertEqual(self.selected(), set(GUARD.CONTENT_GUARDS))
                self.write(name, "int x = 1;\n")
        self.assertEqual(self.selected(), set())

    def test_no_selection_cap_and_runner_continues_after_failure_and_timeout(self):
        for index in range(43):
            self.write(f"test/case_{index:02}_test.dart", "import '../lib/counter.dart';\n")
        self.baseline()
        self.write("lib/counter.dart", "int x = 2;\n")
        selected = self.selected()
        self.assertEqual(len(selected), 43)
        fake = self.repo / "bin/flutter"
        self.write("bin/flutter", f"#!{sys.executable}\n" + '''import os, sys, time
assert sys.argv[1:3] == ["test", "--no-pub"]
with open(os.environ["INVOCATIONS"], "a") as log:
    log.write(" ".join(sys.argv[3:]) + "\\n")
if "test/case_00_test.dart" in sys.argv:
    print("synthetic failure", flush=True)
    sys.exit(7)
if "test/case_10_test.dart" in sys.argv:
    time.sleep(30)
print("successful output should stay hidden")
''')
        fake.chmod(0o755)
        log = self.repo / "invocations"
        env = dict(os.environ, PATH=f"{fake.parent}{os.pathsep}{os.environ['PATH']}", INVOCATIONS=str(log))
        result = self.invoke("--run", "--chunk-size", "10", "--timeout", "1", env=env)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertIn("exit 7", result.stderr)
        self.assertIn("synthetic failure", result.stderr)
        self.assertIn("timeout after 1s", result.stderr)
        self.assertNotIn("successful output", result.stderr)
        chunks = [line.split() for line in log.read_text().splitlines()]
        self.assertEqual([len(chunk) for chunk in chunks], [10, 10, 10, 10, 3])
        self.assertEqual([name for chunk in chunks for name in chunk], sorted(selected))


if __name__ == "__main__":
    unittest.main()
