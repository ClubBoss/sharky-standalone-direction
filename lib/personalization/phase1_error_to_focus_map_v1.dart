const Map<String, String> kPhase1ErrorToFocusLabelV1 = {
  'wrong_action': 'range',
  'incorrect_seat': 'action_order',
  'seat_role_confusion': 'action_order',
  'action_selection': 'initiative',
  'range_leak': 'starting_hands',
  'pot_odds_error': 'pot_odds',
  'equity_miscalc': 'pot_odds',
  'board_slot_confusion': 'board_texture',
  'flop_decision_error': 'flop',
  'equity_realization_error': 'equity_realization',
  'turn_decision_error': 'turn',
  'river_decision_error': 'river',
  'bankroll_leak': 'bankroll',
};

String? focusLabelForPhase1Error(String? errorClass) {
  return focusLabelForPhase1Signal(errorClass: errorClass);
}

String? focusLabelForPhase1Signal({
  String? errorClass,
  String? errorType,
  String? category,
  String? subreason,
}) {
  final directErrorClass = _directFocusFor(errorClass);
  if (directErrorClass != null) {
    return directErrorClass;
  }
  final directErrorType = _directFocusFor(errorType);
  if (directErrorType != null) {
    return directErrorType;
  }

  final candidates = <String?>[
    _normalizeSignal(errorClass),
    _normalizeSignal(errorType),
    _normalizeSignal(category),
    _normalizeSignal(subreason),
  ];
  for (final signal in candidates) {
    if (signal == null) continue;
    final inferred = _inferFocusFromSignal(signal);
    if (inferred != null) {
      return inferred;
    }
  }

  // Backward compatibility: keep existing default mapping.
  final normalizedErrorClass = _normalizeSignal(errorClass);
  if (normalizedErrorClass == 'wrong_action') {
    return 'range';
  }
  final normalizedErrorType = _normalizeSignal(errorType);
  if (normalizedErrorType == 'wrong_action') {
    return 'range';
  }
  return null;
}

String? _directFocusFor(String? value) {
  final normalized = _normalizeSignal(value);
  if (normalized == null) return null;
  return kPhase1ErrorToFocusLabelV1[normalized];
}

String? _normalizeSignal(String? value) {
  if (value == null) return null;
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  return normalized;
}

String? _inferFocusFromSignal(String normalizedSignal) {
  if (_containsAny(normalizedSignal, const <String>[
    'action_order',
    'seat',
    'blind_order',
    'turn_order',
  ])) {
    return 'action_order';
  }
  if (_containsAny(normalizedSignal, const <String>[
    'initiative',
    'aggression',
    'action_selection',
  ])) {
    return 'initiative';
  }
  if (_containsAny(normalizedSignal, const <String>[
    'starting_hands',
    'hand_selection',
    'preflop_range',
    'opening_range',
  ])) {
    return 'starting_hands';
  }
  if (_containsAny(normalizedSignal, const <String>[
    'pot_odds',
    'equity',
    'price_to_call',
  ])) {
    return 'pot_odds';
  }
  if (_containsAny(normalizedSignal, const <String>[
    'board_texture',
    'wet_board',
    'dry_board',
    'texture',
  ])) {
    return 'board_texture';
  }
  if (_containsAny(normalizedSignal, const <String>[
    'equity_realization',
    'realization',
  ])) {
    return 'equity_realization';
  }
  if (_containsAny(normalizedSignal, const <String>['flop'])) {
    return 'flop';
  }
  if (_containsAny(normalizedSignal, const <String>['turn'])) {
    return 'turn';
  }
  if (_containsAny(normalizedSignal, const <String>['river'])) {
    return 'river';
  }
  if (_containsAny(normalizedSignal, const <String>[
    'bankroll',
    'variance',
    'tilt_bankroll',
  ])) {
    return 'bankroll';
  }
  return null;
}

bool _containsAny(String value, List<String> tokens) {
  for (final token in tokens) {
    if (value.contains(token)) {
      return true;
    }
  }
  return false;
}
