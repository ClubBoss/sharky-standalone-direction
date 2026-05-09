import 'dart:convert';
import 'dart:io';

import 'package:intl/locale.dart' show Locale;

import '../models/xp_leaderboard_entry.dart' as xp;
import '../models/xp_trophy.dart';
import '../models/league_tier_badge.dart';
import 'training_progress_service.dart';
import 'xp_history_service.dart';
import 'xp_leaderboard_service.dart';
import 'xp_service.dart';
import 'xp_trophy_service.dart';

/// Aggregates XP, trophy, and training scope information into exportable formats.
class ProgressExportService {
  ProgressExportService({
    XpService? xpService,
    XpHistoryService? xpHistoryService,
    XpTrophyService? xpTrophyService,
    TrainingProgressService? trainingProgressService,
    List<xp.LeaderboardEntry> Function()? leaderboardFetcher,
    Locale? locale,
    DateTime Function()? nowProvider,
    Object? stats,
  }) : _xpService = xpService ?? XpService(),
       _xpHistoryService = xpHistoryService ?? XpHistoryService(),
       _xpTrophyService = xpTrophyService ?? XpTrophyService.instance,
       _trainingProgressService =
           trainingProgressService ?? TrainingProgressService.instance,
       _leaderboardFetcher =
           leaderboardFetcher ?? XpLeaderboardService.fetchTop5,
       _locale = locale ?? Locale.fromSubtags(languageCode: 'en'),
       _nowProvider = nowProvider ?? DateTime.now,
       _stats = stats;

  final XpService _xpService;
  final XpHistoryService _xpHistoryService;
  final XpTrophyService _xpTrophyService;
  final TrainingProgressService _trainingProgressService;
  final List<xp.LeaderboardEntry> Function() _leaderboardFetcher;
  final Locale _locale;
  final DateTime Function() _nowProvider;
  // ignore: unused_field
  final Object? _stats;

  String get _languageCode {
    final code = _locale.languageCode;
    if (code.isEmpty) return 'en';
    return code.toLowerCase();
  }

  bool get _isRu => _languageCode.startsWith('ru');

  Future<String> exportJson() async {
    final data = await _buildPayload();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<String> exportCsv({bool weekly = false}) async {
    final data = await _buildPayload();
    final buffer = StringBuffer()..writeln('section,key,value1,value2');

    final xp = data['xp'] as Map<String, dynamic>;
    buffer.writeln('xp,total,${xp['total']},');
    buffer.writeln('xp,weekly,${xp['weekly']},');
    buffer.writeln();

    buffer.writeln(
      'leaderboard,rank,uid,displayName,xp,leagueEmoji,leagueLabel',
    );
    for (final row in data['leaderboard'] as List<Map<String, dynamic>>) {
      buffer.writeln(
        'leaderboard,${row['rank']},${row['uid']},'
        '${_csvEscape(row['displayName'])},${row['xp']},'
        '${_csvEscape(row['leagueEmoji'])},${_csvEscape(row['leagueLabel'])}',
      );
    }
    buffer.writeln();

    buffer.writeln(
      'trophy,id,titleEn,titleRu,titleLocalized,unlockedAt,leagueEmoji,leagueLabel',
    );
    for (final trophy in data['trophies'] as List<Map<String, dynamic>>) {
      buffer.writeln(
        'trophy,${trophy['id']},${_csvEscape(trophy['titleEn'])},'
        '${_csvEscape(trophy['titleRu'])},'
        '${_csvEscape(trophy['titleLocalized'])},${trophy['unlockedAt']},'
        '${_csvEscape(trophy['leagueEmoji'])},'
        '${_csvEscape(trophy['leagueLabel'])}',
      );
    }
    buffer.writeln();

    buffer.writeln('training,label,completed,total');
    for (final entry in data['training'] as List<Map<String, dynamic>>) {
      buffer.writeln(
        'training,${entry['label']},${entry['completed']},${entry['total']}',
      );
    }

    return buffer.toString().trim();
  }

  Future<String> exportPdf({bool weekly = false}) async {
    // Stub implementation – reuse CSV payload for compatibility.
    return exportCsv(weekly: weekly);
  }

  Future<Map<String, dynamic>> _buildPayload() async {
    await _xpService.initialize();
    final totalXp = _xpService.getTotalXp();
    final history = await _xpHistoryService.getHistory();
    final weeklyXp = await _calculateWeeklyXp(_nowProvider(), history: history);

    await _xpTrophyService.init();
    final trophies = _xpTrophyService.unlocked.toList()
      ..sort((a, b) => a.achievedAt.compareTo(b.achievedAt));

    final scoped = _trainingProgressService.getScopedProgressSnapshots();
    final leaderboard = _leaderboardFetcher();

    return {
      'xp': {'total': totalXp, 'weekly': weeklyXp},
      'leaderboard': leaderboard.map((entry) {
        final badge = LeagueTierBadge.fromXp(entry.xp);
        return {
          'rank': entry.rank,
          'uid': entry.uid,
          'displayName': entry.displayName,
          'xp': entry.xp,
          'leagueEmoji': badge.emoji,
          'leagueLabel': badge.label(_languageCode),
        };
      }).toList(),
      'trophies': trophies
          .map(
            (entry) => {
              'id': entry.type.name,
              'titleEn': entry.type.titleEn,
              'titleRu': entry.type.titleRu,
              'titleLocalized': entry.type.title(isRu: _isRu),
              'unlockedAt': entry.achievedAt.toUtc().toIso8601String(),
              ..._badgeFieldsFor(entry, history, totalXp),
            },
          )
          .toList(),
      'training': scoped
          .map(
            (snapshot) => {
              'label': snapshot.label,
              'completed': snapshot.completedModules,
              'total': snapshot.totalModules,
            },
          )
          .toList(),
    };
  }

  Future<int> _calculateWeeklyXp(DateTime now, {List<XpEvent>? history}) async {
    history ??= await _xpHistoryService.getHistory();
    if (history.isEmpty) return 0;
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));
    var total = 0;
    for (final event in history) {
      final eventDay = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );
      if (!eventDay.isBefore(startOfWeek)) total += event.amount;
    }
    return total;
  }

  Map<String, String> _badgeFieldsFor(
    XpTrophyEntry entry,
    List<XpEvent> history,
    int totalXp,
  ) {
    final xpAtUnlock = _xpAtTimestamp(entry.achievedAt, history, totalXp);
    final badge = LeagueTierBadge.fromXp(xpAtUnlock);
    return {
      'leagueEmoji': badge.emoji,
      'leagueLabel': badge.label(_languageCode),
    };
  }

  int _xpAtTimestamp(DateTime timestamp, List<XpEvent> history, int totalXp) {
    if (history.isEmpty) return totalXp;
    var xpAfter = 0;
    for (final event in history) {
      if (event.timestamp.isAfter(timestamp)) {
        xpAfter += event.amount;
      }
    }
    final xp = totalXp - xpAfter;
    return xp < 0 ? 0 : xp;
  }

  String _csvEscape(Object? value) {
    final str = value?.toString() ?? '';
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      final escaped = str.replaceAll('"', '""');
      return '"$escaped"';
    }
    return str;
  }
}

extension ProgressExportStringExt on String {
  String get path {
    final file = File(
      '${Directory.systemTemp.path}/progress_export_${DateTime.now().microsecondsSinceEpoch}.txt',
    );
    file.writeAsStringSync(this);
    return file.path;
  }
}
