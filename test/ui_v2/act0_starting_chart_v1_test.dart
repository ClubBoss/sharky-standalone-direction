import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_starting_chart_v1.dart';

final _tasks = [
  for (final world in Act0ShellStateV1.sample.worlds)
    if (world.worldNumber == 2 || world.worldNumber == 3)
      for (final lesson in world.lessons) ...lesson.taskList,
];

void main() {
  final chart = CatalogStartingChart.foundation();

  test('typed starting rules render the exact two learner chart pages', () {
    final steps = _tasks
        .singleWhere((t) => t.taskId == 'hand_discipline_buckets_intro')
        .runner
        .teachingSteps;
    expect(steps, hasLength(2));
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

  test('W2–W3 chart decisions match the teaching rows and the table', () {
    var checked = 0;
    for (final task in _tasks) {
      final runner = task.runner;
      if (runner.options.isEmpty) continue;
      final correct = runner.options.singleWhere(
        act0RunnerOptionIsAuthoredCorrectV1,
      );
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
