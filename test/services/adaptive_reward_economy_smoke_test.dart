import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/adaptive_reward_economy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveRewardEconomy', () {
    late File difficultyCache;
    late File telemetryFile;
    late File rewardCache;
    String? difficultyBackup;
    String? telemetryBackup;
    String? rewardBackup;

    setUp(() {
      difficultyCache = File('tools/_reports/.adaptive_difficulty_cache.json');
      telemetryFile = File('tools/_reports/unified_telemetry_summary.json');
      rewardCache = File('tools/_reports/adaptive_reward_cache.json');

      difficultyBackup = difficultyCache.existsSync()
          ? difficultyCache.readAsStringSync()
          : null;
      telemetryBackup = telemetryFile.existsSync()
          ? telemetryFile.readAsStringSync()
          : null;
      rewardBackup = rewardCache.existsSync()
          ? rewardCache.readAsStringSync()
          : null;

      difficultyCache.parent.createSync(recursive: true);
      telemetryFile.parent.createSync(recursive: true);

      difficultyCache.writeAsStringSync(
        jsonEncode({
          'history': [0.62, 0.66, 0.68],
          'average': 0.6533,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }),
      );

      if (rewardCache.existsSync()) {
        rewardCache.deleteSync();
      }
    });

    tearDown(() {
      if (difficultyBackup != null) {
        difficultyCache.writeAsStringSync(difficultyBackup!);
      } else if (difficultyCache.existsSync()) {
        difficultyCache.deleteSync();
      }

      if (telemetryBackup != null) {
        telemetryFile.writeAsStringSync(telemetryBackup!);
      } else if (telemetryFile.existsSync()) {
        telemetryFile.deleteSync();
      }

      if (rewardBackup != null) {
        rewardCache
          ..createSync(recursive: true)
          ..writeAsStringSync(rewardBackup!);
      } else if (rewardCache.existsSync()) {
        rewardCache.deleteSync();
      }
    });

    test('scales rewards within range and writes cache', () {
      telemetryFile.writeAsStringSync(
        jsonEncode({
          'derived_metrics': <String, dynamic>{
            'avg_confidence': 78.0,
            'retention_score': 80.0,
            'avg_latency_ms': 240.0,
          },
        }),
      );

      final decision = AdaptiveRewardEconomy.instance.scaleReward(
        xp: 100,
        chips: 50,
      );

      expect(decision.multiplier, inInclusiveRange(0.8, 1.4));
      expect(decision.multiplier, greaterThan(1.0));
      expect(decision.adjustedXp, greaterThan(100));
      expect(decision.adjustedChips, greaterThan(50));
      expect(rewardCache.existsSync(), isTrue);

      final cacheJson =
          jsonDecode(rewardCache.readAsStringSync()) as Map<String, dynamic>;
      final history = (cacheJson['history'] as List)
          .cast<Map<String, dynamic>>();
      expect(history, isNotEmpty);
      expect(history.first['multiplier'], decision.multiplier);
      expect(history.first['base_xp'], 100);
      expect(history.first['adjusted_xp'], decision.adjustedXp);
    });

    test('reduces multiplier when confidence drops', () {
      telemetryFile.writeAsStringSync(
        jsonEncode({
          'derived_metrics': <String, dynamic>{
            'avg_confidence': 85.0,
            'retention_score': 82.0,
            'avg_latency_ms': 210.0,
          },
        }),
      );
      AdaptiveRewardEconomy.instance.scaleReward(xp: 100, chips: 50);

      telemetryFile.writeAsStringSync(
        jsonEncode({
          'derived_metrics': <String, dynamic>{
            'avg_confidence': 60.0,
            'retention_score': 78.0,
            'avg_latency_ms': 410.0,
          },
        }),
      );

      final decisionLow = AdaptiveRewardEconomy.instance.scaleReward(
        xp: 100,
        chips: 50,
      );

      expect(decisionLow.multiplier, inInclusiveRange(0.8, 1.4));
      expect(decisionLow.multiplier, lessThan(1.0));
      final cacheJson =
          jsonDecode(rewardCache.readAsStringSync()) as Map<String, dynamic>;
      final history = (cacheJson['history'] as List)
          .cast<Map<String, dynamic>>();
      expect(history.length, greaterThanOrEqualTo(2));
    });
  });
}
