import 'act0_learning_evidence_contract_v1.dart';

class Act0ConceptFamilyRepairMemoryV1 {
  const Act0ConceptFamilyRepairMemoryV1({required this.families});

  final List<Act0ConceptFamilyRepairSummaryV1> families;

  factory Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
    Act0LearningEvidenceHistoryV1 history,
  ) {
    final buckets = <String, _ConceptFamilyAccumulatorV1>{};
    for (final record in history.records) {
      final conceptFamilyId = _conceptFamilyId(record);
      if (conceptFamilyId.isEmpty) {
        continue;
      }
      buckets
          .putIfAbsent(
            conceptFamilyId,
            () => _ConceptFamilyAccumulatorV1(conceptFamilyId),
          )
          .add(record);
    }
    final families =
        buckets.values
            .map((bucket) => bucket.toSummary())
            .toList(growable: false)
          ..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0ConceptFamilyRepairMemoryV1(
      families: List<Act0ConceptFamilyRepairSummaryV1>.unmodifiable(families),
    );
  }

  Act0ConceptFamilyRepairCandidateV1? get nextRepairCandidate {
    final eligible = families
        .where((family) => family.incorrectCount > 0)
        .toList(growable: false);
    if (eligible.isEmpty) {
      return null;
    }
    eligible.sort(_candidateOrder);
    final family = eligible.first;
    return Act0ConceptFamilyRepairCandidateV1(
      conceptFamilyId: family.conceptFamilyId,
      repairFocusId: family.repairFocusId,
      skillAtomId: family.skillAtomId,
      errorType: family.latestErrorType,
      incorrectCount: family.incorrectCount,
      correctCount: family.correctCount,
      latestIncorrectOrder: family.latestIncorrectOrder,
      selectionReasonCode: family.incorrectCount > 1
          ? 'repeated_incorrect_family'
          : family.latestWasIncorrect
          ? 'latest_incorrect_family'
          : 'historical_incorrect_family',
    );
  }
}

class Act0ConceptFamilyRepairSummaryV1 {
  const Act0ConceptFamilyRepairSummaryV1({
    required this.conceptFamilyId,
    required this.repairFocusId,
    required this.skillAtomId,
    required this.correctCount,
    required this.incorrectCount,
    required this.latestOrder,
    required this.latestIncorrectOrder,
    required this.latestWasIncorrect,
    required this.latestErrorType,
    required this.latestDecisionTimeBucket,
    required this.slowDecisionCount,
  });

  final String conceptFamilyId;
  final String repairFocusId;
  final String skillAtomId;
  final int correctCount;
  final int incorrectCount;
  final int latestOrder;
  final int latestIncorrectOrder;
  final bool latestWasIncorrect;
  final String latestErrorType;
  final String latestDecisionTimeBucket;
  final int slowDecisionCount;
}

class Act0ConceptFamilyRepairCandidateV1 {
  const Act0ConceptFamilyRepairCandidateV1({
    required this.conceptFamilyId,
    required this.repairFocusId,
    required this.skillAtomId,
    required this.errorType,
    required this.incorrectCount,
    required this.correctCount,
    required this.latestIncorrectOrder,
    required this.selectionReasonCode,
  });

  final String conceptFamilyId;
  final String repairFocusId;
  final String skillAtomId;
  final String errorType;
  final int incorrectCount;
  final int correctCount;
  final int latestIncorrectOrder;
  final String selectionReasonCode;
}

class _ConceptFamilyAccumulatorV1 {
  _ConceptFamilyAccumulatorV1(this.conceptFamilyId);

  final String conceptFamilyId;
  String repairFocusId = '';
  String skillAtomId = '';
  String latestErrorType = '';
  String latestDecisionTimeBucket = '';
  int correctCount = 0;
  int incorrectCount = 0;
  int latestOrder = -1;
  int latestIncorrectOrder = -1;
  int slowDecisionCount = 0;
  bool latestWasIncorrect = false;

  void add(Act0LearningEvidenceRecordV1 record) {
    if (repairFocusId.isEmpty) {
      repairFocusId = record.repairFocusId.trim();
    }
    if (skillAtomId.isEmpty) {
      skillAtomId = record.skillAtomId.trim();
    }
    if (record.decisionTimeBucket == 'over_10s') {
      slowDecisionCount += 1;
    }
    if (record.isCorrect) {
      correctCount += 1;
    } else {
      incorrectCount += 1;
      latestIncorrectOrder = record.createdOrder;
    }
    if (record.createdOrder >= latestOrder) {
      latestOrder = record.createdOrder;
      latestWasIncorrect = !record.isCorrect;
      latestErrorType = record.errorType.trim();
      latestDecisionTimeBucket = record.decisionTimeBucket.trim();
    }
  }

  Act0ConceptFamilyRepairSummaryV1 toSummary() {
    return Act0ConceptFamilyRepairSummaryV1(
      conceptFamilyId: conceptFamilyId,
      repairFocusId: repairFocusId,
      skillAtomId: skillAtomId,
      correctCount: correctCount,
      incorrectCount: incorrectCount,
      latestOrder: latestOrder,
      latestIncorrectOrder: latestIncorrectOrder,
      latestWasIncorrect: latestWasIncorrect,
      latestErrorType: latestErrorType,
      latestDecisionTimeBucket: latestDecisionTimeBucket,
      slowDecisionCount: slowDecisionCount,
    );
  }
}

int _candidateOrder(
  Act0ConceptFamilyRepairSummaryV1 a,
  Act0ConceptFamilyRepairSummaryV1 b,
) {
  final latestIncorrectCompare = _compareBoolDesc(
    a.latestWasIncorrect,
    b.latestWasIncorrect,
  );
  if (latestIncorrectCompare != 0) {
    return latestIncorrectCompare;
  }
  final repeatedCompare = b.incorrectCount.compareTo(a.incorrectCount);
  if (repeatedCompare != 0) {
    return repeatedCompare;
  }
  final recentMissCompare = b.latestIncorrectOrder.compareTo(
    a.latestIncorrectOrder,
  );
  if (recentMissCompare != 0) {
    return recentMissCompare;
  }
  return a.conceptFamilyId.compareTo(b.conceptFamilyId);
}

int _compareBoolDesc(bool a, bool b) {
  if (a == b) {
    return 0;
  }
  return a ? -1 : 1;
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
