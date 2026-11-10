#!/usr/bin/env python3
"""Read-only genuine upgrade receipts; historical W1 is navigation provenance."""
import hashlib
import json
from pathlib import Path
import plistlib
import re
import struct
import sys


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def canonical_raw(path):
    plist = plistlib.loads(path.read_bytes())
    values = []
    for suffix in ('head', 'recovery', 'backup'):
        value = plist['flutter.act0_shell_progress_v1_' + suffix]
        assert isinstance(value, str), 'CANONICAL_ENVELOPE_NOT_STRING'
        envelope = json.loads(value)
        assert envelope['format'] == 1 and type(envelope['revision']) is int and envelope['revision'] > 0
        assert isinstance(envelope['payload'], str), 'MISSING_ACTUAL_CANONICAL_PAYLOAD'
        raw = json.dumps([1, envelope['revision'], envelope['payload']], ensure_ascii=False, separators=(',', ':')).encode()
        assert envelope['digest'] == hashlib.sha256(raw).hexdigest(), 'INVALID_CANONICAL_DIGEST'
        values.append(value)
    assert len(set(values)) == 1, 'CANONICAL_COPIES_DISAGREE'
    assert 'flutter.act0_shell_progress_v1_recovery_intent_v1' not in plist, 'UNFINISHED_RECOVERY'
    return json.loads(json.loads(values[0])['payload'])


def capture_receipt(folder, kind, tag):
    receipt = json.loads((folder / 'receipt.json').read_text())
    status = 'CAPTURED_NATIVE_SCREEN' if kind == 'SCREEN' else 'CAPTURED_NATIVE_PERSISTENCE'
    assert receipt['status'] == status, f'{tag}:capture_failed:{receipt}'
    releases = re.findall(r'PKR0205U_' + kind + '_RELEASE ' + re.escape(tag) + r' epoch=([0-9.]+)', log)
    assert len(releases) == 1, f'{tag}:missing_or_duplicate_release'
    assert 0 <= receipt['completed_lag_seconds'] < 44, f'{tag}:late_capture'
    assert receipt['requested_epoch'] <= receipt['completed_epoch'] < float(releases[0]), f'{tag}:outside_real_hold'
    return receipt


def state(tag):
    folder = checkpoints / tag
    receipt = capture_receipt(folder, 'PERSIST', tag)
    assert sha(folder / 'learner.plist') == receipt['plist_sha256'], f'{tag}:changed_raw_plist'
    value = canonical_raw(folder / 'learner.plist')
    history = value['learningEvidenceHistory']
    assert isinstance(history, list)
    ids = [record['recordId'] for record in history]
    assert len(ids) == len(set(ids)), f'{tag}:duplicate_attempt'
    for record in history:
        assert record['runId'] == (f"run_v1|{record['sourceWorldId']}|{record['sourceLessonId']}|"
                                   f"{record['runKind']}|{record['runOrdinal']}")
        assert record['worldId'] == record['sourceWorldId'] and record['lessonId'] == record['sourceLessonId']
        assert record['sessionId'] and record['startedBy'] and record['decisionTimeBucket']
        assert record['runKind'] in {'lesson', 'repair', 'placement', 'practice', 'spaced_review', 'recheck'}
        if record['runKind'] != 'placement':
            assert record.get('authoredSourceFingerprint') and record['assistanceKind'] == 'none'
    completed = value['completedTaskIds']
    assert len(completed) == len(set(completed)), f'{tag}:duplicate_completion'
    assert set(completed) <= set(MAIN_TASKS + PREFIX_TASKS + [EARLY]), f'{tag}:unearned_unexpected_task'
    assert value['earnedXp'] == sum(SOURCE_REWARDS[task] for task in completed), f'{tag}:source_once_XP_mismatch'
    assert set(value['skippedTaskIds']) == set(PLACEMENT_SKIPS), f'{tag}:placement_skip_identity_changed'
    assert not set(completed) & set(PLACEMENT_SKIPS), f'{tag}:navigation_skip_promoted_to_earned'
    observed[tag] = {'records': len(history), 'earnedXp': value['earnedXp'], 'completedTaskIds': completed,
                     'openRepairIntents': value['openRepairIntents'], 'repairQueue': value['multiRepairQueue']}
    return value


def journal(tag):
    return [json.loads(line) for line in (checkpoints / tag / 'app-owned-telemetry.jsonl').read_text().splitlines() if line]


