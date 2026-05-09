import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _retentionPath =
    '$_reportsDir/retention_intelligence_summary.json';
const String _ltvPath = '$_reportsDir/ltv_forecast_summary.json';
const String _marketingPath = '$_reportsDir/marketing_resonance_summary.json';
const String _monetizationPath =
    '$_reportsDir/global_monetization_summary.json';
const String _summaryTextPath = '$_reportsDir/monetization_synergy_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/monetization_synergy_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final integrator = MonetizationSynergyIntegrator();
  final ok = await integrator.run();
  if (!ok) exitCode = 2;
}

class MonetizationSynergyIntegrator {
  Future<bool> run() async {
    final retention = await _loadSummary(
      _retentionPath,
      'retention_intelligence_index',
    );
    final ltv = await _loadSummary(_ltvPath, 'ltv_forecast_index');
    final marketing = await _loadSummary(
      _marketingPath,
      'marketing_resonance_score',
    );
    final monetization = await _loadSummary(
      _monetizationPath,
      'global_monetization_index',
    );

    if (retention == null ||
        ltv == null ||
        marketing == null ||
        monetization == null) {
      stderr.writeln('Missing monetization synergy inputs.');
      return false;
    }

    if (!retention.pass || !ltv.pass || !marketing.pass || !monetization.pass) {
      stderr.writeln('One or more summaries did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (retention.timestamp != null) retention.timestamp!,
      if (ltv.timestamp != null) ltv.timestamp!,
      if (marketing.timestamp != null) marketing.timestamp!,
      if (monetization.timestamp != null) monetization.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Timestamps exceed ${_timeWindow.inHours}h.');
      return false;
    }

    final scores = [
      _normalize(retention.score),
      _normalize(ltv.score),
      _normalize(marketing.score),
      _normalize(monetization.score),
    ];
    if (scores.any((score) => score == null)) {
      stderr.writeln('Failed to normalize monetization scores.');
      return false;
    }

    final retentionScore = scores[0]!;
    final ltvScore = scores[1]!;
    final marketingScore = scores[2]!;
    final monetizationScore = scores[3]!;

    final synergy =
        ((retentionScore * 0.35) +
                (ltvScore * 0.3) +
                (marketingScore * 0.2) +
                (monetizationScore * 0.15))
            .clamp(0.0, 1.0);
    final pass = synergy >= _threshold;

    final text = _buildText(
      retentionScore,
      ltvScore,
      marketingScore,
      monetizationScore,
      synergy,
      pass,
    );
    final json = _buildJson(
      retentionScore,
      ltvScore,
      marketingScore,
      monetizationScore,
      synergy,
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
        marketingScore,
        monetizationScore,
        synergy,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Monetization Synergy Index ${(synergy * 100).toStringAsFixed(2)}% below threshold.',
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

  bool _aligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
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
    double marketing,
    double monetization,
    double synergy,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('MONETIZATION SYNERGY SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Retention intelligence: ${pct(retention)}')
      ..writeln('LTV forecast: ${pct(ltv)}')
      ..writeln('Marketing resonance: ${pct(marketing)}')
      ..writeln('Monetization index: ${pct(monetization)}')
      ..writeln('Monetization Synergy Index: ${pct(synergy)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double retention,
    double ltv,
    double marketing,
    double monetization,
    double synergy,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'retention_intelligence_index': retention,
    'ltv_forecast_index': ltv,
    'marketing_resonance_score': marketing,
    'global_monetization_index': monetization,
    'monetization_synergy_index': synergy,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double retention,
    double ltv,
    double marketing,
    double monetization,
    double synergy,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'monetization_synergy_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'retention_intelligence_index': retention,
      'ltv_forecast_index': ltv,
      'marketing_resonance_score': marketing,
      'global_monetization_index': monetization,
      'monetization_synergy_index': synergy,
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
