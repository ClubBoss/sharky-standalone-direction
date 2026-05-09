import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _retentionPath = '$_reportsDir/retention_knowledge_summary.json';
const String _contextualPath = '$_reportsDir/contextual_learning_summary.json';
const String _uxPath = '$_reportsDir/ux_resonance_summary.json';

class AdaptiveContextBridgeResult {
  AdaptiveContextBridgeResult({
    required this.retentionKnowledge,
    required this.contextualLearning,
    required this.uxResonance,
  });

  final _ScoreDetail retentionKnowledge;
  final _ScoreDetail contextualLearning;
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

class AdaptiveContextBridgeService {
  const AdaptiveContextBridgeService();

  Future<AdaptiveContextBridgeResult?> evaluate() async {
    final retentionKnowledge = await _loadDetail(_retentionPath, const [
      'retention_knowledge_index',
      'retention_knowledge_score',
      'retention_index',
    ]);
    final contextualLearning = await _loadDetail(_contextualPath, const [
      'contextual_learning_index',
      'contextual_learning_score',
      'contextual_index',
    ]);
    final uxResonance = await _loadDetail(_uxPath, const [
      'ux_resonance_score',
      'average_resonance',
      'ux_index',
    ]);

    if (retentionKnowledge == null ||
        contextualLearning == null ||
        uxResonance == null) {
      return null;
    }

    return AdaptiveContextBridgeResult(
      retentionKnowledge: retentionKnowledge,
      contextualLearning: contextualLearning,
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