def verify_appended_events(tags, initial):
    previous = initial
    checked = 0
    for tag in tags:
        current = states[tag]['learningEvidenceHistory']
        assert current[:len(previous)] == previous, f'{tag}:history_rewritten'
        rows = journal(tag)
        for record in current[len(previous):]:
            for event in ('user_choice', 'decision_made', 'task_result'):
                matches = [row['fields'] for row in rows if row['name'] == event and row['fields'].get('attempt_id') == record['recordId']]
                assert len(matches) == 1, f"{tag}:{record['recordId']}:{event}:cardinality={len(matches)}"
                fields = matches[0]
                assert fields['chosen_action'] == record['choiceId'] and fields['correct'] == record['isCorrect']
                if event == 'decision_made':
                    assert fields.get('assistance_kind', 'none') == record['assistanceKind']
            checked += 1
        previous = current
    return checked


def truth(value):
    return {field: value[field] for field in TRUTH_FIELDS}


def mapped_debt(value, occurrence):
    intents = [intent for intent in value['openRepairIntents'] if intent['sourceTaskId'] == EARLY]
    assert len(intents) == 1 and intents[0]['targetTaskId'] == HELD_TARGET, 'ACTUAL_MAPPED_INTENT_LOST'
    assert intents[0]['mappingType'] == 'repair' and intents[0]['repairOccurrenceId'] == occurrence
    entries = [entry for entry in value['multiRepairQueue']['entries']
               if entry.get('sourceTaskId') == EARLY and entry.get('resolutionState') == 'unresolved']
    assert len(entries) == 1, 'MAPPED_REPAIR_DEBT_NOT_RETAINED'
    return {'intent': intents[0], 'queue': entries}

