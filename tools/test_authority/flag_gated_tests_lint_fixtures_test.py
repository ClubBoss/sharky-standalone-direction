#!/usr/bin/env python3
"""Run the E41 CLI against isolated, synthetic repositories."""

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


LINT = Path(__file__).with_name("flag_gated_tests_lint_v1.py")
GATED_TEST = """
const enabled = bool.fromEnvironment('PILOT');
void main() {
  test('pilot guard', () {}, skip: !enabled);
}
"""


class FlagGatedTestsLintFixturesTest(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)

    def write(self, path, content):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")

    def run_lint(self, expected_exit):
        result = subprocess.run(
            [sys.executable, "-I", str(LINT), "--root", str(self.root)],
            capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, expected_exit, result.stdout + result.stderr)
        return result.stdout

    def test_missing_define_fails(self):
        self.write("test/nested/pilot_test.dart", GATED_TEST)
        output = self.run_lint(1)
        self.assertIn("FAIL E41 test/nested/pilot_test.dart PILOT", output)

    def test_workflow_define_passes(self):
        self.write("test/pilot_test.dart", GATED_TEST)
        self.write(".github/workflows/ci.yml", "- run: flutter test --dart-define=PILOT=true\n")
        self.assertIn("PASS", self.run_lint(0))

    def test_allowlisted_define_warns(self):
        self.write("test/pilot_test.dart", GATED_TEST)
        self.write("tools/test_authority/flag_gated_tests_allowlist_v1.json", json.dumps([
            {"define": "PILOT", "reason": "Pending lane", "until": "2099-01-01"}
        ]))
        output = self.run_lint(0)
        self.assertIn("WARN E41 test/pilot_test.dart PILOT", output)
        self.assertNotIn("FAIL", output)

    def test_unused_workflow_define_passes(self):
        self.write("test/plain_test.dart", "void main() { test('plain', () {}); }")
        self.write(".github/workflows/ci.yml", "- run: flutter test --dart-define=PILOT=true\n")
        self.assertIn("PASS", self.run_lint(0))

    def test_direct_group_gate_and_string_const_alias(self):
        self.write("test/conditional_test.dart", """
const String mode = String.fromEnvironment(
  'MODE', defaultValue: '',
);
const disabled = mode == '';
void main() {
  if (const bool.fromEnvironment('GROUP')) {
    group('group guard', () {});
  }
  if (const bool.fromEnvironment('ELSE')) {
    print('not registered');
  } else {
    test('else guard', () {});
  }
  testWidgets('widget guard', (tester) {}, skip: disabled);
  test('direct skip', () {}, skip: !const bool.fromEnvironment('DIRECT'));
}
""")
        output = self.run_lint(1)
        for flag in ("GROUP", "ELSE", "MODE", "DIRECT"):
            self.assertIn(f"FAIL E41 test/conditional_test.dart {flag}", output)

    def test_imported_const_and_lane_argument(self):
        self.write("pubspec.yaml", "name: fixture_app\n")
        self.write("lib/pilot.dart", "const enabled = bool.fromEnvironment('SHARED');")
        self.write("test/pilot_test.dart", """
import 'package:fixture_app/pilot.dart';
void main() {
  if (!enabled) return;
  test('pilot', () {});
}
""")
        self.assertIn("FAIL E41 test/pilot_test.dart SHARED", self.run_lint(1))
        self.write("tools/test_authority/run_lane_v1.py", "cmd = ['flutter', 'test', f'--dart-define=SHARED={True}']\n")
        self.assertIn("PASS", self.run_lint(0))

    def test_comments_strings_and_fixture_assertions_are_not_gates_or_lanes(self):
        self.write("test/pilot_test.dart", GATED_TEST + """
// test('ghost', () {}, skip: const bool.fromEnvironment('GHOST'));
/* if (const bool.fromEnvironment('GHOST')) test('ghost', () {}); */
void other() {
  test('normal assertion', () {
    expect(const bool.fromEnvironment('NORMAL'), false);
    expect("skip: const bool.fromEnvironment('TEXT')", isNotEmpty);
  });
}
""")
        self.write(".github/workflows/ci.yml", "# - run: flutter test --dart-define=PILOT=true\n")
        self.write("tools/test_authority/run_lane_v1.py", "# --dart-define=PILOT=true\n")
        self.write("tools/test_authority/lane_fixtures_test.py", "assert '--dart-define=PILOT=true'\n")
        output = self.run_lint(1)
        self.assertEqual(output.strip(), "FAIL E41 test/pilot_test.dart PILOT")


if __name__ == "__main__":
    unittest.main()
