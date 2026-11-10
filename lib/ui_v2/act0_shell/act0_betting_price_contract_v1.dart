import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

/// Bounded source/option validation over the existing action trail. This is not
/// an answer oracle: legal actions retain their independently authored grades.
enum Act0BettingPriceTruthV1 { unproved, consistent, contradiction }

class Act0BettingPriceResultV1 {
  const Act0BettingPriceResultV1(
    this.truth,
    this.reason, {
    this.callCostBb,
    this.amountToMatchBb,
    this.minimumRaiseToBb,
    this.actorCommittedBb,
    this.additionalCostBb,
    this.potBeforeActionBb,
    this.sourceReady = false,
    this.appliesToWager = true,
  });

  final Act0BettingPriceTruthV1 truth;
  final String reason;

  /// Capped additional call cost; null when the actor stack is unknown.
  final double? callCostBb;

  /// Uncapped outstanding street commitment, derived from the history.
  final double? amountToMatchBb;

  /// Ordinary full-raise threshold; a legal short all-in may be below it.
  /// Null when the source does not establish that threshold.
  final double? minimumRaiseToBb;
  final double? actorCommittedBb;

  /// Chips this actor would add now, distinct from a raise-to street total.
  final double? additionalCostBb;

  /// All recorded contributions, including the outstanding wager, before this
  /// decision. No side-pot eligibility, rake or uncalled returns are inferred.
  final double? potBeforeActionBb;

  /// Complete source facts and consistent displayed claims, independently of
  /// whether this particular option is legal or strategically appropriate.
  final bool sourceReady;
  final bool appliesToWager;

  bool get isContradiction => truth == Act0BettingPriceTruthV1.contradiction;
}

const _unit = 1000000;
const _unknown = Act0BettingPriceTruthV1.unproved;
const _consistent = Act0BettingPriceTruthV1.consistent;
const _contradiction = Act0BettingPriceTruthV1.contradiction;

// Exact existing author intent, not a poker oracle or a table-scope exemption.
// These answers discuss interpretation/frequency, not the next chip movement.
// Identity AND wording must match; numeric and sizing inputs cannot opt out.
// The full catalog test catches removed/changed admissions. Other directions
// remain unresolved; no blanket sibling or correct-answer exemption is used.
const _conceptualAnswers = <(String, String), String>{
  ('turn_river_changes_w5_street_repair', 'small_same_story'):
      'Bet smaller but keep the same old story',
  ('w6_turn_pressure_shift_transfer', 'check_more'): 'Check more often',
  ('w6_turn_pressure_shift_transfer', 'bet_value'): 'Bet for value',
  ('w9_medium_stack_tighten', 'call_wide'): 'Call off as wide as chip EV says',
  ('w9_medium_stack_tighten', 'fold_all'): 'Fold everything until paid',
  ('w9_big_stack_leverage', 'jam_any_two'): 'Jam any two cards every hand',
  ('w9_bubble_short_stack', 'fold_to_money'):
      'Fold every hand until payouts begin',
  ('w9_bubble_short_stack', 'call_off_light'): 'Call off too light',
  ('w9_bubble_table_risk_transfer', 'call_chip_ev'):
      'Call as wide as normal chip EV allows',
  ('w9_checkpoint_bubble_line', 'fold_everything'):
      'Fold every hand until payout',
  ('w9_checkpoint_table_notice', 'fold_everything_bubble'): 'Fold everything',
  ('w10_overbluff_punish', 'fold_everything'):
      'Fold the weakest bluff-catchers first',
  ('w10_overbluff_punish', 'hero_call_any'):
      'Call more rivers without checking blockers',
  ('w10_underbluff_fold_more', 'fold_more'):
      'Fold more marginal bluff-catchers',
  ('w10_underbluff_fold_more', 'call_normal'): 'Call normal baseline frequency',
  ('w10_underbluff_fold_more', 'raise_bluff'): 'Raise bluff more often',
  ('w11_trigger_overcall_flop', 'value_heavier'):
      'Bet value heavier and trim bluffs',
  ('w12_good_fold_bad_result', 'process_review'):
      'Check the cues before judging the result',
  ('w12_checkpoint_discipline_line', 'fear_line'): 'Fold every close spot now',
};

// These two W1 questions explicitly test universal action DEFINITIONS,
// not execution of a hand. Their source has no action history or amount; a
// learner should not lose the first lesson for lack of invented historical
// chips. Exact task, question, option id, label, and untouched conceptual
// table profile must all match. A changed source fails closed again.
const _actionDefinitionQuestions = <String, String>{
  'actions_legal_context':
      'No bet faces you. Which action keeps you in the hand without adding chips?',
  'actions_check_drill': 'What action keeps playing for free?',
};
const _actionDefinitionChoices = <(String, String), String>{
  ('actions_legal_context', 'fold'): 'Fold',
  ('actions_legal_context', 'check'): 'Check',
  ('actions_legal_context', 'call'): 'Call',
  ('actions_check_drill', 'fold'): 'Fold',
  ('actions_check_drill', 'check'): 'Check',
  ('actions_check_drill', 'call'): 'Call',
};

