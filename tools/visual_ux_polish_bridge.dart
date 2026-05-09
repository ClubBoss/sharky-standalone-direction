import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _phiSummaryPath = '$_reportsDir/phi_v2_final_summary.json';
const String _visualSummaryPath = '$_reportsDir/visual_qa_final_summary.json';
const List<String> _visualJsonFallbacks = <String>[
  '$_reportsDir/visual_cohesion_final_summary.json',
  '$_reportsDir/visual_cohesion_dashboard_v2_summary.json',
];
const List<String> _visualTextFallbacks = <String>[
  '$_reportsDir/visual_qa_final_summary.txt',
  '$_reportsDir/visual_cohesion_final_summary.txt',
  '$_reportsDir/visual_cohesion_dashboard_v2_summary.txt',
];
const String _cognitiveSummaryPath =
    '$_reportsDir/cognitive_design_coherence_summary.json';
const String _summaryTextPath = '$_reportsDir/visual_ux_polish_summary.txt';
const String _summaryJsonPath = '$_reportsDir/visual_ux_polish_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final bridge = VisualUxPolishBridge();
  final ok = await bridge.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualUxPolishBridge {
  Future<bool> run() async {
    final phi = await _readJson(_phiSummaryPath);
    final cognitive = await _readJson(_cognitiveSummaryPath);
    final visualScore = await _resolveVisualScore();

    if (phi == null || cognitive == null || visualScore == null) {
      stderr.writeln(
        'Missing required summaries (Φ-v2 / visual QA final / cognitive coherence).',
      );
      return false;
    }

    final phiIndex = _normalizeScore(
      (phi['phi_v2_final_design_index'] as num?)?.toDouble(),
    );
    final cognitiveScore = _normalizeScore(
      (cognitive['cognitive_coherence_score'] as num?)?.toDouble(),
    );

    final polishIndex =
        ((phiIndex * 0.4) + (visualScore * 0.35) + (cognitiveScore * 0.25))
            .clamp(0, 1)
            .toDouble();
    final pass = polishIndex >= _threshold;

    final summaryText = _buildTextSummary(
      phiIndex,
      visualScore,
      cognitiveScore,
      polishIndex,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      phiIndex,
      visualScore,
      cognitiveScore,
      polishIndex,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        phiIndex,
        visualScore,
        cognitiveScore,
        polishIndex,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Visual UX Polish Index ${polishIndex.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
  }

  Future<double?> _resolveVisualScore() async {
    // Primary JSON path.
    final primary = await _readJson(_visualSummaryPath);
    final primaryScore = _extractVisualScore(primary);
    if (primaryScore != null) return primaryScore;

    // JSON fallbacks.
    for (final path in _visualJsonFallbacks) {
      final data = await _readJson(path);
      final score = _extractVisualScore(data);
      if (score != null) return score;
    }

    // Text fallbacks.
    for (final path in _visualTextFallbacks) {
      final score = await _readTextPercent(path);
      if (score != null) return _normalizeScore(score);
    }
    return null;
  }

  double? _extractVisualScore(Map<String, dynamic>? data) {
    if (data == null) return null;
    final raw =
        (data['final_health'] as num?)?.toDouble() ??
        (data['final_visual_health'] as num?)?.toDouble() ??
        (data['visual_cohesion_score'] as num?)?.toDouble() ??
        (data['visual_ai_cohesion_index'] as num?)?.toDouble();
    if (raw == null) return null;
    return _normalizeScore(raw);
  }

  Future<Map<String, dynamic>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<double?> _readTextPercent(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final contents = await file.readAsString();
      final match = RegExp(r'([0-9.]+)\s*%').firstMatch(contents);
      if (match != null) {
        return double.tryParse(match.group(1) ?? '');
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  String _buildTextSummary(
    double phiIndex,
    double visual,
    double cognitive,
    double polish,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('VISUAL UX POLISH SUMMARY')
      ..writeln('========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Φ-v2 Final Design Index: ${pct(phiIndex)}')
      ..writeln('Visual Cohesion Final QA: ${pct(visual)}')
      ..writeln('Cognitive Coherence Score: ${pct(cognitive)}')
      ..writeln('Visual UX Polish Index: ${pct(polish)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double phiIndex,
    double visual,
    double cognitive,
    double polish,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'phi_v2_final_design_index': phiIndex,
      'visual_cohesion_final_score': visual,
      'cognitive_coherence_score': cognitive,
      'visual_ux_polish_index': polish,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    double phiIndex,
    double visual,
    double cognitive,
    double polish,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_ux_polish_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'phi_v2_final_design_index': phiIndex,
      'visual_cohesion_final_score': visual,
      'cognitive_coherence_score': cognitive,
      'visual_ux_polish_index': polish,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

double _normalizeScore(double? raw) {
  if (raw == null) return 0;
  if (raw <= 1.0) {
    return raw.clamp(0, 1).toDouble();
  }
  return (raw / 100).clamp(0, 1).toDouble();
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
