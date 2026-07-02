enum Act0SharkyCoachTierV1 { foundation, developing }

enum Act0SharkyCoachSurfaceV1 {
  welcome,
  feedback,
  summary,
  home,
  review,
  profile,
  play,
  completion,
}

enum Act0SharkyCoachMomentTypeV1 {
  welcome,
  decisionCorrect,
  decisionIncorrect,
  repairPrompt,
  repairFailed,
  repairCompleted,
  laterImprovementObserved,
  sessionComplete,
  worldComplete,
  bandTransition,
  returnReason,
  reviewPattern,
}

enum Act0SharkyCoachEvidenceKindV1 {
  none,
  directObservation,
  repairTarget,
  repairOutcome,
  transferEvidence,
  multiSessionPattern,
  proof,
  completion,
}

enum Act0SharkyCoachRepairStateV1 { none, open, failed, completed }

enum Act0SharkyCoachTransferStateV1 { none, laterCorrect }

enum Act0SharkyCoachProofStateV1 { none, localProof, multiSessionPattern }

enum Act0SharkyCoachCompletionStateV1 { none, worldCompleted, bandTransition }

enum Act0SharkyCoachClaimBoundaryV1 {
  neutral,
  directObservation,
  repair,
  conservativeTransfer,
  patternObservation,
  progression,
}

enum Act0SharkyCoachPhraseFamilyV1 {
  orient,
  explain,
  repair,
  confirm,
  reinforce,
  reflect,
  transition,
}

enum Act0SharkyCoachMomentV1 {
  homeActiveRepair,
  practiceCurrentFix,
  reviewActiveRepair,
  repairResultProof,
  sessionSummaryProof,
  worldOneCompletionPayoff,
  worldCompletionPayoff,
  bandTransitionPayoff,
}

class Act0SharkyCoachPhraseContextV1 {
  const Act0SharkyCoachPhraseContextV1({
    required this.surface,
    required this.momentType,
    this.tier,
    this.evidenceKind = Act0SharkyCoachEvidenceKindV1.none,
    this.conceptFamilyId,
    this.repairState = Act0SharkyCoachRepairStateV1.none,
    this.transferState = Act0SharkyCoachTransferStateV1.none,
    this.proofState = Act0SharkyCoachProofStateV1.none,
    this.completionState = Act0SharkyCoachCompletionStateV1.none,
    this.claimBoundary = Act0SharkyCoachClaimBoundaryV1.neutral,
    this.fallbackKey = 'neutral_fallback',
    this.worldNumber,
    this.nextWorldNumber,
  });

  final Act0SharkyCoachSurfaceV1 surface;
  final Act0SharkyCoachMomentTypeV1 momentType;
  final Act0SharkyCoachTierV1? tier;
  final Act0SharkyCoachEvidenceKindV1 evidenceKind;
  final String? conceptFamilyId;
  final Act0SharkyCoachRepairStateV1 repairState;
  final Act0SharkyCoachTransferStateV1 transferState;
  final Act0SharkyCoachProofStateV1 proofState;
  final Act0SharkyCoachCompletionStateV1 completionState;
  final Act0SharkyCoachClaimBoundaryV1 claimBoundary;
  final String fallbackKey;
  final int? worldNumber;
  final int? nextWorldNumber;
}

class Act0SharkyCoachPhraseV1 {
  const Act0SharkyCoachPhraseV1({
    required this.line,
    required this.family,
    required this.tier,
    required this.claimBoundary,
    required this.fallbackKey,
  });

  static const neutralFallbackLine = 'Stay with the next clear step.';

  final String line;
  final Act0SharkyCoachPhraseFamilyV1 family;
  final Act0SharkyCoachTierV1 tier;
  final Act0SharkyCoachClaimBoundaryV1 claimBoundary;
  final String fallbackKey;

  @override
  bool operator ==(Object other) {
    return other is Act0SharkyCoachPhraseV1 &&
        other.line == line &&
        other.family == family &&
        other.tier == tier &&
        other.claimBoundary == claimBoundary &&
        other.fallbackKey == fallbackKey;
  }

