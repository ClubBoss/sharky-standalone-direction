import 'act0_concept_family_state_foundation_v1.dart';
import 'act0_durable_retention_contract_v1.dart';
import 'act0_learning_transfer_measurement_v1.dart';
import 'act0_repair_intent_contract_v1.dart';

const String act0ReturnReasonContinueUnresolvedRepairV1 =
    'continue_unresolved_repair';
const String act0ReturnReasonRetryNotYetSucceededV1 = 'retry_not_yet_succeeded';
const String act0ReturnReasonDueReviewV1 = 'due_review';
const String act0ReturnReasonReinforceRecentImprovementV1 =
    'reinforce_recent_improvement';
const String act0ReturnReasonResumeRecentFocusV1 = 'resume_recent_focus';
const String act0ReturnReasonNoPersonalReasonAvailableV1 =
    'no_personal_reason_available';

const String act0ReturnReasonEvidenceActiveRepairV1 = 'active_repair';
const String act0ReturnReasonEvidenceConceptFamilyStateV1 =
    'concept_family_state';
const String act0ReturnReasonEvidenceTransferMeasurementV1 =
    'transfer_measurement';
const String act0ReturnReasonEvidenceDurableRetentionV1 = 'durable_retention';
const String act0ReturnReasonEvidenceFallbackV1 = 'fallback';

const String act0ReturnReasonMessageContinueRepairV1 = 'continue_repair';
const String act0ReturnReasonMessageRetryRepairV1 = 'retry_repair';
const String act0ReturnReasonMessageDueReviewV1 = 'due_review';
const String act0ReturnReasonMessageReinforceTransferV1 = 'reinforce_transfer';
const String act0ReturnReasonMessageResumeFocusV1 = 'resume_focus';
const String act0ReturnReasonMessageNoReasonV1 = 'no_reason';

class Act0PersonalizedReturnReasonV1 {
  const Act0PersonalizedReturnReasonV1({
    this.schemaVersion = 1,
    required this.reasonType,
    required this.conceptFamilyId,
    this.sourceTaskId = '',
    this.sourceSessionId = '',
    required this.evidenceKind,
    required this.messageKey,
    required this.priorityClass,
    this.recommendedDestination = 'learn',
    this.recommendedAction = 'continue',
    this.whyNowMessageKey = 'continue_now',
    this.learnerSafeFocusLabel = '',
    this.rawEvidenceRef = '',
  });

  factory Act0PersonalizedReturnReasonV1.fromSources({
    List<Act0RepairIntentV1> activeRepairIntents = const <Act0RepairIntentV1>[],
    Act0ConceptFamilyStateHistoryV1 conceptFamilyStateHistory =
        const Act0ConceptFamilyStateHistoryV1(),
    Act0LearningTransferMeasurementV1 transferMeasurement =
        const Act0LearningTransferMeasurementV1(signals: []),
    List<Act0DueReviewItemV1> dueReviewItems = const <Act0DueReviewItemV1>[],
  }) {
    final active = _activeRepairReason(activeRepairIntents);
    if (active != null) {
      return active;
    }
    final retry = _retryRepairReason(conceptFamilyStateHistory);
    if (retry != null) {
      return retry;
    }
    final due = _dueReviewReason(dueReviewItems);
    if (due != null) {
      return due;
    }
    final reinforce = _reinforceTransferReason(transferMeasurement);
    if (reinforce != null) {
      return reinforce;
    }
    final recent = _recentFocusReason(conceptFamilyStateHistory);
    if (recent != null) {
      return recent;
    }
    return const Act0PersonalizedReturnReasonV1(
      reasonType: act0ReturnReasonNoPersonalReasonAvailableV1,
      conceptFamilyId: '',
      evidenceKind: act0ReturnReasonEvidenceFallbackV1,
      messageKey: act0ReturnReasonMessageNoReasonV1,
      priorityClass: 5,
      recommendedDestination: 'learn',
      recommendedAction: 'continue',
      whyNowMessageKey: 'no_evidence_available',
    );
  }

  final int schemaVersion;
  final String reasonType;
  final String conceptFamilyId;
  final String sourceTaskId;
  final String sourceSessionId;
  final String evidenceKind;
  final String messageKey;
  final int priorityClass;
  final String recommendedDestination;
  final String recommendedAction;
  final String whyNowMessageKey;
  final String learnerSafeFocusLabel;
  final String rawEvidenceRef;

