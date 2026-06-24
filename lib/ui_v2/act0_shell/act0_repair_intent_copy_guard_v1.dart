const Set<String> act0RepairIntentCopyTemplateAllowlistV1 = <String>{
  'repair_same_clue_v1',
  'repair_exact_replay_v1',
  'fallback_next_hand_v1',
  'review_repair_coach_v1',
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
  'unlock',
  'guarantee',
  'leak',
  'detected',
  'mastered',
  'forever',
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

List<String> act0ReviewRepairCoachCopyGuardLinesV1({
  required String clueLabel,
}) {
  final normalized = _normalizedRepairClueLabelV1(clueLabel);
  if (normalized.isEmpty) {
    return const <String>[];
  }
  final learnerFacingClue = switch (normalized) {
    'no bet yet' => 'The no-bet-yet clue',
    _ => '${normalized[0].toUpperCase()}${normalized.substring(1)}',
  };
  final nextRepair = switch (normalized) {
    'no bet yet' => 'Next repair: one no-bet-yet hand',
    _ => 'Next repair: one focused hand',
  };
  final lines = <String>[
    '$learnerFacingClue is still the one to fix.',
    nextRepair,
  ];
  if (lines.any(_containsForbiddenCopyTokenV1)) {
    return const <String>[];
  }
  return List<String>.unmodifiable(lines);
}

String? act0RepairResultReceiptCopyGuardLineV1({
  required bool repaired,
  required bool exactReplay,
  required String clueLabel,
}) {
  final line = exactReplay
      ? (repaired
            ? 'Replay fixed: you handled this spot correctly.'
            : 'Replay missed again: try the same spot once more.')
      : _sameSignalRepairResultReceiptLineV1(
          repaired: repaired,
          clueLabel: clueLabel,
        );
  if (line == null || _containsForbiddenCopyTokenV1(line)) {
    return null;
  }
  return line;
}

List<String> act0RepairSessionSummaryCopyGuardLinesV1({
  required bool repaired,
  required bool exactReplay,
  required String clueLabel,
}) {
  final lines = exactReplay
      ? const <String>[]
      : _sameSignalRepairSessionSummaryLinesV1(
          repaired: repaired,
          clueLabel: clueLabel,
        );
  if (lines.isEmpty) {
    return const <String>[];
  }
  for (final line in lines) {
    if (_containsForbiddenCopyTokenV1(line)) {
      return const <String>[];
    }
  }
  return List<String>.unmodifiable(lines);
}

String? _sameSignalRepairResultReceiptLineV1({
  required bool repaired,
  required String clueLabel,
}) {
  final compactClue = _learnerFacingCompactClueV1(clueLabel);
  final repeatedClue = _learnerFacingRepeatedMissClueV1(clueLabel);
  if (repaired && compactClue.isNotEmpty) {
    return 'Repair fixed: you caught $compactClue.';
  }
  if (!repaired && repeatedClue.isNotEmpty) {
    return 'Still missed: $repeatedClue. One more repair hand will help.';
  }
  return null;
}

List<String> _sameSignalRepairSessionSummaryLinesV1({
  required bool repaired,
  required String clueLabel,
}) {
  final compactClue = _learnerFacingCompactClueV1(clueLabel);
  if (compactClue.isEmpty) {
    return const <String>[];
  }
  if (repaired) {
    return <String>['Today you repaired $compactClue.'];
  }
  final focusClue = _learnerFacingNextFocusClueV1(clueLabel);
  return <String>[
    'Still fragile: $compactClue.',
    if (focusClue.isNotEmpty) 'Next focus: one more $focusClue repair hand.',
  ];
}

String _learnerFacingSameSignalClueV1(String clueLabel) {
  final normalized = _normalizedRepairClueLabelV1(clueLabel);
  return switch (normalized) {
    'no bet yet' => 'that nobody has bet yet',
    _ => _learnerFacingCompactClueV1(clueLabel),
  };
}

String _learnerFacingRepeatedMissClueV1(String clueLabel) {
  final normalized = _normalizedRepairClueLabelV1(clueLabel);
  return switch (normalized) {
    'no bet yet' => 'nobody had bet yet',
    _ => _learnerFacingCompactClueV1(clueLabel),
  };
}

String _learnerFacingNextFocusClueV1(String clueLabel) {
  final normalized = _normalizedRepairClueLabelV1(clueLabel);
  return switch (normalized) {
    'no bet yet' => 'no-bet-yet',
    _ => normalized.replaceAll(' ', '-'),
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
  final normalized = clueLabel
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return switch (normalized) {
    'legal actions' => 'no bet yet',
    'meet the table' => 'no bet yet',
    _ => normalized,
  };
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
