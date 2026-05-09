import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/regression_health_forecaster.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/regression_health_forecast_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/regression_health_forecast_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final cli = RegressionHealthForecasterCli();
  final ok = await cli.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RegressionHealthForecasterCli {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final forecaster = RegressionHealthForecaster();
    late final RegressionHealthForecastResult result;
    try {
      result = await forecaster.buildForecast();
    } on StateError catch (error) {
      stderr.writeln(error.message);
      return false;
    }

    final clampedForecasts = _clampForecasts(result.forecasts);
    final thresholdsMet = _forecastsMeetThresholds(
      clampedForecasts,
      result.latestRsi,
    );

    final summaryText = _buildTextSummary(
      result,
      stopwatch.elapsedMilliseconds,
      clampedForecasts,
      thresholdsMet,
    );
    final summaryJson = _buildJsonSummary(
      result,
      stopwatch.elapsedMilliseconds,
      clampedForecasts,
      thresholdsMet,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        result,
        stopwatch.elapsedMilliseconds,
        clampedForecasts,
        thresholdsMet,
      );
    });

    if (!thresholdsMet) {
      stderr.writeln(
        'Forecasted RSI outside 90-100% clamp or latest RSI below 90% (latest: '
        '${result.latestRsi.toStringAsFixed(2)}%, projections: '
        '${clampedForecasts.map((v) => v.toStringAsFixed(2)).join(', ')}).',
      );
    }

    return thresholdsMet;
  }

  String _buildTextSummary(
    RegressionHealthForecastResult result,
    int durationMs,
    List<double> forecasts,
    bool thresholdsMet,
  ) {
    final buffer = StringBuffer()
      ..writeln('REGRESSION HEALTH FORECAST')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Latest RSI: ${result.latestRsi.toStringAsFixed(2)}')
      ..writeln(
        'Rolling 7-run trend: ${result.rollingTrend.toStringAsFixed(2)} RSI / run',
      )
      ..writeln('Recovery slope: ${result.recoverySlope.toStringAsFixed(2)}')
      ..writeln('Consolidation verdict: ${result.consolidationVerdict}')
      ..writeln('Guardian RSI: ${result.guardianRsi.toStringAsFixed(2)}%')
      ..writeln('Thresholds met: ${thresholdsMet ? 'YES' : 'NO'}')
      ..writeln()
      ..writeln('Forecast RSI (clamped to 90-100%):')
      ..writeln(
        forecasts
            .asMap()
            .entries
            .map(
              (entry) =>
                  '  Run +${entry.key + 1}: ${entry.value.toStringAsFixed(2)}%',
            )
            .join('\n'),
      )
      ..writeln()
      ..writeln('History (most recent last):');
    for (final entry in result.history) {
      buffer.writeln(
        '  ${entry.timestamp} → ${entry.rsi.toStringAsFixed(2)} (${entry.verdict})',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    RegressionHealthForecastResult result,
    int durationMs,
    List<double> clampedForecasts,
    bool thresholdsMet,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'duration_ms': durationMs,
      'latest_rsi': result.latestRsi,
      'rolling_trend': result.rollingTrend,
      'recovery_slope': result.recoverySlope,
      'guardian_rsi': result.guardianRsi,
      'consolidation_verdict': result.consolidationVerdict,
      'forecasts_raw': result.forecasts,
      'forecasts_clamped': clampedForecasts,
      'thresholds_met': thresholdsMet,
      'history': result.history
          .map(
            (entry) => {
              'timestamp': entry.timestamp,
              'rsi': entry.rsi,
              'verdict': entry.verdict,
            },
          )
          .toList(),
    };
  }

  Future<void> _appendTelemetry(
    RegressionHealthForecastResult result,
    int durationMs,
    List<double> clampedForecasts,
    bool thresholdsMet,
  ) async {
    final payload = {
      'event': 'regression_health_forecast_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'rolling_trend': result.rollingTrend,
      'recovery_slope': result.recoverySlope,
      'forecasts_raw': result.forecasts,
      'forecasts_clamped': clampedForecasts,
      'risk': result.risk,
      'thresholds_met': thresholdsMet,
      'duration_ms': durationMs,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }

  List<double> _clampForecasts(List<double> forecasts) {
    return forecasts
        .map((value) => value.clamp(90.0, 100.0).toDouble())
        .toList(growable: false);
  }

  bool _forecastsMeetThresholds(List<double> forecasts, double latestRsi) {
    if (latestRsi < 90) {
      return false;
    }
    return forecasts.every((value) => value >= 90 && value <= 100);
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
