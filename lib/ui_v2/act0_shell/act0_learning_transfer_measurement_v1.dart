import 'act0_durable_learning_time_contract_v1.dart';
import 'act0_durable_retention_contract_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';

const String act0LearningTransferSameFamilyTransferV1 =
    'same_family_transfer_v1';
const String act0LearningTransferSameTaskRepeatV1 = 'same_task_repeat_v1';
const String act0LearningTransferInsufficientEvidenceV1 =
    'insufficient_evidence_v1';

const String act0LearningTransferRecoveredNotDurableV1 =
    'recovered_not_durable_v1';
const String act0LearningTransferImprovingV1 = 'improving_v1';
const String act0LearningTransferStableV1 = 'stable_v1';
const String act0LearningTransferRegressingV1 = 'regressing_v1';
const String act0LearningTransferMixedV1 = 'mixed_v1';

// Source-compatible aliases for existing deterministic consumers.
const String act0LearningTransferImprovedV1 = act0LearningTransferImprovingV1;
const String act0LearningTransferHeldV1 = act0LearningTransferStableV1;
const String act0LearningTransferNotYetImprovedV1 = act0LearningTransferMixedV1;

class Act0LearningTransferMeasurementV1 {
  const Act0LearningTransferMeasurementV1({required this.signals});

  final List<Act0LearningTransferSignalV1> signals;

  factory Act0LearningTransferMeasurementV1.fromLearningEvidence(
    Act0LearningEvidenceHistoryV1 history, {
    Act0DurableRetentionHistoryV1? retentionHistory,
  }) {
    final retention =
        retentionHistory ??
        Act0DurableRetentionHistoryV1.fromLearningEvidence(history);
    final buckets = <String, List<Act0LearningEvidenceRecordV1>>{};
    for (final record in history.records) {
      final conceptFamilyId = act0ConceptFamilyIdForDurableEvidenceV1(record);
      if (conceptFamilyId.isEmpty || conceptFamilyId == 'none') {
        continue;
      }
      buckets.putIfAbsent(conceptFamilyId, () => []).add(record);
    }
    final signals = <Act0LearningTransferSignalV1>[
      for (final entry in buckets.entries)
        _signalForRecords(
          entry.key,
          entry.value,
          retention.familyById(entry.key),
        ),
    ]..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0LearningTransferMeasurementV1(
      signals: List<Act0LearningTransferSignalV1>.unmodifiable(signals),
    );
  }

  Act0LearningTransferSignalV1 signalForConcept(String conceptFamilyId) {
    final id = conceptFamilyId.trim();
    for (final signal in signals) {
      if (signal.conceptFamilyId == id) {
        return signal;
      }
    }
    return Act0LearningTransferSignalV1.insufficient(id);
  }
}

class Act0LearningTransferSignalV1 {
  const Act0LearningTransferSignalV1({
    required this.conceptFamilyId,
    required this.relationship,
    required this.verdict,
    required this.baselineOrder,
    required this.comparisonOrder,
    required this.baselineTaskId,
    required this.comparisonTaskId,
    required this.baselineSessionId,
    required this.comparisonSessionId,
    required this.baselineDecisionTimeBucket,
    required this.comparisonDecisionTimeBucket,
    this.eligibleEvidenceCount = 0,
    this.recentWindowCount = 0,
  });

  factory Act0LearningTransferSignalV1.insufficient(String conceptFamilyId) =>
      Act0LearningTransferSignalV1(
        conceptFamilyId: conceptFamilyId,
        relationship: act0LearningTransferInsufficientEvidenceV1,
        verdict: act0LearningTransferInsufficientEvidenceV1,
        baselineOrder: null,
        comparisonOrder: null,
        baselineTaskId: '',
        comparisonTaskId: '',
        baselineSessionId: '',
        comparisonSessionId: '',
        baselineDecisionTimeBucket: '',
        comparisonDecisionTimeBucket: '',
      );

