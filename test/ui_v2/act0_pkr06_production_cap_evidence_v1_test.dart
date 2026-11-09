import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_pkr06_cap_evidence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _w9 = 'w9_bubble_table_risk_transfer';
const _allIn = 'what_poker_is_all_in_meaning';

Act0TableStateV1 _table(String id) => Act0ShellStateV1.sample.worlds
    .expand((world) => world.lessons)
    .expand((lesson) => lesson.taskList)
    .singleWhere((task) => task.taskId == id)
    .runner
    .table;

Act0Pkr06CapRowV1 _actionRow(Act0Pkr06CapEvidenceV1 evidence, String label) =>
    evidence.rows.singleWhere(
      (row) =>
          row.sourcePath.startsWith('actionTrail[') && row.sourceLabel == label,
    );

// Test-only field projections. Never write these back into the catalog.
Act0SeatStateV1 _seat(
  Act0SeatStateV1 source, {
  String? seatId,
  String? stack,
  String? committed,
  bool removeCommitment = false,
  bool? isHero,
}) => Act0SeatStateV1(
  seatId: seatId ?? source.seatId,
  seatLabel: source.seatLabel,
  displayName: source.displayName,
  isHero: isHero ?? source.isHero,
  isDealerButton: source.isDealerButton,
  isSmallBlind: source.isSmallBlind,
  isBigBlind: source.isBigBlind,
  blindAmountLabel: source.blindAmountLabel,
  isActive: source.isActive,
  isTarget: source.isTarget,
  isInHand: source.isInHand,
  isFolded: source.isFolded,
  hasActed: source.hasActed,
  isLastAggressor: source.isLastAggressor,
  isOccupied: source.isOccupied,
  stackLabel: stack ?? source.stackLabel,
  holeCards: source.holeCards,
  cardsVisibleMode: source.cardsVisibleMode,
  currentBetLabel: removeCommitment
      ? null
      : committed ?? source.currentBetLabel,
  bet: source.bet,
);

