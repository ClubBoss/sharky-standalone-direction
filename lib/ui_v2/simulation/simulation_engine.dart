import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:poker_analyzer/compat/player_action_compat.dart';

import 'bet_state.dart';

export 'package:poker_analyzer/compat/player_action_compat.dart'
    show PlayerAction;

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/adaptive_difficulty_service.dart';

/// Interactive Simulation Engine that reproduces real poker table play with adaptive pacing.
///
/// Core turn/round state machine handling betting order, pot tracking, and seat actions.
/// Supports 2-10 players with deterministic AI opponents.

enum SimulationStreet { preFlop, flop, turn, river, showdown }

enum PlayerType { hero, ai }

enum AiPersonality { tight, aggressive, passive }

class _AiTuningProfile {
  const _AiTuningProfile({
    required this.aggression,
    required this.bluff,
    required this.fold,
  });

  const _AiTuningProfile.neutral() : aggression = 1.0, bluff = 1.0, fold = 1.0;

  final double aggression;
  final double bluff;
  final double fold;
}

/// Rule-based AI opponent that mimics real poker logic and strategy patterns.
///
/// Features:
/// - Personality traits: tight (selective starting hands), aggressive (raises often), passive (calls more)
/// - Position-aware decisions (early/late position adjustments)
/// - Hand strength evaluation with random strength tiers
/// - Pot odds calculation and bet sizing logic
/// - Street-specific decision trees (pre-flop → river)
class RuleAiOpponent {
  RuleAiOpponent({
    required this.personality,
    required this.position,
    Random? random,
  }) : _random = random ?? Random();

  final AiPersonality personality;
  final int position; // 0-9 seat index
  final Random _random;
  double _aggressionMultiplier = 1.0;
  double _bluffScale = 1.0;
  double _foldScale = 1.0;

  // Personality-based thresholds
  double get foldThreshold {
    final base = switch (personality) {
      AiPersonality.tight => 0.65, // Folds 65% with weak hands
      AiPersonality.aggressive => 0.35, // Folds 35% with weak hands
      AiPersonality.passive => 0.45, // Folds 45% with weak hands
    };
    final adjusted = (base * _foldScale / _aggressionMultiplier).clamp(
      0.10,
      0.90,
    );
    return (adjusted as num).toDouble();
  }

  double get raiseFrequency {
    final base = switch (personality) {
      AiPersonality.tight => 0.20, // Raises 20% of the time
      AiPersonality.aggressive => 0.55, // Raises 55% of the time
      AiPersonality.passive => 0.10, // Raises 10% of the time
    };
    final adjusted = (base * _aggressionMultiplier).clamp(0.05, 0.90);
    return (adjusted as num).toDouble();
  }

  double get bluffFrequency {
    final base = switch (personality) {
      AiPersonality.tight => 0.05, // Bluffs 5%
      AiPersonality.aggressive => 0.25, // Bluffs 25%
      AiPersonality.passive => 0.02, // Bluffs 2%
    };
    final adjusted = (base * _aggressionMultiplier * _bluffScale).clamp(
      0.01,
      0.80,
    );
    return (adjusted as num).toDouble();
  }

  /// Simulates hand strength evaluation (0.0 = weak, 1.0 = strong).
  /// Uses random tiers to mimic variance in hand quality.
  double evaluateHandStrength(SimulationStreet street) {
    // Earlier streets have more variance
    final variance = switch (street) {
      SimulationStreet.preFlop => 0.30,
      SimulationStreet.flop => 0.25,
      SimulationStreet.turn => 0.15,
      SimulationStreet.river => 0.10,
      SimulationStreet.showdown => 0.0,
    };

    final base = _random.nextDouble();
    final adjustment = (_random.nextDouble() - 0.5) * variance;
    return (base + adjustment).clamp(0.0, 1.0);
  }

  /// Determines action and amount based on game state and personality.
  ({PlayerAction action, int? amount, String reasoning}) makeDecision({
    required SimulationStreet street,
    required int currentBet,
    required int playerBet,
    required int playerStack,
    required int pot,
    required int bigBlind,
    required int playerCount,
  }) {
    final callAmount = currentBet - playerBet;
    final handStrength = evaluateHandStrength(street);
    final isLatePosition = position >= (playerCount / 2).floor();
    final potOdds = pot > 0 ? callAmount / (pot + callAmount) : 0.0;
    final stackRatio = playerStack > 0 ? callAmount / playerStack : 1.0;

    // Decision tree per street
    switch (street) {
      case SimulationStreet.preFlop:
        return _decidePreFlop(
          handStrength: handStrength,
          currentBet: currentBet,
          callAmount: callAmount,
          playerStack: playerStack,
          bigBlind: bigBlind,
          isLatePosition: isLatePosition,
        );

      case SimulationStreet.flop:
      case SimulationStreet.turn:
      case SimulationStreet.river:
        return _decidePostFlop(
          street: street,
          handStrength: handStrength,
          currentBet: currentBet,
          callAmount: callAmount,
          playerStack: playerStack,
          pot: pot,
          bigBlind: bigBlind,
          potOdds: potOdds,
          stackRatio: stackRatio,
          isLatePosition: isLatePosition,
        );

      case SimulationStreet.showdown:
        return (
          action: PlayerAction.check,
          amount: null,
          reasoning: 'Showdown',
        );
    }
  }

  ({PlayerAction action, int? amount, String reasoning}) _decidePreFlop({
    required double handStrength,
    required int currentBet,
    required int callAmount,
    required int playerStack,
    required int bigBlind,
    required bool isLatePosition,
  }) {
    // No bet facing us
    if (currentBet == 0) {
      if (handStrength > 0.75 && _random.nextDouble() < raiseFrequency) {
        final raiseSize = bigBlind * (2 + _random.nextInt(3)); // 2-4× BB
        return (
          action: PlayerAction.bet,
          amount: raiseSize,
          reasoning: 'Opens ${(raiseSize / bigBlind).toStringAsFixed(1)}× BB',
        );
      }
      return (action: PlayerAction.check, amount: null, reasoning: 'Checks');
    }

    // Large bet (>50% of stack)
    if (callAmount >= playerStack * 0.5) {
      if (handStrength > 0.85) {
        return (
          action: PlayerAction.call,
          amount: null,
          reasoning: 'Calls all-in',
        );
      }
      return (
        action: PlayerAction.fold,
        amount: null,
        reasoning: 'Folds to pressure',
      );
    }

    // Hand strength-based decisions
    if (handStrength < foldThreshold) {
      return (
        action: PlayerAction.fold,
        amount: null,
        reasoning: 'Folds weak hand',
      );
    }

    if (handStrength > 0.80 && _random.nextDouble() < raiseFrequency) {
      final raiseSize =
          currentBet * (2 + _random.nextInt(2)); // 2-3× current bet
      return (
        action: PlayerAction.raise,
        amount: raiseSize,
        reasoning: 'Raises ${(raiseSize / currentBet).toStringAsFixed(1)}×',
      );
    }

    // Position-based calling
    if (isLatePosition && handStrength > 0.55) {
      return (
        action: PlayerAction.call,
        amount: null,
        reasoning: 'Calls in position',
      );
    }

    if (handStrength > 0.65) {
      return (
        action: PlayerAction.call,
        amount: null,
        reasoning: 'Calls decent hand',
      );
    }

    return (
      action: PlayerAction.fold,
      amount: null,
      reasoning: 'Folds marginal',
    );
  }

