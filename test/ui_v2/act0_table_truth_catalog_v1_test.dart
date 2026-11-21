import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import '../support/act0_catalog_truth_audit_v1.dart';
import '../support/act0_table_truth_v1.dart';
import '../support/act0_w2_catalog_contract_v1.dart';

void main() {
  test('contribution checks reject a changed pot or a missing price label', () {
    final source = Act0ShellStateV1.sample
        .worldById('world_11')
        .lessons
        .expand((lesson) => lesson.taskList)
        .singleWhere(
          (task) => task.taskId == 'w11_trigger_small_price_continue',
        );
    final table = source.runner.table;
    final wrong = table.copyWith(potLabel: 'Pot 11 BB', toCallLabel: '');
    final findings = auditTableContributionsV1(
      source.taskId,
      'mutation',
      wrong,
    );

    expect(
      {for (final row in findings) row.invariant: row.result},
      {'D2.pot_feasibility': 'FAIL', 'D3.to_call_completeness': 'FAIL'},
    );
    expect(table.copyWith(actionTrail: const []).handContributions, isNull);
  });

  test('an omitted call label cannot hide a missing effective stack', () {
    final source = Act0ShellStateV1.sample
        .worldById('world_9')
        .lessons
        .expand((lesson) => lesson.taskList)
        .singleWhere((task) => task.taskId == 'w9_bubble_table_risk_transfer');
    final findings = auditTableContributionsV1(
      source.taskId,
      'mutation',
      source.runner.table.copyWith(toCallLabel: ''),
    );

    expect(
      {for (final row in findings) row.invariant: row.result},
      {
        'D2.pot_feasibility': 'PASS',
        'D3.to_call_completeness': 'NEEDS_SOURCE_CONTEXT',
      },
    );
  });

  test('a played preflop pot without contributions keeps its source gap', () {
    final source = Act0ShellStateV1.sample
        .worldById('world_9')
        .lessons
        .expand((lesson) => lesson.taskList)
        .singleWhere(
          (task) => task.taskId == 'w9_m_ratio_table_window_transfer',
        );

    final findings = auditTableContributionsV1(
      source.taskId,
      'authored/preflop',
      source.runner.table,
    );

    expect(findings.map((row) => (row.invariant, row.result)), [
      ('D2.pot_feasibility', 'NEEDS_SOURCE_CONTEXT'),
    ]);
  });

  test('W9 shows the wager and pot without claiming the exact call', () {
    final task = Act0ShellStateV1.sample
        .worldById('world_9')
        .lessons
        .expand((lesson) => lesson.taskList)
        .singleWhere((task) => task.taskId == 'w9_bubble_table_risk_transfer');
    final table = task.runner.table;
    final ledger = table.handContributions!;
    final seats = table.seats.map((seat) => seat.seatId).toSet();
    expect(table.potLabel, 'Pot 21 BB');
    expect(table.toCallLabel, isEmpty);
    expect(task.runner.caption, contains('15.5 BB more than BTN put in'));
    expect(ledger.amounts(seatIds: seats, actorSeatId: 'btn'), (
      potBb: 21.0,
      toCallBb: null,
    ));
    for (final (startingStack, price) in [(12.0, 9.5), (18.0, 15.5)]) {
      final withStack = Act0HandContributionsV1(
        throughStreet: ledger.throughStreet,
        entries: ledger.entries,
        startingStackBbBySeat: {
          ...ledger.startingStackBbBySeat,
          'btn': startingStack,
        },
      );
      expect(withStack.amounts(seatIds: seats, actorSeatId: 'btn'), (
        potBb: 21.0,
        toCallBb: price,
      ));
    }
  });

  test('W10 uses the authored BTN open and BB call before the check', () {
    final table = Act0ShellStateV1.sample
        .worldById('world_10')
        .lessons
        .expand((lesson) => lesson.taskList)
        .singleWhere(
          (task) => task.taskId == 'w10_table_value_vs_caller_transfer',
        )
        .runner
        .table;

    expect(table.potLabel, 'Pot 5.5 BB');
    expect(table.toCallLabel, isEmpty);
    expect(
      table.handContributions!.entries.map(
        (entry) => (entry.seatId, entry.amountBb),
      ),
      containsAll([('sb', 0.5), ('bb', 1.0), ('btn', 2.5), ('bb', 1.5)]),
    );
    expect(
      table.handContributions!.amounts(
        seatIds: table.seats.map((seat) => seat.seatId).toSet(),
        actorSeatId: 'btn',
      ),
      (potBb: 5.5, toCallBb: 0.0),
    );
  });

  test('a partial street ledger caps its source bound by prior investment', () {
    const expected = {
      'w11_checkpoint_mixed_table_line': 22.0,
      'w12_pretty_hand_bad_price_fold': 80.0,
      'w12_revenge_raise_trap': 27.0,
      'w12_checkpoint_full_loop_line': 17.0,
    };
    final tasks = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList);
    expect({
      for (final task in tasks.where(
        (task) => expected.containsKey(task.taskId),
      ))
        task.taskId: task
            .runner
            .table
            .handContributions!
            .minimumStartingStackBbBySeat['btn'],
    }, expected);
  });

  test('enumerates the live source and final runtime projections', () {
    final rows = auditTableTruth();
    final earlyWorldTasks = Act0ShellStateV1.sample.worlds
        .where((world) => world.worldNumber <= 4)
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .map((task) => task.taskId)
        .toSet();
    for (final (rule, count) in [
      ('D2.pot_feasibility', 156),
      ('D3.to_call_completeness', 112),
    ]) {
      final proof = rows.where(
        (row) => earlyWorldTasks.contains(row.taskId) && row.invariant == rule,
      );
      expect(
        proof.where((row) => row.result != 'PASS').map((row) => row.key),
        isEmpty,
        reason: rule,
      );
      expect(
        proof.map((row) => row.taskId).toSet(),
        hasLength(count),
        reason: rule,
      );
    }
    final middleWorldTasks = Act0ShellStateV1.sample.worlds
        .where((world) => world.worldNumber >= 5 && world.worldNumber <= 8)
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .map((task) => task.taskId)
        .toSet();
    for (final (rule, count) in [
      ('D2.pot_feasibility', 110),
      ('D3.to_call_completeness', 110),
    ]) {
      final proof = rows
          .where(
            (row) =>
                middleWorldTasks.contains(row.taskId) && row.invariant == rule,
          )
          .toList();
      expect(
        proof.map((row) => row.taskId).toSet(),
        hasLength(count),
        reason: rule,
      );
      expect(
        proof.map((row) => row.taskId).toSet(),
        containsAll([
          'w6_continuation_bet_intro',
          'w6_continuation_bet_dry_size',
          'w6_continuation_bet_wet_check',
        ]),
        reason: rule,
      );
      expect(
        proof.where((row) => row.result != 'PASS').map((row) => row.key),
        isEmpty,
      );
    }
    for (final id in [
      'w11_trigger_small_price_continue',
      'w11_trigger_bad_price_fold',
    ]) {
      final proof = rows
          .where(
            (row) =>
                row.taskId == id &&
                (row.invariant == 'D2.pot_feasibility' ||
                    row.invariant == 'D3.to_call_completeness'),
          )
          .toList();
      expect(proof.map((row) => row.invariant).toSet(), {
        'D2.pot_feasibility',
        'D3.to_call_completeness',
      }, reason: id);
      expect(
        proof.map((row) => row.result).toSet(),
        {'PASS'},
        reason:
            '$id: ${proof.where((row) => row.result != 'PASS').map((row) => row.key).join('\n')}',
      );
    }
    final lateWorldTasks = Act0ShellStateV1.sample.worlds
        .where((world) => world.worldNumber >= 9 && world.worldNumber <= 12)
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .map((task) => task.taskId)
        .toSet();
    const lateMissingSource = {
      'D2.pot_feasibility': {
        'w9_m_ratio_table_window_transfer',
        'w11_checkpoint_mixed_table_line',
        'w12_checkpoint_full_loop_line',
        'w12_pretty_hand_bad_price_fold',
        'w12_revenge_raise_trap',
      },
      'D3.to_call_completeness': {'w9_bubble_table_risk_transfer'},
    };
    for (final MapEntry(key: rule, value: missing)
        in lateMissingSource.entries) {
      final proof = rows.where(
        (row) => lateWorldTasks.contains(row.taskId) && row.invariant == rule,
      );
      expect(proof.where((row) => row.result == 'FAIL'), isEmpty, reason: rule);
      expect(
        proof
            .where((row) => row.result == 'NEEDS_SOURCE_CONTEXT')
            .map((row) => row.taskId)
            .toSet(),
        missing,
        reason: rule,
      );
    }
    const lateDecisionProof = {
      'w9_bubble_table_risk_transfer': ('PASS', 'NEEDS_SOURCE_CONTEXT'),
      'w10_table_value_vs_caller_transfer': ('PASS', 'PASS'),
      'w11_checkpoint_mixed_table_line': ('NEEDS_SOURCE_CONTEXT', 'PASS'),
      'w12_checkpoint_full_loop_line': ('NEEDS_SOURCE_CONTEXT', 'PASS'),
      'w12_pretty_hand_bad_price_fold': ('NEEDS_SOURCE_CONTEXT', 'PASS'),
      'w12_revenge_raise_trap': ('NEEDS_SOURCE_CONTEXT', 'PASS'),
      'asm05_new_known_holes_turn_call_10': ('PASS', 'PASS'),
      'asm05_new_known_holes_turn_call_40': ('PASS', 'PASS'),
    };
    for (final MapEntry(key: id, value: (pot, price))
        in lateDecisionProof.entries) {
      for (final (rule, verdict) in [
        ('D2.pot_feasibility', pot),
        ('D3.to_call_completeness', price),
      ]) {
        final proof = rows.where(
          (row) => row.taskId == id && row.invariant == rule,
        );
        expect(proof.map((row) => row.result).toSet(), {
          verdict,
        }, reason: '$id $rule');
      }
    }
    final tasks = Act0ShellStateV1.sample.worlds
        .expand((w) => w.lessons)
        .expand((l) => l.taskList)
        .toList();
    expect(tasks.map((t) => t.taskId).toSet().length, tasks.length);
    expect(
      rows.map((r) => r.taskId).toSet(),
      tasks.map((t) => t.taskId).toSet(),
    );
    final out = Directory(
      Platform.environment['TABLE_TRUTH_OUTPUT'] ?? 'output/table_truth',
    );
    out.createSync(recursive: true);
    File(
      '${out.path}/ledger.json',
    ).writeAsStringSync(jsonEncode(rows.map((r) => r.toJson()).toList()));
    final contract = {
      for (final t in tasks)
        t.taskId: {
          'rewardXp': t.rewardXp,
          'family': t.resolvedTaskFamily.name,
          'options': [
            for (final o in t.runner.options)
              {
                'id': o.id,
                'correct': o.isCorrect,
                'quality': o.quality.name,
                'seat': o.seatId,
                'repairSeats': o.repairFocusSeatIds,
                'repairCards': o.repairFocusCardIds,
                'repairLabels': o.repairFocusLabels,
              },
          ],
        },
    };
    File(
      '${out.path}/learning-contract.json',
    ).writeAsStringSync(jsonEncode(contract));
    const admittedAdditions = {
      'asm05_new_known_holes_turn_call_10',
      'asm05_new_known_holes_turn_call_40',
    };
    final baselineBytes = File(
      'test/ui_v2/fixtures/table_truth_learning_contract_v1.json',
    ).readAsBytesSync();
    expect(
      sha256.convert(baselineBytes).toString(),
      'da163eaa50ee1a19dcdceb09f3ac65af4be3b4c296c36c48ffa5ef7d6d77e7a4',
      reason: 'The historical contract fixture remains byte-for-byte frozen.',
    );
    final baselineContract = Map<String, Object?>.from(
      jsonDecode(utf8.decode(baselineBytes)) as Map,
    );
    final presentAdditions = contract.keys.toSet().intersection(
      admittedAdditions,
    );
    final historicalContract = Map<String, Object?>.from(contract)
      ..removeWhere((id, _) => admittedAdditions.contains(id));
    // Keep the historical fixture immutable. PR460 quality cells and the
    // exact owner-admitted W01 theory option contracts are checked separately;
    // persisted records are never rewritten by this comparison.
    final historicalComparison =
        jsonDecode(jsonEncode(historicalContract)) as Map<String, dynamic>;
    if (presentAdditions.isNotEmpty) {
      final setup =
          historicalComparison['first_table_guide_one_clear_choice']
              as Map<String, dynamic>;
      final options = (setup['options'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final (id, current, prior) in <(String, String, String)>[
        ('co_still_acting', 'wrong', 'wrong'),
        ('hero_has_no_cards', 'wrong', 'suboptimal'),
      ]) {
        final option = options.singleWhere((option) => option['id'] == id);
        expect(
          option['quality'],
          current,
          reason: 'Exact reviewed MAIN01 grade: $id',
        );
        option['quality'] = prior;
      }
    }
    // Exact three-concept source correction admitted on Issue364 / PR475.
    // Literal expected values, never copied from live production at runtime.
    const reviewedW01TheoryOptions = {
      'blinds_theory': [
        {
          'id': 'button_is_not_a_blind',
          'correct': false,
          'quality': 'wrong',
          'seat': 'btn',
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
        {
          'id': 'bb',
          'correct': true,
          'quality': 'correct',
          'seat': 'bb',
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
        {
          'id': 'sb',
          'correct': false,
          'quality': 'wrong',
          'seat': 'sb',
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
      ],
      'cards_ranks_suits_theory': [
        {
          'id': 'rank_only',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
        {
          'id': 'rank_and_suit',
          'correct': true,
          'quality': 'correct',
          'seat': null,
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
        {
          'id': 'suit_only',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
      ],
      'hand_rankings_theory': [
        {
          'id': 'hand_strength',
          'correct': true,
          'quality': 'correct',
          'seat': null,
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
        {
          'id': 'seat_position',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
      ],
    };
    final expectedComparison =
        jsonDecode(jsonEncode(baselineContract)) as Map<String, dynamic>;
    if (presentAdditions.isNotEmpty) {
      for (final entry in reviewedW01TheoryOptions.entries) {
        final expectedTask =
            expectedComparison[entry.key] as Map<String, dynamic>;
        expect(
          expectedTask['options'],
          hasLength(entry.value.length),
          reason:
              'Reviewed theory option cardinality stays frozen: ${entry.key}',
        );
        expectedTask['options'] = entry.value;
      }
    }
    // Exact active W24 context-answer revision. Keep the frozen fixture and
    // verify both literal contracts before reversing only these two choices.
    const contextTaskId = 'same_hand_different_seat_w3_same_hand_recap';
    const priorContextOptions = <Map<String, Object?>>[
      {
        'id': 'utg',
        'correct': false,
        'quality': 'wrong',
        'seat': 'utg',
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      },
      {
        'id': 'btn',
        'correct': true,
        'quality': 'correct',
        'seat': 'btn',
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      },
    ];
    const currentContextOptions = <Map<String, Object?>>[
      {
        'id': 'one_answer',
        'correct': false,
        'quality': 'wrong',
        'seat': null,
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      },
      {
        'id': 'framework',
        'correct': true,
        'quality': 'correct',
        'seat': null,
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      },
      {
        'id': 'seat_blind_only',
        'correct': false,
        'quality': 'wrong',
        'seat': null,
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      },
    ];
    final firstTableOptions =
        (expectedComparison['first_table_guide_one_clear_choice']
                as Map<String, dynamic>)['options']
            as List;
    for (final option in firstTableOptions.cast<Map<String, dynamic>>()) {
      option['repairLabels'] = const [
        'Your cards',
        'Shared cards',
        'Board space',
      ];
    }
    final context = historicalComparison[contextTaskId] as Map<String, dynamic>;
    expect(expectedComparison[contextTaskId], <String, Object?>{
      'rewardXp': 12,
      'family': 'review',
      'options': priorContextOptions,
    });
    if (presentAdditions.isNotEmpty) {
      expect(context, <String, Object?>{
        'rewardXp': 12,
        'family': 'review',
        'options': currentContextOptions,
      });
      context['options'] = priorContextOptions;
    } else {
      expect(context, <String, Object?>{
        'rewardXp': 12,
        'family': 'review',
        'options': priorContextOptions,
      });
    }
    // L1 revises the exact disputed answers while the frozen historical
    // fixture still guards XP, task IDs, unaffected choices and repair fields.
    const gradingCorrections = {
      'button_advantage_button_vs_cutoff': [
        ('co', false, 'co'),
        ('btn', true, 'btn'),
      ],
      'same_hand_different_seat_w3_same_hand_intro': [
        ('cards_and_seat', false, null),
        ('full_context', true, null),
      ],
      'same_hand_different_seat_w3_same_hand_call': [
        ('blinds_only', false, null),
        ('players_behind', true, null),
      ],
      'w4_cheap_price_marginal_call': [
        ('fold', false, null),
        ('call', true, null),
      ],
      'w4_big_price_marginal_fold': [
        ('call', false, null),
        ('fold', true, null),
      ],
      'w4_checkpoint_table_price': [
        ('fold', false, null),
        ('call', true, null),
      ],
    };
    for (final entry in gradingCorrections.entries) {
      final expectedTask =
          expectedComparison[entry.key] as Map<String, dynamic>;
      expectedTask['options'] = [
        for (final (id, correct, seat) in entry.value)
          {
            'id': id,
            'correct': correct,
            'quality': correct ? 'correct' : 'wrong',
            'seat': seat,
            'repairSeats': <String>[],
            'repairCards': <String>[],
            'repairLabels': <String>[],
          },
      ];
    }
    for (final id in [
      'actions_theory',
      'actions_raise_drill',
      'actions_review',
    ]) {
      final row = expectedComparison[id] as Map<String, dynamic>;
      final choice = (row['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == 'call');
      choice['quality'] = 'wrong';
      choice['repairLabels'] = [
        'Matches 1 BB',
        'Sets a higher price',
        'Button',
      ];
    }
    for (final id in [
      'apply_btn_open',
      'button_advantage_button_open',
      'position_apply_btn_open',
    ]) {
      final row = expectedComparison[id] as Map<String, dynamic>;
      for (final choice
          in (row['options'] as List).cast<Map<String, dynamic>>()) {
        choice['repairSeats'] = <String>[];
        choice['repairCards'] = <String>[];
        choice['repairLabels'] = <String>[];
      }
    }
    final checkpointPrice =
        expectedComparison['w4_checkpoint_price'] as Map<String, dynamic>;
    for (final choice
        in (checkpointPrice['options'] as List).cast<Map<String, dynamic>>()) {
      final isCall = choice['id'] == 'call';
      choice['correct'] = isCall;
      choice['quality'] = isCall ? 'correct' : 'wrong';
    }
    // P6 updates the learner label for the two first-hand card exercises.
    // Keep the underlying card focus, choices and grading from the fixture.
    for (final id in [
      'your_first_hand_preflop',
      'your_first_hand_private_cards_recheck',
    ]) {
      final row = expectedComparison[id] as Map<String, dynamic>;
      for (final option
          in (row['options'] as List).cast<Map<String, dynamic>>()) {
        expect(option['repairLabels'], ['Hero cards']);
        option['repairLabels'] = ['Your cards'];
      }
    }
    for (final id in [
      'actions_theory',
      'actions_raise_drill',
      'actions_review',
    ]) {
      final row = expectedComparison[id] as Map<String, dynamic>;
      final options = (row['options'] as List).cast<Map<String, dynamic>>();
      for (final choiceId in ['fold', 'raise']) {
        final option = options.singleWhere((value) => value['id'] == choiceId);
        final labels = (option['repairLabels'] as List).cast<String>();
        expect(labels, contains('Hero acts'));
        option['repairLabels'] = [
          for (final label in labels)
            label == 'Hero acts' ? 'Your turn' : label,
        ];
      }
    }
    const w1FactualGrades = {
      'what_poker_is_table_read_transfer': 'hand_first_only',
      'what_poker_is_table_read_recheck': 'hero_cards_only',
      'your_first_hand_private_cards_recheck': 'board_cards',
      'what_poker_is_all_in_meaning': 'largest_stack_only',
      'what_poker_is_matched_chips_transfer': 'nothing_until_showdown',
      'what_poker_is_win_ways': 'best_hand_showdown',
      'what_poker_is_showdown_win': 'hero_cards_only',
      'what_poker_is_live_win_transfer': 'hero_cards_decide_now',
    };
    for (final entry in w1FactualGrades.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      final option = (task['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((row) => row['id'] == entry.value);
      expect(option['quality'], 'suboptimal', reason: entry.key);
      option['quality'] = 'wrong';
    }
    final qjs =
        expectedComparison['hand_discipline_buckets_borderline']
            as Map<String, dynamic>;
    final strongQJs = (qjs['options'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((option) => option['id'] == 'strong');
    expect(strongQJs['quality'], 'suboptimal');
    strongQJs['quality'] = 'wrong';
    for (final (taskId, optionId) in [
      (
        'position_checkpoint_position_checkpoint_table_notice',
        'late_free_pass',
      ),
      (
        'same_hand_different_seat_position_repair_same_hand_different_seat',
        'position_unimportant',
      ),
      ('w4_bluff_pressure', 'check'),
      ('w4_checkpoint_table_purpose_price', 'random_size'),
    ]) {
      final task = expectedComparison[taskId] as Map<String, dynamic>;
      final option = (task['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == optionId);
      expect(option['quality'], 'suboptimal', reason: '$taskId / $optionId');
      option['quality'] = 'wrong';
    }
    for (final (taskId, choiceId) in [
      ('w9_survival_stack_tradeoff', 'same_both'),
      ('w9_checkpoint_zone_line', 'same_zone'),
    ]) {
      final task = expectedComparison[taskId] as Map<String, dynamic>;
      final choice = (task['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == choiceId);
      expect(choice['quality'], 'suboptimal', reason: taskId);
      choice['quality'] = 'wrong';
    }
    // P7–P8 classify false showdown outcomes and incomplete best fives as wrong.
    for (final id in [
      'showdown_review',
      'your_first_hand_showdown',
      'showdown_best_hand_drill',
    ]) {
      final showdown = expectedComparison[id] as Map<String, dynamic>;
      final winChoice = (showdown['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((choice) => choice['id'] == 'hero_cards_only');
      expect(winChoice['quality'], 'suboptimal');
      winChoice['quality'] = 'wrong';
    }
    expectedComparison['first_table_guide_shared_cards_repair'] = {
      'rewardXp': 0,
      'family': 'repair',
      'options': [
        for (final id in ['board', 'private'])
          {
            'id': id,
            'correct': id == 'board',
            'quality': id == 'board' ? 'correct' : 'wrong',
            'seat': null,
            'repairSeats': <String>[],
            'repairCards': <String>[],
            'repairLabels': <String>[],
          },
      ],
    };
    // P7 aligns the KQo call cue with the chart. Seat and card focus stay pinned.
    final mediumOpen =
        expectedComparison['continue_or_let_go_medium_open']
            as Map<String, dynamic>;
    final limpChoice = (mediumOpen['options'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((choice) => choice['id'] == 'call');
    expect(limpChoice['repairLabels'], ['Limp legal', 'Raise sharper', 'BTN']);
    limpChoice['repairLabels'] = ['Call 1 BB', 'Chart says raise', 'BTN'];
    // L2·3 grades the new price drills and range comparisons explicitly.
    const l2DrawAndRangeOptions = {
      'outs_improvement_w5_table_outs_flush_transfer': [
        ('price_only', false),
        ('heart_outs', true),
      ],
      'outs_improvement_w5_table_outs_straight_transfer': [
        ('four_or_nine', true),
        ('blank_turn_killed', false),
      ],
      'turn_river_changes_w5_board_checkpoint': [
        ('just_outs', false),
        ('texture_draw_outs', true),
      ],
      'w6_value_wet_board': [
        ('bluff', false),
        ('value', true),
        ('missed', false),
      ],
      'w6_board_fit_recap': [
        ('caller', false),
        ('same', false),
        ('raiser', true),
      ],
    };
    for (final entry in l2DrawAndRangeOptions.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      task['options'] = [
        for (final (id, correct) in entry.value)
          {
            'id': id,
            'correct': correct,
            'quality': correct ? 'correct' : 'wrong',
            'seat': null,
            'repairSeats': <String>[],
            'repairCards': <String>[],
            'repairLabels': <String>[],
          },
      ];
    }
    // Exact checkpoint grades replace the retired choice content.
    const l2CheckpointGrades = {
      'straight_draws_w5_gutshot_contrast_transfer': [
        ("gutshot", false, "suboptimal"),
        ("open_ended", true, "correct"),
        ("made_straight", false, "wrong"),
      ],
      'range_checkpoint_value': [
        ("value", true, "correct"),
        ("bluff", false, "suboptimal"),
        ("missed", false, "wrong"),
      ],
      'range_checkpoint_combos': [
        ("twelve", false, "wrong"),
        ("six", false, "wrong"),
        ("sixteen", true, "correct"),
      ],
      'w6_kicker_showdown_compare': [
        ("hero_ak", true, "correct"),
        ("villain_kq", false, "wrong"),
        ("tie", false, "wrong"),
      ],
      'w6_checkpoint_table_best_five': [
        ("hero_wins", false, "wrong"),
        ("split", true, "correct"),
        ("villain_wins", false, "wrong"),
      ],
      'w7_format_table_notice': [
        ("open_same", false, "wrong"),
        ("depth_only", false, "wrong"),
        ("tighten_early", true, "correct"),
      ],
    };
    for (final entry in l2CheckpointGrades.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      task['options'] = [
        for (final (id, correct, quality) in entry.value)
          {
            'id': id,
            'correct': correct,
            'quality': quality,
            'seat': null,
            'repairSeats': <String>[],
            'repairCards': <String>[],
            'repairLabels': <String>[],
          },
      ];
    }
    for (final (taskId, choiceId) in [
      ('w6_ak_combos', 'twelve'),
      ('w6_pair_combos', 'twelve'),
      ('w6_combo_weight_compare', 'same_weight'),
    ]) {
      final task = expectedComparison[taskId] as Map<String, dynamic>;
      final option = (task['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == choiceId);
      expect(option['quality'], 'suboptimal');
      option['quality'] = 'wrong';
    }
    final w6ValueOptions =
        (expectedComparison['w6_value_range_action']
                as Map<String, dynamic>)['options']
            as List;
    final oldFold = w6ValueOptions.cast<Map<String, dynamic>>().singleWhere(
      (option) => option['id'] == 'fold',
    );
    oldFold['id'] = 'bet_bluff'; // BB checked; folding is not an offered line.
    for (final entry in fixedDrawRangeAndStackChoicesV1.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      final option = (task['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == entry.value);
      expect(option['quality'], 'suboptimal', reason: entry.key);
      option['quality'] = 'wrong';
    }
    for (final entry in q3AppendedChoicesV1.entries) {
      final expected = expectedComparison[entry.key] as Map<String, dynamic>;
      (expected['options'] as List).add({
        'id': entry.value,
        'correct': false,
        'quality': 'wrong',
        'seat': null,
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      });
    }
    for (final (taskId, family, correctChoice, choiceCount) in [
      ('w7_flop_bluff_one_player', 'decision', 1, 2),
      ('w7_flop_bluff_two_players', 'decision', 2, 2),
      ('w7_count_winning_rivers', 'counting', 2, 3),
      ('w7_clean_outs_lower_price', 'decision', 1, 2),
      ('w7_clean_outs_higher_price', 'decision', 2, 2),
      ('w7_river_one_bluff_of_six', 'transfer', 2, 2),
      ('w7_river_two_bluffs_of_six', 'transfer', 1, 2),
      ('w7_checkpoint_river_card_excludes_hand', 'transfer', 2, 2),
    ]) {
      expectedComparison[taskId] = {
        'rewardXp': 10,
        'family': family,
        'options': [
          for (var choice = 1; choice <= choiceCount; choice++)
            {
              'id': 'choice_$choice',
              'correct': choice == correctChoice,
              'quality': choice == correctChoice ? 'correct' : 'wrong',
              'seat': null,
              'repairSeats': <String>[],
              'repairCards': <String>[],
              'repairLabels': <String>[],
            },
        ],
      };
    }
    expectedComparison['w4_min_raise_preflop'] = {
      'rewardXp': 8,
      'family': 'decision',
      'options': [
        {
          'id': 'four_bb',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
        {
          'id': 'five_bb',
          'correct': true,
          'quality': 'correct',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
        {
          'id': 'six_bb',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
      ],
    };
    expectedComparison['w4_min_raise_postflop'] = {
      'rewardXp': 8,
      'family': 'decision',
      'options': [
        {
          'id': 'six_bb',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
        {
          'id': 'twelve_bb',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
        {
          'id': 'eight_bb',
          'correct': true,
          'quality': 'correct',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
      ],
    };
    Map<String, Object?> w2Choice(String id, {bool correct = false}) => {
      'id': id,
      'correct': correct,
      'quality': correct ? 'correct' : 'wrong',
      'seat': null,
      'repairSeats': <String>[],
      'repairCards': <String>[],
      'repairLabels': <String>[],
    };
    for (final entry in w2AppendedWrongChoicesV1.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      (task['options'] as List).add(w2Choice(entry.value));
    }
    const w2ReasonChoices = {
      'apply_recap': (['fold', 'call', 'seat_guarantee'], 'fold'),
      'hand_discipline_buckets_recap': (
        ['suit_only', 'bucket_and_seat', 'blinds_only'],
        'bucket_and_seat',
      ),
      'fold_discipline_facing_fold': (
        ['call', 'fold', 'raise_for_pot'],
        'fold',
      ),
    };
    for (final MapEntry(key: id, value: (choices, correct))
        in w2ReasonChoices.entries) {
      final task = expectedComparison[id] as Map<String, dynamic>;
      task['options'] = [
        for (final id in choices) w2Choice(id, correct: id == correct),
      ];
    }
    for (final (id, xp, family, choices, correct) in [
      ('intro', 6, 'learn', <String>[], ''),
      ('premium', 9, 'decision', ['raise', 'call', 'fold'], 'raise'),
      ('strong', 9, 'decision', ['raise', 'call', 'fold'], 'call'),
      ('medium', 9, 'decision', ['premium', 'call', 'unopened'], 'call'),
      ('fold', 12, 'review', ['raise', 'call', 'fold'], 'fold'),
    ]) {
      expectedComparison['w2_narrow_three_bet_$id'] = {
        'rewardXp': xp,
        'family': family,
        'options': [
          for (final id in choices) w2Choice(id, correct: id == correct),
        ],
      };
    }
    Map<String, Object?> w3Option(
      String id, {
      String? seat,
      bool correct = false,
    }) => {
      'id': id,
      'correct': correct,
      'quality': correct ? 'correct' : 'wrong',
      'seat': seat,
      'repairSeats': <String>[],
      'repairCards': <String>[],
      'repairLabels': <String>[],
    };
    final applyRecap = expectedComparison['position_apply_recap'] as Map;
    final limpExplanation = (applyRecap['options'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((option) => option['id'] == 'call');
    expect(limpExplanation['quality'], 'suboptimal');
    limpExplanation['quality'] = 'wrong';
    const w3AddedSeatChoices = {
      'position_six_seats_positions_utg': 'bb',
      'position_six_seats_hj_co_contrast': 'utg',
      'position_six_seats_positions_cutoff': 'btn',
      'position_six_seats_positions_button': 'sb',
      'position_six_seats_sb_recognition': 'btn',
      'position_six_seats_bb_recognition': 'utg',
      'position_six_seats_position_repair_seat_id_btn': 'bb',
      'position_six_seats_position_repair_seat_id_utg': 'sb',
      'button_advantage_button_intro': 'co',
      'button_advantage_find_button': 'sb',
      'button_advantage_button_last': 'bb',
      'button_advantage_button_vs_cutoff': 'hj',
      'button_advantage_position_repair_btn_last_postflop': 'bb',
      'early_vs_late_w2_position_intro': 'hj',
      'early_vs_late_w2_late_position': 'co',
      'early_vs_late_w2_early_position': 'co',
      'position_apply_intro': 'co',
      'position_checkpoint_position_checkpoint_intro': 'hj',
    };
    const w3AddedAnswerChoices = {
      'position_six_seats_positions_review': 'blinds_and_button_only',
      'early_vs_late_early_pressure_choice': 'position_returns_chips',
      'early_vs_late_position_repair_utg_players_behind': 'only_hj',
      'early_vs_late_late_info_choice': 'smaller_blinds',
      'same_hand_different_seat_w3_same_hand_intro': 'seat_and_action',
      'same_hand_different_seat_w3_same_hand_call': 'opener_and_button',
      'same_hand_different_seat_same_hand_early_fold': 'call',
      'same_hand_different_seat_same_hand_late_open': 'fold',
      'position_apply_late_open': 'fold',
      'position_apply_early_fold': 'call',
      'position_apply_hj_fold': 'call',
      'position_apply_recap': 'off_chart',
      'position_checkpoint_position_checkpoint_late_open': 'fold',
      'position_checkpoint_position_checkpoint_early_fold': 'call',
      'position_checkpoint_position_checkpoint_btn_call': 'raise',
      'position_checkpoint_position_checkpoint_review': 'fold',
    };
    for (final entry in w3AddedSeatChoices.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      (task['options'] as List).add(w3Option(entry.value, seat: entry.value));
    }
    for (final entry in w3AddedAnswerChoices.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      (task['options'] as List).add(w3Option(entry.value));
    }
    for (final (id, xp, family, choices, correct) in [
      (
        'position_six_seats_position_order_reason',
        6,
        'decision',
        ['cutoff_first', 'seat_order', 'button_before_cutoff'],
        'seat_order',
      ),
      (
        'button_advantage_button_order_reason',
        6,
        'decision',
        ['sees_first_action', 'smaller_price', 'owns_first_turn'],
        'sees_first_action',
      ),
      ('w3_play_from_blinds_intro', 6, 'learn', <String>[], ''),
      (
        'w3_play_from_blinds_small_blind_fold',
        8,
        'decision',
        ['call', 'fold', 'raise'],
        'fold',
      ),
      (
        'w3_play_from_blinds_small_blind_raise',
        8,
        'decision',
        ['raise', 'call', 'fold'],
        'raise',
      ),
      (
        'w3_play_from_blinds_small_blind_medium_raise',
        8,
        'decision',
        ['raise', 'call', 'fold'],
        'raise',
      ),
      (
        'w3_play_from_blinds_small_blind_medium_fold',
        8,
        'decision',
        ['call', 'fold', 'raise'],
        'fold',
      ),
      (
        'w3_play_from_blinds_big_blind_price',
        8,
        'decision',
        ['two_five', 'one', 'one_five'],
        'one_five',
      ),
      (
        'w3_play_from_blinds_big_blind_defend',
        10,
        'review',
        ['fold', 'call', 'posted_free'],
        'call',
      ),
    ]) {
      expectedComparison[id] = {
        'rewardXp': xp,
        'family': family,
        'options': [
          for (final option in choices)
            w3Option(option, correct: option == correct),
        ],
      };
    }
    for (final (id, xp, family, options, correct) in [
      ('intro', 6, 'learn', <String>[], ''),
      (
        'dry_size',
        9,
        'decision',
        ['bet_two', 'bet_six', 'bet_nine'],
        'bet_two',
      ),
      ('wet_check', 9, 'review', ['bet_small', 'check', 'bet_large'], 'check'),
    ]) {
      expectedComparison['w6_continuation_bet_$id'] = {
        'rewardXp': xp,
        'family': family,
        'options': [
          for (final option in options)
            w2Choice(option, correct: option == correct),
        ],
      };
    }
    expect(
      historicalComparison,
      expectedComparison,
      reason:
          'Only explicitly reviewed MAIN01, W01, W24, L1, L2, Q7, Q11 and the World 2, 3 and 6 packets may '
          'differ. Other identity, XP, family, grading and repair fields stay pinned.',
    );
    const expectedAsmContracts = {
      'asm05_new_known_holes_turn_call_10': {
        'rewardXp': 0,
        'family': 'decision',
        'options': [
          {
            'id': 'fold',
            'correct': false,
            'quality': 'wrong',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
          {
            'id': 'call',
            'correct': true,
            'quality': 'correct',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
        ],
      },
      'asm05_new_known_holes_turn_call_40': {
        'rewardXp': 0,
        'family': 'decision',
        'options': [
          {
            'id': 'fold',
            'correct': true,
            'quality': 'correct',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
          {
            'id': 'call',
            'correct': false,
            'quality': 'wrong',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
        ],
      },
    };
    if (presentAdditions.isNotEmpty) {
      expect(
        presentAdditions,
        admittedAdditions,
        reason: 'The candidate must contain both exact ASM05 additions',
      );
      for (final id in admittedAdditions) {
        expect(contract[id], expectedAsmContracts[id], reason: id);
      }
    }
    final fingerprints = <String, Object?>{};
    final choiceIdentity = <String, Object?>{};
    for (final world in Act0ShellStateV1.sample.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          final fingerprint = act0AuthoredSourceFingerprintV1(
            worldId: world.worldId,
            lessonId: lesson.lessonId,
            task: task,
          );
          expect(fingerprint, isNotNull, reason: task.taskId);
          fingerprints[task.taskId] = {
            'world_id': world.worldId,
            'lesson_id': lesson.lessonId,
            'fingerprint': fingerprint,
          };
          choiceIdentity[task.taskId] = [
            for (final option in task.runner.options)
              [
                option.id,
                option.label,
                option.isCorrect,
                option.quality.name,
                option.preferredLabel,
              ],
          ];
        }
      }
    }
    File(
      '${out.path}/source-fingerprints.json',
    ).writeAsStringSync(jsonEncode(fingerprints));
    File(
      '${out.path}/choice-identity.json',
    ).writeAsStringSync(jsonEncode(choiceIdentity));
    final snapshot = {
      for (final t in tasks)
        t.taskId: {
          'caption': t.runner.caption,
          'hint': t.runner.hint,
          'question': t.runner.question,
          'table': _table(t.runner.table),
          'teaching': [
            for (final step in t.runner.teachingSteps)
              {
                'title': step.title,
                'body': step.body,
                'table': step.table == null ? null : _table(step.table!),
                'seats': step.focusSeatIds,
                'cards': step.focusCardIds,
              },
          ],
          'options': [
            for (final o in t.runner.options)
              {
                'id': o.id,
                'label': o.label,
                'amount': o.amountLabel,
                'reason': o.feedbackReason,
                'preferred': o.preferredLabel,
              },
          ],
        },
    };
    File(
      '${out.path}/runtime-inputs.json',
    ).writeAsStringSync(jsonEncode(snapshot));
    final isCandidate = presentAdditions.isNotEmpty;
    final sourceReference = isCandidate
        ? const {
            'commit': '5b0dd2e300053e52b323e54df6c759ddb5f04b48',
            'state_sha256':
                'd9a78d57817c8eaef7dc1a376f53ade7774229be4a34063d5dc0cf152bb67221',
            'factory_sha256':
                'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
          }
        : const {
            'commit': 'fa079b6c5880814e231981a7bd5ed97df192d215',
            'state_sha256':
                'e9f87d4bf73b75d77bd7b04ddf111cbf6b64e796259ffe42adadea9bbb3270e2',
            'factory_sha256': null,
          };
    final factory = File(
      'lib/ui_v2/act0_shell/act0_asm05_authored_decision_truth_v1.dart',
    );
    final producerReceipt = {
      'head': (Process.runSync('git', ['rev-parse', 'HEAD']).stdout as String)
          .trim(),
      'state_sha256': sha256
          .convert(
            File(
              'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
            ).readAsBytesSync(),
          )
          .toString(),
      'factory_sha256': isCandidate && factory.existsSync()
          ? sha256.convert(factory.readAsBytesSync()).toString()
          : null,
    };
    final artifactRecords = {
      for (final id in admittedAdditions)
        if (presentAdditions.contains(id))
          id: [
            contract[id],
            fingerprints[id],
            choiceIdentity[id],
            snapshot[id],
          ],
    };
    File('${out.path}/typed-cohort-v2.json').writeAsStringSync(
      jsonEncode({
        'schema': 2,
        'role': isCandidate ? 'candidate' : 'historical_baseline',
        'admitted_source_reference': sourceReference,
        'producer_receipt': producerReceipt,
        'historical_ids': baselineContract.keys.toList()..sort(),
        'new_authoring': [
          for (final world in Act0ShellStateV1.sample.worlds)
            for (final lesson in world.lessons)
              for (final task in lesson.taskList)
                if (presentAdditions.contains(task.taskId))
                  {
                    'task_id': task.taskId,
                    'world_id': world.worldId,
                    'lesson_id': lesson.lessonId,
                    'provenance': 'NEW_AUTHORING_ASM05',
                    'artifact_sha256': sha256
                        .convert(
                          utf8.encode(jsonEncode(artifactRecords[task.taskId])),
                        )
                        .toString(),
                    'source_binding_sha256': sha256
                        .convert(
                          utf8.encode(
                            jsonEncode([
                              sourceReference,
                              task.taskId,
                              artifactRecords[task.taskId],
                            ]),
                          ),
                        )
                        .toString(),
                  },
        ],
      }),
    );
    final failures = rows.where((r) => r.result == 'FAIL').toList();
    final byInvariant = <String, Set<String>>{};
    for (final r in failures) {
      byInvariant.putIfAbsent(r.invariant, () => <String>{}).add(r.taskId);
    }
    stdout.writeln(
      'TABLE_TRUTH tasks=${tasks.length} variants=${rows.map((r) => '${r.taskId}|${r.variant}').toSet().length} rows=${rows.length}',
    );
    stdout.writeln(
      jsonEncode({
        for (final e in byInvariant.entries) e.key: e.value.toList()..sort(),
      }),
    );
    if (Platform.environment['TABLE_TRUTH_CENSUS_ONLY'] != '1') {
      expect(
        failures.map((r) => r.key),
        isEmpty,
        reason: 'Confirmed invariants must have exact disposition',
      );
    }
  });
}

Map<String, Object?> _table(Act0TableStateV1 t) => {
  'scope': t.scope.name,
  'hero': t.heroCards.map(cardIdentity).toList(),
  'board': t.boardCards.map(cardIdentity).toList(),
  'street': t.streetLabel,
  'pot': t.potLabel,
  'call': t.toCallLabel,
  'center': t.centerLabel,
  'actor': t.activeSeatId,
  'heroSeat': t.heroSeatId,
  'focusSeats': t.highlightedSeatIds,
  'focusCards': t.highlightedCardIds,
  'trail': [
    for (final a in t.actionTrail) {'kind': a.kind.name, 'label': a.label},
  ],
  'seats': [
    for (final s in t.seats)
      {
        'id': s.seatId,
        'hero': s.isHero,
        'active': s.isActive,
        'inHand': s.isInHand,
        'folded': s.isFolded,
        'occupied': s.isOccupied,
        'acted': s.hasActed,
        'mode': s.cardsVisibleMode.name,
        'cards': s.holeCards.map(cardIdentity).toList(),
        'blind': s.blindAmountLabel,
        'currentBet': s.currentBetLabel,
        'bet': s.bet == null
            ? null
            : {
                'kind': s.bet!.kind.name,
                'label': s.bet!.label,
                'amount': s.bet!.amountLabel,
              },
      },
  ],
};
