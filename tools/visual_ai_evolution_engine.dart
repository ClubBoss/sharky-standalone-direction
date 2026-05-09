import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _personaPath = '$_reportsDir/visual_persona_bridge_summary.json';
const String _tonePath = '$_reportsDir/ai_tone_harmonizer_summary.json';
const String _layoutPath =
    '$_reportsDir/adaptive_layout_rebalancer_summary.json';
const String _summaryTextPath = '$_reportsDir/visual_ai_evolution_summary.txt';
const String _summaryJsonPath = '$_reportsDir/visual_ai_evolution_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final engine = VisualAiEvolutionEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualAiEvolutionEngine {
  Future<bool> run() async {
    final persona = await _loadSummary(_personaPath, 'visual_persona_index');
    final tone = await _loadSummary(_tonePath, 'tone_harmony_index');
    final layout = await _loadSummary(_layoutPath, 'layout_balance_score');

    if (persona == null || tone == null || layout == null) {
      stderr.writeln('Missing Visual-AI inputs.');
      return false;
    }

    if (!persona.pass || !tone.pass || !layout.pass) {
      stderr.writeln('One or more inputs failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (persona.timestamp != null) persona.timestamp!,
      if (tone.timestamp != null) tone.timestamp!,
      if (layout.timestamp != null) layout.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Timestamps span more than $_timeWindow.');
      return false;
    }

    final personaScore = _normalize(persona.score);
    final toneScore = _normalize(tone.score);
    final layoutScore = _normalize(layout.score);

    if (personaScore == null || toneScore == null || layoutScore == null) {
      stderr.writeln('Unable to parse scores.');
      return false;
    }

    final score =
        ((personaScore * 0.4) + (toneScore * 0.35) + (layoutScore * 0.25))
            .clamp(0.0, 1.0);
    final pass = score >= _threshold;

    final text = _buildText(personaScore, toneScore, layoutScore, score, pass);
    final json = _buildJson(personaScore, toneScore, layoutScore, score, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(personaScore, toneScore, layoutScore, score, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Visual-AI Evolution Score ${(score * 100).toStringAsFixed(2)}% below threshold.',
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
    double persona,
    double tone,
    double layout,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('VISUAL-AI EVOLUTION SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual persona index: ${pct(persona)}')
      ..writeln('Tone harmony: ${pct(tone)}')
      ..writeln('Layout balance: ${pct(layout)}')
      ..writeln('Visual-AI Evolution Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double persona,
    double tone,
    double layout,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'visual_persona_index': persona,
    'tone_harmony_score': tone,
    'layout_balance_score': layout,
    'visual_ai_evolution_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double persona,
    double tone,
    double layout,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_ai_evolution_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_persona_index': persona,
      'tone_harmony_score': tone,
      'layout_balance_score': layout,
      'visual_ai_evolution_score': score,
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
