import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _engagementSummaryPath =
    'release/_reports/engagement_heatmap_summary.txt';
const String _retentionSummaryPath =
    'release/_reports/retention_funnel_summary.txt';
const String _outputPath = 'release/_reports/engagement_retention_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

const List<String> _sections = [
  'Home',
  'Lessons',
  'Drills',
  'Quizzes',
  'Recaps',
];

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final engagement = await _loadEngagementIntensities();
  final retentionMetrics = await _loadRetentionMetrics();
  final retention = _projectRetentionToSections(retentionMetrics);

  final normalizedEngagement = _normalize(engagement);
  final normalizedRetention = _normalize(retention);

  final correlation = _CorrelationResult.from(
    normalizedEngagement,
    normalizedRetention,
  );

  await _withReportsWritable(() async {
    await _writeSummary(
      engagement,
      retention,
      normalizedEngagement,
      normalizedRetention,
      correlation,
      stopwatch.elapsedMilliseconds,
    );
    await _emitTelemetry(
      normalizedEngagement,
      normalizedRetention,
      correlation,
      stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'engagement_retention_correlator: summary generated at $_outputPath',
  );
}

Future<Map<String, double>> _loadEngagementIntensities() async {
  final file = File(_engagementSummaryPath);
  if (!await file.exists()) {
    throw StateError('Engagement summary missing: $_engagementSummaryPath');
  }

  final lines = await file.readAsLines();
  final data = <String, double>{};
  final regex = RegExp(
    r'^(Home|Lessons|Drills|Quizzes|Recaps)\s+\|\s+[^\s]+\s+([0-9]+(?:\.[0-9]+)?)%',
  );
  for (final line in lines) {
    final match = regex.firstMatch(line);
    if (match == null) continue;
    final section = match.group(1)!;
    final value = double.parse(match.group(2)!);
    data[section] = value;
  }

  if (!_sections.every(data.containsKey)) {
    throw StateError(
      'Engagement summary missing sections. '
      'Found: ${data.keys.toList()}. Expected: $_sections',
    );
  }

  return Map<String, double>.unmodifiable(data);
}

Future<_RetentionMetrics> _loadRetentionMetrics() async {
  final file = File(_retentionSummaryPath);
  if (!await file.exists()) {
    throw StateError('Retention summary missing: $_retentionSummaryPath');
  }

  final lines = await file.readAsLines();
  double? firstToSignup;
  double? signupToStart;
  double? startToFinish;
  double? total;

  double? _extract(String line) {
    final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)%').firstMatch(line);
    return match == null ? null : double.parse(match.group(1)!);
  }

  for (final line in lines) {
    final lower = line.toLowerCase();
    if (firstToSignup == null &&
        lower.contains('first_launch') &&
        lower.contains('signup')) {
      firstToSignup = _extract(line);
    } else if (signupToStart == null &&
        lower.contains('signup') &&
        lower.contains('tutorial_start')) {
      signupToStart = _extract(line);
    } else if (startToFinish == null &&
        lower.contains('tutorial_start') &&
        lower.contains('tutorial_finish')) {
      startToFinish = _extract(line);
    } else if (total == null && lower.startsWith('total retention')) {
      total = _extract(line);
    }
  }

  if ([firstToSignup, signupToStart, startToFinish, total].contains(null)) {
    throw StateError(
      'Retention summary is missing funnel values in $_retentionSummaryPath',
    );
  }

  return _RetentionMetrics(
    firstToSignup: firstToSignup!,
    signupToStart: signupToStart!,
    startToFinish: startToFinish!,
    totalRetention: total!,
  );
}

Map<String, double> _projectRetentionToSections(_RetentionMetrics metrics) {
  final midCourse = (metrics.signupToStart + metrics.startToFinish) / 2;
  return Map<String, double>.unmodifiable({
    'Home': metrics.firstToSignup,
    'Lessons': metrics.signupToStart,
    'Drills': metrics.startToFinish,
    'Quizzes': midCourse,
    'Recaps': metrics.totalRetention,
  });
}

Map<String, double> _normalize(Map<String, double> values) {
  final minValue = values.values.reduce(min);
  final maxValue = values.values.reduce(max);
  if ((maxValue - minValue).abs() < 1e-9) {
    return values.map((key, _) => MapEntry(key, 0.0));
  }

  return values.map(
    (key, value) => MapEntry(key, (value - minValue) / (maxValue - minValue)),
  );
}

