enum MicroTaskStreetV1 { flop, turn, river }

class MicroTaskStep {
  const MicroTaskStep({
    required this.prompt,
    required this.hint,
    required this.expectedSeatIds,
    this.contextText,
    this.tradeoffText,
    this.consequenceText,
    this.insightText,
    this.instructionText,
    this.goalText,
    this.guidedScope,
    this.isoGroup,
    this.heroSeatId,
    this.street,
    this.boardCards,
    this.heroCards,
    this.pot,
    this.toCall,
    this.allowedActions,
    this.expectedActionKind,
  });

  final String prompt;
  final String hint;
  final List<String> expectedSeatIds;
  final String? contextText;
  final String? tradeoffText;
  final String? consequenceText;
  final String? insightText;
  final String? instructionText;
  final String? goalText;
  final String? guidedScope;
  final String? isoGroup;
  final String? heroSeatId;
  final MicroTaskStreetV1? street;
  final List<String>? boardCards;
  final List<String>? heroCards;
  final int? pot;
  final int? toCall;
  final List<String>? allowedActions;
  final String? expectedActionKind;
}

typedef World1MicroTaskPack = List<MicroTaskStep>;

MicroTaskStep mtStep({
  required String prompt,
  required String hint,
  required List<String> expectedSeatIds,
  String? instructionText,
  String? goalText,
  String? guidedScope,
  String? isoGroup,
  String? contextText,
  String? tradeoffText,
  String? consequenceText,
  String? insightText,
  String? heroSeatId,
  MicroTaskStreetV1? street,
  List<String>? boardCards,
  List<String>? heroCards,
  int? pot,
  int? toCall,
  List<String>? allowedActions,
  String? expectedActionKind,
}) {
  assert(
    _isValidBoardCardsCountV1(boardCards),
    'boardCards must be null or length 0/3/4/5',
  );
  assert(
    _isValidHeroCardsCountV1(heroCards),
    'heroCards must be null or length 2',
  );
  return MicroTaskStep(
    prompt: prompt,
    hint: hint,
    expectedSeatIds: expectedSeatIds,
    instructionText: instructionText,
    goalText: goalText,
    guidedScope: guidedScope,
    isoGroup: isoGroup,
    contextText: contextText,
    tradeoffText: tradeoffText,
    consequenceText: consequenceText,
    insightText: insightText,
    heroSeatId: heroSeatId,
    street: street,
    boardCards: boardCards == null ? null : List<String>.from(boardCards),
    heroCards: heroCards == null ? null : List<String>.from(heroCards),
    pot: pot,
    toCall: toCall,
    allowedActions: allowedActions == null
        ? null
        : List<String>.from(allowedActions),
    expectedActionKind: expectedActionKind,
  );
}

bool _isValidBoardCardsCountV1(List<String>? cards) {
  if (cards == null) return true;
  return cards.length == 0 ||
      cards.length == 3 ||
      cards.length == 4 ||
      cards.length == 5;
}

bool _isValidHeroCardsCountV1(List<String>? cards) {
  if (cards == null) return true;
  return cards.length == 2;
}

World1MicroTaskPack pack12(
  List<MicroTaskStep> steps, {
  int minDistinctConsequenceTexts = 0,
}) {
  assert(steps.length == 12, 'Campaign pack must contain exactly 12 hands.');
  assert(
    minDistinctConsequenceTexts <= 0 ||
        distinctConsequenceTextCount(steps) >= minDistinctConsequenceTexts,
    'Campaign pack consequence text variety invariant failed.',
  );
  return steps;
}

int distinctConsequenceTextCount(Iterable<MicroTaskStep> steps) {
  final values = steps
      .map((step) => step.consequenceText?.trim() ?? '')
      .where((value) => value.isNotEmpty)
      .toSet();
  return values.length;
}

bool hasPositiveAndNegativeConsequenceDeltas(
  Iterable<MicroTaskStep> steps, {
  String positiveToken = '+8',
  String negativeToken = '-6',
}) {
  var sawPositive = false;
  var sawNegative = false;
  for (final step in steps) {
    final consequence = step.consequenceText ?? '';
    if (consequence.contains(positiveToken)) {
      sawPositive = true;
    }
    if (consequence.contains(negativeToken)) {
      sawNegative = true;
    }
    if (sawPositive && sawNegative) {
      return true;
    }
  }
  return false;
}

int distinctConsequenceTextCountForPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  final pack = kCampaignPacksV1[normalized];
  if (pack == null) {
    return 0;
  }
  return distinctConsequenceTextCount(pack);
}

bool hasPositiveAndNegativeConsequenceDeltasForPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  final pack = kCampaignPacksV1[normalized];
  if (pack == null) {
    return false;
  }
  return hasPositiveAndNegativeConsequenceDeltas(pack);
}

World1MicroTaskPack? _spinePackStepsForIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  final pack = kCampaignPacksV1[normalized];
  if (pack == null) {
    return null;
  }
  if (pack.length != 12) {
    return null;
  }
  return pack;
}

String _stepNarrativeTextV1(MicroTaskStep step) {
  return [
    step.prompt,
    step.contextText ?? '',
    step.tradeoffText ?? '',
    step.consequenceText ?? '',
    step.insightText ?? '',
  ].join(' ').toLowerCase();
}

bool _textContainsAnyTokenV1(String text, List<String> tokens) {
  for (final token in tokens) {
    if (text.contains(token)) {
      return true;
    }
  }
  return false;
}

bool spinePackHasEarlyPositiveBeatV1(String packId) {
  final pack = _spinePackStepsForIdV1(packId);
  if (pack == null) {
    return false;
  }
  for (var i = 0; i < 3; i++) {
    final text = _stepNarrativeTextV1(pack[i]);
    if (_textContainsAnyTokenV1(text, ['+8', 'win', 'save', 'clean', 'edge'])) {
      return true;
    }
  }
  return false;
}

bool spinePackHasMidPressureBeatsV1(String packId) {
  final pack = _spinePackStepsForIdV1(packId);
  if (pack == null) {
    return false;
  }
  const pressureTokens = <String>[
    'pressure',
    'tempo',
    'initiative',
    'trap',
    'lane',
    'recount',
    'spew',
    'punish',
  ];
  var pressureBeatCount = 0;
  for (var i = 3; i <= 8; i++) {
    final text = _stepNarrativeTextV1(pack[i]);
    if (_textContainsAnyTokenV1(text, pressureTokens)) {
      pressureBeatCount++;
    }
  }
  return pressureBeatCount >= 2;
}

bool spinePackHasContrastBeatV1(String packId) {
  final pack = _spinePackStepsForIdV1(packId);
  if (pack == null) {
    return false;
  }
  const contrastTokens = <String>[
    'punish',
    'mistake',
    'leak',
    'punt',
    'tax',
    'spew',
    'overcall',
    'misfire',
    'trap',
  ];
  for (final step in pack) {
    final consequence = (step.consequenceText ?? '').toLowerCase();
    if (consequence.contains('+8') &&
        consequence.contains('-6') &&
        _textContainsAnyTokenV1(consequence, contrastTokens)) {
      return true;
    }
  }
  return false;
}

bool spinePackHasStrongFinalBeatV1(String packId) {
  final pack = _spinePackStepsForIdV1(packId);
  if (pack == null) {
    return false;
  }
  final finalText = _stepNarrativeTextV1(pack.last);
  if (!finalText.contains('+8')) {
    return false;
  }
  return _textContainsAnyTokenV1(finalText, [
    'strong close',
    'close',
    'finish',
    'chapter',
    'resolve',
    'level-up',
    'golden',
    'reset',
  ]);
}

bool _isSpineNormalizedPackIdV1(String packId) {
  final id = packId.trim().toLowerCase();
  return id.contains('_spine_campaign_v1') ||
      id.contains('_spine_followup_v1_');
}

MicroTaskStep _cloneNormalizedBeatV1(
  MicroTaskStep source, {
  required String packId,
  required int beatIndex,
}) {
  final beatNumber = beatIndex + 1;
  final pressureToken = const <String>[
    'pressure',
    'tempo',
    'initiative',
    'trap',
    'lane',
    'spew',
    'punish',
    'recount',
  ][beatIndex % 8];

  String withSuffix(String? value, String fallback) {
    final base = (value == null || value.trim().isEmpty)
        ? fallback
        : value.trim();
    return '$base [beat $beatNumber]';
  }

  var consequence = withSuffix(
    source.consequenceText,
    'Beat $beatNumber: +8 chips for clean line. -6 chips for spew line.',
  );
  if (!consequence.contains('+8')) {
    consequence = '$consequence +8 chips.';
  }
  if (!consequence.contains('-6')) {
    consequence = '$consequence -6 chips.';
  }
  if (!consequence.toLowerCase().contains('spew') &&
      !consequence.toLowerCase().contains('punish')) {
    consequence = '$consequence ${beatIndex.isEven ? 'Spew' : 'Punish'} line.';
  }
  if (beatIndex >= 3 &&
      beatIndex <= 8 &&
      !consequence.toLowerCase().contains(pressureToken)) {
    consequence =
        '$consequence ${pressureToken[0].toUpperCase()}${pressureToken.substring(1)} beat.';
  }

  var context = withSuffix(
    source.contextText,
    'Pack ${packId.toLowerCase()} beat $beatNumber.',
  );
  if (beatIndex >= 3 &&
      beatIndex <= 8 &&
      !context.toLowerCase().contains(pressureToken)) {
    context =
        '$context ${pressureToken[0].toUpperCase()}${pressureToken.substring(1)} spot.';
  }

  var tradeoff = withSuffix(
    source.tradeoffText,
    'Choose the clean lane, or drift into mistakes.',
  );
  if (beatIndex >= 3 &&
      beatIndex <= 8 &&
      !tradeoff.toLowerCase().contains(pressureToken)) {
    tradeoff = '$tradeoff Protect $pressureToken.';
  }

  var insight = withSuffix(source.insightText, 'Repeat the clean pattern.');
  if (beatIndex == 11 &&
      !insight.toLowerCase().contains('finish') &&
      !insight.toLowerCase().contains('close') &&
      !insight.toLowerCase().contains('resolve')) {
    insight = '$insight Strong close: resolve the chapter.';
  }

  final inferredGuidedScope = (() {
    final scoped = source.guidedScope?.trim();
    if (scoped != null && scoped.isNotEmpty) {
      return scoped;
    }
    final normalizedPackId = packId.trim().toLowerCase();
    if (!normalizedPackId.contains('world2_spine_')) {
      return source.guidedScope;
    }
    final hasExpectedSeatIds = source.expectedSeatIds.any(
      (seatId) => seatId.trim().isNotEmpty,
    );
    final hasAllowedActions =
        source.allowedActions?.any((action) => action.trim().isNotEmpty) ??
        false;
    final hasExpectedActionKind =
        source.expectedActionKind?.trim().isNotEmpty ?? false;
    if (hasExpectedSeatIds && !hasAllowedActions && !hasExpectedActionKind) {
      return 'seats';
    }
    return source.guidedScope;
  })();

  return MicroTaskStep(
    prompt: source.prompt,
    hint: source.hint,
    expectedSeatIds: List<String>.from(source.expectedSeatIds),
    contextText: context,
    tradeoffText: tradeoff,
    consequenceText: consequence,
    insightText: insight,
    instructionText: source.instructionText == null
        ? null
        : withSuffix(source.instructionText, source.instructionText!),
    goalText: source.goalText == null
        ? null
        : withSuffix(source.goalText, source.goalText!),
    guidedScope: inferredGuidedScope,
    isoGroup: source.isoGroup == null || source.isoGroup!.trim().isEmpty
        ? null
        : '${source.isoGroup}_b$beatNumber',
    heroSeatId: source.heroSeatId,
    street: source.street,
    boardCards: source.boardCards == null
        ? null
        : List<String>.from(source.boardCards!),
    heroCards: source.heroCards == null
        ? null
        : List<String>.from(source.heroCards!),
    pot: source.pot,
    toCall: source.toCall,
    allowedActions: source.allowedActions == null
        ? null
        : List<String>.from(source.allowedActions!),
    expectedActionKind: source.expectedActionKind,
  );
}

World1MicroTaskPack _normalizeSpinePackTo12V1(
  String packId,
  World1MicroTaskPack pack,
) {
  if (pack.length == 12) {
    return pack;
  }
  if (pack.isEmpty) {
    return pack;
  }
  final anchors = pack.length == 1 ? pack : pack.sublist(0, pack.length - 1);
  final finalSource = pack.last;
  final expanded = <MicroTaskStep>[];
  for (var beatIndex = 0; beatIndex < 12; beatIndex++) {
    final source = beatIndex == 11
        ? finalSource
        : anchors[beatIndex % anchors.length];
    expanded.add(
      _cloneNormalizedBeatV1(source, packId: packId, beatIndex: beatIndex),
    );
  }
  return List<MicroTaskStep>.unmodifiable(expanded);
}

Map<String, World1MicroTaskPack> _normalizeCampaignPacksMapV1(
  Map<String, World1MicroTaskPack> raw,
) {
  final normalized = <String, World1MicroTaskPack>{};
  for (final entry in raw.entries) {
    final key = entry.key.trim().toLowerCase();
    final pack = entry.value;
    normalized[key] = _isSpineNormalizedPackIdV1(key)
        ? _normalizeSpinePackTo12V1(key, pack)
        : pack;
  }
  return Map<String, World1MicroTaskPack>.unmodifiable(normalized);
}