// Exact authored early-position discipline questions are strategic reads,
// not requests to execute or size a wager. Preserve all source-owned grades,
// but never turn these into a legal-bet or stack-capacity certificate.
// ATo UTG and KTo HJ are deliberately NOT covered: common 100 BB 6-max
// opening baselines include them, contradicting the strict authored fold grade.
// Source/strategy owner must resolve those original tasks separately.
// This exception expires if the question, choice, cards, six-seat roster,
// authored stack/commitment profile, blind-start history, or price changes.
// It preserves the authored discipline lesson, not a stack-independent optimum.
const _earlyFoldSourceQuestionsV1 = <String, (String, String, String, String)>{
  'fold_discipline_early_fold': (
    'What is the clean action?',
    'utg',
    'Js',
    '8d',
  ),
  'apply_utg_fold': ('What is the clean action?', 'utg', '8s', '4d'),
  'position_checkpoint_position_checkpoint_early_fold': (
    'What is the disciplined action?',
    'utg',
    'Ac',
    '9d',
  ),
};

bool _exactEarlyFoldStrategicReadV1(
  Act0TableStateV1 table,
  Act0RunnerOptionV1 option, {
  required bool sizingBet,
  required String? taskId,
  required String? question,
}) {
  final source = _earlyFoldSourceQuestionsV1[taskId];
  if (source == null ||
      sizingBet ||
      question != source.$1 ||
      option.amountLabel.trim().isNotEmpty ||
      !((option.id == 'fold' && option.label == 'Fold') ||
          (option.id == 'raise' && option.label == 'Raise')) ||
      table.scope != Act0TableScopeV1.playedHand ||
      table.tableFormat != Act0TableFormatV1.sixMax ||
      table.playerCount != 6 ||
      table.seats.length != 6 ||
      table.boardCards.isNotEmpty ||
      table.streetLabel != 'Preflop' ||
      table.activeSeatId != source.$2 ||
      table.heroSeatId != source.$2 ||
      table.potLabel != 'Pot 1.5 BB' ||
      table.toCallLabel != 'To call 1 BB' ||
      table.heroCards.length != 2) {
    return false;
  }
  // Pin only the original poker facts; do not derive an unknown Hero stack
  // from the BTN's independently authored 100 BB label.
  const seatIds = <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
  for (var i = 0; i < seatIds.length; i++) {
    final seat = table.seats[i];
    final id = seatIds[i];
    final blind = id == 'sb' ? '0.5 BB' : (id == 'bb' ? '1 BB' : null);
    if (seat.seatId != id ||
        seat.seatLabel != id.toUpperCase() ||
        !seat.isOccupied ||
        !seat.isInHand ||
        seat.isFolded ||
        seat.hasActed ||
        seat.isLastAggressor ||
        seat.isHero != (id == source.$2) ||
        seat.isActive != (id == source.$2) ||
        seat.isDealerButton != (id == 'btn') ||
        seat.isSmallBlind != (id == 'sb') ||
        seat.isBigBlind != (id == 'bb') ||
        seat.stackLabel != (id == 'btn' ? '100 BB' : null) ||
        seat.blindAmountLabel != blind ||
        seat.currentBetLabel != blind) {
      return false;
    }
    if (blind == null) {
      if (seat.bet != null) return false;
    } else if (seat.bet?.kind != Act0SeatBetKindV1.post ||
        seat.bet?.label != id.toUpperCase() ||
        seat.bet?.amountLabel != blind) {
      return false;
    }
    final expectedCards = id == source.$2
        ? <String>[source.$3, source.$4]
        : const <String>['?', '?'];
    if (seat.holeCards.length != 2) return false;
    for (var card = 0; card < expectedCards.length; card++) {
      if (seat.holeCards[card].label != expectedCards[card]) return false;
    }
  }
  final hero = table.seats.where((s) => s.isHero && s.isOccupied).toList();
  if (hero.length != 1 ||
      hero.single.seatId != source.$2 ||
      !hero.single.isInHand ||
      hero.single.isFolded) {
    return false;
  }
  final cards = [
    for (final card in table.heroCards) '${card.rank}${card.suit}',
  ];
  if (cards[0] != source.$3 || cards[1] != source.$4) return false;
  const blindStart = <String>['SB blind 0.5 BB', 'BB blind 1 BB'];
  final trail = <String>[
    ...blindStart,
    if (source.$2 == 'hj') 'UTG folds',
    '${source.$2.toUpperCase()} acts',
  ];
  if (table.actionTrail.length != trail.length) return false;
  for (var i = 0; i < trail.length; i++) {
    if (table.actionTrail[i].isNote || table.actionTrail[i].label != trail[i]) {
      return false;
    }
  }
  return true;
}

