import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

import '../support/act0_catalog_poker_facts_v1.dart'
    show physicalCards, pokerRanks;

List<String> _namedCards(String question) => [
  for (final match in RegExp(r'([2-9TJQKA])([♣♦♥♠])').allMatches(question))
    match[1]! + const {'♣': 'c', '♦': 'd', '♥': 'h', '♠': 's'}[match[2]]!,
];

double _share(List<String> hero, List<String> opponent, List<String> board) {
  final heroHand = Hand.solveHand([...hero, ...board]);
  final otherHand = Hand.solveHand([...opponent, ...board]);
  final winners = Hand.winners([heroHand, otherHand]);
  return winners.contains(heroHand) ? 1 / winners.length : 0;
}

double _requiredShare(Act0TableStateV1 table) {
  final actor = table.decisionSeatId;
  final amounts = table.handContributions!.amounts(
    seatIds: table.seats.map((seat) => seat.seatId).toSet(),
    actorSeatId: actor,
  );
  final price = amounts.toCallBb!;
  return price / (amounts.potBb + price);
}

String _correct(Act0RunnerStateV1 runner) =>
    runner.options.singleWhere((option) => option.isCorrect).label;

void main() {
  test('W7 keeps its original lesson and adds applied decisions', () {
    final world = Act0ShellStateV1.sample.worldById('world_7');
    expect(world.lessons.map((lesson) => lesson.lessonId), [
      'range_thinking_lite_combo_density',
      'w7_visible_cards_and_price',
      'w7_visible_cards_range_checkpoint',
    ]);
    expect(
      world.lessons.first.taskList.map((task) => task.taskId),
      contains('visible_card_combo_reduction_recap'),
    );
  });

  test('the flop contrasts one and two opponents from the cutoff', () {
    final tasks = Act0ShellStateV1.sample
        .lessonById('w7_visible_cards_and_price')
        .taskList;
    final headsUp = tasks[0].runner;
    final multiway = tasks[1].runner;
    expect(headsUp.table.heroSeatId, 'co');
    expect(multiway.table.heroSeatId, 'co');
    expect(headsUp.table.seats.where((s) => s.isInHand), hasLength(2));
    expect(multiway.table.seats.where((s) => s.isInHand), hasLength(3));
    expect(headsUp.table.potLabel, 'Pot 6.5 BB');
    expect(multiway.table.potLabel, 'Pot 9 BB');
    expect(headsUp.options.singleWhere((o) => o.isCorrect).label, 'Bet 3 BB');
    expect(multiway.options.singleWhere((o) => o.isCorrect).label, 'Check');
  });

  test('the turn answer changes with price, not with cards', () {
    final state = Act0ShellStateV1.sample;
    final tasks = state.lessonById('w7_visible_cards_and_price').taskList;
    final cheaper = tasks[3].runner;
    final dearer = tasks[4].runner;
    expect(
      cheaper.table.heroCards.map((c) => '${c.rank}${c.suit}'),
      dearer.table.heroCards.map((c) => '${c.rank}${c.suit}'),
    );
    expect(
      cheaper.table.boardCards.map((c) => '${c.rank}${c.suit}'),
      dearer.table.boardCards.map((c) => '${c.rank}${c.suit}'),
    );
    expect(cheaper.table.potLabel, 'Pot 11 BB');
    expect(dearer.table.potLabel, 'Pot 14 BB');
    expect(cheaper.table.toCallLabel, 'To call 3 BB');
    expect(dearer.table.toCallLabel, 'To call 6 BB');
    expect(cheaper.options.singleWhere((o) => o.isCorrect).label, 'Call');
    expect(dearer.options.singleWhere((o) => o.isCorrect).label, 'Fold');
  });

  test('the river answer changes with range at the same price', () {
    final tasks = Act0ShellStateV1.sample
        .lessonById('w7_visible_cards_range_checkpoint')
        .taskList;
    final narrow = tasks[0].runner;
    final wide = tasks[1].runner;
    expect(
      narrow.table.heroCards.map((c) => '${c.rank}${c.suit}'),
      wide.table.heroCards.map((c) => '${c.rank}${c.suit}'),
    );
    expect(
      narrow.table.boardCards.map((c) => '${c.rank}${c.suit}'),
      wide.table.boardCards.map((c) => '${c.rank}${c.suit}'),
    );
    expect(narrow.table.potLabel, 'Pot 12 BB');
    expect(wide.table.potLabel, narrow.table.potLabel);
    expect(narrow.table.toCallLabel, 'To call 4 BB');
    expect(wide.table.toCallLabel, narrow.table.toCallLabel);
    expect(narrow.options.singleWhere((o) => o.isCorrect).label, 'Fold');
    expect(wide.options.singleWhere((o) => o.isCorrect).label, 'Call');
  });

  test('the last W7 task uses the new river card without a hint', () {
    final task = Act0ShellStateV1.sample
        .lessonById('w7_visible_cards_range_checkpoint')
        .taskList
        .last;
    expect(task.taskId, 'w7_checkpoint_river_card_excludes_hand');
    expect(task.runner.hint, isEmpty);
    expect(task.runner.table.boardCards.last.rank, '2');
    expect(task.runner.table.boardCards.last.suit, 's');
    expect(task.runner.table.potLabel, 'Pot 13 BB');
    expect(task.runner.table.toCallLabel, 'To call 5 BB');
    expect(task.runner.options.singleWhere((o) => o.isCorrect).label, 'Fold');
  });

  test('all 44 turn runouts give exactly twelve wins and no splits', () {
    final tasks = Act0ShellStateV1.sample
        .lessonById('w7_visible_cards_and_price')
        .taskList;
    for (final task in tasks.skip(2)) {
      final runner = task.runner;
      final table = runner.table;
      final hero = physicalCards(table.heroCards);
      final board = physicalCards(table.boardCards);
      final opponent = _namedCards(runner.question);
      expect(opponent, ['Kc', 'Qs']);
      final known = {...hero, ...board, ...opponent};
      expect(known, hasLength(8));
      final runouts = [
        for (final rank in pokerRanks.split(''))
          for (final suit in 'cdhs'.split(''))
            if (!known.contains('$rank$suit'))
              _share(hero, opponent, [...board, '$rank$suit']),
      ];
      expect(runouts, hasLength(44));
      expect(runouts.where((result) => result == 1), hasLength(12));
      expect(runouts, isNot(contains(0.5)));
      final answer = switch (task.taskId) {
        'w7_count_winning_rivers' => '12',
        _ => 12 / runouts.length > _requiredShare(table) ? 'Call' : 'Fold',
      };
      expect(_correct(runner), answer);
    }
  });

  test('W7 Day 7 compares clean hearts with the actual turn price', () {
    final review = act0NewReviewTasksV1
        .singleWhere(
          (entry) =>
              entry.worldId == 'world_7' &&
              entry.lessonId == 'w7_visible_cards_and_price' &&
              entry.conceptFamilyId == 'pot_to_call',
        )
        .task
        .runner;
    final table = review.table;
    final hero = physicalCards(table.heroCards);
    final board = physicalCards(table.boardCards);
    final visible = {...hero, ...board};
    final available = [
      for (final rank in pokerRanks.split(''))
        for (final suit in 'cdhs'.split(''))
          if (!visible.contains('$rank$suit')) '$rank$suit',
    ];
    for (final king in available.where((c) => c[0] == 'K' && c[1] != 'h')) {
      for (final queen in available.where((c) => c[0] == 'Q' && c[1] != 'h')) {
        final shares = [
          for (final river in available)
            if (river != king && river != queen)
              _share(hero, [king, queen], [...board, river]),
        ];
        expect(shares, hasLength(44));
        expect(shares.where((result) => result == 1), hasLength(8));
        expect(shares, isNot(contains(0.5)));
      }
    }
    expect(_requiredShare(table), 0.2);
    expect(8 / 44, lessThan(_requiredShare(table)));
    expect(_correct(review), 'Fold');
  });

  test('W7 Day 7 calls when one of the three stated river hands loses', () {
    final review = act0NewReviewTasksV1
        .singleWhere(
          (entry) =>
              entry.worldId == 'world_7' &&
              entry.lessonId == 'w7_visible_cards_range_checkpoint',
        )
        .task
        .runner;
    final table = review.table;
    final hero = physicalCards(table.heroCards);
    final board = physicalCards(table.boardCards);
    final outcomes = [
      for (final opponent in [
        ['Kd', 'Qs'],
        ['As', 'Qs'],
        ['Td', '9d'],
      ])
        _share(hero, opponent, board),
    ];
    expect(outcomes, [0, 0, 1]);
    expect(_requiredShare(table), 4 / 14);
    expect(1 / 3, greaterThan(_requiredShare(table)));
    expect(_correct(review), 'Call');
  });

  test('river grading uses only compatible combinations and exact price', () {
    final tasks = Act0ShellStateV1.sample
        .lessonById('w7_visible_cards_range_checkpoint')
        .taskList;
    for (final (index, task) in tasks.indexed) {
      final runner = task.runner;
      final table = runner.table;
      final hero = physicalCards(table.heroCards);
      final board = physicalCards(table.boardCards);
      final known = {...hero, ...board};
      final cards = _namedCards(runner.question);
      final compatible = <List<String>>[];
      final blocked = <List<String>>[];
      expect(cards.length.isEven, isTrue);
      expect(known, hasLength(7));
      for (var i = 0; i < cards.length; i += 2) {
        final hand = cards.sublist(i, i + 2);
        expect(hand.toSet(), hasLength(2));
        (hand.any(known.contains) ? blocked : compatible).add(hand);
      }
      expect(
        blocked,
        index == 2
            ? [
                ['2s', '2d'],
              ]
            : isEmpty,
      );
      expect(compatible, hasLength(index == 2 ? 4 : 6));
      final canonicalHands = compatible.map(
        (hand) => (hand.toList()..sort()).join(),
      );
      expect(canonicalHands.toSet(), hasLength(compatible.length));
      final results = compatible.map((hand) => _share(hero, hand, board));
      final wins = results.where((result) => result == 1).length;
      expect(wins, [1, 2, 1][index]);
      expect(results, isNot(contains(0.5)));
      expect(
        _correct(runner),
        wins / compatible.length > _requiredShare(table) ? 'Call' : 'Fold',
      );
    }
  });
}
