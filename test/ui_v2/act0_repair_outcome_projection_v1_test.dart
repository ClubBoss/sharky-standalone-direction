import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

void main() {
  test('repair-launched correct answer creates repair correct outcome', () {
    final projection = const Act0RepairOutcomeProjectionV1().appendAnsweredTask(
      launchRequest: _launchRequest(),
      selectedChoiceId: 'check',
      correctChoiceId: 'check',
      isCorrect: true,
      sequence: 7,
    );

    expect(projection.outcomes, hasLength(1));
    final outcome = projection.outcomes.single;
    expect(outcome.sourceTaskId, 'actions_legal_context');
    expect(outcome.repairTaskId, 'actions_check_drill');
    expect(outcome.repairFocusKey, 'focus_key');
    expect(outcome.queueItemId, 'queue_item');
    expect(outcome.targetWorldId, 'world_1');
    expect(outcome.targetLessonId, 'fold_check_call_raise');
    expect(outcome.targetTaskId, 'actions_check_drill');
    expect(outcome.selectedChoiceId, 'check');
    expect(outcome.correctChoiceId, 'check');
    expect(outcome.isCorrect, isTrue);
    expect(outcome.outcomeState, act0RepairOutcomeStateCorrectV1);
    expect(outcome.sequence, 7);
    expect(outcome.sourceType, act0PracticeRepairQueueSourceActiveRepairV1);
  });

  test('repair-launched incorrect answer creates needs rep outcome', () {
    final projection = const Act0RepairOutcomeProjectionV1().appendAnsweredTask(
      launchRequest: _launchRequest(),
      selectedChoiceId: 'fold',
      correctChoiceId: 'check',
      isCorrect: false,
      sequence: 8,
    );

    expect(
      projection.outcomes.single.outcomeState,
      act0RepairOutcomeStateStillNeedsRepV1,
    );
    expect(projection.outcomes.single.isCorrect, isFalse);
  });

  test(
    'repair-launched answer without correctness creates attempted outcome',
    () {
      final projection = const Act0RepairOutcomeProjectionV1()
          .appendAnsweredTask(
            launchRequest: _launchRequest(),
            selectedChoiceId: 'fold',
            correctChoiceId: '',
            isCorrect: null,
            sequence: 9,
          );

      expect(
        projection.outcomes.single.outcomeState,
        act0RepairOutcomeStateAttemptedV1,
      );
      expect(projection.outcomes.single.isCorrect, isNull);
    },
  );

  test('normal task without repair source creates no outcome', () {
    final projection = const Act0RepairOutcomeProjectionV1().appendAnsweredTask(
      launchRequest: null,
      selectedChoiceId: 'check',
      correctChoiceId: 'check',
      isCorrect: true,
      sequence: 1,
    );

    expect(projection.outcomes, isEmpty);
  });

  test('history passive launch target creates no outcome', () {
    const request = Act0PracticeRepairQueueLaunchRequestV1(
      targetWorldId: 'world_1',
      targetLessonId: 'fold_check_call_raise',
      targetTaskId: 'actions_check_drill',
      targetType: act0PracticeRepairQueueTargetTypeNotLaunchableV1,
      sourceType: act0PracticeRepairQueueSourceReviewHistoryV1,
      sourceTaskId: 'actions_legal_context',
      repairTaskId: 'actions_check_drill',
      repairFocusKey: 'focus_key',
      queueItemId: 'queue_item',
    );

    final projection = const Act0RepairOutcomeProjectionV1().appendAnsweredTask(
      launchRequest: request,
      selectedChoiceId: 'check',
      correctChoiceId: 'check',
      isCorrect: true,
      sequence: 1,
    );

    expect(projection.outcomes, isEmpty);
  });

  test('ordering is deterministic by sequence', () {
    final projection = const Act0RepairOutcomeProjectionV1()
        .appendAnsweredTask(
          launchRequest: _launchRequest(queueItemId: 'second'),
          selectedChoiceId: 'fold',
          correctChoiceId: 'check',
          isCorrect: false,
          sequence: 2,
        )
        .appendAnsweredTask(
          launchRequest: _launchRequest(queueItemId: 'first'),
          selectedChoiceId: 'check',
          correctChoiceId: 'check',
          isCorrect: true,
          sequence: 1,
        );

    expect(projection.outcomes.map((outcome) => outcome.queueItemId), <String>[
      'first',
      'second',
    ]);
  });

  test('payload contains only safe outcome states', () {
    final projection = const Act0RepairOutcomeProjectionV1().appendAnsweredTask(
      launchRequest: _launchRequest(),
      selectedChoiceId: 'fold',
      correctChoiceId: 'check',
      isCorrect: false,
      sequence: 1,
    );
    final text = projection.toPayload().toString().toLowerCase();

    expect(text, contains(act0RepairOutcomeStateStillNeedsRepV1));
    for (final forbidden in <String>[
      'fixed_v1',
      'cleared_v1',
      'resolved_v1',
      'completed_v1',
      'mastered_v1',
      'leak',
      'ai',
      'gto',
      'solver',
      'premium',
      'paywall',
    ]) {
      expect(_containsForbiddenTokenInText(text, forbidden), isFalse);
    }
  });
}

Act0PracticeRepairQueueLaunchRequestV1 _launchRequest({
  String queueItemId = 'queue_item',
}) {
  return Act0PracticeRepairQueueLaunchRequestV1(
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
    sourceTaskId: 'actions_legal_context',
    repairTaskId: 'actions_check_drill',
    repairFocusKey: 'focus_key',
    queueItemId: queueItemId,
  );
}

bool _containsForbiddenTokenInText(String text, String token) {
  final pattern = RegExp(
    r'(^|[^a-z0-9])' + RegExp.escape(token) + r'([^a-z0-9]|$)',
  );
  return pattern.hasMatch(text.toLowerCase());
}
