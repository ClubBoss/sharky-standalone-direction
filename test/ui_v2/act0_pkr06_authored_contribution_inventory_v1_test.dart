// PKR06 SB + A: source-only evidence, not whole-catalog cap closure.
// A is NEW_CONTENT (2026-11-08), not recovery of an earlier hand history.
// Only the three active tasks below are repaired. The complete active-seat
// inventory deliberately keeps missing blind stacks and unproved cases.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_pot_showdown_truth_v1.dart';

const _allInIds = <String>[
  'what_poker_is_all_in_meaning',
  'what_poker_is_matched_chips_transfer',
];
const _sidePotId = 'what_poker_is_side_pot_intro';

// Named card-ranking tasks, not a blanket world/seat exemption. Even these
// tasks remain cap obligations whenever their actual scene carries a wager.
const _rankingTasks = <String>{
  'hand_rankings_theory',
  'hand_rankings_pair_drill',
  'hand_rankings_two_pair_drill',
  'hand_rankings_trips_drill',
  'hand_rankings_straight_drill',
  'hand_rankings_flush_drill',
  'hand_rankings_full_house_drill',
  'hand_rankings_quads_drill',
  'hand_rankings_royal_flush_drill',
  'hand_rankings_full_house_vs_flush_drill',
  'hand_rankings_quads_vs_full_house_drill',
  'hand_rankings_royal_vs_flush_drill',
  'hand_rankings_best_five_drill',
  'hand_rankings_review',
};

Iterable<Act0LessonTaskV1> _tasks() =>
    Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList);

Act0LessonTaskV1 _task(String id) =>
    _tasks().singleWhere((task) => task.taskId == id);

Map<String, Act0SeatStateV1> _seats(Act0TableStateV1 table) => {
  for (final seat in table.seats) seat.seatId: seat,
};

List<PotTruthActionV1> _actions(Act0TableStateV1 table) => [
  for (final item in table.actionTrail)
    if (potTruthParseActionV1(table, item.label) case final action?) action,
];

Map<String, double> _contributions(Act0TableStateV1 table) => {
  for (final seat in table.seats)
    seat.seatId: potTruthBbV1(seat.currentBetLabel) ?? 0,
};

bool _live(Act0SeatStateV1 seat) => seat.isInHand && !seat.isFolded;

void _expectFold(Act0TableStateV1 table, String seatId) {
  final seat = _seats(table)[seatId]!;
  expect(seat.isInHand, isFalse, reason: seatId);
  expect(seat.isFolded, isTrue, reason: seatId);
  expect(seat.hasActed, isTrue, reason: seatId);
  expect(seat.cardsVisibleMode, Act0CardsVisibleModeV1.none, reason: seatId);
  expect(
    _actions(table).any(
      (action) =>
          action.actor == seat.seatLabel.toUpperCase() &&
          action.verb == 'fold',
    ),
    isTrue,
    reason: '$seatId must have explicit fold provenance',
  );
}

class _Scene {
  const _Scene(this.worldId, this.lessonId, this.task, this.variant, this.table);
  final String worldId;
  final String lessonId;
  final Act0LessonTaskV1 task;
  final String variant;
  final Act0TableStateV1 table;
  String get key => '${task.taskId}|$variant';
}

// Runtime catalog, never a hand-maintained list of compatibility IDs.
// Null teaching tables inherit the primary and do not add a distinct input.
Iterable<_Scene> _scenes() sync* {
  for (final world in Act0ShellStateV1.sample.worlds) {
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        yield _Scene(world.worldId, lesson.lessonId, task, 'primary',
            task.runner.table);
        for (var i = 0; i < task.runner.teachingSteps.length; i++) {
          final table = task.runner.teachingSteps[i].table;
          if (table != null) {
            yield _Scene(world.worldId, lesson.lessonId, task, 'teaching:$i',
                table);
          }
        }
      }
    }
  }
}

bool _hasChipFact(Act0TableStateV1 table, Act0SeatStateV1 seat) =>
    <String?>[
      seat.currentBetLabel,
      seat.bet?.amountLabel,
      seat.blindAmountLabel,
    ].any((label) => label != null && label.trim().isNotEmpty) ||
    _actions(table).any(
      (action) =>
          action.actor == seat.seatLabel.trim().toUpperCase() &&
          potTruthContributionVerbsV1.contains(action.chipVerb),
    );

