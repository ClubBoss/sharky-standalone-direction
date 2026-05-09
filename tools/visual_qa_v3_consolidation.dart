import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _cohesionPath =
    '$_reportsDir/visual_cohesion_dashboard_v2_summary.txt';
const String _stressPath = '$_reportsDir/dynamic_visual_stress_summary.txt';
const String _microPath = '$_reportsDir/ui_micro_animation_summary.txt';
const String _contrastPath = '$_reportsDir/contrast_accessibility_summary.txt';
const String _summaryPath = '$_reportsDir/visual_qa_v3_summary.txt';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _frameTargetMs = 16.0;
const double _latencyTargetMs = 300.0;

Future<void> main(List<String> args) async {
  final cli = VisualQaV3Consolidation();
  final ok = await cli.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualQaV3Consolidation {
  Future<bool> run() async {
    final generatedAt = DateTime.now().toIso8601String();
    final cohesion = await _readFile(_cohesionPath);
    final stress = await _readFile(_stressPath);
    final micro = await _readFile(_microPath);
    final contrast = await _readFile(_contrastPath);

    if (cohesion == null ||
        stress == null ||
        micro == null ||
        contrast == null) {
      stderr.writeln('Missing required visual QA reports.');
      return false;
    }

    final motionP95 = _parseFrameP95(stress);
    final latencyP95 = _parseLatencyP95(micro);

    final breakdown = [
      _MetricBreakdown(
        name: 'Cohesion',
        score: _parseCohesionScore(cohesion),
        detail: 'Visual Cohesion Dashboard v2',
        weight: 0.30,
      ),
      _MetricBreakdown(
        name: 'Contrast',
        score: _parseContrastScore(contrast),
        detail: 'Contrast Accessibility Audit',
        weight: 0.30,
      ),
      _MetricBreakdown(
        name: 'Motion',
        score: _scoreFromTarget(_frameTargetMs, motionP95),
        detail:
            'Dynamic Visual Stress Test P95=${motionP95?.toStringAsFixed(2) ?? '?'}ms',
        weight: 0.20,
      ),
      _MetricBreakdown(
        name: 'Latency',
        score: _scoreFromTarget(_latencyTargetMs, latencyP95),
        detail:
            'UI Micro Animation P95=${latencyP95?.toStringAsFixed(2) ?? '?'}ms',
        weight: 0.20,
      ),
    ];

    final vhi = _weightedAverage(breakdown);
    final verdict = vhi >= 90 ? 'PASS' : (vhi >= 75 ? 'WARN' : 'FAIL');
    final missingMetric = breakdown.any((metric) => metric.score == null);
    final summary = _buildSummary(
      generatedAt: generatedAt,
      vhi: vhi,
      breakdown: breakdown,
      motionP95: motionP95,
      latencyP95: latencyP95,
      missingMetric: missingMetric,
    );

    await _withReportsWritable(() async {
      await File(_summaryPath).writeAsString(summary);
      final telemetryPayload = {
        'event': 'visual_qa_v3_completed',
        'timestamp': generatedAt,
        'visual_health_index': vhi,
        'metrics': breakdown
            .map((m) => {'name': m.name, 'score': m.score, 'status': m.status})
            .toList(),
        'motion_p95_ms': motionP95,
        'latency_p95_ms': latencyP95,
        'verdict': verdict,
      };
      await _appendTelemetry(telemetryPayload);
    });

    return vhi >= 90 && !missingMetric;
  }

  double _weightedAverage(List<_MetricBreakdown> metrics) {
    double total = 0;
    double weightSum = 0;
    for (final metric in metrics) {
      final score = metric.score ?? 0;
      total += score * metric.weight;
      weightSum += metric.weight;
    }
    return weightSum == 0 ? 0 : total / weightSum;
  }
}

String _buildSummary({
  required String generatedAt,
  required double vhi,
  required List<_MetricBreakdown> breakdown,
  required double? motionP95,
  required double? latencyP95,
  required bool missingMetric,
}) {
  final buffer = StringBuffer()
    ..writeln('VISUAL QA v3 SUMMARY')
    ..writeln('====================')
    ..writeln('Generated: $generatedAt')
    ..writeln('Visual Health Index: ${vhi.toStringAsFixed(2)}%')
    ..writeln(
      'Verdict: ${vhi >= 90
          ? 'PASS'
          : vhi >= 75
          ? 'WARN'
          : 'FAIL'}',
    )
    ..writeln()
    ..writeln('Metrics:');
  for (final metric in breakdown) {
    buffer.writeln(
      '- ${metric.name}: ${metric.status} -> ${metric.score?.toStringAsFixed(2) ?? 'n/a'}% (${metric.detail})',
    );
  }
  buffer
    ..writeln()
    ..writeln(
      'Motion P95: ${motionP95?.toStringAsFixed(2) ?? 'n/a'}ms (target ≤ $_frameTargetMs ms)',
    )
    ..writeln(
      'Latency P95: ${latencyP95?.toStringAsFixed(2) ?? 'n/a'}ms (target ≤ $_latencyTargetMs ms)',
    );
  if (missingMetric) {
    buffer
      ..writeln()
      ..writeln(
        'WARN: One or more metrics were missing; VHI includes penalties for missing data.',
      );
  }
  return buffer.toString();
}

Future<String?> _readFile(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    stderr.writeln('Missing report: $path');
    return null;
  }
  return file.readAsString();
}

Future<void> _appendTelemetry(Map<String, Object?> payload) async {
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

class _MetricBreakdown {
  _MetricBreakdown({
    required this.name,
    required this.score,
    required this.detail,
    required this.weight,
  });

  final String name;
  final double? score;
  final String detail;
  final double weight;

  String get status {
    if (score == null) return 'FAIL';
    if (score! >= 90) return 'PASS';
    if (score! >= 75) return 'WARN';
    return 'FAIL';
  }
}

double? _parseCohesionScore(String contents) {
  final match = RegExp(
    r'Overall Visual Health Index:\s*([0-9.]+)%',
  ).firstMatch(contents);
  return match != null ? double.tryParse(match.group(1)!) : null;
}

double? _parseContrastScore(String contents) {
  final match = RegExp(
    r'Min:\s*([0-9.]+)',
    caseSensitive: false,
  ).firstMatch(contents);
  if (match == null) return null;
  final minValue = double.tryParse(match.group(1)!);
  if (minValue == null || minValue <= 0) return null;
  return (minValue / 4.5).clamp(0, 1) * 100;
}

double? _parseFrameP95(String contents) {
  final sanitized = contents.replaceAll(',', '.');
  final match = RegExp(r'P95\s*:\s*([0-9.]+)').firstMatch(sanitized);
  return match != null ? double.tryParse(match.group(1)!) : null;
}

double? _parseLatencyP95(String contents) {
  final sanitized = contents.replaceAll(',', '.');
  final match = RegExp(
    r'Overall latency:.*?p95\s*([0-9.]+)',
    caseSensitive: false,
  ).firstMatch(sanitized);
  return match != null ? double.tryParse(match.group(1)!) : null;
}

double? _scoreFromTarget(double target, double? observed) {
  if (observed == null || observed <= 0) return null;
  final ratio = (target / observed) * 100;
  return ratio.clamp(0, 100).toDouble();
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
