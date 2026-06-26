import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';

void main() {
  test(
    'Sharky phrase tier contract maps world bands without activating AI',
    () {
      expect(
        act0SharkyCoachTierForWorldNumberV1(1),
        Act0SharkyCoachTierV1.foundation,
      );
      expect(
        act0SharkyCoachTierForWorldNumberV1(4),
        Act0SharkyCoachTierV1.foundation,
      );
      expect(
        act0SharkyCoachTierForWorldNumberV1(5),
        Act0SharkyCoachTierV1.developing,
      );
      expect(
        act0SharkyCoachTierForWorldNumberV1(12),
        Act0SharkyCoachTierV1.developing,
      );
      expect(
        act0SharkyCoachTierForWorldNumberV1(13),
        Act0SharkyCoachTierV1.sharp,
      );
      expect(
        act0SharkyCoachTierForWorldNumberV1(36),
        Act0SharkyCoachTierV1.sharp,
      );
    },
  );

  test('Foundation Sharky copy is warm direct and moment-owned', () {
    expect(
      act0SharkyCoachLineForMomentV1(
        Act0SharkyCoachMomentV1.practiceCurrentFix,
      ),
      'Run one quick rep while the clue is fresh.',
    );
    expect(
      act0SharkyCoachLineForMomentV1(
        Act0SharkyCoachMomentV1.reviewActiveRepair,
      ),
      'Keep this read warm with one quick rep.',
    );
    expect(
      act0SharkyCoachLineForMomentV1(Act0SharkyCoachMomentV1.repairResultProof),
      'Nice. You found the table clue.',
    );
    expect(
      act0SharkyCoachLineForMomentV1(
        Act0SharkyCoachMomentV1.worldOneCompletionPayoff,
      ),
      'You banked the first table read.',
    );
  });

  test('Future tiers are deterministic but not active W5-W36 expansion', () {
    expect(
      act0SharkyCoachLineForMomentV1(
        Act0SharkyCoachMomentV1.practiceCurrentFix,
        tier: Act0SharkyCoachTierV1.developing,
      ),
      'Repeat the key clue before adding pressure.',
    );
    expect(
      act0SharkyCoachLineForMomentV1(
        Act0SharkyCoachMomentV1.practiceCurrentFix,
        tier: Act0SharkyCoachTierV1.sharp,
      ),
      'Repeat the signal. Keep the decision clean.',
    );
  });

  test('Sharky coach phrase contract is short ascii and claim-safe', () {
    final moments = Act0SharkyCoachMomentV1.values;
    expect(moments, isNotEmpty);

    final seen = <String>{};
    for (final tier in Act0SharkyCoachTierV1.values) {
      for (final moment in moments) {
        final line = act0SharkyCoachLineForMomentV1(moment, tier: tier);
        expect(line, isNotEmpty);
        expect(line.length, lessThanOrEqualTo(58));
        expect(RegExp(r'^[\x00-\x7F]+$').hasMatch(line), isTrue);
        expect(seen.add('$tier::$line'), isTrue);

        final lower = line.toLowerCase();
        for (final forbidden in <String>[
          'ai',
          'gto',
          'solver',
          'master',
          'fixed forever',
          'cleared',
          'resolved',
          'recovered',
          'all-time',
          'rating',
          'radar',
          'level',
          'premium',
          'guaranteed',
          'remember everything',
          'leak',
          'pro-level',
        ]) {
          expect(lower, isNot(contains(forbidden)));
        }
      }
    }
  });
}
