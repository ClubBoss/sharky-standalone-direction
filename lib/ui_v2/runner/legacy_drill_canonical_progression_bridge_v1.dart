class LegacyDrillCanonicalProgressionStateV1 {
  const LegacyDrillCanonicalProgressionStateV1({
    required this.currentIndex,
    required this.isAnswerRevealed,
    required this.correctAnswers,
    required this.selectedQuizIndex,
    required this.correctQuizIndex,
    required this.selectedQuizCorrect,
    required this.quizLocked,
  });

  const LegacyDrillCanonicalProgressionStateV1.initial()
    : currentIndex = 0,
      isAnswerRevealed = false,
      correctAnswers = 0,
      selectedQuizIndex = null,
      correctQuizIndex = null,
      selectedQuizCorrect = null,
      quizLocked = false;

  final int currentIndex;
  final bool isAnswerRevealed;
  final int correctAnswers;
  final int? selectedQuizIndex;
  final int? correctQuizIndex;
  final bool? selectedQuizCorrect;
  final bool quizLocked;

  LegacyDrillCanonicalProgressionStateV1 copyWith({
    int? currentIndex,
    bool? isAnswerRevealed,
    int? correctAnswers,
    int? selectedQuizIndex,
    int? correctQuizIndex,
    bool? selectedQuizCorrect,
    bool? quizLocked,
    bool clearsQuizSelection = false,
  }) {
    return LegacyDrillCanonicalProgressionStateV1(
      currentIndex: currentIndex ?? this.currentIndex,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      selectedQuizIndex: clearsQuizSelection
          ? null
          : (selectedQuizIndex ?? this.selectedQuizIndex),
      correctQuizIndex: clearsQuizSelection
          ? null
          : (correctQuizIndex ?? this.correctQuizIndex),
      selectedQuizCorrect: clearsQuizSelection
          ? null
          : (selectedQuizCorrect ?? this.selectedQuizCorrect),
      quizLocked: quizLocked ?? this.quizLocked,
    );
  }
}

class LegacyDrillCanonicalAdvanceResultV1 {
  const LegacyDrillCanonicalAdvanceResultV1({
    required this.nextState,
    required this.completesRun,
    required this.finalCorrectCount,
  });

  final LegacyDrillCanonicalProgressionStateV1 nextState;
  final bool completesRun;
  final int finalCorrectCount;
}

class LegacyDrillCanonicalProgressionBridgeV1 {
  const LegacyDrillCanonicalProgressionBridgeV1._();

  static LegacyDrillCanonicalProgressionStateV1 revealAnswer(
    LegacyDrillCanonicalProgressionStateV1 state,
  ) {
    return state.copyWith(isAnswerRevealed: true);
  }

  static LegacyDrillCanonicalProgressionStateV1 resolveQuizSelection(
    LegacyDrillCanonicalProgressionStateV1 state, {
    required bool isCorrect,
    required int selectedIndex,
    required int correctIndex,
  }) {
    if (state.quizLocked) {
      return state;
    }
    return state.copyWith(
      selectedQuizIndex: selectedIndex,
      correctQuizIndex: correctIndex,
      selectedQuizCorrect: isCorrect,
      quizLocked: true,
    );
  }

  static LegacyDrillCanonicalAdvanceResultV1 advance(
    LegacyDrillCanonicalProgressionStateV1 state, {
    required int itemCount,
    required bool countedAsCorrect,
  }) {
    final finalCorrectCount = state.correctAnswers + (countedAsCorrect ? 1 : 0);
    final nextIndex = state.currentIndex + 1;
    final completesRun = nextIndex >= itemCount;
    return LegacyDrillCanonicalAdvanceResultV1(
      nextState: state.copyWith(
        currentIndex: completesRun ? state.currentIndex : nextIndex,
        correctAnswers: finalCorrectCount,
        isAnswerRevealed: false,
        quizLocked: false,
        clearsQuizSelection: true,
      ),
      completesRun: completesRun,
      finalCorrectCount: finalCorrectCount,
    );
  }
}
