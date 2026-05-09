import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_position_feedback_copy_v1.dart';

void main() {
  group('buildPositionIncorrectFeedbackV1', () {
    test('builds expected chosen why and fix for in-position misses', () {
      final feedback = buildPositionIncorrectFeedbackV1(
        expectedActionId: 'hero',
        chosenActionId: 'villain',
        prompt:
            'Hero is on the button versus the big blind. Who is in position?',
        whyText: 'The button acts later after the flop.',
        heroSeat: 'btn',
        villainSeat: 'bb',
      );

      expect(
        feedback,
        'Better answer: HERO. VILLAIN misses this scene. '
        'Notice: The button acts later after the flop. '
        'Next time: Compare the live seats after the flop, then mark HERO because BTN acts later.',
      );
    });

    test('falls back to question-aware why when authored why is absent', () {
      final feedback = buildPositionIncorrectFeedbackV1(
        expectedActionId: 'villain',
        chosenActionId: 'hero',
        prompt:
            'Hero is in the cutoff and villain is on the button. Who acts later?',
        whyText: null,
        heroSeat: 'co',
        villainSeat: 'btn',
      );

      expect(
        feedback,
        'Better answer: VILLAIN. HERO misses this scene. '
        'Notice: VILLAIN acts later here because BTN comes after the other live seat postflop. '
        'Next time: Read the postflop order first, then pick VILLAIN because BTN acts later.',
      );
    });
  });
}
