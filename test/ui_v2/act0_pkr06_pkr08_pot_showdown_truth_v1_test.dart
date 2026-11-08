// PKR-06 (stacks, all-in, eligibility, side pots) and PKR-08 (showdown,
// winner/tie, payout) over every authored table of the shipped catalog.
// MACHINE source oracle only: no Human, native or Runner-render claim.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

import '../support/act0_pot_showdown_truth_v1.dart';

Iterable<Act0LessonTaskV1> _tasks() sync* {
  for (final world in Act0ShellStateV1.sample.worlds) {
    for (final lesson in world.lessons) {
      yield* lesson.taskList;
    }
  }
}

Act0LessonTaskV1 _task(String id) =>
    _tasks().singleWhere((t) => t.taskId == id);

Act0SeatStateV1 _seat(
  Act0SeatStateV1 s, {
  bool? isInHand,
  bool? isFolded,
  String? stackLabel,
  String? currentBetLabel,
  List<Act0CardStateV1>? holeCards,
  Act0CardsVisibleModeV1? cardsVisibleMode,
}) => Act0SeatStateV1(
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
  isInHand: isInHand ?? s.isInHand,
  isFolded: isFolded ?? s.isFolded,
  hasActed: s.hasActed,
  isLastAggressor: s.isLastAggressor,
  isOccupied: s.isOccupied,
  stackLabel: stackLabel ?? s.stackLabel,
  holeCards: holeCards ?? s.holeCards,
  cardsVisibleMode: cardsVisibleMode ?? s.cardsVisibleMode,
  currentBetLabel: currentBetLabel ?? s.currentBetLabel,
  bet: s.bet,
);

Act0TableStateV1 _mapSeats(
  Act0TableStateV1 t,
  Act0SeatStateV1 Function(Act0SeatStateV1) f,
) => t.copyWith(seats: t.seats.map(f).toList());

Act0TableStateV1 _foldOthers(Act0TableStateV1 t, Set<String> keep) => _mapSeats(
  t,
  (s) => keep.contains(s.seatId)
      ? s
      : _seat(
          s,
          isInHand: false,
          isFolded: true,
          cardsVisibleMode: Act0CardsVisibleModeV1.none,
        ),
);

/// Contradictions found on main 2cfda326 in authored explanation tables.
/// Only the single integrator may remove entries, together with the authored
/// catalog repair; the list may shrink, never grow.
const _pkr06AuthoredResidual = <String>{};

/// Graded answers that name a showdown outcome, with the source-determined
/// winning seats. A pot is shared equally between tied winners.
const _pkr08OutcomeClaims = <String, Set<String>>{
  'w6_kicker_showdown_compare': {'btn'},
  'w6_board_pair_strength_compare': {'co'},
  'w6_checkpoint_table_best_five': {'btn', 'co'},
  'hand_rankings_quads_vs_full_house_drill': {'btn'},
};

/// Outcome claims whose winner is not yet determined by source cards (live
/// opponents with hidden hands could beat or tie). Shrink-only, see above.
const _pkr08AuthoredResidual = <String>{};

/// Questions that ask the learner to name who wins the showdown pot.
final _outcomeQuestion = RegExp(
  r'who wins|stronger at showdown|before the pot is pushed',
  caseSensitive: false,
);

