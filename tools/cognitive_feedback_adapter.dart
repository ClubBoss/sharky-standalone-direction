import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _visualAiPath = '$_reportsDir/visual_ai_evolution_summary.json';
const String _emotionPath =
    '$_reportsDir/emotion_feedback_reactor_summary.json';
const String _uxPath = '$_reportsDir/ux_harmony_integrator_summary.json';
const String _summaryTextPath = '$_reportsDir/cognitive_feedback_summary.txt';
const String _summaryJsonPath = '$_reportsDir/cognitive_feedback_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final adapter = CognitiveFeedbackAdapter();
  final ok = await adapter.run();
  if (!ok) {
    exitCode = 2;
  }
}

class CognitiveFeedbackAdapter {
  Future<bool> run() async {
    final visual = await _loadSummary(
      _visualAiPath,
      'visual_ai_evolution_score',
    );
    final emotion = await _loadSummary(
      _emotionPath,
      'emotional_cohesion_score',
    );
    final ux = await _loadSummary(_uxPath, 'ux_harmony_score');

    if (visual == null || emotion == null || ux == null) {
      stderr.writeln('Missing cognitive feedback inputs.');
      return false;
    }

    if (!visual.pass || !emotion.pass || !ux.pass) {
      stderr.writeln('One or more summaries failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (visual.timestamp != null) visual.timestamp!,
      if (emotion.timestamp != null) emotion.timestamp!,
      if (ux.timestamp != null) ux.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Timestamps span more than ${_timeWindow.inHours}h.');
      return false;
    }

    final visualScore = _normalize(visual.score);
    final emotionScore = _normalize(emotion.score);
    final uxScore = _normalize(ux.score);

    if (visualScore == null || emotionScore == null || uxScore == null) {
      stderr.writeln('Failed to normalize scores.');
      return false;
    }

    final cognitiveScore =
        ((visualScore * 0.4) + (emotionScore * 0.35) + (uxScore * 0.25)).clamp(
          0.0,
          1.0,
        );
    final pass = cognitiveScore >= _threshold;

    final text = _buildText(
      visualScore,
      emotionScore,
      uxScore,
      cognitiveScore,
      pass,
    );
    final json = _buildJson(
      visualScore,
      emotionScore,
      uxScore,
      cognitiveScore,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        visualScore,
        emotionScore,
        uxScore,
        cognitiveScore,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Cognitive Feedback Score ${(cognitiveScore * 100).toStringAsFixed(2)}% below threshold.',
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
      final generated =
          decoded['generated_at'] as String? ??
          decoded['generated'] as String? ??
          decoded['timestamp'] as String?;
      final parsed = generated != null ? DateTime.tryParse(generated) : null;
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
    double emotion,
    double ux,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('COGNITIVE FEEDBACK SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual-AI score: ${pct(visual)}')
      ..writeln('Emotion cohesion score: ${pct(emotion)}')
      ..writeln('UX harmony score: ${pct(ux)}')
      ..writeln('Cognitive Feedback Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double visual,
    double emotion,
    double ux,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'visual_ai_score': visual,
    'emotional_cohesion_score': emotion,
    'ux_harmony_score': ux,
    'cognitive_feedback_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double visual,
    double emotion,
    double ux,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'cognitive_feedback_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_ai_score': visual,
      'emotional_cohesion_score': emotion,
      'ux_harmony_score': ux,
      'cognitive_feedback_score': score,
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