  String? get copyLine {
    return switch (messageKey) {
      act0ReturnReasonMessageContinueRepairV1 =>
        'You missed this clue last time. One more clean rep will keep it visible.',
      act0ReturnReasonMessageRetryRepairV1 =>
        'Your last repair did not land yet. Start there.',
      act0ReturnReasonMessageDueReviewV1 =>
        'Review this clue now. It is ready for a spaced check.',
      act0ReturnReasonMessageReinforceTransferV1 =>
        'You handled this clue better on a later hand. Reinforce it once more.',
      act0ReturnReasonMessageResumeFocusV1 =>
        'Resume your most recent table read.',
      _ => null,
    };
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'reasonType': reasonType,
    'conceptFamilyId': conceptFamilyId,
    if (sourceTaskId.isNotEmpty) 'sourceTaskId': sourceTaskId,
    if (sourceSessionId.isNotEmpty) 'sourceSessionId': sourceSessionId,
    'evidenceKind': evidenceKind,
    'messageKey': messageKey,
    'priorityClass': priorityClass,
    if (rawEvidenceRef.isNotEmpty) 'rawEvidenceRef': rawEvidenceRef,
  };

  /// Bounded projection for telemetry. Internal task and concept references
  /// deliberately never leave this decision contract.
  Map<String, Object?> toTelemetryPayload() => <String, Object?>{
    'reason_type': reasonType,
    'evidence_kind': evidenceKind,
    'priority_class': priorityClass,
    'destination': recommendedDestination,
    'action': recommendedAction,
  };
}

Act0PersonalizedReturnReasonV1? _activeRepairReason(
  List<Act0RepairIntentV1> intents,
) {
  final sorted =
      <Act0RepairIntentV1>[
        for (final intent in intents)
          if (_conceptIdFromIntent(intent).isNotEmpty) intent,
      ]..sort((a, b) {
        final sourceCompare = a.sourceTaskId.compareTo(b.sourceTaskId);
        if (sourceCompare != 0) {
          return sourceCompare;
        }
        return _conceptIdFromIntent(a).compareTo(_conceptIdFromIntent(b));
      });
  if (sorted.isEmpty) {
    return null;
  }
  final intent = sorted.first;
  return Act0PersonalizedReturnReasonV1(
    reasonType: act0ReturnReasonContinueUnresolvedRepairV1,
    conceptFamilyId: _conceptIdFromIntent(intent),
    sourceTaskId: intent.sourceTaskId.trim(),
    evidenceKind: act0ReturnReasonEvidenceActiveRepairV1,
    messageKey: act0ReturnReasonMessageContinueRepairV1,
    priorityClass: 0,
    recommendedDestination: 'review',
    recommendedAction: 'repair',
    whyNowMessageKey: 'unfinished_repair',
    learnerSafeFocusLabel: intent.missedSignalLabel.trim(),
    rawEvidenceRef: 'active_repair:${intent.sourceTaskId.trim()}',
  );
}

Act0PersonalizedReturnReasonV1? _retryRepairReason(
  Act0ConceptFamilyStateHistoryV1 history,
) {
  final candidates = _validFamilies(history)
      .where(
        (family) =>
            family.lastOutcome ==
                act0ConceptFamilyOutcomeRepairNotYetSucceededV1 ||
            (family.repairAttemptCount > family.successfulRepairCount &&
                family.lastAttemptAt != null),
      )
      .toList(growable: false);
  final family = _latestFamily(candidates, order: _repairOrder);
  if (family == null) {
    return null;
  }
  return Act0PersonalizedReturnReasonV1(
    reasonType: act0ReturnReasonRetryNotYetSucceededV1,
    conceptFamilyId: family.conceptFamilyId,
    sourceTaskId: family.lastTaskId ?? '',
    sourceSessionId: family.lastSessionId ?? '',
    evidenceKind: act0ReturnReasonEvidenceConceptFamilyStateV1,
    messageKey: act0ReturnReasonMessageRetryRepairV1,
    priorityClass: 1,
    recommendedDestination: 'review',
    recommendedAction: 'retry_repair',
    whyNowMessageKey: 'repair_not_landed',
    rawEvidenceRef: 'concept_family:${family.conceptFamilyId}',
  );
}

Act0PersonalizedReturnReasonV1? _dueReviewReason(
  List<Act0DueReviewItemV1> dueItems,
) {
  final candidates = <Act0DueReviewItemV1>[
    for (final item in dueItems)
      if (item.conceptFamilyId.trim().isNotEmpty &&
          item.taskId.trim().isNotEmpty &&
          item.worldId.trim().isNotEmpty &&
          item.lessonId.trim().isNotEmpty)
        item,
  ]..sort(_compareDueReviewItems);
  if (candidates.isEmpty) return null;
  final item = candidates.first;
  return Act0PersonalizedReturnReasonV1(
    reasonType: act0ReturnReasonDueReviewV1,
    conceptFamilyId: item.conceptFamilyId.trim(),
    sourceTaskId: item.taskId.trim(),
    evidenceKind: act0ReturnReasonEvidenceDurableRetentionV1,
    messageKey: act0ReturnReasonMessageDueReviewV1,
    priorityClass: 2,
    recommendedDestination: 'review',
    recommendedAction: 'spaced_review',
    whyNowMessageKey: 'due_for_review',
    rawEvidenceRef: 'due_review:${item.taskId.trim()}',
  );
}

