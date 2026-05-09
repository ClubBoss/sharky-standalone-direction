import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mistake.dart';
import '../models/session_log.dart';
import '../models/v2/training_pack_spot.dart';
import '../models/training_result.dart';
import 'xp_service.dart';
import 'cloud_sync_service.dart';
import 'smart_recommender_engine.dart' show UserProgress;
import 'nudge_scheduler_service.dart';

const _sessionLogStorageKey = 'session_logs_v1';
const _activeSessionKey = 'session_active_start_v1';
const _legacyLogStorageKey = 'session_logs_v2_legacy';

@immutable
class SessionLogEntry {
  final DateTime startTime;
  final int durationMinutes;
  final String? location;
  final int xpEarned;
  final List<String> tags;
  final String? notes;

  const SessionLogEntry({
    required this.startTime,
    required this.durationMinutes,
    this.location,
    required this.xpEarned,
    this.tags = const [],
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toUtc().toIso8601String(),
    'durationMinutes': durationMinutes,
    if (location != null && location!.isNotEmpty) 'location': location,
    'xpEarned': xpEarned,
    if (tags.isNotEmpty) 'tags': tags,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  static SessionLogEntry? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final start = json['startTime'] as String?;
    final duration = json['durationMinutes'] as int?;
    final xp = json['xpEarned'] as int?;
    final tags = (json['tags'] as List?)?.cast<String>() ?? const [];
    final notes = json['notes'] as String?;
    if (start == null || duration == null || xp == null) {
      return null;
    }
    final parsed = DateTime.tryParse(start);
    if (parsed == null) return null;
    return SessionLogEntry(
      startTime: parsed.toUtc(),
      durationMinutes: duration,
      location: json['location'] as String?,
      xpEarned: xp,
      tags: tags,
      notes: notes,
    );
  }
}

class StageHistoryPoint {
  final DateTime date;
  final double accuracy;

  const StageHistoryPoint({required this.date, required this.accuracy});
}

class StageStats {
  final int handsPlayed;
  final double accuracy;
  final DateTime? lastSession;

  const StageStats({this.handsPlayed = 0, this.accuracy = 0, this.lastSession});
}

class StageStatsWithHistory extends StageStats {
  final List<StageHistoryPoint> history;

  const StageStatsWithHistory({
    int handsPlayed = 0,
    double accuracy = 0,
    DateTime? lastSession,
    this.history = const [],
  }) : super(
         handsPlayed: handsPlayed,
         accuracy: accuracy,
         lastSession: lastSession,
       );
}

class SessionLogService extends ChangeNotifier {
  SessionLogService._internal({Object? sessions, CloudSyncService? cloud})
    : _sessions = sessions,
      _cloud = cloud;

  factory SessionLogService({Object? sessions, CloudSyncService? cloud}) =>
      SessionLogService._internal(sessions: sessions, cloud: cloud);

  static final SessionLogService instance = SessionLogService._internal();

  // ignore: unused_field
  final Object? _sessions;
  // ignore: unused_field
  final CloudSyncService? _cloud;

  List<SessionLogEntry>? _cache;
  DateTime? _activeStartCache;
  bool _legacyLoaded = false;
  final List<SessionLog> _legacyLogs = [];
  final Map<String, List<StageHistoryPoint>> _historyByStage = {};

