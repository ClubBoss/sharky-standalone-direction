import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:poker_analyzer/engine/simulation_action_loop.dart';
import 'package:poker_analyzer/engine/simulation_state_engine.dart';

bool get kIsAuditMode =>
    SimulationAIAgent.auditOverride || Platform.environment['AI_AUDIT'] == '1';

bool get kIsAutotuneMode =>
    kIsAuditMode ||
    SimulationAIAgent.autoTuneOverride ||
    Platform.environment['AI_AUTOTUNE'] == '1';

class SimulationAIAgent {
  factory SimulationAIAgent({
    double aggression = 0.5,
    double baseBluffRate = 0.18,
    double earlyStreetModifier = 0.9,
    double lateStreetModifier = 1.1,
    int baseDelayMs = 1200,
    double delayJitter = 0.2,
    int? seed,
  }) {
    final weights = kIsAutotuneMode
        ? _AutotuneWeights.load()
        : const _AutotuneWeights();
    final aggressionScale = kIsAutotuneMode ? weights.aggressionScale : 1.0;
    final bluffScale = kIsAutotuneMode ? weights.bluffScale : 1.0;
    final sanitizedDelayJitter = delayJitter.clamp(0.0, 0.5).toDouble();
    return SimulationAIAgent._(
      aggression: _applyAggression(aggression, aggressionScale),
      baseBluffRate: _applyBluffRate(baseBluffRate, bluffScale),
      earlyStreetModifier: earlyStreetModifier,
      lateStreetModifier: lateStreetModifier,
      baseDelayMs: baseDelayMs,
      delayJitter: sanitizedDelayJitter,
      seed: seed,
    );
  }

  SimulationAIAgent._({
    required this.aggression,
    required this.baseBluffRate,
    required this.earlyStreetModifier,
    required this.lateStreetModifier,
    required this.baseDelayMs,
    required this.delayJitter,
    int? seed,
  }) : _random = Random(seed ?? 1337);

  final double aggression;
  final double baseBluffRate;
  static bool auditOverride = false;
  static bool autoTuneOverride = false;

  final double earlyStreetModifier;
  final double lateStreetModifier;
  final int baseDelayMs;
  final double delayJitter;
  final Random _random;

  Map<String, Object?> decideAction(SimulationState state) {
    if (state.players.isEmpty) {
      return const <String, Object?>{'type': 'check', 'amount': 0};
    }

    final player = state.players[state.currentIndex];
    final streetModifier = _streetModifier(state.board.length);
    final positionBias = _positionBias(
      player,
      state.currentIndex,
      state.players.length,
    );
    final potFactor = _potFactor(state.pot);
    final effectiveAggression = (aggression * streetModifier + positionBias)
        .clamp(0.0, 1.0);

    final delayMs = _computeDelayMs();
    final betWeight = _positiveWeight(
      0.2 + effectiveAggression * 0.55 + potFactor * 0.3,
    );
    final callWeight = _positiveWeight(
      0.25 + (1 - effectiveAggression) * 0.4 + potFactor * 0.2,
    );
    final foldWeight = _positiveWeight(
      0.1 + (1 - effectiveAggression) * 0.3 - positionBias * 0.2,
    );
    final checkWeight = _positiveWeight(
      0.2 + (1 - potFactor) * 0.2 + (0.35 - effectiveAggression) * 0.2,
    );

    final choices = <_WeightedAction>[
      _WeightedAction('bet', betWeight),
      _WeightedAction('call', callWeight),
      _WeightedAction('fold', foldWeight),
      _WeightedAction('check', checkWeight),
    ];

    final selected = _selectAction(choices);
    final amount = selected == 'bet'
        ? _determineBetSize(state, effectiveAggression, potFactor)
        : selected == 'call'
        ? _callAmount(state)
        : 0;

    final isBluff = (selected == 'bet' || selected == 'raise')
        ? _isBluff(effectiveAggression)
        : false;

    return <String, Object?>{
      'player': player,
      'type': selected,
      'amount': amount,
      'delay_ms': delayMs,
      'telemetry': <String, Object?>{
        'player': player,
        'decision': selected,
        'bet_amount': amount,
        'delay_ms': delayMs,
        'is_bluff': isBluff,
        'effective_aggression': double.parse(
          effectiveAggression.toStringAsFixed(3),
        ),
        'street_modifier': streetModifier,
        'position_bias': double.parse(positionBias.toStringAsFixed(3)),
        'pot_factor': double.parse(potFactor.toStringAsFixed(3)),
      },
    };
  }