  @override
  int get hashCode =>
      Object.hash(line, family, tier, claimBoundary, fallbackKey);
}

Act0SharkyCoachTierV1 act0SharkyCoachTierForWorldNumberV1(int worldNumber) {
  if (worldNumber >= 5) {
    return Act0SharkyCoachTierV1.developing;
  }
  return Act0SharkyCoachTierV1.foundation;
}

Act0SharkyCoachPhraseV1 act0ResolveSharkyCoachPhraseV1(
  Act0SharkyCoachPhraseContextV1 context,
) {
  final tier = context.tier ?? Act0SharkyCoachTierV1.foundation;
  final resolved = _act0ResolveSharkyCoachPhraseLineV1(context, tier);
  if (resolved != null) {
    return resolved;
  }
  return Act0SharkyCoachPhraseV1(
    line: Act0SharkyCoachPhraseV1.neutralFallbackLine,
    family: Act0SharkyCoachPhraseFamilyV1.orient,
    tier: tier,
    claimBoundary: Act0SharkyCoachClaimBoundaryV1.neutral,
    fallbackKey: context.fallbackKey,
  );
}

String act0SharkyCoachLineForMomentV1(
  Act0SharkyCoachMomentV1 moment, {
  Act0SharkyCoachTierV1 tier = Act0SharkyCoachTierV1.foundation,
}) {
  return act0ResolveSharkyCoachPhraseV1(
    _act0LegacyMomentContextV1(moment, tier),
  ).line;
}

