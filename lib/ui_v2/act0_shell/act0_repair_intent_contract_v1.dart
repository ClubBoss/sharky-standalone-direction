import 'act0_lesson_identity_alias_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';
import 'act0_authored_source_proof_v1.dart';
import 'act0_review_mistake_history_v1.dart';
import 'act0_repair_gap_adjudication_v1.dart';
import 'act0_repair_outcome_projection_v1.dart';
import 'act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_position_personalization_ids_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

typedef Act0RepairIntentTargetMapperV1 =
    ({String worldId, String lessonId, String taskId, String mappingType})?
    Function({
      required String nextRepId,
      required String skillAtomId,
      required String sourceSignalId,
      required String sourceTaskId,
      required String receiptOutcome,
    });

class Act0RepairIntentV1 {
  const Act0RepairIntentV1({
    this.schemaVersion = 1,
    this.repairOccurrenceId = '',
    this.goalId = '',
    this.relationId = '',
    this.relationRevision = 0,
    this.sourceFingerprint = '',
    this.targetFingerprint = '',
    required this.sourceWorldId,
    required this.sourceLessonId,
    required this.sourceTaskId,
    required this.choiceId,
    required this.result,
    required this.errorType,
    required this.missedSignalId,
    required this.missedSignalLabel,
    required this.skillAtomId,
    required this.skillLabel,
    required this.targetWorldId,
    required this.targetLessonId,
    required this.targetTaskId,
    required this.mappingType,
    required this.reasonCode,
  });

  final int schemaVersion;
  // Additive witness; legacy absence is readable, never self-authenticating.
  final String goalId, relationId, sourceFingerprint, targetFingerprint;
  final int relationRevision;

  /// Canonical source-miss attempt ID. Empty means legacy/unknown provenance.
  final String repairOccurrenceId;
  final String sourceWorldId;
  final String sourceLessonId;
  final String sourceTaskId;
  final String choiceId;
  final String result;
  final String errorType;
  final String missedSignalId;
  final String missedSignalLabel;
  final String skillAtomId;
  final String skillLabel;
  final String targetWorldId;
  final String targetLessonId;
  final String targetTaskId;
  final String mappingType;
  final String reasonCode;

  bool get isFoundationExactRehearsal =>
      relationId.startsWith('foundation_replay/') &&
      sourceTaskId == targetTaskId &&
      mappingType == 'intentional_exact';

  Map<String, Object> toPayload() {
    return <String, Object>{
      'schemaVersion': schemaVersion,
      if (goalId.isNotEmpty) 'goalId': goalId,
      if (relationId.isNotEmpty) 'relationId': relationId,
      if (relationRevision != 0) 'relationRevision': relationRevision,
      if (sourceFingerprint.isNotEmpty) 'sourceFingerprint': sourceFingerprint,
      if (targetFingerprint.isNotEmpty) 'targetFingerprint': targetFingerprint,
      if (repairOccurrenceId.isNotEmpty)
        'repairOccurrenceId': repairOccurrenceId,
      'sourceWorldId': sourceWorldId,
      'sourceLessonId': sourceLessonId,
      'sourceTaskId': sourceTaskId,
      'choiceId': choiceId,
      'result': result,
      'errorType': errorType,
      'missedSignalId': missedSignalId,
      'missedSignalLabel': missedSignalLabel,
      'skillAtomId': skillAtomId,
      'skillLabel': skillLabel,
      'targetWorldId': targetWorldId,
      'targetLessonId': targetLessonId,
      'targetTaskId': targetTaskId,
      'mappingType': mappingType,
      'reasonCode': reasonCode,
    };
  }

