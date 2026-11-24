import 'act0_action_reason_v1.dart';
import 'act0_number_entry_runner_v1.dart';
import 'dart:convert';
import 'act0_predecision_card_focus_v1.dart';
import 'act0_prechoice_answer_cue_policy_v1.dart';

import 'act0_completed_decision_contract_v1.dart';

import 'package:crypto/crypto.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Fingerprints authored task semantics for current capability evidence.
/// Presentation-only option labels and order are deliberately excluded.
String? act0AuthoredSourceFingerprintV1({
  required String worldId,
  required String lessonId,
  required Act0LessonTaskV1 task,
}) {
  if (worldId.trim().isEmpty ||
      lessonId.trim().isEmpty ||
      task.taskId.trim().isEmpty) {
    return null;
  }
  final table = task.runner.table;
  final sizingPresets = task.runner.sizingConfig.presets.toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  final optionSemantics =
      task.runner.options
          .map(
            (option) => <Object?>[
              option.id,
              option.isCorrect,
              option.quality.name,
              option.amountLabel,
              option.feedbackReason,
              option.seatId,
              option.repairFocusSeatIds.toList()..sort(),
              option.repairFocusCardIds.toList()..sort(),
              option.repairFocusLabels.toList()..sort(),
            ],
          )
          .toList()
        ..sort((a, b) => (a[0] as String).compareTo(b[0] as String));
  final cardFocusRevision = act0PredecisionCardFocusSourceRevisionV1(task);
  final answerCueRevision = act0PrechoiceAnswerCueSourceRevisionV1(
    task,
    lessonId: lessonId,
  );
  final payload = <Object?>[
    'act0_authored_source_v1',
    if (cardFocusRevision != null) cardFocusRevision,
    if (answerCueRevision != null) answerCueRevision,
    worldId,
    lessonId,
    task.taskId,
    task.phase.name,
    task.stepKind.name,
    if (task.guidedDecision) 'guided_decision_v1',
    task.resolvedTaskFamily.name,
    task.tablePresentation.name,
    task.runner.lessonId,
    task.runner.lessonTitle,
    task.runner.caption,
    task.runner.hint,
    task.runner.question,
    task.runner.feedbackReason,
    task.runner.feedbackSignalId,
    task.runner.sizingConfig.mode.name,
    task.runner.sizingConfig.showGuidance,
    <Object?>[
      for (final preset in sizingPresets)
        <Object?>[preset.id, preset.potFraction, preset.isPrimary],
    ],
    _authoredTablePayloadV1(table),
    optionSemantics,
    if (task.multiStreet case final hand?)
      [
        Act0MultiStreetV1.taskType,
        for (final decision in hand.decisions)
          [
            decision.caption,
            decision.question,
            decision.table.handTimelinePrefix!.toPayload(),
            for (final option in decision.options)
              [option.id, option.quality.name, option.feedbackReason],
          ],
      ],
    if (table.decisionSeatId != null)
      <Object?>['decision_actor_v1', table.decisionSeatId],
  ];
  return sha256.convert(utf8.encode(jsonEncode(payload))).toString();
}

/// Binds the actual table captured at submission to its authored counterpart.
String act0ReplayTableFingerprintV1(Act0TableStateV1 table) => sha256
    .convert(utf8.encode(jsonEncode(_authoredTablePayloadV1(table))))
    .toString();