  ({PlayerAction action, int? amount, String reasoning}) _decidePostFlop({
    required SimulationStreet street,
    required double handStrength,
    required int currentBet,
    required int callAmount,
    required int playerStack,
    required int pot,
    required int bigBlind,
    required double potOdds,
    required double stackRatio,
    required bool isLatePosition,
  }) {
    // No bet facing us
    if (currentBet == 0) {
      // Consider betting with strong hands or bluffs
      if (handStrength > 0.75 && _random.nextDouble() < raiseFrequency) {
        final betSize = (pot * (0.5 + _random.nextDouble() * 0.5))
            .toInt(); // 50-100% pot
        return (
          action: PlayerAction.bet,
          amount: betSize,
          reasoning: 'Bets ${(betSize / pot * 100).toStringAsFixed(0)}% pot',
        );
      }

      // Occasional bluff
      if (isLatePosition &&
          handStrength < 0.4 &&
          _random.nextDouble() < bluffFrequency) {
        final betSize = (pot * 0.6).toInt();
        return (
          action: PlayerAction.bet,
          amount: betSize,
          reasoning: 'Bluffs 60% pot',
        );
      }

      return (action: PlayerAction.check, amount: null, reasoning: 'Checks');
    }

    // Facing a bet
    if (stackRatio > 0.7) {
      // Large bet relative to stack
      if (handStrength > 0.90) {
        return (
          action: PlayerAction.call,
          amount: null,
          reasoning: 'Calls with premium',
        );
      }
      return (
        action: PlayerAction.fold,
        amount: null,
        reasoning: 'Folds to big bet',
      );
    }

    // Pot odds calculation
    if (potOdds < 0.25 && handStrength > 0.60) {
      // Good pot odds
      if (_random.nextDouble() < raiseFrequency && handStrength > 0.80) {
        final raiseSize = currentBet * (2 + _random.nextInt(2));
        return (
          action: PlayerAction.raise,
          amount: raiseSize,
          reasoning:
              'Raises ${(raiseSize / pot * 100).toStringAsFixed(0)}% pot',
        );
      }
      return (
        action: PlayerAction.call,
        amount: null,
        reasoning: 'Calls good odds',
      );
    }

    // Marginal situations
    if (potOdds < 0.35 && handStrength > foldThreshold) {
      return (
        action: PlayerAction.call,
        amount: null,
        reasoning: 'Calls marginal',
      );
    }

    // Hand strength vs pot odds
    if (handStrength > 0.75) {
      return (
        action: PlayerAction.call,
        amount: null,
        reasoning: 'Calls strong hand',
      );
    }

    return (
      action: PlayerAction.fold,
      amount: null,
      reasoning: 'Folds weak odds',
    );
  }

  /// Returns AI aggression factor (raises / (raises + calls)).
  double calculateAggressionFactor({
    required int raiseCount,
    required int callCount,
  }) {
    final total = raiseCount + callCount;
    return total > 0 ? raiseCount / total : 0.0;
  }

  void updateAggression(double multiplier) {
    _aggressionMultiplier = multiplier.clamp(0.6, 1.4);
    _bluffScale = 1.0;
    _foldScale = 1.0;
  }

  void applyTuningProfile(_AiTuningProfile profile) {
    _aggressionMultiplier = profile.aggression.clamp(0.6, 1.4);
    _bluffScale = profile.bluff.clamp(0.6, 1.4);
    _foldScale = profile.fold.clamp(0.6, 1.4);
  }

  static double computeAdaptiveAggression(
    double confidence,
    double latencyMs,
    double retention,
  ) {
    var multiplier = 1.0;

    if (confidence >= 75) {
      multiplier += 0.25;
    } else if (confidence >= 50) {
      multiplier += 0.05;
    } else if (confidence < 35) {
      multiplier -= 0.20;
    }

    if (latencyMs > 0 && latencyMs <= 250) {
      multiplier += 0.10;
    } else if (latencyMs > 600) {
      multiplier -= 0.15;
    }

    if (retention >= 70) {
      multiplier += 0.05;
    } else if (retention < 40) {
      multiplier -= 0.10;
    }

    return multiplier.clamp(0.5, 1.5);
  }

  static _AiTuningProfile computeAdaptiveTuning({bool logTelemetry = true}) {
    final telemetry = _readUnifiedTelemetry();
    if (telemetry.isEmpty) {
      if (logTelemetry) {
        unawaited(
          FirebaseLiteTelemetryService.instance.logEvent(
            'ai_tuning_refined',
            params: const <String, Object>{
              'aggression': 1.0,
              'bluff': 1.0,
              'fold': 1.0,
              'confidence': 0.0,
              'latency_ms': 0,
              'retention': 0.0,
              'feeds': 0,
            },
          ),
        );
      }
      return const _AiTuningProfile.neutral();
    }

    final derived =
        telemetry['derived_metrics'] as Map<String, dynamic>? ?? const {};
    final confidence = (derived['avg_confidence'] as num?)?.toDouble() ?? 0.0;
    final latencyMs = (derived['avg_latency_ms'] as num?)?.toDouble() ?? 0.0;
    final retention = (derived['retention_score'] as num?)?.toDouble() ?? 0.0;
    final feedsMerged = (telemetry['feeds_merged'] as num?)?.toInt() ?? 0;

    double clampScale(double value) => value.clamp(0.6, 1.4).toDouble();

    var aggression = computeAdaptiveAggression(
      confidence,
      latencyMs,
      retention,
    );

    var bluff = 1.0;
    var fold = 1.0;

    if (confidence >= 80) {
      aggression += 0.10;
      bluff += 0.12;
      fold -= 0.12;
    } else if (confidence >= 65) {
      aggression += 0.05;
      bluff += 0.06;
      fold -= 0.06;
    } else if (confidence < 40) {
      aggression -= 0.10;
      bluff -= 0.10;
      fold += 0.12;
    } else if (confidence < 50) {
      aggression -= 0.05;
      bluff -= 0.05;
      fold += 0.06;
    }

    if (latencyMs > 0) {
      if (latencyMs <= 220) {
        aggression += 0.08;
        bluff += 0.10;
      } else if (latencyMs <= 320) {
        aggression += 0.04;
      } else if (latencyMs >= 600) {
        aggression -= 0.08;
        bluff -= 0.10;
        fold += 0.08;
      }
    }

    if (retention >= 80) {
      aggression += 0.05;
      bluff += 0.05;
      fold -= 0.04;
    } else if (retention < 55) {
      aggression -= 0.05;
      bluff -= 0.05;
      fold += 0.08;
    }

    aggression = clampScale(aggression);
    bluff = clampScale(bluff);
    fold = clampScale(fold);

    if (logTelemetry) {
      unawaited(
        FirebaseLiteTelemetryService.instance.logEvent(
          'ai_tuning_refined',
          params: <String, Object>{
            'aggression': double.parse(aggression.toStringAsFixed(2)),
            'bluff': double.parse(bluff.toStringAsFixed(2)),
            'fold': double.parse(fold.toStringAsFixed(2)),
            'confidence': double.parse(confidence.toStringAsFixed(2)),
            'latency_ms': latencyMs.round(),
            'retention': double.parse(retention.toStringAsFixed(2)),
            'feeds': feedsMerged,
          },
        ),
      );
    }

    return _AiTuningProfile(aggression: aggression, bluff: bluff, fold: fold);
  }

