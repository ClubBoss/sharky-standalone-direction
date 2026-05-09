import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _feedbackSummaryPath =
    '$_reportsDir/player_explanation_feedback_summary.json';
const String _personaSummaryPath =
    '$_reportsDir/persona_reactions_summary.json';
const String _uxSummaryPath =
    '$_reportsDir/ux_emotional_resonance_summary.json';

class PlayerFeedbackIntegrationResult {
  PlayerFeedbackIntegrationResult({
    required this.feedbackScore,
    required this.personaScore,
    required this.uxScore,
  });

  final _ScoreDetail feedbackScore;
  final _ScoreDetail personaScore;
  final _ScoreDetail uxScore;
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

class PlayerFeedbackIntegrationService {
  const PlayerFeedbackIntegrationService();

  Future<PlayerFeedbackIntegrationResult?> evaluate() async {
    final feedback = await _loadDetail(
      _feedbackSummaryPath,
      'player_explanation_feedback_index',
    );
    final persona = await _loadDetail(
      _personaSummaryPath,
      'persona_reaction_rate',
    );
    final ux = await _loadDetail(_uxSummaryPath, 'average_resonance');

    if (feedback == null || persona == null || ux == null) return null;

    return PlayerFeedbackIntegrationResult(
      feedbackScore: feedback,
      personaScore: persona,
      uxScore: ux,
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
    final raw =
        data['generated_at'] as String? ??
        data['generated'] as String? ??
        data['timestamp'] as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}