List<Object?> _authoredTablePayloadV1(Act0TableStateV1 table) => <Object?>[
  table.scope.name,
  table.tableFormat.name,
  table.playerCount,
  table.density.name,
  table.streetLabel,
  table.potLabel,
  table.toCallLabel,
  table.centerLabel,
  table.focusCalloutLabel,
  table.emptyBoardLabel,
  table.activeSeatId,
  table.heroSeatId,
  for (final seat in table.seats)
    <Object?>[
      seat.seatId,
      seat.seatLabel,
      seat.displayName,
      seat.isHero,
      seat.isDealerButton,
      seat.isSmallBlind,
      seat.isBigBlind,
      seat.blindAmountLabel,
      seat.isActive,
      seat.isTarget,
      seat.isInHand,
      seat.isFolded,
      seat.hasActed,
      seat.isLastAggressor,
      seat.isOccupied,
      seat.stackLabel,
      seat.currentBetLabel,
      seat.cardsVisibleMode.name,
      _cards(seat.holeCards),
      seat.bet == null
          ? null
          : <Object?>[
              seat.bet!.kind.name,
              seat.bet!.label,
              seat.bet!.amountLabel,
            ],
    ],
  _cards(table.heroCards),
  _cards(table.boardCards),
  for (final action in table.actionTrail)
    <Object?>[action.kind.name, action.label],
  table.selectableSeatIds.toList()..sort(),
];

/// Resolves only the recorded table revision. A legacy journal can still play
/// as text when no decision-time table fingerprint was captured.
Act0TableStateV1? act0VerifiedReplayTableV1(
  Act0LearningEvidenceRecordV1 record,
  String? tableFingerprint,
) {
  if (tableFingerprint == null) return null;
  final task = _resolveTask(record.worldId, record.lessonId, record.taskId);
  if (task == null ||
      act0AuthoredSourceFingerprintV1(
            worldId: record.worldId,
            lessonId: record.lessonId,
            task: task,
          ) !=
          record.authoredSourceFingerprint) {
    return null;
  }
  final hand = task.multiStreet;
  final table = hand == null
      ? task.runner.table
      : hand.decisions
            .where(
              (decision) => decision.options.any(
                (option) => option.id == record.choiceId,
              ),
            )
            .firstOrNull
            ?.table;
  if (table == null) return null;
  return act0ReplayTableFingerprintV1(table) == tableFingerprint ? table : null;
}

/// Full semantic revision of the actual existing diagnostic factory output.
/// The temporary task is a hash view only: source IDs/role/XP are never changed.
/// Full semantic revision of the actual existing diagnostic factory output.
/// The temporary task is a hash view only: source IDs/role/XP are never changed.
String? act0PlacementDiagnosticFingerprintV1({
  required String worldId,
  required String lessonId,
  required String diagnosticVariantId,
  required Act0LessonTaskV1 sourceTask,
  required Act0RunnerStateV1 diagnosticRunner,
}) {
  if (!const {
    'board_private_cards',
    'action_basics',
  }.contains(diagnosticVariantId))
    return null;
  final base = act0AuthoredSourceFingerprintV1(
    worldId: worldId,
    lessonId: lessonId,
    task: sourceTask,
  );
  final variant = act0AuthoredSourceFingerprintV1(
    worldId: worldId,
    lessonId: lessonId,
    task: Act0LessonTaskV1(
      taskId: sourceTask.taskId,
      title: sourceTask.title,
      phase: sourceTask.phase,
      runner: diagnosticRunner,
      rewardXp: sourceTask.rewardXp,
      stepKind: sourceTask.stepKind,
      taskFamily: sourceTask.taskFamily,
      tablePresentation: sourceTask.tablePresentation,
      summary: sourceTask.summary,
      lockedSummary: sourceTask.lockedSummary,
    ),
  );
  if (base == null || variant == null) return null;
  // Canonical assessment fingerprints omit presentation labels. Diagnostic
  // choice labels carry the misconception itself, so bind them here only.
  final choices =
      diagnosticRunner.options
          .map(
            (o) => <Object?>[
              o.id,
              o.label,
              o.isCorrect,
              o.quality.name,
              o.preferredLabel,
              o.betterAnswerLabel,
              o.feedbackTitle,
              o.feedbackReason,
              o.amountLabel,
              o.seatId,
              o.repairFocusSeatIds.toList()..sort(),
              o.repairFocusCardIds.toList()..sort(),
              o.repairFocusLabels.toList()..sort(),
            ],
          )
          .toList()
        ..sort((a, b) => (a.first as String).compareTo(b.first as String));
  return sha256
      .convert(
        utf8.encode(
          jsonEncode([
            'act0_placement_diagnostic_variant_v1',
            diagnosticVariantId,
            base,
            variant,
            'placement',
            diagnosticRunner.beatIndex,
            diagnosticRunner.beatCount,
            diagnosticRunner.lessonId,
            diagnosticRunner.lessonTitle,
            diagnosticRunner.lessonSubtitle,
            diagnosticRunner.caption,
            diagnosticRunner.hint,
            diagnosticRunner.question,
            diagnosticRunner.feedbackTitle,
            diagnosticRunner.feedbackReason,
            choices,
          ]),
        ),
      )
      .toString();
}

