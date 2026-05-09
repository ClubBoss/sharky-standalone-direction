import 'dart:convert';
import 'dart:io';

class DesignReadinessSummary {
  DesignReadinessSummary({
    required this.domains,
    required this.failCount,
    required this.stale,
    required this.missing,
    required this.riskScore,
    required this.designPriority,
  });

  final Map<String, bool> domains;
  final int failCount;
  final List<String> stale;
  final List<String> missing;
  final double riskScore;
  final String designPriority;

  Map<String, Object?> toJson() => {
    'domains': domains,
    'fail_count': failCount,
    'stale': stale,
    'missing': missing,
    'risk_score': riskScore,
    'design_priority': designPriority,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

class DesignReadinessBridgeService {
  const DesignReadinessBridgeService();

  Future<DesignReadinessSummary> evaluate() async {
    final file = File('release/_reports/visual_cohesion_probe_summary.json');
    if (!await file.exists())
      throw StateError('Missing visual cohesion summary');
    final bytes = await file.readAsBytes();
    if (!_isAscii(bytes)) throw StateError('Non-ASCII input');
    final decoded = json.decode(utf8.decode(bytes));
    if (decoded is! Map<String, Object?>)
      throw StateError('Invalid snapshot object');
    final rawDomains = decoded['domains'] as Map<String, Object?>?;
    if (rawDomains == null) throw StateError('Missing domains');
    final domains = <String, bool>{};
    rawDomains.forEach((key, value) {
      domains[key] = (value as bool?) ?? false;
    });
    final stale = (decoded['stale'] as List<dynamic>?)?.cast<String>() ?? [];
    final missing =
        (decoded['missing'] as List<dynamic>?)?.cast<String>() ?? [];
    final riskScore = _toDouble(decoded['visual_risk_score']) ?? 0.0;
    final priority = _designPriority(riskScore);
    return DesignReadinessSummary(
      domains: domains,
      failCount: domains.values.where((pass) => !pass).length,
      stale: stale,
      missing: missing,
      riskScore: riskScore.clamp(0.0, 1.0),
      designPriority: priority,
    );
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _designPriority(double score) {
    if (score >= 0.60) return 'high';
    if (score >= 0.30) return 'medium';
    return 'low';
  }

  bool _isAscii(List<int> bytes) => bytes.every((b) => b >= 0 && b <= 127);
}
