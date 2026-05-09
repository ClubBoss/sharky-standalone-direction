import 'dart:convert';

import '../services/session_log_service.dart';

class SessionExportService {
  final List<SessionLogEntry> sessions;
  final String localeCode;

  SessionExportService({required this.sessions, required this.localeCode});

  Map<String, dynamic> toJson() => {
    'summary': _summaryJson(),
    'sessions': sessions.map(_sessionToJson).toList(),
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String toCsv() {
    final headers = _headers();
    final buffer = StringBuffer()..writeln(headers.join(','));
    for (final session in sessions) {
      final row = [
        _escape(session.startTime.toUtc().toIso8601String()),
        session.durationMinutes.toString(),
        _escape(session.location ?? ''),
        session.xpEarned.toString(),
        _escape(session.tags.join('|')),
        _escape(session.notes ?? ''),
      ];
      buffer.writeln(row.join(','));
    }
    return buffer.toString().trim();
  }

  Map<String, dynamic> _summaryJson() {
    final totalSessions = sessions.length;
    final totalXp = sessions.fold<int>(0, (sum, e) => sum + e.xpEarned);
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, e) => sum + e.durationMinutes,
    );
    return {
      'totalSessions': totalSessions,
      'totalXp': totalXp,
      'totalMinutes': totalMinutes,
    };
  }

  Map<String, dynamic> _sessionToJson(SessionLogEntry entry) => {
    'startTime': entry.startTime.toUtc().toIso8601String(),
    'durationMinutes': entry.durationMinutes,
    'location': entry.location,
    'xpEarned': entry.xpEarned,
    'tags': entry.tags,
    'notes': entry.notes,
  };

  List<String> _headers() {
    final isRu = localeCode.toLowerCase().startsWith('ru');
    return isRu
        ? ['Начало', 'Длительность (мин)', 'Локация', 'XP', 'Теги', 'Заметки']
        : ['Start Time', 'Duration (min)', 'Location', 'XP', 'Tags', 'Notes'];
  }

  String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}
