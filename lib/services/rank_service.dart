import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_rank.dart';

/// Service that computes and tracks user rank based on total XP.
/// Exposes a ValueNotifier for UI reactivity and persists rank changes.
class RankService {
  /// Singleton instance for app-wide access.
  static final RankService instance = RankService._();

  RankService._();

  static const String _rankKey = 'user_rank';

  /// Current user rank (reactive).
  final ValueNotifier<UserRank> notifier = ValueNotifier<UserRank>(
    UserRank.bronze,
  );

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Initialize service: load persisted rank from storage.
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();

    final rankName = _prefs?.getString(_rankKey);
    if (rankName != null) {
      try {
        final rank = UserRank.values.firstWhere((r) => r.name == rankName);
        notifier.value = rank;
      } catch (_) {
        // Invalid rank name, default to bronze
        notifier.value = UserRank.bronze;
      }
    }
    _initialized = true;
  }

  /// Update rank based on current total XP.
  /// Returns true if rank changed (for achievement/notification logic).
  Future<bool> updateRank(int totalXp) async {
    await init();
    final newRank = userRankFromXp(totalXp);
    final changed = newRank != notifier.value;
    if (changed) {
      notifier.value = newRank;
      await _persist();
    }
    return changed;
  }

  /// Get current rank (non-reactive).
  UserRank get currentRank => notifier.value;

  /// Persist current rank to SharedPreferences.
  Future<void> _persist() async {
    await _prefs?.setString(_rankKey, notifier.value.name);
  }

  /// For testing: reset rank to bronze.
  Future<void> reset() async {
    await init();
    notifier.value = UserRank.bronze;
    await _persist();
  }
}
