import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Types of XP boosters available.
enum BoosterType {
  study, // For theory/solver sessions
  play, // For cash/MTT/live sessions
  review, // For review sessions
}

/// Represents an active booster with expiry time.
class ActiveBooster {
  final BoosterType type;
  final DateTime activatedAt;
  final DateTime expiresAt;

  const ActiveBooster({
    required this.type,
    required this.activatedAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'activatedAt': activatedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory ActiveBooster.fromJson(Map<String, dynamic> json) => ActiveBooster(
    type: BoosterType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => BoosterType.study,
    ),
    activatedAt: DateTime.parse(json['activatedAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }
}

/// Service to manage temporary XP boosters.
///
/// Boosters provide 2x XP multiplier for specific session types
/// and last for a limited duration (default 15 minutes).
class BoosterService {
  static final BoosterService instance = BoosterService._();
  BoosterService._();

  /// Returns the singleton instance.
  static BoosterService getInstance() => instance;

  static const String _prefsKey = 'active_booster_v1';
  static const int _defaultDurationMinutes = 15;
  static const double _multiplier = 2.0;

  SharedPreferences? _prefs;

  /// Initialize the service by loading SharedPreferences.
  Future<void> init() async {
    await _ensurePrefs();
  }

  Future<void> _ensurePrefs() async {
    // Always fetch current instance to cooperate with SharedPreferences.setMockInitialValues in tests
    _prefs = await SharedPreferences.getInstance();
  }

  /// Activate a booster of the specified type.
  /// Duration defaults to 15 minutes but can be customized.
  Future<void> activate(BoosterType type, {Duration? duration}) async {
    await _ensurePrefs();

    final now = DateTime.now();
    final booster = ActiveBooster(
      type: type,
      activatedAt: now,
      expiresAt: now.add(
        duration ?? const Duration(minutes: _defaultDurationMinutes),
      ),
    );

    await _prefs?.setString(_prefsKey, jsonEncode(booster.toJson()));
  }

  /// Get the currently active booster, or null if none/expired.
  Future<ActiveBooster?> getActive() async {
    await _ensurePrefs();
    await clearExpired(); // Clean up expired boosters

    final raw = _prefs?.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final booster = ActiveBooster.fromJson(decoded);
      return booster.isExpired ? null : booster;
    } catch (_) {
      return null;
    }
  }

  /// Check if any booster is currently active.
  Future<bool> isActive() async {
    final booster = await getActive();
    return booster != null;
  }

  /// Remove expired boosters from storage.
  Future<void> clearExpired() async {
    await _ensurePrefs();

    final raw = _prefs?.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final booster = ActiveBooster.fromJson(decoded);

      if (booster.isExpired) {
        await _prefs?.remove(_prefsKey);
      }
    } catch (_) {
      // Invalid data, clear it
      await _prefs?.remove(_prefsKey);
    }
  }

  /// Get the XP multiplier (2.0 for active booster).
  double get multiplier => _multiplier;

  /// Check if a booster matches the given session tags.
  /// Returns true if the booster type aligns with the session tags.
  bool matchesTags(BoosterType type, List<String> tags) {
    final normalized = tags.map((t) => t.toLowerCase()).toList();

    switch (type) {
      case BoosterType.study:
        return normalized.any((t) => ['study', 'theory', 'solver'].contains(t));
      case BoosterType.play:
        return normalized.any(
          (t) => ['play', 'cash', 'mtt', 'live'].contains(t),
        );
      case BoosterType.review:
        return normalized.contains('review');
    }
  }

  /// For testing: reset all boosters.
  Future<void> reset() async {
    await _ensurePrefs();
    await _prefs?.remove(_prefsKey);
  }
}
