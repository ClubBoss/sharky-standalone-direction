// MACHINE-only clock simulations. No Human retention or mastery claim.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';

final t0 = DateTime.utc(2026, 1, 1);
final now = t0.add(const Duration(days: 1000));
Act0LessonTaskV1 task(int i, {bool other = false, bool sameTask = false}) =>
    Act0ShellStateV1.sample
        .lessonById(other ? 'fold_check_call_raise' : 'blinds_action_order')
        .taskList
        .singleWhere(
          (t) =>
              t.taskId ==
              (other
                  ? (i.isEven && !sameTask
                        ? 'actions_legal_context'
                        : 'actions_check_drill')
                  : (i.isEven && !sameTask
                        ? 'blinds_first_actor'
                        : 'blinds_review')),
        );
Act0LearningEvidenceHistoryV1 append(
  Act0LearningEvidenceHistoryV1 h,
  int i, {
  bool correct = true,
  bool other = false,
  bool sameTask = false,
  int? taskIndex,
  String? session,
  int? hours,
  Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
  Act0ReviewKindV1 kind = Act0ReviewKindV1.spacedReview,
}) {
  final source = task(taskIndex ?? i, other: other, sameTask: sameTask);
  final selected = source.runner.options.firstWhere(
    (o) => o.isCorrect == correct,
  );
  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: source.runner,
    option: selected,
    taskFamily: source.resolvedTaskFamily,
  )!;
  final lesson = other ? 'fold_check_call_raise' : 'blinds_action_order';
  return h.appendCompletedDecision(
    Act0CompletedDecisionV1(
      attemptKey: 'epoch|$i',
      worldId: 'world_1',
      lessonId: lesson,
      taskId: source.taskId,
      sourceTaskId: source.taskId,
      decisionKind: other
          ? Act0CompletedDecisionKindV1.actionList
          : Act0CompletedDecisionKindV1.seat,
      selectedId: selected.id,
      expectedId: source.runner.options.firstWhere((o) => o.isCorrect).id,
      isCorrect: selected.isCorrect,
      decisionTimeBucket: '3_to_10s',
      taskFamily: source.resolvedTaskFamily,
      resultKind: correct ? 'correct' : 'incorrect',
      errorType: correct ? 'none' : 'missed_action_read',
      skillAtomId: receipt.skillAtomId,
      repairFocusId: receipt.sourceSignalId,
      assistanceKind: assistance,
    ),
    authoredSourceFingerprint: act0AuthoredSourceFingerprintV1(
      worldId: 'world_1',
      lessonId: lesson,
      task: source,
    )!,
    sessionId: session ?? 'session|$i',
    recordedAtUtc: t0.add(Duration(hours: hours ?? i * 24)),
    reviewKind: kind,
  );
}

Act0LearningEvidenceHistoryV1 chain(
  int count, {
  bool sameTask = false,
  String? session,
  int stepHours = 24,
  Set<int> misses = const {},
}) {
  var h = const Act0LearningEvidenceHistoryV1();
  for (var i = 1; i <= count; i++) {
    h = append(
      h,
      i,
      sameTask: sameTask,
      session: session,
      hours: i * stepHours,
      correct: !misses.contains(i),
    );
  }
  return h;
}

String family(bool other) {
  final t = task(1, other: other);
  return act0FirstValueSkillReceiptForRunnerV1(
    runner: t.runner,
    option: t.runner.options.first,
    taskFamily: t.resolvedTaskFamily,
  )!.sourceSignalId;
}

Act0LearningTransferSignalV1 signal(
  Act0LearningEvidenceHistoryV1 h, {
  bool other = false,
  DateTime? at,
}) => Act0LearningTransferMeasurementV1.fromLearningEvidence(
  h,
  nowUtc: at ?? now,
).signalForConcept(family(other));
Act0LearningEvidenceHistoryV1 replaceLast(
  Act0LearningEvidenceHistoryV1 h,
  Map<String, Object?> changes,
) {
  final p = h.records.last.toPayload()..addAll(changes);
  return Act0LearningEvidenceHistoryV1(
    records: [
      ...h.records.take(h.records.length - 1),
      Act0LearningEvidenceRecordV1.tryParse(p)!,
    ],
    sourceAnchors: h.sourceAnchors,
    hasCompleteLineage: h.hasCompleteLineage,
  );
}

