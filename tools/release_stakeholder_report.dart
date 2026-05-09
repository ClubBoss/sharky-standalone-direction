import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final sw = Stopwatch()..start();
  final collector = _StakeholderCollector();
  final data = await collector.collect();
  await data.writeMarkdown('release/_reports/release_stakeholder_report.md');
  data.emitTelemetry(sw.elapsed);
}

class _StakeholderCollector {
  Future<_StakeholderData> collect() async {
    final summaries = await _loadSummaries();
    final qaPassRate = _parseDouble(summaries.values, 'pass_rate') ?? 0;
    final qaWarnings = _parseInt(summaries.values, 'warnings') ?? 0;

    final marketingMissingFiles =
        _parseInt(summaries.values, 'missing_files') ?? 0;
    final marketingMissingPubspec =
        _parseInt(summaries.values, 'missing_pubspec') ?? 0;

    final governanceStatus =
        _parseString(summaries['governance_integrity_summary.txt'], 'status') ??
        'UNKNOWN';
    final governanceMismatches = _parseInt(summaries.values, 'mismatches') ?? 0;

    final aiMetrics = _parseAiReliability(summaries);
    final telemetryStats = await _readTelemetry();

    final nextSteps = <String>[];
    if (qaWarnings > 0) {
      nextSteps.add('Resolve $qaWarnings QA warnings from launch readiness.');
    }
    final marketingIssues = marketingMissingFiles + marketingMissingPubspec;
    if (marketingIssues > 0) {
      nextSteps.add('Fix $marketingIssues marketing asset gaps.');
    }
    if (governanceStatus != 'PASS' || governanceMismatches > 0) {
      nextSteps.add('Reconcile governance log entries for archived reports.');
    }
    if (nextSteps.isEmpty) {
      nextSteps.add('Continue monitoring telemetry and retention signals.');
    }

    return _StakeholderData(
      qaPassRate: qaPassRate,
      qaWarnings: qaWarnings,
      marketingIssues: marketingIssues,
      governanceStatus: governanceStatus,
      aiReliability: aiMetrics,
      telemetryEvents: telemetryStats.events,
      telemetryUnique: telemetryStats.uniqueEvents,
      nextSteps: nextSteps,
    );
  }

  Future<Map<String, String>> _loadSummaries() async {
    final dir = Directory('release/_reports');
    final result = <String, String>{};
    if (!dir.existsSync()) {
      return result;
    }
    for (final entity in dir.listSync()) {
      if (entity is File &&
          entity.path.endsWith('.txt') &&
          entity.path.contains('summary')) {
        result[entity.uri.pathSegments.last] = await entity.readAsString();
      }
    }
    return result;
  }

  double? _parseDouble(Iterable<String> contents, String key) {
    final regex = RegExp('$key=([0-9.]+)');
    for (final content in contents) {
      final match = regex.firstMatch(content);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  int? _parseInt(Iterable<String> contents, String key) {
    final regex = RegExp('$key=([0-9]+)');
    for (final content in contents) {
      final match = regex.firstMatch(content);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  String? _parseString(String? content, String key) {
    if (content == null) return null;
    final regex = RegExp('$key=([A-Z]+)');
    final match = regex.firstMatch(content);
    return match?.group(1);
  }

  String _parseAiReliability(Map<String, String> summaries) {
    final entry = summaries.entries.firstWhere(
      (e) => e.key.contains('ai_reliability'),
      orElse: () => const MapEntry('', ''),
    );
    if (entry.key.isEmpty) {
      return 'Not available';
    }
    final pattern = RegExp(r'result=([A-Za-z0-9 .%-]+)');
    final match = pattern.firstMatch(entry.value);
    return match?.group(1) ?? 'Not available';
  }

  Future<_TelemetryStats> _readTelemetry() async {
    final file = File('release/_reports/telemetry.jsonl');
    if (!file.existsSync()) {
      return const _TelemetryStats(events: 0, uniqueEvents: 0);
    }
    final lines = await file.readAsLines();
    final counts = <String, int>{};
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final payload = jsonDecode(line);
        if (payload is Map && payload['event'] is String) {
          final name = payload['event'] as String;
          counts[name] = (counts[name] ?? 0) + 1;
        }
      } catch (_) {
        continue;
      }
    }
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    return _TelemetryStats(events: total, uniqueEvents: counts.length);
  }
}

class _TelemetryStats {
  const _TelemetryStats({required this.events, required this.uniqueEvents});

  final int events;
  final int uniqueEvents;
}

class _StakeholderData {
  _StakeholderData({
    required this.qaPassRate,
    required this.qaWarnings,
    required this.marketingIssues,
    required this.governanceStatus,
    required this.aiReliability,
    required this.telemetryEvents,
    required this.telemetryUnique,
    required this.nextSteps,
  });

  final double qaPassRate;
  final int qaWarnings;
  final int marketingIssues;
  final String governanceStatus;
  final String aiReliability;
  final int telemetryEvents;
  final int telemetryUnique;
  final List<String> nextSteps;

  Future<void> writeMarkdown(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('# Release Stakeholder Report')
      ..writeln()
      ..writeln('## QA')
      ..writeln('- Pass rate: ${qaPassRate.toStringAsFixed(2)}%')
      ..writeln('- Warnings: $qaWarnings')
      ..writeln('- AI reliability: $aiReliability')
      ..writeln()
      ..writeln('## Brand')
      ..writeln('- Marketing issues: $marketingIssues')
      ..writeln()
      ..writeln('## Governance')
      ..writeln('- Status: $governanceStatus')
      ..writeln()
      ..writeln('## Telemetry')
      ..writeln('- Total events: $telemetryEvents')
      ..writeln('- Unique events: $telemetryUnique')
      ..writeln()
      ..writeln('## Next Steps');
    for (final step in nextSteps) {
      buffer.writeln('- $step');
    }
    await file.writeAsString(buffer.toString());
  }

  void emitTelemetry(Duration duration) {
    final payload = <String, Object>{
      'event': 'release_stakeholder_report_completed',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'duration_ms': duration.inMilliseconds,
      'sections': 5,
      'qa_pass_rate': qaPassRate,
      'marketing_issues': marketingIssues,
      'governance_status': governanceStatus,
      'telemetry_events': telemetryEvents,
    };
    stdout.writeln(jsonEncode(payload));
  }
}