def verify():
    global log, states
    main_log = (root / 'main-tests.log').read_text()
    final_log = (root / 'final-tests.log').read_text()
    log = main_log + '\n' + final_log
    assert '** TEST SUCCEEDED **' in main_log and '** TEST SUCCEEDED **' in final_log, 'BOTH_ACTUAL_UI_PHASES_REQUIRED'
    assert 'PKR0205U_MAIN_TERMINATED_FOR_ORDINARY_UPGRADE' in main_log
    assert 'PKR0205U_ACTUAL_EARLYFOLD_ROUTE_COMPLETED full_pkr_hold=true' in final_log
    assert 'PKR0205U_ORIGINAL_RETRY_AFTER_FEEDBACK not_matched_recheck=true' in final_log
    assert (root / 'main/product-identity.txt').read_text().splitlines() == [MAIN, MAIN_TREE]
    assert (root / 'final/product-identity.txt').read_text().splitlines() == [PRODUCT, PRODUCT_TREE]
    device = json.loads((root / 'selected-device.json').read_text())
    assert device['model'] == 'iPhone 14 Pro' and device['runtime_version'] == '26.2'
    assert device['language'] == 'en' and device['logical_size'] == [393, 852]
    trusted = json.loads((root / 'trusted-final-receipt.json').read_text())
    trusted_main = json.loads((root / 'trusted-main-receipt.json').read_text())
    main_artifact = json.loads((root / 'sealed-main-artifact-metadata.json').read_text())
    assert main_artifact['id'] == int(trusted_main['PKR_MAIN_ARTIFACT_ID'])
    assert main_artifact['workflow_run']['id'] == int(trusted_main['PKR_MAIN_RUN_ID'])
    assert main_artifact['workflow_run']['head_sha'] == trusted_main['PKR_MAIN_WRAPPER_SHA']
    assert main_artifact['digest'] == 'sha256:' + trusted_main['PKR_MAIN_ARTIFACT_SHA256']
    assert sha(root / 'main/Runner.zip') == trusted_main['PKR_MAIN_ARCHIVE_SHA256']
    assert (root / 'main/kernel.sha256').read_text().split()[0] == trusted_main['PKR_MAIN_KERNEL_SHA256']
    artifact = json.loads((root / 'sealed-final-artifact-metadata.json').read_text())
    assert artifact['id'] == int(trusted['PKR_FINAL_ARTIFACT_ID']) and artifact['workflow_run']['id'] == 42788406050
    assert artifact['digest'] == 'sha256:' + trusted['PKR_FINAL_ARTIFACT_SHA256']
    assert sha(root / 'final/Runner.zip') == trusted['PKR_FINAL_ARCHIVE_SHA256']
    assert (root / 'final/kernel.sha256').read_text().split()[0] == trusted['PKR_FINAL_KERNEL_SHA256']
    before_folder = root / 'before-install'
    after_folder = root / 'after-install-before-launch'
    before = json.loads((before_folder / 'snapshot.json').read_text())
    after = json.loads((after_folder / 'snapshot.json').read_text())
    assert before['data_container'] == after['data_container'] and before['simulator'] == after['simulator'] == device['udid']
    assert before['running_product_pids'] == after['running_product_pids'] == [], 'PRODUCT_RAN_DURING_INSTALL_BOUNDARY'
    assert (before_folder / 'learner.plist').read_bytes() == (after_folder / 'learner.plist').read_bytes(), 'RAW_LEARNER_STATE_CHANGED_DURING_INSTALL'
    assert before['preference_files_sha256'] == after['preference_files_sha256'], 'PREFERENCE_DOMAIN_CHANGED_DURING_INSTALL'
    assert before['installed_kernel_sha256'] == (root / 'main/kernel.sha256').read_text().split()[0]
    assert after['installed_kernel_sha256'] == trusted['PKR_FINAL_KERNEL_SHA256'], 'INSTALLED_FINAL_BINARY_NOT_SEALED_SOURCE'
    assert before['observed_epoch'] < after['observed_epoch']
    assert json.loads((root / 'ordinary-install-verdict.json').read_text())['status'] == 'PASS_BYTE_IDENTICAL_EXISTING_PREFERENCES_BEFORE_FIRST_FINAL_LAUNCH'
    for tag in SCREENS:
        folder = checkpoints / 'screens' / tag
        receipt = capture_receipt(folder, 'SCREEN', tag)
        data = (folder / 'native.png').read_bytes()
        assert data[:8] == b'\x89PNG\r\n\x1a\n' and struct.unpack('>II', data[16:24]) == (1179, 2556)
        assert hashlib.sha256(data).hexdigest() == receipt['sha256'], f'{tag}:screen_changed'
    states = {tag: state(tag) for tag in MAIN_TAGS + FINAL_TAGS}
    main_history = states['M8_real_world_two_unlocked']['learningEvidenceHistory']
    placement = states['M1_real_placement']
    assert placement['earnedXp'] == 0 and placement['completedTaskIds'] == []
    assert len(placement['learningEvidenceHistory']) == 3
    assert all(r['runKind'] == 'placement' and r['reviewKind'] == 'initialAssessment' for r in placement['learningEvidenceHistory'])
    historical_choices = main_history[3:]
    assert [record['taskId'] for record in historical_choices] == list(MAIN_CHOICES), 'HISTORICAL_UI_ROUTE_NOT_ACTUALLY_EARNED'
    for record in historical_choices:
        assert record['choiceId'] == MAIN_CHOICES[record['taskId']] and record['isCorrect'] is True
        assert record['expectedChoiceId'] == record['choiceId'] and record['errorType'] == 'none'
        assert record['worldId'] == 'world_1' and record['runKind'] == 'lesson'
    historic = states['M8_real_world_two_unlocked']
    assert set(historic['completedTaskIds']) == set(MAIN_TASKS) and historic['earnedXp'] == sum(SOURCE_REWARDS[task] for task in MAIN_TASKS)
    assert truth(canonical_raw(before_folder / 'learner.plist')) == truth(historic), 'TERMINATION_REWROTE_HISTORICAL_TRUTH'
    assert truth(canonical_raw(after_folder / 'learner.plist')) == truth(historic)
    assert truth(states['U0_preserved_on_final_launch']) == truth(historic), 'UPGRADE_FIRST_LAUNCH_REWROTE_HISTORICAL_TRUTH'
    observed['historical_event_records'] = verify_appended_events(MAIN_TAGS, [])
    observed['final_event_records'] = verify_appended_events(FINAL_TAGS, main_history)
    pretarget = states['U2_actual_earlyfold_question']
    assert set(pretarget['completedTaskIds']) == set(MAIN_TASKS + PREFIX_TASKS)
    assert pretarget['earnedXp'] == sum(SOURCE_REWARDS[task] for task in MAIN_TASKS + PREFIX_TASKS)
    prefix = pretarget['learningEvidenceHistory'][len(main_history):]
    assert [record['taskId'] for record in prefix] == list(PREFIX_CHOICES)
    for record in prefix:
        assert record['choiceId'] == PREFIX_CHOICES[record['taskId']] and record['isCorrect'] is True
        assert record['authoredSourceFingerprint'] == FINAL_FINGERPRINTS[record['taskId']]
        assert record['worldId'] == 'world_2' and record['runKind'] == 'lesson'
    wrong_state = states['U3_wrong_raise']
    wrong = wrong_state['learningEvidenceHistory'][-1]
    assert wrong_state['learningEvidenceHistory'][:-1] == pretarget['learningEvidenceHistory']
    assert wrong['taskId'] == EARLY and wrong['choiceId'] == 'raise' and wrong['expectedChoiceId'] == 'fold'
    assert wrong['isCorrect'] is False and wrong['errorType'] not in ('', 'none', None)
    assert wrong['worldId'] == 'world_2' and wrong['lessonId'] == 'fold_discipline'
    assert wrong['authoredSourceFingerprint'] == FINAL_FINGERPRINTS[EARLY]
    assert wrong['runKind'] == 'lesson' and wrong['startedBy'] == 'learn_route' and wrong['assistanceKind'] == 'none'
    assert wrong_state['earnedXp'] == pretarget['earnedXp'] and EARLY not in wrong_state['completedTaskIds']
    observed['wrong_debt'] = mapped_debt(wrong_state, wrong['recordId'])
    repair_before = states['U4_actual_mapped_price_repair']
    repair_after = states['U5_mapped_price_refused']
    assert truth(repair_before) == truth(repair_after), 'HELD_NUMERIC_REPAIR_CHANGED_LEARNER_TRUTH'
    assert repair_after['learningEvidenceHistory'] == wrong_state['learningEvidenceHistory']
    graded = lambda tag: [row for row in journal(tag) if row['name'] in {'user_choice', 'decision_made', 'task_result'}]
    assert graded('U4_actual_mapped_price_repair') == graded('U5_mapped_price_refused'), 'HELD_NUMERIC_REPAIR_EMITTED_GRADE'
    observed['blocked_debt'] = mapped_debt(repair_after, wrong['recordId'])
    correct_state = states['U7_correct_original_retry']
    correct = correct_state['learningEvidenceHistory'][-1]
    assert correct_state['learningEvidenceHistory'][:-1] == wrong_state['learningEvidenceHistory']
    assert correct['taskId'] == EARLY and correct['choiceId'] == 'fold' and correct['expectedChoiceId'] == 'fold'
    assert correct['isCorrect'] is True and correct['errorType'] == 'none' and correct['assistanceKind'] == 'none'
    assert correct['authoredSourceFingerprint'] == FINAL_FINGERPRINTS[EARLY]
    assert correct['runKind'] == 'lesson' and correct['startedBy'] == 'learn_route'
    assert correct['reviewKind'] == 'exactReplay', 'ORDINARY_RETRY_MISLABELLED_AS_MATCHED_RECHECK'
    assert correct['recordId'] != wrong['recordId']
    assert correct_state['earnedXp'] == pretarget['earnedXp'] and EARLY not in correct_state['completedTaskIds'], 'FEEDBACK_PROMOTED_TO_COMPLETION_BEFORE_CONTINUE'
    assert all(record['decisionTimeBucket'] in {'under_3s', '3_to_10s', 'over_10s'} for record in (wrong, correct))
    completed = states['U8_original_completion']
    assert completed['learningEvidenceHistory'] == correct_state['learningEvidenceHistory']
    assert set(completed['completedTaskIds']) == set(MAIN_TASKS + PREFIX_TASKS + [EARLY])
    assert completed['earnedXp'] == pretarget['earnedXp'] + SOURCE_REWARDS[EARLY], 'ORIGINAL_RETRY_DID_NOT_AWARD_SOURCE_ONCE_XP'
    # Source contract: ordinary original retry is not completion of its mapped
    # actions_call_drill repair. Report the actual debt and preserve its identity.
    observed['after_retry_debt'] = mapped_debt(completed, wrong['recordId'])
    assert completed['repairOutcomeProjection'] == wrong_state['repairOutcomeProjection'], 'ORDINARY_RETRY_CLAIMED_MATCHED_REPAIR'
    assert truth(states['U9_before_restart']) == truth(completed)
    assert truth(states['U10_after_restart']) == truth(completed), 'REAL_RESTART_LOST_FINAL_LEARNER_TRUTH'
    prior_pid = json.loads((checkpoints / 'U9_before_restart/process.json').read_text())['pid']
    next_pid = json.loads((checkpoints / 'U10_after_restart/process.json').read_text())['pid']
    assert prior_pid > 0 and next_pid > 0 and prior_pid != next_pid, 'NO_ACTUAL_PROCESS_RESTART'
    assert 'PKR0205U_ACTUAL_PROCESS_TERMINATE' in final_log and 'PKR0205U_ACTUAL_PROCESS_RELAUNCH' in final_log
    observed['final_target_receipts'] = {'wrong': wrong, 'ordinary_retry': correct,
                                         'before_restart_pid': prior_pid, 'after_restart_pid': next_pid}
    observed['upgrade_binding'] = {'main_sha': MAIN, 'final_sha': PRODUCT,
                                   'main_sealed_artifact_id': main_artifact['id'],
                                   'sealed_artifact_id': artifact['id'], 'kernel_sha256': after['installed_kernel_sha256'],
                                   'same_actual_container': True, 'raw_preferences_unchanged_by_install': True}
    return {'status': 'PASS_BOUNDED_GENUINE_UPGRADE_EARLYFOLD', 'product_sha': PRODUCT,
            'historical_main_scope': 'REAL_UI_NAVIGATION_PROVENANCE_ONLY_NOT_FINAL_NUMERIC_RECERTIFICATION',
            'early_fold_native': 'fold_discipline_early_fold wrongRaise and ordinary correctFold retry, feedback and actual restart',
            'repair_recheck': 'HOLD_MAPPED_NUMERIC_TARGET_UNPROVED_NO_MATCHED_RECHECK',
            'other_two_early_fold_tasks': 'NOT_NATIVE_REACHED', 'pkr02_pkr05': 'HOLD_FULL_ACCEPTANCE',
            'mastery_retention': 'NOT_CLAIMED', 'observed': observed}


