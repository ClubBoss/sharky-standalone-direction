import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _cohortPath = '$_reportsDir/cohort_health_bridge_summary.json';
const String _retentionPath = '$_reportsDir/retention_insight_summary.json';
const String _engagementPath = '$_reportsDir/engagement_economy_summary.json';
const String _textSummaryPath = '$_reportsDir/retention_growth_summary.txt';
const String _jsonSummaryPath = '$_reportsDir/retention_growth_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _maxDelta = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final engine = RetentionGrowthEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RetentionGrowthEngine {
  Future<bool> run() async {
    final cohort = await _readJson(_cohortPath);
    final retention = await _readJson(_retentionPath);
    final engagement = await _readJson(_engagementPath);

    if (cohort == null || retention == null || engagement == null) {
      stderr.writeln('Missing retention growth inputs.');
      return false;
    }

    if (!_isPass(cohort) || !_isPass(retention) || !_isPass(engagement)) {
      stderr.writeln('One or more inputs failed.');
      return false;
    }

    final timestamps = <DateTime>[];
    _collectTimestamp(cohort, timestamps);
    _collectTimestamp(retention, timestamps);
    _collectTimestamp(engagement, timestamps);
    if (!_timestampsAligned(timestamps)) {
      stderr.writeln('Inputs span more than 24h.');
      return false;
    }

    final retentionScore = _normalize(retention['retention']) ?? 0.0;
    final cohortIndex = _normalize(cohort['cohort_health_index']) ?? 0.0;
    final engagementScore = _normalize(engagement['engagement_score']) ?? 0.0;
    final score =
        ((retentionScore * 0.4) +
                (cohortIndex * 0.35) +
                (engagementScore * 0.25))
            .clamp(0.0, 1.0);

    final pass = score >= _threshold;

    final textSummary = _buildTextSummary(
      retentionScore,
      cohortIndex,
      engagementScore,
      score,
      pass,
    );
    final jsonSummary = _buildJsonSummary(
      retentionScore,
      cohortIndex,
      engagementScore,
      score,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_textSummaryPath).writeAsString(textSummary);
      await File(
        _jsonSummaryPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(jsonSummary));
      await _appendTelemetry(
        retentionScore,
        cohortIndex,
        engagementScore,
        score,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Retention Growth Score ${(score * 100).toStringAsFixed(2)}% below threshold.',
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

  bool _isPass(Map<String, Object?> data) {
    final verdict = ((data['verdict'] as String?) ?? '').toUpperCase();
    return verdict == 'PASS';
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

  double? _normalize(Object? raw) {
    final value = _parseDouble(raw);
    if (value == null) return null;
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0.0, 1.0);
  }

  double? _parseDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  String _buildTextSummary(
    double retention,
    double cohort,
    double engagement,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('RETENTION GROWTH SUMMARY')
      ..writeln('========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Retention score: ${pct(retention)}')
      ..writeln('Cohort health index: ${pct(cohort)}')
      ..writeln('Engagement score: ${pct(engagement)}')
      ..writeln('Retention Growth Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double retention,
    double cohort,
    double engagement,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'retention_score': retention,
    'cohort_health_index': cohort,
    'engagement_score': engagement,
    'retention_growth_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double retention,
    double cohort,
    double engagement,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'retention_growth_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'retention_score': retention,
      'cohort_health_index': cohort,
      'engagement_score': engagement,
      'retention_growth_score': score,
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
