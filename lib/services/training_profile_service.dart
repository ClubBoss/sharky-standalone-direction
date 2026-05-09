import 'package:shared_preferences/shared_preferences.dart';
import '../models/training_profile.dart';
import 'session_log_service.dart';
import 'xp_service.dart';
import 'streak_tracker_service.dart';

/// Service to compute and cache training profile based on user behavior.
class TrainingProfileService {
  TrainingProfileService._();
  static final TrainingProfileService instance = TrainingProfileService._();

  static const String _cacheKey = 'training_profile_cached';
  static const String _cacheDateKey = 'training_profile_date';

  TrainingProfileType? _cachedProfile;
  DateTime? _cacheDate;

  /// Get current profile (cached if computed today, otherwise recompute).
  Future<TrainingProfileType> currentProfile() async {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    // Check cache
    if (_cachedProfile != null && _cacheDate != null) {
      if (_cacheDate!.isAtSameMomentAs(todayKey)) {
        return _cachedProfile!;
      }
    }

    // Load from storage
    final prefs = await SharedPreferences.getInstance();
    final cachedType = prefs.getString(_cacheKey);
    final cachedDateMs = prefs.getInt(_cacheDateKey);

    if (cachedType != null && cachedDateMs != null) {
      final storedDate = DateTime.fromMillisecondsSinceEpoch(cachedDateMs);
      if (DateTime(
        storedDate.year,
        storedDate.month,
        storedDate.day,
      ).isAtSameMomentAs(todayKey)) {
        _cachedProfile = TrainingProfileType.values.firstWhere(
          (t) => t.toString() == cachedType,
          orElse: () => TrainingProfileType.explorer,
        );
        _cacheDate = todayKey;
        return _cachedProfile!;
      }
    }

    // Recompute
    final computed = await _computeProfile();
    _cachedProfile = computed;
    _cacheDate = todayKey;

    // Save to storage
    await prefs.setString(_cacheKey, computed.toString());
    await prefs.setInt(_cacheDateKey, todayKey.millisecondsSinceEpoch);

    return computed;
  }

  /// Explain current profile with reasoning (for debugging/display).
  Future<String> explain({required bool isRu}) async {
    final profile = await currentProfile();
    final metadata = TrainingProfile.fromType(profile);
    final label = isRu ? 'Ваш профиль' : 'Your profile';
    return '$label: ${metadata.title(isRu: isRu)}';
  }

  /// Force recompute (e.g., after major behavior change).
  Future<TrainingProfileType> recompute() async {
    _cachedProfile = null;
    _cacheDate = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheDateKey);
    return currentProfile();
  }

  /// Compute profile based on behavior heuristics.
  Future<TrainingProfileType> _computeProfile() async {
    try {
      // Gather data
      final sessions = await SessionLogService.instance.getLogs();
      final xpService = XpService();
      await xpService.initialize();
      final totalXp = xpService.getTotalXp();
      final streakStats = await StreakTrackerService().compute();
      final currentStreak = streakStats.currentStreak;

      // Analyze tags
      final tagCounts = <String, int>{};
      for (final session in sessions) {
        for (final tag in session.tags) {
          final normalized = tag.toLowerCase();
          tagCounts[normalized] = (tagCounts[normalized] ?? 0) + 1;
        }
      }

      // Count session tags by type
      int playCount = 0; // play/cash/mtt/live
      int studyCount = 0; // study/theory/review
      int solverCount = 0; // solver/gto
      for (final session in sessions) {
        final lowerTags = session.tags.map((t) => t.toLowerCase()).toList();
        if (lowerTags.any((t) => ['play', 'cash', 'mtt', 'live'].contains(t))) {
          playCount++;
        }
        if (lowerTags.any((t) => ['study', 'theory', 'review'].contains(t))) {
          studyCount++;
        }
        if (lowerTags.any((t) => ['solver', 'gto'].contains(t))) {
          solverCount++;
        }
      }

      final totalSessions = sessions.length;
      final hasHighStreak = currentStreak >= 7;
      final hasHighVolume = totalXp >= 500;

      // Heuristic rules
      if (solverCount > 5 ||
          (solverCount > 0 && solverCount >= totalSessions * 0.3)) {
        return TrainingProfileType.gtoFan;
      }
      if (studyCount > 10 ||
          (studyCount > 0 && studyCount >= totalSessions * 0.4)) {
        return TrainingProfileType.theorist;
      }
      if (playCount > 10 ||
          (playCount > 0 && playCount >= totalSessions * 0.5)) {
        return TrainingProfileType.gambler;
      }
      if (hasHighStreak && hasHighVolume) {
        return TrainingProfileType.grinder;
      }
      if (tagCounts.length >= 3 && totalSessions >= 5) {
        return TrainingProfileType.explorer;
      }

      // Default fallback
      if (totalSessions > 3 && hasHighVolume) {
        return TrainingProfileType.grinder;
      }
      return TrainingProfileType.explorer;
    } catch (_) {
      return TrainingProfileType.explorer; // Safe default
    }
  }
}
