import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _stabilitySummaryPath =
    '$_reportsDir/stability_qa_consolidator_v2_summary.json';
const String _releaseSummaryPath =
    '$_reportsDir/release_qa_consolidation_summary.json';
const String _certificationSummaryPath =
    '$_reportsDir/release_certification_summary.json';
const String _driftSummaryPath =
    '$_reportsDir/adaptive_learning_drift_summary.json';
const String _monetizationSummaryPath =
    '$_reportsDir/monetization_pulse_summary.json';
const String _summaryTextPath = '$_reportsDir/system_snapshot_summary.txt';
const String _summaryJsonPath = '$_reportsDir/system_snapshot_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final finalizer = SystemSnapshotFinalizer();
  final ok = await finalizer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SystemSnapshotFinalizer {
  Future<bool> run() async {
    final stability = await _readScore(
      path: _stabilitySummaryPath,
      key: 'stability_integrity_score',
    );
    final release = await _readScore(
      path: _releaseSummaryPath,
      key: 'release_qa_index',
    );
    final certification = await _readScore(
      path: _certificationSummaryPath,
      key: 'certification_score',
    );
    final monetization = await _readScore(
      path: _monetizationSummaryPath,
      key: 'monetization_pulse_score',
    );
    final drift = await _readScore(
      path: _driftSummaryPath,
      key: 'adaptive_drift',
    );

    if (stability == null ||
        release == null ||
        certification == null ||
        monetization == null ||
        drift == null) {
      stderr.writeln('Missing one or more system snapshot inputs.');
      return false;
    }

    final integrityIndex = _computeIntegrityIndex(
      stability: stability,
      release: release,
      certification: certification,
      monetization: monetization,
      drift: drift,
    );
    final pass = integrityIndex >= _threshold;

    final summaryText = _buildTextSummary(
      stability,
      release,
      certification,
      monetization,
      drift,
      integrityIndex,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      stability,
      release,
      certification,
      monetization,
      drift,
      integrityIndex,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        stability,
        release,
        certification,
        monetization,
        drift,
        integrityIndex,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'System Integrity Index ${integrityIndex.toStringAsFixed(3)} below ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  double _computeIntegrityIndex({
    required double stability,
    required double release,
    required double certification,
    required double monetization,
    required double drift,
  }) {
    final driftContribution = (1 - drift).clamp(0.0, 1.0);
    final score =
        (stability * 0.3) +
        (release * 0.25) +
        (certification * 0.2) +
        (monetization * 0.15) +
        (driftContribution * 0.1);
    return score.clamp(0.0, 1.0);
  }

  Future<double?> _readScore({
    required String path,
    required String key,
  }) async {
    final data = await _readJson(path);
    return _normalize(data?[key]);
  }

  Future<Map<String, Object?>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, Object?>) return decoded;
    } catch (_) {}
    return null;
  }

  double? _normalize(Object? value) {
    if (value is num) {
      return value.clamp(0.0, 1.0).toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed.clamp(0.0, 1.0).toDouble();
      }
    }
    return null;
  }

  String _buildTextSummary(
    double stability,
    double release,
    double certification,
    double monetization,
    double drift,
    double integrityIndex,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('SYSTEM SNAPSHOT SUMMARY')
      ..writeln('=======================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Stability Integrity Score: ${pct(stability)}')
      ..writeln('Release QA Index: ${pct(release)}')
      ..writeln('Certification Score: ${pct(certification)}')
      ..writeln('Monetization Pulse Score: ${pct(monetization)}')
      ..writeln('Adaptive learning drift: ${pct(drift)}')
      ..writeln('System Integrity Index: ${pct(integrityIndex)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double stability,
    double release,
    double certification,
    double monetization,
    double drift,
    double integrityIndex,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'stability_integrity_score': stability,
    'release_qa_index': release,
    'certification_score': certification,
    'monetization_pulse_score': monetization,
    'adaptive_learning_drift': drift,
    'system_integrity_index': integrityIndex,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double stability,
    double release,
    double certification,
    double monetization,
    double drift,
    double integrityIndex,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'system_snapshot_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'stability_integrity_score': stability,
      'release_qa_index': release,
      'certification_score': certification,
      'monetization_pulse_score': monetization,
      'adaptive_learning_drift': drift,
      'system_integrity_index': integrityIndex,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
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
