import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _marketingPath = '$_reportsDir/marketing_resonance_summary.json';
const String _emotionPath =
    '$_reportsDir/emotion_feedback_reactor_summary.json';
const String _personaPath = '$_reportsDir/persona_reactions_summary.json';
const String _summaryTextPath = '$_reportsDir/user_sentiment_summary.txt';
const String _summaryJsonPath = '$_reportsDir/user_sentiment_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const Duration _timeWindow = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final analyzer = UserSentimentAnalyzer();
  final ok = await analyzer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class UserSentimentAnalyzer {
  Future<bool> run() async {
    final marketing = await _readSummary(
      _marketingPath,
      'marketing_resonance_score',
    );
    final emotion = await _readSummary(
      _emotionPath,
      'emotional_cohesion_index',
    );
    final persona = await _readSummary(_personaPath, 'persona_reaction_rate');

    if (marketing == null || emotion == null || persona == null) {
      stderr.writeln('Missing user sentiment summaries.');
      return false;
    }

    if (!marketing.pass || !emotion.pass || !persona.pass) {
      stderr.writeln('One or more sentiment inputs failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (marketing.timestamp != null) marketing.timestamp!,
      if (emotion.timestamp != null) emotion.timestamp!,
      if (persona.timestamp != null) persona.timestamp!,
    ];
    if (!_timestampsAligned(timestamps)) {
      stderr.writeln('Timestamps span more than 24h.');
      return false;
    }

    final marketingScore = _normalize(marketing.score);
    final emotionScore = _normalize(emotion.score);
    final personaScore = _normalize(persona.score);

    if (marketingScore == null ||
        emotionScore == null ||
        personaScore == null) {
      stderr.writeln('Failed to parse scores for sentiment.');
      return false;
    }

    final sentiment =
        ((marketingScore * 0.4) + (emotionScore * 0.35) + (personaScore * 0.25))
            .clamp(0.0, 1.0);
    final pass = sentiment >= _threshold;

    final text = _buildText(
      marketingScore,
      emotionScore,
      personaScore,
      sentiment,
      pass,
    );
    final json = _buildJson(
      marketingScore,
      emotionScore,
      personaScore,
      sentiment,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        marketingScore,
        emotionScore,
        personaScore,
        sentiment,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Sentiment Score ${(sentiment * 100).toStringAsFixed(2)}% below threshold.',
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
      final score = _extractScore(decoded, key);
      return _Summary(pass: verdict == 'PASS', score: score, timestamp: parsed);
    } catch (_) {
      return null;
    }
  }

  double? _extractScore(Map<String, Object?> data, String key) {
    final value = data[key];
    if (value != null) {
      return _toDouble(value);
    }
    return null;
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
    double emotion,
    double persona,
    double sentiment,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('USER SENTIMENT SUMMARY')
      ..writeln('======================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Marketing resonance: ${pct(marketing)}')
      ..writeln('Emotional cohesion: ${pct(emotion)}')
      ..writeln('Persona reaction rate: ${pct(persona)}')
      ..writeln('Sentiment Score: ${pct(sentiment)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double marketing,
    double emotion,
    double persona,
    double sentiment,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'marketing_resonance_score': marketing,
    'emotional_cohesion_score': emotion,
    'persona_reaction_rate': persona,
    'sentiment_score': sentiment,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double marketing,
    double emotion,
    double persona,
    double sentiment,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'user_sentiment_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'marketing_resonance_score': marketing,
      'emotional_cohesion_score': emotion,
      'persona_reaction_rate': persona,
      'sentiment_score': sentiment,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Summary {
  _Summary({required this.pass, required this.score, required this.timestamp});

  final bool pass;
  final double? score;
  final DateTime? timestamp;
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
