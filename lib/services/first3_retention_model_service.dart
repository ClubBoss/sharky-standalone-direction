import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class First3RetentionBundle {
  First3RetentionBundle({
    required this.retentionConfidence,
    required this.retentionClarity,
    required this.retentionEngagement,
    required this.retentionScore,
    required this.retentionTier,
    required this.timestamp,
  });

  final double retentionConfidence;
  final double retentionClarity;
  final double retentionEngagement;
  final double retentionScore;
  final String retentionTier;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'retention_confidence': retentionConfidence,
    'retention_clarity': retentionClarity,
    'retention_engagement': retentionEngagement,
    'retention_score': retentionScore,
    'retention_tier': retentionTier,
    'timestamp': timestamp.toIso8601String(),
  };
}

class First3RetentionModelService {
  static const _ctaPath = 'release/_reports/smart_cta_planner.json';
  static const _scriptPath = 'release/_reports/adaptive_onboarding_script.json';

  const First3RetentionModelService();

  Future<First3RetentionBundle> run() async {
    final cta = await _loadAsciiJson(_ctaPath);
    final script = await _loadAsciiJson(_scriptPath);

    final primaryCta = _extractString(cta, 'primary_cta');
    final secondaryCta = _extractString(cta, 'secondary_cta');
    final microCta = _extractString(cta, 'micro_cta');
    final scriptPriority = _extractDouble(script, 'script_priority');

    final retentionConfidence = _scoreFromPriority(scriptPriority, primaryCta);
    final retentionClarity = _scoreFromDescriptor(secondaryCta, microCta);
    final retentionEngagement = _scoreFromMotivation(primaryCta, microCta);
    final retentionScore =
        (retentionConfidence * 0.5) +
        (retentionClarity * 0.3) +
        (retentionEngagement * 0.2);
    final tier = _tierFromScore(retentionScore);

    return First3RetentionBundle(
      retentionConfidence: retentionConfidence,
      retentionClarity: retentionClarity,
      retentionEngagement: retentionEngagement,
      retentionScore: retentionScore.clamp(0.0, 1.0),
      retentionTier: tier,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw First3RetentionException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw First3RetentionException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw First3RetentionException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw First3RetentionException('Invalid JSON in $path: ${error.message}');
    }
  }

  double _scoreFromPriority(double priority, String primaryCta) {
    final emphasis = primaryCta.contains('bold') ? 0.05 : 0.0;
    return (priority + emphasis).clamp(0.0, 1.0);
  }

  double _scoreFromDescriptor(String secondary, String micro) {
    final combined = '$secondary $micro';
    return _descriptorMatchScore(combined);
  }

  double _scoreFromMotivation(String primary, String micro) {
    final combined = '$primary $micro';
    return _descriptorMatchScore(combined);
  }

  double _descriptorMatchScore(String text) {
    final normalized = text.toLowerCase();
    final positives = [
      'structure',
      'confidence',
      'momentum',
      'steady',
      'calm',
      'focused',
    ];
    final bonuses = positives.where(normalized.contains).length;
    final lengthBoost = (normalized.split(RegExp(r'\s+')).length / 20).clamp(
      0.0,
      0.3,
    );
    return ((bonuses * 0.2) + lengthBoost).clamp(0.0, 1.0);
  }

  String _tierFromScore(double score) {
    if (score >= 0.8) return 'high';
    if (score >= 0.5) return 'mid';
    return 'low';
  }

  String _extractString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw First3RetentionException('$key missing or empty');
  }

  double _extractDouble(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    throw First3RetentionException('$key missing or not numeric');
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class First3RetentionException implements Exception {
  final String message;

  First3RetentionException(this.message);

  @override
  String toString() => 'First3RetentionException: $message';
}
