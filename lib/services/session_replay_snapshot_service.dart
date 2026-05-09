import 'dart:convert';
import 'dart:io';

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const double _minAccuracyPercent = 70.0;

class SessionReplaySnapshotService {
  SessionReplaySnapshotService._();

  static final SessionReplaySnapshotService instance =
      SessionReplaySnapshotService._();

  Future<SessionReplaySnapshot> loadLatestSnapshot() async {
    final lines = await _readTelemetryLines();
    if (lines.isEmpty) {
      throw StateError('Telemetry log is empty.');
    }

    int? endIndex;
    Map<String, dynamic>? endEvent;
    int? startIndex;
    for (var i = lines.length - 1; i >= 0; i--) {
      final data = _decodeLine(lines[i]);
      if (data == null) continue;
      if (data['event'] == 'session_end') {
        endIndex = i;
        endEvent = data;
        break;
      }
    }
    if (endIndex == null || endEvent == null) {
      throw StateError('No session_end event found.');
    }

    final sessionId = endEvent['session_id']?.toString();
    if (sessionId == null) {
      throw StateError('Session end missing session_id.');
    }
    final endTime = DateTime.tryParse(endEvent['timestamp']?.toString() ?? '');
    if (endTime == null) {
      throw StateError('Session end missing timestamp.');
    }

    Map<String, dynamic>? startEvent;
    for (var i = endIndex - 1; i >= 0; i--) {
      final data = _decodeLine(lines[i]);
      if (data == null) continue;
      if (data['event'] == 'session_start' &&
          data['session_id']?.toString() == sessionId) {
        startEvent = data;
        startIndex = i;
        break;
      }
    }
    if (startEvent == null || startIndex == null) {
      throw StateError('No matching session_start for $sessionId.');
    }
    final startTime = DateTime.tryParse(
      startEvent['timestamp']?.toString() ?? '',
    );
    if (startTime == null) {
      throw StateError('Session start missing timestamp.');
    }

    final stats = _collectSessionStats(lines, startIndex, endIndex);
    if (stats.totalQuizzes == 0) {
      throw StateError('Session $sessionId contains no quiz data.');
    }
    final accuracyPercent = (stats.correctQuizzes / stats.totalQuizzes) * 100.0;
    if (accuracyPercent < _minAccuracyPercent) {
      throw StateError(
        'Accuracy ${accuracyPercent.toStringAsFixed(2)}% below threshold.',
      );
    }

    final snapshot = SessionReplaySnapshot(
      sessionId: sessionId,
      startTime: startTime,
      endTime: endTime,
      evPercent: stats.averageScore,
      accuracyPercent: accuracyPercent,
      xpGain: stats.xpGain,
      duration: endTime.difference(startTime),
      quizCount: stats.totalQuizzes,
    );
    await _writeTelemetry(snapshot);
    return snapshot;
  }

  Future<List<String>> _readTelemetryLines() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return const [];
    return file.readAsLines();
  }

  SessionQuizStats _collectSessionStats(
    List<String> lines,
    int startIndex,
    int endIndex,
  ) {
    int total = 0;
    int correct = 0;
    double scoreSum = 0;
    double xpGain = 0;

    for (var i = 0; i < lines.length; i++) {
      if (i <= startIndex || i >= endIndex) continue;
      final data = _decodeLine(lines[i]);
      if (data == null) continue;
      if (data['event'] == 'quiz_complete') {
        final score = (data['score'] as num?)?.toDouble();
        if (score == null) continue;
        total++;
        scoreSum += score;
        if (score >= 80) {
          correct++;
        }
        xpGain += (score / 100) * 40;
      }
    }

    final averageScore = total == 0 ? 0.0 : scoreSum / total;
    return SessionQuizStats(
      totalQuizzes: total,
      correctQuizzes: correct,
      averageScore: averageScore,
      xpGain: xpGain,
    );
  }

  Future<void> _writeTelemetry(SessionReplaySnapshot snapshot) async {
    final payload = <String, Object?>{
      'event': 'session_replay_snapshot_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'session_id': snapshot.sessionId,
      'accuracy_percent': snapshot.accuracyPercent,
      'ev_percent': snapshot.evPercent,
      'xp_gain': snapshot.xpGain,
      'duration_seconds': snapshot.duration.inSeconds,
      'quiz_count': snapshot.quizCount,
    };
    await _withReportsWritable(() async {
      final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
      sink.writeln(jsonEncode(payload));
      await sink.close();
    });
  }

  Map<String, dynamic>? _decodeLine(String line) {
    if (line.trim().isEmpty) return null;
    try {
      final value = json.decode(line);
      if (value is Map<String, dynamic>) return value;
    } catch (_) {
      return null;
    }
    return null;
  }
}

class SessionReplaySnapshot {
  const SessionReplaySnapshot({
    required this.sessionId,
    required this.startTime,
    required this.endTime,
    required this.evPercent,
    required this.accuracyPercent,
    required this.xpGain,
    required this.duration,
    required this.quizCount,
  });

  final String sessionId;
  final DateTime startTime;
  final DateTime endTime;
  final double evPercent;
  final double accuracyPercent;
  final double xpGain;
  final Duration duration;
  final int quizCount;
}

class SessionQuizStats {
  const SessionQuizStats({
    required this.totalQuizzes,
    required this.correctQuizzes,
    required this.averageScore,
    required this.xpGain,
  });

  final int totalQuizzes;
  final int correctQuizzes;
  final double averageScore;
  final double xpGain;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
