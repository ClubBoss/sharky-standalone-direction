import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _evolutionPath =
    '$_reportsDir/content_evolution_audit_summary.json';
const String _retentionPath = '$_reportsDir/retention_growth_summary.json';
const String _drillPath = '$_reportsDir/adaptive_drill_expansion_summary.json';

class ContentReinforcementSynthesizerResult {
  ContentReinforcementSynthesizerResult({
    required this.evolution,
    required this.retention,
    required this.drill,
  });

  final _ScoreDetail evolution;
  final _ScoreDetail retention;
  final _ScoreDetail drill;
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

class ContentReinforcementSynthesizerService {
  const ContentReinforcementSynthesizerService();

  Future<ContentReinforcementSynthesizerResult?> evaluate() async {
    final evolution = await _loadDetail(_evolutionPath, const [
      'content_evolution_index',
      'content_evolution_score',
      'score',
    ]);
    final retention = await _loadDetail(_retentionPath, const [
      'retention_growth_score',
      'retention_growth_index',
      'score',
    ]);
    final drill = await _loadDetail(_drillPath, const [
      'adaptive_drill_index',
      'average_ev',
      'score',
    ]);

    if (evolution == null || retention == null || drill == null) {
      return null;
    }

    return ContentReinforcementSynthesizerResult(
      evolution: evolution,
      retention: retention,
      drill: drill,
    );
  }

  Future<_ScoreDetail?> _loadDetail(
    String path,
    List<String> candidateKeys,
  ) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      double? score;
      for (final key in candidateKeys) {
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
