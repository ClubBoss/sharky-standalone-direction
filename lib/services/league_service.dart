import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../infra/telemetry.dart';
import 'beta_playtest_service.dart';

enum LeagueTier { Bronze, Silver, Gold, Platinum, Diamond }

class LeagueService {
  LeagueService._();
  static final LeagueService instance = LeagueService._();

  static const _prefsKey = 'league_tier';
  static const _xpThresholds = <int>[0, 500, 1500, 3000, 6000];
  static const _metricsPath = 'league_fx_metrics.json';

  final List<void Function(LeagueTier from, LeagueTier to)> _listeners = [];

  LeagueTier getLeagueForXp(int xp) {
    if (xp >= _xpThresholds[4]) return LeagueTier.Diamond;
    if (xp >= _xpThresholds[3]) return LeagueTier.Platinum;
    if (xp >= _xpThresholds[2]) return LeagueTier.Gold;
    if (xp >= _xpThresholds[1]) return LeagueTier.Silver;
    return LeagueTier.Bronze;
  }

  Future<LeagueTier> evaluateLeague(double momentum) async {
    final prefs = await SharedPreferences.getInstance();
    final current = _decode(prefs.getString(_prefsKey));
    final promoted = momentum > 0.7 ? _promote(current) : current;
    if (promoted != current) {
      await prefs.setString(_prefsKey, promoted.name);
      unawaited(
        BetaPlaytestService.logEvent(
          'league',
          'promotion',
          details: {'from': current.name, 'to': promoted.name},
        ),
      );
      await Telemetry.logEvent('league_promotion', {'tier': promoted.name});
      await _appendFxMetrics(from: current, to: promoted);
      for (final listener in List.unmodifiable(_listeners)) {
        listener(current, promoted);
      }
      return promoted;
    }
    if (prefs.getString(_prefsKey) == null) {
      await prefs.setString(_prefsKey, current.name);
    }
    return current;
  }

  LeagueTier _decode(String? value) {
    return LeagueTier.values.firstWhere(
      (t) => t.name == value,
      orElse: () => LeagueTier.Bronze,
    );
  }

  LeagueTier _promote(LeagueTier tier) {
    switch (tier) {
      case LeagueTier.Bronze:
        return LeagueTier.Silver;
      case LeagueTier.Silver:
        return LeagueTier.Gold;
      case LeagueTier.Gold:
        return LeagueTier.Platinum;
      case LeagueTier.Platinum:
        return LeagueTier.Diamond;
      case LeagueTier.Diamond:
        return LeagueTier.Diamond;
    }
  }

  void addTierChangeListener(void Function(LeagueTier from, LeagueTier to) cb) {
    _listeners.add(cb);
  }

  void removeTierChangeListener(
    void Function(LeagueTier from, LeagueTier to) cb,
  ) {
    _listeners.remove(cb);
  }

  Future<void> _appendFxMetrics({
    required LeagueTier from,
    required LeagueTier to,
  }) async {
    Map<String, dynamic> data = {};
    final file = File(_metricsPath);
    if (await file.exists()) {
      try {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {}
    }
    final promotions = (data['promotions'] as num?)?.toInt() ?? 0;
    data['promotions'] = promotions + 1;
    data['last_from'] = from.name;
    data['last_to'] = to.name;
    data['updated_at'] = DateTime.now().toIso8601String();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }
}
