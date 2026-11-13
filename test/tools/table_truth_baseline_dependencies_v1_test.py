"""Controls for historical-source preservation and strict gate error rejection."""
import importlib.util
import os
import re
import textwrap
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


    def test_legacy_compile_only_shim_rejects_mismatched_provenance(self):
        key = ADAPTER.PRICE_DEPENDENCY
        self.put(self.baseline, key, 'source')
        self.put(
            self.baseline, 'lib/ui_v2/act0_shell/act0_street_replay_contract_v1.dart',
            'historical')
        with self.assertRaisesRegex(RuntimeError, 'Historical street contract changed'):
            ADAPTER.add_legacy_compile_only_shim(
                self.baseline, ADAPTER.LEGACY_HEAD, {
                    'copied_missing': {key: 'source'}})

    def test_legacy_compile_only_shim_never_modifies_other_head(self):
        key = ADAPTER.PRICE_DEPENDENCY
        self.put(self.baseline, key, 'source')
        before = (self.baseline / key).read_bytes()
        result = ADAPTER.add_legacy_compile_only_shim(
            self.baseline, 'nonlegacy-baseline', {'copied_missing': {key: 'source'}})
        self.assertIsNone(result)
        self.assertEqual((self.baseline / key).read_bytes(), before)

    def test_legacy_shim_has_failure_sentinel_not_simulated_order(self):
        self.assertIn("throw StateError", ADAPTER.ORDER_COMPILE_SHIM)
        self.assertIn(ADAPTER.ORDER_SENTINEL, ADAPTER.ORDER_COMPILE_SHIM)
        self.assertNotIn('return Act0BettingRoundOrderTruthV1', ADAPTER.ORDER_COMPILE_SHIM)


    def prepare_synthetic_legacy_copy(self):
        # Synthetic adapter controls only; this is not historical RED proof.
        source = ROOT / ADAPTER.PRICE_DEPENDENCY
        self.put(self.baseline, ADAPTER.PRICE_DEPENDENCY, source.read_text())
        street = 'lib/ui_v2/act0_shell/act0_street_replay_contract_v1.dart'
        self.put(self.baseline, street, '// SYNTHETIC historical dependency\n')
        return {'copied_missing': {
            ADAPTER.PRICE_DEPENDENCY:
                ADAPTER.digest(self.baseline / ADAPTER.PRICE_DEPENDENCY)},
            'preserved_existing': {street: ADAPTER.digest(self.baseline / street)}}

    def call_synthetic_legacy_copy(self, dependencies):
        # Only the synthetic street fixture digest is substituted. The price
        # bytes and final-candidate digest check remain real and unmocked.
        street = self.baseline / 'lib/ui_v2/act0_shell/act0_street_replay_contract_v1.dart'
        with mock.patch.object(ADAPTER, 'LEGACY_STREET_SHA256', ADAPTER.digest(street)):
            return ADAPTER.add_legacy_compile_only_shim(
                self.baseline, ADAPTER.LEGACY_HEAD, dependencies)

    def test_legacy_price_pin_is_the_exact_reviewed_final_source(self):
        self.assertEqual(ADAPTER.PRICE_CANDIDATE_SHA256,
                         'cf82f4c1daef79d0f4fe0bfd29d29b22bfa7bf840e7aadae22b87381d857b91e')
        self.assertEqual(ADAPTER.digest(ROOT / ADAPTER.PRICE_DEPENDENCY),
                         ADAPTER.PRICE_CANDIDATE_SHA256)
        self.assertEqual(ADAPTER.LEGACY_HEAD,
                         'fa079b6c5880814e231981a7bd5ed97df192d215')
        self.assertEqual(ADAPTER.LEGACY_STREET_SHA256,
                         'a0ea1b4adff04704bc83feee9397fea1c3abc03523539bd5805db3200ba7c7be')

    def test_legacy_changed_candidate_is_rejected_without_writing(self):
        dependencies = self.prepare_synthetic_legacy_copy()
        price = self.baseline / ADAPTER.PRICE_DEPENDENCY
        price.write_text(price.read_text() + '\n// SYNTHETIC candidate drift\n')
        dependencies['copied_missing'][ADAPTER.PRICE_DEPENDENCY] = ADAPTER.digest(price)
        before = price.read_bytes()
        with self.assertRaisesRegex(RuntimeError, 'Candidate price contract changed'):
            self.call_synthetic_legacy_copy(dependencies)
        self.assertEqual(price.read_bytes(), before)

    def test_legacy_existing_dependency_is_not_eligible_for_injection(self):
        self.prepare_synthetic_legacy_copy()
        self.put(self.baseline, 'lib/runner.dart',
                 "import 'ui_v2/act0_shell/act0_betting_price_contract_v1.dart';")
        self.put(self.baseline, ADAPTER.PRICE_DEPENDENCY,
                 '// SYNTHETIC pre-existing historical dependency\n')
        self.put(self.candidate, ADAPTER.PRICE_DEPENDENCY,
                 '// SYNTHETIC newer candidate must not replace history\n')
        dependencies = ADAPTER.complete_dependencies(
            self.candidate, self.baseline, ['lib/runner.dart'])
        self.assertNotIn(ADAPTER.PRICE_DEPENDENCY, dependencies['copied_missing'])
        self.assertIn(ADAPTER.PRICE_DEPENDENCY, dependencies['preserved_existing'])
        before = {str(p): p.read_bytes() for p in self.baseline.rglob('*') if p.is_file()}
        with self.assertRaisesRegex(RuntimeError, 'Expected missing candidate price dependency'):
            self.call_synthetic_legacy_copy(dependencies)
        self.assertEqual(before,
                         {str(p): p.read_bytes() for p in self.baseline.rglob('*') if p.is_file()})

    def test_legacy_duplicate_injection_is_rejected_without_second_append(self):
        dependencies = self.prepare_synthetic_legacy_copy()
        price = self.baseline / ADAPTER.PRICE_DEPENDENCY
        street = self.baseline / 'lib/ui_v2/act0_shell/act0_street_replay_contract_v1.dart'
        historical_before = street.read_bytes()
        result = self.call_synthetic_legacy_copy(dependencies)
        once = price.read_bytes()
        self.assertEqual(result['prior_sha256'], ADAPTER.PRICE_CANDIDATE_SHA256)
        self.assertEqual(result['after_sha256'], ADAPTER.digest(price))
        self.assertEqual(price.read_text().count(ADAPTER.ORDER_SENTINEL), 1)
        self.assertEqual(street.read_bytes(), historical_before)
        # A second call may reject on changed digest before the sentinel check.
        # Either way it must refuse and leave the once-adapted bytes intact.
        with self.assertRaises(RuntimeError):
            self.call_synthetic_legacy_copy(dependencies)
        self.assertEqual(price.read_bytes(), once)
        self.assertEqual(street.read_bytes(), historical_before)


    def prepare_synthetic_legacy_guide(self):
        # Synthetic constructor envelope only, never historical RED evidence.
        source = '// SYNTHETIC prefix\n' + ADAPTER.GUIDE_CONSTRUCTOR + '// unchanged body\n'
        self.put(self.baseline, ADAPTER.GUIDE_DEPENDENCY, source)
        self.put(self.baseline, ADAPTER.GUIDE_RUNNER,
                 (ROOT / ADAPTER.GUIDE_RUNNER).read_text())
        return {'copied_missing': {}, 'preserved_existing': {
            p: ADAPTER.digest(self.baseline / p)
            for p in (ADAPTER.GUIDE_DEPENDENCY, ADAPTER.GUIDE_RUNNER)}}

    def call_synthetic_legacy_guide(self, dependencies):
        # Only the synthetic Guide fixture pin is substituted. Runner bytes and
        # its reviewed pin remain real and unmocked, as with the price controls.
        guide_pin = dependencies['preserved_existing'][ADAPTER.GUIDE_DEPENDENCY]
        with mock.patch.object(ADAPTER, 'GUIDE_LEGACY_SHA256', guide_pin):
            return ADAPTER.add_legacy_guide_constructor_shim(
                self.baseline, ADAPTER.LEGACY_HEAD, dependencies)

    def test_legacy_guide_inputs_are_exact_reviewed_sources(self):
        self.assertEqual(ADAPTER.GUIDE_LEGACY_SHA256,
                         'e57900a6057525572045246ddd5d2a1630d3c15290c9e1b50cb056ab75419a63')
        self.assertEqual(ADAPTER.GUIDE_RUNNER_SHA256,
                         'd8d1190ae4861763b0568c5e5576a1d334c5f09f39900926546212614389d0ca')
        self.assertEqual(ADAPTER.GUIDE_REVIEWED_RUNNER_SHA256S, frozenset({
            ADAPTER.GUIDE_RUNNER_SHA256,
            '452826ea65dff12c1ae5ee8d9e0e52aa5925762ab0145b1a2bc409c85780ff6c',
        }))
        self.assertIn(ADAPTER.digest(ROOT / ADAPTER.GUIDE_RUNNER),
                      ADAPTER.GUIDE_REVIEWED_RUNNER_SHA256S)

    def test_legacy_guide_only_changes_constructor_and_records_exception(self):
        dependencies = self.prepare_synthetic_legacy_guide()
        guide = self.baseline / ADAPTER.GUIDE_DEPENDENCY
        before = guide.read_text()
        result = self.call_synthetic_legacy_guide(dependencies)
        self.assertEqual(guide.read_text().replace(
            ADAPTER.GUIDE_COMPATIBLE_CONSTRUCTOR, ADAPTER.GUIDE_CONSTRUCTOR), before)
        self.assertIn('bool scrollSupport = false,', ADAPTER.GUIDE_COMPATIBLE_CONSTRUCTOR)
        self.assertIn(f"assert(!scrollSupport, '{ADAPTER.GUIDE_SENTINEL}')",
                      ADAPTER.GUIDE_COMPATIBLE_CONSTRUCTOR)
        self.assertEqual(guide.read_text().count(ADAPTER.GUIDE_SENTINEL), 1)
        self.assertEqual(result['after_sha256'], ADAPTER.digest(guide))
        self.assertNotIn(ADAPTER.GUIDE_DEPENDENCY, dependencies['preserved_existing'])
        self.assertEqual(ADAPTER.digest(self.baseline / ADAPTER.GUIDE_RUNNER),
                         ADAPTER.digest(ROOT / ADAPTER.GUIDE_RUNNER))
        self.assertEqual(result['runner_sha256'],
                         ADAPTER.digest(self.baseline / ADAPTER.GUIDE_RUNNER))

    def test_back_only_runner_reverses_to_original_reviewed_input(self):
        dependencies = self.prepare_synthetic_legacy_guide()
        runner = self.baseline / ADAPTER.GUIDE_RUNNER
        current = runner.read_text()
        self.assertEqual(ADAPTER.digest(runner), ADAPTER.GUIDE_BACK_RUNNER_SHA256)
        new_back = r"""          width: 48,
          height: 48,
          child: IconButton(
            key: const Key('act0_shell_runner_back'),
            tooltip: act0AcademyLanguageV1(context) == 'ru'
                ? '\u041d\u0430\u0437\u0430\u0434'
                : 'Back',
"""
        old_back = """          width: 34,
          height: 34,
          child: IconButton(
            key: const Key('act0_shell_runner_back'),
"""
        self.assertEqual(current.count(new_back), 1)
        runner.write_text(current.replace(new_back, old_back, 1))
        self.assertEqual(ADAPTER.digest(runner), ADAPTER.GUIDE_RUNNER_SHA256)
        dependencies['preserved_existing'][ADAPTER.GUIDE_RUNNER] = ADAPTER.digest(runner)
        result = self.call_synthetic_legacy_guide(dependencies)
        self.assertEqual(result['runner_sha256'], ADAPTER.GUIDE_RUNNER_SHA256)

    def test_unknown_runner_is_rejected_even_with_matching_manifest(self):
        dependencies = self.prepare_synthetic_legacy_guide()
        runner = self.baseline / ADAPTER.GUIDE_RUNNER
        runner.write_text(runner.read_text() + '// SYNTHETIC arbitrary drift\n')
        dependencies['preserved_existing'][ADAPTER.GUIDE_RUNNER] = ADAPTER.digest(runner)
        before = {str(p): p.read_bytes() for p in self.baseline.rglob('*') if p.is_file()}
        with self.assertRaisesRegex(RuntimeError, 'compatibility input changed'):
            self.call_synthetic_legacy_guide(dependencies)
        self.assertEqual(before, {str(p): p.read_bytes() for p in self.baseline.rglob('*') if p.is_file()})

    def test_reviewed_runner_rejects_wrong_manifest_without_writing(self):
        dependencies = self.prepare_synthetic_legacy_guide()
        runner = self.baseline / ADAPTER.GUIDE_RUNNER
        self.assertEqual(ADAPTER.digest(runner), ADAPTER.GUIDE_BACK_RUNNER_SHA256)
        dependencies['preserved_existing'][ADAPTER.GUIDE_RUNNER] = ADAPTER.GUIDE_RUNNER_SHA256
        before = {str(p): p.read_bytes() for p in self.baseline.rglob('*') if p.is_file()}
        with self.assertRaisesRegex(RuntimeError, 'compatibility input changed'):
            self.call_synthetic_legacy_guide(dependencies)
        self.assertEqual(before, {str(p): p.read_bytes() for p in self.baseline.rglob('*') if p.is_file()})

    def test_legacy_guide_input_drift_is_rejected_without_writing(self):
        for relative in (ADAPTER.GUIDE_DEPENDENCY, ADAPTER.GUIDE_RUNNER):
            with self.subTest(relative=relative):
                dependencies = self.prepare_synthetic_legacy_guide()
                path = self.baseline / relative
                path.write_text(path.read_text() + '// SYNTHETIC drift\n')
                before = {str(p): p.read_bytes() for p in self.baseline.rglob('*') if p.is_file()}
                with self.assertRaisesRegex(RuntimeError, 'compatibility input changed'):
                    self.call_synthetic_legacy_guide(dependencies)
                self.assertEqual(before,
                                 {str(p): p.read_bytes() for p in self.baseline.rglob('*') if p.is_file()})

    def test_legacy_guide_must_be_preserved_not_copied(self):
        dependencies = self.prepare_synthetic_legacy_guide()
        dependencies['copied_missing'][ADAPTER.GUIDE_DEPENDENCY] = 'ineligible'
        guide = self.baseline / ADAPTER.GUIDE_DEPENDENCY
        before = guide.read_bytes()
        with self.assertRaisesRegex(RuntimeError, 'compatibility input changed'):
            self.call_synthetic_legacy_guide(dependencies)
        self.assertEqual(guide.read_bytes(), before)

    def test_legacy_guide_duplicate_injection_is_rejected_without_writing(self):
        dependencies = self.prepare_synthetic_legacy_guide()
        self.call_synthetic_legacy_guide(dependencies)
        guide = self.baseline / ADAPTER.GUIDE_DEPENDENCY
        once = guide.read_bytes()
        with self.assertRaisesRegex(RuntimeError, 'compatibility input changed'):
            ADAPTER.add_legacy_guide_constructor_shim(
                self.baseline, ADAPTER.LEGACY_HEAD, dependencies)
        self.assertEqual(guide.read_bytes(), once)

    def test_legacy_guide_never_modifies_other_head(self):
        dependencies = self.prepare_synthetic_legacy_guide()
        before = {str(p): p.read_bytes() for p in self.baseline.rglob('*') if p.is_file()}
        self.assertIsNone(ADAPTER.add_legacy_guide_constructor_shim(
            self.baseline, 'nonlegacy-baseline', dependencies))
        self.assertEqual(before,
                         {str(p): p.read_bytes() for p in self.baseline.rglob('*') if p.is_file()})

    def test_workflow_rejects_runtime_sentinel_before_existing_red_validator(self):
        workflow = (ROOT / '.github/workflows/table-truth.yml').read_text()
        matches = re.findall(
            r'(?ms)^          if grep -q -e SHARKY_BASELINE_PRICE_ORDER_SHIM_EXECUTED '
            r'-e SHARKY_BASELINE_GUIDE_SCROLL_SHIM_EXECUTED '
            r'"\$OUT/baseline-tests\.jsonl"; then\n.*?^          fi\n', workflow)
        self.assertEqual(len(matches), 1, 'Use the actual sole workflow sentinel guard')
        guard = matches[0]
        self.assertLess(workflow.index(guard), workflow.index(
            'python3 tools/table_truth_evidence_v1.py tests "$OUT/baseline-tests.jsonl" red "$code"'))
        log = pathlib.Path(self.tmp.name) / 'baseline-tests.jsonl'
        for sentinel in [None, ADAPTER.ORDER_SENTINEL, ADAPTER.GUIDE_SENTINEL]:
            invoked = sentinel is not None
            with self.subTest(sentinel=sentinel):
                events = [{'type': 'testStart', 'test': {'id': 1, 'name': 'SYNTHETIC RED'}},
                          {'type': 'testDone', 'testID': 1, 'result': 'failure'}]
                if invoked:
                    events.insert(1, {'type': 'error', 'error': sentinel})
                log.write_text('\n'.join(map(json.dumps, events)) + '\n')
                # The existing validator is unchanged and accepts this RED.
                validator = subprocess.run(
                    [sys.executable, str(ROOT / 'tools/table_truth_evidence_v1.py'),
                     'tests', str(log), 'red', '1'], capture_output=True, text=True)
                self.assertEqual(validator.returncode, 0, validator.stderr)
                env = os.environ.copy()
                env['OUT'] = self.tmp.name
                checked = subprocess.run(
                    ['bash', '-c', textwrap.dedent(guard) +
                     "printf 'RED_VALIDATOR_REACHED\\n'\n"],
                    env=env, capture_output=True, text=True)
                self.assertEqual(checked.returncode, 1 if invoked else 0, checked.stderr)
                self.assertEqual('RED_VALIDATOR_REACHED' in checked.stdout, not invoked)

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
