import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';

final DateTime _base = DateTime.utc(2026, 7, 1);

void main() {
  test('recent different-task spaced successes improve after a miss', () {
    final signal = _measure([
      _record(order: 1),
      _record(
        order: 2,
        day: 1,
        taskId: 'task_b',
        sessionId: 'session_v1|2',
        isCorrect: true,
        reviewKind: Act0ReviewKindV1.alternateSameSignal,
      ),
      _record(
        order: 3,
        day: 4,
        taskId: 'task_c',
        sessionId: 'session_v1|3',
        isCorrect: true,
        reviewKind: Act0ReviewKindV1.unseenTransfer,
      ),
    ]);

    expect(signal.relationship, act0LearningTransferSameFamilyTransferV1);
    expect(signal.verdict, act0LearningTransferImprovingV1);
    expect(signal.baselineOrder, 2);
    expect(signal.comparisonOrder, 3);
  });

  test('exact replay is recovery evidence but not transfer', () {
    final signal = _measure([
      _record(order: 1),
      _record(
        order: 2,
        day: 1,
        sessionId: 'session_v1|2',
        isCorrect: true,
        reviewKind: Act0ReviewKindV1.exactReplay,
      ),
    ]);

    expect(signal.relationship, act0LearningTransferInsufficientEvidenceV1);
    expect(signal.verdict, act0LearningTransferRecoveredNotDurableV1);
  });

  test('same-session task variation is insufficient', () {
    final signal = _measure([
      _record(order: 1),
      _record(
        order: 2,
        day: 1,
        taskId: 'task_b',
        isCorrect: true,
        reviewKind: Act0ReviewKindV1.alternateSameSignal,
      ),
    ]);

    expect(signal.verdict, act0LearningTransferRecoveredNotDurableV1);
  });

  test('late eligible miss overrides prior success as regression', () {
    final signal = _measure([
      _record(order: 1, isCorrect: true),
      _record(
        order: 2,
        day: 1,
        taskId: 'task_b',
        sessionId: 'session_v1|2',
        isCorrect: true,
        reviewKind: Act0ReviewKindV1.unseenTransfer,
      ),
      _record(
        order: 3,
        day: 4,
        taskId: 'task_c',
        sessionId: 'session_v1|3',
        reviewKind: Act0ReviewKindV1.unseenTransfer,
      ),
    ]);

    expect(signal.verdict, act0LearningTransferRegressingV1);
  });

  test('legacy records cannot independently prove transfer', () {
    final signal = _measure([
      _record(order: 1, legacy: true),
      _record(
        order: 2,
        taskId: 'task_b',
        sessionId: 'session_v1|2',
        isCorrect: true,
        legacy: true,
      ),
    ]);

    expect(signal.verdict, act0LearningTransferInsufficientEvidenceV1);
  });

  test('different concept family cannot resolve another family', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: [
          _record(order: 1),
          _record(
            order: 2,
            day: 1,
            conceptFamilyId: 'position_read',
            taskId: 'position_task',
            sessionId: 'session_v1|2',
            isCorrect: true,
            reviewKind: Act0ReviewKindV1.unseenTransfer,
          ),
        ],
      ),
    );

    expect(
      measurement.signalForConcept('action_read').verdict,
      act0LearningTransferInsufficientEvidenceV1,
    );
  });

  test('projection stays deterministic and claim-safe', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('DateTime.now')));
    expect(source, isNot(contains('SharedPreferences')));
    expect(source, isNot(contains('mastered')));
    expect(source, contains('recentEvidenceWindow'));
  });
}

Act0LearningTransferSignalV1 _measure(
  List<Act0LearningEvidenceRecordV1> records,
) => Act0LearningTransferMeasurementV1.fromLearningEvidence(
  Act0LearningEvidenceHistoryV1(records: records),
).signalForConcept('action_read');

Act0LearningEvidenceRecordV1 _record({
  required int order,
  int day = 0,
  String conceptFamilyId = 'action_read',
  String taskId = 'task_a',
  String sessionId = 'session_v1|1',
  bool isCorrect = false,
  bool legacy = false,
  Act0ReviewKindV1 reviewKind = Act0ReviewKindV1.initialAssessment,
}) => Act0LearningEvidenceRecordV1(
  recordId: '$conceptFamilyId:$order:$taskId',
  createdOrder: order,
  worldId: 'world_1',
  lessonId: 'lesson',
  taskId: taskId,
  choiceId: isCorrect ? 'correct' : 'wrong',
  expectedChoiceId: 'correct',
  isCorrect: isCorrect,
  errorType: isCorrect ? 'none' : 'missed_action_read',
  conceptFamilyId: conceptFamilyId,
  repairFocusId: conceptFamilyId,
  skillAtomId: conceptFamilyId,
  decisionTimeBucket: '3_to_10s',
  resultKind: isCorrect ? 'correct' : 'incorrect',
  sessionId: sessionId,
  recordedAtUtc: legacy ? null : _base.add(Duration(days: day)),
  reviewKind: legacy ? Act0ReviewKindV1.legacyUnspaced : reviewKind,
);
