// RSP-01 technical package: honesty of the personalized return reason copy.
// MACHINE-only deterministic checks. Synthetic clock gaps are not Human
// retention proof, and passing copy checks is not full RSP-01 acceptance.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_state_foundation_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// One row of the verified branch table. `successClaim` marks copy that
/// asserts learner progress; such rows must name the evidence that gates them.
class _Row {
  const _Row({
    required this.name,
    required this.reason,
    required this.reasonType,
    required this.evidenceKind,
    required this.priorityClass,
    required this.destination,
    required this.action,
    required this.whyNow,
    required this.copyLine,
    required this.successClaim,
  });

  final String name;
  final Act0PersonalizedReturnReasonV1 reason;
  final String reasonType;
  final String evidenceKind;
  final int priorityClass;
  final String destination;
  final String action;
  final String whyNow;
  final String? copyLine;
  final bool successClaim;
}

final _t0 = DateTime.utc(2026, 1, 1);
final _now = _t0.add(const Duration(days: 1000));

void main() {
  final rows = <_Row>[
    _Row(
      name: 'active unresolved repair',
      reason: Act0PersonalizedReturnReasonV1.fromSources(
        activeRepairIntents: <Act0RepairIntentV1>[_intent()],
      ),
      reasonType: act0ReturnReasonContinueUnresolvedRepairV1,
      evidenceKind: act0ReturnReasonEvidenceActiveRepairV1,
      priorityClass: 0,
      destination: 'review',
      action: 'repair',
      whyNow: 'unfinished_repair',
      copyLine:
          'You missed this clue last time. One more clean rep will keep it '
          'visible.',
      successClaim: false,
    ),
    _Row(
      name: 'repair attempted, not landed',
      reason: Act0PersonalizedReturnReasonV1.fromSources(
        conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
          families: <Act0ConceptFamilyStateV1>[
            _family(act0ConceptFamilyOutcomeRepairNotYetSucceededV1),
          ],
        ),
      ),
      reasonType: act0ReturnReasonRetryNotYetSucceededV1,
      evidenceKind: act0ReturnReasonEvidenceConceptFamilyStateV1,
      priorityClass: 1,
      destination: 'review',
      action: 'retry_repair',
      whyNow: 'repair_not_landed',
      copyLine: 'Your last repair did not land yet. Start there.',
      successClaim: false,
    ),
    _Row(
      name: 'spaced review due now',
      reason: Act0PersonalizedReturnReasonV1.fromSources(
        dueReviewItems: <Act0DueReviewItemV1>[_dueItem()],
      ),
      reasonType: act0ReturnReasonDueReviewV1,
      evidenceKind: act0ReturnReasonEvidenceDurableRetentionV1,
      priorityClass: 2,
      destination: 'review',
      action: 'spaced_review',
      whyNow: 'due_for_review',
      copyLine: 'Review this clue now. It is ready for a spaced check.',
      successClaim: false,
    ),
    _Row(
      name: 'transfer improved (arithmetic measurement only)',
      reason: Act0PersonalizedReturnReasonV1.fromSources(
        transferMeasurement: Act0LearningTransferMeasurementV1(
          signals: <Act0LearningTransferSignalV1>[
            _signal(act0LearningTransferImprovedV1),
          ],
        ),
      ),
      reasonType: act0ReturnReasonReinforceRecentImprovementV1,
      evidenceKind: act0ReturnReasonEvidenceTransferMeasurementV1,
      priorityClass: 3,
      destination: 'learn',
      action: 'reinforce',
      whyNow: 'transfer_evidence',
      copyLine:
          'You handled this clue better on a later hand. Reinforce it once '
          'more.',
      successClaim: true,
    ),
    _Row(
      name: 'transfer held (arithmetic measurement only)',
      reason: Act0PersonalizedReturnReasonV1.fromSources(
        transferMeasurement: Act0LearningTransferMeasurementV1(
          signals: <Act0LearningTransferSignalV1>[
            _signal(act0LearningTransferHeldV1),
          ],
        ),
      ),
      reasonType: act0ReturnReasonReinforceStableTransferV1,
      evidenceKind: act0ReturnReasonEvidenceTransferMeasurementV1,
      priorityClass: 3,
      destination: 'learn',
      action: 'reinforce',
      whyNow: 'transfer_evidence',
      copyLine:
          'You kept this clue steady on a later hand. Reinforce it once more.',
      successClaim: true,
    ),
    _Row(
      name: 'recent focus',
      reason: Act0PersonalizedReturnReasonV1.fromSources(
        conceptFamilyStateHistory: Act0ConceptFamilyStateHistoryV1(
          families: <Act0ConceptFamilyStateV1>[
            _family(act0ConceptFamilyOutcomeMissedV1),
          ],
        ),
      ),
      reasonType: act0ReturnReasonResumeRecentFocusV1,
      evidenceKind: act0ReturnReasonEvidenceConceptFamilyStateV1,
      priorityClass: 4,
      destination: 'learn',
      action: 'resume_focus',
      whyNow: 'recent_focus',
      copyLine: 'Resume your most recent table read.',
      successClaim: false,
    ),
    _Row(
      name: 'recent verified (5 independent spaced responses)',
      reason: _fromRecentHistory(_chain(5)),
      reasonType: act0RecentEvidenceVerifiedV1,
      evidenceKind: act0ReturnReasonEvidenceTransferMeasurementV1,
      priorityClass: 3,
      destination: 'learn',
      action: 'continue',
      whyNow: 'continue_now',
      copyLine: 'Recent verified responses',
      successClaim: true,
    ),
    _Row(
      name: 'recent confirmation needed: too few responses',
      reason: _fromRecentHistory(_chain(4)),
      reasonType: act0RecentEvidenceConfirmationNeededV1,
      evidenceKind: act0ReturnReasonEvidenceTransferMeasurementV1,
      priorityClass: 3,
      destination: 'learn',
      action: 'continue',
      whyNow: 'continue_now',
      copyLine: 'Confirmation needed — complete 5 independent responses.',
      successClaim: false,
    ),
    _Row(
      name: 'recent confirmation needed: same task only',
      reason: _fromRecentHistory(_chain(5, sameTask: true)),
      reasonType: act0RecentEvidenceConfirmationNeededV1,
      evidenceKind: act0ReturnReasonEvidenceTransferMeasurementV1,
      priorityClass: 3,
      destination: 'learn',
      action: 'continue',
      whyNow: 'continue_now',
      copyLine:
          'Confirmation needed — try a different task in another session.',
      successClaim: false,
    ),
    _Row(
      name: 'recent confirmation needed: not spaced',
      reason: _fromRecentHistory(_chain(5, stepHours: 23)),
      reasonType: act0RecentEvidenceConfirmationNeededV1,
      evidenceKind: act0ReturnReasonEvidenceTransferMeasurementV1,
      priorityClass: 3,
      destination: 'learn',
      action: 'continue',
      whyNow: 'continue_now',
      copyLine:
          'Confirmation needed — return after 24 hours for an independent '
          'response.',
      successClaim: false,
    ),
    _Row(
      name: 'no personal evidence',
      reason: Act0PersonalizedReturnReasonV1.fromSources(),
      reasonType: act0ReturnReasonNoPersonalReasonAvailableV1,
      evidenceKind: act0ReturnReasonEvidenceFallbackV1,
      priorityClass: 5,
      destination: 'learn',
      action: 'continue',
      whyNow: 'no_evidence_available',
      copyLine: null,
      successClaim: false,
    ),
  ];

  test('verified branch table matches the source exactly', () {
    for (final row in rows) {
      final r = row.reason;
      expect(r.reasonType, row.reasonType, reason: row.name);
      expect(r.evidenceKind, row.evidenceKind, reason: row.name);
      expect(r.priorityClass, row.priorityClass, reason: row.name);
      expect(r.recommendedDestination, row.destination, reason: row.name);
      expect(r.recommendedAction, row.action, reason: row.name);
      expect(r.whyNowMessageKey, row.whyNow, reason: row.name);
      expect(r.copyLine, row.copyLine, reason: row.name);
    }
  });

  test('a miss in the same history yields the neutral recent focus first', () {
    // On the Preview shape the miss also creates a concept family, so the
    // recent-focus branch outranks the last-miss confirmation line.
    final history = _chain(5, misses: const <int>{5});
    final reason = _fromRecentHistory(history);
    expect(reason.reasonType, act0ReturnReasonResumeRecentFocusV1);
    expect(reason.copyLine, 'Resume your most recent table read.');

    // Contract-only: without a concept family the last-miss line is honest.
    final measurementOnly = Act0PersonalizedReturnReasonV1.fromSources(
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(
            history,
            nowUtc: _now,
          ),
    );
    expect(measurementOnly.reasonType, act0RecentEvidenceConfirmationNeededV1);
    expect(
      measurementOnly.copyLine,
      'Confirmation needed — try another independent response.',
    );
  });

  test('no branch promises winning, money, urgency, penalty or a comeback', () {
    // Meaning-level patterns, not only single banned words: outcome promises,
    // loss-chasing invitations, scarcity/urgency, streak or progress threats.
    final forbidden = <RegExp>[
      RegExp(r'\bwin(s|ning)?\b', caseSensitive: false),
      RegExp(r'\bwon\b', caseSensitive: false),
      RegExp(r'profit|money|bankroll|\$|cash|earn', caseSensitive: false),
      RegExp(r'guarantee|always|never miss|sure thing', caseSensitive: false),
      RegExp(
        r'win (it )?back|get (it|them) back|recover|make up for|'
        r'chase|revenge|tilt',
        caseSensitive: false,
      ),
      RegExp(
        r'hurry|immediately|right now|last chance|before it|'
        r'expire|deadline|urgent|don.t miss|or else',
        caseSensitive: false,
      ),
      RegExp(
        r'lose|losing|lost|penalt|punish|streak|reset|fall behind|'
        r'fail(ed|ure)?\b',
        caseSensitive: false,
      ),
      RegExp(
        r'master(ed|y)?|perfect|forever|solved|gto|solver',
        caseSensitive: false,
      ),
      RegExp(r'\bmust\b|\bhave to\b|\bshould have\b', caseSensitive: false),
    ];
    for (final row in rows) {
      final line = row.copyLine;
      if (line == null) continue;
      for (final pattern in forbidden) {
        expect(
          pattern.hasMatch(line),
          isFalse,
          reason: '${row.name}: "$line" matched ${pattern.pattern}',
        );
      }
    }
  });

  test('success wording appears only on evidence-gated rows', () {
    final successWords = RegExp(
      r'better|steady|verified|landed|fixed|improv|held|kept|mastered|'
      r'correct|right',
      caseSensitive: false,
    );
    for (final row in rows) {
      final line = row.copyLine ?? '';
      expect(
        successWords.hasMatch(line),
        row.successClaim,
        reason: '${row.name}: "$line"',
      );
    }
  });

  test('result quality is never conflated with the hand outcome', () {
    // Return copy talks about the decision (clue, read, repair, response),
    // never about cards dealt, pots, chips or who won the hand.
    final outcomeWords = RegExp(
      r'\bpot\b|chips?|stack|showdown|luck|lucky|unlucky|bad beat|cooler|'
      r'river(ed)?|suck ?out|variance',
      caseSensitive: false,
    );
    for (final row in rows) {
      final line = row.copyLine ?? '';
      expect(outcomeWords.hasMatch(line), isFalse, reason: row.name);
    }
  });

  test('assistance cannot pad the verified line', () {
    var history = _chain(4);
    history = _append(
      history,
      5,
      assistance: Act0DecisionAssistanceV1.quickHint,
    );
    final assisted = _fromRecentHistory(history);
    expect(assisted.reasonType, act0RecentEvidenceConfirmationNeededV1);
    expect(assisted.copyLine, isNot(contains('verified')));

    history = _append(
      history,
      6,
      assistance: Act0DecisionAssistanceV1.theoryRecall,
    );
    expect(_fromRecentHistory(history).copyLine, isNot(contains('verified')));
  });

  test('a stale historical arithmetic verdict is never shown as recent '
      'proof on the Preview measurement', () {
    // Preview builds the measurement with fromLearningEvidence, which only
    // emits recent verdicts. The arithmetic improving/stable rows above are
    // contract-reachable but not produced on the Preview route.
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      _chain(5),
      nowUtc: _now,
    );
    for (final signal in measurement.signals) {
      expect(<String>{
        act0RecentEvidenceVerifiedV1,
        act0RecentEvidenceConfirmationNeededV1,
      }, contains(signal.verdict));
    }
  });

  test('telemetry projection carries no task, session, or concept history', () {
    final allowedKeys = <String>{
      'reason_type',
      'evidence_kind',
      'priority_class',
      'destination',
      'action',
    };
    for (final row in rows) {
      final r = row.reason;
      final telemetry = r.toTelemetryPayload();
      expect(telemetry.keys.toSet(), allowedKeys, reason: row.name);
      final flat = telemetry.values.join('|');
      for (final secret in <String>[
        r.conceptFamilyId,
        r.sourceTaskId,
        r.sourceSessionId,
        r.rawEvidenceRef,
      ]) {
        if (secret.trim().isEmpty) continue;
        expect(flat, isNot(contains(secret)), reason: row.name);
      }
    }
  });

  test('copy never echoes internal identifiers or labels', () {
    for (final row in rows) {
      final r = row.reason;
      final line = r.copyLine ?? '';
      expect(line, isNot(contains('_')), reason: row.name);
      for (final id in <String>[
        r.conceptFamilyId,
        r.sourceTaskId,
        r.sourceSessionId,
      ]) {
        if (id.trim().isEmpty) continue;
        expect(line, isNot(contains(id)), reason: row.name);
      }
      expect(r.toPayload().keys, isNot(contains('copyLine')));
      if (r.reasonType != act0ReturnReasonContinueUnresolvedRepairV1) {
        expect(r.learnerSafeFocusLabel, isEmpty, reason: row.name);
      }
    }
  });
}