  static Act0RepairIntentV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<String, Object?>();
    const witnessKeys = [
      'goalId',
      'relationId',
      'relationRevision',
      'sourceFingerprint',
      'targetFingerprint',
    ];
    final hasWitnessKeys = witnessKeys.any(map.containsKey);
    bool nonemptyString(String key) =>
        map[key] is String && (map[key] as String).trim().isNotEmpty;
    final malformedWitness =
        hasWitnessKeys &&
        (!nonemptyString('goalId') ||
            !nonemptyString('relationId') ||
            !nonemptyString('sourceFingerprint') ||
            (_nonNegativeInt(map['relationRevision']) ?? 0) <= 0 ||
            (map.containsKey('targetFingerprint') &&
                !nonemptyString('targetFingerprint')));
    final schemaVersion = _nonNegativeInt(map['schemaVersion']) ?? 1;
    if (schemaVersion != 1) {
      return null;
    }
    final sourceWorldId = _requiredString(map, 'sourceWorldId');
    final sourceLessonId = _requiredString(map, 'sourceLessonId');
    final sourceTaskId = _requiredString(map, 'sourceTaskId');
    final choiceId = _requiredString(map, 'choiceId');
    final result = _requiredString(map, 'result');
    final errorType = _requiredString(map, 'errorType');
    final missedSignalId = _requiredString(map, 'missedSignalId');
    final missedSignalLabel = _requiredString(map, 'missedSignalLabel');
    final skillAtomId = _requiredString(map, 'skillAtomId');
    final skillLabel = _requiredString(map, 'skillLabel');
    final targetWorldId = _requiredString(map, 'targetWorldId');
    final targetLessonId = _requiredString(map, 'targetLessonId');
    final targetTaskId = _requiredString(map, 'targetTaskId');
    final mappingType = _requiredString(map, 'mappingType');
    final reasonCode = _requiredString(map, 'reasonCode');
    if (sourceWorldId == null ||
        sourceLessonId == null ||
        sourceTaskId == null ||
        choiceId == null ||
        result == null ||
        errorType == null ||
        missedSignalId == null ||
        missedSignalLabel == null ||
        skillAtomId == null ||
        skillLabel == null ||
        targetWorldId == null ||
        targetLessonId == null ||
        targetTaskId == null ||
        mappingType == null ||
        reasonCode == null) {
      return null;
    }
    return Act0RepairIntentV1(
      schemaVersion: schemaVersion,
      goalId: map['goalId']?.toString() ?? '',
      relationId: map['relationId']?.toString() ?? '',
      relationRevision: malformedWitness
          ? -1
          : map.containsKey('relationRevision')
          ? _nonNegativeInt(map['relationRevision']) ?? -1
          : 0,
      sourceFingerprint: map['sourceFingerprint']?.toString() ?? '',
      targetFingerprint: map['targetFingerprint']?.toString() ?? '',
      repairOccurrenceId: map['repairOccurrenceId']?.toString().trim() ?? '',
      sourceWorldId: sourceWorldId,
      sourceLessonId: act0CanonicalLessonForTaskV1(
        sourceWorldId,
        sourceLessonId,
        sourceTaskId,
      ),
      sourceTaskId: sourceTaskId,
      choiceId: choiceId,
      result: result,
      errorType: errorType,
      missedSignalId: missedSignalId,
      missedSignalLabel: missedSignalLabel,
      skillAtomId: skillAtomId,
      skillLabel: skillLabel,
      targetWorldId: targetWorldId,
      targetLessonId: act0CanonicalLessonForTaskV1(
        targetWorldId,
        targetLessonId,
        targetTaskId,
      ),
      targetTaskId: targetTaskId,
      mappingType: mappingType,
      reasonCode: reasonCode,
    );
  }
}

