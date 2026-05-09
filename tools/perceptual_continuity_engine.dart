import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _visualCognitivePath =
    '$_reportsDir/visual_cognitive_bridge_summary.json';
const String _uxPath = '$_reportsDir/ux_harmony_integrator_summary.json';
const String _aestheticPath =
    '$_reportsDir/aesthetic_calibration_final_summary.json';
const String _summaryTextPath =
    '$_reportsDir/perceptual_continuity_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/perceptual_continuity_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final engine = PerceptualContinuityEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PerceptualContinuityEngine {
  Future<bool> run() async {
    final visualCognitive = await _loadSummary(
      _visualCognitivePath,
      'visual_cognitive_bridge_score',
    );
    final ux = await _loadSummary(_uxPath, 'ux_harmony_score');
    final aesthetic = await _loadSummary(
      _aestheticPath,
      'final_aesthetic_calibration_index',
    );

    if (visualCognitive == null || ux == null || aesthetic == null) {
      stderr.writeln('Missing perceptual continuity inputs.');
      return false;
    }

    if (!visualCognitive.pass || !ux.pass || !aesthetic.pass) {
      stderr.writeln('One or more inputs did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (visualCognitive.timestamp != null) visualCognitive.timestamp!,
      if (ux.timestamp != null) ux.timestamp!,
      if (aesthetic.timestamp != null) aesthetic.timestamp!,
    ];

    if (!_aligned(timestamps)) {
      stderr.writeln('Timestamps span more than $_timeWindow.');
      return false;
    }

    final visualScore = _normalize(visualCognitive.score);
    final uxScore = _normalize(ux.score);
    final aestheticScore = _normalize(aesthetic.score);

    if (visualScore == null || uxScore == null || aestheticScore == null) {
      stderr.writeln('Unable to parse required scores.');
      return false;
    }

    final continuity =
        ((visualScore * 0.4) + (uxScore * 0.35) + (aestheticScore * 0.25))
            .clamp(0.0, 1.0);
    final pass = continuity >= _threshold;

    final text = _buildText(
      visualScore,
      uxScore,
      aestheticScore,
      continuity,
      pass,
    );
    final json = _buildJson(
      visualScore,
      uxScore,
      aestheticScore,
      continuity,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        visualScore,
        uxScore,
        aestheticScore,
        continuity,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Perceptual Continuity Score ${(continuity * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Summary?> _loadSummary(String path, String key) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      final verdict = ((decoded['verdict'] as String?) ?? '').toUpperCase();
      final timestamp =
          decoded['generated_at'] as String? ??
          decoded['generated'] as String? ??
          decoded['timestamp'] as String?;
      final parsed = timestamp != null ? DateTime.tryParse(timestamp) : null;
      final score = _nullableScore(decoded[key], decoded['score']);
      return _Summary(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
  }

  double? _nullableScore(Object? primary, Object? fallback) {
    return _toDouble(primary) ?? _toDouble(fallback);
  }

  bool _aligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  double? _normalize(double? value) {
    if (value == null) return null;
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0.0, 1.0);
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  String _buildText(
    double visual,
    double ux,
    double aesthetic,
    double score,
    bool pass,
  ) {
    final pct = (double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('PERCEPTUAL CONTINUITY SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual-AI score: ${pct(visual)}')
      ..writeln('UX harmony score: ${pct(ux)}')
      ..writeln('Aesthetic calibration: ${pct(aesthetic)}')
      ..writeln('Perceptual Continuity Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double visual,
    double ux,
    double aesthetic,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'visual_ai_score': visual,
    'ux_harmony_score': ux,
    'aesthetic_calibration_score': aesthetic,
    'perceptual_continuity_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double visual,
    double ux,
    double aesthetic,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'perceptual_continuity_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_ai_score': visual,
      'ux_harmony_score': ux,
      'aesthetic_calibration_score': aesthetic,
      'perceptual_continuity_score': score,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Summary {
  _Summary({required this.pass, required this.timestamp, required this.score});

  final bool pass;
  final DateTime? timestamp;
  final double? score;
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
