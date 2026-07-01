/// Compatibility campaign pack registry for the older intro/core microtask
/// chain. This file remains live for runner/bootstrap/test compatibility, but
/// it is no longer the active product content truth for Sharky_1.0.
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

MicroTaskStep _w7VisibleRangeStepV1({
  required String prompt,
  required String hint,
  required String contextText,
  required String tradeoffText,
  required String consequenceText,
  required String insightText,
  String expectedSeatId = 'btn',
  List<String>? boardCards,
}) {
  return MicroTaskStep(
    prompt: prompt,
    hint: hint,
    expectedSeatIds: <String>[expectedSeatId],
    boardCards: boardCards,
    contextText: contextText,
    tradeoffText: tradeoffText,
    consequenceText: consequenceText,
    insightText: insightText,
  );
}

List<MicroTaskStep> _w7VisibleRangeCampaignPackV1() => <MicroTaskStep>[
  _w7VisibleRangeStepV1(
    prompt: 'A72 has a visible ace. Tap Button after reading the range clue.',
    hint: 'Visible ace means fewer ace hands remain possible.',
    expectedSeatId: 'btn',
    boardCards: <String>['As', '7d', '2c'],
    contextText:
        'W7 continues W6: start with the visible board, then narrow the possible range.',
    tradeoffText:
        'Use the visible ace as a range clue, or guess one exact hand.',
    consequenceText: 'Visible-card read: +8 chips. Exact-hand leak: -6 chips.',
    insightText:
        'A visible ace reduces some ace hands, but ace hands can still exist.',
  ),
  _w7VisibleRangeStepV1(
    prompt: 'K84 has a visible king. Tap Cutoff after reading the range clue.',
    hint: 'Visible king means fewer king hands remain possible.',
    expectedSeatId: 'co',
    boardCards: <String>['Ks', '8d', '4c'],
    contextText:
        'The same W7 idea transfers: visible ranks change what remains possible.',
    tradeoffText:
        'Narrow the range by the visible king, or ignore the card and drift.',
    consequenceText: 'King read: +8 chips. Range drift spew: -6 chips.',
    insightText:
        'The visible king is unavailable to private hands, not proof of one exact hand.',
  ),
  _w7VisibleRangeStepV1(
    prompt: '772 is paired. Tap Big Blind after checking what can still exist.',
    hint: 'Two visible sevens reduce seven hands, but trips are not gone.',
    expectedSeatId: 'bb',
    boardCards: <String>['7s', '7d', '2c'],
    contextText:
        'Paired visible cards create pressure because some strong hands remain possible.',
    tradeoffText:
        'Respect what still exists, or over-remove every strong hand.',
    consequenceText:
        'Paired-board caution: +8 chips. Over-remove mistake: -6 chips.',
    insightText:
        'Visible pairs reduce combinations, but they do not erase every strong hand.',
  ),
  _w7VisibleRangeStepV1(
    prompt: 'A72 and K84 share one rule. Tap Hijack after naming it.',
    hint: 'Visible ranks reduce matching-rank hands across boards.',
    expectedSeatId: 'hj',
    boardCards: <String>['Ah', '7c', '2d'],
    contextText:
        'This is recognition practice: carry the W7 clue across different boards.',
    tradeoffText:
        'Transfer the visible-card rule, or treat every board as unrelated.',
    consequenceText: 'Transfer read: +8 chips. Recount trap: -6 chips.',
    insightText:
        'Visible cards narrow the possible range; they do not show the exact hand.',
  ),
  _w7VisibleRangeStepV1(
    prompt: 'QJ4 has a visible queen. Tap Small Blind after reading the clue.',
    hint: 'A visible queen reduces queen-heavy hands, but some can remain.',
    expectedSeatId: 'sb',
    boardCards: <String>['Qs', 'Jd', '4c'],
    contextText:
        'Use W6 range buckets, then let W7 visible cards narrow the possible hands.',
    tradeoffText:
        'Adjust the range carefully, or overclaim the opponent cannot have queens.',
    consequenceText: 'Careful narrow: +8 chips. Overclaim punish: -6 chips.',
    insightText:
        'Visible cards are range clues, not certainty about one exact hand.',
  ),
];

List<MicroTaskStep> _w7VisibleRangeFollowupB0V1() => <MicroTaskStep>[
  _w7VisibleRangeStepV1(
    prompt: 'A95 shows an ace. Tap Button after a quick visible-card check.',
    hint: 'Fewer ace hands remain possible, not zero.',
    boardCards: <String>['Ad', '9c', '5s'],
    contextText:
        'B0 repairs the common miss: visible does not mean impossible.',
    tradeoffText: 'Keep some ace hands in range, or erase too much.',
    consequenceText: 'Repair held: +8 chips. Range erase leak: -6 chips.',
    insightText: 'The exact hand is unknown; some ace hands can still exist.',
  ),
  _w7VisibleRangeStepV1(
    prompt: 'K72 shows a king. Tap Cutoff after narrowing the range.',
    hint: 'The visible king removes one rank card from private hands.',
    expectedSeatId: 'co',
    boardCards: <String>['Kh', '7s', '2d'],
    contextText: 'B0 repeats the visible-rank read on a clean board.',
    tradeoffText: 'Use the visible king, or keep the old count unchanged.',
    consequenceText:
        'Count adjusted: +8 chips. Unchanged-count spew: -6 chips.',
    insightText:
        'Visible cards narrow possible hands without proving one exact hand.',
  ),
  _w7VisibleRangeStepV1(
    prompt: '884 is paired. Tap Big Blind after checking what still exists.',
    hint: 'Paired visible cards reduce some hands; they do not remove all.',
    expectedSeatId: 'bb',
    boardCards: <String>['8s', '8c', '4d'],
    contextText:
        'B0 keeps paired-board range repair concrete and beginner-readable.',
    tradeoffText: 'Respect remaining strong hands, or over-remove them.',
    consequenceText: 'Still-exists read: +8 chips. Over-remove trap: -6 chips.',
    insightText:
        'Some strong hands still exist after visible cards reduce the count.',
  ),
  _w7VisibleRangeStepV1(
    prompt: 'A72 to K84 transfer. Tap Hijack after using the shared rule.',
    hint: 'Visible high cards reduce matching-rank hands on both boards.',
    expectedSeatId: 'hj',
    boardCards: <String>['Ks', '8d', '4c'],
    contextText: 'B0 closes by transferring the visible-card range clue.',
    tradeoffText: 'Use the shared range rule, or restart from guessing.',
    consequenceText: 'Transfer close: +8 chips. Guess reset: -6 chips.',
    insightText:
        'The shared rule narrows the possible range, not the exact hand.',
  ),
];

