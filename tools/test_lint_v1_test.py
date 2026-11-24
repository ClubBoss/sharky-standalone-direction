"""Exercise the test lint CLI with temporary Git and Dart fixtures."""

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


LINT = Path(__file__).with_name("test_lint_v1.py").resolve()


class TestLint(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(dir=LINT.parents[1])
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        bin_dir = self.root / "bin"
        bin_dir.mkdir()
        (bin_dir / "git").symlink_to(shutil.which("git"))
        self.env = {**os.environ, "PATH": str(bin_dir)}
        dart = bin_dir / "dart"
        dart.write_text(
            f"#!{sys.executable}\n"
            "from pathlib import Path\n"
            "import sys\n"
            "assert sys.argv[1:5] == ['--suppress-analytics', 'format', "
            "'--output=none', '--set-exit-if-changed']\n"
            "for name in sys.argv[5:]:\n"
            "    if Path(name).read_text() == 'void main(){}\\n':\n"
            "        print(f'Changed {name}')\n"
            "        sys.exit(1)\n",
            encoding="utf-8",
        )
        dart.chmod(0o755)
        self.git("init", "-q")

    def git(self, *args):
        subprocess.run(
            ["git", "-c", "core.fsmonitor=false", *args],
            cwd=self.root, capture_output=True, check=True,
        )

    def fixture(self, name, source="void main() {}\n"):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source, encoding="utf-8")
        return name

    def lint(self, *args, code=0):
        result = subprocess.run(
            [sys.executable, "-I", str(LINT), *args],
            cwd=self.root, env=self.env, capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, code, result.stdout + result.stderr)
        return result.stdout

    def test_tl1_flags_inline_callback_and_named_tearoff(self):
        path = self.fixture(
            "test/widget_test.dart",
            "void main() {\n"
            "  addTearDown(\n    () => wrap(semantics.dispose()),\n  );\n"
            "  addTearDown(disposeSemantics);\n"
            "}\n",
        )
        output = self.lint(path, code=1)
        self.assertIn(f"{path}:2: TL1 fail: call semantics.dispose() in the test body", output)
        self.assertIn(f"{path}:5: TL1 fail:", output)

    def test_tl1_allows_body_disposal_and_unrelated_teardown(self):
        path = self.fixture(
            "test/widget_test.dart",
            "void main() {\n"
            "  // addTearDown(semantics.dispose);\n"
            "  print('addTearDown(disposeSemantics)');\n"
            "  addTearDown(controller.dispose);\n"
            "  semantics.dispose();\n"
            "}\n",
        )
        self.assertNotIn("TL1", self.lint(path))

    def test_tl2_flags_changed_file_against_base(self):
        clean = self.fixture("clean.dart")
        changed = self.fixture("needs format.dart")
        self.git("add", "--", clean, changed)
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                 "-c", "commit.gpgsign=false", "-c", "core.hooksPath=/dev/null",
                 "commit", "-qm", "Fixture base")
        self.git("update-ref", "refs/remotes/origin/main", "HEAD")
        self.fixture(changed, "void main(){}\n")
        self.assertEqual(
            self.lint("--base", "origin/main", code=1),
            f"{changed}:1: TL2 fail: run dart format\n",
        )
        self.assertEqual((self.root / changed).read_text(), "void main(){}\n")

    def test_tl2_accepts_clean_explicit_path(self):
        self.assertEqual(self.lint(self.fixture("clean.dart")), "")

    def test_tl2_skips_when_dart_is_missing(self):
        (self.root / "bin/dart").unlink()
        self.assertIn("TL2 skip: dart is missing", self.lint(self.fixture("clean.dart")))

    def test_tl3_warns_for_both_untracked_suffixes_without_failing(self):
        for path in ("test/nested/widget_test.dart", "test/widget_goldens.dart"):
            self.fixture(path)
        output = self.lint(self.fixture("clean.dart"))
        for path in ("test/nested/widget_test.dart", "test/widget_goldens.dart"):
            self.assertIn(f"{path}:1: TL3 warn: untracked test file; commit or delete", output)

    def test_tl3_ignores_indexed_tests_and_other_paths(self):
        tracked = self.fixture("test/tracked_test.dart")
        self.git("add", "--", tracked)
        self.fixture("test/helper.dart")
        self.fixture("outside_test.dart")
        self.assertEqual(self.lint(tracked), "")


if __name__ == "__main__":
    unittest.main()