void main() {
  test('PKR06 every stack, all-in and side-pot table matches its own data', () {
    final findings = <String>{};
    var applicable = 0;
    for (final t in _tasks()) {
      if (!pkr06ApplicableV1(t.runner.table)) continue;
      applicable++;
      findings.addAll(
        pkr06FindingsV1(t.taskId, t.runner.table).map((f) => f.key),
      );
    }
    expect(applicable, greaterThan(80), reason: 'oracle must see the catalog');
    expect(findings, _pkr06AuthoredResidual);
  });

  test('PKR06 declared side pot is recomputed from contributions', () {
    final t = _task('what_poker_is_side_pot_intro').runner.table;
    expect(t.potLabel, 'Main 60.5 BB; side 60 BB');
    final keys = pkr06FindingsV1('x', t).map((f) => f.rule).toSet();
    expect(keys, isNot(contains('side_pot_amounts')));
    expect(keys, isNot(contains('bet_exceeds_stack')));
    // UTG/HJ folds are authored in the side-pot trail and SB's fold is in its
    // own trail note, so the shipped table is fully consistent.
    expect(pkr06FindingsV1('x', t), isEmpty);
    for (final id in ['utg', 'hj', 'sb']) {
      final seat = t.seats.singleWhere((s) => s.seatId == id);
      expect(seat.isFolded && !seat.isInHand, isTrue, reason: id);
    }
    final bb = t.seats.singleWhere((s) => s.seatId == 'bb');
    expect(bb.isInHand && !bb.isFolded, isTrue, reason: 'BB contributes');
  });

  // Added authored all-in history (content decision): every action parses,
  // CO's limp counts as a 1 BB contribution, and the folded seats carry their
  // folds in the trail, so the scenes are consistent without inferred facts.
  test('PKR06 added all-in history is parsed and consistent', () {
    for (final id in [
      'what_poker_is_all_in_meaning',
      'what_poker_is_matched_chips_transfer',
    ]) {
      final t = _task(id).runner.table;
      expect(pkr06FindingsV1(id, t), isEmpty, reason: id);
      expect(t.potLabel, 'Pot 41.5 BB');
      final co = [
        for (final item in t.actionTrail)
          if (potTruthParseActionV1(t, item.label) case final a?
              when a.actor == 'CO')
            (a.chipVerb, a.amount),
      ];
      expect(co, [('call', 1.0), ('call', 20.0)], reason: id);
      for (final seat in t.seats.where(
        (s) => !{'btn', 'co'}.contains(s.seatId),
      )) {
        expect(seat.isFolded && !seat.isInHand, isTrue, reason: seat.seatId);
        final actor = seat.seatLabel.toUpperCase();
        expect(
          t.actionTrail.any((item) {
            final a = potTruthParseActionV1(t, item.label);
            return a?.verb == 'fold' && a?.actor == actor;
          }),
          isTrue,
          reason: '$id $actor fold provenance',
        );
      }
    }
  });

  // Eligibility for each pot, recomputed from contributions and liveness, must
  // match the graded side-pot statement (Hero: main only).
  test('PKR06 each pot is contested only by the seats that matched it', () {
    final task = _task('what_poker_is_side_pot_intro');
    final t = task.runner.table;
    final put = {
      for (final s in t.seats) s.seatId: potTruthBbV1(s.currentBetLabel) ?? 0,
    };
    final live = {
      for (final s in t.seats)
        if (s.isInHand && !s.isFolded) s.seatId,
    };
    final level = put['btn']!; // Hero's all-in sets the main-pot level.
    final main = {
      for (final id in live)
        if (put[id]! >= level) id,
    };
    final side = {
      for (final id in live)
        if (put[id]! > level) id,
    };
    expect(main, {'btn', 'co', 'bb'});
    expect(side, {'co', 'bb'});
    expect(
      task.runner.options.singleWhere((o) => o.isCorrect).id,
      'hero_main_only',
    );
  });

  // Fail-closed inventory: where the source omits stacks, the cap cannot be
  // proved and is reported here instead of being assumed. Shrink-only.
  test('PKR06 contributions without an authored stack are explicit', () {
    final allInWithoutStack = <String>{};
    final otherWithoutStack = <String>{};
    for (final task in _tasks()) {
      final t = task.runner.table;
      if (!pkr06ApplicableV1(t)) continue;
      final seats = {for (final s in t.seats) s.seatLabel.toUpperCase(): s};
      for (final item in t.actionTrail) {
        final a = potTruthParseActionV1(t, item.label);
        if (a == null || !potTruthContributionVerbsV1.contains(a.chipVerb)) {
          continue;
        }
        if (seats[a.actor]?.stackLabel != null) continue;
        (a.chipVerb == 'all_in' ? allInWithoutStack : otherWithoutStack).add(
          '${task.taskId}:${a.actor}',
        );
      }
      for (final s in t.seats) {
        if (s.stackLabel == null && potTruthBbV1(s.currentBetLabel) != null) {
          final actor = s.seatLabel.toUpperCase();
          if (!{'SB', 'BB'}.contains(actor)) {
            otherWithoutStack.add('${task.taskId}:$actor');
          }
        }
      }
    }
    expect(allInWithoutStack, {'w9_bubble_table_risk_transfer:BB'});
    // Besides blind posts (0.5/1 BB, never stacked in the catalog), only the
    // bubble spot's BTN raise lacks a stack.
    expect(
      otherWithoutStack.where((k) => !k.endsWith(':SB') && !k.endsWith(':BB')),
      {'w9_bubble_table_risk_transfer:BTN'},
    );
  });

  test('PKR06 negative controls fail closed', () {
    // Synthetic consistent control: UTG/HJ folds are added to the trail so the
    // seat flags carry provenance. This is not a claim about the source hand.
    final sidePot = _task('what_poker_is_side_pot_intro').runner.table;
    final base = _foldOthers(
      sidePot.copyWith(
        actionTrail: [
          const Act0ActionTrailItemV1.note(label: 'UTG folds'),
          const Act0ActionTrailItemV1.note(label: 'HJ folds'),
          ...sidePot.actionTrail,
        ],
      ),
      {'btn', 'co', 'bb'},
    );
    expect(pkr06FindingsV1('x', base), isEmpty);
    Set<String> rules(Act0TableStateV1 t) =>
        pkr06FindingsV1('x', t).map((f) => f.rule).toSet();

    // A bet larger than the chips a seat owns.
    expect(
      rules(
        base.copyWith(
          actionTrail: [
            ...base.actionTrail,
            const Act0ActionTrailItemV1.note(label: 'CO raises to 140 BB'),
          ],
        ),
      ),
      contains('bet_exceeds_stack'),
    );
    // Every attributed verb is capped, not only raises (review 5815162573).
    for (final verb in ['calls', 'bets', 'posts']) {
      expect(
        rules(
          base.copyWith(
            actionTrail: [
              ...base.actionTrail,
              Act0ActionTrailItemV1.note(label: 'CO $verb 999 BB'),
            ],
          ),
        ),
        contains('bet_exceeds_stack'),
        reason: verb,
      );
    }
    // Every contribution verb before a fold stays capped while the action
    // stays a fold (reviews 6715993358, 6716215513).
    for (final clause in [
      'posts 999 BB',
      'blind 999 BB',
      'calls 999 BB',
      'bets 999 BB',
      'raises to 999 BB',
      'contributes 999 BB total',
      'shoves 999 BB',
    ]) {
      final label = 'CO $clause, then folds';
      final parsed = potTruthParseActionV1(base, label);
      expect(parsed?.verb, 'fold', reason: label);
      expect(parsed?.chipVerb, isNotNull, reason: label);
      expect(
        rules(
          base.copyWith(
            actionTrail: [
              ...base.actionTrail,
              Act0ActionTrailItemV1.note(label: label),
            ],
          ),
        ),
        containsAll(['bet_exceeds_stack', 'folded_seat_live']),
        reason: label,
      );
    }
    // A plain fold carries no contribution.
    expect(potTruthParseActionV1(base, 'CO folds')?.chipVerb, isNull);
    // An all-in player shown with chips behind.
    expect(
      rules(
        _mapSeats(base, (s) => s.isHero ? _seat(s, stackLabel: '5 BB') : s),
      ),
      contains('all_in_with_chips_behind'),
    );
    // Zero behind but no all-in in the source.
    expect(
      rules(
        _mapSeats(
          base,
          (s) => s.seatId == 'co' ? _seat(s, stackLabel: '0 BB') : s,
        ),
      ),
      contains('zero_stack_without_all_in'),
    );
    // Wrong side-pot amount.
    expect(
      rules(base.copyWith(potLabel: 'Main 60.5 BB; side 40 BB')),
      contains('side_pot_amounts'),
    );
    // A folded player shown live (eligible for chips).
    expect(
      rules(
        _mapSeats(
          base,
          (s) =>
              s.seatId == 'sb' ? _seat(s, isInHand: true, isFolded: false) : s,
        ),
      ),
      contains('folded_seat_live'),
    );
    // A live player who neither matched the all-in nor folded.
    expect(
      rules(
        _mapSeats(
          base,
          (s) =>
              s.seatId == 'utg' ? _seat(s, isInHand: true, isFolded: false) : s,
        ),
      ),
      contains('live_seat_neither_matched_nor_folded'),
    );
    // Unparseable amounts are never treated as zero.
    expect(
      rules(
        _mapSeats(
          base,
          (s) => s.seatId == 'co' ? _seat(s, currentBetLabel: 'lots') : s,
        ),
      ),
      contains('amount_unparsed'),
    );
    // A malformed BB amount on any contribution is reported, never skipped
    // (review 6717829622).
    for (final clause in [
      'bets several BB',
      'calls several BB',
      'raises to several BB',
      'contributes several BB total',
      'posts several BB',
      'posts several BB, then folds',
    ]) {
      final label = 'CO $clause';
      expect(
        rules(
          base.copyWith(
            actionTrail: [
              ...base.actionTrail,
              Act0ActionTrailItemV1.note(label: label),
            ],
          ),
        ),
        contains('action_amount_unparsed'),
        reason: label,
      );
    }
    // An action without any amount is not a malformed amount.
    expect(
      rules(
        base.copyWith(
          actionTrail: [
            ...base.actionTrail,
            const Act0ActionTrailItemV1.note(label: 'CO calls'),
          ],
        ),
      ),
      isNot(contains('action_amount_unparsed')),
    );
  });

  test('PKR08 every graded showdown outcome is resolved from source cards', () {
    final classified = {..._pkr08OutcomeClaims.keys, ..._pkr08AuthoredResidual};
    for (final t in _tasks()) {
      final asksOutcome = _outcomeQuestion.hasMatch(t.runner.question);
      if (asksOutcome) {
        expect(classified, contains(t.taskId), reason: t.runner.question);
      }
    }
    for (final entry in _pkr08OutcomeClaims.entries) {
      final r = resolveShowdownTruthV1(_task(entry.key).runner.table);
      expect(
        r.verdict,
        PotTruthVerdictV1.proved,
        reason: '${entry.key} ${r.reason}',
      );
      expect(r.winners.toSet(), entry.value, reason: entry.key);
      // Payout: the whole pot, shared equally by the tied winners only.
      final share = r.potBb! / r.winners.length;
      expect(share * r.winners.length, r.potBb);
      final table = _task(entry.key).runner.table;
      for (final id in r.winners) {
        final seat = table.seats.singleWhere((s) => s.seatId == id);
        expect(seat.isInHand && !seat.isFolded, isTrue, reason: '$id eligible');
      }
    }
    for (final id in _pkr08AuthoredResidual) {
      final r = resolveShowdownTruthV1(_task(id).runner.table);
      expect(r.verdict, PotTruthVerdictV1.unproved, reason: id);
      expect(r.reason, startsWith('hidden_live_hand_can_win_or_tie'));
    }
  });

  test('PKR08 graded winner matches the authored correct option', () {
    // The graded label must name exactly the oracle winner(s).
    const labels = <String, String>{
      'w6_kicker_showdown_compare': 'Hero A-K',
      'w6_board_pair_strength_compare': 'Villain K-8',
      'w6_checkpoint_table_best_five': 'Split the pot',
      'hand_rankings_quads_vs_full_house_drill': 'Hero four of a kind',
    };
    for (final e in labels.entries) {
      final correct = _task(e.key).runner.options.where((o) => o.isCorrect);
      expect(correct.map((o) => o.label), [e.value], reason: e.key);
    }
  });

  // Playable consumer parity: the real Runner's showdown read must name the
  // same winner(s) as the oracle, and must stay silent where the oracle cannot
  // determine the winner from source cards.
  Future<void> pumpTheory(WidgetTester tester, Act0RunnerStateV1 runner) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner.copyWith(
              teachingSteps: const [],
              phase: Act0LessonPhaseV1.theory,
            ),
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_card_board_0')));
    await tester.pumpAndSettle();
  }

  String? shownRead(WidgetTester tester) {
    for (final w in tester.widgetList<Text>(find.byType(Text))) {
      final s = w.data ?? w.textSpan?.toPlainText() ?? '';
      if (s.startsWith('Best shown hand:') ||
          s.startsWith('Tied best hands:')) {
        return s;
      }
    }
    return null;
  }

  // Lessons whose Runner offers the interactive showdown read; this anchor
  // keeps the parity check from passing vacuously.
  const runnerShowsRead = {
    'w6_kicker_showdown_compare',
    'w6_checkpoint_table_best_five',
  };
  for (final id in _pkr08OutcomeClaims.keys) {
    testWidgets(
      'PKR08 Runner showdown read never contradicts the oracle: $id',
      (tester) async {
        final runner = _task(id).runner;
        final r = resolveShowdownTruthV1(runner.table);
        await pumpTheory(tester, runner);
        final read = shownRead(tester);
        if (runnerShowsRead.contains(id)) expect(read, isNotNull, reason: id);
        if (read == null) return; // the Runner may stay silent, never disagree
        expect(read, isNot(contains('You win with')));
        if (r.winners.length > 1) {
          expect(read, startsWith('Tied best hands:'));
          for (final w in r.winners) {
            final seat = runner.table.seats.singleWhere((s) => s.seatId == w);
            expect(read, contains(seat.isHero ? 'You' : seat.seatLabel));
          }
        } else {
          final seat = runner.table.seats.singleWhere(
            (s) => s.seatId == r.winners.single,
          );
          expect(
            read,
            startsWith(
              'Best shown hand: ${seat.isHero ? 'You' : seat.seatLabel} ',
            ),
          );
        }
      },
    );
  }

  for (final id in _pkr08AuthoredResidual) {
    testWidgets('PKR08 Runner names no winner while hands are hidden: $id', (
      tester,
    ) async {
      await pumpTheory(tester, _task(id).runner);
      expect(find.textContaining('Best shown hand:'), findsNothing);
      expect(find.textContaining('Tied best hands:'), findsNothing);
    });
  }

  // A comparison of the two shown hands: graded by their cards alone, while
  // the whole-pot winner stays unproved because four live hands are hidden.
  test('PKR08 two-hand comparison never names a whole-pot winner', () {
    final task = _task('hand_rankings_full_house_vs_flush_drill');
    final table = task.runner.table;
    expect(_outcomeQuestion.hasMatch(task.runner.question), isFalse);
    List<String> cards(Iterable<Act0CardStateV1> c) =>
        c.map(potTruthSolverCardV1).cast<String>().toList();
    final board = cards(table.boardCards);
    final hero = Hand.solveHand([...board, ...cards(table.heroCards)]);
    final co = table.seats.singleWhere((s) => s.seatId == 'co');
    final villain = Hand.solveHand([...board, ...cards(co.holeCards)]);
    expect(hero.compare(villain), lessThan(0), reason: 'Hero hand is stronger');
    expect(task.runner.options.where((o) => o.isCorrect).map((o) => o.id), [
      'hero_full_house',
    ]);
    final whole = resolveShowdownTruthV1(table);
    expect(whole.verdict, PotTruthVerdictV1.unproved);
    expect(whole.reason, startsWith('hidden_live_hand_can_win_or_tie'));

    // Every learner-visible string stays a two-hand comparison: no winner,
    // pot award or split wording anywhere in the task (independent review
    // gap: question-only matching let 'Which hand wins the pot?' or
    // 'Correct winner.' regress silently).
    final runner = task.runner;
    final visible = <String>[
      runner.caption,
      runner.hint,
      runner.question,
      runner.feedbackTitle,
      runner.feedbackReason,
      table.centerLabel,
      for (final o in runner.options) ...[
        o.label,
        o.preferredLabel,
        o.betterAnswerLabel,
        o.feedbackTitle,
        o.feedbackReason,
        ...o.repairFocusLabels,
      ],
      for (final s in runner.teachingSteps) ...[
        s.title,
        s.body,
        ...s.focusLabels,
      ],
    ];
    final wholePotClaim = RegExp(
      r'\bwin|\bwon\b|\bpot\b|scoop|\bchop|\bsplit',
      caseSensitive: false,
    );
    expect(
      visible.where(wholePotClaim.hasMatch).toList(),
      isEmpty,
      reason: 'two-hand comparison must not claim the whole pot',
    );
  });

  testWidgets('PKR08 Runner names no whole-pot winner on the comparison', (
    tester,
  ) async {
    await pumpTheory(
      tester,
      _task('hand_rankings_full_house_vs_flush_drill').runner,
    );
    expect(find.textContaining('Best shown hand:'), findsNothing);
    expect(find.textContaining('Tied best hands:'), findsNothing);
  });

  test('PKR08 negative controls never invent a winner or payout', () {
    final base = _task('w6_kicker_showdown_compare').runner.table;
    expect(resolveShowdownTruthV1(base).winners, ['btn']);

    // A live opponent with hidden cards blocks the verdict.
    final hiddenOpponent = _mapSeats(
      base,
      (s) => s.seatId == 'co'
          ? _seat(s, cardsVisibleMode: Act0CardsVisibleModeV1.faceDown)
          : s,
    );
    expect(
      resolveShowdownTruthV1(hiddenOpponent).verdict,
      PotTruthVerdictV1.unproved,
    );

    // A source trail fold contradicting a live seat must not prove a winner
    // (review 6717471702).
    final trailFoldLive = base.copyWith(
      actionTrail: [
        ...base.actionTrail,
        const Act0ActionTrailItemV1.note(label: 'BTN folds'),
      ],
    );
    final trailFoldVerdict = resolveShowdownTruthV1(trailFoldLive);
    expect(trailFoldVerdict.verdict, PotTruthVerdictV1.unproved);
    expect(trailFoldVerdict.reason, 'folded_seat_live:btn');

    // A folded player is never paid even with the best cards.
    final foldedWinner = _mapSeats(
      base,
      (s) => s.isHero ? _seat(s, isInHand: false, isFolded: true) : s,
    );
    expect(
      resolveShowdownTruthV1(foldedWinner).verdict,
      PotTruthVerdictV1.unproved,
    );

    // Duplicate physical card.
    final dup = base.copyWith(
      boardCards: [...base.boardCards.take(4), base.heroCards.first],
    );
    expect(resolveShowdownTruthV1(dup).reason, 'duplicate_card');

    // Incomplete board.
    final turn = base.copyWith(boardCards: base.boardCards.take(4).toList());
    expect(resolveShowdownTruthV1(turn).reason, 'board_incomplete');

    // A side pot needs per-pot eligibility the catalog does not author.
    final sidePot = base.copyWith(potLabel: 'Main 6 BB; side 5 BB');
    expect(
      resolveShowdownTruthV1(sidePot).reason,
      'side_pot_showdown_not_supported',
    );

    // Changing the real cards changes the winner: no fixed answer survives.
    final swapped = _mapSeats(
      base,
      (s) => s.seatId == 'co'
          ? _seat(
              s,
              holeCards: const [
                Act0CardStateV1(
                  rank: 'K',
                  suit: 's',
                  tone: Act0CardToneV1.dark,
                ),
                Act0CardStateV1(rank: '9', suit: 'd', tone: Act0CardToneV1.red),
              ],
            )
          : s,
    );
    expect(resolveShowdownTruthV1(swapped).winners, ['co']);

    // Review 6714410161: fold flags without fold/showdown provenance must not
    // turn hidden live opponents into proven losers.
    final residual = _task(
      'hand_rankings_full_house_vs_flush_drill',
    ).runner.table;
    final flagOnly = resolveShowdownTruthV1(
      _foldOthers(residual, {'btn', 'co'}),
    );
    expect(flagOnly.verdict, PotTruthVerdictV1.unproved);
    expect(flagOnly.reason, startsWith('fold_without_provenance'));
    // The same folds with explicit trail provenance do resolve the hand.
    final withProvenance = _foldOthers(
      residual.copyWith(
        actionTrail: [
          for (final seat in ['UTG', 'HJ', 'SB', 'BB'])
            Act0ActionTrailItemV1.note(label: '$seat folds'),
        ],
      ),
      {'btn', 'co'},
    );
    expect(resolveShowdownTruthV1(withProvenance).winners, ['btn']);
  });
}
