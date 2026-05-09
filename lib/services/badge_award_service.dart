import 'package:shared_preferences/shared_preferences.dart';

import '../infra/telemetry.dart';

enum BadgeType { streak7, streak30, challenge10, league_promo, season_champion }

class BadgeAwardService {
  BadgeAwardService._();
  static final BadgeAwardService instance = BadgeAwardService._();

  static const _prefsKey = 'awarded_badges';

  Future<List<BadgeType>> getAllBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? const <String>[];
    return stored
        .map(
          (name) => BadgeType.values.firstWhere(
            (b) => b.name == name,
            orElse: () => BadgeType.streak7,
          ),
        )
        .toList();
  }

  Future<void> grantBadge(BadgeType type) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? <String>[];
    if (stored.contains(type.name)) return;
    stored.add(type.name);
    await prefs.setStringList(_prefsKey, stored);
    await Telemetry.logEvent('badge_awarded', {'type': type.name});
  }
}
