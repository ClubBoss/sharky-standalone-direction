// SYNTHETIC table-only price vectors: ordinary 0.5/1 BB no-limit hold'em,
// no ante/rake/side pots. Every expected number below is literal, independent
// arithmetic written from the authored history, never generated from the
// production ledger. Synthetic tables are not catalog, native, source-authority
// or Human proof, and this file does not accept HLP-02 or PKR-05.
// The only real-catalog reads are a no-throw/parity census and the existing
// w4_price_intro table, which must stay unavailable; no W4 fact is invented.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _blinds = <String>['SB blind 0.5 BB', 'BB blind 1 BB'];
const _buttonOpen = <String>[..._blinds, 'UTG folds', 'HJ folds', 'CO folds'];
// Preflop pot: SB 0.5 (folded) + BTN 3 + BB 3 = 6.5.
const _flopStart = <String>[
  ..._buttonOpen,
  'BTN raises 3 BB',
  'SB folds',
  'BB calls 3 BB',
];

const _ready = Act0TablePriceReadinessV1.ready;
const _unavailable = Act0TablePriceReadinessV1.unavailable;
const _contradiction = Act0TablePriceReadinessV1.contradiction;

/// SYNTHETIC six-max table. Stack labels are chips behind; potLabel is empty
/// (no claim) unless a test supplies one.
Act0TableStateV1 _table({
  List<String> trail = _buttonOpen,
  String street = 'Preflop',
  String hero = 'BTN',
  String due = '1',
  String? heroStack = '100 BB',
  Map<String, String?> stacks = const {},
  String pot = '',
  Act0TableScopeV1 scope = Act0TableScopeV1.playedHand,
}) {
  final folded = <String>{
    for (final label in trail)
      if (label.endsWith(' folds')) label.split(' ').first,
  };
  return Act0TableStateV1(
    scope: scope,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: [
      for (final position in const ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'])
        Act0SeatStateV1(
          seatId: position.toLowerCase(),
          seatLabel: position,
          displayName: position == hero ? 'Hero' : position,
          isHero: position == hero,
          isActive: position == hero,
          isDealerButton: position == 'BTN',
          isSmallBlind: position == 'SB',
          isBigBlind: position == 'BB',
          isInHand: !folded.contains(position),
          isFolded: folded.contains(position),
          stackLabel: stacks.containsKey(position)
              ? stacks[position]
              : position == hero
              ? heroStack
              : '100 BB',
        ),
    ],
    heroCards: const [],
    boardCards: const [],
    streetLabel: street,
    potLabel: pot,
    toCallLabel: due.isEmpty ? '' : 'To call $due BB',
    centerLabel: 'SYNTHETIC table-only price fixture',
    actionTrail: [
      for (final label in trail) Act0ActionTrailItemV1(label: label),
    ],
    activeSeatId: hero.toLowerCase(),
    heroSeatId: hero.toLowerCase(),
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
  );
}

/// SYNTHETIC multistreet profile mirroring the existing multistreet oracle:
/// all start 100 BB, chips behind after the recorded history.
Act0TableStateV1 _multistreet({required bool turn}) {
  final behind = <String, String>{
    'UTG': '100',
    'HJ': '100',
    'CO': '100',
    'BTN': turn ? '95' : '97',
    'SB': '99.5',
    'BB': turn ? '91' : '95',
  };
  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      for (final seat in const ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'])
        Act0SeatStateV1(
          seatId: seat.toLowerCase(),
          seatLabel: seat,
          displayName: seat == 'BTN' ? 'Hero' : seat,
          isHero: seat == 'BTN',
          isDealerButton: seat == 'BTN',
          isSmallBlind: seat == 'SB',
          isBigBlind: seat == 'BB',
          isActive: seat == 'BTN',
          isInHand: seat == 'BTN' || seat == 'BB',
          isFolded: seat != 'BTN' && seat != 'BB',
          stackLabel: '${behind[seat]} BB',
          currentBetLabel: seat == 'BB' ? (turn ? '4 BB' : '2 BB') : null,
        ),
    ],
    heroCards: const [
      Act0CardStateV1(rank: 'A', suit: 's'),
      Act0CardStateV1(rank: 'K', suit: 'd'),
    ],
    boardCards: <Act0CardStateV1>[
      const Act0CardStateV1(rank: 'A', suit: 'h'),
      const Act0CardStateV1(rank: '7', suit: 'c'),
      const Act0CardStateV1(rank: '2', suit: 'd'),
      if (turn) const Act0CardStateV1(rank: '5', suit: 's'),
    ],
    streetLabel: turn ? 'Turn' : 'Flop',
    potLabel: turn ? 'Pot 14.5 BB' : 'Pot 8.5 BB',
    toCallLabel: turn ? 'To call 4 BB' : 'To call 2 BB',
    centerLabel: 'SYNTHETIC 0.5/1 BB, all start 100, no ante/rake',
    actionTrail: [
      for (final action in <String>[
        ..._flopStart,
        'Flop: BB bets 2 BB',
        if (turn) ...['Flop: BTN calls 2 BB', 'Turn: BB bets 4 BB'],
      ])
        Act0ActionTrailItemV1(label: action),
    ],
    activeSeatId: 'btn',
    heroSeatId: 'btn',
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
  );
}