Act0PersonalizedReturnReasonV1 _fromRecentHistory(
  Act0LearningEvidenceHistoryV1 history,
) => Act0PersonalizedReturnReasonV1.fromSources(
  // Same source shapes the Preview passes for this evidence history.
  conceptFamilyStateHistory:
      Act0ConceptFamilyStateHistoryV1.fromLearningEvidence(history),
  transferMeasurement: Act0LearningTransferMeasurementV1.fromLearningEvidence(
    history,
    nowUtc: _now,
  ),
  dueReviewItems: Act0DurableRetentionHistoryV1.fromLearningEvidence(
    history,
  ).dueItemsAt(_now),
);

// Authored-evidence fixture pattern shared with
// act0_asm07_recent_epoch_semantics_test.dart.
Act0LessonTaskV1 _task(int i, {bool sameTask = false}) => Act0ShellStateV1
    .sample
    .lessonById('blinds_action_order')
    .taskList
    .singleWhere(
      (t) =>
          t.taskId ==
          (i.isEven && !sameTask ? 'blinds_first_actor' : 'blinds_review'),
    );

Act0LearningEvidenceHistoryV1 _append(
  Act0LearningEvidenceHistoryV1 h,
  int i, {
  bool correct = true,
  bool sameTask = false,
  int? hours,
  Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
}) {
  final source = _task(i, sameTask: sameTask);
  final selected = source.runner.options.firstWhere(
    (o) => o.isCorrect == correct,
  );
  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: source.runner,
    option: selected,
    taskFamily: source.resolvedTaskFamily,
  )!;
  return h.appendCompletedDecision(
    Act0CompletedDecisionV1(
      attemptKey: 'rsp01|$i',
      worldId: 'world_1',
      lessonId: 'blinds_action_order',
      taskId: source.taskId,
      sourceTaskId: source.taskId,
      decisionKind: Act0CompletedDecisionKindV1.seat,
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
      lessonId: 'blinds_action_order',
      task: source,
    )!,
    sessionId: 'rsp01_session|$i',
    recordedAtUtc: _t0.add(Duration(hours: hours ?? i * 24)),
    reviewKind: Act0ReviewKindV1.spacedReview,
  );
}