final Map<String, World1MicroTaskPack>
kCampaignPacksV1 = _normalizeCampaignPacksMapV1(<String, World1MicroTaskPack>{
  'world1_act0_table_literacy': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find the Button seat.',
      hint: 'Dealer button is the bottom center seat.',
      expectedSeatIds: <String>['btn'],
      instructionText: 'Table map first: lock the dealer anchor.',
      goalText: 'Goal: tap Button to orient the table.',
      guidedScope: 'seats',
      isoGroup: 'world1_act0_table_literacy_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Now tap Small Blind.',
      hint: 'Small Blind is immediately left of Button.',
      expectedSeatIds: <String>['sb'],
      isoGroup: 'world1_act0_table_literacy_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Finish by tapping Big Blind.',
      hint: 'Big Blind is to the right of Small Blind.',
      expectedSeatIds: <String>['bb'],
      isoGroup: 'world1_act0_table_literacy_v1_g1',
    ),
  ],
  'world1_act0_action_literacy': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Button first in with KTs. Pick the clean action.',
      hint: 'Late position with no opener should start the hand cleanly.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      heroCards: <String>['Kh', 'Ts'],
      pot: 3,
      toCall: 2,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'raise',
      instructionText:
          'Action words should become a real choice, not another seat tap.',
      goalText: 'Goal: turn late position into the right first action.',
      guidedScope: 'actions',
      contextText: 'Button has the cleanest first-in seat at this short table.',
      tradeoffText:
          'Raise the clean opener now or waste the seat edge with a passive line.',
      consequenceText:
          'Correct: clean late-position raise starts the hand on your terms. Incorrect: passive action blurs the seat edge.',
      insightText:
          'Late position should feel proactive when the pot is still unopened.',
      isoGroup: 'world1_act0_action_literacy_v1_g1',
    ),
    MicroTaskStep(
      prompt:
          'Button opened first and hero is in the big blind with QJs. Pick the cleaner continue.',
      hint:
          'A playable defend should continue without turning into a loose raise.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      heroCards: <String>['Qh', 'Js'],
      pot: 7,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'call',
      contextText:
          'Pressure already reached you, but the hand is still playable.',
      tradeoffText: 'Call the defend now or overreact from out of position.',
      consequenceText:
          'Correct: big blind defend stayed compact. Incorrect: the response drifted away from the clean continue.',
      insightText:
          'When pressure reaches you, the clean answer can still be a call.',
      isoGroup: 'world1_act0_action_literacy_v1_g1',
    ),
    MicroTaskStep(
      prompt:
          'Small blind with J7o and only the big blind behind. Pick the disciplined action.',
      hint: 'Weak offsuit starts should not force a blind battle.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      heroCards: <String>['Jd', '7c'],
      pot: 2,
      toCall: 1,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'fold',
      contextText:
          'Out of position with a weak hand is not the same as a clean button start.',
      tradeoffText:
          'Fold the weak blind start now or donate chips from the worst seat.',
      consequenceText:
          'Correct: weak small-blind hand released cleanly. Incorrect: the blind seat was forced into a bad continue.',
      insightText:
          'Seat order matters most when the blind seat is weak and out of position.',
      isoGroup: 'world1_act0_action_literacy_v1_g1',
    ),
  ],
  'world1_act0_street_flow': <MicroTaskStep>[
    MicroTaskStep(
      prompt:
          'Flop on the button with KJ over K-7-2. Which action fits when nobody has bet?',
      hint: 'Top pair on a calm flop should use a simple value action.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Ks', '7d', '2c'],
      heroCards: <String>['Kh', 'Jd'],
      pot: 8,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'bet',
      instructionText:
          'Street flow should change the action family, not just the label on the screen.',
      goalText: 'Goal: read the street first, then choose the fitting action.',
      guidedScope: 'actions',
      contextText: 'The hand moved from preflop into a calm flop value spot.',
      tradeoffText:
          'Bet the value hand now or give up a clean flop action for free.',
      consequenceText:
          'Correct: flop value was taken while the street stayed calm. Incorrect: the street changed but the action clue was missed.',
      insightText:
          'Street names matter because the legal action family changes with them.',
      isoGroup: 'world1_act0_street_flow_v1_g1',
    ),
    MicroTaskStep(
      prompt:
          'Turn on the button with KJ over K-7-2-Q facing a small bet. Which action fits now?',
      hint:
          'Respect the turn price before turning a one-pair hand into a big raise.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Ks', '7d', '2c', 'Qh'],
      heroCards: <String>['Kh', 'Jd'],
      pot: 16,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'call',
      contextText:
          'The street changed and now there is a real price to manage.',
      tradeoffText:
          'Call the fair turn price now or overplay one pair into pressure.',
      consequenceText:
          'Correct: turn price stayed under control. Incorrect: the new street pressure was handled too aggressively.',
      insightText:
          'Street flow changes what “clean continue” means from one card to the next.',
      isoGroup: 'world1_act0_street_flow_v1_g1',
    ),
    MicroTaskStep(
      prompt:
          'River on the button with T8 over A-K-7-2-2 facing a bet. Which action fits now?',
      hint:
          'By the river, weak showdown value should not pay off just to be curious.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['As', 'Kd', '7c', '2h', '2d'],
      heroCards: <String>['Th', '8h'],
      pot: 20,
      toCall: 8,
      allowedActions: <String>['fold', 'call'],
      expectedActionKind: 'fold',
      contextText:
          'The hand reached the last street and the price is no longer cheap.',
      tradeoffText:
          'Fold the weak river bluff-catcher now or burn chips on a low-payoff call.',
      consequenceText:
          'Correct: weak river hand exited cleanly. Incorrect: the final street price was paid without enough value.',
      insightText:
          'The same table feels different once the street reaches its last decision.',
      isoGroup: 'world1_act0_street_flow_v1_g1',
    ),
  ],
  'intro_welcome': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find the Button seat.',
      hint: 'Look for the dealer spot at the bottom center.',
      expectedSeatIds: <String>['btn'],
      instructionText: 'Start by identifying the dealer anchor first.',
      goalText: 'Goal: lock table orientation before action.',
      guidedScope: 'seats',
      isoGroup: 'intro_welcome_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Find the Small Blind seat.',
      hint: 'Small Blind sits directly to the left of the Button.',
      expectedSeatIds: <String>['sb'],
      isoGroup: 'intro_welcome_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Find the Big Blind seat.',
      hint: 'Big Blind is immediately after Small Blind.',
      expectedSeatIds: <String>['bb'],
      isoGroup: 'intro_welcome_v1_g1',
    ),
  ],
  'intro_game_types': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find the Big Blind seat first.',
      hint: 'Tap the right-lower blind seat.',
      expectedSeatIds: <String>['bb'],
      instructionText: 'Use blind seats to anchor format quickly.',
      goalText: 'Goal: identify blinds before variants.',
      guidedScope: 'seats',
      isoGroup: 'intro_game_types_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Now find the Button seat.',
      hint: 'Dealer button is the bottom center seat.',
      expectedSeatIds: <String>['btn'],
      isoGroup: 'intro_game_types_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Skip empty UTG and tap next occupied seat.',
      hint: 'UTG is empty here, continue to Hijack.',
      expectedSeatIds: <String>['hj'],
      isoGroup: 'intro_game_types_v1_g1',
    ),
  ],
  'intro_actions': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Cutoff seat to begin action order.',
      hint: 'Cutoff is on the upper-left side.',
      expectedSeatIds: <String>['co'],
      instructionText: 'Anchor late-position seats before action names.',
      goalText: 'Goal: identify action order anchors.',
      guidedScope: 'seats',
      isoGroup: 'intro_actions_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Tap Button seat next in order.',
      hint: 'Button follows Cutoff preflop.',
      expectedSeatIds: <String>['btn'],
      isoGroup: 'intro_actions_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind after the Button.',
      hint: 'Small Blind is left of Button.',
      expectedSeatIds: <String>['sb'],
      isoGroup: 'intro_actions_v1_g1',
    ),
  ],
  'intro_hand_rankings': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button to anchor table position.',
      hint: 'Bottom center dealer seat.',
      expectedSeatIds: <String>['btn'],
      instructionText: 'Anchor one fixed seat before ranking drills.',
      goalText: 'Goal: keep orientation stable on table.',
      guidedScope: 'seats',
      isoGroup: 'intro_hand_rankings_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind for showdown order context.',
      hint: 'Big Blind is right-lower blind seat.',
      expectedSeatIds: <String>['bb'],
      isoGroup: 'intro_hand_rankings_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Skip empty seat and tap Hijack.',
      hint: 'Move to the next occupied seat, Hijack.',
      expectedSeatIds: <String>['hj'],
      isoGroup: 'intro_hand_rankings_v1_g1',
    ),
  ],
  'intro_how_to_win': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Small Blind to start the blind pair.',
      hint: 'Small Blind sits left of Button.',
      expectedSeatIds: <String>['sb'],
      instructionText: 'Use blind pair as first win orientation cue.',
      goalText: 'Goal: map blind sequence quickly.',
      guidedScope: 'seats',
      isoGroup: 'intro_how_to_win_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind to complete the pair.',
      hint: 'Big Blind is to the right of Small Blind.',
      expectedSeatIds: <String>['bb'],
      isoGroup: 'intro_how_to_win_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff for late-position pressure.',
      hint: 'Cutoff is upper-left at this table.',
      expectedSeatIds: <String>['co'],
      isoGroup: 'intro_how_to_win_v1_g1',
    ),
  ],
  'core_rules_and_setup': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find the dealer Button seat.',
      hint: 'Bottom center seat marks the dealer.',
      expectedSeatIds: <String>['btn'],
      instructionText: 'Start from dealer seat before setup rules.',
      goalText: 'Goal: establish setup anchor.',
      guidedScope: 'seats',
      isoGroup: 'core_rules_and_setup_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind for posting order.',
      hint: 'Small Blind posts first after the Button.',
      expectedSeatIds: <String>['sb'],
      isoGroup: 'core_rules_and_setup_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind for the second post.',
      hint: 'Big Blind posts after Small Blind.',
      expectedSeatIds: <String>['bb'],
      isoGroup: 'core_rules_and_setup_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Skip empty UTG and continue to Hijack.',
      hint: 'Ignore empty seats when counting.',
      expectedSeatIds: <String>['hj'],
      isoGroup: 'core_rules_and_setup_v1_g1',
    ),
  ],
  'tier_1_checkpoint': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Checkpoint: tap Button.',
      hint: 'Bottom center dealer seat.',
      expectedSeatIds: <String>['btn'],
      instructionText: 'Checkpoint seed: verify orientation anchor first.',
      goalText: 'Goal: prove baseline orientation is retained.',
      guidedScope: 'seats',
      isoGroup: 'tier_1_checkpoint_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint: tap Small Blind.',
      hint: 'Left of Button.',
      expectedSeatIds: <String>['sb'],
      isoGroup: 'tier_1_checkpoint_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint: tap Big Blind.',
      hint: 'Right of Small Blind.',
      expectedSeatIds: <String>['bb'],
      isoGroup: 'tier_1_checkpoint_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint: skip empty seat and tap Hijack.',
      hint: 'Continue counting only occupied seats.',
      expectedSeatIds: <String>['hj'],
      isoGroup: 'tier_1_checkpoint_v1_g1',
    ),
  ],
  'season1_checkpoint_global_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Checkpoint: Preflop in Button. To call 2 chips.',
      hint: 'Use one clean choice: fold weak, call medium, raise strong.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      heroCards: <String>['Ah', 'Qd'],
      pot: 3,
      toCall: 2,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'raise',
      instructionText: 'Checkpoint: verify the table map before continuing.',
      goalText: 'Goal: review top mistakes with short table decisions.',
      guidedScope: 'actions',
      contextText: 'Range class: open strong hands from late position.',
      tradeoffText: 'Raise now or leak value by taking a passive line.',
      consequenceText:
          'Correct: strong open captured value. Incorrect: value leaked.',
      insightText: 'Raise strong hands when price and position are clear.',
      isoGroup: 'season1_checkpoint_global_v1_ec_range',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint: tap Small Blind after Button.',
      hint: 'Small Blind is immediately left of Button.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Timing class: anchor first, then move one seat clockwise.',
      tradeoffText: 'Confirm order now or drift into blind confusion.',
      consequenceText:
          'Correct: order stayed stable. Incorrect: order drifted.',
      insightText: 'Button first, then Small Blind.',
      isoGroup: 'season1_checkpoint_global_v1_ec_timing',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint: Flop in Cutoff. Pot 12, to call 4.',
      hint: 'Pick a size-aware line from legal actions.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['As', '7d', '2c'],
      heroCards: <String>['Ad', 'Tc'],
      pot: 12,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'call',
      contextText: 'Sizing class: respect the current price before pressing.',
      tradeoffText: 'Call fair price now or overreact with a large move.',
      consequenceText:
          'Correct: price was respected. Incorrect: price was ignored.',
      insightText: 'When price is fair, calling can keep weaker hands in.',
      isoGroup: 'season1_checkpoint_global_v1_ec_sizing',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint: Preflop in Hijack. To call 2 chips.',
      hint: 'Weak offsuit hand here is usually a fold.',
      expectedSeatIds: <String>['hj'],
      heroSeatId: 'HJ',
      heroCards: <String>['9d', '4c'],
      pot: 3,
      toCall: 2,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'fold',
      contextText: 'Range class: do not defend weak hands for a full price.',
      tradeoffText: 'Fold now or donate chips with weak equity.',
      consequenceText:
          'Correct: weak hand folded. Incorrect: chips were donated.',
      insightText: 'Folding weak hands protects stack and decision quality.',
      isoGroup: 'season1_checkpoint_global_v1_ec_range',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint: skip one empty seat and tap Big Blind.',
      hint: 'Continue clockwise and ignore empty lanes.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Timing class: count occupied seats in strict order.',
      tradeoffText: 'Hold the clockwise count or click the wrong lane.',
      consequenceText: 'Correct: count stayed clean. Incorrect: count broke.',
      insightText: 'Clockwise order stays deterministic even with empties.',
      isoGroup: 'season1_checkpoint_global_v1_ec_timing',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint: Turn in Button. Pot 18, to call 6.',
      hint: 'Use legal actions and avoid over-sizing pressure spots.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Ks', '9h', '3d', '2c'],
      heroCards: <String>['Kd', 'Jd'],
      pot: 18,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'call',
      contextText:
          'Sizing class: call when price and hand strength still align.',
      tradeoffText: 'Call the fair turn price or overplay with a large raise.',
      consequenceText:
          'Correct: turn price was managed. Incorrect: sizing drifted.',
      insightText: 'Price control keeps the line stable on later streets.',
      isoGroup: 'season1_checkpoint_global_v1_ec_sizing',
    ),
  ],
  // Deprecated in v2 routing; kept for backward compatibility.
  'season1_checkpoint_w1_3_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Checkpoint W1-3: tap Button.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      instructionText:
          'Checkpoint: prove the same seat map is stable enough to start every hand in the right order.',
      goalText:
          'Goal: keep Button, blinds, and late seats clear before the next chapter.',
      guidedScope: 'seats',
      isoGroup: 'season1_checkpoint_w1_3_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W1-3: tap Small Blind.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      isoGroup: 'season1_checkpoint_w1_3_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W1-3: tap Big Blind.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      isoGroup: 'season1_checkpoint_w1_3_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W1-3: tap Cutoff.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      isoGroup: 'season1_checkpoint_w1_3_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W1-3: tap Hijack.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      isoGroup: 'season1_checkpoint_w1_3_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W1-3: tap Button again.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      isoGroup: 'season1_checkpoint_w1_3_v1_g2',
    ),
  ],
  'season1_checkpoint_w4_6_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Checkpoint W4-6: tap Cutoff.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      instructionText:
          'Checkpoint: keep the same seat map stable while action purpose and board pressure get richer.',
      goalText:
          'Goal: hold the seat map steady while later decisions get more layered.',
      guidedScope: 'seats',
      isoGroup: 'season1_checkpoint_w4_6_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W4-6: tap Button.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      isoGroup: 'season1_checkpoint_w4_6_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W4-6: tap Hijack.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      isoGroup: 'season1_checkpoint_w4_6_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W4-6: tap Small Blind.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      isoGroup: 'season1_checkpoint_w4_6_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W4-6: tap Big Blind.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      isoGroup: 'season1_checkpoint_w4_6_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W4-6: tap Cutoff again.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      isoGroup: 'season1_checkpoint_w4_6_v1_g2',
    ),
  ],
  'season1_checkpoint_w7_10_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Checkpoint W7-10: tap Hijack.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      instructionText:
          'Checkpoint: keep the same seat map stable while stack pressure, tournament pressure, and track context change.',
      goalText:
          'Goal: preserve the table map so later-world decisions still start from the right seat.',
      guidedScope: 'seats',
      isoGroup: 'season1_checkpoint_w7_10_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W7-10: tap Cutoff.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      isoGroup: 'season1_checkpoint_w7_10_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W7-10: tap Button.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      isoGroup: 'season1_checkpoint_w7_10_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W7-10: tap Big Blind.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      isoGroup: 'season1_checkpoint_w7_10_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W7-10: tap Small Blind.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      isoGroup: 'season1_checkpoint_w7_10_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'Checkpoint W7-10: tap Hijack again.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      isoGroup: 'season1_checkpoint_w7_10_v1_g2',
    ),
  ],
  'season1_demo_multistreet_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Demo flop spot. Hero in CO.',
      hint: 'Read the board and action context.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['As', 'Kd', '7h'],
      heroCards: <String>['Qh', 'Qs'],
      pot: 12,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise'],
      isoGroup: 'season1_demo_multistreet_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Demo turn spot. Hero in SB.',
      hint: 'Turn card is added. Context is deterministic.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['As', 'Kd', '7h', '2c'],
      heroCards: <String>['9d', '9s'],
      pot: 20,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      isoGroup: 'season1_demo_multistreet_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'Demo river spot. Hero in BB.',
      hint: 'River board complete. Context stays fixed.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['As', 'Kd', '7h', '2c', '2d'],
      heroCards: <String>['Ah', 'Jc'],
      pot: 28,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise'],
      isoGroup: 'season1_demo_multistreet_v1_g2',
    ),
  ],
  'world1_streets_demo_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'CO on flop. Choose action.',
      hint: 'Use board and action context.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Ah', '7d', '2c'],
      heroCards: <String>['Kd', 'Qd'],
      pot: 10,
      toCall: 2,
      allowedActions: <String>['fold', 'call', 'raise'],
      isoGroup: 'world1_streets_demo_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'SB on turn. Choose action.',
      hint: 'Turn card is visible.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Ah', '7d', '2c', '9s'],
      heroCards: <String>['8h', '8c'],
      pot: 18,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      isoGroup: 'world1_streets_demo_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'BB on river. Choose action.',
      hint: 'River board is complete.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Ah', '7d', '2c', '9s', '9d'],
      heroCards: <String>['As', 'Tc'],
      pot: 26,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      isoGroup: 'world1_streets_demo_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'HJ on flop. Choose action.',
      hint: 'Flop board only.',
      expectedSeatIds: <String>['hj'],
      heroSeatId: 'HJ',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Ks', 'Jc', '4h'],
      heroCards: <String>['Qh', 'Th'],
      pot: 14,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise'],
      isoGroup: 'world1_streets_demo_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'BTN on turn. Choose action.',
      hint: 'Turn card updates the board.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Ks', 'Jc', '4h', '2d'],
      heroCards: <String>['Ad', 'Qc'],
      pot: 22,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      isoGroup: 'world1_streets_demo_v1_g3',
    ),
  ],
  'world2_streets_demo_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'UTG on flop. Choose action.',
      hint: 'Read the flop and chips.',
      expectedSeatIds: <String>['utg'],
      heroSeatId: 'UTG',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Qs', '8s', '3d'],
      heroCards: <String>['As', 'Kd'],
      pot: 12,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise'],
      isoGroup: 'world2_streets_demo_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'CO on turn. Choose action.',
      hint: 'Turn card is added.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Qs', '8s', '3d', '2h'],
      heroCards: <String>['Qd', 'Jd'],
      pot: 20,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      isoGroup: 'world2_streets_demo_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'SB on river. Choose action.',
      hint: 'River board complete.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Qs', '8s', '3d', '2h', '2s'],
      heroCards: <String>['9c', '9h'],
      pot: 30,
      toCall: 8,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      isoGroup: 'world2_streets_demo_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'HJ on flop. Choose action.',
      hint: 'Use the flop texture.',
      expectedSeatIds: <String>['hj'],
      heroSeatId: 'HJ',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Tc', '7c', '5d'],
      heroCards: <String>['Ac', 'Jc'],
      pot: 16,
      toCall: 5,
      allowedActions: <String>['fold', 'call', 'raise'],
      isoGroup: 'world2_streets_demo_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'BB on turn. Choose action.',
      hint: 'Turn card changes context.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Tc', '7c', '5d', 'Kh'],
      heroCards: <String>['Kc', 'Td'],
      pot: 24,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      isoGroup: 'world2_streets_demo_v1_g3',
    ),
  ],
  'world3_streets_demo_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'BTN on flop. Choose action.',
      hint: 'Flop board and chips are fixed.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Jh', '9h', '4c'],
      heroCards: <String>['Ah', 'Qh'],
      pot: 14,
      toCall: 3,
      allowedActions: <String>['fold', 'call', 'raise'],
      isoGroup: 'world3_streets_demo_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'CO on river. Choose action.',
      hint: 'River board is complete.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Jh', '9h', '4c', '4d', '2s'],
      heroCards: <String>['Js', 'Tc'],
      pot: 34,
      toCall: 10,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      isoGroup: 'world3_streets_demo_v1_g1',
    ),
    MicroTaskStep(
      prompt: 'SB on turn. Choose action.',
      hint: 'Turn card is visible.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['8d', '8c', '3h', 'Kc'],
      heroCards: <String>['Ad', '8h'],
      pot: 22,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      isoGroup: 'world3_streets_demo_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'UTG on flop. Choose action.',
      hint: 'Use the flop board.',
      expectedSeatIds: <String>['utg'],
      heroSeatId: 'UTG',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Kd', '6s', '2h'],
      heroCards: <String>['Qc', 'Qd'],
      pot: 12,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise'],
      isoGroup: 'world3_streets_demo_v1_g2',
    ),
    MicroTaskStep(
      prompt: 'BB on river. Choose action.',
      hint: 'River card is visible.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Kd', '6s', '2h', '2c', '9d'],
      heroCards: <String>['Kh', '5h'],
      pot: 32,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      isoGroup: 'world3_streets_demo_v1_g3',
    ),
  ],
  'world1_spine_campaign_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Preflop in Button. To call 2 chips.',
      hint: 'Start simple: fold weak, call playable, raise strong.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      heroCards: <String>['Ah', 'Qd'],
      pot: 3,
      toCall: 2,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'raise',
      contextText:
          'First rep introduces action choice with clear to-call value.',
      tradeoffText: 'Pick a clear action now, or leak chips by guessing.',
      consequenceText: 'Clear preflop open: +8 chips. Guess leak: -6 chips.',
      insightText: 'Read to-call first, then choose action.',
    ),
    MicroTaskStep(
      prompt: 'Preflop in Small Blind. To call 1 chip.',
      hint: 'Use the same action set; keep the decision clean.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      heroCards: <String>['Ks', 'Js'],
      pot: 3,
      toCall: 1,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'call',
      contextText: 'Second rep repeats preflop action with a new seat.',
      tradeoffText: 'Apply the same process, or drift between seats.',
      consequenceText: 'Process held: +8 chips. Process drift: -6 chips.',
      insightText: 'Same process across seats keeps decisions stable.',
    ),
    MicroTaskStep(
      prompt: 'Preflop in Big Blind. Pot 3, check or raise.',
      hint:
          'In blind-vs-blind with zero toCall, legal actions are check or raise.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      heroCards: <String>['Qh', '9h'],
      pot: 3,
      toCall: 0,
      allowedActions: <String>['check', 'raise'],
      expectedActionKind: 'raise',
      contextText:
          'This preflop rep anchors the zero-cost action grammar early.',
      tradeoffText:
          'Take free action structure, or force an illegal call path.',
      consequenceText: 'Zero-cost read: +8 chips. Forced line miss: -6 chips.',
      insightText: 'Preflop with toCall 0 starts from check or raise.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Cutoff. Pot 12, to call 4.',
      hint: 'Flop has 3 board cards. Use them before acting.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['As', '7d', '2c'],
      heroCards: <String>['Ad', 'Tc'],
      pot: 12,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'call',
      contextText: 'Street ladder starts here: flop adds board context.',
      tradeoffText: 'Use board + chips, or click without context.',
      consequenceText: 'Flop read correct: +8 chips. Flop miss: -6 chips.',
      insightText: 'On flop, combine board and to-call before acting.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Big Blind. Pot 10, check or bet.',
      hint: 'When toCall is 0, the legal actions are check or bet.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Kd', '8c', '3h'],
      heroCards: <String>['Kc', '9d'],
      pot: 10,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'bet',
      contextText: 'Second flop rep reinforces zero to-call action shape.',
      tradeoffText: 'Take the free option structure, or force wrong action.',
      consequenceText: 'Zero-cost line: +8 chips. Forced error: -6 chips.',
      insightText: 'If to-call is zero, decision starts from check/bet.',
    ),
    MicroTaskStep(
      prompt: 'Turn in Hijack. Pot 20, to call 5.',
      hint: 'Turn has 4 board cards; keep actions deterministic.',
      expectedSeatIds: <String>['hj'],
      heroSeatId: 'HJ',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Qs', '8s', '3d', '2h'],
      heroCards: <String>['Qd', 'Jd'],
      pot: 20,
      toCall: 5,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'raise',
      contextText: 'Turn rep increases pressure with one card to come.',
      tradeoffText: 'Respect turn pressure, or overreact without reason.',
      consequenceText: 'Turn pressure handled: +8 chips. Turn panic: -6 chips.',
      insightText: 'Turn narrows time and widens mistake cost.',
    ),
    MicroTaskStep(
      prompt: 'Turn in Button. Pot 22, check or bet.',
      hint: 'Turn with zero toCall keeps check/bet only.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Ts', '7c', '5d', 'Kh'],
      heroCards: <String>['Kc', 'Td'],
      pot: 22,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'check',
      contextText:
          'This turn rep mirrors flop zero-cost logic on later street.',
      tradeoffText: 'Use consistent shape, or invent unavailable actions.',
      consequenceText: 'Turn shape held: +8 chips. Shape break: -6 chips.',
      insightText: 'Street changes, but legal action set still matters first.',
    ),
    MicroTaskStep(
      prompt: 'River in Cutoff. Pot 30, to call 8.',
      hint: 'River is final street: no cards left to come.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Jh', '9h', '4c', '4d', '2s'],
      heroCards: <String>['Js', 'Tc'],
      pot: 30,
      toCall: 8,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'raise_to',
      contextText: 'River rep closes the street ladder with final decision.',
      tradeoffText:
          'Treat river as final, or plan for cards that do not exist.',
      consequenceText:
          'River finality read: +8 chips. River fantasy: -6 chips.',
      insightText: 'On river, action is final for this hand.',
    ),
    MicroTaskStep(
      prompt: 'River in Big Blind. Pot 28, to call 6.',
      hint: 'Keep the same deterministic action set on river.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['As', 'Kd', '7h', '2c', '2d'],
      heroCards: <String>['Ah', 'Jc'],
      pot: 28,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'call',
      contextText:
          'Second river rep builds confidence under final-street pressure.',
      tradeoffText: 'Stay in the legal set, or click outside constraints.',
      consequenceText: 'River discipline: +8 chips. River leak: -6 chips.',
      insightText: 'Discipline is highest on final street decisions.',
    ),
    MicroTaskStep(
      prompt: 'River in Button. Pot 26, to call 6.',
      hint: 'River is final: no more cards, only this decision remains.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Qc', '9d', '6h', '2c', '2d'],
      heroCards: <String>['Ac', 'Jc'],
      pot: 26,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'fold',
      contextText:
          'Late river rep adds one more final-street pressure decision.',
      tradeoffText: 'Use final-street legal set, or click outside constraints.',
      consequenceText:
          'River discipline: +8 chips. Constraint break: -6 chips.',
      insightText: 'Final street decisions stay inside fold/call/raise_to.',
    ),
    MicroTaskStep(
      prompt: 'River in Small Blind. Pot 24, to call 4.',
      hint: 'River keeps the same legal choices: fold, call, or raise.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Tc', '7c', '5d', 'Kh', '2s'],
      heroCards: <String>['Ac', 'Qc'],
      pot: 24,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'raise_to',
      contextText: 'Penultimate rep keeps chip pressure on the final street.',
      tradeoffText: 'Take legal final options, or invent unavailable actions.',
      consequenceText: 'Final-street process: +8 chips. Action leak: -6 chips.',
      insightText: 'River pressure is handled with the same legal grammar.',
    ),
    MicroTaskStep(
      prompt: 'River in Big Blind. Pot 26, check or bet.',
      hint: 'Final rep: toCall 0 still means check or bet only.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['8d', '8c', '3h', 'Kc', '2h'],
      heroCards: <String>['Ad', '8h'],
      pot: 26,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'check',
      contextText: 'Final rep closes the run with a zero-cost river decision.',
      tradeoffText:
          'Finish with legal check/bet, or force a non-existent call.',
      consequenceText: 'Clean close: +8 chips. Final-step break: -6 chips.',
      insightText: 'World 1 goal: consistent action decisions across streets.',
    ),
  ],
  // Difficulty ladder rules:
  // b0: zero jargon, short lines, obvious targets, forgiving consequences.
  'world1_spine_followup_v1_b0': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Button preflop. Pot 3, to call 2.',
      hint: 'Keep it simple: fold, call, or raise.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      heroCards: <String>['Qh', 'Js'],
      pot: 3,
      toCall: 2,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'call',
      contextText: 'Safe reset hand: one clear seat, one clear decision.',
      tradeoffText: 'Take the clear anchor, or start the run in noise.',
      consequenceText: 'Calm open: +8 chips. Noisy open: -6 chips.',
      insightText: 'Next time: pick the obvious anchor first.',
    ),
    MicroTaskStep(
      prompt: 'Small Blind preflop. Pot 3, to call 1.',
      hint: 'Stay disciplined with blind decisions.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      heroCards: <String>['7c', '6c'],
      pot: 3,
      toCall: 1,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'fold',
      contextText: 'Discipline beat: blind order makes pressure manageable.',
      tradeoffText: 'Confirm order now, or pay for guessing.',
      consequenceText: 'Discipline win: +8 chips. Guess tax: -6 chips.',
      insightText: 'Next time: lock blinds before pressure starts.',
    ),
    MicroTaskStep(
      prompt: 'Big Blind preflop. Pot 3, check or raise.',
      hint: 'When toCall is 0, start from check or raise.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      heroCards: <String>['Ad', '9d'],
      pot: 3,
      toCall: 0,
      allowedActions: <String>['check', 'raise'],
      expectedActionKind: 'raise',
      contextText: 'Save beat: complete the map before tempo rises.',
      tradeoffText: 'Finish map now, or panic into a leak.',
      consequenceText: 'Map complete: +8 chips. Panic leak: -6 chips.',
      insightText: 'Next time: finish BB anchor, then react.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Cutoff. Pot 10, check or bet.',
      hint: 'Flop shows 3 cards before action.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Kd', '7s', '2c'],
      heroCards: <String>['Kh', 'Qc'],
      pot: 10,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'check',
      contextText: 'Trap avoided beat: empty seats bait rushed clicks.',
      tradeoffText: 'Skip the trap, or break the order.',
      consequenceText: 'Trap avoided: +8 chips. Order break: -6 chips.',
      insightText: 'Next time: count occupied seats only.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Hijack. Pot 14, to call 4.',
      hint: 'Use fold/call/raise when chips are owed.',
      expectedSeatIds: <String>['hj'],
      heroSeatId: 'HJ',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['9h', '8d', '3s'],
      heroCards: <String>['As', 'Td'],
      pot: 14,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'call',
      contextText: 'Value beat: simple close still earns chips.',
      tradeoffText: 'Stay clean, or rush and leak.',
      consequenceText: 'Value close: +8 chips. Rush leak: -6 chips.',
      insightText: 'Next time: close easy runs slowly and cleanly.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Big Blind. Pot 16, to call 5.',
      hint: 'Pressure spot: fold, call, or raise_to.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Qd', '6c', '4h'],
      heroCards: <String>['Jd', 'Jc'],
      pot: 16,
      toCall: 5,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'raise_to',
      contextText: 'Pressure beat: late seat gives low-risk initiative.',
      tradeoffText: 'Use initiative now, or lose small edges.',
      consequenceText: 'Initiative gain: +8 chips. Passive slip: -6 chips.',
      insightText: 'Next time: use late position for simple pressure.',
    ),
    MicroTaskStep(
      prompt: 'Turn in Button. Pot 22, check or bet.',
      hint: 'Turn has 4 board cards.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Ts', '7h', '2d', 'Kc'],
      heroCards: <String>['Ac', 'Th'],
      pot: 22,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'bet',
      contextText: 'Composure beat: reset before mistakes stack.',
      tradeoffText: 'Reset now, or drift into errors.',
      consequenceText: 'Composure hold: +8 chips. Drift stack: -6 chips.',
      insightText: 'Next time: reset on Button after pressure hands.',
    ),
    MicroTaskStep(
      prompt: 'Turn in Small Blind. Pot 24, to call 6.',
      hint: 'No check when toCall is positive.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Ad', '9c', '5s', '5d'],
      heroCards: <String>['Ks', 'Qs'],
      pot: 24,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'fold',
      contextText: 'Save beat: a good fold here saves chips fast.',
      tradeoffText: 'Take the safe read, or burn chips from confusion.',
      consequenceText: 'Chips saved: +8 chips. Burned chips: -6 chips.',
      insightText: 'Next time: blind identity first, action second.',
    ),
    MicroTaskStep(
      prompt: 'River in Cutoff. Pot 30, to call 8.',
      hint: 'Final street keeps fold/call/raise_to.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Jh', '8h', '4c', '4d', '2s'],
      heroCards: <String>['Jc', '9c'],
      pot: 30,
      toCall: 8,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'call',
      contextText: 'Punish greed beat: fast overcalls get punished.',
      tradeoffText: 'Stay basic, or chase and pay.',
      consequenceText: 'Greed punished: +8 chips. Chase tax: -6 chips.',
      insightText: 'Next time: speed only after target is clear.',
    ),
    MicroTaskStep(
      prompt: 'River in Big Blind. Pot 28, to call 6.',
      hint: 'Keep call/fold available and avoid check.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['As', 'Kd', '7c', '3d', '3h'],
      heroCards: <String>['Ah', 'Tc'],
      pot: 28,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'fold',
      contextText: 'Closure beat: one final order check.',
      tradeoffText: 'Count cleanly, or break sequence under no pressure.',
      consequenceText: 'Sequence held: +8 chips. Sequence break: -6 chips.',
      insightText: 'Next time: finish with occupied-seat discipline.',
    ),
    MicroTaskStep(
      prompt: 'River in Button. Pot 26, to call 6.',
      hint: 'Raise_to is legal with positive toCall.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Qc', '9d', '6h', '2c', '2d'],
      heroCards: <String>['Ac', 'Jc'],
      pot: 26,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'raise_to',
      contextText: 'Discipline rewarded beat: repeat good process.',
      tradeoffText: 'Repeat process, or invent risk.',
      consequenceText: 'Process reward: +8 chips. Invented risk: -6 chips.',
      insightText: 'Next time: boring discipline keeps bankroll stable.',
    ),
    MicroTaskStep(
      prompt: 'River in Small Blind. Pot 26, check or bet.',
      hint: 'Zero toCall means check/bet only.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['8d', '8c', '3h', 'Kc', '2h'],
      heroCards: <String>['Ad', '7d'],
      pot: 26,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'check',
      contextText: 'Final hand: simple certainty beats flashy clicks.',
      tradeoffText: 'Take certainty now, or donate at the finish.',
      consequenceText: 'Confident finish: +8 chips. Finish donation: -6 chips.',
      insightText: 'Next time: simple certainty closes sessions well.',
    ),
  ],
  // b1: introduce one new concept every ~3 hands, still table-first.
  'world1_spine_followup_v1_b1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Cutoff preflop. Pot 3, to call 2.',
      hint: 'Start with fold/call/raise.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      heroCards: <String>['Ah', 'Td'],
      pot: 3,
      toCall: 2,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'raise',
      contextText: 'B1 focuses on clean seat order under repeated transitions.',
      tradeoffText: 'Name late seat now, or drift in order.',
      consequenceText: 'Late seat correct: +8 chips. Drift: -6 chips.',
      insightText: 'Start each set with a clear seat label.',
    ),
    MicroTaskStep(
      prompt: 'Button preflop. Pot 4, to call 2.',
      hint: 'Positive toCall removes CHECK.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      heroCards: <String>['Kc', 'Qc'],
      pot: 4,
      toCall: 2,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'call',
      contextText: 'Anchor refresh prevents sequence errors after rotation.',
      tradeoffText: 'Refresh anchor now, or guess next seats.',
      consequenceText: 'Refresh correct: +8 chips. Guess miss: -6 chips.',
      insightText: 'Anchor refresh keeps order stable.',
    ),
    MicroTaskStep(
      prompt: 'Big Blind preflop. Pot 4, check or raise.',
      hint: 'toCall 0 gives check/raise only.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      heroCards: <String>['9s', '8s'],
      pot: 4,
      toCall: 0,
      allowedActions: <String>['check', 'raise'],
      expectedActionKind: 'raise',
      contextText: 'Blind-side checks confirm left-right orientation.',
      tradeoffText: 'Verify blind side now, or invert blinds.',
      consequenceText: 'Blind side correct: +8 chips. Inversion: -6 chips.',
      insightText: 'Blind orientation should never flip.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Hijack. Pot 12, to call 3.',
      hint: 'Flop uses exactly 3 board cards.',
      expectedSeatIds: <String>['hj'],
      heroSeatId: 'HJ',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['As', '7d', '2c'],
      heroCards: <String>['Ad', 'Tc'],
      pot: 12,
      toCall: 3,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'call',
      contextText: 'This step checks occupancy-aware ordering.',
      tradeoffText: 'Adapt to occupancy now, or click missing seat.',
      consequenceText:
          'Adaptation pass: +8 chips. Missing-seat click: -6 chips.',
      insightText: 'Occupancy changes order, not labels.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Small Blind. Pot 10, check or bet.',
      hint: 'No call when toCall is 0.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Kd', '8c', '3h'],
      heroCards: <String>['Kc', '9d'],
      pot: 10,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'check',
      contextText: 'Blind identity should stay accurate under repetition.',
      tradeoffText: 'Confirm identity, or misclick by habit.',
      consequenceText: 'Identity correct: +8 chips. Habit miss: -6 chips.',
      insightText: 'SB checks prevent blind-order drift.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Button. Pot 18, to call 5.',
      hint: 'Pressure spot includes raise_to.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Qh', '9c', '4d'],
      heroCards: <String>['Qs', 'Jd'],
      pot: 18,
      toCall: 5,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'raise_to',
      contextText: 'Cycle close checks if anchor remains consistent.',
      tradeoffText: 'Close on anchor, or finish on stale order.',
      consequenceText: 'Cycle close pass: +8 chips. Stale close: -6 chips.',
      insightText: 'Cycle closes should return to BTN.',
    ),
    MicroTaskStep(
      prompt: 'Turn in Cutoff. Pot 22, to call 6.',
      hint: 'Turn has 4 board cards and no CHECK here.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Ts', '7c', '5d', 'Kh'],
      heroCards: <String>['Kc', 'Td'],
      pot: 22,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'fold',
      contextText: 'Second cycle should keep same late-seat mapping.',
      tradeoffText: 'Carry mapping forward, or reset incorrectly.',
      consequenceText: 'Mapping held: +8 chips. Reset miss: -6 chips.',
      insightText: 'Late seats should remain stable across cycles.',
    ),
    MicroTaskStep(
      prompt: 'Turn in Button. Pot 20, check or bet.',
      hint: 'Zero toCall keeps check/bet.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['8s', '6d', '2h', 'Qc'],
      heroCards: <String>['Qd', '8h'],
      pot: 20,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'bet',
      contextText: 'Re-anchoring between cycles reduces blind confusion.',
      tradeoffText: 'Re-anchor now, or miss blind sequence.',
      consequenceText: 'Re-anchor pass: +8 chips. Blind miss: -6 chips.',
      insightText: 'Re-anchor before each blind check.',
    ),
    MicroTaskStep(
      prompt: 'River in Small Blind. Pot 32, to call 8.',
      hint: 'Final street: fold/call/raise_to only.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Jh', '9h', '4c', '4d', '2s'],
      heroCards: <String>['Js', 'Tc'],
      pot: 32,
      toCall: 8,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'call',
      contextText: 'This checks immediate transition from BTN to SB.',
      tradeoffText: 'Follow transition now, or skip to wrong seat.',
      consequenceText: 'Transition correct: +8 chips. Skip error: -6 chips.',
      insightText: 'BTN -> SB transition should be automatic.',
    ),
    MicroTaskStep(
      prompt: 'River in Big Blind. Pot 30, to call 7.',
      hint: 'Keep call/fold and remove CHECK.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Ah', 'Kd', '7h', '2c', '2d'],
      heroCards: <String>['Ac', 'Jc'],
      pot: 30,
      toCall: 7,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'raise_to',
      contextText: 'Blind pair completion should stay exact late in set.',
      tradeoffText: 'Complete pair now, or mislabel BB.',
      consequenceText: 'Pair completion: +8 chips. BB miss: -6 chips.',
      insightText: 'SB then BB remains fixed.',
    ),
    MicroTaskStep(
      prompt: 'River in Button. Pot 28, to call 6.',
      hint: 'Choose among fold/call/raise_to.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Tc', '7c', '5d', 'Kh', '2s'],
      heroCards: <String>['Ac', 'Qc'],
      pot: 28,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'fold',
      contextText: 'Penultimate step checks anchor consistency at end.',
      tradeoffText: 'Reset anchor now, or finish on stale map.',
      consequenceText: 'Anchor reset: +8 chips. Stale map: -6 chips.',
      insightText: 'Late-hand anchor checks reduce last-step errors.',
    ),
    MicroTaskStep(
      prompt: 'River in Small Blind. Pot 24, check or bet.',
      hint: 'Close with zero toCall discipline.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['9d', '6s', '3c', '3h', 'Kd'],
      heroCards: <String>['Qh', '9h'],
      pot: 24,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'check',
      contextText: 'Final step validates order accuracy under repetition.',
      tradeoffText: 'Finish in order, or end with a basic miss.',
      consequenceText: 'Ordered close: +8 chips. Final miss: -6 chips.',
      insightText: 'B1 goal: stable order through repeated cycles.',
    ),
  ],
  // b2: tighter tradeoffs, ambiguity, stronger consequence language.
  'world1_spine_followup_v1_b2': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Big Blind preflop. Pot 3, to call 2.',
      hint: 'Start with fold/call/raise pressure.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      heroCards: <String>['Ah', 'Qh'],
      pot: 3,
      toCall: 2,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'raise',
      contextText: 'Advanced spot: catch a bluff only from the right seat.',
      tradeoffText: 'Read node first, or call and burn chips.',
      consequenceText: 'Bluff catch: +8 chips. Bad catch: -6 chips.',
      insightText: 'Next time: bluff catches need the correct node first.',
    ),
    MicroTaskStep(
      prompt: 'Cutoff preflop. Pot 3, to call 2.',
      hint: 'Stay in fold/call/raise set.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      heroCards: <String>['Ks', 'Ts'],
      pot: 3,
      toCall: 2,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'fold',
      contextText: 'Advanced pressure lane opens from Cutoff.',
      tradeoffText: 'Take the lane now or surrender control.',
      consequenceText: 'Lane used: +8 chips. Control lost: -6 chips.',
      insightText: 'Next time: launch pressure from Cutoff lanes.',
    ),
    MicroTaskStep(
      prompt: 'Button preflop. Pot 3, check or raise.',
      hint: 'toCall 0 gives check/raise only.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      heroCards: <String>['9d', '7d'],
      pot: 3,
      toCall: 0,
      allowedActions: <String>['check', 'raise'],
      expectedActionKind: 'raise',
      contextText: 'River decisions are thin and need exact position.',
      tradeoffText: 'Anchor now or turn a thin call into a punt.',
      consequenceText: 'River clarity: +8 chips. River punt: -6 chips.',
      insightText: 'Next time: position check before every river call.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Hijack. Pot 14, to call 4.',
      hint: 'Flop has exactly 3 board cards.',
      expectedSeatIds: <String>['hj'],
      heroSeatId: 'HJ',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Ad', '8c', '2h'],
      heroCards: <String>['Ac', 'Td'],
      pot: 14,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise'],
      expectedActionKind: 'call',
      contextText: 'Advanced lines still break on basic order errors.',
      tradeoffText: 'Keep precision or drop your edge instantly.',
      consequenceText: 'Precision held: +8 chips. Edge drop: -6 chips.',
      insightText: 'Next time: precision beats speed under pressure.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Small Blind. Pot 12, check or bet.',
      hint: 'Zero toCall: no fold/call.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Kc', '9h', '4s'],
      heroCards: <String>['Kd', 'Jd'],
      pot: 12,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'check',
      contextText: 'Squeeze means re-raise with pressure from leverage.',
      tradeoffText: 'Use real leverage or over-bluff and pay.',
      consequenceText: 'Leverage used: +8 chips. Over-bluff: -6 chips.',
      insightText: 'Next time: squeeze only when leverage is real.',
    ),
    MicroTaskStep(
      prompt: 'Flop in Big Blind. Pot 20, to call 6.',
      hint: 'Use fold/call/raise_to under pressure.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Qh', '7s', '5c'],
      heroCards: <String>['Qs', 'Th'],
      pot: 20,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'raise_to',
      contextText: 'Repeat the high-value bluff-catch node with discipline.',
      tradeoffText: 'Stay disciplined or lose edge on one lazy click.',
      consequenceText: 'Edge repeat: +8 chips. Edge punt: -6 chips.',
      insightText: 'Next time: edge comes from disciplined repetition.',
    ),
    MicroTaskStep(
      prompt: 'Turn in Hijack. Pot 24, to call 7.',
      hint: 'Turn shows 4 board cards.',
      expectedSeatIds: <String>['hj'],
      heroSeatId: 'HJ',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Js', '8d', '3c', '2h'],
      heroCards: <String>['Jd', 'Tc'],
      pot: 24,
      toCall: 7,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'call',
      contextText: 'Mixed occupancy creates close, thin value choices.',
      tradeoffText: 'Get seat order wrong and miss the value line.',
      consequenceText: 'Thin value: +8 chips. Value miss: -6 chips.',
      insightText: 'Next time: thin value starts with exact seat order.',
    ),
    MicroTaskStep(
      prompt: 'Turn in Button. Pot 22, check or bet.',
      hint: 'No CALL when toCall is zero.',
      expectedSeatIds: <String>['btn'],
      heroSeatId: 'BTN',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Ts', '6h', '4d', 'Kh'],
      heroCards: <String>['As', 'Tc'],
      pot: 22,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'bet',
      contextText: 'River pressure spot where call and fold both look close.',
      tradeoffText: 'Anchor now or convert pressure into a hero punt.',
      consequenceText: 'Pressure solved: +8 chips. Hero punt: -6 chips.',
      insightText: 'Next time: certainty first, then thin river decision.',
    ),
    MicroTaskStep(
      prompt: 'River in Cutoff. Pot 34, to call 9.',
      hint: 'River keeps fold/call/raise_to.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Ah', 'Jh', '6c', '6d', '2s'],
      heroCards: <String>['Ac', 'Qd'],
      pot: 34,
      toCall: 9,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'fold',
      contextText: 'Advanced spot: attack only when villain range is capped.',
      tradeoffText: 'Pick wrong lane and pressure turns into spew.',
      consequenceText: 'Lane attack: +8 chips. Spew lane: -6 chips.',
      insightText: 'Next time: attack capped ranges, skip unclear lanes.',
    ),
    MicroTaskStep(
      prompt: 'River in Small Blind. Pot 32, to call 8.',
      hint: 'Positive toCall: include CALL and FOLD.',
      expectedSeatIds: <String>['sb'],
      heroSeatId: 'SB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Kc', 'Td', '7h', '3c', '3d'],
      heroCards: <String>['Kh', 'Jc'],
      pot: 32,
      toCall: 8,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'call',
      contextText: 'Final advanced node: leverage exists but margin is thin.',
      tradeoffText: 'Use squeeze too often and variance explodes.',
      consequenceText: 'Discipline close: +8 chips. Variance spike: -6 chips.',
      insightText: 'Next time: strong lines still need frequency discipline.',
    ),
    MicroTaskStep(
      prompt: 'River in Big Blind. Pot 30, to call 7.',
      hint: 'Raise_to remains legal with pressure.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['Qd', '9c', '5h', '2c', '2d'],
      heroCards: <String>['Qs', 'Jd'],
      pot: 30,
      toCall: 7,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'raise_to',
      contextText: 'Advanced save beat: overcalls look cheap but stack losses.',
      tradeoffText: 'Fold disciplined now, or overcall into burn.',
      consequenceText: 'Overcall avoided: +8 chips. Overcall burn: -6 chips.',
      insightText: 'Next time: disciplined folds protect deep-run bankroll.',
    ),
    MicroTaskStep(
      prompt: 'River in Cutoff. Pot 26, check or bet.',
      hint: 'Close with clean zero-toCall action set.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.river,
      boardCards: <String>['9s', '8c', '4h', '4d', 'Ad'],
      heroCards: <String>['Kd', '9d'],
      pot: 26,
      toCall: 0,
      allowedActions: <String>['check', 'bet'],
      expectedActionKind: 'check',
      contextText: 'Resolution beat: pressure with control, not ego.',
      tradeoffText: 'Apply pressure in lane, or spew from emotion.',
      consequenceText:
          'Controlled pressure: +8 chips. Emotional spew: -6 chips.',
      insightText: 'Next time: control first, pressure second.',
    ),
  ],
  'world2_spine_campaign_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find Under the Gun',
      hint: 'Preflop starts left of the Big Blind.',
      expectedSeatIds: <String>['utg'],
      contextText:
          'World 2 starts with preflop order: begin left of the Big Blind.',
      tradeoffText: 'Start from UTG, or begin the loop from the wrong seat.',
      consequenceText: 'Order anchor set: +8 chips. Wrong start: -6 chips.',
      insightText: 'UTG is first to act preflop at a full table.',
    ),
    MicroTaskStep(
      prompt: 'Find Hijack',
      hint: 'Action moves clockwise from UTG.',
      expectedSeatIds: <String>['hj'],
      contextText:
          'Continue the clockwise action loop from UTG to the next seat.',
      tradeoffText: 'Follow clockwise order, or skip to the wrong position.',
      consequenceText: 'Order continued: +8 chips. Order break: -6 chips.',
      insightText: 'Hijack follows UTG in preflop order.',
    ),
    MicroTaskStep(
      prompt: 'Find Cutoff',
      hint: 'Keep moving clockwise.',
      expectedSeatIds: <String>['co'],
      contextText: 'This extends the loop from middle to late position.',
      tradeoffText: 'Step to CO in order, or confuse late seats.',
      consequenceText: 'Late seat mapped: +8 chips. Seat mix-up: -6 chips.',
      insightText: 'Cutoff follows Hijack and sits before Button.',
    ),
    MicroTaskStep(
      prompt: 'Find the Button',
      hint: 'Button is the dealer seat.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Now anchor the dealer seat in the same clockwise loop.',
      tradeoffText: 'Place BTN correctly, or break the late-seat map.',
      consequenceText: 'Dealer anchor set: +8 chips. Anchor miss: -6 chips.',
      insightText: 'Button follows Cutoff in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Preflop decision in Hijack: facing an open.',
      hint: 'You face a raise. Choose from legal facing-bet actions.',
      expectedSeatIds: <String>['hj'],
      heroSeatId: 'HJ',
      boardCards: <String>[],
      heroCards: <String>['As', 'Qs'],
      pot: 8,
      toCall: 3,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'raise_to',
      contextText:
          'Use your late-position anchor now before returning to the blind loop.',
      tradeoffText:
          'Apply pressure now, or allow the opener to realize equity.',
      consequenceText: 'Pressure line: +8 chips. Passive line: -6 chips.',
      insightText:
          'Raising here builds value and isolates better than a flat call.',
    ),
    MicroTaskStep(
      prompt: 'Find Small Blind',
      hint: 'After Button comes the blinds.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Transition from dealer seat to the blind seats.',
      tradeoffText: 'Mark SB now, or mix late seats with blinds.',
      consequenceText: 'Blind transition: +8 chips. Label mix-up: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
    MicroTaskStep(
      prompt: 'Find Big Blind',
      hint: 'Big Blind follows Small Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Finish the clockwise seat loop by confirming Big Blind.',
      tradeoffText:
          'Complete the full loop, or leave preflop order incomplete.',
      consequenceText:
          'Clockwise loop complete: +8 chips. Incomplete loop: -6 chips.',
      insightText: 'Big Blind closes the six-seat clockwise loop.',
    ),
    MicroTaskStep(
      prompt: 'Flop decision in Cutoff: board is visible.',
      hint: 'Use the flop board and price to choose your action.',
      expectedSeatIds: <String>['co'],
      heroSeatId: 'CO',
      street: MicroTaskStreetV1.flop,
      boardCards: <String>['Kh', '8d', '3c'],
      heroCards: <String>['Kd', 'Qh'],
      pot: 17,
      toCall: 4,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'call',
      contextText:
          'Top pair can continue versus one small flop bet at this price.',
      tradeoffText: 'Continue with your made hand, or fold too much equity.',
      consequenceText: 'Measured continue: +8 chips. Overfold: -6 chips.',
      insightText:
          'Calling keeps weaker bluffs in while controlling pot growth.',
    ),
    MicroTaskStep(
      prompt: 'Seat recap: find Under the Gun again.',
      hint: 'Reset the clockwise map from the first preflop seat.',
      expectedSeatIds: <String>['utg'],
      contextText:
          'Reset the seat map before the final pressure example in World 2.',
      tradeoffText: 'Reset from UTG, or carry a blurred order map.',
      consequenceText: 'Anchor reset: +8 chips. Blurred map: -6 chips.',
      insightText: 'UTG starts the clockwise preflop order.',
    ),
    MicroTaskStep(
      prompt: 'Turn decision in Big Blind: read the fourth board card.',
      hint: 'Turn adds one card. Re-evaluate with new pressure.',
      expectedSeatIds: <String>['bb'],
      heroSeatId: 'BB',
      street: MicroTaskStreetV1.turn,
      boardCards: <String>['Kh', '8d', '3c', '2s'],
      heroCards: <String>['Kd', 'Qh'],
      pot: 25,
      toCall: 6,
      allowedActions: <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'fold',
      contextText:
          'The turn bet is larger and your one-pair hand drops in strength.',
      tradeoffText: 'Preserve chips against pressure, or pay off too wide.',
      consequenceText: 'Disciplined fold: +8 chips. Loose continue: -6 chips.',
      insightText:
          'Folding here controls losses when price and board pressure worsen.',
    ),
    MicroTaskStep(
      prompt: 'Seat recap: find Cutoff.',
      hint: 'Cutoff sits before Button in clockwise order.',
      expectedSeatIds: <String>['co'],
      contextText: 'Reconfirm a late seat after the action slice.',
      tradeoffText: 'Keep late seats distinct, or merge them by memory.',
      consequenceText: 'Late-seat precision: +8 chips. Label drift: -6 chips.',
      insightText: 'Cutoff is the seat immediately before Button.',
    ),
    MicroTaskStep(
      prompt: 'Seat recap close: find Big Blind.',
      hint: 'Close on the second blind seat.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Finish World 2 campaign by closing on blind position.',
      tradeoffText: 'Close with blind certainty, or end with seat drift.',
      consequenceText: 'Strong close: +8 chips. Drift close: -6 chips.',
      insightText: 'Big Blind closes the blind pair and the seat loop.',
    ),
  ],
  'world2_spine_followup_v1_b0': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find the Button',
      hint: 'Button is a late-seat label. Not action order.',
      expectedSeatIds: <String>['btn'],
      contextText: 'B0 keeps World 2 simple: anchor first, then compare seats.',
      tradeoffText: 'Anchor now, or guess the rest of the table.',
      consequenceText: 'Anchor set: +8 chips. Guess start: -6 chips.',
      insightText: 'BTN is the late-position anchor.',
    ),
    MicroTaskStep(
      prompt: 'Find Cutoff',
      hint: 'Seat order only. Not action order.',
      expectedSeatIds: <String>['co'],
      contextText:
          'This checks the late-position pair with seat-order wording.',
      tradeoffText: 'Map CO from BTN, or confuse the late seats.',
      consequenceText: 'Late pair correct: +8 chips. Seat mix-up: -6 chips.',
      insightText: 'CO sits directly before BTN in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Find Small Blind',
      hint: 'Small Blind is a blind seat, not a late seat.',
      expectedSeatIds: <String>['sb'],
      contextText:
          'World 2 also checks contrast between late seats and blind seats.',
      tradeoffText: 'Switch categories now, or keep the wrong seat in mind.',
      consequenceText: 'Category switch: +8 chips. Carryover miss: -6 chips.',
      insightText: 'SB is a blind seat, not a late seat.',
    ),
    MicroTaskStep(
      prompt: 'Find Big Blind',
      hint: 'Big Blind is a blind seat, not a late seat.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Close B0 by confirming both blind seats after BTN/CO.',
      tradeoffText: 'Complete the pair, or leave the table map incomplete.',
      consequenceText:
          'Blind pair complete: +8 chips. Incomplete map: -6 chips.',
      insightText: 'SB then BB completes the blind pair.',
    ),
  ],
  'world2_spine_followup_v1_b1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find Cutoff',
      hint: 'Cutoff is before Button in seat order.',
      expectedSeatIds: <String>['co'],
      contextText:
          'B1 tests one error-class: seat-label drift under repetition.',
      tradeoffText: 'Name the seat now, or drift on a repeated pattern.',
      consequenceText: 'Seat correct: +8 chips. Drift miss: -6 chips.',
      insightText: 'Repetition should not change seat labels.',
    ),
    MicroTaskStep(
      prompt: 'Find the Button',
      hint: 'Seat order only. Not action order.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Anchor refresh keeps the repeated sequence stable.',
      tradeoffText: 'Refresh anchor now, or continue from stale mapping.',
      consequenceText: 'Anchor refresh: +8 chips. Stale mapping: -6 chips.',
      insightText: 'BTN resets the repeated cycle.',
    ),
    MicroTaskStep(
      prompt: 'Find Hijack',
      hint: 'Hijack is before Cutoff in seat order.',
      expectedSeatIds: <String>['hj'],
      contextText: 'This step checks order after an occupancy change.',
      tradeoffText: 'Recalculate seat order now, or click a missing seat.',
      consequenceText: 'Recalculation pass: +8 chips. Order miss: -6 chips.',
      insightText: 'Occupancy changes require a fresh seat-order check.',
    ),
    MicroTaskStep(
      prompt: 'Find Small Blind',
      hint: 'Small Blind is a blind seat, not a late seat.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Close B1 by confirming blind identity after repetition.',
      tradeoffText: 'Confirm the blind seat now, or end on a label mix-up.',
      consequenceText: 'Blind seat confirmed: +8 chips. Label miss: -6 chips.',
      insightText: 'World 2 B1 goal: no seat-order drift.',
    ),
  ],
  'world2_spine_followup_v1_b2': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find Big Blind',
      hint: 'Big Blind is a blind seat, not a late seat.',
      expectedSeatIds: <String>['bb'],
      contextText:
          'B2 keeps the same mechanic but adds sharper seat-role framing.',
      tradeoffText:
          'Identify the seat first, or attach the idea to the wrong seat.',
      consequenceText: 'Seat-role match: +8 chips. Seat-role miss: -6 chips.',
      insightText: 'Advanced labels still start with exact seat ID.',
    ),
    MicroTaskStep(
      prompt: 'Find Cutoff',
      hint: 'Seat order only. Not action order.',
      expectedSeatIds: <String>['co'],
      contextText: 'This checks a late-position seat under advanced wording.',
      tradeoffText: 'Map the seat now, or let the wording hide the seat error.',
      consequenceText: 'Seat mapped: +8 chips. Hidden miss: -6 chips.',
      insightText:
          'CO remains a seat-order task here, not an action-order task.',
    ),
    MicroTaskStep(
      prompt: 'Find Hijack',
      hint: 'Hijack is before Cutoff in seat order.',
      expectedSeatIds: <String>['hj'],
      contextText: 'Advanced prompts still require occupancy-aware seat order.',
      tradeoffText: 'Recalculate seat order now, or click by habit.',
      consequenceText: 'Precision held: +8 chips. Habit miss: -6 chips.',
      insightText: 'Precision beats speed when labels get denser.',
    ),
    MicroTaskStep(
      prompt: 'Find the Button',
      hint: 'Button is a late-seat label. Not action order.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Close B2 by returning to the anchor after advanced labels.',
      tradeoffText: 'Close on the anchor, or finish on a stale map.',
      consequenceText: 'Anchor close: +8 chips. Stale close: -6 chips.',
      insightText:
          'World 2 B2 goal: advanced wording without seat-label drift.',
    ),
  ],
  'world3_spine_campaign_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find the Button',
      hint: 'Price to call first. Seat order stays separate.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Pot odds start with one number: chips needed to continue.',
      tradeoffText: 'Mark call cost first, or guess and overpay.',
      consequenceText: 'Price read: +8 chips. Guess price: -6 chips.',
      insightText: 'Call cost is the first check every hand.',
    ),
    MicroTaskStep(
      prompt: 'Find Small Blind',
      hint: 'Seat label first, then price check.',
      expectedSeatIds: <String>['sb'],
      contextText: 'You compare call cost to the pot you can win.',
      tradeoffText: 'Use pot-after-call, or compare against the wrong pot.',
      consequenceText: 'Pot read: +8 chips. Wrong base: -6 chips.',
      insightText: 'Compare call X to total pot (pot + X).',
    ),
    MicroTaskStep(
      prompt: 'Find Big Blind',
      hint: 'Compare call cost to total pot (pot + call).',
      expectedSeatIds: <String>['bb'],
      contextText: 'Break-even means your call price is fair to continue.',
      tradeoffText: 'Tag break-even, or call spots that are too expensive.',
      consequenceText: 'Break-even hit: +8 chips. Overpay call: -6 chips.',
      insightText: 'Bad price means fold more, good price means continue more.',
    ),
    MicroTaskStep(
      prompt: 'Find Hijack',
      hint: 'Good price can continue more.',
      expectedSeatIds: <String>['hj'],
      contextText: 'Lower call cost against a larger pot supports continuing.',
      tradeoffText: 'Use the cheap price, or fold too often.',
      consequenceText: 'Cheap-price continue: +8 chips. Tight fold: -6 chips.',
      insightText: 'Cheap price increases continue frequency.',
    ),
    MicroTaskStep(
      prompt: 'Find Cutoff',
      hint: 'Bad price should fold more.',
      expectedSeatIds: <String>['co'],
      contextText: 'Large call cost with low return is an overpay trap.',
      tradeoffText: 'Fold the bad price, or leak chips repeatedly.',
      consequenceText: 'Disciplined fold: +8 chips. Repeat leak: -6 chips.',
      insightText: 'Bad-price folds protect bankroll best.',
    ),
  ],
  'world3_spine_followup_v1_b0': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find the Button',
      hint: 'Price to call first. Seat order stays separate.',
      expectedSeatIds: <String>['btn'],
      contextText: 'B0 repeats the pot-odds routine with short checks.',
      tradeoffText: 'Read the price first, or guess the decision.',
      consequenceText: 'Price-first start: +8 chips. Guess start: -6 chips.',
      insightText: 'Start with call cost on every decision.',
    ),
    MicroTaskStep(
      prompt: 'Find Small Blind',
      hint: 'Seat label first, then price check.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Use total pot after calling as the comparison base.',
      tradeoffText: 'Compare to the full pot, or use the wrong number.',
      consequenceText: 'Pot base correct: +8 chips. Wrong base: -6 chips.',
      insightText: 'Compare call X to total pot (pot + X).',
    ),
    MicroTaskStep(
      prompt: 'Find Big Blind',
      hint: 'Compare call cost to total pot (pot + call).',
      expectedSeatIds: <String>['bb'],
      contextText: 'High call cost against low return is an overpay.',
      tradeoffText: 'Fold the bad price, or overcall.',
      consequenceText: 'Bad-price fold: +8 chips. Overcall: -6 chips.',
      insightText: 'Bad price should fold by default.',
    ),
    MicroTaskStep(
      prompt: 'Find Cutoff',
      hint: 'Good price can continue more.',
      expectedSeatIds: <String>['co'],
      contextText: 'Low call cost against a larger return supports continuing.',
      tradeoffText: 'Use the good price, or fold too much value.',
      consequenceText:
          'Good-price continue: +8 chips. Missed continue: -6 chips.',
      insightText: 'Good price can justify a wider continue.',
    ),
  ],
  'world3_spine_followup_v1_b1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find Cutoff',
      hint: 'Price to call first. Seat order stays separate.',
      expectedSeatIds: <String>['co'],
      contextText: 'This set trains one error-class: overcalling bad prices.',
      tradeoffText: 'Fold bad price now, or pay unnecessary chips.',
      consequenceText: 'Bad-price fold: +8 chips. Overcall leak: -6 chips.',
      insightText: 'Expensive calls are the main leak to remove.',
    ),
    MicroTaskStep(
      prompt: 'Find the Button',
      hint: 'Seat label first, then price check.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Low call cost against larger return supports continuing.',
      tradeoffText: 'Take fair price, or fold too much value.',
      consequenceText: 'Good-price call: +8 chips. Missed call: -6 chips.',
      insightText: 'Good price justifies more continues.',
    ),
    MicroTaskStep(
      prompt: 'Find Big Blind',
      hint: 'Compare call cost to total pot (pot + call).',
      expectedSeatIds: <String>['bb'],
      contextText: 'Close spots are decided by one short comparison.',
      tradeoffText: 'Check the ratio, or default into overcalling.',
      consequenceText: 'Close-spot check: +8 chips. Default call: -6 chips.',
      insightText: 'Close prices require explicit yes/no math.',
    ),
    MicroTaskStep(
      prompt: 'Find Hijack',
      hint: 'Good price can continue more.',
      expectedSeatIds: <String>['hj'],
      contextText: 'If call cost is too high, folding is correct.',
      tradeoffText: 'Take the fold, or overpay from habit.',
      consequenceText: 'Price discipline: +8 chips. Habit leak: -6 chips.',
      insightText: 'Bad price should trigger fold by default.',
    ),
  ],
  'world3_spine_followup_v1_b2': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find Small Blind',
      hint: 'Price to call first. Seat order stays separate.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Use seat labels for orientation, then run price math.',
      tradeoffText: 'Separate seat order from price, or mix the concepts.',
      consequenceText: 'Concepts separated: +8 chips. Mixed read: -6 chips.',
      insightText: 'Seat order labels do not change call-price math.',
    ),
    MicroTaskStep(
      prompt: 'Find Big Blind',
      hint: 'Seat label first, then price check.',
      expectedSeatIds: <String>['bb'],
      contextText: 'The same price-first routine applies in every seat.',
      tradeoffText: 'Check price first, or call from habit.',
      consequenceText: 'Price-first check: +8 chips. Habit call: -6 chips.',
      insightText: 'Price to call first, action second.',
    ),
    MicroTaskStep(
      prompt: 'Find Cutoff',
      hint: 'Compare call cost to total pot (pot + call).',
      expectedSeatIds: <String>['co'],
      contextText: 'Close prices are where overcalls happen most often.',
      tradeoffText: 'Check one more time, or call from impulse.',
      consequenceText: 'Close-price check: +8 chips. Impulse call: -6 chips.',
      insightText: 'Close prices need explicit confirmation.',
    ),
    MicroTaskStep(
      prompt: 'Find the Button',
      hint: 'Good price can continue more.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Low call cost against a larger return supports continuing.',
      tradeoffText: 'Use the good price, or fold too tight.',
      consequenceText: 'Good-price continue: +8 chips. Tight fold: -6 chips.',
      insightText: 'Good price should not be folded automatically.',
    ),
    MicroTaskStep(
      prompt: 'Find Hijack',
      hint: 'Bad price should fold more.',
      expectedSeatIds: <String>['hj'],
      contextText: 'High call cost against low return is an overpay.',
      tradeoffText: 'Fold the bad price, or leak chips.',
      consequenceText: 'Bad-price fold: +8 chips. Overpay: -6 chips.',
      insightText: 'Bad price should trigger fold by default.',
    ),
  ],
  'world4_spine_campaign_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: anchor the seat map first.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Start each set by anchoring the seat map on Button.',
      tradeoffText: 'Anchor the map first, or guess seat labels.',
      consequenceText: 'Anchor set: +8 chips. Seat guess: -6 chips.',
      insightText: 'Button is the anchor for seat-order drills.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: identify the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Blind seats are position labels in this set.',
      tradeoffText: 'Name the blind seat now, or mix labels later.',
      consequenceText: 'Blind seat read: +8 chips. Mixed labels: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Big Blind completes the two-seat blind pair.',
      tradeoffText: 'Complete the pair, or leave the map incomplete.',
      consequenceText:
          'Blind pair complete: +8 chips. Incomplete map: -6 chips.',
      insightText: 'BB is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: continue seat order away from blinds.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'This step checks seat labels beyond Button and blinds.',
      tradeoffText: 'Use seat-order labels, or click by shape only.',
      consequenceText: 'Seat order held: +8 chips. Label drift: -6 chips.',
      insightText: 'Hijack is a seat-order label, not an action-order rule.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: confirm the late-position seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Cutoff is a seat label in the late-position group.',
      tradeoffText: 'Confirm the label, or mix late seats.',
      consequenceText:
          'Late seat confirmed: +8 chips. Late-seat miss: -6 chips.',
      insightText: 'Cutoff sits before Button in seat order.',
    ),
  ],
  'world4_spine_followup_v1_b0': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: restart from the seat-order anchor.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'B0 repeats core labels with short checks.',
      tradeoffText: 'Start from the anchor, or guess the map.',
      consequenceText: 'Anchor restart: +8 chips. Guess start: -6 chips.',
      insightText: 'Restart from Button when the map feels noisy.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: verify blind label quickly.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Short followup keeps blind labels accurate.',
      tradeoffText: 'Verify the seat label, or drift by memory.',
      consequenceText: 'Blind verified: +8 chips. Label drift: -6 chips.',
      insightText: 'Blind labels should stay automatic.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair again.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Pairing SB and BB prevents blind-label misses.',
      tradeoffText: 'Complete the pair, or leave a gap.',
      consequenceText: 'Pair complete: +8 chips. Gap left: -6 chips.',
      insightText: 'SB and BB should be checked as a pair.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: finish on the late seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Final step checks a non-blind late seat label.',
      tradeoffText: 'Finish with seat order, or revert to guessing.',
      consequenceText: 'Late label finish: +8 chips. Guess finish: -6 chips.',
      insightText: 'Cutoff and Button should stay distinct.',
    ),
  ],
  'world4_spine_followup_v1_b1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Cutoff: seat order before Button.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'This followup reinforces late-seat order only.',
      tradeoffText: 'Use seat-order wording, or imply action order.',
      consequenceText: 'Seat order clear: +8 chips. Wording drift: -6 chips.',
      insightText: 'Cutoff is before Button in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: keep the anchor label precise.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Anchor label checks support faster seat reads.',
      tradeoffText: 'Confirm the anchor, or click by habit.',
      consequenceText: 'Anchor confirmed: +8 chips. Habit miss: -6 chips.',
      insightText: 'Button remains the anchor seat label.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: check the middle seat label.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'Middle-seat labels break anchor-only habits.',
      tradeoffText: 'Read the label, or overuse anchor cues.',
      consequenceText:
          'Middle seat read: +8 chips. Anchor-only miss: -6 chips.',
      insightText: 'Hijack is a position label in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: finish with the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Close by returning to a blind label check.',
      tradeoffText: 'Finish on a clear blind label, or end on drift.',
      consequenceText: 'Blind close: +8 chips. Drift close: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
  ],
  'world4_spine_followup_v1_b2': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Small Blind: seat label first, then decision.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Separate seat recognition from later hand decisions.',
      tradeoffText: 'Name the seat first, or mix tasks together.',
      consequenceText: 'Tasks separated: +8 chips. Mixed tasks: -6 chips.',
      insightText: 'Seat labels and action decisions are different checks.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: confirm the second blind seat.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Blind-seat order should remain stable under repetition.',
      tradeoffText: 'Confirm the blind seat, or drift on labels.',
      consequenceText: 'Blind confirmed: +8 chips. Label drift: -6 chips.',
      insightText: 'Big Blind is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: keep late-seat labels distinct.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Late-seat labels should stay precise under repetition.',
      tradeoffText: 'Keep labels distinct, or merge late seats.',
      consequenceText:
          'Late-seat precision: +8 chips. Merged labels: -6 chips.',
      insightText: 'Cutoff and Button are different late seats.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: close on the anchor seat label.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Closing on the anchor confirms the full seat map.',
      tradeoffText: 'Close on the anchor, or finish on drift.',
      consequenceText: 'Anchor close: +8 chips. Drift close: -6 chips.',
      insightText: 'Close on Button to reset the seat map.',
    ),
  ],
  'world5_spine_campaign_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: anchor the seat map first.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Start each set by anchoring the seat map on Button.',
      tradeoffText: 'Anchor the map first, or guess seat labels.',
      consequenceText: 'Anchor set: +8 chips. Seat guess: -6 chips.',
      insightText: 'Button is the anchor for seat-order drills.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: identify the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Blind seats are position labels in this set.',
      tradeoffText: 'Name the blind seat now, or mix labels later.',
      consequenceText: 'Blind seat read: +8 chips. Mixed labels: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Big Blind completes the two-seat blind pair.',
      tradeoffText: 'Complete the pair, or leave the map incomplete.',
      consequenceText:
          'Blind pair complete: +8 chips. Incomplete map: -6 chips.',
      insightText: 'BB is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: continue seat order away from blinds.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'This step checks seat labels beyond Button and blinds.',
      tradeoffText: 'Use seat-order labels, or click by shape only.',
      consequenceText: 'Seat order held: +8 chips. Label drift: -6 chips.',
      insightText: 'Hijack is a seat-order label, not an action-order rule.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: confirm the late-position seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Cutoff is a seat label in the late-position group.',
      tradeoffText: 'Confirm the label, or mix late seats.',
      consequenceText:
          'Late seat confirmed: +8 chips. Late-seat miss: -6 chips.',
      insightText: 'Cutoff sits before Button in seat order.',
    ),
  ],
  'world5_spine_followup_v1_b0': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: restart from the seat-order anchor.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'B0 repeats core labels with short checks.',
      tradeoffText: 'Start from the anchor, or guess the map.',
      consequenceText: 'Anchor restart: +8 chips. Guess start: -6 chips.',
      insightText: 'Restart from Button when the map feels noisy.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: verify blind label quickly.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Short followup keeps blind labels accurate.',
      tradeoffText: 'Verify the seat label, or drift by memory.',
      consequenceText: 'Blind verified: +8 chips. Label drift: -6 chips.',
      insightText: 'Blind labels should stay automatic.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair again.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Pairing SB and BB prevents blind-label misses.',
      tradeoffText: 'Complete the pair, or leave a gap.',
      consequenceText: 'Pair complete: +8 chips. Gap left: -6 chips.',
      insightText: 'SB and BB should be checked as a pair.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: finish on the late seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Final step checks a non-blind late seat label.',
      tradeoffText: 'Finish with seat order, or revert to guessing.',
      consequenceText: 'Late label finish: +8 chips. Guess finish: -6 chips.',
      insightText: 'Cutoff and Button should stay distinct.',
    ),
  ],
  'world5_spine_followup_v1_b1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Cutoff: seat order before Button.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'This followup reinforces late-seat order only.',
      tradeoffText: 'Use seat-order wording, or imply action order.',
      consequenceText: 'Seat order clear: +8 chips. Wording drift: -6 chips.',
      insightText: 'Cutoff is before Button in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: keep the anchor label precise.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Anchor label checks support faster seat reads.',
      tradeoffText: 'Confirm the anchor, or click by habit.',
      consequenceText: 'Anchor confirmed: +8 chips. Habit miss: -6 chips.',
      insightText: 'Button remains the anchor seat label.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: check the middle seat label.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'Middle-seat labels break anchor-only habits.',
      tradeoffText: 'Read the label, or overuse anchor cues.',
      consequenceText:
          'Middle seat read: +8 chips. Anchor-only miss: -6 chips.',
      insightText: 'Hijack is a position label in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: finish with the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Close by returning to a blind label check.',
      tradeoffText: 'Finish on a clear blind label, or end on drift.',
      consequenceText: 'Blind close: +8 chips. Drift close: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
  ],
  'world5_spine_followup_v1_b2': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Small Blind: seat label first, then decision.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Separate seat recognition from later hand decisions.',
      tradeoffText: 'Name the seat first, or mix tasks together.',
      consequenceText: 'Tasks separated: +8 chips. Mixed tasks: -6 chips.',
      insightText: 'Seat labels and action decisions are different checks.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: confirm the second blind seat.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Blind-seat order should remain stable under repetition.',
      tradeoffText: 'Confirm the blind seat, or drift on labels.',
      consequenceText: 'Blind confirmed: +8 chips. Label drift: -6 chips.',
      insightText: 'Big Blind is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: keep late-seat labels distinct.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Late-seat labels should stay precise under repetition.',
      tradeoffText: 'Keep labels distinct, or merge late seats.',
      consequenceText:
          'Late-seat precision: +8 chips. Merged labels: -6 chips.',
      insightText: 'Cutoff and Button are different late seats.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: close on the anchor seat label.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Closing on the anchor confirms the full seat map.',
      tradeoffText: 'Close on the anchor, or finish on drift.',
      consequenceText: 'Anchor close: +8 chips. Drift close: -6 chips.',
      insightText: 'Close on Button to reset the seat map.',
    ),
  ],

  'world6_spine_campaign_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: anchor the seat map first.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Start each set by anchoring the seat map on Button.',
      tradeoffText: 'Anchor the map first, or guess seat labels.',
      consequenceText: 'Anchor set: +8 chips. Seat guess: -6 chips.',
      insightText: 'Button is the anchor for seat-order drills.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: identify the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Blind seats are position labels in this set.',
      tradeoffText: 'Name the blind seat now, or mix labels later.',
      consequenceText: 'Blind seat read: +8 chips. Mixed labels: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Big Blind completes the two-seat blind pair.',
      tradeoffText: 'Complete the pair, or leave the map incomplete.',
      consequenceText:
          'Blind pair complete: +8 chips. Incomplete map: -6 chips.',
      insightText: 'BB is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: continue seat order away from blinds.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'This step checks seat labels beyond Button and blinds.',
      tradeoffText: 'Use seat-order labels, or click by shape only.',
      consequenceText: 'Seat order held: +8 chips. Label drift: -6 chips.',
      insightText: 'Hijack is a seat-order label, not an action-order rule.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: confirm the late-position seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Cutoff is a seat label in the late-position group.',
      tradeoffText: 'Confirm the label, or mix late seats.',
      consequenceText:
          'Late seat confirmed: +8 chips. Late-seat miss: -6 chips.',
      insightText: 'Cutoff sits before Button in seat order.',
    ),
  ],

  'world6_spine_followup_v1_b0': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: restart from the seat-order anchor.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'B0 repeats core labels with short checks.',
      tradeoffText: 'Start from the anchor, or guess the map.',
      consequenceText: 'Anchor restart: +8 chips. Guess start: -6 chips.',
      insightText: 'Restart from Button when the map feels noisy.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: verify blind label quickly.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Short followup keeps blind labels accurate.',
      tradeoffText: 'Verify the seat label, or drift by memory.',
      consequenceText: 'Blind verified: +8 chips. Label drift: -6 chips.',
      insightText: 'Blind labels should stay automatic.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair again.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Pairing SB and BB prevents blind-label misses.',
      tradeoffText: 'Complete the pair, or leave a gap.',
      consequenceText: 'Pair complete: +8 chips. Gap left: -6 chips.',
      insightText: 'SB and BB should be checked as a pair.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: finish on the late seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Final step checks a non-blind late seat label.',
      tradeoffText: 'Finish with seat order, or revert to guessing.',
      consequenceText: 'Late label finish: +8 chips. Guess finish: -6 chips.',
      insightText: 'Cutoff and Button should stay distinct.',
    ),
  ],

  'world6_spine_followup_v1_b1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Cutoff: seat order before Button.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'This followup reinforces late-seat order only.',
      tradeoffText: 'Use seat-order wording, or imply action order.',
      consequenceText: 'Seat order clear: +8 chips. Wording drift: -6 chips.',
      insightText: 'Cutoff is before Button in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: keep the anchor label precise.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Anchor label checks support faster seat reads.',
      tradeoffText: 'Confirm the anchor, or click by habit.',
      consequenceText: 'Anchor confirmed: +8 chips. Habit miss: -6 chips.',
      insightText: 'Button remains the anchor seat label.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: check the middle seat label.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'Middle-seat labels break anchor-only habits.',
      tradeoffText: 'Read the label, or overuse anchor cues.',
      consequenceText:
          'Middle seat read: +8 chips. Anchor-only miss: -6 chips.',
      insightText: 'Hijack is a position label in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: finish with the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Close by returning to a blind label check.',
      tradeoffText: 'Finish on a clear blind label, or end on drift.',
      consequenceText: 'Blind close: +8 chips. Drift close: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
  ],

  'world6_spine_followup_v1_b2': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Small Blind: seat label first, then decision.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Separate seat recognition from later hand decisions.',
      tradeoffText: 'Name the seat first, or mix tasks together.',
      consequenceText: 'Tasks separated: +8 chips. Mixed tasks: -6 chips.',
      insightText: 'Seat labels and action decisions are different checks.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: confirm the second blind seat.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Blind-seat order should remain stable under repetition.',
      tradeoffText: 'Confirm the blind seat, or drift on labels.',
      consequenceText: 'Blind confirmed: +8 chips. Label drift: -6 chips.',
      insightText: 'Big Blind is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: keep late-seat labels distinct.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Late-seat labels should stay precise under repetition.',
      tradeoffText: 'Keep labels distinct, or merge late seats.',
      consequenceText:
          'Late-seat precision: +8 chips. Merged labels: -6 chips.',
      insightText: 'Cutoff and Button are different late seats.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: close on the anchor seat label.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Closing on the anchor confirms the full seat map.',
      tradeoffText: 'Close on the anchor, or finish on drift.',
      consequenceText: 'Anchor close: +8 chips. Drift close: -6 chips.',
      insightText: 'Close on Button to reset the seat map.',
    ),
  ],

  'world7_spine_campaign_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: anchor the seat map first.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Start each set by anchoring the seat map on Button.',
      tradeoffText: 'Anchor the map first, or guess seat labels.',
      consequenceText: 'Anchor set: +8 chips. Seat guess: -6 chips.',
      insightText: 'Button is the anchor for seat-order drills.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: identify the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Blind seats are position labels in this set.',
      tradeoffText: 'Name the blind seat now, or mix labels later.',
      consequenceText: 'Blind seat read: +8 chips. Mixed labels: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Big Blind completes the two-seat blind pair.',
      tradeoffText: 'Complete the pair, or leave the map incomplete.',
      consequenceText:
          'Blind pair complete: +8 chips. Incomplete map: -6 chips.',
      insightText: 'BB is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: continue seat order away from blinds.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'This step checks seat labels beyond Button and blinds.',
      tradeoffText: 'Use seat-order labels, or click by shape only.',
      consequenceText: 'Seat order held: +8 chips. Label drift: -6 chips.',
      insightText: 'Hijack is a seat-order label, not an action-order rule.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: confirm the late-position seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Cutoff is a seat label in the late-position group.',
      tradeoffText: 'Confirm the label, or mix late seats.',
      consequenceText:
          'Late seat confirmed: +8 chips. Late-seat miss: -6 chips.',
      insightText: 'Cutoff sits before Button in seat order.',
    ),
  ],

  'world7_spine_followup_v1_b0': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: restart from the seat-order anchor.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'B0 repeats core labels with short checks.',
      tradeoffText: 'Start from the anchor, or guess the map.',
      consequenceText: 'Anchor restart: +8 chips. Guess start: -6 chips.',
      insightText: 'Restart from Button when the map feels noisy.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: verify blind label quickly.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Short followup keeps blind labels accurate.',
      tradeoffText: 'Verify the seat label, or drift by memory.',
      consequenceText: 'Blind verified: +8 chips. Label drift: -6 chips.',
      insightText: 'Blind labels should stay automatic.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair again.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Pairing SB and BB prevents blind-label misses.',
      tradeoffText: 'Complete the pair, or leave a gap.',
      consequenceText: 'Pair complete: +8 chips. Gap left: -6 chips.',
      insightText: 'SB and BB should be checked as a pair.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: finish on the late seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Final step checks a non-blind late seat label.',
      tradeoffText: 'Finish with seat order, or revert to guessing.',
      consequenceText: 'Late label finish: +8 chips. Guess finish: -6 chips.',
      insightText: 'Cutoff and Button should stay distinct.',
    ),
  ],

  'world7_spine_followup_v1_b1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Cutoff: seat order before Button.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'This followup reinforces late-seat order only.',
      tradeoffText: 'Use seat-order wording, or imply action order.',
      consequenceText: 'Seat order clear: +8 chips. Wording drift: -6 chips.',
      insightText: 'Cutoff is before Button in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: keep the anchor label precise.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Anchor label checks support faster seat reads.',
      tradeoffText: 'Confirm the anchor, or click by habit.',
      consequenceText: 'Anchor confirmed: +8 chips. Habit miss: -6 chips.',
      insightText: 'Button remains the anchor seat label.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: check the middle seat label.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'Middle-seat labels break anchor-only habits.',
      tradeoffText: 'Read the label, or overuse anchor cues.',
      consequenceText:
          'Middle seat read: +8 chips. Anchor-only miss: -6 chips.',
      insightText: 'Hijack is a position label in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: finish with the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Close by returning to a blind label check.',
      tradeoffText: 'Finish on a clear blind label, or end on drift.',
      consequenceText: 'Blind close: +8 chips. Drift close: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
  ],

  'world7_spine_followup_v1_b2': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Small Blind: seat label first, then decision.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Separate seat recognition from later hand decisions.',
      tradeoffText: 'Name the seat first, or mix tasks together.',
      consequenceText: 'Tasks separated: +8 chips. Mixed tasks: -6 chips.',
      insightText: 'Seat labels and action decisions are different checks.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: confirm the second blind seat.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Blind-seat order should remain stable under repetition.',
      tradeoffText: 'Confirm the blind seat, or drift on labels.',
      consequenceText: 'Blind confirmed: +8 chips. Label drift: -6 chips.',
      insightText: 'Big Blind is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: keep late-seat labels distinct.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Late-seat labels should stay precise under repetition.',
      tradeoffText: 'Keep labels distinct, or merge late seats.',
      consequenceText:
          'Late-seat precision: +8 chips. Merged labels: -6 chips.',
      insightText: 'Cutoff and Button are different late seats.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: close on the anchor seat label.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Closing on the anchor confirms the full seat map.',
      tradeoffText: 'Close on the anchor, or finish on drift.',
      consequenceText: 'Anchor close: +8 chips. Drift close: -6 chips.',
      insightText: 'Close on Button to reset the seat map.',
    ),
  ],

  'world8_spine_campaign_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: anchor the seat map first.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Start each set by anchoring the seat map on Button.',
      tradeoffText: 'Anchor the map first, or guess seat labels.',
      consequenceText: 'Anchor set: +8 chips. Seat guess: -6 chips.',
      insightText: 'Button is the anchor for seat-order drills.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: identify the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Blind seats are position labels in this set.',
      tradeoffText: 'Name the blind seat now, or mix labels later.',
      consequenceText: 'Blind seat read: +8 chips. Mixed labels: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Big Blind completes the two-seat blind pair.',
      tradeoffText: 'Complete the pair, or leave the map incomplete.',
      consequenceText:
          'Blind pair complete: +8 chips. Incomplete map: -6 chips.',
      insightText: 'BB is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: continue seat order away from blinds.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'This step checks seat labels beyond Button and blinds.',
      tradeoffText: 'Use seat-order labels, or click by shape only.',
      consequenceText: 'Seat order held: +8 chips. Label drift: -6 chips.',
      insightText: 'Hijack is a seat-order label, not an action-order rule.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: confirm the late-position seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Cutoff is a seat label in the late-position group.',
      tradeoffText: 'Confirm the label, or mix late seats.',
      consequenceText:
          'Late seat confirmed: +8 chips. Late-seat miss: -6 chips.',
      insightText: 'Cutoff sits before Button in seat order.',
    ),
  ],

  'world8_spine_followup_v1_b0': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: restart from the seat-order anchor.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'B0 repeats core labels with short checks.',
      tradeoffText: 'Start from the anchor, or guess the map.',
      consequenceText: 'Anchor restart: +8 chips. Guess start: -6 chips.',
      insightText: 'Restart from Button when the map feels noisy.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: verify blind label quickly.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Short followup keeps blind labels accurate.',
      tradeoffText: 'Verify the seat label, or drift by memory.',
      consequenceText: 'Blind verified: +8 chips. Label drift: -6 chips.',
      insightText: 'Blind labels should stay automatic.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair again.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Pairing SB and BB prevents blind-label misses.',
      tradeoffText: 'Complete the pair, or leave a gap.',
      consequenceText: 'Pair complete: +8 chips. Gap left: -6 chips.',
      insightText: 'SB and BB should be checked as a pair.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: finish on the late seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Final step checks a non-blind late seat label.',
      tradeoffText: 'Finish with seat order, or revert to guessing.',
      consequenceText: 'Late label finish: +8 chips. Guess finish: -6 chips.',
      insightText: 'Cutoff and Button should stay distinct.',
    ),
  ],

  'world8_spine_followup_v1_b1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Cutoff: seat order before Button.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'This followup reinforces late-seat order only.',
      tradeoffText: 'Use seat-order wording, or imply action order.',
      consequenceText: 'Seat order clear: +8 chips. Wording drift: -6 chips.',
      insightText: 'Cutoff is before Button in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: keep the anchor label precise.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Anchor label checks support faster seat reads.',
      tradeoffText: 'Confirm the anchor, or click by habit.',
      consequenceText: 'Anchor confirmed: +8 chips. Habit miss: -6 chips.',
      insightText: 'Button remains the anchor seat label.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: check the middle seat label.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'Middle-seat labels break anchor-only habits.',
      tradeoffText: 'Read the label, or overuse anchor cues.',
      consequenceText:
          'Middle seat read: +8 chips. Anchor-only miss: -6 chips.',
      insightText: 'Hijack is a position label in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: finish with the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Close by returning to a blind label check.',
      tradeoffText: 'Finish on a clear blind label, or end on drift.',
      consequenceText: 'Blind close: +8 chips. Drift close: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
  ],

  'world8_spine_followup_v1_b2': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Small Blind: seat label first, then decision.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Separate seat recognition from later hand decisions.',
      tradeoffText: 'Name the seat first, or mix tasks together.',
      consequenceText: 'Tasks separated: +8 chips. Mixed tasks: -6 chips.',
      insightText: 'Seat labels and action decisions are different checks.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: confirm the second blind seat.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Blind-seat order should remain stable under repetition.',
      tradeoffText: 'Confirm the blind seat, or drift on labels.',
      consequenceText: 'Blind confirmed: +8 chips. Label drift: -6 chips.',
      insightText: 'Big Blind is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: keep late-seat labels distinct.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Late-seat labels should stay precise under repetition.',
      tradeoffText: 'Keep labels distinct, or merge late seats.',
      consequenceText:
          'Late-seat precision: +8 chips. Merged labels: -6 chips.',
      insightText: 'Cutoff and Button are different late seats.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: close on the anchor seat label.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Closing on the anchor confirms the full seat map.',
      tradeoffText: 'Close on the anchor, or finish on drift.',
      consequenceText: 'Anchor close: +8 chips. Drift close: -6 chips.',
      insightText: 'Close on Button to reset the seat map.',
    ),
  ],

  'world9_spine_campaign_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: anchor the seat map first.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Start each set by anchoring the seat map on Button.',
      tradeoffText: 'Anchor the map first, or guess seat labels.',
      consequenceText: 'Anchor set: +8 chips. Seat guess: -6 chips.',
      insightText: 'Button is the anchor for seat-order drills.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: identify the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Blind seats are position labels in this set.',
      tradeoffText: 'Name the blind seat now, or mix labels later.',
      consequenceText: 'Blind seat read: +8 chips. Mixed labels: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Big Blind completes the two-seat blind pair.',
      tradeoffText: 'Complete the pair, or leave the map incomplete.',
      consequenceText:
          'Blind pair complete: +8 chips. Incomplete map: -6 chips.',
      insightText: 'BB is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: continue seat order away from blinds.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'This step checks seat labels beyond Button and blinds.',
      tradeoffText: 'Use seat-order labels, or click by shape only.',
      consequenceText: 'Seat order held: +8 chips. Label drift: -6 chips.',
      insightText: 'Hijack is a seat-order label, not an action-order rule.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: confirm the late-position seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Cutoff is a seat label in the late-position group.',
      tradeoffText: 'Confirm the label, or mix late seats.',
      consequenceText:
          'Late seat confirmed: +8 chips. Late-seat miss: -6 chips.',
      insightText: 'Cutoff sits before Button in seat order.',
    ),
  ],

  'world9_spine_followup_v1_b0': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: restart from the seat-order anchor.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'B0 repeats core labels with short checks.',
      tradeoffText: 'Start from the anchor, or guess the map.',
      consequenceText: 'Anchor restart: +8 chips. Guess start: -6 chips.',
      insightText: 'Restart from Button when the map feels noisy.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: verify blind label quickly.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Short followup keeps blind labels accurate.',
      tradeoffText: 'Verify the seat label, or drift by memory.',
      consequenceText: 'Blind verified: +8 chips. Label drift: -6 chips.',
      insightText: 'Blind labels should stay automatic.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair again.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Pairing SB and BB prevents blind-label misses.',
      tradeoffText: 'Complete the pair, or leave a gap.',
      consequenceText: 'Pair complete: +8 chips. Gap left: -6 chips.',
      insightText: 'SB and BB should be checked as a pair.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: finish on the late seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Final step checks a non-blind late seat label.',
      tradeoffText: 'Finish with seat order, or revert to guessing.',
      consequenceText: 'Late label finish: +8 chips. Guess finish: -6 chips.',
      insightText: 'Cutoff and Button should stay distinct.',
    ),
  ],

  'world9_spine_followup_v1_b1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Cutoff: seat order before Button.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'This followup reinforces late-seat order only.',
      tradeoffText: 'Use seat-order wording, or imply action order.',
      consequenceText: 'Seat order clear: +8 chips. Wording drift: -6 chips.',
      insightText: 'Cutoff is before Button in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: keep the anchor label precise.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Anchor label checks support faster seat reads.',
      tradeoffText: 'Confirm the anchor, or click by habit.',
      consequenceText: 'Anchor confirmed: +8 chips. Habit miss: -6 chips.',
      insightText: 'Button remains the anchor seat label.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: check the middle seat label.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'Middle-seat labels break anchor-only habits.',
      tradeoffText: 'Read the label, or overuse anchor cues.',
      consequenceText:
          'Middle seat read: +8 chips. Anchor-only miss: -6 chips.',
      insightText: 'Hijack is a position label in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: finish with the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Close by returning to a blind label check.',
      tradeoffText: 'Finish on a clear blind label, or end on drift.',
      consequenceText: 'Blind close: +8 chips. Drift close: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
  ],

  'world9_spine_followup_v1_b2': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Small Blind: seat label first, then decision.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Separate seat recognition from later hand decisions.',
      tradeoffText: 'Name the seat first, or mix tasks together.',
      consequenceText: 'Tasks separated: +8 chips. Mixed tasks: -6 chips.',
      insightText: 'Seat labels and action decisions are different checks.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: confirm the second blind seat.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Blind-seat order should remain stable under repetition.',
      tradeoffText: 'Confirm the blind seat, or drift on labels.',
      consequenceText: 'Blind confirmed: +8 chips. Label drift: -6 chips.',
      insightText: 'Big Blind is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: keep late-seat labels distinct.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Late-seat labels should stay precise under repetition.',
      tradeoffText: 'Keep labels distinct, or merge late seats.',
      consequenceText:
          'Late-seat precision: +8 chips. Merged labels: -6 chips.',
      insightText: 'Cutoff and Button are different late seats.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: close on the anchor seat label.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Closing on the anchor confirms the full seat map.',
      tradeoffText: 'Close on the anchor, or finish on drift.',
      consequenceText: 'Anchor close: +8 chips. Drift close: -6 chips.',
      insightText: 'Close on Button to reset the seat map.',
    ),
  ],

  'world10_spine_campaign_v1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: anchor the seat map first.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Start each set by anchoring the seat map on Button.',
      tradeoffText: 'Anchor the map first, or guess seat labels.',
      consequenceText: 'Anchor set: +8 chips. Seat guess: -6 chips.',
      insightText: 'Button is the anchor for seat-order drills.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: identify the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Blind seats are position labels in this set.',
      tradeoffText: 'Name the blind seat now, or mix labels later.',
      consequenceText: 'Blind seat read: +8 chips. Mixed labels: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Big Blind completes the two-seat blind pair.',
      tradeoffText: 'Complete the pair, or leave the map incomplete.',
      consequenceText:
          'Blind pair complete: +8 chips. Incomplete map: -6 chips.',
      insightText: 'BB is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: continue seat order away from blinds.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'This step checks seat labels beyond Button and blinds.',
      tradeoffText: 'Use seat-order labels, or click by shape only.',
      consequenceText: 'Seat order held: +8 chips. Label drift: -6 chips.',
      insightText: 'Hijack is a seat-order label, not an action-order rule.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: confirm the late-position seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Cutoff is a seat label in the late-position group.',
      tradeoffText: 'Confirm the label, or mix late seats.',
      consequenceText:
          'Late seat confirmed: +8 chips. Late-seat miss: -6 chips.',
      insightText: 'Cutoff sits before Button in seat order.',
    ),
  ],

  'world10_spine_followup_v1_b0': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Button: restart from the seat-order anchor.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'B0 repeats core labels with short checks.',
      tradeoffText: 'Start from the anchor, or guess the map.',
      consequenceText: 'Anchor restart: +8 chips. Guess start: -6 chips.',
      insightText: 'Restart from Button when the map feels noisy.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: verify blind label quickly.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Short followup keeps blind labels accurate.',
      tradeoffText: 'Verify the seat label, or drift by memory.',
      consequenceText: 'Blind verified: +8 chips. Label drift: -6 chips.',
      insightText: 'Blind labels should stay automatic.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: complete the blind pair again.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Pairing SB and BB prevents blind-label misses.',
      tradeoffText: 'Complete the pair, or leave a gap.',
      consequenceText: 'Pair complete: +8 chips. Gap left: -6 chips.',
      insightText: 'SB and BB should be checked as a pair.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: finish on the late seat label.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Final step checks a non-blind late seat label.',
      tradeoffText: 'Finish with seat order, or revert to guessing.',
      consequenceText: 'Late label finish: +8 chips. Guess finish: -6 chips.',
      insightText: 'Cutoff and Button should stay distinct.',
    ),
  ],

  'world10_spine_followup_v1_b1': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Cutoff: seat order before Button.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'This followup reinforces late-seat order only.',
      tradeoffText: 'Use seat-order wording, or imply action order.',
      consequenceText: 'Seat order clear: +8 chips. Wording drift: -6 chips.',
      insightText: 'Cutoff is before Button in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: keep the anchor label precise.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Anchor label checks support faster seat reads.',
      tradeoffText: 'Confirm the anchor, or click by habit.',
      consequenceText: 'Anchor confirmed: +8 chips. Habit miss: -6 chips.',
      insightText: 'Button remains the anchor seat label.',
    ),
    MicroTaskStep(
      prompt: 'Tap Hijack: check the middle seat label.',
      hint: 'Tap Hijack.',
      expectedSeatIds: <String>['hj'],
      contextText: 'Middle-seat labels break anchor-only habits.',
      tradeoffText: 'Read the label, or overuse anchor cues.',
      consequenceText:
          'Middle seat read: +8 chips. Anchor-only miss: -6 chips.',
      insightText: 'Hijack is a position label in seat order.',
    ),
    MicroTaskStep(
      prompt: 'Tap Small Blind: finish with the first blind seat.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Close by returning to a blind label check.',
      tradeoffText: 'Finish on a clear blind label, or end on drift.',
      consequenceText: 'Blind close: +8 chips. Drift close: -6 chips.',
      insightText: 'Small Blind sits immediately left of Button.',
    ),
  ],

  'world10_spine_followup_v1_b2': <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Tap Small Blind: seat label first, then decision.',
      hint: 'Tap Small Blind.',
      expectedSeatIds: <String>['sb'],
      contextText: 'Separate seat recognition from later hand decisions.',
      tradeoffText: 'Name the seat first, or mix tasks together.',
      consequenceText: 'Tasks separated: +8 chips. Mixed tasks: -6 chips.',
      insightText: 'Seat labels and action decisions are different checks.',
    ),
    MicroTaskStep(
      prompt: 'Tap Big Blind: confirm the second blind seat.',
      hint: 'Tap Big Blind.',
      expectedSeatIds: <String>['bb'],
      contextText: 'Blind-seat order should remain stable under repetition.',
      tradeoffText: 'Confirm the blind seat, or drift on labels.',
      consequenceText: 'Blind confirmed: +8 chips. Label drift: -6 chips.',
      insightText: 'Big Blind is the second blind seat.',
    ),
    MicroTaskStep(
      prompt: 'Tap Cutoff: keep late-seat labels distinct.',
      hint: 'Tap Cutoff.',
      expectedSeatIds: <String>['co'],
      contextText: 'Late-seat labels should stay precise under repetition.',
      tradeoffText: 'Keep labels distinct, or merge late seats.',
      consequenceText:
          'Late-seat precision: +8 chips. Merged labels: -6 chips.',
      insightText: 'Cutoff and Button are different late seats.',
    ),
    MicroTaskStep(
      prompt: 'Tap Button: close on the anchor seat label.',
      hint: 'Tap Button.',
      expectedSeatIds: <String>['btn'],
      contextText: 'Closing on the anchor confirms the full seat map.',
      tradeoffText: 'Close on the anchor, or finish on drift.',
      consequenceText: 'Anchor close: +8 chips. Drift close: -6 chips.',
      insightText: 'Close on Button to reset the seat map.',
    ),
  ],
});

