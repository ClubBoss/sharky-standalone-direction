import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_spaced_repetition_engine_v1.dart';

final DateTime _t0 = DateTime.utc(2026, 7, 18, 12);

void main() {
  group('durable retention state and schedule', () {
    test('1-2 miss then immediate repair is recovered but not durable', () {
      final history = _recoveredHistory();
      final family = history.familyById('no_bet_yet')!;

      expect(
        family.retentionState,
        Act0RetentionStateV1.recoveredPendingSpacedReview,
      );
      expect(family.nextDueAtUtc, _t0.add(const Duration(hours: 24)));
      expect(family.incorrectCount, 1);
      expect(family.spacedSuccessStage, 0);
    });

    test('3 before 24h is not due', () {
      final schedule = Act0SpacedRepetitionScheduleV1.fromRetention(
        nowUtc: _t0.add(const Duration(hours: 23, minutes: 59)),
        retentionHistory: _recoveredHistory(),
      );

      expect(schedule.nextDueFamily, isNull);
    });

    test('4 at 24h is due', () {
      final schedule = Act0SpacedRepetitionScheduleV1.fromRetention(
        nowUtc: _t0.add(const Duration(hours: 24)),
        retentionHistory: _recoveredHistory(),
      );

      expect(schedule.nextDueFamily!.conceptFamilyId, 'no_bet_yet');
      expect(schedule.nextDueFamily!.scheduleState, act0SpacedRepStateDueNowV1);
    });

    test('5 first due success schedules 72h', () {
      final dueAt = _t0.add(const Duration(hours: 24));
      final history = _recoveredHistory().applyEvidence(
        _record(
          order: 3,
          at: dueAt,
          taskId: 'actions_check_transfer',
          sourceTaskId: 'actions_legal_context',
          sessionId: 'session_v1|2',
          isCorrect: true,
          reviewKind: Act0ReviewKindV1.spacedReview,
        ),
      );
      final family = history.familyById('no_bet_yet')!;

      expect(family.spacedSuccessStage, 1);
      expect(family.nextDueAtUtc, dueAt.add(const Duration(hours: 72)));
      expect(
        family.retentionState,
        Act0RetentionStateV1.recoveredPendingSpacedReview,
      );
    });

    test('6 second due success becomes durable with 7d maintenance', () {
      final history = _durableHistory();
      final family = history.familyById('no_bet_yet')!;
      final secondDueAt = _t0.add(const Duration(hours: 96));

      expect(family.spacedSuccessStage, 2);
      expect(family.retentionState, Act0RetentionStateV1.durable);
      expect(family.nextDueAtUtc, secondDueAt.add(const Duration(days: 7)));
    });

    test('7 due miss lapses and schedules 24h', () {
      final maintenanceAt = _t0.add(const Duration(hours: 96, days: 7));
      final history = _durableHistory().applyEvidence(
        _record(
          order: 5,
          at: maintenanceAt,
          taskId: 'actions_unseen_transfer',
          sourceTaskId: 'actions_legal_context',
          sessionId: 'session_v1|4',
          reviewKind: Act0ReviewKindV1.unseenTransfer,
        ),
      );
      final family = history.familyById('no_bet_yet')!;

      expect(family.retentionState, Act0RetentionStateV1.lapsed);
      expect(family.lapseCount, 1);
      expect(family.spacedSuccessStage, 0);
      expect(family.nextDueAtUtc, maintenanceAt.add(const Duration(hours: 24)));
    });

    test('8 repeated misses survive one same-session correct', () {
      final evidence = Act0LearningEvidenceHistoryV1(
        records: [
          _record(order: 1, at: _t0),
          _record(order: 2, at: _t0.add(const Duration(minutes: 1))),
          _record(
            order: 3,
            at: _t0.add(const Duration(minutes: 2)),
            isCorrect: true,
            reviewKind: Act0ReviewKindV1.exactReplay,
          ),
        ],
      );
      final immediateMemory =
          Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(evidence);
      final durable = Act0DurableRetentionHistoryV1.fromLearningEvidence(
        evidence,
      ).familyById('no_bet_yet')!;

      expect(
        immediateMemory.nextRepairCandidate,
        isNull,
        reason: 'the immediate repair queue may close',
      );
      expect(durable.incorrectCount, 2);
      expect(
        durable.retentionState,
        Act0RetentionStateV1.recoveredPendingSpacedReview,
      );
      expect(durable.nextDueAtUtc, isNotNull);
    });

    test('a later-session correct also recovers debt without durability', () {
      final history = const Act0DurableRetentionHistoryV1()
          .applyEvidence(_record(order: 1, at: _t0))
          .applyEvidence(
            _record(
              order: 2,
              at: _t0.add(const Duration(days: 2)),
              taskId: 'actions_check_transfer',
              sessionId: 'session_v1|2',
              isCorrect: true,
              reviewKind: Act0ReviewKindV1.unseenTransfer,
            ),
          );
      final family = history.familyById('no_bet_yet')!;

      expect(
        family.retentionState,
        Act0RetentionStateV1.recoveredPendingSpacedReview,
      );
      expect(family.spacedSuccessStage, 0);
      expect(family.nextDueAtUtc, _t0.add(const Duration(days: 3)));
    });

    test('9 unrelated concept success cannot resolve debt', () {
      final history = _recoveredHistory().applyEvidence(
        _record(
          order: 3,
          at: _t0.add(const Duration(hours: 24)),
          conceptFamilyId: 'position_read',
          taskId: 'position_transfer',
          sourceTaskId: 'position_source',
          isCorrect: true,
          reviewKind: Act0ReviewKindV1.unseenTransfer,
        ),
      );

      expect(history.familyById('no_bet_yet')!.spacedSuccessStage, 0);
    });

    test('16 legacy evidence stays unspaced with no fabricated due time', () {
      final legacy = Act0DurableRetentionHistoryV1.fromLearningEvidence(
        Act0LearningEvidenceHistoryV1(
          records: [
            _legacyRecord(order: 1),
            _legacyRecord(order: 2, isCorrect: true),
          ],
        ),
      ).familyById('no_bet_yet')!;

      expect(legacy.hasLegacyUnspacedEvidence, isTrue);
      expect(legacy.nextDueAtUtc, isNull);
      expect(legacy.lastRecordedAtUtc, isNull);
      expect(legacy.spacedSuccessStage, 0);
    });

    test('18 clean retention payload round trips exactly', () {
      final history = _durableHistory();
      final parsed = Act0DurableRetentionHistoryV1.tryParse(
        history.toPayload(),
      );

      expect(parsed.toPayload(), history.toPayload());
    });

    test('20-21 restart before and after due preserves time truth', () {
      final payload = _recoveredHistory().toPayload();
      final restored = Act0DurableRetentionHistoryV1.tryParse(payload);

      expect(
        restored
            .refreshedAt(_t0.add(const Duration(hours: 23)))
            .familyById('no_bet_yet')!
            .retentionState,
        Act0RetentionStateV1.recoveredPendingSpacedReview,
      );
      expect(
        restored
            .refreshedAt(_t0.add(const Duration(hours: 24)))
            .familyById('no_bet_yet')!
            .retentionState,
        Act0RetentionStateV1.due,
      );
    });

    test('22 due ordering is earliest, severity, then stable id', () {
      var history = const Act0DurableRetentionHistoryV1();
      var order = 0;
      for (final concept in ['c_family', 'a_family', 'b_family']) {
        history = history.applyEvidence(
          _record(
            order: ++order,
            at: _t0,
            conceptFamilyId: concept,
            taskId: '${concept}_task',
          ),
        );
        if (concept == 'b_family') {
          history = history.applyEvidence(
            _record(
              order: ++order,
              at: _t0.add(const Duration(seconds: 30)),
              conceptFamilyId: concept,
              taskId: '${concept}_task',
            ),
          );
        }
        history = history.applyEvidence(
          _record(
            order: ++order,
            at: _t0.add(const Duration(minutes: 1)),
            conceptFamilyId: concept,
            taskId: '${concept}_task',
            isCorrect: true,
            reviewKind: Act0ReviewKindV1.immediateRepair,
          ),
        );
      }

      expect(
        history
            .dueItemsAt(_t0.add(const Duration(hours: 25)))
            .map((item) => item.conceptFamilyId),
        ['b_family', 'a_family', 'c_family'],
      );
    });

    test('23 one concept produces one due item', () {
      final due = _recoveredHistory().dueItemsAt(
        _t0.add(const Duration(days: 2)),
      );

      expect(due, hasLength(1));
      expect(due.single.taskId, 'actions_legal_context');
    });

    test('clock returns injected UTC without movement side effects', () {
      final local = DateTime.parse('2026-07-18T16:00:00+04:00');
      final clock = Act0FixedUtcClockV1(local);

      expect(clock.nowUtc(), _t0);
      expect(clock.nowUtc(), _t0);
    });
  });

  group('recent spaced transfer verdict', () {
    test('10 exact replay alone is insufficient transfer', () {
      final evidence = Act0LearningEvidenceHistoryV1(
        records: [
          _record(order: 1, at: _t0),
          _record(
            order: 2,
            at: _t0.add(const Duration(days: 1)),
            isCorrect: true,
            reviewKind: Act0ReviewKindV1.exactReplay,
          ),
        ],
      );

      expect(_verdict(evidence), act0LearningTransferRecoveredNotDurableV1);
    });

    test('11 alternate same-signal evidence is distinguished', () {
      final record = _record(
        order: 2,
        at: _t0.add(const Duration(days: 1)),
        taskId: 'actions_check_transfer',
        isCorrect: true,
        reviewKind: Act0ReviewKindV1.alternateSameSignal,
      );

      expect(record.reviewKind, Act0ReviewKindV1.alternateSameSignal);
      expect(record.toPayload()['reviewKind'], 'alternateSameSignal');
    });

    test('12 unseen spaced task may contribute to stable transfer', () {
      final history = _durableEvidenceHistory();
      final measurement =
          Act0LearningTransferMeasurementV1.fromLearningEvidence(history);
      final signal = measurement.signalForConcept('no_bet_yet');

      expect(signal.relationship, act0LearningTransferSameFamilyTransferV1);
      expect(signal.verdict, act0LearningTransferStableV1);
    });

    test('13 early miss plus recent spaced successes improves', () {
      final evidence = _durableEvidenceHistory();
      final retention = Act0DurableRetentionHistoryV1.fromLearningEvidence(
        evidence,
      );
      final pending = Act0DurableRetentionHistoryV1(
        families: [retention.familyById('no_bet_yet')!._testPendingCopy()],
      );
      final signal = Act0LearningTransferMeasurementV1.fromLearningEvidence(
        evidence,
        retentionHistory: pending,
      ).signalForConcept('no_bet_yet');

      expect(signal.verdict, act0LearningTransferImprovingV1);
    });

    test('14 early success plus late miss regresses', () {
      final evidence = Act0LearningEvidenceHistoryV1(
        records: [
          _record(order: 1, at: _t0, isCorrect: true),
          _record(
            order: 2,
            at: _t0.add(const Duration(days: 1)),
            taskId: 'actions_check_transfer',
            isCorrect: true,
            sessionId: 'session_v1|2',
            reviewKind: Act0ReviewKindV1.unseenTransfer,
          ),
          _record(
            order: 3,
            at: _t0.add(const Duration(days: 4)),
            taskId: 'actions_raise_transfer',
            sessionId: 'session_v1|3',
            reviewKind: Act0ReviewKindV1.unseenTransfer,
          ),
        ],
      );

      expect(_verdict(evidence), act0LearningTransferRegressingV1);
    });

    test('15 sufficient inconsistent recent evidence is mixed', () {
      final evidence = Act0LearningEvidenceHistoryV1(
        records: [
          _record(order: 1, at: _t0),
          _record(
            order: 2,
            at: _t0.add(const Duration(days: 1)),
            taskId: 'task_b',
            sessionId: 'session_v1|2',
            isCorrect: true,
            reviewKind: Act0ReviewKindV1.unseenTransfer,
          ),
          _record(
            order: 3,
            at: _t0.add(const Duration(days: 4)),
            taskId: 'task_c',
            sessionId: 'session_v1|3',
            reviewKind: Act0ReviewKindV1.unseenTransfer,
          ),
          _record(
            order: 4,
            at: _t0.add(const Duration(days: 5)),
            taskId: 'task_d',
            sessionId: 'session_v1|4',
            isCorrect: true,
            reviewKind: Act0ReviewKindV1.unseenTransfer,
          ),
        ],
      );

      expect(_verdict(evidence), act0LearningTransferMixedV1);
    });

    test(
      '19 equal timestamps and duplicate orders use stable record-id tie-break',
      () {
        final sameTime = _t0.add(const Duration(days: 1));
        final evidence = Act0LearningEvidenceHistoryV1(
          records: [
            _record(order: 1, at: _t0),
            _record(
              order: 2,
              at: sameTime,
              taskId: 'task_b',
              isCorrect: true,
              reviewKind: Act0ReviewKindV1.unseenTransfer,
            ),
            _record(
              order: 2,
              at: sameTime,
              taskId: 'task_c',
              isCorrect: true,
              reviewKind: Act0ReviewKindV1.unseenTransfer,
              recordId: 'record_z',
            ),
          ],
        );
        final signal = Act0LearningTransferMeasurementV1.fromLearningEvidence(
          evidence,
        ).signalForConcept('no_bet_yet');

        expect(signal.comparisonOrder, 2);
        expect(signal.comparisonTaskId, 'task_c');
      },
    );

    test('legacy timing and task diversity cannot prove transfer', () {
      final evidence = Act0LearningEvidenceHistoryV1(
        records: [
          _legacyRecord(order: 1),
          _legacyRecord(order: 2, taskId: 'task_b', isCorrect: true),
        ],
      );

      expect(_verdict(evidence), act0LearningTransferInsufficientEvidenceV1);
    });
  });
}