Act0LearningEvidenceHistoryV1 _chain(
  int count, {
  bool sameTask = false,
  int stepHours = 24,
  Set<int> misses = const <int>{},
}) {
  var h = const Act0LearningEvidenceHistoryV1();
  for (var i = 1; i <= count; i++) {
    h = _append(
      h,
      i,
      sameTask: sameTask,
      hours: i * stepHours,
      correct: !misses.contains(i),
    );
  }
  return h;
}

Act0ConceptFamilyStateV1 _family(String outcome) => Act0ConceptFamilyStateV1(
  conceptFamilyId: 'no_bet_yet',
  worldId: 'world_1',
  lastSeenAt: 4,
  lastAttemptAt: outcome == act0ConceptFamilyOutcomeMissedV1 ? null : 4,
  missCount: 1,
  repairAttemptCount: outcome == act0ConceptFamilyOutcomeMissedV1 ? 0 : 1,
  successfulRepairCount: 0,
  lastOutcome: outcome,
  lastTaskId: 'actions_check_drill',
  lastSessionId: 'rsp01_session|4',
);

Act0DueReviewItemV1 _dueItem() => Act0DueReviewItemV1(
  conceptFamilyId: 'no_bet_yet',
  worldId: 'world_1',
  lessonId: 'fold_check_call_raise',
  taskId: 'actions_check_drill',
  nextDueAtUtc: DateTime.utc(2026, 11, 1),
  repeatedMissCount: 1,
  lapseCount: 0,
);

