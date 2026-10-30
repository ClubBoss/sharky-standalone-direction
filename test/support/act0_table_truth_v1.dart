import 'package:poker_solver/poker_solver.dart';
// Catalog invariants over the actual Runner projection. Not a betting engine.
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

class TableTruthRow {
  TableTruthRow(
    this.taskId,
    this.variant,
    this.invariant,
    this.result,
    this.detail,
  );
  final String taskId, variant, invariant, result, detail;
  String get key => '$taskId|$variant|$invariant|$detail';
  Map<String, Object?> toJson() => {
    'task_id': taskId,
    'step_phase_variant': variant,
    'invariant': invariant,
    'result': result,
    'expectation_or_exception': detail,
    'source': 'Act0ShellStateV1.sample',
    'rendered_ownership':
        variant.endsWith('/raw') || variant.startsWith('authored/')
        ? 'raw authored source'
        : 'canonical Runner table projection',
    'evidence_kind': 'DETERMINISTIC_SOURCE_PROJECTION',
  };
}

String cardIdentity(Act0CardStateV1 c) =>
    '${c.rank == '10' ? 'T' : c.rank}${c.suit}';
const streets = {'Preflop': 0, 'Flop': 3, 'Turn': 4, 'River': 5};

List<TableTruthRow> auditTableTruth() {
  final rows = <TableTruthRow>[];
  for (final world in Act0ShellStateV1.sample.worlds) {
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        final r = task.runner;
        if (lesson.lessonId == 'your_first_hand') {
          final opening = lesson.taskList.first.runner.table.heroCards
              .map(cardIdentity)
              .join(',');
          final hand = r.table.heroCards.map(cardIdentity).join(',');
          rows.add(
            TableTruthRow(
              task.taskId,
              'declared-same-hand',
              'D4.hand_continuity',
              hand == opening ? 'PASS' : 'FAIL',
              'opening=$opening current=$hand',
            ),
          );
        }

        final states = <String, Act0TableStateV1>{
          'authored/${task.phase.name}': r.table,
          for (var i = 0; i < r.teachingSteps.length; i++)
            'teaching/$i/raw': r.teachingSteps[i].table ?? r.table,
          for (var i = 0; i < r.teachingSteps.length; i++)
            'teaching/$i/projected': act0TeachingTableForRunnerV1(
              r.table,
              r.teachingSteps[i],
            ),
          'decision': r.table,
          for (final o in r.options)
            'feedback/${o.id}': act0FeedbackTableForRunnerV1(
              runner: r.copyWith(
                phase: Act0LessonPhaseV1.review,
                selectedOptionId: o.id,
                teachingStepIndex: r.teachingSteps.length,
              ),
              taskFamily: task.resolvedTaskFamily,
            ),
          'review': r.table,
        };
        final plan = act0TableChoreographyPlanForTableV1(r.table);
        if (plan != null)
          for (var i = 0; i < plan.beats.length; i++) {
            states['choreography/$i/${plan.beats[i].kind.name}'] =
                act0TableForChoreographyFrameV1(
                  r.table,
                  act0TableChoreographyFrameAfterBeatV1(plan, i),
                );
          }
        for (final e in states.entries) {
          final t = e.value;
          final v = e.key;
          void check(String id, bool ok, String detail) => rows.add(
            TableTruthRow(task.taskId, v, id, ok ? 'PASS' : 'FAIL', detail),
          );
          final physical =
              [
                    ...t.heroCards,
                    ...t.boardCards,
                    for (final s in t.seats)
                      if (!s.isHero &&
                          s.isOccupied &&
                          s.isInHand &&
                          !s.isFolded &&
                          s.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp)
                        ...s.holeCards,
                  ]
                  .where((c) => c.suit.isNotEmpty && c.rank != '?')
                  .map(cardIdentity)
                  .toList();
          check(
            'D5.deck_unique',
            physical.toSet().length == physical.length,
            'physical deck ${physical.join(',')}',
          );
          check(
            'D6.street_board',
            streets[t.streetLabel] == t.boardCards.length,
            '${t.streetLabel}:${t.boardCards.length}',
          );
          final actor =
              (t.activeSeatId ??
                  t.seats
                      .where((s) => s.isActive)
                      .map((s) => s.seatId)
                      .firstOrNull) ??
              '';
          final actorSeat = t.seats.where((s) => s.seatId == actor).firstOrNull;
          final activeFlags = t.seats
              .where((s) => s.isActive)
              .map((s) => s.seatId)
              .toList();
          check(
            'D1.actor_consistency',
            (t.activeSeatId ?? '').isEmpty ||
                activeFlags.isEmpty ||
                (activeFlags.length == 1 &&
                    activeFlags.single == t.activeSeatId),
            'explicit=${t.activeSeatId} flags=${activeFlags.join(',')}',
          );
          final seatIds = t.seats.map((s) => s.seatId).toSet();
          for (final id in t.highlightedSeatIds)
            check('clue.seat_exists', seatIds.contains(id), 'seat=$id');

          check(
            'D1.actor_live',
            actor.isEmpty ||
                (actorSeat != null &&
                    actorSeat.isOccupied &&
                    actorSeat.isInHand &&
                    !actorSeat.isFolded),
            'actor=$actor',
          );
          // An explicit actor is admitted for actor/position questions and replay beats.
          final actorQuestion =
              r.options.any((o) => o.seatId != null) ||
              RegExp(
                r'\b(UTG|HJ|CO|SB|BB)\b.*(act|pressure|discipline)|who .*act|which .*seat|which .*position',
                caseSensitive: false,
              ).hasMatch(r.question);
          if (!v.startsWith('choreography/') &&
              r.options.isNotEmpty &&
              !actorQuestion) {
            check(
              'D1.decision_actor',
              actor.isEmpty || actor == t.heroSeat.seatId,
              'actor=$actor hero=${t.heroSeat.seatId}',
            );
          }
          for (final s in t.seats) {
            check(
              'D3.bet_label_owner',
              s.bet == null ||
                  ![
                    'UTG',
                    'HJ',
                    'CO',
                    'BTN',
                    'SB',
                    'BB',
                  ].contains(s.bet!.label.toUpperCase()) ||
                  s.bet!.label.toLowerCase() == s.seatId.toLowerCase(),
              'seat=${s.seatId} label=${s.bet?.label}',
            );
            check(
              'D3.no_old_blind',
              t.streetLabel == 'Preflop' ||
                  (s.bet?.kind != Act0SeatBetKindV1.post &&
                      (s.blindAmountLabel ?? '').isEmpty),
              'seat=${s.seatId} street=${t.streetLabel}',
            );
          }
          if (!v.startsWith('choreography/')) {
            final trail = t.actionTrail.map((a) => a.label).join(' | ');
            for (final m in RegExp(
              r'\b(UTG|HJ|CO|BTN|SB|BB) folds\b',
              caseSensitive: false,
            ).allMatches(trail)) {
              final s = t.seats
                  .where(
                    (s) => s.seatLabel.toUpperCase() == m[1]!.toUpperCase(),
                  )
                  .firstOrNull;
              check(
                'D2.explicit_fold',
                s != null && s.isFolded && !s.isInHand,
                'folded=${m[1]}',
              );
            }
            // A present street prefix is authoritative. Unprefixed fragments do not
            // establish a complete history or permission for guessed pot arithmetic.
            final described = RegExp(
              r'\b(Preflop|Flop|Turn|River):',
              caseSensitive: false,
            ).allMatches(trail).map((m) => m[1]!.toLowerCase()).toList();
            if (described.isNotEmpty) {
              final index = [
                'preflop',
                'flop',
                'turn',
                'river',
              ].indexOf(t.streetLabel.toLowerCase());
              check(
                'D6.no_future_action',
                described.every(
                  (s) =>
                      ['preflop', 'flop', 'turn', 'river'].indexOf(s) <= index,
                ),
                'trail=$trail',
              );
            }
            // Explicit current hand claims, not keywords in wrong answers or generic
            // teaching about a possible hand category.
            final named = RegExp(
              r'(?:Hero (?:holds|has)|you hold) ([AKQJT2-9])-([AKQJT2-9])\b',
            ).firstMatch(r.caption);
            if (named != null) {
              final actual = t.heroCards.map((c) => c.rank).toList()..sort();
              final expected = [named[1]!, named[2]!]..sort();
              check(
                'D4.named_hole_cards',
                actual.join(',') == expected.join(','),
                'named=${expected.join(',')} actual=${actual.join(',')}',
              );
            }
            if (t.heroCards.length == 2 &&
                t.heroCards.every((c) => c.suit.isNotEmpty) &&
                t.boardCards.length >= 3) {
              final claim = RegExp(
                r'(?:Hero|[AKQJT2-9]-[AKQJT2-9]) (?:has|flopped|makes) (top pair|two pair|a set|a flush|a straight)',
                caseSensitive: false,
              ).firstMatch('${r.caption} ${r.hint}');
              if (claim != null) {
                final hand = Hand.solveHand(
                  [...t.heroCards, ...t.boardCards].map(cardIdentity).toList(),
                );
                final expected = {
                  'top pair': 'Pair',
                  'two pair': 'Two Pair',
                  'a set': 'Three of a Kind',
                  'a flush': 'Flush',
                  'a straight': 'Straight',
                }[claim[1]!.toLowerCase()]!;
                check(
                  'D4.made_hand',
                  madeHandClaimMatches(t, claim[1]!.toLowerCase()),
                  'claim=$expected actual=${hand.name}',
                );
              }
            }
            // Last explicitly sized current-street bet must be shown at that seat.
            // A trailing open/raise without a street declaration is deliberately not
            // guessed to be a current postflop commitment.
            final currentBet = explicitCurrentStreetBet(t);
            if (currentBet != null) {
              final seat = t.seats
                  .where((s) => s.seatLabel == currentBet.$1)
                  .first;
              final amount = RegExp(
                r'^(\d+(?:\.\d+)?) BB$',
              ).firstMatch(seat.bet?.amountLabel ?? '');
              check(
                'D3.explicit_current_bet',
                seat.bet?.kind == Act0SeatBetKindV1.bet &&
                    amount != null &&
                    double.parse(amount[1]!) == currentBet.$2,
                'owner=${currentBet.$1} amount=${currentBet.$2} BB',
              );
            }
            if (t.boardCards.isNotEmpty) {
              final claim = RegExp(
                r'\b(one|two) overcards\b',
                caseSensitive: false,
              ).firstMatch('${r.caption} ${r.hint}');
              if (claim != null) {
                int rank(String r) =>
                    '23456789TJQKA'.indexOf(r == '10' ? 'T' : r);
                final high = t.boardCards
                    .map((c) => rank(c.rank))
                    .reduce((a, b) => a > b ? a : b);
                final count = t.heroCards
                    .where((c) => rank(c.rank) > high)
                    .length;
                check(
                  'D4.overcards',
                  count == (claim[1]!.toLowerCase() == 'one' ? 1 : 2),
                  'claimed=${claim[1]} actual=$count',
                );
              }
            }
            final shown = t.highlightedCardIds.where(
              (id) => RegExp(r'^(hero|board)_\d+$').hasMatch(id),
            );
            for (final id in shown) {
              final p = id.split('_');
              final n = int.parse(p[1]);
              check(
                'clue.visible',
                n < (p[0] == 'hero' ? t.heroCards.length : t.boardCards.length),
                'clue=$id',
              );
            }
            if (t.streetLabel != 'Preflop')
              rows.add(
                TableTruthRow(
                  task.taskId,
                  v,
                  'D2.pot_feasibility',
                  'NEEDS_SOURCE_CONTEXT',
                  'No complete contribution/ante ledger; visible current-street bets are not whole-pot inputs.',
                ),
              );
            if (t.toCallLabel.isNotEmpty)
              rows.add(
                TableTruthRow(
                  task.taskId,
                  v,
                  'D3.to_call_completeness',
                  'NEEDS_SOURCE_CONTEXT',
                  'Need complete current-street commitments; missing chips do not identify an actor.',
                ),
              );
          }
        }
      }
    }
  }
  return rows;
}