root = Path(sys.argv[1])
checkpoints = root / 'checkpoints'
observed = {}
MAIN = '3784d421beb5ae7cb8cfaacd10b1083855148850'
MAIN_TREE = 'eb088750944257db10fc3bd851ebc49000cf255a'
PRODUCT = 'fdff8a471817f9063b15e1a6a43c92eb4e2204a7'
PRODUCT_TREE = '12ada8e1839e16dfe1651d2c94511c4085c17e4e'
ROUTE_MANIFEST_SHA256 = '44cd1595c84163b8a4a555b5017496cbae44a20d4f8f3abedf634d10263cec67'
REWARD_MANIFEST_SHA256 = '57fdc7565197ed1aa2cf9024b4a7cc7baeeda2283dfa835d63ae8ccc47df0927'
SOURCE_REWARDS = {'what_poker_is_theory': 5, 'what_poker_is_find_hero': 5, 'what_poker_is_table_read_transfer': 5, 'what_poker_is_table_read_recheck': 5, 'first_table_guide_one_clear_choice': 5, 'first_table_guide_route_roles': 5, 'actions_legal_context': 5, 'actions_check_drill': 5, 'actions_fold_drill': 5, 'actions_call_drill': 5, 'actions_raise_drill': 5, 'actions_review': 5, 'blinds_theory': 5, 'blinds_posts_drill': 5, 'blinds_first_actor': 5, 'blinds_last_actor': 5, 'blinds_postflop_button': 5, 'blinds_button_moves': 5, 'blinds_review': 5, 'positions_theory': 5, 'positions_button': 5, 'positions_utg': 5, 'positions_cutoff': 5, 'positions_late_seat': 5, 'positions_early_late': 5, 'positions_review': 5, 'hand_rankings_theory': 8, 'hand_rankings_pair_drill': 7, 'hand_rankings_two_pair_drill': 7, 'hand_rankings_trips_drill': 7, 'hand_rankings_straight_drill': 7, 'hand_rankings_flush_drill': 7, 'hand_rankings_full_house_drill': 7, 'hand_rankings_quads_drill': 7, 'hand_rankings_royal_flush_drill': 7, 'hand_rankings_full_house_vs_flush_drill': 7, 'hand_rankings_quads_vs_full_house_drill': 7, 'hand_rankings_royal_vs_flush_drill': 7, 'hand_rankings_best_five_drill': 7, 'hand_rankings_review': 8, 'showdown_theory': 8, 'showdown_foldout_drill': 7, 'showdown_best_hand_drill': 7, 'showdown_kicker_drill': 7, 'showdown_board_plays_drill': 7, 'showdown_tie_drill': 7, 'showdown_review': 8, 'hand_discipline_buckets_intro': 5, 'hand_discipline_buckets_premium': 6, 'hand_discipline_buckets_strong': 7, 'hand_discipline_buckets_medium': 7, 'hand_discipline_buckets_trash': 7, 'hand_discipline_buckets_borderline': 7, 'hand_discipline_buckets_recap': 10, 'fold_discipline_discipline_intro': 6, 'fold_discipline_early_fold': 8}
MAIN_TAGS = ['M1_real_placement', 'M2_guide', 'M3_actions', 'M4_blinds',
             'M5_positions', 'M6_rankings', 'M7_showdown', 'M8_real_world_two_unlocked']
