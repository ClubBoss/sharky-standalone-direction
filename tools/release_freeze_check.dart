import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _regressionAuditPath =
    '$_reportsDir/regression_snapshot_audit_summary.json';
const String _systemSnapshotPath =
    '$_reportsDir/system_snapshot_v3_summary.json';
const String _certificationSummaryPath =
    '$_reportsDir/final_release_certification_summary.json';
const String _summaryTextPath = '$_reportsDir/release_freeze_summary.txt';
const String _summaryJsonPath = '$_reportsDir/release_freeze_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.95;
const Duration _maxTimestampDelta = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final checker = ReleaseFreezeCheck();
  final ok = await checker.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ReleaseFreezeCheck {
  final List<_FreezeTarget> _targets = const <_FreezeTarget>[
    _FreezeTarget(
      label: 'Regression Snapshot Audit',
      path: _regressionAuditPath,
    ),
    _FreezeTarget(label: 'System Snapshot v3', path: _systemSnapshotPath),
    _FreezeTarget(
      label: 'Final Release Certification',
      path: _certificationSummaryPath,
    ),
  ];

  Future<bool> run() async {
    final results = <_FreezeResult>[];
    final timestamps = <DateTime>[];
    var passed = 0;
    for (final target in _targets) {
      final data = await _readJson(target.path);
      if (data == null) {
        results.add(
          _FreezeResult(
            label: target.label,
            path: target.path,
            verdict: 'MISSING',
            timestamp: null,
            consistent: false,
          ),
        );
        continue;
      }
      final verdict = ((data['verdict'] as String?) ?? '').toUpperCase().trim();
      final generated =
          data['generated_at'] as String? ??
          data['generated'] as String? ??
          data['timestamp'] as String?;
      DateTime? parsed;
      if (generated != null) {
        parsed = DateTime.tryParse(generated);
        if (parsed != null) {
          timestamps.add(parsed);
        }
      }
      final success = verdict == 'PASS';
      if (success) {
        passed++;
      }
      results.add(
        _FreezeResult(
          label: target.label,
          path: target.path,
          verdict: verdict.isEmpty ? 'UNKNOWN' : verdict,
          timestamp: parsed,
          consistent: success,
        ),
      );
    }

    final total = _targets.length;
    final double score = total == 0 ? 0.0 : passed / total;
    final bool timeAligned = _timestampsAligned(timestamps);
    final pass = score >= _threshold && timeAligned;

    final summaryText = _buildText(results, score, timeAligned, pass);
    final summaryJson = _buildJson(results, score, timeAligned, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(results, score, timeAligned, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Release freeze integrity ${(score * 100).toStringAsFixed(2)}% '
        'with timestamps aligned=${timeAligned ? 'yes' : 'no'} below ${(_threshold * 100).toStringAsFixed(2)}%.',
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

  bool _timestampsAligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    final delta = timestamps.last.difference(timestamps.first);
    return delta <= _maxTimestampDelta;
  }

  String _buildText(
    List<_FreezeResult> results,
    double score,
    bool timeAligned,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('RELEASE FREEZE CHECK SUMMARY')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Score: ${(score * 100).toStringAsFixed(2)}%')
      ..writeln('Timestamps aligned within 24h: ${timeAligned ? 'yes' : 'no'}')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Targets:');
    for (final result in results) {
      buffer.writeln(
        '- ${result.label}: verdict=${result.verdict}, '
        'timestamp=${result.timestamp?.toIso8601String() ?? 'missing'}, '
        'passed=${result.consistent}',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    List<_FreezeResult> results,
    double score,
    bool timeAligned,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'threshold': _threshold,
    'score': score,
    'time_aligned': timeAligned,
    'verdict': pass ? 'PASS' : 'FAIL',
    'targets': results.map((result) => result.toJson()).toList(),
  };

  Future<void> _appendTelemetry(
    List<_FreezeResult> results,
    double score,
    bool timeAligned,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'release_freeze_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'score': score,
      'time_aligned': timeAligned,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
      'targets': results.map((result) => result.toJson()).toList(),
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _FreezeTarget {
  const _FreezeTarget({required this.label, required this.path});

  final String label;
  final String path;
}

class _FreezeResult {
  _FreezeResult({
    required this.label,
    required this.path,
    required this.verdict,
    required this.timestamp,
    required this.consistent,
  });

  final String label;
  final String path;
  final String verdict;
  final DateTime? timestamp;
  final bool consistent;

  Map<String, Object?> toJson() => {
    'label': label,
    'path': path,
    'verdict': verdict,
    'timestamp': timestamp?.toIso8601String(),
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
