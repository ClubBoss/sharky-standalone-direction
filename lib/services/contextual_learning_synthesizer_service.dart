import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _semanticPath = '$_reportsDir/semantic_depth_summary.json';
const String _reinforcementPath =
    '$_reportsDir/content_reinforcement_synthesizer_summary.json';
const String _uxResonancePath =
    '$_reportsDir/ux_emotional_resonance_summary.json';

class ContextualLearningSynthesizerResult {
  ContextualLearningSynthesizerResult({
    required this.semanticDepth,
    required this.reinforcement,
    required this.uxResonance,
  });

  final _ScoreDetail semanticDepth;
  final _ScoreDetail reinforcement;
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

class ContextualLearningSynthesizerService {
  const ContextualLearningSynthesizerService();

  Future<ContextualLearningSynthesizerResult?> evaluate() async {
    final semanticDepth = await _loadDetail(_semanticPath, const [
      'semantic_depth_index',
      'semantic_depth_score',
    ]);
    final reinforcement = await _loadDetail(_reinforcementPath, const [
      'content_reinforcement_index',
      'content_reinforcement_score',
    ]);
    final uxResonance = await _loadDetail(_uxResonancePath, const [
      'average_resonance',
      'ux_resonance',
    ]);

    if (semanticDepth == null || reinforcement == null || uxResonance == null) {
      return null;
    }

    return ContextualLearningSynthesizerResult(
      semanticDepth: semanticDepth,
      reinforcement: reinforcement,
      uxResonance: uxResonance,
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
