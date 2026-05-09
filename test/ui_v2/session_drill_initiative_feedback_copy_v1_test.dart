import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_initiative_feedback_copy_v1.dart';

void main() {
  group('buildInitiativeIncorrectFeedbackV1', () {
    test('builds expected chosen why and fix for initiative owner misses', () {
      final feedback = buildInitiativeIncorrectFeedbackV1(
        expectedActionId: 'hero',
        chosenActionId: 'villain',
        prompt: 'Hero raised and villain called. Who has initiative?',
        whyText: 'The raiser keeps initiative.',
        lastAggressor: 'hero',
        initiativeOwner: 'hero',
      );

      expect(
        feedback,
        'Better answer: HERO. VILLAIN misses this scene. '
        'Notice: The raiser keeps initiative. '
        'Next time: Start from the last raise, then carry initiative forward to HERO before you choose.',
      );
    });

    test('falls back to aggressor-aware why when authored why is absent', () {
      final feedback = buildInitiativeIncorrectFeedbackV1(
        expectedActionId: 'villain',
        chosenActionId: 'hero',
        prompt: 'Villain raised and hero called. Who was the last aggressor?',
        whyText: null,
        lastAggressor: 'villain',
        initiativeOwner: 'villain',
      );

      expect(
        feedback,
        'Better answer: VILLAIN. HERO misses this scene. '
        'Notice: VILLAIN made the last raise, so VILLAIN is still the aggressor in this spot. '
        'Next time: Track who made the last raise, then label VILLAIN as the aggressor before you answer.',
      );
    });
  });
}
