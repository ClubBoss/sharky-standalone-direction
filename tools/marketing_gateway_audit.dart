import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _freezeSummaryPath = '$_reportsDir/release_freeze_summary.json';
const String _marketingSummaryPath =
    '$_reportsDir/marketing_onboarding_qa_final_summary.json';
const String _retentionSummaryPath =
    '$_reportsDir/retention_insight_summary.json';
const String _summaryTextPath = '$_reportsDir/marketing_gateway_summary.txt';
const String _summaryJsonPath = '$_reportsDir/marketing_gateway_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.95;
const Duration _maxTimestampDelta = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final audit = MarketingGatewayAudit();
  final ok = await audit.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MarketingGatewayAudit {
  final List<_GatewayTarget> _targets = const <_GatewayTarget>[
    _GatewayTarget(label: 'Release Freeze', path: _freezeSummaryPath),
    _GatewayTarget(
      label: 'Marketing Onboarding QA',
      path: _marketingSummaryPath,
    ),
    _GatewayTarget(label: 'Retention Insight', path: _retentionSummaryPath),
  ];

  Future<bool> run() async {
    final results = <_GatewayResult>[];
    final timestamps = <DateTime>[];
    var passed = 0;
    for (final target in _targets) {
      final data = await _readJson(target.path);
      if (data == null) {
        results.add(
          _GatewayResult(
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
        _GatewayResult(
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
    final timeAligned = _timestampsAligned(timestamps);
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
        'Marketing Gateway Score ${(score * 100).toStringAsFixed(2)}% below threshold or timestamps misaligned.',
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
    List<_GatewayResult> results,
    double score,
    bool aligned,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('MARKETING GATEWAY SUMMARY')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Score: ${(score * 100).toStringAsFixed(2)}%')
      ..writeln('Timestamps within 24h: ${aligned ? 'yes' : 'no'}')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Inputs:');
    for (final result in results) {
      buffer.writeln(
        '- ${result.label}: ${result.verdict} '
        '(timestamp=${result.timestamp?.toIso8601String() ?? 'missing'}) '
        'passed=${result.consistent}',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    List<_GatewayResult> results,
    double score,
    bool aligned,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'threshold': _threshold,
    'score': score,
    'time_aligned': aligned,
    'verdict': pass ? 'PASS' : 'FAIL',
    'targets': results.map((result) => result.toJson()).toList(),
  };

  Future<void> _appendTelemetry(
    List<_GatewayResult> results,
    double score,
    bool aligned,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'marketing_gateway_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'score': score,
      'threshold': _threshold,
      'time_aligned': aligned,
      'verdict': pass ? 'PASS' : 'FAIL',
      'targets': results.map((result) => result.toJson()).toList(),
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _GatewayTarget {
  const _GatewayTarget({required this.label, required this.path});

  final String label;
  final String path;
}

class _GatewayResult {
  _GatewayResult({
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