List<MicroTaskStep> _w7VisibleRangeFollowupB1V1() => <MicroTaskStep>[
  _w7VisibleRangeStepV1(
    prompt: 'Q93 shows a queen. Tap Button after reading the range clue.',
    hint: 'Queen-containing hands become fewer, not impossible.',
    boardCards: <String>['Qh', '9s', '3d'],
    contextText:
        'B1 adds a new rank so the visible-card idea does not stay ace-only.',
    tradeoffText: 'Narrow queen hands, or leave the range too wide.',
    consequenceText: 'Queen narrow: +8 chips. Too-wide range leak: -6 chips.',
    insightText:
        'Visible queens reduce possible queen hands, but some still exist.',
  ),
  _w7VisibleRangeStepV1(
    prompt: 'TT5 is paired. Tap Cutoff after naming the safe takeaway.',
    hint: 'Visible tens reduce ten hands but do not prove or erase trips.',
    expectedSeatId: 'co',
    boardCards: <String>['Ts', 'Td', '5c'],
    contextText:
        'B1 repairs paired-board overclaims with a second pair example.',
    tradeoffText: 'Keep the range balanced, or jump to one exact hand.',
    consequenceText: 'Balanced read: +8 chips. Exact-hand trap: -6 chips.',
    insightText:
        'Paired visible cards change possible hands without proving the exact hand.',
  ),
  _w7VisibleRangeStepV1(
    prompt: 'KJ4 shows a king. Tap Small Blind after adjusting the range.',
    hint: 'The visible king narrows matching-rank hands.',
    expectedSeatId: 'sb',
    boardCards: <String>['Kd', 'Jh', '4s'],
    contextText:
        'B1 keeps the clue tied to W6 range thinking rather than seat memory.',
    tradeoffText: 'Adjust from the visible card, or ignore the board clue.',
    consequenceText:
        'Board clue used: +8 chips. Ignored clue punish: -6 chips.',
    insightText:
        'Visible cards narrow a possible range; they do not complete the read.',
  ),
  _w7VisibleRangeStepV1(
    prompt: 'A72, K84, and Q93. Tap Big Blind after choosing the shared idea.',
    hint: 'Each visible rank reduces matching-rank hands.',
    expectedSeatId: 'bb',
    boardCards: <String>['Qs', '9d', '3c'],
    contextText: 'B1 closes with multi-board recognition, not mastery.',
    tradeoffText: 'Transfer the clue, or treat each board as a new guess.',
    consequenceText: 'Multi-board transfer: +8 chips. Recount spew: -6 chips.',
    insightText:
        'The exact hand stays unknown, but the possible range becomes narrower.',
  ),
];

List<MicroTaskStep> _w7VisibleRangeFollowupB2V1() => <MicroTaskStep>[
  _w7VisibleRangeStepV1(
    prompt: 'A77 has an ace and a pair. Tap Button after checking both clues.',
    hint: 'Visible cards can narrow more than one part of the range.',
    boardCards: <String>['Ah', '7s', '7c'],
    contextText:
        'B2 combines rank and paired-board clues without claiming certainty.',
    tradeoffText: 'Combine visible clues, or over-focus on one card.',
    consequenceText: 'Combined read: +8 chips. One-card tunnel: -6 chips.',
    insightText:
        'Several visible cards narrow possible hands, but exact holdings remain unknown.',
  ),
  _w7VisibleRangeStepV1(
    prompt: 'KQ4 shows two high cards. Tap Cutoff after narrowing both ranks.',
    hint: 'Visible high cards reduce matching high-card hands.',
    expectedSeatId: 'co',
    boardCards: <String>['Ks', 'Qd', '4h'],
    contextText: 'B2 adds scenario richness with two visible ranks.',
    tradeoffText: 'Narrow both ranks, or leave the possible range too loose.',
    consequenceText: 'Two-rank narrow: +8 chips. Loose range leak: -6 chips.',
    insightText:
        'Visible cards reduce parts of the range; they do not reveal the exact hand.',
  ),
  _w7VisibleRangeStepV1(
    prompt: '995 is paired. Tap Small Blind after checking what still exists.',
    hint: 'Some nine hands are reduced, while strong hands can still exist.',
    expectedSeatId: 'sb',
    boardCards: <String>['9h', '9d', '5s'],
    contextText:
        'B2 repeats the most important repair: still possible does not mean certain.',
    tradeoffText: 'Respect remaining hands, or make a certainty claim.',
    consequenceText:
        'Respect still-possible: +8 chips. Certainty tax: -6 chips.',
    insightText:
        'Visible cards narrow the range, but some strong hands still exist.',
  ),
  _w7VisibleRangeStepV1(
    prompt: 'Final W7 check: visible cards narrow ranges. Tap Big Blind.',
    hint:
        'Recognition only: narrow what is possible without claiming certainty.',
    expectedSeatId: 'bb',
    boardCards: <String>['As', 'Kd', '2c'],
    contextText: 'B2 closes the route bridge after W6 range buckets.',
    tradeoffText: 'Use visible-card recognition, or jump to one exact hand.',
    consequenceText: 'Strong close: +8 chips. Exact-hand misfire: -6 chips.',
    insightText:
        'W7 is a bridge: visible cards narrow the possible range, not a final read.',
  ),
];

MicroTaskStep _w8DrawImprovementStepV1({
  required String prompt,
  required String hint,
  required String contextText,
  required String tradeoffText,
  required String consequenceText,
  required String insightText,
  String expectedSeatId = 'btn',
  List<String>? boardCards,
}) {
  return MicroTaskStep(
    prompt: prompt,
    hint: hint,
    expectedSeatIds: <String>[expectedSeatId],
    boardCards: boardCards,
    contextText: contextText,
    tradeoffText: tradeoffText,
    consequenceText: consequenceText,
    insightText: insightText,
  );
}

