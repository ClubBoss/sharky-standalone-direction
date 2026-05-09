import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';

/// Unit tests for the simulation economy system (BankrollManager and BettingEconomy).
void main() {
  group('BankrollManager', () {
    test('initializes with correct bankrolls for all players', () {
      final manager = BankrollManager(
        playerCount: 6,
        initialBankroll: 10000,
        trainingMode: true,
        minBankroll: 100,
      );

      for (var i = 0; i < 6; i++) {
        expect(manager.getBankroll(i), 10000);
        expect(manager.getProfitLoss(i), 0);
      }
    });

    test('debit reduces bankroll correctly', () {
      final manager = BankrollManager(
        playerCount: 3,
        initialBankroll: 5000,
        trainingMode: false,
        minBankroll: 50,
      );

      final actualAmount = manager.debit(0, 1000);
      expect(actualAmount, 1000);
      expect(manager.getBankroll(0), 4000);
      expect(manager.getProfitLoss(0), -1000);
    });

    test('debit caps at available bankroll', () {
      final manager = BankrollManager(
        playerCount: 3,
        initialBankroll: 500,
        trainingMode: false,
        minBankroll: 50,
      );

      final actualAmount = manager.debit(1, 1000);
      expect(actualAmount, 500);
      expect(manager.getBankroll(1), 0);
      expect(manager.isBusted(1), true);
    });

    test('credit increases bankroll correctly', () {
      final manager = BankrollManager(
        playerCount: 4,
        initialBankroll: 2000,
        trainingMode: false,
        minBankroll: 100,
      );

      manager.debit(2, 500);
      expect(manager.getBankroll(2), 1500);

      manager.credit(2, 1500);
      expect(manager.getBankroll(2), 3000);
      expect(manager.getProfitLoss(2), 1000);
    });

    test('isBusted returns true when bankroll below minimum', () {
      final manager = BankrollManager(
        playerCount: 2,
        initialBankroll: 200,
        trainingMode: false,
        minBankroll: 100,
      );

      expect(manager.isBusted(0), false);

      manager.debit(0, 150);
      expect(manager.getBankroll(0), 50);
      expect(manager.isBusted(0), true);
    });

    test('handleBustOut tops up in training mode', () {
      final manager = BankrollManager(
        playerCount: 3,
        initialBankroll: 1000,
        trainingMode: true,
        minBankroll: 100,
      );

      manager.debit(1, 950);
      expect(manager.getBankroll(1), 50);
      expect(manager.isBusted(1), true);

      final topUpAmount = manager.handleBustOut(1);
      expect(topUpAmount, 1000); // Top-up amount is initialBankroll
      expect(manager.getBankroll(1), 1000); // Bankroll reset to initialBankroll
      expect(manager.isBusted(1), false);
    });

    test('handleBustOut resets in non-training mode', () {
      final manager = BankrollManager(
        playerCount: 3,
        initialBankroll: 1000,
        trainingMode: false,
        minBankroll: 100,
      );

      manager.debit(2, 980);
      expect(manager.getBankroll(2), 20);
      expect(manager.isBusted(2), true);

      final topUpAmount = manager.handleBustOut(2);
      expect(topUpAmount, 0); // Non-training mode: no top-up
      expect(manager.getBankroll(2), 20); // Bankroll unchanged
      expect(manager.isBusted(2), true); // Still busted
    });

    test('getBalanceTrend returns correct trend', () {
      final manager = BankrollManager(
        playerCount: 4,
        initialBankroll: 5000,
        trainingMode: false,
        minBankroll: 50,
      );

      // No change initially
      expect(manager.getBalanceTrend(0), 0.0);

      // Win scenario
      manager.credit(0, 3000);
      final winTrend = manager.getBalanceTrend(0);
      expect(winTrend > 0, true);

      // Loss scenario
      manager.debit(1, 4000);
      final lossTrend = manager.getBalanceTrend(1);
      expect(lossTrend < 0, true);
    });

    test('toJson exports correct structure', () {
      final manager = BankrollManager(
        playerCount: 2,
        initialBankroll: 3000,
        trainingMode: true,
        minBankroll: 150,
      );

      manager.debit(0, 500);
      manager.credit(1, 1000);

      final json = manager.toJson();
      expect(json['total_bankroll'], 6500); // 2*3000 - 500 + 1000
      expect(json['bankrolls'], isA<Map>());
      expect(json['profit_loss'], isA<Map>());
    });
  });

  group('BettingEconomy', () {
    late BankrollManager bankrollManager;
    late BettingEconomy economy;

    setUp(() {
      bankrollManager = BankrollManager(
        playerCount: 6,
        initialBankroll: 10000,
        trainingMode: true,
        minBankroll: 100,
      );
      economy = BettingEconomy(
        bankrollManager: bankrollManager,
        baseSmallBlind: 10,
        baseBigBlind: 20,
        enableAdaptiveDifficulty: true,
      );
    });

    test('initializes with correct blind levels', () {
      expect(economy.currentSmallBlind, 10);
      expect(economy.currentBigBlind, 20);
      expect(economy.roundsPlayed, 0);
    });

    test('postBlinds debits correct amounts', () {
      final events = economy.postBlinds(sbSeat: 1, bbSeat: 2);

      expect(events.length, 2);
      expect(events[0].type, EconomyEventType.blindPosted);
      expect(events[0].seatIndex, 1);
      expect(events[0].amount, 10);

      expect(events[1].type, EconomyEventType.blindPosted);
      expect(events[1].seatIndex, 2);
      expect(events[1].amount, 20);

      expect(bankrollManager.getBankroll(1), 9990);
      expect(bankrollManager.getBankroll(2), 9980);
    });

    test('postAntes debits all players', () {
      final economyWithAntes = BettingEconomy(
        bankrollManager: bankrollManager,
        baseSmallBlind: 10,
        baseBigBlind: 20,
        enableAdaptiveDifficulty: false,
        enableAntes: true,
      );

      final events = economyWithAntes.postAntes([0, 1, 2, 3]);
      expect(events.isEmpty, true); // Antes don't emit individual events

      // Each player should have ante (2) deducted
      for (var i = 0; i < 4; i++) {
        expect(bankrollManager.getBankroll(i), 9998);
      }
    });

    test('placeBet debits bankroll', () {
      final event = economy.placeBet(3, 100);

      expect(event, isNotNull);
      expect(event!.type, EconomyEventType.betPlaced);
      expect(event.seatIndex, 3);
      expect(event.amount, 100);
      expect(bankrollManager.getBankroll(3), 9900);
    });

    test('placeBet returns null for zero amount', () {
      final event = economy.placeBet(0, 0);
      expect(event, isNull);
    });

    test('awardPot credits winner', () {
      final event = economy.awardPot(4, 500);

      expect(event.type, EconomyEventType.potWon);
      expect(event.seatIndex, 4);
      expect(event.amount, 500);
      expect(bankrollManager.getBankroll(4), 10500);
      expect(economy.roundsPlayed, 1);
    });

    test('averagePot calculates correctly', () {
      economy.awardPot(0, 200);
      economy.awardPot(1, 400);
      economy.awardPot(2, 600);

      expect(economy.averagePot, 400);
    });

    test('handleBustOuts detects and handles busted players', () {
      // Bust player 5
      bankrollManager.debit(5, 9950);
      expect(bankrollManager.isBusted(5), true);

      final events = economy.handleBustOuts();
      expect(events.length, 1);
      expect(events[0].type, EconomyEventType.topUp); // Training mode
      expect(events[0].seatIndex, 5);

      // Training mode tops up
      expect(bankrollManager.isBusted(5), false);
    });

    test('adjustAdaptiveDifficulty increases stakes when hero winning', () {
      // Need at least 10 rounds played for adaptive difficulty
      for (var i = 0; i < 10; i++) {
        economy.awardPot(1, 100); // Play some rounds
      }

      // Simulate hero winning
      bankrollManager.credit(0, 5000); // Hero now at 15000 (>30% gain)

      final event = economy.adjustAdaptiveDifficulty(0);
      expect(event, isNotNull);
      expect(event!.type, EconomyEventType.stakesAdjusted);

      // Blinds should increase
      expect(economy.currentSmallBlind, greaterThan(10));
      expect(economy.currentBigBlind, greaterThan(20));
    });

    test('adjustAdaptiveDifficulty decreases stakes when hero losing', () {
      // Need at least 10 rounds played for adaptive difficulty
      for (var i = 0; i < 10; i++) {
        economy.awardPot(1, 100); // Play some rounds
      }

      // Simulate hero losing
      bankrollManager.debit(0, 4000); // Hero now at 6000 (>30% loss)

      final event = economy.adjustAdaptiveDifficulty(0);
      expect(event, isNotNull);
      expect(event!.type, EconomyEventType.stakesAdjusted);

      // Blinds should decrease
      expect(economy.currentSmallBlind, lessThan(10));
      expect(economy.currentBigBlind, lessThan(20));
    });

    test('getAiAggressionMultiplier adjusts based on hero trend', () {
      // Initial multiplier should be 1.0
      expect(economy.getAiAggressionMultiplier(0), 1.0);

      // Hero winning -> AI more aggressive
      bankrollManager.credit(0, 5000);
      economy.adjustAdaptiveDifficulty(0);
      final aggressiveMultiplier = economy.getAiAggressionMultiplier(0);
      expect(aggressiveMultiplier, greaterThan(1.0));
      expect(aggressiveMultiplier, lessThanOrEqualTo(1.5));

      // Reset for loss test
      final manager2 = BankrollManager(
        playerCount: 6,
        initialBankroll: 10000,
        trainingMode: true,
        minBankroll: 100,
      );
      final economy2 = BettingEconomy(
        bankrollManager: manager2,
        baseSmallBlind: 10,
        baseBigBlind: 20,
        enableAdaptiveDifficulty: true,
      );

      // Hero losing -> AI less aggressive
      manager2.debit(0, 4000);
      economy2.adjustAdaptiveDifficulty(0);
      final passiveMultiplier = economy2.getAiAggressionMultiplier(0);
      expect(passiveMultiplier, lessThan(1.0));
      expect(passiveMultiplier, greaterThanOrEqualTo(0.7));
    });

    test('toJson exports correct structure', () {
      economy.postBlinds(sbSeat: 0, bbSeat: 1);
      economy.awardPot(2, 300);

      final json = economy.toJson();
      expect(json['current_small_blind'], 10);
      expect(json['current_big_blind'], 20);
      expect(json['blind_level_multiplier'], 1.0);
      expect(json['rounds_played'], 1);
      expect(json['average_pot'], 300);
      expect(json.containsKey('total_blinds_posted'), true);
    });
  });

  group('Economy Integration with SimulationEngine', () {
    test('engine with economy tracks bankroll', () {
      final engine = SimulationEngine(
        playerCount: 4,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        initialStack: 1000,
        enableEconomy: true,
        trainingMode: true,
      );

      expect(engine.bankrollManager, isNotNull);
      expect(engine.bettingEconomy, isNotNull);

      // Initial bankroll should be 10x stack
      expect(engine.bankrollManager!.getBankroll(0), 10000);
    });

    test('engine without economy has null managers', () {
      final engine = SimulationEngine(
        playerCount: 4,
        heroSeat: 0,
        enableEconomy: false,
      );

      expect(engine.bankrollManager, isNull);
      expect(engine.bettingEconomy, isNull);
    });

    test('economy events are emitted during round', () async {
      final engine = SimulationEngine(
        playerCount: 3,
        heroSeat: 0,
        smallBlind: 10,
        bigBlind: 20,
        enableEconomy: true,
        trainingMode: true,
      );

      final economyEvents = <EconomyEvent>[];
      engine.eventStream.listen((event) {
        if (event.type == 'economy_event' && event.economyEvent != null) {
          economyEvents.add(event.economyEvent!);
        }
      });

      engine.startRound();
      await Future.delayed(const Duration(milliseconds: 100));

      // Should have at least blind events
      expect(economyEvents.isNotEmpty, true);
      expect(
        economyEvents
            .where((e) => e.type == EconomyEventType.blindPosted)
            .length,
        greaterThanOrEqualTo(2),
      );

      engine.dispose();
    });

    test('metrics include economy data when enabled', () {
      final engine = SimulationEngine(
        playerCount: 4,
        enableEconomy: true,
        trainingMode: true,
      );

      engine.startRound();

      final json = engine.metrics.toJson(
        bankrollManager: engine.bankrollManager,
        bettingEconomy: engine.bettingEconomy,
      );

      expect(json['bankroll'], isNotNull);
      expect(json['economy'], isNotNull);
      expect(json['bankroll']['total_bankroll'], isA<int>());
      expect(json['economy']['rounds_played'], isA<int>());

      engine.dispose();
    });
  });
}
