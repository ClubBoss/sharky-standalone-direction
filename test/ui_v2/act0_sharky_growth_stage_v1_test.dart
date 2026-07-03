import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';

void main() {
  group('act0SharkyGrowthStageForWorldNumberV1 — admission rules', () {
    test('worlds 1-4 resolve Foundation growth', () {
      for (final worldNumber in <int>[1, 2, 3, 4]) {
        expect(
          act0SharkyGrowthStageForWorldNumberV1(worldNumber),
          Act0SharkyGrowthStageV1.foundation,
          reason: 'world $worldNumber must be Foundation',
        );
      }
    });

    test('world 5 and beyond resolve Developing growth', () {
      for (final worldNumber in <int>[5, 6, 7, 12]) {
        expect(
          act0SharkyGrowthStageForWorldNumberV1(worldNumber),
          Act0SharkyGrowthStageV1.developing,
          reason: 'world $worldNumber must be Developing',
        );
      }
    });

    test('W13+ still resolves only the existing Developing stage', () {
      for (final worldNumber in <int>[13, 20, 24, 36]) {
        expect(
          act0SharkyGrowthStageForWorldNumberV1(worldNumber),
          Act0SharkyGrowthStageV1.developing,
        );
      }
      // No third stage exists for W13+ or any other input.
      expect(Act0SharkyGrowthStageV1.values.length, 2);
    });

    test('a missing/zero/negative world number falls back to Foundation', () {
      expect(
        act0SharkyGrowthStageForWorldNumberV1(0),
        Act0SharkyGrowthStageV1.foundation,
      );
      expect(
        act0SharkyGrowthStageForWorldNumberV1(-1),
        Act0SharkyGrowthStageV1.foundation,
      );
    });

    test('a missing/null tier falls back to Foundation', () {
      expect(
        act0SharkyGrowthStageForTierV1(null),
        Act0SharkyGrowthStageV1.foundation,
      );
    });

    test('growth stage matches the phrase tier boundary exactly', () {
      for (var worldNumber = 0; worldNumber <= 20; worldNumber++) {
        final tier = act0SharkyCoachTierForWorldNumberV1(worldNumber);
        final expectedStage = act0SharkyGrowthStageForTierV1(tier);
        expect(
          act0SharkyGrowthStageForWorldNumberV1(worldNumber),
          expectedStage,
          reason: 'world $worldNumber growth/tier must agree',
        );
      }
    });

    test('same input yields deterministic output', () {
      final first = act0SharkyGrowthStageForWorldNumberV1(4);
      final second = act0SharkyGrowthStageForWorldNumberV1(4);
      expect(first, second);
    });
  });

  group('Growth stage vocabulary is bounded', () {
    test('exactly two stages exist, no rank/tier-number/rarity extras', () {
      final names = Act0SharkyGrowthStageV1.values
          .map((stage) => stage.name)
          .toSet();
      expect(names, <String>{'foundation', 'developing'});
      for (final forbidden in <String>[
        'beginner',
        'intermediate',
        'advanced',
        'expert',
        'tier1',
        'tier2',
        'tier3',
        'rarity',
        'prestige',
        'locked',
        'unlocked',
        'level',
        'rank',
      ]) {
        expect(names, isNot(contains(forbidden)));
      }
    });
  });

  group('No string-driven stage inference', () {
    test(
      'the growth-stage resolver functions never read resolved phrase text',
      () {
        final source = File(
          'lib/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart',
        ).readAsStringSync();
        final start = source.indexOf('enum Act0SharkyGrowthStageV1');
        expect(start, greaterThan(-1));
        final end = source.indexOf(
          'Act0SharkyCoachPhraseV1 act0ResolveSharkyCoachPhraseV1(',
          start,
        );
        final body = source.substring(start, end == -1 ? source.length : end);
        expect(body, isNot(contains('.line')));
        expect(body, isNot(contains('context.')));
      },
    );
  });
}