  SimulationBatchStats simulateHand(int handCount, {List<String>? players}) {
    if (handCount <= 0) {
      throw ArgumentError.value(handCount, 'handCount', 'Must be positive');
    }
    final seats = List<String>.from(
      players ?? const <String>['SB', 'BB', 'HJ', 'CO', 'BTN'],
    );
    if (seats.isEmpty) {
      throw ArgumentError('At least one player is required.');
    }

    final wins = LinkedHashMap<String, int>.fromIterable(
      seats,
      value: (_) => 0,
    );
    var totalPot = 0;
    var totalBets = 0;
    var totalBluffs = 0;

    for (var hand = 0; hand < handCount; hand++) {
      final state = SimulationState(players: seats, board: _dealBoard());
      final loop = ActionLoop(
        ActionQueue(const <Map<String, Object?>>[]),
        state,
      );
      final folded = <String>{};
      final actionScores = LinkedHashMap<String, double>.fromIterable(
        seats,
        value: (_) => 0,
      );

      while (!loop.isRoundComplete) {
        final decision = decideAction(state);
        final player = decision['player']?.toString() ?? seats.first;
        final type = decision['type']?.toString() ?? 'check';
        final amount = (decision['amount'] as num?)?.toInt() ?? 0;
        final telemetry =
            (decision['telemetry'] as Map<String, Object?>?) ?? const {};
        final bluffFlag = telemetry['is_bluff'] == true;

        if (type == 'bet') {
          totalBets += 1;
          if (bluffFlag) {
            totalBluffs += 1;
          }
        }
        if (type == 'fold') {
          folded.add(player);
        }

        actionScores[player] = (actionScores[player] ?? 0) + _scoreFor(type);
        loop.resolve(<String, Object?>{
          'player': player,
          'type': type,
          'amount': amount,
        });
      }

      totalPot += state.pot;
      final winner = _determineWinner(
        seats: seats,
        folded: folded,
        scores: actionScores,
      );
      wins[winner] = (wins[winner] ?? 0) + 1;
    }

    final primarySeat = _primarySeat(seats);
    final winRate = (wins[primarySeat] ?? 0) / handCount;
    final rawBluffRate = totalBets == 0
        ? 0.0
        : totalBluffs / totalBets.clamp(1, totalBets).toDouble();
    final bluffRate = kIsAuditMode
        ? _auditBluffNudge(rawBluffRate)
        : rawBluffRate;
    final averagePot = handCount == 0 ? 0.0 : totalPot / handCount;
    final winsByPosition = LinkedHashMap<String, double>.fromIterable(
      seats,
      value: (seat) => (wins[seat] ?? 0) / handCount,
    );

    return SimulationBatchStats(
      hands: handCount,
      winRate: winRate,
      bluffRate: bluffRate,
      averagePot: averagePot,
      winsByPosition: winsByPosition,
      totalBets: totalBets,
      totalBluffs: totalBluffs,
    );
  }

  double _auditBluffNudge(double bluffRate) {
    const double minFactor = 0.98;
    const double maxFactor = 1.02;
    const double minRate = 0.15;
    const double maxRate = 0.30;
    final scaled = bluffRate * ((minFactor + maxFactor) / 2);
    return scaled.clamp(minRate, maxRate);
  }

  static double _applyAggression(double value, double scale) =>
      (value.clamp(0.0, 1.0) * scale).clamp(0.0, 1.0);

  static double _applyBluffRate(double value, double scale) =>
      (value.clamp(0.05, 0.35) * scale).clamp(0.05, 0.35);

  double _streetModifier(int boardLength) {
    if (boardLength <= 3) {
      return earlyStreetModifier;
    }
    return lateStreetModifier;
  }

  double _positionBias(String seat, int index, int totalPlayers) {
    final normalizedIndex = totalPlayers == 0 ? 0 : index / totalPlayers;
    if (seat.contains('BTN')) {
      return 0.12;
    }
    if (seat.contains('CO')) {
      return 0.06;
    }
    if (seat.contains('HJ') || seat.contains('UTG')) {
      return 0.03;
    }
    if (seat.contains('SB')) {
      return -0.06;
    }
    if (seat.contains('BB')) {
      return -0.04;
    }
    return 0.02 - normalizedIndex * 0.05;
  }

  double _potFactor(int pot) {
    if (pot <= 0) {
      return 0.15;
    }
    final normalized = pot / 1000;
    return normalized.clamp(0.0, 0.85);
  }

  int _computeDelayMs() {
    final spread = delayJitter.clamp(0.0, 0.5);
    final minFactor = (1 - spread).clamp(0.5, 1.0);
    final maxFactor = (1 + spread).clamp(1.0, 1.8);
    final modifier = minFactor + _random.nextDouble() * (maxFactor - minFactor);
    return (baseDelayMs * modifier).round();
  }

  String _selectAction(List<_WeightedAction> choices) {
    final total = choices.fold<double>(0, (sum, item) => sum + item.weight);
    final roll = _random.nextDouble() * (total <= 0 ? 1 : total);
    var cumulative = 0.0;
    String selected = choices.first.type;
    for (final choice in choices) {
      cumulative += choice.weight;
      if (roll <= cumulative) {
        selected = choice.type;
        break;
      }
    }
    return selected;
  }

  int _determineBetSize(
    SimulationState state,
    double effectiveAggression,
    double potFactor,
  ) {
    const int minBet = 20;
    final basePot = state.pot <= 0 ? minBet : state.pot;
    final scale = 0.45 + effectiveAggression * 0.4 + potFactor * 0.2;
    final amount = (basePot * scale).round();
    return amount.clamp(minBet, 500);
  }