void main() {
  test(
    'four/five source-authentic all-success attempts share explicit threshold',
    () {
      expect(signal(chain(4)).verdict, act0RecentEvidenceConfirmationNeededV1);
      expect(signal(chain(5)).verdict, act0RecentEvidenceVerifiedV1);
    },
  );
  test('three correct, latest correct and mixed factual counts', () {
    expect(
      signal(chain(5, misses: {1, 2, 3})).verdict,
      act0RecentEvidenceConfirmationNeededV1,
    );
    final s = signal(chain(5, misses: {1, 3}));
    expect(s.verdict, act0RecentEvidenceVerifiedV1);
    expect(s.correctCount, 3);
    expect(s.confirmationLine, 'Recent verified responses');
    expect(
      signal(chain(5, misses: {5})).verdict,
      act0RecentEvidenceConfirmationNeededV1,
    );
  });
  test('task/session diversity and 24h boundary cannot be padded', () {
    expect(
      signal(chain(5, sameTask: true)).verdict,
      act0RecentEvidenceConfirmationNeededV1,
    );
    expect(
      signal(chain(5, session: 'same')).verdict,
      act0RecentEvidenceConfirmationNeededV1,
    );
    expect(
      signal(chain(5, stepHours: 23)).verdict,
      act0RecentEvidenceConfirmationNeededV1,
    );
    expect(
      signal(chain(5, stepHours: 24)).verdict,
      act0RecentEvidenceVerifiedV1,
    );
  });
  test(
    'same-session confirming pair cannot borrow older session diversity',
    () {
      var h = chain(3);
      h = append(h, 4, session: 'same');
      h = append(h, 5, session: 'same');
      expect(signal(h).verdict, act0RecentEvidenceConfirmationNeededV1);
    },
  );
  test('assistance and exact replay cannot pad five independent attempts', () {
    var h = chain(4);
    h = append(h, 5, assistance: Act0DecisionAssistanceV1.quickHint);
    expect(signal(h).eligibleEvidenceCount, 4);
    expect(signal(h).verdict, act0RecentEvidenceConfirmationNeededV1);
    h = append(h, 6, kind: Act0ReviewKindV1.exactReplay);
    expect(signal(h).eligibleEvidenceCount, 4);
    h = append(h, 7);
    expect(signal(h).verdict, act0RecentEvidenceVerifiedV1);
  });
  test(
    'all-success recent proof survives200 and never claims lifelong retention',
    () {
      var h = chain(210);
      expect(h.records.length, 200);
      expect(signal(h).verdict, act0RecentEvidenceVerifiedV1);
      expect(
        Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
          h,
          nowUtc: now,
        ).families,
        isEmpty,
      );
      for (var i = 211; i <= 420; i++) {
        h = append(h, i);
      }
      expect(signal(h).verdict, act0RecentEvidenceVerifiedV1);
    },
  );
  test(
    'repeated missing intervals reset suffix then five fresh successes recover',
    () {
      var h = chain(210);
      h = Act0LearningEvidenceHistoryV1(
        records: h.records.where((r) => r.createdOrder != 208).toList(),
      );
      expect(signal(h).verdict, act0RecentEvidenceConfirmationNeededV1);
      for (var i = 211; i <= 215; i++) {
        h = append(h, i);
      }
      expect(signal(h).verdict, act0RecentEvidenceVerifiedV1);
      h = Act0LearningEvidenceHistoryV1(
        records: h.records.where((r) => r.createdOrder != 214).toList(),
      );
      expect(signal(h).verdict, act0RecentEvidenceConfirmationNeededV1);
      for (var i = 216; i <= 220; i++) {
        h = append(h, i);
      }
      expect(signal(h).verdict, act0RecentEvidenceVerifiedV1);
    },
  );
  test(
    'answer/condition incompatibility fences old success and later valid data recover',
    () {
      for (final change in [
        {
          'choiceId': 'bb',
          'expectedChoiceId': 'bb',
          'isCorrect': true,
          'resultKind': 'correct',
          'errorType': 'none',
        },
        {'authoredSourceFingerprint': 'old-condition-same-answer-ids'},
      ]) {
        var h = replaceLast(chain(6), change);
        expect(signal(h).verdict, act0RecentEvidenceConfirmationNeededV1);
        for (var i = 7; i <= 11; i++) {
          h = append(h, i);
        }
        expect(signal(h).verdict, act0RecentEvidenceVerifiedV1);
      }
    },
  );
  test(
    'known-family invalidation is isolated; unknown identity resets at its position',
    () {
      var h = const Act0LearningEvidenceHistoryV1();
      for (var i = 1; i <= 10; i++) {
        h = append(h, i, other: i.isEven, taskIndex: (i + 1) ~/ 2);
      }
      expect(family(true), isNot(family(false)));
      expect(signal(h).verdict, act0RecentEvidenceVerifiedV1);
      expect(signal(h, other: true).verdict, act0RecentEvidenceVerifiedV1);
      h = append(h, 11);
      h = replaceLast(h, {'authoredSourceFingerprint': 'stale'});
      expect(signal(h).verdict, act0RecentEvidenceConfirmationNeededV1);
      expect(signal(h, other: true).verdict, act0RecentEvidenceVerifiedV1);
      h = append(h, 12);
      h = replaceLast(h, {
        'taskId': 'unresolved',
        'sourceTaskId': 'unresolved',
      });
      expect(
        signal(h, other: true).verdict,
        act0RecentEvidenceConfirmationNeededV1,
      );
      for (var i = 13; i <= 17; i++) {
        h = append(h, i);
      }
      expect(signal(h).verdict, act0RecentEvidenceVerifiedV1);
      expect(
        signal(h, other: true).verdict,
        act0RecentEvidenceConfirmationNeededV1,
      );
    },
  );
  test('future and reversed time do not support current confirmation', () {
    var h = chain(5);
    h = append(h, 6, hours: 240000);
    expect(signal(h).verdict, act0RecentEvidenceConfirmationNeededV1);
    h = append(chain(5), 6, hours: 1);
    expect(signal(h).verdict, act0RecentEvidenceConfirmationNeededV1);
  });
  test('duplicate identity conflict is a fence not an earned response', () {
    final h = chain(5);
    final p = h.records.last.toPayload()
      ..['isCorrect'] = false
      ..['resultKind'] = 'incorrect';
    final conflicting = Act0LearningEvidenceRecordV1.tryParse(p)!;
    expect(
      signal(
        Act0LearningEvidenceHistoryV1(records: [...h.records, conflicting]),
      ).verdict,
      act0RecentEvidenceConfirmationNeededV1,
    );
  });
  test(
    'historical raw cache/counts/schedules remain unchanged by recent reads',
    () {
      final h = chain(5, misses: {1});
      final cache = Act0DurableRetentionHistoryV1.fromLearningEvidence(h);
      final raw = h.toStorageString();
      final saved = cache.toStorageString();
      final m = Act0LearningTransferMeasurementV1.fromLearningEvidence(
        h,
        retentionHistory: cache,
        nowUtc: now,
      );
      expect(m.isRecentEvidence, isTrue);
      expect(h.toStorageString(), raw);
      expect(cache.toStorageString(), saved);
      expect(
        m.signals.every(
          (s) =>
              s.verdict != act0LearningTransferStableV1 &&
              s.verdict != act0LearningTransferImprovingV1,
        ),
        isTrue,
      );
    },
  );
  test(
    'Profile and FixProof share current status while banked repair stays saved',
    () {
      var recovered = replaceLast(append(chain(5), 6), {
        'authoredSourceFingerprint': 'stale',
      });
      final invalidated = recovered;
      for (var i = 7; i <= 11; i++) {
        recovered = append(recovered, i);
      }
      for (final h in [chain(4), chain(5), invalidated, recovered]) {
        final m = Act0LearningTransferMeasurementV1.fromLearningEvidence(
          h,
          nowUtc: now,
        );
        final profile = Act0ProfileEvidenceConsumerV1.fromProjection(
          Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
            h,
            nowUtc: now,
          ),
        );
        final achievements = Act0AchievementSeedProjectionV1.fromSources(
          learningEvidenceHistory: h,
          profileEvidenceProjection:
              Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
                h,
                nowUtc: now,
              ),
        );
        expect(
          achievements
              .seedForId(act0AchievementSeedFirstEvidenceSignalV1)
              .earned,
          isFalse,
        );
        final proof = Act0FixProofProjectionV1.fromSources(
          repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
            outcomes: [
              Act0RepairOutcomeV1(
                sourceTaskId: 'blinds_review',
                repairTaskId: 'blinds_first_actor',
                repairFocusKey: family(false),
                queueItemId: 'q',
                targetWorldId: 'world_1',
                targetLessonId: 'blinds_action_order',
                targetTaskId: 'blinds_first_actor',
                selectedChoiceId: 'utg',
                correctChoiceId: 'utg',
                isCorrect: true,
                outcomeState: act0RepairOutcomeStateCorrectV1,
                sequence: 1,
                sourceType: 'active_repair',
                sessionId: 'old',
              ),
            ],
          ),
          reviewResolutionReceiptHistory: Act0ReviewResolutionReceiptHistoryV1(
            receipts: [
              Act0ReviewResolutionReceiptV1(
                reviewItemId: 'r',
                conceptFamilyId: family(false),
                sourceTaskId: 'blinds_review',
                reviewState: act0ReviewResolutionStateResolvedV1,
                resolutionReason: act0ReviewResolutionReasonRepairSucceededV1,
                repairOutcomeId: 'repair_outcome_v1|1|q',
                resolvedAtOrder: 1,
              ),
            ],
          ),
          transferMeasurement: m,
        );
        expect(proof.aggregate.completedFixCount, 1);
        expect(
          proof.proofs.single.proofState,
          act0FixProofStateRepairCompletedV1,
        );
        expect(
          proof.proofs.single.currentVerificationState,
          profile.signal!.confirmationState,
        );
        expect(
          proof.proofs.single.currentVerificationLine,
          contains(
            (h.records.length == 5 || identical(h, recovered))
                ? 'Recent verified'
                : 'Confirmation needed',
          ),
        );
      }
    },
  );
  test(
    'empty or invalid evidence shows explicit neutral actionable wording',
    () {
      final p = Act0ProfileEvidenceConsumerV1.fromProjection(
        Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
          const Act0LearningEvidenceHistoryV1(),
          nowUtc: now,
        ),
      );
      expect(p.signal!.proofLine, contains('Confirmation needed'));
      expect(p.signal!.proofLine, contains('independent'));
    },
  );
}
