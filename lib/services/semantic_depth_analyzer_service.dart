import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _reinforcementPath =
    '$_reportsDir/content_reinforcement_synthesizer_summary.json';
const String _drillPath = '$_reportsDir/adaptive_drill_expansion_summary.json';
const String _uxHarmonyPath = '$_reportsDir/ux_harmony_integrator_summary.json';

class SemanticDepthAnalyzerResult {
  SemanticDepthAnalyzerResult({
    required this.reinforcement,
    required this.adaptiveDrill,
    required this.uxHarmony,
  });

  final _ScoreDetail reinforcement;
  final _ScoreDetail adaptiveDrill;
  final _ScoreDetail uxHarmony;
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

class SemanticDepthAnalyzerService {
  const SemanticDepthAnalyzerService();

  Future<SemanticDepthAnalyzerResult?> evaluate() async {
    final reinforcement = await _loadDetail(_reinforcementPath, const [
      'content_reinforcement_index',
      'content_reinforcement_score',
    ]);
    final adaptiveDrill = await _loadDetail(_drillPath, const [
      'adaptive_drill_index',
      'average_ev',
      'score',
    ]);
    final uxHarmony = await _loadDetail(_uxHarmonyPath, const [
      'ux_harmony_score',
      'harmony_index',
      'score',
    ]);

    if (reinforcement == null || adaptiveDrill == null || uxHarmony == null) {
      return null;
    }

    return SemanticDepthAnalyzerResult(
      reinforcement: reinforcement,
      adaptiveDrill: adaptiveDrill,
      uxHarmony: uxHarmony,
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
