import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath = '$_reportsDir/engagement_economy_summary.txt';
const String _summaryJsonPath = '$_reportsDir/engagement_economy_summary.json';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final bridge = EngagementEconomyBridge();
  final ok = await bridge.run();
  if (!ok) {
    exitCode = 2;
  }
}

class EngagementEconomyBridge {
  Future<bool> run() async {
    final retention = await _readRetentionScore();
    final monetization = await _readMonetizationIndex();
    final xpEfficiency = await _readXpEfficiency();

    if (retention == null || monetization == null || xpEfficiency == null) {
      stderr.writeln('Missing retention, monetization, or XP inputs.');
      return false;
    }

    final score =
        (0.4 * retention) + (0.35 * monetization) + (0.25 * xpEfficiency);
    final verdict = score >= _threshold ? 'PASS' : 'FAIL';

    final summaryText = _buildTextSummary(
      retention: retention,
      monetization: monetization,
      xpEfficiency: xpEfficiency,
      score: score,
      verdict: verdict,
    );
    final summaryJson = _buildJsonSummary(
      retention: retention,
      monetization: monetization,
      xpEfficiency: xpEfficiency,
      score: score,
      verdict: verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        retention,
        monetization,
        xpEfficiency,
        score,
        verdict,
      );
    });

    if (verdict == 'FAIL') {
      stderr.writeln(
        'Engagement Economy Score ${score.toStringAsFixed(4)} < $_threshold.',
      );
    }

    return verdict == 'PASS';
  }

  Future<double?> _readRetentionScore() async {
    final file = File('$_reportsDir/retention_marketing_loop_v2_summary.json');
    if (!await file.exists()) return null;
    final data = json.decode(await file.readAsString());
    if (data is Map<String, Object?>) {
      return _asDouble(data['retention_score']);
    }
    return null;
  }

  Future<double?> _readMonetizationIndex() async {
    final file = File('$_reportsDir/global_monetization_summary.json');
    if (!await file.exists()) return null;
    final data = json.decode(await file.readAsString());
    if (data is Map<String, Object?>) {
      return _asDouble(data['global_monetization_index']);
    }
    return null;
  }

  Future<double?> _readXpEfficiency() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return null;
    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 24));
    final lines = await file.readAsLines();
    for (final line in lines.reversed) {
      if (line.trim().isEmpty) continue;
      Map<String, Object?>? payload;
      try {
        payload = json.decode(line) as Map<String, Object?>;
      } catch (_) {
        continue;
      }
      if (payload['event'] == 'profile_persistence_completed' &&
          payload['timestamp'] is String) {
        final timestamp = DateTime.tryParse(payload['timestamp'] as String);
        if (timestamp == null || timestamp.isBefore(cutoff)) {
          continue;
        }
        final xpTotal = _asDouble(payload['xp_total']);
        if (xpTotal == null) continue;
        return (xpTotal / 1000).clamp(0.0, 1.0);
      }
    }
    return null;
  }

  String _buildTextSummary({
    required double retention,
    required double monetization,
    required double xpEfficiency,
    required double score,
    required String verdict,
  }) {
    final buffer = StringBuffer()
      ..writeln('ENGAGEMENT ECONOMY BRIDGE')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Retention component: ${(retention * 100).toStringAsFixed(2)}%')
      ..writeln(
        'Monetization component: ${(monetization * 100).toStringAsFixed(2)}%',
      )
      ..writeln(
        'XP efficiency component: ${(xpEfficiency * 100).toStringAsFixed(2)}%',
      )
      ..writeln(
        'Engagement Economy Score: ${(score * 100).toStringAsFixed(2)}%',
      )
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required double retention,
    required double monetization,
    required double xpEfficiency,
    required double score,
    required String verdict,
  }) => {
    'generated_at': DateTime.now().toIso8601String(),
    'retention_score': retention,
    'monetization_index': monetization,
    'xp_efficiency': xpEfficiency,
    'engagement_economy_score': score,
    'threshold': _threshold,
    'verdict': verdict,
  };

  Future<void> _appendTelemetry(
    double retention,
    double monetization,
    double xpEfficiency,
    double score,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'engagement_economy_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'retention_score': retention,
      'monetization_index': monetization,
      'xp_efficiency': xpEfficiency,
      'engagement_economy_score': score,
      'verdict': verdict,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
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