Act0DurableRetentionHistoryV1 _recoveredHistory() =>
    const Act0DurableRetentionHistoryV1()
        .applyEvidence(_record(order: 1, at: _t0))
        .applyEvidence(
          _record(
            order: 2,
            at: _t0,
            isCorrect: true,
            reviewKind: Act0ReviewKindV1.immediateRepair,
          ),
        );

Act0DurableRetentionHistoryV1 _durableHistory() =>
    Act0DurableRetentionHistoryV1.fromLearningEvidence(
      _durableEvidenceHistory(),
    );

Act0LearningEvidenceHistoryV1 _durableEvidenceHistory() =>
    Act0LearningEvidenceHistoryV1(
      records: [
        _record(order: 1, at: _t0),
        _record(
          order: 2,
          at: _t0,
          isCorrect: true,
          reviewKind: Act0ReviewKindV1.immediateRepair,
        ),
        _record(
          order: 3,
          at: _t0.add(const Duration(hours: 24)),
          taskId: 'actions_check_transfer',
          sourceTaskId: 'actions_legal_context',
          sessionId: 'session_v1|2',
          isCorrect: true,
          reviewKind: Act0ReviewKindV1.alternateSameSignal,
        ),
        _record(
          order: 4,
          at: _t0.add(const Duration(hours: 96)),
          taskId: 'actions_unseen_transfer',
          sourceTaskId: 'actions_legal_context',
          sessionId: 'session_v1|3',
          isCorrect: true,
          reviewKind: Act0ReviewKindV1.unseenTransfer,
        ),
      ],
    );