String? _requiredString(Map<String, Object?> map, String key) {
  final value = map[key]?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

bool act0IsExactRepairMappingTypeV1(String mappingType) {
  return mappingType == 'exact' || mappingType == 'intentional_exact';
}

Act0RepairIntentV1? buildAct0RepairIntentV1({
  required String sourceWorldId,
  required String sourceLessonId,
  required String sourceTaskId,
  required Act0RunnerStateV1 runner,
  required Act0RunnerOptionV1 selectedOption,
  Act0RepairIntentTargetMapperV1? mapSameSignalRep,
  Act0RepairFingerprintResolverV1? currentFingerprintForIdentity,
  Act0LessonTaskV1? sourceTask,
  String diagnosticVariantId = '',
  Act0DiagnosticVariantFingerprintResolverV1?
  currentDiagnosticVariantFingerprint,
}) {
  if (selectedOption.isCorrect || selectedOption.quality.passes) {
    return null;
  }

  // This canonical recap is authored review with drill entry. Preserve that
  // source role when deriving its receipt; other repair callers keep their
  // existing decision projection.
  final contextReviewSource =
      sourceWorldId == 'world_3' &&
      sourceLessonId == 'same_hand_different_seat' &&
      sourceTaskId == 'same_hand_different_seat_w3_same_hand_recap';
  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: runner,
    option: selectedOption,
    taskFamily: contextReviewSource
        ? Act0TaskFamilyV1.review
        : Act0TaskFamilyV1.decision,
  );
  final concept = act0ConceptErrorDefinitionForTaskV1(
    worldId: sourceWorldId,
    lessonId: sourceLessonId,
    taskId: sourceTaskId,
  );
  final goal = act0RepairGoalContractForSourceV1(
    worldId: sourceWorldId,
    lessonId: sourceLessonId,
    taskId: sourceTaskId,
    choiceId: selectedOption.id,
    diagnosticVariantId: diagnosticVariantId,
  );
  if (receipt == null && concept == null && goal == null) {
    return null;
  }

  final result = selectedOption.quality.resultKind;
  final receiptOutcome = receipt == null
      ? 'repair_started'
      : _receiptOutcomeIdV1(receipt.outcome);
  final canonicalPositionSource =
      sourceTaskId == act0PositionPersonalizationSourceTaskIdV1;
  final skillAtomId = canonicalPositionSource
      ? act0PositionPersonalizationSkillIdV1
      : receipt?.skillAtomId ?? concept?.eligibleRepairFamily ?? goal!.goalId;
  final skillLabel = canonicalPositionSource
      ? 'Table position read'
      : receipt?.skillLabel ??
            concept?.learnerInterpretation ??
            goal!.learnerGoalLabel;
  final sourceSignalId = canonicalPositionSource
      ? act0PositionPersonalizationSignalIdV1
      : receipt?.sourceSignalId ?? concept?.id ?? goal!.goalId;
  final sourceSignalLabel = canonicalPositionSource
      ? 'Button'
      : receipt?.sourceSignalLabel ??
            concept?.learnerInterpretation ??
            goal!.learnerGoalLabel;
  final nextRepId = canonicalPositionSource
      ? 'repeat_table_position_read'
      : receipt?.nextRepId ?? 'repeat_$skillAtomId';
  mapSameSignalRep?.call(
    nextRepId: nextRepId,
    skillAtomId: skillAtomId,
    sourceSignalId: sourceSignalId,
    sourceTaskId: sourceTaskId,
    receiptOutcome: receiptOutcome,
  );

  final canonicalChoices = runner.options
      .where((o) => o.id == selectedOption.id)
      .toList();
  final diagnostic = goal?.isDiagnosticLearningEntry ?? false;
  final capturedVariant =
      diagnostic && sourceTask != null && sourceTask.taskId == sourceTaskId
      ? act0PlacementDiagnosticFingerprintV1(
          worldId: sourceWorldId,
          lessonId: sourceLessonId,
          diagnosticVariantId: diagnosticVariantId,
          sourceTask: sourceTask,
          diagnosticRunner: runner,
        )
      : null;
  final sourceFingerprint = diagnostic
      ? (capturedVariant ?? '')
      : (goal?.sourceFingerprint ?? '');
  final currentSourceBound = diagnostic
      ? capturedVariant != null &&
            currentFingerprintForIdentity?.call(
                  worldId: sourceWorldId,
                  lessonId: sourceLessonId,
                  taskId: sourceTaskId,
                ) ==
                goal?.sourceContainerFingerprint &&
            currentDiagnosticVariantFingerprint?.call(
                  worldId: sourceWorldId,
                  lessonId: sourceLessonId,
                  taskId: sourceTaskId,
                  diagnosticVariantId: diagnosticVariantId,
                ) ==
                capturedVariant
      : currentFingerprintForIdentity?.call(
              worldId: sourceWorldId,
              lessonId: sourceLessonId,
              taskId: sourceTaskId,
            ) ==
            goal?.sourceFingerprint;
  final expected = runner.options.where(act0RunnerOptionIsPreferredV1).toList();
  final sourceBound =
      goal != null &&
      canonicalChoices.length == 1 &&
      runner.question == goal.sourceQuestion &&
      selectedOption.label == goal.sourceChoiceLabel &&
      selectedOption.feedbackReason == goal.sourceChoiceReason &&
      selectedOption.quality.name == goal.sourceChoiceQuality &&
      _sameRepairOptionV1(canonicalChoices.single, selectedOption) &&
      currentSourceBound &&
      expected.length == 1 &&
      expected.single.id == goal.sourceCorrectChoiceId;
  // Persist structural source IDs for a held obligation, never as a fallback
  // target. All launchers must consume the semantic eligibility helper.
  final validatedTarget =
      sourceBound &&
      goal != null &&
      goal.hasValidatedTarget &&
      currentFingerprintForIdentity?.call(
            worldId: goal.targetWorldId,
            lessonId: goal.targetLessonId,
            taskId: goal.targetTaskId,
          ) ==
          goal.targetFingerprint;
  final targetWorldId = validatedTarget ? goal.targetWorldId : sourceWorldId;
  final targetLessonId = validatedTarget ? goal.targetLessonId : sourceLessonId;
  final targetTaskId = validatedTarget ? goal.targetTaskId : sourceTaskId;
  final mappingType = validatedTarget
      ? goal.mappingType
      : 'unresolved_product_gap';
  final reasonCode = switch (mappingType) {
    'intentional_exact' =>
      'intentional_exact_replay_${skillAtomId}_$sourceSignalId',
    'unresolved_product_gap' =>
      'unresolved_product_gap_${skillAtomId}_$sourceSignalId',
    'exact' => 'exact_replay_${skillAtomId}_$sourceSignalId',
    _ => 'same_signal_${skillAtomId}_$sourceSignalId',
  };

  return Act0RepairIntentV1(
    goalId: sourceBound ? goal.goalId : '',
    relationId: sourceBound ? goal.relationId : '',
    relationRevision: sourceBound ? goal.relationRevision : 0,
    sourceFingerprint: sourceBound ? sourceFingerprint : '',
    targetFingerprint: validatedTarget ? goal.targetFingerprint : '',
    sourceWorldId: sourceWorldId,
    sourceLessonId: sourceLessonId,
    sourceTaskId: sourceTaskId,
    choiceId: selectedOption.id,
    result: result,
    errorType: act0CanonicalErrorTypeForDecisionV1(
      result: result,
      skillAtomId: skillAtomId,
      sourceTaskId: sourceTaskId,
      sourceWorldId: sourceWorldId,
      sourceLessonId: sourceLessonId,
    ),
    missedSignalId: sourceSignalId,
    missedSignalLabel: sourceSignalLabel,
    skillAtomId: skillAtomId,
    skillLabel: skillLabel,
    targetWorldId: targetWorldId,
    targetLessonId: targetLessonId,
    targetTaskId: targetTaskId,
    mappingType: mappingType,
    reasonCode: reasonCode,
  );
}

