import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _marketingGatewayPath =
    '$_reportsDir/marketing_gateway_summary.json';
const String _retentionSummaryPath =
    '$_reportsDir/retention_insight_summary.json';
const String _onboardingSummaryPath =
    '$_reportsDir/marketing_onboarding_qa_final_summary.json';
const String _summaryTextPath = '$_reportsDir/user_funnel_summary.txt';
const String _summaryJsonPath = '$_reportsDir/user_funnel_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _maxTimestampDelta = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final integrator = UserFunnelIntegrator();
  final ok = await integrator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class UserFunnelIntegrator {
  Future<bool> run() async {
    final gateway = await _readJson(_marketingGatewayPath);
    final retention = await _readJson(_retentionSummaryPath);
    final onboarding = await _readJson(_onboardingSummaryPath);

    if (gateway == null || retention == null || onboarding == null) {
      stderr.writeln('Missing one or more funnel summaries.');
      return false;
    }

    final timestamps = <DateTime>[];
    _collectTimestamp(gateway, timestamps);
    _collectTimestamp(retention, timestamps);
    _collectTimestamp(onboarding, timestamps);
    final timeAligned = _timestampsAligned(timestamps);

    final gatewayPass = _isPass(gateway);
    final retentionPass = _isPass(retention);
    final onboardingPass = _isPass(onboarding);
    final passed = [
      gatewayPass,
      retentionPass,
      onboardingPass,
    ].where((v) => v).length;
    final score = passed / 3.0;
    final pass = score >= _threshold && timeAligned;

    final conversionRate = _normalize(retention['conversion']);
    final retentionRate = _normalize(retention['retention']);
    final onboardingRate = _normalize(onboarding['marketing_onboarding_score']);

    if (conversionRate == null ||
        retentionRate == null ||
        onboardingRate == null) {
      stderr.writeln('Unable to derive funnel rates from summaries.');
      return false;
    }

    final funnelIndex =
        ((conversionRate * 0.4) +
                (retentionRate * 0.35) +
                (onboardingRate * 0.25))
            .clamp(0.0, 1.0);

    final summaryText = _buildTextSummary(
      conversionRate,
      retentionRate,
      onboardingRate,
      funnelIndex,
      score,
      timeAligned,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      conversionRate,
      retentionRate,
      onboardingRate,
      funnelIndex,
      score,
      timeAligned,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        conversionRate,
        retentionRate,
        onboardingRate,
        funnelIndex,
        score,
        timeAligned,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Funnel Cohesion Index ${(funnelIndex * 100).toStringAsFixed(2)}% '
        'or readiness score ${(score * 100).toStringAsFixed(2)}% below threshold.',
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

  void _collectTimestamp(Map<String, Object?>? data, List<DateTime> collector) {
    if (data == null) return;
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
    final delta = timestamps.last.difference(timestamps.first);
    return delta <= _maxTimestampDelta;
  }

  bool _isPass(Map<String, Object?> data) {
    final verdict = ((data['verdict'] as String?) ?? '').toUpperCase().trim();
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

  String _buildTextSummary(
    double conversionRate,
    double retentionRate,
    double onboardingRate,
    double funnelIndex,
    double readinessScore,
    bool timeAligned,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('USER FUNNEL INTEGRATOR SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Conversion rate: ${pct(conversionRate)}')
      ..writeln('Retention rate: ${pct(retentionRate)}')
      ..writeln('Onboarding score: ${pct(onboardingRate)}')
      ..writeln('Funnel Cohesion Index: ${pct(funnelIndex)}')
      ..writeln(
        'Gateway readiness score: ${(readinessScore * 100).toStringAsFixed(2)}%',
      )
      ..writeln('Timestamps aligned ≤24h: ${timeAligned ? 'yes' : 'no'}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double conversionRate,
    double retentionRate,
    double onboardingRate,
    double funnelIndex,
    double readinessScore,
    bool timeAligned,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'conversion_rate': conversionRate,
    'retention_rate': retentionRate,
    'onboarding_score': onboardingRate,
    'funnel_cohesion_index': funnelIndex,
    'readiness_score': readinessScore,
    'time_aligned': timeAligned,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double conversionRate,
    double retentionRate,
    double onboardingRate,
    double funnelIndex,
    double readinessScore,
    bool timeAligned,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'user_funnel_integrator_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'conversion_rate': conversionRate,
      'retention_rate': retentionRate,
      'onboarding_score': onboardingRate,
      'funnel_cohesion_index': funnelIndex,
      'readiness_score': readinessScore,
      'time_aligned': timeAligned,
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
