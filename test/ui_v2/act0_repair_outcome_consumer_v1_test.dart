import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

void main() {
  test('empty projection produces no local proof', () {
    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(
      const Act0RepairOutcomeProjectionV1(),
    );

    expect(consumer.proof, isNull);
    expect(consumer.hasProof, isFalse);
    expect(consumer.sessionReceipt, isNull);
    expect(consumer.hasSessionReceipt, isFalse);
  });

  test('correct outcome maps to safe local proof', () {
    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(
      _projection(isCorrect: true, selectedChoiceId: 'check'),
    );

    expect(consumer.hasProof, isTrue);
    expect(consumer.proof?.title, 'Fix landed');
    expect(consumer.proof?.detail, 'Nice repair. Same spot, cleaner decision.');
    expect(consumer.proof?.outcomeState, act0RepairOutcomeStateCorrectV1);
  });

  test('incorrect outcome maps to safe repeat proof', () {
    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(
      _projection(isCorrect: false, selectedChoiceId: 'fold'),
    );

    expect(consumer.proof?.title, 'Fix attempt');
    expect(consumer.proof?.detail, 'Not landed yet. One more rep.');
    expect(consumer.proof?.outcomeState, act0RepairOutcomeStateStillNeedsRepV1);
  });

  test('attempted outcome maps to safe attempted proof', () {
    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(
      _projection(isCorrect: null, selectedChoiceId: 'fold'),
    );

    expect(consumer.proof?.title, 'Fix attempt');
    expect(consumer.proof?.detail, 'You gave the repair a try.');
    expect(consumer.proof?.outcomeState, act0RepairOutcomeStateAttemptedV1);
  });

  test('consumer uses latest deterministic outcome only', () {
    final projection =
        _projection(
          isCorrect: false,
          selectedChoiceId: 'fold',
          sequence: 1,
        ).appendAnsweredTask(
          launchRequest: _launchRequest(),
          selectedChoiceId: 'check',
          correctChoiceId: 'check',
          isCorrect: true,
          sequence: 2,
        );

    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(projection);

    expect(consumer.proof?.detail, 'Nice repair. Same spot, cleaner decision.');
    expect(consumer.proof?.sequence, 2);
  });

  test('correct outcomes summarize as good repair reps', () {
    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(
      _projection(isCorrect: true, selectedChoiceId: 'check'),
    );

    expect(consumer.hasSessionReceipt, isTrue);
    expect(consumer.sessionReceipt?.title, "Fixes you've banked");
    expect(consumer.sessionReceipt?.lines, <String>['Good fixes: 1']);
  });

  test('incorrect outcomes summarize as worth repeating', () {
    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(
      _projection(isCorrect: false, selectedChoiceId: 'fold'),
    );

    expect(consumer.sessionReceipt?.title, "Fixes you've banked");
    expect(consumer.sessionReceipt?.lines, <String>['Still to fix: 1']);
  });

  test('attempted-only outcomes summarize as attempted reps', () {
    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(
      _projection(isCorrect: null, selectedChoiceId: 'fold'),
    );

    expect(consumer.sessionReceipt?.title, "Fixes you've banked");
    expect(consumer.sessionReceipt?.lines, <String>['Fixes tried: 1']);
  });

  test('multiple outcomes summarize deterministically', () {
    final projection = const Act0RepairOutcomeProjectionV1(
      outcomes: <Act0RepairOutcomeV1>[
        Act0RepairOutcomeV1(
          sourceTaskId: 'source_a',
          repairTaskId: 'repair_a',
          repairFocusKey: 'focus_a',
          queueItemId: 'queue_a',
          targetWorldId: 'world_1',
          targetLessonId: 'fold_check_call_raise',
          targetTaskId: 'repair_a',
          selectedChoiceId: 'fold',
          correctChoiceId: 'check',
          isCorrect: false,
          outcomeState: act0RepairOutcomeStateStillNeedsRepV1,
          sequence: 3,
          sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
        ),
        Act0RepairOutcomeV1(
          sourceTaskId: 'source_b',
          repairTaskId: 'repair_b',
          repairFocusKey: 'focus_b',
          queueItemId: 'queue_b',
          targetWorldId: 'world_1',
          targetLessonId: 'fold_check_call_raise',
          targetTaskId: 'repair_b',
          selectedChoiceId: 'check',
          correctChoiceId: 'check',
          isCorrect: true,
          outcomeState: act0RepairOutcomeStateCorrectV1,
          sequence: 1,
          sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
        ),
        Act0RepairOutcomeV1(
          sourceTaskId: 'source_c',
          repairTaskId: 'repair_c',
          repairFocusKey: 'focus_c',
          queueItemId: 'queue_c',
          targetWorldId: 'world_1',
          targetLessonId: 'fold_check_call_raise',
          targetTaskId: 'repair_c',
          selectedChoiceId: 'check',
          correctChoiceId: 'check',
          isCorrect: true,
          outcomeState: act0RepairOutcomeStateCorrectV1,
          sequence: 2,
          sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
        ),
      ],
    );

    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(projection);

    expect(consumer.sessionReceipt?.lines, <String>[
      'Good fixes: 2',
      'Still to fix: 1',
    ]);
  });

  test('consumer copy avoids old repair-loop plumbing labels', () {
    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(
      _projection(isCorrect: true, selectedChoiceId: 'check'),
    );
    final attempted = Act0RepairOutcomeConsumerV1.fromProjection(
      _projection(isCorrect: null, selectedChoiceId: 'fold'),
    );
    final stillNeedsRep = Act0RepairOutcomeConsumerV1.fromProjection(
      _projection(isCorrect: false, selectedChoiceId: 'fold'),
    );
    final text = <String>[
      consumer.proof?.title ?? '',
      consumer.proof?.detail ?? '',
      attempted.proof?.detail ?? '',
      stillNeedsRep.proof?.detail ?? '',
      consumer.sessionReceipt?.title ?? '',
      ...?consumer.sessionReceipt?.lines,
      ...?attempted.sessionReceipt?.lines,
      ...?stillNeedsRep.sessionReceipt?.lines,
    ].join(' ');

    for (final oldCopy in <String>[
      'Repair rep',
      'rep attempted',
      'Good rep',
      'Still worth repeating',
      'Repair reps',
      'Good reps',
      'Worth repeating',
      'Attempted reps',
    ]) {
      expect(text, isNot(contains(oldCopy)));
    }
  });

  test('proof copy avoids forbidden claim families', () {
    for (final state in <String>[
      act0RepairOutcomeStateCorrectV1,
      act0RepairOutcomeStateStillNeedsRepV1,
      act0RepairOutcomeStateAttemptedV1,
    ]) {
      final proof = Act0RepairOutcomeConsumerV1.fromProjection(
        Act0RepairOutcomeProjectionV1(
          outcomes: <Act0RepairOutcomeV1>[_outcome(outcomeState: state)],
        ),
      ).proof!;
      final text = '${proof.title} ${proof.detail}'.toLowerCase();
      final receiptText = Act0RepairOutcomeConsumerV1.fromProjection(
        Act0RepairOutcomeProjectionV1(
          outcomes: <Act0RepairOutcomeV1>[_outcome(outcomeState: state)],
        ),
      ).sessionReceipt!.lines.join(' ').toLowerCase();
      for (final forbidden in <String>[
        'cleared',
        'resolved',
        'fixed forever',
        'completed',
        'mastered',
        'leak',
        'all-time',
        'rating',
        'radar',
        'level',
        'ai',
        'gto',
        'solver',
        'premium',
        'paywall',
        'guaranteed',
        'improvement',
      ]) {
        expect(_containsForbiddenTokenInText(text, forbidden), isFalse);
        expect(_containsForbiddenTokenInText(receiptText, forbidden), isFalse);
      }
    }
  });

  test('consumer reads only repair outcome projection source', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart',
    ).readAsStringSync();

    expect(source, contains('act0_repair_outcome_projection_v1.dart'));
    expect(source, isNot(contains('act0_practice_repair_queue')));
    expect(source, isNot(contains('act0_review_mistake_history')));
    expect(source, isNot(contains('telemetry')));
  });
}

