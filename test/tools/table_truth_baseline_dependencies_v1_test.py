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

    def test_workflow_rejects_runtime_sentinel_before_existing_red_validator(self):
        workflow = (ROOT / '.github/workflows/table-truth.yml').read_text()
        matches = re.findall(
            r'(?ms)^          if grep -q SHARKY_BASELINE_PRICE_ORDER_SHIM_EXECUTED '
            r'"\$OUT/baseline-tests\.jsonl"; then\n.*?^          fi\n', workflow)
        self.assertEqual(len(matches), 1, 'Use the actual sole workflow sentinel guard')
        guard = matches[0]
        self.assertLess(workflow.index(guard), workflow.index(
            'python3 tools/table_truth_evidence_v1.py tests "$OUT/baseline-tests.jsonl" red "$code"'))
        log = pathlib.Path(self.tmp.name) / 'baseline-tests.jsonl'
        for invoked in [False, True]:
            with self.subTest(invoked=invoked):
                events = [{'type': 'testStart', 'test': {'id': 1, 'name': 'SYNTHETIC RED'}},
                          {'type': 'testDone', 'testID': 1, 'result': 'failure'}]
                if invoked:
                    events.insert(1, {'type': 'error', 'error': ADAPTER.ORDER_SENTINEL})
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


class ChoiceTransitionControls(unittest.TestCase):
    """Synthetic comparator inputs; never substitute for real source evidence."""
    TASK = 'first_table_guide_one_clear_choice'
    OLD = 'CO/cutoff already folded, so You at BTN act next'
    NEW = 'CO/cutoff still acts before You at BTN'
    PREFERRED = 'You are BTN, blinds are posted, and no board is out yet'
    OLD_FP = '0089e0394bdc30b3ce7d65dec1d098b8ae08a10b8eb2d504acf7456a7f14b4da'
    NEW_FP = '68083c5acfb7594a176f7e2b6a2a966f0e2a921e32aa9be7a12c31b6ebfbf0f5'

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = pathlib.Path(self.tmp.name)
        self.before_choices = {self.TASK: [
            ['co_still_acting', self.OLD, False, 'wrong', self.PREFERRED],
            ['hero_btn_preflop_setup', self.PREFERRED, True, 'correct', self.PREFERRED],
        ], 'other_task': [['other_choice', 'Original', True, 'correct', 'Original']]}
        self.after_choices = json.loads(json.dumps(self.before_choices))
        self.after_choices[self.TASK][0][1] = self.NEW
        self.before_fp = {self.TASK: {'world_id': 'world_1', 'lesson_id': 'what_poker_is',
                                     'fingerprint': self.OLD_FP},
                          'other_task': {'world_id': 'world_1', 'lesson_id': 'other',
                                         'fingerprint': 'unchanged-test-fixture'}}
        self.after_fp = json.loads(json.dumps(self.before_fp))
        self.after_fp[self.TASK]['fingerprint'] = self.NEW_FP
        self.contract = {self.TASK: {'rewardXp': 5, 'family': 'decision',
            'options': [{'id': 'co_still_acting', 'correct': False, 'quality': 'wrong',
                         'repairSeats': ['btn'], 'repairCards': [], 'repairLabels': []}]}}
        for phase, choices, fingerprints in [
                ('baseline', self.before_choices, self.before_fp),
                ('candidate', self.after_choices, self.after_fp)]:
            self.put(phase, 'choice-identity', choices)
            self.put(phase, 'source-fingerprints', fingerprints)
            self.put(phase, 'learning-contract', self.contract)
            self.put(phase, 'runtime-inputs', {t: {'options': rows} for t, rows in choices.items()})
            self.put(phase, 'ledger', [{'task_id': self.TASK, 'phase': 'decision',
                'invariant': 'synthetic-source-case', 'status': 'FAIL' if phase == 'baseline' else 'PASS'}])

    def put(self, phase, name, value):
        path = self.root / phase / (name + '.json')
        path.parent.mkdir(exist_ok=True)
        path.write_text(json.dumps(value))

    def run_compare(self):
        return subprocess.run([sys.executable, str(ROOT / 'tools/table_truth_evidence_v1.py'),
                               'compare', str(self.root)], capture_output=True, text=True)

    def reject(self):
        result = self.run_compare()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertFalse((self.root / 'comparison.json').exists())

    def test_exact_authorized_transition_records_truthful_delta_without_rewriting_inputs(self):
        originals = {str(p): p.read_bytes() for phase in ['baseline', 'candidate']
                     for p in (self.root / phase).glob('*.json')}
        result = self.run_compare()
        self.assertEqual(result.returncode, 0, result.stderr)
        evidence = json.loads((self.root / 'comparison.json').read_text())
        self.assertFalse(evidence['choice_identity_identical'])
        self.assertTrue(evidence['choice_identity_compatible'])
        delta = evidence['choice_identity_changes']
        self.assertEqual(len(delta), 1)
        self.assertEqual(delta[0]['task_id'], self.TASK)
        self.assertEqual(delta[0]['choice_id'], 'co_still_acting')
        self.assertEqual(delta[0]['index'], 0)
        self.assertEqual(delta[0]['field'], 'label')
        self.assertEqual(delta[0]['before'], self.before_choices[self.TASK][0])
        self.assertEqual(delta[0]['after'], self.after_choices[self.TASK][0])
        self.assertEqual(delta[0]['before_source_fingerprint'], self.OLD_FP)
        self.assertEqual(delta[0]['after_source_fingerprint'], self.NEW_FP)
        classification = json.loads((self.root / 'source-fingerprint-delta.json').read_text())[self.TASK]
        self.assertEqual(classification['classification'], 'SOURCE_CONDITION_CHANGED')
        self.assertEqual(classification['current_source_policy'], 'reject old fingerprint')
        self.assertIn('retain original fingerprint', classification['historical_record_policy'])
        self.assertEqual(originals, {p: pathlib.Path(p).read_bytes() for p in originals})

    def test_unchanged_choice_contract_remains_accepted_without_migration(self):
        self.put('candidate', 'choice-identity', self.before_choices)
        result = self.run_compare()
        self.assertEqual(result.returncode, 0, result.stderr)
        evidence = json.loads((self.root / 'comparison.json').read_text())
        self.assertTrue(evidence['choice_identity_identical'])
        self.assertEqual(evidence.get('choice_identity_changes', []), [])

    def test_unapproved_new_text_is_rejected(self):
        self.after_choices[self.TASK][0][1] = self.NEW + ' altered'
        self.put('candidate', 'choice-identity', self.after_choices)
        self.reject()

    def test_unapproved_old_text_is_rejected(self):
        self.before_choices[self.TASK][0][1] = 'Different historical meaning'
        self.put('baseline', 'choice-identity', self.before_choices)
        self.reject()

    def test_transition_on_another_task_is_rejected(self):
        for phase, choices, fingerprints in [('baseline', self.before_choices, self.before_fp),
                                             ('candidate', self.after_choices, self.after_fp)]:
            choices['renamed_task'] = choices.pop(self.TASK)
            fingerprints['renamed_task'] = fingerprints.pop(self.TASK)
            self.put(phase, 'choice-identity', choices)
            self.put(phase, 'source-fingerprints', fingerprints)
        self.reject()

    def test_transition_on_another_choice_is_rejected(self):
        for phase, choices in [('baseline', self.before_choices), ('candidate', self.after_choices)]:
            choices[self.TASK][0][0] = 'different_choice'
            self.put(phase, 'choice-identity', choices)
        self.reject()

    def test_second_label_change_is_rejected(self):
        self.after_choices['other_task'][0][1] = 'Second changed label'
        self.put('candidate', 'choice-identity', self.after_choices)
        self.reject()

    def test_order_change_is_rejected(self):
        self.after_choices[self.TASK].reverse()
        self.put('candidate', 'choice-identity', self.after_choices)
        self.reject()

    def test_transition_at_a_different_index_is_rejected(self):
        for phase, choices in [('baseline', self.before_choices), ('candidate', self.after_choices)]:
            choices[self.TASK].reverse()
            self.put(phase, 'choice-identity', choices)
        self.reject()

    def test_correctness_quality_and_preferred_answer_changes_are_rejected(self):
        for index, value in [(2, True), (3, 'suboptimal'), (4, 'Different preferred answer')]:
            with self.subTest(field=index):
                changed = json.loads(json.dumps(self.after_choices))
                changed[self.TASK][0][index] = value
                self.put('candidate', 'choice-identity', changed)
                self.reject()

    def test_wrong_full_historical_row_is_rejected_even_when_flags_agree(self):
        for phase, choices in [('baseline', self.before_choices), ('candidate', self.after_choices)]:
            choices[self.TASK][0][3] = 'suboptimal'
            self.put(phase, 'choice-identity', choices)
        self.reject()

    def test_missing_task_or_added_choice_is_rejected(self):
        for remove_task in [True, False]:
            with self.subTest(remove_task=remove_task):
                changed = json.loads(json.dumps(self.after_choices))
                if remove_task:
                    del changed['other_task']
                else:
                    changed[self.TASK].append(['new', 'Extra', False, 'wrong', self.PREFERRED])
                self.put('candidate', 'choice-identity', changed)
                self.reject()

    def test_missing_or_unapproved_source_fingerprint_is_rejected(self):
        for value in [self.OLD_FP, '', 'unapproved-new-source']:
            with self.subTest(fingerprint=value):
                changed = json.loads(json.dumps(self.after_fp))
                changed[self.TASK]['fingerprint'] = value
                self.put('candidate', 'source-fingerprints', changed)
                self.reject()

    def test_unapproved_historical_fingerprint_is_rejected(self):
        self.before_fp[self.TASK]['fingerprint'] = 'unapproved-history'
        self.put('baseline', 'source-fingerprints', self.before_fp)
        self.reject()

    def test_source_world_or_lesson_drift_is_rejected(self):
        for field in ['world_id', 'lesson_id']:
            with self.subTest(field=field):
                changed = json.loads(json.dumps(self.after_fp))
                changed[self.TASK][field] = 'different-owner'
                self.put('candidate', 'source-fingerprints', changed)
                self.reject()

    def test_xp_repair_and_other_learning_contract_drift_is_rejected(self):
        for field, value in [('rewardXp', 999), ('family', 'transfer'),
                             ('assistance', 'changed'), ('persistence', 'changed')]:
            with self.subTest(field=field):
                changed = json.loads(json.dumps(self.contract))
                changed[self.TASK][field] = value
                self.put('candidate', 'learning-contract', changed)
                self.reject()
        for field, value in [('id', 'renamed'), ('correct', True), ('quality', 'correct'),
                             ('repairSeats', ['bb']), ('repairCards', ['hero_0']),
                             ('repairLabels', ['different'])]:
            with self.subTest(option_field=field):
                changed = json.loads(json.dumps(self.contract))
                changed[self.TASK]['options'][0][field] = value
                self.put('candidate', 'learning-contract', changed)
                self.reject()

    def test_required_genuine_baseline_red_and_candidate_green_remain_enforced(self):
        for phase, status in [('baseline', 'PASS'), ('candidate', 'FAIL')]:
            with self.subTest(phase=phase):
                self.put(phase, 'ledger', [{'task_id': self.TASK, 'phase': 'decision',
                    'invariant': 'synthetic-source-case', 'status': status}])
                self.reject()
                self.put(phase, 'ledger', [{'task_id': self.TASK, 'phase': 'decision',
                    'invariant': 'synthetic-source-case', 'status': 'FAIL' if phase == 'baseline' else 'PASS'}])


if __name__ == '__main__':
    unittest.main()
