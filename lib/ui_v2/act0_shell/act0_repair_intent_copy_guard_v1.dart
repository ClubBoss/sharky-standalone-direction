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
  final line = switch (safeTemplateId) {
    'repair_same_clue_v1' when clue.isNotEmpty =>
      'You missed $clue. This hand repairs the same clue.',
    'repair_exact_replay_v1' when clue.isNotEmpty =>
      'Replay this spot to fix $clue.',
    'fallback_next_hand_v1' when skill.isNotEmpty =>
      'Next hand: keep building $skill.',
    _ => null,
  };

  if (line == null || _containsForbiddenCopyTokenV1(line)) {
    return null;
  }
  return line;
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
