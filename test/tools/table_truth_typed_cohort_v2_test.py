#!/usr/bin/env python3
import copy
import hashlib
import importlib.util
import json
import pathlib
import shutil
import sys
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    'truth', ROOT / 'tools/table_truth_evidence_v1.py'
)
TRUTH = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(TRUTH)
CANONICAL = json.loads(
    (ROOT / 'test/tools/fixtures/table_truth_asm05_new_authoring_v1.json').read_text()
)
NEW = set(CANONICAL['tasks'])


class TypedCohortV2Controls(unittest.TestCase):
    def fixture(self):
        root = pathlib.Path(tempfile.mkdtemp())
        historical = {f'historical_{index:03d}' for index in range(367)}
        base_contract = {key: {'identity': key} for key in historical}
        base_fingerprints = {
            key: {
                'world_id': 'world_1',
                'lesson_id': 'historical',
                'fingerprint': f'historical-fingerprint-{key}',
            }
            for key in historical
        }
        base_choices = {key: [['fold', 'Fold', True, 'correct', 'Fold']] for key in historical}
        base_runtime = {key: {'caption': key, 'table': {'actor': 'bb'}} for key in historical}
        for phase in ('baseline', 'candidate'):
            out = root / phase
            out.mkdir()
            contract = copy.deepcopy(base_contract)
            fingerprints = copy.deepcopy(base_fingerprints)
            choices = copy.deepcopy(base_choices)
            runtime = copy.deepcopy(base_runtime)
            if phase == 'candidate':
                for task_id, record in CANONICAL['tasks'].items():
                    contract[task_id] = copy.deepcopy(record['learning_contract'])
                    fingerprints[task_id] = copy.deepcopy(record['source_fingerprint'])
                    choices[task_id] = copy.deepcopy(record['choice_identity'])
                    runtime[task_id] = copy.deepcopy(record['runtime_input'])
            self.write(out / 'learning-contract.json', contract)
            self.write(out / 'source-fingerprints.json', fingerprints)
            self.write(out / 'choice-identity.json', choices)
            self.write(out / 'runtime-inputs.json', runtime)
            self.write(
                out / 'ledger.json',
                [
                    {
                        'task_id': 'historical_000',
                        'phase': 'authored/drill',
                        'status': 'FAIL',
                        'result': 'FAIL',
                        'invariant': 'HISTORICAL_RED',
                    }
                ]
                if phase == 'baseline'
                else [],
            )
            self.write(
                out / 'typed-cohort-v2.json',
                self.cohort(phase, historical, contract, fingerprints, choices, runtime),
            )
        return root

    def cohort(self, phase, historical, contract, fingerprints, choices, runtime):
        role = 'historical_baseline' if phase == 'baseline' else 'candidate'
        reference = copy.deepcopy(TRUTH.SOURCE_REFERENCES[role])
        cohort = {
            'schema': 2,
            'role': role,
            'admitted_source_reference': reference,
            'producer_receipt': {
                'head': ('a' if phase == 'baseline' else 'b') * 40,
                'state_sha256': reference['state_sha256'],
                'factory_sha256': reference['factory_sha256'],
            },
            'historical_ids': sorted(historical),
            'new_authoring': [],
        }
        if phase == 'candidate':
            for task_id in sorted(NEW):
                bundle = [
                    contract[task_id],
                    fingerprints[task_id],
                    choices[task_id],
                    runtime[task_id],
                ]
                cohort['new_authoring'].append(
                    {
                        'task_id': task_id,
                        'world_id': 'world_12',
                        'lesson_id': 'decision_over_outcome',
                        'provenance': 'NEW_AUTHORING_ASM05',
                        'artifact_sha256': TRUTH._digest(bundle),
                        'source_binding_sha256': TRUTH._digest(
                            [reference, task_id, bundle]
                        ),
                    }
                )
        return cohort

    def test_complete_captured_canonical_records_are_accepted_at_cohort_layer(self):
        identity = TRUTH.validate_typed_cohort(self.fixture())
        self.assertEqual(set(identity['additions']), NEW)

    def test_legitimate_changed_producer_head_with_identical_source_bytes_is_accepted(self):
        root = self.fixture()
        cohort = self.read(root / 'candidate/typed-cohort-v2.json')
        cohort['producer_receipt']['head'] = 'c' * 40
        self.write(root / 'candidate/typed-cohort-v2.json', cohort)
        TRUTH.validate_typed_cohort(root)

    def test_wrong_source_receipt_is_rejected(self):
        root = self.fixture()
        cohort = self.read(root / 'candidate/typed-cohort-v2.json')
        cohort['producer_receipt']['state_sha256'] = '0' * 64
        self.write(root / 'candidate/typed-cohort-v2.json', cohort)
        self.rejects(root, 'Producing source receipt')

    def test_recomputed_checksums_cannot_bless_forged_runtime_model(self):
        root = self.fixture()
        task_id = 'asm05_new_known_holes_turn_call_10'
        runtime = self.read(root / 'candidate/runtime-inputs.json')
        runtime[task_id]['table']['hero'] = ['Ah', 'Ad']
        self.write(root / 'candidate/runtime-inputs.json', runtime)
        self.recompute(root, task_id)
        self.rejects(root, 'canonical record mismatch')

    def test_recomputed_checksums_cannot_bless_false_fingerprint(self):
        root = self.fixture()
        task_id = 'asm05_new_known_holes_turn_call_40'
        fingerprints = self.read(root / 'candidate/source-fingerprints.json')
        fingerprints[task_id]['fingerprint'] = 'f' * 64
        self.write(root / 'candidate/source-fingerprints.json', fingerprints)
        self.recompute(root, task_id)
        self.rejects(root, 'canonical record mismatch')

    def test_regression_twenty_d3_failures_would_remain_blocking_for_full_compare(self):
        root = self.fixture()
        failures = [
            {
                'task_id': task_id,
                'phase': f'captured/variant_{index}',
                'status': 'FAIL',
                'result': 'FAIL',
                'invariant': 'D3.no_old_blind',
                'reason': f'captured {task_id} D3 failure {index}',
            }
            for task_id in sorted(NEW)
            for index in range(10)
        ]
        self.write(root / 'candidate/ledger.json', failures)
        with self.assertRaisesRegex(SystemExit, 'Candidate retains invariant failures'):
            TRUTH.compare(root)

    def test_historical_runtime_and_fingerprint_repairs_are_classified(self):
        root = self.fixture()
        runtime = self.read(root / 'candidate/runtime-inputs.json')
        runtime['historical_000']['caption'] = 'repaired presentation'
        self.write(root / 'candidate/runtime-inputs.json', runtime)
        fingerprints = self.read(root / 'candidate/source-fingerprints.json')
        fingerprints['historical_000']['fingerprint'] = '1' * 64
        self.write(root / 'candidate/source-fingerprints.json', fingerprints)
        TRUTH.compare(root)
        comparison = self.read(root / 'comparison.json')
        delta = self.read(root / 'source-fingerprint-delta.json')
        self.assertEqual(comparison['runtime_changed_task_count'], 1)
        self.assertEqual(
            delta['historical_000']['classification'],
            'SOURCE_CONDITION_CHANGED',
        )

    def test_invalid_historical_runtime_semantics_remain_ledger_blocked(self):
        mutations = {
            'actor': 'D4.actor_order',
            'bet': 'D5.bet_accounting',
            'folded': 'D7.fold_state',
            'terminal': 'D8.terminal_state',
            'outcome': 'D9.outcome_state',
        }
        for field, invariant in mutations.items():
            with self.subTest(field=field):
                root = self.fixture()
                runtime = self.read(root / 'candidate/runtime-inputs.json')
                runtime['historical_000']['table'][field] = 'invalid'
                self.write(root / 'candidate/runtime-inputs.json', runtime)
                self.write(
                    root / 'candidate/ledger.json',
                    [
                        {
                            'task_id': 'historical_000',
                            'phase': 'authored/drill',
                            'status': 'FAIL',
                            'result': 'FAIL',
                            'invariant': invariant,
                            'reason': f'invalid {field}',
                        }
                    ],
                )
                with self.assertRaisesRegex(
                    SystemExit, 'Candidate retains invariant failures'
                ):
                    TRUTH.compare(root)

    def test_unknown_addition_is_rejected(self):
        root = self.fixture()
        cohort = self.read(root / 'candidate/typed-cohort-v2.json')
        extra = copy.deepcopy(cohort['new_authoring'][0])
        extra['task_id'] = 'unknown_new_authoring'
        cohort['new_authoring'].append(extra)
        self.write(root / 'candidate/typed-cohort-v2.json', cohort)
        self.rejects(root, 'missing or contains unknown')

    def test_missing_addition_is_rejected(self):
        root = self.fixture()
        cohort = self.read(root / 'candidate/typed-cohort-v2.json')
        cohort['new_authoring'].pop()
        self.write(root / 'candidate/typed-cohort-v2.json', cohort)
        self.rejects(root, 'missing or contains unknown')

    def test_duplicate_addition_is_rejected(self):
        root = self.fixture()
        cohort = self.read(root / 'candidate/typed-cohort-v2.json')
        cohort['new_authoring'].append(copy.deepcopy(cohort['new_authoring'][0]))
        self.write(root / 'candidate/typed-cohort-v2.json', cohort)
        self.rejects(root, 'missing or contains unknown')

    def test_addition_in_historical_baseline_is_rejected(self):
        root = self.fixture()
        cohort = self.read(root / 'baseline/typed-cohort-v2.json')
        cohort['new_authoring'] = [{'task_id': 'forbidden'}]
        self.write(root / 'baseline/typed-cohort-v2.json', cohort)
        self.rejects(root, 'Historical baseline contains')

    def test_historical_mutation_is_rejected(self):
        root = self.fixture()
        contract = self.read(root / 'candidate/learning-contract.json')
        contract['historical_000']['identity'] = 'changed'
        self.write(root / 'candidate/learning-contract.json', contract)
        self.rejects(root, 'Learning identity')

    def test_historical_removal_is_rejected(self):
        root = self.fixture()
        contract = self.read(root / 'candidate/learning-contract.json')
        contract.pop('historical_000')
        self.write(root / 'candidate/learning-contract.json', contract)
        self.rejects(root, 'cohort key set')

    def test_wrong_learning_xp_is_rejected(self):
        root = self.fixture()
        contract = self.read(root / 'candidate/learning-contract.json')
        contract['asm05_new_known_holes_turn_call_10']['rewardXp'] = 9
        self.write(root / 'candidate/learning-contract.json', contract)
        self.rejects(root, 'canonical record mismatch')

    def test_wrong_learning_correctness_is_rejected(self):
        root = self.fixture()
        contract = self.read(root / 'candidate/learning-contract.json')
        contract['asm05_new_known_holes_turn_call_40']['options'][0]['correct'] = False
        self.write(root / 'candidate/learning-contract.json', contract)
        self.rejects(root, 'canonical record mismatch')

    def test_wrong_choice_order_is_rejected(self):
        root = self.fixture()
        choices = self.read(root / 'candidate/choice-identity.json')
        choices['asm05_new_known_holes_turn_call_10'].reverse()
        self.write(root / 'candidate/choice-identity.json', choices)
        self.rejects(root, 'canonical record mismatch')

    def test_missing_nested_model_evidence_is_rejected(self):
        root = self.fixture()
        runtime = self.read(root / 'candidate/runtime-inputs.json')
        runtime['asm05_new_known_holes_turn_call_40']['table'].pop('board')
        self.write(root / 'candidate/runtime-inputs.json', runtime)
        self.rejects(root, 'canonical record mismatch')

    def test_malformed_world_identity_is_rejected(self):
        root = self.fixture()
        cohort = self.read(root / 'candidate/typed-cohort-v2.json')
        cohort['new_authoring'][0]['world_id'] = 'wrong_world'
        self.write(root / 'candidate/typed-cohort-v2.json', cohort)
        self.rejects(root, 'identity is malformed')

    def reviewed_cells(self):
        return {
            TRUTH.MAIN01_TASK_ID: {
                'rewardXp': 5,
                'options': [
                    {'id': 'co_still_acting', 'correct': False, 'quality': 'suboptimal'},
                    {'id': 'hero_btn_preflop_setup', 'correct': True, 'quality': 'correct'},
                    {'id': 'hero_has_no_cards', 'correct': False, 'quality': 'wrong'},
                ],
            },
            'unchanged_control': {'rewardXp': 7},
        }

    def reviewed_producer(self):
        cohort = {'admitted_source_reference': copy.deepcopy(TRUTH.SOURCE_REFERENCES['candidate']),
                  'producer_receipt': {'head': 'd' * 40, **{
                      key: TRUTH.MAIN01_PRODUCER_REVISION[key]
                      for key in ('state_sha256', 'factory_sha256')}}}
        return cohort

    def test_reviewed_exact_producer_bytes_are_separate_from_authoring_origin(self):
        cohort = self.reviewed_producer()
        self.assertEqual(TRUTH.producer_revision(cohort, 'candidate'), 'MAIN01_REVIEWED_SETUP_QUALITIES')
        self.assertEqual(cohort['admitted_source_reference']['commit'], CANONICAL['admitted_source_reference'])
        cohort['producer_receipt']['head'] = 'e' * 40
        self.assertEqual(TRUTH.producer_revision(cohort, 'candidate'), 'MAIN01_REVIEWED_SETUP_QUALITIES')

    def test_reviewed_unknown_state_factory_origin_and_head_are_rejected(self):
        for field, replacement in [('state_sha256', '0' * 64), ('factory_sha256', '1' * 64), ('head', 'not-a-sha')]:
            with self.subTest(field=field):
                cohort = self.reviewed_producer()
                cohort['producer_receipt'][field] = replacement
                with self.assertRaises(SystemExit):
                    TRUTH.producer_revision(cohort, 'candidate')
        cohort = self.reviewed_producer()
        cohort['admitted_source_reference']['commit'] = TRUTH.MAIN01_PRODUCER_REVISION['source_revision']
        with self.assertRaisesRegex(SystemExit, 'Admitted source reference'):
            TRUTH.producer_revision(cohort, 'candidate')

    def test_reviewed_quality_normalization_changes_only_exact_two_cells_in_memory(self):
        captured = self.reviewed_cells()
        frozen = copy.deepcopy(captured)
        origin = TRUTH.main01_origin_capture('learning-contract.json', captured)
        self.assertEqual(captured, frozen)
        expected = copy.deepcopy(frozen)
        expected[TRUTH.MAIN01_TASK_ID]['options'][0]['quality'] = 'wrong'
        expected[TRUTH.MAIN01_TASK_ID]['options'][2]['quality'] = 'suboptimal'
        self.assertEqual(origin, expected)
        choices = {TRUTH.MAIN01_TASK_ID: [
            ['co_still_acting', 'partial', False, 'suboptimal', 'full'],
            ['hero_btn_preflop_setup', 'full', True, 'correct', 'full'],
            ['hero_has_no_cards', 'false', False, 'wrong', 'full'],
        ]}
        before = copy.deepcopy(choices)
        normalized = TRUTH.main01_origin_capture('choice-identity.json', choices)
        self.assertEqual(choices, before)
        before[TRUTH.MAIN01_TASK_ID][0][3] = 'wrong'
        before[TRUTH.MAIN01_TASK_ID][2][3] = 'suboptimal'
        self.assertEqual(normalized, before)

    def test_reviewed_quality_cells_cannot_be_missing_reversed_or_correct(self):
        for mutation in ('missing', 'old_quality', 'correctness', 'duplicate'):
            with self.subTest(mutation=mutation):
                captured = self.reviewed_cells()
                options = captured[TRUTH.MAIN01_TASK_ID]['options']
                if mutation == 'missing': options.pop()
                elif mutation == 'old_quality': options[0]['quality'] = 'wrong'
                elif mutation == 'correctness': options[2]['correct'] = True
                else: options.append(copy.deepcopy(options[0]))
                with self.assertRaisesRegex(SystemExit, 'MAIN01 exact quality'):
                    TRUTH.main01_origin_capture('learning-contract.json', captured)

    def test_reviewed_fingerprint_is_exact_and_only_that_leaf_is_normalized(self):
        captured = {TRUTH.MAIN01_TASK_ID: {'world_id': 'world_1', 'lesson_id': 'what_poker_is',
                    'fingerprint': TRUTH.MAIN01_CURRENT_FINGERPRINT}, 'other': {'fingerprint': 'retained'}}
        frozen = copy.deepcopy(captured)
        origin = TRUTH.main01_origin_capture('source-fingerprints.json', captured)
        self.assertEqual(captured, frozen)
        frozen[TRUTH.MAIN01_TASK_ID]['fingerprint'] = TRUTH.MAIN01_PRIOR_FINGERPRINT
        self.assertEqual(origin, frozen)
        for field, value in [('fingerprint', 'f' * 64), ('world_id', 'unknown'), ('lesson_id', 'unknown')]:
            invalid = copy.deepcopy(captured)
            invalid[TRUTH.MAIN01_TASK_ID][field] = value
            with self.assertRaisesRegex(SystemExit, 'exact setup fingerprint'):
                TRUTH.main01_origin_capture('source-fingerprints.json', invalid)

    def test_capture_hash_guard_rejects_other_changes_and_old_receipt_new_grades(self):
        root = pathlib.Path(tempfile.mkdtemp())
        captured = self.reviewed_cells()
        path = root / 'learning-contract.json'
        self.write(path, captured)
        origin = TRUTH.main01_origin_capture(path.name, captured)
        pin = {path.name: TRUTH._digest(origin)}
        TRUTH.validate_capture_artifacts(root, 'MAIN01_REVIEWED_SETUP_QUALITIES', pin)
        with self.assertRaisesRegex(SystemExit, 'Captured source artifact drift'):
            TRUTH.validate_capture_artifacts(root, 'ORIGINAL_AUTHORING_BYTES', pin)
        for mutate in ('xp', 'other_task'):
            changed = copy.deepcopy(captured)
            if mutate == 'xp': changed[TRUTH.MAIN01_TASK_ID]['rewardXp'] = 50
            else: changed['unchanged_control']['rewardXp'] = 8
            self.write(path, changed)
            with self.assertRaisesRegex(SystemExit, 'Captured source artifact drift'):
                TRUTH.validate_capture_artifacts(root, 'MAIN01_REVIEWED_SETUP_QUALITIES', pin)

    def test_reviewed_capture_encoding_and_duplicate_keys_cannot_be_normalized_away(self):
        root = pathlib.Path(tempfile.mkdtemp())
        captured = self.reviewed_cells()
        path = root / 'learning-contract.json'
        pin = {path.name: TRUTH._digest(TRUTH.main01_origin_capture(path.name, captured))}
        for raw in [json.dumps(captured, indent=2),
                    json.dumps(captured, separators=(',', ':')).replace('"rewardXp":5', '"rewardXp":6,"rewardXp":5')]:
            with self.subTest(raw=raw[:40]):
                path.write_text(raw)
                with self.assertRaisesRegex(SystemExit, 'Captured JSON byte encoding drift'):
                    TRUTH.validate_capture_artifacts(root, 'MAIN01_REVIEWED_SETUP_QUALITIES', pin)

    def w01_producer(self):
        cohort = self.reviewed_producer()
        for key in ('state_sha256', 'factory_sha256'):
            cohort['producer_receipt'][key] = TRUTH.W01_PRODUCER_REVISION[key]
        return cohort

    def test_w01_exact_source_bytes_keep_original_authoring_origin(self):
        cohort = self.w01_producer()
        self.assertEqual(TRUTH.producer_revision(cohort, 'candidate'), TRUTH.W01_REVISION)
        cohort['producer_receipt']['head'] = 'f' * 40
        self.assertEqual(TRUTH.producer_revision(cohort, 'candidate'), TRUTH.W01_REVISION)
        self.assertEqual(cohort['admitted_source_reference'], TRUTH.SOURCE_REFERENCES['candidate'])

    def test_w01_missing_wrong_source_factory_origin_role_and_head_rejected(self):
        for field in ('state_sha256', 'factory_sha256', 'head'):
            for replacement in (None, '0', '0' * 64):
                with self.subTest(field=field, replacement=replacement):
                    cohort = self.w01_producer()
                    cohort['producer_receipt'][field] = replacement
                    with self.assertRaises(SystemExit):
                        TRUTH.producer_revision(cohort, 'candidate')
        cohort = self.w01_producer()
        cohort['admitted_source_reference']['commit'] = TRUTH.W01_PRODUCER_REVISION['source_revision']
        with self.assertRaisesRegex(SystemExit, 'Admitted source reference'):
            TRUTH.producer_revision(cohort, 'candidate')
        cohort = self.w01_producer()
        cohort['admitted_source_reference'] = copy.deepcopy(TRUTH.SOURCE_REFERENCES['historical_baseline'])
        with self.assertRaisesRegex(SystemExit, 'Producing source receipt'):
            TRUTH.producer_revision(cohort, 'historical_baseline')

    def test_w01_literal_reconstruction_changes_only_reviewed_fields_on_copy(self):
        for name, tasks in TRUTH.W01_CAPTURE_OPTIONS.items():
            with self.subTest(capture=name):
                is_options = name in ('learning-contract.json', 'runtime-inputs.json')
                captured = {task: {'options': copy.deepcopy(row['current']), 'unchanged': 7}
                            if is_options else copy.deepcopy(row['current'])
                            for task, row in tasks.items()}
                captured['other_task'] = {'sentinel': 'preserve every field'}
                before = copy.deepcopy(captured)
                expected = copy.deepcopy(captured)
                for task, row in tasks.items():
                    if is_options:
                        expected[task]['options'] = copy.deepcopy(row['prior'])
                    else:
                        expected[task] = copy.deepcopy(row['prior'])
                self.assertEqual(TRUTH.w01_origin_capture(name, captured), expected)
                self.assertEqual(captured, before)
                for task in tasks:
                    invalid = copy.deepcopy(captured)
                    del invalid[task]
                    with self.assertRaisesRegex(SystemExit, 'W01 exact theory'):
                        TRUTH.w01_origin_capture(name, invalid)

    def test_w01_wrong_option_order_values_duplicate_or_old_rows_rejected(self):
        for name in ('learning-contract.json', 'choice-identity.json', 'runtime-inputs.json'):
            is_options = name != 'choice-identity.json'
            tasks = TRUTH.W01_CAPTURE_OPTIONS[name]
            for task in tasks:
                for mutation in ('reverse', 'duplicate', 'old'):
                    with self.subTest(capture=name, task=task, mutation=mutation):
                        captured = {key: {'options': copy.deepcopy(row['current'])}
                                    if is_options else copy.deepcopy(row['current'])
                                    for key, row in tasks.items()}
                        options = captured[task]['options'] if is_options else captured[task]
                        if mutation == 'reverse': options.reverse()
                        elif mutation == 'duplicate': options.append(copy.deepcopy(options[0]))
                        elif is_options: captured[task]['options'] = copy.deepcopy(tasks[task]['prior'])
                        else: captured[task] = copy.deepcopy(tasks[task]['prior'])
                        with self.assertRaisesRegex(SystemExit, 'W01 exact theory'):
                            TRUTH.w01_origin_capture(name, captured)

    def test_w01_exact_ledger_indices_ids_and_two_phase_fields_only(self):
        rows = [{'untouched': index} for index in range(62712)]
        expected = copy.deepcopy(rows)
        seen = set()
        for revision in TRUTH.W01_LEDGER_REVISIONS:
            for index in revision['indices']:
                self.assertNotIn(index, seen)
                seen.add(index)
                rows[index] = {'task_id': revision['task_id'], 'phase': revision['current'],
                               'step_phase_variant': revision['current'], 'status': 'PASS', 'reason': 'retained'}
                expected[index] = {**rows[index], 'phase': revision['prior'], 'step_phase_variant': revision['prior']}
        self.assertEqual(len(seen), 56)
        frozen = copy.deepcopy(rows)
        self.assertEqual(TRUTH.w01_origin_capture('ledger.json', rows), expected)
        self.assertEqual(rows, frozen)
        for field in ('task_id', 'phase', 'step_phase_variant'):
            invalid = copy.deepcopy(rows)
            invalid[min(seen)][field] = 'unauthorized'
            with self.assertRaisesRegex(SystemExit, 'W01 exact theory'):
                TRUTH.w01_origin_capture('ledger.json', invalid)
        with self.assertRaisesRegex(SystemExit, 'W01 exact theory'):
            TRUTH.w01_origin_capture('ledger.json', rows[:-1])

    def pkg1_producer(self):
        cohort = self.w01_producer()
        for key in ('state_sha256', 'factory_sha256'):
            cohort['producer_receipt'][key] = TRUTH.PKG1_PRODUCER_REVISION[key]
        return cohort

    def test_pkg1_exact_source_binding_preserves_authoring_origin(self):
        cohort = self.pkg1_producer()
        self.assertEqual(TRUTH.producer_revision(cohort, 'candidate'), TRUTH.PKG1_REVISION)
        cohort['producer_receipt']['head'] = 'f' * 40
        self.assertEqual(TRUTH.producer_revision(cohort, 'candidate'), TRUTH.PKG1_REVISION)
        self.assertEqual(cohort['admitted_source_reference'], TRUTH.SOURCE_REFERENCES['candidate'])

    def test_pkg1_unknown_missing_source_factory_origin_role_head_rejected(self):
        for field in ('state_sha256', 'factory_sha256', 'head'):
            for replacement in (None, '0', '0' * 64):
                cohort = self.pkg1_producer()
                cohort['producer_receipt'][field] = replacement
                with self.assertRaises(SystemExit):
                    TRUTH.producer_revision(cohort, 'candidate')
        cohort = self.pkg1_producer()
        cohort['admitted_source_reference']['commit'] = TRUTH.PKG1_PRODUCER_REVISION['source_revision']
        with self.assertRaises(SystemExit):
            TRUTH.producer_revision(cohort, 'candidate')
        cohort = self.pkg1_producer()
        cohort['admitted_source_reference'] = copy.deepcopy(TRUTH.SOURCE_REFERENCES['historical_baseline'])
        with self.assertRaises(SystemExit):
            TRUTH.producer_revision(cohort, 'historical_baseline')

    def position_producer(self):
        cohort = self.pkg1_producer()
        for key in ('state_sha256', 'factory_sha256'):
            cohort['producer_receipt'][key] = TRUTH.W01_POSITION_PRODUCER_REVISION[key]
        return cohort

    def test_position_feedback_exact_source_keeps_original_authoring_origin(self):
        cohort = self.position_producer()
        self.assertEqual(TRUTH.producer_revision(cohort, 'candidate'), TRUTH.W01_POSITION_REVISION)
        cohort['producer_receipt']['head'] = 'f' * 40
        self.assertEqual(TRUTH.producer_revision(cohort, 'candidate'), TRUTH.W01_POSITION_REVISION)
        self.assertEqual(cohort['admitted_source_reference'], TRUTH.SOURCE_REFERENCES['candidate'])

    def test_position_feedback_wrong_source_factory_origin_role_head_rejected(self):
        for field in ('state_sha256', 'factory_sha256', 'head'):
            for replacement in (None, '0', '0' * 64):
                cohort = self.position_producer()
                cohort['producer_receipt'][field] = replacement
                with self.assertRaises(SystemExit):
                    TRUTH.producer_revision(cohort, 'candidate')
        cohort = self.position_producer()
        cohort['admitted_source_reference']['commit'] = TRUTH.W01_POSITION_PRODUCER_REVISION['source_revision']
        with self.assertRaises(SystemExit):
            TRUTH.producer_revision(cohort, 'candidate')
        cohort = self.position_producer()
        cohort['admitted_source_reference'] = copy.deepcopy(TRUTH.SOURCE_REFERENCES['historical_baseline'])
        with self.assertRaises(SystemExit):
            TRUTH.producer_revision(cohort, 'historical_baseline')

    def recompute(self, root, task_id):
        contract = self.read(root / 'candidate/learning-contract.json')
        fingerprints = self.read(root / 'candidate/source-fingerprints.json')
        choices = self.read(root / 'candidate/choice-identity.json')
        runtime = self.read(root / 'candidate/runtime-inputs.json')
        cohort = self.read(root / 'candidate/typed-cohort-v2.json')
        bundle = [contract[task_id], fingerprints[task_id], choices[task_id], runtime[task_id]]
        row = next(row for row in cohort['new_authoring'] if row['task_id'] == task_id)
        row['artifact_sha256'] = TRUTH._digest(bundle)
        row['source_binding_sha256'] = TRUTH._digest(
            [cohort['admitted_source_reference'], task_id, bundle]
        )
        self.write(root / 'candidate/typed-cohort-v2.json', cohort)

    def rejects(self, root, message):
        with self.assertRaisesRegex(SystemExit, message):
            TRUTH.validate_typed_cohort(root)

    @staticmethod
    def read(path):
        return json.loads(path.read_text())

    @staticmethod
    def write(path, value):
        path.write_text(json.dumps(value, separators=(',', ':'), ensure_ascii=False))


