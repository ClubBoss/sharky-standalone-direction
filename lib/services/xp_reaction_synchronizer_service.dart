import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _feedbackPath =
    '$_reportsDir/player_feedback_integration_summary.json';
const String _sessionPath = '$_reportsDir/session_replay_snapshot_summary.json';
const String _personaPath = '$_reportsDir/persona_reactions_summary.json';

class XpReactionSynchronizerResult {
  XpReactionSynchronizerResult({
    required this.feedbackDetail,
    required this.sessionDetail,
    required this.personaDetail,
  });

  final _ScoreDetail feedbackDetail;
  final _ScoreDetail sessionDetail;
  final _ScoreDetail personaDetail;
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

class XpReactionSynchronizerService {
  const XpReactionSynchronizerService();

  Future<XpReactionSynchronizerResult?> evaluate() async {
    final feedback = await _loadDetail(
      _feedbackPath,
      'feedback_integration_index',
    );
    final session = await _loadDetail(_sessionPath, 'accuracy_percent');
    final persona = await _loadDetail(_personaPath, 'persona_reaction_rate');

    if (feedback == null || session == null || persona == null) {
      return null;
    }

    return XpReactionSynchronizerResult(
      feedbackDetail: feedback,
      sessionDetail: session,
      personaDetail: persona,
    );
  }

  Future<_ScoreDetail?> _loadDetail(String path, String key) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      final raw = decoded[key];
      final score = _toDouble(raw) ?? _toDouble(decoded['score']);
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
