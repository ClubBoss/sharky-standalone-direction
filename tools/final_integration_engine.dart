import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _systemSnapshotPath =
    '$_reportsDir/system_snapshot_v3_summary.json';
const String _ltvResonancePath = '$_reportsDir/ltv_resonance_summary.json';
const String _visualCohesionPath =
    '$_reportsDir/visual_cohesion_final_v2_summary.json';
const String _aestheticPath =
    '$_reportsDir/aesthetic_calibration_final_summary.json';
const String _summaryTextPath = '$_reportsDir/final_integration_summary.txt';
const String _summaryJsonPath = '$_reportsDir/final_integration_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final engine = FinalIntegrationEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class FinalIntegrationEngine {
  Future<bool> run() async {
    final system = await _readSummary(
      _systemSnapshotPath,
      'system_snapshot_v3_score',
    );
    final ltv = await _readSummary(_ltvResonancePath, 'ltv_resonance_score');
    final visual = await _readSummary(
      _visualCohesionPath,
      'visual_cohesion_final_v2_index',
    );
    final aesthetic = await _readSummary(
      _aestheticPath,
      'final_aesthetic_calibration_index',
    );

    if (system == null || ltv == null || visual == null || aesthetic == null) {
      stderr.writeln('Missing final integration inputs.');
      return false;
    }

    if (!system.pass || !ltv.pass || !visual.pass || !aesthetic.pass) {
      stderr.writeln('One or more inputs did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (system.timestamp != null) system.timestamp!,
      if (ltv.timestamp != null) ltv.timestamp!,
      if (visual.timestamp != null) visual.timestamp!,
      if (aesthetic.timestamp != null) aesthetic.timestamp!,
    ];
    if (!_withinWindow(timestamps)) {
      stderr.writeln(
        'Input timestamps span more than ${_timeWindow.inHours}h.',
      );
      return false;
    }

    final systemScore = _normalize(system.score);
    final ltvScore = _normalize(ltv.score);
    final visualScore = _normalize(visual.score);
    final aestheticScore = _normalize(aesthetic.score);

    if (systemScore == null ||
        ltvScore == null ||
        visualScore == null ||
        aestheticScore == null) {
      stderr.writeln('Unable to parse scores.');
      return false;
    }

    final finalScore =
        ((systemScore * 0.3) +
                (ltvScore * 0.3) +
                (visualScore * 0.25) +
                (aestheticScore * 0.15))
            .clamp(0.0, 1.0);

    final pass = finalScore >= _threshold;

    final text = _buildText(
      systemScore,
      ltvScore,
      visualScore,
      aestheticScore,
      finalScore,
      pass,
    );
    final json = _buildJson(
      systemScore,
      ltvScore,
      visualScore,
      aestheticScore,
      finalScore,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        systemScore,
        ltvScore,
        visualScore,
        aestheticScore,
        finalScore,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Final Integration Score ${(finalScore * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Summary?> _readSummary(String path, String key) async {
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
      final score = _extractScore(decoded, key);
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
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0.0, 1.0);
  }

  double? _extractScore(Map<String, Object?> data, String key) {
    if (data.containsKey(key)) {
      return _toDouble(data[key]);
    }
    return null;
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  String _buildText(
    double system,
    double ltv,
    double visual,
    double aesthetic,
    double finalScore,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('FINAL INTEGRATION SUMMARY')
      ..writeln('========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('System snapshot: ${pct(system)}')
      ..writeln('LTV resonance: ${pct(ltv)}')
      ..writeln('Visual cohesion: ${pct(visual)}')
      ..writeln('Aesthetic calibration: ${pct(aesthetic)}')
      ..writeln('Final Integration Score: ${pct(finalScore)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double system,
    double ltv,
    double visual,
    double aesthetic,
    double finalScore,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'system_snapshot_score': system,
    'ltv_resonance_score': ltv,
    'visual_cohesion_score': visual,
    'aesthetic_calibration_score': aesthetic,
    'final_integration_score': finalScore,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double system,
    double ltv,
    double visual,
    double aesthetic,
    double finalScore,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'final_integration_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'system_snapshot_score': system,
      'ltv_resonance_score': ltv,
      'visual_cohesion_score': visual,
      'aesthetic_calibration_score': aesthetic,
      'final_integration_score': finalScore,
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