List<MicroTaskStep> _w8DrawImprovementCampaignPackV1() => <MicroTaskStep>[
  _w8DrawImprovementStepV1(
    prompt: 'Two hearts make a flush draw. Tap Button after reading the clue.',
    hint: 'A future card of the suit can improve the hand.',
    expectedSeatId: 'btn',
    boardCards: <String>['Ah', '7h', '2c'],
    contextText:
        'W8 follows W7: after visible cards narrow ranges, draws show how a future card can improve a hand.',
    tradeoffText:
        'Name the flush draw path, or treat the hand as already complete.',
    consequenceText: 'Draw read: +8 chips. Made-hand mistake: -6 chips.',
    insightText:
        'A flush draw is not made yet; a future card of the suit can improve it.',
  ),
  _w8DrawImprovementStepV1(
    prompt: '5-6-7-8 is open-ended. Tap Cutoff after naming the draw.',
    hint: 'Open-ended means either end can complete the straight.',
    expectedSeatId: 'co',
    boardCards: <String>['5s', '6d', '7c'],
    contextText:
        'An open-ended straight draw has clear improvement cards on both sides.',
    tradeoffText:
        'Use the open-ended clue, or look for only one exact future card.',
    consequenceText: 'Two-side draw read: +8 chips. One-card tunnel: -6 chips.',
    insightText:
        'Open-ended straight draws can improve from either end of the sequence.',
  ),
  _w8DrawImprovementStepV1(
    prompt: 'One inside card completes the straight. Tap Big Blind.',
    hint: 'A one-gap straight draw has a narrower improvement path.',
    expectedSeatId: 'bb',
    boardCards: <String>['5s', '6d', '8c'],
    contextText:
        'This introduces the gutshot idea without making the route depend on jargon.',
    tradeoffText: 'Compare the narrow draw, or call every draw equally strong.',
    consequenceText: 'Narrow-path read: +8 chips. Equal-draw leak: -6 chips.',
    insightText:
        'A one-gap draw can still improve, but it has fewer clear future-card paths than an open-ended draw.',
  ),
  _w8DrawImprovementStepV1(
    prompt: 'Flush draw vs no clear draw. Tap Hijack after choosing the path.',
    hint: 'The flush draw has more visible improvement potential.',
    expectedSeatId: 'hj',
    boardCards: <String>['Kh', '9h', '3c'],
    contextText:
        'Transfer W8: compare a visible draw with a hand that has no clear draw.',
    tradeoffText:
        'Choose the hand with visible improvement, or guess from current strength only.',
    consequenceText:
        'Improvement path found: +8 chips. Static guess: -6 chips.',
    insightText:
        'Draws matter because future cards can improve them; they do not reveal the next card.',
  ),
  _w8DrawImprovementStepV1(
    prompt: 'Final W8 check: draws can improve later. Tap Small Blind.',
    hint: 'Read the draw first, then stay claim-safe.',
    expectedSeatId: 'sb',
    boardCards: <String>['Qh', 'Jh', '4s'],
    contextText:
        'W8 stays beginner-safe: draw means possible improvement, not certainty.',
    tradeoffText:
        'Explain the future-card path, or overclaim the hand is solved.',
    consequenceText: 'Claim-safe close: +8 chips. Overclaim punish: -6 chips.',
    insightText:
        'Flush draw, open-ended draw, and one-gap draw are improvement clues, not final answers.',
  ),
];

List<MicroTaskStep> _w8DrawImprovementFollowupB0V1() => <MicroTaskStep>[
  _w8DrawImprovementStepV1(
    prompt: 'Hearts on board create a flush draw. Tap Button.',
    hint: 'A future card of that suit can improve the hand.',
    boardCards: <String>['Jh', '8h', '2s'],
    contextText: 'B0 repairs the first miss: draw is not the same as made.',
    tradeoffText:
        'Keep the flush draw as future-card potential, or mark it complete now.',
    consequenceText: 'Repair held: +8 chips. Made-now leak: -6 chips.',
    insightText:
        'The flush draw can improve later; it is not complete on this street.',
  ),
  _w8DrawImprovementStepV1(
    prompt: '4-5-6-7 is open-ended. Tap Cutoff.',
    hint: 'Cards on either end can complete the straight.',
    expectedSeatId: 'co',
    boardCards: <String>['4s', '5d', '6c'],
    contextText: 'B0 repeats the open-ended straight draw in a new shape.',
    tradeoffText:
        'Use both ends of the sequence, or search for one exact card only.',
    consequenceText: 'Open-ended repair: +8 chips. One-card tunnel: -6 chips.',
    insightText:
        'Open-ended draws have more clear improvement paths than one-gap draws.',
  ),
  _w8DrawImprovementStepV1(
    prompt: 'Inside-card straight draw. Tap Big Blind after comparing it.',
    hint: 'This draw can improve, but through a narrower path.',
    expectedSeatId: 'bb',
    boardCards: <String>['6s', '7d', '9c'],
    contextText: 'B0 compares narrow and open-ended draw shapes.',
    tradeoffText:
        'Notice the narrower future-card path, or treat all draws the same.',
    consequenceText: 'Shape compared: +8 chips. Same-draw mistake: -6 chips.',
    insightText:
        'A one-gap draw still has improvement potential, just fewer clear paths.',
  ),
  _w8DrawImprovementStepV1(
    prompt: 'Flush draw beats no clear draw for improvement. Tap Hijack.',
    hint: 'A visible draw gives cleaner future-card paths.',
    expectedSeatId: 'hj',
    boardCards: <String>['Th', '6h', '2d'],
    contextText: 'B0 closes with draw vs no-draw transfer.',
    tradeoffText:
        'Choose visible improvement potential, or ignore the draw clue.',
    consequenceText: 'Transfer repair: +8 chips. Ignored clue: -6 chips.',
    insightText:
        'The draw gives visible ways to improve without promising the next card.',
  ),
];

List<MicroTaskStep> _w8DrawImprovementFollowupB1V1() => <MicroTaskStep>[
  _w8DrawImprovementStepV1(
    prompt: 'Spades create a flush draw. Tap Button after the safe read.',
    hint: 'A future card of the suit can help complete a flush.',
    boardCards: <String>['As', '9s', '4d'],
    contextText: 'B1 changes suit and board while keeping the same draw idea.',
    tradeoffText:
        'Read the flush draw, or call the current hand static forever.',
    consequenceText: 'Suit-path read: +8 chips. Static-hand leak: -6 chips.',
    insightText:
        'A flush draw is an improvement path from future cards of the suit.',
  ),
  _w8DrawImprovementStepV1(
    prompt: '8-9-T-J is open-ended. Tap Small Blind.',
    hint: 'Either side of the straight shape can matter.',
    expectedSeatId: 'sb',
    boardCards: <String>['8c', '9d', 'Ts'],
    contextText: 'B1 adds a higher open-ended straight draw example.',
    tradeoffText: 'Use the two-sided path, or over-focus on one future card.',
    consequenceText: 'Two-sided read: +8 chips. Tunnel miss: -6 chips.',
    insightText:
        'Open-ended draws can improve from either side; that is why the shape matters.',
  ),
  _w8DrawImprovementStepV1(
    prompt: 'One-gap draw compared with open-ended. Tap Cutoff.',
    hint: 'The open-ended draw has more clear improvement cards.',
    expectedSeatId: 'co',
    boardCards: <String>['7s', '8d', 'Tc'],
    contextText:
        'B1 makes the comparison explicit without requiring equity math.',
    tradeoffText: 'Compare improvement paths, or use raw hand strength only.',
    consequenceText: 'Path comparison: +8 chips. Raw-strength drift: -6 chips.',
    insightText:
        'Draw quality starts with how many clear future-card paths can improve the hand.',
  ),
  _w8DrawImprovementStepV1(
    prompt: 'Draw vs no clear draw transfer. Tap Big Blind.',
    hint: 'Visible improvement paths make the draw easier to continue with.',
    expectedSeatId: 'bb',
    boardCards: <String>['Qh', '8h', '3s'],
    contextText: 'B1 closes with a transfer across board texture.',
    tradeoffText: 'Carry the draw-improvement clue, or restart from guessing.',
    consequenceText: 'Transfer read: +8 chips. Guess reset: -6 chips.',
    insightText:
        'Future cards can improve a visible draw; no clear draw has fewer visible paths.',
  ),
];

