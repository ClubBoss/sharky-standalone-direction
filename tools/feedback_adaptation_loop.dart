// Feedback-Driven Adaptation Loop (Stage Ψ-3)
// Pure Dart CLI: compares predicted vs actual UX metrics and computes correction coefficients.
// Outputs ASCII summary and telemetry event.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final sw = Stopwatch()..start();
  final forecastPath = 'predictive_trend_forecast.txt';
  final dashboardPath = 'ux_dashboard_summary.txt';

  final predicted = await _parseKeyValues(forecastPath);
  final actual = await _parseKeyValues(dashboardPath);

  final overlap =
      predicted.keys.toSet().intersection(actual.keys.toSet()).toList()..sort();

  final rows = <_Row>[];
  double alphaSum = 0.0;
  int alphaCount = 0;
  double driftSum = 0.0;
  for (final k in overlap) {
    final p = _toNum(predicted[k]);
    final a = _toNum(actual[k]);
    if (p == null || a == null || p == 0) continue;
    final alphaRaw = p / a;
    final alpha = alphaRaw.clamp(0.8, 1.2);
    final driftPct = ((a - p) / p) * 100.0;
    rows.add(
      _Row(
        metric: k,
        predicted: p,
        actual: a,
        alpha: alpha,
        driftPct: driftPct,
      ),
    );
    alphaSum += alpha;
    alphaCount++;
    driftSum += driftPct;
  }

  final alphaAvg = alphaCount == 0 ? 1.0 : alphaSum / alphaCount;
  final driftAvg = overlap.isEmpty
      ? 0.0
      : (rows.isEmpty ? 0.0 : driftSum / rows.length);

  final report = StringBuffer()
    ..writeln('Feedback Adaptation Summary')
    ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('\n| Metric | Predicted | Actual | Alpha | Drift % |')
    ..writeln('| ------ | --------- | ------ | ----- | -------- |');
  for (final r in rows) {
    report.writeln(
      '| ${r.metric} | ${r.predicted.toStringAsFixed(3)} | ${r.actual.toStringAsFixed(3)} | ${r.alpha.toStringAsFixed(3)} | ${r.driftPct.toStringAsFixed(2)} |',
    );
  }
  report
    ..writeln('\nAverages:')
    ..writeln('- alpha_avg: ${alphaAvg.toStringAsFixed(3)}')
    ..writeln('- drift_pct: ${driftAvg.toStringAsFixed(2)}');

  var outPath = 'release/_reports/feedback_adaptation_summary.txt';
  try {
    await File(outPath).writeAsString(report.toString());
  } catch (_) {
    outPath = 'release/_exports/feedback_adaptation_summary.txt';
    await File(outPath).writeAsString(report.toString());
  }

  final telemetry = {
    'event': 'feedback_adaptation_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'alpha_avg': alphaAvg,
    'drift_pct': driftAvg,
    'duration_ms': sw.elapsedMilliseconds,
  };
  final telemetryPath = 'release/_exports/feedback_adaptation_telemetry.jsonl';
  await File(
    telemetryPath,
  ).writeAsString(jsonEncode(telemetry) + '\n', mode: FileMode.append);

  stdout.writeln('+-------------------------------+');
  stdout.writeln('| Feedback Adaptation COMPLETE  |');
  stdout.writeln('+-------------------------------+');
  stdout.writeln('Report: ' + outPath);
  stdout.writeln('alpha_avg: ' + alphaAvg.toStringAsFixed(3));
  stdout.writeln('drift_pct: ' + driftAvg.toStringAsFixed(2));
  stdout.writeln('Duration ms: ${sw.elapsedMilliseconds}');
}

Future<Map<String, dynamic>> _parseKeyValues(String path) async {
  final file = File(path);
  if (!file.existsSync()) return <String, dynamic>{};
  final lines = await file.readAsLines();
  final map = <String, dynamic>{};
  for (final raw in lines) {
    final l = raw.trim();
    if (l.isEmpty) continue;
    // format: Key: value (numeric) or Key = value
    final idx = l.indexOf(':');
    final eq = l.indexOf('=');
    final cut = (idx >= 0) ? idx : eq;
    if (cut < 0) continue;
    final key = l.substring(0, cut).trim().toLowerCase().replaceAll(' ', '_');
    final valStr = l.substring(cut + 1).trim();
    map[key] = valStr;
  }
  return map;
}

double? _toNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().replaceAll('%', '').replaceAll(',', '').trim();
  if (s.isEmpty) return null;
  return double.tryParse(s);
}

class _Row {
  _Row({
    required this.metric,
    required this.predicted,
    required this.actual,
    required this.alpha,
    required this.driftPct,
  });
  final String metric;
  final double predicted;
  final double actual;
  final double alpha;
  final double driftPct;
}
