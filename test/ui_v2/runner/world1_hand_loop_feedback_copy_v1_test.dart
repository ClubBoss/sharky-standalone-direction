import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_hand_loop_feedback_copy_v1.dart';

void main() {
  group('world1 hand loop feedback copy', () {
    test('builds factual expected/chosen correction with why and fix', () {
      final fixLine = resolveWorld1HandLoopMismatchFixLineV1(
        expectedActionKind: ActionKindV1.raise,
        expectedLabel: 'RAISE TO',
        toCallMilliBb: 1000,
      );
      final feedbackLine = buildWorld1HandLoopExpectedChosenFeedbackLineV1(
        expectedLabel: 'RAISE TO',
        chosenLabel: 'CALL',
        factualContextLine: 'Why: Facing the bet, aggression keeps initiative.',
        fixLine: fixLine,
      );

      expect(
        fixLine,
        'Fix: Facing a bet here, raise instead of taking the passive line.',
      );
      expect(
        feedbackLine,
        'Better line: RAISE TO. CALL is weaker here. '
        'Notice: Facing the bet, aggression keeps initiative. '
        'Next time: Facing a bet here, raise instead of taking the passive line.',
      );
    });

    test('uses no-bet fix for check decisions', () {
      final fixLine = resolveWorld1HandLoopMismatchFixLineV1(
        expectedActionKind: ActionKindV1.check,
        expectedLabel: 'CHECK',
      );

      expect(
        fixLine,
        'Fix: No bet is on you, so check instead of putting chips in.',
      );
    });

    test('falls back from expected label when action kind is unavailable', () {
      final fixLine = resolveWorld1HandLoopMismatchFixLineV1(
        expectedActionKind: null,
        expectedLabel: 'CALL',
        toCallMilliBb: 500,
      );

      expect(fixLine, 'Fix: Match the current price before you continue.');
    });
  });
}