Map<String, Object?> _inventoryRow(_Scene scene, Act0SeatStateV1 seat) {
  final table = scene.table;
  final actor = seat.seatLabel.trim().toUpperCase();
  final actions = _actions(table)
      .where((action) => action.actor == actor)
      .toList();
  final stack = potTruthBbV1(seat.stackLabel);
  final committed = potTruthBbV1(seat.currentBetLabel);
  final capObligation = _hasChipFact(table, seat);
  final sceneHasWager = table.seats.any((s) => _hasChipFact(table, s)) ||
      table.toCallLabel.trim().isNotEmpty ||
      scene.task.runner.options.any(
        (option) => option.amountLabel.trim().isNotEmpty,
      );
  final String status;
  if (seat.stackLabel != null && stack == null) {
    status = 'UNPROVED_STACK_UNPARSED';
  } else if (capObligation && stack == null) {
    status = 'UNPROVED_CAP_STACK_MISSING';
  } else if (capObligation) {
    // This identifies available input, not proof of a chronological ledger.
    status = 'CAP_INPUT_PRESENT_HISTORY_NOT_PROVED';
  } else if (!sceneHasWager &&
      _rankingTasks.contains(scene.task.taskId)) {
    status = 'RANKING_ONLY_NO_WAGER';
  } else if (!_live(seat) && !capObligation) {
    status = 'NO_CONTRIBUTION_SEAT_OUT';
  } else if (!sceneHasWager &&
      table.scope == Act0TableScopeV1.orientation) {
    status = 'ORIENTATION_NO_WAGER';
  } else if (stack == null) {
    status = 'UNPROVED_NO_STACK_APPLICABILITY';
  } else {
    status = 'STACK_PRESENT_NO_ATTRIBUTED_WAGER';
  }
  return {
    'key': '${scene.key}|${seat.seatId}',
    'world_id': scene.worldId,
    'lesson_id': scene.lessonId,
    'task_id': scene.task.taskId,
    'variant': scene.variant,
    'seat_id': seat.seatId,
    'occupied': seat.isOccupied,
    'in_hand': seat.isInHand,
    'folded': seat.isFolded,
    'scope': table.scope.name,
    'legacy_oracle_applicable': pkr06ApplicableV1(table),
    'cap_obligation': capObligation,
    'status': status,
    'stack_label': seat.stackLabel,
    'committed_label': seat.currentBetLabel,
    'blind_label': seat.blindAmountLabel,
    'bet_amount_label': seat.bet?.amountLabel,
    'snapshot_cap_bb':
        stack == null || (seat.currentBetLabel != null && committed == null)
            ? null
            : stack + (committed ?? 0),
    'attributed_actions': [
      for (final action in actions)
        {
          'raw': action.raw,
          'verb': action.verb,
          'chip_verb': action.chipVerb,
          'amount_bb': action.amount,
        },
    ],
  };
}

