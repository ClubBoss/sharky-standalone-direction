import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_canonical_progression_bridge_v1.dart';

void main() {
  test('legacy drill progression bridge reveals, locks quiz state, and advances', () {
    const initial = LegacyDrillCanonicalProgressionStateV1.initial();

    final revealed = LegacyDrillCanonicalProgressionBridgeV1.revealAnswer(
      initial,
    );
    expect(revealed.isAnswerRevealed, isTrue);
    expect(revealed.currentIndex, 0);

    final selected = LegacyDrillCanonicalProgressionBridgeV1.resolveQuizSelection(
      revealed,
      isCorrect: true,
      selectedIndex: 1,
      correctIndex: 1,
    );
    expect(selected.quizLocked, isTrue);
    expect(selected.selectedQuizIndex, 1);
    expect(selected.correctQuizIndex, 1);
    expect(selected.selectedQuizCorrect, isTrue);

    final unchangedWhenLocked =
        LegacyDrillCanonicalProgressionBridgeV1.resolveQuizSelection(
          selected,
          isCorrect: false,
          selectedIndex: 0,
          correctIndex: 1,
        );
    expect(unchangedWhenLocked.selectedQuizIndex, 1);
    expect(unchangedWhenLocked.selectedQuizCorrect, isTrue);

    final advanced = LegacyDrillCanonicalProgressionBridgeV1.advance(
      selected,
      itemCount: 3,
      countedAsCorrect: true,
    );
    expect(advanced.completesRun, isFalse);
    expect(advanced.finalCorrectCount, 1);
    expect(advanced.nextState.currentIndex, 1);
    expect(advanced.nextState.correctAnswers, 1);
    expect(advanced.nextState.isAnswerRevealed, isFalse);
    expect(advanced.nextState.quizLocked, isFalse);
    expect(advanced.nextState.selectedQuizIndex, isNull);
  });

  test('legacy drill progression bridge marks final advancement as completion', () {
    const state = LegacyDrillCanonicalProgressionStateV1(
      currentIndex: 1,
      isAnswerRevealed: true,
      correctAnswers: 1,
      selectedQuizIndex: null,
      correctQuizIndex: null,
      selectedQuizCorrect: null,
      quizLocked: false,
    );

    final result = LegacyDrillCanonicalProgressionBridgeV1.advance(
      state,
      itemCount: 2,
      countedAsCorrect: false,
    );
    expect(result.completesRun, isTrue);
    expect(result.finalCorrectCount, 1);
    expect(result.nextState.currentIndex, 1);
  });
}