  static double loadAdaptiveAggressionMultiplier() {
    final profile = computeAdaptiveTuning(logTelemetry: false);
    return profile.aggression;
  }

  static Map<String, dynamic> _readUnifiedTelemetry() {
    const paths = [
      'tools/_reports/unified_telemetry_summary.json',
      'release/public_beta_v2/unified_telemetry_summary.json',
    ];

    for (final path in paths) {
      try {
        final file = File(path);
        if (!file.existsSync()) {
          continue;
        }
        final raw = file.readAsStringSync();
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (error) {
        stderr.writeln('[WARN] Failed to read unified telemetry: $error');
      }
    }

    return const {};
  }
}

class PlayerState {
  PlayerState({
    required this.seatIndex,
    required this.name,
    required this.stack,
    required this.type,
    this.hasFolded = false,
    this.currentBet = 0,
    this.isAllIn = false,
    this.aiPersonality,
    this.lastReasoning,
  });

  final int seatIndex;
  final String name;
  final PlayerType type;
  int stack;
  bool hasFolded;
  int currentBet;
  bool isAllIn;
  final AiPersonality? aiPersonality;
  String? lastReasoning; // AI decision reasoning for UI display

  bool get isActive => !hasFolded && !isAllIn && stack > 0;

  PlayerState copyWith({
    int? stack,
    bool? hasFolded,
    int? currentBet,
    bool? isAllIn,
    String? lastReasoning,
  }) {
    return PlayerState(
      seatIndex: seatIndex,
      name: name,
      stack: stack ?? this.stack,
      type: type,
      hasFolded: hasFolded ?? this.hasFolded,
      currentBet: currentBet ?? this.currentBet,
      isAllIn: isAllIn ?? this.isAllIn,
      aiPersonality: aiPersonality,
      lastReasoning: lastReasoning ?? this.lastReasoning,
    );
  }
}

class SimulationEvent {
  SimulationEvent({
    required this.type,
    required this.seatIndex,
    this.action,
    this.amount,
    this.street,
    this.pot,
    this.economyEvent,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String
  type; // 'action', 'street_change', 'pot_update', 'round_end', 'economy_event'
  final int seatIndex;
  final PlayerAction? action;
  final int? amount;
  final SimulationStreet? street;
  final int? pot;
  final EconomyEvent? economyEvent;
  final DateTime timestamp;
}

/// Economy event types for bankroll tracking.
enum EconomyEventType {
  blindPosted,
  betPlaced,
  potWon,
  bustOut,
  topUp,
  stakesAdjusted,
}

/// Economy event details for telemetry.
class EconomyEvent {
  EconomyEvent({
    required this.type,
    required this.seatIndex,
    required this.amount,
    this.newBalance,
    this.newBlindLevel,
  });

  final EconomyEventType type;
  final int seatIndex;
  final int amount;
  final int? newBalance;
  final int? newBlindLevel;
}

/// Records simulation history to a JSONL file for review & replay.
/// Each line is a JSON object representing either a completed round summary
/// or an action taken during a round. ASCII-only logging, no external deps.
class SimulationHistoryRecorder {
  SimulationHistoryRecorder({
    required this.engine,
    this.historyPath = 'tools/_reports/simulation_history.jsonl',
  }) {
    _subscription = engine.eventStream.listen(_onEvent);
  }

  final SimulationEngine engine;
  final String historyPath;
  final List<Map<String, Object?>> _roundActions = [];
  StreamSubscription<SimulationEvent>? _subscription;
  int? _heroStartBankroll;
  int? _heroStartStack;

  void _onEvent(SimulationEvent event) {
    // Ensure directory exists
    try {
      final file = File(historyPath);
      file.parent.createSync(recursive: true);
    } catch (_) {}

    if (event.type == 'round_start') {
      _roundActions.clear();
      _heroStartBankroll = engine.bankrollManager?.getBankroll(engine.heroSeat);
      _heroStartStack = engine.players[engine.heroSeat].stack;
      return;
    }

    if (event.type == 'action') {
      // Record minimal action snapshot
      _roundActions.add({
        't': event.timestamp.toIso8601String(),
        'seat': event.seatIndex,
        'action': event.action.toString().split('.').last,
        'amount': event.amount ?? 0,
        'street': event.street?.toString().split('.').last,
        'pot': event.pot ?? 0,
      });
      // Also append to file as an action record
      _appendLine({
        'type': 'action',
        'ts': event.timestamp.toIso8601String(),
        'seat': event.seatIndex,
        'action': event.action.toString().split('.').last,
        'amount': event.amount ?? 0,
        'street': event.street?.toString().split('.').last,
        'pot': event.pot ?? 0,
      });
      return;
    }

    if (event.type == 'round_end') {
      final now = DateTime.now();
      final sb = engine.bettingEconomy?.currentSmallBlind ?? engine.smallBlind;
      final bb = engine.bettingEconomy?.currentBigBlind ?? engine.bigBlind;

      final heroEndBankroll = engine.bankrollManager?.getBankroll(
        engine.heroSeat,
      );
      final heroEndStack = engine.players[engine.heroSeat].stack;

      final useBankroll = engine.bankrollManager != null;
      final start = useBankroll
          ? (_heroStartBankroll ?? 0)
          : (_heroStartStack ?? 0);
      final end = useBankroll ? (heroEndBankroll ?? 0) : (heroEndStack);
      final heroEvDiff = end - start;

      // Determine outcome relative to hero
      String outcome = 'neutral';
      if (heroEvDiff > 0) outcome = 'win';
      if (heroEvDiff < 0) outcome = 'loss';

      final summary = <String, Object?>{
        'type': 'round',
        'ts': now.toIso8601String(),
        'sb': sb,
        'bb': bb,
        'hero_seat': engine.heroSeat,
        'hero_ev_diff': heroEvDiff,
        'outcome': outcome,
        'pot': event.pot ?? 0,
        'actions': _roundActions,
        'bankroll_hero_after': heroEndBankroll,
        'bankroll_hero_before': _heroStartBankroll,
      };
      _appendLine(summary);
      return;
    }
  }

  void _appendLine(Map<String, Object?> json) {
    try {
      final file = File(historyPath);
      final encoder = const JsonEncoder();
      file.writeAsStringSync(
        '${encoder.convert(json)}\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // Best-effort only; never throw
      // ignore: avoid_print
      print('[History] write failed: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  /// Loads all history entries (JSONL) into a list of Map.
  static Future<List<Map<String, dynamic>>> loadHistory({
    String path = 'tools/_reports/simulation_history.jsonl',
  }) async {
    final file = File(path);
    if (!await file.exists()) return const [];
    final lines = await file.readAsLines();
    final list = <Map<String, dynamic>>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        final v = jsonDecode(trimmed);
        if (v is Map<String, dynamic>) list.add(v);
      } catch (_) {}
    }
    return list;
  }

  /// Returns most recent N round summaries.
  static Future<List<Map<String, dynamic>>> getRecentSessions(
    int count, {
    String path = 'tools/_reports/simulation_history.jsonl',
  }) async {
    final items = await loadHistory(path: path);
    final rounds = items.where((e) => e['type'] == 'round').toList();
    if (rounds.length <= count) return rounds.reversed.toList();
    return rounds.reversed.take(count).toList();
  }
}

/// Manages player bankroll tracking across simulation rounds.
///
/// Features:
/// - Per-player balance tracking
/// - Bust-out detection and auto top-up (training mode)
/// - Profit/loss calculation
/// - Balance trend analysis for adaptive difficulty
class BankrollManager {
  BankrollManager({
    required this.playerCount,
    required this.initialBankroll,
    this.trainingMode = true,
    this.minBankroll = 100,
  }) {
    for (var i = 0; i < playerCount; i++) {
      _bankrolls[i] = initialBankroll;
      _startingBankrolls[i] = initialBankroll;
    }
  }

  final int playerCount;
  final int initialBankroll;
  final bool trainingMode; // Auto top-up when bust
  final int minBankroll;

  final Map<int, int> _bankrolls = {};
  final Map<int, int> _startingBankrolls = {};
  final Map<int, int> _totalWinnings = {};
  final Map<int, int> _totalLosses = {};
  final Map<int, int> _bustCount = {};
  final Map<int, int> _topUpCount = {};

  int get totalBankroll => _bankrolls.values.fold(0, (a, b) => a + b);

  int getBankroll(int seatIndex) => _bankrolls[seatIndex] ?? 0;

  int getProfitLoss(int seatIndex) {
    final current = _bankrolls[seatIndex] ?? 0;
    final starting = _startingBankrolls[seatIndex] ?? 0;
    return current - starting;
  }

  int getTotalWinnings(int seatIndex) => _totalWinnings[seatIndex] ?? 0;

  int getTotalLosses(int seatIndex) => _totalLosses[seatIndex] ?? 0;

  int getBustCount(int seatIndex) => _bustCount[seatIndex] ?? 0;

  int getTopUpCount(int seatIndex) => _topUpCount[seatIndex] ?? 0;

  /// Calculates balance trend (positive = gaining, negative = losing).
  /// Returns value between -1.0 and 1.0.
  double getBalanceTrend(int seatIndex) {
    final current = _bankrolls[seatIndex] ?? 0;
    final starting = _startingBankrolls[seatIndex] ?? 0;
    if (starting == 0) return 0.0;

    final change = current - starting;
    final percentChange = change / starting;
    return percentChange.clamp(-1.0, 1.0);
  }

  /// Debits amount from player bankroll.
  /// Returns actual amount debited (may be less if insufficient funds).
  int debit(int seatIndex, int amount) {
    final currentBalance = _bankrolls[seatIndex] ?? 0;
    final actualDebit = min(amount, currentBalance);
    _bankrolls[seatIndex] = currentBalance - actualDebit;
    _totalLosses[seatIndex] = (_totalLosses[seatIndex] ?? 0) + actualDebit;
    return actualDebit;
  }

  /// Credits amount to player bankroll.
  void credit(int seatIndex, int amount) {
    _bankrolls[seatIndex] = (_bankrolls[seatIndex] ?? 0) + amount;
    _totalWinnings[seatIndex] = (_totalWinnings[seatIndex] ?? 0) + amount;
  }

  /// Checks if player is busted (bankroll < minBankroll).
  bool isBusted(int seatIndex) {
    return (_bankrolls[seatIndex] ?? 0) < minBankroll;
  }

  /// Handles bust-out: increments counter and optionally tops up.
  /// Returns top-up amount (0 if no top-up).
  int handleBustOut(int seatIndex) {
    _bustCount[seatIndex] = (_bustCount[seatIndex] ?? 0) + 1;

    if (trainingMode) {
      final topUpAmount = initialBankroll;
      _bankrolls[seatIndex] = topUpAmount;
      _topUpCount[seatIndex] = (_topUpCount[seatIndex] ?? 0) + 1;
      return topUpAmount;
    }

    return 0;
  }

  /// Resets bankroll to initial amount (for new session).
  void reset(int seatIndex) {
    _bankrolls[seatIndex] = initialBankroll;
    _startingBankrolls[seatIndex] = initialBankroll;
    _totalWinnings[seatIndex] = 0;
    _totalLosses[seatIndex] = 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_bankroll': totalBankroll,
      'bankrolls': _bankrolls,
      'profit_loss': Map.fromEntries(
        _bankrolls.keys.map((k) => MapEntry(k.toString(), getProfitLoss(k))),
      ),
      'total_winnings': _totalWinnings,
      'total_losses': _totalLosses,
      'bust_counts': _bustCount,
      'top_up_counts': _topUpCount,
    };
  }
}

/// Manages betting economy: blinds, antes, pots, payouts.
///
/// Features:
/// - Dynamic blind levels with escalation
/// - Pot management and splitting
/// - Adaptive difficulty: adjust stakes based on player performance
/// - Ante support (optional)
class BettingEconomy {
  BettingEconomy({
    required this.bankrollManager,
    this.baseSmallBlind = 10,
    this.baseBigBlind = 20,
    this.blindLevelMultiplier = 1.0,
    this.enableAdaptiveDifficulty = true,
    this.enableAntes = false,
  });

  final BankrollManager bankrollManager;
  final int baseSmallBlind;
  final int baseBigBlind;
  double blindLevelMultiplier;
  final bool enableAdaptiveDifficulty;
  final bool enableAntes;

  final List<int> _potHistory = [];
  int _roundsPlayed = 0;
  int _totalBlindsPosted = 0;
  int _totalAntesPosted = 0;

  int get currentSmallBlind => (baseSmallBlind * blindLevelMultiplier).round();
  int get currentBigBlind => (baseBigBlind * blindLevelMultiplier).round();
  int get currentAnte => enableAntes ? (currentBigBlind * 0.1).round() : 0;

  int get averagePot => _potHistory.isEmpty
      ? 0
      : (_potHistory.reduce((a, b) => a + b) / _potHistory.length).round();

  int get roundsPlayed => _roundsPlayed;
  int get totalBlindsPosted => _totalBlindsPosted;
  int get totalAntesPosted => _totalAntesPosted;

  /// Posts blinds for new round, debiting from bankrolls.
  /// Returns list of economy events.
  List<EconomyEvent> postBlinds({required int sbSeat, required int bbSeat}) {
    final events = <EconomyEvent>[];

    // Small blind
    final sbAmount = bankrollManager.debit(sbSeat, currentSmallBlind);
    _totalBlindsPosted += sbAmount;
    events.add(
      EconomyEvent(
        type: EconomyEventType.blindPosted,
        seatIndex: sbSeat,
        amount: sbAmount,
        newBalance: bankrollManager.getBankroll(sbSeat),
      ),
    );

    // Big blind
    final bbAmount = bankrollManager.debit(bbSeat, currentBigBlind);
    _totalBlindsPosted += bbAmount;
    events.add(
      EconomyEvent(
        type: EconomyEventType.blindPosted,
        seatIndex: bbSeat,
        amount: bbAmount,
        newBalance: bankrollManager.getBankroll(bbSeat),
      ),
    );

    return events;
  }

  /// Posts antes for all players (optional).
  /// Returns list of economy events.
  List<EconomyEvent> postAntes(List<int> activeSeats) {
    if (!enableAntes || currentAnte == 0) return [];

    final events = <EconomyEvent>[];
    for (final seat in activeSeats) {
      final anteAmount = bankrollManager.debit(seat, currentAnte);
      _totalAntesPosted += anteAmount;
      // No event for antes (too noisy), just track in pot
    }
    return events;
  }

  /// Adds bet to pot, debiting from bankroll.
  /// Returns economy event.
  EconomyEvent? placeBet(
    int seatIndex,
    int amount, {
    EconomyEventType type = EconomyEventType.betPlaced,
  }) {
    if (amount <= 0) return null;

    final actualAmount = bankrollManager.debit(seatIndex, amount);

    if (type == EconomyEventType.blindPosted) {
      _totalBlindsPosted += actualAmount;
    }

    return EconomyEvent(
      type: type,
      seatIndex: seatIndex,
      amount: actualAmount,
      newBalance: bankrollManager.getBankroll(seatIndex),
    );
  }

  /// Awards pot to winner, crediting bankroll.
  /// Returns economy event.
  EconomyEvent awardPot(int winningSeat, int potAmount) {
    bankrollManager.credit(winningSeat, potAmount);
    _potHistory.add(potAmount);
    _roundsPlayed++;

    return EconomyEvent(
      type: EconomyEventType.potWon,
      seatIndex: winningSeat,
      amount: potAmount,
      newBalance: bankrollManager.getBankroll(winningSeat),
    );
  }

  /// Handles bust-outs for players below minimum bankroll.
  /// Returns list of economy events.
  List<EconomyEvent> handleBustOuts() {
    final events = <EconomyEvent>[];
    for (var i = 0; i < bankrollManager.playerCount; i++) {
      if (bankrollManager.isBusted(i)) {
        final topUpAmount = bankrollManager.handleBustOut(i);
        if (topUpAmount > 0) {
          events.add(
            EconomyEvent(
              type: EconomyEventType.topUp,
              seatIndex: i,
              amount: topUpAmount,
              newBalance: bankrollManager.getBankroll(i),
            ),
          );
        } else {
          events.add(
            EconomyEvent(
              type: EconomyEventType.bustOut,
              seatIndex: i,
              amount: 0,
              newBalance: 0,
            ),
          );
        }
      }
    }
    return events;
  }

  /// Adjusts blind level based on adaptive difficulty.
  /// Increases stakes if player is winning, decreases if losing.
  /// Returns economy event if stakes changed.
  EconomyEvent? adjustAdaptiveDifficulty(int heroSeat) {
    if (!enableAdaptiveDifficulty) return null;
    if (_roundsPlayed < 10) return null; // Need history

    final trend = bankrollManager.getBalanceTrend(heroSeat);
    final oldMultiplier = blindLevelMultiplier;

    // Adjust multiplier based on trend
    if (trend > 0.3) {
      // Winning: increase difficulty
      blindLevelMultiplier = (blindLevelMultiplier * 1.1).clamp(1.0, 3.0);
    } else if (trend < -0.3) {
      // Losing: decrease difficulty
      blindLevelMultiplier = (blindLevelMultiplier * 0.9).clamp(0.5, 3.0);
    }

    if ((oldMultiplier - blindLevelMultiplier).abs() > 0.01) {
      return EconomyEvent(
        type: EconomyEventType.stakesAdjusted,
        seatIndex: heroSeat,
        amount: 0,
        newBlindLevel: currentBigBlind,
      );
    }

    return null;
  }

  /// Adjusts AI aggression based on player balance trend.
  /// Returns aggression multiplier (1.0 = normal, <1.0 = less aggressive, >1.0 = more aggressive).
  double getAiAggressionMultiplier(int heroSeat) {
    if (!enableAdaptiveDifficulty) return 1.0;

    final trend = bankrollManager.getBalanceTrend(heroSeat);

    // If player is winning, make AI more aggressive
    if (trend > 0.3) {
      return 1.0 + (trend * 0.5).clamp(0.0, 0.5);
    }
    // If player is losing, make AI less aggressive
    else if (trend < -0.3) {
      return 1.0 - (trend.abs() * 0.3).clamp(0.0, 0.3);
    }

    return 1.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'current_small_blind': currentSmallBlind,
      'current_big_blind': currentBigBlind,
      'current_ante': currentAnte,
      'blind_level_multiplier': blindLevelMultiplier,
      'average_pot': averagePot,
      'rounds_played': roundsPlayed,
      'total_blinds_posted': totalBlindsPosted,
      'total_antes_posted': totalAntesPosted,
      'pot_history_size': _potHistory.length,
    };
  }
}

class SimulationMetrics {
  int roundCount = 0;
  int aiActionCount = 0;
  int aiRaiseCount = 0;
  int aiCallCount = 0;
  int aiFoldCount = 0;
  final List<int> roundDurations = [];
  final List<int> userInteractionLatencies = [];
  DateTime? lastUserActionTime;

  // Per-personality analytics
  final Map<AiPersonality, int> personalityActionCounts = {
    AiPersonality.tight: 0,
    AiPersonality.aggressive: 0,
    AiPersonality.passive: 0,
  };

  void recordRoundDuration(int ms) {
    roundDurations.add(ms);
  }

  void recordAiAction(PlayerAction action, AiPersonality? personality) {
    aiActionCount++;

    switch (action) {
      case PlayerAction.raise:
      case PlayerAction.bet:
      case PlayerAction.post:
        aiRaiseCount++;
        break;
      case PlayerAction.call:
      case PlayerAction.check:
      case PlayerAction.none:
        aiCallCount++;
        break;
      case PlayerAction.fold:
        aiFoldCount++;
        break;
      case PlayerAction.allIn:
      case PlayerAction.push:
        aiRaiseCount++; // Count all-in as aggressive action
        break;
    }

    if (personality != null) {
      personalityActionCounts[personality] =
          (personalityActionCounts[personality] ?? 0) + 1;
    }
  }

  void recordUserInteraction() {
    if (lastUserActionTime != null) {
      final latency = DateTime.now()
          .difference(lastUserActionTime!)
          .inMilliseconds;
      userInteractionLatencies.add(latency);
    }
    lastUserActionTime = DateTime.now();
  }

  /// Returns AI aggression factor: raises / (raises + calls).
  double get aiAggressionFactor {
    final total = aiRaiseCount + aiCallCount;
    return total > 0 ? aiRaiseCount / total : 0.0;
  }

  /// Returns AI decision accuracy: (raises + calls) / total actions.
  /// Higher value means fewer folds (more confident decisions).
  double get aiDecisionAccuracy {
    return aiActionCount > 0
        ? (aiRaiseCount + aiCallCount) / aiActionCount
        : 0.0;
  }

  Map<String, dynamic> toJson({
    BankrollManager? bankrollManager,
    BettingEconomy? bettingEconomy,
  }) {
    final avgRoundMs = roundDurations.isEmpty
        ? 0
        : (roundDurations.reduce((a, b) => a + b) / roundDurations.length)
              .round();
    final avgUserLatency = userInteractionLatencies.isEmpty
        ? 0
        : (userInteractionLatencies.reduce((a, b) => a + b) /
                  userInteractionLatencies.length)
              .round();

    final json = {
      'round_count': roundCount,
      'ai_action_count': aiActionCount,
      'ai_raise_count': aiRaiseCount,
      'ai_call_count': aiCallCount,
      'ai_fold_count': aiFoldCount,
      'ai_aggression_factor': aiAggressionFactor,
      'ai_decision_accuracy': aiDecisionAccuracy,
      'avg_simulation_round_ms': avgRoundMs,
      'avg_user_interaction_latency_ms': avgUserLatency,
      'personality_tight_actions': personalityActionCounts[AiPersonality.tight],
      'personality_aggressive_actions':
          personalityActionCounts[AiPersonality.aggressive],
      'personality_passive_actions':
          personalityActionCounts[AiPersonality.passive],
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Add economy metrics if available
    if (bankrollManager != null) {
      json['bankroll'] = bankrollManager.toJson();
    }
    if (bettingEconomy != null) {
      json['economy'] = bettingEconomy.toJson();
    }

    return json;
  }
}

/// Core simulation engine with state machine and event streaming.
class SimulationEngine {
  SimulationEngine({
    required this.playerCount,
    this.heroSeat = 0,
    this.smallBlind = 10,
    this.bigBlind = 20,
    this.initialStack = 1000,
    this.enableEconomy = true,
    this.trainingMode = true,
    this.enableHistory = true,
    this.autoPlayHero = false,
    Random? random,
  }) : assert(playerCount >= 2 && playerCount <= 10),
       assert(heroSeat >= 0 && heroSeat < playerCount) {
    _random = random ?? Random();
    // Initialize economy system
    if (enableEconomy) {
      bankrollManager = BankrollManager(
        playerCount: playerCount,
        initialBankroll: initialStack * 10, // 10x stack for bankroll
        trainingMode: trainingMode,
        minBankroll: smallBlind * 10,
      );
      bettingEconomy = BettingEconomy(
        bankrollManager: bankrollManager!,
        baseSmallBlind: smallBlind,
        baseBigBlind: bigBlind,
        enableAdaptiveDifficulty: true,
      );
    }
    _initializePlayers();
    _eventController = StreamController<SimulationEvent>.broadcast();
    if (enableHistory) {
      _history = SimulationHistoryRecorder(engine: this);
    }
    _resetBettingState(carryPot: true);
  }

  final int playerCount;
  final int heroSeat;
  final int smallBlind;
  final int bigBlind;
  final int initialStack;
  final bool enableEconomy;
  final bool trainingMode;
  final bool enableHistory;
  final bool autoPlayHero;

  final List<PlayerState> _players = [];
  final Map<int, RuleAiOpponent> _aiOpponents = {}; // seat index -> AI opponent
  late StreamController<SimulationEvent> _eventController;
  late final Random _random;
  final SimulationMetrics metrics = SimulationMetrics();
  BankrollManager? bankrollManager;
  BettingEconomy? bettingEconomy;
  SimulationHistoryRecorder? _history;

  SimulationStreet _currentStreet = SimulationStreet.preFlop;
  int _pot = 0;
  int _currentBet = 0;
  int _currentSeat = 0;
  int _buttonSeat = 0;
  DateTime? _roundStartTime;
  bool _isRoundActive = false;
  late BetState _betState;
  Map<int, BetParticipant> _betParticipants = {};

  Stream<SimulationEvent> get eventStream => _eventController.stream;
  SimulationStreet get currentStreet => _currentStreet;
  int get pot => _pot;
  int get currentSeat => _currentSeat;
  List<PlayerState> get players => List.unmodifiable(_players);
  bool get isRoundActive => _isRoundActive;
  BetState get betState => _betState;
  List<SidePot> get sidePots => List.unmodifiable(_betState.sidePots);

  void _initializePlayers() {
    // Distribute personalities across AI players
    final personalities = [
      AiPersonality.tight,
      AiPersonality.aggressive,
      AiPersonality.passive,
    ];

    for (var i = 0; i < playerCount; i++) {
      // Determine initial stack from bankroll or default
      final playerStack = bankrollManager != null
          ? min(initialStack, bankrollManager!.getBankroll(i))
          : initialStack;

      if (i == heroSeat) {
        _players.add(
          PlayerState(
            seatIndex: i,
            name: 'Hero',
            stack: playerStack,
            type: PlayerType.hero,
          ),
        );
      } else {
        final personality = personalities[i % personalities.length];
        final personalityLabel = personality.toString().split('.').last;

        _players.add(
          PlayerState(
            seatIndex: i,
            name: 'AI ${i + 1} ($personalityLabel)',
            stack: playerStack,
            type: PlayerType.ai,
            aiPersonality: personality,
          ),
        );

        _aiOpponents[i] = RuleAiOpponent(
          personality: personality,
          position: i,
          random: _random,
        );
      }
    }
  }

  void _resetBettingState({bool carryPot = false}) {
    _betState = BetState.initial(bigBlind: bigBlind);
    if (carryPot) {
      _betState = _betState.copyWith(totalPot: _pot);
    }
    _betParticipants = {
      for (final player in _players)
        player.seatIndex: BetParticipant(
          seatIndex: player.seatIndex,
          stack: player.stack,
          currentBet: player.currentBet,
          hasFolded: player.hasFolded,
          isAllIn: player.isAllIn,
        ),
    };
    if (!carryPot) {
      _pot = _betState.totalPot;
    }
    _currentBet = _betState.currentBet;
  }

  void startRound() {
    if (_isRoundActive) return;

    final tuningProfile = RuleAiOpponent.computeAdaptiveTuning();
    final difficultyMultiplier = AdaptiveDifficultyService.instance
        .getCurrentDifficultyMultiplier();
    final combinedProfile = _AiTuningProfile(
      aggression: tuningProfile.aggression * difficultyMultiplier,
      bluff: tuningProfile.bluff * difficultyMultiplier,
      fold: tuningProfile.fold / max(difficultyMultiplier, 0.01),
    );
    for (final opponent in _aiOpponents.values) {
      opponent.applyTuningProfile(combinedProfile);
    }
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'ai_difficulty_adjusted',
        params: <String, Object>{
          'multiplier': double.parse(
            combinedProfile.aggression.toStringAsFixed(2),
          ),
          'ai_count': _aiOpponents.length,
          'difficulty_multiplier': double.parse(
            difficultyMultiplier.toStringAsFixed(2),
          ),
        },
      ),
    );

    // Check for bust-outs and adjust difficulty before round
    if (bettingEconomy != null) {
      final bustEvents = bettingEconomy!.handleBustOuts();
      for (final event in bustEvents) {
        _emitEvent(
          SimulationEvent(
            type: 'economy_event',
            seatIndex: event.seatIndex,
            economyEvent: event,
          ),
        );
      }

      // Adjust adaptive difficulty
      final difficultyEvent = bettingEconomy!.adjustAdaptiveDifficulty(
        heroSeat,
      );
      if (difficultyEvent != null) {
        _emitEvent(
          SimulationEvent(
            type: 'economy_event',
            seatIndex: difficultyEvent.seatIndex,
            economyEvent: difficultyEvent,
          ),
        );
      }
    }

    _isRoundActive = true;
    _roundStartTime = DateTime.now();
    _currentStreet = SimulationStreet.preFlop;
    _pot = 0;
    _currentBet = 0;
    metrics.roundCount++;

    // Reset player states
    for (var i = 0; i < _players.length; i++) {
      _players[i] = _players[i].copyWith(
        hasFolded: false,
        currentBet: 0,
        isAllIn: false,
      );
    }

    _resetBettingState();

    // Post blinds
    _postBlinds();

    // Start action after big blind
    _currentSeat = (_buttonSeat + 3) % playerCount;
    _advanceToNextActivePlayer(skipCurrent: false);

    _emitEvent(
      SimulationEvent(
        type: 'round_start',
        seatIndex: _currentSeat,
        street: _currentStreet,
        pot: _pot,
      ),
    );

    // Auto-advance if AI is first to act
    if (_players[_currentSeat].type == PlayerType.ai) {
      _scheduleAiAction();
    } else if (autoPlayHero && _players[_currentSeat].type == PlayerType.hero) {
      _scheduleHeroAutoAction();
    }
  }

  void _postBlinds() {
    final sbSeat = (_buttonSeat + 1) % playerCount;
    final bbSeat = (_buttonSeat + 2) % playerCount;

    _postBlind(sbSeat, smallBlind);
    _postBlind(bbSeat, bigBlind);
  }

  void _postBlind(int seatIndex, int amount) {
    if (amount <= 0) {
      return;
    }
    var blindAmount = amount;
    if (bettingEconomy != null) {
      final beforeStack = _players[seatIndex].stack;
      final economyEvent = bettingEconomy!.placeBet(
        seatIndex,
        amount,
        type: EconomyEventType.blindPosted,
      );
      if (economyEvent != null) {
        _emitEvent(
          SimulationEvent(
            type: 'economy_event',
            seatIndex: seatIndex,
            economyEvent: economyEvent,
          ),
        );
      }
      _syncStackWithBankroll(seatIndex);
      final afterStack = _players[seatIndex].stack;
      blindAmount = beforeStack - afterStack;
      if (blindAmount <= 0) {
        blindAmount = amount;
      }
      _players[seatIndex] = _players[seatIndex].copyWith(
        stack: beforeStack,
        currentBet: 0,
      );
      _betParticipants[seatIndex] = _betParticipants[seatIndex]!.copyWith(
        stack: beforeStack,
        currentBet: 0,
      );
    }

    final participant = _betParticipants[seatIndex];
    final target = (participant?.currentBet ?? 0) + blindAmount;
    _applyBetAction(
      seatIndex,
      PlayerAction.bet,
      amount: target,
      updateEconomy: bettingEconomy == null,
    );
  }

  /// Syncs player stack with bankroll.
  void _syncStackWithBankroll(int seatIndex) {
    if (bankrollManager == null) return;

    final currentStack = _players[seatIndex].stack;
    final bankroll = bankrollManager!.getBankroll(seatIndex);

    // Stack should not exceed bankroll
    final correctStack = min(currentStack, bankroll);
    if (correctStack != currentStack) {
      _players[seatIndex] = _players[seatIndex].copyWith(stack: correctStack);
    }
  }

  void _applyBetAction(
    int seatIndex,
    PlayerAction action, {
    int? amount,
    bool updateEconomy = true,
  }) {
    final participant = _betParticipants[seatIndex];
    if (participant == null) {
      return;
    }

    final result = _betState.applyAction(
      player: participant,
      action: action,
      amount: amount,
      participants: _betParticipants.values,
    );

    _betState = result.state;

    if (updateEconomy && bettingEconomy != null && result.invested > 0) {
      final economyEvent = bettingEconomy!.placeBet(seatIndex, result.invested);
      if (economyEvent != null) {
        _emitEvent(
          SimulationEvent(
            type: 'economy_event',
            seatIndex: seatIndex,
            economyEvent: economyEvent,
          ),
        );
      }
    }

    final player = _players[seatIndex];
    final nextStack = max(0, player.stack - result.invested);

    _players[seatIndex] = player.copyWith(
      stack: nextStack,
      currentBet: result.player.currentBet,
      hasFolded: result.player.hasFolded,
      isAllIn: result.player.isAllIn,
    );

    _betParticipants[seatIndex] = result.player.copyWith(stack: nextStack);

    _pot = _betState.totalPot;
    _currentBet = _betState.currentBet;
  }

  void playerAction(PlayerAction action, {int? amount}) {
    if (!_isRoundActive) return;
    final player = _players[_currentSeat];
    if (player.type != PlayerType.hero) return;

    metrics.recordUserInteraction();
    _processAction(_currentSeat, action, amount: amount);
  }

  void _processAction(int seatIndex, PlayerAction action, {int? amount}) {
    final participant = _betParticipants[seatIndex];
    if (participant == null) {
      return;
    }

    int? targetAmount = amount;
    switch (action) {
      case PlayerAction.raise:
      case PlayerAction.bet:
      case PlayerAction.post:
        if (targetAmount == null || targetAmount <= participant.currentBet) {
          if (_betState.currentBet == 0) {
            targetAmount = participant.currentBet + _betState.minRaise;
          } else {
            targetAmount = _betState.currentBet + _betState.minRaise;
          }
        }
        break;
      case PlayerAction.allIn:
      case PlayerAction.push:
        targetAmount = participant.currentBet + participant.stack;
        break;
      case PlayerAction.fold:
      case PlayerAction.call:
      case PlayerAction.check:
      case PlayerAction.none:
        targetAmount = null;
        break;
    }

    _applyBetAction(seatIndex, action, amount: targetAmount);

    _emitEvent(
      SimulationEvent(
        type: 'action',
        seatIndex: seatIndex,
        action: action,
        amount: targetAmount,
        pot: _pot,
      ),
    );

    if (_activePlayerCount() <= 1) {
      _endRound();
      return;
    }

    if (_isStreetComplete()) {
      _advanceStreet();
    } else {
      _advanceToNextActivePlayer();
      if (_players[_currentSeat].type == PlayerType.ai) {
        _scheduleAiAction();
      } else if (autoPlayHero &&
          _players[_currentSeat].type == PlayerType.hero) {
        _scheduleHeroAutoAction();
      }
    }
  }

  void _advanceToNextActivePlayer({bool skipCurrent = true}) {
    var checked = 0;
    if (!skipCurrent && _players[_currentSeat].isActive) {
      return;
    }
    while (checked < playerCount) {
      _currentSeat = (_currentSeat + 1) % playerCount;
      if (_players[_currentSeat].isActive) {
        return;
      }
      checked++;
    }
  }

  int _activePlayerCount() {
    return _players.where((p) => p.isActive).length;
  }

  bool _isStreetComplete() {
    final activePlayers = _players.where((p) => p.isActive).toList();
    if (activePlayers.isEmpty || activePlayers.length == 1) {
      return true;
    }

    // Check if all active players have matched the current bet
    for (final player in activePlayers) {
      if (player.currentBet < _currentBet) {
        return false;
      }
    }
    return true;
  }

  void _advanceStreet() {
    // Reset current bets for new street
    for (var i = 0; i < _players.length; i++) {
      _players[i] = _players[i].copyWith(currentBet: 0);
    }
    _currentBet = 0;
    _resetBettingState();

    switch (_currentStreet) {
      case SimulationStreet.preFlop:
        _currentStreet = SimulationStreet.flop;
        break;
      case SimulationStreet.flop:
        _currentStreet = SimulationStreet.turn;
        break;
      case SimulationStreet.turn:
        _currentStreet = SimulationStreet.river;
        break;
      case SimulationStreet.river:
        _currentStreet = SimulationStreet.showdown;
        _endRound();
        return;
      case SimulationStreet.showdown:
        _endRound();
        return;
    }

    _emitEvent(
      SimulationEvent(
        type: 'street_change',
        seatIndex: _currentSeat,
        street: _currentStreet,
        pot: _pot,
      ),
    );

    // Action starts after button on new street
    _currentSeat = (_buttonSeat + 1) % playerCount;
    _advanceToNextActivePlayer(skipCurrent: false);

    if (_players[_currentSeat].type == PlayerType.ai) {
      _scheduleAiAction();
    } else if (autoPlayHero && _players[_currentSeat].type == PlayerType.hero) {
      _scheduleHeroAutoAction();
    }
  }

  void _endRound() {
    _isRoundActive = false;

    if (_roundStartTime != null) {
      final duration = DateTime.now()
          .difference(_roundStartTime!)
          .inMilliseconds;
      metrics.recordRoundDuration(duration);
    }

    // Award pot to winner (simplified - in real game would need showdown logic)
    final activePlayers = _players.where((p) => !p.hasFolded).toList();
    if (activePlayers.length == 1) {
      final winner = activePlayers.first;

      // Use economy system for pot payout
      if (bettingEconomy != null) {
        final economyEvent = bettingEconomy!.awardPot(winner.seatIndex, _pot);
        _emitEvent(
          SimulationEvent(
            type: 'economy_event',
            seatIndex: winner.seatIndex,
            economyEvent: economyEvent,
          ),
        );
        // Sync stack with bankroll
        _syncStackWithBankroll(winner.seatIndex);
      } else {
        // Legacy mode
        _players[winner.seatIndex] = winner.copyWith(
          stack: winner.stack + _pot,
        );
      }
    } else {
      // Split pot among active players (simplified)
      final splitAmount = _pot ~/ activePlayers.length;
      for (final player in activePlayers) {
        if (bettingEconomy != null) {
          final economyEvent = bettingEconomy!.awardPot(
            player.seatIndex,
            splitAmount,
          );
          _emitEvent(
            SimulationEvent(
              type: 'economy_event',
              seatIndex: player.seatIndex,
              economyEvent: economyEvent,
            ),
          );
          _syncStackWithBankroll(player.seatIndex);
        } else {
          _players[player.seatIndex] = player.copyWith(
            stack: player.stack + splitAmount,
          );
        }
      }
    }

    _emitEvent(SimulationEvent(type: 'round_end', seatIndex: -1, pot: _pot));

    _pot = 0;
    _buttonSeat = (_buttonSeat + 1) % playerCount;
    _resetBettingState();
  }

  void _scheduleAiAction() {
    // Simulate thinking time (200-800ms)
    final thinkTime = 200 + _random.nextInt(600);
    Future.delayed(Duration(milliseconds: thinkTime), () {
      if (!_isRoundActive) return;
      if (_players[_currentSeat].type != PlayerType.ai) return;

      final decision = _determineAiAction(_currentSeat);

      // Record AI action with personality
      final player = _players[_currentSeat];
      metrics.recordAiAction(decision.action, player.aiPersonality);

      // Update player state with reasoning
      _players[_currentSeat] = player.copyWith(
        lastReasoning: decision.reasoning,
      );

      _processAction(_currentSeat, decision.action, amount: decision.amount);
    });
  }

  void _scheduleHeroAutoAction() {
    Future.microtask(() {
      if (!_isRoundActive) return;
      if (_players[_currentSeat].type != PlayerType.hero) return;
      final participant = _betParticipants[_currentSeat];
      if (participant == null) return;

      final callAmount = max(_betState.currentBet - participant.currentBet, 0);
      if (callAmount > participant.stack) {
        _processAction(_currentSeat, PlayerAction.fold);
        return;
      }

      final action = callAmount == 0 ? PlayerAction.check : PlayerAction.call;
      _processAction(_currentSeat, action);
    });
  }

  ({PlayerAction action, int? amount, String reasoning}) _determineAiAction(
    int seatIndex,
  ) {
    final aiOpponent = _aiOpponents[seatIndex];
    if (aiOpponent == null) {
      // Fallback for missing AI opponent
      return (
        action: PlayerAction.fold,
        amount: null,
        reasoning: 'Error: No AI',
      );
    }

    final player = _players[seatIndex];
    return aiOpponent.makeDecision(
      street: _currentStreet,
      currentBet: _currentBet,
      playerBet: player.currentBet,
      playerStack: player.stack,
      pot: _pot,
      bigBlind: bigBlind,
      playerCount: playerCount,
    );
  }

  void _emitEvent(SimulationEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  RuleAiOpponent? debugAiOpponent(int seatIndex) {
    return _aiOpponents[seatIndex];
  }

  void dispose() {
    _eventController.close();
    _history?.dispose();
  }
}