Act0RepairOutcomeProjectionV1 _projection({
  required bool? isCorrect,
  required String selectedChoiceId,
  int sequence = 1,
}) {
  return const Act0RepairOutcomeProjectionV1().appendAnsweredTask(
    launchRequest: _launchRequest(),
    selectedChoiceId: selectedChoiceId,
    correctChoiceId: 'check',
    isCorrect: isCorrect,
    sequence: sequence,
  );
}

Act0PracticeRepairQueueLaunchRequestV1 _launchRequest() {
  return const Act0PracticeRepairQueueLaunchRequestV1(
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
    sourceTaskId: 'actions_legal_context',
    repairTaskId: 'actions_check_drill',
    repairFocusKey: 'focus_key',
    queueItemId: 'queue_item',
  );
}

Act0RepairOutcomeV1 _outcome({required String outcomeState}) {
  return Act0RepairOutcomeV1(
    sourceTaskId: 'actions_legal_context',
    repairTaskId: 'actions_check_drill',
    repairFocusKey: 'focus_key',
    queueItemId: 'queue_item',
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    selectedChoiceId: 'check',
    correctChoiceId: 'check',
    isCorrect: outcomeState == act0RepairOutcomeStateCorrectV1
        ? true
        : outcomeState == act0RepairOutcomeStateStillNeedsRepV1
        ? false
        : null,
    outcomeState: outcomeState,
    sequence: 1,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
  );
}

bool _containsForbiddenTokenInText(String text, String token) {
  final pattern = RegExp(
    r'(^|[^a-z0-9])' + RegExp.escape(token) + r'([^a-z0-9]|$)',
  );
  return pattern.hasMatch(text.toLowerCase());
}