void main() {
  test('PKR06 production evidence preserves original W9 unknown budget', () {
    final source = _table(_w9);
    final result = act0Pkr06CapEvidenceForTableV1(source);
    expect(source.potLabel, 'Pot 21 BB');
    expect(source.toCallLabel, 'To call 15.5 BB');
    expect(
      source.seats.singleWhere((s) => s.seatId == 'btn').currentBetLabel,
      '2.5 BB',
    );
    expect(
      source.seats.singleWhere((s) => s.seatId == 'btn').stackLabel,
      isNull,
    );
    expect(
      source.seats.singleWhere((s) => s.seatId == 'bb').currentBetLabel,
      '18 BB',
    );
    expect(
      source.seats.singleWhere((s) => s.seatId == 'bb').stackLabel,
      isNull,
    );
    expect(result.scope, Act0Pkr06CapScopeV1.playedHand);
    expect(result.amountVerdict, Act0Pkr06CapVerdictV1.unproved);
    final row = _actionRow(result, 'BB shoves to 18 BB');
    expect(row.actorSeatId, 'bb');
    expect(row.verdict, Act0Pkr06CapVerdictV1.unproved);
    expect(row.reason, Act0Pkr06CapReasonV1.stackMissingOrUnsupported);
    expect(row.preflopBudgetMicros, isNull);
  });

  test('PKR06 exact W9 18 to 999 mutation invents neither cap nor excess', () {
    final source = _table(_w9);
    const original = 'BB shoves to 18 BB';
    expect(
      source.actionTrail.where((item) => item.label == original),
      hasLength(1),
    );
    final mutated = source.copyWith(
      actionTrail: [
        for (final item in source.actionTrail)
          if (item.label == original)
            const Act0ActionTrailItemV1(label: 'BB shoves to 999 BB')
          else
            item,
      ],
    );
    expect(mutated.seats, source.seats);
    expect(mutated.heroCards, same(source.heroCards));
    expect(mutated.boardCards, same(source.boardCards));
    expect(mutated.potLabel, source.potLabel);
    expect(mutated.toCallLabel, source.toCallLabel);
    expect(
      mutated.seats.singleWhere((s) => s.seatId == 'bb').currentBetLabel,
      '18 BB',
    );
    final result = act0Pkr06CapEvidenceForTableV1(mutated);
    final row = _actionRow(result, 'BB shoves to 999 BB');
    expect(row.verdict, Act0Pkr06CapVerdictV1.unproved);
    expect(row.reason, Act0Pkr06CapReasonV1.stackMissingOrUnsupported);
    expect(row.preflopBudgetMicros, isNull);
    expect(result.amountVerdict, Act0Pkr06CapVerdictV1.unproved);
    expect(source.actionTrail.last.label, original);
  });

  test('PKR06 exact Hero20 positive and CO999 negative have own evidence', () {
    final source = _table(_allIn);
    final hero = source.seats.singleWhere((s) => s.isHero);
    final co = source.seats.singleWhere((s) => s.seatId == 'co');
    expect(hero.stackLabel, '0 BB');
    expect(hero.currentBetLabel, '20 BB');
    expect(co.stackLabel, '80 BB');
    expect(co.currentBetLabel, '20 BB');
    final result = act0Pkr06CapEvidenceForTableV1(source);
    final positive = _actionRow(result, 'Hero shoves 20 BB');
    expect(positive.verdict, Act0Pkr06CapVerdictV1.proved);
    expect(positive.reason, Act0Pkr06CapReasonV1.amountWithinPreflopBudget);
    expect(positive.actorSeatId, hero.seatId);
    expect(positive.amountMicros, 20000000);
    expect(positive.preflopBudgetMicros, 20000000);
    final mutation = source.copyWith(
      actionTrail: [
        ...source.actionTrail,
        const Act0ActionTrailItemV1.note(label: 'CO calls 999 BB'),
      ],
    );
    final negative = act0Pkr06CapEvidenceForTableV1(mutation);
    final overCap = _actionRow(negative, 'CO calls 999 BB');
    expect(overCap.verdict, Act0Pkr06CapVerdictV1.contradiction);
    expect(overCap.reason, Act0Pkr06CapReasonV1.amountExceedsPreflopBudget);
    expect(overCap.amountMicros, 999000000);
    expect(overCap.preflopBudgetMicros, 100000000);
    expect(negative.amountVerdict, Act0Pkr06CapVerdictV1.contradiction);
  });

  test(
    'PKR06 later snapshot cannot falsely cap an earlier affordable shove',
    () {
      final source = _table(_allIn);
      final later = source.copyWith(
        streetLabel: 'Flop',
        seats: [
          for (final seat in source.seats)
            if (seat.isHero) _seat(seat, committed: '0 BB') else seat,
        ],
      );
      // Intentionally incomplete temporal projection, not a legal flop fixture.
      final result = act0Pkr06CapEvidenceForTableV1(later);
      final row = _actionRow(result, 'Hero shoves 20 BB');
      expect(row.verdict, Act0Pkr06CapVerdictV1.unproved);
      expect(row.reason, Act0Pkr06CapReasonV1.sourceTimeBudgetUnproved);
      expect(row.preflopBudgetMicros, isNull);
      expect(result.amountVerdict, Act0Pkr06CapVerdictV1.unproved);
    },
  );

  test(
    'PKR06 missing commitment is not zero or a legacy cap contradiction',
    () {
      final source = _table(_allIn);
      final missing = source.copyWith(
        seats: [
          for (final seat in source.seats)
            if (seat.isHero) _seat(seat, removeCommitment: true) else seat,
        ],
      );
      expect(missing.actionTrail, same(source.actionTrail));
      expect(missing.seats.singleWhere((s) => s.isHero).stackLabel, '0 BB');
      final result = act0Pkr06CapEvidenceForTableV1(missing);
      final row = _actionRow(result, 'Hero shoves 20 BB');
      expect(row.verdict, Act0Pkr06CapVerdictV1.unproved);
      expect(row.reason, Act0Pkr06CapReasonV1.commitmentMissingOrUnsupported);
      expect(result.amountVerdict, Act0Pkr06CapVerdictV1.unproved);
    },
  );

  test('PKR06 folded dead-blind unknowns keep historical source scope', () {
    var unknownDeadBlinds = 0;
    for (final id in [
      _allIn,
      'what_poker_is_matched_chips_transfer',
      'what_poker_is_side_pot_intro',
    ]) {
      final source = _table(id);
      final result = act0Pkr06CapEvidenceForTableV1(source);
      expect(result.scope, Act0Pkr06CapScopeV1.historical);
      for (var index = 0; index < source.seats.length; index++) {
        final seat = source.seats[index];
        if (!seat.isFolded ||
            seat.stackLabel != null ||
            !const {'0.5 BB', '1 BB'}.contains(seat.currentBetLabel))
          continue;
        unknownDeadBlinds++;
        final row = result.rows.singleWhere(
          (row) => row.sourcePath == 'seats[$index].currentBetLabel',
        );
        expect(row.actorSeatId, seat.seatId);
        expect(row.verdict, Act0Pkr06CapVerdictV1.unproved);
        expect(row.reason, Act0Pkr06CapReasonV1.stackMissingOrUnsupported);
      }
    }
    expect(unknownDeadBlinds, 5);
  });

  test('PKR06 scope and coverage guards produce their own negative rows', () {
    final source = _table(_allIn);
    expect(
      _actionRow(
        act0Pkr06CapEvidenceForTableV1(source),
        'Hero shoves 20 BB',
      ).verdict,
      Act0Pkr06CapVerdictV1.proved,
    );
    final unknownScope = act0Pkr06CapEvidenceForTableV1(
      source.copyWith(scope: Act0TableScopeV1.unclassified),
    );
    final scopeRow = unknownScope.rows.singleWhere(
      (r) => r.sourcePath == 'scope',
    );
    expect(scopeRow.reason, Act0Pkr06CapReasonV1.scopeUnclassified);
    expect(scopeRow.verdict, Act0Pkr06CapVerdictV1.unproved);
    expect(unknownScope.scope, Act0Pkr06CapScopeV1.unknown);
    expect(unknownScope.amountVerdict, Act0Pkr06CapVerdictV1.unproved);

    final empty = act0Pkr06CapEvidenceForTableV1(
      source.copyWith(actionTrail: const []),
    );
    final emptyRow = empty.rows.singleWhere(
      (r) => r.sourcePath == 'actionTrail',
    );
    expect(emptyRow.reason, Act0Pkr06CapReasonV1.noCapComparisons);
    expect(emptyRow.verdict, Act0Pkr06CapVerdictV1.unproved);
    expect(empty.amountVerdict, Act0Pkr06CapVerdictV1.unproved);

    const label = 'Unknown shoves to 18 BB';
    final unsupported = act0Pkr06CapEvidenceForTableV1(
      source.copyWith(actionTrail: const [Act0ActionTrailItemV1(label: label)]),
    );
    final unsupportedRow = _actionRow(unsupported, label);
    expect(unsupportedRow.reason, Act0Pkr06CapReasonV1.unsupportedTrailLabel);
    expect(unsupportedRow.verdict, Act0Pkr06CapVerdictV1.unproved);
    expect(unsupported.amountVerdict, Act0Pkr06CapVerdictV1.unproved);
  });

  test('PKR06 ambiguous Hero or duplicate seat ID cannot prove that row', () {
    final source = _table(_allIn);
    for (final seats in [
      [
        for (final s in source.seats)
          if (s.seatId == 'co') _seat(s, isHero: true) else s,
      ],
      [
        for (final s in source.seats)
          if (s.seatId == 'co') _seat(s, seatId: 'btn') else s,
      ],
    ]) {
      final result = act0Pkr06CapEvidenceForTableV1(
        source.copyWith(seats: seats),
      );
      final row = _actionRow(result, 'Hero shoves 20 BB');
      expect(row.verdict, Act0Pkr06CapVerdictV1.unproved);
      expect(row.reason, Act0Pkr06CapReasonV1.actorNotUnique);
    }
  });

  test(
    'PKR06 decimal excess is exact and unsupported amounts stay unknown',
    () {
      final source = _table(_allIn);
      final excess = source.copyWith(
        actionTrail: [
          for (final item in source.actionTrail)
            if (item.label == 'Hero shoves 20 BB')
              const Act0ActionTrailItemV1.note(
                label: 'Hero shoves 20.000001 BB',
              )
            else
              item,
        ],
      );
      final row = _actionRow(
        act0Pkr06CapEvidenceForTableV1(excess),
        'Hero shoves 20.000001 BB',
      );
      expect(row.verdict, Act0Pkr06CapVerdictV1.contradiction);
      expect(row.amountMicros, 20000001);
      expect(row.preflopBudgetMicros, 20000000);
      for (final stack in ['NaN BB', '-1 BB', 'Infinity BB', '10000000 BB']) {
        final malformed = source.copyWith(
          seats: [
            for (final seat in source.seats)
              if (seat.isHero) _seat(seat, stack: stack) else seat,
          ],
        );
        final unknown = _actionRow(
          act0Pkr06CapEvidenceForTableV1(malformed),
          'Hero shoves 20 BB',
        );
        expect(unknown.verdict, Act0Pkr06CapVerdictV1.unproved);
        expect(unknown.reason, Act0Pkr06CapReasonV1.stackMissingOrUnsupported);
      }
      final badCommitment = source.copyWith(
        seats: [
          for (final seat in source.seats)
            if (seat.isHero) _seat(seat, committed: '20.0000001 BB') else seat,
        ],
      );
      final unsupportedCommitment = _actionRow(
        act0Pkr06CapEvidenceForTableV1(badCommitment),
        'Hero shoves 20 BB',
      );
      expect(unsupportedCommitment.verdict, Act0Pkr06CapVerdictV1.unproved);
      expect(
        unsupportedCommitment.reason,
        Act0Pkr06CapReasonV1.commitmentMissingOrUnsupported,
      );
      const badLabel = 'Hero shoves NaN BB';
      final badAction = source.copyWith(
        actionTrail: [
          for (final item in source.actionTrail)
            if (item.label == 'Hero shoves 20 BB')
              const Act0ActionTrailItemV1.note(label: badLabel)
            else
              item,
        ],
      );
      final unsupportedAction = _actionRow(
        act0Pkr06CapEvidenceForTableV1(badAction),
        badLabel,
      );
      expect(unsupportedAction.verdict, Act0Pkr06CapVerdictV1.unproved);
      expect(
        unsupportedAction.reason,
        Act0Pkr06CapReasonV1.unsupportedTrailLabel,
      );
    },
  );

  test(
    'PKR06 board and trail time guards each reject their own projection',
    () {
      final source = _table(_allIn);
      // Reuse supplied cards only to make an inconsistent nonempty-board
      // projection. This is not a new hand and cannot establish a legal flop.
      final suppliedBoard = _table('your_first_hand_turn').boardCards;
      expect(suppliedBoard, isNotEmpty);
      final boardProjection = source.copyWith(boardCards: suppliedBoard);
      final boardRow = _actionRow(
        act0Pkr06CapEvidenceForTableV1(boardProjection),
        'Hero shoves 20 BB',
      );
      expect(boardRow.verdict, Act0Pkr06CapVerdictV1.unproved);
      expect(boardRow.reason, Act0Pkr06CapReasonV1.sourceTimeBudgetUnproved);
      const lateLabel = 'Flop: Hero shoves 20 BB';
      final trailProjection = source.copyWith(
        actionTrail: [
          for (final item in source.actionTrail)
            if (item.label == 'Hero shoves 20 BB')
              const Act0ActionTrailItemV1.note(label: lateLabel)
            else
              item,
        ],
      );
      final trailRow = _actionRow(
        act0Pkr06CapEvidenceForTableV1(trailProjection),
        lateLabel,
      );
      expect(trailRow.verdict, Act0Pkr06CapVerdictV1.unproved);
      expect(trailRow.reason, Act0Pkr06CapReasonV1.sourceTimeBudgetUnproved);
    },
  );

  test(
    'PKR06 bounded amount proof is immutable and not complete hand proof',
    () {
      final source = _table(_allIn);
      // A one-row projection preserves exact source numbers but intentionally
      // lacks a full roster/history. This test certifies only the named amount.
      final projection = source.copyWith(
        seats: [source.seats.singleWhere((s) => s.isHero)],
        actionTrail: [
          source.actionTrail.singleWhere(
            (item) => item.label == 'Hero shoves 20 BB',
          ),
        ],
      );
      final result = act0Pkr06CapEvidenceForTableV1(projection);
      expect(result.scope, Act0Pkr06CapScopeV1.historical);
      expect(result.amountVerdict, Act0Pkr06CapVerdictV1.proved);
      expect(result.rows, hasLength(1));
      expect(
        result.rows.single.reason,
        Act0Pkr06CapReasonV1.amountWithinPreflopBudget,
      );
      expect(() => result.rows.clear(), throwsUnsupportedError);
      expect(source.seats, hasLength(6));
      expect(source.actionTrail, hasLength(8));
    },
  );
}
