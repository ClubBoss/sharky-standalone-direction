import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _psiPath = '$_reportsDir/psi_insight_summary.json';
const String _retentionPath = '$_reportsDir/retention_resonance_summary.json';
const String _ltvPath = '$_reportsDir/ltv_forecast_summary.json';
const String _marketingPath = '$_reportsDir/marketing_resonance_summary.json';
const String _summaryTextPath =
    '$_reportsDir/user_growth_analytics_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/user_growth_analytics_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final hub = UserGrowthAnalyticsHub();
  final ok = await hub.run();
  if (!ok) {
    exitCode = 2;
  }
}

class UserGrowthAnalyticsHub {
  Future<bool> run() async {
    final psi = await _load(_psiPath, 'psi_insight_index');
    final retention = await _load(_retentionPath, 'retention_resonance_score');
    final ltv = await _load(_ltvPath, 'ltv_forecast_index');
    final marketing = await _load(_marketingPath, 'marketing_resonance_score');

    if (psi == null || retention == null || ltv == null || marketing == null) {
      stderr.writeln('Missing growth analytics inputs.');
      return false;
    }

    if (!psi.pass || !retention.pass || !ltv.pass || !marketing.pass) {
      stderr.writeln('One or more inputs failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (psi.timestamp != null) psi.timestamp!,
      if (retention.timestamp != null) retention.timestamp!,
      if (ltv.timestamp != null) ltv.timestamp!,
      if (marketing.timestamp != null) marketing.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Timestamps exceed ${_timeWindow.inHours}h.');
      return false;
    }

    final scores = [
      _normalize(psi.score),
      _normalize(retention.score),
      _normalize(ltv.score),
      _normalize(marketing.score),
    ];
    if (scores.any((score) => score == null)) {
      stderr.writeln('Unable to normalize growth scores.');
      return false;
    }

    final psiScore = scores[0]!;
    final retentionScore = scores[1]!;
    final ltvScore = scores[2]!;
    final marketingScore = scores[3]!;

    final userGrowthIndex =
        ((psiScore * 0.35) +
                (retentionScore * 0.30) +
                (ltvScore * 0.20) +
                (marketingScore * 0.15))
            .clamp(0.0, 1.0);
    final pass = userGrowthIndex >= _threshold;

    final text = _buildText(
      psiScore,
      retentionScore,
      ltvScore,
      marketingScore,
      userGrowthIndex,
      pass,
    );
    final json = _buildJson(
      psiScore,
      retentionScore,
      ltvScore,
      marketingScore,
      userGrowthIndex,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        psiScore,
        retentionScore,
        ltvScore,
        marketingScore,
        userGrowthIndex,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'User Growth Index ${(userGrowthIndex * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Summary?> _load(String path, String scoreKey) async {
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
      final score = _toDouble(decoded[scoreKey]) ?? _toDouble(decoded['score']);
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
    double psi,
    double retention,
    double ltv,
    double marketing,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('USER GROWTH ANALYTICS SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Ψ Insight Index: ${pct(psi)}')
      ..writeln('Retention resonance: ${pct(retention)}')
      ..writeln('LTV forecast: ${pct(ltv)}')
      ..writeln('Marketing resonance: ${pct(marketing)}')
      ..writeln('User Growth Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double psi,
    double retention,
    double ltv,
    double marketing,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'psi_insight_index': psi,
    'retention_resonance_score': retention,
    'ltv_forecast_index': ltv,
    'marketing_resonance_score': marketing,
    'user_growth_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double psi,
    double retention,
    double ltv,
    double marketing,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'user_growth_analytics_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'psi_insight_index': psi,
      'retention_resonance_score': retention,
      'ltv_forecast_index': ltv,
      'marketing_resonance_score': marketing,
      'user_growth_index': index,
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
