import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _systemUxSummaryPath =
    '$_reportsDir/system_ux_snapshot_v2_summary.json';
const String _aestheticFinalPath =
    '$_reportsDir/aesthetic_calibration_final_summary.json';
const String _visualCalibrationPath =
    '$_reportsDir/visual_calibration_summary.json';
const String _summaryTextPath =
    '$_reportsDir/visual_cohesion_final_v2_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/visual_cohesion_final_v2_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final qa = VisualCohesionQaFinalV2();
  final ok = await qa.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualCohesionQaFinalV2 {
  Future<bool> run() async {
    final systemUx = await _readScore(
      _systemUxSummaryPath,
      keys: const ['system_ux_integrity_index', 'system_ux_index'],
    );
    final aesthetic = await _readScore(
      _aestheticFinalPath,
      keys: const [
        'final_aesthetic_calibration_index',
        'aesthetic_calibration_score',
      ],
    );
    final visual = await _readScore(
      _visualCalibrationPath,
      keys: const ['visual_calibration_score', 'visual_calibration_index'],
    );

    if (systemUx == null || aesthetic == null || visual == null) {
      stderr.writeln('Missing one or more visual coherence summaries.');
      return false;
    }

    final index = ((systemUx * 0.4) + (aesthetic * 0.35) + (visual * 0.25))
        .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final summaryText = _buildText(systemUx, aesthetic, visual, index, pass);
    final summaryJson = _buildJson(systemUx, aesthetic, visual, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(systemUx, aesthetic, visual, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Visual Cohesion Final V2 Index ${index.toStringAsFixed(3)} '
        'below ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  Future<double?> _readScore(String path, {required List<String> keys}) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      for (final key in keys) {
        if (!decoded.containsKey(key)) continue;
        final value = _asDouble(decoded[key]);
        if (value == null) continue;
        final normalized = value > 1 ? value / 100 : value;
        return normalized.clamp(0.0, 1.0).toDouble();
      }
    } catch (_) {}
    return null;
  }

  String _buildText(
    double systemUx,
    double aesthetic,
    double visual,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('VISUAL COHESION FINAL V2 SUMMARY')
      ..writeln('=================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('System UX Integrity Index: ${pct(systemUx)}')
      ..writeln('Final Aesthetic Calibration Score: ${pct(aesthetic)}')
      ..writeln('Visual Calibration Score: ${pct(visual)}')
      ..writeln('Visual Cohesion Final V2 Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double systemUx,
    double aesthetic,
    double visual,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'system_ux_integrity_index': systemUx,
    'final_aesthetic_calibration_score': aesthetic,
    'visual_calibration_score': visual,
    'visual_cohesion_final_v2_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double systemUx,
    double aesthetic,
    double visual,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_cohesion_final_v2_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'system_ux_integrity_index': systemUx,
      'final_aesthetic_calibration_score': aesthetic,
      'visual_calibration_score': visual,
      'visual_cohesion_final_v2_index': index,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
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
