import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/ai_coach/ai_coach_engine.dart';
import 'package:poker_analyzer/ui_v2/ai_coach/ai_coach_overlay.dart';

void main() {
  testWidgets('AI Coach overlay shows feedback and auto-dismisses', (
    tester,
  ) async {
    final engine = AiCoachEngine(enabled: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.black)),
              // Inject the overlay with the engine's feedback stream
              AiCoachOverlay(
                feedbackStream: engine.feedbackStream,
                visible: true,
              ),
            ],
          ),
        ),
      ),
    );

    // Trigger a feedback by evaluating an action
    engine.evaluateAction(
      userAction: 'call',
      street: 'flop',
      pot: 100,
      heroStack: 800,
      currentBet: 50,
      numActivePlayers: 2,
      heroPosition: 0,
    );

    // Let the overlay animate in (300ms) + a small buffer
    await tester.pump(const Duration(milliseconds: 350));

    // Expect some EV text to be present (from the overlay badge)
    // Overlay can render EV both in the headline and in the badge
    expect(find.textContaining('EV'), findsWidgets);

    // Wait for auto-hide (4s) + buffer, and animations to settle
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 400));

    // Overlay should be hidden
    expect(find.textContaining('EV'), findsNothing);
  });

  testWidgets('AI Coach overlay handles multiple rapid feedback events', (
    tester,
  ) async {
    final engine = AiCoachEngine(enabled: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.black)),
              AiCoachOverlay(
                feedbackStream: engine.feedbackStream,
                visible: true,
              ),
            ],
          ),
        ),
      ),
    );

    // Emit several feedbacks quickly
    final actions = ['bet', 'check', 'raise', 'fold'];
    for (final a in actions) {
      engine.evaluateAction(
        userAction: a,
        street: 'turn',
        pot: 120,
        heroStack: 600,
        currentBet: 40,
        numActivePlayers: 2,
        heroPosition: 1,
      );
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Allow last animation to process
    await tester.pump(const Duration(milliseconds: 350));

    // After hide duration for the last feedback, it should disappear
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.textContaining('EV'), findsNothing);
  });
}