String? act0CurrentAuthoredSourceFingerprintForIdentityV1({
  required String worldId,
  required String lessonId,
  required String taskId,
}) {
  final task = _resolveTask(worldId, lessonId, taskId);
  if (task == null) return null;
  return act0AuthoredSourceFingerprintV1(
    worldId: worldId,
    lessonId: lessonId,
    task: task,
  );
}

/// Study has a separate revision because assessment fingerprints deliberately
/// omit teaching rails. Reuse the same table fingerprint for each teaching scene.
String? act0AuthoredStudyRevisionV1({
  required String worldId,
  required String lessonId,
  required Act0LessonTaskV1 task,
}) {
  if (task.phase != Act0LessonPhaseV1.theory) return null;
  final base = act0AuthoredSourceFingerprintV1(
    worldId: worldId,
    lessonId: lessonId,
    task: task,
  );
  if (base == null) return null;
  return sha256
      .convert(
        utf8.encode(
          jsonEncode([
            'act0_study_source_v1',
            base,
            task.title,
            for (final step in task.runner.teachingSteps)
              [
                step.title,
                step.body,
                step.ctaLabel,
                step.identityTeachingSemantics.name,
                step.focusSeatIds,
                step.focusCardIds,
                step.focusLabels,
                if (step.table != null)
                  act0AuthoredSourceFingerprintV1(
                    worldId: worldId,
                    lessonId: lessonId,
                    task: Act0LessonTaskV1(
                      taskId: task.taskId,
                      title: task.title,
                      phase: task.phase,
                      runner: task.runner.copyWith(table: step.table),
                      rewardXp: task.rewardXp,
                      stepKind: task.stepKind,
                      taskFamily: task.taskFamily,
                      tablePresentation: task.tablePresentation,
                    ),
                  ),
              ],
          ]),
        ),
      )
      .toString();
}

/// Exact authored topic only. A study receipt does not establish a skill map,
/// comprehension, current correctness, unseen transfer or retention.
String? act0CurrentStudyTopicV1(Act0StudyObservationV1 observation) {
  final task = _resolveTask(
    observation.worldId,
    observation.lessonId,
    observation.taskId,
  );
  if (task == null ||
      observation.sourceRevision !=
          act0AuthoredStudyRevisionV1(
            worldId: observation.worldId,
            lessonId: observation.lessonId,
            task: task,
          ))
    return null;
  return task.title;
}

List<Object?> _cards(Iterable<Act0CardStateV1> cards) => [
  for (final card in cards) <Object?>[card.rank, card.suit],
];

bool _isAuthoredTeachingTaskV1(Act0LessonTaskV1 task) =>
    task.phase == Act0LessonPhaseV1.theory ||
    task.resolvedTaskFamily == Act0TaskFamilyV1.learn;

/// Classifies an old receipt without rewriting its grade, help or lineage.
/// Teaching choices are observations, never independent assessment samples.
bool act0RecordIsAuthoredTeachingV1(Act0LearningEvidenceRecordV1 record) {
  final task = _resolveTask(record.worldId, record.lessonId, record.taskId);
  return task != null && _isAuthoredTeachingTaskV1(task);
}

