#!/usr/bin/env python3
"""Judge native UI receipts using actual canonical persisted evidence only."""
import hashlib
import json
from pathlib import Path
import plistlib
import re
import struct
import sys

root = Path(sys.argv[1])
checkpoints = root / 'checkpoints'
observed = {}
PRODUCT = 'fdff8a471817f9063b15e1a6a43c92eb4e2204a7'
TREE = '12ada8e1839e16dfe1651d2c94511c4085c17e4e'
TAGS = ['P1_before_prerequisites', 'P2_guide_completed', 'P4_wrong_fold',
        'P5_correct_repair', 'P6_original_recheck', 'P7_before_unproved',
        'P8_unproved_refused', 'P8b_source_completion_refused', 'P9_after_restart']
SCREENS = ['P0_first_use', 'P1_before_prerequisites', 'P2_guide_completed',
           'P3_legal_context_question'] + TAGS[2:]
GUIDE = {'what_poker_is_theory', 'what_poker_is_find_hero',
         'what_poker_is_table_read_transfer', 'what_poker_is_table_read_recheck',
         'first_table_guide_one_clear_choice', 'first_table_guide_route_roles'}
TARGETS = {'actions_legal_context', 'actions_check_drill'}
TRUTH_FIELDS = ['learningEvidenceHistory', 'earnedXp', 'completedTaskIds',
                'completedLessonIds', 'skippedTaskIds', 'openRepairIntents',
                'multiRepairQueue', 'repairOutcomeProjection',
                'durableRetentionHistory', 'retentionMemory']


def capture_receipt(folder, kind, tag):
    receipt = json.loads((folder / 'receipt.json').read_text())
    expected = 'CAPTURED_NATIVE_SCREEN' if kind == 'SCREEN' else 'CAPTURED_NATIVE_PERSISTENCE'
    assert receipt['status'] == expected, f'{tag}:{receipt}'
    releases = re.findall(r'PKR0205_' + kind + '_RELEASE ' + re.escape(tag)
                          + r' epoch=([0-9.]+)', log)
    assert len(releases) == 1, f'{tag}:missing_or_duplicate_release'
    assert 0 <= receipt['completed_lag_seconds'] < 44, f'{tag}:late_capture'
    assert receipt['requested_epoch'] <= receipt['completed_epoch'] < float(releases[0]), f'{tag}:outside_real_hold'
    return receipt


def canonical_state(tag):
    folder = checkpoints / tag
    receipt = capture_receipt(folder, 'PERSIST', tag)
    raw = (folder / 'learner.plist').read_bytes()
    assert hashlib.sha256(raw).hexdigest() == receipt['plist_sha256'], f'{tag}:raw_plist_changed'
    plist = plistlib.loads(raw)
    envelopes = []
    for suffix in ('head', 'recovery', 'backup'):
        value = plist['flutter.act0_shell_progress_v1_' + suffix]
        assert isinstance(value, str), f'{tag}:{suffix}:not_string'
        envelope = json.loads(value)
        assert envelope['format'] == 1 and type(envelope['revision']) is int and envelope['revision'] > 0
        assert isinstance(envelope['payload'], str), f'{tag}:{suffix}:missing_real_payload'
        digest_input = json.dumps([1, envelope['revision'], envelope['payload']],
                                  ensure_ascii=False, separators=(',', ':')).encode()
        assert envelope['digest'] == hashlib.sha256(digest_input).hexdigest(), f'{tag}:{suffix}:invalid_canonical_digest'
        envelopes.append(value)
    assert len(set(envelopes)) == 1, f'{tag}:canonical_copies_disagree'
    assert 'flutter.act0_shell_progress_v1_recovery_intent_v1' not in plist, f'{tag}:recovery_in_progress'
    state = json.loads(json.loads(envelopes[0])['payload'])
    assert isinstance(state['learningEvidenceHistory'], list)
    ids = [record['recordId'] for record in state['learningEvidenceHistory']]
    assert len(ids) == len(set(ids)), f'{tag}:duplicate_receipt_id'
    for record in state['learningEvidenceHistory']:
        assert record['runId'] == (f"run_v1|{record['sourceWorldId']}|"
                                   f"{record['sourceLessonId']}|{record['runKind']}|{record['runOrdinal']}")
        assert record['worldId'] == record['sourceWorldId'] and record['lessonId'] == record['sourceLessonId']
        assert record['sessionId'] and record['startedBy'] and record['decisionTimeBucket']
        assert record['runKind'] in {'lesson', 'repair', 'placement', 'practice', 'spaced_review', 'recheck'}
        if record['taskId'] in TARGETS:
            assert record.get('authoredSourceFingerprint'), f'{tag}:missing_authored_identity'
            assert record['decisionTimeBucket'] in {'under_3s', '3_to_10s', 'over_10s'}
    completed = state['completedTaskIds']
    assert len(completed) == len(set(completed)), f'{tag}:duplicate_completion'
    assert set(completed) <= GUIDE | TARGETS, f'{tag}:unexpected_completion'
    assert state['earnedXp'] == 5 * len(completed), f'{tag}:source_once_XP_mismatch'
    observed[tag] = {'revision': json.loads(envelopes[0])['revision'],
                     'records': len(ids), 'earnedXp': state['earnedXp'],
                     'completedTaskIds': completed,
                     'canonical_payload_sha256': hashlib.sha256(json.loads(envelopes[0])['payload'].encode()).hexdigest()}
    return state


