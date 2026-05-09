import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _monetizationPath =
    '$_reportsDir/monetization_insight_summary.json';
const String _revenueForecastPath =
    '$_reportsDir/revenue_forecast_summary.json';
const String _retentionInsightPath =
    '$_reportsDir/retention_insight_summary.json';
const String _retentionCampaignPath =
    '$_reportsDir/retention_campaign_summary.json';
const String _summaryTextPath = '$_reportsDir/profitability_ltv_summary.txt';
const String _summaryJsonPath = '$_reportsDir/profitability_ltv_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _warnThreshold = 0.80;
const double _passThreshold = 0.90;

Future<void> main(List<String> args) async {
  final monitor = ProfitabilityLtvMonitor();
  final ok = await monitor.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ProfitabilityLtvMonitor {
  Future<bool> run() async {
    final monetization = await _readSummary(_monetizationPath);
    final revenue = await _readSummary(_revenueForecastPath);
    final retentionInsight = await _readSummary(_retentionInsightPath);
    if (monetization == null || revenue == null || retentionInsight == null) {
      stderr.writeln(
        'Required summaries missing or malformed (monetization/revenue/retention).',
      );
      return false;
    }

    final monetizationScore = _normalize(
      monetization['monetization_insight_score'],
    );
    final revenueScore = _normalize(revenue['revenue_forecast_score']);
    final retentionScore = _resolveRetentionScore(retentionInsight);
    final campaignLift = await _readCampaignLift();

    final adjustedRetention = (retentionScore * campaignLift)
        .clamp(0, 1)
        .toDouble();
    final ltvFactor = adjustedRetention * (0.5 + 0.5 * revenueScore);
    final profitabilityScore =
        monetizationScore * revenueScore * adjustedRetention;
    final index = (0.5 * profitabilityScore + 0.5 * ltvFactor)
        .clamp(0, 1)
        .toDouble();

    final verdict = index >= _passThreshold
        ? 'PASS'
        : index >= _warnThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      monetizationScore,
      revenueScore,
      adjustedRetention,
      ltvFactor,
      profitabilityScore,
      index,
      verdict,
      campaignLiftUsed: campaignLift != 1.0,
    );
    final summaryJson = _buildJsonSummary(
      monetizationScore,
      revenueScore,
      adjustedRetention,
      ltvFactor,
      profitabilityScore,
      index,
      verdict,
      campaignLiftUsed: campaignLift != 1.0,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        monetizationScore,
        revenueScore,
        adjustedRetention,
        index,
        verdict,
      );
    });

    if (index < _passThreshold) {
      stderr.writeln(
        'Profitability & LTV Index ${index.toStringAsFixed(3)} below ${_passThreshold.toStringAsFixed(2)}.',
      );
    }

    return index >= _passThreshold;
  }

  Future<Map<String, dynamic>?> _readSummary(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  double _normalize(dynamic value) {
    if (value is num) {
      final doubleVal = value.toDouble();
      if (doubleVal <= 1.0) {
        return doubleVal.clamp(0, 1).toDouble();
      }
      return (doubleVal / 100).clamp(0, 1).toDouble();
    }
    return 0;
  }

  double _resolveRetentionScore(Map<String, dynamic> retention) {
    final candidates = [
      retention['retention_score'],
      retention['user_retention_score'],
      retention['retention'],
      retention['retention_insight_score'],
    ];
    for (final candidate in candidates) {
      final normalized = _normalize(candidate);
      if (normalized > 0) return normalized;
    }
    return 0;
  }

  Future<double> _readCampaignLift() async {
    final file = File(_retentionCampaignPath);
    if (!await file.exists()) return 1.0;
    try {
      final Map<String, dynamic> decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final lift = _normalize(decoded['retention_index']);
      return lift == 0 ? 1.0 : lift;
    } catch (_) {
      return 1.0;
    }
  }

  String _buildTextSummary(
    double monetization,
    double revenue,
    double retention,
    double ltvFactor,
    double profitabilityScore,
    double index,
    String verdict, {
    required bool campaignLiftUsed,
  }) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('PROFITABILITY & LTV MONITOR SUMMARY')
      ..writeln('===================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Monetization Insight Score: ${pct(monetization)}')
      ..writeln('Revenue Forecast Score: ${pct(revenue)}')
      ..writeln('Retention Score: ${pct(retention)}')
      ..writeln('Base LTV Factor: ${pct(ltvFactor)}')
      ..writeln('Profitability Score: ${pct(profitabilityScore)}')
      ..writeln('Profitability & LTV Index: ${pct(index)}')
      ..writeln('Verdict: $verdict')
      ..writeln()
      ..writeln(
        'Notes: ${campaignLiftUsed ? 'Retention campaign lift applied.' : 'Retention campaign summary missing; neutral lift used.'}',
      )
      ..writeln('Scores normalized from 0–100 to 0–1 range.');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double monetization,
    double revenue,
    double retention,
    double ltvFactor,
    double profitabilityScore,
    double index,
    String verdict, {
    required bool campaignLiftUsed,
  }) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'monetization_insight_score': monetization,
      'revenue_forecast_score': revenue,
      'retention_score': retention,
      'ltv_factor': ltvFactor,
      'profitability_score': profitabilityScore,
      'profitability_ltv_index': index,
      'verdict': verdict,
      'used_retention_campaign': campaignLiftUsed,
    };
  }

  Future<void> _appendTelemetry(
    double monetization,
    double revenue,
    double retention,
    double index,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'profitability_ltv_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'monetization_insight_score': monetization,
      'revenue_forecast_score': revenue,
      'retention_score': retention,
      'profitability_ltv_index': index,
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