int _compareDueReviewItems(Act0DueReviewItemV1 a, Act0DueReviewItemV1 b) {
  final due = a.nextDueAtUtc.compareTo(b.nextDueAtUtc);
  if (due != 0) return due;
  final severity = (b.repeatedMissCount + b.lapseCount).compareTo(
    a.repeatedMissCount + a.lapseCount,
  );
  if (severity != 0) return severity;
  final family = a.conceptFamilyId.compareTo(b.conceptFamilyId);
  return family != 0 ? family : a.taskId.compareTo(b.taskId);
}

Act0PersonalizedReturnReasonV1? _reinforceTransferReason(
  Act0LearningTransferMeasurementV1 measurement,
) {
  final candidates =
      measurement.signals
          .where(
            (signal) =>
                signal.conceptFamilyId.trim().isNotEmpty &&
                signal.conceptFamilyId.trim() != 'none' &&
                signal.relationship ==
                    act0LearningTransferSameFamilyTransferV1 &&
                (signal.verdict == act0LearningTransferImprovedV1 ||
                    signal.verdict == act0LearningTransferHeldV1),
          )
          .toList(growable: false)
        ..sort((a, b) {
          final orderCompare = (b.comparisonOrder ?? -1).compareTo(
            a.comparisonOrder ?? -1,
          );
          if (orderCompare != 0) {
            return orderCompare;
          }
          return a.conceptFamilyId.compareTo(b.conceptFamilyId);
        });
  if (candidates.isEmpty) {
    return null;
  }
  final signal = candidates.first;
  return Act0PersonalizedReturnReasonV1(
    reasonType: act0ReturnReasonReinforceRecentImprovementV1,
    conceptFamilyId: signal.conceptFamilyId,
    sourceTaskId: signal.comparisonTaskId,
    sourceSessionId: signal.comparisonSessionId,
    evidenceKind: act0ReturnReasonEvidenceTransferMeasurementV1,
    messageKey: act0ReturnReasonMessageReinforceTransferV1,
    priorityClass: 3,
    recommendedDestination: 'learn',
    recommendedAction: 'reinforce',
    whyNowMessageKey: 'transfer_evidence',
    rawEvidenceRef: 'transfer:${signal.conceptFamilyId}',
  );
}

Act0PersonalizedReturnReasonV1? _recentFocusReason(
  Act0ConceptFamilyStateHistoryV1 history,
) {
  final family = _latestFamily(_validFamilies(history), order: _seenOrder);
  if (family == null) {
    return null;
  }
  return Act0PersonalizedReturnReasonV1(
    reasonType: act0ReturnReasonResumeRecentFocusV1,
    conceptFamilyId: family.conceptFamilyId,
    sourceTaskId: family.lastTaskId ?? '',
    sourceSessionId: family.lastSessionId ?? '',
    evidenceKind: act0ReturnReasonEvidenceConceptFamilyStateV1,
    messageKey: act0ReturnReasonMessageResumeFocusV1,
    priorityClass: 4,
    recommendedDestination: 'learn',
    recommendedAction: 'resume_focus',
    whyNowMessageKey: 'recent_focus',
    rawEvidenceRef: 'concept_family:${family.conceptFamilyId}',
  );
}

List<Act0ConceptFamilyStateV1> _validFamilies(
  Act0ConceptFamilyStateHistoryV1 history,
) {
  return history.families
      .where(
        (family) =>
            family.conceptFamilyId.trim().isNotEmpty &&
            family.conceptFamilyId.trim() != 'none',
      )
      .toList(growable: false);
}

Act0ConceptFamilyStateV1? _latestFamily(
  List<Act0ConceptFamilyStateV1> families, {
  required int Function(Act0ConceptFamilyStateV1 family) order,
}) {
  if (families.isEmpty) {
    return null;
  }
  final sorted = <Act0ConceptFamilyStateV1>[...families]
    ..sort((a, b) {
      final orderCompare = order(b).compareTo(order(a));
      if (orderCompare != 0) {
        return orderCompare;
      }
      return a.conceptFamilyId.compareTo(b.conceptFamilyId);
    });
  return sorted.first;
}

int _repairOrder(Act0ConceptFamilyStateV1 family) =>
    family.lastAttemptAt ?? family.lastSeenAt;

int _seenOrder(Act0ConceptFamilyStateV1 family) => family.lastSeenAt;

String _conceptIdFromIntent(Act0RepairIntentV1 intent) {
  final missedSignalId = intent.missedSignalId.trim();
  if (missedSignalId.isNotEmpty) {
    return missedSignalId;
  }
  final skillAtomId = intent.skillAtomId.trim();
  if (skillAtomId.isNotEmpty) {
    return skillAtomId;
  }
  return intent.errorType.trim();
}