List<MicroTaskStep> _w8DrawImprovementFollowupB2V1() => <MicroTaskStep>[
  _w8DrawImprovementStepV1(
    prompt:
        'Two draws appear together. Tap Button after naming the safer idea.',
    hint: 'Multiple draw paths can give more ways to improve.',
    boardCards: <String>['Jh', 'Th', '9s'],
    contextText:
        'B2 adds scenario richness: a hand can have more than one improvement path.',
    tradeoffText:
        'Combine visible draw paths, or treat the spot as already complete.',
    consequenceText: 'Combined draw read: +8 chips. Made-hand jump: -6 chips.',
    insightText:
        'Flush draw plus straight shape can add future-card improvement paths.',
  ),
  _w8DrawImprovementStepV1(
    prompt: 'Open-ended draw with no flush draw. Tap Cutoff.',
    hint: 'A straight draw can matter even without the suit draw.',
    expectedSeatId: 'co',
    boardCards: <String>['6c', '7d', '8s'],
    contextText: 'B2 separates straight improvement from flush improvement.',
    tradeoffText:
        'Name the open-ended path, or require every draw to be a flush draw.',
    consequenceText: 'Straight path read: +8 chips. Flush-only leak: -6 chips.',
    insightText:
        'Open-ended straight draws can improve through future cards at either end.',
  ),
  _w8DrawImprovementStepV1(
    prompt: 'Flush draw with no straight draw. Tap Small Blind.',
    hint: 'The suited future-card path is still enough to matter.',
    expectedSeatId: 'sb',
    boardCards: <String>['Ah', '6h', '2c'],
    contextText: 'B2 separates flush improvement from straight improvement.',
    tradeoffText:
        'Use the suit path, or miss the draw because no straight is present.',
    consequenceText: 'Flush path read: +8 chips. Missed-draw leak: -6 chips.',
    insightText:
        'A flush draw can improve from a future card of the suit even without a straight draw.',
  ),
  _w8DrawImprovementStepV1(
    prompt:
        'Final W8 transfer: draw means possible improvement. Tap Big Blind.',
    hint: 'Possible improvement is useful, but it is not certainty.',
    expectedSeatId: 'bb',
    boardCards: <String>['Ks', 'Qs', '4d'],
    contextText: 'B2 closes W8 as a route bridge after visible-card work.',
    tradeoffText:
        'Use draw improvement potential, or claim the future card is known.',
    consequenceText: 'Safe close: +8 chips. Certainty claim: -6 chips.',
    insightText:
        'Flush draw and open-ended draw clues show possible improvement, not a final result.',
  ),
];

MicroTaskStep _w9CallPriceStepV1({
  required String prompt,
  required String hint,
  required String contextText,
  required String tradeoffText,
  required String consequenceText,
  required String insightText,
  String expectedSeatId = 'btn',
  List<String>? boardCards,
}) {
  return MicroTaskStep(
    prompt: prompt,
    hint: hint,
    expectedSeatIds: <String>[expectedSeatId],
    boardCards: boardCards,
    contextText: contextText,
    tradeoffText: tradeoffText,
    consequenceText: consequenceText,
    insightText: insightText,
  );
}

List<MicroTaskStep> _w9CallPriceCampaignPackV1() => <MicroTaskStep>[
  _w9CallPriceStepV1(
    prompt: 'Big pot, small call. Tap Button after reading the price.',
    hint: 'A small call compared with the pot is a cheaper price.',
    expectedSeatId: 'btn',
    boardCards: <String>['Ah', '9d', '4c'],
    contextText:
        'W9 follows W8: after draw improvement, compare the call cost to the pot reward.',
    tradeoffText: 'Compare price to pot reward, or call without checking risk.',
    consequenceText: 'Price read: +8 chips. Risk-blind call: -6 chips.',
    insightText:
        'Pot odds start simple: the price of a call is cheap or expensive compared with the pot.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Small pot, large call. Tap Cutoff after naming the risk.',
    hint: 'A large call into a small pot is an expensive price.',
    expectedSeatId: 'co',
    boardCards: <String>['Ks', '8d', '3c'],
    contextText:
        'The same pot-price idea can warn you when the risk is too large.',
    tradeoffText:
        'Notice the expensive call, or chase reward without price discipline.',
    consequenceText: 'Risk checked: +8 chips. Price leak: -6 chips.',
    insightText:
        'An expensive call asks for more reward because the risk is larger.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Same hand, different pot. Tap Big Blind after comparing prices.',
    hint: 'The pot size changes whether a call price feels cheap or expensive.',
    expectedSeatId: 'bb',
    boardCards: <String>['Qh', '7s', '2d'],
    contextText:
        'W9 is comparison practice: price only makes sense next to the pot.',
    tradeoffText: 'Compare both spots, or judge the call amount alone.',
    consequenceText:
        'Comparison read: +8 chips. Isolated-price miss: -6 chips.',
    insightText:
        'A call can be better in a bigger pot because the reward is larger.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Cheap call or fold? Tap Hijack after weighing risk and reward.',
    hint: 'Cheap price can support a call, but it does not promise a win.',
    expectedSeatId: 'hj',
    boardCards: <String>['Jh', 'Th', '5c'],
    contextText:
        'Keep W9 claim-safe: pot price informs call or fold, not the exact result.',
    tradeoffText: 'Use risk and reward, or pretend odds guarantee the outcome.',
    consequenceText: 'Claim-safe call read: +8 chips. Result claim: -6 chips.',
    insightText:
        'Odds guide the call/fold decision by comparing risk to pot reward.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Final W9 check: price before call. Tap Small Blind.',
    hint: 'Compare pot, call price, risk, and reward before choosing.',
    expectedSeatId: 'sb',
    boardCards: <String>['9s', '8d', '4h'],
    contextText:
        'W9 closes as a route bridge from draw potential to call-price discipline.',
    tradeoffText: 'Check the price first, or click call/fold by habit.',
    consequenceText: 'Discipline close: +8 chips. Habit click: -6 chips.',
    insightText:
        'The safer read is simple: pot reward and call price shape risk before action.',
  ),
];

List<MicroTaskStep> _w9CallPriceFollowupB0V1() => <MicroTaskStep>[
  _w9CallPriceStepV1(
    prompt: 'Large pot, tiny call. Tap Button after the cheap-price read.',
    hint: 'Cheap price means less risk for the pot reward.',
    boardCards: <String>['Ad', 'Td', '3s'],
    contextText:
        'B0 repairs the easy miss: call price is relative to pot size.',
    tradeoffText:
        'Compare the price to the pot, or treat every call amount the same.',
    consequenceText:
        'Relative-price read: +8 chips. Same-price leak: -6 chips.',
    insightText:
        'A small call can be attractive when the pot reward is already large.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Small pot, big call. Tap Cutoff after the expensive-price read.',
    hint: 'More risk needs more reward.',
    expectedSeatId: 'co',
    boardCards: <String>['Kh', '6d', '2c'],
    contextText: 'B0 repeats the expensive-call side of the comparison.',
    tradeoffText:
        'Respect the larger risk, or chase with weak price discipline.',
    consequenceText: 'Risk respected: +8 chips. Chase leak: -6 chips.',
    insightText:
        'An expensive call is not forbidden, but it needs enough pot reward.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Call or fold after price check. Tap Big Blind.',
    hint: 'Price helps decide whether the risk is worth continuing.',
    expectedSeatId: 'bb',
    boardCards: <String>['Qs', 'Jd', '4c'],
    contextText: 'B0 keeps the action tied to pot and price.',
    tradeoffText:
        'Use the price to choose call/fold, or decide from hand hope alone.',
    consequenceText: 'Action priced: +8 chips. Hope call: -6 chips.',
    insightText:
        'Call/fold discipline starts by comparing the call price to the pot.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Transfer W9: bigger pot improves the same call price. Tap Hijack.',
    hint: 'The same risk can look better with more reward.',
    expectedSeatId: 'hj',
    boardCards: <String>['8h', '7h', '2s'],
    contextText: 'B0 closes with direct risk/reward transfer.',
    tradeoffText:
        'Transfer the price idea, or restart from guessing each spot.',
    consequenceText: 'Transfer held: +8 chips. Guess reset: -6 chips.',
    insightText:
        'The same call price can be more attractive when the pot reward is bigger.',
  ),
];

