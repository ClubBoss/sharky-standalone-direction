"""Controls for historical-source preservation and strict gate error rejection."""
import importlib.util
import json
import pathlib
import subprocess
import sys
import tempfile
import unittest
from unittest import mock


ROOT = pathlib.Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    'baseline_dependencies', ROOT / 'tools/table_truth_baseline_dependencies_v1.py')
ADAPTER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ADAPTER)


class DependencyControls(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.candidate = pathlib.Path(self.tmp.name) / 'candidate'
        self.baseline = pathlib.Path(self.tmp.name) / 'baseline'
        self.candidate.mkdir()
        self.baseline.mkdir()

    def put(self, root, name, text):
        path = root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def run_adapter(self):
        return ADAPTER.complete_dependencies(
            self.candidate, self.baseline, ['lib/runner.dart'])

    def test_transitive_conditional_export_part_package_and_cycle(self):
        self.put(self.baseline, 'lib/runner.dart', "import 'a.dart';")
        self.put(self.candidate, 'lib/a.dart',
                 "export 'b.dart' if (dart.library.io) 'c.dart';\npart 'piece.dart';")
        self.put(self.candidate, 'lib/b.dart', "import 'package:poker_analyzer/d.dart';")
        self.put(self.candidate, 'lib/c.dart', "import 'package:flutter/material.dart';")
        self.put(self.candidate, 'lib/d.dart', "import 'a.dart';\nimport 'dart:ui';")
        self.put(self.candidate, 'lib/piece.dart', "part of 'a.dart';")
        result = self.run_adapter()
        self.assertEqual(set(result['copied_missing']),
                         {'lib/a.dart', 'lib/b.dart', 'lib/c.dart',
                          'lib/d.dart', 'lib/piece.dart'})

    def test_existing_baseline_source_and_its_own_dependency_are_preserved(self):
        self.put(self.baseline, 'lib/runner.dart', "import 'state.dart';")
        self.put(self.baseline, 'lib/state.dart', "import 'old.dart';\nconst truth = 'RED';")
        self.put(self.baseline, 'lib/old.dart', "const old = true;")
        self.put(self.candidate, 'lib/state.dart', "import 'new.dart';\nconst truth = 'GREEN';")
        result = self.run_adapter()
        self.assertEqual(result['copied_missing'], {})
        self.assertIn("truth = 'RED'", (self.baseline / 'lib/state.dart').read_text())
        self.assertNotIn('lib/new.dart', result['preserved_existing'])

    def test_missing_dependency_fails_closed(self):
        self.put(self.baseline, 'lib/runner.dart', "import 'absent.dart';")
        with self.assertRaises(FileNotFoundError):
            self.run_adapter()

    def test_dependency_cannot_escape_root(self):
        self.put(self.baseline, 'lib/runner.dart', "import '../../outside.dart';")
        with self.assertRaises(ValueError):
            self.run_adapter()

    def test_existing_gate_rejects_compile_error_for_red_and_green(self):
        events = [
            {'type': 'testStart', 'test': {'id': 1, 'name': 'real case'}},
            {'type': 'error', 'error': 'Compilation failed: missing dependency'},
            {'type': 'testDone', 'testID': 1, 'result': 'failure'},
        ]
        log = pathlib.Path(self.tmp.name) / 'compile.jsonl'
        log.write_text('\n'.join(map(json.dumps, events)) + '\n')
        for expected in ['red', 'green']:
            with self.subTest(expected=expected):
                result = subprocess.run(
                    ['python3', str(ROOT / 'tools/table_truth_evidence_v1.py'),
                     'tests', str(log), expected, '1'], capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('does not establish', result.stderr)

    def test_wrong_baseline_head_fails_before_copy_or_output(self):
        output = pathlib.Path(self.tmp.name) / 'manifest.json'
        args = ['adapter', '--baseline', str(self.baseline),
                '--expected-head', 'pinned-baseline', '--output', str(output)]
        with mock.patch.object(sys, 'argv', args), mock.patch.object(
                ADAPTER.subprocess, 'check_output', return_value='wrong-head\n'):
            with self.assertRaisesRegex(SystemExit, 'HEAD mismatch'):
                ADAPTER.main()
        self.assertFalse(output.exists())
        self.assertEqual(list(self.baseline.iterdir()), [])

    def test_existing_gate_rejects_inverted_results_and_skips(self):
        log = pathlib.Path(self.tmp.name) / 'invalid.jsonl'
        for expected, result, skipped, code in [
                ('red', 'success', False, '0'),
                ('green', 'failure', False, '1'),
                ('red', 'failure', True, '1'),
                ('green', 'success', True, '0')]:
            with self.subTest(expected=expected, skipped=skipped):
                events = [
                    {'type': 'testStart', 'test': {'id': 1, 'name': 'case'}},
                    {'type': 'testDone', 'testID': 1, 'result': result,
                     'skipped': skipped},
                ]
                log.write_text('\n'.join(map(json.dumps, events)) + '\n')
                check = subprocess.run(
                    ['python3', str(ROOT / 'tools/table_truth_evidence_v1.py'),
                     'tests', str(log), expected, code], capture_output=True, text=True)
                self.assertNotEqual(check.returncode, 0)


if __name__ == '__main__':
    unittest.main()
