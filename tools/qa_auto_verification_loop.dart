import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _snapshotPath = '$_reportsDir/system_snapshot_v3_summary.json';
const String _releaseQaPath =
    '$_reportsDir/release_qa_consolidation_summary.json';
const String _stabilityPath =
    '$_reportsDir/stability_qa_consolidator_v2_summary.json';
const String _summaryTextPath = '$_reportsDir/qa_auto_verification_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/qa_auto_verification_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.95;

Future<void> main(List<String> args) async {
  final loop = QaAutoVerificationLoop();
  final ok = await loop.run();
  if (!ok) {
    exitCode = 2;
  }
}

class _Report {
  const _Report(this.label, this.path);

  final String label;
  final String path;
}

class QaAutoVerificationLoop {
  final List<_Report> _reports = const <_Report>[
    _Report('System Snapshot v3', _snapshotPath),
    _Report('Release QA Consolidation', _releaseQaPath),
    _Report('Stability QA Consolidator v2', _stabilityPath),
  ];

  Future<bool> run() async {
    final results = <Map<String, Object?>>[];
    var passed = 0;
    for (final report in _reports) {
      final data = await _readJson(report.path);
      final verdict = (data?['verdict'] as String?)?.toUpperCase();
      final success = verdict == 'PASS';
      if (data == null) {
        stderr.writeln('Missing report: ${report.label}');
      }
      if (success) passed++;
      results.add({
        'label': report.label,
        'path': report.path,
        'verdict': verdict ?? 'MISSING',
        'passed': success && data != null,
      });
    }

    final total = _reports.length;
    final score = passed / total;
    final pass =
        score >= _threshold && results.every((r) => r['passed'] == true);

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
        'QA verification score ${(score * 100).toStringAsFixed(2)}% below 95%.',
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
    List<Map<String, Object?>> results,
    double score,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('QA AUTO VERIFICATION SUMMARY')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Score: ${(score * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Report breakdown:');
    for (final report in results) {
      buffer.writeln(
        '- ${report['label']}: ${report['verdict']} '
        '(passed=${report['passed']})',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    List<Map<String, Object?>> results,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'threshold': _threshold,
    'score': score,
    'verdict': pass ? 'PASS' : 'FAIL',
    'reports': results,
  };

  Future<void> _appendTelemetry(
    List<Map<String, Object?>> results,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'qa_auto_verification_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'score': score,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
      'reports': results,
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
