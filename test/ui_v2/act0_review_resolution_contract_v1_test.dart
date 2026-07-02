import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('valid mistake with no repair is unresolved', () {
    final state = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
    );

    final item = state.resolutionForReviewItemId(_reviewItemId);

    expect(item, isNotNull);
    expect(item!.reviewState, act0ReviewResolutionStateUnresolvedV1);
    expect(item.resolutionReason, act0ReviewResolutionReasonNoRepairOutcomeV1);
    expect(item.isVisibleInActiveReview, isTrue);
    expect(item.conceptFamilyId, 'no_bet_yet');
    expect(item.sourceTaskId, 'actions_legal_context');
  });

  test('matching failed repair remains unresolved and actionable', () {
    final state = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_outcome(isCorrect: false)],
      ),
    );

    final item = state.resolutionForReviewItemId(_reviewItemId)!;

    expect(
      item.reviewState,
      act0ReviewResolutionStateRepairAttemptedNotResolvedV1,
    );
    expect(item.resolutionReason, act0ReviewResolutionReasonRepairFailedV1);
    expect(item.isVisibleInActiveReview, isTrue);
  });

  test('matching successful repair resolves the Review item', () {
    final state = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_outcome(isCorrect: true)],
      ),
    );

    final item = state.resolutionForReviewItemId(_reviewItemId)!;

    expect(item.reviewState, act0ReviewResolutionStateResolvedV1);
    expect(item.resolutionReason, act0ReviewResolutionReasonRepairSucceededV1);
    expect(item.repairOutcomeId, 'repair_outcome_v1|3|$_queueItemId');
    expect(item.resolvedAtOrder, 3);
    expect(item.isVisibleInActiveReview, isFalse);
  });

  test('unrelated success does not resolve the Review item', () {
    final state = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _outcome(queueItemId: 'practice_repair_queue_v1|active|other'),
        ],
      ),
    );

    expect(
      state.resolutionForReviewItemId(_reviewItemId)!.reviewState,
      act0ReviewResolutionStateUnresolvedV1,
    );
  });

  test('same-family but different exact identity does not over-resolve', () {
    final history = _history(
      taskId: 'actions_second_context',
      sourceTaskId: 'actions_second_context',
    );
    final state = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: history,
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_outcome(isCorrect: true)],
      ),
    );

    expect(state.resolutions.single.conceptFamilyId, 'no_bet_yet');
    expect(
      state.resolutions.single.reviewState,
      act0ReviewResolutionStateUnresolvedV1,
    );
  });

  test('repeated success is idempotent', () {
    final first = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _outcome(isCorrect: true, sequence: 4),
          _outcome(isCorrect: true, sequence: 5),
        ],
      ),
    );
    final second = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[
          _outcome(isCorrect: true, sequence: 5),
          _outcome(isCorrect: true, sequence: 4),
        ],
      ),
    );

    expect(first.resolutions, hasLength(1));
    expect(second.toPayload(), first.toPayload());
    expect(first.resolutions.single.resolvedAtOrder, 4);
  });

  test('malformed and missing-target evidence fail closed', () {
    final parsed = Act0ReviewMistakeRecordV1.tryParse(<String, Object?>{
      'schemaVersion': 1,
      'recordId': '',
      'sourceDecisionId': 'attempt',
      'createdOrder': 1,
      'updatedOrder': 1,
      'worldId': 'world_1',
      'lessonId': 'fold_check_call_raise',
      'decisionTaskId': 'actions_legal_context',
      'sourceTaskId': 'actions_legal_context',
      'decisionKind': 'actionList',
      'selectedId': 'fold',
      'expectedId': 'check',
      'resultKind': 'incorrect',
      'attemptRecordIds': <String>['attempt'],
      'dedupUsesFallback': false,
      'state': act0ReviewMistakeStateUnresolvedOnlyV1,
    });
    final targetless = _history(
      repairFocusId: '',
      missedSignalId: '',
      skillAtomId: '',
      errorType: '',
    );

    final state = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: targetless,
    );

    expect(parsed, isNull);
    expect(
      state.resolutions.single.reviewState,
      isIn(<String>[
        act0ReviewResolutionStateNotActionableV1,
        act0ReviewResolutionStateInsufficientEvidenceV1,
      ]),
    );
    expect(state.visibleReviewItemIds, isEmpty);
  });

  test('persisted receipt keeps resolved item resolved after reload', () {
    final live = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_outcome(isCorrect: true)],
      ),
    );
    final receiptHistory = const Act0ReviewResolutionReceiptHistoryV1()
        .appendFromResolution(live.resolutions.single);

    final reloaded = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
      receiptHistory: Act0ReviewResolutionReceiptHistoryV1.tryParse(
        receiptHistory.toPayload(),
      ),
    );

    expect(
      reloaded.resolutionForReviewItemId(_reviewItemId)!.reviewState,
      act0ReviewResolutionStateResolvedV1,
    );
    expect(reloaded.visibleReviewItemIds, isEmpty);
  });

  test('old state loads safely and rendering derivation does not mutate', () {
    final parsed = Act0ReviewResolutionReceiptHistoryV1.tryParse(<Object?>[
      <String, Object?>{
        'schemaVersion': 0,
        'reviewItemId': 'old',
        'reviewState': act0ReviewResolutionStateResolvedV1,
      },
      <String, Object?>{
        'schemaVersion': 1,
        'reviewItemId': _reviewItemId,
        'learningEvidenceId': 'attempt',
        'repairIntentId': _activeRepairIntent.reasonCode,
        'conceptFamilyId': 'no_bet_yet',
        'sourceTaskId': 'actions_legal_context',
        'reviewState': act0ReviewResolutionStateResolvedV1,
        'resolutionReason': act0ReviewResolutionReasonRepairSucceededV1,
        'repairOutcomeId': 'repair_outcome_v1|3|$_queueItemId',
        'resolvedAtOrder': 3,
      },
    ]);
    final first = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
      receiptHistory: parsed,
    );
    final second = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
      receiptHistory: parsed,
    );

    expect(parsed.receipts, hasLength(1));
    expect(second.toPayload(), first.toPayload());
  });

  test('Review and Practice resolution agree for matching identity', () {
    final queueState = Act0QueueResolutionStateV1.fromSources(
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_outcome(isCorrect: true)],
      ),
    );
    final reviewState = Act0ReviewResolutionStateV1.fromSources(
      reviewMistakeHistory: _history(),
      activeRepairIntents: const <Act0RepairIntentV1>[_activeRepairIntent],
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: <Act0RepairOutcomeV1>[_outcome(isCorrect: true)],
      ),
    );

    expect(
      queueState.resolutionForQueueItemId(_queueItemId)!.resolutionState,
      act0QueueResolutionStateResolvedV1,
    );
    expect(
      reviewState.resolutionForReviewItemId(_reviewItemId)!.reviewState,
      act0ReviewResolutionStateResolvedV1,
    );
    expect(reviewState.visibleReviewItemIds, isEmpty);
  });

  test(
    'source contains no UI telemetry ranking or broad persistence owner',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('package:flutter/')));
      expect(source, isNot(contains('Telemetry')));
      expect(source, isNot(contains('score')));
      expect(source, isNot(contains('mastery')));
      expect(source, isNot(contains('XP')));
    },
  );
}

