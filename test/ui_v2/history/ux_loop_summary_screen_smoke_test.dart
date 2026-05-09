import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/player_progression_service.dart';
import 'package:poker_analyzer/ui_v2/history/ux_loop_summary_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String rewardCachePath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ux_loop_summary_test_');
    rewardCachePath = '${tempDir.path}/cache.json';
    PlayerProgressionService.instance.reset();
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
    PlayerProgressionService.instance.reset();
  });

  testWidgets('renders summaries and chart from recent rewards', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final now = DateTime.now().toUtc();
      final history = [
        {
          'timestamp': now.toIso8601String(),
          'adjusted_xp': 100,
          'adjusted_chips': 40,
        },
        {
          'timestamp': now.subtract(const Duration(days: 1)).toIso8601String(),
          'adjusted_xp': 80,
          'adjusted_chips': 20,
        },
        {
          'timestamp': now.subtract(const Duration(days: 2)).toIso8601String(),
          'adjusted_xp': 60,
          'adjusted_chips': 10,
        },
        {
          'timestamp': now.subtract(const Duration(days: 7)).toIso8601String(),
          'adjusted_xp': 200,
          'adjusted_chips': 90,
        },
      ];

      final payload = {'history': history, 'last_confidence': 50.0};

      final file = File(rewardCachePath);
      file.createSync(recursive: true);
      file.writeAsStringSync(jsonEncode(payload));

      // Bump streak to a known value.
      PlayerProgressionService.instance.applyReward(xp: 120, chips: 50);
      PlayerProgressionService.instance.applyReward(xp: 130, chips: 60);
      PlayerProgressionService.instance.applyReward(xp: 90, chips: 40);

      await tester.pumpWidget(
        MaterialApp(
          home: UxLoopSummaryScreen(rewardCachePath: rewardCachePath),
        ),
      );
      await tester.pump(); // allow initial future microtasks
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await tester.pump();

      expect(find.text('Avg XP per Session'), findsOneWidget);
      expect(find.text('80.0'), findsOneWidget);
      expect(find.text('Total Chips Earned'), findsOneWidget);
      expect(find.text('70'), findsOneWidget);
      expect(find.text('Active Streak'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('7-Day XP and Chips Trend'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
