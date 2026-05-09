import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _profitabilityPath = '$_reportsDir/profitability_ltv_summary.json';
const String _revenueForecastPath =
    '$_reportsDir/revenue_forecast_summary.json';
const String _monetizationPath =
    '$_reportsDir/monetization_insight_summary.json';
const String _summaryTextPath = '$_reportsDir/revenue_stability_summary.txt';
const String _summaryJsonPath = '$_reportsDir/revenue_stability_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _warnThreshold = 0.85;
const double _passThreshold = 0.95;

Future<void> main(List<String> args) async {
  final audit = RevenueStabilityAudit();
  final ok = await audit.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RevenueStabilityAudit {
  Future<bool> run() async {
    final profitability = await _readJson(_profitabilityPath);
    final forecast = await _readJson(_revenueForecastPath);
    final monetization = await _readJson(_monetizationPath);
    if (profitability == null || forecast == null || monetization == null) {
      stderr.writeln(
        'Required summaries missing or malformed (profitability/revenue forecast/monetization).',
      );
      return false;
    }

    final profitabilityIndex =
        (profitability['profitability_ltv_index'] as num?)?.toDouble() ?? 0;
    final revenueScore =
        (forecast['revenue_forecast_score'] as num?)?.toDouble() ?? 0;
    final monetizationScore =
        (monetization['monetization_insight_score'] as num?)?.toDouble() ?? 0;

    final stabilityIndex = _computeStability(
      profitabilityIndex,
      revenueScore,
      monetizationScore,
    );

    final verdict = stabilityIndex >= _passThreshold
        ? 'PASS'
        : stabilityIndex >= _warnThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      profitabilityIndex,
      revenueScore,
      monetizationScore,
      stabilityIndex,
      verdict,
    );
    final summaryJson = _buildJsonSummary(
      profitabilityIndex,
      revenueScore,
      monetizationScore,
      stabilityIndex,
      verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        profitabilityIndex,
        revenueScore,
        monetizationScore,
        stabilityIndex,
        verdict,
      );
    });

    if (stabilityIndex < _warnThreshold) {
      stderr.writeln(
        'Revenue Stability Index ${stabilityIndex.toStringAsFixed(3)} below 0.85.',
      );
    } else if (stabilityIndex < _passThreshold) {
      stderr.writeln(
        'Revenue Stability Index ${stabilityIndex.toStringAsFixed(3)} warning range.',
      );
    }

    return stabilityIndex >= _passThreshold;
  }

  Future<Map<String, dynamic>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }

  double _computeStability(
    double profitabilityIndex,
    double revenueScore,
    double monetizationScore,
  ) {
    final metrics = [profitabilityIndex, revenueScore, monetizationScore];
    final mean = metrics.reduce((a, b) => a + b) / metrics.length;
    final variance =
        metrics
            .map((value) => pow(value - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        metrics.length;
    final stdDev = sqrt(variance);
    final consistency = 1 - stdDev;
    final stability = (consistency * mean).clamp(0, 1).toDouble();
    return stability;
  }

  String _buildTextSummary(
    double profitability,
    double revenue,
    double monetization,
    double stability,
    String verdict,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('REVENUE STABILITY SUMMARY')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Profitability & LTV Index: ${pct(profitability)}')
      ..writeln('Revenue Forecast Score: ${pct(revenue)}')
      ..writeln('Monetization Insight Score: ${pct(monetization)}')
      ..writeln('Revenue Stability Index: ${pct(stability)}')
      ..writeln(
        'Thresholds: PASS ≥ ${(_passThreshold * 100).toStringAsFixed(0)}%, '
        'WARN ≥ ${(_warnThreshold * 100).toStringAsFixed(0)}%',
      )
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double profitability,
    double revenue,
    double monetization,
    double stability,
    String verdict,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'profitability_ltv_index': profitability,
      'revenue_forecast_score': revenue,
      'monetization_insight_score': monetization,
      'revenue_stability_index': stability,
      'thresholds': {'warn': _warnThreshold, 'pass': _passThreshold},
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(
    double profitability,
    double revenue,
    double monetization,
    double stability,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'revenue_stability_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'profitability_ltv_index': profitability,
      'revenue_forecast_score': revenue,
      'monetization_insight_score': monetization,
      'revenue_stability_index': stability,
      'verdict': verdict,
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