/// Probe option for the OLD API only. The table-only API never sees it.
Act0RunnerOptionV1 _probe(String label, String amount, {bool correct = true}) =>
    Act0RunnerOptionV1(
      id: label.toLowerCase().replaceAll(' ', '_'),
      label: label,
      amountLabel: amount.isEmpty ? '' : '$amount BB',
      isCorrect: correct,
      preferredLabel: label,
      quality: correct
          ? Act0FeedbackQualityV1.correct
          : Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'SYNTHETIC probe',
      feedbackReason: 'SYNTHETIC probe.',
    );

void _expectFacts(
  Act0TablePriceReadV1 read, {
  required String street,
  required double pot,
  required double prior,
  required double current,
  required double folded,
  required double priceTo,
  required double committed,
  required double toMatch,
  required double call,
  required bool capped,
  required double stack,
}) {
  expect(read.readiness, _ready, reason: read.reason);
  expect(read.reason, 'table_price_ready');
  final facts = read.facts!;
  expect(facts.street, street);
  expect(facts.potBeforeActionBb, pot);
  expect(facts.priorStreetsPotBb, prior);
  expect(facts.currentStreetPotBb, current);
  expect(facts.foldedPlayersContributionBb, folded);
  expect(facts.streetPriceToBb, priceTo);
  expect(facts.actorStreetCommittedBb, committed);
  expect(facts.amountToMatchBb, toMatch);
  expect(facts.callCostBb, call);
  expect(facts.callIsStackCapped, capped);
  expect(facts.actorStackBb, stack);
  expect(facts.facesWager, toMatch > 0);
}

void _expectNotReady(
  Act0TablePriceReadV1 read,
  Act0TablePriceReadinessV1 readiness,
  String reason,
) {
  expect(read.readiness, readiness, reason: read.reason);
  expect(read.reason, reason);
  expect(read.isReady, isFalse);
  expect(read.facts, isNull);
}

