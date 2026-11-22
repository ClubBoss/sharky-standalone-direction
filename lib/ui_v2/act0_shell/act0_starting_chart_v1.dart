/// The course's six-max starting chart. Hand keys use standard notation:
/// AA for pairs, AKs for suited hands, and AKo for offsuit hands.
enum Act0ChartGroupV1 { premium, strong, mediumHj, mediumCo, weak }

enum Act0ChartSeatV1 { utg, hj, co, btn, sb, bb }

enum Act0ChartActionV1 { raise, call, fold, priceDecision, notCovered }

/// A proven prefix through the hero's decision. Use [notCovered] for limps,
/// multiple entrants, reraises, short-stack rules or opponent adaptations.
enum Act0ChartPrefixV1 {
  unopened,
  utgOpen,
  hjOpen,
  coOpen,
  btnOpen,
  sbOpen,
  notCovered,
}

const act0ChartRanksV1 = 'AKQJT98765432';

const act0ChartGroupsV1 = <Act0ChartGroupV1, Set<String>>{
  Act0ChartGroupV1.premium: {'AA', 'KK', 'QQ', 'AKs'},
  Act0ChartGroupV1.strong: {'JJ', 'TT', 'AKo', 'AQs', 'AJs'},
  Act0ChartGroupV1.mediumHj: {'AQo', 'AJo', 'KQs', 'KQo', 'ATs', 'ATo'},
  Act0ChartGroupV1.mediumCo: {
    '99',
    '88',
    '77',
    '66',
    '55',
    '44',
    '33',
    '22',
    'KJs',
    'KJo',
    'QJs',
    'QJo',
    'KTs',
    'KTo',
    'QTs',
    'QTo',
  },
};

final act0ChartHandsV1 = Set<String>.unmodifiable({
  for (var high = 0; high < act0ChartRanksV1.length; high++) ...[
    '${act0ChartRanksV1[high]}${act0ChartRanksV1[high]}',
    for (var low = high + 1; low < act0ChartRanksV1.length; low++)
      for (final form in ['s', 'o'])
        '${act0ChartRanksV1[high]}${act0ChartRanksV1[low]}$form',
  ],
});

Act0ChartGroupV1 act0ChartGroupV1(String hand) {
  if (!act0ChartHandsV1.contains(hand)) {
    throw ArgumentError.value(hand, 'hand', 'Not a canonical chart hand');
  }
  for (final entry in act0ChartGroupsV1.entries) {
    if (entry.value.contains(hand)) return entry.key;
  }
  return Act0ChartGroupV1.weak;
}

const act0ChartThreeBetsV1 = {'AA', 'KK', 'QQ', 'AKs', 'AKo'};
const act0ChartStrongCallsV1 = {'JJ', 'TT', 'AQs', 'AJs'};
const act0ChartButtonCallsV1 = {'KQs', 'KQo', 'KJs', 'QJs'};

Act0ChartActionV1 act0ChartActionV1(
  String hand,
  Act0ChartSeatV1 heroSeat,
  Act0ChartPrefixV1 actionBeforeHero,
) {
  const raise = Act0ChartActionV1.raise;
  const call = Act0ChartActionV1.call;
  const fold = Act0ChartActionV1.fold;
  const uncovered = Act0ChartActionV1.notCovered;
  if (actionBeforeHero == Act0ChartPrefixV1.notCovered ||
      !act0ChartHandsV1.contains(hand)) {
    return uncovered;
  }
  final group = act0ChartGroupV1(hand);
  if (actionBeforeHero == Act0ChartPrefixV1.unopened) {
    if (heroSeat.index > Act0ChartSeatV1.btn.index) return uncovered;
    return switch (group) {
      Act0ChartGroupV1.premium || Act0ChartGroupV1.strong => raise,
      Act0ChartGroupV1.mediumHj =>
        heroSeat.index >= Act0ChartSeatV1.hj.index ? raise : fold,
      Act0ChartGroupV1.mediumCo =>
        heroSeat.index >= Act0ChartSeatV1.co.index ? raise : fold,
      Act0ChartGroupV1.weak => fold,
    };
  }

  if (heroSeat == Act0ChartSeatV1.bb) return Act0ChartActionV1.priceDecision;
  if (heroSeat == Act0ChartSeatV1.sb &&
      actionBeforeHero == Act0ChartPrefixV1.btnOpen) {
    return switch (group) {
      Act0ChartGroupV1.premium ||
      Act0ChartGroupV1.strong ||
      Act0ChartGroupV1.mediumHj => raise,
      Act0ChartGroupV1.mediumCo || Act0ChartGroupV1.weak => fold,
    };
  }
  final inPosition = switch (actionBeforeHero) {
    Act0ChartPrefixV1.hjOpen =>
      heroSeat == Act0ChartSeatV1.co || heroSeat == Act0ChartSeatV1.btn,
    Act0ChartPrefixV1.coOpen => heroSeat == Act0ChartSeatV1.btn,
    _ => false,
  };
  if (!inPosition) return uncovered;
  if (act0ChartThreeBetsV1.contains(hand)) return raise;
  if (act0ChartStrongCallsV1.contains(hand) ||
      (heroSeat == Act0ChartSeatV1.btn &&
          act0ChartButtonCallsV1.contains(hand))) {
    return call;
  }
  return fold;
}
