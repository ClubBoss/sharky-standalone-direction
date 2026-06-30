import 'act0_learning_evidence_contract_v1.dart';
import 'act0_repair_transfer_projection_v1.dart';

const String act0PracticeActionTransferLaterCorrectWithoutPracticeEvidenceV1 =
    'later_correct_without_practice_evidence_v1';
const String act0PracticeActionTransferPracticeBeforeCorrectV1 =
    'practice_attempt_before_later_correct_v1';
const String act0PracticeActionTransferSessionSummaryCtaBeforeCorrectV1 =
    'session_summary_cta_before_later_correct_v1';
const String act0PracticeActionTransferUnknownSourceBeforeCorrectV1 =
    'repair_attempt_before_later_correct_unknown_source_v1';
const String act0PracticeActionTransferOtherRepairBeforeCorrectV1 =
    'other_repair_before_later_correct_v1';
const String act0PracticeActionTransferPracticeAfterCorrectV1 =
    'practice_attempt_after_later_correct_v1';
const String act0PracticeActionTransferPracticeEvidenceUnorderedV1 =
    'practice_evidence_unordered_v1';
const String act0PracticeActionTransferUnrelatedPracticeTargetV1 =
    'unrelated_practice_target_v1';
const String act0PracticeActionTransferInsufficientEvidenceV1 =
    'insufficient_evidence_v1';
const String act0PracticeActionTransferUnsafeEvidenceV1 = 'unsafe_evidence_v1';
const String act0PracticeActionTransferSourceUnavailableV1 =
    'source_unavailable_v1';
const String act0PracticeActionTransferSourceSessionSummaryCtaV1 =
    'session_summary_cta_v1';
const String act0PracticeActionTransferSourceOtherRepairV1 = 'other_repair_v1';

class Act0PracticeActionTransferJoinProjectionV1 {
  const Act0PracticeActionTransferJoinProjectionV1({required this.signals});

  final List<Act0PracticeActionTransferJoinSignalV1> signals;

  factory Act0PracticeActionTransferJoinProjectionV1.fromEvidence(
    Act0LearningEvidenceHistoryV1 history,
  ) {
    final transfer = Act0RepairTransferProjectionV1.fromLearningEvidence(
      history,
    );
    final repairRecords = history.records
        .where(_isRepairPracticeEvidence)
        .toList(growable: false);
    final signals = <Act0PracticeActionTransferJoinSignalV1>[
      for (final transferSignal in transfer.signals)
        _joinSignal(transferSignal, repairRecords),
    ]..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0PracticeActionTransferJoinProjectionV1(
      signals: List<Act0PracticeActionTransferJoinSignalV1>.unmodifiable(
        signals,
      ),
    );
  }

  Act0PracticeActionTransferJoinSignalV1 signalForConcept(
    String conceptFamilyId,
  ) {
    final id = conceptFamilyId.trim();
    for (final signal in signals) {
      if (signal.conceptFamilyId == id) {
        return signal;
      }
    }
    return Act0PracticeActionTransferJoinSignalV1.insufficient(id);
  }
}

class Act0PracticeActionTransferJoinSignalV1 {
  const Act0PracticeActionTransferJoinSignalV1({
    required this.conceptFamilyId,
    required this.state,
    required this.priorMissOrder,
    required this.practiceEvidenceOrder,
    required this.laterCorrectOrder,
    this.practiceSource = act0PracticeActionTransferSourceUnavailableV1,
  });

  factory Act0PracticeActionTransferJoinSignalV1.insufficient(
    String conceptFamilyId,
  ) {
    return Act0PracticeActionTransferJoinSignalV1(
      conceptFamilyId: conceptFamilyId,
      state: act0PracticeActionTransferInsufficientEvidenceV1,
      priorMissOrder: null,
      practiceEvidenceOrder: null,
      laterCorrectOrder: null,
    );
  }

  final String conceptFamilyId;
  final String state;
  final int? priorMissOrder;
  final int? practiceEvidenceOrder;
  final int? laterCorrectOrder;
  final String practiceSource;
}