  Future<List<SessionLogEntry>> getLogs() async {
    if (_cache != null) return List.unmodifiable(_cache!);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionLogStorageKey);
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
      final entries =
          decoded
              .map(
                (item) =>
                    SessionLogEntry.fromJson(item as Map<String, dynamic>?),
              )
              .whereType<SessionLogEntry>()
              .toList()
            ..sort((a, b) => b.startTime.compareTo(a.startTime));
      _cache = entries;
      return List.unmodifiable(entries);
    } catch (_) {
      _cache = const [];
      return const [];
    }
  }

  Future<void> addLog(dynamic entry) async {
    if (entry is SessionLogEntry) {
      final logs = await getLogs();
      final updated = [entry, ...logs];
      await _persist(updated);
      _cache = updated;
      // SessionLogEntry does not carry pack context; expose as informational log.
      _upsertLegacyLog(_convertEntryToLegacy(entry));
      return;
    }
    if (entry is SessionLog) {
      await _ensureLegacyLoaded();
      _upsertLegacyLog(entry);
      return;
    }
    throw ArgumentError.value(
      entry,
      'entry',
      'Unsupported log type for SessionLogService',
    );
  }

  Future<void> startSession(DateTime start, {List<String>? tags}) async {
    final prefs = await SharedPreferences.getInstance();
    final iso = start.toUtc().toIso8601String();
    await prefs.setString(_activeSessionKey, iso);
    _activeStartCache = start.toUtc();
    await setActiveTags(tags ?? const []);
  }

  Future<DateTime?> getActiveSessionStart() async {
    if (_activeStartCache != null) return _activeStartCache;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeSessionKey);
    if (raw == null) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    _activeStartCache = parsed.toUtc();
    return _activeStartCache;
  }

  Future<SessionLogEntry?> endSession({
    DateTime? endTime,
    String? location,
  }) async {
    final start = await getActiveSessionStart();
    if (start == null) return null;
    final end = (endTime ?? DateTime.now()).toUtc();
    var minutes = end.difference(start).inMinutes;
    if (minutes < 1) minutes = 1;
    if (minutes > 480) minutes = 480;
    final tags = await _activeTags();
    final xp = await XpService.computeSessionXp(minutes, tags: tags);
    final entry = SessionLogEntry(
      startTime: start,
      durationMinutes: minutes,
      location: location,
      xpEarned: xp,
      tags: tags,
      notes: null,
    );
    await addLog(entry);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeSessionKey);
    await prefs.remove('$_activeSessionKey:tags');
    _activeStartCache = null;
    _activeTagCache = null;

    // Update last session timestamp for nudge scheduling
    unawaited(NudgeSchedulerService.instance.updateLastSession());

    return entry;
  }

  Future<void> _persist(List<SessionLogEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_sessionLogStorageKey, encoded);
  }

  @visibleForTesting
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionLogStorageKey);
    await prefs.remove(_activeSessionKey);
    await prefs.remove('$_activeSessionKey:tags');
    _cache = null;
    _activeStartCache = null;
    _activeTagCache = null;
    if (_legacyLoaded) {
      _legacyLogs.clear();
      _historyByStage.clear();
      await _persistLegacyLogs();
      notifyListeners();
    }
  }

  List<String>? _activeTagCache;

  Future<void> setActiveTags(List<String> tags) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = tags.take(3).toList();
    await prefs.setString('$_activeSessionKey:tags', jsonEncode(trimmed));
    _activeTagCache = trimmed;
  }

  Future<List<String>> _activeTags() async {
    if (_activeTagCache != null) return _activeTagCache!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_activeSessionKey:tags');
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final tags = decoded.cast<String>().take(3).toList();
        _activeTagCache = tags;
        return tags;
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<List<String>> getActiveSessionTags() async =>
      List.unmodifiable(await _activeTags());

  Future<void> updateNotes(DateTime startTime, String? notes) async {
    final logs = await getLogs();
    final normalized = notes?.trim();
    final limited = normalized == null
        ? null
        : (normalized.length > 2000
              ? normalized.substring(0, 2000)
              : normalized);
    final updated = logs.map((entry) {
      if (entry.startTime.toUtc() == startTime.toUtc()) {
        return SessionLogEntry(
          startTime: entry.startTime,
          durationMinutes: entry.durationMinutes,
          location: entry.location,
          xpEarned: entry.xpEarned,
          tags: entry.tags,
          notes: limited == null || limited.isEmpty ? null : limited,
        );
      }
      return entry;
    }).toList();
    await _persist(updated);
    _cache = updated;
    // Notes are informational only; keep legacy cache unchanged.
    notifyListeners();
  }

  /// Legacy compatibility -----------------------------------------------------------------------

  List<SessionLog> get logs {
    // Ensure legacy data is warm; fire and forget if not yet loaded.
    if (!_legacyLoaded) {
      unawaited(load());
    }
    return List.unmodifiable(_legacyLogs);
  }

  Future<void> init() async {
    await load();
  }

  Future<void> load() async {
    await _loadLegacyLogs();
    await getLogs(); // Warm modern cache.
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<SessionLog> filter({
    String? templateId,
    DateTime? since,
    String? tag,
    DateTimeRange? range,
  }) {
    if (!_legacyLoaded) {
      unawaited(load());
      return const [];
    }
    return _legacyLogs.where((log) {
      if (templateId != null && log.templateId != templateId) return false;
      if (since != null && log.completedAt.isBefore(since)) return false;
      if (range != null) {
        final start = range.start.toUtc();
        final end = range.end.toUtc();
        if (log.completedAt.isBefore(start) || log.completedAt.isAfter(end)) {
          return false;
        }
      }
      if (tag != null) {
        final lower = tag.toLowerCase();
        final tagMatch = log.tags.any((t) => t.trim().toLowerCase() == lower);
        final categoryMatch = log.categories.keys.any(
          (t) => t.trim().toLowerCase() == lower,
        );
        if (!tagMatch && !categoryMatch) return false;
      }
      return true;
    }).toList();
  }

  Map<String, int> getRecentMistakes({int limit = 50}) {
    if (!_legacyLoaded) {
      unawaited(load());
      return const {};
    }
    final counts = <String, int>{};
    for (final log in _legacyLogs.take(limit)) {
      for (final entry in log.categories.entries) {
        final key = entry.key.trim().toLowerCase();
        if (key.isEmpty) continue;
        counts.update(key, (v) => v + entry.value, ifAbsent: () => entry.value);
      }
      for (final tag in log.tags) {
        final key = tag.trim().toLowerCase();
        if (key.isEmpty) continue;
        counts.update(key, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  StageStats getStats(String stageId) {
    final stats = getStatsWithHistory(stageId);
    return StageStats(
      handsPlayed: stats.handsPlayed,
      accuracy: stats.accuracy,
      lastSession: stats.lastSession,
    );
  }

  StageStatsWithHistory getStatsWithHistory(String stageId) {
    if (!_legacyLoaded) {
      unawaited(load());
      return const StageStatsWithHistory();
    }
    final logsForStage = filter(templateId: stageId);
    if (logsForStage.isEmpty) {
      return const StageStatsWithHistory();
    }
    final hands = logsForStage.fold<int>(
      0,
      (sum, log) => sum + log.correctCount + log.mistakeCount,
    );
    final correct = logsForStage.fold<int>(
      0,
      (sum, log) => sum + log.correctCount,
    );
    final accuracy = hands == 0 ? 0.0 : (correct * 100.0) / hands;
    final history = _historyByStage[stageId] ?? const <StageHistoryPoint>[];
    return StageStatsWithHistory(
      handsPlayed: hands,
      accuracy: accuracy,
      lastSession: logsForStage.first.completedAt,
      history: history,
    );
  }

  Future<UserProgress> getUserProgress() async {
    if (!_legacyLoaded) {
      await load();
    }
    final results = _legacyLogs.map((log) {
      final total = log.correctCount + log.mistakeCount;
      final accuracy = total == 0 ? 0.0 : log.correctCount / total;
      return TrainingResult(
        date: log.completedAt,
        total: total,
        correct: log.correctCount,
        accuracy: accuracy,
        tags: log.tags,
        notes: log.unlockGoalReached == true ? 'goal-completed' : null,
        evDiff: log.evPercent,
      );
    }).toList();
    return UserProgress(history: results);
  }

  List<Mistake> getMistakesByTopic(String topicId) {
    // TODO replace stub when logic is restored.
    return const [];
  }

  Future<Map<String, int>> getSessionCounts() async {
    // TODO replace stub when logic is restored.
    return const {'last7Days': 0, 'last30Days': 0};
  }

  /// Internal helpers ---------------------------------------------------------------------------

  Future<void> _ensureLegacyLoaded() async {
    if (_legacyLoaded) return;
    await _loadLegacyLogs();
  }

  Future<void> _loadLegacyLogs() async {
    if (_legacyLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_legacyLogStorageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _legacyLogs.clear();
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _legacyLogs.add(SessionLog.fromJson(item));
            } else if (item is Map) {
              _legacyLogs.add(
                SessionLog.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
          _legacyLogs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
        }
      } catch (_) {}
    }
    _rebuildHistory();
    _legacyLoaded = true;
  }

  void _upsertLegacyLog(SessionLog log) async {
    await _ensureLegacyLoaded();
    _legacyLogs.removeWhere((existing) => existing.sessionId == log.sessionId);
    _legacyLogs.add(log);
    _legacyLogs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    _rebuildHistoryFor(log);
    await _persistLegacyLogs();
    notifyListeners();
  }

  SessionLog _convertEntryToLegacy(SessionLogEntry entry) {
    final end = entry.startTime.toUtc().add(
      Duration(minutes: entry.durationMinutes),
    );
    return SessionLog(
      sessionId: entry.startTime.millisecondsSinceEpoch.toString(),
      templateId: '',
      startedAt: entry.startTime.toUtc(),
      completedAt: end,
      correctCount: 0,
      mistakeCount: 0,
      evPercent: null,
      accuracyBefore: null,
      accuracyAfter: null,
      handsBefore: null,
      handsAfter: null,
      unlockGoalReached: null,
      categories: const {},
      tags: entry.tags,
    );
  }

  Future<void> _persistLegacyLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _legacyLogs.map((log) => log.toJson()).toList();
    await prefs.setString(_legacyLogStorageKey, jsonEncode(jsonList));
  }

  void _rebuildHistory() {
    _historyByStage.clear();
    for (final log in _legacyLogs) {
      _rebuildHistoryFor(log);
    }
  }

  void _rebuildHistoryFor(SessionLog log) {
    final stageId = log.templateId;
    if (stageId.isEmpty) return;
    final total = log.correctCount + log.mistakeCount;
    final accuracy = total == 0 ? 0.0 : (log.correctCount * 100.0) / total;
    final list = _historyByStage.putIfAbsent(stageId, () => []);
    list.removeWhere((point) => point.date == log.completedAt);
    list.add(StageHistoryPoint(date: log.completedAt, accuracy: accuracy));
    list.sort((a, b) => a.date.compareTo(b.date));
    if (list.length > 50) {
      list.removeRange(0, list.length - 50);
    }
  }
}

extension TrainingPackSpotDescription on TrainingPackSpot {
  String get description => title.isNotEmpty ? title : note;
}
