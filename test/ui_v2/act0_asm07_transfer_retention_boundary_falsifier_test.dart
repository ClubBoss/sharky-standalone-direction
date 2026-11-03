// MACHINE simulations only: synthetic clock gaps are not Human retention proof.
import 'dart:convert';
import 'dart:io';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const lesson = 'blinds_action_order';
final family = act0FirstValueSkillReceiptForRunnerV1(
  runner: current.runner,
  option: current.runner.options.first,
  taskFamily: current.resolvedTaskFamily,
)!.sourceSignalId;
final t0 = DateTime.utc(2026, 1, 1);
Act0LessonTaskV1 task(String id) => Act0ShellStateV1.sample
    .lessonById(lesson)
    .tasks
    .singleWhere((t) => t.taskId == id);
String fingerprint(Act0LessonTaskV1 t) => act0AuthoredSourceFingerprintV1(
  worldId: 'world_1',
  lessonId: lesson,
  task: t,
)!;
Act0LessonTaskV1 withRunner(Act0LessonTaskV1 t, Act0RunnerStateV1 r) =>
    Act0LessonTaskV1(
      taskId: t.taskId,
      title: t.title,
      phase: t.phase,
      runner: r,
      rewardXp: t.rewardXp,
      stepKind: t.stepKind,
      taskFamily: t.taskFamily,
      tablePresentation: t.tablePresentation,
      summary: t.summary,
      lockedSummary: t.lockedSummary,
    );
