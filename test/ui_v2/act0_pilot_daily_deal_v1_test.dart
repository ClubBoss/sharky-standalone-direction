import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_timeline_v1.dart';

import '../support/act0_catalog_snapshot_v1.dart';

const _priceSources = {
  'w14_6_read_induced_raise_price': 27.9,
  'w18_5_transfer_overcall_price': 20.0,
};

void main() {
  test('W1–W12 snapshot bytes agree with the release fixture', () {
    expect(
      utf8.encode(renderCatalogSnapshot(excludePilot: true)),
      File('test/fixtures/act0_catalog_snapshot_v1.txt').readAsBytesSync(),
    );
  });

  test(
    'pilot recipes and direct generation are unavailable with flag off',
    () {
      const source = 'w18_5_transfer_overcall_price';
      const id = 'daily_deal_v1:20781:callPrice:reopen_and_limp:$source';
      expect(act0DailyDealTemplateForSourceV1(source), isNull);
      expect(act0DailyDealRecipeV1(id), isNull);
      expect(
        act0GenerateDailyDealV1(
          taskId: id,
          lessonId: 'reopen_and_limp',
          template: Act0DailyDealTemplateV1.callPrice,
          seed: 42,
          sourceTaskId: source,
        ),
        isNull,
      );
    },
    skip: act0CurriculumPilotEnabledV1,
  );

  test(
    'completed-drill recipes vary and keep source grade and legal table',
    () {
      final counts = <int, int>{};
      for (final row in catalogTasks.where(
        (row) => row.world.worldNumber > 12,
      )) {
        final source = row.task;
        final template = act0DailyDealTemplateForSourceV1(source.taskId);
        if (template == null) continue;
        expect(source.entryPhase, Act0LessonPhaseV1.drill);
        counts.update(
          row.world.worldNumber,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        final sourceGrade = source.runner.options
            .singleWhere(
              (option) => option.quality == Act0FeedbackQualityV1.correct,
            )
            .label
            .split(' ')
            .first;
        final boards = <String>{};
        final prices = <String>{};
        for (var day = 20780; day < 20800; day++) {
          final recipe = (
            day: day,
            template: template,
            lessonId: row.lesson.lessonId,
            sourceTaskId: source.taskId,
          );
          final id = act0DailyDealIdV1(recipe);
          expect(act0DailyDealRecipeV1(id), recipe);
          final task = act0GenerateDailyDealV1(
            taskId: id,
            lessonId: recipe.lessonId,
            template: template,
            seed: day * 31 + template.index,
            sourceTaskId: source.taskId,
          );
          expect(task, isNotNull, reason: id);
          expect(task!.rewardXp, 0);
          final table = task.runner.table;
          final prefix = table.handTimelinePrefix!;
          expect(prefix.decisionError(table.heroSeatId!), isNull);
          expect(act0PilotDailyDealTableIsValidV1(table), isTrue);
          expect(prefix.board, table.boardCards.map((card) => card.label));
          expect(
            table.actionTrail,
            hasLength(prefix.events.whereType<Act0HandActionV1>().length),
          );
          boards.add(prefix.board.join(' '));
          final sourceAmount = _priceSources[source.taskId];
          final best = task.runner.options.singleWhere(
            (option) => option.isCorrect,
          );
          if (sourceAmount != null) {
            expect(double.parse(sourceGrade.replaceAll('%', '')), sourceAmount);
            final amounts = prefix.contributions.amounts(
              seatIds: prefix.startingStacks.keys.toSet(),
              actorSeatId: table.heroSeatId,
            );
            final call = amounts.toCallBb!;
            expect(
              best.label,
              '${(100 * call / (amounts.potBb + call)).toStringAsFixed(1)}%',
            );
            prices.add(best.label);
          } else {
            expect(best.label.split(' ').first, sourceGrade, reason: id);
          }
        }
        expect(boards.length, greaterThan(1), reason: source.taskId);
        if (_priceSources.containsKey(source.taskId))
          expect(prices.length, greaterThan(1));
      }
      expect(counts, {13: 7, 14: 9, 15: 6, 16: 3, 17: 2, 18: 1});
    },
    skip: !act0CurriculumPilotEnabledV1,
  );

  test(
    'pilot truth gate rejects an illegal stack, wrong price, future card and out-of-order action',
    () {
      final table = act0GenerateDailyDealV1(
        taskId: 'generated',
        lessonId: 'equity_vs_range',
        template: Act0DailyDealTemplateV1.cleanOuts,
        seed: 42,
        sourceTaskId: 'w13_3_guided_flush_draw_turn',
      )!.runner.table;
      expect(act0PilotDailyDealTableIsValidV1(table), isTrue);
      final ledger = table.handContributions!;
      final illegalStack = Act0HandContributionsV1(
        throughStreet: ledger.throughStreet,
        entries: ledger.entries,
        startingStackBbBySeat: {...ledger.startingStackBbBySeat, 'bb': 1},
      );
      expect(
        act0PilotDailyDealTableIsValidV1(
          table.copyWith(handContributions: illegalStack),
        ),
        isFalse,
      );
      final prefix = table.handTimelinePrefix!;
      final actions = [
        for (final action in prefix.events.whereType<Act0HandActionV1>())
          (
            street: action.street,
            seat: action.seat,
            verb: action.verb,
            chipsAdded: action.chipsAdded,
          ),
      ];
      final utgFold = actions[2];
      actions[2] = actions[3];
      actions[3] = utgFold;
      final illegalOrder = Act0HandTimelineV1.fromDeltas(
        coverage: prefix.coverage,
        startingStacks: prefix.startingStacks,
        button: prefix.button,
        smallBlind: prefix.smallBlind,
        bigBlind: prefix.bigBlind,
        board: prefix.board,
        actions: actions,
      ).beforeDecision;
      expect(illegalOrder.decisionError(table.heroSeatId!), isNotNull);
      expect(
        act0PilotDailyDealTableIsValidV1(
          table.copyWith(handTimelinePrefix: illegalOrder),
        ),
        isFalse,
      );
      expect(
        act0PilotDailyDealTableIsValidV1(
          table.copyWith(toCallLabel: 'To call 999 BB'),
        ),
        isFalse,
      );
      expect(
        act0PilotDailyDealTableIsValidV1(
          table.copyWith(
            handTimelinePrefix: table.handTimelinePrefix,
            boardCards: [
              ...table.boardCards,
              const Act0CardStateV1(rank: '2', suit: 's'),
            ],
          ),
        ),
        isFalse,
      );
    },
    skip: !act0CurriculumPilotEnabledV1,
  );
}