const Set<String> kCampaignPackIdsV1 = <String>{
  'world1_act0_table_literacy',
  'world1_act0_action_literacy',
  'world1_act0_street_flow',
  'world1_spine_campaign_v1',
  'world1_spine_followup_v1_b0',
  'world1_spine_followup_v1_b1',
  'world1_spine_followup_v1_b2',
  'world2_spine_campaign_v1',
  'world2_spine_followup_v1_b0',
  'world2_spine_followup_v1_b1',
  'world2_spine_followup_v1_b2',
  'world3_spine_campaign_v1',
  'world3_spine_followup_v1_b0',
  'world3_spine_followup_v1_b1',
  'world3_spine_followup_v1_b2',
  'world4_spine_campaign_v1',
  'world4_spine_followup_v1_b0',
  'world4_spine_followup_v1_b1',
  'world4_spine_followup_v1_b2',
  'world5_spine_campaign_v1',
  'world5_spine_followup_v1_b0',
  'world5_spine_followup_v1_b1',
  'world5_spine_followup_v1_b2',
  'world6_spine_campaign_v1',
  'world6_spine_followup_v1_b0',
  'world6_spine_followup_v1_b1',
  'world6_spine_followup_v1_b2',
  'world7_spine_campaign_v1',
  'world7_spine_followup_v1_b0',
  'world7_spine_followup_v1_b1',
  'world7_spine_followup_v1_b2',
  'world8_spine_campaign_v1',
  'world8_spine_followup_v1_b0',
  'world8_spine_followup_v1_b1',
  'world8_spine_followup_v1_b2',
  'world9_spine_campaign_v1',
  'world9_spine_followup_v1_b0',
  'world9_spine_followup_v1_b1',
  'world9_spine_followup_v1_b2',
  'world10_spine_campaign_v1',
  'world10_spine_followup_v1_b0',
  'world10_spine_followup_v1_b1',
  'world10_spine_followup_v1_b2',
};

int campaignHandCountForPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  if (!kCampaignPackIdsV1.contains(normalized)) {
    return 0;
  }
  final pack = kCampaignPacksV1[normalized];
  return pack?.length ?? 0;
}

bool isCampaignPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  return kCampaignPackIdsV1.contains(normalized);
}

List<String> campaignFollowupPackIdsV1() {
  final ids = <String>[];
  for (final id in kCampaignPackIdsV1) {
    if (id.contains('_spine_followup_v1_b0') ||
        id.contains('_spine_followup_v1_b1') ||
        id.contains('_spine_followup_v1_b2')) {
      ids.add(id);
    }
  }
  ids.sort();
  return ids;
}
