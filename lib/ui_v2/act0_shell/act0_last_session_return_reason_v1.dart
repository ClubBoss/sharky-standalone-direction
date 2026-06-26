const String act0LastSessionProofFixLandedV1 = 'fix_landed';
const String act0LastSessionProofNotYetV1 = 'not_yet';
const String act0LastSessionProofSkippedV1 = 'skipped';

class Act0LastSessionLearnerStateV1 {
  const Act0LastSessionLearnerStateV1({
    required this.lastSessionRepairFocusId,
    required this.lastSessionProofResult,
    required this.lastSessionDate,
    required this.lastSessionWorldId,
  });

  final String lastSessionRepairFocusId;
  final String lastSessionProofResult;
  final String lastSessionDate;
  final String lastSessionWorldId;

  bool get isUsable =>
      lastSessionProofResult.trim().isNotEmpty &&
      lastSessionDate.trim().isNotEmpty &&
      lastSessionWorldId.trim().isNotEmpty;

  Map<String, Object> toJson() => <String, Object>{
    'last_session_repair_focus_id': lastSessionRepairFocusId,
    'last_session_proof_result': lastSessionProofResult,
    'last_session_date': lastSessionDate,
    'last_session_world_id': lastSessionWorldId,
  };

  static Act0LastSessionLearnerStateV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<String, Object?>();
    final repairFocusId = _field(map, 'last_session_repair_focus_id');
    final proofResult = _field(map, 'last_session_proof_result');
    final sessionDate = _field(map, 'last_session_date');
    final worldId = _field(map, 'last_session_world_id');
    if (proofResult.isEmpty || sessionDate.isEmpty || worldId.isEmpty) {
      return null;
    }
    if (proofResult != act0LastSessionProofFixLandedV1 &&
        proofResult != act0LastSessionProofNotYetV1 &&
        proofResult != act0LastSessionProofSkippedV1) {
      return null;
    }
    return Act0LastSessionLearnerStateV1(
      lastSessionRepairFocusId: repairFocusId,
      lastSessionProofResult: proofResult,
      lastSessionDate: sessionDate,
      lastSessionWorldId: worldId,
    );
  }

  static String _field(Map<String, Object?> map, String key) {
    return (map[key] ?? '').toString().trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Act0LastSessionLearnerStateV1 &&
          other.lastSessionRepairFocusId == lastSessionRepairFocusId &&
          other.lastSessionProofResult == lastSessionProofResult &&
          other.lastSessionDate == lastSessionDate &&
          other.lastSessionWorldId == lastSessionWorldId;

  @override
  int get hashCode => Object.hash(
    lastSessionRepairFocusId,
    lastSessionProofResult,
    lastSessionDate,
    lastSessionWorldId,
  );
}

String? act0PersonalizedReturnReasonLineV1(
  Act0LastSessionLearnerStateV1? state, {
  Map<String, String> repairFocusLabelsById = const <String, String>{},
}) {
  final usable = state;
  if (usable == null || !usable.isUsable) {
    return null;
  }
  final focusLabel = _safeFocusLabel(
    usable.lastSessionRepairFocusId,
    repairFocusLabelsById,
  );
  return switch (usable.lastSessionProofResult) {
    act0LastSessionProofFixLandedV1 =>
      focusLabel == null
          ? 'Yesterday you landed the fix. One quick rep keeps it fresh.'
          : 'Yesterday you landed the fix. Keep the $focusLabel fresh.',
    act0LastSessionProofNotYetV1 =>
      focusLabel == null
          ? 'You were working on this table clue. One rep keeps it honest.'
          : 'You were working on the $focusLabel. One rep keeps it honest.',
    act0LastSessionProofSkippedV1 =>
      'Start with one table read and build today\'s proof.',
    _ => null,
  };
}

String? _safeFocusLabel(String focusId, Map<String, String> labelsById) {
  final raw = labelsById[focusId.trim()]?.trim() ?? '';
  if (raw.isEmpty) {
    return null;
  }
  final lower = raw.toLowerCase();
  const forbidden = <String>[
    'ai',
    'gto',
    'solver',
    'master',
    'premium',
    'paywall',
  ];
  if (forbidden.any(lower.contains)) {
    return null;
  }
  if (raw.contains('_')) {
    return null;
  }
  return raw;
}
