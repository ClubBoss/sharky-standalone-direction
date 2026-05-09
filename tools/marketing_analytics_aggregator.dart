import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final aggregator = _MarketingAnalyticsAggregator();
  final report = aggregator.run();
  report.printTable();
  await report.writeSummary('release/_reports/marketing_analytics_summary.txt');
  report.emitTelemetry();
}

class _MarketingAnalyticsAggregator {
  static const String _telemetryLog = 'release/_reports/telemetry.jsonl';
  static const String _metadataPath =
      'release/_reports/marketing_metadata.json';
  static const String _packagingPath =
      'release/_reports/release_packaging_summary.txt';

  _AnalyticsReport run() {
    final telemetryFile = File(_telemetryLog);
    final metadataFile = File(_metadataPath);
    final packagingFile = File(_packagingPath);

    for (final file in [telemetryFile, metadataFile, packagingFile]) {
      if (!file.existsSync()) {
        stderr.writeln('Missing required file: ${file.path}');
        exit(1);
      }
    }

    final telemetryStats = _TelemetryStats.parse(
      telemetryFile.readAsLinesSync(),
    );
    final metadata = jsonDecode(metadataFile.readAsStringSync());
    if (metadata is! Map<String, dynamic>) {
      stderr.writeln('Invalid marketing_metadata.json payload.');
      exit(1);
    }

    final packagingSummary = packagingFile.readAsLinesSync().join('\n');
    final packagingPass = packagingSummary.contains('Overall: PASS');

    return _AnalyticsReport(
      marketingMetadata: metadata,
      telemetryStats: telemetryStats,
      packagingPass: packagingPass,
    );
  }
}

class _TelemetryStats {
  _TelemetryStats({
    required this.dailyActiveUsers,
    required this.conversionRate,
    required this.retentionDelta,
    required this.averageSessionDurationSeconds,
  });

  final int dailyActiveUsers;
  final double conversionRate;
  final double retentionDelta;
  final double averageSessionDurationSeconds;

  static _TelemetryStats parse(List<String> lines) {
    final userSets = <String, Set<String>>{};
    final sessionDurations = <double>[];
    var conversionCandidates = 0;
    var conversions = 0;
    double retentionSum = 0;
    var retentionCount = 0;

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      Map<String, dynamic> data;
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          continue;
        }
      } catch (_) {
        stderr.writeln('Malformed telemetry row: $line');
        exit(1);
      }

      final timestamp = _parseTimestamp(data['timestamp']);
      final userId = _firstString(data, const [
        'user_id',
        'userId',
        'uid',
        'user',
        'player_id',
      ]);
      if (timestamp != null && userId != null && userId.isNotEmpty) {
        final day = timestamp.toUtc().toIso8601String().split('T').first;
        userSets.putIfAbsent(day, () => <String>{}).add(userId);
      }

      final durationMs = _firstNum(data, const [
        'session_duration_ms',
        'sessionDurationMs',
        'duration_ms',
      ]);
      if (durationMs != null) {
        sessionDurations.add(durationMs.toDouble());
      }

      final converted = _firstBool(data, const [
        'converted',
        'conversion',
        'didConvert',
        'purchase',
      ]);
      if (converted != null) {
        conversionCandidates++;
        if (converted) conversions++;
      }

      final retentionIndex = _firstNum(data, const [
        'retentionIndex',
        'retention_index',
      ]);
      if (retentionIndex != null) {
        retentionSum += retentionIndex.toDouble();
        retentionCount++;
      }
    }

    final latestDay = userSets.keys.isEmpty
        ? null
        : userSets.keys.reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
    final dau = latestDay == null ? 0 : userSets[latestDay]!.length;
    final double conversionRate = conversionCandidates == 0
        ? 0
        : conversions / conversionCandidates;
    final double retentionDelta = retentionCount == 0
        ? 0
        : (retentionSum / retentionCount) - 1.0;
    final double avgSessionDurationSeconds = sessionDurations.isEmpty
        ? 0
        : (sessionDurations.reduce((a, b) => a + b) /
              sessionDurations.length /
              1000);

    return _TelemetryStats(
      dailyActiveUsers: dau,
      conversionRate: conversionRate,
      retentionDelta: retentionDelta,
      averageSessionDurationSeconds: avgSessionDurationSeconds,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String? _firstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String) {
        return value;
      }
    }
    return null;
  }

  static num? _firstNum(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is num) {
        return value;
      }
    }
    return null;
  }

  static bool? _firstBool(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is bool) {
        return value;
      }
      if (value is num) {
        if (value == 1) return true;
        if (value == 0) return false;
      }
      if (value is String) {
        final normalized = value.toLowerCase();
        if (normalized == 'true' || normalized == 'yes') return true;
        if (normalized == 'false' || normalized == 'no') return false;
      }
    }
    return null;
  }
}