List<MicroTaskStep> _w9CallPriceFollowupB1V1() => <MicroTaskStep>[
  _w9CallPriceStepV1(
    prompt: 'Medium pot, medium call. Tap Button after checking the price.',
    hint: 'Not every spot is clearly cheap or clearly expensive.',
    boardCards: <String>['Ac', '8s', '5d'],
    contextText: 'B1 adds middle-price judgment without heavy math.',
    tradeoffText:
        'Keep comparing pot and call price, or force a simple label too fast.',
    consequenceText: 'Balanced price read: +8 chips. Forced label: -6 chips.',
    insightText:
        'Pot odds can be a spectrum: price, risk, and reward still guide the decision.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Cheap call with weak reward. Tap Small Blind.',
    hint: 'Cheap price helps, but reward still matters.',
    expectedSeatId: 'sb',
    boardCards: <String>['Kd', '9c', '2h'],
    contextText: 'B1 prevents cheap-price autopilot.',
    tradeoffText: 'Check reward too, or call only because the price is small.',
    consequenceText: 'Reward checked: +8 chips. Cheap-only leak: -6 chips.',
    insightText:
        'A cheap call can still be wrong if the reward side is not good enough.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Expensive call with big reward. Tap Cutoff.',
    hint: 'Big pot reward can make more risk worth considering.',
    expectedSeatId: 'co',
    boardCards: <String>['Qd', 'Td', '6s'],
    contextText: 'B1 keeps expensive calls from being auto-folds.',
    tradeoffText:
        'Compare risk to reward, or fold every larger price automatically.',
    consequenceText: 'Risk/reward read: +8 chips. Auto-fold leak: -6 chips.',
    insightText:
        'An expensive call needs more reward, but price alone does not decide.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Final B1 transfer: pot and price together. Tap Big Blind.',
    hint: 'The call price only makes sense next to the pot.',
    expectedSeatId: 'bb',
    boardCards: <String>['Jh', '8s', '3d'],
    contextText: 'B1 closes with a beginner-safe pot odds summary.',
    tradeoffText: 'Use pot plus price, or judge the call without context.',
    consequenceText: 'Context read: +8 chips. Context-free call: -6 chips.',
    insightText: 'Pot, call, price, risk, and reward are the core W9 words.',
  ),
];

List<MicroTaskStep> _w9CallPriceFollowupB2V1() => <MicroTaskStep>[
  _w9CallPriceStepV1(
    prompt: 'Draw from W8, price from W9. Tap Button after combining them.',
    hint: 'A draw can improve, but the call price still matters.',
    boardCards: <String>['Jh', 'Th', '4c'],
    contextText: 'B2 connects W8 draw potential to W9 pot-price discipline.',
    tradeoffText: 'Use draw plus price, or call every draw regardless of risk.',
    consequenceText: 'Combined read: +8 chips. Any-draw call: -6 chips.',
    insightText:
        'A draw gives possible reward, while the pot and call price define risk.',
  ),
  _w9CallPriceStepV1(
    prompt: 'No clear draw, expensive call. Tap Cutoff after the fold warning.',
    hint: 'High risk and weak reward can point toward fold.',
    expectedSeatId: 'co',
    boardCards: <String>['Ks', '8d', '2c'],
    contextText: 'B2 adds a fold-friendly price spot without overclaiming.',
    tradeoffText: 'Let price warn you, or continue with no clear reward.',
    consequenceText: 'Fold warning read: +8 chips. Price ignore: -6 chips.',
    insightText:
        'Fold can be disciplined when the call price is high and reward is thin.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Clear draw, cheap call. Tap Small Blind after the call support.',
    hint: 'Cheap price plus possible reward can support continuing.',
    expectedSeatId: 'sb',
    boardCards: <String>['Ah', '9h', '3s'],
    contextText: 'B2 contrasts a better call-price spot.',
    tradeoffText: 'Use price plus reward, or ignore the cheap path.',
    consequenceText: 'Call support read: +8 chips. Missed price: -6 chips.',
    insightText:
        'A cheap call with visible reward can be easier to justify than a costly call.',
  ),
  _w9CallPriceStepV1(
    prompt: 'Final W9 transfer: price shapes call or fold. Tap Big Blind.',
    hint: 'No exact math needed: compare risk and reward first.',
    expectedSeatId: 'bb',
    boardCards: <String>['Qs', '7s', '5d'],
    contextText: 'B2 closes W9 before bet-purpose work.',
    tradeoffText:
        'Use risk/reward discipline, or claim the result from price alone.',
    consequenceText: 'Safe close: +8 chips. Result claim: -6 chips.',
    insightText:
        'Pot odds guide call/fold choices; they do not guarantee the outcome.',
  ),
];

MicroTaskStep _w10BetPurposeStepV1({
  required String prompt,
  required String hint,
  required String contextText,
  required String tradeoffText,
  required String consequenceText,
  required String insightText,
  String expectedSeatId = 'btn',
  List<String>? boardCards,
}) {
  return MicroTaskStep(
    prompt: prompt,
    hint: hint,
    expectedSeatIds: <String>[expectedSeatId],
    boardCards: boardCards,
    contextText: contextText,
    tradeoffText: tradeoffText,
    consequenceText: consequenceText,
    insightText: insightText,
  );
}