def journal(tag):
    return [json.loads(line) for line in
            (checkpoints / tag / 'app-owned-telemetry.jsonl').read_text().splitlines() if line]


def truth(state):
    return {field: state[field] for field in TRUTH_FIELDS}


try:
    log = (root / 'native-tests.log').read_text()
    assert (root / 'product-identity.txt').read_text().splitlines() == [PRODUCT, TREE], 'EXACT_PRODUCT_IDENTITY_MISMATCH'
    device = json.loads((root / 'selected-device.json').read_text())
    assert device['model'] == 'iPhone 14 Pro' and device['runtime_version'] == '26.2'
    assert device['language'] == 'en' and device['logical_size'] == [393, 852]
    assert '** TEST SUCCEEDED **' in log, 'NATIVE_XCTEST_DID_NOT_PASS'
    assert 'PKR0205_NATIVE_UI_ROUTE_COMPLETED canonical_evidence_verifier_pending=true' in log
    assert 'PKR0205_ACTUAL_PROCESS_TERMINATE' in log and 'PKR0205_ACTUAL_PROCESS_RELAUNCH' in log
    assert 'PKR0205_EARLY_FOLD_NATIVE_NOT_REACHED prerequisite=actions_fold_drill source_hold=true' in log
    for tag in SCREENS:
        folder = checkpoints / 'screens' / tag
        receipt = capture_receipt(folder, 'SCREEN', tag)
        data = (folder / 'native.png').read_bytes()
        assert data[:8] == b'\x89PNG\r\n\x1a\n'
        assert struct.unpack('>II', data[16:24]) == (1179, 2556), f'{tag}:not_14pro_portrait'
        assert hashlib.sha256(data).hexdigest() == receipt['sha256'], f'{tag}:screen_changed'
    states = {tag: canonical_state(tag) for tag in TAGS}
    previous = []
    checked = 0
    for tag in TAGS:
        history = states[tag]['learningEvidenceHistory']
        assert history[:len(previous)] == previous, f'{tag}:history_rewritten'
        rows = journal(tag)
        for record in history[len(previous):]:
            for event in ('user_choice', 'decision_made', 'task_result'):
                matches = [row['fields'] for row in rows if row['name'] == event
                           and row['fields'].get('attempt_id') == record['recordId']]
                assert len(matches) == 1, f"{tag}:{record['recordId']}:{event}:cardinality={len(matches)}"
                fields = matches[0]
                assert fields['chosen_action'] == record['choiceId'] and fields['correct'] == record['isCorrect']
                if event == 'decision_made':
                    assert fields.get('assistance_kind', 'none') == record['assistanceKind']
            checked += 1
        previous = history
    before = states['P1_before_prerequisites']
    guide = states['P2_guide_completed']
    assert before['completedTaskIds'] == [] and before['earnedXp'] == 0
    placement = before['learningEvidenceHistory']
    assert len(placement) == 3 and all(r['runKind'] == 'placement' and r['reviewKind'] == 'initialAssessment' for r in placement)
    assert len({r['runId'] for r in placement}) == 1, 'PLACEMENT_RUN_IDENTITY_MISMATCH'
    assert GUIDE <= set(guide['completedTaskIds']) and 'what_poker_is' in guide['completedLessonIds']
    assert guide['skippedTaskIds'] == before['skippedTaskIds'], 'GUIDE_PREREQUISITES_NOT_EARNED'
    wrong = states['P4_wrong_fold']['learningEvidenceHistory'][-1]
    correction = states['P5_correct_repair']['learningEvidenceHistory'][-1]
    recheck = states['P6_original_recheck']['learningEvidenceHistory'][-1]
    assert wrong['taskId'] == 'actions_legal_context' and wrong['choiceId'] == 'fold'
    assert wrong['expectedChoiceId'] == 'check' and wrong['isCorrect'] is False
    assert wrong['errorType'] == 'misread_action_legality' and wrong['assistanceKind'] == 'none'
    assert wrong['runKind'] == 'lesson' and wrong['startedBy'] == 'learn_route'
    assert correction['taskId'] == 'actions_check_drill' and correction['choiceId'] == 'check'
    assert correction['isCorrect'] is True and correction['assistanceKind'] == 'none'
    assert correction['runKind'] == 'repair' and correction['reviewKind'] == 'alternateSameSignal'
    assert recheck['taskId'] == 'actions_legal_context' and recheck['choiceId'] == 'check'
    assert recheck['isCorrect'] is True and recheck['errorType'] == 'none' and recheck['assistanceKind'] == 'none'
    assert recheck['runKind'] == 'recheck' and recheck['reviewKind'] == 'originalSourceRecheck'
    assert recheck['startedBy'] == 'same_signal_feedback_cta'
    assert len({r['recordId'] for r in (wrong, correction, recheck)}) == 3
    assert len({r['runId'] for r in (wrong, correction, recheck)}) == 3
    assert states['P4_wrong_fold']['earnedXp'] == guide['earnedXp'], 'WRONG_ANSWER_GRANTED_XP'
    assert 'actions_legal_context' not in states['P4_wrong_fold']['completedTaskIds']
    assert any(i['sourceTaskId'] == 'actions_legal_context' for i in states['P4_wrong_fold']['openRepairIntents']), 'WRONG_SOURCE_DID_NOT_OPEN_REPAIR'
    assert any(i.get('sourceTaskId') == 'actions_legal_context' and i.get('resolutionState') == 'unresolved'
               for i in states['P4_wrong_fold']['multiRepairQueue']['entries']), 'WRONG_SOURCE_DID_NOT_OPEN_QUEUE_DEBT'
    ready = states['P7_before_unproved']
    for event in ('recheck_started', 'recheck_result'):
        links = [row['fields'] for row in journal('P7_before_unproved') if row['name'] == event
                 and row['fields'].get('source_task_id') == 'actions_legal_context']
        assert len(links) == 1 and links[0]['recheck_task_id'] == 'actions_legal_context', f'{event}:source_identity_lost'
        if event == 'recheck_started':
            assert links[0]['repair_task_id'] == 'actions_check_drill', 'REPAIR_BRIDGE_IDENTITY_LOST'
        else:
            assert links[0]['result'] == 'correct' and links[0]['proof_status'] == 'unassisted'
    assert TARGETS <= set(ready['completedTaskIds'])
    assert not any(i['sourceTaskId'] == 'actions_legal_context' for i in ready['openRepairIntents'])
    assert not any(i.get('sourceTaskId') == 'actions_legal_context'
                   and i.get('resolutionState') == 'unresolved'
                   for i in ready['multiRepairQueue']['entries'])
    assert 'fold_check_call_raise' not in ready['completedLessonIds'], 'PARTIAL_ACTIONS_CLAIMED_COMPLETE'
    for tag in ('P8_unproved_refused', 'P8b_source_completion_refused', 'P9_after_restart'):
        assert truth(states[tag]) == truth(ready), f'{tag}:blocked_or_restart_changed_learner_truth'
        assert not any(r['taskId'] == 'actions_fold_drill' for r in states[tag]['learningEvidenceHistory'])
    for tag in ('P8_unproved_refused', 'P8b_source_completion_refused'):
        graded = [row for row in journal(tag) if row['name'] in {'user_choice', 'decision_made', 'task_result'}]
        assert not any(row['fields'].get('taskId', row['fields'].get('task_id')) == 'actions_fold_drill'
                       for row in graded), f'{tag}:unproved_case_emitted_grade'
    prior_process = json.loads((checkpoints / 'P8b_source_completion_refused' / 'process.json').read_text())
    new_process = json.loads((checkpoints / 'P9_after_restart' / 'process.json').read_text())
    assert prior_process['pid'] > 0 and new_process['pid'] > 0 and prior_process['pid'] != new_process['pid'], 'NO_REAL_PROCESS_RESTART'
    observed['native_evidence'] = {'screens': len(SCREENS), 'telemetry_matched_records': checked,
                                  'wrong': wrong, 'repair': correction, 'recheck': recheck,
                                  'pre_restart_pid': prior_process['pid'], 'post_restart_pid': new_process['pid']}
    verdict = {'status': 'PASS_BOUNDED_ACTION_DEFINITIONS_AND_UNPROVED_BLOCK',
               'product_sha': PRODUCT, 'product_tree': TREE,
               'early_fold_native': 'NOT_REACHED_ACTIONS_PREREQUISITE_HELD',
               'scope': 'EN iPhone 14 Pro 393x852; actual UI; canonical persistence after real process restart',
               'pkr02_pkr05': 'HOLD_FULL_ACCEPTANCE_NOT_CLAIMED', 'observed': observed}
except (AssertionError, KeyError, OSError, ValueError, TypeError, plistlib.InvalidFileException) as exc:
    verdict = {'status': 'FAIL_BOUNDED_NATIVE_ACCEPTANCE', 'error': repr(exc),
               'product_sha': PRODUCT, 'observed': observed}
root.mkdir(parents=True, exist_ok=True)
(root / 'native-verdict.json').write_text(json.dumps(verdict, indent=2))
print(verdict['status'], verdict.get('error', ''))
sys.exit(0 if verdict['status'].startswith('PASS_') else 1)
