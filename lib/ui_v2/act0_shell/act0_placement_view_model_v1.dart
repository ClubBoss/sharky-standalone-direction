enum Act0PlacementActionV1 { start, startFromZero, diagnostic, next }

/// Presentation state for the placement question flow and its primary action.
class Act0PlacementViewModelV1 {
  Act0PlacementViewModelV1({
    required this.showIntro,
    required String? questionId,
    required Set<String> selections,
    required int minSelections,
  }) : explicitBeginnerStart =
           questionId == 'experience' && selections.contains('new'),
       awaitingDiagnostic = questionId == null,
       allowNext =
           questionId != null &&
           selections.length >= (minSelections <= 0 ? 1 : minSelections);

  final bool explicitBeginnerStart;
  final bool awaitingDiagnostic;
  final bool allowNext;
  final bool showIntro;

  Act0PlacementActionV1? get primaryAction {
    if (showIntro) return Act0PlacementActionV1.start;
    if (explicitBeginnerStart) return Act0PlacementActionV1.startFromZero;
    if (awaitingDiagnostic) return Act0PlacementActionV1.diagnostic;
    return allowNext ? Act0PlacementActionV1.next : null;
  }
}
