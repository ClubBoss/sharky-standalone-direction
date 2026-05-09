import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/overlay_manager.dart';

final class PlayerProgressionService {
  PlayerProgressionService._();

  static final PlayerProgressionService instance = PlayerProgressionService._();

  static const String _statePath = 'tools/_reports/progression_state.json';
  static const int _baseXp = 1000;
  static const List<_LeagueThreshold> _leagueThresholds = <_LeagueThreshold>[
    _LeagueThreshold('Bronze', 0),
    _LeagueThreshold('Silver', 5000),
    _LeagueThreshold('Gold', 15000),
    _LeagueThreshold('Diamond', 35000),
    _LeagueThreshold('Elite', 60000),
  ];

  ProgressionState? _cachedState;

  // Broadcast stream for level-up events so UI can react without tight coupling.
  final StreamController<LevelUpEvent> _levelUpController =
      StreamController<LevelUpEvent>.broadcast();

  Stream<LevelUpEvent> get onLevelUp => _levelUpController.stream;

  ProgressionState get _state {
    _cachedState ??= _readState();
    return _cachedState!;
  }

  void applyReward({required int xp, required int chips}) {
    if (xp <= 0 && chips <= 0) {
      return;
    }

    final state = _state;
    final previousLevel = state.level;

    state.xpTotal += xp;
    state.chipTotal += chips;

    if (xp > 0) {
      state.streak += 1;
    } else {
      state.streak = 0;
    }

    _applyLevelUps(state);
    state.leagueTier = _determineLeague(state.xpTotal);

    _writeState(state);

    if (state.level > previousLevel) {
      _emitLevelUp(state.level, state.xpTotal, state.nextLevelXp, state.streak);
    }
  }

  ProgressionState snapshot() {
    final current = _state;
    return current.copy();
  }

  void reset() {
    final state = ProgressionState.initial();
    _cachedState = state;
    _writeState(state);
  }

  void _applyLevelUps(ProgressionState state) {
    while (state.xpTotal >= state.nextLevelXp) {
      state.level += 1;
      final increment = _xpIncrementForLevel(state.level);
      state.nextLevelXp += increment;
    }
  }

  static int _xpIncrementForLevel(int level) {
    final value = _baseXp * pow(1.15, (level - 1));
    return value.round();
  }

  String _determineLeague(int xpTotal) {
    var league = _leagueThresholds.first.name;
    for (final threshold in _leagueThresholds) {
      if (xpTotal >= threshold.xp) {
        league = threshold.name;
      } else {
        break;
      }
    }
    return league;
  }

  ProgressionState _readState() {
    final file = File(_statePath);
    if (!file.existsSync()) {
      final initial = ProgressionState.initial();
      _writeState(initial);
      return initial;
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        return ProgressionState.fromJson(decoded);
      }
    } catch (error) {
      stderr.writeln(
        '[WARN] PlayerProgressionService failed to read state: $error',
      );
    }
    final fallback = ProgressionState.initial();
    _writeState(fallback);
    return fallback;
  }

  void _writeState(ProgressionState state) {
    final file = File(_statePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(state.toJson()),
    );
  }

  void _emitLevelUp(int level, int xpTotal, int nextLevelXp, int streak) {
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'player_leveled_up',
        params: <String, Object>{
          'level': level,
          'xp_total': xpTotal,
          'next_level_xp': nextLevelXp,
          'streak': streak,
        },
      ),
    );
    unawaited(
      OverlayManager.instance.show(OverlayType.levelUp, <String, Object?>{
        'level': level,
        'xp_total': xpTotal,
        'streak': streak,
      }),
    );
    // Notify UI listeners; non-blocking.
    _levelUpController.add(
      LevelUpEvent(
        level: level,
        xpTotal: xpTotal,
        nextLevelXp: nextLevelXp,
        streak: streak,
      ),
    );
  }
}

class ProgressionState {
  ProgressionState({
    required this.level,
    required this.xpTotal,
    required this.nextLevelXp,
    required this.chipTotal,
    required this.leagueTier,
    required this.streak,
  });

  int level;
  int xpTotal;
  int nextLevelXp;
  int chipTotal;
  String leagueTier;
  int streak;

  factory ProgressionState.initial() {
    return ProgressionState(
      level: 1,
      xpTotal: 0,
      nextLevelXp: PlayerProgressionService._xpIncrementForLevel(1),
      chipTotal: 0,
      leagueTier: 'Bronze',
      streak: 0,
    );
  }

  factory ProgressionState.fromJson(Map<String, dynamic> json) {
    return ProgressionState(
      level: (json['level'] as num?)?.toInt() ?? 1,
      xpTotal: (json['xp_total'] as num?)?.toInt() ?? 0,
      nextLevelXp:
          (json['next_level_xp'] as num?)?.toInt() ??
          PlayerProgressionService._xpIncrementForLevel(1),
      chipTotal: (json['chip_total'] as num?)?.toInt() ?? 0,
      leagueTier: json['league_tier']?.toString() ?? 'Bronze',
      streak: (json['streak'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object> toJson() {
    return <String, Object>{
      'level': level,
      'xp_total': xpTotal,
      'next_level_xp': nextLevelXp,
      'chip_total': chipTotal,
      'league_tier': leagueTier,
      'streak': streak,
    };
  }

  ProgressionState copy() {
    return ProgressionState(
      level: level,
      xpTotal: xpTotal,
      nextLevelXp: nextLevelXp,
      chipTotal: chipTotal,
      leagueTier: leagueTier,
      streak: streak,
    );
  }
}

class _LeagueThreshold {
  const _LeagueThreshold(this.name, this.xp);

  final String name;
  final int xp;
}

/// Value object for level-up UI events.
final class LevelUpEvent {
  const LevelUpEvent({
    required this.level,
    required this.xpTotal,
    required this.nextLevelXp,
    required this.streak,
  });

  final int level;
  final int xpTotal;
  final int nextLevelXp;
  final int streak;
}