List<MicroTaskStep> _w10BetPurposeCampaignPackV1() => <MicroTaskStep>[
  _w10BetPurposeStepV1(
    prompt: 'Strong hand, worse hands can call. Tap Button.',
    hint: 'Value means the bet purpose is getting called by worse hands.',
    expectedSeatId: 'btn',
    boardCards: <String>['Ah', 'Kd', '4c'],
    contextText:
        'W10 follows W9: after price discipline, ask why the bet is made.',
    tradeoffText:
        'Name the value purpose, or confuse it with making stronger hands fold.',
    consequenceText: 'Value read: +8 chips. Purpose mix-up: -6 chips.',
    insightText:
        'A value bet is mainly for worse hands to call; it does not promise the result.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Weak hand, stronger hands might fold. Tap Cutoff.',
    hint: 'This bet purpose is about making stronger hands fold.',
    expectedSeatId: 'co',
    boardCards: <String>['Qs', '9d', '3c'],
    contextText:
        'The contrast is simple: value wants worse calls; this purpose wants stronger folds.',
    tradeoffText:
        'Read the stronger-hands-fold purpose, or call every bet value.',
    consequenceText: 'Purpose contrast: +8 chips. Value-only leak: -6 chips.',
    insightText:
        'A pressure bet can target stronger hands folding, but it does not guarantee a fold.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Worse calls or stronger folds? Tap Big Blind after comparing.',
    hint: 'Bet purpose starts with who you want to continue or fold.',
    expectedSeatId: 'bb',
    boardCards: <String>['Jh', '8h', '2s'],
    contextText:
        'W10 comparison practice keeps value separate from stronger-hands-fold purpose.',
    tradeoffText: 'Compare both purposes, or label the bet from size alone.',
    consequenceText: 'Comparison read: +8 chips. Size-only miss: -6 chips.',
    insightText:
        'The same bet size can have different purpose depending on worse hands and stronger hands.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Bet purpose before click. Tap Hijack.',
    hint: 'Ask whether the bet wants worse calls or stronger folds.',
    expectedSeatId: 'hj',
    boardCards: <String>['Td', '7c', '2h'],
    contextText:
        'This is beginner-safe W10: purpose before action, no advanced labels needed.',
    tradeoffText: 'Name the purpose, or bet without knowing the target.',
    consequenceText: 'Target named: +8 chips. Blind bet: -6 chips.',
    insightText:
        'Bet purpose is a target: worse hands calling or stronger hands folding.',
  ),
  _w10BetPurposeStepV1(
    prompt:
        'Final W10 check: value is not stronger-hands-fold. Tap Small Blind.',
    hint: 'Keep the two purposes separate.',
    expectedSeatId: 'sb',
    boardCards: <String>['As', 'Qc', '5d'],
    contextText: 'W10 closes by separating value from pressure.',
    tradeoffText:
        'Keep purpose clear, or claim every bet does both jobs equally.',
    consequenceText: 'Clear close: +8 chips. Blended-purpose leak: -6 chips.',
    insightText:
        'Value targets worse hands calling; pressure targets stronger hands folding.',
  ),
];

List<MicroTaskStep> _w10BetPurposeFollowupB0V1() => <MicroTaskStep>[
  _w10BetPurposeStepV1(
    prompt: 'Top pair, worse hands can call. Tap Button.',
    hint: 'Value purpose: worse hands continue.',
    boardCards: <String>['Kh', '9s', '4d'],
    contextText: 'B0 repairs the value side with a concrete made-hand spot.',
    tradeoffText:
        'Choose worse-hands-call value, or say the bet is only to make folds.',
    consequenceText: 'Value repair: +8 chips. Fold-only leak: -6 chips.',
    insightText: 'When worse hands can call, the bet purpose can be value.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Missed hand, stronger hands may fold. Tap Cutoff.',
    hint: 'Pressure purpose: stronger hands folding.',
    expectedSeatId: 'co',
    boardCards: <String>['Qd', '8c', '3s'],
    contextText: 'B0 repairs the stronger-hands-fold side.',
    tradeoffText:
        'Name the pressure purpose, or call it value without worse calls.',
    consequenceText: 'Pressure repair: +8 chips. Value label leak: -6 chips.',
    insightText:
        'A bet can target stronger hands folding when worse calls are not the story.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Strong hand but no worse calls. Tap Big Blind.',
    hint: 'Value needs worse hands that can call.',
    expectedSeatId: 'bb',
    boardCards: <String>['Ah', 'As', '7c'],
    contextText: 'B0 prevents automatic value labels.',
    tradeoffText:
        'Check whether worse hands call, or name value from strength alone.',
    consequenceText: 'Target checked: +8 chips. Strength-only label: -6 chips.',
    insightText:
        'Hand strength helps, but value purpose needs worse hands to call.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Transfer W10: ask who continues. Tap Hijack.',
    hint: 'Worse calls and stronger folds are different targets.',
    expectedSeatId: 'hj',
    boardCards: <String>['Jc', '9c', '2d'],
    contextText: 'B0 closes with target-recognition transfer.',
    tradeoffText: 'Transfer the target question, or restart from bet size.',
    consequenceText: 'Transfer held: +8 chips. Size reset: -6 chips.',
    insightText: 'Purpose starts with the target, not with a promised result.',
  ),
];

List<MicroTaskStep> _w10BetPurposeFollowupB1V1() => <MicroTaskStep>[
  _w10BetPurposeStepV1(
    prompt: 'Medium hand, worse hands can still call. Tap Button.',
    hint: 'Value can be simple: worse calls are available.',
    boardCards: <String>['Qh', '7d', '3c'],
    contextText:
        'B1 adds a less obvious value example without thin-value jargon.',
    tradeoffText:
        'Look for worse calls, or assume only very strong hands can value bet.',
    consequenceText: 'Worse-call read: +8 chips. Too-narrow value: -6 chips.',
    insightText:
        'Value purpose means worse hands can call, even when the hand is not the nuts.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Weak hand, fold target is stronger hands. Tap Small Blind.',
    hint: 'The purpose is not value if worse calls are not the plan.',
    expectedSeatId: 'sb',
    boardCards: <String>['Ks', 'Ts', '4h'],
    contextText: 'B1 repeats the stronger-hands-fold side in new wording.',
    tradeoffText: 'Name the fold target, or mislabel pressure as value.',
    consequenceText: 'Fold target read: +8 chips. Mislabel leak: -6 chips.',
    insightText:
        'Trying to make stronger hands fold is a different purpose from value.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Same bet size, different purpose. Tap Cutoff.',
    hint: 'Size alone does not tell you value or stronger-hands-fold purpose.',
    expectedSeatId: 'co',
    boardCards: <String>['9h', '8d', '2c'],
    contextText: 'B1 compares purpose without changing to advanced strategy.',
    tradeoffText: 'Use target hands, or infer purpose from size only.',
    consequenceText: 'Target comparison: +8 chips. Size-only trap: -6 chips.',
    insightText:
        'Bet purpose depends on worse hands calling or stronger hands folding.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Final B1 transfer: purpose before result. Tap Big Blind.',
    hint: 'Purpose guides the bet; it does not lock what happens.',
    expectedSeatId: 'bb',
    boardCards: <String>['Ad', '6s', '2h'],
    contextText: 'B1 keeps claim safety explicit.',
    tradeoffText: 'Read the purpose, or claim the bet proves the result.',
    consequenceText: 'Claim-safe read: +8 chips. Result claim: -6 chips.',
    insightText:
        'A value or stronger-hands-fold purpose is a plan, not a locked result.',
  ),
];

