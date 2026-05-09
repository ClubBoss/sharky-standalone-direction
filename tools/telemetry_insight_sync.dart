import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath = '$_reportsDir/telemetry_insight_summary.txt';
const String _summaryJsonPath = '$_reportsDir/telemetry_insight_summary.json';

const double _threshold = 0.90;
const Duration _window = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final sync = TelemetryInsightSync();
  final ok = await sync.run();
  if (!ok) {
    exitCode = 2;
  }
}

class TelemetryInsightSync {
  Future<bool> run() async {
    final now = DateTime.now().toUtc();
    final cutoff = now.subtract(_window);
    final entries = await _readRecentEntries(cutoff);
    if (entries.isEmpty) {
      stderr.writeln('Telemetry log empty for the last 24h.');
      return false;
    }

    final visualEvents = <DateTime, String>{};
    final explanationEvents = <DateTime>[];
    final persistenceEvents = <DateTime>[];

    for (final entry in entries) {
      final event = entry['event'] as String?;
      if (event == null) continue;
      final ts = entry['timestamp'] as String?;
      if (ts == null) continue;
      final timestamp = DateTime.tryParse(ts)?.toUtc();
      if (timestamp == null) continue;
      switch (event) {
        case 'visual_interaction_qa_completed':
          final verdict = entry['verdict'] as String? ?? 'FAIL';
          visualEvents[timestamp] = verdict;
          break;
        case 'player_explanation_completed':
          explanationEvents.add(timestamp);
          break;
        case 'profile_persistence_completed':
          persistenceEvents.add(timestamp);
          break;
      }
    }

    if (visualEvents.isEmpty ||
        explanationEvents.isEmpty ||
        persistenceEvents.isEmpty) {
      stderr.writeln('Missing required telemetry events.');
      return false;
    }

    final latencies = _computeLatencyGaps(explanationEvents, persistenceEvents);
    if (latencies.isEmpty) {
      stderr.writeln('No latency pairs found.');
      return false;
    }

    final meanGapMs = latencies.reduce((a, b) => a + b) / latencies.length;
    final passRate = _computePassRate(visualEvents);
    final healthScore = (1 - (meanGapMs / 1000)).clamp(0.0, 1.0) * passRate;
    final verdict = healthScore >= _threshold ? 'PASS' : 'FAIL';

    final summaryText = _buildText(
      meanGapMs: meanGapMs,
      passRate: passRate,
      healthScore: healthScore,
      verdict: verdict,
    );
    final summaryJson = _buildJson(
      meanGapMs: meanGapMs,
      passRate: passRate,
      healthScore: healthScore,
      verdict: verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(meanGapMs, passRate, healthScore, verdict);
    });

    if (verdict == 'FAIL') {
      stderr.writeln(
        'UX Health Score ${healthScore.toStringAsFixed(4)} < $_threshold.',
      );
    }
    return verdict == 'PASS';
  }

  Future<List<Map<String, Object?>>> _readRecentEntries(DateTime cutoff) async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return [];
    final lines = await file.readAsLines();
    final entries = <Map<String, Object?>>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final payload = json.decode(line) as Map<String, Object?>;
        final ts = payload['timestamp'] as String?;
        if (ts == null) continue;
        final timestamp = DateTime.tryParse(ts)?.toUtc();
        if (timestamp == null || timestamp.isBefore(cutoff)) continue;
        entries.add(payload);
      } catch (_) {
        continue;
      }
    }
    return entries;
  }

  List<double> _computeLatencyGaps(
    List<DateTime> explanation,
    List<DateTime> persistence,
  ) {
    persistence.sort();
    final latencies = <double>[];
    for (final exp in explanation) {
      final match = persistence.firstWhere(
        (p) => p.isAfter(exp),
        orElse: () => DateTime.fromMillisecondsSinceEpoch(0),
      );
      if (match.year == 1970) continue;
      latencies.add(match.difference(exp).inMilliseconds.toDouble());
    }
    return latencies;
  }

  double _computePassRate(Map<DateTime, String> visualEvents) {
    final total = visualEvents.length;
    final passCount = visualEvents.values.where((v) => v == 'PASS').length;
    return total == 0 ? 0.0 : passCount / total;
  }

  String _buildText({
    required double meanGapMs,
    required double passRate,
    required double healthScore,
    required String verdict,
  }) {
    return '''
TELEMETRY INSIGHT SYNC
Generated: ${DateTime.now().toIso8601String()}
Latency gap (mean): ${meanGapMs.toStringAsFixed(2)} ms
Interaction pass rate: ${(passRate * 100).toStringAsFixed(2)}%
UX Health Score: ${(healthScore * 100).toStringAsFixed(2)}%
Threshold: ${(_threshold * 100).toStringAsFixed(2)}%
Verdict: $verdict
''';
  }

  Map<String, Object?> _buildJson({
    required double meanGapMs,
    required double passRate,
    required double healthScore,
    required String verdict,
  }) => {
    'generated_at': DateTime.now().toIso8601String(),
    'mean_latency_gap_ms': meanGapMs,
    'interaction_pass_rate': passRate,
    'ux_health_score': healthScore,
    'threshold': _threshold,
    'verdict': verdict,
  };

  Future<void> _appendTelemetry(
    double meanGapMs,
    double passRate,
    double healthScore,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'telemetry_insight_sync_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'mean_latency_gap_ms': meanGapMs,
      'interaction_pass_rate': passRate,
      'ux_health_score': healthScore,
      'verdict': verdict,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
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