void main() {
  test('recorded all-in fact is canonical and persists across streets', () {
    expect(act0TablePriceV1(_table()).facts!.hasRecordedAllIn, isFalse);
    for (final verb in ['shoves', 'jams']) {
      final trail = <String>[
        ..._blinds,
        'UTG $verb 3 BB',
        'HJ calls 3 BB',
        'CO calls 3 BB',
        'BTN folds',
        'SB folds',
        'BB folds',
        'Flop: HJ checks',
      ];
      final source = _table(
        trail: trail,
        street: 'Flop',
        hero: 'CO',
        due: '0',
        heroStack: '97 BB',
        stacks: {'UTG': '0 BB', 'HJ': '97 BB'},
        pot: 'Pot 10.5 BB',
      );
      final read = act0TablePriceV1(source);
      expect(read.readiness, _ready, reason: '$verb: ${read.reason}');
      expect(read.facts!.hasRecordedAllIn, isTrue);
      expect(read.facts!.facesWager, isFalse);
      final rejected = act0TablePriceV1(
        source.copyWith(potLabel: 'Pot 999 BB'),
      );
      expect(rejected.isReady, isFalse);
      expect(rejected.facts, isNull);
    }
  });

  test('SYNTHETIC API needs only the table: no option, grade or fake Call', () {
    // Compile-time proof of the signature.
    const Act0TablePriceReadV1 Function(Act0TableStateV1) read =
        act0TablePriceV1;
    expect(read(_table()).isReady, isTrue);
  });

  test('SYNTHETIC ready preflop table without options; pot claim verified', () {
    // Blinds 0.5 + 1 = 1.5; BTN faces 1, nothing committed.
    for (final pot in ['', 'Pot 1.5 BB']) {
      _expectFacts(
        act0TablePriceV1(_table(pot: pot)),
        street: 'preflop',
        pot: 1.5,
        prior: 0,
        current: 1.5,
        folded: 0,
        priceTo: 1,
        committed: 0,
        toMatch: 1,
        call: 1,
        capped: false,
        stack: 100,
      );
    }
    expect(act0TablePriceV1(_table()).facts!.actorSeatId, 'btn');
  });

  test('SYNTHETIC zero price: checked flop, empty or zero display', () {
    for (final due in ['', '0']) {
      _expectFacts(
        act0TablePriceV1(
          _table(
            trail: [..._flopStart, 'Flop: BB checks'],
            street: 'Flop',
            due: due,
          ),
        ),
        street: 'flop',
        pot: 6.5,
        prior: 6.5,
        current: 0,
        folded: 0.5,
        priceTo: 0,
        committed: 0,
        toMatch: 0,
        call: 0,
        capped: false,
        stack: 100,
      );
    }
  });

  test('SYNTHETIC ordinary flop price keeps earlier streets and dead SB', () {
    // 6.5 preflop + BB bets 2 = 8.5; folded SB's 0.5 stays in the pot.
    _expectFacts(
      act0TablePriceV1(
        _table(
          trail: [..._flopStart, 'Flop: BB bets 2 BB'],
          street: 'Flop',
          due: '2',
        ),
      ),
      street: 'flop',
      pot: 8.5,
      prior: 6.5,
      current: 2,
      folded: 0.5,
      priceTo: 2,
      committed: 0,
      toMatch: 2,
      call: 2,
      capped: false,
      stack: 100,
    );
  });

  test('SYNTHETIC multistreet flop and turn with verified pot claims', () {
    _expectFacts(
      act0TablePriceV1(_multistreet(turn: false)),
      street: 'flop',
      pot: 8.5,
      prior: 6.5,
      current: 2,
      folded: 0.5,
      priceTo: 2,
      committed: 0,
      toMatch: 2,
      call: 2,
      capped: false,
      stack: 97,
    );
    // 6.5 + flop 2 + 2 = 10.5 earlier; turn BB bets 4: pot 14.5.
    _expectFacts(
      act0TablePriceV1(_multistreet(turn: true)),
      street: 'turn',
      pot: 14.5,
      prior: 10.5,
      current: 4,
      folded: 0.5,
      priceTo: 4,
      committed: 0,
      toMatch: 4,
      call: 4,
      capped: false,
      stack: 95,
    );
    _expectNotReady(
      act0TablePriceV1(
        _multistreet(turn: true).copyWith(potLabel: 'Pot 10.5 BB'),
      ),
      _contradiction,
      'pot_mismatch',
    );
  });

  test('SYNTHETIC posted blind is committed; raise-to is not a call', () {
    // BTN raises to 3, SB folds: pot 0.5 + 1 + 3 = 4.5; BB adds 2, not 3.
    final table = _table(
      trail: [..._buttonOpen, 'BTN raises 3 BB', 'SB folds'],
      hero: 'BB',
      due: '2',
    );
    _expectFacts(
      act0TablePriceV1(table),
      street: 'preflop',
      pot: 4.5,
      prior: 0,
      current: 4.5,
      folded: 0.5,
      priceTo: 3,
      committed: 1,
      toMatch: 2,
      call: 2,
      capped: false,
      stack: 100,
    );
    _expectNotReady(
      act0TablePriceV1(table.copyWith(toCallLabel: 'To call 3 BB')),
      _contradiction,
      'display_price_mismatch',
    );
  });

  test('SYNTHETIC stack-capped call keeps the uncapped amount separate', () {
    final table = _table(
      trail: [..._flopStart, 'Flop: BB bets 2 BB'],
      street: 'Flop',
      due: '2',
      heroStack: '0.5 BB',
    );
    for (final display in ['To call 2 BB', 'To call 0.5 BB', '']) {
      _expectFacts(
        act0TablePriceV1(table.copyWith(toCallLabel: display)),
        street: 'flop',
        pot: 8.5,
        prior: 6.5,
        current: 2,
        folded: 0.5,
        priceTo: 2,
        committed: 0,
        toMatch: 2,
        call: 0.5,
        capped: true,
        stack: 0.5,
      );
    }
    _expectNotReady(
      act0TablePriceV1(table.copyWith(toCallLabel: 'To call 1 BB')),
      _contradiction,
      'display_price_mismatch',
    );
  });

  test('SYNTHETIC missing actor/stack/blinds/history: unavailable', () {
    _expectNotReady(
      act0TablePriceV1(_table().copyWith(activeSeatId: '')),
      _unavailable,
      'missing_active_actor',
    );
    _expectNotReady(
      act0TablePriceV1(_table(heroStack: null)),
      _unavailable,
      'missing_actor_stack',
    );
    final flopBet = [..._flopStart, 'Flop: BB bets 2 BB'];
    // Unknown stack: a display below the outstanding 2 may be a capped call.
    _expectNotReady(
      act0TablePriceV1(
        _table(trail: flopBet, street: 'Flop', due: '0.5', heroStack: null),
      ),
      _unavailable,
      'missing_actor_stack',
    );
    // ...but no stack can make a call larger than the outstanding amount.
    _expectNotReady(
      act0TablePriceV1(
        _table(trail: flopBet, street: 'Flop', due: '3', heroStack: null),
      ),
      _contradiction,
      'display_price_mismatch',
    );
    _expectNotReady(
      act0TablePriceV1(
        _table(trail: const ['Flop: BB checks'], street: 'Flop', due: ''),
      ),
      _unavailable,
      'missing_blind_start',
    );
    _expectNotReady(
      act0TablePriceV1(_table(trail: const ['CO raises 2 BB'])),
      _unavailable,
      'missing_blind_start',
    );
    _expectNotReady(
      act0TablePriceV1(_table(trail: const [])),
      _unavailable,
      'unrecorded_current_street',
    );
    _expectNotReady(
      act0TablePriceV1(_table(trail: [..._buttonOpen, 'Unknown source'])),
      _unavailable,
      'unsupported_history',
    );
    _expectNotReady(
      act0TablePriceV1(_table(scope: Act0TableScopeV1.explanation)),
      _unavailable,
      'not_played_hand',
    );
  });

  test('SYNTHETIC contradictory or unsupported labels are never the price', () {
    _expectNotReady(
      act0TablePriceV1(_table(pot: 'Pot 2 BB')),
      _contradiction,
      'pot_mismatch',
    );
    _expectNotReady(
      act0TablePriceV1(_table(due: '2')),
      _contradiction,
      'display_price_mismatch',
    );
    _expectNotReady(
      act0TablePriceV1(_table(pot: 'Pot about 2')),
      _unavailable,
      'unsupported_pot',
    );
    _expectNotReady(
      act0TablePriceV1(_table().copyWith(toCallLabel: 'To call some')),
      _unavailable,
      'unsupported_display_price',
    );
    // A provable contradiction outranks an unsupported claim.
    _expectNotReady(
      act0TablePriceV1(_table(pot: 'Pot about 2', due: '2')),
      _contradiction,
      'display_price_mismatch',
    );
  });

  test('SYNTHETIC wrong order, street or amount in the history', () {
    _expectNotReady(
      act0TablePriceV1(
        _table(
          trail: [
            ..._flopStart,
            'Flop: BB checks',
            'Turn: BB checks',
            'Flop: BB checks',
          ],
          street: 'Flop',
          due: '',
        ),
      ),
      _contradiction,
      'street_order',
    );
    // Current street label disagrees with the recorded history.
    _expectNotReady(
      act0TablePriceV1(
        _table(
          trail: [..._flopStart, 'Flop: BB bets 2 BB'],
          street: 'Turn',
          due: '2',
        ),
      ),
      _unavailable,
      'unrecorded_current_street',
    );
    _expectNotReady(
      act0TablePriceV1(_table(trail: [..._buttonOpen, 'UTG raises 3 BB'])),
      _contradiction,
      'action_after_fold',
    );
    _expectNotReady(
      act0TablePriceV1(
        _table(
          trail: [..._buttonOpen, 'BTN raises 3 BB', 'SB raises 2 BB'],
          hero: 'BB',
          due: '2',
        ),
      ),
      _contradiction,
      'inconsistent_aggression',
    );
    _expectNotReady(
      act0TablePriceV1(
        _table(
          trail: [
            ..._buttonOpen,
            'BTN raises 3 BB',
            'SB folds',
            'BB calls 2 BB',
          ],
          street: 'Preflop',
          due: '',
        ),
      ),
      _unavailable,
      'unproved_history_call',
    );
    _expectNotReady(
      act0TablePriceV1(
        _table(
          trail: [..._blinds, 'UTG folds', 'HJ folds', 'CO folds', 'BTN folds'],
        ),
      ),
      _contradiction,
      'inactive_actor',
    );
  });

  test('SYNTHETIC old option API keeps its verdicts, reasons, numbers', () {
    final base = _table();
    final call = act0BettingPriceForOptionV1(base, _probe('Call', '1'));
    expect(call.truth, Act0BettingPriceTruthV1.consistent);
    expect(call.reason, 'numeric_action_consistent');
    expect(call.sourceReady, isTrue);
    expect(call.callCostBb, 1);
    expect(call.amountToMatchBb, 1);
    expect(call.actorCommittedBb, 0);
    expect(call.additionalCostBb, 1);
    expect(call.minimumRaiseToBb, 2);
    expect(call.potBeforeActionBb, 1.5);
    final over = act0BettingPriceForOptionV1(base, _probe('Call', '1.5'));
    expect(over.truth, Act0BettingPriceTruthV1.contradiction);
    expect(over.reason, 'call_cost_mismatch');
    final under = act0BettingPriceForOptionV1(base, _probe('Raise to', '1.5'));
    expect(under.reason, 'wager_below_minimum');
    expect(under.minimumRaiseToBb, 2);
    final noDisplay = act0BettingPriceForOptionV1(
      base.copyWith(toCallLabel: ''),
      _probe('Call', '1'),
    );
    expect(noDisplay.truth, Act0BettingPriceTruthV1.unproved);
    expect(noDisplay.reason, 'missing_display_price');
    expect(noDisplay.sourceReady, isTrue);
    expect(
      act0BettingPriceBlocksAuthoredSuccessV1(base, _probe('Call', '1.5')),
      isTrue,
    );
    expect(
      act0BettingPriceBlocksAuthoredSuccessV1(
        base,
        _probe('Call', '1.5', correct: false),
      ),
      isFalse,
    );
    final capped = act0BettingPriceForOptionV1(
      _table(
        trail: [..._flopStart, 'Flop: BB bets 2 BB'],
        street: 'Flop',
        due: '2',
        heroStack: '0.5 BB',
      ),
      _probe('Call', '0.5'),
    );
    expect(capped.truth, Act0BettingPriceTruthV1.consistent);
    expect(capped.callCostBb, 0.5);
    expect(capped.amountToMatchBb, 2);
    final bb = act0BettingPriceForOptionV1(
      _table(
        trail: [..._buttonOpen, 'BTN raises 3 BB', 'SB folds'],
        hero: 'BB',
        due: '2',
      ),
      _probe('Raise to', '5'),
    );
    expect(bb.truth, Act0BettingPriceTruthV1.consistent);
    expect(bb.actorCommittedBb, 1);
    // Option-label checks still run before any table read.
    final units = act0BettingPriceForOptionV1(
      _table(trail: const []),
      _probe('Call to', '1'),
    );
    expect(units.reason, 'unsupported_option_units');
  });

  test('SYNTHETIC shared ledger: table read and old API agree exactly', () {
    final flopBet = [..._flopStart, 'Flop: BB bets 2 BB'];
    final tables = <Act0TableStateV1>[
      _table(),
      _table(pot: 'Pot 1.5 BB'),
      _table(pot: 'Pot 2 BB'),
      _table(pot: 'Pot about 2'),
      _table(due: '2'),
      _table(due: ''),
      _table(heroStack: null),
      _table().copyWith(activeSeatId: ''),
      _table(
        trail: [..._flopStart, 'Flop: BB checks'],
        street: 'Flop',
        due: '',
      ),
      _table(trail: flopBet, street: 'Flop', due: '2'),
      _table(trail: flopBet, street: 'Flop', due: '2', heroStack: '0.5 BB'),
      _table(trail: flopBet, street: 'Flop', due: '0.5', heroStack: null),
      _table(trail: flopBet, street: 'Turn', due: '2'),
      _table(
        trail: [..._buttonOpen, 'BTN raises 3 BB', 'SB folds'],
        hero: 'BB',
        due: '2',
      ),
      _table(trail: const ['CO raises 2 BB']),
      _table(trail: [..._buttonOpen, 'UTG raises 3 BB']),
      _table(scope: Act0TableScopeV1.explanation),
      _multistreet(turn: false),
      _multistreet(turn: true),
    ];
    for (final table in tables) {
      final read = act0TablePriceV1(table);
      final old = act0BettingPriceForOptionV1(table, _probe('Call', ''));
      _expectAgreement(read, old, table.actionTrail.map((i) => i.label));
    }
  });

  test('SYNTHETIC known reason split: unknown stack, display below due', () {
    // Flop BB bets 2; Hero stack unknown; display claims 0.5. Both APIs fail
    // closed; only the reason class differs (documented on act0TablePriceV1).
    final table = _table(
      trail: [..._flopStart, 'Flop: BB bets 2 BB'],
      street: 'Flop',
      due: '0.5',
      heroStack: null,
    );
    _expectNotReady(
      act0TablePriceV1(table),
      _unavailable,
      'missing_actor_stack',
    );
    final fold = act0BettingPriceForOptionV1(table, _probe('Fold', ''));
    expect(fold.truth, Act0BettingPriceTruthV1.contradiction);
    expect(fold.reason, 'display_price_mismatch');
    expect(fold.sourceReady, isFalse);
  });

  test('SYNTHETIC reading a price is pure and repeatable', () {
    final table = _table(
      trail: [..._buttonOpen, 'BTN raises 3 BB', 'SB folds'],
      hero: 'BB',
      due: '2',
    );
    final trail = table.actionTrail.map((item) => item.label).toList();
    final first = act0TablePriceV1(table);
    final second = act0TablePriceV1(table);
    expect(second.readiness, first.readiness);
    expect(second.reason, first.reason);
    expect(second.facts!.callCostBb, first.facts!.callCostBb);
    expect(second.facts!.potBeforeActionBb, first.facts!.potBeforeActionBb);
    expect(table.actionTrail.map((item) => item.label).toList(), trail);
    expect(table.toCallLabel, 'To call 2 BB');
    expect(table.potLabel, '');
  });

  test('real catalog: no throw, parity, w4_price_intro unavailable', () {
    var tables = 0;
    var sawW4Intro = false;
    for (final world in Act0ShellStateV1.sample.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          tables++;
          final table = task.runner.table;
          final read = act0TablePriceV1(table);
          expect(read.isReady, read.facts != null, reason: task.taskId);
          if (task.taskId == 'w4_price_intro') {
            sawW4Intro = true;
            // Current source lacks sufficient history/actor/stack proof.
            expect(read.isReady, isFalse, reason: read.reason);
            expect(read.facts, isNull);
          }
          for (final option in task.runner.options) {
            final old = act0BettingPriceForOptionV1(table, option);
            // Only options that reached the shared table read are comparable;
            // option-label and scope checks return before it. No taskId or
            // question is passed, so task exemptions never fire: this is a
            // shared-ledger parity census, not a runtime-faithful grade census.
            if (old.amountToMatchBb == null) continue;
            _expectNumbersAgree(read, old, task.taskId);
          }
        }
      }
    }
    expect(tables, greaterThan(0));
    expect(sawW4Intro, isTrue);
  });
}

