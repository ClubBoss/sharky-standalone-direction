import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryAggregatorPath =
    '$_reportsDir/visual_telemetry_aggregator_summary.json';
const String _visualCohesionPath =
    '$_reportsDir/visual_cohesion_final_v2_summary.json';
const String _designLiftPath = '$_reportsDir/design_lift_phase1_summary.json';
const String _aestheticPath =
    '$_reportsDir/aesthetic_calibration_final_summary.json';
const String _summaryTextPath =
    '$_reportsDir/visual_ux_polish_final_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/visual_ux_polish_final_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final finalizer = VisualUxPolishFinalizer();
  final ok = await finalizer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualUxPolishFinalizer {
  Future<bool> run() async {
    final telemetry = await _loadSummary(
      _telemetryAggregatorPath,
      'visual_stability_index',
    );
    final cohesion = await _loadSummary(
      _visualCohesionPath,
      'visual_cohesion_final_v2_index',
    );
    final design = await _loadSummary(_designLiftPath, 'design_lift_score');
    final aesthetic = await _loadSummary(
      _aestheticPath,
      'final_aesthetic_calibration_index',
    );

    if (telemetry == null ||
        cohesion == null ||
        design == null ||
        aesthetic == null) {
      stderr.writeln('Missing visual polish inputs.');
      return false;
    }

    if (!telemetry.pass || !cohesion.pass || !design.pass || !aesthetic.pass) {
      stderr.writeln('One or more visual summaries failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (telemetry.timestamp != null) telemetry.timestamp!,
      if (cohesion.timestamp != null) cohesion.timestamp!,
      if (design.timestamp != null) design.timestamp!,
      if (aesthetic.timestamp != null) aesthetic.timestamp!,
    ];
    if (!_withinWindow(timestamps)) {
      stderr.writeln('Timestamps span more than ${_timeWindow.inHours}h.');
      return false;
    }

    final telemetryScore = _normalize(telemetry.score);
    final cohesionScore = _normalize(cohesion.score);
    final designScore = _normalize(design.score);
    final aestheticScore = _normalize(aesthetic.score);

    if (telemetryScore == null ||
        cohesionScore == null ||
        designScore == null ||
        aestheticScore == null) {
      stderr.writeln('Unable to normalize scores.');
      return false;
    }

    final polishScore =
        ((telemetryScore * 0.3) +
                (cohesionScore * 0.3) +
                (designScore * 0.25) +
                (aestheticScore * 0.15))
            .clamp(0.0, 1.0);
    final pass = polishScore >= _threshold;

    final text = _buildText(
      telemetryScore,
      cohesionScore,
      designScore,
      aestheticScore,
      polishScore,
      pass,
    );
    final json = _buildJson(
      telemetryScore,
      cohesionScore,
      designScore,
      aestheticScore,
      polishScore,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        telemetryScore,
        cohesionScore,
        designScore,
        aestheticScore,
        polishScore,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Visual Polish Score ${(polishScore * 100).toStringAsFixed(2)}% below threshold.',
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

  bool _withinWindow(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  double? _normalize(double? value) {
    if (value == null) return null;
    final norm = value > 1 ? value / 100 : value;
    return norm.clamp(0.0, 1.0);
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  String _buildText(
    double telemetry,
    double cohesion,
    double design,
    double aesthetic,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('VISUAL UX POLISH FINALIZER')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual telemetry: ${pct(telemetry)}')
      ..writeln('Visual cohesion: ${pct(cohesion)}')
      ..writeln('Design lift: ${pct(design)}')
      ..writeln('Aesthetic score: ${pct(aesthetic)}')
      ..writeln('Visual Polish Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double telemetry,
    double cohesion,
    double design,
    double aesthetic,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'visual_telemetry_score': telemetry,
    'visual_cohesion_score': cohesion,
    'design_lift_score': design,
    'aesthetic_score': aesthetic,
    'visual_polish_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double telemetry,
    double cohesion,
    double design,
    double aesthetic,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_ux_polish_finalizer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_telemetry_score': telemetry,
      'visual_cohesion_score': cohesion,
      'design_lift_score': design,
      'aesthetic_score': aesthetic,
      'visual_polish_score': score,
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