  final String conceptFamilyId;
  final String relationship;
  final String verdict;
  final int? baselineOrder;
  final int? comparisonOrder;
  final String baselineTaskId;
  final String comparisonTaskId;
  final String baselineSessionId;
  final String comparisonSessionId;
  final String baselineDecisionTimeBucket;
  final String comparisonDecisionTimeBucket;
  final int eligibleEvidenceCount;
  final int recentWindowCount;
}

Act0LearningTransferSignalV1 _signalForRecords(
  String conceptFamilyId,
  List<Act0LearningEvidenceRecordV1> records,
  Act0DurableRetentionFamilyV1? retention,
) {
  final eligible = records.where(_eligibleForTransferTrend).toList()
    ..sort(_compareEvidenceTimeThenOrder);
  final recoveryOnly = _hasRecoveryWithoutDurability(retention, records);
  if (!_hasAdequateTimingAndDiversity(eligible)) {
    final signal = _signalFromPair(
      conceptFamilyId,
      eligible,
      recoveryOnly
          ? act0LearningTransferRecoveredNotDurableV1
          : act0LearningTransferInsufficientEvidenceV1,
    );
    return signal;
  }

  final recentStart =
      eligible.length > Act0DurableLearningTimingV1.recentEvidenceWindow
      ? eligible.length - Act0DurableLearningTimingV1.recentEvidenceWindow
      : 0;
  final recent = eligible.sublist(recentStart);
  final latest = recent.last;
  final earlier = eligible.take(eligible.length - 1);
  final hasEarlierCorrect = earlier.any((record) => record.isCorrect);
  final hasEarlierMiss = earlier.any((record) => !record.isCorrect);
  final recentCorrect = recent.where((record) => record.isCorrect).length;
  final recentMisses = recent.length - recentCorrect;

  final String verdict;
  if (!latest.isCorrect && hasEarlierCorrect) {
    verdict = act0LearningTransferRegressingV1;
  } else if (retention?.retentionState == Act0RetentionStateV1.durable &&
      latest.isCorrect &&
      recent.reversed.take(2).every((record) => record.isCorrect)) {
    verdict = act0LearningTransferStableV1;
  } else if (latest.isCorrect && hasEarlierMiss && recentMisses == 1) {
    verdict = act0LearningTransferImprovingV1;
  } else if (recentCorrect > 0 && recentMisses > 0) {
    verdict = act0LearningTransferMixedV1;
  } else if (recoveryOnly) {
    verdict = act0LearningTransferRecoveredNotDurableV1;
  } else if (recentMisses == 0 && _hasTwoSpacedSuccesses(recent)) {
    verdict = act0LearningTransferStableV1;
  } else {
    verdict = act0LearningTransferMixedV1;
  }
  return _signalFromPair(conceptFamilyId, recent, verdict);
}

bool _eligibleForTransferTrend(Act0LearningEvidenceRecordV1 record) {
  if (record.recordedAtUtc == null) {
    return false;
  }
  return record.reviewKind != Act0ReviewKindV1.legacyUnspaced &&
      record.reviewKind != Act0ReviewKindV1.immediateRepair &&
      record.reviewKind != Act0ReviewKindV1.exactReplay;
}

bool _hasAdequateTimingAndDiversity(
  List<Act0LearningEvidenceRecordV1> records,
) {
  if (records.length < 2) {
    return false;
  }
  final taskIds = records
      .map((record) => record.taskId.trim())
      .where((id) => id.isNotEmpty)
      .toSet();
  if (taskIds.length < 2) {
    return false;
  }
  final sessionIds = records
      .map((record) => record.sessionId.trim())
      .where((id) => id.isNotEmpty)
      .toSet();
  if (sessionIds.length < 2) {
    return false;
  }
  final first = records.first.recordedAtUtc!;
  final last = records.last.recordedAtUtc!;
  return last.difference(first) >=
      Act0DurableLearningTimingV1.minimumTransferSeparation;
}

