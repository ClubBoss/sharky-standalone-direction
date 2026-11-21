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
      'T means ten. In KTs, s means same suit. In J8o, o means different suits.\n\n'
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
      final expected = chart.expected(runner.table, groupOnly: group);
      expect(
        startingChartActual(correct, expected),
        expected,
        reason: task.taskId,
      );
    }
    expect(checked, greaterThan(30), reason: 'Chart assessment coverage');
  });
}
