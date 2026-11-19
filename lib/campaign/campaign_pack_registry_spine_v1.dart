part of 'campaign_pack_registry_v1.dart';

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
        'In W6, you started thinking in range buckets instead of one exact hand. Now W7 shows how visible cards narrow which hands are still possible.',
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

MicroTaskStep _w8StackDepthRiskStepV1({
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

List<MicroTaskStep> _w8StackDepthRiskCampaignPackV1() => <MicroTaskStep>[
  _w8StackDepthRiskStepV1(
    prompt: 'Short stack, less room. Tap Button after reading the risk.',
    hint: 'Fewer chips behind means all-in pressure can arrive faster.',
    boardCards: <String>['Ah', '7d', '2c'],
    contextText:
        'W8 starts stack depth and risk: the amount behind changes how much room a decision has before all-in pressure.',
    tradeoffText: 'Read stack depth first, or treat every stack as equal risk.',
    consequenceText:
        'Stack-depth read: +8 chips. Equal-stack mistake: -6 chips.',
    insightText:
        'A short stack has less room behind, so risk can tighten quickly.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Deep stack, more future room. Tap Cutoff.',
    hint: 'More chips behind can leave more future betting decisions.',
    expectedSeatId: 'co',
    boardCards: <String>['Ks', '8d', '3c'],
    contextText:
        'A deeper stack does not remove risk; it changes how much room remains.',
    tradeoffText: 'Account for chips behind, or judge only the current bet.',
    consequenceText: 'Room counted: +8 chips. Current-bet tunnel: -6 chips.',
    insightText:
        'Deeper stacks can create more future risk because more chips remain behind.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Pot is large relative to stack. Tap Big Blind.',
    hint: 'Large pot plus shallow stack can create commitment pressure.',
    expectedSeatId: 'bb',
    boardCards: <String>['Qh', '7s', '2d'],
    contextText:
        'W8 compares the pot with the stack behind before choosing a risk line.',
    tradeoffText:
        'Compare stack to pot, or ignore how quickly chips can be committed.',
    consequenceText: 'Commitment read: +8 chips. Risk miss: -6 chips.',
    insightText:
        'When the pot is large relative to the stack, later decisions can become all-in faster.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Same hand, different stack depth. Tap Hijack.',
    hint: 'The shallower stack reaches all-in pressure faster.',
    expectedSeatId: 'hj',
    boardCards: <String>['Jh', '9d', '4s'],
    contextText:
        'Transfer W8: the hand can look similar while stack-depth risk changes.',
    tradeoffText:
        'Use the stack signal, or copy the same action across both stacks.',
    consequenceText: 'Risk transfer: +8 chips. Copy-paste leak: -6 chips.',
    insightText:
        'Stack depth changes risk even when the visible cards look familiar.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Final W8 check: risk before all-in. Tap Small Blind.',
    hint: 'Read chips behind before deciding how much risk remains.',
    expectedSeatId: 'sb',
    boardCards: <String>['Td', '6c', '2h'],
    contextText:
        'W8 stays claim-safe: stack depth shapes risk, not the final result.',
    tradeoffText: 'Name the stack-depth risk, or assume the action is forced.',
    consequenceText:
        'Claim-safe close: +8 chips. Forced-action leak: -6 chips.',
    insightText:
        'Stack depth helps control risk because it shows how close the spot is to all-in pressure.',
  ),
];

List<MicroTaskStep> _w8StackDepthRiskFollowupB0V1() => <MicroTaskStep>[
  _w8StackDepthRiskStepV1(
    prompt: 'Shallow stack warning. Tap Button.',
    hint: 'All-in pressure can arrive with fewer chips behind.',
    contextText: 'B0 repairs the first miss: shallow means less risk room.',
    tradeoffText: 'Respect the shallow stack, or treat it like a deep stack.',
    consequenceText: 'Repair held: +8 chips. Stack-size leak: -6 chips.',
    insightText: 'Short stacks can make risk tighter before the next decision.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Deep stack leaves room. Tap Cutoff.',
    hint: 'More chips behind can create later decisions.',
    expectedSeatId: 'co',
    contextText: 'B0 repeats deep-stack room in a new spot.',
    tradeoffText: 'Count chips behind, or stop at the first bet only.',
    consequenceText: 'Room counted: +8 chips. One-street tunnel: -6 chips.',
    insightText: 'Deep stacks keep more future risk in play.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Stack-to-pot pressure. Tap Big Blind.',
    hint: 'Compare what is behind with what is already in the pot.',
    expectedSeatId: 'bb',
    contextText: 'B0 reinforces commitment pressure.',
    tradeoffText: 'Compare stack to pot, or miss the commitment signal.',
    consequenceText: 'Pressure read: +8 chips. Commitment miss: -6 chips.',
    insightText: 'Pot size and stack behind combine into the risk read.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Transfer W8 risk. Tap Hijack.',
    hint: 'Same cards can carry different stack-depth risk.',
    expectedSeatId: 'hj',
    contextText: 'B0 closes with stack-depth transfer.',
    tradeoffText: 'Transfer the risk signal, or copy the same line by habit.',
    consequenceText: 'Transfer held: +8 chips. Habit line: -6 chips.',
    insightText: 'Stack depth changes the risk profile of a familiar spot.',
  ),
];

List<MicroTaskStep> _w8StackDepthRiskFollowupB1V1() => <MicroTaskStep>[
  _w8StackDepthRiskStepV1(
    prompt: 'Medium stack, moderate room. Tap Button.',
    hint: 'Not shallow, not deep: still count chips behind.',
    contextText: 'B1 adds middle-stack judgment.',
    tradeoffText: 'Keep the stack read, or force every stack into one label.',
    consequenceText: 'Middle read: +8 chips. Forced label: -6 chips.',
    insightText: 'Stack depth can sit between clear shallow and clear deep.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'All-in threshold is close. Tap Small Blind.',
    hint: 'Fewer chips behind lowers the threshold.',
    expectedSeatId: 'sb',
    contextText: 'B1 makes all-in threshold explicit.',
    tradeoffText: 'Respect the threshold, or ignore how close risk is.',
    consequenceText: 'Threshold read: +8 chips. Risk drift: -6 chips.',
    insightText: 'A lower all-in threshold asks for cleaner risk control.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Deep stack, no automatic safety. Tap Cutoff.',
    hint: 'More room can still mean more future risk.',
    expectedSeatId: 'co',
    contextText: 'B1 prevents deep-stack autopilot.',
    tradeoffText: 'Use deeper-stack room, or assume deeper always means safe.',
    consequenceText: 'Risk balanced: +8 chips. Autopilot leak: -6 chips.',
    insightText: 'More room is useful, but it does not remove risk.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Final B1 transfer: stack first. Tap Big Blind.',
    hint: 'Read the stack before picking the risk line.',
    expectedSeatId: 'bb',
    contextText: 'B1 closes with risk-control transfer.',
    tradeoffText: 'Transfer stack-depth control, or decide from cards alone.',
    consequenceText: 'Control held: +8 chips. Cards-only miss: -6 chips.',
    insightText: 'Stack depth is part of the decision, not background noise.',
  ),
];

List<MicroTaskStep> _w8StackDepthRiskFollowupB2V1() => <MicroTaskStep>[
  _w8StackDepthRiskStepV1(
    prompt: 'Two stack sizes, one risk choice. Tap Button.',
    hint: 'The shallower stack needs tighter all-in awareness.',
    contextText: 'B2 combines shallow and deeper stack comparison.',
    tradeoffText: 'Compare the stacks, or treat both risk lines the same.',
    consequenceText: 'Comparison read: +8 chips. Same-risk leak: -6 chips.',
    insightText: 'Different stack depths create different risk pressure.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Pot pressure grows. Tap Cutoff.',
    hint: 'A bigger pot relative to stack raises commitment pressure.',
    expectedSeatId: 'co',
    contextText: 'B2 separates pot pressure from raw card strength.',
    tradeoffText: 'Use the pot-to-stack clue, or ignore commitment risk.',
    consequenceText: 'Commitment read: +8 chips. Pressure miss: -6 chips.',
    insightText: 'The pot and stack behind jointly shape all-in pressure.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Deeper stack keeps options. Tap Small Blind.',
    hint: 'More chips behind can preserve more choices.',
    expectedSeatId: 'sb',
    contextText: 'B2 balances the shallow-stack warning.',
    tradeoffText: 'Keep options in view, or force the spot too soon.',
    consequenceText: 'Options read: +8 chips. Forced-line leak: -6 chips.',
    insightText: 'Deeper stacks can keep more decision paths open.',
  ),
  _w8StackDepthRiskStepV1(
    prompt: 'Final W8 transfer: stack depth controls risk. Tap Big Blind.',
    hint: 'Stack, pot, and all-in pressure belong together.',
    expectedSeatId: 'bb',
    contextText: 'B2 closes W8 before tournament pressure.',
    tradeoffText: 'Use the risk-control frame, or claim one forced answer.',
    consequenceText: 'Safe close: +8 chips. Forced-answer leak: -6 chips.',
    insightText:
        'Stack depth controls how much risk remains before all-in pressure.',
  ),
];

MicroTaskStep _w9TournamentPressureStepV1({
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

List<MicroTaskStep> _w9TournamentPressureCampaignPackV1() => <MicroTaskStep>[
  _w9TournamentPressureStepV1(
    prompt: 'Near bubble, survival pressure rises. Tap Button.',
    hint: 'Tournament pressure can make chip risk tighter.',
    boardCards: <String>['Ah', '9d', '4c'],
    contextText:
        'W9 starts tournament pressure: survival, bubble, and payout context can change how risky a chip decision feels.',
    tradeoffText:
        'Read tournament pressure, or treat it like the same chip spot every time.',
    consequenceText: 'Pressure read: +8 chips. Context miss: -6 chips.',
    insightText:
        'Tournament pressure shapes risk because survival can carry extra value.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Medium stack under pressure. Tap Cutoff.',
    hint: 'Risk premium means extra care before risking chips.',
    expectedSeatId: 'co',
    boardCards: <String>['Ks', '8d', '3c'],
    contextText:
        'A medium stack may need more caution when tournament pressure is high.',
    tradeoffText: 'Account for risk premium, or take the same risk blindly.',
    consequenceText: 'Premium respected: +8 chips. Pressure leak: -6 chips.',
    insightText:
        'Risk premium raises the bar before putting tournament life or leverage at risk.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Short stack can ladder by surviving. Tap Big Blind.',
    hint: 'Survival pressure can matter more near payout jumps.',
    expectedSeatId: 'bb',
    boardCards: <String>['Qh', '7s', '2d'],
    contextText: 'W9 compares chip risk with payout-ladder survival pressure.',
    tradeoffText: 'Weigh survival, or ignore the tournament ladder.',
    consequenceText: 'Ladder read: +8 chips. Survival miss: -6 chips.',
    insightText:
        'A payout ladder can make survival more valuable than in a cash-game frame.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Same hand, different tournament pressure. Tap Hijack.',
    hint: 'Higher pressure can require more caution.',
    expectedSeatId: 'hj',
    boardCards: <String>['Jh', 'Th', '5c'],
    contextText:
        'Transfer W9: identical cards can carry different pressure in different tournament states.',
    tradeoffText: 'Use the pressure context, or copy the same line by habit.',
    consequenceText: 'Transfer read: +8 chips. Habit line: -6 chips.',
    insightText:
        'Tournament pressure changes incentives without predicting the result.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Final W9 check: pressure before risk. Tap Small Blind.',
    hint: 'Bubble, survival, and stack position shape the risk bar.',
    expectedSeatId: 'sb',
    boardCards: <String>['9s', '8d', '4h'],
    contextText:
        'W9 closes as tournament-pressure discipline before player adjustment.',
    tradeoffText: 'Name the pressure first, or act as if context is absent.',
    consequenceText: 'Discipline close: +8 chips. Context-free leak: -6 chips.',
    insightText:
        'Tournament pressure guides risk by combining survival, payout context, and chip position.',
  ),
];

List<MicroTaskStep> _w9TournamentPressureFollowupB0V1() => <MicroTaskStep>[
  _w9TournamentPressureStepV1(
    prompt: 'Bubble pressure warning. Tap Button.',
    hint: 'Survival pressure can tighten risky actions.',
    contextText: 'B0 repairs the first miss: bubble context matters.',
    tradeoffText: 'Respect survival pressure, or ignore tournament context.',
    consequenceText: 'Repair held: +8 chips. Bubble miss: -6 chips.',
    insightText: 'Near the bubble, survival can raise the risk bar.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Risk premium check. Tap Cutoff.',
    hint: 'Extra tournament risk asks for extra care.',
    expectedSeatId: 'co',
    contextText: 'B0 repeats risk-premium discipline.',
    tradeoffText: 'Use the premium, or take risk as if pressure is absent.',
    consequenceText: 'Premium read: +8 chips. Pressure leak: -6 chips.',
    insightText: 'Risk premium is a caution signal, not a forced action.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Payout ladder pressure. Tap Big Blind.',
    hint: 'Survival can gain value near payout jumps.',
    expectedSeatId: 'bb',
    contextText: 'B0 reinforces ladder pressure.',
    tradeoffText: 'Weigh survival, or ignore the payout context.',
    consequenceText: 'Ladder read: +8 chips. Context miss: -6 chips.',
    insightText: 'The ladder can make survival more valuable.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Transfer W9 pressure. Tap Hijack.',
    hint: 'Higher pressure can need more caution.',
    expectedSeatId: 'hj',
    contextText: 'B0 closes with tournament-pressure transfer.',
    tradeoffText: 'Transfer the pressure signal, or copy the same line.',
    consequenceText: 'Transfer held: +8 chips. Copy leak: -6 chips.',
    insightText: 'Tournament context can change the right risk threshold.',
  ),
];

List<MicroTaskStep> _w9TournamentPressureFollowupB1V1() => <MicroTaskStep>[
  _w9TournamentPressureStepV1(
    prompt: 'Lower pressure, more room. Tap Button.',
    hint: 'Less tournament pressure can lower the risk premium.',
    contextText: 'B1 adds lower-pressure comparison.',
    tradeoffText: 'Compare pressure levels, or over-tighten every decision.',
    consequenceText: 'Pressure compared: +8 chips. One-label leak: -6 chips.',
    insightText:
        'Pressure can be higher or lower depending on tournament state.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'High pressure does not force all-in. Tap Small Blind.',
    hint: 'Pressure changes caution, not every action.',
    expectedSeatId: 'sb',
    contextText: 'B1 prevents pressure autopilot.',
    tradeoffText: 'Use caution, or treat pressure as an automatic shove.',
    consequenceText: 'Caution read: +8 chips. Autopilot leak: -6 chips.',
    insightText:
        'Tournament pressure guides risk; it does not force one action.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Chip position matters. Tap Cutoff.',
    hint: 'Stack position is part of tournament pressure.',
    expectedSeatId: 'co',
    contextText: 'B1 connects pressure to chip position.',
    tradeoffText: 'Use chip position, or ignore who is at risk.',
    consequenceText: 'Position read: +8 chips. Context miss: -6 chips.',
    insightText: 'The same pressure can hit stacks differently.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Final B1 transfer: survival context. Tap Big Blind.',
    hint: 'Survival pressure belongs in the risk read.',
    expectedSeatId: 'bb',
    contextText: 'B1 closes with survival-pressure transfer.',
    tradeoffText: 'Transfer survival context, or use a cash-game frame.',
    consequenceText: 'Transfer read: +8 chips. Context drift: -6 chips.',
    insightText: 'Tournament pressure is a context signal for risk decisions.',
  ),
];

List<MicroTaskStep> _w9TournamentPressureFollowupB2V1() => <MicroTaskStep>[
  _w9TournamentPressureStepV1(
    prompt: 'Bubble plus medium stack. Tap Button.',
    hint: 'Risk premium can rise when survival matters.',
    contextText: 'B2 combines bubble and stack-position pressure.',
    tradeoffText: 'Combine the signals, or read only the cards.',
    consequenceText: 'Combined read: +8 chips. Cards-only miss: -6 chips.',
    insightText: 'Bubble pressure and stack position work together.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Ladder jump changes caution. Tap Cutoff.',
    hint: 'Payout context can raise the caution level.',
    expectedSeatId: 'co',
    contextText: 'B2 separates payout pressure from raw chip count.',
    tradeoffText: 'Use the ladder, or ignore survival value.',
    consequenceText: 'Ladder read: +8 chips. Survival miss: -6 chips.',
    insightText: 'Payout context can change the risk threshold.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Lower pressure spot. Tap Small Blind.',
    hint: 'Less pressure can reduce the risk premium.',
    expectedSeatId: 'sb',
    contextText: 'B2 balances the high-pressure warning.',
    tradeoffText: 'Adjust pressure down, or over-tighten every decision.',
    consequenceText: 'Adjustment read: +8 chips. Over-tight leak: -6 chips.',
    insightText: 'Not every tournament spot carries the same pressure.',
  ),
  _w9TournamentPressureStepV1(
    prompt: 'Final W9 transfer: pressure shapes risk. Tap Big Blind.',
    hint: 'Tournament, survival, and pressure belong together.',
    expectedSeatId: 'bb',
    contextText: 'B2 closes W9 before player-adjustment work.',
    tradeoffText: 'Use the pressure frame, or claim one forced answer.',
    consequenceText: 'Safe close: +8 chips. Forced-answer leak: -6 chips.',
    insightText:
        'Tournament pressure shapes risk without guaranteeing the outcome.',
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
    prompt: 'Player read first: tight blinds keep folding. Tap Button.',
    hint: 'W10 starts with one player tendency before one adjustment.',
    expectedSeatId: 'btn',
    boardCards: <String>['Ah', 'Kd', '4c'],
    contextText:
        'W10 Player Adjustment asks which player tendency changes the plan after the baseline strategy is known.',
    tradeoffText:
        'Tag the player tendency, or make a random adjustment with no read.',
    consequenceText: 'Tendency tag: +8 chips. Random adjustment: -6 chips.',
    insightText: 'A reliable player read supports one measured exploit lever.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'One-lever adjustment: blinds overfold. Tap Cutoff.',
    hint: 'A tight-folding profile supports a small late-position widen.',
    expectedSeatId: 'co',
    boardCards: <String>['Qs', '9d', '3c'],
    contextText:
        'Player Adjustment changes one lever at a time so the exploit stays trackable.',
    tradeoffText:
        'Open a little wider from late position, or rewrite the whole plan.',
    consequenceText: 'Measured exploit: +8 chips. Over-adjustment: -6 chips.',
    insightText:
        'One lever gives feedback; many simultaneous changes create noise.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Guardrail check: only two odd hands so far. Tap Big Blind.',
    hint: 'Sample size controls how far the player adjustment can go.',
    expectedSeatId: 'bb',
    boardCards: <String>['Jh', '8h', '2s'],
    contextText:
        'A player read can be useful before it is perfect, but thin evidence keeps the exploit small.',
    tradeoffText:
        'Make a small adjustment and keep watching, or hard-counter too soon.',
    consequenceText: 'Guardrail held: +8 chips. Overreaction: -6 chips.',
    insightText:
        'Player Adjustment is not guessing; it is measured response to repeated behavior.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Transfer check: tag, lever, guardrail. Tap Hijack.',
    hint: 'The W10 loop is tendency tag -> one lever -> guardrail.',
    expectedSeatId: 'hj',
    boardCards: <String>['Td', '7c', '2h'],
    contextText:
        'This is the player-adjustment bridge into real-play transfer.',
    tradeoffText:
        'Run the structured loop, or let intuition change too many actions.',
    consequenceText: 'Structured exploit: +8 chips. Chaotic read: -6 chips.',
    insightText:
        'W10 closes when one player tendency creates one disciplined adjustment.',
  ),
  _w10BetPurposeStepV1(
    prompt: 'Final W10 check: player read before exploit. Tap Small Blind.',
    hint: 'Keep the exploit tied to one observed tendency.',
    expectedSeatId: 'sb',
    boardCards: <String>['As', 'Qc', '5d'],
    contextText: 'W10 closes on Player Adjustment, not a betting taxonomy.',
    tradeoffText:
        'Keep the adjustment tied to the read, or drift into unsupported changes.',
    consequenceText: 'Adjustment loop: +8 chips. Unsupported drift: -6 chips.',
    insightText:
        'Player Adjustment means tag one tendency, choose one lever, and keep guardrails.',
  ),
];

List<MicroTaskStep> _w10BetPurposeFollowupB0V1() =>
    _w10BetPurposeCampaignPackV1();
List<MicroTaskStep> _w10BetPurposeFollowupB1V1() =>
    _w10BetPurposeCampaignPackV1();
List<MicroTaskStep> _w10BetPurposeFollowupB2V1() =>
    _w10BetPurposeCampaignPackV1();
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
    prompt: 'Session plan first: choose one focus. Tap Button.',
    hint: 'Real Play Transfer starts before the first hand.',
    expectedSeatId: 'btn',
    boardCards: <String>['Ah', '7d', '2c'],
    contextText:
        'W11 turns app lessons into a real session loop: one plan, one trigger, one review output.',
    tradeoffText:
        'Pick one session focus, or overload the session with too many goals.',
    consequenceText: 'One-focus plan: +8 chips. Overload: -6 chips.',
    insightText:
        'A simple plan gives live play one thing to notice and review.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'Live trigger appears: blinds overfold. Tap Cutoff.',
    hint: 'Use one prepared trigger-action pair.',
    expectedSeatId: 'co',
    boardCards: <String>['9h', '8d', '7c'],
    contextText:
        'Real Play Transfer applies a prepared cue when a repeated table trigger appears.',
    tradeoffText:
        'Activate one trigger, or apply every possible adjustment at once.',
    consequenceText: 'Trigger transfer: +8 chips. Multi-lever noise: -6 chips.',
    insightText: 'One trigger-action pair is easier to execute and review.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'After session: choose one leak and one fix. Tap Big Blind.',
    hint: 'The review loop turns play into tomorrow action.',
    expectedSeatId: 'bb',
    boardCards: <String>['Kh', 'Th', '4s'],
    contextText:
        'W11 closes the real-play loop by selecting one repeated leak and one concrete next-session fix.',
    tradeoffText:
        'Create one repair target, or write long notes with no next action.',
    consequenceText: 'Review loop: +8 chips. Fuzzy review: -6 chips.',
    insightText:
        'Transfer compounds when each session outputs one action for the next session.',
  ),
  _w11BoardTextureStepV1(
    prompt: 'W11 check: plan, trigger, review. Tap Hijack.',
    hint: 'The transfer loop repeats across real sessions.',
    expectedSeatId: 'hj',
    boardCards: <String>['Jc', 'Tc', '8d'],
    contextText:
        'Real Play Transfer is the practical loop that carries prior worlds into live decisions.',
    tradeoffText:
        'Run the loop, or treat live play as disconnected from training.',
    consequenceText: 'Transfer loop: +8 chips. Disconnected play: -6 chips.',
    insightText:
        'W11 is admitted by the real-play loop, not by a board-texture route.',
  ),
];

List<MicroTaskStep> _w11BoardTextureFollowupB0V1() =>
    _w11BoardTextureCampaignPackV1();
List<MicroTaskStep> _w11BoardTextureFollowupB1V1() =>
    _w11BoardTextureCampaignPackV1();
List<MicroTaskStep> _w11BoardTextureFollowupB2V1() =>
    _w11BoardTextureCampaignPackV1();
MicroTaskStep _w12ReviewPayoffStepV1({
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

List<MicroTaskStep> _w12ReviewPayoffCampaignPackV1() => <MicroTaskStep>[
  _w12ReviewPayoffStepV1(
    prompt: 'Process first after a noisy result. Tap Button.',
    hint: 'Mindset Bridge judges the decision before the outcome.',
    expectedSeatId: 'btn',
    boardCards: <String>['Qh', 'Jh', '8c'],
    contextText:
        'W12 Mindset Bridge keeps process quality separate from one short-term result.',
    tradeoffText:
        'Audit the decision process, or let the result grade everything.',
    consequenceText: 'Process anchor: +8 chips. Outcome trap: -6 chips.',
    insightText:
        'A stable player reviews process before emotion rewrites the lesson.',
  ),
  _w12ReviewPayoffStepV1(
    prompt: 'Tilt signs appear after a bad beat. Tap Cutoff.',
    hint: 'Reset before the next major spot.',
    expectedSeatId: 'co',
    boardCards: <String>['Ah', 'Th', '4s'],
    contextText:
        'The bridge habit is a short reset: name the emotion, breathe, and re-anchor to the plan.',
    tradeoffText: 'Reset and re-anchor, or chase the lost chips immediately.',
    consequenceText: 'Reset held: +8 chips. Tilt carryover: -6 chips.',
    insightText: 'Reset protects the next decision from the last outcome.',
  ),
  _w12ReviewPayoffStepV1(
    prompt: 'Confidence without ego. Tap Big Blind.',
    hint: 'Strong mindset stays assertive and evidence-led.',
    expectedSeatId: 'bb',
    boardCards: <String>['Kd', '9c', '3s'],
    contextText:
        'W12 keeps confidence from turning into entitlement or point-proving lines.',
    tradeoffText:
        'Follow evidence with calm confidence, or force a line to prove a point.',
    consequenceText: 'Disciplined confidence: +8 chips. Ego line: -6 chips.',
    insightText:
        'Confidence is valuable only while discipline still controls the action.',
  ),
  _w12ReviewPayoffStepV1(
    prompt: 'Mindset bridge close: process, reset, discipline. Tap Hijack.',
    hint: 'W12 closes into Volume I review without opening a new world.',
    expectedSeatId: 'hj',
    boardCards: <String>['Jc', 'Tc', '8d'],
    contextText:
        'The W12 teaching identity is Mindset Bridge. Volume I review remains the post-completion recap destination.',
    tradeoffText:
        'Carry process/reset/discipline to Volume I review, or treat recap as a new world unlock.',
    consequenceText:
        'Terminal-safe bridge: +8 chips. Future-world drift: -6 chips.',
    insightText:
        'W12 closes Volume I habits and hands off to review, not a future world.',
  ),
];

List<MicroTaskStep> _w12ReviewPayoffFollowupB0V1() =>
    _w12ReviewPayoffCampaignPackV1();
List<MicroTaskStep> _w12ReviewPayoffFollowupB1V1() =>
    _w12ReviewPayoffCampaignPackV1();
List<MicroTaskStep> _w12ReviewPayoffFollowupB2V1() =>
    _w12ReviewPayoffCampaignPackV1();
List<MicroTaskStep> _volumeITerminalReviewPackV1() => <MicroTaskStep>[
  MicroTaskStep(
    prompt: 'Volume I review is complete. Start the keep-sharp review.',
    hint: 'Stay in review and keep the Volume I clues sharp.',
    expectedSeatIds: <String>['btn'],
    contextText:
        'Volume I review is complete. This keep-sharp review is intentional. Later worlds stay locked for now.',
    tradeoffText:
        'Use this as a keep-sharp review, or mistake it for a new world.',
    consequenceText: 'Review state held: +8 chips. New-world drift: -6 chips.',
    insightText: 'The next visible activity is review and keep-sharp work.',
  ),
  MicroTaskStep(
    prompt: 'Keep-sharp review: connect the clue stack. Tap Cutoff.',
    hint: 'Review visible cards, range, draw, price, purpose, and texture.',
    expectedSeatIds: <String>['co'],
    contextText:
        'This terminal pack keeps Volume I clues warm without opening a future world.',
    tradeoffText:
        'Review the clue stack, or treat the terminal state as a proof claim.',
    consequenceText: 'Review state clear: +8 chips. Proof overclaim: -6 chips.',
    insightText:
        'This review repeats earlier clues without making a proof claim.',
  ),
  MicroTaskStep(
    prompt: 'Keep-sharp review: name the missed cue. Tap Big Blind.',
    hint: 'A missed cue can be range, draw, call price, purpose, or texture.',
    expectedSeatIds: <String>['bb'],
    contextText:
        'The terminal state is for review, explanation, and modest repair language.',
    tradeoffText: 'Name the missed cue, or overclaim future results.',
    consequenceText: 'Cue named: +8 chips. Overclaim: -6 chips.',
    insightText:
        'Volume I can be reviewed here; no next-world promise is made.',
  ),
  MicroTaskStep(
    prompt: 'Volume I complete',
    hint: 'Review stays open. Tap Small Blind to keep this clue sharp.',
    expectedSeatIds: <String>['sb'],
    contextText: 'You can now slow down and read the table before choosing.',
    tradeoffText: 'Review stays open. Later worlds stay locked for now.',
    consequenceText: 'Review close: +8 chips. Unlock assumption: -6 chips.',
    insightText: 'Keep the Volume I clues sharp in Review.',
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
