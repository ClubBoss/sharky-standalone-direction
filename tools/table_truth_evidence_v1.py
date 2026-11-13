#!/usr/bin/env python3
"""Summarize real Flutter cases and preserve paired TABLE.TRUTH provenance."""
import collections
import copy
import hashlib
import json
import pathlib
import re
import sys


NEW_AUTHORING_IDS = {
    'asm05_new_known_holes_turn_call_10',
    'asm05_new_known_holes_turn_call_40',
}
SOURCE_REFERENCES = {
    'historical_baseline': {
        'commit': 'fa079b6c5880814e231981a7bd5ed97df192d215',
        'state_sha256': 'e9f87d4bf73b75d77bd7b04ddf111cbf6b64e796259ffe42adadea9bbb3270e2',
        'factory_sha256': None,
    },
    'candidate': {
        'commit': '5b0dd2e300053e52b323e54df6c759ddb5f04b48',
        'state_sha256': 'd9a78d57817c8eaef7dc1a376f53ade7774229be4a34063d5dc0cf152bb67221',
        'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
    },
}
# Authoring origin above is immutable. This separately admitted source revision
# changes only two grading qualities in one existing task; producer HEAD remains
# an execution receipt (a later tooling-only commit can have identical bytes).
MAIN01_PRODUCER_REVISION = {
    'source_revision': 'fe6dd994774b3da2524e39ff322cad109687a9b5',
    'state_sha256': 'ee5fe77ef24b5541a35e6e58823497f7ca47560714de6366f96f3632cfd00c61',
    'factory_sha256': 'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
}
MAIN01_TASK_ID = 'first_table_guide_one_clear_choice'
MAIN01_PRIOR_FINGERPRINT = '2c7cc8212fe8a0fe211c79b4be08391f4262c8a7ef1abfb170de27bbd41ce278'
MAIN01_CURRENT_FINGERPRINT = '2573cfd7f0d3d18a5680b1a744a6dde0c95714a4bd655cd14a9478a4fd139500'
MAIN01_QUALITY_REVISION = {
    'co_still_acting': ('wrong', 'suboptimal'),
    'hero_has_no_cards': ('suboptimal', 'wrong'),
}
CANONICAL_NEW_AUTHORING = pathlib.Path(__file__).resolve().parents[1] / (
    'test/tools/fixtures/table_truth_asm05_new_authoring_v1.json'
)
EXPECTED_CAPTURE_ARTIFACTS = {
    'choice-identity.json': 'c36878c369d880bcefc4c5f53b0f3247725e1c2439956619e511a77ccd06fd8d',
    'learning-contract.json': '1cf59348b0296053cf73b97201879b033479c83347a759b9be16bf87ea907d25',
    'ledger.json': '382960a25750f83cb26d33a5b6d8e80cdcf3a77f98f420bedc2b3030d33c368f',
    'runtime-inputs.json': '886e8e2bf0a90dbb7a37b58858502782d940fba4f82cc414b877a9f4ebda9c9f',
    'source-fingerprints.json': '6b848f76f99825b968eef9072b00e707a7ee5a9da278aaf3db3674c6cab1b786',
}


def summarize(path, expected, code):
    starts, cases, errors = {}, [], []
    for line in pathlib.Path(path).read_text().splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(event, dict):
            continue
        if event.get('type') == 'testStart':
            starts[event['test']['id']] = event['test']
        elif event.get('type') == 'testDone':
            test = starts.get(event['testID'], {})
            if not event.get('hidden') and not test.get('name', '').startswith('loading '):
                cases.append({**test, **event})
        elif event.get('type') == 'error':
            errors.append(event)
    counts = collections.Counter('skipped' if c.get('skipped') else c['result'] for c in cases)
    result = {'counts': dict(counts), 'case_count': len(cases), 'exit_code': code,
              'expected': expected, 'cases': cases, 'errors': errors}
    pathlib.Path(path + '.summary.json').write_text(json.dumps(result, indent=2))
    print(json.dumps({k: result[k] for k in ['counts', 'case_count', 'exit_code', 'expected']}))
    compile_error = any('Compilation failed' in e.get('error', '') or 'Failed to load' in e.get('error', '') for e in errors)
    valid = bool(cases) and not counts['skipped'] and not compile_error
    valid &= (code != 0 and (counts['error'] + counts['failure']) > 0) if expected == 'red' else (code == 0 and counts['error'] == 0 and counts['failure'] == 0)
    if not valid:
        for e in errors[-8:]:
            print(e.get('error', ''))
        raise SystemExit('TABLE.TRUTH execution does not establish the expected result')


def _digest(value):
    encoded = json.dumps(value, separators=(',', ':'), ensure_ascii=False).encode()
    return hashlib.sha256(encoded).hexdigest()