FINAL_TAGS = ['U0_preserved_on_final_launch', 'U1_final_buckets',
              'U2_actual_earlyfold_question', 'U3_wrong_raise',
              'U4_actual_mapped_price_repair', 'U5_mapped_price_refused',
              'U7_correct_original_retry', 'U8_original_completion',
              'U9_before_restart', 'U10_after_restart']
SCREENS = ['M0_fresh_main'] + MAIN_TAGS + FINAL_TAGS + ['U6_actual_original_retry_question']
TRUTH_FIELDS = ['learningEvidenceHistory', 'earnedXp', 'completedTaskIds',
                'completedLessonIds', 'skippedTaskIds', 'openRepairIntents',
                'multiRepairQueue', 'repairOutcomeProjection',
                'durableRetentionHistory', 'retentionMemory']
EARLY = 'fold_discipline_early_fold'
HELD_TARGET = 'actions_call_drill'
MAIN_TASKS = ['what_poker_is_theory', 'what_poker_is_find_hero', 'what_poker_is_table_read_transfer', 'what_poker_is_table_read_recheck', 'first_table_guide_one_clear_choice', 'first_table_guide_route_roles', 'actions_legal_context', 'actions_check_drill', 'actions_fold_drill', 'actions_call_drill', 'actions_raise_drill', 'actions_review', 'blinds_theory', 'blinds_posts_drill', 'blinds_first_actor', 'blinds_last_actor', 'blinds_postflop_button', 'blinds_button_moves', 'blinds_review', 'positions_theory', 'positions_button', 'positions_utg', 'positions_cutoff', 'positions_late_seat', 'positions_early_late', 'positions_review', 'hand_rankings_theory', 'hand_rankings_pair_drill', 'hand_rankings_two_pair_drill', 'hand_rankings_trips_drill', 'hand_rankings_straight_drill', 'hand_rankings_flush_drill', 'hand_rankings_full_house_drill', 'hand_rankings_quads_drill', 'hand_rankings_royal_flush_drill', 'hand_rankings_full_house_vs_flush_drill', 'hand_rankings_quads_vs_full_house_drill', 'hand_rankings_royal_vs_flush_drill', 'hand_rankings_best_five_drill', 'hand_rankings_review', 'showdown_theory', 'showdown_foldout_drill', 'showdown_best_hand_drill', 'showdown_kicker_drill', 'showdown_board_plays_drill', 'showdown_tie_drill', 'showdown_review']
MAIN_CHOICES = {'what_poker_is_find_hero': 'bottom', 'what_poker_is_table_read_transfer': 'two_three_six', 'what_poker_is_table_read_recheck': 'two_three_four', 'first_table_guide_one_clear_choice': 'hero_btn_preflop_setup', 'first_table_guide_route_roles': 'review', 'actions_legal_context': 'check', 'actions_check_drill': 'check', 'actions_fold_drill': 'fold', 'actions_call_drill': 'call', 'actions_raise_drill': 'raise', 'actions_review': 'raise', 'blinds_posts_drill': 'bb', 'blinds_first_actor': 'utg', 'blinds_last_actor': 'bb', 'blinds_postflop_button': 'btn', 'blinds_button_moves': 'btn', 'blinds_review': 'utg', 'positions_button': 'btn', 'positions_utg': 'utg', 'positions_cutoff': 'co', 'positions_late_seat': 'btn', 'positions_early_late': 'utg', 'positions_review': 'bottom', 'hand_rankings_pair_drill': 'pair', 'hand_rankings_two_pair_drill': 'two_pair', 'hand_rankings_trips_drill': 'trips', 'hand_rankings_straight_drill': 'five_in_row', 'hand_rankings_flush_drill': 'flush', 'hand_rankings_full_house_drill': 'full_house', 'hand_rankings_quads_drill': 'quads', 'hand_rankings_royal_flush_drill': 'royal_flush', 'hand_rankings_full_house_vs_flush_drill': 'hero_full_house', 'hand_rankings_quads_vs_full_house_drill': 'hero_quads', 'hand_rankings_royal_vs_flush_drill': 'hero_royal_flush', 'hand_rankings_best_five_drill': 'five', 'hand_rankings_review': 'flush', 'showdown_foldout_drill': 'win_now', 'showdown_best_hand_drill': 'best_hand', 'showdown_kicker_drill': 'kicker', 'showdown_board_plays_drill': 'tie', 'showdown_tie_drill': 'split', 'showdown_review': 'best_hand'}
PREFIX_TASKS = ['hand_discipline_buckets_intro', 'hand_discipline_buckets_premium', 'hand_discipline_buckets_strong', 'hand_discipline_buckets_medium', 'hand_discipline_buckets_trash', 'hand_discipline_buckets_borderline', 'hand_discipline_buckets_recap', 'fold_discipline_discipline_intro']
PREFIX_CHOICES = {'hand_discipline_buckets_premium': 'premium', 'hand_discipline_buckets_strong': 'strong', 'hand_discipline_buckets_medium': 'medium', 'hand_discipline_buckets_trash': 'trash', 'hand_discipline_buckets_borderline': 'medium'}
PLACEMENT_SKIPS = ['what_poker_is_pot_stack', 'what_poker_is_win_ways', 'what_poker_is_showdown_win', 'what_poker_is_all_in_meaning', 'what_poker_is_matched_chips_transfer', 'what_poker_is_live_win_transfer', 'what_poker_is_review', 'cards_ranks_suits_theory', 'cards_ranks_suits_rank_drill', 'cards_ranks_suits_suit_drill', 'cards_ranks_suits_private_board', 'cards_ranks_suits_board_count', 'cards_ranks_suits_best_five', 'cards_ranks_suits_recap', 'your_first_hand_preflop', 'your_first_hand_private_cards_recheck', 'your_first_hand_flop', 'your_first_hand_turn', 'your_first_hand_river', 'your_first_hand_showdown', 'your_first_hand_action_trail', 'your_first_hand_recap', 'actions_theory']
FINAL_FINGERPRINTS = {'hand_discipline_buckets_intro': '483dd47f9ad37bdc95db449095285e9cc5787adfdb2abfd100c8d42389daf304', 'hand_discipline_buckets_premium': '42ada0b5698d0215f0211ed107b5c5e2e25781383a4d302bfa38b520a951c4fc', 'hand_discipline_buckets_strong': '696451cf963e5639f895bc3f068166045a25cada1572b358321adfcc561ddd1d', 'hand_discipline_buckets_medium': '5d3baf2bdc82468aad8ace7f861fad9f32cd08bafb0c44ce8dc83fb141c5cd32', 'hand_discipline_buckets_trash': '610558c2eec2926c785ba47842d17ba1807569dec034db1be2583f5eac52f3fe', 'hand_discipline_buckets_borderline': 'f528fbd3c9dfdcb4692167d5e0d722cd4d1d107688f631d0f6038a534f8ee4d5', 'hand_discipline_buckets_recap': 'b4f886542d0cd2ff1f95fcdd07b8e34675f2a0a324eabc697d0c8edc52ace285', 'fold_discipline_discipline_intro': '88f0a5ba62417ec84711977e8475723594861c903bdd8de50fbcd37cd23aa722', 'fold_discipline_early_fold': '654db3e84bb298bca713a6b859977e23ee96e53754ca902c747344545b9918db'}

try:
    verdict = verify()
except (AssertionError, KeyError, OSError, ValueError, TypeError, plistlib.InvalidFileException) as exc:
    verdict = {'status': 'FAIL_GENUINE_UPGRADE_NATIVE_ACCEPTANCE', 'error': repr(exc),
               'product_sha': PRODUCT, 'observed': observed}
root.mkdir(parents=True, exist_ok=True)
(root / 'upgrade-native-verdict.json').write_text(json.dumps(verdict, indent=2))
print(verdict['status'], verdict.get('error', ''))
sys.exit(0 if verdict['status'].startswith('PASS_') else 1)
