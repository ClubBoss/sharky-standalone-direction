import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath = '$_reportsDir/marketing_funnel_summary.txt';
const String _summaryJsonPath = '$_reportsDir/marketing_funnel_summary.json';
const String _telemetryOutPath = '$_reportsDir/telemetry.jsonl';
const int _minSampleSize = 25;
const double _minConversionPercent = 40.0;

Future<void> main(List<String> args) async {
  final analyzer = MarketingFunnelAnalytics();
  final ok = await analyzer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MarketingFunnelAnalytics {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final telemetry = await _loadTelemetry();
    final funnel = _FunnelComputation(telemetry);
    final metrics = funnel.compute();

    await _withReportsWritable(() async {
      await _writeTextSummary(metrics, stopwatch.elapsedMilliseconds);
      await _writeJsonSummary(metrics, stopwatch.elapsedMilliseconds);
      await _emitTelemetry(metrics, stopwatch.elapsedMilliseconds);
    });

    final conversionsOk = metrics.conversions.every(
      (conversion) => conversion.percentage >= _minConversionPercent,
    );
    final sampleOk = metrics.sampleSize >= _minSampleSize;
    return conversionsOk && sampleOk;
  }

  Future<List<Map<String, Object?>>> _loadTelemetry() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      throw StateError('Telemetry file missing at $_telemetryPath');
    }
    final events = <Map<String, Object?>>[];
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final decoded = json.decode(line);
        if (decoded is Map<String, Object?>) {
          events.add(decoded);
        }
      } catch (_) {
        // ignore malformed lines
      }
    }
    return events;
  }

  Future<void> _writeTextSummary(_FunnelMetrics metrics, int durationMs) async {
    final buffer = StringBuffer()
      ..writeln('MARKETING FUNNEL SUMMARY')
      ..writeln('========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Sample size (signups): ${metrics.sampleSize}')
      ..writeln(
        'Average session duration (per user): '
        '${metrics.averageSessionSeconds.toStringAsFixed(1)}s',
      )
      ..writeln('Duration: ${durationMs}ms')
      ..writeln();

    buffer.writeln('Stage counts:');
    metrics.stageCounts.forEach((stage, count) {
      buffer.writeln('- $stage: $count users');
    });

    buffer
      ..writeln()
      ..writeln('Conversions:');
    for (final conversion in metrics.conversions) {
      buffer.writeln(
        '- ${conversion.from} → ${conversion.to}: '
        '${conversion.percentage.toStringAsFixed(1)}% '
        '(${conversion.converted}/${conversion.total})',
      );
    }

    await File(_summaryTextPath).writeAsString(buffer.toString());
  }

  Future<void> _writeJsonSummary(_FunnelMetrics metrics, int durationMs) async {
    final payload = <String, Object?>{
      'generated': DateTime.now().toIso8601String(),
      'duration_ms': durationMs,
      'sample_size': metrics.sampleSize,
      'average_session_seconds': metrics.averageSessionSeconds,
      'stage_counts': metrics.stageCounts,
      'conversions': [
        for (final conversion in metrics.conversions)
          {
            'from': conversion.from,
            'to': conversion.to,
            'percentage': conversion.percentage,
            'converted': conversion.converted,
            'total': conversion.total,
          },
      ],
    };

    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
  }

  Future<void> _emitTelemetry(_FunnelMetrics metrics, int durationMs) async {
    final payload = <String, Object?>{
      'event': 'marketing_funnel_analytics_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'sample_size': metrics.sampleSize,
      'average_session_seconds': metrics.averageSessionSeconds,
      'conversions': [
        for (final conversion in metrics.conversions)
          {
            'from': conversion.from,
            'to': conversion.to,
            'percentage': double.parse(
              conversion.percentage.toStringAsFixed(2),
            ),
          },
      ],
      'duration_ms': durationMs,
    };

    final sink = File(_telemetryOutPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _FunnelComputation {
  _FunnelComputation(this.events);

  final List<Map<String, Object?>> events;
  static const List<String> _stages = <String>[
    'signup_completed',
    'tutorial_started',
    'tutorial_finished',
    'session_start',
    'session_end',
  ];

  _FunnelMetrics compute() {
    final stageUsers = <String, Set<String>>{
      for (final stage in _stages) stage: <String>{},
    };
    final journeys = <String, _UserJourney>{};

    for (final payload in events) {
      final event = payload['event']?.toString();
      if (event == null || !_stages.contains(event)) continue;
      final userId = _extractUserId(payload);
      if (userId == null) continue;
      final journey = journeys.putIfAbsent(userId, _UserJourney.new);

      switch (event) {
        case 'signup_completed':
          journey.signupCompleted = true;
          break;
        case 'tutorial_started':
          journey.tutorialStarted = true;
          break;
        case 'tutorial_finished':
          journey.tutorialFinished = true;
          break;
        case 'session_start':
          journey.registerSessionStart(_timestamp(payload));
          break;
        case 'session_end':
          journey.registerSessionEnd(_timestamp(payload));
          break;
      }
      stageUsers[event]!.add(userId);
    }

    final conversions = <_ConversionResult>[];
    for (var i = 0; i < _stages.length - 1; i++) {
      final fromStage = _stages[i];
      final toStage = _stages[i + 1];
      final fromUsers = stageUsers[fromStage] ?? const <String>{};
      final toUsers = stageUsers[toStage] ?? const <String>{};
      final converted = toUsers.intersection(fromUsers).length;
      final percentage = fromUsers.isEmpty
          ? 0.0
          : (converted / fromUsers.length) * 100.0;
      conversions.add(
        _ConversionResult(
          from: fromStage,
          to: toStage,
          converted: converted,
          total: fromUsers.length,
          percentage: percentage,
        ),
      );
    }

    final sampleSize = stageUsers['signup_completed']?.length ?? 0;
    final averageSessionSeconds = _calculateAverageSessionSeconds(journeys);

    return _FunnelMetrics(
      stageCounts: {
        for (final entry in stageUsers.entries) entry.key: entry.value.length,
      },
      conversions: conversions,
      sampleSize: sampleSize,
      averageSessionSeconds: averageSessionSeconds,
    );
  }

  String? _extractUserId(Map<String, Object?> payload) {
    final candidates = [
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

  double _calculateAverageSessionSeconds(Map<String, _UserJourney> journeys) {
    final perUserAverages = <double>[];
    for (final journey in journeys.values) {
      if (journey.sessionDurations.isEmpty) continue;
      final total = journey.sessionDurations
          .reduce((a, b) => a + b)
          .inMilliseconds
          .toDouble();
      final avg = total / journey.sessionDurations.length / 1000.0;
      perUserAverages.add(avg);
    }
    if (perUserAverages.isEmpty) return 0;
    final sum = perUserAverages.reduce((a, b) => a + b);
    return sum / perUserAverages.length;
  }
}

class _UserJourney {
  bool signupCompleted = false;
  bool tutorialStarted = false;
  bool tutorialFinished = false;
  final List<DateTime> _pendingSessions = <DateTime>[];
  final List<Duration> sessionDurations = <Duration>[];

  void registerSessionStart(DateTime? timestamp) {
    if (timestamp == null) return;
    _pendingSessions.add(timestamp);
  }

  void registerSessionEnd(DateTime? timestamp) {
    if (timestamp == null || _pendingSessions.isEmpty) return;
    final start = _pendingSessions.removeAt(0);
    sessionDurations.add(timestamp.difference(start));
  }
}

class _FunnelMetrics {
  _FunnelMetrics({
    required this.stageCounts,
    required this.conversions,
    required this.sampleSize,
    required this.averageSessionSeconds,
  });

  final Map<String, int> stageCounts;
  final List<_ConversionResult> conversions;
  final int sampleSize;
  final double averageSessionSeconds;
}

class _ConversionResult {
  _ConversionResult({
    required this.from,
    required this.to,
    required this.converted,
    required this.total,
    required this.percentage,
  });

  final String from;
  final String to;
  final int converted;
  final int total;
  final double percentage;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore chmod failure
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore
    }
  }
}
