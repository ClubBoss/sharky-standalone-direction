import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _retentionPath = '$_reportsDir/retention_resonance_summary.json';
const String _ltvPath = '$_reportsDir/ltv_forecast_summary.json';
const String _operationsPath = '$_reportsDir/operations_integrity_summary.json';
const String _summaryTextPath = '$_reportsDir/ltv_resonance_summary.txt';
const String _summaryJsonPath = '$_reportsDir/ltv_resonance_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _window = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final evaluator = LtvResonanceEvaluator();
  final ok = await evaluator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class LtvResonanceEvaluator {
  Future<bool> run() async {
    final retention = await _loadSummary(
      _retentionPath,
      'retention_resonance_score',
    );
    final ltv = await _loadSummary(_ltvPath, 'ltv_forecast_index');
    final operations = await _loadSummary(
      _operationsPath,
      'operations_integrity_index',
    );

    if (retention == null || ltv == null || operations == null) {
      stderr.writeln('Missing LTV resonance inputs.');
      return false;
    }

    if (!retention.pass || !ltv.pass || !operations.pass) {
      stderr.writeln('One or more inputs failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (retention.timestamp != null) retention.timestamp!,
      if (ltv.timestamp != null) ltv.timestamp!,
      if (operations.timestamp != null) operations.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Inputs span more than 24h.');
      return false;
    }

    final retentionScore = _normalize(retention.score);
    final ltvScore = _normalize(ltv.score);
    final operationsScore = _normalize(operations.score);

    if (retentionScore == null || ltvScore == null || operationsScore == null) {
      stderr.writeln('Unable to normalize scores.');
      return false;
    }

    final resonance =
        ((retentionScore * 0.4) + (ltvScore * 0.35) + (operationsScore * 0.25))
            .clamp(0.0, 1.0);
    final pass = resonance >= _threshold;

    final text = _buildText(
      retentionScore,
      ltvScore,
      operationsScore,
      resonance,
      pass,
    );
    final json = _buildJson(
      retentionScore,
      ltvScore,
      operationsScore,
      resonance,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        retentionScore,
        ltvScore,
        operationsScore,
        resonance,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'LTV Resonance Score ${(resonance * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Summary?> _loadSummary(String path, String key) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      final verdict = ((decoded['verdict'] as String?) ?? '').toUpperCase();
      final generated =
          decoded['generated_at'] as String? ??
          decoded['generated'] as String? ??
          decoded['timestamp'] as String?;
      final parsed = generated != null ? DateTime.tryParse(generated) : null;
      final score = _toDouble(decoded[key]) ?? _toDouble(decoded['score']);
      return _Summary(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
  }

  bool _aligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _window;
  }

  double? _normalize(double? value) {
    if (value == null) return null;
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0.0, 1.0);
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  String _buildText(
    double retention,
    double ltv,
    double operations,
    double score,
    bool pass,
  ) {
    String pct(double v) => '${(v * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('LTV RESONANCE SUMMARY')
      ..writeln('=====================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Retention resonance: ${pct(retention)}')
      ..writeln('LTV forecast: ${pct(ltv)}')
      ..writeln('Operations integrity: ${pct(operations)}')
      ..writeln('LTV Resonance Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double retention,
    double ltv,
    double operations,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'retention_resonance_score': retention,
    'ltv_forecast_index': ltv,
    'operations_integrity_index': operations,
    'ltv_resonance_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double retention,
    double ltv,
    double operations,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'ltv_resonance_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'retention_resonance_score': retention,
      'ltv_forecast_index': ltv,
      'operations_integrity_index': operations,
      'ltv_resonance_score': score,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Summary {
  _Summary({required this.pass, required this.timestamp, required this.score});

  final bool pass;
  final DateTime? timestamp;
  final double? score;
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
