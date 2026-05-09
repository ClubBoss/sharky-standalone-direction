import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _funnelPath = '$_reportsDir/user_funnel_summary.json';
const String _retentionPath = '$_reportsDir/retention_insight_summary.json';
const String _telemetryPath =
    '$_reportsDir/post_release_telemetry_summary.json';
const String _summaryTextPath = '$_reportsDir/cohort_health_bridge_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/cohort_health_bridge_summary.json';
const String _telemetryLogPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _maxDelta = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final bridge = CohortHealthBridge();
  final ok = await bridge.run();
  if (!ok) {
    exitCode = 2;
  }
}

class CohortHealthBridge {
  Future<bool> run() async {
    final funnel = await _readJson(_funnelPath);
    final retention = await _readJson(_retentionPath);
    final telemetry = await _readJson(_telemetryPath);

    if (funnel == null || retention == null || telemetry == null) {
      stderr.writeln('Missing cohort health inputs.');
      return false;
    }

    if (!_isPass(funnel) || !_isPass(retention) || !_isPass(telemetry)) {
      stderr.writeln('One or more inputs did not pass.');
      return false;
    }

    final timestamps = <DateTime>[];
    _collectTimestamp(funnel, timestamps);
    _collectTimestamp(retention, timestamps);
    _collectTimestamp(telemetry, timestamps);
    if (!_timestampsAligned(timestamps)) {
      stderr.writeln('Inputs timestamps exceed 24h span.');
      return false;
    }

    final conversion = _normalize(funnel['conversion_rate']) ?? 0.0;
    final onboarding = _normalize(funnel['onboarding_score']) ?? 0.0;
    final retentionScore = _normalize(retention['retention']) ?? 0.0;
    final coverage = _normalize(telemetry['coverage_rate']) ?? 0.0;
    final anomalies = telemetry['anomalies'] as int? ?? 0;

    final cohIndex =
        ((conversion * 0.4) + (retentionScore * 0.35) + (coverage * 0.25))
            .clamp(0.0, 1.0);

    final pass = cohIndex >= _threshold;

    final summaryText = _buildText(
      conversion,
      retentionScore,
      coverage,
      cohIndex,
      anomalies,
      pass,
    );
    final summaryJson = _buildJson(
      conversion,
      retentionScore,
      coverage,
      cohIndex,
      anomalies,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        conversion,
        retentionScore,
        coverage,
        cohIndex,
        pass,
        anomalies,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Cohort Health Index ${(cohIndex * 100).toStringAsFixed(2)}% below threshold.',
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

  void _collectTimestamp(Map<String, Object?> data, List<DateTime> collector) {
    final generated =
        data['generated_at'] as String? ??
        data['generated'] as String? ??
        data['timestamp'] as String?;
    if (generated != null) {
      final parsed = DateTime.tryParse(generated);
      if (parsed != null) {
        collector.add(parsed);
      }
    }
  }

  bool _timestampsAligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _maxDelta;
  }

  bool _isPass(Map<String, Object?> data) {
    final verdict = ((data['verdict'] as String?) ?? '').toUpperCase();
    return verdict == 'PASS';
  }

  double? _normalize(Object? raw) {
    final value = _toDouble(raw);
    if (value == null) return null;
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0.0, 1.0);
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  String _buildText(
    double conversion,
    double retentionScore,
    double coverage,
    double chi,
    int anomalies,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('COHORT HEALTH BRIDGE SUMMARY')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Conversion rate: ${pct(conversion)}')
      ..writeln('Retention score: ${pct(retentionScore)}')
      ..writeln('Coverage rate: ${pct(coverage)}')
      ..writeln('Anomalies: $anomalies')
      ..writeln('Cohort Health Index: ${pct(chi)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double conversion,
    double retentionScore,
    double coverage,
    double chi,
    int anomalies,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'conversion_rate': conversion,
    'retention_score': retentionScore,
    'coverage_rate': coverage,
    'anomalies': anomalies,
    'cohort_health_index': chi,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double conversion,
    double retentionScore,
    double coverage,
    double chi,
    bool pass,
    int anomalies,
  ) async {
    final payload = <String, Object?>{
      'event': 'cohort_health_bridge_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'conversion_rate': conversion,
      'retention_score': retentionScore,
      'coverage_rate': coverage,
      'anomalies': anomalies,
      'cohort_health_index': chi,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryLogPath).openWrite(mode: FileMode.append);
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
