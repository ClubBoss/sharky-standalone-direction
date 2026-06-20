import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('open repair intent resolves next useful hand to stored target', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    final target = _nextUsefulHandTargetPayload(tester);
    final audit = _repairIntentAuditTrailPayload(tester);
    final bridge = _copyBridgePayload(tester);
    final decision = _repairDecisionPayload(target);

    expect(target?['source'], 'repair_intent');
    expect(target?['selectionSource'], 'repair_intent_mapped');
    expect(target?['sourceTaskId'], 'actions_legal_context');
    expect(target?['targetTaskId'], 'actions_check_drill');
    expect(target?['missedSignalId'], 'no_bet_yet');
    expect(target?['skillAtomId'], 'action_read');
    expect(target?['mappingType'], 'repair');
    expect(target?['reasonCode'], 'same_signal_action_read_no_bet_yet');
    expect(decision?['recommendationSource'], 'repair_intent');
    expect(decision?['actionType'], 'same_signal_repair');
    expect(decision?['selectionSource'], 'repair_intent_mapped');
    expect(decision?['decisionRule'], 'same_signal_repair_v1');
    expect(decision?['priorityBand'], 'repair_next');
    expect(decision?['priorityScore'], 80);
    expect(decision?['choiceId'], 'fold');
    expect(decision?['result'], 'incorrect');
    expect(decision?['errorType'], 'missed_action_read');
    expect(decision?['sourceTaskId'], 'actions_legal_context');
    expect(decision?['targetTaskId'], 'actions_check_drill');
    expect(decision?['reasonCode'], 'same_signal_action_read_no_bet_yet');
    expect(audit.length, 2);
    expect(audit.first['transition'], 'intent_created');
    expect(audit.first['sourceTaskId'], 'actions_legal_context');
    expect(audit.first['targetTaskId'], 'actions_check_drill');
    expect(audit.first['mappingType'], 'repair');
    expect(audit.last['transition'], 'mapped_selection');
    expect(audit.last['sourceTaskId'], 'actions_legal_context');
    expect(audit.last['targetTaskId'], 'actions_check_drill');
    expect(audit.last['selectionSource'], 'repair_intent_mapped');
    expect(audit.last['reasonCode'], 'same_signal_action_read_no_bet_yet');
    expect(audit.last['mappingType'], 'repair');
    expect(bridge['schemaVersion'], 1);
    expect(bridge['lineKind'], 'missed_clue_repair_same_signal');
    expect(bridge['safeTemplateId'], 'repair_same_clue_v1');
    expect(bridge['sourceTaskId'], 'actions_legal_context');
    expect(bridge['targetTaskId'], 'actions_check_drill');
    expect(bridge['clueKey'], 'no_bet_yet');
    expect(bridge['clueLabel'], 'No bet yet');
    expect(bridge['skillKey'], 'action_read');
    expect(bridge['skillLabel'], 'Action read');
    expect(bridge['selectionSource'], 'repair_intent_mapped');
    expect(bridge['reasonCode'], 'same_signal_action_read_no_bet_yet');
  });

  testWidgets('mapped repair bridge renders same-clue review copy', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    await _openReview(tester);

    expect(
      find.text(
        'You missed that nobody has bet yet. This hand repeats that table clue.',
      ),
      findsOneWidget,
    );
    final snapshot = _reviewSupportCopySnapshot(tester);
    expect(snapshot?['schemaVersion'], 1);
    expect(snapshot?['safeTemplateId'], 'repair_same_clue_v1');
    expect(snapshot?['lineKind'], 'missed_clue_repair_same_signal');
    expect(snapshot?['selectionSource'], 'repair_intent_mapped');
    expect(
      snapshot?['renderedLine'],
      'You missed that nobody has bet yet. This hand repeats that table clue.',
    );
    expect(snapshot?['sourceTaskId'], 'actions_legal_context');
    expect(snapshot?['targetTaskId'], 'actions_check_drill');
    expect(snapshot?['reasonCode'], 'same_signal_action_read_no_bet_yet');
    expect(
      find.text('Replay this spot to fix the no-bet-yet clue.'),
      findsNothing,
    );
  });

  testWidgets('mapped repair reason is visible on Home next useful hand', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    const visibleReason =
        'You missed that nobody has bet yet. This hand repeats that table clue.';
    expect(_homeNextUsefulHandReasonLine(tester), visibleReason);
    await _pumpHomeWithReason(tester, visibleReason);
    expect(find.text(visibleReason), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_next_best_action_block')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_next_best_action_title')),
      findsOneWidget,
    );
    expect(find.text('Repair the no-bet-yet clue'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_next_best_action_reason')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_session_summary_ceremony_block')),
      findsNothing,
    );
    expect(find.text('Session proof'), findsNothing);
    for (final token in _forbiddenVisibleReasonTokens) {
      expect(_containsForbiddenTokenInText(visibleReason, token), isFalse);
    }
  });

  testWidgets('mapped repair reason becomes Practice reinforcement entry', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    await _openPractice(tester);

    final hero = find.byKey(const Key('act0_shell_play_daily_hero'));
    expect(hero, findsOneWidget);
    expect(
      find.descendant(
        of: hero,
        matching: find.text('Practice the no-bet-yet clue'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: hero,
        matching: find.text('One same-clue rep will help lock this in.'),
      ),
      findsOneWidget,
    );
    expect(find.text('Repair reinforcement'), findsOneWidget);
    expect(find.text('Session proof'), findsNothing);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_review_screen')), findsNothing);
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsNothing);
    expect(find.byKey(const Key('act0_shell_profile_screen')), findsNothing);
    expect(find.textContaining('leak'), findsNothing);
  });

  testWidgets('exact replay bridge renders exact-replay review copy', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    await _openReview(tester);

    expect(
      find.text('Replay this spot to fix the no-bet-yet clue.'),
      findsOneWidget,
    );
    final snapshot = _reviewSupportCopySnapshot(tester);
    expect(snapshot?['schemaVersion'], 1);
    expect(snapshot?['safeTemplateId'], 'repair_exact_replay_v1');
    expect(snapshot?['lineKind'], 'exact_replay_repair');
    expect(snapshot?['selectionSource'], 'repair_intent_exact_replay');
    expect(
      snapshot?['renderedLine'],
      'Replay this spot to fix the no-bet-yet clue.',
    );
    expect(snapshot?['sourceTaskId'], 'actions_legal_context');
    expect(snapshot?['targetTaskId'], 'actions_legal_context');
    expect(snapshot?['reasonCode'], 'exact_replay_action_read_no_bet_yet');
    expect(
      find.text(
        'You missed that nobody has bet yet. This hand repeats that table clue.',
      ),
      findsNothing,
    );
  });

  testWidgets('exact replay reason is visible on Home without same-signal copy', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    const visibleReason = 'Replay this spot to fix the no-bet-yet clue.';
    expect(_homeNextUsefulHandReasonLine(tester), visibleReason);
    await _pumpHomeWithReason(tester, visibleReason);
    expect(find.text(visibleReason), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_next_best_action_block')),
      findsOneWidget,
    );
    expect(find.text('Replay this spot'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_session_summary_ceremony_block')),
      findsNothing,
    );
    expect(find.text('Session proof'), findsNothing);
    expect(
      find.text(
        'You missed that nobody has bet yet. This hand repeats that table clue.',
      ),
      findsNothing,
    );
    for (final token in _forbiddenVisibleReasonTokens) {
      expect(_containsForbiddenTokenInText(visibleReason, token), isFalse);
    }
  });

  testWidgets('exact replay reason becomes replay Practice entry', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    await _openPractice(tester);

    final hero = find.byKey(const Key('act0_shell_play_daily_hero'));
    expect(hero, findsOneWidget);
    expect(
      find.descendant(of: hero, matching: find.text('Replay this spot')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: hero,
        matching: find.text('Train the exact spot again.'),
      ),
      findsOneWidget,
    );
    expect(find.text('Repair reinforcement'), findsOneWidget);
    expect(find.textContaining('same-clue'), findsNothing);
    expect(find.textContaining('same signal'), findsNothing);
    expect(find.text('Session proof'), findsNothing);
  });

  testWidgets('same state resolves same repair intent target repeatedly', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    final first = _nextUsefulHandTargetPayload(tester);
    final second = _nextUsefulHandTargetPayload(tester);
    final firstBridge = _copyBridgePayload(tester);
    final secondBridge = _copyBridgePayload(tester);
    final audit = _repairIntentAuditTrailPayload(tester);

    expect(first, second);
    expect(firstBridge, secondBridge);
    expect(second?['targetTaskId'], 'actions_check_drill');
    expect(audit.length, 2);
    expect(audit.last['transition'], 'mapped_selection');
  });

  testWidgets('successful repair clears resolver priority', (tester) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');
    expect(
      _nextUsefulHandTargetPayload(tester)?['targetTaskId'],
      'actions_check_drill',
    );

    await _launchReviewRepair(tester);
    await _advanceTeachingToDrill(tester);
    await _answerCorrectly(tester);
    expect(
      find.text('Repair fixed: you caught the no-bet-yet clue.'),
      findsOneWidget,
    );
    expect(
      find.text('Today you repaired the no-bet-yet clue.'),
      findsOneWidget,
    );
    expect(find.textContaining('mastered forever'), findsNothing);
    expect(
      find.text(
        'Still missed: nobody had bet yet. One more repair hand will help.',
      ),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    final target = _nextUsefulHandTargetPayload(tester);
    final bridge = _copyBridgePayload(tester);
    final audit = _repairIntentAuditTrailPayload(tester);
    expect(target?['source'], isNot('repair_intent'));
    expect(target?['selectionSource'], 'existing_fallback');
    expect(target?['targetTaskId'], isNot('actions_check_drill'));
    expect(bridge['lineKind'], 'existing_fallback');
    expect(bridge['safeTemplateId'], 'fallback_next_hand_v1');
    expect(bridge['selectionSource'], 'existing_fallback');
    expect(
      audit.map((entry) => entry['transition']),
      containsAllInOrder(<String>[
        'intent_cleared',
        'existing_fallback_selection',
      ]),
    );
    expect(audit.last['transition'], 'existing_fallback_selection');
    expect(audit.last['selectionSource'], 'existing_fallback');

    await _openReview(tester);
    expect(_reviewSupportCopySnapshot(tester), isNull);
    expect(
      find.text(
        'You missed that nobody has bet yet. This hand repeats that table clue.',
      ),
      findsNothing,
    );
    expect(
      find.text('Replay this spot to fix the no-bet-yet clue.'),
      findsNothing,
    );

    expect(_homeNextUsefulHandReasonLine(tester), isNull);
    await _pumpHomeWithReason(tester, null);
    expect(
      find.byKey(const Key('act0_shell_home_next_best_action_block')),
      findsOneWidget,
    );
    expect(find.text('Continue your first lesson'), findsOneWidget);
    expect(
      find.text('Sharky has your next useful hand ready.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_session_summary_ceremony_block')),
      findsNothing,
    );
    expect(find.text('Session proof'), findsNothing);
    expect(
      find.text(
        'You missed that nobody has bet yet. This hand repeats that table clue.',
      ),
      findsNothing,
    );
    expect(
      find.text('Replay this spot to fix the no-bet-yet clue.'),
      findsNothing,
    );
  });

  testWidgets('failed repair keeps resolver priority', (tester) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    await _launchReviewRepair(tester);
    await _advanceTeachingToDrill(tester);
    await _answerWrongly(tester);
    expect(
      find.text(
        'Still missed: nobody had bet yet. One more repair hand will help.',
      ),
      findsOneWidget,
    );
    expect(find.text('Still fragile: the no-bet-yet clue.'), findsOneWidget);
    expect(
      find.text('Next focus: one more no-bet-yet repair hand.'),
      findsOneWidget,
    );
    expect(
      find.text('Repair fixed: you caught the no-bet-yet clue.'),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    final target = _nextUsefulHandTargetPayload(tester);
    final bridge = _copyBridgePayload(tester);
    final audit = _repairIntentAuditTrailPayload(tester);
    final decision = _repairDecisionPayload(target);
    expect(target?['source'], 'repair_intent');
    expect(target?['selectionSource'], 'repair_intent_mapped');
    expect(target?['targetTaskId'], 'actions_check_drill');
    expect(target?['missedSignalId'], 'no_bet_yet');
    expect(target?['skillAtomId'], 'action_read');
    expect(target?['reasonCode'], 'same_signal_action_read_no_bet_yet');
    expect(decision?['actionType'], 'same_signal_repair');
    expect(decision?['priorityBand'], 'repair_first');
    expect(decision?['priorityScore'], 85);
    expect(decision?['decisionRule'], 'same_signal_repair_v1');
    expect(decision?['reasonCode'], 'same_signal_action_read_no_bet_yet');
    expect(bridge['lineKind'], 'missed_clue_repair_same_signal');
    expect(bridge['safeTemplateId'], 'repair_same_clue_v1');
    expect(bridge['selectionSource'], 'repair_intent_mapped');
    expect(bridge['reasonCode'], 'same_signal_action_read_no_bet_yet');
    expect(
      audit.map((entry) => entry['transition']),
      contains('failed_repair_retained'),
    );
    expect(audit.last['transition'], 'mapped_selection');
    expect(audit.last['selectionSource'], 'repair_intent_mapped');
    expect(audit.last['reasonCode'], 'same_signal_action_read_no_bet_yet');

    await _openReview(tester);
    final snapshot = _reviewSupportCopySnapshot(tester);
    expect(snapshot?['safeTemplateId'], 'repair_same_clue_v1');
    expect(snapshot?['selectionSource'], 'repair_intent_mapped');
    expect(
      snapshot?['renderedLine'],
      'You missed that nobody has bet yet. This hand repeats that table clue.',
    );
    expect(snapshot?['sourceTaskId'], 'actions_legal_context');
    expect(snapshot?['targetTaskId'], 'actions_check_drill');
    expect(snapshot?['reasonCode'], 'same_signal_action_read_no_bet_yet');
    expect(
      find.text(
        'You missed that nobody has bet yet. This hand repeats that table clue.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('unavailable mapped target falls back to exact replay target', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    final target = _nextUsefulHandTargetPayload(tester);
    final audit = _repairIntentAuditTrailPayload(tester);
    final bridge = _copyBridgePayload(tester);
    final decision = _repairDecisionPayload(target);

    expect(target?['source'], 'repair_intent');
    expect(target?['selectionSource'], 'repair_intent_exact_replay');
    expect(target?['sourceTaskId'], 'actions_legal_context');
    expect(target?['targetTaskId'], 'actions_legal_context');
    expect(target?['missedSignalId'], 'no_bet_yet');
    expect(target?['skillAtomId'], 'action_read');
    expect(target?['mappingType'], 'exact');
    expect(target?['reasonCode'], 'exact_replay_action_read_no_bet_yet');
    expect(decision?['recommendationSource'], 'repair_intent');
    expect(decision?['actionType'], 'exact_replay');
    expect(decision?['selectionSource'], 'repair_intent_exact_replay');
    expect(decision?['decisionRule'], 'exact_replay_fallback_v1');
    expect(decision?['priorityBand'], 'repair_next');
    expect(decision?['priorityScore'], 70);
    expect(decision?['sourceTaskId'], 'actions_legal_context');
    expect(decision?['targetTaskId'], 'actions_legal_context');
    expect(decision?['reasonCode'], 'exact_replay_action_read_no_bet_yet');
    expect(audit.length, 2);
    expect(audit.last['transition'], 'exact_replay_selection');
    expect(audit.last['selectionSource'], 'repair_intent_exact_replay');
    expect(audit.last['reasonCode'], 'exact_replay_action_read_no_bet_yet');
    expect(audit.last['mappingType'], 'exact');
    expect(bridge['lineKind'], 'exact_replay_repair');
    expect(bridge['safeTemplateId'], 'repair_exact_replay_v1');
    expect(bridge['sourceTaskId'], 'actions_legal_context');
    expect(bridge['targetTaskId'], 'actions_legal_context');
    expect(bridge['selectionSource'], 'repair_intent_exact_replay');
    expect(bridge['reasonCode'], 'exact_replay_action_read_no_bet_yet');
  });

  testWidgets('exact replay fixed receipt avoids same-signal claims', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    await _launchReviewRepair(tester);
    await _advanceTeachingToDrill(tester);
    await _answerCorrectly(tester);
    expect(
      find.text('Replay fixed: you handled this spot correctly.'),
      findsOneWidget,
    );
    expect(
      find.text('Replay fixed: you handled that spot correctly.'),
      findsOneWidget,
    );
    expect(find.textContaining('same clue'), findsNothing);
    expect(
      find.text('Repair fixed: you caught the no-bet-yet clue.'),
      findsNothing,
    );
  });

  testWidgets('exact replay repeated receipt avoids same-signal claims', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');
    await _launchReviewRepair(tester);
    await _advanceTeachingToDrill(tester);
    await _answerWrongly(tester);
    expect(
      find.text('Replay missed again: try the same spot once more.'),
      findsOneWidget,
    );
    expect(
      find.text('Replay still missed: try the spot once more.'),
      findsOneWidget,
    );
    expect(find.textContaining('same clue'), findsNothing);
    expect(
      find.text(
        'Still missed: nobody had bet yet. One more repair hand will help.',
      ),
      findsNothing,
    );
  });

  testWidgets('correct answer does not override existing recommendation', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'check');
    expect(
      find.byKey(const Key('act0_shell_session_repair_summary')),
      findsNothing,
    );
    expect(find.textContaining('Repair fixed:'), findsNothing);
    expect(find.textContaining('Still missed:'), findsNothing);
    expect(find.textContaining('Replay fixed:'), findsNothing);
    expect(find.textContaining('Replay missed again:'), findsNothing);

    final target = _nextUsefulHandTargetPayload(tester);
    final bridge = _copyBridgePayload(tester);

    expect(target?['source'], isNot('repair_intent'));
    expect(target?['selectionSource'], 'existing_fallback');
    expect(target?['sourceTaskId'], isNot('actions_legal_context'));
    expect(_repairDecisionPayload(target), isNull);
    expect(bridge['lineKind'], 'existing_fallback');
    expect(bridge['safeTemplateId'], 'fallback_next_hand_v1');
    expect(bridge['selectionSource'], 'existing_fallback');

    await _openReview(tester);
    expect(_reviewSupportCopySnapshot(tester), isNull);
    expect(
      find.text(
        'You missed that nobody has bet yet. This hand repeats that table clue.',
      ),
      findsNothing,
    );
    expect(
      find.text('Replay this spot to fix the no-bet-yet clue.'),
      findsNothing,
    );
  });

  testWidgets('rendered repair copy excludes forbidden terms and new surfaces', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    await _openReview(tester);

    final snapshot = _reviewSupportCopySnapshot(tester);
    final supportText = (snapshot?['renderedLine'] ?? '').toString();
    expect(
      supportText,
      'You missed that nobody has bet yet. This hand repeats that table clue.',
    );
    expect(snapshot?['renderedLine'], supportText);
    const forbidden = <String>{
      'ai',
      'ml',
      'adaptive',
      'solver',
      'gto',
      'optimal',
      'win-rate',
      'guaranteed',
      'premium',
      'paywall',
      'trial',
      'purchase',
      'restore',
    };
    for (final token in forbidden) {
      expect(_containsForbiddenTokenInText(supportText, token), isFalse);
      expect(
        _containsForbiddenTokenInText(
          (snapshot?['renderedLine'] ?? '').toString(),
          token,
        ),
        isFalse,
      );
    }
    expect(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            (key.value.contains('repair_intent_copy') ||
                key.value.contains('copy_bridge'));
      }),
      findsNothing,
    );
  });

  testWidgets('repair result receipt copy excludes forbidden terms', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    await _launchReviewRepair(tester);
    await _advanceTeachingToDrill(tester);
    await _answerCorrectly(tester);

    const receipt = 'Repair fixed: you caught the no-bet-yet clue.';
    const summary = 'Today you repaired the no-bet-yet clue.';
    expect(find.text(receipt), findsOneWidget);
    expect(find.text(summary), findsOneWidget);
    const forbidden = <String>{
      'ai',
      'adaptive',
      'gto',
      'solver',
      'optimal',
      'win-rate',
      'guarantee',
      'premium',
      'paywall',
      'trial',
      'unlock',
      'leak detected',
      'mastered forever',
    };
    for (final token in forbidden) {
      expect(_containsForbiddenTokenInText(receipt, token), isFalse);
      expect(_containsForbiddenTokenInText(summary, token), isFalse);
    }
  });

  testWidgets('resolver snapshot excludes forbidden AI and commerce fields', (
    tester,
  ) async {
    await _pumpResolverHost(
      tester,
      taskIds: const <String>['actions_legal_context', 'actions_check_drill'],
      taskId: 'actions_legal_context',
    );
    await _answerOption(tester, 'fold');

    final payload = _nextUsefulHandTargetPayload(tester)!;
    final audit = _repairIntentAuditTrailPayload(tester);
    final bridge = _copyBridgePayload(tester);
    final decision = _repairDecisionPayload(payload)!;
    const forbiddenKeys = <String>{
      'ai',
      'ml',
      'adaptive',
      'solver',
      'gto',
      'commerce',
      'trial',
      'paywall',
      'premium',
      'price',
      'purchase',
      'restore',
      'premiumHub',
      'optimal',
      'win-rate',
      'guaranteed',
    };
    for (final key in forbiddenKeys) {
      expect(payload.containsKey(key), isFalse, reason: key);
      expect(bridge.containsKey(key), isFalse, reason: key);
      expect(decision.containsKey(key), isFalse, reason: key);
      expect(_containsForbiddenToken(bridge, key), isFalse, reason: key);
      expect(_containsForbiddenToken(decision, key), isFalse, reason: key);
      for (final entry in audit) {
        expect(entry.containsKey(key), isFalse, reason: key);
      }
    }
  });
}

