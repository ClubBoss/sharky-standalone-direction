import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/history/ux_feedback_history_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String cachePath;
  late String exportPath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ux_feedback_history_test_');
    cachePath = '${tempDir.path}/cache.json';
    exportPath = '${tempDir.path}/export.json';
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('renders latest rewards and exports history', (tester) async {
    await tester.runAsync(() async {
      final file = File(cachePath);
      file.createSync(recursive: true);
      final baseTime = DateTime.utc(2024, 1, 1);

      final history = List.generate(18, (index) {
        final timestamp = baseTime
            .add(Duration(minutes: index))
            .toIso8601String();
        return {
          'timestamp': timestamp,
          'base_xp': index,
          'adjusted_xp': index + 10,
          'base_chips': index * 2,
          'adjusted_chips': index * 2 + 5,
          'multiplier': 1.0 + index * 0.01,
        };
      });

      final payload = {'history': history, 'last_confidence': 55.0};
      file.writeAsStringSync(jsonEncode(payload));

      await tester.pumpWidget(
        MaterialApp(
          home: UxFeedbackHistoryScreen(
            enableSnackBar: false,
            rewardCachePath: cachePath,
            exportPath: exportPath,
          ),
        ),
      );
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      await tester.pump();

      // Only 15 most recent entries should be shown (indices 17 down to 3).
      expect(find.byKey(const ValueKey('history_row_0')), findsOneWidget);
      // Top row is the most recent entry.
      expect(find.text('XP 17 -> 27'), findsOneWidget);
      expect(find.text('Chips 34 -> 39'), findsOneWidget);
      expect(find.text('x1.17'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('history_row_14')),
        200,
      );
      expect(find.byKey(const ValueKey('history_row_14')), findsOneWidget);
      expect(find.byKey(const ValueKey('history_row_15')), findsNothing);

      // Export the visible history.
      await tester.tap(find.byKey(const ValueKey('export_button')));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await tester.pump();

      final exportFile = File(exportPath);
      expect(exportFile.existsSync(), isTrue);

      final decoded =
          jsonDecode(exportFile.readAsStringSync()) as Map<String, dynamic>;
      final exportedHistory = decoded['rewards'] as List<dynamic>;

      expect(decoded['count'], 15);
      expect(exportedHistory.length, 15);
      expect(exportedHistory.first['base_xp'], 17);
      expect(exportedHistory.last['base_xp'], 3);
    });
  });
}
