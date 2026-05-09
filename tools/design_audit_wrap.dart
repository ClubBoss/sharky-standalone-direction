import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _cohesionPath =
    '$_reportsDir/visual_cohesion_final_v2_summary.json';
const String _systemUxPath = '$_reportsDir/system_ux_snapshot_v2_summary.json';
const String _aestheticPath =
    '$_reportsDir/aesthetic_calibration_final_summary.json';
const String _summaryTextPath = '$_reportsDir/design_audit_wrap_summary.txt';
const String _summaryJsonPath = '$_reportsDir/design_audit_wrap_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final audit = DesignAuditWrap();
  final ok = await audit.run();
  if (!ok) {
    exitCode = 2;
  }
}

class DesignAuditWrap {
  Future<bool> run() async {
    final visual = await _readScore(
      _cohesionPath,
      keys: const ['visual_cohesion_final_v2_index', 'visual_cohesion_score'],
    );
    final systemUx = await _readScore(
      _systemUxPath,
      keys: const ['system_ux_integrity_index', 'system_ux_index'],
    );
    final aesthetic = await _readScore(
      _aestheticPath,
      keys: const [
        'final_aesthetic_calibration_index',
        'aesthetic_calibration_score',
      ],
    );

    if (visual == null || systemUx == null || aesthetic == null) {
      stderr.writeln('Missing required design audit summaries.');
      return false;
    }

    final index = ((visual * 0.4) + (systemUx * 0.35) + (aesthetic * 0.25))
        .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final summaryText = _buildText(visual, systemUx, aesthetic, index, pass);
    final summaryJson = _buildJson(visual, systemUx, aesthetic, index, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(visual, systemUx, aesthetic, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Design Certification Index ${index.toStringAsFixed(3)} below '
        '${(_threshold * 100).toStringAsFixed(2)}%.',
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
        final raw = _asDouble(decoded[key]);
        if (raw == null) continue;
        final value = raw > 1 ? raw / 100 : raw;
        return value.clamp(0.0, 1.0).toDouble();
      }
    } catch (_) {}
    return null;
  }

  String _buildText(
    double visual,
    double systemUx,
    double aesthetic,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('DESIGN AUDIT WRAP SUMMARY')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual Cohesion Final V2: ${pct(visual)}')
      ..writeln('System UX Integrity: ${pct(systemUx)}')
      ..writeln('Final Aesthetic Calibration: ${pct(aesthetic)}')
      ..writeln('Design Certification Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double visual,
    double systemUx,
    double aesthetic,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'visual_cohesion_final_v2_index': visual,
    'system_ux_integrity_index': systemUx,
    'aesthetic_calibration_score': aesthetic,
    'design_certification_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double visual,
    double systemUx,
    double aesthetic,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'design_audit_wrap_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_cohesion_final_v2_index': visual,
      'system_ux_integrity_index': systemUx,
      'aesthetic_calibration_score': aesthetic,
      'design_certification_index': index,
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