String _receiptOutcomeIdV1(Act0SkillReceiptOutcomeV1 outcome) {
  return switch (outcome) {
    Act0SkillReceiptOutcomeV1.learned => 'learned',
    Act0SkillReceiptOutcomeV1.repairStarted => 'repair_started',
    Act0SkillReceiptOutcomeV1.needsRep => 'needs_rep',
  };
}

typedef Act0RepairFingerprintResolverV1 =
    String? Function({
      required String worldId,
      required String lessonId,
      required String taskId,
    });

class Act0RepairGoalResolutionV1 {
  const Act0RepairGoalResolutionV1({
    this.contract,
    required this.isHeld,
    required this.reason,
  });
  final Act0RepairGoalContractV1? contract;
  final bool isHeld;
  final String reason;
  String get goalId => contract?.goalId ?? '';
  String get misconceptionId => contract?.misconceptionId ?? '';
  String get relationId => contract?.relationId ?? '';
  int get relationRevision => contract?.relationRevision ?? 0;
  String get evidenceClass => contract?.evidenceClass ?? 'unconfirmed';
  bool get canLaunch => !isHeld && contract?.hasValidatedTarget == true;
  bool get canClaimIndependentApplication => false;
  bool get canClaimMatchedRecheck => contract?.canClaimMatchedRecheck ?? false;
  bool get retainsObligation => true;
}

