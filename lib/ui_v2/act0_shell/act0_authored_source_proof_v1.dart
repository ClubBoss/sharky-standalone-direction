import 'dart:convert';
import 'act0_predecision_card_focus_v1.dart';

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
  final payload = <Object?>[
    'act0_authored_source_v1',
    if (cardFocusRevision != null) cardFocusRevision,
    worldId,
    lessonId,
    task.taskId,
    task.phase.name,
    task.stepKind.name,
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
    <Object?>[
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
    ],
    optionSemantics,
  ];
  return sha256.convert(utf8.encode(jsonEncode(payload))).toString();
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
  if (_isAuthoredTeachingTaskV1(task) ||
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
  if (choices.length != 1) return null;
  final option = choices.single;
  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: task.runner,
    option: option,
    taskFamily: task.resolvedTaskFamily,
  );
  if (receipt == null || receipt.skillAtomId.trim().isEmpty) return null;
  return Act0CurrentAuthoredSourceProofV1(
    fingerprint: fingerprint,
    skillAtomId: receipt.skillAtomId,
    conceptFamilyId: receipt.sourceSignalId,
    isCurrentlyCorrect: act0RunnerOptionIsAuthoredCorrectV1(option),
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
    final taskFamilies = <String>{
      if (task != null)
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
    payload['resultKind'] = proof.isCurrentlyCorrect ? 'correct' : 'incorrect';
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
    if (r.isPlacementAssessment || act0RecordIsAuthoredTeachingV1(r)) {
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
    payload['resultKind'] = proof.isCurrentlyCorrect ? 'correct' : 'incorrect';
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
