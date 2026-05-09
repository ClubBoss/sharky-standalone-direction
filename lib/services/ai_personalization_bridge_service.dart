import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _xpReactionPath = '$_reportsDir/xp_reaction_summary.json';
const String _tonePath = '$_reportsDir/ai_tone_harmonizer_summary.json';
const String _uxPath = '$_reportsDir/ux_emotional_resonance_summary.json';

class AiPersonalizationBridgeResult {
  AiPersonalizationBridgeResult({
    required this.xpReaction,
    required this.tone,
    required this.uxResonance,
  });

  final _ScoreDetail xpReaction;
  final _ScoreDetail tone;
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

class AiPersonalizationBridgeService {
  const AiPersonalizationBridgeService();

  Future<AiPersonalizationBridgeResult?> evaluate() async {
    final xpReaction = await _loadDetail(_xpReactionPath, 'xp_reaction_index');
    final tone = await _loadDetail(_tonePath, 'tone_harmony_score');
    final ux = await _loadDetail(_uxPath, 'ux_resonance');

    if (xpReaction == null || tone == null || ux == null) return null;

    return AiPersonalizationBridgeResult(
      xpReaction: xpReaction,
      tone: tone,
      uxResonance: ux,
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
