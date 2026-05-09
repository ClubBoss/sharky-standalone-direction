import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final generatedAt = DateTime.now().toUtc();
  final reportDir = Directory('release/_reports');

  final releaseSummary = await _readLines(
    '${reportDir.path}/release_summary.txt',
  );
  final mobileSummary = await _readLines(
    '${reportDir.path}/mobile_build_summary.txt',
  );
  final parallelProfile = await _readLines(
    '${reportDir.path}/parallel_ci_profile.txt',
  );
  final continuousReport = await _readLines(
    '${reportDir.path}/continuous_delivery_report.txt',
  );
  final versionLog = await _readLines('${reportDir.path}/version_tag_log.txt');

  final buildSuccessRate = _computeBuildSuccessRate(
    releaseSummary,
    continuousReport,
  );
  final averageBuildDuration = _computeAverageBuildDuration(mobileSummary);
  final averageSpeedup = _computeAverageSpeedup(parallelProfile);
  final meanTimeToPatch = _computeMeanTimeToPatch(versionLog);
  final failureTrend = _computeFailureTrend(continuousReport);

  final console = _buildDashboard(
    generatedAt: generatedAt,
    buildSuccessRate: buildSuccessRate,
    averageBuildDuration: averageBuildDuration,
    averageSpeedup: averageSpeedup,
    meanTimeToPatch: meanTimeToPatch,
    failureTrend: failureTrend,
    colorize: true,
  );
  stdout.write(console);

  await reportDir.create(recursive: true);
  final reportFile = File('${reportDir.path}/developer_metrics.txt');
  final fileContent = _buildDashboard(
    generatedAt: generatedAt,
    buildSuccessRate: buildSuccessRate,
    averageBuildDuration: averageBuildDuration,
    averageSpeedup: averageSpeedup,
    meanTimeToPatch: meanTimeToPatch,
    failureTrend: failureTrend,
    colorize: false,
  );
  await reportFile.writeAsString(fileContent);

  final telemetry = jsonEncode({
    'event': 'developer_metrics_generated',
    'timestamp': generatedAt.toIso8601String(),
    if (buildSuccessRate != null) 'build_success_rate': buildSuccessRate,
    if (averageBuildDuration != null)
      'average_build_duration_sec': averageBuildDuration,
    if (averageSpeedup != null) 'average_ci_speedup_ratio': averageSpeedup,
    if (meanTimeToPatch != null) 'mean_time_to_patch_days': meanTimeToPatch,
    'failure_trend_available': failureTrend.isNotEmpty,
  });
  stdout.writeln(telemetry);
}

Future<List<String>> _readLines(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return const [];
  }
  final content = await file.readAsString();
  return content.split('\n');
}

double? _computeBuildSuccessRate(
  List<String> releaseSummary,
  List<String> continuousReport,
) {
  final statuses = <String>[];
  for (final line in releaseSummary) {
    if (line.trim().startsWith('Status:')) {
      statuses.add(line.trim().substring('Status:'.length).trim());
    }
  }
  for (final line in continuousReport) {
    if (line.contains('->')) {
      final parts = line.split('->');
      if (parts.length > 1) {
        final statusPart = parts[1].trim();
        if (statusPart.startsWith('PASS')) {
          statuses.add('PASS');
        } else if (statusPart.startsWith('FAIL')) {
          statuses.add('FAIL');
        }
      }
    }
  }
  if (statuses.isEmpty) {
    return null;
  }
  final recent = statuses.length > 10
      ? statuses.sublist(statuses.length - 10)
      : statuses;
  final successCount = recent.where((status) => status == 'PASS').length;
  return successCount / recent.length;
}

double? _computeAverageBuildDuration(List<String> mobileSummary) {
  if (mobileSummary.isEmpty) {
    return null;
  }
  final durations = <double>[];
  for (final line in mobileSummary) {
    if (line.trim().startsWith('Duration_sec:')) {
      final value = line.trim().substring('Duration_sec:'.length).trim();
      final parsed = double.tryParse(value);
      if (parsed != null) {
        durations.add(parsed);
      }
    }
  }
  if (durations.isEmpty) {
    return null;
  }
  final total = durations.reduce((a, b) => a + b);
  return total / durations.length;
}

double? _computeAverageSpeedup(List<String> parallelProfile) {
  if (parallelProfile.isEmpty) {
    return null;
  }
  final ratios = <double>[];
  for (final line in parallelProfile) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Speedup:')) {
      final value = trimmed.substring('Speedup:'.length).trim();
      final numeric = value.replaceAll('x', '');
      final parsed = double.tryParse(numeric);
      if (parsed != null) {
        ratios.add(parsed);
      }
    }
  }
  if (ratios.isEmpty) {
    return null;
  }
  final total = ratios.reduce((a, b) => a + b);
  return total / ratios.length;
}

