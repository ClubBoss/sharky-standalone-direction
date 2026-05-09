import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _omegaPath = '$_reportsDir/omega_health_summary.json';
const String _retentionPath = '$_reportsDir/retention_resonance_summary.json';
const String _marketingPath = '$_reportsDir/marketing_resonance_summary.json';
const String _sentimentPath = '$_reportsDir/user_sentiment_summary.json';
const String _summaryTextPath = '$_reportsDir/psi_insight_summary.txt';
const String _summaryJsonPath = '$_reportsDir/psi_insight_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final integrator = PsiInsightIntegrator();
  final ok = await integrator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PsiInsightIntegrator {
  Future<bool> run() async {
    final omega = await _loadSummary(_omegaPath, 'omega_health_score');
    final retention = await _loadSummary(
      _retentionPath,
      'retention_resonance_score',
    );
    final marketing = await _loadSummary(
      _marketingPath,
      'marketing_resonance_score',
    );
    final sentiment = await _loadSummary(_sentimentPath, 'sentiment_score');

    if (omega == null ||
        retention == null ||
        marketing == null ||
        sentiment == null) {
      stderr.writeln('Missing PSI inputs.');
      return false;
    }

    if (!omega.pass || !retention.pass || !marketing.pass || !sentiment.pass) {
      stderr.writeln('One or more PSI inputs failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (omega.timestamp != null) omega.timestamp!,
      if (retention.timestamp != null) retention.timestamp!,
      if (marketing.timestamp != null) marketing.timestamp!,
      if (sentiment.timestamp != null) sentiment.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('PSI inputs span more than ${_timeWindow.inHours}h.');
      return false;
    }

    final scores = [
      _normalize(omega.score),
      _normalize(retention.score),
      _normalize(marketing.score),
      _normalize(sentiment.score),
    ];
    if (scores.any((value) => value == null)) {
      stderr.writeln('Unable to normalize PSI scores.');
      return false;
    }

    final omegaScore = scores[0]!;
    final retentionScore = scores[1]!;
    final marketingScore = scores[2]!;
    final sentimentScore = scores[3]!;

    final psiIndex =
        ((omegaScore * 0.35) +
                (retentionScore * 0.3) +
                (marketingScore * 0.2) +
                (sentimentScore * 0.15))
            .clamp(0.0, 1.0);

    final pass = psiIndex >= _threshold;

    final text = _buildText(
      omegaScore,
      retentionScore,
      marketingScore,
      sentimentScore,
      psiIndex,
      pass,
    );
    final json = _buildJson(
      omegaScore,
      retentionScore,
      marketingScore,
      sentimentScore,
      psiIndex,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        omegaScore,
        retentionScore,
        marketingScore,
        sentimentScore,
        psiIndex,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'PSI Index ${(psiIndex * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Summary?> _loadSummary(String path, String key) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final data = json.decode(await file.readAsString());
      if (data is! Map<String, Object?>) return null;
      final verdict = ((data['verdict'] as String?) ?? '').toUpperCase();
      final timestamp =
          data['generated_at'] as String? ??
          data['generated'] as String? ??
          data['timestamp'] as String?;
      final parsed = timestamp != null ? DateTime.tryParse(timestamp) : null;
      final score = _toDouble(data[key]) ?? _toDouble(data['score']);
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
    double omega,
    double retention,
    double marketing,
    double sentiment,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('PSI INSIGHT SUMMARY')
      ..writeln('===================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Ω health score: ${pct(omega)}')
      ..writeln('Retention resonance: ${pct(retention)}')
      ..writeln('Marketing resonance: ${pct(marketing)}')
      ..writeln('Sentiment score: ${pct(sentiment)}')
      ..writeln('Ψ Insight Index: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double omega,
    double retention,
    double marketing,
    double sentiment,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'omega_health_score': omega,
    'retention_resonance_score': retention,
    'marketing_resonance_score': marketing,
    'sentiment_score': sentiment,
    'psi_insight_index': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double omega,
    double retention,
    double marketing,
    double sentiment,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'psi_insight_integrator_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'omega_health_score': omega,
      'retention_resonance_score': retention,
      'marketing_resonance_score': marketing,
      'sentiment_score': sentiment,
      'psi_insight_index': score,
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
