import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _profileSurfacePath =
    '$_reportsDir/player_profile_surface_summary.json';
const String _sessionSummaryPath =
    '$_reportsDir/session_replay_snapshot_summary.json';
const String _uxSummaryPath =
    '$_reportsDir/ux_emotional_resonance_summary.json';

class PlayerExplanationFeedbackResult {
  PlayerExplanationFeedbackResult({
    required this.profileSurface,
    required this.sessionAccuracy,
    required this.uxResonance,
  });

  final _ScoreDetail profileSurface;
  final _ScoreDetail sessionAccuracy;
  final _ScoreDetail uxResonance;
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

class PlayerExplanationFeedbackService {
  const PlayerExplanationFeedbackService();

  Future<PlayerExplanationFeedbackResult?> evaluate() async {
    final profileSurface = await _loadDetail(
      _profileSurfacePath,
      'player_profile_surface_index',
    );
    final sessionAccuracy = await _loadDetail(
      _sessionSummaryPath,
      'accuracy_percent',
    );
    final uxResonance = await _loadDetail(_uxSummaryPath, 'average_resonance');

    if (profileSurface == null ||
        sessionAccuracy == null ||
        uxResonance == null) {
      return null;
    }

    return PlayerExplanationFeedbackResult(
      profileSurface: profileSurface,
      sessionAccuracy: sessionAccuracy,
      uxResonance: uxResonance,
    );
  }

  Future<_ScoreDetail?> _loadDetail(String path, String key) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final data = json.decode(await file.readAsString());
      if (data is! Map<String, dynamic>) return null;
      final scoreRaw = data[key];
      final score = _toDouble(scoreRaw);
      if (score == null) return null;
      final normalizedScore = _normalize(score);
      final verdict = ((data['verdict'] as String?) ?? 'PASS').toUpperCase();
      final timestamp = _parseTimestamp(data);
      return _ScoreDetail(
        score: normalizedScore,
        timestamp: timestamp,
        verdict: verdict,
      );
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseTimestamp(Map<String, dynamic> data) {
    final timeStr =
        data['generated_at'] as String? ??
        data['generated'] as String? ??
        data['timestamp'] as String?;
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  double _normalize(double value) {
    if (value <= 1.0) return value.clamp(0.0, 1.0);
    return (value / 100).clamp(0.0, 1.0);
  }
}
