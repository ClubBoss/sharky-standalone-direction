import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _funnelSummaryPath = '$_reportsDir/marketing_funnel_summary.txt';
const String _summaryTextPath = '$_reportsDir/retention_campaign_summary.txt';
const String _summaryJsonPath = '$_reportsDir/retention_campaign_summary.json';

const double _minRetentionIndex = 0.65;
const int _minSampleSize = 100;

Future<void> main(List<String> args) async {
  final engine = RetentionCampaignEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RetentionCampaignEngine {
  Future<bool> run() async {
    final telemetry = await _loadTelemetry();
    final stats = _computeRetentionStats(telemetry);
    final campaigns = await _parseCampaignConversions();

    final pass =
        stats.retentionIndex >= _minRetentionIndex &&
        stats.sampleSize >= _minSampleSize;

    final summaryText = _buildTextSummary(stats, campaigns, pass);
    final summaryJson = _buildJsonSummary(stats, campaigns, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(stats, campaigns, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Retention Index ${stats.retentionIndex.toStringAsFixed(3)} with sample '
        '${stats.sampleSize} below thresholds.',
      );
    }

    return pass;
  }

  Future<List<Map<String, Object?>>> _loadTelemetry() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return const [];
    final entries = <Map<String, Object?>>[];
    try {
      final lines = await file.readAsLines();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        try {
          final decoded = json.decode(trimmed);
          if (decoded is Map<String, Object?>) {
            entries.add(decoded);
          }
        } catch (_) {
          // ignore malformed telemetry lines
        }
      }
    } catch (_) {
      // ignore IO errors and return whatever we have
    }
    return entries;
  }

  _RetentionStats _computeRetentionStats(List<Map<String, Object?>> telemetry) {
    final now = DateTime.now();
    final cutoff7 = now.subtract(const Duration(days: 7));
    final cutoff30 = now.subtract(const Duration(days: 30));
    final last7 = <String>{};
    final last30 = <String>{};

    for (final entry in telemetry) {
      final event = entry['event']?.toString();
      if (event == null ||
          (event != 'session_start' &&
              event != 'session_end' &&
              event != 'session_abort')) {
        continue;
      }
      final timestampStr = entry['timestamp']?.toString();
      if (timestampStr == null) continue;
      DateTime timestamp;
      try {
        timestamp = DateTime.parse(timestampStr);
      } catch (_) {
        continue;
      }
      final id = _extractIdentity(entry);
      if (id == null) continue;
      if (timestamp.isAfter(cutoff30)) {
        last30.add(id);
      }
      if (timestamp.isAfter(cutoff7)) {
        last7.add(id);
      }
    }

    final sample = last30.length;
    final retentionIndex = sample == 0
        ? 0.0
        : last7.length / sample.clamp(1, double.maxFinite).toDouble();

    return _RetentionStats(
      activeLast7: last7.length,
      activeLast30: sample,
      retentionIndex: retentionIndex,
      sampleSize: sample,
    );
  }

  String? _extractIdentity(Map<String, Object?> entry) {
    final candidates = [
      entry['sessionId'],
      entry['session_id'],
      entry['userId'],
      entry['user_id'],
      entry['player_id'],
      entry['profile_id'],
    ];
    for (final candidate in candidates) {
      if (candidate == null) continue;
      final value = candidate.toString();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  Future<List<_CampaignConversion>> _parseCampaignConversions() async {
    final file = File(_funnelSummaryPath);
    if (!await file.exists()) return const [];
    final campaigns = <_CampaignConversion>[];
    final lines = await file.readAsLines();
    final regex = RegExp(
      r'(?:Campaign|campaign)\s+([A-Za-z0-9_\- ]+):\s*([0-9.]+)%',
    );
    for (final line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final name = match.group(1)?.trim() ?? 'unknown';
        final value = double.tryParse(match.group(2) ?? '');
        if (value != null) {
          campaigns.add(_CampaignConversion(name: name, conversion: value));
        }
      }
    }
    return campaigns;
  }

  String _buildTextSummary(
    _RetentionStats stats,
    List<_CampaignConversion> campaigns,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('RETENTION CAMPAIGN SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Retention Index (7d/30d): ${stats.retentionIndex.toStringAsFixed(3)}',
      )
      ..writeln('Active users (7d): ${stats.activeLast7}')
      ..writeln('Active users (30d): ${stats.activeLast30}')
      ..writeln('Sample size: ${stats.sampleSize}')
      ..writeln(
        'Threshold: index >= $_minRetentionIndex & sample >= $_minSampleSize',
      )
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln();
    if (campaigns.isNotEmpty) {
      buffer.writeln('Campaign conversions:');
      for (final campaign in campaigns) {
        buffer.writeln(
          '  - ${campaign.name}: ${campaign.conversion.toStringAsFixed(2)}%',
        );
      }
    } else {
      buffer.writeln('No campaign conversion data found.');
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    _RetentionStats stats,
    List<_CampaignConversion> campaigns,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'retention_index': stats.retentionIndex,
      'active_last_7d': stats.activeLast7,
      'active_last_30d': stats.activeLast30,
      'sample_size': stats.sampleSize,
      'thresholds': {
        'retention_index': _minRetentionIndex,
        'sample_size': _minSampleSize,
      },
      'verdict': pass ? 'PASS' : 'FAIL',
      'campaign_conversions': campaigns
          .map(
            (campaign) => {
              'name': campaign.name,
              'conversion': campaign.conversion,
            },
          )
          .toList(),
    };
  }

  Future<void> _appendTelemetry(
    _RetentionStats stats,
    List<_CampaignConversion> campaigns,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'retention_campaign_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'retention_index': stats.retentionIndex,
      'active_last_7d': stats.activeLast7,
      'active_last_30d': stats.activeLast30,
      'sample_size': stats.sampleSize,
      'campaign_count': campaigns.length,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _RetentionStats {
  const _RetentionStats({
    required this.activeLast7,
    required this.activeLast30,
    required this.retentionIndex,
    required this.sampleSize,
  });

  final int activeLast7;
  final int activeLast30;
  final double retentionIndex;
  final int sampleSize;
}

class _CampaignConversion {
  const _CampaignConversion({required this.name, required this.conversion});

  final String name;
  final double conversion;
}

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
      // ignore failures
    }
  }
}
