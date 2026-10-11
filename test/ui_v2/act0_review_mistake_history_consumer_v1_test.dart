import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_pattern_coaching_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('consumer reads unresolved history records newest first', () {
    final history = const Act0ReviewMistakeHistoryV1()
        .appendCompletedDecision(
          _decision(
            attempt: 1,
            sourceTaskId: 'actions_legal_context',
            selectedId: 'fold',
            expectedId: 'check',
          ),
        )
        .appendCompletedDecision(
          _decision(
            attempt: 2,
            sourceTaskId: 'actions_raise_drill',
            selectedId: 'call',
            expectedId: 'raise',
            errorType: 'missed_raise_spot',
            skillAtomId: 'initiative_read',
            repairFocusId: 'open_pot',
          ),
        );

    final model = Act0ReviewMistakeHistoryConsumerV1.fromHistory(history);

    expect(model.items, hasLength(2));
    expect(model.items.first.sourceTaskId, 'actions_raise_drill');
    expect(model.items.first.primaryLabel, 'Initiative read');
    expect(model.items.first.decisionLine, 'You chose call; better was raise.');
    expect(model.items.first.contextLine, 'fold check call raise');
    expect(model.items.first.orderLabel, 'Most recent');
  });

  test('Review F09 renders exact source-owned W1 option meaning, not IDs', () {
    final history = const Act0ReviewMistakeHistoryV1().appendCompletedDecision(
      _decision(
        attempt: 1,
        lessonId: 'what_poker_is',
        taskId: 'what_poker_is_table_read_transfer',
        sourceTaskId: 'what_poker_is_table_read_transfer',
        selectedId: 'five_board_now',
        expectedId: 'two_three_six',
      ),
    );
    final source = Act0ShellStateV1.sample;
    final english = Act0ReviewMistakeHistoryConsumerV1.fromHistory(
      history,
      sourceState: source,
    );
    expect(
      english.items.single.decisionLine,
      'You chose 5 board cards are already out; better was '
      '2 private cards, 3 board cards, 6 BB in the pot.',
    );
    final russian = Act0ReviewMistakeHistoryConsumerV1.fromHistory(
      history,
      sourceState: source,
      localeIsRu: true,
      localizeOptionLabel: (label) => 'RU:$label',
    );
    expect(russian.items.single.decisionLine, contains('RU:5 board cards'));
    expect(russian.items.single.decisionLine, contains('RU:2 private cards'));
    expect(
      russian.items.single.decisionLine,
      startsWith('\u0412\u0430\u0448 \u0432\u044B\u0431\u043E\u0440:'),
    );
    final ruFallback = Act0ReviewMistakeHistoryConsumerV1.fromHistory(
      history,
      sourceState: source,
      localeIsRu: true,
      localizeOptionLabel: (label) => label,
    );
    expect(
      ruFallback.items.single.decisionLine,
      '\u0412\u0430\u0448 \u0432\u044B\u0431\u043E\u0440: \u0423\u0436\u0435 \u043E\u0442\u043A\u0440\u044B\u0442\u043E 5 \u043E\u0431\u0449\u0438\u0445 \u043A\u0430\u0440\u0442; \u043B\u0443\u0447\u0448\u0435: '
      '2 \u0437\u0430\u043A\u0440\u044B\u0442\u044B\u0435 \u043A\u0430\u0440\u0442\u044B, 3 \u043E\u0431\u0449\u0438\u0435 \u043A\u0430\u0440\u0442\u044B, \u0431\u0430\u043D\u043A 6 BB.',
    );
    expect(history.records.single.selectedId, 'five_board_now');
    expect(history.records.single.expectedId, 'two_three_six');
  });

  test('Review F09 never invents semantics for unknown source option IDs', () {
    final history = const Act0ReviewMistakeHistoryV1().appendCompletedDecision(
      _decision(
        attempt: 2,
        selectedId: 'unmapped_choice_982',
        expectedId: 'unmapped_correct_982',
      ),
    );
    final text = Act0ReviewMistakeHistoryConsumerV1.fromHistory(
      history,
      sourceState: Act0ShellStateV1.sample,
    ).items.single.decisionLine;
    expect(text, 'You chose that option; better was that option.');
    expect(text, isNot(contains('982')));
  });

  test('consumer filters active repair source without mutating history', () {
    final history = const Act0ReviewMistakeHistoryV1()
        .appendCompletedDecision(
          _decision(attempt: 1, sourceTaskId: 'actions_legal_context'),
        )
        .appendCompletedDecision(
          _decision(attempt: 2, sourceTaskId: 'actions_raise_drill'),
        );

    final model = Act0ReviewMistakeHistoryConsumerV1.fromHistory(
      history,
      activeRepairSourceTaskIds: const <String>{'actions_raise_drill'},
    );

    expect(model.items, hasLength(1));
    expect(model.items.single.sourceTaskId, 'actions_legal_context');
    expect(history.records, hasLength(2));
  });

  test('consumer filters resolved review items and keeps failed repairs', () {
    final history = const Act0ReviewMistakeHistoryV1()
        .appendCompletedDecision(_decision(attempt: 1))
        .appendCompletedDecision(
          _decision(
            attempt: 2,
            sourceTaskId: 'actions_raise_drill',
            taskId: 'actions_raise_drill',
            errorType: 'missed_raise_spot',
            skillAtomId: 'initiative_read',
            repairFocusId: 'open_pot',
          ),
        );
    final resolutionState = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: history,
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_successfulOutcome],
      ),
    );

    final model = Act0ReviewMistakeHistoryConsumerV1.fromHistory(
      history,
      reviewResolutionState: resolutionState,
    );

    expect(model.items, hasLength(1));
    expect(model.items.single.sourceTaskId, 'actions_raise_drill');
    expect(history.records, hasLength(2));
  });

  test('consumer keeps failed repair visible under unresolved-only policy', () {
    final history = const Act0ReviewMistakeHistoryV1().appendCompletedDecision(
      _decision(attempt: 1),
    );
    final resolutionState = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: history,
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _successfulOutcome.copyWithForTest(isCorrect: false),
        ],
      ),
    );

    final model = Act0ReviewMistakeHistoryConsumerV1.fromHistory(
      history,
      reviewResolutionState: resolutionState,
    );

    expect(model.items, hasLength(1));
    expect(model.items.single.sourceTaskId, 'actions_legal_context');
  });

  test('consumer attaches one matching pattern line to read-only history', () {
    final history = const Act0ReviewMistakeHistoryV1()
        .appendCompletedDecision(_decision(attempt: 1))
        .appendCompletedDecision(_decision(attempt: 2));
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _learningRecord(order: 1, sessionId: 'session_a'),
          _learningRecord(order: 2, sessionId: 'session_b'),
        ],
      ),
    );

    final model = Act0ReviewMistakeHistoryConsumerV1.fromHistory(
      history,
      patternCoachingProjection: projection,
    );

    expect(model.items, hasLength(1));
    expect(
      model.items.single.patternLine,
      'This table-reading mistake showed up in more than one session.',
    );
  });

  test('consumer does not attach pattern line to unrelated family', () {
    final history = const Act0ReviewMistakeHistoryV1().appendCompletedDecision(
      _decision(attempt: 1),
    );
    final projection = Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _learningRecord(
            order: 1,
            conceptFamilyId: 'open_pot',
            sessionId: 'session_a',
          ),
          _learningRecord(
            order: 2,
            conceptFamilyId: 'open_pot',
            sessionId: 'session_b',
          ),
        ],
      ),
    );

    final model = Act0ReviewMistakeHistoryConsumerV1.fromHistory(
      history,
      patternCoachingProjection: projection,
    );

    expect(model.items.single.patternLine, isNull);
  });

  test('consumer emits no forbidden action or capability claims', () {
    final history = const Act0ReviewMistakeHistoryV1().appendCompletedDecision(
      _decision(attempt: 1),
    );

    final model = Act0ReviewMistakeHistoryConsumerV1.fromHistory(history);
    final text = model.items
        .expand(
          (item) => <String>[
            item.primaryLabel,
            item.detailLine,
            item.decisionLine,
            item.contextLine,
            item.orderLabel,
            item.patternLine ?? '',
          ],
        )
        .join(' ');

    expect(text, isNot(contains('clear')));
    expect(text, isNot(contains('fix')));
    expect(text, isNot(contains('resolved')));
    expect(text, isNot(contains('mastery')));
    expect(text, isNot(contains('leak')));
    expect(text, isNot(contains('AI')));
    expect(text, isNot(contains('GTO')));
    expect(text, isNot(contains('solver')));
  });
}