def producer_revision(cohort, role):
    reference = cohort.get('admitted_source_reference')
    if reference != SOURCE_REFERENCES[role]:
        raise SystemExit('Admitted source reference changed')
    receipt = cohort.get('producer_receipt')
    if not isinstance(receipt, dict) or not re.fullmatch(
        r'[0-9a-f]{40}', receipt.get('head', '')
    ):
        raise SystemExit('Producing HEAD receipt is missing or malformed')
    source_bytes = {
        key: receipt.get(key) for key in ('state_sha256', 'factory_sha256')
    }
    origin_bytes = {key: reference[key] for key in source_bytes}
    if source_bytes == origin_bytes:
        return 'ORIGINAL_AUTHORING_BYTES'
    admitted_bytes = {key: MAIN01_PRODUCER_REVISION[key] for key in source_bytes}
    if role == 'candidate' and source_bytes == admitted_bytes:
        return 'MAIN01_REVIEWED_SETUP_QUALITIES'
    raise SystemExit('Producing source receipt does not match admitted bytes')


def main01_origin_capture(name, value):
    """Return an in-memory origin comparison; never rewrite captured artifacts."""
    result = copy.deepcopy(value)
    if name in ('learning-contract.json', 'choice-identity.json'):
        try:
            options = (result[MAIN01_TASK_ID]['options']
                       if name == 'learning-contract.json' else result[MAIN01_TASK_ID])
            by_id = {(row['id'] if isinstance(row, dict) else row[0]): row
                     for row in options}
            if len(options) != 3 or set(by_id) != {
                'hero_btn_preflop_setup', *MAIN01_QUALITY_REVISION
            }:
                raise ValueError('unexpected choice identities')
            for choice, (prior, current) in MAIN01_QUALITY_REVISION.items():
                row = by_id[choice]
                if name == 'learning-contract.json':
                    if row['quality'] != current or row['correct'] is not False:
                        raise ValueError('unexpected current grading cell')
                    row['quality'] = prior
                else:
                    if len(row) != 5 or row[3] != current or row[2] is not False:
                        raise ValueError('unexpected current choice cell')
                    row[3] = prior
        except (KeyError, TypeError, IndexError, ValueError) as error:
            raise SystemExit(f'MAIN01 exact quality revision mismatch: {name}') from error
    elif name == 'source-fingerprints.json':
        if result.get(MAIN01_TASK_ID) != {
            'world_id': 'world_1', 'lesson_id': 'what_poker_is',
            'fingerprint': MAIN01_CURRENT_FINGERPRINT,
        }:
            raise SystemExit('MAIN01 exact setup fingerprint mismatch')
        result[MAIN01_TASK_ID]['fingerprint'] = MAIN01_PRIOR_FINGERPRINT
    return result


def validate_capture_artifacts(source, revision, names=None):
    """Pin every field of the reviewed capture to the unchanged original capture.

    Original artifacts retain exact raw-byte checks. The reviewed revision uses
    compact canonical JSON after reversing only its two known qualities and one
    resulting task fingerprint; all remaining bytes/fields keep original pins.
    """
    names = EXPECTED_CAPTURE_ARTIFACTS if names is None else names
    for name, expected in names.items():
        raw = (pathlib.Path(source) / name).read_bytes()
        observed = hashlib.sha256(raw).hexdigest()
        if revision == 'MAIN01_REVIEWED_SETUP_QUALITIES':
            captured = json.loads(raw)
            compact = json.dumps(captured, separators=(',', ':'), ensure_ascii=False).encode()
            if raw != compact:
                raise SystemExit(f'Captured JSON byte encoding drift: {name}')
            observed = _digest(main01_origin_capture(name, captured))
        if observed != expected:
            raise SystemExit(f'Captured source artifact drift: {name}')


