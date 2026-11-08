#!/usr/bin/env python3
"""Summarize real Flutter cases and preserve paired TABLE.TRUTH provenance."""
import collections
import hashlib
import json
import pathlib
import sys


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


def approved_choice_changes(before, after, before_fingerprints, after_fingerprints):
    """Accept only the owner-admitted ASM-03 correction; never rewrite evidence."""
    if before == after:
        return []
    rejection = 'Accepted choice text, ordering or preferred answer changed'
    if before.keys() != after.keys():
        raise SystemExit(rejection)
    task = 'first_table_guide_one_clear_choice'
    preferred = 'You are BTN, blinds are posted, and no board is out yet'
    old_row = ['co_still_acting', 'CO/cutoff already folded, so You at BTN act next',
               False, 'wrong', preferred]
    new_row = ['co_still_acting', 'CO/cutoff still acts before You at BTN',
               False, 'wrong', preferred]
    # Owner admitted this exact semantic transition on 2026-11-07. These are
    # canonical SOURCE fingerprints, distinct from the global ASM-01 snapshot.
    old_source = {'world_id': 'world_1', 'lesson_id': 'what_poker_is',
                  'fingerprint': '0089e0394bdc30b3ce7d65dec1d098b8ae08a10b8eb2d504acf7456a7f14b4da'}
    new_source = {'world_id': 'world_1', 'lesson_id': 'what_poker_is',
                  'fingerprint': '68083c5acfb7594a176f7e2b6a2a966f0e2a921e32aa9be7a12c31b6ebfbf0f5'}
    changes = []
    for task_id, old in before.items():
        new = after[task_id]
        if old == new:
            continue
        if (task_id != task or not isinstance(old, list) or not isinstance(new, list)
                or not old or len(old) != len(new)
                or old[0] != old_row or new[0] != new_row
                or any(a != b for a, b in zip(old[1:], new[1:]))):
            raise SystemExit(rejection)
        if (before_fingerprints.get(task_id) != old_source
                or after_fingerprints.get(task_id) != new_source):
            raise SystemExit('ASM-03 choice correction requires the exact historical and new source fingerprints')
        changes.append({'task_id': task, 'choice_id': 'co_still_acting',
                        'index': 0, 'field': 'label', 'before': old[0], 'after': new[0],
                        'before_source_fingerprint': old_source['fingerprint'],
                        'after_source_fingerprint': new_source['fingerprint'],
                        'authorization': 'ASM03_EXACT_LABEL_CORRECTION_20261107'})
    if len(changes) != 1:
        raise SystemExit(rejection)
    return changes


def compare(root):
    root = pathlib.Path(root)
    base = json.loads((root / 'baseline' / 'learning-contract.json').read_text())
    final = json.loads((root / 'candidate' / 'learning-contract.json').read_text())
    if base != final:
        raise SystemExit('Learning identity, XP, correctness or repair contract changed')
    before = json.loads((root / 'baseline' / 'runtime-inputs.json').read_text())
    after = json.loads((root / 'candidate' / 'runtime-inputs.json').read_text())
    delta = {key: {'before': before[key], 'after': after[key]} for key in before if before[key] != after[key]}
    (root / 'runtime-input-delta.json').write_text(json.dumps(delta, indent=2))
    before_fingerprints = json.loads((root / 'baseline' / 'source-fingerprints.json').read_text())
    after_fingerprints = json.loads((root / 'candidate' / 'source-fingerprints.json').read_text())
    if before_fingerprints.keys() != after_fingerprints.keys():
        raise SystemExit('Canonical fingerprint task identity changed')
    before_choices = json.loads((root / 'baseline' / 'choice-identity.json').read_text())
    after_choices = json.loads((root / 'candidate' / 'choice-identity.json').read_text())
    choice_changes = approved_choice_changes(
        before_choices, after_choices, before_fingerprints, after_fingerprints)
    fingerprint_delta = {}
    for task_id, old in before_fingerprints.items():
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
    result = {'ledgers': ledgers, 'runtime_changed_task_count': len(delta), 'runtime_changed_task_ids': sorted(delta),
              'learning_contract_identical': True,
              'choice_identity_identical': before_choices == after_choices,
              'choice_identity_compatible': True, 'choice_identity_changes': choice_changes,
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