Act0LearningEvidenceRecordV1 _learningRecord({
  required int order,
  required String sessionId,
  String conceptFamilyId = 'no_bet_yet',
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: 'learning_$order',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    choiceId: 'fold',
    expectedChoiceId: 'check',
    isCorrect: false,
    errorType: 'missed_action_read',
    conceptFamilyId: conceptFamilyId,
    repairFocusId: conceptFamilyId,
    skillAtomId: 'action_read',
    decisionTimeBucket: 'under_3s',
    resultKind: 'incorrect',
    sessionId: sessionId,
  );
}

const Act0RepairIntentV1 _activeRepairIntent = Act0RepairIntentV1(
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
  targetTaskId: 'actions_check_drill',
  mappingType: 'repair',
  reasonCode: 'same_signal_action_read_no_bet_yet',
);

const Act0RepairOutcomeV1 _successfulOutcome = Act0RepairOutcomeV1(
  sourceTaskId: 'actions_legal_context',
  repairTaskId: 'actions_check_drill',
  repairFocusKey:
      '21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read',
  queueItemId:
      'practice_repair_queue_v1|active|75:21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read',
  targetWorldId: 'world_1',
  targetLessonId: 'fold_check_call_raise',
  targetTaskId: 'actions_check_drill',
  selectedChoiceId: 'check',
  correctChoiceId: 'check',
  isCorrect: true,
  outcomeState: act0RepairOutcomeStateCorrectV1,
  sequence: 3,
  sourceType: 'active_repair_v1',
);