const String _reviewItemId =
    'review_mistake_v1|21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read';
const String _queueItemId =
    'practice_repair_queue_v1|active|75:21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read';

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

Act0ReviewMistakeHistoryV1 _history({
  String taskId = 'actions_legal_context',
  String sourceTaskId = 'actions_legal_context',
  String selectedId = 'fold',
  String expectedId = 'check',
  String errorType = 'missed_action_read',
  String skillAtomId = 'action_read',
  String repairFocusId = 'no_bet_yet',
  String missedSignalId = 'no_bet_yet',
}) {
  return const Act0ReviewMistakeHistoryV1().appendCompletedDecision(
    Act0CompletedDecisionV1(
      attemptKey:
          'v1|world_1|fold_check_call_raise|$taskId|actionList|$selectedId|1',
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
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
      missedSignalId: missedSignalId,
    ),
  );
}

Act0RepairOutcomeV1 _outcome({
  String queueItemId = _queueItemId,
  bool? isCorrect = true,
  int sequence = 3,
}) {
  return Act0RepairOutcomeV1(
    sourceTaskId: 'actions_legal_context',
    repairTaskId: 'actions_check_drill',
    repairFocusKey:
        '21:actions_legal_context|10:no_bet_yet|11:action_read|18:missed_action_read',
    queueItemId: queueItemId,
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    selectedChoiceId: isCorrect == true ? 'check' : 'fold',
    correctChoiceId: 'check',
    isCorrect: isCorrect,
    outcomeState: isCorrect == true
        ? act0RepairOutcomeStateCorrectV1
        : act0RepairOutcomeStateStillNeedsRepV1,
    sequence: sequence,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
  );
}
