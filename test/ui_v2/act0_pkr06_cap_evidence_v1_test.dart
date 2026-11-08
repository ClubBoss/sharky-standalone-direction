// Scoped cap evidence, not full PKR06 admission or a new betting engine.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_pot_showdown_truth_v1.dart';

Act0TableStateV1 _table(String id) => Act0ShellStateV1.sample.worlds
    .expand((w) => w.lessons)
    .expand((l) => l.taskList)
    .singleWhere((t) => t.taskId == id)
    .runner
    .table;

const _w9 = 'w9_bubble_table_risk_transfer';

void main() {
  test('PKR06 W9 source is applicable but missing stacks are UNPROVED', () {
    final t = _table(_w9);
    expect(t.scope, Act0TableScopeV1.playedHand);
    expect(t.potLabel, 'Pot 21 BB');
    expect(t.toCallLabel, 'To call 15.5 BB');
    expect(
      t.seats.singleWhere((s) => s.seatId == 'btn').currentBetLabel,
      '2.5 BB',
    );
    expect(
      t.seats.singleWhere((s) => s.seatId == 'bb').currentBetLabel,
      '18 BB',
    );
    expect(t.seats.singleWhere((s) => s.seatId == 'btn').stackLabel, isNull);
    expect(t.seats.singleWhere((s) => s.seatId == 'bb').stackLabel, isNull);
    expect(pkr06FindingsV1(_w9, t), isEmpty);
    final r = pkr06CapEvidenceV1(_w9, t);
    expect(r.applicability, Pkr06CapApplicabilityV1.playedHand);
    expect(r.verdict, PotTruthVerdictV1.unproved);
    expect(
      r.comparisons
          .singleWhere((c) => c.sourceLabel == 'BB shoves to 18 BB')
          .reason,
      'stack_missing:bb',
    );
  });

  test('PKR06 exact W9 18 to 999 mutation cannot certify cap evidence', () {
    final source = _table(_w9);
    const original = 'BB shoves to 18 BB';
    expect(source.actionTrail.where((a) => a.label == original), hasLength(1));
    final mutated = source.copyWith(
      actionTrail: [
        for (final a in source.actionTrail)
          if (a.label == original)
            const Act0ActionTrailItemV1(label: 'BB shoves to 999 BB')
          else
            a,
      ],
    );
    // Exactly the trail amount changes. No invented stacks/cards/outcomes.
    expect(mutated.seats, source.seats);
    expect(mutated.heroCards, same(source.heroCards));
    expect(mutated.boardCards, same(source.boardCards));
    expect(mutated.potLabel, 'Pot 21 BB');
    expect(mutated.toCallLabel, 'To call 15.5 BB');
    expect(
      mutated.seats.singleWhere((s) => s.seatId == 'bb').currentBetLabel,
      '18 BB',
    );
    final r = pkr06CapEvidenceV1(_w9, mutated);
    expect(r.verdict, PotTruthVerdictV1.unproved);
    expect(
      r.comparisons
          .singleWhere((c) => c.sourceLabel == 'BB shoves to 999 BB')
          .verdict,
      PotTruthVerdictV1.unproved,
    );
    expect(source.actionTrail.last.label, original);
  });

  test('PKR06 source-owned amount comparisons preserve all three verdicts', () {
    final t = _table('what_poker_is_all_in_meaning');
    final hero = t.seats.singleWhere((s) => s.isHero);
    final co = t.seats.singleWhere((s) => s.seatId == 'co');
    expect(hero.stackLabel, '0 BB');
    expect(hero.currentBetLabel, '20 BB');
    expect(co.stackLabel, '80 BB');
    expect(co.currentBetLabel, '20 BB');
    final r = pkr06CapEvidenceV1('source', t);
    expect(r.applicability, Pkr06CapApplicabilityV1.historical);
    final positive = r.comparisons.singleWhere(
      (c) => c.sourceLabel == 'Hero shoves 20 BB',
    );
    expect(positive.verdict, PotTruthVerdictV1.proved);
    expect(positive.reason, 'source_amount_within_preflop_budget');
    // Existing source stack + commitment remains unchanged. Only a negative
    // trail mutation is introduced, never a replacement source hand.
    final bad = t.copyWith(
      actionTrail: [
        ...t.actionTrail,
        const Act0ActionTrailItemV1.note(label: 'CO calls 999 BB'),
      ],
    );
    final negative = pkr06CapEvidenceV1('negative', bad);
    expect(negative.verdict, PotTruthVerdictV1.contradiction);
    final overCap = negative.comparisons.singleWhere(
      (c) => c.sourceLabel == 'CO calls 999 BB',
    );
    expect(overCap.verdict, PotTruthVerdictV1.contradiction);
    expect(overCap.reason, 'amount_exceeds_preflop_budget');
    expect(
      pkr06FindingsV1('negative', bad).map((f) => f.rule),
      contains('bet_exceeds_stack'),
    );
  });

  test('PKR06 earlier affordable shove is not capped by a later snapshot', () {
    final source = _table('what_poker_is_all_in_meaning');
    final hero = source.seats.singleWhere((s) => s.isHero);
    expect(hero.stackLabel, '0 BB');
    expect(hero.currentBetLabel, '20 BB');
    // Test-only temporal projection: the actual affordable preflop20 is now
    // historical, and the all-in player's current-street commitment is zero.
    // No starting stacks or board cards are fabricated. This sparse projection
    // is not a complete legal flop fixture and must not certify anything.
    final later = source.copyWith(
      streetLabel: 'Flop',
      seats: [
        for (final s in source.seats)
          if (!s.isHero)
            s
          else
            Act0SeatStateV1(
              seatId: s.seatId,
              seatLabel: s.seatLabel,
              displayName: s.displayName,
              isHero: s.isHero,
              isDealerButton: s.isDealerButton,
              isSmallBlind: s.isSmallBlind,
              isBigBlind: s.isBigBlind,
              blindAmountLabel: s.blindAmountLabel,
              isActive: s.isActive,
              isTarget: s.isTarget,
              isInHand: s.isInHand,
              isFolded: s.isFolded,
              hasActed: s.hasActed,
              isLastAggressor: s.isLastAggressor,
              isOccupied: s.isOccupied,
              stackLabel: s.stackLabel,
              holeCards: s.holeCards,
              cardsVisibleMode: s.cardsVisibleMode,
              currentBetLabel: '0 BB',
            ),
      ],
    );
    // Document the legacy false-cap diagnostic, but do not promote it.
    expect(
      pkr06FindingsV1('late', later).map((f) => f.rule),
      contains('bet_exceeds_stack'),
    );
    final result = pkr06CapEvidenceV1('late', later);
    final oldShove = result.comparisons.singleWhere(
      (c) => c.sourceLabel == 'Hero shoves 20 BB',
    );
    expect(oldShove.verdict, PotTruthVerdictV1.unproved);
    expect(oldShove.reason, 'source_time_budget_unproved');
    expect(result.verdict, PotTruthVerdictV1.unproved);
  });

  test('PKR06 absent commitment cannot promote a legacy cap diagnostic', () {
    final source = _table('what_poker_is_all_in_meaning');
    final hero = source.seats.singleWhere((s) => s.isHero);
    expect(source.streetLabel, 'Preflop');
    expect(hero.stackLabel, '0 BB');
    expect(hero.currentBetLabel, '20 BB');
    // Delete only Hero currentBetLabel. Keep the preflop trail, behind0,
    // typed bet and every other source field unchanged; null is not zero.
    final missing = source.copyWith(
      seats: [
        for (final s in source.seats)
          if (!s.isHero)
            s
          else
            Act0SeatStateV1(
              seatId: s.seatId,
              seatLabel: s.seatLabel,
              displayName: s.displayName,
              isHero: s.isHero,
              isDealerButton: s.isDealerButton,
              isSmallBlind: s.isSmallBlind,
              isBigBlind: s.isBigBlind,
              blindAmountLabel: s.blindAmountLabel,
              isActive: s.isActive,
              isTarget: s.isTarget,
              isInHand: s.isInHand,
              isFolded: s.isFolded,
              hasActed: s.hasActed,
              isLastAggressor: s.isLastAggressor,
              isOccupied: s.isOccupied,
              stackLabel: s.stackLabel,
              holeCards: s.holeCards,
              cardsVisibleMode: s.cardsVisibleMode,
              currentBetLabel: null,
              bet: s.bet,
            ),
      ],
    );
    expect(missing.actionTrail, same(source.actionTrail));
    expect(missing.seats.singleWhere((s) => s.isHero).currentBetLabel, isNull);
    final result = pkr06CapEvidenceV1('missing', missing);
    final row = result.comparisons.singleWhere(
      (c) => c.sourceLabel == 'Hero shoves 20 BB',
    );
    expect(row.verdict, PotTruthVerdictV1.unproved);
    expect(row.reason, 'commitment_missing:btn');
    expect(result.verdict, PotTruthVerdictV1.unproved);
    expect(result.findings.map((f) => f.rule), contains('bet_exceeds_stack'));
    expect(
      pkr06FindingsV1('missing', missing).map((f) => f.rule),
      contains('bet_exceeds_stack'),
    );
  });

  test('PKR06 folded dead-blind unknowns remain historical, not playable', () {
    var missingDeadBlinds = 0;
    for (final id in [
      'what_poker_is_all_in_meaning',
      'what_poker_is_matched_chips_transfer',
      'what_poker_is_side_pot_intro',
    ]) {
      final t = _table(id);
      final r = pkr06CapEvidenceV1(id, t);
      expect(r.applicability, Pkr06CapApplicabilityV1.historical);
      for (final s in t.seats.where(
        (s) =>
            s.isFolded &&
            (potTruthBbV1(s.currentBetLabel) ?? 0) > 0 &&
            s.stackLabel == null,
      )) {
        missingDeadBlinds++;
        expect(
          r.comparisons
              .singleWhere(
                (c) => c.sourceLabel == 'seats.${s.seatId}.currentBetLabel',
              )
              .verdict,
          PotTruthVerdictV1.unproved,
        );
      }
    }
    expect(missingDeadBlinds, 5);
  });

  test('PKR06 scope and coverage produce their own rejection evidence', () {
    // Start with real known-input proof, not W9 whose null stacks can mask a
    // deleted scope/coverage guard. Assert the specific guard's own row.
    final t = _table('what_poker_is_all_in_meaning');
    expect(
      pkr06CapEvidenceV1('known', t).comparisons
          .singleWhere((c) => c.sourceLabel == 'Hero shoves 20 BB')
          .verdict,
      PotTruthVerdictV1.proved,
    );
    final scope = pkr06CapEvidenceV1(
      'scope',
      t.copyWith(scope: Act0TableScopeV1.unclassified),
    );
    expect(scope.applicability, Pkr06CapApplicabilityV1.unknown);
    final scopeRow = scope.comparisons.singleWhere(
      (c) => c.sourceLabel == 'scope',
    );
    expect(scopeRow.verdict, PotTruthVerdictV1.unproved);
    expect(scopeRow.reason, 'scope_unclassified');
    expect(scope.verdict, PotTruthVerdictV1.unproved);

    final empty = pkr06CapEvidenceV1(
      'empty',
      t.copyWith(actionTrail: const []),
    );
    final coverage = empty.comparisons.singleWhere(
      (c) => c.sourceLabel == 'actionTrail',
    );
    expect(coverage.verdict, PotTruthVerdictV1.unproved);
    expect(coverage.reason, 'no_cap_comparisons');
    expect(empty.verdict, PotTruthVerdictV1.unproved);

    const unsupported = 'Unknown shoves to 18 BB';
    final unknown = pkr06CapEvidenceV1(
      'unknown',
      t.copyWith(
        actionTrail: const [Act0ActionTrailItemV1(label: unsupported)],
      ),
    );
    final unsupportedRow = unknown.comparisons.singleWhere(
      (c) => c.sourceLabel == unsupported,
    );
    expect(unsupportedRow.verdict, PotTruthVerdictV1.unproved);
    expect(unsupportedRow.reason, 'unsupported_trail_label');
    expect(unknown.verdict, PotTruthVerdictV1.unproved);
  });
}
