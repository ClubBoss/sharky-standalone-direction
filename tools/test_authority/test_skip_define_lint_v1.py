#!/usr/bin/env python3
"""Isolated E41 CLI fixtures; no Flutter SDK or real repository needed."""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

LINT = Path(__file__).with_name("skip_define_lint_v1.py").resolve()


class SkipDefineLintTest(unittest.TestCase):
    def setUp(self):
        fixture = tempfile.TemporaryDirectory()
        self.addCleanup(fixture.cleanup)
        self.root = Path(fixture.name)
        self.write("tools/test_authority/run_lane_v1.py", "TIER_A_COMMANDS = []\n")

    def write(self, relative, source):
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source, encoding="utf-8")

    def run_lint(self):
        return subprocess.run(
            [sys.executable, "-I", str(LINT), "--root", str(self.root)],
            capture_output=True, text=True, encoding="utf-8",
        )

    def test_unset_define_fails_with_file_and_line(self):
        self.write("test/nested/gated_test.dart", """\
const bool _enabled = bool.fromEnvironment('MISSING');
void main() {
  test('gated', () {}, skip: !_enabled);
}
""")
        self.write("tools/test_authority/run_lane_v1.py",
                   "# Not actually set: --dart-define=MISSING=true\n")
        result = self.run_lint()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("test/nested/gated_test.dart:3 · MISSING · lanes that set it: none",
                      result.stdout)
        self.assertIn("FAIL: 1 unset define skip(s)", result.stdout)

    def test_lane_sets_imported_compound_flag(self):
        self.write("lib/pilot.dart", """\
const pilotEnabled =
    kDebugMode && bool.fromEnvironment('PILOT', defaultValue: false);
""")
        self.write("test/pilot_test.dart", """\
import '../lib/pilot.dart';
void main() {
  test('snapshot', () {}, skip: !pilotEnabled);
}
""")
        result = self.run_lint()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("test/pilot_test.dart:3 · PILOT · lanes that set it: none",
                      result.stdout)
        self.write("tools/test_authority/run_lane_v1.py", """\
TIER_A_COMMANDS = [
    {'name': 'pilot', 'cmd': ['flutter', 'test', '--dart-define=PILOT=true']},
]
""")
        result = self.run_lint()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("PASS: 0 unset define skip(s)", result.stdout)

    def test_unrelated_lane_metadata_does_not_count_as_argument(self):
        self.write("test/gated_test.dart", """\
const enabled = bool.fromEnvironment('MISSING');
void main() { test('gated', () {}, skip: !enabled); }
""")
        self.write("tools/test_authority/run_lane_v1.py", """\
TIER_A_COMMANDS = [
    {'name': '--dart-define=MISSING=true', 'cmd': ['flutter', 'test']},
]
""")
        result = self.run_lint()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("· MISSING · lanes that set it: none", result.stdout)

    def test_literal_skips_warn_without_failing(self):
        self.write("test/literal_test.dart", """\
void main() {
  test('literal', () {}, skip: true);
  test('reason', () {}, skip: 'external checkout');
  test('not skipped', () {}, skip: false);
}
""")
        result = self.run_lint()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("WARN test/literal_test.dart:2", result.stdout)
        self.assertIn("WARN test/literal_test.dart:3", result.stdout)
        self.assertIn("2 literal skip warning(s)", result.stdout)

    def test_string_define_inside_multiline_expression(self):
        self.write("test/support/settings.dart",
                   'const String mode = String.fromEnvironment("MODE");\n')
        self.write("test/mode_test.dart", """\
import 'support/settings.dart';
void main() {
  test('mode', () {},
    skip: (mode == 'local' || const bool.fromEnvironment('OTHER')),
  );
}
""")
        result = self.run_lint()
        self.assertEqual(result.returncode, 1, result.stderr)
        for define in ("MODE", "OTHER"):
            self.assertIn(f"test/mode_test.dart:4 · {define} · lanes that set it: none",
                          result.stdout)

    def test_ignore_comments_and_quoted_source(self):
        self.write("lib/settings.dart", "const pilot = bool.fromEnvironment('PILOT');")
        self.write("test/quoted_test.dart", """\
void main() {
  // skip: !pilot,
  /* nested /* skip: !pilot */ skip: !pilot */
  final source = 'skip: !pilot';
  test('ordinary', () {}, skip: reason == 'pilot');
}
""")
        result = self.run_lint()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("PASS: 0 unset define skip(s), 0 literal skip warning(s)",
                      result.stdout)

    def test_private_constants_do_not_leak_between_files(self):
        self.write("test/local_test.dart", """\
const _enabled = bool.fromEnvironment('LOCAL');
void main() { test('local', () {}, skip: !_enabled); }
""")
        self.write("test/other_test.dart", """\
const _enabled = bool.fromEnvironment('OTHER');
void main() { test('other', () {}, skip: !_enabled); }
""")
        self.write("tools/test_authority/run_lane_v1.py",
                   "TIER_A_COMMANDS = [{'cmd': ['flutter', 'test', '--dart-define=OTHER=true']}]")
        result = self.run_lint()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("test/local_test.dart:2 · LOCAL · lanes that set it: none", result.stdout)
        self.assertNotIn("test/other_test.dart", result.stdout)


if __name__ == "__main__":
    unittest.main()