Future<void> _pumpResolverHost(
  WidgetTester tester, {
  required List<String> taskIds,
  required String taskId,
}) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.play,
        initialPhase: Act0LessonPhaseV1.drill,
        showPlacementOnStart: false,
        state: _stateForFoldCheckCallRaiseTasks(taskIds),
        debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
          mode: Act0ControlledDemoCaptureModeV1.directState,
          surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: taskId,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0ShellStateV1 _stateForFoldCheckCallRaiseTasks(List<String> taskIds) {
  final sample = Act0ShellStateV1.sample;
  final baseWorld = sample.worldById('world_1');
  final baseLesson = baseWorld.lessons.firstWhere(
    (lesson) => lesson.lessonId == 'fold_check_call_raise',
  );
  final tasks = <Act0LessonTaskV1>[
    for (final taskId in taskIds)
      baseLesson.taskList.firstWhere((task) => task.taskId == taskId),
  ];
  final lesson = baseLesson.copyWith(
    state: Act0LessonStateV1.current,
    isSelectable: true,
    isLocked: false,
    primaryCtaLabel: 'Open lesson',
    tasks: tasks,
  );
  final world = baseWorld.copyWith(
    status: Act0WorldStateV1.current,
    isSelectable: true,
    isLocked: false,
    lessons: <Act0LessonCardV1>[lesson],
  );

  return Act0ShellStateV1(
    courseTitle: sample.courseTitle,
    courseSubtitle: sample.courseSubtitle,
    levelLabel: sample.levelLabel,
    xp: sample.xp,
    xpTarget: sample.xpTarget,
    streakDays: sample.streakDays,
    dailyGoalLabel: sample.dailyGoalLabel,
    dailyGoalValue: sample.dailyGoalValue,
    pathProgressLabel: sample.pathProgressLabel,
    selectedWorldId: 'world_1',
    worlds: <Act0WorldCardV1>[world],
    lessons: <Act0LessonCardV1>[lesson],
    review: sample.review,
    profile: sample.profile,
  );
}

