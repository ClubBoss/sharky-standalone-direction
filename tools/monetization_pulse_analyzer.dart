import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _insightSummaryPath =
    '$_reportsDir/monetization_insight_summary.json';
const String _globalSummaryPath =
    '$_reportsDir/global_monetization_summary.json';
const String _revenueSummaryPath =
    '$_reportsDir/revenue_stability_summary.json';
const String _summaryTextPath = '$_reportsDir/monetization_pulse_summary.txt';
const String _summaryJsonPath = '$_reportsDir/monetization_pulse_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final analyzer = MonetizationPulseAnalyzer();
  final ok = await analyzer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MonetizationPulseAnalyzer {
  Future<bool> run() async {
    final insight = await _readJson(_insightSummaryPath);
    final global = await _readJson(_globalSummaryPath);
    final revenue = await _readJson(_revenueSummaryPath);

    if (insight == null || global == null || revenue == null) {
      stderr.writeln(
        'Missing monetization summaries (insight/global/revenue).',
      );
      return false;
    }

    final insightScore = _normalizePercent(
      insight['monetization_insight_score'],
    );
    final globalScore = _normalizePercent(global['global_monetization_index']);
    final revenueScore = _normalizePercent(revenue['revenue_stability_index']);

    if (insightScore == null || globalScore == null || revenueScore == null) {
      stderr.writeln('Could not parse one of the monetization scores.');
      return false;
    }

    final pulse =
        (insightScore * 0.4) + (globalScore * 0.35) + (revenueScore * 0.25);
    final pass = pulse >= _threshold;

    final summaryText = _buildTextSummary(
      insightScore,
      globalScore,
      revenueScore,
      pulse,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      insightScore,
      globalScore,
      revenueScore,
      pulse,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        insightScore,
        globalScore,
        revenueScore,
        pulse,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Monetization Pulse Score ${pulse.toStringAsFixed(3)} below ${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  String _buildTextSummary(
    double insightScore,
    double globalScore,
    double revenueScore,
    double pulse,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('MONETIZATION PULSE SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Monetization Insight Score: ${pct(insightScore)}')
      ..writeln('Global Monetization Index: ${pct(globalScore)}')
      ..writeln('Revenue Stability Index: ${pct(revenueScore)}')
      ..writeln('Monetization Pulse Score: ${pct(pulse)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double insightScore,
    double globalScore,
    double revenueScore,
    double pulse,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'monetization_insight_score': insightScore,
    'global_monetization_index': globalScore,
    'revenue_stability_index': revenueScore,
    'monetization_pulse_score': pulse,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double insightScore,
    double globalScore,
    double revenueScore,
    double pulse,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'monetization_pulse_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'monetization_insight_score': insightScore,
      'global_monetization_index': globalScore,
      'revenue_stability_index': revenueScore,
      'monetization_pulse_score': pulse,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

double? _normalizePercent(Object? raw) {
  if (raw is num) {
    final value = raw.toDouble();
    return value <= 1
        ? value.clamp(0, 1).toDouble()
        : (value / 100).clamp(0, 1).toDouble();
  }
  if (raw is String) {
    final parsed = double.tryParse(raw);
    if (parsed != null) {
      return parsed <= 1
          ? parsed.clamp(0, 1).toDouble()
          : (parsed / 100).clamp(0, 1).toDouble();
    }
  }
  return null;
}

Future<Map<String, Object?>?> _readJson(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    final decoded = json.decode(await file.readAsString());
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
  } catch (_) {}
  return null;
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
