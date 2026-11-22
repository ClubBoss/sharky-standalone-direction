import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_w11_wave4_contract_v1.dart';
import '../support/act0_w12_wave4_contract_v1.dart';
import '../support/act0_catalog_truth_audit_v1.dart';
import '../support/act0_w2_catalog_contract_v1.dart';
import '../support/act0_w3_catalog_contract_v1.dart';
import '../support/act0_w6_catalog_contract_v1.dart';

const _asm05NewTaskIds = <String>{
  'asm05_new_known_holes_turn_call_10',
  'asm05_new_known_holes_turn_call_40',
};

/// Assessment identity and grading consistency for all current W1-W12 tasks.
/// The 367 legacy rows retain their frozen contract; exactly two named
/// NEW_AUTHORING ASM-05 rows extend it without replacing historical meaning.
/// Reviewed MAIN01 quality cells and three W01 theory option contracts each
/// have exact current freezes and reconstruct only their prior comparison cells.
/// Both historical fingerprints and persisted records remain intact.
///
/// Stable task ids and choice ids are what saved receipts, repair debt and
/// XP refer to; grading flags, answer quality, preferred answers and feedback
/// must agree with each other so the learner sees one truthful verdict.
void main() {
  final tasks = <Act0LessonTaskV1>[
    for (final w in Act0ShellStateV1.sample.worlds)
      for (final l in w.lessons) ...l.taskList,
  ];

  test('task ids and choice ids are unique and stable in shape', () {
    expect(
      tasks,
      hasLength(
        435 + w11Wave4ChoiceContractV1.length + w12Wave4ChoiceContractV1.length,
      ),
    );
    expect(
      tasks.map((t) => t.taskId).toSet(),
      hasLength(
        435 + w11Wave4ChoiceContractV1.length + w12Wave4ChoiceContractV1.length,
      ),
    );
    final problems = <String>[];
    for (final t in tasks) {
      final ids = t.runner.options.map((o) => o.id).toList();
      if (ids.toSet().length != ids.length) problems.add('${t.taskId} dup');
      for (final id in [t.taskId, ...ids]) {
        if (!RegExp(r'^[a-z0-9_]+$').hasMatch(id)) problems.add('$id shape');
      }
    }
    expect(problems, isEmpty);
  });

  test('graded answers, quality, preferred answer and feedback agree', () {
    final problems = <String>[];
    var graded = 0;
    for (final t in tasks) {
      final options = t.runner.options;
      if (t.phase == Act0LessonPhaseV1.theory || options.isEmpty) continue;
      graded += 1;
      final labels = options.map((o) => o.label).toSet();
      final correct = options.where((o) => o.isCorrect).toList();
      if (correct.isEmpty) problems.add('${t.taskId}: no correct option');
      for (final o in options) {
        final id = '${t.taskId}/${o.id}';
        if (o.isCorrect != (o.quality == Act0FeedbackQualityV1.correct)) {
          problems.add('$id: correct=${o.isCorrect} quality=${o.quality}');
        }
        if (!labels.contains(o.preferredLabel)) {
          problems.add('$id: preferred "${o.preferredLabel}" is no option');
        }
        if (!o.isCorrect && !correct.any((c) => c.label == o.preferredLabel)) {
          problems.add('$id: preferred answer is not a correct option');
        }
        if (o.feedbackReason.trim().isEmpty) problems.add('$id: no feedback');
      }
    }
    expect(graded, greaterThan(250));
    expect(problems, isEmpty);
  });

  test('frozen source task and choice identity contract', () {
    final entries = <List<Object?>>[
      for (final world in Act0ShellStateV1.sample.worlds)
        for (final lesson in world.lessons)
          for (final task in lesson.taskList)
            <Object?>[
              world.worldId,
              lesson.lessonId,
              task.taskId,
              task.phase.name,
              task.stepKind.name,
              <List<Object?>>[
                for (final option in task.runner.options)
                  <Object?>[
                    option.id,
                    option.label,
                    option.isCorrect,
                    option.quality.name,
                    option.preferredLabel,
                  ],
              ],
            ],
    ]..sort((a, b) => (a[2] as String).compareTo(b[2] as String));
    final w1Changes =
        jsonDecode(
              File('test/fixtures/act0_w1_revision_v1.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(w1Changes, hasLength(47));
    for (final change in w1Changes.entries) {
      final index = entries.indexWhere((row) => row[2] == change.key);
      expect(index, isNonNegative, reason: change.key);
      expect(entries[index][0], 'world_1', reason: change.key);
      expect(entries[index], change.value['current'], reason: change.key);
      final prior = (change.value['prior'] as List).cast<Object?>();
      entries[index] = [
        ...prior.take(5),
        (prior[5] as List)
            .map((option) => (option as List).cast<Object?>())
            .toList(),
      ];
    }
    expect(
      entries,
      hasLength(
        435 + w11Wave4ChoiceContractV1.length + w12Wave4ChoiceContractV1.length,
      ),
    );
    const w1Additions = {
      'hand_rankings_find_the_match': [
        'world_1',
        'hand_rankings_table',
        'hand_rankings_find_the_match',
        'drill',
        'practice',
        [
          ['kings', 'Kings', false, 'wrong', 'Eights'],
          ['queens', 'Queens', false, 'wrong', 'Eights'],
          ['eights', 'Eights', true, 'correct', 'Eights'],
        ],
      ],
      'blinds_pot_after_posts': [
        'world_1',
        'blinds_order_practice',
        'blinds_pot_after_posts',
        'drill',
        'practice',
        [
          ['both', '1.5 BB', true, 'correct', '1.5 BB'],
          ['bb_only', '1 BB', false, 'wrong', '1.5 BB'],
          ['equal_posts', '2 BB', false, 'wrong', '1.5 BB'],
        ],
      ],
      'positions_read_first_check': [
        'world_1',
        'positions',
        'positions_read_first_check',
        'drill',
        'practice',
        [
          ['hj', 'HJ', false, 'wrong', 'BB'],
          ['bb', 'BB', true, 'correct', 'BB'],
          ['btn', 'BTN', false, 'wrong', 'BB'],
        ],
      ],
      'what_poker_is_side_pot_eligibility': [
        'world_1',
        'what_poker_is_content',
        'what_poker_is_side_pot_eligibility',
        'drill',
        'practice',
        [
          ['both_pots', 'Both pots', false, 'wrong', 'Main pot only'],
          ['main_pot_only', 'Main pot only', true, 'correct', 'Main pot only'],
          ['side_pot_only', 'Side pot only', false, 'wrong', 'Main pot only'],
        ],
      ],
      'cards_ranks_suits_premium_decision': [
        'world_1',
        'cards_ranks_suits',
        'cards_ranks_suits_premium_decision',
        'drill',
        'practice',
        [
          ['call', 'Call', false, 'suboptimal', 'Raise to 7.5 BB'],
          ['raise', 'Raise to 7.5 BB', true, 'correct', 'Raise to 7.5 BB'],
          ['fold', 'Fold', false, 'wrong', 'Raise to 7.5 BB'],
        ],
      ],
      'blinds_missing_post_amount': [
        'world_1',
        'blinds_action_order',
        'blinds_missing_post_amount',
        'drill',
        'practice',
        [
          ['small_blind_only', '0.5 BB', false, 'wrong', '1 BB'],
          ['big_blind_amount', '1 BB', true, 'correct', '1 BB'],
          ['both_posts', '1.5 BB', false, 'wrong', '1 BB'],
        ],
      ],
      'actions_call_chip_cost': [
        'world_1',
        'fold_check_call_raise',
        'actions_call_chip_cost',
        'drill',
        'practice',
        [
          ['free', '0 BB', false, 'wrong', '2 BB'],
          ['match_bet', '2 BB', true, 'correct', '2 BB'],
          ['match_pot', '8 BB', false, 'wrong', '2 BB'],
        ],
      ],
      'first_table_guide_first_decision': [
        'world_1',
        'what_poker_is',
        'first_table_guide_first_decision',
        'drill',
        'practice',
        [
          ['fold', 'Fold', false, 'wrong', 'Raise to 7.5 BB'],
          ['call', 'Call', false, 'suboptimal', 'Raise to 7.5 BB'],
          ['raise', 'Raise to 7.5 BB', true, 'correct', 'Raise to 7.5 BB'],
        ],
      ],
      'hand_rankings_compare_ace_straights': [
        'world_1',
        'hand_rankings_comparisons',
        'hand_rankings_compare_ace_straights',
        'drill',
        'practice',
        [
          ['broadway', 'Broadway wins', true, 'correct', 'Broadway wins'],
          ['wheel', 'A-2-3-4-5 wins', false, 'wrong', 'Broadway wins'],
          ['tie', 'Both straights tie', false, 'wrong', 'Broadway wins'],
        ],
      ],
    };
    for (final addition in w1Additions.entries) {
      expect(
        entries.singleWhere((row) => row[2] == addition.key),
        addition.value,
      );
    }
    const boardRepair = 'first_table_guide_shared_cards_repair';
    expect(entries.singleWhere((row) => row[2] == boardRepair), [
      'world_1',
      'what_poker_is',
      boardRepair,
      'drill',
      'fixMistakes',
      [
        ['board', 'Board cards', true, 'correct', 'Board cards'],
        ['private', 'Private cards', false, 'wrong', 'Board cards'],
      ],
    ]);
    final newEntries = entries
        .where((row) => _asm05NewTaskIds.contains(row[2]))
        .toList(growable: false);
    expect(newEntries, <List<Object?>>[
      <Object?>[
        'world_12',
        'decision_over_outcome',
        'asm05_new_known_holes_turn_call_10',
        'drill',
        'practice',
        <List<Object?>>[
          <Object?>['fold', 'Fold', false, 'wrong', 'Call'],
          <Object?>['call', 'Call', true, 'correct', 'Call'],
        ],
      ],
      <Object?>[
        'world_12',
        'decision_over_outcome',
        'asm05_new_known_holes_turn_call_40',
        'drill',
        'practice',
        <List<Object?>>[
          <Object?>['fold', 'Fold', true, 'correct', 'Fold'],
          <Object?>['call', 'Call', false, 'wrong', 'Fold'],
        ],
      ],
    ]);
    for (final entry in {
      ...q3AppendedChoicesV1,
      ...w2AppendedWrongChoicesV1,
      ...w3AppendedWrongChoicesV1,
    }.entries) {
      final task = entries.singleWhere((row) => row[2] == entry.key);
      final choices = task.last as List<List<Object?>>;
      expect(choices, hasLength(3), reason: entry.key);
      expect(choices.last.take(1), [entry.value], reason: entry.key);
      expect(choices.last[2], isFalse, reason: entry.key);
      expect(choices.last[3], 'wrong', reason: entry.key);
      choices.removeLast();
    }
    for (final entry in wave4CorrectOptionMovedLastV1.entries) {
      final task = entries.singleWhere((row) => row[2] == entry.key);
      final choices = task.last as List<List<Object?>>;
      expect(choices, hasLength(3), reason: entry.key);
      expect(choices.last[0], entry.value, reason: entry.key);
      expect(choices.last[2], isTrue, reason: entry.key);
      // Restore the historical comparison while keeping today's order asserted.
      choices.insert(1, choices.removeLast());
    }
    for (final entry in w4AddedOptionQualityV1.entries) {
      final task = entries.singleWhere((row) => row[2] == entry.key);
      final choices = task.last as List<List<Object?>>;
      final (id, quality) = entry.value;
      expect(choices, hasLength(3), reason: entry.key);
      expect(choices.last[0], id, reason: entry.key);
      expect(choices.last[2], isFalse, reason: entry.key);
      expect(choices.last[3], quality, reason: entry.key);
      choices.removeLast();
      if (entry.key == 'w4_big_price_marginal_fold') {
        expect(choices, [
          ['call', '46% · Call', false, 'wrong', '32% · Fold'],
          ['fold', '32% · Fold', true, 'correct', '32% · Fold'],
        ]);
        task[5] = <List<Object?>>[
          ['call', 'Call', false, 'wrong', 'Fold'],
          ['fold', 'Fold', true, 'correct', 'Fold'],
        ];
      }
    }
    expect(
      entries.where((row) => w7AppliedTaskIdsV1.contains(row[2])),
      hasLength(8),
    );
    expect(
      entries.where((row) => w4MinRaiseTaskIdsV1.contains(row[2])),
      hasLength(2),
    );
    for (final entry in w2Q9ChoiceContractV1.entries) {
      final task = entries.singleWhere((row) => row[2] == entry.key);
      expect(task.take(2), ['world_2', 'w2_narrow_three_bet']);
      expect(task.last, entry.value, reason: entry.key);
    }
    for (final entry in w2CurrentReasonChoicesV1.entries) {
      final task = entries.singleWhere((row) => row[2] == entry.key);
      expect(task.last, entry.value, reason: entry.key);
      task[5] = preW2ReasonChoicesV1[entry.key];
    }
    for (final entry in w3NewChoiceContractV1.entries) {
      final task = entries.singleWhere((row) => row[2] == entry.key);
      expect(task.first, 'world_3');
      expect(task.last, entry.value, reason: entry.key);
    }
    for (final entry in w3CurrentReasonChoicesV1.entries) {
      final task = entries.singleWhere((row) => row[2] == entry.key);
      expect(task.last, entry.value, reason: entry.key);
      task[5] = preW3ReasonChoicesV1[entry.key];
    }
    for (final entry in w6NewChoiceContractV1.entries) {
      final row = entries.singleWhere((row) => row[2] == entry.key);
      expect(row.take(2), ['world_6', 'w6_continuation_bet']);
      expect(row.last, entry.value, reason: entry.key);
    }
    for (final entry in w6CurrentChoiceContractV1.entries) {
      final row = entries.singleWhere((row) => row[2] == entry.key);
      expect(row.last, entry.value, reason: entry.key);
      row[5] = preW6ChoiceContractV1[entry.key];
    }
    for (final id in w6MovedToRangeReadingV1) {
      final row = entries.singleWhere((row) => row[2] == id);
      expect(row.take(2), ['world_6', 'range_reading_review']);
      row[1] = 'range_thinking_checkpoint';
    }
    for (final entry in w5AddedOptionQualityV1.entries) {
      final task = entries.singleWhere((row) => row[2] == entry.key);
      final choices = task.last as List<List<Object?>>;
      final (id, quality) = entry.value;
      expect(choices, hasLength(3), reason: entry.key);
      expect(choices.last[0], id, reason: entry.key);
      expect(choices.last[2], isFalse, reason: entry.key);
      expect(choices.last[3], quality, reason: entry.key);
      choices.removeLast();
      switch (entry.key) {
        case 'flush_draws_w5_no_flush_draw':
          expect(choices, [
            [
              'yes',
              '1 · flush draw',
              false,
              'wrong',
              '3 · not enough cards remain',
            ],
            [
              'no',
              '3 · not enough cards remain',
              true,
              'correct',
              '3 · not enough cards remain',
            ],
          ]);
          task[5] = <List<Object?>>[
            ['yes', 'Yes', false, 'wrong', 'No'],
            ['no', 'No', true, 'correct', 'No'],
          ];
        case 'straight_draws_w5_straight_draw_find':
          expect(choices, [
            [
              'straight_draw',
              '2 · open-ended straight draw',
              true,
              'correct',
              '2 · open-ended straight draw',
            ],
            [
              'flush_draw',
              '0 · flush draw instead',
              false,
              'wrong',
              '2 · open-ended straight draw',
            ],
          ]);
          task[5] = <List<Object?>>[
            [
              'straight_draw',
              'Straight draw',
              true,
              'correct',
              'Straight draw',
            ],
            ['flush_draw', 'Flush draw', false, 'wrong', 'Straight draw'],
          ];
      }
    }
    const w4SeatAdditions = {
      'w4_purpose_collect_value': [
        'world_4',
        'why_bets_happen',
        'w4_purpose_collect_value',
        'drill',
        'practice',
        [
          ['bet_two', 'Bet 2 BB', true, 'correct', 'Bet 2 BB'],
          ['check', 'Check', false, 'wrong', 'Bet 2 BB'],
          ['bet_four', 'Bet 4 BB', false, 'wrong', 'Bet 2 BB'],
        ],
      ],
      'w4_protection_small_denial': [
        'world_4',
        'protection_and_denial',
        'w4_protection_small_denial',
        'drill',
        'practice',
        [
          ['check', 'Check', false, 'wrong', 'Bet 2 BB'],
          ['bet_four', 'Bet 4 BB', false, 'wrong', 'Bet 2 BB'],
          ['bet_two', 'Bet 2 BB', true, 'correct', 'Bet 2 BB'],
        ],
      ],
      'w4_value_worse_call_seat': [
        'world_4',
        'value_bets',
        'w4_value_worse_call_seat',
        'drill',
        'practice',
        [
          ['btn', 'Button', false, 'wrong', 'Big blind'],
          ['bb', 'Big blind', true, 'correct', 'Big blind'],
          ['co', 'Cutoff', false, 'wrong', 'Big blind'],
        ],
      ],
      'w4_bluff_target_seat': [
        'world_4',
        'bluff_pressure',
        'w4_bluff_target_seat',
        'drill',
        'practice',
        [
          ['btn', 'Button', false, 'wrong', 'Big blind'],
          ['co', 'Cutoff', false, 'wrong', 'Big blind'],
          ['bb', 'Big blind', true, 'correct', 'Big blind'],
        ],
      ],
    };
    for (final addition in w4SeatAdditions.entries) {
      expect(
        entries.singleWhere((row) => row[2] == addition.key),
        addition.value,
      );
    }
    const w4BettorTask = 'w4_price_find_bettor';
    expect(entries.singleWhere((row) => row[2] == w4BettorTask), [
      'world_4',
      'call_price',
      w4BettorTask,
      'drill',
      'practice',
      [
        ['bb', 'Your seat', false, 'wrong', 'Cutoff'],
        ['btn', 'Button', false, 'wrong', 'Cutoff'],
        ['co', 'Cutoff', true, 'correct', 'Cutoff'],
      ],
    ]);
    const w5Additions = {
      'board_texture_basics_w5_texture_dry_value': (
        'board_texture_basics',
        [
          ['check', 'Check', false, 'wrong', 'Bet 2 BB'],
          ['two', 'Bet 2 BB', true, 'correct', 'Bet 2 BB'],
          ['six', 'Bet 6 BB', false, 'wrong', 'Bet 2 BB'],
        ],
      ),
      'board_texture_basics_w5_texture_wet_showdown': (
        'board_texture_basics',
        [
          ['small', 'Bet 2 BB', false, 'wrong', 'Check'],
          ['large', 'Bet 6 BB', false, 'wrong', 'Check'],
          ['check', 'Check', true, 'correct', 'Check'],
        ],
      ),
      'connected_boards_w5_connected_read_bet': (
        'connected_boards',
        [
          ['fold', 'Fold', true, 'correct', 'Fold'],
          ['call', 'Call', false, 'wrong', 'Fold'],
          ['raise', 'Raise', false, 'wrong', 'Fold'],
        ],
      ),
    };
    for (final entry in w5Additions.entries) {
      expect(entries.singleWhere((row) => row[2] == entry.key), [
        'world_5',
        entry.value.$1,
        entry.key,
        'drill',
        'practice',
        entry.value.$2,
      ], reason: entry.key);
    }
    const w8Additions = {
      'w8_hero_stack_cap_seat': [
        'world_8',
        'effective_stack_basics',
        'w8_hero_stack_cap_seat',
        'drill',
        'practice',
        [
          ['hj', 'Hijack', true, 'correct', 'Hijack'],
          ['sb', 'Small blind', false, 'wrong', 'Hijack'],
          ['bb', 'Big blind', false, 'wrong', 'Hijack'],
        ],
      ],
      'w8_pot_bet_committed_seat': [
        'world_8',
        'same_hand_different_depth',
        'w8_pot_bet_committed_seat',
        'drill',
        'practice',
        [
          ['co', 'Cutoff', false, 'wrong', 'Big blind'],
          ['bb', 'Big blind', true, 'correct', 'Big blind'],
          ['sb', 'Small blind', false, 'wrong', 'Big blind'],
        ],
      ],
      'w8_effective_stack_seat': [
        'world_8',
        'effective_stack_basics',
        'w8_effective_stack_seat',
        'drill',
        'practice',
        [
          ['co', 'Your seat', false, 'wrong', 'Big blind'],
          ['bb', 'Big blind', true, 'correct', 'Big blind'],
          ['sb', 'Small blind', false, 'wrong', 'Big blind'],
        ],
      ],
      'w8_spr_value_size': [
        'world_8',
        'spr_and_commitment',
        'w8_spr_value_size',
        'drill',
        'practice',
        [
          ['two', '2 BB', false, 'suboptimal', '4 BB'],
          ['four', '4 BB', true, 'correct', '4 BB'],
          ['eight', '8 BB', false, 'wrong', '4 BB'],
        ],
      ],
    };
    for (final addition in w8Additions.entries) {
      expect(
        entries.singleWhere((row) => row[2] == addition.key),
        addition.value,
      );
    }
    for (final entry in w11Wave4ChoiceContractV1.entries) {
      final task = entries.singleWhere((row) => row[2] == entry.key);
      expect(task, [
        'world_11',
        entry.value.$1,
        entry.key,
        'drill',
        'practice',
        entry.value.$2,
      ], reason: entry.key);
    }
    for (final entry in w12Wave4ChoiceContractV1.entries) {
      final task = entries.singleWhere((row) => row[2] == entry.key);
      expect(task, [
        'world_12',
        entry.value.$1,
        entry.key,
        'drill',
        'practice',
        entry.value.$2,
      ], reason: entry.key);
    }
    // Compare the new W9 identities separately. Reconstruct the old view for
    // the earlier frozen hashes so those hashes still witness their own source.
    expect(
      sha256
          .convert(
            utf8.encode(
              jsonEncode(entries.where((row) => row[0] == 'world_9').toList()),
            ),
          )
          .toString(),
      '45bbd95d0a3e80dc5a8a2c6374444eb84f04c97f4c1eb9bb9c3287e34ae4478e',
    );
    final preAtlasW9 =
        jsonDecode(
              File(
                'test/fixtures/act0_w9_pre_atlas_identity_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    // Compare the new W10 identities separately. Reconstruct the earlier
    // frozen view from its own task and choice records.
    expect(
      sha256
          .convert(
            utf8.encode(
              jsonEncode(entries.where((row) => row[0] == 'world_10').toList()),
            ),
          )
          .toString(),
      '473edd7ace18f2b8ff5af25c786324cb5555cdfb73a2a095d3574b58577c0e08',
    );
    final preAtlasW10 =
        jsonDecode(
              File(
                'test/fixtures/act0_w10_pre_atlas_identity_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final comparisonEntries = [
      ...entries.where((row) => !{'world_9', 'world_10'}.contains(row[0])),
      ...(preAtlasW9['identity'] as List).cast<List<Object?>>(),
      ...(preAtlasW10['identity'] as List).cast<List<Object?>>(),
    ]..sort((a, b) => (a[2] as String).compareTo(b[2] as String));
    final legacyEntries = comparisonEntries
        .where(
          (row) =>
              !_asm05NewTaskIds.contains(row[2]) &&
              !w11Wave4ChoiceContractV1.containsKey(row[2]) &&
              !w12Wave4ChoiceContractV1.containsKey(row[2]) &&
              !w7AppliedTaskIdsV1.contains(row[2]) &&
              !w4MinRaiseTaskIdsV1.contains(row[2]) &&
              !w2Q9ChoiceContractV1.containsKey(row[2]) &&
              !w3NewChoiceContractV1.containsKey(row[2]) &&
              !w6NewChoiceContractV1.containsKey(row[2]) &&
              !w1Additions.containsKey(row[2]) &&
              row[2] != w4BettorTask &&
              !w5Additions.containsKey(row[2]) &&
              !w8Additions.containsKey(row[2]) &&
              !w4SeatAdditions.containsKey(row[2]) &&
              row[2] != boardRepair,
        )
        .toList(growable: false);
    expect(legacyEntries, hasLength(367));
    final encoded = jsonEncode(legacyEntries);
    final fingerprint = sha256.convert(utf8.encode(encoded)).toString();
    // PR460 admits the MAIN01 quality pair; the owner-admitted PR475 correction
    // adds exactly three theory option contracts. Freeze actual semantics, then
    // reconstruct both historical comparison stages without rewriting evidence.
    const acceptedCurrentFingerprint =
        '89c0097554f2fdb7d3054d551df7c71c65bf8fcd5d08fb77258f8e44cea8c4c0';
    const acceptedMain01Fingerprint =
        'e06d7556a9dde9fd1197f7b9584233f1e583ddf08e4bca81ddaac9551783615f';
    const acceptedMainFingerprint =
        '26c8c2d76a89ba00adfb482b2130e758f7b8e32699ef85f75e15abf189e57bb4';
    print('ASM01_SOURCE_FINGERPRINT=$fingerprint');
    // Exact W24 context-answer evolution reproduced by the Dart census.
    // Keep every prior whole-source pin in the historical reconstruction.
    const currentW24ContextFingerprint =
        'da8c4dc65ebc99979b01b3eb1c6e16d92626b95b4fbc4d4eb5df15d8585ff4c7';
    const currentExplicitW01ContextFingerprint =
        '32e9e58b4821edec4c04239e417ddce1e6acf8257d0f844a0deba67dc834f44b';
    // Reverse approved learner-facing label edits for the historical identity
    // comparison. IDs, correctness and grades are compared as authored.
    const priorCopyLabels = <String, String>{
      'Mostly all-in now': 'Mostly jam now',
      'Mostly all-in or fold only': 'Mostly shove-or-fold only',
      'Use all-in-or-fold logic': 'Use shove logic',
      'Take a reasonable all-in spot, first in or over a raise':
          'Take a reasonable jam or reshove spot',
      'Still take practical all-in spots before blinded out':
          'Still take practical jam spots before blinded out',
      'Value-bet your strongest hands and check the rest':
          'Only shove strong hands',
      'Go all-in with wide hands without checking position':
          'Jam any two cards every hand',
      'Go all-in to deny equity': 'Jam to deny equity',
      'You have top pair. An opponent could be drawing to a flush':
          'Hero already has top pair, and the heart draw is still only pressure',
      'You already have a flush': 'The heart draw is already a made flush',
      'A possible flush draw cancels your pair':
          'The draw matters, so the pair does not count yet',
      'A-K has more combos': 'A-K appears more often',
      'Pocket eights have more combos': 'Pocket eights appear more often',
      'They have the same combo count': 'They appear equally often',
      'They have the same weight': 'They appear equally often',
      'You win the pot right away': 'You win the pot automatically',
      'Nothing counts until all stacks are equal':
          'Nothing counts until every stack is equal',
      'The button wins right away': 'The button wins automatically',
      'CO acts last before and after the flop':
          'CO already acts last every street',
      'Late seat makes most hands easy': 'Late seat makes every hand easy',
      'You have a flush draw, not a made flush yet':
          'Hero has a flush draw, not a made flush yet',
      'You already have a made flush': 'Hero already has a made flush',
      'It turns into value right away': 'It becomes value automatically',
      'The bucket stays fixed after the flop':
          'The bucket never changes after flop',
      'Keep betting across streets': 'Keep betting on every street',
      'The paired board leaves seven-containing combinations unchanged.':
          'The paired board leaves every seven-containing combination available.',
      'Fold playable all-in hands to try to ladder into the money':
          'Fold every hand until payouts begin',
      'Plan to fold borderline hands like A-J against the covering blind':
          'Over-fold every close hand',
      'Fold borderline hands like A-J by default against a big-stack open':
          'Fold every hand until payout',
      'Map pressure, then copy broad player reads':
          'Map pressure, then copy every player read',
      'Keep default play until blinds show it again':
          'Keep baseline until blinds show it again',
      'Push top pair into a huge pot immediately':
          'Make every top pair hand huge immediately',
      'Call normal standard frequency': 'Call normal baseline frequency',
      'Change open sizings across early and late seats':
          'Change every sizing in all positions',
      'Flat-call wider from early and middle seats':
          'Flat-call more in every seat',
      'Overhaul your three-street calling plan right away':
          'Hard-counter every future street now',
      'Structured adjustment before live play':
          'Structured exploit before transfer',
      'Use table feel without a written routine':
          'Use table feel without a written loop',
      'Stay standard until another table cue confirms it':
          'Stay baseline until another table cue confirms it',
      'Narrow to one session goal next time':
          'Narrow to one transfer goal next session',
      'Track all leaks from the start': 'Track every leak from the start',
      'If an opponent underbluffs, fold marginal bluff-catchers':
          'If villain underbluffs, fold marginal bluff-catchers',
      'Study another concept before applying it':
          'Study another concept before looping it',
      'A repeatable daily practice cycle': 'A repeatable daily transfer loop',
      'Stick to process and your planned line':
          'Stick to process and planned exploit line',
      'Call down anyway with top pair': 'Hero-call top pair',
      'Fold all close spots now': 'Fold every close spot now',
      'Read your two cards and act right away': 'Only your hand matters first',
      'Check your two cards and skip the board': 'Only your cards matter',
      'The rank value': 'Rank only',
      'The suit symbol': 'Suit only',
      'The two private cards at your seat': 'Your cards only',
      'BTN, SB, and BB': 'BTN, SB, BB only',
      'Focus on bet size before checking the third heart':
          'Only the bet size matters now',
      'A board must pair before matching-rank combinations drop.':
          'Only a paired board can change how many matching-rank combinations remain.',
      'Fold even premium hands until payouts begin':
          'Avoid all risk until paid',
      'Wait for AA or KK before entering a pot': 'Wait only for premium pairs',
      'Wait for a big pocket pair like AA or KK':
          'Wait for perfect premium only',
      'Go all-in with the next playable hand right away':
          'Force any spot immediately',
      'Go all-in with 7-2 offsuit over a tight early-position raise and a call':
          'Panic with any two cards now',
      'Fold until you pick up pocket aces': 'Wait only for aces',
      'Adjust by player type and ignore stack pressure':
          'Adjust only by player type',
      'Stick to default chart lines and ignore the table cue':
          'Ignore all reads forever',
      'Play the next session without a focus target':
          'Avoid setting any goal again',
      'Wait to adjust until post-session review':
          'Save the adjustment for review only',
      'Tackle both leaks together in the next session':
          'Fix all leaks at once tomorrow',
      'Leave the river leak unwritten and move on':
          'Do not set any repair task',
      'Skip the cue check and move to the next hand':
          'Move on after a quick note only',
      'Call with the same routine': 'Call with the same loop',
      'A repeatable process-reset-discipline cycle':
          'A repeatable process-reset-discipline loop',
    };
    // Reverse only reviewed P1 identity deltas for the historical comparison.
    const priorL1Options = {
      'first_table_guide_one_clear_choice': [
        [
          "co_still_acting",
          "CO/cutoff already folded, so You at BTN act next",
          false,
          "suboptimal",
          "You are BTN, blinds are posted, and no board is out yet",
        ],
        [
          "hero_btn_preflop_setup",
          "You are BTN, blinds are posted, and no board is out yet",
          true,
          "correct",
          "You are BTN, blinds are posted, and no board is out yet",
        ],
        [
          "hero_has_no_cards",
          "Blinds are posted, but You at BTN have no cards",
          false,
          "wrong",
          "You are BTN, blinds are posted, and no board is out yet",
        ],
      ],
      'what_poker_is_win_ways': [
        ["largest_stack", "Largest stack", false, "wrong", "Everyone folds"],
        [
          "best_hand_showdown",
          "Best hand at showdown",
          false,
          "suboptimal",
          "Everyone folds",
        ],
        ["everyone_folds", "Everyone folds", true, "correct", "Everyone folds"],
      ],
      'what_poker_is_review': [
        [
          "largest_stack",
          "The largest stack still held by a player",
          false,
          "wrong",
          "Chips already committed to the middle",
        ],
        [
          "everyone_folds",
          "Everyone folds before showdown",
          false,
          "wrong",
          "Chips already committed to the middle",
        ],
        [
          "pot_committed_chips",
          "Chips already committed to the middle",
          true,
          "correct",
          "Chips already committed to the middle",
        ],
      ],
      'hand_rankings_royal_flush_drill': [
        ["royal_flush", "Royal flush", true, "correct", "Royal flush"],
        ["ace_high_flush", "Ace-high flush", false, "wrong", "Royal flush"],
      ],
      'weak_ace_warning_weak_ace_kicker_compare': [
        [
          "two_big_cards_auto",
          "Two broadway cards always continue after an open",
          false,
          "wrong",
          "It keeps position and avoids weak-ace domination",
        ],
        [
          "less_dominated",
          "It keeps position and avoids weak-ace domination",
          true,
          "correct",
          "It keeps position and avoids weak-ace domination",
        ],
      ],
      'button_advantage_button_vs_cutoff': [
        ["utg", "UTG", false, "wrong", "BTN"],
        ["btn", "BTN", true, "correct", "BTN"],
      ],
      'same_hand_different_seat_w3_same_hand_intro': [
        ["utg", "UTG", false, "wrong", "BTN"],
        ["btn", "BTN", true, "correct", "BTN"],
      ],
      'same_hand_different_seat_w3_same_hand_call': [
        ["fold", "Fold", false, "wrong", "Call"],
        ["call", "Call", true, "correct", "Call"],
      ],
      'w4_cheap_price_marginal_call': [
        ["fold", "Fold", false, "wrong", "Call"],
        ["raise", "Raise", false, "suboptimal", "Call"],
        ["call", "Call", true, "correct", "Call"],
      ],
      'w4_big_price_marginal_fold': [
        ["call", "Call", false, "wrong", "Fold"],
        ["raise", "Raise", false, "wrong", "Fold"],
        ["fold", "Fold", true, "correct", "Fold"],
      ],
      'w4_checkpoint_table_price': [
        ["fold", "Fold", false, "wrong", "Call"],
        ["raise", "Raise", false, "suboptimal", "Call"],
        ["call", "Call", true, "correct", "Call"],
      ],
    };
    // Reconstruct only the W1/W2 lesson moves and copy edits from P3.
    const priorL1LessonIds = {
      'hand_rankings_best_five_drill': 'hand_rankings_table',
      'hand_rankings_flush_drill': 'hand_rankings_table',
      'hand_rankings_full_house_drill': 'hand_rankings_table',
      'hand_rankings_full_house_vs_flush_drill': 'hand_rankings_table',
      'hand_rankings_quads_drill': 'hand_rankings_table',
      'hand_rankings_quads_vs_full_house_drill': 'hand_rankings_table',
      'hand_rankings_review': 'hand_rankings_table',
      'hand_rankings_royal_flush_drill': 'hand_rankings_table',
      'hand_rankings_royal_vs_flush_drill': 'hand_rankings_table',
      'hand_rankings_straight_drill': 'hand_rankings_table',
      'positions_button': 'positions',
      'positions_cutoff': 'positions',
      'positions_theory': 'positions',
      'positions_utg': 'positions',
      'showdown_kicker_drill': 'showdown_winning',
    };
    const priorL1TeachingOptions = {
      'what_poker_is_theory': [
        ["top", "UTG", false, "wrong", "BTN (your seat)"],
        ["random", "BB", false, "wrong", "BTN (your seat)"],
        ["bottom", "BTN (your seat)", true, "correct", "BTN (your seat)"],
      ],
      'what_poker_is_find_hero': [
        ["top", "You", false, "wrong", "BTN"],
        ["bottom", "BTN", true, "correct", "BTN"],
        ["random", "Your private cards", false, "wrong", "BTN"],
      ],
      'first_table_guide_one_clear_choice': [
        [
          "co_still_acting",
          "CO still has to act before you at BTN",
          false,
          "suboptimal",
          "You are BTN, blinds are posted, and no board is out yet",
        ],
        [
          "hero_btn_preflop_setup",
          "You are BTN, blinds are posted, and no board is out yet",
          true,
          "correct",
          "You are BTN, blinds are posted, and no board is out yet",
        ],
        [
          "hero_has_no_cards",
          "Blinds are posted, but You at BTN have no cards",
          false,
          "wrong",
          "You are BTN, blinds are posted, and no board is out yet",
        ],
      ],
      'your_first_hand_showdown': [
        ["first_actor", "First actor", false, "wrong", "Best hand"],
        [
          "hero_cards_only",
          "Hero cards only",
          false,
          "suboptimal",
          "Best hand",
        ],
        ["best_hand", "Best hand", true, "correct", "Best hand"],
      ],
      'hand_rankings_theory': [
        ["hand_strength", "Hand strength", true, "correct", "Hand strength"],
        ["seat_position", "Seat position", false, "wrong", "Hand strength"],
      ],
      'hand_rankings_full_house_vs_flush_drill': [
        ["co_flush", "CO flush", false, "wrong", "Hero full house"],
        [
          "hero_full_house",
          "Hero full house",
          true,
          "correct",
          "Hero full house",
        ],
      ],
      'hand_rankings_quads_vs_full_house_drill': [
        [
          "hero_quads",
          "Hero four of a kind",
          true,
          "correct",
          "Hero four of a kind",
        ],
        [
          "co_full_house",
          "CO full house",
          false,
          "wrong",
          "Hero four of a kind",
        ],
      ],
      'hand_rankings_royal_vs_flush_drill': [
        [
          "co_ace_high_flush",
          "CO ace-high flush",
          false,
          "wrong",
          "Hero royal flush",
        ],
        [
          "hero_royal_flush",
          "Hero royal flush",
          true,
          "correct",
          "Hero royal flush",
        ],
      ],
      'hand_discipline_buckets_medium': [
        ["strong", "Strong", false, "wrong", "Medium"],
        ["trash", "Trash", false, "wrong", "Medium"],
        ["medium", "Medium", true, "correct", "Medium"],
      ],
      'hand_discipline_buckets_trash': [
        ["strong", "Strong", false, "wrong", "Trash"],
        ["trash", "Trash", true, "correct", "Trash"],
      ],
      'hand_discipline_buckets_borderline': [
        ["strong", "Strong", false, "suboptimal", "Medium"],
        ["medium", "Medium", true, "correct", "Medium"],
        ["trash", "Trash", false, "wrong", "Medium"],
      ],
      'discipline_checkpoint_checkpoint_table_discipline': [
        [
          "trash_fold",
          "Trash bucket, clean fold",
          true,
          "correct",
          "Trash bucket, clean fold",
        ],
        [
          "looks_fun_open",
          "Open too loose",
          false,
          "wrong",
          "Trash bucket, clean fold",
        ],
        [
          "maybe_limp",
          "Limp the trash hand",
          false,
          "suboptimal",
          "Trash bucket, clean fold",
        ],
      ],
    };
    // Reconstruct the reviewed P4 choice labels and two mechanical grades.
    const priorL1PrechoiceOptions = {
      'first_table_guide_one_clear_choice': [
        [
          "co_still_acting",
          "Two private cards and three shared cards",
          false,
          "suboptimal",
          "Two private cards and no shared cards",
        ],
        [
          "hero_btn_preflop_setup",
          "Two private cards and no shared cards",
          true,
          "correct",
          "Two private cards and no shared cards",
        ],
        [
          "hero_has_no_cards",
          "No private cards and no shared cards",
          false,
          "wrong",
          "Two private cards and no shared cards",
        ],
      ],
      'showdown_kicker_drill': [
        ["kicker", "Kicker", true, "correct", "Kicker"],
        ["seat", "Seat name", false, "wrong", "Kicker"],
      ],
      'positions_theory': [
        ["top", "UTG", false, "wrong", "BTN (your seat)"],
        ["random", "BB", false, "wrong", "BTN (your seat)"],
        ["bottom", "BTN (your seat)", true, "correct", "BTN (your seat)"],
      ],
      'actions_theory': [
        ["raise", "Raise", true, "correct", "Raise"],
        ["fold", "Fold", false, "wrong", "Raise"],
        ["call", "Call", false, "suboptimal", "Raise"],
      ],
      'actions_raise_drill': [
        ["fold", "Fold", false, "wrong", "Raise"],
        ["call", "Call", false, "suboptimal", "Raise"],
        ["raise", "Raise", true, "correct", "Raise"],
      ],
      'actions_review': [
        ["raise", "Raise", true, "correct", "Raise"],
        ["fold", "Fold", false, "wrong", "Raise"],
        ["call", "Call", false, "suboptimal", "Raise"],
      ],
      'button_advantage_button_recap': [
        ["top", "UTG", false, "wrong", "BTN (your seat)"],
        ["bottom", "BTN (your seat)", true, "correct", "BTN (your seat)"],
        ["random", "BB", false, "wrong", "BTN (your seat)"],
      ],
      'early_vs_late_w2_position_recap': [
        ["top", "UTG", false, "wrong", "BTN (your seat)"],
        ["bottom", "BTN (your seat)", true, "correct", "BTN (your seat)"],
        ["random", "BB", false, "wrong", "BTN (your seat)"],
      ],
      'w4_value_purpose': [
        ["bluff", "Bluff", false, "wrong", "Value"],
        ["value", "Value", true, "correct", "Value"],
      ],
      'w4_bluff_purpose': [
        ["value", "Value", false, "wrong", "Bluff"],
        ["bluff", "Bluff", true, "correct", "Bluff"],
      ],
      'w4_checkpoint_value': [
        ["bluff", "Bluff", false, "wrong", "Value"],
        ["value", "Value", true, "correct", "Value"],
      ],
      'w4_checkpoint_table_purpose_price': [
        [
          "small_value_price",
          "Small value bet that sets a cheap continue price",
          true,
          "correct",
          "Small value bet that sets a cheap continue price",
        ],
        [
          "pot_bluff",
          "Pot-size bluff trying to force folds",
          false,
          "wrong",
          "Small value bet that sets a cheap continue price",
        ],
        [
          "random_size",
          "Random bet with no clear job",
          false,
          "suboptimal",
          "Small value bet that sets a cheap continue price",
        ],
      ],
    };
    const priorL1CheckpointOptions = {
      "showdown_best_hand_drill": [
        ["first_actor", "First actor", false, "wrong", "Best hand"],
        [
          "hero_cards_only",
          "Hero cards only",
          false,
          "suboptimal",
          "Best hand",
        ],
        ["best_hand", "Best hand", true, "correct", "Best hand"],
      ],
      "showdown_review": [
        ["best_hand", "Best hand", true, "correct", "Best hand"],
        ["first_actor", "First actor", false, "wrong", "Best hand"],
        [
          "hero_cards_only",
          "Hero cards only",
          false,
          "suboptimal",
          "Best hand",
        ],
      ],
      "w4_checkpoint_value": [
        ["bluff", "A-K", false, "wrong", "A-J"],
        ["value", "A-J", true, "correct", "A-J"],
      ],
      "w4_checkpoint_price": [
        ["call", "Call", false, "wrong", "Fold"],
        ["fold", "Fold", true, "correct", "Fold"],
      ],
    };
    const priorL1LanguageOptions = {
      "hand_rankings_full_house_vs_flush_drill": [
        ["co_flush", "Other player: flush", false, "wrong", "Hero full house"],
        [
          "hero_full_house",
          "Hero full house",
          true,
          "correct",
          "Hero full house",
        ],
      ],
      "hand_rankings_quads_vs_full_house_drill": [
        [
          "hero_quads",
          "Hero four of a kind",
          true,
          "correct",
          "Hero four of a kind",
        ],
        [
          "co_full_house",
          "Other player: full house",
          false,
          "wrong",
          "Hero four of a kind",
        ],
      ],
      "hand_rankings_royal_vs_flush_drill": [
        [
          "co_ace_high_flush",
          "Other player: ace-high flush",
          false,
          "wrong",
          "Hero royal flush",
        ],
        [
          "hero_royal_flush",
          "Hero royal flush",
          true,
          "correct",
          "Hero royal flush",
        ],
      ],
      "what_poker_is_all_in_meaning": [
        [
          "automatic_win",
          "Hero wins the pot automatically",
          false,
          "wrong",
          "Hero put in all remaining chips",
        ],
        [
          "all_remaining_committed",
          "Hero put in all remaining chips",
          true,
          "correct",
          "Hero put in all remaining chips",
        ],
        [
          "largest_stack_only",
          "Only the bigger stack matters now",
          false,
          "suboptimal",
          "Hero put in all remaining chips",
        ],
      ],
      "what_poker_is_showdown_win": [
        ["first_actor", "First actor", false, "wrong", "Best hand"],
        [
          "hero_cards_only",
          "Hero cards only",
          false,
          "suboptimal",
          "Best hand",
        ],
        ["best_hand", "Best hand", true, "correct", "Best hand"],
      ],
      "what_poker_is_live_win_transfer": [
        [
          "fold_or_showdown",
          "A fold or a showdown",
          true,
          "correct",
          "A fold or a showdown",
        ],
        [
          "button_wins_now",
          "The button wins automatically",
          false,
          "wrong",
          "A fold or a showdown",
        ],
        [
          "hero_cards_decide_now",
          "Hero cards decide it immediately",
          false,
          "suboptimal",
          "A fold or a showdown",
        ],
      ],
    };
    final beforeL1 = jsonDecode(encoded) as List<dynamic>;
    final beforeP8 = {
      for (final row in beforeL1.cast<List<dynamic>>())
        row[2] as String: (row[5] as List).cast<List<dynamic>>(),
    };
    for (final entry in [
      ...w11Wave4GradeCorrectionsV1.entries,
      ...w12Wave4GradeCorrectionsV1.entries,
    ]) {
      final option = beforeP8[entry.key]!.singleWhere(
        (row) => row[0] == entry.value,
      );
      expect(option[2], isFalse, reason: entry.key);
      expect(option[3], 'wrong', reason: entry.key);
      option[3] = 'suboptimal';
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
      final option = beforeP8[entry.key]!.singleWhere(
        (row) => row[0] == entry.value,
      );
      expect(option[2], isFalse, reason: entry.key);
      expect(option[3], 'wrong', reason: entry.key);
      option[3] = 'suboptimal';
    }
    final strongQJs = beforeP8['hand_discipline_buckets_borderline']!
        .singleWhere((row) => row[0] == 'strong');
    expect(strongQJs[2], isFalse);
    expect(strongQJs[3], 'wrong');
    strongQJs[3] = 'suboptimal';
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
      final option = beforeP8[taskId]!.singleWhere((row) => row[0] == optionId);
      expect(option[2], isFalse);
      expect(option[3], 'wrong', reason: '$taskId / $optionId');
      option[3] = 'suboptimal';
    }
    for (final (taskId, choiceId) in [
      ('w9_survival_stack_tradeoff', 'same_both'),
      ('w9_checkpoint_zone_line', 'same_zone'),
    ]) {
      final choice = beforeP8[taskId]!.singleWhere((row) => row[0] == choiceId);
      expect(choice[2], isFalse, reason: taskId);
      expect(choice[3], 'wrong', reason: taskId);
      choice[3] = 'suboptimal';
    }
    for (final taskId in [
      'your_first_hand_showdown',
      'showdown_best_hand_drill',
    ]) {
      final wrong = beforeP8[taskId]!.singleWhere(
        (row) => row[0] == 'hero_cards_only',
      );
      expect(wrong[2], isFalse);
      expect(wrong[3], 'wrong');
      wrong[3] = 'suboptimal';
    }
    final bestFive = beforeP8['hand_rankings_best_five_drill']!;
    expect(bestFive, [
      ['five', 'Four', true, 'correct', 'Four'],
      ['seven', 'Jack', false, 'wrong', 'Four'],
    ]);
    bestFive[0][1] = 'Five';
    bestFive[0][4] = 'Five';
    bestFive[1][1] = 'Seven';
    bestFive[1][4] = 'Five';
    final trips = beforeP8['hand_rankings_trips_drill']!;
    final threeOfAKind = trips.singleWhere((row) => row[0] == 'trips');
    expect(threeOfAKind[1], 'Three of a kind');
    threeOfAKind[1] = 'Trips';
    for (final choice in trips) {
      expect(choice[4], 'Three of a kind');
      choice[4] = 'Trips';
    }
    final fullHouseTrips = beforeP8['hand_rankings_full_house_drill']!
        .singleWhere((choice) => choice[0] == 'trips');
    expect(fullHouseTrips[1], 'Three of a kind');
    fullHouseTrips[1] = 'Trips';
    final stack = beforeP8['what_poker_is_matched_chips_transfer']!.singleWhere(
      (row) => row[0] == 'entire_covering_stack',
    );
    expect(stack[1], "The other player's whole 100 BB stack");
    stack[1] = 'All 100 BB from the covering stack';
    const pressureLabels = {
      'Check': 'Missed',
      'Bet half pot as a bluff': 'Bluff candidate',
      'Bet half pot for value': 'Value',
    };
    const l2AssessmentLabels = {
      'w6_missed_dry_board': pressureLabels,
      'w6_bluff_candidate': pressureLabels,
      'range_checkpoint_pressure': pressureLabels,
      'w6_turn_pressure_shift_transfer': {'Check': 'Check more often'},
      'w6_value_range_action': {'Check': 'Check and see'},
      'w6_table_value_line_transfer': {'Check': 'Check back'},
      'w7_20bb_wider': {
        'Bet 2 BB': '20 BB',
        'Bet 4 BB': '100 BB',
        'Go all-in': 'Same either way',
      },
      'w7_40bb_middle': {
        '25 BB': 'Some room, but not carefree deep',
        '40 BB': 'Mostly all-in or fold only',
        '30 BB': 'It plays just like 100 BB deep',
      },
      'w7_100bb_tighter': {
        '75 BB': 'More room and more risk',
        '90 BB': 'Less risk than 20 BB',
        '100 BB': 'Mostly all-in now',
      },
      'w7_ajs_btn_25bb_transfer': {
        'Raise to 7.5 BB': 'Use the short-stack read',
        'Call 2.5 BB': 'Treat depth as irrelevant',
        'Go all-in for 25 BB': 'Treat it as too fragile',
      },
      'w7_ajs_btn_100bb_transfer': {
        'Call 2.5 BB': 'Treat it as deeper',
        'Raise to 7.5 BB': 'Treat it like 25 BB',
        'Go all-in for 100 BB': 'Use all-in-or-fold logic',
      },
    };
    const l2CheckpointOptionDeltas = {
      'straight_draws_w5_gutshot_contrast_transfer': (
        [
          [
            "gutshot",
            "Gutshot straight draw",
            false,
            "suboptimal",
            "Open-ended straight draw",
          ],
          [
            "open_ended",
            "Open-ended straight draw",
            true,
            "correct",
            "Open-ended straight draw",
          ],
          [
            "made_straight",
            "Made straight",
            false,
            "wrong",
            "Open-ended straight draw",
          ],
        ],
        [
          [
            "gutshot",
            "Gutshot straight draw",
            true,
            "correct",
            "Gutshot straight draw",
          ],
          [
            "open_ended",
            "Open-ended straight draw",
            false,
            "suboptimal",
            "Gutshot straight draw",
          ],
          [
            "made_straight",
            "Made straight",
            false,
            "wrong",
            "Gutshot straight draw",
          ],
        ],
      ),
      'turn_river_changes_w5_turn_texture_shift_transfer': (
        [
          [
            "nothing_changed",
            "Nothing changed, so keep the same easy plan",
            false,
            "wrong",
            "An opponent can now have a flush",
          ],
          [
            "board_got_wetter",
            "An opponent can now have a flush",
            true,
            "correct",
            "An opponent can now have a flush",
          ],
          [
            "size_only_changed",
            "Focus on bet size before checking the third heart",
            false,
            "suboptimal",
            "An opponent can now have a flush",
          ],
        ],
        [
          [
            "nothing_changed",
            "Nothing changed, so keep the same easy plan",
            false,
            "wrong",
            "The board got wetter and more connected",
          ],
          [
            "board_got_wetter",
            "The board got wetter and more connected",
            true,
            "correct",
            "The board got wetter and more connected",
          ],
          [
            "size_only_changed",
            "Focus on bet size before checking the third heart",
            false,
            "suboptimal",
            "The board got wetter and more connected",
          ],
        ],
      ),
      'turn_river_changes_w5_river_draw_story_transfer': (
        [
          [
            "river_restarts_story",
            "The river starts a new story from zero",
            false,
            "wrong",
            "The river missed the straight draw",
          ],
          [
            "draw_hit_anyway",
            "The draw probably got there anyway",
            false,
            "suboptimal",
            "The river missed the straight draw",
          ],
          [
            "draw_missed_story",
            "The river missed the straight draw",
            true,
            "correct",
            "The river missed the straight draw",
          ],
        ],
        [
          [
            "river_restarts_story",
            "The river starts a new story from zero",
            false,
            "wrong",
            "The same draw story missed",
          ],
          [
            "draw_hit_anyway",
            "The draw probably got there anyway",
            false,
            "suboptimal",
            "The same draw story missed",
          ],
          [
            "draw_missed_story",
            "The same draw story missed",
            true,
            "correct",
            "The same draw story missed",
          ],
        ],
      ),
      'w6_wet_board_repair': (
        [
          [
            "nothing_changed",
            "Make the same bluff again",
            false,
            "wrong",
            "Check instead of betting again",
          ],
          [
            "respect_wetter_board",
            "Check instead of betting again",
            true,
            "correct",
            "Check instead of betting again",
          ],
          [
            "smaller_same_story",
            "Bet smaller but keep the same dry-board story",
            false,
            "suboptimal",
            "Check instead of betting again",
          ],
        ],
        [
          [
            "nothing_changed",
            "Nothing changed, keep the same dry-board plan",
            false,
            "wrong",
            "The board got wetter, so the old thin-value plan needs caution",
          ],
          [
            "respect_wetter_board",
            "The board got wetter, so the old thin-value plan needs caution",
            true,
            "correct",
            "The board got wetter, so the old thin-value plan needs caution",
          ],
          [
            "smaller_same_story",
            "Bet smaller but keep the same dry-board story",
            false,
            "suboptimal",
            "The board got wetter, so the old thin-value plan needs caution",
          ],
        ],
      ),
      'range_checkpoint_value': (
        [
          [
            "value",
            "Bet half pot for value",
            true,
            "correct",
            "Bet half pot for value",
          ],
          [
            "bluff",
            "Bet half pot as a bluff",
            false,
            "suboptimal",
            "Bet half pot for value",
          ],
          ["missed", "Check", false, "wrong", "Bet half pot for value"],
        ],
        [
          ["value", "Value", true, "correct", "Value"],
          ["bluff", "Bluff candidate", false, "wrong", "Value"],
          ["missed", "Missed", false, "wrong", "Value"],
        ],
      ),
      'range_checkpoint_board_fit': (
        [
          ["missed", "Ace-high", true, "correct", "Ace-high"],
          ["bluff", "One pair", false, "suboptimal", "Ace-high"],
          ["value", "A made straight", false, "wrong", "Ace-high"],
        ],
        [
          ["missed", "Missed", true, "correct", "Missed"],
          ["bluff", "Bluff candidate", false, "suboptimal", "Missed"],
          ["value", "Value", false, "wrong", "Missed"],
        ],
      ),
      'range_checkpoint_combos': (
        [
          ["twelve", "12", false, "wrong", "16"],
          ["six", "6", false, "wrong", "16"],
          ["sixteen", "16", true, "correct", "16"],
        ],
        [
          ["twelve", "12 combos", false, "suboptimal", "16 combos"],
          ["six", "6 combos", false, "wrong", "16 combos"],
          ["sixteen", "16 combos", true, "correct", "16 combos"],
        ],
      ),
      'w6_kicker_showdown_compare': (
        [
          ["hero_ak", "9-8 and 6-5", true, "correct", "9-8 and 6-5"],
          ["villain_kq", "A-K and Q-J", false, "wrong", "9-8 and 6-5"],
          ["tie", "9-9 and 6-6", false, "wrong", "9-8 and 6-5"],
        ],
        [
          ["hero_ak", "Hero A-K", true, "correct", "Hero A-K"],
          ["villain_kq", "Villain K-Q", false, "wrong", "Hero A-K"],
          ["tie", "Tie", false, "suboptimal", "Hero A-K"],
        ],
      ),
      'w6_board_pair_strength_compare': (
        [
          ["hero_aj", "BTN, the raiser", false, "suboptimal", "BB, the caller"],
          ["villain_k8", "BB, the caller", true, "correct", "BB, the caller"],
          [
            "tie",
            "They have the same number",
            false,
            "wrong",
            "BB, the caller",
          ],
        ],
        [
          ["hero_aj", "Hero A-J", false, "suboptimal", "Villain K-8"],
          ["villain_k8", "Villain K-8", true, "correct", "Villain K-8"],
          ["tie", "Tie", false, "wrong", "Villain K-8"],
        ],
      ),
      'w6_checkpoint_table_best_five': (
        [
          ["hero_wins", "A-T suited", false, "wrong", "Pocket sevens"],
          ["split", "Pocket sevens", true, "correct", "Pocket sevens"],
          [
            "villain_wins",
            "They have the same count",
            false,
            "wrong",
            "Pocket sevens",
          ],
        ],
        [
          ["hero_wins", "Hero wins with aces", false, "wrong", "Split the pot"],
          [
            "villain_wins",
            "Villain wins with kings",
            false,
            "suboptimal",
            "Split the pot",
          ],
          ["split", "Split the pot", true, "correct", "Split the pot"],
        ],
      ),
      'range_checkpoint_review': (
        [
          [
            "range_plus_stack_depth",
            "One ace is already on the board",
            true,
            "correct",
            "One ace is already on the board",
          ],
          [
            "range_plus_pot_size",
            "The pot is 5.5 BB",
            false,
            "suboptimal",
            "One ace is already on the board",
          ],
          [
            "range_only",
            "BTN has the dealer marker",
            false,
            "wrong",
            "One ace is already on the board",
          ],
        ],
        [
          [
            "range_plus_stack_depth",
            "Range plus stack depth",
            true,
            "correct",
            "Range plus stack depth",
          ],
          [
            "range_plus_pot_size",
            "Range plus pot size",
            false,
            "suboptimal",
            "Range plus stack depth",
          ],
          [
            "range_only",
            "Range plus board texture only",
            false,
            "wrong",
            "Range plus stack depth",
          ],
        ],
      ),
      'visible_card_combo_reduction_recap': (
        [
          ["only_board_low_cards_matter", "16", false, "wrong", "12"],
          ["visible_cards_show_exact_hand", "6", false, "wrong", "12"],
          [
            "visible_rank_reduces_matching_rank_combos",
            "12",
            true,
            "correct",
            "12",
          ],
        ],
        [
          [
            "only_board_low_cards_matter",
            "A board must pair before matching-rank combinations drop.",
            false,
            "wrong",
            "Fewer queen-containing combinations remain; no exact hand is proved.",
          ],
          [
            "visible_cards_show_exact_hand",
            "The visible queens prove the opponent’s exact hand.",
            false,
            "wrong",
            "Fewer queen-containing combinations remain; no exact hand is proved.",
          ],
          [
            "visible_rank_reduces_matching_rank_combos",
            "Fewer queen-containing combinations remain; no exact hand is proved.",
            true,
            "correct",
            "Fewer queen-containing combinations remain; no exact hand is proved.",
          ],
        ],
      ),
      'what_poker_is_side_pot_intro': (
        [
          ["hero_main_only", "20 BB", true, "correct", "20 BB"],
          ["hero_wins_everything", "50 BB", false, "wrong", "20 BB"],
          ["side_pot_is_penalty", "30 BB", false, "suboptimal", "20 BB"],
        ],
        [
          [
            "hero_main_only",
            "Hero can win the main pot, but not the side pot",
            true,
            "correct",
            "Hero can win the main pot, but not the side pot",
          ],
          [
            "hero_wins_everything",
            "Hero can win every chip once all-in",
            false,
            "wrong",
            "Hero can win the main pot, but not the side pot",
          ],
          [
            "side_pot_is_penalty",
            "The side pot is a penalty for the short stack",
            false,
            "suboptimal",
            "Hero can win the main pot, but not the side pot",
          ],
        ],
      ),
      'w7_6max_wider': (
        [
          ["fullring", "Fold", false, "wrong", "Raise to 2.5 BB"],
          ["same", "Raise to 8 BB", false, "suboptimal", "Raise to 2.5 BB"],
          ["6max", "Raise to 2.5 BB", true, "correct", "Raise to 2.5 BB"],
        ],
        [
          ["fullring", "Full ring", false, "wrong", "6-max"],
          ["same", "Same in both", false, "suboptimal", "6-max"],
          ["6max", "6-max", true, "correct", "6-max"],
        ],
      ),
      'w7_fullring_tighter': (
        [
          ["tighter", "Fold", true, "correct", "Fold"],
          ["wider", "Raise to 2.5 BB", false, "wrong", "Fold"],
          ["depth", "Raise to 8 BB", false, "suboptimal", "Fold"],
        ],
        [
          ["tighter", "Open fewer hands", true, "correct", "Open fewer hands"],
          ["wider", "Open more hands", false, "wrong", "Open fewer hands"],
          [
            "depth",
            "Only stack depth matters",
            false,
            "suboptimal",
            "Open fewer hands",
          ],
        ],
      ),
      'w7_format_table_notice': (
        [
          ["open_same", "Bet 10 BB", false, "wrong", "Bet 6 BB"],
          ["depth_only", "Bet 12 BB", false, "wrong", "Bet 6 BB"],
          ["tighten_early", "Bet 6 BB", true, "correct", "Bet 6 BB"],
        ],
        [
          [
            "open_same",
            "Open just as wide as 6-max",
            false,
            "wrong",
            "Count more players behind and tighten early opens a bit",
          ],
          [
            "depth_only",
            "Only watch stack depth, not player count",
            false,
            "suboptimal",
            "Count more players behind and tighten early opens a bit",
          ],
          [
            "tighten_early",
            "Count more players behind and tighten early opens a bit",
            true,
            "correct",
            "Count more players behind and tighten early opens a bit",
          ],
        ],
      ),
      'w7_stack_checkpoint': (
        [
          ["range_only", "About 5.4", false, "suboptimal", "4"],
          ["range_plus_depth", "4", true, "correct", "4"],
          ["chips_only", "32", false, "wrong", "4"],
        ],
        [
          [
            "range_only",
            "Range only",
            false,
            "suboptimal",
            "Range plus stack risk",
          ],
          [
            "range_plus_depth",
            "Range plus stack risk",
            true,
            "correct",
            "Range plus stack risk",
          ],
          [
            "chips_only",
            "Range plus raw chip count",
            false,
            "wrong",
            "Range plus stack risk",
          ],
        ],
      ),
    };
    const l2OptionDeltas = {
      'outs_improvement_w5_table_outs_flush_transfer': (
        [
          ["price_only", "Fold", false, "wrong", "Call 2 BB"],
          ["heart_outs", "Call 2 BB", true, "correct", "Call 2 BB"],
        ],
        [
          [
            "ace_only",
            "Only an ace matters now",
            false,
            "wrong",
            "Any heart still completes the flush",
          ],
          [
            "heart_outs",
            "Any heart still completes the flush",
            true,
            "correct",
            "Any heart still completes the flush",
          ],
          [
            "price_only",
            "Only the small price matters",
            false,
            "suboptimal",
            "Any heart still completes the flush",
          ],
        ],
      ),
      'outs_improvement_w5_table_outs_straight_transfer': (
        [
          ["four_or_nine", "Fold", true, "correct", "Fold"],
          ["blank_turn_killed", "Call 3 BB", false, "wrong", "Fold"],
        ],
        [
          [
            "king_pairs",
            "Only a king can help now",
            false,
            "wrong",
            "A 4 or 9 still completes the straight",
          ],
          [
            "blank_turn_killed",
            "Blank turn means give up",
            false,
            "suboptimal",
            "A 4 or 9 still completes the straight",
          ],
          [
            "four_or_nine",
            "A 4 or 9 still completes the straight",
            true,
            "correct",
            "A 4 or 9 still completes the straight",
          ],
        ],
      ),
      'turn_river_changes_w5_board_checkpoint': (
        [
          ["just_outs", "Fold", false, "wrong", "Call 1 BB"],
          ["texture_draw_outs", "Call 1 BB", true, "correct", "Call 1 BB"],
        ],
        [
          [
            "just_outs",
            "Just count outs",
            false,
            "suboptimal",
            "Texture, draw, outs",
          ],
          [
            "random_guess",
            "Random guess",
            false,
            "wrong",
            "Texture, draw, outs",
          ],
          [
            "texture_draw_outs",
            "Texture, draw, outs",
            true,
            "correct",
            "Texture, draw, outs",
          ],
        ],
      ),
      'w6_value_wet_board': (
        [
          ["bluff", "BTN, the raiser", false, "wrong", "BB, the caller"],
          ["value", "BB, the caller", true, "correct", "BB, the caller"],
          [
            "missed",
            "They have the same number",
            false,
            "wrong",
            "BB, the caller",
          ],
        ],
        [
          ["value", "Value", true, "correct", "Value"],
          ["bluff", "Bluff candidate", false, "wrong", "Value"],
          ["missed", "Missed", false, "wrong", "Value"],
        ],
      ),
      'w6_board_fit_recap': (
        [
          ["caller", "BB, the caller", false, "wrong", "BTN, the raiser"],
          [
            "same",
            "They have the same number",
            false,
            "wrong",
            "BTN, the raiser",
          ],
          ["raiser", "BTN, the raiser", true, "correct", "BTN, the raiser"],
        ],
        [],
      ),
      'w6_value_range_action': (
        [
          ['check', 'Check and see', false, 'suboptimal', 'Bet for value'],
          ['bet_bluff', 'Bet as a bluff', false, 'wrong', 'Bet for value'],
          ['bet', 'Bet for value', true, 'correct', 'Bet for value'],
        ],
        [
          ['check', 'Check and see', false, 'suboptimal', 'Bet for value'],
          ['fold', 'Fold', false, 'wrong', 'Bet for value'],
          ['bet', 'Bet for value', true, 'correct', 'Bet for value'],
        ],
      ),
      'w7_fullring_tighter': (
        [
          ['tighter', 'Open fewer hands', true, 'correct', 'Open fewer hands'],
          ['wider', 'Open more hands', false, 'wrong', 'Open fewer hands'],
          [
            'depth',
            'Only stack depth matters',
            false,
            'suboptimal',
            'Open fewer hands',
          ],
        ],
        [
          ['tighter', 'Range tightens', true, 'correct', 'Range tightens'],
          ['wider', 'Range widens more', false, 'wrong', 'Range tightens'],
          [
            'depth',
            'Only stack depth matters',
            false,
            'suboptimal',
            'Range tightens',
          ],
        ],
      ),
    };
    const l2FactualGradeCorrections = {
      'w6_ak_combos': 'twelve',
      'w6_pair_combos': 'twelve',
      'w6_combo_weight_compare': 'same_weight',
    };
    const l2PlainLanguage = {
      'w6_missed_hand_action': (
        'Keep betting across streets',
        'Always barrel as pressure',
      ),
      'w6_turn_pressure_shift_transfer': ('Bet big again', 'Barrel big again'),
      'w7_low_spr_commit': (
        'Plenty of chips left for later bets',
        'Plenty of room to float and wait',
      ),
      'w7_high_spr_room': (
        'More options for later bets',
        'More room to maneuver',
      ),
    };
    for (final row in beforeL1.cast<List<dynamic>>()) {
      row[1] = priorL1LessonIds[row[2]] ?? row[1];
      final currentOptions = (row[5] as List).cast<List<dynamic>>();
      final revisedChoiceId =
          l2FactualGradeCorrections[row[2]] ??
          fixedDrawRangeAndStackChoicesV1[row[2]];
      if (revisedChoiceId case final choiceId?) {
        final choice = currentOptions.singleWhere(
          (option) => option[0] == choiceId,
        );
        expect(choice[3], 'wrong', reason: row[2] as String);
        choice[3] = 'suboptimal';
      }
      if (l2PlainLanguage[row[2]] case (final current, final prior)) {
        expect(currentOptions.any((option) => option[1] == current), isTrue);
        for (final option in currentOptions) {
          if (option[1] == current) option[1] = prior;
          if (option[4] == current) option[4] = prior;
        }
      }
      if (l2CheckpointOptionDeltas[row[2]] case (final current, final prior)) {
        expect(row[5], current, reason: row[2] as String);
        row[5] = prior;
      }
      final assessmentLabels = l2AssessmentLabels[row[2]];
      if (assessmentLabels != null) {
        final choices = (row[5] as List).cast<List<dynamic>>();
        expect(
          choices.map((choice) => choice[1]),
          containsAll(assessmentLabels.keys),
          reason: row[2] as String,
        );
        for (final choice in choices) {
          choice[1] = assessmentLabels[choice[1]] ?? choice[1];
          choice[4] = assessmentLabels[choice[4]] ?? choice[4];
        }
      }
      if (l2OptionDeltas[row[2]] case (final current, final prior)) {
        expect(row[5], current, reason: row[2] as String);
        row[5] = prior;
      }
      final options =
          priorL1Options[row[2]] ??
          priorL1TeachingOptions[row[2]] ??
          priorL1PrechoiceOptions[row[2]] ??
          priorL1CheckpointOptions[row[2]] ??
          priorL1LanguageOptions[row[2]];
      if (options != null) row[5] = options;
    }
    var beforeCopyEdits = jsonEncode(beforeL1);
    for (final e in priorCopyLabels.entries) {
      beforeCopyEdits = beforeCopyEdits.replaceAll(
        jsonEncode(e.key),
        jsonEncode(e.value),
      );
    }
    expect(fingerprint, isNot(currentExplicitW01ContextFingerprint));
    expect(
      sha256.convert(utf8.encode(beforeCopyEdits)).toString(),
      currentExplicitW01ContextFingerprint,
    );
    final historicalComparison = jsonDecode(beforeCopyEdits) as List<dynamic>;
    final position = historicalComparison.cast<List<dynamic>>().singleWhere(
      (row) => row[2] == 'positions_review',
    );
    expect(position, <Object?>[
      'world_1',
      'positions',
      'positions_review',
      'review',
      'proveIt',
      <Object?>[
        <Object?>['top', 'UTG', false, 'wrong', 'BTN'],
        <Object?>['random', 'BB', false, 'wrong', 'BTN'],
        <Object?>['bottom', 'BTN', true, 'correct', 'BTN'],
      ],
    ]);
    position[5] = <Object?>[
      <Object?>['top', 'UTG', false, 'wrong', 'BTN (your seat)'],
      <Object?>['random', 'BB', false, 'wrong', 'BTN (your seat)'],
      <Object?>[
        'bottom',
        'BTN (your seat)',
        true,
        'correct',
        'BTN (your seat)',
      ],
    ];
    expect(
      sha256.convert(utf8.encode(jsonEncode(historicalComparison))).toString(),
      currentW24ContextFingerprint,
      reason:
          'Only the reviewed positions_review BTN display/preferred labels are reversed; IDs and grades remain exact.',
    );
    final context = historicalComparison.cast<List<dynamic>>().singleWhere(
      (row) => row[2] == 'same_hand_different_seat_w3_same_hand_recap',
    );
    expect(context, <Object?>[
      'world_3',
      'same_hand_different_seat',
      'same_hand_different_seat_w3_same_hand_recap',
      'review',
      'review',
      <Object?>[
        <Object?>[
          'one_answer',
          'One answer per hand',
          false,
          'wrong',
          'Bucket, seat, frame',
        ],
        <Object?>[
          'framework',
          'Bucket, seat, frame',
          true,
          'correct',
          'Bucket, seat, frame',
        ],
      ],
    ]);
    context[5] = <Object?>[
      <Object?>['utg', 'UTG', false, 'wrong', 'BTN'],
      <Object?>['btn', 'BTN', true, 'correct', 'BTN'],
    ];
    expect(
      sha256.convert(utf8.encode(jsonEncode(historicalComparison))).toString(),
      acceptedCurrentFingerprint,
      reason: 'Only the exact reviewed W24 context choice tuple is reversed.',
    );
    // Freeze the full current rows before reconstructing only the reviewed
    // old comparison tuples. This does not migrate saved learner records.
    const reviewedW01TheoryRows = {
      'blinds_theory': [
        'world_1',
        'blinds_action_order',
        'blinds_theory',
        'theory',
        'learn',
        [
          ['button_is_not_a_blind', 'BTN', false, 'wrong', 'BB'],
          ['bb', 'BB', true, 'correct', 'BB'],
          ['sb', 'SB', false, 'wrong', 'BB'],
        ],
      ],
      'cards_ranks_suits_theory': [
        'world_1',
        'cards_ranks_suits',
        'cards_ranks_suits_theory',
        'theory',
        'learn',
        [
          ['rank_only', 'Rank only', false, 'wrong', 'Rank and suit'],
          ['rank_and_suit', 'Rank and suit', true, 'correct', 'Rank and suit'],
          ['suit_only', 'Suit only', false, 'wrong', 'Rank and suit'],
        ],
      ],
      'hand_rankings_theory': [
        'world_1',
        'hand_rankings_table',
        'hand_rankings_theory',
        'theory',
        'learn',
        [
          ['hand_strength', 'Hand strength', true, 'correct', 'Hand strength'],
          ['seat_position', 'Seat position', false, 'wrong', 'Hand strength'],
        ],
      ],
    };
    const historicalW01TheoryOptions = {
      'blinds_theory': [
        ['top', 'UTG', false, 'wrong', 'BTN (your seat)'],
        ['bottom', 'BTN (your seat)', true, 'correct', 'BTN (your seat)'],
        ['random', 'BB', false, 'wrong', 'BTN (your seat)'],
      ],
      'cards_ranks_suits_theory': [
        ['king', 'King', false, 'wrong', 'Ace'],
        ['ace', 'Ace', true, 'correct', 'Ace'],
        ['suit', 'Suit decides', false, 'wrong', 'Ace'],
      ],
      'hand_rankings_theory': [
        ['pair', 'Pair', true, 'correct', 'Pair'],
        ['high_card', 'High card', false, 'wrong', 'Pair'],
      ],
    };
    for (final entry in reviewedW01TheoryRows.entries) {
      final row = historicalComparison.cast<List<dynamic>>().singleWhere(
        (row) => row[2] == entry.key,
      );
      expect(
        row,
        entry.value,
        reason: 'Exact reviewed W01 identity: ${entry.key}',
      );
      expect(row[5], hasLength(historicalW01TheoryOptions[entry.key]!.length));
      row[5] = historicalW01TheoryOptions[entry.key];
    }
    expect(
      sha256.convert(utf8.encode(jsonEncode(historicalComparison))).toString(),
      acceptedMain01Fingerprint,
      reason:
          'Only the three reviewed theory option tuples differ from MAIN01.',
    );
    final setup = historicalComparison.cast<List<dynamic>>().singleWhere(
      (row) => row[2] == 'first_table_guide_one_clear_choice',
    );
    final setupOptions = (setup[5] as List<dynamic>).cast<List<dynamic>>();
    for (final (id, current, prior) in <(String, String, String)>[
      ('co_still_acting', 'suboptimal', 'wrong'),
      ('hero_has_no_cards', 'wrong', 'suboptimal'),
    ]) {
      final option = setupOptions.singleWhere((option) => option[0] == id);
      expect(option[3], current, reason: 'Exact reviewed MAIN01 grade: $id');
      option[3] = prior;
    }
    final historicalEncoded = jsonEncode(historicalComparison);
    expect(
      sha256.convert(utf8.encode(historicalEncoded)).toString(),
      acceptedMainFingerprint,
      reason: 'Every other legacy identity and grading field stays frozen.',
    );
    final tampered = jsonDecode(historicalEncoded) as List<dynamic>;
    final withChoice = tampered.cast<List<dynamic>>().firstWhere(
      (row) => (row[5] as List<dynamic>).isNotEmpty,
    );
    ((withChoice[5] as List<dynamic>).first as List<dynamic>)[0] =
        'renamed_choice_invalidates_history';
    expect(
      sha256.convert(utf8.encode(jsonEncode(tampered))).toString(),
      isNot(acceptedMainFingerprint),
      reason: 'A source choice rename must invalidate the accepted snapshot.',
    );
  });

  test('source-owned choice identities survive legacy persisted evidence', () {
    final taskIndex = <String, (String, String, Act0LessonTaskV1)>{
      for (final world in Act0ShellStateV1.sample.worlds)
        for (final lesson in world.lessons)
          for (final task in lesson.taskList)
            task.taskId: (world.worldId, lesson.lessonId, task),
    };
    expect(
      taskIndex,
      hasLength(
        435 + w11Wave4ChoiceContractV1.length + w12Wave4ChoiceContractV1.length,
      ),
    );
    var validated = 0;
    for (final entry in taskIndex.entries) {
      final (worldId, lessonId, task) = entry.value;
      final choices = task.runner.options;
      if (choices.isEmpty) continue;
      final expected = choices.where((choice) => choice.isCorrect).toList();
      expect(expected, isNotEmpty, reason: entry.key);
      for (final choice in choices) {
        final evidence = Act0LearningEvidenceRecordV1(
          recordId: 'legacy:$worldId:$lessonId:${task.taskId}:${choice.id}',
          createdOrder: validated,
          worldId: worldId,
          lessonId: lessonId,
          taskId: task.taskId,
          choiceId: choice.id,
          expectedChoiceId: expected.first.id,
          isCorrect: choice.isCorrect,
          errorType: choice.isCorrect ? 'none' : 'missed_action_read',
          repairFocusId: '',
          skillAtomId: task.taskId,
          decisionTimeBucket: '3_to_10s',
          resultKind: choice.isCorrect ? 'correct' : 'incorrect',
        );
        final restored = Act0LearningEvidenceRecordV1.tryParse(
          evidence.toPayload(),
        );
        expect(restored, evidence, reason: evidence.recordId);
        expect(restored!.taskId, task.taskId);
        expect(restored.choiceId, choice.id);
        expect(restored.expectedChoiceId, expected.first.id);
        expect(restored.isCorrect, choice.isCorrect);
        validated++;
      }
    }
    print('ASM01_EVIDENCE_ROUNDTRIPS=$validated');
    expect(validated, greaterThan(500));
    // A renamed task/choice is not silently mapped to a different skill.
    final first = taskIndex.values.first.$3;
    expect(taskIndex.containsKey('${first.taskId}_renamed'), isFalse);
    expect(
      first.runner.options.any(
        (choice) => choice.id == 'nonexistent_choice_migration',
      ),
      isFalse,
    );
  });

  test('accepted-main legacy payload retains exact source meaning', () {
    // Literal v1 fixture frozen from accepted-main 130a1da4 source test
    // test/ui_v2/act0_learning_evidence_contract_v1_test.dart, combined
    // with that commit's Act0LearningEvidenceRecordV1.toPayload fields.
    // It was NOT generated by this candidate's toPayload and does NOT
    // represent a real user's persisted record.
    const acceptedMainPayload = <String, Object?>{
      'schemaVersion': 1,
      'recordId': '1:world_1:actions_legal_context:fold',
      'createdOrder': 1,
      'worldId': 'world_1',
      'lessonId': 'fold_check_call_raise',
      'taskId': 'actions_legal_context',
      'choiceId': 'fold',
      'expectedChoiceId': 'check',
      'isCorrect': false,
      'errorType': 'missed_action_read',
      'conceptFamilyId': '',
      'repairFocusId': 'no_bet_yet',
      'skillAtomId': 'action_read',
      'decisionTimeBucket': '3_to_10s',
      'resultKind': 'incorrect',
    };
    final restored = Act0LearningEvidenceRecordV1.tryParse(acceptedMainPayload);
    expect(restored, isNotNull);
    expect(restored!.toPayload(), acceptedMainPayload);
    final world = Act0ShellStateV1.sample.worlds.singleWhere(
      (world) => world.worldId == restored.worldId,
    );
    final lesson = world.lessons.singleWhere(
      (lesson) => lesson.lessonId == restored.lessonId,
    );
    final task = lesson.taskList.singleWhere(
      (task) => task.taskId == restored.taskId,
    );
    final selected = task.runner.options.singleWhere(
      (choice) => choice.id == restored.choiceId,
    );
    final originalExpected = task.runner.options.singleWhere(
      (choice) => choice.id == restored.expectedChoiceId,
    );
    expect(selected.isCorrect, isFalse);
    expect(originalExpected.isCorrect, isTrue);
    expect(restored.errorType, 'missed_action_read');
    expect(restored.repairFocusId, 'no_bet_yet');
    // A differently named source choice cannot match this old record.
    expect(
      task.runner.options.any(
        (choice) => choice.id == 'fold_renamed_during_patch',
      ),
      isFalse,
    );
  });
}
