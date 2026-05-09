import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _retentionGrowthPath =
    '$_reportsDir/retention_growth_summary.json';
const String _engagementPath = '$_reportsDir/engagement_economy_summary.json';
const String _monetizationPath = '$_reportsDir/monetization_pulse_summary.json';
const String _summaryTextPath = '$_reportsDir/ltv_forecast_summary.txt';
const String _summaryJsonPath = '$_reportsDir/ltv_forecast_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _maxDelta = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final bridge = LtvForecastBridge();
  final ok = await bridge.run();
  if (!ok) {
    exitCode = 2;
  }
}

class LtvForecastBridge {
  Future<bool> run() async {
    final retentionGrowth = await _readJson(_retentionGrowthPath);
    final engagement = await _readJson(_engagementPath);
    final monetization = await _readJson(_monetizationPath);

    if (retentionGrowth == null || engagement == null || monetization == null) {
      stderr.writeln('Missing one or more LTV bridge inputs.');
      return false;
    }

    if (!_isPass(retentionGrowth) ||
        !_isPass(engagement) ||
        !_isPass(monetization)) {
      stderr.writeln('One or more inputs did not pass.');
      return false;
    }

    final timestamps = <DateTime>[];
    _collectTimestamp(retentionGrowth, timestamps);
    _collectTimestamp(engagement, timestamps);
    _collectTimestamp(monetization, timestamps);
    if (!_timestampsAligned(timestamps)) {
      stderr.writeln('Input timestamps span more than 24h.');
      return false;
    }

    final retentionScore =
        _normalize(retentionGrowth['retention_growth_score']) ?? 0.0;
    final engagementScore =
        _normalize(engagement['engagement_economy_score']) ?? 0.0;
    final monetizationScore =
        _normalize(monetization['monetization_pulse_score']) ?? 0.0;

    final ltvIndex =
        ((retentionScore * 0.4) +
                (monetizationScore * 0.35) +
                (engagementScore * 0.25))
            .clamp(0.0, 1.0);

    final pass = ltvIndex >= _threshold;

    final textSummary = _buildText(
      retentionScore,
      monetizationScore,
      engagementScore,
      ltvIndex,
      pass,
    );
    final jsonSummary = _buildJson(
      retentionScore,
      monetizationScore,
      engagementScore,
      ltvIndex,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(textSummary);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(jsonSummary));
      await _appendTelemetry(
        retentionScore,
        monetizationScore,
        engagementScore,
        ltvIndex,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'LTV Forecast Index ${(ltvIndex * 100).toStringAsFixed(2)}% below threshold.',
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
    double retention,
    double monetization,
    double engagement,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('LTV FORECAST SUMMARY')
      ..writeln('====================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Retention score: ${pct(retention)}')
      ..writeln('Monetization pulse: ${pct(monetization)}')
      ..writeln('Engagement score: ${pct(engagement)}')
      ..writeln('LTV Forecast Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double retention,
    double monetization,
    double engagement,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'retention_growth_score': retention,
    'monetization_pulse_score': monetization,
    'engagement_economy_score': engagement,
    'ltv_forecast_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double retention,
    double monetization,
    double engagement,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'ltv_forecast_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'retention_growth_score': retention,
      'monetization_pulse_score': monetization,
      'engagement_economy_score': engagement,
      'ltv_forecast_index': index,
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
