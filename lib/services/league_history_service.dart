import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/xp_league.dart';

const _storageKey = 'league_history_records';

class LeaguePromotionRecord {
  final String leagueId;
  final DateTime promotedAt;

  const LeaguePromotionRecord({
    required this.leagueId,
    required this.promotedAt,
  });

  XpLeague? get league {
    try {
      return XpLeague.values.firstWhere((value) => value.name == leagueId);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'leagueId': leagueId,
    'promotedAt': promotedAt.toUtc().toIso8601String(),
  };

  static LeaguePromotionRecord? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['leagueId'] as String?;
    final stamped = json['promotedAt'] as String?;
    if (id == null || stamped == null) return null;
    final parsed = DateTime.tryParse(stamped);
    if (parsed == null) return null;
    return LeaguePromotionRecord(leagueId: id, promotedAt: parsed.toUtc());
  }
}

class LeagueHistoryService {
  LeagueHistoryService._();

  static final LeagueHistoryService instance = LeagueHistoryService._();

  List<LeaguePromotionRecord>? _cache;

  Future<void> recordPromotion(XpLeague league, DateTime timestamp) async {
    final history = await getHistory();
    final updated = [
      ...history,
      LeaguePromotionRecord(
        leagueId: league.name,
        promotedAt: timestamp.toUtc(),
      ),
    ];
    await _persist(updated);
    _cache = updated;
  }

  Future<List<LeaguePromotionRecord>> getHistory() async {
    if (_cache != null) {
      return List.unmodifiable(_cache!);
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _cache = const [];
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        _cache = const [];
        return const [];
      }
      final records = decoded
          .map(
            (item) =>
                LeaguePromotionRecord.fromJson(item as Map<String, dynamic>?),
          )
          .whereType<LeaguePromotionRecord>()
          .toList();
      records.sort((a, b) => a.promotedAt.compareTo(b.promotedAt));
      _cache = records;
      return List.unmodifiable(records);
    } catch (_) {
      _cache = const [];
      return const [];
    }
  }

  Future<LeaguePromotionRecord?> getLastPromotion() async {
    final history = await getHistory();
    if (history.isEmpty) return null;
    return history.last;
  }

  Future<void> _persist(List<LeaguePromotionRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      records.map((record) => record.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  @visibleForTesting
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _cache = null;
  }
}
