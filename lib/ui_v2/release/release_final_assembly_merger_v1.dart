class ReleaseFinalAssemblyMergerV1 {
  const ReleaseFinalAssemblyMergerV1();

  static Map<String, Object> build({
    required Map<String, Object?> synthesisMap,
    required Map<String, Object?> unifiedReadinessMap,
    required Map<String, Object?> visualNormalizerMap,
    required Map<String, Object?> finalSignatureMap,
    required Map<String, Object> rcPackagingMap,
    required Map<String, Object> rcFreezeMap,
    required Map<String, Object> notesMap,
  }) {
    final Map<String, Object?> synthesisBody =
        synthesisMap['release_synthesis_surface_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> readinessBody =
        unifiedReadinessMap['release_unified_readiness_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> visualBody =
        visualNormalizerMap['release_visual_qa_normalizer_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> signatureBody =
        finalSignatureMap['release_final_signature_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final bool synthesisOk = synthesisBody['release_ok'] == true;
    final bool umbrellaOk = readinessBody['ready'] == true;
    final bool visualOk = visualBody['visual_ok'] == true;
    final bool signatureOk = signatureBody['ready'] == true;
    final bool packagingOk = rcPackagingMap['rc_ready'] == true;
    final bool freezeOk =
        rcFreezeMap['rc_freeze_v1'] is Map &&
        (((rcFreezeMap['rc_freeze_v1'] as Map)['freeze_ok'] ?? false) == true);
    final bool notesOk =
        notesMap['release_notes_v1'] is Map &&
        (((notesMap['release_notes_v1'] as Map)['ready'] ?? false) == true);
    final List<String> synthesisIssues = _normalizeList(
      synthesisBody['unique_issues'],
    );
    final List<String> readinessIssues = _normalizeList(
      readinessBody['unique_issues'],
    );
    final List<String> signatureIssues = _normalizeList(
      signatureBody['unique_issues'],
    );
    final Set<String> uniqueIssues = <String>{
      ...synthesisIssues,
      ...readinessIssues,
      ...signatureIssues,
    };
    final List<String> sortedIssues = uniqueIssues.toList()..sort();
    final int score = _readInt(signatureBody['score']) != 0
        ? _readInt(signatureBody['score'])
        : _readInt(synthesisBody['weighted_score']);
    final bool ready =
        synthesisOk &&
        umbrellaOk &&
        visualOk &&
        signatureOk &&
        packagingOk &&
        freezeOk &&
        notesOk;
    final Map<String, Object?> sections = <String, Object?>{
      'synthesis_ok': synthesisOk,
      'umbrella_ok': umbrellaOk,
      'visual_ok': visualOk,
      'signature_ok': signatureOk,
      'packaging_ok': packagingOk,
      'freeze_ok': freezeOk,
      'notes_ok': notesOk,
    };
    return <String, Object>{
      'release_final_assembly_merger_v1': <String, Object>{
        'ready': ready,
        'score': score,
        'issue_count': sortedIssues.length,
        'unique_issues': sortedIssues,
        'sections': sections,
        'merged_payload': <String, Object>{
          'synthesis': synthesisBody,
          'umbrella': readinessBody,
          'visual_normalizer': visualBody,
          'signature': signatureBody,
          'packaging': rcPackagingMap,
          'freeze': rcFreezeMap,
          'notes': notesMap,
        },
      },
    };
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static List<String> _normalizeList(Object? input) {
    if (input is List) {
      return input.whereType<String>().toList()..sort();
    }
    return <String>[];
  }
}