String _verdict(Act0LearningEvidenceHistoryV1 evidence) =>
    Act0LearningTransferMeasurementV1.fromLearningEvidence(
      evidence,
    ).signalForConcept('no_bet_yet').verdict;

Act0LearningEvidenceRecordV1 _record({
  required int order,
  required DateTime at,
  String conceptFamilyId = 'no_bet_yet',
  String taskId = 'actions_legal_context',
  String sourceTaskId = '',
  String sessionId = 'session_v1|1',
  bool isCorrect = false,
  Act0ReviewKindV1 reviewKind = Act0ReviewKindV1.initialAssessment,
  String? recordId,
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: recordId ?? '$conceptFamilyId:$order:$taskId',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: taskId,
    sourceTaskId: sourceTaskId,
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: isCorrect ? 'none' : 'missed_action_read',
    conceptFamilyId: conceptFamilyId,
    repairFocusId: conceptFamilyId,
    skillAtomId: 'action_read',
    decisionTimeBucket: '3_to_10s',
    resultKind: isCorrect ? 'correct' : 'incorrect',
    sessionId: sessionId,
    recordedAtUtc: at,
    reviewKind: reviewKind,
  );
}

Act0LearningEvidenceRecordV1 _legacyRecord({
  required int order,
  String taskId = 'actions_legal_context',
  bool isCorrect = false,
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: 'legacy:$order:$taskId',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: taskId,
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: isCorrect ? 'none' : 'missed_action_read',
    conceptFamilyId: 'no_bet_yet',
    repairFocusId: 'no_bet_yet',
    skillAtomId: 'action_read',
    decisionTimeBucket: '3_to_10s',
    resultKind: isCorrect ? 'correct' : 'incorrect',
    sessionId: 'session_v1|1',
  );
}

extension on Act0DurableRetentionFamilyV1 {
  Act0DurableRetentionFamilyV1 _testPendingCopy() {
    final payload = toPayload()
      ..['retentionState'] =
          Act0RetentionStateV1.recoveredPendingSpacedReview.name
      ..['spacedSuccessStage'] = 1;
    return Act0DurableRetentionFamilyV1.tryParse(payload)!;
  }
}