extension on Act0RepairOutcomeV1 {
  Act0RepairOutcomeV1 copyWithForTest({required bool isCorrect}) {
    return Act0RepairOutcomeV1(
      sourceTaskId: sourceTaskId,
      repairTaskId: repairTaskId,
      repairFocusKey: repairFocusKey,
      queueItemId: queueItemId,
      targetWorldId: targetWorldId,
      targetLessonId: targetLessonId,
      targetTaskId: targetTaskId,
      selectedChoiceId: isCorrect ? correctChoiceId : 'fold',
      correctChoiceId: correctChoiceId,
      isCorrect: isCorrect,
      outcomeState: isCorrect
          ? act0RepairOutcomeStateCorrectV1
          : act0RepairOutcomeStateStillNeedsRepV1,
      sequence: sequence,
      sourceType: sourceType,
      sessionId: sessionId,
    );
  }
}

Act0CompletedDecisionV1 _decision({
  required int attempt,
  String taskId = 'actions_legal_context',
  String sourceTaskId = 'actions_legal_context',
  String lessonId = 'fold_check_call_raise',
  String selectedId = 'fold',
  String expectedId = 'check',
  String errorType = 'missed_action_read',
  String skillAtomId = 'action_read',
  String repairFocusId = 'no_bet_yet',
}) {
  return Act0CompletedDecisionV1(
    attemptKey: 'v1|world_1|$lessonId|$taskId|actionList|$selectedId|$attempt',
    worldId: 'world_1',
    lessonId: lessonId,
    taskId: taskId,
    sourceTaskId: sourceTaskId,
    decisionKind: Act0CompletedDecisionKindV1.actionList,
    selectedId: selectedId,
    expectedId: expectedId,
    isCorrect: false,
    decisionTimeBucket: 'under_3s',
    taskFamily: Act0TaskFamilyV1.decision,
    resultKind: 'incorrect',
    errorType: errorType,
    skillAtomId: skillAtomId,
    repairFocusId: repairFocusId,
    missedSignalId: repairFocusId,
  );
}
