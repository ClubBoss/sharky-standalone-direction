import 'dart:convert';
import 'dart:io';

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _onboardingSummaryPath =
    'release/_reports/onboarding_metrics_summary.txt';
const String _funnelSummaryPath =
    'release/_reports/retention_funnel_summary.txt';
const String _telemetryOutput = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final telemetryCounts = await _parseTelemetry();
  final summaryCounts = await _parseOnboardingSummary();

  final counts = telemetryCounts.merge(summaryCounts);
  final funnel = _FunnelMetrics.fromCounts(counts);

  await _withReportsWritable(() async {
    await _writeSummary(funnel, stopwatch.elapsedMilliseconds);
    await _emitTelemetry(funnel, stopwatch.elapsedMilliseconds);
  });

  stdout.writeln(
    'retention_funnel_analyzer: total_retention='
    '${funnel.totalRetention.toStringAsFixed(1)}%',
  );
}

Future<_StageCounts> _parseTelemetry() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) {
    throw StateError('Telemetry file missing: $_telemetryPath');
  }

  final counts = _StageCounts();
  final lines = await file.readAsLines();
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    dynamic payload;
    try {
      payload = json.decode(line);
    } catch (_) {
      continue;
    }
    if (payload is! Map<String, dynamic>) continue;
    final event = payload['event']?.toString();
    switch (event) {
      case 'first_launch':
        counts.firstLaunch++;
        break;
      case 'signup_completed':
        counts.signupCompleted++;
        break;
      case 'tutorial_started':
        counts.tutorialStarted++;
        break;
      case 'tutorial_finished':
        counts.tutorialFinished++;
        break;
    }
  }
  return counts;
}

Future<_StageCounts> _parseOnboardingSummary() async {
  final file = File(_onboardingSummaryPath);
  if (!await file.exists()) return _StageCounts();
  final lines = await file.readAsLines();
  final counts = _StageCounts();
  for (final line in lines) {
    final trimmed = line.trim().toLowerCase();
    if (trimmed.startsWith('first launches')) {
      counts.firstLaunch = _extractInt(trimmed);
    } else if (trimmed.startsWith('signup completed')) {
      counts.signupCompleted = _extractInt(trimmed);
    } else if (trimmed.startsWith('tutorial started')) {
      counts.tutorialStarted = _extractInt(trimmed);
    } else if (trimmed.startsWith('tutorial finished')) {
      counts.tutorialFinished = _extractInt(trimmed);
    }
  }
  return counts;
}

Future<void> _writeSummary(_FunnelMetrics metrics, int durationMs) async {
  final buffer = StringBuffer()
    ..writeln('RETENTION FUNNEL SUMMARY')
    ..writeln('========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'first_launch → signup: ${metrics.firstToSignup.toStringAsFixed(1)}%',
    )
    ..writeln(
      'signup → tutorial_start: '
      '${metrics.signupToStart.toStringAsFixed(1)}%',
    )
    ..writeln(
      'tutorial_start → tutorial_finish: '
      '${metrics.startToFinish.toStringAsFixed(1)}%',
    )
    ..writeln('Total retention: ${metrics.totalRetention.toStringAsFixed(1)}%')
    ..writeln('Duration: ${durationMs}ms');

  await File(_funnelSummaryPath).writeAsString('${buffer.toString()}\n');
}

Future<void> _emitTelemetry(_FunnelMetrics metrics, int durationMs) async {
  final payload = <String, Object?>{
    'event': 'retention_funnel_updated',
    'timestamp': DateTime.now().toIso8601String(),
    'first_to_signup': double.parse(metrics.firstToSignup.toStringAsFixed(1)),
    'signup_to_start': double.parse(metrics.signupToStart.toStringAsFixed(1)),
    'start_to_finish': double.parse(metrics.startToFinish.toStringAsFixed(1)),
    'total_retention': double.parse(metrics.totalRetention.toStringAsFixed(1)),
    'duration_ms': durationMs,
  };

  await File(_telemetryOutput).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

int _extractInt(String line) {
  final match = RegExp(r'(\d+)').firstMatch(line);
  return match == null ? 0 : int.parse(match.group(1)!);
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'retention_funnel_analyzer: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _StageCounts {
  _StageCounts({
    this.firstLaunch = 0,
    this.signupCompleted = 0,
    this.tutorialStarted = 0,
    this.tutorialFinished = 0,
  });

  int firstLaunch;
  int signupCompleted;
  int tutorialStarted;
  int tutorialFinished;

  _StageCounts merge(_StageCounts other) => _StageCounts(
    firstLaunch: firstLaunch + other.firstLaunch,
    signupCompleted: signupCompleted + other.signupCompleted,
    tutorialStarted: tutorialStarted + other.tutorialStarted,
    tutorialFinished: tutorialFinished + other.tutorialFinished,
  );
}

class _FunnelMetrics {
  const _FunnelMetrics({
    required this.firstToSignup,
    required this.signupToStart,
    required this.startToFinish,
    required this.totalRetention,
  });

  factory _FunnelMetrics.fromCounts(_StageCounts counts) {
    final firstToSignup = counts.firstLaunch == 0
        ? 0.0
        : (counts.signupCompleted / counts.firstLaunch) * 100;
    final signupToStart = counts.signupCompleted == 0
        ? 0.0
        : (counts.tutorialStarted / counts.signupCompleted) * 100;
    final startToFinish = counts.tutorialStarted == 0
        ? 0.0
        : (counts.tutorialFinished / counts.tutorialStarted) * 100;
    final totalRetention = counts.firstLaunch == 0
        ? 0.0
        : (counts.tutorialFinished / counts.firstLaunch) * 100;

    return _FunnelMetrics(
      firstToSignup: firstToSignup,
      signupToStart: signupToStart,
      startToFinish: startToFinish,
      totalRetention: totalRetention,
    );
  }

  final double firstToSignup;
  final double signupToStart;
  final double startToFinish;
  final double totalRetention;
}
