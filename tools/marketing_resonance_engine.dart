import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _ltvPath = '$_reportsDir/ltv_forecast_summary.json';
const String _growthPath = '$_reportsDir/retention_growth_summary.json';
const String _marketingPath =
    '$_reportsDir/marketing_onboarding_qa_final_summary.json';
const String _summaryTextPath = '$_reportsDir/marketing_resonance_summary.txt';
const String _summaryJsonPath = '$_reportsDir/marketing_resonance_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _maxDelta = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final engine = MarketingResonanceEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MarketingResonanceEngine {
  Future<bool> run() async {
    final ltv = await _readSummary(_ltvPath, 'ltv_forecast_index');
    final growth = await _readSummary(_growthPath, 'retention_growth_score');
    final marketing = await _readSummary(
      _marketingPath,
      'marketing_onboarding_score',
    );

    if (ltv == null || growth == null || marketing == null) {
      stderr.writeln('Missing marketing resonance inputs.');
      return false;
    }

    if (!ltv.pass || !growth.pass || !marketing.pass) {
      stderr.writeln('One or more summaries did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (ltv.timestamp != null) ltv.timestamp!,
      if (growth.timestamp != null) growth.timestamp!,
      if (marketing.timestamp != null) marketing.timestamp!,
    ];
    if (!_timestampsAligned(timestamps)) {
      stderr.writeln('Input timestamps span more than 24h.');
      return false;
    }

    final ltvScore = _normalize(ltv.score);
    final growthScore = _normalize(growth.score);
    final marketingScore = _normalize(marketing.score);

    if (ltvScore == null || growthScore == null || marketingScore == null) {
      stderr.writeln('Unable to extract required scores.');
      return false;
    }

    final resonance =
        ((ltvScore * 0.4) + (growthScore * 0.35) + (marketingScore * 0.25))
            .clamp(0.0, 1.0);
    final pass = resonance >= _threshold;

    final text = _buildText(
      ltvScore,
      growthScore,
      marketingScore,
      resonance,
      pass,
    );
    final json = _buildJson(
      ltvScore,
      growthScore,
      marketingScore,
      resonance,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        ltvScore,
        growthScore,
        marketingScore,
        resonance,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Marketing Resonance Score ${(resonance * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Summary?> _readSummary(String path, String key) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      final verdict = ((decoded['verdict'] as String?) ?? '').toUpperCase();
      final timestamp =
          decoded['generated_at'] as String? ??
          decoded['generated'] as String? ??
          decoded['timestamp'] as String?;
      final parsed = timestamp != null ? DateTime.tryParse(timestamp) : null;
      final score = _toDouble(decoded[key]) ?? _toDouble(decoded['score']);
      return _Summary(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
  }

  bool _timestampsAligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _maxDelta;
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
    double ltv,
    double growth,
    double marketing,
    double resonance,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('MARKETING RESONANCE SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('LTV forecast: ${pct(ltv)}')
      ..writeln('Retention growth: ${pct(growth)}')
      ..writeln('Marketing onboarding: ${pct(marketing)}')
      ..writeln('Marketing Resonance Score: ${pct(resonance)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double ltv,
    double growth,
    double marketing,
    double resonance,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'ltv_forecast_index': ltv,
    'retention_growth_score': growth,
    'marketing_onboarding_score': marketing,
    'marketing_resonance_score': resonance,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double ltv,
    double growth,
    double marketing,
    double resonance,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'marketing_resonance_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'ltv_forecast_index': ltv,
      'retention_growth_score': growth,
      'marketing_onboarding_score': marketing,
      'marketing_resonance_score': resonance,
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