Act0RepairGoalResolutionV1 act0RepairGoalResolutionForIntentV1(
  Act0RepairIntentV1 intent, {
  required Act0LearningEvidenceHistoryV1 learningEvidence,
  required Act0RepairFingerprintResolverV1 currentFingerprintForIdentity,
}) {
  final row = act0RepairGoalContractForSourceV1(
    worldId: intent.sourceWorldId,
    lessonId: intent.sourceLessonId,
    taskId: intent.sourceTaskId,
    choiceId: intent.choiceId,
  );
  Act0RepairGoalResolutionV1 held(String reason) =>
      Act0RepairGoalResolutionV1(contract: row, isHeld: true, reason: reason);
  if (row == null) return held('relation_unconfirmed');
  final sources = act0RepairEvidenceRecordsForIdV1(
    learningEvidence,
    intent.repairOccurrenceId,
  );
  if (intent.repairOccurrenceId.isEmpty || sources.length != 1)
    return held('source_occurrence_unconfirmed');
  final source = sources.single;
  if (source.worldId != row.sourceWorldId ||
      act0CanonicalLessonForTaskV1(
            source.worldId,
            source.lessonId,
            source.taskId,
          ) !=
          row.sourceLessonId ||
      source.taskId != row.sourceTaskId ||
      source.sourceTaskId != row.sourceTaskId ||
      source.choiceId != row.sourceChoiceId ||
      source.expectedChoiceId != row.sourceCorrectChoiceId ||
      source.isCorrect ||
      source.isPlacementAssessment ||
      source.isDiagnosticLearningEntry ||
      source.sessionId.isEmpty ||
      source.runId.isEmpty ||
      (source.runOrdinal ?? 0) <= 0 ||
      source.resultKind != intent.result ||
      source.authoredSourceFingerprint != row.sourceFingerprint ||
      currentFingerprintForIdentity(
            worldId: row.sourceWorldId,
            lessonId: row.sourceLessonId,
            taskId: row.sourceTaskId,
          ) !=
          row.sourceFingerprint)
    return held('source_semantics_unconfirmed');
  final hasWitness =
      intent.goalId.isNotEmpty ||
      intent.relationId.isNotEmpty ||
      intent.relationRevision != 0 ||
      intent.sourceFingerprint.isNotEmpty ||
      intent.targetFingerprint.isNotEmpty;
  if (row.requireCapturedGoalWitness && !hasWitness)
    return held('relation_capture_unconfirmed');
  if (hasWitness &&
      (intent.goalId != row.goalId ||
          intent.relationId != row.relationId ||
          intent.relationRevision != row.relationRevision ||
          intent.sourceFingerprint != row.sourceFingerprint ||
          intent.targetFingerprint != row.targetFingerprint))
    return held('relation_revision_unconfirmed');
  if (!row.hasValidatedTarget) return held('no_validated_target');
  // Legacy absence is revalidated from the exact source event, never guessed
  // from a scene, an aggregate success or the old queue identifier.
  if (intent.targetWorldId != row.targetWorldId ||
      intent.targetLessonId != row.targetLessonId ||
      intent.targetTaskId != row.targetTaskId ||
      intent.mappingType != row.mappingType ||
      currentFingerprintForIdentity(
            worldId: row.targetWorldId,
            lessonId: row.targetLessonId,
            taskId: row.targetTaskId,
          ) !=
          row.targetFingerprint)
    return held('target_relation_unconfirmed');
  return Act0RepairGoalResolutionV1(
    contract: row,
    isHeld: false,
    reason: 'validated_familiar_relation',
  );
}

/// Current factory semantics for one named diagnostic, never a scene fallback.
typedef Act0DiagnosticVariantFingerprintResolverV1 =
    String? Function({
      required String worldId,
      required String lessonId,
      required String taskId,
      required String diagnosticVariantId,
    });

/// Navigation permission only. It cannot discharge the source obligation.
class Act0DiagnosticLearningEntryV1 {
  const Act0DiagnosticLearningEntryV1({
    required this.contract,
    required this.sourceOccurrenceId,
  });
  final Act0RepairGoalContractV1 contract;
  final String sourceOccurrenceId;
  String get diagnosticVariantId => contract.diagnosticVariantId;
  String get targetWorldId => contract.targetWorldId;
  String get targetLessonId => contract.targetLessonId;
  String get targetTaskId => contract.targetTaskId;
  bool get canLaunchTeaching => true;
  bool get canClaimRepairClosure => false;
  bool get canClaimIndependentApplication => false;
  bool get canClaimMatchedRecheck => false;
}

