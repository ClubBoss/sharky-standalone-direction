import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('AI Advisor report', () {
    late Directory tempRoot;
    late Directory reportsDir;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('ai_advisor_report_');
      reportsDir = Directory('${tempRoot.path}/tools/_reports')
        ..createSync(recursive: true);
    });

    tearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('merges sources and writes summaries', () async {
      final tunerPath = File('${reportsDir.path}/mini_ai_tuner_summary.json');
      final coachPath = File('${reportsDir.path}/ai_coach_metrics.json');
      final retentionPath = File(
        '${reportsDir.path}/ai_coaching_retention.json',
      );

      tunerPath.writeAsStringSync(
        jsonEncode({
          'metrics': {
            'avg_confidence': {'current': 0.66, 'seven_day': 0.60},
            'avg_ev_diff': {'current': -0.15, 'seven_day': -0.25},
            'correct_ratio': {'current': 0.70, 'seven_day': 0.66},
          },
          'weaknesses': [
            {'tag': 'river_bluff', 'ev_loss': 1.8, 'count': 3},
          ],
        }),
      );

      coachPath.writeAsStringSync(
        jsonEncode({
          'metrics': {
            'confidence': {'current': 0.68, 'seven_day': 0.64},
            'ev_diff': {'current': -0.05, 'seven_day': -0.08},
            'correct_ratio': {'current': 0.74, 'seven_day': 0.70},
          },
          'issue_tags': [
            {'tag': 'river_bluff', 'ev_loss': 2.0, 'count': 4},
            {'tag': 'flop_call', 'ev_loss': 1.5, 'count': 5},
          ],
        }),
      );

      retentionPath.writeAsStringSync(
        jsonEncode({
          'retention_metrics': {
            'retention_score': {'current': 0.82, 'seven_day': 0.78},
          },
        }),
      );

      final result = await Process.run('dart', [
        'run',
        'tools/ai_advisor_report.dart',
        '--export',
        '--root=${tempRoot.path}',
      ]);

      expect(result.exitCode, equals(0), reason: result.stderr.toString());

      final summaryFile = File(
        '${tempRoot.path}/tools/_reports/ai_advisor_summary.json',
      );
      expect(summaryFile.existsSync(), isTrue);

      final releaseFile = File(
        '${tempRoot.path}/release/public_beta_v2/ai_advisor_summary.json',
      );
      expect(releaseFile.existsSync(), isTrue);

      final summary =
          jsonDecode(summaryFile.readAsStringSync()) as Map<String, dynamic>;

      expect(summary['pass'], isTrue);
      expect(summary['feeds_merged'], equals(3));

      final metrics = (summary['metrics'] as Map<String, dynamic>)
          .cast<String, dynamic>();
      final confidence = metrics['avg_confidence'] as Map<String, dynamic>;
      final evDiff = metrics['avg_ev_diff'] as Map<String, dynamic>;
      final correct = metrics['correct_ratio'] as Map<String, dynamic>;
      final retention = metrics['retention_score'] as Map<String, dynamic>;

      expect(confidence['current'], closeTo(0.67, 0.001));
      expect(evDiff['current'], closeTo(-0.1, 0.001));
      expect(correct['current'], closeTo(0.72, 0.001));
      expect(retention['current'], closeTo(0.82, 0.001));

      final trend = (summary['trend_vs_last_7_days'] as Map<String, dynamic>)
          .cast<String, String>();
      expect(trend['avg_confidence'], equals('UP'));
      expect(trend['avg_ev_diff'], equals('UP'));
      expect(trend['retention_score'], equals('UP'));

      final weaknesses = (summary['weakness_tags'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(weaknesses, isNotEmpty);
      expect(weaknesses.first['tag'], equals('river_bluff'));
      expect(weaknesses.first['ev_loss'], closeTo(1.9143, 0.0001));
    });
  });
}