final current = task('blinds_review');
final oldBbSource = withRunner(
  current,
  current.runner.copyWith(
    options: [
      const Act0RunnerOptionV1(
        id: 'bb',
        label: 'BB',
        seatId: 'bb',
        isCorrect: true,
        preferredLabel: 'BB',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'Old BB key',
        feedbackReason: 'Historical authored BB key',
      ),
      for (final o in current.runner.options)
        Act0RunnerOptionV1(
          id: o.id,
          label: o.label,
          preferredLabel: o.preferredLabel,
          feedbackTitle: o.feedbackTitle,
          seatId: o.seatId,
          isCorrect: o.id == 'bb',
          quality: o.id == 'bb'
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
          feedbackReason: o.feedbackReason,
        ),
    ],
  ),
);
Act0LearningEvidenceRecordV1 record(
  int order,
  int hour, {
  String taskId = 'blinds_review',
  String choice = 'utg',
  bool correct = true,
  String? sourceFingerprint,
  Act0ReviewKindV1 kind = Act0ReviewKindV1.spacedReview,
  Act0DecisionAssistanceV1 help = Act0DecisionAssistanceV1.none,
}) => Act0LearningEvidenceRecordV1(
  recordId: 'asm07_boundary|$order',
  createdOrder: order,
  worldId: 'world_1',
  lessonId: lesson,
  taskId: taskId,
  sourceTaskId: taskId,
  choiceId: choice,
  expectedChoiceId: sourceFingerprint == fingerprint(oldBbSource)
      ? 'bb'
      : 'utg',
  isCorrect: correct,
  errorType: correct ? 'none' : 'missed_action_read',
  conceptFamilyId: family,
  repairFocusId: family,
  skillAtomId: 'table_read',
  decisionTimeBucket: '3_to_10s',
  resultKind: correct ? 'correct' : 'incorrect',
  sessionId: 'machine_session_$order',
  recordedAtUtc: t0.add(Duration(hours: hour)),
  reviewKind: kind,
  assistanceKind: help,
  authoredSourceFingerprint: sourceFingerprint ?? fingerprint(task(taskId)),
);
Act0LearningEvidenceHistoryV1 history(
  List<Act0LearningEvidenceRecordV1> records,
) => Act0LearningEvidenceHistoryV1(records: records);
String verdict(
  Act0LearningEvidenceHistoryV1 h, [
  Act0DurableRetentionHistoryV1? cache,
]) => Act0LearningTransferMeasurementV1.fromLearningEvidence(
  h,
  retentionHistory: cache,
  nowUtc: t0.add(const Duration(hours: 96)),
).signalForConcept(family).verdict;
List<Act0LearningEvidenceRecordV1> durableRecords({
  bool stale = false,
  String? conditionFingerprint,
}) => [
  record(
    1,
    0,
    choice: 'btn',
    correct: false,
    kind: Act0ReviewKindV1.initialAssessment,
  ),
  record(
    2,
    0,
    choice: stale ? 'bb' : 'utg',
    sourceFingerprint: stale ? fingerprint(oldBbSource) : conditionFingerprint,
    kind: Act0ReviewKindV1.immediateRepair,
  ),
  record(
    3,
    24,
    choice: stale ? 'bb' : 'utg',
    sourceFingerprint: stale ? fingerprint(oldBbSource) : conditionFingerprint,
  ),
  record(
    4,
    96,
    choice: stale ? 'bb' : 'utg',
    sourceFingerprint: stale ? fingerprint(oldBbSource) : conditionFingerprint,
  ),
];
void main() {
  test(
    'fresh completion append path builds complete current retention proof',
    () {
      var h = const Act0LearningEvidenceHistoryV1();
      for (final r in durableRecords()) {
        final source = task(r.taskId);
        final selected = source.runner.options.singleWhere(
          (o) => o.id == r.choiceId,
        );
        final receipt = act0FirstValueSkillReceiptForRunnerV1(
          runner: source.runner,
          option: selected,
          taskFamily: source.resolvedTaskFamily,
        )!;
        h = h.appendCompletedDecision(
          Act0CompletedDecisionV1(
            attemptKey: r.recordId,
            worldId: 'world_1',
            lessonId: lesson,
            taskId: r.taskId,
            sourceTaskId: r.taskId,
            decisionKind: Act0CompletedDecisionKindV1.seat,
            selectedId: selected.id,
            expectedId: 'utg',
            isCorrect: selected.isCorrect,
            decisionTimeBucket: '3_to_10s',
            taskFamily: source.resolvedTaskFamily,
            resultKind: selected.isCorrect ? 'correct' : 'incorrect',
            errorType: selected.isCorrect ? 'none' : 'missed_action_read',
            skillAtomId: receipt.skillAtomId,
            repairFocusId: receipt.sourceSignalId,
            assistanceKind: Act0DecisionAssistanceV1.none,
          ),
          authoredSourceFingerprint: fingerprint(source),
          sessionId: r.sessionId,
          recordedAtUtc: r.recordedAtUtc,
          reviewKind: r.reviewKind,
        );
      }
      final current = act0CompleteCurrentAuthoredEvidenceV1(h);
      expect(current.records, hasLength(4));
      expect(
        Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
          h,
          nowUtc: t0.add(const Duration(hours: 96)),
        ).familyById(family)?.retentionState,
        Act0RetentionStateV1.durable,
      );
      expect(
        Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
          h,
          nowUtc: t0.add(const Duration(days: 20)),
        ).familyById(family)?.retentionState,
        Act0RetentionStateV1.due,
      );
    },
  );
  test(
    'distinct original repair source is not silently accepted as attempted identity',
    () {
      final payload = record(1, 0).toPayload();
      payload['sourceTaskId'] = 'blinds_first_actor';
      expect(
        act0CompleteCurrentAuthoredEvidenceV1(
          history([Act0LearningEvidenceRecordV1.tryParse(payload)!]),
        ).records,
        isEmpty,
      );
    },
  );

  test('production consumers cannot use unverified fixture entrypoint', () {
    final uses = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) =>
              f.path.endsWith('.dart') &&
              f.path.replaceAll('\\', '/') !=
                  'lib/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart',
        )
        .where(
          (f) => f.readAsStringSync().contains(
            'Act0LearningTransferMeasurementV1.fromUnverifiedEvidenceForTests',
          ),
        )
        .map((f) => f.path)
        .toList();
    expect(uses, isEmpty);
  });
  test(
    'complete compatible chain survives evidence serialization and current projection',
    () {
      final h = Act0LearningEvidenceHistoryV1.tryParseStorageString(
        history(durableRecords()).toStorageString(),
      )!;
      expect(
        Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
          h,
          nowUtc: t0.add(const Duration(hours: 96)),
        ).familyById(family)?.retentionState,
        Act0RetentionStateV1.durable,
      );
    },
  );
  test(
    'current observation preserves exact history and historical due schedule',
    () {
      final h = history(durableRecords(stale: true));
      final raw = h.toStorageString();
      final historical = Act0DurableRetentionHistoryV1.fromLearningEvidence(h);
      final cache = historical.toStorageString();
      final due = historical
          .dueItemsAt(t0.add(const Duration(days: 20)))
          .map((x) => x.taskId)
          .toList();
      verdict(h, historical);
      Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
        h,
        nowUtc: t0.add(const Duration(hours: 96)),
      );
      expect(h.toStorageString(), raw);
      expect(historical.toStorageString(), cache);
      expect(historical.familyById(family)?.incorrectCount, 1);
      expect(historical.familyById(family)?.correctCount, 3);
      expect(
        historical
            .dueItemsAt(t0.add(const Duration(days: 20)))
            .map((x) => x.taskId),
        due,
      );
    },
  );
  test(
    'missing earlier dependency fails closed despite complete-lineage flag',
    () {
      final h = history(durableRecords().skip(1).toList());
      expect(h.hasCompleteLineage, isTrue);
      expect(
        Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
          h,
          nowUtc: t0.add(const Duration(hours: 96)),
        ).families,
        isEmpty,
      );
    },
  );
  test('conflicting duplicate identity fails closed', () {
    final records = durableRecords();
    final h = Act0LearningEvidenceHistoryV1(
      records: records,
      sourceAnchors: [record(2, 0, choice: 'btn', correct: false)],
    );
    expect(act0CompleteCurrentAuthoredEvidenceV1(h).records, isEmpty);
  });
  test(
    'later incompatible event cannot resurrect older stable proof under forged family',
    () {
      final stale = record(
        3,
        48,
        choice: 'bb',
        sourceFingerprint: fingerprint(oldBbSource),
      ).toPayload();
      stale['conceptFamilyId'] = 'forged_other_family';
      final h = history([
        record(1, 0, taskId: 'blinds_first_actor'),
        record(2, 24),
        Act0LearningEvidenceRecordV1.tryParse(stale)!,
      ]);
      expect(verdict(h), isNot(act0LearningTransferStableV1));
      expect(verdict(h), act0RecentEvidenceConfirmationNeededV1);
    },
  );
  test(
    'valid fingerprint recomputes grade instead of trusting stored grade',
    () {
      final h = history([
        record(1, 0, taskId: 'blinds_first_actor'),
        record(2, 24),
        record(3, 48, taskId: 'blinds_first_actor'),
        record(4, 72),
        record(5, 96, correct: false),
      ]);
      expect(verdict(h), act0RecentEvidenceVerifiedV1);
      expect(h.records.last.isCorrect, isFalse);
    },
  );
  test('unknown assistance cannot yield positive current proof', () {
    final h = history([
      record(1, 0, taskId: 'blinds_first_actor'),
      record(2, 24, help: Act0DecisionAssistanceV1.legacyUnknown),
    ]);
    expect(verdict(h), isNot(act0LearningTransferStableV1));
    expect(verdict(h), act0RecentEvidenceConfirmationNeededV1);
  });
  test(
    'evicted lifetime retention chain stays unavailable after fresh append',
    () {
      var h = const Act0LearningEvidenceHistoryV1();
      for (final r in durableRecords()) {
        h = h.append(r);
      }
      for (var i = 5; i < 210; i++) {
        h = h.append(record(i, i * 100, taskId: 'blinds_first_actor'));
      }
      expect(act0CompleteCurrentAuthoredEvidenceV1(h).records, isEmpty);
      h = h.append(record(210, 21000));
      expect(act0CompleteCurrentAuthoredEvidenceV1(h).records, isEmpty);
      expect(
        Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
          h,
          nowUtc: t0.add(const Duration(hours: 96)),
        ).families,
        isEmpty,
      );
    },
  );

  test(
    'F6 stale BB transfer must not drive personalized current reinforcement',
    () {
      final h = history([
        record(
          1,
          0,
          taskId: 'blinds_first_actor',
          choice: 'btn',
          correct: false,
        ),
        record(
          2,
          24,
          choice: 'bb',
          sourceFingerprint: fingerprint(oldBbSource),
        ),
      ]);
      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        transferMeasurement:
            Act0LearningTransferMeasurementV1.fromLearningEvidence(h),
      );
      expect(
        reason.reasonType,
        isNot(act0ReturnReasonReinforceRecentImprovementV1),
      );
    },
  );
  test('F7 stale BB transfer must not upgrade banked historical fix', () {
    final h = history([
      record(1, 0, taskId: 'blinds_first_actor', choice: 'btn', correct: false),
      record(2, 24, choice: 'bb', sourceFingerprint: fingerprint(oldBbSource)),
    ]);
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
        outcomes: [
          Act0RepairOutcomeV1(
            sourceTaskId: 'blinds_first_actor',
            repairTaskId: 'blinds_review',
            repairFocusKey: family,
            queueItemId: 'asm07_queue',
            targetWorldId: 'world_1',
            targetLessonId: lesson,
            targetTaskId: 'blinds_review',
            selectedChoiceId: 'utg',
            correctChoiceId: 'utg',
            isCorrect: true,
            outcomeState: act0RepairOutcomeStateCorrectV1,
            sequence: 0,
            sourceType: 'active_repair',
            sessionId: 'banked_session',
          ),
        ],
      ),
      reviewResolutionReceiptHistory: Act0ReviewResolutionReceiptHistoryV1(
        receipts: [
          Act0ReviewResolutionReceiptV1(
            reviewItemId: 'asm07_review',
            conceptFamilyId: family,
            sourceTaskId: 'blinds_first_actor',
            sourceSessionId: 'banked_session',
            reviewState: act0ReviewResolutionStateResolvedV1,
            resolutionReason: act0ReviewResolutionReasonRepairSucceededV1,
            repairOutcomeId: 'repair_outcome_v1|0|asm07_queue',
            resolvedAtOrder: 0,
          ),
        ],
      ),
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(h),
    );
    expect(projection.aggregate.completedFixCount, 1);
    expect(projection.aggregate.reinforcedFixCount, 0);
  });
  test('control compaction keeps first facts but not all spaced witnesses', () {
    var h = const Act0LearningEvidenceHistoryV1();
    for (final r in durableRecords()) {
      h = h.append(r);
    }
    final oldCache = Act0DurableRetentionHistoryV1.fromLearningEvidence(h);
    for (var i = 5; i < 210; i++) {
      h = h.append(record(i, i * 100, taskId: 'blinds_first_actor'));
    }
    h = Act0LearningEvidenceHistoryV1.tryParseStorageString(
      h.toStorageString(),
    )!;
    expect(h.records.length, 200);
    expect(
      h.provenanceRecords.any((r) => r.recordId == 'asm07_boundary|1'),
      isTrue,
    );
    expect(
      h.provenanceRecords.any((r) => r.recordId == 'asm07_boundary|2'),
      isTrue,
    );
    expect(
      h.provenanceRecords.any((r) => r.recordId == 'asm07_boundary|3'),
      isFalse,
    );
    expect(
      h.provenanceRecords.any((r) => r.recordId == 'asm07_boundary|4'),
      isFalse,
    );
    expect(
      oldCache.familyById(family)?.retentionState,
      Act0RetentionStateV1.durable,
    );
  });

  test('control current source rejects self-consistent old BB fingerprint', () {
    expect(current.runner.options.singleWhere((o) => o.isCorrect).id, 'utg');
    final r = record(
      1,
      0,
      choice: 'bb',
      sourceFingerprint: fingerprint(oldBbSource),
    );
    expect(oldBbSource.runner.options.singleWhere((o) => o.isCorrect).id, 'bb');
    expect(r.isCorrect, isTrue);
    expect(r.expectedChoiceId, 'bb');
    expect(act0CurrentAuthoredSourceProofV1(r), isNull);
  });
  test('F1 stale BB correct cannot produce current improving', () {
    final h = history([
      record(1, 0, taskId: 'blinds_first_actor', choice: 'btn', correct: false),
      record(2, 24, choice: 'bb', sourceFingerprint: fingerprint(oldBbSource)),
    ]);
    final before = h.toStorageString();
    expect(verdict(h), isNot(act0LearningTransferImprovingV1));
    expect(verdict(h), act0RecentEvidenceConfirmationNeededV1);
    expect(h.toStorageString(), before);
  });
  test('F2 stale BB correct cannot produce current stable', () {
    final h = history([
      record(1, 0, taskId: 'blinds_first_actor'),
      record(2, 24, choice: 'bb', sourceFingerprint: fingerprint(oldBbSource)),
    ]);
    expect(verdict(h), isNot(act0LearningTransferStableV1));
    expect(verdict(h), act0RecentEvidenceConfirmationNeededV1);
  });
  test(
    'F3 stale BB recovery plus two spaced successes cannot become durable',
    () {
      final h = history(durableRecords(stale: true));
      expect(
        Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
          h,
          nowUtc: t0.add(const Duration(hours: 96)),
        ).familyById(family)?.retentionState,
        isNot(Act0RetentionStateV1.durable),
      );
    },
  );
  test(
    'F4 persisted historical cache cannot upgrade current nonspaced successes',
    () {
      final cache = Act0DurableRetentionHistoryV1.tryParse(
        jsonDecode(
          Act0DurableRetentionHistoryV1.fromLearningEvidence(
            history(durableRecords(stale: true)),
          ).toStorageString(),
        ),
      );
      final h = history([
        record(
          1,
          120,
          taskId: 'blinds_first_actor',
          choice: 'btn',
          correct: false,
        ),
        record(2, 145, taskId: 'blinds_first_actor'),
        record(3, 146),
      ]);
      expect(
        Act0LearningTransferMeasurementV1.fromUnverifiedEvidenceForTests(
          h,
        ).signalForConcept(family).verdict,
        act0LearningTransferImprovingV1,
      );
      expect(verdict(h, cache), isNot(act0LearningTransferStableV1));
      expect(verdict(h, cache), act0RecentEvidenceConfirmationNeededV1);
    },
  );
  test(
    'F5 changed conditions with same answer IDs cannot retain durable proof',
    () {
      final oldCondition = withRunner(
        current,
        current.runner.copyWith(
          question: '${current.runner.question} old condition',
        ),
      );
      expect(
        oldCondition.runner.options.map((o) => o.id),
        current.runner.options.map((o) => o.id),
      );
      final records = durableRecords(
        conditionFingerprint: fingerprint(oldCondition),
      );
      expect(act0CurrentAuthoredSourceProofV1(records.last), isNull);
      expect(
        Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
          history(records),
          nowUtc: t0.add(const Duration(hours: 96)),
        ).familyById(family)?.retentionState,
        isNot(Act0RetentionStateV1.durable),
      );
    },
  );
  test('control fresh compatible unassisted records remain useful', () {
    final records = durableRecords();
    for (final r in records) {
      expect(act0CurrentAuthoredSourceProofV1(r), isNotNull);
    }
    expect(
      Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
        history(records),
        nowUtc: t0.add(const Duration(hours: 96)),
      ).familyById(family)?.retentionState,
      Act0RetentionStateV1.durable,
    );
    // Current confirmation is a narrower recent-response claim, not the old
    // two-event improving/stable classification. Five authentic current-source
    // responses meet the approved shared predicate without fabricated debt.
    expect(
      verdict(
        history([
          record(1, 0, taskId: 'blinds_first_actor'),
          record(2, 24),
          record(3, 48, taskId: 'blinds_first_actor'),
          record(4, 72),
          record(5, 96),
        ]),
      ),
      act0RecentEvidenceVerifiedV1,
    );
    expect(
      verdict(
        history([record(1, 0, taskId: 'blinds_first_actor'), record(2, 24)]),
      ),
      act0RecentEvidenceConfirmationNeededV1,
    );
  });
  test('control assistance stays excluded from fresh positive retention', () {
    final records = [
      record(1, 0, choice: 'btn', correct: false),
      for (var i = 2; i <= 4; i++)
        record(i, (i - 2) * 96, help: Act0DecisionAssistanceV1.quickHint),
    ];
    expect(
      Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
        history(records),
        nowUtc: t0.add(const Duration(hours: 96)),
      ).familyById(family)?.retentionState,
      Act0RetentionStateV1.needsRepair,
    );
  });
}
