import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/player_progression_service.dart';
import 'package:poker_analyzer/ui_v2/overlays/level_up_overlay.dart';

void main() {
  testWidgets('LevelUpOverlayHost spawns and auto-disposes overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LevelUpOverlayHost(child: SizedBox(width: 400, height: 300)),
        ),
      ),
    );

    // Trigger level-up by applying sufficient XP
    PlayerProgressionService.instance.reset();
    PlayerProgressionService.instance.applyReward(xp: 1500, chips: 0);

    // Initial pump should start animation (overlay visible)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    // We expect overlay widgets to be present: banner text
    expect(find.text('LEVEL UP!'), findsOneWidget);

    // After 1s, confetti fades out but banner fades in
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text('LEVEL UP!'), findsOneWidget);

    // After total 2.1s, overlay should auto-hide
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('LEVEL UP!'), findsNothing);
  });
}
