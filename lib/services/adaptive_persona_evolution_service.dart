import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _personalizationPath =
    '$_reportsDir/ai_personalization_bridge_summary.json';
const String _emotionPath =
    '$_reportsDir/emotion_feedback_reactor_summary.json';
const String _feedbackPath =
    '$_reportsDir/player_feedback_integration_summary.json';

class AdaptivePersonaEvolutionResult {
  AdaptivePersonaEvolutionResult({
    required this.personalization,
    required this.emotion,
    required this.feedback,
  });

  final _ScoreDetail personalization;
  final _ScoreDetail emotion;
  final _ScoreDetail feedback;
}

class _ScoreDetail {
  const _ScoreDetail({
    required this.score,
    required this.timestamp,
    required this.verdict,
  });

  final double score;
  final DateTime? timestamp;
  final String verdict;
}

class AdaptivePersonaEvolutionService {
  const AdaptivePersonaEvolutionService();

  Future<AdaptivePersonaEvolutionResult?> evaluate() async {
    final personalization = await _loadDetail(
      _personalizationPath,
      'personalization_index',
    );
    final emotion = await _loadDetail(_emotionPath, 'emotional_cohesion_score');
    final feedback = await _loadDetail(
      _feedbackPath,
      'feedback_integration_index',
    );

    if (personalization == null || emotion == null || feedback == null)
      return null;

    return AdaptivePersonaEvolutionResult(
      personalization: personalization,
      emotion: emotion,
      feedback: feedback,
    );
  }

  Future<_ScoreDetail?> _loadDetail(String path, String key) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      final score = _toDouble(decoded[key]) ?? _toDouble(decoded['score']);
      if (score == null) return null;
      final normalized = _normalize(score);
      final verdict = ((decoded['verdict'] as String?) ?? 'PASS').toUpperCase();
      final timestamp = _parseTimestamp(decoded);
      return _ScoreDetail(
        score: normalized,
        timestamp: timestamp,
        verdict: verdict,
      );
    } catch (_) {
      return null;
    }
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double _normalize(double value) {
    if (value <= 1.0) return value.clamp(0.0, 1.0);
    return (value / 100).clamp(0.0, 1.0);
  }

  DateTime? _parseTimestamp(Map<String, dynamic> data) {
    final timestamp =
        data['generated_at'] as String? ??
        data['generated'] as String? ??
        data['timestamp'] as String?;
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp);
  }
}
