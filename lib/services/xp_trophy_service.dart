import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/xp_trophy.dart';
import '../widgets/booster_activation_popup.dart';
import 'booster_service.dart';

/// In-memory XP trophy unlock and export system.
class XpTrophyService {
  /// Singleton instance for app-wide access.
  static final XpTrophyService instance = XpTrophyService();

  /// Notifier to allow widgets to react to unlock changes.
  final ValueNotifier<Set<XpTrophyEntry>> notifier =
      ValueNotifier<Set<XpTrophyEntry>>(<XpTrophyEntry>{});

  static const String _prefsKey = 'xp_trophies';
  final Set<XpTrophyEntry> _unlocked = <XpTrophyEntry>{};
  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Unlocks a trophy if not already unlocked.
  /// Sets achievedAt to current UTC time and persists immediately.
  void unlock(XpTrophy trophy) {
    if (has(trophy)) return;
    final wasEmpty = _unlocked.isEmpty;
    _unlocked.add(
      XpTrophyEntry(type: trophy, achievedAt: DateTime.now().toUtc()),
    );
    // update notifier immediately so UI reflects change
    notifier.value = Set.unmodifiable(_unlocked);
    save();

    // Offer a booster on the very first trophy unlock
    if (wasEmpty) {
      unawaited(
        BoosterActivationPopup.show(
          type: BoosterType.review,
          source: BoosterRewardSource.trophy,
        ),
      );
    }
  }

  /// Returns true if the trophy is unlocked.
  bool has(XpTrophy trophy) => _unlocked.any((e) => e.type == trophy);

  /// Serializes all unlocked trophies to JSON.
  Map<String, dynamic> toJson() => {
    'entries': _unlocked.map((e) => e.toJson()).toList(),
  };

  /// Loads unlocked trophies from JSON.
  void fromJson(Map<String, dynamic> json) {
    _unlocked.clear();
    final entries = json['entries'] as List<dynamic>?;
    if (entries != null) {
      for (final entry in entries) {
        _unlocked.add(XpTrophyEntry.fromJson(entry as Map<String, dynamic>));
      }
    }
    // push to notifier after loading
    notifier.value = Set.unmodifiable(_unlocked);
  }

  /// Resets all unlocked trophies (for testing/dev) and persists immediately.
  void reset() {
    _unlocked.clear();
    notifier.value = Set.unmodifiable(_unlocked);
    save();
  }

  /// Returns all unlocked entries (read-only).
  Set<XpTrophyEntry> get unlocked => Set.unmodifiable(_unlocked);

  /// Loads trophies from SharedPreferences (call before use).
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        fromJson(decoded);
      } catch (_) {
        // Ignore parse errors, start fresh
        _unlocked.clear();
      }
    }
    // ensure notifier is primed
    notifier.value = Set.unmodifiable(_unlocked);
    _initialized = true;
  }

  /// Saves current unlocked trophies to SharedPreferences.
  void save() {
    if (_prefs == null) return;
    final encoded = jsonEncode(toJson());
    _prefs!.setString(_prefsKey, encoded);
  }

  /// For testing: allow injection of mock SharedPreferences.
  void setPrefs(SharedPreferences prefs) {
    _prefs = prefs;
  }
}
