"""Exercise the semantics lint CLI in a temporary checkout."""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


class SemanticsDisposeLintTest(unittest.TestCase):
    def setUp(self):
        fixture_dir = tempfile.TemporaryDirectory(dir=Path(__file__).resolve().parent)
        self.addCleanup(fixture_dir.cleanup)
        self.root = Path(fixture_dir.name)
        tools = self.root / "tools/test_lint"
        tools.mkdir(parents=True)
        self.lint = tools / "semantics_dispose_lint_v1.py"
        shutil.copyfile(Path(__file__).with_name(self.lint.name), self.lint)
        self.allow_list = tools / "semantics_dispose_allow_v1.txt"
        self.allow_list.touch()
        self.fixture = self.root / "test/nested/widget_test.dart"
        self.fixture.parent.mkdir(parents=True)

    def run_lint(self, body):
        source = f"testWidgets('fixture', (tester) async {{\n{body}\n}});\n"
        self.fixture.write_text(source, encoding="utf-8")
        return subprocess.run(
            [sys.executable, "-I", str(self.lint)],
            cwd=self.root, capture_output=True, text=True, check=False,
        )

    def assert_violation(self, body):
        result = self.run_lint(body)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("test/nested/widget_test.dart:3:", result.stdout)

    def assert_passes(self, body):
        result = self.run_lint(body)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "")

    def test_semantics_dispose_tearoff(self):
        self.assert_violation(
            "final semantics = tester.ensureSemantics();\n"
            "addTearDown(semantics.dispose);"
        )

    def test_renamed_handle_dispose_tearoff(self):
        self.assert_violation(
            "final handle = tester.ensureSemantics();\n"
            "addTearDown(handle.dispose);"
        )

    def test_inline_callback_disposes_handle(self):
        self.assert_violation(
            "final semantics = tester.ensureSemantics();\n"
            "addTearDown(\n  () => semantics.dispose(),\n);"
        )

    def test_dispose_in_test_body(self):
        self.assert_passes(
            "final semantics = tester.ensureSemantics();\n"
            "// addTearDown(semantics.dispose);\n"
            "final example = 'addTearDown(semantics.dispose)';\n"
            "semantics.dispose();"
        )

    def test_unrelated_dispose_tearoff(self):
        self.assert_passes(
            "final semantics = tester.ensureSemantics();\n"
            "final controller = AnimationController(vsync: tester);\n"
            "addTearDown(controller.dispose);\n"
            "semantics.dispose();"
        )

    def test_allow_list_matches_only_listed_location(self):
        self.allow_list.write_text(
            "test/nested/widget_test.dart:3 # pre-existing, fix later\n",
            encoding="utf-8",
        )
        body = (
            "final semantics = tester.ensureSemantics();\n"
            "addTearDown(semantics.dispose);"
        )
        self.assert_passes(body)
        result = self.run_lint(body + "\naddTearDown(semantics.dispose);")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertNotIn("test/nested/widget_test.dart:3:", result.stdout)
        self.assertIn("test/nested/widget_test.dart:4:", result.stdout)


if __name__ == "__main__":
    unittest.main()
