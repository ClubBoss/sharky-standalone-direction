import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _sentimentPath = '$_reportsDir/user_sentiment_summary.json';
const String _retentionPath = '$_reportsDir/retention_growth_summary.json';
const String _engagementPath = '$_reportsDir/engagement_economy_summary.json';
const String _summaryTextPath = '$_reportsDir/retention_resonance_summary.txt';
const String _summaryJsonPath = '$_reportsDir/retention_resonance_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final synthesizer = RetentionResonanceSynthesizer();
  final ok = await synthesizer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RetentionResonanceSynthesizer {
  Future<bool> run() async {
    final sentiment = await _loadSummary(_sentimentPath, 'sentiment_score');
    final retention = await _loadSummary(
      _retentionPath,
      'retention_growth_score',
    );
    final engagement = await _loadSummary(
      _engagementPath,
      'engagement_economy_score',
    );

    if (sentiment == null || retention == null || engagement == null) {
      stderr.writeln('Missing retention resonance inputs.');
      return false;
    }

    if (!sentiment.pass || !retention.pass || !engagement.pass) {
      stderr.writeln('One or more inputs failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (sentiment.timestamp != null) sentiment.timestamp!,
      if (retention.timestamp != null) retention.timestamp!,
      if (engagement.timestamp != null) engagement.timestamp!,
    ];
    if (!_timestampsAligned(timestamps)) {
      stderr.writeln('Input timestamps span more than $_timeWindow.');
      return false;
    }

    final marketingScore = _normalize(sentiment.score);
    final retentionScore = _normalize(retention.score);
    final engagementScore = _normalize(engagement.score);

    if (marketingScore == null ||
        retentionScore == null ||
        engagementScore == null) {
      stderr.writeln('Unable to normalize scores.');
      return false;
    }

    final resonance =
        ((marketingScore * 0.4) +
                (retentionScore * 0.35) +
                (engagementScore * 0.25))
            .clamp(0.0, 1.0);

    final pass = resonance >= _threshold;

    final text = _buildText(
      marketingScore,
      retentionScore,
      engagementScore,
      resonance,
      pass,
    );
    final json = _buildJson(
      marketingScore,
      retentionScore,
      engagementScore,
      resonance,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        marketingScore,
        retentionScore,
        engagementScore,
        resonance,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Retention Resonance Score ${(resonance * 100).toStringAsFixed(2)}% below threshold.',
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
      return _Summary(pass: verdict == 'PASS', score: score, timestamp: parsed);
    } catch (_) {
      return null;
    }
  }

  bool _timestampsAligned(List<DateTime> timestamps) {
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
    double marketing,
    double retention,
    double engagement,
    double score,
    bool pass,
  ) {
    final pct = (double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('RETENTION RESONANCE SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Marketing resonance: ${pct(marketing)}')
      ..writeln('Retention growth: ${pct(retention)}')
      ..writeln('Engagement economy: ${pct(engagement)}')
      ..writeln('Retention Resonance Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double marketing,
    double retention,
    double engagement,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'marketing_resonance_score': marketing,
    'retention_growth_score': retention,
    'engagement_economy_score': engagement,
    'retention_resonance_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double marketing,
    double retention,
    double engagement,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'retention_resonance_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'marketing_resonance_score': marketing,
      'retention_growth_score': retention,
      'engagement_economy_score': engagement,
      'retention_resonance_score': score,
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
