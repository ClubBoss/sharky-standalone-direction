import 'act0_learning_evidence_contract_v1.dart';

const String act0LearningTransferSameFamilyTransferV1 =
    'same_family_transfer_v1';
const String act0LearningTransferSameTaskRepeatV1 = 'same_task_repeat_v1';
const String act0LearningTransferInsufficientEvidenceV1 =
    'insufficient_evidence_v1';

const String act0LearningTransferImprovedV1 = 'improved_v1';
const String act0LearningTransferHeldV1 = 'held_v1';
const String act0LearningTransferNotYetImprovedV1 = 'not_yet_improved_v1';

class Act0LearningTransferMeasurementV1 {
  const Act0LearningTransferMeasurementV1({required this.signals});

  final List<Act0LearningTransferSignalV1> signals;

  factory Act0LearningTransferMeasurementV1.fromLearningEvidence(
    Act0LearningEvidenceHistoryV1 history,
  ) {
    final buckets = <String, _Act0LearningTransferBucketV1>{};
    for (final record in history.records) {
      final conceptFamilyId = _conceptFamilyId(record);
      if (conceptFamilyId.isEmpty || conceptFamilyId == 'none') {
        continue;
      }
      buckets
          .putIfAbsent(
            conceptFamilyId,
            () => _Act0LearningTransferBucketV1(conceptFamilyId),
          )
          .add(record);
    }
    final signals =
        buckets.values
            .map((bucket) => bucket.toSignal())
            .toList(growable: false)
          ..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0LearningTransferMeasurementV1(
      signals: List<Act0LearningTransferSignalV1>.unmodifiable(signals),
    );
  }

  Act0LearningTransferSignalV1 signalForConcept(String conceptFamilyId) {
    final id = conceptFamilyId.trim();
    if (id.isEmpty) {
      return Act0LearningTransferSignalV1.insufficient(id);
    }
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
  });

  factory Act0LearningTransferSignalV1.insufficient(String conceptFamilyId) {
    return Act0LearningTransferSignalV1(
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
  }

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
}

class _Act0LearningTransferBucketV1 {
  _Act0LearningTransferBucketV1(this.conceptFamilyId);

  final String conceptFamilyId;
  final List<Act0LearningEvidenceRecordV1> _records =
      <Act0LearningEvidenceRecordV1>[];

  void add(Act0LearningEvidenceRecordV1 record) {
    _records.add(record);
  }

  Act0LearningTransferSignalV1 toSignal() {
    if (_records.length < 2 || _hasUnsafeOrdering(_records)) {
      return Act0LearningTransferSignalV1.insufficient(conceptFamilyId);
    }
    final ordered = <Act0LearningEvidenceRecordV1>[..._records]
      ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
    final baseline = ordered.first;
    final comparison = ordered
        .where((record) => record.createdOrder > baseline.createdOrder)
        .lastOrNull;
    if (comparison == null) {
      return Act0LearningTransferSignalV1.insufficient(conceptFamilyId);
    }
    final relationship = _relationship(baseline, comparison);
    final verdict = relationship == act0LearningTransferSameFamilyTransferV1
        ? _verdict(baseline, comparison)
        : act0LearningTransferInsufficientEvidenceV1;
    return Act0LearningTransferSignalV1(
      conceptFamilyId: conceptFamilyId,
      relationship: relationship,
      verdict: verdict,
      baselineOrder: baseline.createdOrder,
      comparisonOrder: comparison.createdOrder,
      baselineTaskId: baseline.taskId,
      comparisonTaskId: comparison.taskId,
      baselineSessionId: baseline.sessionId,
      comparisonSessionId: comparison.sessionId,
      baselineDecisionTimeBucket: baseline.decisionTimeBucket,
      comparisonDecisionTimeBucket: comparison.decisionTimeBucket,
    );
  }
}

bool _hasUnsafeOrdering(List<Act0LearningEvidenceRecordV1> records) {
  final seenOrders = <int>{};
  for (final record in records) {
    if (record.createdOrder < 0 || !seenOrders.add(record.createdOrder)) {
      return true;
    }
  }
  return false;
}

String _relationship(
  Act0LearningEvidenceRecordV1 baseline,
  Act0LearningEvidenceRecordV1 comparison,
) {
  final baselineTaskId = baseline.taskId.trim();
  final comparisonTaskId = comparison.taskId.trim();
  final baselineSessionId = baseline.sessionId.trim();
  final comparisonSessionId = comparison.sessionId.trim();
  if (baselineTaskId.isEmpty ||
      comparisonTaskId.isEmpty ||
      baselineSessionId.isEmpty ||
      comparisonSessionId.isEmpty ||
      baselineSessionId == comparisonSessionId) {
    return act0LearningTransferInsufficientEvidenceV1;
  }
  if (baselineTaskId == comparisonTaskId) {
    return act0LearningTransferSameTaskRepeatV1;
  }
  return act0LearningTransferSameFamilyTransferV1;
}

String _verdict(
  Act0LearningEvidenceRecordV1 baseline,
  Act0LearningEvidenceRecordV1 comparison,
) {
  if (!baseline.isCorrect && comparison.isCorrect) {
    return act0LearningTransferImprovedV1;
  }
  if (baseline.isCorrect && comparison.isCorrect) {
    return act0LearningTransferHeldV1;
  }
  return act0LearningTransferNotYetImprovedV1;
}

String _conceptFamilyId(Act0LearningEvidenceRecordV1 record) {
  final conceptFamilyId = record.conceptFamilyId.trim();
  if (conceptFamilyId.isNotEmpty) {
    return conceptFamilyId;
  }
  final repairFocusId = record.repairFocusId.trim();
  if (repairFocusId.isNotEmpty) {
    return repairFocusId;
  }
  final skillAtomId = record.skillAtomId.trim();
  if (skillAtomId.isNotEmpty) {
    return skillAtomId;
  }
  return record.errorType.trim();
}

extension _Act0LearningTransferIterableX<T> on Iterable<T> {
  T? get lastOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    var value = iterator.current;
    while (iterator.moveNext()) {
      value = iterator.current;
    }
    return value;
  }
}
