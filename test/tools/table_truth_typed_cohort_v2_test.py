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
        repair = CANONICAL['historical_repair_control']
        for phase, source in (('baseline', baseline), ('candidate', candidate)):
            expected = repair[f'{phase}_artifacts']
            observed = {
                name: hashlib.sha256((source / name).read_bytes()).hexdigest()
                for name in expected
            }
            if observed != expected:
                raise SystemExit(
                    f'Historical repair control artifact drift: {phase}'
                )
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
        print(json.dumps(result, sort_keys=True))
        if {key: result[key] for key in expected_counts} != expected_counts:
            raise SystemExit('Unexpected real TABLE.TRUTH delta classification')
    else:
        unittest.main(verbosity=2)