// Placement's third check reuses the W1 table-read task identity, but asks
// for an action DEFINITION rather than a chip commitment. The real EN14Pro
// first-use route was blocked by the numeric wager guard on the authored
// correct Check answer. Never exempt an altered amount, grade, question or
// table; the other two answers remain wrong teaching distractors.
const _placementActionLabelsV1 = <String, String>{
  'check': 'Check',
  'call': 'Call',
  'raise': 'Raise',
};

// Accept the exact two existing source-owned Placement projections. This is
// compatibility with an existing locale, not permission to invent grades or
// bypass a numeric bet. Mixed languages or altered phrasing fail closed.
const _placementActionDefinitionSourcesV1 = <String, Map<String, String>>{
  'No bet faces Hero. Which action is free?': _placementActionLabelsV1,
  '\u041f\u0435\u0440\u0435\u0434 Hero \u043d\u0435\u0442 \u0441\u0442\u0430\u0432\u043a\u0438. \u041a\u0430\u043a\u043e\u0435 \u0434\u0435\u0439\u0441\u0442\u0432\u0438\u0435 \u0431\u0435\u0441\u043f\u043b\u0430\u0442\u043d\u043e?':
      <String, String>{
        'check': '\u0427\u0435\u043a',
        'call': '\u041a\u043e\u043b\u043b',
        'raise': '\u0420\u0435\u0439\u0437',
      },
};

// The five legacy World 1 word-definition tasks no longer display or grade
// unverified chip amounts. A frozen task/question/choice/grade and an
// unpriced played-hand illustration are required; no legal wager is certified.
const _w1ActionWordSourcesV1 = <String, (String, String)>{
  'actions_theory': (
    'Which action increases what opponents must match?',
    'raise',
  ),
  'actions_fold_drill': (
    'Which action ends your participation in the hand?',
    'fold',
  ),
  'actions_call_drill': (
    'Which action matches a wager without increasing it?',
    'call',
  ),
  'actions_raise_drill': ('Which action increases the current wager?', 'raise'),
  'actions_review': ('Which action adds more than a call?', 'raise'),
};
const _w1ActionWordLabelsV1 = <String, String>{
  'fold': 'Fold',
  'call': 'Call',
  'raise': 'Raise',
};

bool _exactW1ActionWordV1(
  Act0TableStateV1 table,
  Act0RunnerOptionV1 option, {
  required bool sizingBet,
  required String? taskId,
  required String? question,
}) {
  final source = _w1ActionWordSourcesV1[taskId];
  final expectedQuality = option.id == source?.$2
      ? Act0FeedbackQualityV1.correct
      : option.id == 'call' && source?.$2 == 'raise'
      ? Act0FeedbackQualityV1.suboptimal
      : Act0FeedbackQualityV1.wrong;
  if (source == null ||
      sizingBet ||
      question != source.$1 ||
      option.amountLabel.trim().isNotEmpty ||
      _w1ActionWordLabelsV1[option.id] != option.label ||
      option.isCorrect != (option.id == source.$2) ||
      option.quality != expectedQuality ||
      table.scope != Act0TableScopeV1.playedHand ||
      table.tableFormat != Act0TableFormatV1.sixMax ||
      table.playerCount != 6 ||
      table.seats.length != 6 ||
      table.potLabel.trim().isNotEmpty ||
      table.toCallLabel.trim().isNotEmpty ||
      table.actionTrail.isNotEmpty) {
    return false;
  }
  return table.seats.every(
    (seat) =>
        seat.bet == null &&
        seat.currentBetLabel == null &&
        seat.blindAmountLabel == null,
  );
}

bool _exactPlacementActionDefinitionV1(
  Act0TableStateV1 table,
  Act0RunnerOptionV1 option, {
  required bool sizingBet,
  required String? question,
}) {
  final sourceLabels = _placementActionDefinitionSourcesV1[question];
  if (sizingBet ||
      sourceLabels == null ||
      option.amountLabel.trim().isNotEmpty ||
      sourceLabels[option.id] != option.label ||
      option.isCorrect != (option.id == 'check') ||
      option.quality !=
          (option.id == 'check'
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong) ||
      table.scope != Act0TableScopeV1.playedHand ||
      table.tableFormat != Act0TableFormatV1.sixMax ||
      table.playerCount != 6 ||
      table.seats.length != 6 ||
      table.streetLabel != 'Flop' ||
      table.potLabel != 'Pot 6 BB' ||
      table.toCallLabel.trim().isNotEmpty ||
      (table.activeSeatId?.trim().isNotEmpty ?? false) ||
      (table.heroSeatId?.trim().isNotEmpty ?? false) ||
      table.actionTrail.isNotEmpty ||
      table.heroCards.length != 2 ||
      table.boardCards.length != 3) {
    return false;
  }
  const cards = <String>['As', 'Kd', 'Ah', '7c', '2d'];
  final shown = <String>[
    for (final card in table.heroCards) '${card.rank}${card.suit}',
    for (final card in table.boardCards) '${card.rank}${card.suit}',
  ];
  for (var i = 0; i < cards.length; i++) {
    if (shown[i] != cards[i]) return false;
  }
  const ids = <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
  for (var i = 0; i < ids.length; i++) {
    final seat = table.seats[i];
    final id = ids[i];
    if (seat.seatId != id ||
        seat.seatLabel != id.toUpperCase() ||
        seat.isHero != (id == 'btn') ||
        seat.isDealerButton != (id == 'btn') ||
        seat.isSmallBlind != (id == 'sb') ||
        seat.isBigBlind != (id == 'bb') ||
        seat.isActive ||
        !seat.isOccupied ||
        !seat.isInHand ||
        seat.isFolded ||
        seat.hasActed ||
        seat.stackLabel != null ||
        seat.currentBetLabel != null ||
        seat.blindAmountLabel != null ||
        seat.bet != null) {
      return false;
    }
  }
  return true;
}

