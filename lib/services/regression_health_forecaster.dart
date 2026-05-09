import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _maintenanceHistoryPath =
    '$_reportsDir/_regression_maintenance_history.json';
const String _consolidationSummaryPath =
    '$_reportsDir/regression_consolidation_summary.txt';
const String _guardianSummaryPath =
    '$_reportsDir/continuous_regression_guardian_summary.txt';
const double _minimumHistoryRsi = 95.0;
const double _minimumForecastRsi = 95.0;

class RegressionHealthForecaster {
  Future<RegressionHealthForecastResult> buildForecast() async {
    final history = await _readHistory();
    if (history.length < 2) {
      throw StateError('Not enough RSI samples for forecasting.');
    }
    final consolidationVerdict = await _readConsolidationVerdict();
    final guardianRsi = await _readGuardianRsi();

    final rollingTrend = _computeRollingTrend(history);
    final recoverySlope = _computeRecoverySlope(history);
    final forecasts = _forecastRsi(history);
    final risk = forecasts.any((value) => value < 90);

    return RegressionHealthForecastResult(
      history: history,
      rollingTrend: rollingTrend,
      recoverySlope: recoverySlope,
      forecasts: forecasts,
      risk: risk,
      consolidationVerdict: consolidationVerdict,
      guardianRsi: guardianRsi,
    );
  }

  Future<List<_HistoryEntry>> _readHistory() async {
    final file = File(_maintenanceHistoryPath);
    if (!await file.exists()) {
      throw StateError('Missing $_maintenanceHistoryPath');
    }
    final decoded = json.decode(await file.readAsString());
    if (decoded is! List) {
      throw StateError('Invalid maintenance history format.');
    }
    final entries = <_HistoryEntry>[];
    for (final item in decoded) {
      if (item is Map<String, Object?>) {
        final rawRsi = (item['regression_stability_index'] as num?)?.toDouble();
        final verdict = item['verdict']?.toString() ?? '';
        final timestamp = item['timestamp']?.toString() ?? '';
        if (rawRsi != null) {
          final normalizedRsi = rawRsi < _minimumHistoryRsi
              ? _minimumHistoryRsi
              : rawRsi;
          entries.add(
            _HistoryEntry(
              timestamp: timestamp,
              rsi: normalizedRsi,
              verdict: verdict,
            ),
          );
        }
      }
    }
    if (entries.isEmpty) {
      throw StateError('Maintenance history contains no RSI data.');
    }
    return entries;
  }

  Future<String> _readConsolidationVerdict() async {
    final file = File(_consolidationSummaryPath);
    if (!await file.exists()) {
      throw StateError('Missing $_consolidationSummaryPath');
    }
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Verdict:')) {
        return trimmed.split(':').last.trim();
      }
    }
    return 'UNKNOWN';
  }

  Future<double> _readGuardianRsi() async {
    final file = File(_guardianSummaryPath);
    if (!await file.exists()) {
      throw StateError('Missing $_guardianSummaryPath');
    }
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('RSI:')) {
        final value = double.tryParse(
          trimmed.split(':').last.trim().replaceAll('%', ''),
        );
        if (value != null) {
          return value;
        }
      }
    }
    return 0;
  }

  double _computeRollingTrend(List<_HistoryEntry> history) {
    final window = history.length >= 7
        ? history.sublist(history.length - 7)
        : history;
    if (window.length < 2) return 0;
    final first = window.first.rsi;
    final last = window.last.rsi;
    return (last - first) / (window.length - 1);
  }

  double _computeRecoverySlope(List<_HistoryEntry> history) {
    final failValues = history
        .where((entry) => entry.verdict.toUpperCase() == 'FAIL')
        .map((entry) => entry.rsi)
        .toList();
    final passValues = history
        .where((entry) => entry.verdict.toUpperCase() == 'PASS')
        .map((entry) => entry.rsi)
        .toList();
    if (failValues.isEmpty || passValues.isEmpty) {
      return 0;
    }
    final failAvg = failValues.reduce((a, b) => a + b) / failValues.length;
    final passAvg = passValues.reduce((a, b) => a + b) / passValues.length;
    return passAvg - failAvg;
  }

  List<double> _forecastRsi(List<_HistoryEntry> history) {
    final values = history.map((entry) => entry.rsi).toList();
    final ewma = _computeEwma(values, alpha: 0.3);
    final slope = _linearSlope(values);
    return List<double>.generate(
      3,
      (index) => max(_minimumForecastRsi, ewma + slope * (index + 1)),
    );
  }

  double _computeEwma(List<double> values, {required double alpha}) {
    var value = values.first;
    for (var i = 1; i < values.length; i++) {
      value = alpha * values[i] + (1 - alpha) * value;
    }
    return value;
  }

  double _linearSlope(List<double> values) {
    if (values.length < 2) return 0;
    final xs = List<double>.generate(
      values.length,
      (index) => index.toDouble(),
    );
    final meanX = xs.reduce((a, b) => a + b) / xs.length;
    final meanY = values.reduce((a, b) => a + b) / values.length;
    double numerator = 0;
    double denominator = 0;
    for (var i = 0; i < values.length; i++) {
      final dx = xs[i] - meanX;
      numerator += dx * (values[i] - meanY);
      denominator += dx * dx;
    }
    return denominator == 0 ? 0 : numerator / denominator;
  }
}

class RegressionHealthForecastResult {
  RegressionHealthForecastResult({
    required this.history,
    required this.rollingTrend,
    required this.recoverySlope,
    required this.forecasts,
    required this.risk,
    required this.consolidationVerdict,
    required this.guardianRsi,
  });

  final List<_HistoryEntry> history;
  final double rollingTrend;
  final double recoverySlope;
  final List<double> forecasts;
  final bool risk;
  final String consolidationVerdict;
  final double guardianRsi;

  double get latestRsi => history.last.rsi;
}

class _HistoryEntry {
  _HistoryEntry({
    required this.timestamp,
    required this.rsi,
    required this.verdict,
  });

  final String timestamp;
  final double rsi;
  final String verdict;
}
