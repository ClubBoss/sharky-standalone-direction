import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _regressionSnapshotPath =
    '$_reportsDir/regression_snapshot_summary.json';
const String _qaVerificationPath =
    '$_reportsDir/qa_auto_verification_summary.json';
const String _systemSnapshotPath =
    '$_reportsDir/system_snapshot_v3_summary.json';
const String _summaryTextPath =
    '$_reportsDir/regression_snapshot_audit_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/regression_snapshot_audit_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.95;

Future<void> main(List<String> args) async {
  final audit = RegressionSnapshotAudit();
  final ok = await audit.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RegressionSnapshotAudit {
  final List<_AuditTarget> _targets = const <_AuditTarget>[
    _AuditTarget(label: 'Regression snapshot', path: _regressionSnapshotPath),
    _AuditTarget(label: 'QA auto verification', path: _qaVerificationPath),
    _AuditTarget(label: 'System snapshot v3', path: _systemSnapshotPath),
  ];

  Future<bool> run() async {
    final results = <_AuditResult>[];
    int consistent = 0;
    for (final target in _targets) {
      final data = await _readJson(target.path);
      if (data == null) {
        results.add(
          _AuditResult(
            label: target.label,
            path: target.path,
            verdict: 'MISSING',
            timestamp: null,
            consistent: false,
          ),
        );
        continue;
      }
      final verdict = ((data['verdict'] as String?) ?? '').toUpperCase();
      final generated =
          data['generated_at'] as String? ?? data['timestamp'] as String?;
      final consistentVerdict = verdict == 'PASS';
      if (consistentVerdict) {
        consistent++;
      }
      results.add(
        _AuditResult(
          label: target.label,
          path: target.path,
          verdict: verdict.isEmpty ? 'UNKNOWN' : verdict,
          timestamp: generated,
          consistent: consistentVerdict,
        ),
      );
    }

    final total = _targets.length;
    final score = total == 0 ? 0.0 : consistent / total;
    final pass = score >= _threshold && consistent == total;

    final summaryText = _buildTextSummary(results, score, pass);
    final summaryJson = _buildJsonSummary(results, score, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(results, score, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Regression Audit Score ${(score * 100).toStringAsFixed(2)}% below 95%.',
      );
    }

    return pass;
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

  String _buildTextSummary(
    List<_AuditResult> results,
    double score,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('REGRESSION SNAPSHOT AUDIT SUMMARY')
      ..writeln('=================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Score: ${(score * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Targets:');
    for (final result in results) {
      buffer.writeln(
        '- ${result.label} (${result.path}): verdict=${result.verdict}, '
        'timestamp=${result.timestamp ?? 'missing'}, passed=${result.consistent}',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    List<_AuditResult> results,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'threshold': _threshold,
    'score': score,
    'verdict': pass ? 'PASS' : 'FAIL',
    'targets': results.map((result) => result.toJson()).toList(),
  };

  Future<void> _appendTelemetry(
    List<_AuditResult> results,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'regression_snapshot_audit_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'score': score,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
      'targets': results.map((result) => result.toJson()).toList(),
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _AuditTarget {
  const _AuditTarget({required this.label, required this.path});

  final String label;
  final String path;
}

class _AuditResult {
  _AuditResult({
    required this.label,
    required this.path,
    required this.verdict,
    required this.timestamp,
    required this.consistent,
  });

  final String label;
  final String path;
  final String verdict;
  final String? timestamp;
  final bool consistent;

  Map<String, Object?> toJson() => {
    'label': label,
    'path': path,
    'verdict': verdict,
    'timestamp': timestamp,
    'consistent': consistent,
  };
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
