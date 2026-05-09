import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _masteryPath = '$_reportsDir/mastery_transfer_summary.json';
const String _learningPath = '$_reportsDir/learning_transfer_summary.json';
const String _reinforcementPath =
    '$_reportsDir/content_reinforcement_synthesizer_summary.json';

class SkillConsolidationEngineResult {
  SkillConsolidationEngineResult({
    required this.masteryTransfer,
    required this.learningTransfer,
    required this.reinforcementSynthesizer,
  });

  final _ScoreDetail masteryTransfer;
  final _ScoreDetail learningTransfer;
  final _ScoreDetail reinforcementSynthesizer;
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

class SkillConsolidationEngineService {
  const SkillConsolidationEngineService();

  Future<SkillConsolidationEngineResult?> evaluate() async {
    final masteryTransfer = await _loadDetail(_masteryPath, const [
      'mastery_transfer_index',
      'mastery_transfer_score',
      'skill_mastery_index',
    ]);
    final learningTransfer = await _loadDetail(_learningPath, const [
      'learning_transfer_index',
      'learning_transfer_score',
      'learning_index',
    ]);
    final reinforcement = await _loadDetail(_reinforcementPath, const [
      'content_reinforcement_index',
      'content_reinforcement_score',
      'reinforcement_index',
    ]);

    if (masteryTransfer == null ||
        learningTransfer == null ||
        reinforcement == null) {
      return null;
    }

    return SkillConsolidationEngineResult(
      masteryTransfer: masteryTransfer,
      learningTransfer: learningTransfer,
      reinforcementSynthesizer: reinforcement,
    );
  }

  Future<_ScoreDetail?> _loadDetail(String path, List<String> keys) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      double? score;
      for (final key in keys) {
        final value = decoded[key];
        score = _toDouble(value);
        if (score != null) break;
      }
      score ??= _toDouble(decoded['score']);
      score ??= _toDouble(decoded['index']);
      score ??= _toDouble(decoded['value']);
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
    if (value <= 2.0) return (value - 1.0).clamp(0.0, 1.0);
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
