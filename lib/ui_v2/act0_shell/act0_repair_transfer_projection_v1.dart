import 'act0_learning_evidence_contract_v1.dart';

const String act0RepairTransferNoPriorMissV1 = 'no_prior_miss_v1';
const String act0RepairTransferMissStillActiveV1 = 'miss_still_active_v1';
const String act0RepairTransferLaterCorrectSignalV1 = 'later_correct_signal_v1';
const String act0RepairTransferInsufficientOrderingV1 =
    'insufficient_ordering_v1';
const String act0RepairTransferUnmappedConceptV1 = 'unmapped_concept_v1';
const String act0RepairTransferUnsafeEvidenceV1 = 'unsafe_evidence_v1';

class Act0RepairTransferProjectionV1 {
  const Act0RepairTransferProjectionV1({required this.signals});

  final List<Act0RepairTransferSignalV1> signals;

  factory Act0RepairTransferProjectionV1.fromLearningEvidence(
    Act0LearningEvidenceHistoryV1 history,
  ) {
    final buckets = <String, _Act0RepairTransferAccumulatorV1>{};
    for (final record in history.records) {
      final conceptFamilyId = _conceptFamilyId(record);
      if (conceptFamilyId.isEmpty || conceptFamilyId == 'none') {
        continue;
      }
      buckets
          .putIfAbsent(
            conceptFamilyId,
            () => _Act0RepairTransferAccumulatorV1(conceptFamilyId),
          )
          .add(record);
    }
    final signals =
        buckets.values
            .map((bucket) => bucket.toSignal())
            .toList(growable: false)
          ..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0RepairTransferProjectionV1(
      signals: List<Act0RepairTransferSignalV1>.unmodifiable(signals),
    );
  }

  Act0RepairTransferSignalV1 signalForConcept(String conceptFamilyId) {
    final id = conceptFamilyId.trim();
    if (id.isEmpty) {
      return Act0RepairTransferSignalV1.unmapped(id);
    }
    for (final signal in signals) {
      if (signal.conceptFamilyId == id) {
        return signal;
      }
    }
    return Act0RepairTransferSignalV1.unmapped(id);
  }
}

class Act0RepairTransferSignalV1 {
  const Act0RepairTransferSignalV1({
    required this.conceptFamilyId,
    required this.state,
    required this.priorMissOrder,
    required this.laterCorrectOrder,
    required this.incorrectCount,
    required this.correctCount,
  });

  factory Act0RepairTransferSignalV1.unmapped(String conceptFamilyId) {
    return Act0RepairTransferSignalV1(
      conceptFamilyId: conceptFamilyId,
      state: act0RepairTransferUnmappedConceptV1,
      priorMissOrder: null,
      laterCorrectOrder: null,
      incorrectCount: 0,
      correctCount: 0,
    );
  }

  final String conceptFamilyId;
  final String state;
  final int? priorMissOrder;
  final int? laterCorrectOrder;
  final int incorrectCount;
  final int correctCount;

  bool get hasLaterCorrectSignal =>
      state == act0RepairTransferLaterCorrectSignalV1;
}

class _Act0RepairTransferAccumulatorV1 {
  _Act0RepairTransferAccumulatorV1(this.conceptFamilyId);

  final String conceptFamilyId;
  int incorrectCount = 0;
  int correctCount = 0;
  int? latestMissOrder;
  int? firstCorrectAfterLatestMissOrder;
  bool hasInsufficientOrdering = false;

  void add(Act0LearningEvidenceRecordV1 record) {
    if (record.createdOrder < 0) {
      hasInsufficientOrdering = true;
    }
    if (record.isCorrect) {
      correctCount += 1;
      if (latestMissOrder != null &&
          record.createdOrder > latestMissOrder! &&
          (firstCorrectAfterLatestMissOrder == null ||
              record.createdOrder < firstCorrectAfterLatestMissOrder!)) {
        firstCorrectAfterLatestMissOrder = record.createdOrder;
      }
      return;
    }
    incorrectCount += 1;
    if (latestMissOrder == null || record.createdOrder >= latestMissOrder!) {
      latestMissOrder = record.createdOrder;
      firstCorrectAfterLatestMissOrder = null;
    }
  }

  Act0RepairTransferSignalV1 toSignal() {
    final state = _state();
    return Act0RepairTransferSignalV1(
      conceptFamilyId: conceptFamilyId,
      state: state,
      priorMissOrder: state == act0RepairTransferNoPriorMissV1
          ? null
          : latestMissOrder,
      laterCorrectOrder: state == act0RepairTransferLaterCorrectSignalV1
          ? firstCorrectAfterLatestMissOrder
          : null,
      incorrectCount: incorrectCount,
      correctCount: correctCount,
    );
  }

  String _state() {
    if (hasInsufficientOrdering) {
      return act0RepairTransferInsufficientOrderingV1;
    }
    if (incorrectCount == 0) {
      return act0RepairTransferNoPriorMissV1;
    }
    if (firstCorrectAfterLatestMissOrder != null) {
      return act0RepairTransferLaterCorrectSignalV1;
    }
    return act0RepairTransferMissStillActiveV1;
  }
}

String _conceptFamilyId(Act0LearningEvidenceRecordV1 record) {
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