class _AnalyticsReport {
  _AnalyticsReport({
    required this.marketingMetadata,
    required this.telemetryStats,
    required this.packagingPass,
  });

  final Map<String, dynamic> marketingMetadata;
  final _TelemetryStats telemetryStats;
  final bool packagingPass;

  void printTable() {
    const border = '+---------------------------+-------------------+';
    stdout.writeln(border);
    stdout.writeln('| Metric                    | Value             |');
    stdout.writeln(border);
    stdout.writeln(
      '| Daily Active Users        | '
      '${telemetryStats.dailyActiveUsers.toString().padLeft(17)} |',
    );
    stdout.writeln(
      '| Conversion Rate           | '
      '${_formatPercent(telemetryStats.conversionRate).padLeft(17)} |',
    );
    stdout.writeln(
      '| Retention Delta           | '
      '${_formatDelta(telemetryStats.retentionDelta).padLeft(17)} |',
    );
    stdout.writeln(
      '| Avg Session Duration (s)  | '
      '${telemetryStats.averageSessionDurationSeconds.toStringAsFixed(1).padLeft(17)} |',
    );
    stdout.writeln(
      '| Packaging Status          | '
      '${(packagingPass ? 'PASS' : 'FAIL').padLeft(17)} |',
    );
    stdout.writeln(
      '| Campaign                  | '
      '${_campaign.padLeft(17)} |',
    );
    stdout.writeln(border);
  }

  Future<void> writeSummary(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Marketing Analytics Summary')
      ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln()
      ..writeln('Version: ${marketingMetadata['version'] ?? 'n/a'}')
      ..writeln('Build: ${marketingMetadata['build'] ?? 'n/a'}')
      ..writeln('Campaign: $_campaign')
      ..writeln('Packaging Status: ${packagingPass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Daily Active Users: ${telemetryStats.dailyActiveUsers}')
      ..writeln(
        'Conversion Rate: ${_formatPercent(telemetryStats.conversionRate)}',
      )
      ..writeln(
        'Retention Delta: ${_formatDelta(telemetryStats.retentionDelta)}',
      )
      ..writeln(
        'Avg Session Duration: '
        '${telemetryStats.averageSessionDurationSeconds.toStringAsFixed(1)} s',
      );
    await file.writeAsString(buffer.toString());
  }

  void emitTelemetry() {
    final payload = <String, Object>{
      'event': TelemetryEvents.marketingAnalyticsCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'daily_active_users': telemetryStats.dailyActiveUsers,
      'conversion_rate': double.parse(
        telemetryStats.conversionRate.toStringAsFixed(4),
      ),
      'retention_delta': double.parse(
        telemetryStats.retentionDelta.toStringAsFixed(4),
      ),
      'avg_session_duration_sec': double.parse(
        telemetryStats.averageSessionDurationSeconds.toStringAsFixed(2),
      ),
      'packaging_pass': packagingPass,
      'campaign': _campaign,
    };
    stdout.writeln(jsonEncode(payload));
  }

  String get _campaign {
    final value = marketingMetadata['campaign'];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return 'unknown';
  }

  static String _formatPercent(double value) =>
      '${(value * 100).toStringAsFixed(2)}%';

  static String _formatDelta(double value) =>
      value >= 0 ? '+${value.toStringAsFixed(3)}' : value.toStringAsFixed(3);
}