Future<void> _writeSummary(
  Map<String, double> engagement,
  Map<String, double> retention,
  Map<String, double> normalizedEngagement,
  Map<String, double> normalizedRetention,
  _CorrelationResult correlation,
  int durationMs,
) async {
  final buffer = StringBuffer()
    ..writeln('ENGAGEMENT VS RETENTION')
    ..writeln('======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Normalization: min-max (0-1 scale)')
    ..writeln();

  buffer
    ..writeln('Section Snapshots:')
    ..writeln('Section  | Eng%  | Ret%  | Eng(norm) | Ret(norm)')
    ..writeln('---------+-------+-------+-----------+-----------');
  for (final section in _sections) {
    buffer.writeln(
      '${section.padRight(8)}|'
      ' ${engagement[section]!.toStringAsFixed(1).padLeft(5)} |'
      ' ${retention[section]!.toStringAsFixed(1).padLeft(5)} |'
      ' ${normalizedEngagement[section]!.toStringAsFixed(2).padLeft(9)} |'
      ' ${normalizedRetention[section]!.toStringAsFixed(2).padLeft(9)}',
    );
  }

  buffer
    ..writeln()
    ..writeln('Correlation Insights:')
    ..writeln(
      'Overall Pearson r: ${correlation.overall.toStringAsFixed(3)} '
      '(${_trendLabel(correlation.overall)})',
    )
    ..writeln('Per-section contribution (r_i):');
  for (final section in _sections) {
    final rValue = correlation.perSection[section] ?? 0.0;
    buffer.writeln(
      '- $section: r=${rValue.toStringAsFixed(3)} '
      '(${_trendLabel(rValue)})',
    );
  }

  await File(_outputPath).writeAsString('${buffer.toString()}\n');
}

Future<void> _emitTelemetry(
  Map<String, double> normalizedEngagement,
  Map<String, double> normalizedRetention,
  _CorrelationResult correlation,
  int durationMs,
) async {
  final payload = <String, Object?>{
    'event': 'engagement_retention_correlated',
    'timestamp': DateTime.now().toIso8601String(),
    'normalized_engagement': normalizedEngagement,
    'normalized_retention': normalizedRetention,
    'overall_r': double.parse(correlation.overall.toStringAsFixed(4)),
    'per_section_r': correlation.perSection.map(
      (key, value) => MapEntry(key, double.parse(value.toStringAsFixed(4))),
    ),
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

class _CorrelationResult {
  const _CorrelationResult({required this.overall, required this.perSection});

  factory _CorrelationResult.from(
    Map<String, double> engagement,
    Map<String, double> retention,
  ) {
    final data = _sections
        .map(
          (section) =>
              _Pair(engagement[section]!, retention[section]!, section),
        )
        .toList();
    final meanEng =
        data.map((pair) => pair.engagement).reduce((a, b) => a + b) /
        data.length;
    final meanRet =
        data.map((pair) => pair.retention).reduce((a, b) => a + b) /
        data.length;

    double sumEngVar = 0;
    double sumRetVar = 0;

    for (final pair in data) {
      final engDelta = pair.engagement - meanEng;
      final retDelta = pair.retention - meanRet;
      sumEngVar += engDelta * engDelta;
      sumRetVar += retDelta * retDelta;
    }

    final denominator = sqrt(sumEngVar) * sqrt(sumRetVar);
    if (denominator == 0) {
      return _CorrelationResult(
        overall: 0,
        perSection: {for (final section in _sections) section: 0.0},
      );
    }

    final perSection = <String, double>{};
    for (final pair in data) {
      final engDelta = pair.engagement - meanEng;
      final retDelta = pair.retention - meanRet;
      perSection[pair.section] = (engDelta * retDelta) / denominator;
    }

    final overall = perSection.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    return _CorrelationResult(overall: overall, perSection: perSection);
  }

  final double overall;
  final Map<String, double> perSection;
}

class _Pair {
  const _Pair(this.engagement, this.retention, this.section);

  final double engagement;
  final double retention;
  final String section;
}

String _trendLabel(double value) {
  if (value > 0.05) return 'positive impact';
  if (value < -0.05) return 'negative impact';
  return 'neutral';
}

class _RetentionMetrics {
  const _RetentionMetrics({
    required this.firstToSignup,
    required this.signupToStart,
    required this.startToFinish,
    required this.totalRetention,
  });

  final double firstToSignup;
  final double signupToStart;
  final double startToFinish;
  final double totalRetention;
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
      'engagement_retention_correlator: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
