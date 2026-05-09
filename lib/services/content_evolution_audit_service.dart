import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _personaPath =
    '$_reportsDir/adaptive_persona_evolution_summary.json';
const String _contentSyncPath = '$_reportsDir/content_sync_audit_summary.json';
const String _retentionPath = '$_reportsDir/retention_growth_summary.json';

class ContentEvolutionAuditResult {
  ContentEvolutionAuditResult({
    required this.personaEvolution,
    required this.contentSync,
    required this.retentionGrowth,
  });

  final _ScoreDetail personaEvolution;
  final _ScoreDetail contentSync;
  final _ScoreDetail retentionGrowth;
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

class ContentEvolutionAuditService {
  const ContentEvolutionAuditService();

  Future<ContentEvolutionAuditResult?> evaluate() async {
    final personaEvolution = await _loadDetail(
      _personaPath,
      'persona_evolution_index',
    );
    final contentSync = await _loadDetail(
      _contentSyncPath,
      'content_consistency_index',
    );
    final retentionGrowth = await _loadDetail(
      _retentionPath,
      'retention_growth_index',
    );

    if (personaEvolution == null ||
        contentSync == null ||
        retentionGrowth == null) {
      return null;
    }

    return ContentEvolutionAuditResult(
      personaEvolution: personaEvolution,
      contentSync: contentSync,
      retentionGrowth: retentionGrowth,
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
    return timestamp != null ? DateTime.tryParse(timestamp) : null;
  }
}
