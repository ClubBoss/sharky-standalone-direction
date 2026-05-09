import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Medal tier based on XP efficiency (XP per minute)
enum SessionMedalTier {
  bronze, // ≥2.0 XP/min
  silver, // ≥3.0 XP/min
  gold, // ≥4.0 XP/min
}

extension SessionMedalTierExt on SessionMedalTier {
  /// Minimum XP per minute threshold for this tier
  double get minXpPerMinute {
    switch (this) {
      case SessionMedalTier.bronze:
        return 2.0;
      case SessionMedalTier.silver:
        return 3.0;
      case SessionMedalTier.gold:
        return 4.0;
    }
  }

  /// Display name in English
  String get nameEn {
    switch (this) {
      case SessionMedalTier.bronze:
        return 'Bronze';
      case SessionMedalTier.silver:
        return 'Silver';
      case SessionMedalTier.gold:
        return 'Gold';
    }
  }

  /// Display name in Russian
  String get nameRu {
    switch (this) {
      case SessionMedalTier.bronze:
        return 'Бронза';
      case SessionMedalTier.silver:
        return 'Серебро';
      case SessionMedalTier.gold:
        return 'Золото';
    }
  }

  /// Display name based on locale
  String name({required bool isRu}) => isRu ? nameRu : nameEn;
}

/// Represents a single session medal award
class SessionMedalAward {
  final SessionMedalTier tier;
  final DateTime awardedAt;
  final int sessionXp;
  final int durationMinutes;
  final double xpPerMinute;

  const SessionMedalAward({
    required this.tier,
    required this.awardedAt,
    required this.sessionXp,
    required this.durationMinutes,
    required this.xpPerMinute,
  });

  Map<String, dynamic> toJson() => {
    'tier': tier
        .toString()
        .split('.')
        .last, // Use toString to get 'bronze', 'silver', 'gold'
    'awardedAt': awardedAt.toIso8601String(),
    'sessionXp': sessionXp,
    'durationMinutes': durationMinutes,
    'xpPerMinute': xpPerMinute,
  };

  factory SessionMedalAward.fromJson(Map<String, dynamic> json) {
    final tierStr = json['tier'] as String;
    return SessionMedalAward(
      tier: SessionMedalTier.values.firstWhere(
        (t) => t.toString().split('.').last == tierStr,
        orElse: () => SessionMedalTier.bronze,
      ),
      awardedAt: DateTime.parse(json['awardedAt'] as String),
      sessionXp: json['sessionXp'] as int,
      durationMinutes: json['durationMinutes'] as int,
      xpPerMinute: (json['xpPerMinute'] as num).toDouble(),
    );
  }
}

/// Service for tracking and awarding session medals based on XP efficiency
class SessionMedalService {
  static final SessionMedalService instance = SessionMedalService._();
  SessionMedalService._();

  static const String _storageKey = 'session_medals_v1';
  static const int _maxHistory = 30; // Keep last 30 medals

  /// Evaluates a session and returns a medal tier if earned, null otherwise
  SessionMedalTier? evaluateSession({
    required int sessionXp,
    required int durationMinutes,
  }) {
    if (durationMinutes <= 0) return null;

    final xpPerMinute = sessionXp / durationMinutes;

    // Check tiers from highest to lowest
    if (xpPerMinute >= SessionMedalTier.gold.minXpPerMinute) {
      return SessionMedalTier.gold;
    } else if (xpPerMinute >= SessionMedalTier.silver.minXpPerMinute) {
      return SessionMedalTier.silver;
    } else if (xpPerMinute >= SessionMedalTier.bronze.minXpPerMinute) {
      return SessionMedalTier.bronze;
    }

    return null;
  }

  /// Awards a medal and persists it to history
  Future<SessionMedalAward?> awardMedal({
    required int sessionXp,
    required int durationMinutes,
  }) async {
    final tier = evaluateSession(
      sessionXp: sessionXp,
      durationMinutes: durationMinutes,
    );

    if (tier == null) return null;

    final award = SessionMedalAward(
      tier: tier,
      awardedAt: DateTime.now(),
      sessionXp: sessionXp,
      durationMinutes: durationMinutes,
      xpPerMinute: sessionXp / durationMinutes,
    );

    await _persistAward(award);
    return award;
  }

  /// Retrieves medal history
  Future<List<SessionMedalAward>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => SessionMedalAward.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Retrieves medals earned in the last 7 days
  Future<List<SessionMedalAward>> getRecentMedals({int days = 7}) async {
    final history = await getHistory();
    final cutoff = DateTime.now().subtract(Duration(days: days));

    return history.where((award) => award.awardedAt.isAfter(cutoff)).toList();
  }

  /// Counts medals by tier in the last 7 days
  Future<Map<SessionMedalTier, int>> getMedalCounts({int days = 7}) async {
    final recent = await getRecentMedals(days: days);

    final counts = <SessionMedalTier, int>{
      SessionMedalTier.bronze: 0,
      SessionMedalTier.silver: 0,
      SessionMedalTier.gold: 0,
    };

    for (final award in recent) {
      counts[award.tier] = (counts[award.tier] ?? 0) + 1;
    }

    return counts;
  }

  /// Clears all medal history (for testing)
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _persistAward(SessionMedalAward award) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    history.add(award);

    // Keep only the last _maxHistory medals
    if (history.length > _maxHistory) {
      history.removeRange(0, history.length - _maxHistory);
    }

    final encoded = jsonEncode(history.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