// Existing poker_solver owns hand ranking; these are claim-specific identity
// constraints, not a new hand evaluator or gameplay engine.
bool madeHandClaimMatches(Act0TableStateV1 table, String claim) {
  final h = Hand.solveHand(
    [...table.heroCards, ...table.boardCards].map(cardIdentity).toList(),
  );
  final names = {
    'top pair': 'Pair',
    'two pair': 'Two Pair',
    'a set': 'Three of a Kind',
    'a flush': 'Flush',
    'a straight': 'Straight',
  };
  if (h.name != names[claim]) return false;
  if (claim == 'top pair') {
    int rank(String r) => '23456789TJQKA'.indexOf(r == '10' ? 'T' : r);
    final high = table.boardCards
        .map((c) => rank(c.rank))
        .reduce((a, b) => a > b ? a : b);
    return table.boardCards.where((c) => rank(c.rank) == high).length == 1 &&
        table.heroCards.any((c) => rank(c.rank) == high);
  }
  if (claim == 'a set')
    return table.heroCards.length == 2 &&
        table.heroCards[0].rank == table.heroCards[1].rank &&
        table.boardCards
                .where((c) => c.rank == table.heroCards[0].rank)
                .length ==
            1;
  return true;
}

(String, double)? explicitCurrentStreetBet(Act0TableStateV1 table) {
  String? declaredStreet;
  (String, double)? candidate;
  for (final item in table.actionTrail) {
    final header = RegExp(
      r'^(Preflop|Flop|Turn|River)(?::| dealt)',
      caseSensitive: false,
    ).firstMatch(item.label);
    if (header != null) {
      declaredStreet = header[1]!.toLowerCase();
      candidate = null; // commitments from an earlier street are collected.
    }
    final bet = RegExp(
      r'\b(UTG|HJ|CO|BTN|SB|BB) bets (\d+(?:\.\d+)?) BB',
    ).firstMatch(item.label);
    if (bet != null &&
        (declaredStreet == null ||
            declaredStreet == table.streetLabel.toLowerCase()))
      candidate = (bet[1]!, double.parse(bet[2]!));
  }
  return candidate;
}