// Decimal BB units avoid binary floating-point errors at exact minimum raises.
// Other units, rounding, symbolic sizes, negative or extravagant inputs are not
// silently reinterpreted. The normalizer is deliberately bounded.
int? _bb(String label, {String prefix = ''}) {
  final match = RegExp(
    '^${RegExp.escape(prefix)}([0-9]{1,7})(?:\\.([0-9]{1,6}))?\\s+BB\$',
    caseSensitive: false,
  ).firstMatch(label.trim());
  if (match == null) return null;
  return int.parse(match[1]!) * _unit +
      int.parse((match[2] ?? '').padRight(6, '0'));
}

int? _street(String value) => switch (value.trim().toLowerCase()) {
  'preflop' => 0,
  'flop' => 1,
  'turn' => 2,
  'river' => 3,
  _ => null,
};

class _PriceLedger {
  final committed = <String, int>{};
  final lastActedAt = <String, int>{};
  final lastActedFullRaise = <String, int>{};
  final allIn = <String>{};
  final folded = <String>{};
  int pot = 0;
  int price = _unit;
  int fullRaise = _unit;
  int street = 0;

  bool canRaise(String actor) =>
      !lastActedAt.containsKey(actor) ||
      price - lastActedAt[actor]! >= lastActedFullRaise[actor]!;

  void acted(String actor) {
    lastActedAt[actor] = price;
    lastActedFullRaise[actor] = fullRaise;
  }
}

