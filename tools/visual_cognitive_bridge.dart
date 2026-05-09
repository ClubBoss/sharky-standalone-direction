import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _visualAiPath = '$_reportsDir/visual_ai_evolution_summary.json';
const String _cognitivePath = '$_reportsDir/cognitive_feedback_summary.json';
const String _aestheticPath =
    '$_reportsDir/aesthetic_calibration_final_summary.json';
const String _summaryTextPath =
    '$_reportsDir/visual_cognitive_bridge_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/visual_cognitive_bridge_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final bridge = VisualCognitiveBridge();
  final ok = await bridge.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualCognitiveBridge {
  Future<bool> run() async {
    final visual = await _loadSummary(
      _visualAiPath,
      'visual_ai_evolution_score',
    );
    final cognitive = await _loadSummary(
      _cognitivePath,
      'cognitive_feedback_score',
    );
    final aesthetic = await _loadSummary(
      _aestheticPath,
      'final_aesthetic_calibration_index',
    );

    if (visual == null || cognitive == null || aesthetic == null) {
      stderr.writeln('Missing visual-cognitive inputs.');
      return false;
    }

    if (!visual.pass || !cognitive.pass || !aesthetic.pass) {
      stderr.writeln('One or more inputs failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (visual.timestamp != null) visual.timestamp!,
      if (cognitive.timestamp != null) cognitive.timestamp!,
      if (aesthetic.timestamp != null) aesthetic.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Timestamps span more than $_timeWindow.');
      return false;
    }

    final visualScore = _normalize(visual.score);
    final cognitiveScore = _normalize(cognitive.score);
    final aestheticScore = _normalize(aesthetic.score);

    if (visualScore == null ||
        cognitiveScore == null ||
        aestheticScore == null) {
      stderr.writeln('Failed to parse scores.');
      return false;
    }

    final bridgeScore =
        ((visualScore * 0.4) +
                (cognitiveScore * 0.35) +
                (aestheticScore * 0.25))
            .clamp(0.0, 1.0);
    final pass = bridgeScore >= _threshold;

    final text = _buildText(
      visualScore,
      cognitiveScore,
      aestheticScore,
      bridgeScore,
      pass,
    );
    final json = _buildJson(
      visualScore,
      cognitiveScore,
      aestheticScore,
      bridgeScore,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        visualScore,
        cognitiveScore,
        aestheticScore,
        bridgeScore,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Visual-Cognitive Bridge Score ${(bridgeScore * 100).toStringAsFixed(2)}% below threshold.',
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
      final score = _toDouble(decoded[key]) ?? _toDouble(decoded['score']);
      return _Summary(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
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
    double cognitive,
    double aesthetic,
    double score,
    bool pass,
  ) {
    final pct = (double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('VISUAL-COGNITIVE BRIDGE SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual-AI score: ${pct(visual)}')
      ..writeln('Cognitive feedback: ${pct(cognitive)}')
      ..writeln('Aesthetic calibration: ${pct(aesthetic)}')
      ..writeln('Bridge Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double visual,
    double cognitive,
    double aesthetic,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'visual_ai_score': visual,
    'cognitive_feedback_score': cognitive,
    'aesthetic_calibration_score': aesthetic,
    'visual_cognitive_bridge_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double visual,
    double cognitive,
    double aesthetic,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_cognitive_bridge_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_ai_score': visual,
      'cognitive_feedback_score': cognitive,
      'aesthetic_calibration_score': aesthetic,
      'visual_cognitive_bridge_score': score,
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
