import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_rule_based_repair_personalization_v1.dart';

void main() {
  test('mapped repair intent creates deterministic same-signal decision', () {
    final decision = buildAct0RuleBasedRepairDecisionV1(
      openRepairIntent: _mappedIntent(),
      isOpen: true,
      repeatedMissCount: 1,
    );

    expect(decision, isNotNull);
    expect(decision?.schemaVersion, 1);
    expect(decision?.recommendationSource, 'repair_intent');
    expect(decision?.actionType, 'same_signal_repair');
    expect(decision?.selectionSource, 'repair_intent_mapped');
    expect(decision?.decisionRule, 'same_signal_repair_v1');
    expect(decision?.priorityBand, 'repair_next');
    expect(decision?.priorityScore, 80);
    expect(decision?.sourceTaskId, 'actions_legal_context');
    expect(decision?.choiceId, 'fold');
    expect(decision?.result, 'incorrect');
    expect(decision?.errorType, 'missed_action_read');
    expect(decision?.missedSignalId, 'no_bet_yet');
    expect(decision?.skillAtomId, 'action_read');
    expect(decision?.targetTaskId, 'actions_check_drill');
    expect(decision?.mappingType, 'repair');
    expect(decision?.reasonCode, 'same_signal_action_read_no_bet_yet');
  });

  test('same input creates same decision payload', () {
    final intent = _mappedIntent();

    final first = buildAct0RuleBasedRepairDecisionV1(
      openRepairIntent: intent,
      isOpen: true,
      repeatedMissCount: 2,
    );
    final second = buildAct0RuleBasedRepairDecisionV1(
      openRepairIntent: intent,
      isOpen: true,
      repeatedMissCount: 2,
    );

    expect(first?.toPayload(), second?.toPayload());
    expect(first?.priorityScore, 85);
    expect(first?.priorityBand, 'repair_first');
  });

  test('exact replay fallback remains deterministic', () {
    final decision = buildAct0RuleBasedRepairDecisionV1(
      openRepairIntent: _exactIntent(),
      isOpen: true,
      repeatedMissCount: 1,
    );

    expect(decision, isNotNull);
    expect(decision?.actionType, 'exact_replay');
    expect(decision?.selectionSource, 'repair_intent_exact_replay');
    expect(decision?.decisionRule, 'exact_replay_fallback_v1');
    expect(decision?.priorityBand, 'repair_next');
    expect(decision?.priorityScore, 70);
    expect(decision?.sourceTaskId, 'actions_legal_context');
    expect(decision?.targetTaskId, 'actions_legal_context');
    expect(decision?.mappingType, 'exact');
    expect(decision?.reasonCode, 'exact_replay_action_read_no_bet_yet');
  });

  test('closed, missing, or correct intent creates no open decision', () {
    expect(
      buildAct0RuleBasedRepairDecisionV1(openRepairIntent: null, isOpen: true),
      isNull,
    );
    expect(
      buildAct0RuleBasedRepairDecisionV1(
        openRepairIntent: _mappedIntent(),
        isOpen: false,
      ),
      isNull,
    );
    expect(
      buildAct0RuleBasedRepairDecisionV1(
        openRepairIntent: _mappedIntent(result: 'correct'),
        isOpen: true,
      ),
      isNull,
    );
  });

  test('payload excludes forbidden AI and commerce fields', () {
    final decision = buildAct0RuleBasedRepairDecisionV1(
      openRepairIntent: _mappedIntent(),
      isOpen: true,
      repeatedMissCount: 2,
    );
    final payload = decision!.toPayload();
    const forbiddenTokens = <String>{
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
    };

    for (final entry in payload.entries) {
      for (final token in forbiddenTokens) {
        expect(_containsToken(entry.key, token), isFalse, reason: entry.key);
        expect(
          _containsToken('${entry.value}', token),
          isFalse,
          reason: '${entry.key}: ${entry.value}',
        );
      }
    }
  });
}

Act0RepairIntentV1 _mappedIntent({String result = 'incorrect'}) {
  return Act0RepairIntentV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'fold_check_call_raise',
    sourceTaskId: 'actions_legal_context',
    choiceId: 'fold',
    result: result,
    errorType: result == 'suboptimal'
        ? 'thin_action_read'
        : 'missed_action_read',
    missedSignalId: 'no_bet_yet',
    missedSignalLabel: 'No bet yet',
    skillAtomId: 'action_read',
    skillLabel: 'Action read',
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    mappingType: 'repair',
    reasonCode: 'same_signal_action_read_no_bet_yet',
  );
}

Act0RepairIntentV1 _exactIntent() {
  return const Act0RepairIntentV1(
    sourceWorldId: 'world_1',
    sourceLessonId: 'fold_check_call_raise',
    sourceTaskId: 'actions_legal_context',
    choiceId: 'fold',
    result: 'incorrect',
    errorType: 'missed_action_read',
    missedSignalId: 'no_bet_yet',
    missedSignalLabel: 'No bet yet',
    skillAtomId: 'action_read',
    skillLabel: 'Action read',
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_legal_context',
    mappingType: 'exact',
    reasonCode: 'exact_replay_action_read_no_bet_yet',
  );
}

bool _containsToken(String text, String token) {
  final normalizedToken = token.toLowerCase();
  return text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9-]+'))
      .where((part) => part.isNotEmpty)
      .contains(normalizedToken);
}
