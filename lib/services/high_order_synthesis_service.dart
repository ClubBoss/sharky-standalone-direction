import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _conceptualPath = '$_reportsDir/conceptual_skill_summary.json';
const String _metaPath = '$_reportsDir/meta_progression_summary.json';
const String _learningPath = '$_reportsDir/learning_transfer_summary.json';

class HighOrderSynthesisResult {
  HighOrderSynthesisResult({
    required this.conceptualSkill,
    required this.metaProgression,
    required this.learningTransfer,
  });

  final _ScoreDetail conceptualSkill;
  final _ScoreDetail metaProgression;
  final _ScoreDetail learningTransfer;
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

class HighOrderSynthesisService {
  const HighOrderSynthesisService();

  Future<HighOrderSynthesisResult?> evaluate() async {
    final conceptual = await _loadDetail(_conceptualPath, const [
      'conceptual_skill_index',
      'conceptual_skill_score',
      'score',
    ]);
    final meta = await _loadDetail(_metaPath, const [
      'meta_progression_index',
      'meta_progression_score',
      'index',
    ]);
    final learning = await _loadDetail(_learningPath, const [
      'learning_transfer_index',
      'learning_transfer_score',
      'learning_index',
    ]);

    if (conceptual == null || meta == null || learning == null) return null;

    return HighOrderSynthesisResult(
      conceptualSkill: conceptual,
      metaProgression: meta,
      learningTransfer: learning,
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
        score = _toDouble(decoded[key]);
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
