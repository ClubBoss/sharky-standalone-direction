import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _asm05NewTaskIds = <String>{
  'asm05_new_known_holes_turn_call_10',
  'asm05_new_known_holes_turn_call_40',
};

/// Assessment identity and grading consistency for all 369 W1-W12 tasks.
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
    expect(tasks, hasLength(370));
    expect(tasks.map((t) => t.taskId).toSet(), hasLength(370));
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
    expect(entries, hasLength(370));
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
    final legacyEntries = entries
        .where(
          (row) => !_asm05NewTaskIds.contains(row[2]) && row[2] != boardRepair,
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
      'Only go all-in with strong hands': 'Only shove strong hands',
      'Go all-in with any two cards every hand': 'Jam any two cards every hand',
      'Go all-in to deny equity': 'Jam to deny equity',
      'Hero has top pair. An opponent could be drawing to a flush':
          'Hero already has top pair, and the heart draw is still only pressure',
      'Hero already has a flush': 'The heart draw is already a made flush',
      'A possible flush draw cancels Hero’s pair':
          'The draw matters, so the pair does not count yet',
      'A-K has more combos': 'A-K appears more often',
      'Pocket eights have more combos': 'Pocket eights appear more often',
      'They have the same combo count': 'They appear equally often',
      'They have the same weight': 'They appear equally often',
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
      'Missed: check': 'Missed',
      'Consider a bluff': 'Bluff candidate',
      'Value: bet': 'Value',
    };
    const l2AssessmentLabels = {
      'w6_missed_dry_board': pressureLabels,
      'w6_bluff_candidate': pressureLabels,
      'range_checkpoint_pressure': pressureLabels,
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
    for (final row in beforeL1.cast<List<dynamic>>()) {
      row[1] = priorL1LessonIds[row[2]] ?? row[1];
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
    expect(taskIndex, hasLength(370));
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