Act0LearningTransferSignalV1 _signal(String verdict) =>
    Act0LearningTransferSignalV1(
      conceptFamilyId: 'no_bet_yet',
      relationship: act0LearningTransferSameFamilyTransferV1,
      verdict: verdict,
      baselineOrder: 1,
      comparisonOrder: 4,
      baselineTaskId: 'actions_legal_context',
      comparisonTaskId: 'actions_check_drill',
      baselineSessionId: 'rsp01_session|1',
      comparisonSessionId: 'rsp01_session|4',
      baselineDecisionTimeBucket: '3_to_10s',
      comparisonDecisionTimeBucket: '3_to_10s',
    );

Act0RepairIntentV1 _intent() => const Act0RepairIntentV1(
  sourceWorldId: 'world_1',
  sourceLessonId: 'fold_check_call_raise',
  sourceTaskId: 'actions_legal_context',
  choiceId: 'fold',
  result: 'incorrect',
  errorType: 'misread_action_legality',
  missedSignalId: 'no_bet_yet',
  missedSignalLabel: 'Nobody has bet yet',
  skillAtomId: 'action_read',
  skillLabel: 'Action read',
  targetWorldId: 'world_1',
  targetLessonId: 'fold_check_call_raise',
  targetTaskId: 'actions_check_drill',
  mappingType: 'same_signal',
  reasonCode: 'same_signal_action_read_no_bet_yet',
);
