const Set<String> act0RepairIntentCopyTemplateAllowlistV1 = <String>{
  'repair_same_clue_v1',
  'repair_exact_replay_v1',
  'fallback_next_hand_v1',
};

const Set<String> _act0RepairIntentForbiddenCopyTokensV1 = <String>{
  'ai',
  'ml',
  'adaptive',
  'solver',
  'gto',
  'optimal',
  'win-rate',
  'guaranteed',
  'premium',
  'paywall',
  'trial',
  'purchase',
  'restore',
};

String? act0RepairIntentCopyGuardLineV1({
  required String safeTemplateId,
  required String clueLabel,
  required String skillLabel,
}) {
  if (!act0RepairIntentCopyTemplateAllowlistV1.contains(safeTemplateId)) {
    return null;
  }

  final clue = clueLabel.trim();
  final skill = skillLabel.trim();
  final sameSignalClue = _learnerFacingSameSignalClueV1(clue);
  final exactReplayClue = _learnerFacingExactReplayClueV1(clue);
  final line = switch (safeTemplateId) {
    'repair_same_clue_v1' when sameSignalClue.isNotEmpty =>
      'You missed $sameSignalClue. This hand repeats that table clue.',
    'repair_exact_replay_v1' when exactReplayClue.isNotEmpty =>
      'Replay this spot to fix $exactReplayClue.',
    'fallback_next_hand_v1' when skill.isNotEmpty =>
      'Next hand: keep building $skill.',
    _ => null,
  };

  if (line == null || _containsForbiddenCopyTokenV1(line)) {
    return null;
  }
  return line;
}

String _learnerFacingSameSignalClueV1(String clueLabel) {
  final normalized = _normalizedRepairClueLabelV1(clueLabel);
  return switch (normalized) {
    'no bet yet' => 'that nobody has bet yet',
    _ => _learnerFacingCompactClueV1(clueLabel),
  };
}

String _learnerFacingExactReplayClueV1(String clueLabel) {
  return _learnerFacingCompactClueV1(clueLabel);
}

String _learnerFacingCompactClueV1(String clueLabel) {
  final normalized = _normalizedRepairClueLabelV1(clueLabel);
  return switch (normalized) {
    'no bet yet' => 'the no-bet-yet clue',
    _ when normalized.isNotEmpty => 'the $normalized clue',
    _ => '',
  };
}

String _normalizedRepairClueLabelV1(String clueLabel) {
  return clueLabel
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _containsForbiddenCopyTokenV1(String line) {
  final tokens = line
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9-]+'))
      .where((token) => token.isNotEmpty);
  for (final token in tokens) {
    if (_act0RepairIntentForbiddenCopyTokensV1.contains(token)) {
      return true;
    }
  }
  return false;
}