Act0SharkyCoachPhraseV1? _act0ResolveSharkyCoachPhraseLineV1(
  Act0SharkyCoachPhraseContextV1 context,
  Act0SharkyCoachTierV1 tier,
) {
  switch (context.momentType) {
    case Act0SharkyCoachMomentTypeV1.welcome:
      if (context.evidenceKind != Act0SharkyCoachEvidenceKindV1.none) {
        return null;
      }
      return _act0PhraseV1(
        line: tier == Act0SharkyCoachTierV1.foundation
            ? 'Start with one clear table clue.'
            : 'Start with the signal that shapes the decision.',
        family: Act0SharkyCoachPhraseFamilyV1.orient,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.neutral,
      );
    case Act0SharkyCoachMomentTypeV1.decisionCorrect:
      if (context.evidenceKind !=
          Act0SharkyCoachEvidenceKindV1.directObservation) {
        return null;
      }
      return _act0PhraseV1(
        line: tier == Act0SharkyCoachTierV1.foundation
            ? 'Good read. You used the table clue.'
            : 'Good. The signal and action lined up.',
        family: Act0SharkyCoachPhraseFamilyV1.confirm,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.directObservation,
      );
    case Act0SharkyCoachMomentTypeV1.decisionIncorrect:
      if (context.evidenceKind !=
          Act0SharkyCoachEvidenceKindV1.directObservation) {
        return null;
      }
      return _act0PhraseV1(
        line: tier == Act0SharkyCoachTierV1.foundation
            ? 'You missed the no-bet-yet clue.'
            : 'The early action signal got skipped.',
        family: Act0SharkyCoachPhraseFamilyV1.explain,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.directObservation,
      );
    case Act0SharkyCoachMomentTypeV1.repairPrompt:
      if (context.evidenceKind != Act0SharkyCoachEvidenceKindV1.repairTarget ||
          context.repairState != Act0SharkyCoachRepairStateV1.open) {
        return null;
      }
      return _act0PhraseV1(
        line: _act0RepairPromptLineV1(context.surface, tier),
        family: Act0SharkyCoachPhraseFamilyV1.repair,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.repair,
      );
    case Act0SharkyCoachMomentTypeV1.repairFailed:
      if (context.evidenceKind != Act0SharkyCoachEvidenceKindV1.repairOutcome ||
          context.repairState != Act0SharkyCoachRepairStateV1.failed) {
        return null;
      }
      return _act0PhraseV1(
        line: tier == Act0SharkyCoachTierV1.foundation
            ? 'Try the repair again with one clue first.'
            : 'Run it again and isolate the missed signal.',
        family: Act0SharkyCoachPhraseFamilyV1.repair,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.repair,
      );
    case Act0SharkyCoachMomentTypeV1.repairCompleted:
      if (context.evidenceKind != Act0SharkyCoachEvidenceKindV1.repairOutcome ||
          context.repairState != Act0SharkyCoachRepairStateV1.completed) {
        return null;
      }
      return _act0PhraseV1(
        line: tier == Act0SharkyCoachTierV1.foundation
            ? 'That repair landed.'
            : 'Clean proof. Keep the pattern ready.',
        family: Act0SharkyCoachPhraseFamilyV1.reinforce,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.repair,
      );
    case Act0SharkyCoachMomentTypeV1.laterImprovementObserved:
      if (context.evidenceKind !=
              Act0SharkyCoachEvidenceKindV1.transferEvidence ||
          context.transferState !=
              Act0SharkyCoachTransferStateV1.laterCorrect) {
        return null;
      }
      return _act0PhraseV1(
        line: tier == Act0SharkyCoachTierV1.foundation
            ? 'You handled this clue correctly on a later hand.'
            : 'Later hand, cleaner signal-to-action link.',
        family: Act0SharkyCoachPhraseFamilyV1.reflect,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.conservativeTransfer,
      );
    case Act0SharkyCoachMomentTypeV1.sessionComplete:
      if (context.evidenceKind != Act0SharkyCoachEvidenceKindV1.proof ||
          context.proofState != Act0SharkyCoachProofStateV1.localProof) {
        return null;
      }
      return _act0PhraseV1(
        line: tier == Act0SharkyCoachTierV1.foundation
            ? 'Small win, real proof.'
            : 'Clean proof. Keep the pattern ready.',
        family: Act0SharkyCoachPhraseFamilyV1.reinforce,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.repair,
      );
    case Act0SharkyCoachMomentTypeV1.worldComplete:
      if (context.evidenceKind != Act0SharkyCoachEvidenceKindV1.completion ||
          context.completionState !=
              Act0SharkyCoachCompletionStateV1.worldCompleted) {
        return null;
      }
      return _act0PhraseV1(
        line: tier == Act0SharkyCoachTierV1.foundation
            ? "You banked this world's core read."
            : "This world's read is ready for the next pattern.",
        family: Act0SharkyCoachPhraseFamilyV1.transition,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.progression,
      );
    case Act0SharkyCoachMomentTypeV1.bandTransition:
      if (context.evidenceKind != Act0SharkyCoachEvidenceKindV1.completion ||
          context.completionState !=
              Act0SharkyCoachCompletionStateV1.bandTransition ||
          context.worldNumber != 4 ||
          context.nextWorldNumber != 5) {
        return null;
      }
      return _act0PhraseV1(
        line: 'Foundation complete.',
        family: Act0SharkyCoachPhraseFamilyV1.transition,
        tier: Act0SharkyCoachTierV1.foundation,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.progression,
      );
    case Act0SharkyCoachMomentTypeV1.returnReason:
      if (context.evidenceKind != Act0SharkyCoachEvidenceKindV1.repairTarget ||
          context.repairState != Act0SharkyCoachRepairStateV1.open) {
        return null;
      }
      return _act0PhraseV1(
        line: tier == Act0SharkyCoachTierV1.foundation
            ? 'This is the next useful hand.'
            : 'Return here while the pattern is still live.',
        family: Act0SharkyCoachPhraseFamilyV1.orient,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.repair,
      );
    case Act0SharkyCoachMomentTypeV1.reviewPattern:
      if (context.evidenceKind !=
              Act0SharkyCoachEvidenceKindV1.multiSessionPattern ||
          context.proofState !=
              Act0SharkyCoachProofStateV1.multiSessionPattern) {
        return null;
      }
      return _act0PhraseV1(
        line: tier == Act0SharkyCoachTierV1.foundation
            ? 'This same miss showed up in more than one session.'
            : 'The same pattern repeated across sessions.',
        family: Act0SharkyCoachPhraseFamilyV1.reflect,
        tier: tier,
        claimBoundary: Act0SharkyCoachClaimBoundaryV1.patternObservation,
      );
  }
}

