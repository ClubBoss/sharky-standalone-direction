import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _designAuditPath = '$_reportsDir/design_audit_wrap_summary.json';
const String _releaseQaPath =
    '$_reportsDir/release_qa_consolidation_summary.json';
const String _certificationPath =
    '$_reportsDir/final_release_certification_summary.json';
const String _summaryTextPath = '$_reportsDir/system_snapshot_v3_summary.txt';
const String _summaryJsonPath = '$_reportsDir/system_snapshot_v3_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final snapshot = SystemSnapshotV3();
  final ok = await snapshot.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SystemSnapshotV3 {
  Future<bool> run() async {
    final design = await _readScore(
      _designAuditPath,
      keys: const ['design_certification_index', 'design_certification_score'],
    );
    final qa = await _readScore(
      _releaseQaPath,
      keys: const ['release_qa_index', 'qa_score'],
    );
    final certification = await _readScore(
      _certificationPath,
      keys: const ['certification_score'],
    );

    if (design == null || qa == null || certification == null) {
      stderr.writeln('Missing inputs for System Snapshot v3.');
      return false;
    }

    final score = ((design * 0.4) + (qa * 0.35) + (certification * 0.25)).clamp(
      0.0,
      1.0,
    );
    final pass = score >= _threshold;
    final summaryText = _buildText(design, qa, certification, score, pass);
    final summaryJson = _buildJson(design, qa, certification, score, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(design, qa, certification, score, pass);
    });

    if (!pass) {
      stderr.writeln(
        'System Snapshot v3 Score ${score.toStringAsFixed(3)} below threshold.',
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
        final raw = _toDouble(decoded[key]);
        if (raw == null) continue;
        final value = raw > 1 ? raw / 100 : raw;
        return value.clamp(0.0, 1.0);
      }
    } catch (_) {}
    return null;
  }

  String _buildText(
    double design,
    double qa,
    double certification,
    double score,
    bool pass,
  ) {
    String pct(double v) => '${(v * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('SYSTEM SNAPSHOT V3 SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Design Certification Index: ${pct(design)}')
      ..writeln('Release QA Index: ${pct(qa)}')
      ..writeln('Final Certification Score: ${pct(certification)}')
      ..writeln('System Snapshot v3 Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double design,
    double qa,
    double certification,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'design_certification_index': design,
    'release_qa_index': qa,
    'certification_score': certification,
    'system_snapshot_v3_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double design,
    double qa,
    double certification,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'system_snapshot_v3_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'design_certification_index': design,
      'release_qa_index': qa,
      'certification_score': certification,
      'system_snapshot_v3_score': score,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

double? _toDouble(Object? value) {
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
