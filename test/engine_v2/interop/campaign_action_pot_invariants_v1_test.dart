import 'package:poker_analyzer/ui_v2/screens/campaign_action_pot_invariants_v1.dart';
import 'package:test/test.dart';

void main() {
  test('campaign action pot invariants are deterministic', () {
    final truth = deriveCampaignActionPotTruthV1(
      committedBySeatId: const <String, int>{'btn': 10, 'utg': 25, 'co': 25},
      actingSeatId: 'utg',
    );

    expect(truth.potTotal, 60);
    expect(truth.sumCommitted, 60);
    expect(truth.currentBet, 25);
    expect(truth.toCallBySeatId['btn'], 15);
    expect(truth.toCallBySeatId['utg'], 0);
    expect(truth.toCallBySeatId['co'], 0);
    expect(truth.actingSeatToCall, truth.toCallBySeatId['utg']);
  });

  test(
    'campaign action pot invariants include seeded blinds in committed scale',
    () {
      final truth = deriveCampaignActionPotTruthV1(
        committedBySeatId: const <String, int>{
          'sb': 1, // 0.5 in display chips
          'bb': 2, // 1.0 in display chips
          'utg': 20,
        },
        actingSeatId: 'btn',
      );

      expect(truth.potTotal, 23);
      expect(truth.sumCommitted, 23);
      expect(truth.currentBet, 20);
      expect(truth.toCallBySeatId['sb'], 19);
      expect(truth.toCallBySeatId['bb'], 18);
      expect(truth.toCallBySeatId['utg'], 0);
      expect(truth.actingSeatToCall, 20);
    },
  );

  test('seeded blinds + UTG open keep BTN toCall exact in integer units', () {
    final truth = deriveCampaignActionPotTruthV1(
      committedBySeatId: const <String, int>{
        'btn': 0,
        'sb': 1,
        'bb': 2,
        'utg': 15,
      },
      actingSeatId: 'btn',
    );

    expect(truth.toCallBySeatId['btn'], 15);
    expect(truth.currentBet, 15);
    expect(truth.actingSeatToCall, 15);
  });

  test('seeded blinds + UTG open keep pot equal to sumCommitted', () {
    final truth = deriveCampaignActionPotTruthV1(
      committedBySeatId: const <String, int>{
        'btn': 0,
        'sb': 1,
        'bb': 2,
        'utg': 15,
      },
      actingSeatId: 'btn',
    );

    expect(truth.potTotal, 18);
    expect(truth.sumCommitted, 18);
    expect(truth.potTotal, truth.sumCommitted);
  });
}
