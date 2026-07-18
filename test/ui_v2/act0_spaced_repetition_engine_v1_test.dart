import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_spaced_repetition_engine_v1.dart';

final DateTime _now = DateTime.utc(2026, 7, 18, 12);

void main() {
  test('time-based projection excludes not-due family', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromRetention(
      nowUtc: _now.add(const Duration(hours: 23)),
      retentionHistory: _recovered(),
    );

    expect(schedule.nextDueFamily, isNull);
    expect(
      schedule.scheduleForConceptFamily('action_read')!.scheduleState,
      act0SpacedRepStateNotDueV1,
    );
  });

  test('time-based projection includes overdue family', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromRetention(
      nowUtc: _now.add(const Duration(hours: 25)),
      retentionHistory: _recovered(),
    );

    expect(schedule.nextDueFamily!.conceptFamilyId, 'action_read');
    expect(
      schedule.nextDueFamily!.nextDueAtUtc,
      _now.add(const Duration(hours: 24)),
    );
  });

  test('payload round trip preserves UTC due time', () {
    final schedule = Act0SpacedRepetitionScheduleV1.fromRetention(
      nowUtc: _now.add(const Duration(hours: 25)),
      retentionHistory: _recovered(),
    );
    final parsed = Act0SpacedRepetitionScheduleV1.tryParse(
      schedule.toPayload(),
    );

    expect(parsed.toPayload(), schedule.toPayload());
  });

  test('malformed and legacy session-ordinal schedules are rejected', () {
    final parsed = Act0SpacedRepetitionScheduleV1.tryParse([
      {'schemaVersion': 1, 'dueAfterSessionOrdinal': 2},
      {'schemaVersion': 2, 'conceptFamilyId': ''},
    ]);

    expect(parsed.schedules, isEmpty);
  });

  test('engine owns no clock, persistence, telemetry, or background work', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_spaced_repetition_engine_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('DateTime.now')));
    expect(source, isNot(contains('SharedPreferences')));
    expect(source, isNot(contains('Timer')));
    expect(source, isNot(contains('Telemetry')));
    expect(source, isNot(contains('dueAfterSessionOrdinal')));
  });
}

Act0DurableRetentionHistoryV1 _recovered() =>
    const Act0DurableRetentionHistoryV1()
        .applyEvidence(_record(order: 1, isCorrect: false))
        .applyEvidence(
          _record(
            order: 2,
            isCorrect: true,
            reviewKind: Act0ReviewKindV1.immediateRepair,
          ),
        );

Act0LearningEvidenceRecordV1 _record({
  required int order,
  required bool isCorrect,
  Act0ReviewKindV1 reviewKind = Act0ReviewKindV1.initialAssessment,
}) => Act0LearningEvidenceRecordV1(
  recordId: 'record_$order',
  createdOrder: order,
  worldId: 'world_1',
  lessonId: 'lesson',
  taskId: 'task',
  choiceId: isCorrect ? 'correct' : 'wrong',
  expectedChoiceId: 'correct',
  isCorrect: isCorrect,
  errorType: isCorrect ? 'none' : 'missed_action_read',
  conceptFamilyId: 'action_read',
  repairFocusId: 'action_read',
  skillAtomId: 'action_read',
  decisionTimeBucket: '3_to_10s',
  resultKind: isCorrect ? 'correct' : 'incorrect',
  sessionId: 'session_v1|1',
  recordedAtUtc: _now,
  reviewKind: reviewKind,
);
