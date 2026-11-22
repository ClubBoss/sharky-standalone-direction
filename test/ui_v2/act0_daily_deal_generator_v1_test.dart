import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_daily_practice_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_preflop_equity_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_starting_chart_v1.dart';
import 'package:poker_solver/poker_solver.dart';

import '../../tools/act0_daily_deal_export_v1.dart'
    show renderDailyDealExportSectionV1;
import '../../tools/act0_preflop_equity_v1.dart';
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
        final correctActions = <String, int>{};
        final scenes = <String>{};
        final flopEquities = <String, double>{};
        final flopAnswers = <double, Set<String>>{};
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
          final netContributions = table.handContributions!.entries
              .fold<double>(
                0,
                (sum, entry) =>
                    entry.kind == Act0ContributionKindV1.uncalledReturn
                    ? sum - entry.amountBb
                    : sum + entry.amountBb,
              );
          expect(
            double.parse(table.potLabel.split(' ')[1]),
            netContributions,
            reason: '$id pot must equal net contributions',
          );
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
          final correct = template == Act0DailyDealTemplateV1.lowSpr
              ? _verifiedLowSprAnswer(task, flopEquities, flopAnswers)
              : _expected(template, task);
          expect(answer.label, correct, reason: id);
          correctActions.update(
            correct,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
          scenes.add(catalogTableLine(table));
        }
        if (template == Act0DailyDealTemplateV1.open) {
          expect(scenes.length, greaterThan(500));
          expect(correctActions.values, everyElement(lessThanOrEqualTo(700)));
        } else {
          expect(scenes.length, greaterThan(900));
        }
        if (template == Act0DailyDealTemplateV1.lowSpr) {
          expect(flopEquities, hasLength(5));
          expect(flopAnswers[1059 / 2970], {'Call', 'Fold'});
        }
        expect(correctActions.length, greaterThan(1), reason: template.name);
      },
    );
  }

  test(
    '20 defend-BB classes match direct legal pocket and board enumeration',
    () async {
      const sampled = [
        'AA',
        'JJ',
        '22',
        'AKs',
        'AKo',
        'AQs',
        'A9o',
        'A2s',
        'KQs',
        'K2o',
        'QJs',
        'Q9o',
        'JTs',
        'J9s',
        'T9o',
        '98s',
        '76o',
        '54s',
        '83o',
        '32s',
      ];
      final computed = <String, Map<String, ({int halfShares, int deals})>>{};
      for (final opener in [Act0ChartSeatV1.co, Act0ChartSeatV1.btn]) {
        final range = act0ChartHandsV1
            .where(
              (hand) =>
                  act0ChartActionV1(hand, opener, Act0ChartPrefixV1.unopened) ==
                  Act0ChartActionV1.raise,
            )
            .toSet();
        final signature = range.join(',');
        final direct = computed[signature] ??= await enumeratePreflopEquityV1(
          range,
          directHands: sampled,
        );
        expect(direct.keys, unorderedEquals(sampled));
        for (final code in sampled) {
          final count = direct[code]!;
          final expected = (500 * count.halfShares / count.deals).round();
          expect(
            act0PreflopEquityTenthsV1(code, opener),
            expected,
            reason: '${opener.name} $code',
          );
          expect(count.deals, _matchups(code, range) * 1712304);
        }
        expect(
          act0ChartHandsV1.every(
            (code) => act0PreflopEquityTenthsV1(code, opener) != null,
          ),
          isTrue,
        );
      }
      expect(act0PreflopEquityTenthsV1('AA', Act0ChartSeatV1.sb), isNull);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'the same defend-BB price allows opposite answers for different hands',
    () {
      final byPrice = <(String, String), Set<String>>{};
      for (var seed = 0; seed < 100; seed++) {
        final task = act0GenerateDailyDealV1(
          taskId: 'defend_price_probe_$seed',
          lessonId: 'defend',
          template: Act0DailyDealTemplateV1.defendBb,
          seed: seed,
        )!;
        final table = task.runner.table;
        final opener = table.seats
            .singleWhere((seat) => seat.bet?.kind == Act0SeatBetKindV1.raise)
            .seatId;
        final answer = task.runner.options.singleWhere(
          (option) => option.isCorrect,
        );
        byPrice
            .putIfAbsent((opener, table.toCallLabel), () => {})
            .add(answer.label);
      }
      expect(
        byPrice.values.where((answers) => answers.length == 2),
        isNotEmpty,
      );
    },
  );

  test('low-SPR export cannot substitute the pot after a call', () {
    final lines = renderDailyDealExportSectionV1(
      Act0DailyDealTemplateV1.lowSpr,
    ).toList();
    final index = lines.indexWhere(
      (line) => line.startsWith('TASK generated_lowSpr_0 '),
    );
    expect(index, greaterThanOrEqualTo(0));
    final taskLines = lines.skip(index).takeWhile((line) => line.isNotEmpty);
    final table = taskLines.singleWhere((line) => line.startsWith('TABLE:'));
    final money = RegExp(
      r'Pot ([\d.]+) BB \| To call ([\d.]+) BB',
    ).firstMatch(table)!;
    final currentPot = money[1]!;
    final projectedPot = double.parse(currentPot) + double.parse(money[2]!);
    final potLine = taskLines.singleWhere((line) => line.startsWith('POTS:'));
    expect(potLine, 'POTS: current $currentPot');
    expect(potLine, isNot(contains('main $projectedPot')));
  });

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

String _expected(Act0DailyDealTemplateV1 template, Act0LessonTaskV1 task) {
  final table = task.runner.table;
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
    final opener = table.seats
        .singleWhere((seat) => seat.bet?.kind == Act0SeatBetKindV1.raise)
        .seatId;
    final code = CatalogPokerFacts(table).code!;
    final equity =
        act0PreflopEquityTenthsV1(
          code,
          Act0ChartSeatV1.values.byName(opener),
        )! /
        1000;
    expect((equity - price).abs(), inInclusiveRange(0.002, 0.05));
    expect(
      task.runner.caption,
      contains(
        "Your $code has ${(100 * equity).toStringAsFixed(1)}% equity against ${opener.toUpperCase()}'s chart opening range.",
      ),
    );
    return equity > price ? 'Call' : 'Fold';
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

String _verifiedLowSprAnswer(
  Act0LessonTaskV1 task,
  Map<String, double> equities,
  Map<double, Set<String>> answers,
) {
  final runner = task.runner;
  final table = runner.table;
  final ledger = table.handContributions!;
  expect(ledger.throughStreet, PokerStreet.flop);
  final flop = physicalCards(table.boardCards);
  final hero = physicalCards(table.heroCards);
  expect(flop, hasLength(3));
  final overpair = hero[0][0] == hero[1][0];
  int rank(String card) => '23456789TJQKA'.indexOf(card[0]);
  final highest = flop.map(rank).reduce((a, b) => a > b ? a : b);
  expect(
    overpair ? rank(hero.first) > highest : hero.any((c) => rank(c) == highest),
    isTrue,
  );

  final bb = table.seats.singleWhere((seat) => seat.seatId == 'bb');
  expect(bb.cardsVisibleMode, Act0CardsVisibleModeV1.faceDown);
  expect(bb.bet?.kind, Act0SeatBetKindV1.allIn);
  final preflop = ledger.entries.where(
    (entry) => entry.street == PokerStreet.preflop,
  );
  final openingPot = preflop.fold(0.0, (sum, entry) => sum + entry.amountBb);
  double atFlop(String seatId) =>
      ledger.startingStackBbBySeat[seatId]! -
      preflop
          .where((entry) => entry.seatId == seatId)
          .fold(0.0, (sum, entry) => sum + entry.amountBb);
  final depth = [
    atFlop('bb'),
    atFlop(table.heroSeatId!),
  ].reduce((a, b) => a < b ? a : b);
  final spr = depth / openingPot;
  final due = double.parse(table.toCallLabel.split(' ')[2]);
  expect(due, depth);
  expect(spr, inInclusiveRange(1, 2));
  expect(runner.caption, contains('SPR ${spr.toStringAsFixed(2)}'));
  final price = due / (openingPot + 2 * due);

  final cards = RegExp(
    r'\b[23456789TJQKA][shdc]\b',
  ).allMatches(runner.caption).map((m) => m[0]!).toList();
  expect(cards, hasLength(6));
  final range = [
    for (var i = 0; i < cards.length; i += 2) cards.sublist(i, i + 2),
  ];
  final known = {...hero, ...flop};
  for (final holding in range) {
    expect({...known, ...holding}, hasLength(7));
  }
  final suits = <String, int>{};
  final key = [...hero, ...flop, ...cards]
      .map(
        (card) =>
            card[0] + suits.putIfAbsent(card[1], () => suits.length).toString(),
      )
      .join(' ');
  final equity = equities.putIfAbsent(key, () {
    final deck = [
      for (final rank in '23456789TJQKA'.split(''))
        for (final suit in 'cdhs'.split('')) '$rank$suit',
    ];
    var totalShare = 0.0;
    for (final holding in range) {
      final remaining = deck
          .where((card) => !known.contains(card) && !holding.contains(card))
          .toList();
      expect(remaining, hasLength(45));
      for (final (i, first) in remaining.indexed) {
        for (final second in remaining.take(i)) {
          final board = [...flop, first, second];
          final player = Hand.solveHand([...hero, ...board]);
          final opponent = Hand.solveHand([...holding, ...board]);
          final winners = Hand.winners([player, opponent]);
          if (winners.contains(player)) totalShare += 1 / winners.length;
        }
      }
    }
    return totalShare / (range.length * 990);
  });
  expect(
    runner.caption,
    contains(
      'Your equity against that range is ${(100 * equity).toStringAsFixed(2)}%.',
    ),
  );
  final feedback = runner.options
      .singleWhere((option) => option.isCorrect)
      .feedbackReason;
  expect(feedback, contains('${(100 * equity).toStringAsFixed(2)}% equity'));
  expect(feedback, contains('${(100 * price).toStringAsFixed(2)}% call price'));
  final answer = equity > price ? 'Call' : 'Fold';
  answers.putIfAbsent(equity, () => {}).add(answer);
  return answer;
}

int _matchups(String code, Set<String> range) {
  final deck = [
    for (final rank in '23456789TJQKA'.split(''))
      for (final suit in 'cdhs'.split('')) '$rank$suit',
  ];
  final pocket = [code[0] + 's', code[1] + (code.endsWith('s') ? 's' : 'h')];
  final remaining = deck.where((card) => !pocket.contains(card)).toList();
  var combinations = 0;
  for (final (index, a) in remaining.indexed) {
    for (final b in remaining.take(index)) {
      if (range.contains(startingHandCode([a, b]))) combinations++;
    }
  }
  return combinations *
      (code.length == 2
          ? 6
          : code.endsWith('s')
          ? 4
          : 12);
}
