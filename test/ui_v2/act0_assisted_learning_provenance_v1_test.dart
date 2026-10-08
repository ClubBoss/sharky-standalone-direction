import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';

final DateTime t0 = DateTime.utc(2026, 10, 8, 12);

Act0CompletedDecisionV1 choice(Act0DecisionAssistanceV1 assistance, int n) =>
    Act0CompletedDecisionV1(
      attemptKey: 'attempt|$n',
      worldId: 'world_1',
      lessonId: 'lesson',
      taskId: 'task_$n',
      sourceTaskId: 'task_$n',
      decisionKind: Act0CompletedDecisionKindV1.actionList,
      selectedId: 'check',
      expectedId: 'check',
      isCorrect: true,
      decisionTimeBucket: '3_to_10s',
      taskFamily: null,
      resultKind: 'correct',
      errorType: 'none',
      skillAtomId: 'action_read',
      repairFocusId: 'no_bet_yet',
      assistanceKind: assistance,
    );

Act0LearningEvidenceRecordV1 record(
  Act0DecisionAssistanceV1 assistance,
  int n, {
  Act0ReviewKindV1 kind = Act0ReviewKindV1.unseenTransfer,
  int day = 0,
  String session = 'session_v1|2',
}) => act0LearningEvidenceRecordFromCompletedDecisionV1(
  choice(assistance, n),
  createdOrder: n,
  recordedAtUtc: t0.add(Duration(days: day)),
  reviewKind: kind,
  sessionId: session,
)!;

void main() {
  test('normal vs quick hint vs full recall preserve distinct provenance', () {
    for (final mode in <Act0DecisionAssistanceV1>[
      Act0DecisionAssistanceV1.none,
      Act0DecisionAssistanceV1.quickHint,
      Act0DecisionAssistanceV1.theoryRecall,
    ]) {
      final entry = record(mode, 1);
      expect(entry.assistanceKind, mode);
      expect(entry.toPayload()['assistanceKind'], mode.name);
      final recovered = Act0LearningEvidenceRecordV1.tryParse(
        entry.toPayload(),
      );
      expect(recovered, entry);
      expect(
        recovered!.isAssistedCorrect,
        mode != Act0DecisionAssistanceV1.none,
      );
    }
  });

  test('older persisted records load without inventing independence', () {
    final original = record(Act0DecisionAssistanceV1.none, 1).toPayload()
      ..remove('assistanceKind');
    final loaded = Act0LearningEvidenceRecordV1.tryParse(original);
    expect(loaded, isNotNull);
    expect(loaded!.assistanceKind, Act0DecisionAssistanceV1.legacyUnknown);
    expect(loaded.toPayload(), isNot(contains('assistanceKind')));
    final corrupt = Map<String, Object?>.from(original)
      ..['assistanceKind'] = 'invalid';
    expect(Act0LearningEvidenceRecordV1.tryParse(corrupt), isNull);
  });

  test('hinted success is saved but does not advance durable schedule', () {
    final miss = Act0LearningEvidenceRecordV1(
      recordId: 'miss',
      createdOrder: 0,
      worldId: 'world_1',
      lessonId: 'lesson',
      taskId: 'task_0',
      choiceId: 'fold',
      expectedChoiceId: 'check',
      isCorrect: false,
      errorType: 'missed_action_read',
      conceptFamilyId: 'no_bet_yet',
      repairFocusId: 'no_bet_yet',
      skillAtomId: 'action_read',
      decisionTimeBucket: '3_to_10s',
      resultKind: 'incorrect',
      sessionId: 'session_v1|1',
      recordedAtUtc: t0,
      reviewKind: Act0ReviewKindV1.initialAssessment,
    );
    final initial = const Act0DurableRetentionHistoryV1().applyEvidence(miss);
    final hinted = record(
      Act0DecisionAssistanceV1.quickHint,
      1,
      day: 1,
      kind: Act0ReviewKindV1.spacedReview,
    );
    final followed = initial.applyEvidence(hinted);
    expect(followed.familyById('no_bet_yet'), initial.familyById('no_bet_yet'));
    expect(
      Act0LearningEvidenceHistoryV1(records: [miss, hinted]).records.length,
      2,
    );
    final independent = initial.applyEvidence(
      record(
        Act0DecisionAssistanceV1.none,
        2,
        day: 1,
        kind: Act0ReviewKindV1.spacedReview,
      ),
    );
    expect(independent.familyById('no_bet_yet')!.nextDueAtUtc, isNotNull);
    expect(independent.familyById('no_bet_yet')!.correctCount, 1);
  });

  test('hinted answers cannot fabricate transfer or profile capability', () {
    final records = <Act0LearningEvidenceRecordV1>[
      for (var i = 1; i <= 5; i++)
        record(
          i == 1
              ? Act0DecisionAssistanceV1.none
              : Act0DecisionAssistanceV1.theoryRecall,
          i,
          day: i,
          session: 'session_v1|$i',
        ),
    ];
    final history = Act0LearningEvidenceHistoryV1(records: records);
    final signal = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      history,
    ).signalForConcept('no_bet_yet');
    expect(signal.verdict, act0LearningTransferInsufficientEvidenceV1);
    final profile = Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
      history,
    );
    final entry = profile.signals.single;
    expect(entry.attemptCount, 1);
    expect(entry.isCapabilityEligible, false);
  });
}