Act0SharkyCoachPhraseContextV1 _act0LegacyMomentContextV1(
  Act0SharkyCoachMomentV1 moment,
  Act0SharkyCoachTierV1 tier,
) {
  switch (moment) {
    case Act0SharkyCoachMomentV1.homeActiveRepair:
      return Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.home,
        momentType: Act0SharkyCoachMomentTypeV1.returnReason,
        tier: tier,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairTarget,
        repairState: Act0SharkyCoachRepairStateV1.open,
      );
    case Act0SharkyCoachMomentV1.practiceCurrentFix:
      return Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.play,
        momentType: Act0SharkyCoachMomentTypeV1.repairPrompt,
        tier: tier,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairTarget,
        repairState: Act0SharkyCoachRepairStateV1.open,
      );
    case Act0SharkyCoachMomentV1.reviewActiveRepair:
      return Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.review,
        momentType: Act0SharkyCoachMomentTypeV1.repairPrompt,
        tier: tier,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairTarget,
        repairState: Act0SharkyCoachRepairStateV1.open,
      );
    case Act0SharkyCoachMomentV1.repairResultProof:
      return Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.feedback,
        momentType: Act0SharkyCoachMomentTypeV1.repairCompleted,
        tier: tier,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.repairOutcome,
        repairState: Act0SharkyCoachRepairStateV1.completed,
      );
    case Act0SharkyCoachMomentV1.sessionSummaryProof:
      return Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.summary,
        momentType: Act0SharkyCoachMomentTypeV1.sessionComplete,
        tier: tier,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.proof,
        proofState: Act0SharkyCoachProofStateV1.localProof,
      );
    case Act0SharkyCoachMomentV1.worldOneCompletionPayoff:
      return Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.worldComplete,
        tier: Act0SharkyCoachTierV1.foundation,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.worldCompleted,
      );
    case Act0SharkyCoachMomentV1.worldCompletionPayoff:
      return Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.worldComplete,
        tier: tier,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.worldCompleted,
      );
    case Act0SharkyCoachMomentV1.bandTransitionPayoff:
      return const Act0SharkyCoachPhraseContextV1(
        surface: Act0SharkyCoachSurfaceV1.completion,
        momentType: Act0SharkyCoachMomentTypeV1.bandTransition,
        tier: Act0SharkyCoachTierV1.foundation,
        evidenceKind: Act0SharkyCoachEvidenceKindV1.completion,
        completionState: Act0SharkyCoachCompletionStateV1.bandTransition,
        worldNumber: 4,
        nextWorldNumber: 5,
      );
  }
}

Act0SharkyCoachPhraseV1 _act0PhraseV1({
  required String line,
  required Act0SharkyCoachPhraseFamilyV1 family,
  required Act0SharkyCoachTierV1 tier,
  required Act0SharkyCoachClaimBoundaryV1 claimBoundary,
}) {
  return Act0SharkyCoachPhraseV1(
    line: line,
    family: family,
    tier: tier,
    claimBoundary: claimBoundary,
    fallbackKey: '',
  );
}

String _act0RepairPromptLineV1(
  Act0SharkyCoachSurfaceV1 surface,
  Act0SharkyCoachTierV1 tier,
) {
  if (surface == Act0SharkyCoachSurfaceV1.review) {
    return tier == Act0SharkyCoachTierV1.foundation
        ? 'Keep this read warm with one quick rep.'
        : 'Review the signal before the next decision.';
  }
  return tier == Act0SharkyCoachTierV1.foundation
      ? 'Run one quick rep while the clue is fresh.'
      : 'Repeat the key signal before adding pressure.';
}
