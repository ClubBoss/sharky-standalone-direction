import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _conversionPath =
    '$_reportsDir/conversion_attribution_summary.json';
const String _campaignPath = '$_reportsDir/campaign_optimizer_summary.json';
const String _retentionPath = '$_reportsDir/retention_insight_summary.json';
const String _summaryTextPath = '$_reportsDir/forecast_feedback_summary.txt';
const String _summaryJsonPath = '$_reportsDir/forecast_feedback_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _thresholdScore = 0.9;

Future<void> main(List<String> args) async {
  final integrator = ForecastFeedbackIntegrator();
  final ok = await integrator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ForecastFeedbackIntegrator {
  Future<bool> run() async {
    final conversion = await _readJson(_conversionPath);
    final campaign = await _readJson(_campaignPath);
    final retention = await _readJson(_retentionPath);

    final conversionGain =
        ((conversion['accuracy'] as num?)?.toDouble() ?? 0) / 100;
    final retentionScore =
        ((retention['user_retention_score'] as num?)?.toDouble() ?? 0) / 100;
    final optimizerUplift =
        ((campaign['global_ev_uplift'] as num?)?.toDouble() ?? 0);
    final optimizerNormalized = (optimizerUplift / 5).clamp(0, 1);

    final forecastFeedbackScore =
        (conversionGain + retentionScore + optimizerNormalized) / 3;
    final roiDelta =
        ((conversionGain + retentionScore) / 2) * (optimizerUplift / 100);
    final verdict = forecastFeedbackScore >= _thresholdScore ? 'PASS' : 'FAIL';

    final summaryText = _buildTextSummary(
      conversionGain: conversionGain,
      retentionScore: retentionScore,
      optimizerUplift: optimizerUplift,
      score: forecastFeedbackScore,
      roiDelta: roiDelta,
      verdict: verdict,
    );
    final summaryJson = _buildJsonSummary(
      conversionGain: conversionGain,
      retentionScore: retentionScore,
      optimizerUplift: optimizerUplift,
      score: forecastFeedbackScore,
      roiDelta: roiDelta,
      verdict: verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(forecastFeedbackScore, verdict);
    });

    if (forecastFeedbackScore < _thresholdScore) {
      stderr.writeln(
        'Forecast Feedback Score ${forecastFeedbackScore.toStringAsFixed(3)} below 0.9 threshold.',
      );
    }
    return forecastFeedbackScore >= _thresholdScore;
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
    required double conversionGain,
    required double retentionScore,
    required double optimizerUplift,
    required double score,
    required double roiDelta,
    required String verdict,
  }) {
    final buffer = StringBuffer()
      ..writeln('FORECAST FEEDBACK SUMMARY')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Conversion gain: ${(conversionGain * 100).toStringAsFixed(2)}%',
      )
      ..writeln(
        'Retention score: ${(retentionScore * 100).toStringAsFixed(2)}%',
      )
      ..writeln('Optimizer uplift: ${optimizerUplift.toStringAsFixed(2)}%')
      ..writeln('ROI delta: ${(roiDelta * 100).toStringAsFixed(2)}%')
      ..writeln('Forecast Feedback Score: ${score.toStringAsFixed(3)}')
      ..writeln('Threshold: ${_thresholdScore.toStringAsFixed(2)}')
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required double conversionGain,
    required double retentionScore,
    required double optimizerUplift,
    required double score,
    required double roiDelta,
    required String verdict,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'conversion_gain': conversionGain,
      'retention_score': retentionScore,
      'optimizer_uplift_percent': optimizerUplift,
      'roi_delta': roiDelta,
      'forecast_feedback_score': score,
      'threshold': _thresholdScore,
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(double score, String verdict) async {
    final payload = <String, Object?>{
      'event': 'forecast_feedback_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'forecast_feedback_score': score,
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