def validate_typed_cohort(root):
    root = pathlib.Path(root)
    base = json.loads((root / 'baseline' / 'learning-contract.json').read_text())
    final = json.loads((root / 'candidate' / 'learning-contract.json').read_text())
    base_cohort = json.loads((root / 'baseline' / 'typed-cohort-v2.json').read_text())
    final_cohort = json.loads((root / 'candidate' / 'typed-cohort-v2.json').read_text())
    canonical = json.loads(CANONICAL_NEW_AUTHORING.read_text())
    if (
        canonical.get('schema') != 1
        or canonical.get('admitted_source_reference')
        != SOURCE_REFERENCES['candidate']['commit']
        or canonical.get('capture_artifacts') != EXPECTED_CAPTURE_ARTIFACTS
        or canonical.get('d3_no_old_blind_fail_count') != 0
        or set(canonical.get('tasks', {})) != NEW_AUTHORING_IDS
    ):
        raise SystemExit('Pinned ASM05 canonical record fixture is malformed')
    for role, cohort in (
        ('historical_baseline', base_cohort),
        ('candidate', final_cohort),
    ):
        if cohort.get('schema') != 2 or cohort.get('role') != role:
            raise SystemExit('Unknown or mismatched typed cohort role')
        revision = producer_revision(cohort, role)
        if role == 'candidate':
            candidate_revision = revision
    if base_cohort.get('new_authoring'):
        raise SystemExit('Historical baseline contains NEW_AUTHORING additions')
    addition_rows = final_cohort.get('new_authoring', [])
    additions = {row.get('task_id'): row for row in addition_rows}
    if len(addition_rows) != len(NEW_AUTHORING_IDS) or set(additions) != NEW_AUTHORING_IDS:
        raise SystemExit('NEW_AUTHORING cohort is missing or contains unknown tasks')
    historical_ids = set(base_cohort.get('historical_ids', []))
    if (
        historical_ids != set(final_cohort.get('historical_ids', []))
        or len(historical_ids) != 367
    ):
        raise SystemExit('Historical cohort identity changed')
    if set(base) != historical_ids or set(final) != historical_ids | NEW_AUTHORING_IDS:
        raise SystemExit('Learning contract cohort key set is inconsistent')
    comparison_contract = final
    if candidate_revision == 'MAIN01_REVIEWED_SETUP_QUALITIES':
        validate_capture_artifacts(root / 'candidate', candidate_revision)
        comparison_contract = main01_origin_capture('learning-contract.json', final)
    if {key: comparison_contract[key] for key in historical_ids} != base:
        raise SystemExit('Learning identity, XP, correctness or repair contract changed')
    before = json.loads((root / 'baseline' / 'runtime-inputs.json').read_text())
    after = json.loads((root / 'candidate' / 'runtime-inputs.json').read_text())
    before_fingerprints = json.loads(
        (root / 'baseline' / 'source-fingerprints.json').read_text()
    )
    after_fingerprints = json.loads(
        (root / 'candidate' / 'source-fingerprints.json').read_text()
    )
    before_choices = json.loads((root / 'baseline' / 'choice-identity.json').read_text())
    after_choices = json.loads((root / 'candidate' / 'choice-identity.json').read_text())
    for label, historical, candidate in (
        ('runtime input', before, after),
        ('source fingerprint', before_fingerprints, after_fingerprints),
        ('choice identity', before_choices, after_choices),
    ):
        if set(historical) != historical_ids or set(candidate) != (
            historical_ids | NEW_AUTHORING_IDS
        ):
            raise SystemExit(f'{label} cohort key set is inconsistent')
    comparison_choices = (
        main01_origin_capture('choice-identity.json', after_choices)
        if candidate_revision == 'MAIN01_REVIEWED_SETUP_QUALITIES' else after_choices
    )
    if any(before_choices[key] != comparison_choices[key] for key in historical_ids):
        raise SystemExit('Historical choice identity changed')
    for task_id in NEW_AUTHORING_IDS:
        expected = canonical['tasks'][task_id]
        actual_bundle = [
            final[task_id],
            after_fingerprints[task_id],
            after_choices[task_id],
            after[task_id],
        ]
        expected_bundle = [
            expected['learning_contract'],
            expected['source_fingerprint'],
            expected['choice_identity'],
            expected['runtime_input'],
        ]
        if actual_bundle != expected_bundle:
            raise SystemExit(f'NEW_AUTHORING canonical record mismatch: {task_id}')
        row = additions[task_id]
        identity = {
            key: value
            for key, value in row.items()
            if key not in {'artifact_sha256', 'source_binding_sha256'}
        }
        if identity != {
            'task_id': task_id,
            'world_id': 'world_12',
            'lesson_id': 'decision_over_outcome',
            'provenance': 'NEW_AUTHORING_ASM05',
        }:
            raise SystemExit(f'NEW_AUTHORING identity is malformed: {task_id}')
        if row.get('artifact_sha256') != _digest(actual_bundle):
            raise SystemExit(f'NEW_AUTHORING artifact digest mismatch: {task_id}')
        source_binding = [
            final_cohort['admitted_source_reference'],
            task_id,
            actual_bundle,
        ]
        if row.get('source_binding_sha256') != _digest(source_binding):
            raise SystemExit(f'NEW_AUTHORING source binding mismatch: {task_id}')
    return {
        'root': root,
        'base': base,
        'final': final,
        'historical_ids': historical_ids,
        'before': before,
        'after': after,
        'before_fingerprints': before_fingerprints,
        'after_fingerprints': after_fingerprints,
        'before_choices': before_choices,
        'after_choices': after_choices,
        'additions': additions,
        'final_cohort': final_cohort,
        'candidate_revision': candidate_revision,
        'historical_learning_contract_identical': {key: final[key] for key in historical_ids} == base,
        'historical_choice_identity_identical': all(before_choices[key] == after_choices[key] for key in historical_ids),
    }


