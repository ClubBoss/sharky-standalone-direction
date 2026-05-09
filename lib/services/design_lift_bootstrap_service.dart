import 'dart:convert';
import 'dart:io';

class DesignLiftBlueprint {
  DesignLiftBlueprint({
    required this.designPriority,
    required this.riskScore,
    required this.domains,
    required this.focusAreas,
    required this.coreDirectives,
  });

  final String designPriority;
  final double riskScore;
  final Map<String, bool> domains;
  final List<String> focusAreas;
  final List<String> coreDirectives;

  Map<String, Object?> toJson() => {
    'design_priority': designPriority,
    'risk_score': riskScore,
    'domains': domains,
    'focus_areas': focusAreas,
    'core_directives': coreDirectives,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

class DesignLiftBootstrapService {
  const DesignLiftBootstrapService();

  Future<DesignLiftBlueprint> bootstrap() async {
    final file = File('release/_reports/design_readiness_summary.json');
    if (!await file.exists())
      throw StateError('Missing design readiness summary');
    final bytes = await file.readAsBytes();
    if (!_isAscii(bytes)) throw StateError('Non-ASCII readiness summary');
    final decoded = json.decode(utf8.decode(bytes));
    if (decoded is! Map<String, Object?>)
      throw StateError('Invalid summary structure');
    final domains = (decoded['domains'] as Map<String, Object?>?)?.map(
      (key, value) => MapEntry(key, (value as bool?) ?? false),
    );
    if (domains == null) throw StateError('Missing domains map');
    final failCount = (decoded['fail_count'] as int?) ?? 0;
    final stale = (decoded['stale'] as List<dynamic>?)?.cast<String>() ?? [];
    final missing =
        (decoded['missing'] as List<dynamic>?)?.cast<String>() ?? [];
    final riskScore = _toDouble(decoded['risk_score']) ?? 0.0;
    final priority = (decoded['design_priority'] as String?) ?? 'low';
    final focusAreas = <String>['visual_polish', 'layout_pass'];
    if (stale.isNotEmpty) focusAreas.insert(0, 'fix_stale');
    if (missing.isNotEmpty) focusAreas.insert(0, 'fix_missing');
    if (failCount > 0) focusAreas.insert(0, 'fix_failures');
    final coreDirectives = const [
      'unify_spacing',
      'normalize_colors',
      'improve_contrast',
      'strengthen_hierarchy',
    ];
    return DesignLiftBlueprint(
      designPriority: priority,
      riskScore: riskScore.clamp(0.0, 1.0),
      domains: domains,
      focusAreas: focusAreas,
      coreDirectives: coreDirectives,
    );
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool _isAscii(List<int> bytes) => bytes.every((b) => b >= 0 && b <= 127);
}