bool _hasRecoveryWithoutDurability(
  Act0DurableRetentionFamilyV1? retention,
  List<Act0LearningEvidenceRecordV1> records,
) {
  if (retention != null &&
      (retention.retentionState ==
              Act0RetentionStateV1.recoveredPendingSpacedReview ||
          retention.retentionState == Act0RetentionStateV1.due ||
          retention.retentionState == Act0RetentionStateV1.lapsed ||
          retention.retentionState == Act0RetentionStateV1.needsRepair)) {
    return records.any(
      (record) => record.isCorrect && record.recordedAtUtc != null,
    );
  }
  final ordered = [...records]..sort(_compareEvidenceTimeThenOrder);
  final firstMiss = ordered.indexWhere((record) => !record.isCorrect);
  return firstMiss >= 0 &&
      ordered
          .skip(firstMiss + 1)
          .any((record) => record.isCorrect && record.recordedAtUtc != null);
}

bool _hasTwoSpacedSuccesses(List<Act0LearningEvidenceRecordV1> records) {
  final correct = records.where((record) => record.isCorrect).toList();
  if (correct.length < 2) {
    return false;
  }
  return correct.last.recordedAtUtc!.difference(
        correct[correct.length - 2].recordedAtUtc!,
      ) >=
      Act0DurableLearningTimingV1.minimumTransferSeparation;
}

Act0LearningTransferSignalV1 _signalFromPair(
  String conceptFamilyId,
  List<Act0LearningEvidenceRecordV1> records,
  String verdict,
) {
  if (records.isEmpty) {
    return Act0LearningTransferSignalV1(
      conceptFamilyId: conceptFamilyId,
      relationship: act0LearningTransferInsufficientEvidenceV1,
      verdict: verdict,
      baselineOrder: null,
      comparisonOrder: null,
      baselineTaskId: '',
      comparisonTaskId: '',
      baselineSessionId: '',
      comparisonSessionId: '',
      baselineDecisionTimeBucket: '',
      comparisonDecisionTimeBucket: '',
    );
  }
  final comparison = records.last;
  final baseline = records.length > 1 ? records[records.length - 2] : null;
  final relationship = baseline == null
      ? act0LearningTransferInsufficientEvidenceV1
      : baseline.taskId == comparison.taskId
      ? act0LearningTransferSameTaskRepeatV1
      : act0LearningTransferSameFamilyTransferV1;
  return Act0LearningTransferSignalV1(
    conceptFamilyId: conceptFamilyId,
    relationship: relationship,
    verdict: verdict,
    baselineOrder: baseline?.createdOrder,
    comparisonOrder: comparison.createdOrder,
    baselineTaskId: baseline?.taskId ?? '',
    comparisonTaskId: comparison.taskId,
    baselineSessionId: baseline?.sessionId ?? '',
    comparisonSessionId: comparison.sessionId,
    baselineDecisionTimeBucket: baseline?.decisionTimeBucket ?? '',
    comparisonDecisionTimeBucket: comparison.decisionTimeBucket,
    eligibleEvidenceCount: records.length,
    recentWindowCount: records.length,
  );
}

int _compareEvidenceTimeThenOrder(
  Act0LearningEvidenceRecordV1 a,
  Act0LearningEvidenceRecordV1 b,
) {
  final aTime = a.recordedAtUtc;
  final bTime = b.recordedAtUtc;
  if (aTime == null && bTime != null) {
    return -1;
  }
  if (aTime != null && bTime == null) {
    return 1;
  }
  final time = aTime == null ? 0 : aTime.compareTo(bTime!);
  if (time != 0) {
    return time;
  }
  final order = a.createdOrder.compareTo(b.createdOrder);
  return order != 0 ? order : a.recordId.compareTo(b.recordId);
}