Act0DiagnosticLearningEntryV1? act0DiagnosticLearningEntryForIntentV1(
  Act0RepairIntentV1 intent, {
  required Act0LearningEvidenceHistoryV1 learningEvidence,
  required Act0ReviewMistakeHistoryV1 reviewMistakeHistory,
  required Act0RepairFingerprintResolverV1 currentFingerprintForIdentity,
  required Act0DiagnosticVariantFingerprintResolverV1
  currentDiagnosticVariantFingerprint,
}) {
  final candidates = act0RepairGoalContractsV1
      .where(
        (row) =>
            row.isDiagnosticLearningEntry &&
            row.sourceWorldId == intent.sourceWorldId &&
            row.sourceLessonId == intent.sourceLessonId &&
            row.sourceTaskId == intent.sourceTaskId &&
            row.sourceChoiceId == intent.choiceId &&
            row.goalId == intent.goalId &&
            row.relationId == intent.relationId &&
            row.relationRevision == intent.relationRevision,
      )
      .toList();
  if (candidates.length != 1 || intent.repairOccurrenceId.isEmpty) return null;
  final row = candidates.single;
  // All five witnesses must have been stored at the real miss. A base-only
  // legacy occurrence cannot prove what its old diagnostic variant asked.
  final currentVariant = currentDiagnosticVariantFingerprint(
    worldId: row.sourceWorldId,
    lessonId: row.sourceLessonId,
    taskId: row.sourceTaskId,
    diagnosticVariantId: row.diagnosticVariantId,
  );
  if (currentVariant == null ||
      currentVariant.isEmpty ||
      intent.sourceFingerprint != currentVariant ||
      intent.targetFingerprint != row.targetFingerprint ||
      currentFingerprintForIdentity(
            worldId: row.sourceWorldId,
            lessonId: row.sourceLessonId,
            taskId: row.sourceTaskId,
          ) !=
          row.sourceContainerFingerprint ||
      intent.targetWorldId != row.targetWorldId ||
      intent.targetLessonId != row.targetLessonId ||
      intent.targetTaskId != row.targetTaskId ||
      intent.mappingType != 'diagnostic_learning_entry' ||
      currentFingerprintForIdentity(
            worldId: row.targetWorldId,
            lessonId: row.targetLessonId,
            taskId: row.targetTaskId,
          ) !=
          row.targetFingerprint)
    return null;
  final sources = act0RepairEvidenceRecordsForIdV1(
    learningEvidence,
    intent.repairOccurrenceId,
  );
  if (sources.length != 1) return null;
  final source = sources.single;
  if (!source.isPlacementAssessment ||
      source.isCorrect ||
      source.worldId != row.sourceWorldId ||
      source.lessonId != row.sourceLessonId ||
      source.taskId != row.sourceTaskId ||
      source.sourceTaskId != row.sourceTaskId ||
      source.choiceId != row.sourceChoiceId ||
      source.expectedChoiceId != row.sourceCorrectChoiceId ||
      source.authoredSourceFingerprint != row.sourceContainerFingerprint ||
      source.resultKind != intent.result ||
      source.sessionId.isEmpty ||
      source.runId.isEmpty ||
      (source.runOrdinal ?? 0) <= 0)
    return null;
  final review = reviewMistakeHistory.records
      .where(
        (r) =>
            r.sourceDecisionId == intent.repairOccurrenceId &&
            r.worldId == row.sourceWorldId &&
            r.lessonId == row.sourceLessonId &&
            r.decisionTaskId == row.sourceTaskId &&
            r.sourceTaskId == row.sourceTaskId &&
            r.selectedId == row.sourceChoiceId &&
            r.expectedId == row.sourceCorrectChoiceId &&
            r.runKind == act0PlacementAssessmentRunKindV1 &&
            r.runId == source.runId &&
            r.runOrdinal == source.runOrdinal &&
            r.resultKind == source.resultKind &&
            r.attemptRecordIds.contains(intent.repairOccurrenceId),
      )
      .toList();
  if (review.length != 1) return null;
  return Act0DiagnosticLearningEntryV1(
    contract: row,
    sourceOccurrenceId: intent.repairOccurrenceId,
  );
}

