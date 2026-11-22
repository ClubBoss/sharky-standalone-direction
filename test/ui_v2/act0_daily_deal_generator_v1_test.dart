import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_daily_practice_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_starting_chart_v1.dart';
import 'package:poker_solver/poker_solver.dart';

import '../support/act0_catalog_decision_copy_v1.dart';
import '../support/act0_catalog_poker_facts_v1.dart';
import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_catalog_truth_audit_v1.dart';
import '../support/act0_table_truth_v1.dart';

void main() {
  final anchors = {
    for (final row in catalogTasks)
      if (!row.task.repairOnly &&
          row.task.entryPhase == Act0LessonPhaseV1.drill)
        row.task.taskId: row,
  };

  test('every template is linked to an actual course drill', () {
    expect(anchors.keys, containsAll(act0DailyDealSourceTasksV1.keys));
    expect(
      act0DailyDealSourceTasksV1.values.toSet(),
      Act0DailyDealTemplateV1.values.toSet(),
    );
  });

  for (final template in Act0DailyDealTemplateV1.values) {
    test(
      '1000 ${template.name} deals satisfy G1, Table Truth and independent score',
      () {
        final anchor =
            anchors[act0DailyDealSourceTasksV1.entries
                .firstWhere((item) => item.value == template)
                .key]!;
        final correctActions = <String>{};
        final scenes = <String>{};
        for (var seed = 0; seed < 1000; seed++) {
          final id = 'generated_${template.name}_$seed';
          final task = act0GenerateDailyDealV1(
            taskId: id,
            lessonId: anchor.lesson.lessonId,
            template: template,
            seed: seed,
          );
          expect(task, isNotNull, reason: id);
          final table = task!.runner.table;
          final row = (
            world: anchor.world,
            lesson: anchor.lesson,
            task: task,
            lessonIndex: anchor.lessonIndex,
          );
          final truth = runCatalogAudit(rows: [row]);
          // The authored-catalog recovery rule expects every miss to have
          // an authored repair. A generated zero-XP drill is practice only.
          expect(
            truth.findings.keys.where(
              (key) => !key.startsWith('10.repair_resolves|'),
            ),
            isEmpty,
            reason: '$id ${truth.findings}',
          );
          expect(auditDecisionCopyV1(row), isEmpty, reason: id);
          expect(actorFlagsConsistent(table), isTrue, reason: id);
          final d = auditTableContributionsV1(id, 'generated', table);
          expect(
            d.where((result) => result.result != 'PASS'),
            isEmpty,
            reason: id,
          );
          final answer = task.runner.options.singleWhere(
            (option) => option.isCorrect,
          );
          expect(task.runner.options, hasLength(2));
          expect(
            answer.feedbackReason.trim().split(RegExp(r'\s+')).length,
            lessThanOrEqualTo(40),
            reason: id,
          );
          final correct = _expected(template, table);
          expect(answer.label, correct, reason: id);
          correctActions.add(correct);
          scenes.add(catalogTableLine(table));
        }
        expect(scenes.length, greaterThan(900));
        expect(correctActions.length, greaterThan(1), reason: template.name);
      },
    );
  }

  test('daily recipe and finite selection survive a queue round trip', () {
    final recipes = [
      for (final template in Act0DailyDealTemplateV1.values.take(3))
        (
          day: 20779,
          template: template,
          lessonId:
              anchors[act0DailyDealSourceTasksV1.entries
                      .firstWhere((entry) => entry.value == template)
                      .key]!
                  .lesson
                  .lessonId,
          sourceTaskId: act0DailyDealSourceTasksV1.entries
              .firstWhere((entry) => entry.value == template)
              .key,
        ),
    ];
    for (final recipe in recipes) {
      final id = act0DailyDealIdV1(recipe);
      expect(act0DailyDealRecipeV1(id), recipe);
      Act0LessonTaskV1 generate(int day) => act0GenerateDailyDealV1(
        taskId: id,
        lessonId: recipe.lessonId,
        template: recipe.template,
        seed: day * 31 + recipe.template.index,
      )!;
      final a = generate(recipe.day).runner;
      final b = generate(recipe.day).runner;
      expect(catalogTableLine(a.table), catalogTableLine(b.table));
      expect(
        a.options.map((answer) => (answer.id, answer.feedbackReason)),
        b.options.map((answer) => (answer.id, answer.feedbackReason)),
      );
      expect(
        catalogTableLine(a.table),
        isNot(catalogTableLine(generate(recipe.day + 1).runner.table)),
      );
    }
    final ids = recipes.map(act0DailyDealIdV1).toList();
    final queue = Act0DailyPracticeQueueV1.start(
      ids,
    ).answer(ids.first, independentCorrect: true);
    final restored = Act0DailyPracticeQueueV1.tryParse(
      jsonDecode(jsonEncode(queue.toPayload())),
    )!;
    expect(restored.taskIds, ids);
    expect(restored.nextTaskId, ids[1]);
    expect(restored.cleanTaskIds, {ids.first});
    expect(
      act0DailyDealRecipeV1('daily_deal_v1:1:open:fake:unlearned'),
      isNull,
    );
  });
}

String _expected(Act0DailyDealTemplateV1 template, Act0TableStateV1 table) {
  if (template == Act0DailyDealTemplateV1.open) {
    final chart = act0ChartActionV1(
      CatalogPokerFacts(table).code!,
      Act0ChartSeatV1.values.byName(table.heroSeatId!),
      Act0ChartPrefixV1.unopened,
    );
    return chart == Act0ChartActionV1.raise ? 'Raise' : 'Fold';
  }
  final pot = double.parse(table.potLabel.split(' ')[1]);
  final due = double.parse(table.toCallLabel.split(' ')[2]);
  final price = due / (pot + due);
  if (template == Act0DailyDealTemplateV1.callPrice) {
    return '${(price * 100).toStringAsFixed(1)}%';
  }
  if (template == Act0DailyDealTemplateV1.defendBb) {
    return price < 0.30 ? 'Call' : 'Fold';
  }
  final hero = physicalCards(table.heroCards);
  final board = physicalCards(table.boardCards);
  final villain = physicalCards(
    table.seats.singleWhere((seat) => !seat.isHero && !seat.isFolded).holeCards,
  );
  final seen = {...hero, ...board, ...villain};
  final possible = [
    for (final rank in '23456789TJQKA'.split(''))
      for (final suit in 'cdhs'.split(''))
        if (!seen.contains('$rank$suit')) '$rank$suit',
  ];
  final wins = possible.where((river) {
    final player = Hand.solveHand([...hero, ...board, river]);
    final bettor = Hand.solveHand([...villain, ...board, river]);
    return Hand.winners([player, bettor]).singleOrNull == player;
  });
  return wins.length / possible.length > price ? 'Call' : 'Fold';
}