/// Resolves the record against today's authored source and recomputes its
/// current answer/skill semantics. Stored grade and skill fields are ignored.
Act0CurrentAuthoredSourceProofV1? act0CurrentAuthoredSourceProofV1(
  Act0LearningEvidenceRecordV1 record,
) {
  final task = _resolveTask(record.worldId, record.lessonId, record.taskId);
  if (task == null) return null;
  return act0CurrentAuthoredSourceProofForTaskV1(
    record: record,
    worldId: record.worldId,
    lessonId: record.lessonId,
    task: task,
  );
}

Act0CurrentAuthoredSourceProofV1? act0CurrentAuthoredSourceProofForTaskV1({
  required Act0LearningEvidenceRecordV1 record,
  required String worldId,
  required String lessonId,
  required Act0LessonTaskV1 task,
}) {
  if (record.isDiagnosticLearningEntry ||
      _isAuthoredTeachingTaskV1(task) ||
      record.worldId != worldId ||
      record.lessonId != lessonId ||
      record.taskId != task.taskId ||
      (record.sourceTaskId.isNotEmpty && record.sourceTaskId != task.taskId)) {
    return null;
  }
  final fingerprint = act0AuthoredSourceFingerprintV1(
    worldId: worldId,
    lessonId: lessonId,
    task: task,
  );
  if (fingerprint == null || record.authoredSourceFingerprint != fingerprint) {
    return null;
  }
  final choices = task.runner.options
      .where((option) => option.id == record.choiceId)
      .toList();
  if (choices.length > 1) return null;
  final option =
      choices.firstOrNull ?? act0RestoredNumberOptionV1(task, record.choiceId);
  if (option == null) return null;
  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: task.runner,
    option: option,
    taskFamily: task.resolvedTaskFamily,
  );
  final reviewConceptFamily = act0NewReviewConceptFamilyV1(
    worldId,
    lessonId,
    task.taskId,
  );
  final skillAtomId = receipt?.skillAtomId ?? reviewConceptFamily;
  final conceptFamilyId = reviewConceptFamily ?? receipt?.sourceSignalId;
  if (skillAtomId == null ||
      skillAtomId.trim().isEmpty ||
      conceptFamilyId == null)
    return null;
  return Act0CurrentAuthoredSourceProofV1(
    fingerprint: fingerprint,
    skillAtomId: skillAtomId,
    conceptFamilyId: conceptFamilyId,
    isCurrentlyCorrect:
        act0RunnerOptionIsAuthoredCorrectV1(option) &&
        !act0IsReasonErrorTypeV1(record.errorType),
  );
}

Act0LessonTaskV1? _resolveTask(String worldId, String lessonId, String taskId) {
  final worlds = Act0ShellStateV1.sample.worlds
      .where((world) => world.worldId == worldId)
      .toList();
  if (worlds.length != 1) return null;
  final lessons = worlds.single.lessons
      .where((lesson) => lesson.lessonId == lessonId)
      .toList();
  if (lessons.length != 1) return null;
  final tasks = lessons.single.taskList
      .where((task) => task.taskId == taskId)
      .toList();
  if (tasks.isEmpty) return act0ReviewOnlyTaskV1(worldId, lessonId, taskId);
  return tasks.length == 1 ? tasks.single : null;
}

class Act0CurrentAuthoredSourceProofV1 {
  const Act0CurrentAuthoredSourceProofV1({
    required this.fingerprint,
    required this.skillAtomId,
    required this.conceptFamilyId,
    required this.isCurrentlyCorrect,
  });

  final String fingerprint;
  final String skillAtomId;
  final String conceptFamilyId;
  final bool isCurrentlyCorrect;
}

