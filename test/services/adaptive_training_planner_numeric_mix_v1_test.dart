import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/adaptive_training_planner.dart';

void main() {
  test('positive regular standard input allocates the single booster', () {
    expect(AdaptiveTrainingPlanner.mixFor(1, 'regular', 'standard'), {
      'theory': 0,
      'booster': 1,
      'assessment': 0,
    });
  });

  test('standard mixes preserve the three audience weight contracts', () {
    for (final entry in <String, Map<String, int>>{
      'novice': {'theory': 4, 'booster': 3, 'assessment': 1},
      'regular': {'theory': 2, 'booster': 3, 'assessment': 1},
      'advanced': {'theory': 1, 'booster': 2, 'assessment': 3},
    }.entries) {
      final count = entry.value.values.reduce((a, b) => a + b);
      expect(
        AdaptiveTrainingPlanner.mixFor(count, entry.key, 'standard'),
        entry.value,
        reason: entry.key,
      );
    }
  });

  test('quick keeps the existing booster and assessment multipliers', () {
    expect(AdaptiveTrainingPlanner.mixFor(18, 'novice', 'quick'), {
      'theory': 8,
      'booster': 9,
      'assessment': 1,
    });
  });

  test('deep keeps the existing assessment multiplier', () {
    expect(AdaptiveTrainingPlanner.mixFor(15, 'advanced', 'deep'), {
      'theory': 2,
      'booster': 4,
      'assessment': 9,
    });
  });

  test('nonpositive tag counts keep all allocations zero', () {
    for (final count in [-5, 0]) {
      expect(AdaptiveTrainingPlanner.mixFor(count, 'regular', 'quick'), {
        'theory': 0,
        'booster': 0,
        'assessment': 0,
      });
    }
  });

  test('unknown audience and format retain the standard regular fallback', () {
    const expected = {'theory': 2, 'booster': 3, 'assessment': 1};
    expect(AdaptiveTrainingPlanner.mixFor(6, 'unknown', 'standard'), expected);
    expect(AdaptiveTrainingPlanner.mixFor(6, 'regular', 'unknown'), expected);
    expect(AdaptiveTrainingPlanner.mixFor(6, 'unknown', 'unknown'), expected);
  });

  test('a quick mix cannot mutate later standard or deep mixes', () {
    AdaptiveTrainingPlanner.mixFor(18, 'novice', 'quick');
    expect(AdaptiveTrainingPlanner.mixFor(8, 'novice', 'standard'), {
      'theory': 4,
      'booster': 3,
      'assessment': 1,
    });
    expect(AdaptiveTrainingPlanner.mixFor(15, 'advanced', 'deep'), {
      'theory': 2,
      'booster': 4,
      'assessment': 9,
    });
  });

  test(
    'positive mixes conserve count and remain nonnegative deterministic ints',
    () {
      for (final audience in ['novice', 'regular', 'advanced', 'unknown']) {
        for (final format in ['standard', 'quick', 'deep', 'unknown']) {
          for (final count in [1, 2, 3, 7, 24]) {
            final result = AdaptiveTrainingPlanner.mixFor(
              count,
              audience,
              format,
            );
            expect(
              result.keys,
              unorderedEquals(['theory', 'booster', 'assessment']),
            );
            expect(result.values, everyElement(greaterThanOrEqualTo(0)));
            expect(result.values, everyElement(isA<int>()));
            expect(result.values.reduce((a, b) => a + b), count);
            expect(
              result,
              AdaptiveTrainingPlanner.mixFor(count, audience, format),
            );
          }
        }
      }
    },
  );
}
