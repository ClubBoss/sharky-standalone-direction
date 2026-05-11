import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';

void main() {
  Future<void> _pumpUntilSettled(
    WidgetTester tester, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 120,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (find
              .byKey(const Key('session_drill_player_load_error'))
              .evaluate()
              .isNotEmpty ||
          find.byType(ModernTableScreenV1).evaluate().isNotEmpty) {
        return;
      }
    }
  }

  testWidgets(
    'common runner fences contradictory empty-blind truth before table render',
    (tester) async {
      final drills = <SessionDrillItemV1>[
        const SessionDrillItemV1(
          drillId: 'invalid_projection_truth_v1',
          spec: DrillSpecV1(
            id: 'invalid_projection_truth_v1',
            kind: DrillKindV1.positionThinkingChoice,
            prompt: 'Who acts here?',
            expected: DrillExpectedV1(actionId: 'hero'),
            errorClass: 'position_thinking_choice_mismatch',
            streetV1: 'flop',
            availableActionsV1: <String>['hero', 'villain'],
            playerCountV1: 4,
            heroSeatV1: 'btn',
            villainSeatV1: 'bb',
            activeSeatsV1: <String>['btn', 'bb'],
            foldedSeatsV1: <String>['co'],
            emptySeatsV1: <String>['sb'],
            smallBlindSeatV1: 'sb',
            bigBlindSeatV1: 'bb',
            smallBlindAmountV1: 50,
            bigBlindAmountV1: 100,
            feedbackCorrectV1: 'Correct.',
            feedbackIncorrectV1: 'Incorrect.',
          ),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s02',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilSettled(tester);

      final exception = tester.takeException();
      expect(exception, isA<StateError>());
      expect(
        exception.toString(),
        contains('small blind seat to be non-empty'),
      );
      expect(find.byType(ModernTableScreenV1), findsNothing);
    },
  );
}