Act0PracticeActionTransferJoinSignalV1 _joinSignal(
  Act0RepairTransferSignalV1 transferSignal,
  List<Act0LearningEvidenceRecordV1> repairRecords,
) {
  final conceptFamilyId = transferSignal.conceptFamilyId;
  final sameConceptRepairRecords =
      repairRecords
          .where((record) => _conceptFamilyId(record) == conceptFamilyId)
          .toList(growable: false)
        ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
  if (sameConceptRepairRecords.any((record) => record.createdOrder < 0)) {
    return Act0PracticeActionTransferJoinSignalV1(
      conceptFamilyId: conceptFamilyId,
      state: act0PracticeActionTransferPracticeEvidenceUnorderedV1,
      priorMissOrder: transferSignal.priorMissOrder,
      practiceEvidenceOrder: null,
      laterCorrectOrder: transferSignal.laterCorrectOrder,
    );
  }
  if (transferSignal.state == act0RepairTransferUnsafeEvidenceV1) {
    return Act0PracticeActionTransferJoinSignalV1(
      conceptFamilyId: conceptFamilyId,
      state: act0PracticeActionTransferUnsafeEvidenceV1,
      priorMissOrder: transferSignal.priorMissOrder,
      practiceEvidenceOrder: null,
      laterCorrectOrder: transferSignal.laterCorrectOrder,
    );
  }
  if (transferSignal.state == act0RepairTransferInsufficientOrderingV1) {
    return Act0PracticeActionTransferJoinSignalV1(
      conceptFamilyId: conceptFamilyId,
      state: act0PracticeActionTransferInsufficientEvidenceV1,
      priorMissOrder: transferSignal.priorMissOrder,
      practiceEvidenceOrder: null,
      laterCorrectOrder: transferSignal.laterCorrectOrder,
    );
  }
  if (transferSignal.state != act0RepairTransferLaterCorrectSignalV1 ||
      transferSignal.priorMissOrder == null ||
      transferSignal.laterCorrectOrder == null) {
    return Act0PracticeActionTransferJoinSignalV1.insufficient(conceptFamilyId);
  }
  final priorPractice = sameConceptRepairRecords
      .cast<Act0LearningEvidenceRecordV1?>()
      .firstWhere(
        (record) =>
            record != null &&
            record.createdOrder >= transferSignal.priorMissOrder! &&
            record.createdOrder < transferSignal.laterCorrectOrder!,
        orElse: () => null,
      );
  if (priorPractice != null) {
    final practiceSource = _practiceSource(priorPractice);
    return Act0PracticeActionTransferJoinSignalV1(
      conceptFamilyId: conceptFamilyId,
      state: _priorPracticeState(practiceSource),
      priorMissOrder: transferSignal.priorMissOrder,
      practiceEvidenceOrder: priorPractice.createdOrder,
      laterCorrectOrder: transferSignal.laterCorrectOrder,
      practiceSource: practiceSource,
    );
  }
  final laterPractice = sameConceptRepairRecords
      .cast<Act0LearningEvidenceRecordV1?>()
      .firstWhere(
        (record) =>
            record != null &&
            record.createdOrder >= transferSignal.laterCorrectOrder!,
        orElse: () => null,
      );
  if (laterPractice != null) {
    return Act0PracticeActionTransferJoinSignalV1(
      conceptFamilyId: conceptFamilyId,
      state: act0PracticeActionTransferPracticeAfterCorrectV1,
      priorMissOrder: transferSignal.priorMissOrder,
      practiceEvidenceOrder: laterPractice.createdOrder,
      laterCorrectOrder: transferSignal.laterCorrectOrder,
    );
  }
  final hasOtherRepairEvidence = repairRecords.any(
    (record) => _conceptFamilyId(record) != conceptFamilyId,
  );
  return Act0PracticeActionTransferJoinSignalV1(
    conceptFamilyId: conceptFamilyId,
    state: hasOtherRepairEvidence
        ? act0PracticeActionTransferUnrelatedPracticeTargetV1
        : act0PracticeActionTransferLaterCorrectWithoutPracticeEvidenceV1,
    priorMissOrder: transferSignal.priorMissOrder,
    practiceEvidenceOrder: null,
    laterCorrectOrder: transferSignal.laterCorrectOrder,
  );
}

bool _isRepairPracticeEvidence(Act0LearningEvidenceRecordV1 record) {
  return record.runKind.trim() == 'repair';
}

String _practiceSource(Act0LearningEvidenceRecordV1 record) {
  return switch (record.startedBy.trim()) {
    'session_summary_practice_cta' =>
      act0PracticeActionTransferSourceSessionSummaryCtaV1,
    '' => act0PracticeActionTransferSourceUnavailableV1,
    _ => act0PracticeActionTransferSourceOtherRepairV1,
  };
}

String _priorPracticeState(String practiceSource) {
  return switch (practiceSource) {
    act0PracticeActionTransferSourceSessionSummaryCtaV1 =>
      act0PracticeActionTransferSessionSummaryCtaBeforeCorrectV1,
    act0PracticeActionTransferSourceOtherRepairV1 =>
      act0PracticeActionTransferOtherRepairBeforeCorrectV1,
    _ => act0PracticeActionTransferUnknownSourceBeforeCorrectV1,
  };
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
