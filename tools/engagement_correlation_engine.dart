import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _funnelSummaryPath = '$_reportsDir/marketing_funnel_summary.json';
const String _summaryOutPath =
    '$_reportsDir/engagement_correlation_summary.txt';
const String _telemetryOutPath = '$_reportsDir/telemetry.jsonl';
const int _minSampleSize = 25;
const double _minCorrelation = 0.3;

Future<void> main(List<String> args) async {
  final engine = EngagementCorrelationEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class EngagementCorrelationEngine {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final telemetryEvents = await _loadTelemetry();
    final funnel = await _loadFunnel();
    final users = _buildUserMetrics(telemetryEvents);
    final metrics = _computeCorrelation(users, funnel.healthIndex);

    await _withReportsWritable(() async {
      await _writeSummary(metrics, funnel, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(metrics, funnel, stopwatch.elapsedMilliseconds);
    });

    final sampleOk = metrics.sampleSize >= _minSampleSize;
    final correlationOk = metrics.pearsonR >= _minCorrelation;
    return sampleOk && correlationOk;
  }

  Future<List<Map<String, Object?>>> _loadTelemetry() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      throw StateError('Telemetry stream missing at $_telemetryPath');
    }
    final events = <Map<String, Object?>>[];
    for (final line in await file.readAsLines()) {
      if (line.trim().isEmpty) continue;
      try {
        final decoded = json.decode(line);
        if (decoded is Map<String, Object?>) {
          events.add(decoded);
        }
      } catch (_) {
        // ignore malformed rows
      }
    }
    return events;
  }

  Future<_FunnelHealth> _loadFunnel() async {
    final file = File(_funnelSummaryPath);
    if (!await file.exists()) {
      throw StateError(
        'Marketing funnel summary missing at $_funnelSummaryPath. '
        'Run tools/marketing_funnel_analytics.dart first.',
      );
    }
    final decoded = json.decode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid marketing funnel summary JSON.');
    }
    final conversions = decoded['conversions'];
    if (conversions is! List) {
      throw StateError('Missing conversions array in funnel summary.');
    }
    if (conversions.isEmpty) {
      return const _FunnelHealth(healthIndex: 0);
    }
    final total = conversions
        .whereType<Map>()
        .map((entry) => (entry['percentage'] as num?)?.toDouble() ?? 0)
        .fold<double>(0, (sum, value) => sum + value);
    final healthIndex = total / conversions.length;
    return _FunnelHealth(healthIndex: healthIndex);
  }

  Map<String, _UserMetrics> _buildUserMetrics(
    List<Map<String, Object?>> events,
  ) {
    final users = <String, _UserMetrics>{};
    for (final payload in events) {
      final event = payload['event']?.toString();
      if (event == null) continue;
      final userId = _extractUserId(payload);
      if (userId == null) continue;
      final metrics = users.putIfAbsent(userId, _UserMetrics.new);
      final timestamp = _timestamp(payload);
      switch (event) {
        case 'ad_impression':
          metrics.adImpressions++;
          break;
        case 'lesson_open':
          metrics.lessonOpens++;
          break;
        case 'quiz_complete':
          metrics.quizCompletes++;
          break;
        case 'recap_view':
          metrics.recapViews++;
          break;
        case 'signup_completed':
          metrics.reachedStages.add('signup_completed');
          break;
        case 'tutorial_started':
          metrics.reachedStages.add('tutorial_started');
          break;
        case 'tutorial_finished':
          metrics.reachedStages.add('tutorial_finished');
          break;
        case 'session_start':
          metrics.reachedStages.add('session_start');
          metrics.sessionStarts.add(timestamp);
          break;
        case 'session_end':
          metrics.reachedStages.add('session_end');
          metrics.sessionEnds.add(timestamp);
          break;
      }
    }
    return users;
  }

  _CorrelationMetrics _computeCorrelation(
    Map<String, _UserMetrics> users,
    double funnelHealth,
  ) {
    final engagement = <double>[];
    final retention = <double>[];
    for (final metrics in users.values) {
      final engagementScore = metrics.engagementIndex;
      final retentionScore = metrics.retentionScore;
      if (engagementScore == 0 && retentionScore == 0) continue;
      engagement.add(engagementScore);
      retention.add(retentionScore);
    }
    final sampleSize = engagement.length;
    final pearsonR = _pearson(engagement, retention);
    return _CorrelationMetrics(
      sampleSize: sampleSize,
      pearsonR: pearsonR,
      funnelHealthIndex: funnelHealth,
      averageEngagement: _average(engagement),
      averageRetentionScore: _average(retention),
    );
  }

  Future<void> _writeSummary(
    _CorrelationMetrics metrics,
    _FunnelHealth funnel,
    int durationMs,
  ) async {
    final buffer = StringBuffer()
      ..writeln('ENGAGEMENT CORRELATION SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Sample size: ${metrics.sampleSize}')
      ..writeln(
        'Average engagement index: '
        '${metrics.averageEngagement.toStringAsFixed(2)}',
      )
      ..writeln(
        'Average retention score: '
        '${metrics.averageRetentionScore.toStringAsFixed(2)}',
      )
      ..writeln(
        'Retention Health Index: '
        '${funnel.healthIndex.toStringAsFixed(2)}%',
      )
      ..writeln('Pearson r: ${metrics.pearsonR.toStringAsFixed(3)}')
      ..writeln('Duration: ${durationMs}ms');

    await File(_summaryOutPath).writeAsString(buffer.toString());
  }

  Future<void> _emitTelemetry(
    _CorrelationMetrics metrics,
    _FunnelHealth funnel,
    int durationMs,
  ) async {
    final payload = <String, Object?>{
      'event': 'engagement_correlation_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'sample_size': metrics.sampleSize,
      'pearson_r': metrics.pearsonR,
      'average_engagement': metrics.averageEngagement,
      'average_retention_score': metrics.averageRetentionScore,
      'retention_health_index': funnel.healthIndex,
      'duration_ms': durationMs,
    };
    final sink = File(_telemetryOutPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _FunnelHealth {
  const _FunnelHealth({required this.healthIndex});

  final double healthIndex;
}

class _UserMetrics {
  int adImpressions = 0;
  int lessonOpens = 0;
  int quizCompletes = 0;
  int recapViews = 0;
  final Set<String> reachedStages = <String>{};
  final List<DateTime?> sessionStarts = <DateTime?>[];
  final List<DateTime?> sessionEnds = <DateTime?>[];

  double get engagementIndex =>
      adImpressions * 0.5 +
      lessonOpens * 1.0 +
      quizCompletes * 1.5 +
      recapViews * 1.0;

  double get retentionScore {
    const stages = [
      'signup_completed',
      'tutorial_started',
      'tutorial_finished',
      'session_start',
      'session_end',
    ];
    final matched = stages.where(reachedStages.contains).length;
    return matched / stages.length;
  }
}

double _pearson(List<double> xs, List<double> ys) {
  if (xs.length != ys.length || xs.isEmpty) return 0;
  final meanX = _average(xs);
  final meanY = _average(ys);
  var numerator = 0.0;
  var sumSqX = 0.0;
  var sumSqY = 0.0;
  for (var i = 0; i < xs.length; i++) {
    final dx = xs[i] - meanX;
    final dy = ys[i] - meanY;
    numerator += dx * dy;
    sumSqX += dx * dx;
    sumSqY += dy * dy;
  }
  final denominator = sqrt(sumSqX * sumSqY);
  if (denominator == 0) return 0;
  return numerator / denominator;
}

double _average(List<double> values) {
  if (values.isEmpty) return 0;
  return values.reduce((a, b) => a + b) / values.length;
}

String? _extractUserId(Map<String, Object?> payload) {
  const candidates = <String>[
    'user_id',
    'userId',
    'uid',
    'player_id',
    'playerId',
    'profile_id',
    'profileId',
  ];
  for (final key in candidates) {
    final value = payload[key];
    if (value == null) continue;
    final str = value.toString().trim();
    if (str.isNotEmpty) return str;
  }
  return null;
}

DateTime? _timestamp(Map<String, Object?> payload) {
  final raw = payload['timestamp']?.toString();
  if (raw == null) return null;
  return DateTime.tryParse(raw);
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

class _CorrelationMetrics {
  _CorrelationMetrics({
    required this.sampleSize,
    required this.pearsonR,
    required this.funnelHealthIndex,
    required this.averageEngagement,
    required this.averageRetentionScore,
  });

  final int sampleSize;
  final double pearsonR;
  final double funnelHealthIndex;
  final double averageEngagement;
  final double averageRetentionScore;
}