/// Validates an actual attempt, including an authentic incorrect attempt.
/// Callers still require isCorrect == true for a successful repair claim.
bool act0RepairGoalOutcomeIsEligibleV1({
  required Act0RepairIntentV1 intent,
  required Act0RepairOutcomeV1 outcome,
  required Act0LearningEvidenceHistoryV1 learningEvidence,
  required Act0RepairFingerprintResolverV1 currentFingerprintForIdentity,
}) {
  if (outcome.repairIntentIsUnconfirmed) return false;
  final attached = outcome.repairIntent;
  if (attached != null) {
    final captured = attached.toPayload();
    final supplied = intent.toPayload();
    if (captured.length != supplied.length ||
        captured.entries.any((entry) => supplied[entry.key] != entry.value)) {
      return false;
    }
  }
  final goal = act0RepairGoalResolutionForIntentV1(
    intent,
    learningEvidence: learningEvidence,
    currentFingerprintForIdentity: currentFingerprintForIdentity,
  );
  final row = goal.contract;
  if (!goal.canLaunch ||
      row == null ||
      outcome.sourceType != 'active_repair_v1' ||
      outcome.queueItemId != queueItemIdForAct0RepairIntentV1(intent) ||
      outcome.repairOccurrenceId != intent.repairOccurrenceId ||
      outcome.sourceTaskId != intent.sourceTaskId ||
      outcome.repairTaskId != row.targetTaskId ||
      outcome.targetWorldId != row.targetWorldId ||
      act0CanonicalLessonForTaskV1(
            outcome.targetWorldId,
            outcome.targetLessonId,
            outcome.targetTaskId,
          ) !=
          row.targetLessonId ||
      outcome.targetTaskId != row.targetTaskId ||
      outcome.repairAttemptId.isEmpty ||
      outcome.correctChoiceId != row.targetCorrectChoiceId ||
      !row.targetChoiceIds.contains(outcome.selectedChoiceId))
    return false;
  final attempts = act0RepairEvidenceRecordsForIdV1(
    learningEvidence,
    outcome.repairAttemptId,
  );
  final sources = act0RepairEvidenceRecordsForIdV1(
    learningEvidence,
    intent.repairOccurrenceId,
  );
  if (attempts.length != 1 || sources.length != 1) return false;
  final attempt = attempts.single;
  final roleMatches = row.evidenceClass == 'intentional_exact_replay'
      ? attempt.reviewKind.name == 'exactReplay'
      : const {
          'alternateSameSignal',
          'immediateRepair',
        }.contains(attempt.reviewKind.name);
  return roleMatches &&
      attempt.runKind == 'repair' &&
      !attempt.isPlacementAssessment &&
      !attempt.isDiagnosticLearningEntry &&
      attempt.worldId == row.targetWorldId &&
      act0CanonicalLessonForTaskV1(
            attempt.worldId,
            attempt.lessonId,
            attempt.taskId,
          ) ==
          row.targetLessonId &&
      attempt.taskId == row.targetTaskId &&
      attempt.sourceTaskId == row.targetTaskId &&
      attempt.choiceId == outcome.selectedChoiceId &&
      attempt.expectedChoiceId == row.targetCorrectChoiceId &&
      attempt.authoredSourceFingerprint == row.targetFingerprint &&
      attempt.assistanceKind.name == 'none' &&
      attempt.isCorrect == outcome.isCorrect &&
      attempt.isCorrect == (attempt.choiceId == row.targetCorrectChoiceId) &&
      outcome.outcomeState ==
          (attempt.isCorrect
              ? 'repair_correct_v1'
              : 'repair_still_needs_rep_v1') &&
      attempt.createdOrder > sources.single.createdOrder &&
      attempt.recordId != sources.single.recordId &&
      attempt.sessionId.isNotEmpty &&
      attempt.sessionId == outcome.sessionId &&
      attempt.runId.isNotEmpty &&
      (attempt.runOrdinal ?? 0) > 0;
}