void _expectAgreement(
  Act0TablePriceReadV1 read,
  Act0BettingPriceResultV1 old,
  Iterable<String> trail,
) {
  final context = '${read.reason} / ${old.reason} / ${trail.join(', ')}';
  if (old.amountToMatchBb == null) {
    // The shared reader failed: same reason, same fail-closed class.
    expect(read.reason, old.reason, reason: context);
    expect(read.facts, isNull, reason: context);
    expect(
      read.readiness,
      old.isContradiction ? _contradiction : _unavailable,
      reason: context,
    );
    return;
  }
  _expectNumbersAgree(read, old, context);
}

void _expectNumbersAgree(
  Act0TablePriceReadV1 read,
  Act0BettingPriceResultV1 old,
  String context,
) {
  // Readiness is exactly the old sourceReady with a non-negative outstanding
  // amount; ready numbers are the old numbers.
  expect(
    read.isReady,
    old.sourceReady && old.amountToMatchBb! >= 0,
    reason: context,
  );
  if (!read.isReady) return;
  final facts = read.facts!;
  expect(facts.potBeforeActionBb, old.potBeforeActionBb, reason: context);
  expect(facts.amountToMatchBb, old.amountToMatchBb, reason: context);
  expect(facts.callCostBb, old.callCostBb, reason: context);
  expect(facts.actorStreetCommittedBb, old.actorCommittedBb, reason: context);
  // Sums of separately converted doubles: compare within float tolerance.
  expect(
    facts.streetPriceToBb,
    closeTo(facts.actorStreetCommittedBb + facts.amountToMatchBb, 1e-9),
    reason: context,
  );
  expect(
    facts.priorStreetsPotBb + facts.currentStreetPotBb,
    closeTo(facts.potBeforeActionBb, 1e-9),
    reason: context,
  );
}
