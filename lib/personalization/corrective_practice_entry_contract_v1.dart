import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';

class CorrectivePracticeEntryContractV1 {
  const CorrectivePracticeEntryContractV1({
    required this.title,
    required this.weaknessLine,
    required this.goalLine,
    required this.practiceRuleLine,
  });

  final String title;
  final String weaknessLine;
  final String goalLine;
  final String practiceRuleLine;
}

class CorrectivePracticeEntryContractFactoryV1 {
  CorrectivePracticeEntryContractFactoryV1._();

  static CorrectivePracticeEntryContractV1? forWorld2PositionFamily({
    required ProgressionHandoffContextV1? handoffContextV1,
  }) {
    final handoff = handoffContextV1;
    if (handoff == null) return null;
    final weaknessLabel = handoff.continuationWeaknessLabel?.trim() ?? '';
    final reviewGoal = handoff.continuationReviewGoal?.trim() ?? '';
    if (weaknessLabel.isEmpty || reviewGoal.isEmpty) return null;
    return CorrectivePracticeEntryContractV1(
      title: 'Position Review',
      weaknessLine: 'Weak pattern: $weaknessLabel',
      goalLine: 'Goal: $reviewGoal',
      practiceRuleLine:
          'Practice rule: Find who acts later after the flop, then anchor the in-position player before you choose.',
    );
  }

  static CorrectivePracticeEntryContractV1? forWorld2InitiativeFamily({
    required ProgressionHandoffContextV1? handoffContextV1,
  }) {
    final handoff = handoffContextV1;
    if (handoff == null) return null;
    final weaknessLabel = handoff.continuationWeaknessLabel?.trim() ?? '';
    final reviewGoal = handoff.continuationReviewGoal?.trim() ?? '';
    if (weaknessLabel.isEmpty || reviewGoal.isEmpty) return null;
    return CorrectivePracticeEntryContractV1(
      title: 'Initiative Review',
      weaknessLine: 'Weak pattern: $weaknessLabel',
      goalLine: 'Goal: $reviewGoal',
      practiceRuleLine:
          'Practice rule: Find the last aggressor first, then carry initiative forward to that player.',
    );
  }

  static CorrectivePracticeEntryContractV1? forWorld2BoardTextureFamily({
    required ProgressionHandoffContextV1? handoffContextV1,
  }) {
    final handoff = handoffContextV1;
    if (handoff == null) return null;
    final weaknessLabel = handoff.continuationWeaknessLabel?.trim() ?? '';
    final reviewGoal = handoff.continuationReviewGoal?.trim() ?? '';
    if (weaknessLabel.isEmpty || reviewGoal.isEmpty) return null;
    return CorrectivePracticeEntryContractV1(
      title: 'Board Texture Review',
      weaknessLine: 'Weak pattern: $weaknessLabel',
      goalLine: 'Goal: $reviewGoal',
      practiceRuleLine:
          'Practice rule: Classify board pressure first, then choose the calmer or pressure-building label.',
    );
  }

  static CorrectivePracticeEntryContractV1? forActionOrderFamily({
    required ProgressionHandoffContextV1? handoffContextV1,
  }) {
    final handoff = handoffContextV1;
    if (handoff == null) return null;
    final weaknessLabel = handoff.continuationWeaknessLabel?.trim() ?? '';
    final reviewGoal = handoff.continuationReviewGoal?.trim() ?? '';
    if (weaknessLabel.isEmpty || reviewGoal.isEmpty) return null;
    return CorrectivePracticeEntryContractV1(
      title: 'Action Order Review',
      weaknessLine: 'Weak pattern: $weaknessLabel',
      goalLine: 'Goal: $reviewGoal',
      practiceRuleLine:
          'Practice rule: Anchor the button first, then eliminate the earlier seats until only the last actor remains.',
    );
  }
}
