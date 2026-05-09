class TableV4VisualQASurfaceV1 {
  const TableV4VisualQASurfaceV1();

  static Map<String, Object> build({
    required Map<String, Object?> contrastMap,
    required Map<String, Object?> cohesionMap,
    required Map<String, Object?> readinessMap,
  }) {
    final bool contrastOk = contrastMap['v4_contrast_audit_v1'] is Map
        ? (contrastMap['v4_contrast_audit_v1']
                      as Map<String, Object?>)['typography_ok'] ==
                  true &&
              (contrastMap['v4_contrast_audit_v1']
                      as Map<String, Object?>)['spacing_ok'] ==
                  true &&
              (contrastMap['v4_contrast_audit_v1']
                      as Map<String, Object?>)['glow_ok'] ==
                  true &&
              (contrastMap['v4_contrast_audit_v1']
                      as Map<String, Object?>)['card_ok'] ==
                  true
        : false;
    final Map<String, Object?> cohesionBody =
        cohesionMap['visual_cohesion_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final bool cohesionOk =
        (cohesionBody['typography_ok'] == true) &&
        (cohesionBody['spacing_ok'] == true) &&
        (cohesionBody['glow_ok'] == true) &&
        (cohesionBody['card_ok'] == true) &&
        (cohesionBody['animation_ok'] == true);
    final bool readinessOk = readinessMap['v4_ready'] == true;
    final List<String> issues = <String>[
      ..._issuesFromContrast(contrastMap),
      ..._issuesFromCohesion(cohesionBody),
    ];
    issues.sort();
    final bool allOk = contrastOk && cohesionOk && readinessOk;
    return <String, Object>{
      'table_v4_visual_qa_surface_v1': <String, Object>{
        'contrast_ok': contrastOk,
        'cohesion_ok': cohesionOk,
        'readiness_ok': readinessOk,
        'all_ok': allOk,
        'issues': issues,
        'ready': false,
      },
    };
  }

  static List<String> _issuesFromContrast(Map<String, Object?> contrastMap) {
    final Object? body = contrastMap['v4_contrast_audit_v1'];
    if (body is Map<String, Object?>) {
      final Object? issues = body['issues'];
      if (issues is List<Object?>) {
        return issues.whereType<String>().toList();
      }
    }
    return <String>[];
  }

  static List<String> _issuesFromCohesion(Map<String, Object?> cohesionBody) {
    final Object? issues = cohesionBody['issues'];
    if (issues is List<Object?>) {
      return issues.whereType<String>().toList();
    }
    return <String>[];
  }
}