if __name__ == '__main__':
    if len(sys.argv) == 4 and sys.argv[1] == '--real-artifacts':
        baseline = pathlib.Path(sys.argv[2])
        candidate = pathlib.Path(sys.argv[3])
        root = pathlib.Path(tempfile.mkdtemp())
        names = (
            'learning-contract.json',
            'source-fingerprints.json',
            'choice-identity.json',
            'runtime-inputs.json',
            'ledger.json',
        )
        for phase, source in (('baseline', baseline), ('candidate', candidate)):
            out = root / phase
            out.mkdir()
            for name in names:
                shutil.copyfile(source / name, out / name)
            # Preserve real producer/source receipts when supplied. Never turn a
            # reviewed new producer into a synthetic original-byte receipt.
            cohort_path = source / 'typed-cohort-v2.json'
            if cohort_path.is_file():
                shutil.copyfile(cohort_path, out / cohort_path.name)
        repair = CANONICAL['historical_repair_control']
        for phase, source in (('baseline', baseline), ('candidate', candidate)):
            role = 'historical_baseline' if phase == 'baseline' else 'candidate'
            cohort_path = source / 'typed-cohort-v2.json'
            revision = (TRUTH.producer_revision(json.loads(cohort_path.read_text()), role)
                        if cohort_path.is_file() else 'ORIGINAL_AUTHORING_BYTES')
            try:
                TRUTH.validate_capture_artifacts(source, revision, repair[f'{phase}_artifacts'])
                if phase == 'candidate':
                    TRUTH.validate_capture_artifacts(source, revision)
            except SystemExit as error:
                raise SystemExit(f'Historical repair control artifact drift: {phase}: {error}')
        contracts = {
            phase: json.loads((root / phase / 'learning-contract.json').read_text())
            for phase in ('baseline', 'candidate')
        }
        fingerprints = {
            phase: json.loads((root / phase / 'source-fingerprints.json').read_text())
            for phase in ('baseline', 'candidate')
        }
        choices = {
            phase: json.loads((root / phase / 'choice-identity.json').read_text())
            for phase in ('baseline', 'candidate')
        }
        runtime = {
            phase: json.loads((root / phase / 'runtime-inputs.json').read_text())
            for phase in ('baseline', 'candidate')
        }
        historical = set(contracts['baseline'])
        helper = TypedCohortV2Controls()
        for phase in ('baseline', 'candidate'):
            if (root / phase / 'typed-cohort-v2.json').is_file():
                continue
            helper.write(
                root / phase / 'typed-cohort-v2.json',
                helper.cohort(
                    phase,
                    historical,
                    contracts[phase],
                    fingerprints[phase],
                    choices[phase],
                    runtime[phase],
                ),
            )
        TRUTH.compare(root)
        comparison = helper.read(root / 'comparison.json')
        fingerprint_delta = helper.read(root / 'source-fingerprint-delta.json')
        runtime_delta = helper.read(root / 'runtime-input-delta.json')
        task_id = repair['task_id']
        baseline_runtime = runtime['baseline'][task_id]
        candidate_runtime = runtime['candidate'][task_id]
        baseline_seats = {
            row['id']: row for row in baseline_runtime['table']['seats']
        }
        candidate_seats = {
            row['id']: row for row in candidate_runtime['table']['seats']
        }
        exemplar = fingerprint_delta[task_id]
        real_control = {
            'baseline_fingerprint': exemplar['before']['fingerprint'],
            'candidate_fingerprint': exemplar['after']['fingerprint'],
            'baseline_btn_cards': baseline_seats['btn']['cards'],
            'candidate_btn_cards': candidate_seats['btn']['cards'],
            'baseline_hj_active': baseline_seats['hj']['active'],
            'candidate_hj_active': candidate_seats['hj']['active'],
            'classification': exemplar['classification'],
            'historical_record_policy': exemplar['historical_record_policy'],
            'current_source_policy': exemplar['current_source_policy'],
        }
        expected_real_control = {
            key: value
            for key, value in repair.items()
            if key not in {'task_id', 'baseline_artifacts', 'candidate_artifacts'}
        }
        if real_control != expected_real_control or task_id not in runtime_delta:
            raise SystemExit('Historical repair exemplar classification drift')
        result = {
            'runtime_changed_task_count': comparison['runtime_changed_task_count'],
            'fingerprint_changed_task_count': sum(
                row['classification'] == 'SOURCE_CONDITION_CHANGED'
                for row in fingerprint_delta.values()
            ),
            'candidate_fail_count': comparison['ledgers']['candidate'][
                'statuses'
            ].get('FAIL', 0),
            'candidate_producer_revision': comparison['candidate_producer_revision'],
            'producer_receipt': comparison['producer_receipt'],
            'historical_learning_contract_identical': comparison['historical_learning_contract_identical'],
            'historical_choice_identity_identical': comparison['historical_choice_identity_identical'],
            'reviewed_quality_changes': comparison['reviewed_quality_changes'],
            'historical_repair_exemplar': {
                'task_id': task_id,
                'classification': exemplar['classification'],
                'historical_fingerprint_retained': exemplar['before'][
                    'fingerprint'
                ],
                'current_fingerprint': exemplar['after']['fingerprint'],
                'current_source_policy': exemplar['current_source_policy'],
            },
        }
        expected_counts = {
            'runtime_changed_task_count': 309,
            'fingerprint_changed_task_count': 328,
            'candidate_fail_count': 0,
        }
        if comparison['candidate_producer_revision'] in (TRUTH.W01_REVISION, TRUTH.PKG1_REVISION, TRUTH.W01_POSITION_REVISION):
            # Count actual current-source changes, never normalize the public
            # classification output back to an earlier source revision.
            for name, captured, before in (
                ('runtime-inputs.json', runtime['candidate'], runtime['baseline']),
                ('source-fingerprints.json', fingerprints['candidate'], fingerprints['baseline']),
            ):
                pkg1_capture = (TRUTH.w01_position_pkg1_capture(name, captured)
                                if comparison['candidate_producer_revision'] == TRUTH.W01_POSITION_REVISION else captured)
                w01_capture = (TRUTH.pkg1_w01_capture(name, pkg1_capture)
                               if comparison['candidate_producer_revision'] in (TRUTH.PKG1_REVISION, TRUTH.W01_POSITION_REVISION) else pkg1_capture)
                old = TRUTH.w01_origin_capture(name, w01_capture)
                current_changed = {key for key in historical if w01_capture[key] != before[key]}
                prior_changed = {key for key in historical if old[key] != before[key]}
                if current_changed - prior_changed != {'blinds_theory', 'cards_ranks_suits_theory'} or prior_changed - current_changed:
                    raise SystemExit('Unexpected W01 newly changed task identities')
                if len(prior_changed) != (309 if name == 'runtime-inputs.json' else 328):
                    raise SystemExit('Prior revision delta count drift')
            expected_counts.update(runtime_changed_task_count=311, fingerprint_changed_task_count=330)
            if comparison['candidate_producer_revision'] in (TRUTH.PKG1_REVISION, TRUTH.W01_POSITION_REVISION):
                for name, captured in (('runtime-inputs.json', runtime['candidate']),
                                       ('source-fingerprints.json', fingerprints['candidate'])):
                    pkg1_capture = (TRUTH.w01_position_pkg1_capture(name, captured)
                                    if comparison['candidate_producer_revision'] == TRUTH.W01_POSITION_REVISION else captured)
                    prior = TRUTH.pkg1_w01_capture(name, pkg1_capture)
                    changed = {key for key in historical if pkg1_capture[key] != prior[key]}
                    expected = {path[0] for path, _, _ in TRUTH.PKG1_CAPTURE_LEAVES[name]}
                    if changed != expected:
                        raise SystemExit('Unexpected PKG1 changed task identities')
                # These are actual current-vs-original classifications. Reversal
                # validates history; it never masks current-source changes.
                expected_counts.update(runtime_changed_task_count=315, fingerprint_changed_task_count=330)
            if comparison['candidate_producer_revision'] == TRUTH.W01_POSITION_REVISION:
                for name, captured in (('runtime-inputs.json', runtime['candidate']),
                                       ('source-fingerprints.json', fingerprints['candidate'])):
                    prior = TRUTH.w01_position_pkg1_capture(name, captured)
                    changed = {key for key in historical if captured[key] != prior[key]}
                    if changed != {'positions_theory', 'positions_review'}:
                        raise SystemExit('Unexpected position-feedback changed task identities')
                expected_counts.update(runtime_changed_task_count=317, fingerprint_changed_task_count=332)
            if comparison['historical_contracts_identical_except_reviewed_setup_qualities']:
                raise SystemExit('W01 source evolution falsely described as setup qualities only')
            if set(row['task_id'] for row in comparison['reviewed_theory_changes']) != set(TRUTH.W01_CAPTURE_OPTIONS['learning-contract.json']):
                raise SystemExit('Missing reviewed W01 source change explanation')

            # Use the actual immutable producer captures. Recomputed cohort
            # checksums cannot bless unauthorized model or capture edits.
            frozen_files = {p.name: p.read_bytes() for p in (root / 'candidate').iterdir() if p.is_file()}
            cases = [
                ('learning-contract.json', ['blinds_theory', 'rewardXp'], 99),
                ('learning-contract.json', ['cards_ranks_suits_theory', 'options', 1, 'correct'], False),
                ('learning-contract.json', ['blinds_theory', 'options', 0, 'repairSeats'], ['unknown']),
                ('choice-identity.json', ['blinds_theory', 0, 4], 'wrong preferred'),
                ('choice-identity.json', ['cards_ranks_suits_theory', 0, 0], 'unknown_choice'),
                ('runtime-inputs.json', ['blinds_theory', 'options', 0, 'amount'], None),
                ('runtime-inputs.json', ['blinds_theory', 'options', 0, 'reason'], 'forged reason'),
                ('runtime-inputs.json', ['blinds_theory', 'table', 'pot'], 'Pot 99 BB'),
                ('runtime-inputs.json', ['asm05_new_known_holes_turn_call_10', 'table', 'hero'], ['Ah', 'Ad']),
                ('source-fingerprints.json', ['hand_rankings_theory', 'fingerprint'], 'f' * 64),
                ('ledger.json', [1023, 'phase'], 'feedback/unknown'),
                ('ledger.json', [1023, 'task_id'], 'unknown_task'),
                ('ledger.json', [1023, 'status'], 'FAIL'),
                ('ledger.json', [1023, 'result'], 'FAIL'),
                ('ledger.json', [1023, 'reason'], 'forged reason'),
                ('ledger.json', [0, 'status'], 'FAIL'),
            ]
            if comparison['candidate_producer_revision'] in (TRUTH.PKG1_REVISION, TRUTH.W01_POSITION_REVISION):
                cases.extend([
                    ('runtime-inputs.json', ['hand_discipline_buckets_borderline', 'table', 'hero', 0], 'Qh'),
                    ('runtime-inputs.json', ['hand_discipline_buckets_borderline', 'table', 'seats', 3, 'cards', 0], 'Qh'),
                    ('runtime-inputs.json', ['hand_discipline_buckets_borderline', 'caption'], 'forged caption'),
                    ('runtime-inputs.json', ['apply_btn_open', 'teaching', 0, 'body'], 'BTN always acts last.'),
                    ('runtime-inputs.json', ['position_apply_hj_fold', 'options', 0, 'reason'], 'forged HJ reason'),
                    ('runtime-inputs.json', ['position_apply_early_fold', 'options', 0, 'reason'], 'forged UTG reason'),
                    ('runtime-inputs.json', ['position_checkpoint_position_checkpoint_early_fold', 'options', 0, 'reason'], 'forged A9o reason'),
                    ('runtime-inputs.json', ['same_hand_different_seat_same_hand_early_fold', 'options', 0, 'reason'], 'forged alias reason'),
                    ('source-fingerprints.json', ['hand_discipline_buckets_borderline', 'fingerprint'], 'f' * 64),
                    ('ledger.json', [9844, 'reason'], 'forged QJs reason'),
                    ('ledger.json', [9844, 'task_id'], 'other_task'),
                    ('ledger.json', [9844, 'phase'], 'other_phase'),
                    ('ledger.json', [9844, 'invariant'], 'other_invariant'),
                    ('ledger.json', [9844, 'status'], 'FAIL'),
                ])
                # Prove complete exact reversal without mutating actual captures.
                for name in names:
                    captured = json.loads(frozen_files[name])
                    pkg1_capture = (TRUTH.w01_position_pkg1_capture(name, captured)
                                    if comparison['candidate_producer_revision'] == TRUTH.W01_POSITION_REVISION else captured)
                    prior = TRUTH.pkg1_w01_capture(name, pkg1_capture)
                    if TRUTH._digest(prior) != TRUTH.W01_CAPTURE_SHA256[name] or captured != json.loads(frozen_files[name]):
                        raise SystemExit('PKG1 exact reversal mutated current capture')
            if comparison['candidate_producer_revision'] == TRUTH.W01_POSITION_REVISION:
                for task_id in ('positions_theory', 'positions_review'):
                    for index in range(3):
                        cases.append(('runtime-inputs.json', [task_id, 'options', index, 'reason'], 'forged position reason'))
                    cases.append(('source-fingerprints.json', [task_id, 'fingerprint'], 'f' * 64))
                for name in names:
                    captured = json.loads(frozen_files[name])
                    prior = TRUTH.w01_position_pkg1_capture(name, captured)
                    if TRUTH._digest(prior) != TRUTH.PKG1_CAPTURE_SHA256[name] or captured != json.loads(frozen_files[name]):
                        raise SystemExit('Position feedback reversal mutated current capture')
            other_task = next(key for key in contracts['candidate'] if key not in TRUTH.W01_CAPTURE_OPTIONS['learning-contract.json'] and key not in NEW)
            cases.append(('learning-contract.json', [other_task, 'rewardXp'], 99))
            for name, path, replacement in cases:
                captured = json.loads(frozen_files[name])
                node = captured
                for key in path[:-1]: node = node[key]
                node[path[-1]] = replacement
                helper.write(root / 'candidate' / name, captured)
                if path[0] in NEW:
                    helper.recompute(root, path[0])
                try:
                    TRUTH.validate_typed_cohort(root)
                except SystemExit:
                    pass
                else:
                    raise SystemExit(f'W01 negative mutation unexpectedly accepted: {name} {path}')
                for restore in (name, 'typed-cohort-v2.json'):
                    (root / 'candidate' / restore).write_bytes(frozen_files[restore])
            for name in ('learning-contract.json', 'choice-identity.json', 'runtime-inputs.json'):
                captured = json.loads(frozen_files[name])
                task = 'blinds_theory'
                options = captured[task] if name == 'choice-identity.json' else captured[task]['options']
                for mutation in ('reverse', 'duplicate'):
                    altered = copy.deepcopy(captured)
                    target = altered[task] if name == 'choice-identity.json' else altered[task]['options']
                    if mutation == 'reverse': target.reverse()
                    else: target.append(copy.deepcopy(target[0]))
                    helper.write(root / 'candidate' / name, altered)
                    with helper.assertRaises(SystemExit):
                        TRUTH.validate_typed_cohort(root)
                    (root / 'candidate' / name).write_bytes(frozen_files[name])
            name = 'learning-contract.json'
            raw = frozen_files[name].decode()
            for malformed in (json.dumps(json.loads(raw), indent=2), raw.replace('"rewardXp":5', '"rewardXp":99,"rewardXp":5', 1)):
                if malformed == raw:
                    raise SystemExit('Malformed encoding negative control did not mutate input')
                (root / 'candidate' / name).write_text(malformed)
                with helper.assertRaisesRegex(SystemExit, 'byte encoding drift'):
                    TRUTH.validate_typed_cohort(root)
                (root / 'candidate' / name).write_bytes(frozen_files[name])
            if any((root / 'candidate' / name).read_bytes() != raw for name, raw in frozen_files.items()):
                raise SystemExit('Negative controls failed to restore owned captures')
            TRUTH.validate_typed_cohort(root)
            result['w01_actual_capture_negative_controls'] = len(cases) + 6 + 2 - (14 if comparison['candidate_producer_revision'] in (TRUTH.PKG1_REVISION, TRUTH.W01_POSITION_REVISION) else 0) - (8 if comparison['candidate_producer_revision'] == TRUTH.W01_POSITION_REVISION else 0)
            result['reviewed_theory_changes'] = comparison['reviewed_theory_changes']
            if comparison['candidate_producer_revision'] in (TRUTH.PKG1_REVISION, TRUTH.W01_POSITION_REVISION):
                result['pkg1_actual_capture_negative_controls'] = 14
                result['reviewed_hand_seat_changes'] = comparison['reviewed_hand_seat_changes']
            if comparison['candidate_producer_revision'] == TRUTH.W01_POSITION_REVISION:
                result['position_actual_capture_negative_controls'] = 8
                result['reviewed_position_feedback_changes'] = comparison['reviewed_position_feedback_changes']
        print(json.dumps(result, sort_keys=True))
        if {key: result[key] for key in expected_counts} != expected_counts:
            raise SystemExit('Unexpected real TABLE.TRUTH delta classification')
    else:
        unittest.main(verbosity=2)