void main() {
  test('PKR06 bundle targets unique active tasks and preserves grades and XP', () {
    final active = _tasks().toList();
    expect(active.map((task) => task.taskId).toSet().length, active.length);
    const correct = <String, String>{
      'what_poker_is_all_in_meaning': 'all_remaining_committed',
      'what_poker_is_matched_chips_transfer': 'matched_amount_only',
      _sidePotId: 'hero_main_only',
    };
    const options = <String, Set<String>>{
      'what_poker_is_all_in_meaning': {
        'all_remaining_committed', 'automatic_win', 'largest_stack_only',
      },
      'what_poker_is_matched_chips_transfer': {
        'matched_amount_only', 'entire_covering_stack', 'nothing_until_showdown',
      },
      _sidePotId: {'hero_main_only', 'hero_wins_everything', 'side_pot_is_penalty'},
    };
    for (final id in [..._allInIds, _sidePotId]) {
      final task = _task(id);
      expect(task.rewardXp, id == _sidePotId ? 10 : 4, reason: id);
      expect(task.runner.options.map((option) => option.id).toSet(), options[id]);
      expect(
        task.runner.options.where((option) => option.isCorrect).single.id,
        correct[id],
      );
      expect(task.runner.options.map((option) => option.quality).toSet(), {
        Act0FeedbackQualityV1.correct,
        Act0FeedbackQualityV1.wrong,
        Act0FeedbackQualityV1.suboptimal,
      });
    }
  });

  for (final id in _allInIds) {
    test('PKR06 $id authors legal preflop folds and a 19 BB final call', () {
      final table = _task(id).runner.table;
      expect(table.actionTrail.map((item) => item.label), [
        'Blinds: 1.5 BB',
        'UTG folds',
        'HJ folds',
        'CO calls 1 BB (limps)',
        'Hero shoves 20 BB',
        'SB folds',
        'BB folds',
        'CO calls, 20 BB total',
      ]);
      expect(_actions(table).length, 7);
      final coCalls = _actions(table)
          .where((action) => action.actor == 'CO')
          .toList();
      expect(coCalls.map((action) => action.chipVerb), ['call', 'call']);
      expect(coCalls.map((action) => action.amount), [1.0, 20.0]);
      expect(coCalls.last.raw, contains('20 BB total'));
      expect(coCalls.last.amount! - coCalls.first.amount!, 19.0);
      final contributions = _contributions(table);
      expect(contributions, {
        'utg': 0.0, 'hj': 0.0, 'co': 20.0,
        'btn': 20.0, 'sb': 0.5, 'bb': 1.0,
      });
      expect(contributions.values.reduce((a, b) => a + b), 41.5);
      expect(table.potLabel, 'Pot 41.5 BB');
      expect(_seats(table)['co']!.stackLabel, '80 BB');
      expect(_seats(table)['btn']!.stackLabel, '0 BB');
      for (final seatId in ['utg', 'hj', 'sb', 'bb']) {
        _expectFold(table, seatId);
      }
      expect(table.seats.where(_live).map((seat) => seat.seatId).toSet(),
          {'btn', 'co'});
      expect(pkr06FindingsV1(id, table), isEmpty);
    });
  }

  test('PKR06 side pot preserves dead SB and restores the contributing BB', () {
    final table = _task(_sidePotId).runner.table;
    final seats = _seats(table);
    expect(table.actionTrail.map((item) => item.label), [
      'UTG folds',
      'HJ folds',
      'SB posts 0.5 BB, then folds',
      'BB post is included in BB total',
      'Hero all-in 20 BB',
      'CO contributes 50 BB total',
      'BB contributes 50 BB total',
      'CO and BB: 30 BB each to side',
    ]);
    // This trail is a contribution summary, not a full betting replay.
    final contributions = _contributions(table);
    expect(contributions, {
      'utg': 0.0, 'hj': 0.0, 'co': 50.0,
      'btn': 20.0, 'sb': 0.5, 'bb': 50.0,
    });
    final main = contributions.values
        .map((amount) => math.min(amount, 20.0))
        .reduce((a, b) => a + b);
    final side = contributions.values
        .map((amount) => math.max(amount - 20.0, 0.0))
        .reduce((a, b) => a + b);
    expect(main, 60.5);
    expect(side, 60.0);
    expect(main + side, 120.5);
    expect(table.potLabel, 'Main 60.5 BB; side 60 BB');
    expect(
      table.seats
          .where((seat) => _live(seat) && contributions[seat.seatId]! >= 20)
          .map((seat) => seat.seatId).toSet(),
      {'btn', 'co', 'bb'},
    );
    expect(
      table.seats
          .where((seat) => _live(seat) && contributions[seat.seatId]! > 20)
          .map((seat) => seat.seatId).toSet(),
      {'co', 'bb'},
    );
    for (final seatId in ['utg', 'hj', 'sb']) {
      _expectFold(table, seatId);
    }
    expect(seats['bb']!.isInHand, isTrue);
    expect(seats['bb']!.isFolded, isFalse);
    expect(seats['bb']!.cardsVisibleMode, Act0CardsVisibleModeV1.faceDown);
    expect(seats['co']!.stackLabel, '50 BB');
    expect(seats['bb']!.stackLabel, '50 BB');
    expect(pkr06FindingsV1(_sidePotId, table), isEmpty);
  });

  test('PKR06 authored contribution scenes make no terminal winner claim', () {
    final baseline = _task('what_poker_is_pot_stack').runner.table;
    String cards(Iterable<Act0CardStateV1> cards) =>
        cards.map((card) => '${card.rank}:${card.suit}:${card.tone.name}').join('|');
    for (final id in [..._allInIds, _sidePotId]) {
      final table = _task(id).runner.table;
      expect(table.scope, Act0TableScopeV1.explanation);
      expect(table.streetLabel, 'Preflop');
      expect(table.boardCards, isEmpty);
      expect(cards(table.heroCards), cards(baseline.heroCards));
      for (final seat in table.seats) {
        expect(cards(seat.holeCards),
            cards(_seats(baseline)[seat.seatId]!.holeCards));
      }
      final result = resolveShowdownTruthV1(table);
      expect(result.verdict, PotTruthVerdictV1.unproved);
      expect(result.winners, isEmpty);
      expect(result.potBb, isNull);
    }
  });

  test('PKR06 authored scenes keep cap and unparseable-amount negative controls', () {
    final table = _task(_sidePotId).runner.table;
    for (final label in ['CO calls 101 BB', 'CO contributes 101 BB total']) {
      final changed = table.copyWith(actionTrail: [
        ...table.actionTrail,
        Act0ActionTrailItemV1.note(label: label),
      ]);
      expect(pkr06FindingsV1('negative', changed).map((f) => f.rule),
          contains('bet_exceeds_stack'));
    }
    final changed = table.copyWith(actionTrail: [
      ...table.actionTrail,
      const Act0ActionTrailItemV1.note(label: 'CO calls many BB'),
    ]);
    expect(pkr06FindingsV1('negative', changed).map((f) => f.rule),
        contains('action_amount_unparsed'));
  });

  test('PKR06 inventory retains all active seats and unresolved blind caps', () {
    final scenes = _scenes().toList();
    final rows = [
      for (final scene in scenes)
        for (final seat in scene.table.seats) _inventoryRow(scene, seat),
    ];
    expect(rows.length,
        scenes.fold<int>(0, (count, scene) => count + scene.table.seats.length));
    expect(rows.map((row) => row['key']).toSet().length, rows.length);
    expect(scenes.where((scene) => scene.variant == 'primary').length,
        _tasks().length);
    expect(_tasks().map((task) => task.taskId).toSet(), containsAll(_rankingTasks));

    // Concrete unresolved obligations, including every SB/BB in this bundle.
    // Folded/dead blind chips do not prove their original stack caps.
    for (final (id, seatId) in [
      for (final id in _allInIds) ...[(id, 'sb'), (id, 'bb')],
      (_sidePotId, 'sb'),
    ]) {
      final row = rows.singleWhere(
        (row) => row['key'] == '$id|primary|$seatId',
      );
      expect(row['cap_obligation'], isTrue);
      expect(row['status'], 'UNPROVED_CAP_STACK_MISSING');
    }

    final counts = <String, int>{};
    for (final row in rows) {
      final status = row['status']! as String;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    final out = Directory(
      Platform.environment['PKR06_INVENTORY_OUTPUT'] ??
          'output/pkr06_authored_contribution_inventory_v1',
    )..createSync(recursive: true);
    File('${out.path}/inventory.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'evidence_class': 'MACHINE_SOURCE_INVENTORY_NOT_FULL_DOD',
        'scope': 'Active primary and explicit teaching input tables only; '
            'not Runner runtime projections, full betting histories, '
            'option execution, or all prose amounts.',
        'primary_tasks': _tasks().length,
        'scene_variants': scenes.length,
        'seat_rows': rows.length,
        'legacy_oracle_applicable_scenes':
            scenes.where((scene) => pkr06ApplicableV1(scene.table)).length,
        'status_counts': counts,
        'full_cap_applicability_accepted': false,
        'rows': rows,
      }),
    );
    // This test proves enumeration integrity, never an empty gap list.
    // No frozen 85-table count and no :SB/:BB exclusions.
    stdout.writeln('PKR06_INVENTORY tasks=${_tasks().length} '
        'scenes=${scenes.length} seats=${rows.length} '
        'counts=${jsonEncode(counts)} full_dod=NOT_PROVED');
  });
}