/// A read-only current-proof input, never a replacement for persisted history.
/// First-fact lineage alone is not complete retention chronology. Require every
/// original event from order 1 through the present boundary, including anchors.
/// Overflow/missing/ambiguous chronology fails closed; no new log or pruning.
Act0LearningEvidenceHistoryV1 act0CompleteCurrentAuthoredEvidenceV1(
  Act0LearningEvidenceHistoryV1 history,
) {
  const unavailable = Act0LearningEvidenceHistoryV1(hasCompleteLineage: false);
  if (!history.hasCompleteLineage) return unavailable;
  final byId = <String, Act0LearningEvidenceRecordV1>{};
  for (final record in [...history.sourceAnchors, ...history.records]) {
    final prior = byId[record.recordId];
    if (prior != null && prior != record) return unavailable;
    byId[record.recordId] = record;
  }
  final ordered = byId.values.toList()
    ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
  for (var i = 0; i < ordered.length; i++) {
    if (ordered[i].createdOrder != i + 1) return unavailable;
  }
  final blocked = <String>{};
  final validated = <Act0LearningEvidenceRecordV1>[];
  DateTime? previousTime;
  for (final record in ordered) {
    // Placement is assessment, not a retention/transfer learning witness.
    if (record.isPlacementAssessment ||
        record.isDiagnosticLearningEntry ||
        act0RecordIsAuthoredTeachingV1(record)) {
      continue;
    }
    final rawFamily =
        [
              record.conceptFamilyId,
              record.repairFocusId,
              record.skillAtomId,
              record.errorType,
            ]
            .where((s) => s.trim().isNotEmpty && s.trim() != 'none')
            .firstOrNull
            ?.trim() ??
        '';
    final proof = act0CurrentAuthoredSourceProofV1(record);
    // Even a stale/removed choice can invalidate current proof for this task.
    // Resolve its possible current families independently of the stored family.
    final task = _resolveTask(record.worldId, record.lessonId, record.taskId);
    final reviewConceptFamily = act0NewReviewConceptFamilyV1(
      record.worldId,
      record.lessonId,
      record.taskId,
    );
    final taskFamilies = <String>{
      if (reviewConceptFamily != null) reviewConceptFamily,
      if (task != null && reviewConceptFamily == null)
        for (final option in task.runner.options)
          if (act0FirstValueSkillReceiptForRunnerV1(
                runner: task.runner,
                option: option,
                taskFamily: task.resolvedTaskFamily,
              )
              case final receipt?)
            receipt.sourceSignalId.trim(),
    };
    final family = proof?.conceptFamilyId.trim() ?? '';
    final time = record.recordedAtUtc;
    if (time == null || (previousTime != null && time.isBefore(previousTime))) {
      return unavailable;
    }
    previousTime = time;
    if (proof == null ||
        family.isEmpty ||
        rawFamily != family ||
        record.assistanceKind == Act0DecisionAssistanceV1.legacyUnknown ||
        record.sessionId.trim().isEmpty) {
      blocked.add(rawFamily);
      blocked.addAll(taskFamilies);
      if (family.isNotEmpty) blocked.add(family);
      continue;
    }
    // Only detached projection copies are normalized. Stored grades, counts,
    // XP, debt, timestamps, identity and old lineage seals remain untouched.
    final payload = record.toPayload();
    payload['isCorrect'] = proof.isCurrentlyCorrect;
    if (proof.isCurrentlyCorrect) payload['errorType'] = 'none';
    payload['skillAtomId'] = proof.skillAtomId;
    payload['conceptFamilyId'] = family;
    payload['repairFocusId'] = family;
    payload['resultKind'] = !proof.isCurrentlyCorrect
        ? 'incorrect'
        : record.isRepaired
        ? record.resultKind
        : 'correct';
    final current = Act0LearningEvidenceRecordV1.tryParse(payload);
    if (current == null) return unavailable;
    validated.add(current);
  }
  return Act0LearningEvidenceHistoryV1(
    records: List.unmodifiable(
      validated.where((r) => !blocked.contains(r.conceptFamilyId)),
    ),
  );
}

/// Current epochs are bounded observations, not reconstructed lifetime history.
class Act0RecentAuthoredEvidenceV1 {
  const Act0RecentAuthoredEvidenceV1(this.families);
  final Map<String, List<Act0LearningEvidenceRecordV1>> families;
}