/// Checks a wager against its authored history. Calls in choice amountLabel are
/// additional chips; raises are street-total commitments unless explicitly "by".
/// Trail calls are totals unless the source explicitly says "BB more".
///
/// Supported source profile: ordinary 0.5/1 BB no-limit hold'em, explicit blind
/// start and explicit street boundaries. No ante, straddle, pot-limit, forced
/// completion, uncalled-return, inferred fold, or inferred historical stack.
/// Missing grammar/facts remain unproved. The PKR-03 owner still decides order.
/// Legal short all-in choices are preserved using the actor's supplied stack;
/// a short all-in in the history does not itself reopen a prior actor's raise.
Act0BettingPriceResultV1 act0BettingPriceForOptionV1(
  Act0TableStateV1 table,
  Act0RunnerOptionV1 option, {
  bool sizingBet = false,
  String? taskId,
  String? question,
}) {
  if (_earlyFoldSourceQuestionsV1.containsKey(taskId)) {
    if (_exactEarlyFoldStrategicReadV1(
      table,
      option,
      sizingBet: sizingBet,
      taskId: taskId,
      question: question,
    )) {
      return const Act0BettingPriceResultV1(
        _unknown,
        'source_early_fold_strategic_read',
        appliesToWager: false,
      );
    }
    // These grades were admitted only for the exact lesson scene. A changed
    // scope, stack or other fact cannot inherit its old strategic grade via
    // another conceptual exception or the general legality parser.
    return const Act0BettingPriceResultV1(
      _unknown,
      'changed_early_fold_source',
    );
  }
  // This reused source task has a real first-use definition question.
  // Exact scene/choice identity is required; otherwise fail closed rather
  // than treating an unproved numeric wager as a learner mistake.
  if (taskId == 'what_poker_is_table_read_transfer' &&
      _placementActionLabelsV1.containsKey(option.id)) {
    if (_exactPlacementActionDefinitionV1(
      table,
      option,
      sizingBet: sizingBet,
      question: question,
    )) {
      return const Act0BettingPriceResultV1(
        _unknown,
        'source_placement_action_definition',
        appliesToWager: false,
      );
    }
    return const Act0BettingPriceResultV1(
      _unknown,
      'changed_placement_action_source',
    );
  }
  if (_w1ActionWordSourcesV1.containsKey(taskId)) {
    if (_exactW1ActionWordV1(
      table,
      option,
      sizingBet: sizingBet,
      taskId: taskId,
      question: question,
    )) {
      return const Act0BettingPriceResultV1(
        _unknown,
        'source_w1_action_word',
        appliesToWager: false,
      );
    }
    return const Act0BettingPriceResultV1(
      _unknown,
      'changed_w1_action_word_source',
    );
  }
  if (table.scope == Act0TableScopeV1.orientation ||
      table.scope == Act0TableScopeV1.explanation) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'not_played_hand',
      appliesToWager: false,
    );
  }
  if (!sizingBet &&
      option.amountLabel.trim().isEmpty &&
      _conceptualAnswers[(taskId, option.id)] == option.label) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'source_conceptual_answer',
      appliesToWager: false,
    );
  }
  if (!sizingBet &&
      option.amountLabel.trim().isEmpty &&
      _actionDefinitionQuestions[taskId] == question &&
      _actionDefinitionChoices[(taskId, option.id)] == option.label &&
      table.scope == Act0TableScopeV1.playedHand &&
      (table.activeSeatId?.trim().isEmpty ?? true) &&
      (table.heroSeatId?.trim().isEmpty ?? true) &&
      table.streetLabel == 'Flop' &&
      table.potLabel == 'Pot 3 BB' &&
      table.toCallLabel.trim().isEmpty &&
      table.actionTrail.every((item) => item.isNote)) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'source_action_definition',
      appliesToWager: false,
    );
  }
  // Only the typed sizing consumer may treat a bare BB answer as a bet.
  // Numeric counting/recognition answers must never become poker actions.
  final sizingAmount = sizingBet ? _bb(option.label) : null;
  final actionMatch = RegExp(
    r'^(call|hero-call|bet|raise|shove|jam|fold|check|all-in)\b',
    caseSensitive: false,
  ).firstMatch(option.label.trim());
  if (actionMatch == null && sizingAmount == null) {
    return Act0BettingPriceResultV1(
      _unknown,
      sizingBet ? 'unsupported_choice_amount' : 'not_wager_action',
      appliesToWager: sizingBet,
    );
  }
  final rawAction = sizingAmount != null
      ? 'bet'
      : actionMatch![1]!.toLowerCase();
  final action = rawAction == 'hero-call' ? 'call' : rawAction;
  final passive = action == 'check' || action == 'fold';
  final otherUnits = RegExp(
    r'^(?:call|hero-call|bet|shove|jam|all-in)\s+(to|by)\b',
    caseSensitive: false,
  ).firstMatch(option.label.trim());
  if (otherUnits != null &&
      (action == 'call' || otherUnits[1]!.toLowerCase() == 'by')) {
    // Call choices in this contract are additional chips. Do not silently
    // reinterpret a total or an unsupported increment as that amount.
    return const Act0BettingPriceResultV1(_unknown, 'unsupported_option_units');
  }
  final raiseBy =
      action == 'raise' &&
      RegExp(
        r'^raise\s+by\b',
        caseSensitive: false,
      ).hasMatch(option.label.trim());
  // "By" explicitly denotes the raise increment above the current price.
  // "More" on a raise remains ambiguous (increment versus actor-added chips).
  if (action == 'raise' &&
      RegExp(r'\bmore\b', caseSensitive: false).hasMatch(option.label)) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'incremental_raise_unknown',
    );
  }
  final embedded = RegExp(
    r'^(?:call|hero-call|bet|raise|shove|jam|all-in)(?:\s+(?:to|by))?\s+'
    r'([0-9]{1,7}(?:\.[0-9]{1,6})?\s+BB)$',
    caseSensitive: false,
  ).firstMatch(option.label.trim());
  if (sizingAmount == null &&
      embedded == null &&
      RegExp(r'[0-9]|\bBB\b', caseSensitive: false).hasMatch(option.label)) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'unsupported_option_amount_label',
    );
  }
  final explicitAmount = option.amountLabel.trim().isNotEmpty
      ? _bb(option.amountLabel)
      : embedded == null
      ? null
      : _bb(embedded[1]!);
  var chosen = sizingAmount ?? explicitAmount;
  if (option.amountLabel.trim().isNotEmpty && explicitAmount == null ||
      chosen == null && (action == 'bet' || action == 'raise')) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'unsupported_choice_amount',
    );
  }
  if (option.amountLabel.trim().isNotEmpty &&
      ((embedded != null && _bb(embedded[1]!) != explicitAmount) ||
          (sizingAmount != null && sizingAmount != explicitAmount))) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'conflicting_option_amounts',
    );
  }
  if (table.scope != Act0TableScopeV1.playedHand ||
      !table.usesCanonicalPlayerCount ||
      table.seats.length != table.playerCount) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'not_complete_hand_profile',
    );
  }
  final seats = <String, Act0SeatStateV1>{};
  final ids = <String>{};
  final labels = <String>{};
  for (final seat in table.seats) {
    final actor = seat.seatLabel.trim().toUpperCase();
    if (!table.canonicalSeatOrder.contains(actor) ||
        !labels.add(actor) ||
        !ids.add(seat.seatId)) {
      return const Act0BettingPriceResultV1(_unknown, 'ambiguous_participants');
    }
    if (!seat.isOccupied) continue;
    seats[actor] = seat;
  }
  final history = table.actionTrail.where((item) => !item.isNote).toList();
  final heroes = table.seats.where((s) => s.isHero && s.isOccupied).toList();
  final explicitActorId = table.activeSeatId?.trim();
  // A terminal "Hero acts" is source-owned actor identity even where the
  // redundant activeSeatId projection is absent. Never infer from a label,
  // question, pot or option, and never override a conflicting explicit actor.
  final terminalHeroMarker =
      history.isNotEmpty &&
      RegExp(
        r'^Hero acts$',
        caseSensitive: false,
      ).hasMatch(history.last.label.trim());
  final inferredHeroId =
      (explicitActorId?.isEmpty ?? true) &&
          terminalHeroMarker &&
          heroes.length == 1 &&
          ((table.heroSeatId?.trim().isEmpty ?? true) ||
              table.heroSeatId == heroes.single.seatId)
      ? heroes.single.seatId
      : null;
  final actorId = (explicitActorId?.isNotEmpty ?? false)
      ? explicitActorId
      : inferredHeroId;
  final matching = table.seats.where((s) => s.seatId == actorId);
  if (matching.length != 1) {
    return const Act0BettingPriceResultV1(_unknown, 'missing_active_actor');
  }
  final hero = matching.single;
  if (!hero.isOccupied ||
      heroes.length != 1 ||
      !hero.isHero ||
      ((table.heroSeatId?.trim().isNotEmpty ?? false) &&
          hero.seatId != table.heroSeatId)) {
    return const Act0BettingPriceResultV1(_unknown, 'not_hero_action');
  }
  if (hero.isFolded || !hero.isInHand) {
    return const Act0BettingPriceResultV1(_contradiction, 'inactive_actor');
  }
  final actor = hero.seatLabel.trim().toUpperCase();
  final ledger = _PriceLedger();
  var actionCount = 0;
  for (var historyIndex = 0; historyIndex < history.length; historyIndex++) {
    final item = history[historyIndex];
    var label = item.label.trim();
    final marker = RegExp(
      r'^(Preflop|Flop|Turn|River):\s*(.*)$',
      caseSensitive: false,
    ).firstMatch(label);
    if (marker != null) {
      final next = _street(marker[1]!)!;
      if (next != ledger.street) {
        // A partial prefix or an omitted earlier street cannot establish the
        // supported history profile. Do not punish the learner for absent facts.
        if (actionCount < 2) {
          return const Act0BettingPriceResultV1(
            _unknown,
            'missing_blind_start',
          );
        }
        if (next > ledger.street + 1) {
          return const Act0BettingPriceResultV1(
            _unknown,
            'unrecorded_street_gap',
          );
        }
        if (next < ledger.street) {
          return const Act0BettingPriceResultV1(_contradiction, 'street_order');
        }
        ledger.street = next;
        ledger.price = 0;
        ledger.fullRaise = _unit;
        ledger.committed.clear();
        ledger.lastActedAt.clear();
        ledger.lastActedFullRaise.clear();
      }
      label = marker[2]!.trim();
      if (label.isEmpty) continue;
    }
    final decision = RegExp(
      r'^(\S+)\s+acts$',
      caseSensitive: false,
    ).firstMatch(label);
    if (decision != null) {
      final who = decision[1]!.toUpperCase();
      if (historyIndex != history.length - 1 ||
          (who != actor && who != 'HERO')) {
        return const Act0BettingPriceResultV1(
          _contradiction,
          'invalid_decision_marker',
        );
      }
      continue;
    }
    final parsed = RegExp(
      r'^(UTG|HJ|CO|BTN|SB|BB|UTG\+1|UTG\+2|LJ|MP) '
      r'(blind|posts|folds?|checks?|calls?|bets?|raises?|opens|shoves?|jams?)'
      r'(?: (?:to )?([0-9]{1,7}(?:\.[0-9]{1,6})? BB)( more)?)?$',
      caseSensitive: false,
    ).firstMatch(label);
    if (parsed == null) {
      return const Act0BettingPriceResultV1(_unknown, 'unsupported_history');
    }
    final who = parsed[1]!.toUpperCase();
    final verb = parsed[2]!.toLowerCase();
    if (!seats.containsKey(who)) {
      return const Act0BettingPriceResultV1(_unknown, 'unknown_history_actor');
    }
    if (ledger.allIn.contains(who)) {
      return const Act0BettingPriceResultV1(
        _contradiction,
        'action_after_all_in',
      );
    }
    if (ledger.folded.contains(who)) {
      return const Act0BettingPriceResultV1(
        _contradiction,
        'action_after_fold',
      );
    }
    final amount = parsed[3] == null ? null : _bb(parsed[3]!);
    final more = parsed[4] != null;
    final post = verb == 'blind' || verb == 'posts';
    if (actionCount < 2) {
      if (!post ||
          ledger.street != 0 ||
          more ||
          who != (actionCount == 0 ? 'SB' : 'BB') ||
          amount != (actionCount == 0 ? _unit ~/ 2 : _unit)) {
        return const Act0BettingPriceResultV1(_unknown, 'missing_blind_start');
      }
      ledger.committed[who] = amount!;
      ledger.pot += amount;
      actionCount++;
      continue;
    }
    actionCount++;
    if (post) {
      return const Act0BettingPriceResultV1(_unknown, 'extra_forced_post');
    }
    if (verb.startsWith('fold') || verb.startsWith('check')) {
      if (amount != null || more) {
        return const Act0BettingPriceResultV1(
          _unknown,
          'unexpected_passive_amount',
        );
      }
      if (verb.startsWith('check') &&
          (ledger.committed[who] ?? 0) != ledger.price) {
        return const Act0BettingPriceResultV1(
          _contradiction,
          'check_facing_price',
        );
      }
      if (verb.startsWith('check')) ledger.acted(who);
      if (verb.startsWith('fold')) ledger.folded.add(who);
      continue;
    }
    if (amount == null || amount <= 0 || (more && !verb.startsWith('call'))) {
      return const Act0BettingPriceResultV1(
        _unknown,
        'unsupported_history_amount',
      );
    }
    final before = ledger.committed[who] ?? 0;
    final total = more ? before + amount : amount;
    final isAllIn = verb.startsWith('shove') || verb.startsWith('jam');
    if (verb.startsWith('call') || (isAllIn && total <= ledger.price)) {
      if (ledger.price == 0 ||
          total <= before ||
          total > ledger.price ||
          (!isAllIn && total != ledger.price)) {
        return const Act0BettingPriceResultV1(
          _unknown,
          'unproved_history_call',
        );
      }
    } else {
      if (total <= ledger.price ||
          (verb.startsWith('bet') && ledger.price > 0) ||
          (verb.startsWith('raise') && ledger.price == 0)) {
        return const Act0BettingPriceResultV1(
          _contradiction,
          'inconsistent_aggression',
        );
      }
      if (!ledger.canRaise(who)) {
        return const Act0BettingPriceResultV1(
          _contradiction,
          'raise_not_reopened',
        );
      }
      final increment = total - ledger.price;
      if (increment < ledger.fullRaise) {
        // Only explicit all-in history may be short. A sparse stack cannot
        // certify an ordinary bet as illegal: it might consume the whole stack.
        if (!isAllIn) {
          final remaining = _bb(seats[who]!.stackLabel ?? '');
          return Act0BettingPriceResultV1(
            remaining != null && remaining > 0 ? _contradiction : _unknown,
            'short_history_wager_without_all_in',
          );
        }
      } else {
        ledger.fullRaise = increment;
      }
      ledger.price = total;
    }
    ledger.pot += total - before;
    ledger.committed[who] = total;
    ledger.acted(who);
    if (isAllIn) ledger.allIn.add(who);
  }
  if (actionCount < 2 || _street(table.streetLabel) != ledger.street) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'unrecorded_current_street',
    );
  }
  final order = act0BettingRoundOrderTruthForTableV1(
    inferredHeroId == null
        ? table
        : table.copyWith(activeSeatId: inferredHeroId),
  );
  if (order == Act0BettingRoundOrderTruthV1.contradiction) {
    return const Act0BettingPriceResultV1(
      _contradiction,
      'source_order_contradiction',
    );
  }
  if (ledger.allIn.contains(actor)) {
    return const Act0BettingPriceResultV1(
      _contradiction,
      'active_actor_all_in',
    );
  }
  final committed = ledger.committed[actor] ?? 0;
  final due = ledger.price - committed;
  final remaining = _bb(hero.stackLabel ?? '');
  if (remaining == 0) {
    return const Act0BettingPriceResultV1(
      _contradiction,
      'active_actor_has_no_chips',
    );
  }
  for (final who in ledger.allIn) {
    final stack = _bb(seats[who]!.stackLabel ?? '');
    if (stack != null && stack > 0) {
      return const Act0BettingPriceResultV1(
        _contradiction,
        'all_in_has_chips_behind',
      );
    }
  }
  final cappedCall = remaining == null
      ? null
      : (due < remaining ? due : remaining);
  final potClaim = table.potLabel.trim();
  final displayedPot = potClaim.isEmpty
      ? ledger.pot
      : _bb(potClaim, prefix: 'Pot ');
  final displayLabel = table.toCallLabel.trim();
  final displayed = displayLabel.isEmpty
      ? null
      : _bb(displayLabel, prefix: 'To call ');
  final displayMatches =
      displayLabel.isEmpty || displayed == due || displayed == cappedCall;
  final sourceReady =
      order == Act0BettingRoundOrderTruthV1.consistent &&
      remaining != null &&
      displayedPot == ledger.pot &&
      displayMatches;
  int? additionalCost;
  Act0BettingPriceResultV1 result(
    Act0BettingPriceTruthV1 truth,
    String reason,
  ) => Act0BettingPriceResultV1(
    truth,
    reason,
    callCostBb: cappedCall == null ? null : cappedCall / _unit,
    amountToMatchBb: due / _unit,
    minimumRaiseToBb: (ledger.price + ledger.fullRaise) / _unit,
    actorCommittedBb: committed / _unit,
    additionalCostBb: additionalCost == null ? null : additionalCost / _unit,
    potBeforeActionBb: sourceReady ? ledger.pot / _unit : null,
    sourceReady: sourceReady,
  );
  if (due < 0) return result(_contradiction, 'commitment_exceeds_price');
  if (!passive && chosen != null && chosen <= 0) {
    return result(_contradiction, 'nonpositive_wager');
  }
  final allInChoice =
      action == 'shove' || action == 'jam' || action == 'all-in';
  if (passive) {
    additionalCost = 0;
    if (chosen != null) return result(_unknown, 'unexpected_passive_amount');
    if (action == 'check' && due > 0)
      return result(_contradiction, 'check_facing_price');
  } else {
    chosen ??= action == 'call'
        ? cappedCall
        : allInChoice && remaining != null
        ? committed + remaining
        : null;
    if (chosen == null) return result(_unknown, 'missing_actor_stack');
    if (raiseBy) chosen += ledger.price;
    final callChoice =
        action == 'call' || (allInChoice && chosen <= ledger.price);
    if (callChoice) {
      final callAmount = action == 'call' ? chosen : chosen - committed;
      additionalCost = callAmount;
      if (due == 0) return result(_contradiction, 'call_without_price');
      if (remaining == null) {
        return callAmount > due
            ? result(_contradiction, 'call_exceeds_price')
            : result(_unknown, 'missing_actor_stack');
      }
      final legalCall = due < remaining ? due : remaining;
      if (callAmount != legalCall ||
          legalCall <= 0 ||
          (allInChoice && callAmount != remaining)) {
        return result(_contradiction, 'call_cost_mismatch');
      }
    } else {
      final total = chosen;
      final additional = total - committed;
      additionalCost = additional;
      if (additional <= 0 || total <= ledger.price) {
        return result(_contradiction, 'aggression_does_not_raise_price');
      }
      if ((action == 'bet' && ledger.price > 0) ||
          (action == 'raise' && ledger.price == 0)) {
        return result(_contradiction, 'wrong_wager_kind');
      }
      if (!ledger.canRaise(actor))
        return result(_contradiction, 'raise_not_reopened');
      if (remaining == null) return result(_unknown, 'missing_actor_stack');
      if (additional > remaining)
        return result(_contradiction, 'wager_exceeds_stack');
      if (allInChoice && additional != remaining) {
        return result(_contradiction, 'all_in_not_whole_stack');
      }
      if (total < ledger.price + ledger.fullRaise && additional != remaining) {
        return result(_contradiction, 'wager_below_minimum');
      }
      final opponents = seats.entries.where(
        (entry) =>
            entry.key != actor &&
            entry.value.isInHand &&
            !entry.value.isFolded &&
            !ledger.folded.contains(entry.key),
      );
      if (opponents.isNotEmpty &&
          opponents.every((entry) => ledger.allIn.contains(entry.key))) {
        return result(_contradiction, 'no_opponent_can_call_raise');
      }
      if (!opponents.any(
        (entry) =>
            !ledger.allIn.contains(entry.key) &&
            (_bb(entry.value.stackLabel ?? '') ?? 0) > 0,
      )) {
        return result(_unknown, 'missing_opponent_stack');
      }
    }
  }
  if (displayedPot == null) return result(_unknown, 'unsupported_pot');
  if (displayedPot != ledger.pot) return result(_contradiction, 'pot_mismatch');
  // Display is a claim to verify, not the authority used to derive the price.
  if (displayLabel.isEmpty && due > 0) {
    return result(_unknown, 'missing_display_price');
  }
  if (displayed == null && displayLabel.isNotEmpty)
    return result(_unknown, 'unsupported_display_price');
  // With an all-in cap, displays may expose either the outstanding price or
  // the actual chips the short stack can call. Neither changes the ledger.
  if (!displayMatches) {
    return result(_contradiction, 'display_price_mismatch');
  }
  return result(
    order == Act0BettingRoundOrderTruthV1.consistent ? _consistent : _unknown,
    order == Act0BettingRoundOrderTruthV1.consistent
        ? 'numeric_action_consistent'
        : 'numeric_price_only_order_unproved',
  );
}

/// Incomplete/contradictory source cannot grade either answer. With a proven
/// source, intentionally illegal wrong distractors retain their teaching role.
/// This guard never upgrades legality to strategic correctness.
bool act0BettingPriceBlocksAuthoredSuccessV1(
  Act0TableStateV1 table,
  Act0RunnerOptionV1 option, {
  bool sizingBet = false,
  String? taskId,
  String? question,
}) {
  final result = act0BettingPriceForOptionV1(
    table,
    option,
    sizingBet: sizingBet,
    taskId: taskId,
    question: question,
  );
  if (!result.appliesToWager) return false;
  if (!result.sourceReady) return true;
  if (result.truth == _unknown && result.reason != 'missing_display_price')
    return true;
  return (option.isCorrect ||
          option.quality == Act0FeedbackQualityV1.correct) &&
      result.isContradiction;
}
