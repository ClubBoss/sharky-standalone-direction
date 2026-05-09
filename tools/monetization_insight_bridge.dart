import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _retentionPath = '$_reportsDir/retention_insight_summary.json';
const String _forecastPath = '$_reportsDir/forecast_feedback_summary.json';
const String _campaignPath = '$_reportsDir/campaign_optimizer_summary.json';
const String _summaryTextPath = '$_reportsDir/monetization_insight_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/monetization_insight_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _thresholdScore = 0.9;

Future<void> main(List<String> args) async {
  final bridge = MonetizationInsightBridge();
  final ok = await bridge.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MonetizationInsightBridge {
  Future<bool> run() async {
    final retention = await _readJson(_retentionPath);
    final forecast = await _readJson(_forecastPath);
    final campaign = await _readJson(_campaignPath);

    final retentionScore =
        ((retention['user_retention_score'] as num?)?.toDouble() ?? 0) / 100;
    final conversionGain =
        ((forecast['conversion_gain'] as num?)?.toDouble() ?? 0);
    final uplift =
        ((campaign['global_ev_uplift'] as num?)?.toDouble() ?? 0) / 100;

    final score =
        (retentionScore * 0.4) + (conversionGain * 0.3) + (uplift * 0.3);
    final verdict = score >= _thresholdScore ? 'PASS' : 'FAIL';

    final summaryText = _buildTextSummary(
      retention: retentionScore,
      conversion: conversionGain,
      uplift: uplift,
      score: score,
      verdict: verdict,
    );
    final summaryJson = _buildJsonSummary(
      retention: retentionScore,
      conversion: conversionGain,
      uplift: uplift,
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
        'Monetization Insight Score ${score.toStringAsFixed(3)} below 0.9.',
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
    required double retention,
    required double conversion,
    required double uplift,
    required double score,
    required String verdict,
  }) {
    final buffer = StringBuffer()
      ..writeln('MONETIZATION INSIGHT SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Retention score: ${(retention * 100).toStringAsFixed(2)}%')
      ..writeln('Conversion gain: ${(conversion * 100).toStringAsFixed(2)}%')
      ..writeln('Optimizer uplift: ${(uplift * 100).toStringAsFixed(2)}%')
      ..writeln('Monetization Insight Score: ${score.toStringAsFixed(3)}')
      ..writeln('Threshold: ${_thresholdScore.toStringAsFixed(2)}')
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required double retention,
    required double conversion,
    required double uplift,
    required double score,
    required String verdict,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'retention_score': retention,
      'conversion_gain': conversion,
      'optimizer_uplift': uplift,
      'monetization_insight_score': score,
      'threshold': _thresholdScore,
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(double score, String verdict) async {
    final payload = <String, Object?>{
      'event': 'monetization_insight_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'score': score,
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