Act0RecentAuthoredEvidenceV1 act0RecentAuthoredEvidenceV1(
  Act0LearningEvidenceHistoryV1 history, {
  required DateTime nowUtc,
}) {
  final records = history.records.toList()
    ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
  final bounded = records.length > Act0LearningEvidenceHistoryV1.maxRecords
      ? records.sublist(
          records.length - Act0LearningEvidenceHistoryV1.maxRecords,
        )
      : records;
  final families = <String, List<Act0LearningEvidenceRecordV1>>{};
  final byId = <String, Act0LearningEvidenceRecordV1>{};
  final conflictingIds = <String>{};
  final orders = <int, Set<String>>{};
  for (final r in bounded) {
    final prior = byId[r.recordId];
    if (prior != null && prior != r) conflictingIds.add(r.recordId);
    byId[r.recordId] = r;
    orders.putIfAbsent(r.createdOrder, () => {}).add(r.recordId);
  }
  final seen = <String>{};
  int? previousOrder;
  void reset(Iterable<String> ids) {
    for (final id in ids.toList()) {
      families[id] = [];
    }
  }

  for (final r in bounded) {
    if (!seen.add(r.recordId) && !conflictingIds.contains(r.recordId)) continue;
    if (previousOrder != null && r.createdOrder != previousOrder + 1)
      reset(families.keys);
    previousOrder = r.createdOrder;
    final task = _resolveTask(r.worldId, r.lessonId, r.taskId);
    final knownFamilies = <String>{
      if (task != null)
        for (final option in task.runner.options)
          if (act0FirstValueSkillReceiptForRunnerV1(
                runner: task.runner,
                option: option,
                taskFamily: task.resolvedTaskFamily,
              )
              case final receipt?)
            receipt.sourceSignalId.trim(),
    }..remove('');
    if (conflictingIds.contains(r.recordId) ||
        orders[r.createdOrder]!.length != 1 ||
        r.createdOrder < 1) {
      reset(knownFamilies.isEmpty ? families.keys : knownFamilies);
      continue;
    }
    if (r.isPlacementAssessment ||
        r.isDiagnosticLearningEntry ||
        act0RecordIsAuthoredTeachingV1(r)) {
      continue;
    }
    final proof = act0CurrentAuthoredSourceProofV1(r);
    final rawFamily =
        [r.conceptFamilyId, r.repairFocusId, r.skillAtomId, r.errorType]
            .where((x) => x.trim().isNotEmpty && x.trim() != 'none')
            .firstOrNull
            ?.trim() ??
        '';
    final time = r.recordedAtUtc;
    final family = proof?.conceptFamilyId.trim() ?? '';
    final prior = families[family]?.lastOrNull;
    if (proof == null ||
        family.isEmpty ||
        rawFamily != family ||
        r.assistanceKind == Act0DecisionAssistanceV1.legacyUnknown ||
        time == null ||
        time.isAfter(nowUtc.toUtc()) ||
        (prior?.recordedAtUtc != null &&
            time.isBefore(prior!.recordedAtUtc!)) ||
        r.sessionId.trim().isEmpty) {
      reset(knownFamilies.isEmpty ? families.keys : knownFamilies);
      continue;
    }
    final payload = r.toPayload();
    payload['isCorrect'] = proof.isCurrentlyCorrect;
    payload['skillAtomId'] = proof.skillAtomId;
    payload['conceptFamilyId'] = family;
    payload['repairFocusId'] = family;
    payload['resultKind'] = !proof.isCurrentlyCorrect
        ? 'incorrect'
        : r.isRepaired
        ? r.resultKind
        : 'correct';
    if (proof.isCurrentlyCorrect) payload['errorType'] = 'none';
    final current = Act0LearningEvidenceRecordV1.tryParse(payload);
    if (current == null) {
      reset([family]);
      continue;
    }
    families.putIfAbsent(family, () => []).add(current);
  }
  return Act0RecentAuthoredEvidenceV1(
    Map.unmodifiable({
      for (final e in families.entries)
        e.key: List<Act0LearningEvidenceRecordV1>.unmodifiable(e.value),
    }),
  );
}