Future<void> _answerOption(WidgetTester tester, String optionId) async {
  final option = find.byKey(Key('act0_shell_option_$optionId'));
  expect(option, findsOneWidget);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> _advanceTeachingToDrill(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    if (_hasVisibleAnswer()) {
      return;
    }
    final selectedLessonCta = find.byKey(
      const Key('act0_shell_selected_lesson_cta'),
    );
    if (selectedLessonCta.evaluate().isNotEmpty) {
      await tester.ensureVisible(selectedLessonCta);
      await tester.tap(selectedLessonCta, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final luminousStartCta = find.byKey(
      const Key('act0_shell_start_luminous_cta_v6'),
    );
    if (luminousStartCta.evaluate().isNotEmpty) {
      await tester.ensureVisible(luminousStartCta);
      await tester.tap(luminousStartCta, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final currentMissionCta = find.byKey(
      const Key('act0_shell_current_mission_cta'),
    );
    if (currentMissionCta.evaluate().isNotEmpty) {
      await tester.ensureVisible(currentMissionCta);
      await tester.tap(currentMissionCta, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final featuredCta = find.byKey(const Key('act0_shell_play_featured_cta'));
    if (featuredCta.evaluate().isNotEmpty) {
      await tester.tap(featuredCta);
      await tester.pumpAndSettle();
      continue;
    }
    final dailyGroup = find.byKey(const Key('act0_shell_practice_group_daily'));
    if (dailyGroup.evaluate().isNotEmpty) {
      await tester.tap(dailyGroup);
      await tester.pumpAndSettle();
      continue;
    }
    final cta = find.byKey(const Key('act0_shell_runner_primary_cta'));
    if (cta.evaluate().isNotEmpty) {
      await tester.tap(cta);
      await tester.pumpAndSettle();
      continue;
    }
    final continueButton = find.byKey(const Key('act0_shell_continue_cta'));
    if (continueButton.evaluate().isNotEmpty) {
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      continue;
    }
    final continueCta = find.byKey(const Key('act0_shell_theory_continue_cta'));
    if (continueCta.evaluate().isNotEmpty) {
      await tester.tap(continueCta);
      await tester.pumpAndSettle();
      continue;
    }
    await tester.pumpAndSettle();
  }
  if (_hasVisibleAnswer()) {
    return;
  }
  fail('Runner did not reach a visible answer surface.');
}

bool _hasVisibleAnswer() {
  return find
          .byKey(const Key('act0_shell_action_panel'))
          .evaluate()
          .isNotEmpty ||
      find
          .byWidgetPredicate((widget) {
            final key = widget.key;
            return key is ValueKey<String> &&
                key.value.startsWith('act0_shell_option_');
          })
          .evaluate()
          .isNotEmpty;
}

Future<void> _answerCorrectly(WidgetTester tester) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.firstWhere((option) => option.isCorrect);
  await _answerOption(tester, option.id);
}

Future<void> _answerWrongly(WidgetTester tester) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.firstWhere(
    (option) => !option.isCorrect,
  );
  await _answerOption(tester, option.id);
}

Future<void> _launchReviewRepair(WidgetTester tester) async {
  await _openReview(tester);
  await tester.tap(find.byKey(const Key('act0_shell_review_fix_next_cta')));
  await tester.pumpAndSettle();
}

Future<void> _openReview(WidgetTester tester) async {
  final runnerBack = find.byKey(const Key('act0_shell_runner_back'));
  if (runnerBack.evaluate().isNotEmpty) {
    await tester.ensureVisible(runnerBack);
    await tester.tap(runnerBack, warnIfMissed: false);
    await tester.pumpAndSettle();
  }
  final reviewTab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('Review'),
  );
  await tester.ensureVisible(reviewTab);
  await tester.tap(reviewTab, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> _openPractice(WidgetTester tester) async {
  final runnerBack = find.byKey(const Key('act0_shell_runner_back'));
  if (runnerBack.evaluate().isNotEmpty) {
    await tester.ensureVisible(runnerBack);
    await tester.tap(runnerBack, warnIfMissed: false);
    await tester.pumpAndSettle();
  }
  final practiceTab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('Practice'),
  );
  await tester.ensureVisible(practiceTab);
  await tester.tap(practiceTab, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> _pumpHomeWithReason(
  WidgetTester tester,
  String? nextUsefulHandReasonLine,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0HomeShellV1(
        state: Act0ShellStateV1.sample,
        showChecklist: true,
        nextUsefulHandReasonLine: nextUsefulHandReasonLine,
        onContinue: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Map<String, Object?>? _nextUsefulHandTargetPayload(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugNextUsefulHandTargetPayloadV1() as Map<String, Object?>?;
}

String? _homeNextUsefulHandReasonLine(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugHomeNextUsefulHandReasonLineV1() as String?;
}

Map<String, Object?>? _repairDecisionPayload(Map<String, Object?>? target) {
  final raw = target?['repairDecision'];
  if (raw is! Map) {
    return null;
  }
  return raw.cast<String, Object?>();
}

Map<String, Object?> _copyBridgePayload(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugNextUsefulHandCopyBridgePayloadV1() as Map<String, Object?>;
}

Map<String, Object?>? _reviewSupportCopySnapshot(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugReviewSupportCopySnapshotV1() as Map<String, Object?>?;
}

List<Map<String, Object?>> _repairIntentAuditTrailPayload(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  final raw = state.debugRepairIntentAuditTrailPayloadV1() as List<Object?>;
  return raw.cast<Map<String, Object?>>();
}

bool _containsForbiddenToken(Map<String, Object?> payload, String token) {
  final values = payload.values.join(' ').toLowerCase();
  return _containsForbiddenTokenInText(values, token);
}

bool _containsForbiddenTokenInText(String text, String token) {
  final values = text.toLowerCase();
  final normalizedToken = token.toLowerCase();
  return values
      .split(RegExp(r'[^a-z0-9-]+'))
      .where((part) => part.isNotEmpty)
      .contains(normalizedToken);
}

const Set<String> _forbiddenVisibleReasonTokens = <String>{
  'ai',
  'ml',
  'adaptive',
  'solver',
  'gto',
  'optimal',
  'win-rate',
  'guaranteed',
  'premium',
  'paywall',
  'trial',
  'purchase',
  'restore',
  'unlock',
};