/// Read-only migration/proof candidate. Never writes a fresh intent or event.
Act0RepairIntentV1? act0RepairIntentForRecordedOutcomeV1({
  required Act0RepairOutcomeV1 outcome,
  required Act0LearningEvidenceHistoryV1 learningEvidence,
  required Act0RepairFingerprintResolverV1 currentFingerprintForIdentity,
  Iterable<Act0RepairIntentV1> repairIntents = const <Act0RepairIntentV1>[],
}) {
  if (outcome.repairIntentIsUnconfirmed) return null;
  final attached = outcome.repairIntent;
  if (attached != null) {
    return act0RepairGoalOutcomeIsEligibleV1(
          intent: attached,
          outcome: outcome,
          learningEvidence: learningEvidence,
          currentFingerprintForIdentity: currentFingerprintForIdentity,
        )
        ? attached
        : null;
  }
  var hasExplicitOccurrence = false;
  for (final intent in repairIntents) {
    if (intent.repairOccurrenceId == outcome.repairOccurrenceId)
      hasExplicitOccurrence = true;
    if (act0RepairGoalOutcomeIsEligibleV1(
      intent: intent,
      outcome: outcome,
      learningEvidence: learningEvidence,
      currentFingerprintForIdentity: currentFingerprintForIdentity,
    ))
      return intent;
  }
  // Conflicting/stale explicit provenance is not "missing legacy metadata".
  if (hasExplicitOccurrence) return null;
  final sources = act0RepairEvidenceRecordsForIdV1(
    learningEvidence,
    outcome.repairOccurrenceId,
  );
  if (outcome.repairOccurrenceId.isEmpty || sources.length != 1) return null;
  final source = sources.single;
  final row = act0RepairGoalContractForSourceV1(
    worldId: source.worldId,
    lessonId: source.lessonId,
    taskId: source.taskId,
    choiceId: source.choiceId,
  );
  if (row == null || !row.hasValidatedTarget) return null;
  final candidate = Act0RepairIntentV1(
    repairOccurrenceId: outcome.repairOccurrenceId,
    sourceWorldId: source.worldId,
    sourceLessonId: act0CanonicalLessonForTaskV1(
      source.worldId,
      source.lessonId,
      source.taskId,
    ),
    sourceTaskId: source.taskId,
    choiceId: source.choiceId,
    result: source.resultKind,
    errorType: source.errorType,
    missedSignalId: source.repairFocusId,
    missedSignalLabel: row.goalId,
    skillAtomId: source.skillAtomId,
    skillLabel: row.goalId,
    targetWorldId: outcome.targetWorldId,
    targetLessonId: act0CanonicalLessonForTaskV1(
      outcome.targetWorldId,
      outcome.targetLessonId,
      outcome.targetTaskId,
    ),
    targetTaskId: outcome.targetTaskId,
    mappingType: row.mappingType,
    reasonCode: 'legacy_relation_revalidated',
  );
  return act0RepairGoalOutcomeIsEligibleV1(
        intent: candidate,
        outcome: outcome,
        learningEvidence: learningEvidence,
        currentFingerprintForIdentity: currentFingerprintForIdentity,
      )
      ? candidate
      : null;
}

bool _sameRepairOptionV1(Act0RunnerOptionV1 a, Act0RunnerOptionV1 b) =>
    a.id == b.id &&
    a.label == b.label &&
    a.amountLabel == b.amountLabel &&
    a.seatId == b.seatId &&
    a.isCorrect == b.isCorrect &&
    a.quality == b.quality &&
    a.preferredLabel == b.preferredLabel &&
    a.betterAnswerLabel == b.betterAnswerLabel &&
    a.feedbackTitle == b.feedbackTitle &&
    a.feedbackReason == b.feedbackReason &&
    _sameRepairStringsV1(a.repairFocusSeatIds, b.repairFocusSeatIds) &&
    _sameRepairStringsV1(a.repairFocusCardIds, b.repairFocusCardIds) &&
    _sameRepairStringsV1(a.repairFocusLabels, b.repairFocusLabels);
bool _sameRepairStringsV1(List<String> a, List<String> b) =>
    a.length == b.length &&
    List.generate(a.length, (i) => a[i] == b[i]).every((same) => same);

// Anchors are retained source lineage, not newly reconstructed evidence. Equal
// copies may occur in both windows; contradictory copies cannot certify a link.
List<Act0LearningEvidenceRecordV1> act0RepairEvidenceRecordsForIdV1(
  Act0LearningEvidenceHistoryV1 history,
  String recordId,
) {
  if (recordId.isEmpty) return const [];
  final distinct = <Act0LearningEvidenceRecordV1>[];
  for (final record in [...history.sourceAnchors, ...history.records]) {
    if (record.recordId != recordId) continue;
    final payload = record.toPayload();
    if (distinct.any((previous) {
      final prior = previous.toPayload();
      return prior.length == payload.length &&
          prior.entries.every((entry) => payload[entry.key] == entry.value);
    }))
      continue;
    distinct.add(record);
  }
  return distinct;
}
