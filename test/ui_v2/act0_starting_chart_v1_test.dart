import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_starting_chart_v1.dart';

final _tasks = [
  for (final world in Act0ShellStateV1.sample.worlds)
    if (world.worldNumber == 2 || world.worldNumber == 3)
      for (final lesson in world.lessons) ...lesson.taskList,
];

void main() {
  final chart = CatalogStartingChart.foundation();

  test('W2 introduces first in before the two exact starting chart pages', () {
    final steps = _tasks
        .singleWhere((t) => t.taskId == 'hand_discipline_buckets_intro')
        .runner
        .teachingSteps;
    expect(steps, hasLength(3));
    expect(steps.first.title, 'You are first in.');
    expect(steps.first.body, contains('the players before you folded'));
    expect(
      '${steps.first.title} ${steps.first.body}'.split(RegExp(r'\s+')).length,
      lessThanOrEqualTo(60),
    );
    expect(
      steps
          .singleWhere((s) => s.title == 'Groups and seats, before a raise.')
          .body,
      'T means ten. Suited means same suit (s); offsuit means different suits (o).\n\n'
      '${renderStartingChartOpening()}',
    );
    expect(
      steps.singleWhere((s) => s.title == 'On BTN after a raise.').body,
      renderStartingChartFacingRaise(),
    );
  });

  test('starting chart has the intended AJ and KJ opening boundaries', () {
    for (final code in ['AJo', 'ATo']) {
      expect(chart.opening[code]?.group, 'Medium');
      expect(chart.opening[code]?.seats, ['HJ', 'CO', 'BTN']);
    }
    for (final code in ['KJs', 'KJo']) {
      expect(chart.opening[code]?.group, 'Medium');
      expect(chart.opening[code]?.seats, ['CO', 'BTN']);
    }
    expect(chart.callHands, contains('KJs'));
  });

  test('Q9 keeps Strong pairs and uses the BTN facing-open row for Medium', () {
    final strong = _tasks
        .singleWhere((task) => task.taskId == 'w2_narrow_three_bet_strong')
        .runner;
    final btn = _tasks
        .singleWhere((task) => task.taskId == 'w2_narrow_three_bet_medium')
        .runner
        .table;
    final co = strong.table;
    List<Act0CardStateV1> hand(
      String first,
      String second, {
      bool suited = false,
    }) => [
      Act0CardStateV1(rank: first, suit: 'h'),
      Act0CardStateV1(rank: second, suit: suited ? 'h' : 'c'),
    ];

    expect(chart.expected(co, groupOnly: true), 'Strong');
    expect(chart.expected(co, groupOnly: false, narrowThreeBet: true), 'call');
    expect(
      strong.options.singleWhere(act0RunnerOptionIsAuthoredCorrectV1).id,
      'call',
    );
    for (final (table, cards, action) in [
      (co, hand('J', 'J'), 'call'),
      (co, hand('T', 'T'), 'call'),
      (co, hand('K', 'T'), 'fold'),
      (co, hand('Q', 'J', suited: true), 'fold'),
      (btn, hand('K', 'T'), 'fold'),
      (btn, hand('K', 'Q'), 'call'),
      (btn, hand('K', 'J', suited: true), 'call'),
      (btn, hand('Q', 'J', suited: true), 'call'),
      (co, hand('A', 'K'), 'raise'),
      (co, hand('A', '5'), 'fold'),
    ]) {
      expect(
        chart.expected(
          table.copyWith(heroCards: cards),
          groupOnly: false,
          narrowThreeBet: true,
        ),
        action,
        reason:
            '${table.heroSeatId} ${cards.map((card) => card.label).join(" ")}',
      );
    }
  });

  test('W2 facing-open feedback separates the blind pot and the open', () {
    for (final (id, opener) in const [
      ('weak_ace_warning_w3_strong_continue', 'hj'),
      ('continue_or_let_go_medium_call_or_fold', 'co'),
      ('discipline_checkpoint_checkpoint_borderline_continue', 'co'),
    ]) {
      final runner = _tasks.singleWhere((task) => task.taskId == id).runner;
      final table = runner.table;
      final ledger = table.handContributions!;
      final open = ledger.entries.singleWhere(
        (entry) => entry.kind == Act0ContributionKindV1.wager,
      );
      expect(open.seatId, opener, reason: id);
      expect(open.amountBb, 2.5, reason: id);
      final beforeOpen = ledger.entries
          .takeWhile((entry) => entry != open)
          .fold<double>(0, (pot, entry) => pot + entry.amountBb);
      final decision = ledger.amounts(
        seatIds: table.seats.map((seat) => seat.seatId).toSet(),
        actorSeatId: 'btn',
      );
      expect(beforeOpen, 1.5, reason: id);
      expect(decision, (potBb: 4.0, toCallBb: 2.5), reason: id);
      expect(
        runner.options.singleWhere(act0RunnerOptionIsAuthoredCorrectV1).id,
        'call',
        reason: id,
      );
      expect(
        runner.options
            .singleWhere((option) => option.id == 'fold')
            .feedbackReason,
        startsWith(
          '${opener.toUpperCase()} opened to 2.5 BB with 1.5 BB in the pot. '
          'The pot is 4 BB after the open.',
        ),
        reason: id,
      );
    }
  });

  test('W2–W3 chart decisions match the teaching rows and the table', () {
    var checked = 0;
    for (final task in _tasks) {
      final runner = task.runner;
      if (runner.options.isEmpty) continue;
      final correct = runner.options.singleWhere(
        act0RunnerOptionIsAuthoredCorrectV1,
      );
      if (runner.lessonId == 'w3_play_from_blinds') {
        final table = runner.table;
        expect(chartRaisers(table), ['BTN'], reason: task.taskId);
        switch (table.heroSeat.seatId) {
          case 'sb':
            expect(
              correct.id,
              chart.smallBlindVsButton(table),
              reason: task.taskId,
            );
          case 'bb':
            final amounts = table.handContributions!.amounts(
              actorSeatId: table.heroSeatId,
              seatIds: table.seats.map((seat) => seat.seatId).toSet(),
            );
            final call = amounts.toCallBb!;
            if (task.taskId.endsWith('_price')) {
              expect(correct.label, '$call BB', reason: task.taskId);
            } else {
              final statedChance = double.parse(
                RegExp(r'you win (\d+)%').firstMatch(runner.caption)![1]!,
              );
              expect(
                correct.id,
                statedChance >= 100 * call / (amounts.potBb + call)
                    ? 'call'
                    : 'fold',
                reason: task.taskId,
              );
            }
          default:
            fail('Unexpected hero seat in ${task.taskId}');
        }
        checked++;
        continue;
      }
      final group = startingChartGroups.contains(correct.id);
      final preflop = runner.table.streetLabel == 'Preflop';
      if (!referencesStartingChart(runner) &&
          !(preflop && (group || startingChartActions.contains(correct.id)))) {
        continue;
      }
      checked++;
      final expected = chart.expected(
        runner.table,
        groupOnly: group,
        narrowThreeBet: runner.lessonId == 'w2_narrow_three_bet',
      );
      expect(
        startingChartActual(correct, expected),
        expected,
        reason: task.taskId,
      );
    }
    expect(checked, greaterThan(30), reason: 'Chart assessment coverage');
  });
}