def compare(root):
    identity = validate_typed_cohort(root)
    root = identity['root']
    historical_ids = identity['historical_ids']
    before = identity['before']
    after = identity['after']
    before_fingerprints = identity['before_fingerprints']
    after_fingerprints = identity['after_fingerprints']
    before_choices = identity['before_choices']
    after_choices = identity['after_choices']
    delta = {
        key: {'before': before[key], 'after': after[key]}
        for key in historical_ids
        if before[key] != after[key]
    }
    (root / 'runtime-input-delta.json').write_text(json.dumps(delta, indent=2))
    fingerprint_delta = {}
    for task_id in sorted(historical_ids):
        old = before_fingerprints[task_id]
        new = after_fingerprints[task_id]
        changed = old['fingerprint'] != new['fingerprint']
        classification = ('SOURCE_CONDITION_CHANGED' if changed else
                          'PRESENTATION_OR_TEACHING_ONLY' if task_id in delta else 'UNCHANGED')
        fingerprint_delta[task_id] = {
            'before': old, 'after': new, 'classification': classification,
            'changed_runtime_fields': [field for field in before[task_id]
                                       if before[task_id][field] != after[task_id][field]],
            'historical_record_policy': 'retain original fingerprint, grade, assistance, XP and repair lineage',
            'current_source_policy': 'reject old fingerprint' if changed else 'regrade against current compatible source',
        }
    (root / 'source-fingerprint-delta.json').write_text(json.dumps(fingerprint_delta, indent=2))
    fingerprint_counts = dict(collections.Counter(v['classification'] for v in fingerprint_delta.values()))
    ledgers = {}
    for phase in ['baseline', 'candidate']:
        rows = json.loads((root / phase / 'ledger.json').read_text())
        ledgers[phase] = {
            'tasks': len({r['task_id'] for r in rows}),
            'variants': len({(r['task_id'], r['phase']) for r in rows}),
            'rows': len(rows), 'statuses': dict(collections.Counter(r['status'] for r in rows)),
            'by_invariant': {i: dict(collections.Counter(r['status'] for r in rows if r['invariant'] == i)) for i in sorted({r['invariant'] for r in rows})},
            'failed_ids': sorted({r['task_id'] for r in rows if r['status'] == 'FAIL'}),
        }
    if not ledgers['baseline']['statuses'].get('FAIL', 0):
        raise SystemExit('Baseline contains no genuine RED source counterexamples')
    if ledgers['candidate']['statuses'].get('FAIL', 0):
        raise SystemExit('Candidate retains invariant failures: ' + str(ledgers['candidate']['failed_ids']))
    new_authoring = {
        task_id: {
            'cohort': identity['additions'][task_id],
            'learning_contract': identity['final'][task_id],
            'source_fingerprint': after_fingerprints[task_id],
            'choice_identity': after_choices[task_id],
            'runtime_input': after[task_id],
        }
        for task_id in sorted(NEW_AUTHORING_IDS)
    }
    result = {'ledgers': ledgers, 'runtime_changed_task_count': len(delta), 'runtime_changed_task_ids': sorted(delta),
              'historical_learning_contract_identical': identity['historical_learning_contract_identical'],
              'historical_choice_identity_identical': identity['historical_choice_identity_identical'],
              'historical_contracts_identical_except_reviewed_setup_qualities': True,
              'candidate_producer_revision': identity['candidate_revision'],
              'producer_receipt': identity['final_cohort']['producer_receipt'],
              'reviewed_producer_source_revision': (MAIN01_PRODUCER_REVISION['source_revision']
                  if identity['candidate_revision'] == 'MAIN01_REVIEWED_SETUP_QUALITIES' else None),
              'reviewed_quality_changes': ([
                  {'task_id': MAIN01_TASK_ID, 'choice_id': choice, 'before': prior, 'after': current}
                  for choice, (prior, current) in MAIN01_QUALITY_REVISION.items()
              ] if identity['candidate_revision'] == 'MAIN01_REVIEWED_SETUP_QUALITIES' else []),
              'historical_cohort_count': len(historical_ids),
              'new_authoring': new_authoring,
              'canonical_source_fingerprints': fingerprint_counts, 'native': 'PENDING'}
    (root / 'comparison.json').write_text(json.dumps(result, indent=2))
    hashes = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(root.rglob('*')) if p.is_file()}
    (root / 'sha256.json').write_text(json.dumps(hashes, indent=2))
    print(json.dumps(result))


if __name__ == '__main__':
    if sys.argv[1] == 'tests':
        summarize(sys.argv[2], sys.argv[3], int(sys.argv[4]))
    else:
        compare(sys.argv[2])
