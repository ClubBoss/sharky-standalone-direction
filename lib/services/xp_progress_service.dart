import 'package:shared_preferences/shared_preferences.dart';
import '../infra/telemetry.dart';

/// Service for tracking player XP, level, and achievements.
/// Integrates with telemetry for progress events.
class XpProgressService {
  XpProgressService._();
  static final instance = XpProgressService._();

  static const _keyXpTotal = 'player_xp_total';
  static const _keyLevel = 'player_level';
  static const _keyAchievements = 'player_achievements';
  static const int xpPerLevel = 1000;

  int _xpTotal = 0;
  int _level = 1;
  final Set<String> _achievements = {};

  int get xpTotal => _xpTotal;
  int get level => _level;
  int get achievementsCount => _achievements.length;
  Set<String> get achievements => Set.unmodifiable(_achievements);

  /// Load player progress from SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _xpTotal = prefs.getInt(_keyXpTotal) ?? 0;
    _level = prefs.getInt(_keyLevel) ?? 1;
    final achList = prefs.getStringList(_keyAchievements) ?? [];
    _achievements.addAll(achList);
  }

  /// Add XP and auto-level if threshold reached.
  /// Emits player_xp_gain telemetry event.
  Future<void> addXp(int amount) async {
    if (amount <= 0) return;
    _xpTotal += amount;
    final newLevel = (_xpTotal ~/ xpPerLevel) + 1;
    final leveledUp = newLevel > _level;
    _level = newLevel;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyXpTotal, _xpTotal);
    await prefs.setInt(_keyLevel, _level);

    // Emit telemetry event
    await Telemetry.logEvent('player_xp_gain', {
      'amount': amount,
      'total_xp': _xpTotal,
      'level': _level,
      'leveled_up': leveledUp,
    });
  }

  /// Log an achievement unlock.
  /// Emits achievement_unlocked telemetry event if not already unlocked.
  Future<void> logAchievement(String id, String title) async {
    if (_achievements.contains(id)) return;
    _achievements.add(id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyAchievements, _achievements.toList());

    // Emit telemetry event
    await Telemetry.logEvent('achievement_unlocked', {
      'achievement_id': id,
      'achievement_title': title,
      'total_achievements': _achievements.length,
    });
  }

  /// Get current XP progress within current level (0-999).
  int get xpInCurrentLevel => _xpTotal % xpPerLevel;

  /// Get XP needed for next level.
  int get xpForNextLevel => xpPerLevel - xpInCurrentLevel;
}
