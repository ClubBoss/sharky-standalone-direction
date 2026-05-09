import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _insightPath = '$_reportsDir/monetization_insight_summary.json';
const String _campaignPath = '$_reportsDir/campaign_optimizer_summary.json';
const String _forecastPath = '$_reportsDir/forecast_feedback_summary.json';
const String _summaryTextPath = '$_reportsDir/revenue_forecast_summary.txt';
const String _summaryJsonPath = '$_reportsDir/revenue_forecast_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _thresholdScore = 0.9;

Future<void> main(List<String> args) async {
  final dashboard = RevenueForecastDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RevenueForecastDashboard {
  Future<bool> run() async {
    final insight = await _readJson(_insightPath);
    final campaign = await _readJson(_campaignPath);
    final forecast = await _readJson(_forecastPath);
    if (insight.isEmpty || campaign.isEmpty || forecast.isEmpty) {
      stderr.writeln('Missing required input summaries for revenue forecast.');
      return false;
    }

    final insightScore =
        (insight['monetization_insight_score'] as num?)?.toDouble() ?? 0;
    final roiTrend = (campaign['global_ev_uplift'] as num?)?.toDouble() ?? 0;
    final feedback =
        (forecast['forecast_feedback_score'] as num?)?.toDouble() ?? 0;

    final score = (roiTrend / 10).clamp(0, 1) * feedback * insightScore;
    final verdict = score >= _thresholdScore ? 'PASS' : 'FAIL';

    final summaryText = _buildTextSummary(
      insightScore: insightScore,
      roiTrend: roiTrend,
      feedback: feedback,
      score: score,
      verdict: verdict,
    );
    final summaryJson = _buildJsonSummary(
      insightScore: insightScore,
      roiTrend: roiTrend,
      feedback: feedback,
      score: score,
      verdict: verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(score, verdict);
    });

    if (score < _thresholdScore) {
      stderr.writeln(
        'Revenue Forecast Score ${score.toStringAsFixed(3)} below 0.9.',
      );
    }
    return score >= _thresholdScore;
  }

  Future<Map<String, dynamic>> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return const {};
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return const {};
    }
    return const {};
  }

  String _buildTextSummary({
    required double insightScore,
    required double roiTrend,
    required double feedback,
    required double score,
    required String verdict,
  }) {
    final buffer = StringBuffer()
      ..writeln('REVENUE FORECAST SUMMARY')
      ..writeln('========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Monetization insight score: ${insightScore.toStringAsFixed(3)}',
      )
      ..writeln('Campaign ROI trend: ${roiTrend.toStringAsFixed(2)}%')
      ..writeln('Forecast feedback score: ${feedback.toStringAsFixed(3)}')
      ..writeln('Revenue Forecast Score: ${score.toStringAsFixed(3)}')
      ..writeln('Threshold: ${_thresholdScore.toStringAsFixed(2)}')
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required double insightScore,
    required double roiTrend,
    required double feedback,
    required double score,
    required String verdict,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'monetization_insight_score': insightScore,
      'campaign_roi_trend_percent': roiTrend,
      'forecast_feedback_score': feedback,
      'revenue_forecast_score': score,
      'threshold': _thresholdScore,
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(double score, String verdict) async {
    final payload = <String, Object?>{
      'event': 'revenue_forecast_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'revenue_forecast_score': score,
      'threshold': _thresholdScore,
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
