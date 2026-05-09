import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _stabilityPath = '$_reportsDir/stability_dashboard_summary.json';
const String _forecastPath =
    '$_reportsDir/regression_health_forecast_summary.json';
const String _maintenancePath =
    '$_reportsDir/automation_maintenance_consolidator_summary.json';
const String _rsiPath = '$_reportsDir/rsi_auto_recovery_summary.txt';
const String _historyPath = '$_reportsDir/_regression_maintenance_history.json';
const String _summaryTextPath =
    '$_reportsDir/continuous_regression_assurance_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/continuous_regression_assurance_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _warnThreshold = 0.85;
const double _passThreshold = 0.95;

Future<void> main(List<String> args) async {
  final assurance = ContinuousRegressionAssurance();
  final ok = await assurance.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ContinuousRegressionAssurance {
  Future<bool> run() async {
    final stability = await _readJson(_stabilityPath);
    final forecast = await _readJson(_forecastPath);
    final maintenance = await _readJson(_maintenancePath);
    if (stability == null || forecast == null || maintenance == null) {
      stderr.writeln(
        'Required regression assurance summaries missing or malformed.',
      );
      return false;
    }

    final forecastScore = (forecast['latest_rsi'] as num?)?.toDouble() ?? 0;
    final stabilityScore = (stability['health_score'] as num?)?.toDouble() ?? 0;
    final maintenanceScore =
        (maintenance['automation_integrity_index'] as num?)?.toDouble() ?? 0;
    final failPatterns = await _detectFailPatterns();
    var ras =
        (forecastScore * 0.4) +
        (stabilityScore * 0.3) +
        (maintenanceScore * 0.3);

    if (await File(_rsiPath).exists()) {
      ras = (ras * 1.02).clamp(0, 1);
    }

    if (failPatterns >= 2) {
      ras = (ras * 0.95).clamp(0, 1);
    }

    final verdict = ras >= _passThreshold
        ? 'PASS'
        : ras >= _warnThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      forecastScore,
      stabilityScore,
      maintenanceScore,
      ras,
      verdict,
      failPatterns,
    );
    final summaryJson = _buildJsonSummary(
      forecastScore,
      stabilityScore,
      maintenanceScore,
      ras,
      verdict,
      failPatterns,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        forecastScore,
        stabilityScore,
        maintenanceScore,
        ras,
        verdict,
      );
    });

    if (ras < _warnThreshold) {
      stderr.writeln(
        'Regression Assurance Score ${ras.toStringAsFixed(3)} below 0.85.',
      );
    } else if (ras < _passThreshold) {
      stderr.writeln(
        'Regression Assurance Score ${ras.toStringAsFixed(3)} warning range.',
      );
    }

    return ras >= _passThreshold;
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

  Future<int> _detectFailPatterns() async {
    final file = File(_historyPath);
    if (!await file.exists()) return 0;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! List) return 0;
      int failCount = 0;
      for (final entry in decoded.takeLast(10)) {
        if (entry is Map &&
            (entry['verdict']?.toString().toUpperCase() == 'FAIL')) {
          failCount++;
        }
      }
      return failCount;
    } catch (_) {
      return 0;
    }
  }

  String _buildTextSummary(
    double forecast,
    double stability,
    double maintenance,
    double ras,
    String verdict,
    int failPatterns,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('CONTINUOUS REGRESSION ASSURANCE SUMMARY')
      ..writeln('=======================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Forecast strength: ${pct(forecast)}')
      ..writeln('Stability health: ${pct(stability)}')
      ..writeln('Maintenance integrity: ${pct(maintenance)}')
      ..writeln('Detected fail patterns: $failPatterns')
      ..writeln('Regression Assurance Score: ${pct(ras)}')
      ..writeln(
        'Thresholds: PASS ≥ ${(_passThreshold * 100).toStringAsFixed(0)}%, '
        'WARN ≥ ${(_warnThreshold * 100).toStringAsFixed(0)}%',
      )
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double forecast,
    double stability,
    double maintenance,
    double ras,
    String verdict,
    int failPatterns,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'forecast_strength': forecast,
      'stability_health': stability,
      'maintenance_integrity': maintenance,
      'fail_patterns': failPatterns,
      'regression_assurance_score': ras,
      'thresholds': {'warn': _warnThreshold, 'pass': _passThreshold},
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(
    double forecast,
    double stability,
    double maintenance,
    double ras,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'continuous_regression_assurance_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'forecast_strength': forecast,
      'stability_health': stability,
      'maintenance_integrity': maintenance,
      'regression_assurance_score': ras,
      'verdict': verdict,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

extension<T> on List<T> {
  Iterable<T> takeLast(int count) {
    if (length <= count) return this;
    return sublist(length - count);
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
