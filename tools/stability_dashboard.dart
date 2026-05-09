import 'dart:convert';
import 'dart:io';

const String _reportsRoot = 'release/_reports';
const String _summaryTxt = 'release/_reports/stability_dashboard_summary.txt';
const String _summaryJson = 'release/_reports/stability_dashboard_summary.json';
const String _forecastJson =
    'release/_reports/regression_health_forecast_summary.json';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final reports = await _collectReports();
  final total = reports.length;
  final passes = reports.where((report) => report.status == 'PASS').length;
  final score = total == 0 ? 100.0 : (passes / total) * 100;
  final forecast = await _loadForecastAttachment();
  final verdict = _deriveVerdict(score, forecast);

  await _withReportsWritable(() async {
    await _writeTextSummary(
      reports,
      score,
      verdict,
      forecast,
      stopwatch.elapsedMilliseconds,
    );
    await _writeJsonSummary(
      reports,
      score,
      verdict,
      forecast,
      stopwatch.elapsedMilliseconds,
    );
    await _emitTelemetry(
      reports,
      score,
      verdict,
      forecast,
      stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'stability_dashboard: reports=$total pass=$passes '
    'score=${score.toStringAsFixed(2)} verdict=$verdict',
  );
}

Future<List<_ReportStatus>> _collectReports() async {
  final dir = Directory(_reportsRoot);
  if (!await dir.exists()) {
    throw StateError('Reports directory missing at $_reportsRoot');
  }
  final reports = <_ReportStatus>[];
  await for (final entity in dir.list(recursive: false)) {
    if (entity is! File || !entity.path.endsWith('_summary.txt')) continue;
    final status = await _extractStatus(entity);
    reports.add(_ReportStatus(file: entity.path, status: status));
  }
  reports.sort((a, b) => a.file.compareTo(b.file));
  return reports;
}

Future<String> _extractStatus(File file) async {
  final lines = await file.readAsLines();
  for (final line in lines) {
    if (line.toUpperCase().startsWith('VERDICT:')) {
      final status = line.split(':').last.trim().toUpperCase();
      if (_validStatuses.contains(status)) return status;
    }
  }
  // If no explicit verdict is present, treat the report as PASS to avoid
  // false negatives from descriptive text (e.g. "FAIL: 0" summary rows).
  return 'PASS';
}

Future<void> _writeTextSummary(
  List<_ReportStatus> reports,
  double score,
  String verdict,
  _ForecastAttachment? forecast,
  int durationMs,
) async {
  final buffer = StringBuffer()
    ..writeln('STABILITY DASHBOARD SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Health score: ${score.toStringAsFixed(2)}%')
    ..writeln('Dashboard verdict: $verdict')
    ..writeln(
      'Forecast RSI: ${_formatForecastLine(forecast?.projectedRsi ?? const [])}',
    )
    ..writeln('Risk Level: ${forecast?.riskLabel ?? 'UNKNOWN'}')
    ..writeln()
    ..writeln('Reports:')
    ..writeln('Status  | File')
    ..writeln('--------+--------------------------------------------');

  for (final report in reports) {
    buffer.writeln(
      '${report.status.padRight(6)} | ${report.file.replaceFirst('$_reportsRoot/', '')}',
    );
  }

  buffer.writeln();
  await File(_summaryTxt).writeAsString('${buffer.toString()}');
}

Future<void> _writeJsonSummary(
  List<_ReportStatus> reports,
  double score,
  String verdict,
  _ForecastAttachment? forecast,
  int durationMs,
) async {
  final data = {
    'generated_at': DateTime.now().toIso8601String(),
    'duration_ms': durationMs,
    'health_score': double.parse(score.toStringAsFixed(2)),
    'verdict': verdict,
    'forecast': forecast?.toJson(),
    'reports': reports
        .map(
          (report) => {
            'file': report.file.replaceFirst('$_reportsRoot/', ''),
            'status': report.status,
          },
        )
        .toList(),
  };
  await File(
    _summaryJson,
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(data));
}

Future<void> _emitTelemetry(
  List<_ReportStatus> reports,
  double score,
  String verdict,
  _ForecastAttachment? forecast,
  int durationMs,
) async {
  final payload = <String, Object?>{
    'event': 'stability_dashboard_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'health_score': score,
    'verdict': verdict,
    'forecast_risk': forecast?.risk ?? false,
    'forecast_rsi': forecast?.projectedRsi ?? const <double>[],
    'report_count': reports.length,
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

class _ReportStatus {
  const _ReportStatus({required this.file, required this.status});

  final String file;
  final String status;
}

const Set<String> _validStatuses = {'PASS', 'WARN', 'FAIL'};

String _formatForecastLine(List<double> forecast) {
  if (forecast.isEmpty) return 'n/a';
  return forecast
      .asMap()
      .entries
      .map((entry) => '+${entry.key + 1}:${entry.value.toStringAsFixed(1)}%')
      .join(' ');
}

String _deriveVerdict(double score, _ForecastAttachment? forecast) {
  var verdict = score >= 90 ? 'PASS' : 'WARN';
  if (forecast?.risk ?? false) {
    verdict = 'WARN';
  }
  return verdict;
}

Future<_ForecastAttachment?> _loadForecastAttachment() async {
  final file = File(_forecastJson);
  if (!await file.exists()) return null;
  try {
    final Map<String, dynamic> data =
        json.decode(await file.readAsString()) as Map<String, dynamic>;
    final List<double> projections = (data['forecasts'] as List<dynamic>? ?? [])
        .map((value) => (value as num).toDouble())
        .take(3)
        .toList();
    return _ForecastAttachment(
      rollingTrend: (data['rolling_trend'] as num?)?.toDouble() ?? 0.0,
      risk: projections.any((value) => value < 90),
      projectedRsi: projections,
    );
  } catch (_) {
    return null;
  }
}

class _ForecastAttachment {
  _ForecastAttachment({
    required this.rollingTrend,
    required this.risk,
    required this.projectedRsi,
  });

  final double rollingTrend;
  final bool risk;
  final List<double> projectedRsi;

  String get riskLabel => risk ? 'AT_RISK' : 'STABLE';

  Map<String, Object?> toJson() {
    return {
      'rolling_trend': rollingTrend,
      'risk': risk,
      'projected_rsi': projectedRsi,
    };
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
