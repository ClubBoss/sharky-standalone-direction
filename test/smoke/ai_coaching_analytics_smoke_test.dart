import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/ai_coaching_analytics_service.dart';

void main() {
  group('AiCoachingAnalyticsService smoke', () {
    final reportsDir = Directory('tools/_reports');
    final historyPath = 'tools/_reports/ai_coach_history.jsonl';
    final outPath = 'tools/_reports/ai_coaching_retention.json';

    setUp(() async {
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }
      final historyFile = File(historyPath);
      if (await historyFile.exists()) {
        await historyFile.delete();
      }
      final outFile = File(outPath);
      if (await outFile.exists()) {
        await outFile.delete();
      }
    });

    test('computes retention and trends from synthetic history', () async {
      final now = DateTime.now();

      final sink = File(historyPath).openWrite(mode: FileMode.append);

      // Helper to write a session line
      void writeSession({
        required DateTime ts,
        required double correctRatio,
        required double avgConfidence,
        required double avgEvDiff,
        required Map<String, int> actionBreakdown,
        required int hintCount,
      }) {
        final line = jsonEncode({
          'timestamp': ts.toIso8601String(),
          'ai_correct_ratio': correctRatio,
          'avg_confidence': avgConfidence,
          'avg_ev_diff': avgEvDiff,
          'ai_hint_count': hintCount,
          'action_breakdown': actionBreakdown,
        });
        sink.writeln(line);
      }

      // Previous window (8-14 days ago): weaker performance
      for (int d = 8; d <= 14; d++) {
        writeSession(
          ts: now.subtract(Duration(days: d)),
          correctRatio: 0.45,
          avgConfidence: 0.55,
          avgEvDiff: 0.6, // more EV loss
          actionBreakdown: {
            'raise': 20,
            'call': 10,
            'fold': 10,
            'bet': 5,
            'check': 5,
          },
          hintCount: 50,
        );
      }

      // Recent window (last 7 days): better performance
      for (int d = 0; d < 7; d++) {
        writeSession(
          ts: now.subtract(Duration(days: d)),
          correctRatio: 0.65,
          avgConfidence: 0.70,
          avgEvDiff: 0.3, // less EV loss
          actionBreakdown: {
            'raise': 30,
            'call': 10,
            'fold': 10,
            'bet': 8,
            'check': 6,
          },
          hintCount: 64,
        );
      }

      await sink.flush();
      await sink.close();

      // Generate report
      await AiCoachingAnalyticsService.generateRetentionReport();

      // Verify file exists
      final outFile = File(outPath);
      expect(outFile.existsSync(), isTrue);

      // Read JSON
      final jsonMap =
          jsonDecode(await outFile.readAsString()) as Map<String, dynamic>;

      // Basic structure
      expect(jsonMap.containsKey('retention_score_percent'), isTrue);
      expect(jsonMap.containsKey('trend_vs_last_7_days'), isTrue);
      expect(jsonMap.containsKey('trend_vs_last_14_days'), isTrue);
      expect(jsonMap.containsKey('recommendations'), isTrue);

      // Values
      final rs = (jsonMap['retention_score_percent'] as num).toDouble();
      expect(rs, inInclusiveRange(0.0, 100.0));

      final trend7 = (jsonMap['trend_vs_last_7_days'] as num).toDouble();
      expect(trend7, greaterThanOrEqualTo(0.0)); // improved recent window

      final trend14 = (jsonMap['trend_vs_last_14_days'] as num).toDouble();
      expect(trend14, isA<double>());

      final recs = (jsonMap['recommendations'] as List).cast<String>();
      expect(recs.length, greaterThan(0));

      // raise should appear as a focus area given synthetic breakdown
      final joined = recs.join(' ').toLowerCase();
      expect(joined.contains('raise'), isTrue);
    });
  });
}