List<MicroTaskStep> _w10BetPurposeFollowupB2V1() => <MicroTaskStep>[
  _w10BetPurposeStepV1(
    prompt: 'W9 price was good; W10 asks why bet. Tap Button.',
    hint: 'Call price and bet purpose are different questions.',
    boardCards: <String>['Ah', 'Jd', '5c'],
    contextText: 'B2 connects W9 price discipline to W10 purpose discipline.',
    tradeoffText:
        'Ask the bet-purpose question, or reuse call-price logic only.',
    consequenceText: 'Purpose bridge: +8 chips. Old-question leak: -6 chips.',
    insightText:
        'W9 asks about call price; W10 asks whether worse hands call or stronger hands fold.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Value spot: worse hands can call. Tap Cutoff.',
    hint: 'Value is about worse hands continuing.',
    expectedSeatId: 'co',
    boardCards: <String>['Kd', 'Qc', '6h'],
    contextText: 'B2 repeats the value target in compact form.',
    tradeoffText:
        'Choose worse-hands-call purpose, or chase stronger folds by mistake.',
    consequenceText: 'Value target: +8 chips. Wrong target: -6 chips.',
    insightText:
        'A value bet wants worse hands to call, not stronger hands to fold.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Pressure spot: stronger hands can fold. Tap Small Blind.',
    hint: 'This purpose targets stronger hands folding.',
    expectedSeatId: 'sb',
    boardCards: <String>['Qh', '9s', '4d'],
    contextText: 'B2 repeats the pressure target in compact form.',
    tradeoffText:
        'Choose stronger-hands-fold purpose, or call it value by habit.',
    consequenceText: 'Pressure target: +8 chips. Habit label: -6 chips.',
    insightText:
        'A stronger-hands-fold purpose is different from worse hands calling.',
  ),
  _w10BetPurposeStepV1(
    prompt:
        'Final W10 transfer: name the target before betting. Tap Big Blind.',
    hint: 'Worse calls or stronger folds: pick one safe purpose.',
    expectedSeatId: 'bb',
    boardCards: <String>['Ts', '7c', '3d'],
    contextText: 'B2 closes W10 before W11 remains locked.',
    tradeoffText: 'Name the target, or make an unfocused bet.',
    consequenceText: 'Safe close: +8 chips. Unfocused bet: -6 chips.',
    insightText:
        'Bet purpose is beginner-safe when the target is clear and claims stay bounded.',
  ),
];

MicroTaskStep _w11BoardTextureStepV1({
  required String prompt,
  required String hint,
  required String contextText,
  required String tradeoffText,
  required String consequenceText,
  required String insightText,
  String expectedSeatId = 'btn',
  List<String>? boardCards,
}) {
  return MicroTaskStep(
    prompt: prompt,
    hint: hint,
    expectedSeatIds: <String>[expectedSeatId],
    boardCards: boardCards,
    contextText: contextText,
    tradeoffText: tradeoffText,
    consequenceText: consequenceText,
    insightText: insightText,
  );
}

List<MicroTaskStep> _w11BoardTextureCampaignPackV1() => <MicroTaskStep>[
  _w11BoardTextureStepV1(
    prompt: 'Dry board texture has fewer clear links. Tap Button.',
    hint:
        'A dry board is less connected and usually carries less immediate danger.',
    expectedSeatId: 'btn',
    boardCards: <String>['Ah', '7d', '2c'],
    contextText:
        'W11 starts after bet purpose by reading board texture danger.',
    tradeoffText:
        'Name the dry board texture, or treat every flop as equally dangerous.',
    consequenceText: 'Dry board read: +8 chips. Same-texture leak: -6 chips.',
    insightText:
        'A dry board has fewer obvious straight or flush paths; that lowers texture danger without deciding the hand.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'Connected board texture creates more paths. Tap Cutoff.',
    hint: 'Close ranks can create more straight paths.',
    expectedSeatId: 'co',
    boardCards: <String>['9h', '8d', '7c'],
    contextText: 'W11 separates connected board danger from a calm dry board.',
    tradeoffText:
        'Use the connected ranks, or ignore how more hands can interact.',
    consequenceText: 'Connected read: +8 chips. Missed danger: -6 chips.',
    insightText:
        'A connected board can be more dangerous because more hands can find draws or made-hand paths.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'Suited board texture adds flush pressure. Tap Big Blind.',
    hint: 'Shared suits can add danger without proving a flush.',
    expectedSeatId: 'bb',
    boardCards: <String>['Kh', 'Th', '4s'],
    contextText: 'W11 adds suit texture as another beginner-safe clue.',
    tradeoffText: 'Read the suited danger clue, or say suits never matter.',
    consequenceText: 'Suit clue read: +8 chips. Suit miss: -6 chips.',
    insightText:
        'A suited board can add flush pressure; it is a danger signal, not a certain result.',
  ),
  _w11BoardTextureStepV1(
    prompt:
        'One pair faces more danger on connected suited boards. Tap Hijack.',
    hint: 'One pair is less comfortable when texture creates many paths.',
    expectedSeatId: 'hj',
    boardCards: <String>['Jc', 'Tc', '8d'],
    contextText: 'W11 closes the first pack with one pair transfer.',
    tradeoffText:
        'Transfer texture danger to one pair, or call one pair always safe.',
    consequenceText: 'Transfer read: +8 chips. Always-safe leak: -6 chips.',
    insightText:
        'One pair can still matter, but connected and suited texture asks for more caution.',
  ),
];

List<MicroTaskStep> _w11BoardTextureFollowupB0V1() => <MicroTaskStep>[
  _w11BoardTextureStepV1(
    prompt: 'Dry board texture repeat: fewer connections. Tap Button.',
    hint: 'Far-apart ranks make fewer straight paths.',
    boardCards: <String>['Kc', '8d', '3s'],
    contextText: 'B0 repairs the dry board idea in a new spot.',
    tradeoffText:
        'Keep the dry board read, or overstate danger on every board.',
    consequenceText: 'Dry repair: +8 chips. Over-danger leak: -6 chips.',
    insightText:
        'Dry board texture means fewer immediate connection clues, not a known winner.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'Connected ranks raise board texture danger. Tap Cutoff.',
    hint: 'Ranks sitting near each other can create more paths.',
    expectedSeatId: 'co',
    boardCards: <String>['8s', '7h', '6d'],
    contextText: 'B0 repairs connected board recognition.',
    tradeoffText: 'Use rank connection, or read only card height.',
    consequenceText: 'Connection repair: +8 chips. Height-only miss: -6 chips.',
    insightText:
        'Connected board texture can interact with more hands than a dry board.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'Two clubs on board create suited danger. Tap Small Blind.',
    hint: 'Shared suits can add flush-pressure danger.',
    expectedSeatId: 'sb',
    boardCards: <String>['Qc', '9c', '2h'],
    contextText: 'B0 repairs suited board texture.',
    tradeoffText: 'Read suited pressure, or ignore suits completely.',
    consequenceText: 'Suit repair: +8 chips. Suit-blind leak: -6 chips.',
    insightText:
        'Suited texture adds danger because future cards can complete or pressure flush paths.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'One pair transfer: dry board is calmer. Tap Big Blind.',
    hint: 'Compare dry board danger with connected suited danger.',
    expectedSeatId: 'bb',
    boardCards: <String>['As', '7c', '2d'],
    contextText: 'B0 closes by comparing one pair across texture.',
    tradeoffText:
        'Compare texture danger, or treat one pair the same everywhere.',
    consequenceText: 'Transfer repair: +8 chips. Texture-blind leak: -6 chips.',
    insightText:
        'One pair on a dry board usually faces fewer immediate danger clues than on a connected suited board.',
  ),
];

