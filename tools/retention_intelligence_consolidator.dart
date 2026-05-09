import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _growthPath = '$_reportsDir/user_growth_analytics_summary.json';
const String _resonancePath = '$_reportsDir/retention_resonance_summary.json';
const String _sentimentPath = '$_reportsDir/user_sentiment_summary.json';
const String _emotionPath =
    '$_reportsDir/emotion_feedback_reactor_summary.json';
const String _summaryTextPath =
    '$_reportsDir/retention_intelligence_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/retention_intelligence_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final consolidator = RetentionIntelligenceConsolidator();
  final ok = await consolidator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class RetentionIntelligenceConsolidator {
  Future<bool> run() async {
    final growth = await _loadSummary(_growthPath, 'user_growth_index');
    final resonance = await _loadSummary(
      _resonancePath,
      'retention_resonance_score',
    );
    final sentiment = await _loadSummary(_sentimentPath, 'sentiment_score');
    final emotion = await _loadSummary(
      _emotionPath,
      'emotional_cohesion_score',
    );

    if (growth == null ||
        resonance == null ||
        sentiment == null ||
        emotion == null) {
      stderr.writeln('Missing retention intelligence inputs.');
      return false;
    }

    if (!growth.pass || !resonance.pass || !sentiment.pass || !emotion.pass) {
      stderr.writeln('One or more inputs failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (growth.timestamp != null) growth.timestamp!,
      if (resonance.timestamp != null) resonance.timestamp!,
      if (sentiment.timestamp != null) sentiment.timestamp!,
      if (emotion.timestamp != null) emotion.timestamp!,
    ];

    if (!_aligned(timestamps)) {
      stderr.writeln('Timestamps exceed ${_timeWindow.inHours}h.');
      return false;
    }

    final scores = [
      _normalize(growth.score),
      _normalize(resonance.score),
      _normalize(sentiment.score),
      _normalize(emotion.score),
    ];
    if (scores.any((score) => score == null)) {
      stderr.writeln('Unable to normalize retention scores.');
      return false;
    }

    final growthScore = scores[0]!;
    final resonanceScore = scores[1]!;
    final sentimentScore = scores[2]!;
    final emotionScore = scores[3]!;

    final index =
        ((growthScore * 0.35) +
                (resonanceScore * 0.30) +
                (sentimentScore * 0.20) +
                (emotionScore * 0.15))
            .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(
      growthScore,
      resonanceScore,
      sentimentScore,
      emotionScore,
      index,
      pass,
    );
    final json = _buildJson(
      growthScore,
      resonanceScore,
      sentimentScore,
      emotionScore,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        growthScore,
        resonanceScore,
        sentimentScore,
        emotionScore,
        index,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Retention Intelligence Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
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
    double growth,
    double resonance,
    double sentiment,
    double emotion,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('RETENTION INTELLIGENCE SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('User Growth Index: ${pct(growth)}')
      ..writeln('Retention resonance: ${pct(resonance)}')
      ..writeln('Sentiment score: ${pct(sentiment)}')
      ..writeln('Emotion cohesion: ${pct(emotion)}')
      ..writeln('Retention Intelligence Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double growth,
    double resonance,
    double sentiment,
    double emotion,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'user_growth_index': growth,
    'retention_resonance_score': resonance,
    'sentiment_score': sentiment,
    'emotion_cohesion_score': emotion,
    'retention_intelligence_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double growth,
    double resonance,
    double sentiment,
    double emotion,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'retention_intelligence_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'user_growth_index': growth,
      'retention_resonance_score': resonance,
      'sentiment_score': sentiment,
      'emotion_cohesion_score': emotion,
      'retention_intelligence_index': index,
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
