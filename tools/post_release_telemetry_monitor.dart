import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath =
    '$_reportsDir/post_release_telemetry_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/post_release_telemetry_summary.json';

const double _coverageThreshold = 90.0;
const double _anomalyThreshold = 15.0;
const double _lowActivityThreshold = 0.5; // average per hour
const Duration _window = Duration(hours: 24);
const Duration _keyWindow = _window;

Future<void> main(List<String> args) async {
  final monitor = PostReleaseTelemetryMonitor();
  final ok = await monitor.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PostReleaseTelemetryMonitor {
  Future<bool> run() async {
    final telemetryFile = File(_telemetryPath);
    if (!await telemetryFile.exists()) {
      stderr.writeln('Telemetry file not found at $_telemetryPath');
      return false;
    }

    final now = DateTime.now().toUtc();
    final cutoff = now.subtract(_window);
    final fallbackHour = _hourKey(now);

    final lines = await telemetryFile.readAsLines();
    final stats = <String, _EventStats>{};
    final keyEvents = <String>{};

    for (final line in lines) {
      if (line.trim().isEmpty) {
        continue;
      }
      Map<String, Object?>? payload;
      try {
        payload = json.decode(line) as Map<String, Object?>?;
      } catch (_) {
        continue;
      }
      if (payload == null) {
        continue;
      }
      final event = payload['event'] as String?;
      if (event == null || !event.endsWith('_completed')) {
        continue;
      }
      final timestampStr = payload['timestamp'] as String?;
      if (timestampStr == null) {
        continue;
      }
      DateTime timestamp;
      try {
        timestamp = DateTime.parse(timestampStr).toUtc();
      } catch (_) {
        continue;
      }
      if (timestamp.isBefore(now.subtract(_keyWindow))) {
        continue;
      }
      keyEvents.add(event);
      if (timestamp.isBefore(cutoff)) {
        continue;
      }
      final eventStats = stats.putIfAbsent(event, _EventStats.new);
      eventStats.add(timestamp);
    }

    if (keyEvents.isEmpty) {
      stderr.writeln(
        'No *_completed telemetry events found in the key window.',
      );
      return false;
    }

    DateTime referenceHour = fallbackHour;
    for (final entry in stats.values) {
      final latest = entry.latestHour;
      if (latest != null && latest.isAfter(referenceHour)) {
        referenceHour = latest;
      }
    }

    final reports = <_EventReport>[];
    final sortedEvents = keyEvents.toList()..sort();
    bool anomalyDetected = false;
    final lowActivityEvents = <String>[];

    for (final event in sortedEvents) {
      final eventStats = stats[event];
      final totalCount = eventStats?.totalCount ?? 0;
      final averagePerHour = totalCount == 0
          ? 0.0
          : totalCount.toDouble() / _window.inHours;
      final eventReferenceHour = eventStats?.latestHour ?? referenceHour;
      final lastHourCount = eventStats?.countForHour(eventReferenceHour) ?? 0;
      final deviation = averagePerHour > 0
          ? ((lastHourCount - averagePerHour) / averagePerHour) * 100.0
          : 0.0;
      final sampleFloorMet = totalCount >= _window.inHours;
      final isAnomaly =
          sampleFloorMet && averagePerHour > 0 && lastHourCount == 0;
      final isLowActivity = averagePerHour < _lowActivityThreshold;
      if (isAnomaly) {
        anomalyDetected = true;
      }
      if (isLowActivity) {
        lowActivityEvents.add(event);
      }
      reports.add(
        _EventReport(
          name: event,
          totalCount: totalCount,
          averagePerHour: averagePerHour,
          lastHourCount: lastHourCount,
          deviationPercent: deviation,
          anomaly: isAnomaly,
          lowActivity: isLowActivity,
          lastObservedHour: eventReferenceHour,
        ),
      );
    }

    final healthyModules = reports
        .where((report) => report.totalCount > 0)
        .length;
    final coverage = reports.isEmpty
        ? 0.0
        : healthyModules * 100.0 / reports.length;

    final success = coverage >= _coverageThreshold && !anomalyDetected;

    final summaryText = _buildTextSummary(
      generatedAt: now,
      coverage: coverage,
      anomalyDetected: anomalyDetected,
      lowActivityEvents: lowActivityEvents,
      reports: reports,
      referenceHour: referenceHour,
    );
    final summaryJson = _buildJsonSummary(
      generatedAt: now,
      coverage: coverage,
      anomalyDetected: anomalyDetected,
      reports: reports,
      success: success,
      referenceHour: referenceHour,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        coverage: coverage,
        anomalyDetected: anomalyDetected,
        lowActivity: lowActivityEvents,
        success: success,
      );
    });

    if (!success) {
      stderr.writeln(
        'Post-release telemetry monitor failed: coverage=${coverage.toStringAsFixed(2)}%, '
        'anomalyDetected=$anomalyDetected',
      );
    }

    return success;
  }

  String _buildTextSummary({
    required DateTime generatedAt,
    required double coverage,
    required bool anomalyDetected,
    required List<String> lowActivityEvents,
    required List<_EventReport> reports,
    required DateTime referenceHour,
  }) {
    final buffer = StringBuffer()
      ..writeln('POST-RELEASE TELEMETRY SUMMARY')
      ..writeln('Generated: ${generatedAt.toIso8601String()}')
      ..writeln(
        'Coverage (modules active in last 24h): '
        '${coverage.toStringAsFixed(2)}% (threshold ${_coverageThreshold.toStringAsFixed(0)}%)',
      )
      ..writeln('Last observed hour: ${referenceHour.toIso8601String()}')
      ..writeln('Anomaly detected: ${anomalyDetected ? 'YES' : 'NO'}')
      ..writeln()
      ..writeln(
        'Low activity modules (avg/hr < ${_lowActivityThreshold.toStringAsFixed(2)}):',
      );
    if (lowActivityEvents.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final event in lowActivityEvents) {
        buffer.writeln('- $event');
      }
    }
    buffer
      ..writeln()
      ..writeln('Per-event metrics (last 24h):')
      ..writeln('Event | Total | Avg/hr | Last hr | Deviation% | Flags');
    for (final report in reports) {
      final flags = <String>[];
      if (report.anomaly) flags.add('ANOMALY');
      if (report.lowActivity) flags.add('LOW');
      buffer.writeln(
        '${report.name} | ${report.totalCount} | '
        '${report.averagePerHour.toStringAsFixed(2)} | '
        '${report.lastHourCount} | '
        '${report.deviationPercent.toStringAsFixed(2)} | '
        '${flags.isEmpty ? 'OK' : flags.join('+')}',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required DateTime generatedAt,
    required double coverage,
    required bool anomalyDetected,
    required List<_EventReport> reports,
    required bool success,
    required DateTime referenceHour,
  }) {
    return {
      'generated_at': generatedAt.toIso8601String(),
      'coverage_percent': coverage,
      'coverage_threshold': _coverageThreshold,
      'anomaly_detected': anomalyDetected,
      'anomaly_threshold_percent': _anomalyThreshold,
      'last_observed_hour': referenceHour.toIso8601String(),
      'events': reports.map((report) => report.toJson()).toList(),
      'verdict': success ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry({
    required double coverage,
    required bool anomalyDetected,
    required List<String> lowActivity,
    required bool success,
  }) async {
    final payload = <String, Object?>{
      'event': 'post_release_telemetry_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'coverage_percent': coverage,
      'anomaly_detected': anomalyDetected,
      'low_activity_events': lowActivity,
      'verdict': success ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _EventStats {
  void add(DateTime timestamp) {
    totalCount += 1;
    final hour = _hourKey(timestamp);
    hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
    if (latestHour == null || hour.isAfter(latestHour!)) {
      latestHour = hour;
    }
  }

  int countForHour(DateTime hour) => hourlyCounts[hour] ?? 0;

  int totalCount = 0;
  final Map<DateTime, int> hourlyCounts = <DateTime, int>{};
  DateTime? latestHour;
}

class _EventReport {
  _EventReport({
    required this.name,
    required this.totalCount,
    required this.averagePerHour,
    required this.lastHourCount,
    required this.deviationPercent,
    required this.anomaly,
    required this.lowActivity,
    required this.lastObservedHour,
  });

  final String name;
  final int totalCount;
  final double averagePerHour;
  final int lastHourCount;
  final double deviationPercent;
  final bool anomaly;
  final bool lowActivity;
  final DateTime? lastObservedHour;

  Map<String, Object?> toJson() {
    return {
      'event': name,
      'total_count': totalCount,
      'average_per_hour': averagePerHour,
      'last_hour_count': lastHourCount,
      'deviation_percent': deviationPercent,
      'anomaly': anomaly,
      'low_activity': lowActivity,
      'last_observed_hour': lastObservedHour?.toIso8601String(),
    };
  }
}

DateTime _hourKey(DateTime timestamp) => DateTime.utc(
  timestamp.year,
  timestamp.month,
  timestamp.day,
  timestamp.hour,
);

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore chmod failures
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