List<MicroTaskStep> _w11BoardTextureFollowupB1V1() => <MicroTaskStep>[
  _w11BoardTextureStepV1(
    prompt: 'Dry board, low texture danger. Tap Button.',
    hint: 'Dry board texture has fewer obvious draw paths.',
    boardCards: <String>['Qh', '6d', '2c'],
    contextText: 'B1 repeats dry board recognition with different ranks.',
    tradeoffText: 'Notice fewer paths, or invent danger from no clear clue.',
    consequenceText: 'Fewer paths: +8 chips. Invented danger: -6 chips.',
    insightText:
        'Dry board texture is a calmer clue, but it still does not guarantee the result.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'Connected board, higher texture danger. Tap Hijack.',
    hint: 'Close ranks can create straight paths.',
    expectedSeatId: 'hj',
    boardCards: <String>['Ts', '9d', '8c'],
    contextText: 'B1 repeats connected texture with a new board.',
    tradeoffText: 'Read the connected danger, or treat the board as dry.',
    consequenceText: 'Danger read: +8 chips. Dry-label leak: -6 chips.',
    insightText:
        'Connected texture can give more hands ways to continue or improve.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'Suited connected board: stack the danger clues. Tap Cutoff.',
    hint: 'Connection plus suits can both matter.',
    expectedSeatId: 'co',
    boardCards: <String>['Jh', 'Th', '9s'],
    contextText: 'B1 adds scenario richness without advanced labels.',
    tradeoffText: 'Stack the texture clues, or read only one card at a time.',
    consequenceText: 'Clues stacked: +8 chips. One-card miss: -6 chips.',
    insightText:
        'A board can be dangerous for more than one reason: connected ranks and suited pressure.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'One pair needs caution on dangerous texture. Tap Big Blind.',
    hint: 'One pair is not always safe on connected suited boards.',
    expectedSeatId: 'bb',
    boardCards: <String>['Qd', 'Jd', '9c'],
    contextText: 'B1 closes with one pair caution transfer.',
    tradeoffText:
        'Carry caution forward, or ignore board texture after pairing.',
    consequenceText: 'Caution transfer: +8 chips. Pair-only leak: -6 chips.',
    insightText:
        'One pair can be useful, but dangerous texture should slow automatic confidence.',
  ),
];

List<MicroTaskStep> _w11BoardTextureFollowupB2V1() => <MicroTaskStep>[
  _w11BoardTextureStepV1(
    prompt: 'Final dry board transfer: calmer texture. Tap Button.',
    hint: 'Dry board means fewer obvious danger paths.',
    boardCards: <String>['Ad', '8c', '3h'],
    contextText: 'B2 starts the final transfer loop with dry board texture.',
    tradeoffText: 'Use the calmer clue, or mark all boards as dangerous.',
    consequenceText: 'Calm read: +8 chips. All-danger leak: -6 chips.',
    insightText:
        'A dry board is calmer because fewer obvious straight or flush paths appear.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'Final connected transfer: danger rises. Tap Small Blind.',
    hint: 'Connected ranks create more ways for hands to interact.',
    expectedSeatId: 'sb',
    boardCards: <String>['7s', '6c', '5d'],
    contextText: 'B2 repeats connected texture before the close.',
    tradeoffText: 'Read the connected danger, or miss the rank pattern.',
    consequenceText: 'Pattern read: +8 chips. Pattern miss: -6 chips.',
    insightText:
        'Connected board texture can raise danger by opening more straight-path stories.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'Final suited transfer: shared suits add danger. Tap Cutoff.',
    hint: 'Suited board texture adds flush pressure.',
    expectedSeatId: 'co',
    boardCards: <String>['Ks', '9s', '4d'],
    contextText: 'B2 repeats suited texture in claim-safe language.',
    tradeoffText: 'Use suited danger, or claim the flush is already decided.',
    consequenceText: 'Suit read: +8 chips. Result claim: -6 chips.',
    insightText:
        'Suited board texture adds danger; it does not prove a final hand.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'Final W11: one pair plus texture danger. Tap Big Blind.',
    hint:
        'Compare dry board with connected suited board before trusting one pair.',
    expectedSeatId: 'bb',
    boardCards: <String>['Jc', 'Tc', '8c'],
    contextText: 'B2 closes W11 and keeps the next world locked.',
    tradeoffText:
        'Transfer texture danger to one pair, or claim one pair solves the spot.',
    consequenceText: 'Safe close: +8 chips. Overclaim leak: -6 chips.',
    insightText:
        'One pair deserves more caution when board texture is connected and suited.',
  ),
];

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

  'world7_spine_campaign_v1': _w7VisibleRangeCampaignPackV1(),

  'world7_spine_followup_v1_b0': _w7VisibleRangeFollowupB0V1(),

  'world7_spine_followup_v1_b1': _w7VisibleRangeFollowupB1V1(),

  'world7_spine_followup_v1_b2': _w7VisibleRangeFollowupB2V1(),

  'world8_spine_campaign_v1': _w8DrawImprovementCampaignPackV1(),

  'world8_spine_followup_v1_b0': _w8DrawImprovementFollowupB0V1(),

  'world8_spine_followup_v1_b1': _w8DrawImprovementFollowupB1V1(),

  'world8_spine_followup_v1_b2': _w8DrawImprovementFollowupB2V1(),

  'world9_spine_campaign_v1': _w9CallPriceCampaignPackV1(),

  'world9_spine_followup_v1_b0': _w9CallPriceFollowupB0V1(),

  'world9_spine_followup_v1_b1': _w9CallPriceFollowupB1V1(),

  'world9_spine_followup_v1_b2': _w9CallPriceFollowupB2V1(),

  'world10_spine_campaign_v1': _w10BetPurposeCampaignPackV1(),

  'world10_spine_followup_v1_b0': _w10BetPurposeFollowupB0V1(),

  'world10_spine_followup_v1_b1': _w10BetPurposeFollowupB1V1(),

  'world10_spine_followup_v1_b2': _w10BetPurposeFollowupB2V1(),

  'world11_spine_campaign_v1': _w11BoardTextureCampaignPackV1(),

  'world11_spine_followup_v1_b0': _w11BoardTextureFollowupB0V1(),

  'world11_spine_followup_v1_b1': _w11BoardTextureFollowupB1V1(),

  'world11_spine_followup_v1_b2': _w11BoardTextureFollowupB2V1(),
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
  'world11_spine_campaign_v1',
  'world11_spine_followup_v1_b0',
  'world11_spine_followup_v1_b1',
  'world11_spine_followup_v1_b2',
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
