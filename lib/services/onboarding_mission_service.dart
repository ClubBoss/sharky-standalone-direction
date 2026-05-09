import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'xp_trophy_service.dart';
import 'xp_service.dart';
import '../models/xp_trophy.dart';

/// Tracks onboarding mission progress for new users.
///
/// Five intro quests:
/// 1. Open first training module
/// 2. Complete a drill
/// 3. Finish a session
/// 4. View profile
/// 5. Earn first trophy
///
/// Progress persisted in SharedPreferences. Awards XP + trophy on completion.
class OnboardingMissionService {
  static final OnboardingMissionService instance = OnboardingMissionService._();
  OnboardingMissionService._();

  static const String _prefsKey = 'onboarding_missions_v1';

  SharedPreferences? _prefs;
  bool _initialized = false;

  final Map<String, bool> _missions = {
    'moduleOpened': false,
    'drillCompleted': false,
    'sessionFinished': false,
    'profileViewed': false,
    'trophyEarned': false,
  };

  /// Initialize service and load progress from SharedPreferences.
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    await _load();
    _initialized = true;
  }

  /// Load missions from SharedPreferences.
  Future<void> _load() async {
    final raw = _prefs?.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final key in _missions.keys) {
        if (decoded.containsKey(key)) {
          _missions[key] = decoded[key] as bool;
        }
      }
    } catch (_) {
      // Ignore parse errors, start fresh
    }
  }

  /// Save missions to SharedPreferences.
  Future<void> _save() async {
    if (_prefs == null) return;
    final encoded = jsonEncode(_missions);
    await _prefs!.setString(_prefsKey, encoded);
  }

  /// Mark a mission as completed.
  Future<void> completeMission(String missionKey) async {
    if (!_missions.containsKey(missionKey)) return;
    if (_missions[missionKey] == true) return; // Already completed

    _missions[missionKey] = true;
    await _save();

    // Check if all missions are now completed
    if (isCompleted()) {
      await _awardCompletion();
    }
  }

  /// Award trophy and XP when all missions are completed.
  Future<void> _awardCompletion() async {
    final trophyService = XpTrophyService.instance;
    await trophyService.init();

    // Award trophy if not already unlocked
    if (!trophyService.has(XpTrophy.introComplete)) {
      trophyService.unlock(XpTrophy.introComplete);
    }

    // Award 20 XP
    final xpService = XpService();
    await xpService.initialize();
    await xpService.awardChallengeXp('onboarding_complete', 20);
  }

  /// Check if a specific mission is completed.
  bool isMissionCompleted(String missionKey) => _missions[missionKey] ?? false;

  /// Get current progress (0-5).
  int getProgress() => _missions.values.where((completed) => completed).length;

  /// Check if all missions are completed.
  bool isCompleted() => getProgress() == _missions.length;

  /// Get total number of missions.
  int getTotalMissions() => _missions.length;

  /// Get map of all mission states.
  Map<String, bool> getAllMissions() => Map.unmodifiable(_missions);

  /// Reset all missions (for testing/debugging).
  Future<void> reset() async {
    for (final key in _missions.keys) {
      _missions[key] = false;
    }
    await _save();
  }

  /// For testing: allow injection of mock SharedPreferences.
  void setPrefs(SharedPreferences prefs) {
    _prefs = prefs;
  }
}
