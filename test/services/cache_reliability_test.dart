import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/adaptive_reward_economy.dart';
import 'package:poker_analyzer/services/player_progression_service.dart';
import 'package:poker_analyzer/services/ux_feedback_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const progressionPath = 'tools/_reports/progression_state.json';
  const rewardCachePath = 'tools/_reports/adaptive_reward_cache.json';
  const difficultyCachePath = 'tools/_reports/.adaptive_difficulty_cache.json';

  setUp(() async {
    await _deleteIfExists(progressionPath);
    await _deleteIfExists(rewardCachePath);
    await _deleteIfExists(difficultyCachePath);
  });

  tearDown(() async {
    await _deleteIfExists(progressionPath);
    await _deleteIfExists(rewardCachePath);
    await _deleteIfExists(difficultyCachePath);
  });

  group('PlayerProgressionService cache resilience', () {
    test('recovers from truncated JSON by recreating defaults', () {
      final file = File(progressionPath);
      file.createSync(recursive: true);
      file.writeAsStringSync('{"level": 4,'); // deliberately truncated

      final snapshot = PlayerProgressionService.instance.snapshot();

      expect(snapshot.level, 1);
      expect(snapshot.xpTotal, 0);
      expect(snapshot.leagueTier, 'Bronze');
    });

    test('ignores missing cache gracefully', () {
      final snapshot = PlayerProgressionService.instance.snapshot();
      expect(snapshot.level, greaterThanOrEqualTo(1));
    });
  });

  group('AdaptiveRewardEconomy cache resilience', () {
    test('uses defaults when difficulty cache unreadable', () {
      final diffFile = File(difficultyCachePath);
      diffFile.createSync(recursive: true);
      diffFile.writeAsStringSync('totally-invalid-json');

      final decision = AdaptiveRewardEconomy.instance.scaleReward(
        xp: 60,
        chips: 30,
      );

      expect(decision.multiplier, inInclusiveRange(0.8, 1.4));
      expect(decision.adjustedXp, greaterThan(0));
      expect(decision.adjustedChips, greaterThanOrEqualTo(0));
    });

    test('skips corrupted reward history entries without throwing', () {
      final cache = {
        'history': [
          {
            'timestamp': DateTime.now().toUtc().toIso8601String(),
            'adjusted_xp': 40,
            'adjusted_chips': 10,
            'multiplier': 1.05,
          },
          {
            'timestamp': 'not-a-date',
            'adjusted_xp': 'bad-value',
            'adjusted_chips': 5,
            'multiplier': 1.2,
          },
        ],
        'last_confidence': 47.2,
      };
      final file = File(rewardCachePath);
      file.createSync(recursive: true);
      file.writeAsStringSync(jsonEncode(cache));

      final decision = AdaptiveRewardEconomy.instance.scaleReward(
        xp: 20,
        chips: 5,
      );

      expect(decision.multiplier, inInclusiveRange(0.8, 1.4));
    });
  });

  group('UxFeedbackManager cache resilience', () {
    test('returns baseline reward when telemetry cache empty', () async {
      final file = File(rewardCachePath);
      file.createSync(recursive: true);
      file.writeAsStringSync('');

      final result = await UxFeedbackManager.instance.computeAdaptiveReward(
        xp: 25,
        chips: 10,
      );

      expect(result.adjustedXp, 25);
      expect(result.adjustedChips, 10);
      expect(result.scalingFactor, 1.0);
    });

    test('handles missing cache files without crashes', () async {
      final result = await UxFeedbackManager.instance.computeAdaptiveReward(
        xp: 12,
        chips: 6,
      );

      expect(result.scalingFactor, greaterThanOrEqualTo(0));
    });
  });
}

Future<void> _deleteIfExists(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}
