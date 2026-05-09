import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_board_texture_feedback_copy_v1.dart';

void main() {
  group('buildBoardTextureIncorrectFeedbackV1', () {
    test('builds expected chosen why and fix for dry board misses', () {
      final feedback = buildBoardTextureIncorrectFeedbackV1(
        expectedActionId: 'call',
        chosenActionId: 'raise',
        boardTexture: 'dry',
        whyText: 'Dry rainbow boards build less immediate draw pressure.',
      );

      expect(
        feedback,
        'Better line: CALL. RAISE is weaker here. '
        'Notice: Dry rainbow boards build less immediate draw pressure. '
        'Next time: On calmer textures, prefer the controlled call instead of forcing extra chips in.',
      );
    });

    test('falls back to texture-aware why and fix when authored why is absent', () {
      final feedback = buildBoardTextureIncorrectFeedbackV1(
        expectedActionId: 'raise',
        chosenActionId: 'call',
        boardTexture: 'connected',
        whyText: null,
      );

      expect(
        feedback,
        'Better line: RAISE. CALL is weaker here. '
        'Notice: This board creates more draw pressure and asks for the stronger pressure response. '
        'Next time: Start from the draw-heavy texture, then choose the aggressive raise line.',
      );
    });
  });
}
