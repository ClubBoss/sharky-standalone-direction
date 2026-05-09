class V4VisualQAExportBundle {
  const V4VisualQAExportBundle({
    required this.v3Snapshot,
    required this.v4Snapshot,
    required this.v4NormalizedTokens,
    required this.v4Delta,
    required this.v4Cohesion,
  });

  final Map<String, Object> v3Snapshot;
  final Map<String, Object> v4Snapshot;
  final Map<String, Object> v4NormalizedTokens;
  final Map<String, Object> v4Delta;
  final Map<String, Object> v4Cohesion;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'v3_snapshot': Map<String, Object>.unmodifiable(v3Snapshot),
    'v4_snapshot': Map<String, Object>.unmodifiable(v4Snapshot),
    'v4_normalized_tokens': Map<String, Object>.unmodifiable(
      v4NormalizedTokens,
    ),
    'v4_delta_report': Map<String, Object>.unmodifiable(v4Delta),
    'v4_cohesion_report': Map<String, Object>.unmodifiable(v4Cohesion),
  });
}
