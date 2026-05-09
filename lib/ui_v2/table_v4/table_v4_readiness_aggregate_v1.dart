class TableV4ReadinessAggregateV1 {
  const TableV4ReadinessAggregateV1();

  static Map<String, Object> build({
    required Map<String, Object?> readabilityMap,
    required Map<String, Object?> spacingMap,
    required Map<String, Object?> glowMap,
    required Map<String, Object?> animationMap,
    required Map<String, Object?> contrastMap,
    required Map<String, Object?> cohesionMap,
    required Map<String, Object?> visualQAMap,
  }) {
    final bool readabilityOk = readabilityMap['ready'] == true;
    final bool spacingOk = spacingMap['ready'] == true;
    final bool glowOk = glowMap['ready'] == true;
    final bool animationOk = animationMap['ready'] == true;
    final Map<String, Object?> contrastBody =
        contrastMap['v4_contrast_audit_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final bool contrastOk =
        contrastBody['typography_ok'] == true &&
        contrastBody['spacing_ok'] == true &&
        contrastBody['glow_ok'] == true &&
        contrastBody['card_ok'] == true;
    final Map<String, Object?> cohesionBody =
        cohesionMap['visual_cohesion_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final bool cohesionOk =
        cohesionBody['cohesion_ok'] == true &&
        cohesionBody['typography_ok'] == true &&
        cohesionBody['spacing_ok'] == true &&
        cohesionBody['glow_ok'] == true &&
        cohesionBody['card_ok'] == true &&
        cohesionBody['animation_ok'] == true;
    final Map<String, Object?> qaBody =
        visualQAMap['table_v4_visual_qa_surface_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final bool qaOk = qaBody['all_ok'] == true;
    final bool allOk =
        readabilityOk &&
        spacingOk &&
        glowOk &&
        animationOk &&
        contrastOk &&
        cohesionOk &&
        qaOk;
    final List<String> issues = <String>[
      ..._extractIssues(contrastBody, 'contrast'),
      ..._extractIssues(cohesionBody, 'cohesion'),
      ..._extractIssues(qaBody, 'visual_qa'),
    ];
    issues.sort();
    return <String, Object>{
      'table_v4_readiness_aggregate_v1': <String, Object>{
        'readability_ok': readabilityOk,
        'spacing_ok': spacingOk,
        'glow_ok': glowOk,
        'animation_ok': animationOk,
        'contrast_ok': contrastOk,
        'cohesion_ok': cohesionOk,
        'qa_ok': qaOk,
        'all_ok': allOk,
        'issues': issues,
        'ready': false,
      },
    };
  }

  static List<String> _extractIssues(Map<String, Object?> map, String prefix) {
    final Object? issues = map['issues'];
    if (issues is List) {
      return issues
          .whereType<String>()
          .map((issue) => '$prefix:$issue')
          .toList();
    }
    return <String>[];
  }
}
