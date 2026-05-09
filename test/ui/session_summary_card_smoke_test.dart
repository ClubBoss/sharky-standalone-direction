import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/ux_feedback_manager.dart';
import 'package:poker_analyzer/services/player_progression_service.dart';
import 'package:poker_analyzer/ui_v2/progression/session_summary_card.dart';

void main() {
  testWidgets(
    'SessionSummaryCardHost shows, fills progress, and auto-dismisses',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SessionSummaryCardHost(
              child: SizedBox(width: 400, height: 300),
            ),
          ),
        ),
      );

      // Prepare XP to ~50% toward next level
      PlayerProgressionService.instance.reset();
      PlayerProgressionService.instance.applyReward(xp: 500, chips: 0);

      // Trigger via UxFeedbackManager
      UxFeedbackManager.instance.showSummary(
        xpDelta: 250,
        chipsDelta: 1000,
        newLevel: 3,
        streakDelta: 2,
        leagueTier: 'Silver',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Card content should be visible
      expect(find.text('Session Summary'), findsOneWidget);
      expect(find.textContaining('Level'), findsOneWidget);
      expect(find.textContaining('XP'), findsOneWidget);

      // Let animations play (800ms card + 700ms progress)
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump(const Duration(milliseconds: 800));

      // Assert progress fill ~0.5
      final fill = tester.widget<FractionallySizedBox>(
        find.byKey(const Key('league_progress_fill')),
      );
      final widthFactor = fill.widthFactor ?? 0.0;
      expect((widthFactor - 0.5).abs() < 0.05, isTrue);
      expect(find.byKey(const Key('league_progress_label')), findsOneWidget);

      // After >3 seconds, auto-dismiss
      await tester.pump(const Duration(milliseconds: 3100));
      expect(find.text('Session Summary'), findsNothing);
    },
  );
}