double? _computeMeanTimeToPatch(List<String> versionLog) {
  final timestamps = <DateTime>[];
  for (final line in versionLog) {
    if (line.trim().startsWith('Timestamp:')) {
      final value = line.trim().substring('Timestamp:'.length).trim();
      try {
        timestamps.add(DateTime.parse(value).toUtc());
      } catch (_) {
        // Ignore malformed.
      }
    }
  }
  if (timestamps.length < 2) {
    return null;
  }
  timestamps.sort();
  final differences = <double>[];
  for (var i = 1; i < timestamps.length; i++) {
    final delta = timestamps[i].difference(timestamps[i - 1]).inHours / 24;
    differences.add(delta);
  }
  if (differences.isEmpty) {
    return null;
  }
  final total = differences.reduce((a, b) => a + b);
  return total / differences.length;
}

Map<String, String> _computeFailureTrend(List<String> continuousReport) {
  final trend = <String, String>{};
  for (final line in continuousReport) {
    if (!line.contains('->')) {
      continue;
    }
    final segments = line.split('->');
    if (segments.length < 2) {
      continue;
    }
    final stage = segments[0].trim();
    final status = segments[1].trim();
    if (stage.isEmpty) {
      continue;
    }
    if (status.startsWith('PASS')) {
      trend[stage] = 'PASS';
    } else if (status.startsWith('FAIL')) {
      trend[stage] = 'FAIL';
    }
  }
  return trend;
}

String _buildDashboard({
  required DateTime generatedAt,
  required double? buildSuccessRate,
  required double? averageBuildDuration,
  required double? averageSpeedup,
  required double? meanTimeToPatch,
  required Map<String, String> failureTrend,
  required bool colorize,
}) {
  String color(String code, String text) {
    if (!colorize) {
      return text;
    }
    return '$code$text\x1B[0m';
  }

  String formatPercent(double? value) {
    return value == null ? 'N/A' : '${(value * 100).toStringAsFixed(1)}%';
  }

  String formatNumber(double? value, {String suffix = ''}) {
    return value == null ? 'N/A' : '${value.toStringAsFixed(2)}$suffix';
  }

  final buffer = StringBuffer()
    ..writeln(color('\x1B[36m', '=== Developer Metrics Dashboard ==='))
    ..writeln('Generated: ${generatedAt.toIso8601String()}')
    ..writeln('')
    ..writeln('Key Metrics:')
    ..writeln(
      ' - Build Success Rate: ${color('\x1B[32m', formatPercent(buildSuccessRate))}',
    )
    ..writeln(
      ' - Average Build Duration: ${color('\x1B[33m', formatNumber(averageBuildDuration, suffix: 's'))}',
    )
    ..writeln(
      ' - Average CI Speedup: ${color('\x1B[35m', formatNumber(averageSpeedup, suffix: 'x'))}',
    )
    ..writeln(
      ' - Mean Time To Patch: ${color('\x1B[34m', formatNumber(meanTimeToPatch, suffix: ' days'))}',
    )
    ..writeln('')
    ..writeln('Failure Trend:');

  if (failureTrend.isEmpty) {
    buffer.writeln(' - N/A');
  } else {
    for (final entry in failureTrend.entries) {
      final statusColor = entry.value == 'PASS' ? '\x1B[32m' : '\x1B[31m';
      buffer.writeln(' - ${entry.key}: ${color(statusColor, entry.value)}');
    }
  }

  buffer.writeln('');
  buffer.writeln('ASCII Bars:');
  buffer.writeln(
    _buildBar('Build Success', buildSuccessRate, colorize ? '\x1B[32m' : ''),
  );
  buffer.writeln(
    _buildBar(
      'CI Speedup',
      averageSpeedup != null
          ? (averageSpeedup / 4).clamp(0.0, 1.0).toDouble()
          : null,
      colorize ? '\x1B[35m' : '',
    ),
  );
  buffer.writeln(
    _buildBar(
      'Patch Cadence',
      meanTimeToPatch != null
          ? (1 / (1 + meanTimeToPatch)).clamp(0.0, 1.0).toDouble()
          : null,
      colorize ? '\x1B[34m' : '',
    ),
  );

  return buffer.toString();
}

String _buildBar(String label, double? ratio, String colorCode) {
  if (ratio == null) {
    return '$label | N/A';
  }
  final clamped = ratio.clamp(0.0, 1.0).toDouble();
  final filled = ((clamped * 30).round()).clamp(0, 30);
  final filledInt = filled.toInt();
  final bar = '${'#' * filledInt}${'-' * (30 - filledInt)}';
  final reset = colorCode.isEmpty ? '' : '\x1B[0m';
  return '$label | $colorCode[$bar]$reset ${(clamped * 100).toStringAsFixed(1)}%';
}
