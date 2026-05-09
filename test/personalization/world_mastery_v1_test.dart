import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';

void main() {
  group('computeWorldMasteryV1', () {
    test('gold requires 90+ accuracy, clean run, review cleared', () {
      final result = computeWorldMasteryV1(
        accuracyPercent: 90,
        mistakesCount: 0,
        reviewCleared: true,
      );
      expect(result.level, WorldMasteryLevelV1.gold);
      expect(result.reason, '90%+ and clean run');
    });

    test('gold blocked when review not cleared', () {
      final result = computeWorldMasteryV1(
        accuracyPercent: 100,
        mistakesCount: 0,
        reviewCleared: false,
      );
      expect(result.level, WorldMasteryLevelV1.silver);
      expect(result.reason, 'Good accuracy, minor mistakes');
    });

    test('silver at 75 percent with up to 2 mistakes', () {
      final result = computeWorldMasteryV1(
        accuracyPercent: 75,
        mistakesCount: 2,
        reviewCleared: false,
      );
      expect(result.level, WorldMasteryLevelV1.silver);
      expect(result.reason, 'Good accuracy, minor mistakes');
    });

    test('bronze below accuracy threshold', () {
      final result = computeWorldMasteryV1(
        accuracyPercent: 74,
        mistakesCount: 0,
        reviewCleared: true,
      );
      expect(result.level, WorldMasteryLevelV1.bronze);
      expect(result.reason, 'Needs more practice');
    });

    test('bronze on too many mistakes', () {
      final result = computeWorldMasteryV1(
        accuracyPercent: 88,
        mistakesCount: 3,
        reviewCleared: true,
      );
      expect(result.level, WorldMasteryLevelV1.bronze);
      expect(result.reason, 'Needs more practice');
    });

    test('same inputs are deterministic', () {
      final a = computeWorldMasteryV1(
        accuracyPercent: 92,
        mistakesCount: 1,
        reviewCleared: true,
      );
      final b = computeWorldMasteryV1(
        accuracyPercent: 92,
        mistakesCount: 1,
        reviewCleared: true,
      );
      expect(a.level, b.level);
      expect(a.reason, b.reason);
    });
  });
}