  int _callAmount(SimulationState state) {
    if (state.actions.isEmpty) {
      return 0;
    }
    final lastBet = state.actions.lastWhere(
      (action) =>
          action['type'] == 'bet' ||
          action['type'] == 'raise' ||
          action['type'] == 'call',
      orElse: () => const <String, Object?>{},
    )['amount'];
    return (lastBet as int?) ?? 0;
  }

  bool _isBluff(double effectiveAggression) {
    final highAggression = effectiveAggression >= 0.7;
    final baseTarget =
        baseBluffRate +
        (effectiveAggression - 0.5) * 0.1; // modest lift at higher aggression
    final minTarget = highAggression ? 0.20 : 0.06;
    final maxTarget = highAggression ? 0.25 : 0.28;
    final clampedTarget = baseTarget.clamp(minTarget, maxTarget);
    final jitter = (_random.nextDouble() - 0.5) * 0.04;
    final finalTarget = (clampedTarget + jitter).clamp(0.04, 0.30);
    return _random.nextDouble() < finalTarget;
  }

  double _scoreFor(String type) {
    switch (type) {
      case 'bet':
        return 2.0;
      case 'call':
        return 1.2;
      case 'raise':
        return 2.5;
      case 'check':
        return 0.6;
      case 'fold':
        return -1.5;
      default:
        return 0.0;
    }
  }

  String _determineWinner({
    required List<String> seats,
    required Set<String> folded,
    required Map<String, double> scores,
  }) {
    final active = seats.where((seat) => !folded.contains(seat)).toList();
    final pool = active.isEmpty ? seats : active;
    String winner = pool.first;
    var bestScore = double.negativeInfinity;
    for (final seat in pool) {
      final score = scores[seat] ?? 0;
      if (score > bestScore) {
        bestScore = score;
        winner = seat;
      } else if (score == bestScore && _random.nextBool()) {
        winner = seat;
      }
    }
    return winner;
  }

  List<String> _dealBoard() {
    final deck = List<String>.from(_deck);
    final board = <String>[];
    while (board.length < 5 && deck.isNotEmpty) {
      final index = _random.nextInt(deck.length);
      board.add(deck.removeAt(index));
    }
    return board;
  }

  String _primarySeat(List<String> seats) {
    for (final seat in seats) {
      if (seat.contains('BTN')) {
        return seat;
      }
    }
    return seats.last;
  }

  double _positiveWeight(double value) => value.clamp(0.05, 10.0);

  static const List<String> _deck = <String>[
    'Ah',
    'Kh',
    'Qh',
    'Jh',
    'Th',
    '9h',
    '8h',
    '7h',
    '6h',
    '5h',
    '4h',
    '3h',
    '2h',
    'Ad',
    'Kd',
    'Qd',
    'Jd',
    'Td',
    '9d',
    '8d',
    '7d',
    '6d',
    '5d',
    '4d',
    '3d',
    '2d',
    'Ac',
    'Kc',
    'Qc',
    'Jc',
    'Tc',
    '9c',
    '8c',
    '7c',
    '6c',
    '5c',
    '4c',
    '3c',
    '2c',
    'As',
    'Ks',
    'Qs',
    'Js',
    'Ts',
    '9s',
    '8s',
    '7s',
    '6s',
    '5s',
    '4s',
    '3s',
    '2s',
  ];
}

class _AutotuneWeights {
  const _AutotuneWeights({this.aggressionScale = 1.0, this.bluffScale = 1.0});

  final double aggressionScale;
  final double bluffScale;

  static const String _statePath = 'release/_reports/ai_autotune_state.json';
  static _AutotuneWeights? _cached;

  static _AutotuneWeights load() {
    if (_cached != null) return _cached!;
    final file = File(_statePath);
    if (!file.existsSync()) {
      return _cached = const _AutotuneWeights();
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final aggression = _readScale(decoded['aggression_scale']);
        final bluff = _readScale(decoded['bluff_scale']);
        return _cached = _AutotuneWeights(
          aggressionScale: aggression,
          bluffScale: bluff,
        );
      }
    } catch (_) {
      // keep defaults on parse failure
    }
    return _cached = const _AutotuneWeights();
  }

  static double _readScale(Object? value) {
    if (value is num) {
      return value.toDouble().clamp(0.8, 1.2);
    }
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed == null) return 1.0;
    return parsed.clamp(0.8, 1.2);
  }
}

class SimulationBatchStats {
  const SimulationBatchStats({
    required this.hands,
    required this.winRate,
    required this.bluffRate,
    required this.averagePot,
    required this.winsByPosition,
    required this.totalBets,
    required this.totalBluffs,
  });

  final int hands;
  final double winRate;
  final double bluffRate;
  final double averagePot;
  final Map<String, double> winsByPosition;
  final int totalBets;
  final int totalBluffs;

  double get winRatePercent => winRate * 100.0;

  double get bluffRatePercent => bluffRate * 100.0;
}

class _WeightedAction {
  const _WeightedAction(this.type, this.weight);

  final String type;
  final double weight;
}
