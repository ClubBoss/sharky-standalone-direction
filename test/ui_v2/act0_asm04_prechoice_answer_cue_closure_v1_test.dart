import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_predecision_card_focus_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_prechoice_answer_cue_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// ASM-04 catalog-wide pre-choice closure (2026-11-08).
//
// The detector below is test-only and may read grades; production policy
// never does. It renders the real Learn (Academy) and Runner consumers for
// every assessed task, before any choice, with assistance off, and asks
// whether any visible string (other than the choice buttons themselves)
// names the correct choice without naming a wrong one, or states that the
// correct choice beats/wins. Every remaining hit is an exact, reasoned
// allowance: a table fact the question needs, or the question restating its
// own target. Allowances may shrink, never grow.

final _catalog = [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList)
        (world: world, lesson: lesson, task: task),
];

final _assessed = [
  for (final row in _catalog)
    if (act0IsPrechoiceAssessmentTaskV1(row.task)) row,
];

const _seatWords = <String>{
  'hero',
  'villain',
  'co',
  'btn',
  'utg',
  'hj',
  'sb',
  'bb',
  'you',
  'your',
  'cutoff',
  'button',
  'seat',
};
const _stopWords = <String>{
  'a',
  'an',
  'the',
  'to',
  'of',
  'and',
  'or',
  'is',
  'it',
  'in',
  'on',
  'at',
  'for',
  'with',
  'this',
  'that',
  'be',
  'by',
  'as',
  'are',
};

String _norm(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String _core(String label) => _norm(label)
    .split(' ')
    .where((w) => w.isNotEmpty && !_seatWords.contains(w))
    .where((w) => !_stopWords.contains(w))
    .join(' ');

bool _hasPhrase(String text, String phrase) =>
    phrase.isNotEmpty &&
    RegExp('(^| )${RegExp.escape(phrase)}( |\$)').hasMatch(_norm(text));

/// Visible strings that disclose the correct choice before the decision.
List<String> _answerCues(Iterable<String> visible, Act0RunnerStateV1 runner) {
  final labels = {for (final o in runner.options) o.label};
  final correct = [
    for (final o in runner.options)
      if (o.isCorrect) _core(o.label),
  ];
  final wrong = [
    for (final o in runner.options)
      if (!o.isCorrect) _core(o.label),
  ];
  final hits = <String>[];
  for (final text in visible) {
    if (text.trim().isEmpty || labels.contains(text)) continue;
    final namesCorrect = correct.any((c) => _hasPhrase(text, c));
    final namesWrong = wrong.any((w) => _hasPhrase(text, w));
    final verdict = correct.any(
      (c) =>
          c.isNotEmpty &&
          RegExp(
            '(^| )${RegExp.escape(c)}s? (beats?|wins?|ranks? higher|is stronger)',
          ).hasMatch(_norm(text)),
    );
    if ((namesCorrect && !namesWrong) || verdict) hits.add(text);
  }
  return hits;
}

// Adjudicated pre-choice leaks, pinned here with the exact authored text
// (independent of the production policy sets): removing a policy entry, or
// an authored text drifting, fails this test instead of passing silently.
const _pinnedTitleLeaks = <String, String>{
  'actions_call_drill': 'Call a price',
  'actions_check_drill': 'Check when no bet',
  'actions_fold_drill': 'Fold weak hands',
  'actions_raise_drill': 'Raise on the Button',
  'apply_btn_open': 'BTN, strong hand',
  'apply_hj_decision': 'HJ, medium hand',
  'apply_utg_fold': 'UTG, trash hand',
  'board_texture_basics_w5_dry_board': 'Dry board',
  'board_texture_basics_w5_wet_board': 'Wet board',
  'button_advantage_button_open': 'BTN first-in open',
  'button_advantage_button_vs_cutoff': 'BTN vs CO',
  'button_advantage_position_repair_btn_last_postflop':
      'Repair BTN last postflop',
  'cards_ranks_suits_best_five': 'Best five idea',
  'connected_boards_w5_connected_board': 'Connected board',
  'connected_boards_w5_disconnected_board': 'Disconnected board',
  'continue_or_let_go_continue_recap': 'Continue recap',
  'continue_or_let_go_medium_open': 'Medium hand opens',
  'continue_or_let_go_premium_continue': 'Premium continue',
  'continue_or_let_go_weak_let_go': 'Weak let go',
  'discipline_checkpoint_checkpoint_borderline_continue': 'Borderline continue',
  'discipline_checkpoint_checkpoint_fold': 'Disciplined fold',
  'discipline_checkpoint_checkpoint_premium': 'Premium hand',
  'flush_draws_w5_flush_draw_find': 'Find flush draw',
  'flush_draws_w5_no_flush_draw': 'No flush draw',
  'fold_discipline_discipline_stack_protect': 'Protect stack',
  'fold_discipline_early_fold': 'Early weak hand',
  'outs_improvement_w5_table_outs_flush_transfer': 'Live heart outs',
  'outs_improvement_w5_table_outs_straight_transfer': 'Live straight outs',
  'position_apply_btn_open': 'BTN: open strong hand',
  'position_apply_early_fold': 'Early: same hand folds',
  'position_apply_hj_fold': 'HJ: discipline hold',
  'position_checkpoint_position_checkpoint_btn_call': 'BTN: callable spot',
  'position_checkpoint_position_checkpoint_early_fold':
      'Early: same hand folds',
  'range_checkpoint_pressure': 'Bluff candidate',
  'range_checkpoint_value': 'Value on dry board',
  'same_hand_different_seat_same_hand_early_fold': 'Early seat fold',
  'same_hand_different_seat_same_hand_late_open': 'Late seat open',
  'same_hand_different_seat_w3_same_hand_call': 'Call frame',
  'same_hand_different_seat_w3_same_hand_open': 'Open frame',
  'showdown_best_hand_drill': 'Best hand at showdown',
  'showdown_kicker_drill': 'Same pair, better kicker',
  'straight_draws_w5_gap_board': 'Gap board',
  'straight_draws_w5_gutshot_draw': 'Gutshot draw',
  'straight_draws_w5_straight_draw_find': 'Find straight draw',
  'turn_river_changes_w5_river_draw_story_transfer':
      'River keeps the draw story honest',
  'turn_river_changes_w5_river_misses': 'River misses',
  'turn_river_changes_w5_turn_hits': 'Turn hits',
  'turn_river_changes_w5_turn_texture_shift_transfer':
      'Turn changes the texture',
  'w10_checkpoint_lever_line': 'One-lever exploit line',
  'w10_checkpoint_tag_line': 'Tag then act',
  'w10_guardrail_sample_size': 'Respect sample size',
  'w10_loose_passive_tag': 'Loose-passive profile',
  'w10_nit_tag': 'Nit profile',
  'w10_overaggressive_tag': 'Over-aggressive profile',
  'w10_overbluff_punish': 'Punish overbluffs',
  'w10_table_value_vs_caller_transfer': 'Value shift at the table',
  'w10_underbluff_fold_more': 'Fold more vs underbluffs',
  'w10_vs_caller_value_heavier': 'Value heavier vs callers',
  'w10_vs_nit_open_wider': 'Steal more vs tight folds',
  'w10_vs_sticky_defender_tighten_steals': 'Tighten steals vs sticky defenders',
  'w11_checkpoint_review_line': 'Review line',
  'w11_plan_avoid_overload': 'Avoid overload plan',
  'w11_plan_focus_choice': 'Choose one focus',
  'w11_review_pick_leak': 'Pick priority leak',
  'w11_trigger_small_price_continue': 'Small-price continue',
  'w12_assertive_not_ego': 'Assertive, not ego',
  'w12_bad_call_good_result': 'Bad call, lucky win',
  'w12_checkpoint_process_line': 'Process line',
  'w12_checkpoint_reset_line': 'Reset line',
  'w12_good_fold_bad_result': 'Good fold, bad result',
  'w12_pretty_hand_bad_price_fold': 'Pretty hand, bad price',
  'w4_bad_bluff': 'Bad pressure',
  'w4_big_price_marginal_fold': 'Big price, thinner hand',
  'w4_bluff_pressure': 'Apply pressure',
  'w4_bluff_purpose': 'Bluff reason',
  'w4_cheap_price_marginal_call': 'Cheap call with middle pair',
  'w4_checkpoint_review': 'Price recap',
  'w4_protection_check': 'Free card risk',
  'w4_value_bet': 'Bet top pair',
  'w4_value_missed': 'Do not hide value',
  'w4_value_purpose': 'Value reason',
  'w6_bluff_candidate': 'Bluff candidate',
  'w6_board_pair_strength_compare': 'Paired board changes the winner',
  'w6_kicker_showdown_compare': 'Same pair, better kicker',
  'w6_table_value_line_transfer': 'Live-table value line',
  'w6_value_dry_board': 'Value on dry board',
  'w6_value_range_action': 'Value bets',
  'w6_value_wet_board': 'Value on wet board',
  'w6_wrong_board': 'Missed on wet board',
  'w7_20bb_wider': '20 BB decision',
  'w7_6max_wider': '6-max opens wider',
  'w7_format_table_notice': 'Count players behind',
  'w7_fullring_tighter': 'Full ring tightens',
  'w9_big_stack_leverage': 'Big stack leverage',
  'w9_bubble_short_stack': 'Short stack urgency',
  'w9_checkpoint_bubble_line': 'Bubble risk premium line',
  'w9_checkpoint_zone_line': 'Urgency by zone',
  'w9_m_ratio_green_zone': 'Green zone patience',
  'w9_m_ratio_yellow_zone': 'Yellow zone planning',
  'w9_medium_stack_tighten': 'Medium stack discipline',
  'weak_ace_warning_w3_dominated_fold': 'Fold trouble',
  'weak_ace_warning_w3_strong_continue': 'Strong continue',
  'weak_ace_warning_weak_ace_pressure_fold': 'Pressure fold',
};
const _pinnedSummaryLeaks = <String, String>{
  'actions_call_drill': 'You face a small bet and want the cheapest continue.',
  'blinds_postflop_button': 'After the flop, Button often acts last.',
  'blinds_posts_drill': 'BB sets the 1 BB baseline for the hand.',
  'board_texture_basics_w5_dry_board':
      'K-7-2 rainbow is spread out and different suits.',
  'board_texture_basics_w5_wet_board':
      'T-9-8 with two hearts can change quickly.',
  'button_advantage_button_last': 'After the flop, Button often acts last.',
  'button_advantage_button_vs_cutoff':
      'CO is late, but BTN still acts after CO.',
  'button_advantage_position_repair_btn_last_postflop':
      'Repair: BTN acts last after the flop.',
  'cards_ranks_suits_best_five':
      'A poker hand uses the best five cards available.',
  'cards_ranks_suits_board_count': 'A full board has five shared cards.',
  'cards_ranks_suits_private_board':
      'Private cards belong to you. Board cards are shared.',
  'cards_ranks_suits_recap': 'Lesson learned: cards have a job.',
  'cards_ranks_suits_suit_drill':
      'Each card has a rank and a suit. Ah means ace of hearts.',
  'connected_boards_w5_connected_board': '9-8-7 is connected.',
  'connected_boards_w5_disconnected_board':
      'A-K-4 is high-card heavy but not connected.',
  'early_vs_late_early_pressure_choice':
      'UTG must act before HJ, CO, BTN, SB, and BB.',
  'early_vs_late_position_repair_utg_players_behind':
      'Repair: UTG has five players behind.',
  'flush_draws_w5_no_flush_draw':
      'Hero has mixed suits and the board is rainbow.',
  'outs_improvement_w5_flush_out': 'Hero needs one more heart.',
  'outs_improvement_w5_straight_out': 'With 6-5 on 8-7-2, a 4 or 9 helps.',
  'position_checkpoint_position_checkpoint_table_notice':
      'Real table. Hero is CO with QJs and three seats still act after.',
  'showdown_best_hand_drill': 'At showdown, the best hand wins the pot.',
  'showdown_board_plays_drill':
      'Sometimes the best five cards are all on the board.',
  'showdown_kicker_drill':
      'If both players share a pair, the side card can matter.',
  'showdown_tie_drill': 'A tie means the pot is split.',
  'straight_draws_w5_gap_board': 'A-Q-4 has large rank gaps.',
  'turn_river_changes_w5_river_draw_story_transfer':
      'Real table. The flop and turn showed a heart draw, but the river bricks with the black 3.',
  'turn_river_changes_w5_river_misses':
      'Different runout: the river is the 2 of diamonds. The heart draw misses.',
  'turn_river_changes_w5_street_repair':
      'The turn connected the board, but hero still treats one pair like the flop stayed easy.',
  'turn_river_changes_w5_turn_hits':
      'The turn brings a heart. The same flush story now completes.',
  'w4_bad_bluff': 'Villain called big already. Fold pressure is low.',
  'w4_bluff_pressure': 'Hero missed, but BB checked and can fold.',
  'w4_protection_bet':
      'Hero has top pair. Checking gives villain a free next card.',
  'w4_value_bet': 'Top pair on a safe flop. BB can call worse.',
  'w4_value_missed': 'Hero has top pair and worse hands can still call a bet.',
  'w6_value_range_action':
      'K-7-2 rainbow. Hero holds K-Q. You are in the value range.',
  'w6_wet_board_repair':
      'Suppose a turn makes a dry board wetter, but Hero keeps the old one-pair plan.',
  'w7_20bb_wider': 'You hold A-J suited with 20 BB effective.',
  'w9_survival_stack_tradeoff':
      'Cash table can reload. Tournament table cannot.',
  'what_poker_is_showdown_win': 'At showdown, the best hand wins the pot.',
  'what_poker_is_win_ways':
      'You win when others fold or when your hand wins showdown.',
  'your_first_hand_flop': 'The flop puts three shared cards in the middle.',
  'your_first_hand_river': 'The river is the fifth board card.',
  'your_first_hand_showdown': 'At showdown, the best hand wins the pot.',
  'your_first_hand_turn': 'The turn is the fourth board card.',
};
const _pinnedCueLeaks = <String, String>{
  'apply_btn_open': 'Strong late',
  'apply_recap': 'Weak ace',
  'apply_utg_fold': 'Trash early',
  'continue_or_let_go_medium_open': 'Medium, good seat',
  'discipline_checkpoint_checkpoint_borderline_continue': 'Playable broadway',
  'discipline_checkpoint_checkpoint_fold': 'Weak ace',
  'flush_draws_w5_flush_draw_recheck_transfer': 'Four hearts, not home yet',
  'flush_draws_w5_no_flush_draw': 'Rainbow flop',
  'fold_discipline_discipline_stack_protect': 'Weak ace',
  'fold_discipline_fold_recap': 'Weak ace',
  'hand_rankings_full_house_drill': 'A-A-A with 7-7',
  'hand_rankings_royal_flush_drill': 'A-K-Q-J-T hearts',
  'outs_improvement_w5_table_outs_flush_transfer': 'Live heart outs',
  'outs_improvement_w5_table_outs_straight_transfer': 'Live straight outs',
  'position_checkpoint_position_checkpoint_early_fold': 'UTG discipline',
  'position_checkpoint_position_checkpoint_table_notice':
      'CO with three seats behind',
  'showdown_best_hand_drill': 'Hero pair of queens beats CO pair of jacks',
  'showdown_review': 'Hero pair of queens beats CO pair of jacks',
  'straight_draws_w5_gap_board': 'Big gaps',
  'straight_draws_w5_gutshot_contrast_transfer': 'Only a 6 fits',
  'straight_draws_w5_straight_draw_find': '4 or 9 helps',
  'w11_trigger_small_price_continue': 'BTN, top pair, small price',
  'w12_checkpoint_full_loop_line': 'After mistake, stay clean',
  'w12_pretty_hand_bad_price_fold': 'Top pair, bad river price',
  'w12_revenge_raise_trap': 'Top pair, ego trap',
  'w4_bad_price_fold': 'High price',
  'w4_big_price_marginal_fold': 'Top pair, big price',
  'w4_cheap_price_marginal_call': 'Cheap price, middle pair',
  'w4_checkpoint_price': 'High price',
  'w4_good_price_call': 'Small price',
  'weak_ace_warning_w3_dominated_fold': 'Weak ace',
  'weak_ace_warning_w3_dominated_recap': 'Weak ace',
  'what_poker_is_all_in_meaning': 'All-in is all remaining chips',
  'what_poker_is_matched_chips_transfer': 'Matched chips set the contest',
  'what_poker_is_showdown_win': 'Hero pair of queens beats CO pair of jacks',
  'what_poker_is_side_pot_intro': 'Hero cannot win side pot',
  'your_first_hand_showdown': 'Hero pair of aces beats BB pair of jacks',
};
const _pinnedQuestionLeaks = <String, String>{
  'continue_or_let_go_continue_recap':
      'What is the cleaner continue with this playable hand facing an open?',
  'discipline_checkpoint_checkpoint_borderline_continue':
      'What is the simple continue?',
  'weak_ace_warning_w3_strong_continue': 'What is the simple continue?',
  'your_first_hand_recap': 'Which street comes after the turn?',
};

const _priceChip = 'Price chip: the same to-call fact shows for call and fold';

/// Exact remaining detector hits that are table facts the question needs.
const _allowedRunnerHits = <String, List<String>>{
  'your_first_hand_private_cards_recheck': ['K'],
  'actions_call_drill': ['To call 1 BB'],
  'weak_ace_warning_w3_strong_continue': ['To call 2.5 BB'],
  'continue_or_let_go_medium_call_or_fold': ['To call 2.5 BB'],
  'continue_or_let_go_continue_recap': ['To call 2.5 BB'],
  'discipline_checkpoint_checkpoint_borderline_continue': ['To call 2.5 BB'],
  'same_hand_different_seat_w3_same_hand_call': ['To call 2.5 BB'],
  'position_checkpoint_position_checkpoint_btn_call': ['To call 2.5 BB'],
  'w4_good_price_call': ['To call 1 BB'],
  'w4_cheap_price_marginal_call': ['To call 1 BB'],
  'w4_checkpoint_table_price': ['To call 2 BB'],
  'w6_kicker_showdown_compare': ['K'],
  'your_first_hand_recap': ['RIVER'],
};
const _allowedRunnerReasons = <String, String>{
  'your_first_hand_private_cards_recheck':
      'Hero card face the question asks to read',
  'w6_kicker_showdown_compare': 'Rank shared by both shown hands',
  'your_first_hand_recap': 'Table-read step: the shown river is the asked fact',
};

const _allowedLearnHits = <String, List<String>>{
  'w4_good_price_call': [
    'Call price',
    'Start here: Price decision 1. Pot is 8 BB. To call is 1 BB with one pair.',
  ],
  'w4_cheap_price_marginal_call': [
    'Call price',
    'Start here: Price decision 3. Pot is 10 BB. To call is 1 BB with middle pair.',
  ],
  'w4_small_bet': ['Current step · 2 of 5'],
  'w4_half_pot_bet': ['Current step · 3 of 5'],
  'w4_checkpoint_table_price': [
    'Start here: Real-table price read. Real table. Pot is 7 BB. To call is 2 BB. Hero has second pair.',
  ],
  'w7_effective_stack_100bb': ['100 vs 100'],
};
const _allowedLearnReasons = <String, String>{
  'w4_good_price_call':
      'Lesson topic also grades fold answers; pot/price facts',
  'w4_cheap_price_marginal_call':
      'Lesson topic also grades fold answers; pot/price facts',
  'w4_small_bet': 'Step counter digit, not copy',
  'w4_half_pot_bet': 'Step counter digit, not copy',
  'w4_checkpoint_table_price': 'Pot/price facts the question needs',
  'w7_effective_stack_100bb': 'Both stack sizes are the question input',
};

/// No open residuals: World 4 is displayed as 'Betting Decisions' (owner
/// decision), so its recap answer is no longer named by the world title.
const _openRunnerResiduals = <String, List<String>>{};
const _openLearnResiduals = <String, List<String>>{};

Widget _runnerFixture(
  ({dynamic world, dynamic lesson, Act0LessonTaskV1 task}) r,
) {
  final task = r.task;
  return MaterialApp(
    home: Scaffold(
      body: Act0LessonRunnerShellV1(
        runner: task.runner.copyWith(
          phase: task.entryPhase,
          teachingStepIndex: task.runner.teachingSteps.length,
        ),
        worldNumber: (r.world as Act0WorldCardV1).worldNumber,
        selectedWorldId: (r.world as Act0WorldCardV1).worldId,
        selectedLessonId: (r.lesson as Act0LessonCardV1).lessonId,
        selectedTaskId: task.taskId,
        // The production feed (preview screen `_localizedTaskTitleV1`).
        selectedTaskTitle: act0LocalizedTaskTitleAtomByIdV1(
          task.taskId,
          fallback: task.title,
        ),
        selectedTaskFamily: task.resolvedTaskFamily,
        compositionFamily: task.resolvedCompositionFamily,
        tablePresentation: task.tablePresentation,
        onBack: () {},
        onContinueTheory: () {},
        onChooseOption: (_) {},
        onContinueReview: () {},
      ),
    ),
  );
}

Widget _learnFixture(
  Act0WorldCardV1 world,
  Act0LessonCardV1 lesson,
  Act0LessonTaskV1 task,
) {
  final opened = lesson.copyWith(
    state: Act0LessonStateV1.current,
    isSelectable: true,
    isLocked: false,
  );
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: const [Locale('en'), Locale('ru')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: Act0LearnPathShellV1(
        // The production feed (preview screen moduleTitle).
        moduleTitle: act0DisplayWorldNameCopyV1(world.title),
        moduleProgressLabel: '0 earned',
        worlds: [
          world.copyWith(lessons: [opened]),
        ],
        selectedWorldId: world.worldId,
        showWorldMenu: false,
        worldDetailId: null,
        lessons: [opened],
        selectedLessonId: lesson.lessonId,
        selectedTaskId: task.taskId,
        activePopupTaskId: task.taskId,
        completedTaskIds: const {},
        perfectTaskIds: const {},
        skippedTaskIds: const {},
        pathClosedTaskIds: {
          for (final t in lesson.taskList.takeWhile(
            (t) => t.taskId != task.taskId,
          ))
            t.taskId,
        },
        detailLessonId: lesson.lessonId,
        lessonOutcomeLabels: const {},
        onSelectWorld: (_) {},
        onOpenWorldMenu: () {},
        onCloseWorldMenu: () {},
        onDismissWorldDetail: () {},
        onPreviewPremiumWorld: (_) {},
        onSelectLesson: (_) => true,
        onOpenLessonAfterScroll: (_) {},
        onDismissDetail: () {},
        onSelectTask: (_, _) {},
        onDismissTaskPopup: () {},
        onStartTask: (_, _) {},
      ),
    ),
  );
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

List<String> _visibleTexts(WidgetTester tester) => [
  for (final w in tester.widgetList<Text>(find.byType(Text)))
    if (w.data != null) w.data!,
  for (final w in tester.widgetList<RichText>(find.byType(RichText)))
    w.text.toPlainText(),
];

List<String> _tableCues(WidgetTester tester) => [
  for (final w in tester.widgetList(
    find.byWidgetPredicate((w) => w.runtimeType.toString() == '_Act0TableV1'),
  ))
    ((w as dynamic).centerLabelOverride as String?) ?? '',
];

Future<({List<String> texts, List<String> cues})> _pumpRunner(
  WidgetTester tester,
  ({Act0WorldCardV1 world, Act0LessonCardV1 lesson, Act0LessonTaskV1 task})
  row, {
  required bool decided,
}) async {
  final task = row.task;
  final correct = task.runner.options.singleWhere((o) => o.isCorrect);
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0LessonRunnerShellV1(
          runner: task.runner.copyWith(
            phase: decided ? Act0LessonPhaseV1.review : task.entryPhase,
            teachingStepIndex: task.runner.teachingSteps.length,
            selectedOptionId: decided ? correct.id : null,
          ),
          worldNumber: row.world.worldNumber,
          selectedWorldId: row.world.worldId,
          selectedLessonId: row.lesson.lessonId,
          selectedTaskId: task.taskId,
          selectedTaskTitle: act0LocalizedTaskTitleAtomByIdV1(
            task.taskId,
            fallback: task.title,
          ),
          selectedTaskFamily: task.resolvedTaskFamily,
          compositionFamily: task.resolvedCompositionFamily,
          tablePresentation: task.tablePresentation,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  while (tester.takeException() != null) {}
  return (texts: _visibleTexts(tester), cues: _tableCues(tester));
}

({Act0WorldCardV1 world, Act0LessonCardV1 lesson, Act0LessonTaskV1 task}) _row(
  String taskId,
) {
  final r = _catalog.singleWhere((r) => r.task.taskId == taskId);
  return (world: r.world, lesson: r.lesson, task: r.task);
}

void main() {
  test('policy sets name only assessed catalog tasks', () {
    final assessedIds = {for (final r in _assessed) r.task.taskId};
    expect(_assessed, hasLength(275));
    for (final id in [
      ...act0PrechoiceNeutralTitleByTaskIdV1.keys,
      ...act0PrechoiceAnswerBearingSummaryTaskIdsV1,
      ...act0PrechoiceAnswerBearingTableCueTaskIdsV1,
    ]) {
      expect(assessedIds, contains(id));
    }
    // Neutral titles must not themselves name any choice of their task.
    for (final entry in act0PrechoiceNeutralTitleByTaskIdV1.entries) {
      final task = _assessed.singleWhere((r) => r.task.taskId == entry.key);
      expect(
        _answerCues([entry.value], task.task.runner),
        isEmpty,
        reason: entry.key,
      );
    }
  });

  test('policy covers exactly the pinned leaks, with drift detection', () {
    expect(
      act0PrechoiceNeutralTitleByTaskIdV1.keys.toSet(),
      _pinnedTitleLeaks.keys.toSet(),
    );
    expect(
      act0PrechoiceAnswerBearingSummaryTaskIdsV1,
      _pinnedSummaryLeaks.keys.toSet(),
    );
    expect(
      act0PrechoiceAnswerBearingTableCueTaskIdsV1,
      _pinnedCueLeaks.keys.toSet(),
    );
    expect(
      act0PrechoiceNeutralQuestionByTaskIdV1.keys.toSet(),
      _pinnedQuestionLeaks.keys.toSet(),
    );
    for (final e in _pinnedTitleLeaks.entries) {
      final shown = act0LocalizedTaskTitleAtomByIdV1(e.key, fallback: e.value);
      expect(shown, isNot(e.value), reason: e.key);
      expect(shown, isNot(contains(e.value)), reason: e.key);
    }
    for (final e in _pinnedQuestionLeaks.entries) {
      expect(
        act0LocalizedRunnerQuestionAtomByTaskIdV1(e.key, fallback: e.value),
        isNot(e.value),
        reason: e.key,
      );
    }
  });

  testWidgets('Runner shows no answer cue before choice across the catalog', (
    tester,
  ) async {
    _phone(tester);
    final found = <String, List<String>>{};
    for (final row in _assessed) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _runnerFixture((world: row.world, lesson: row.lesson, task: row.task)),
      );
      await tester.pumpAndSettle();
      while (tester.takeException() != null) {}
      final cues = _tableCues(tester);
      final authoredCue = row.task.runner.table.centerLabel.trim();
      final pinnedCue = _pinnedCueLeaks[row.task.taskId];
      if (pinnedCue != null) {
        // Adjudicated answer-bearing cue: never shown before the choice.
        expect(authoredCue, pinnedCue, reason: row.task.taskId);
        expect(cues, isNot(contains(pinnedCue)), reason: row.task.taskId);
      }
      final pinnedQuestion = _pinnedQuestionLeaks[row.task.taskId];
      if (pinnedQuestion != null) {
        expect(
          _visibleTexts(tester).where((t) => t.contains(pinnedQuestion)),
          isEmpty,
          reason: row.task.taskId,
        );
      }
      expect(
        _visibleTexts(
          tester,
        ).where((t) => t.contains(act0World4AuthoredTitleV1)),
        isEmpty,
        reason: row.task.taskId,
      );
      final hits = _answerCues([
        ..._visibleTexts(tester),
        ...cues,
      ], row.task.runner);
      if (hits.isNotEmpty) found[row.task.taskId] = hits.toSet().toList();
    }
    for (final e in found.entries) {
      // ignore: avoid_print
      print('ASM04_RUNNER_HIT ${e.key}: ${e.value}');
    }
    expect(
      _allowedRunnerReasons.keys.toSet().difference(
        _allowedRunnerHits.keys.toSet(),
      ),
      isEmpty,
    );
    expect(found, {..._allowedRunnerHits, ..._openRunnerResiduals});
    // ignore: avoid_print
    print(
      'ASM04_RUNNER price-chip allowances: ${_allowedRunnerHits.length - _allowedRunnerReasons.length} ($_priceChip)',
    );
  });

  testWidgets('Academy shows no answer cue before choice across the catalog', (
    tester,
  ) async {
    _phone(tester);
    final found = <String, List<String>>{};
    for (final row in _assessed) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_learnFixture(row.world, row.lesson, row.task));
      await tester.pumpAndSettle();
      while (tester.takeException() != null) {}
      final visible = _visibleTexts(tester);
      final id = row.task.taskId;
      final pinnedTitle = _pinnedTitleLeaks[id];
      if (pinnedTitle != null) {
        expect(row.task.title, pinnedTitle, reason: id);
        expect(visible, contains(act0PrechoiceNeutralTitleByTaskIdV1[id]));
        expect(
          visible.where(
            (t) =>
                t == row.task.title ||
                t.contains('Start here: ${row.task.title}.'),
          ),
          isEmpty,
          reason: id,
        );
      }
      final pinnedSummary = _pinnedSummaryLeaks[id];
      if (pinnedSummary != null) {
        expect(row.task.runner.caption, pinnedSummary, reason: id);
        expect(
          visible.where((t) => t.contains(pinnedSummary)),
          isEmpty,
          reason: id,
        );
      }
      expect(
        visible.where((t) => t.contains(act0World4AuthoredTitleV1)),
        isEmpty,
        reason: id,
      );
      final hits = _answerCues(visible, row.task.runner);
      if (hits.isNotEmpty) found[row.task.taskId] = hits.toSet().toList();
    }
    for (final e in found.entries) {
      // ignore: avoid_print
      print('ASM04_LEARN_HIT ${e.key}: ${e.value}');
    }
    expect(_allowedLearnReasons.keys.toSet(), _allowedLearnHits.keys.toSet());
    expect(found, {..._allowedLearnHits, ..._openLearnResiduals});
  });

  testWidgets('authored cue returns after the decision, source untouched', (
    tester,
  ) async {
    _phone(tester);
    // Centre cue: neutral before choice, authored verdict after it.
    final side = _row('what_poker_is_side_pot_intro');
    expect(side.task.runner.table.centerLabel, 'Hero cannot win side pot');
    final before = await _pumpRunner(tester, side, decided: false);
    expect(before.cues, isNot(contains('Hero cannot win side pot')));
    expect(before.cues.where((c) => c.isNotEmpty), isNotEmpty);
    final after = await _pumpRunner(tester, side, decided: true);
    expect(after.cues, contains('Hero cannot win side pot'));

    // Task rail (seat-target layouts show it): neutral EN atom, never the
    // authored 'BTN vs CO' that names the answer to 'later than CO?'.
    final seat = _row('button_advantage_button_vs_cutoff');
    expect(seat.task.title, 'BTN vs CO');
    final rail = await _pumpRunner(tester, seat, decided: false);
    expect(rail.texts, contains('Seat order question'));
    expect(rail.texts, isNot(contains('BTN vs CO')));
  });

  test('display policy never edits the authored source catalog', () {
    for (final r in _assessed) {
      final t = r.task;
      // The projections take authored copy as input and return either it or
      // a neutral constant; the source objects stay as authored.
      final title = act0PrechoiceDisplayTitleV1(
        taskId: t.taskId,
        authoredTitle: t.title,
        isAssessment: true,
        hasSubmittedCurrentDecision: true,
      );
      expect(title, t.title, reason: t.taskId);
      final summary = act0PrechoiceDisplaySummaryV1(
        taskId: t.taskId,
        authoredSummary: t.runner.caption,
        isAssessment: true,
        hasSubmittedCurrentDecision: true,
      );
      expect(summary, t.runner.caption, reason: t.taskId);
    }
    expect(
      act0PrechoiceDisplaySummaryV1(
        taskId: 'what_poker_is_win_ways',
        authoredSummary: 'x',
        isAssessment: true,
        hasSubmittedCurrentDecision: false,
      ),
      act0PrechoiceNeutralSummaryV1,
    );
  });

  test(
    'single-answer lesson stays a declared limitation, not a choice proof',
    () {
      for (final lessonId in act0PrechoiceSingleAnswerLessonIdsV1) {
        final rows = _assessed.where((r) => r.lesson.lessonId == lessonId);
        expect(rows, isNotEmpty, reason: lessonId);
        final answers = {
          for (final r in rows)
            r.task.runner.options.singleWhere((o) => o.isCorrect).label,
        };
        // Authored Fold answers are kept; the lesson cannot evidence choosing
        // between different actions, so it is only claimed as recall.
        expect(answers, {'Fold'}, reason: lessonId);
        expect(
          act0LocalizedLessonTitleAtomByIdV1(
            lessonId,
            fallback: rows.first.lesson.title,
          ),
          isNot(contains('Fold')),
        );
      }
      // No other lesson repeats one answer across three or more assessments.
      final byLesson = <String, Set<String>>{};
      final counts = <String, int>{};
      for (final r in _assessed) {
        final id = r.lesson.lessonId;
        byLesson
            .putIfAbsent(id, () => {})
            .add(r.task.runner.options.singleWhere((o) => o.isCorrect).label);
        counts[id] = (counts[id] ?? 0) + 1;
      }
      expect({
        for (final e in byLesson.entries)
          if (e.value.length == 1 && counts[e.key]! >= 3) e.key,
      }, act0PrechoiceSingleAnswerLessonIdsV1);
    },
  );

  test('recap keeps the real river and asks an honest table read', () {
    final r = _row('your_first_hand_recap').task;
    expect(r.runner.table.boardCards, hasLength(5));
    expect(r.runner.question, 'Which street comes after the turn?');
    expect(
      act0LocalizedRunnerQuestionAtomByTaskIdV1(
        r.taskId,
        fallback: r.runner.question,
      ),
      'Which street is on the table now?',
    );
    expect(r.runner.options.singleWhere((o) => o.isCorrect).label, 'River');
  });

  group('saved answers and history', () {
    // Fingerprints on main 1a4316d, before this package (no #418 either).
    const mainFingerprints = <String, String>{
      'actions_check_drill':
          'f83ccdabce1c8c216939274080ba10409b49285f7adcece8b42face691e42d6b',
      'actions_raise_drill':
          'c105d1969e7b9a7886def4fed1b93aaee5404f7d0603e771be44ea3a76d06971',
      'actions_legal_context':
          'd889c669abcb49a96b62c12447888f10e8e262e3a2f663b8d2e700010686cad4',
    };
    String fingerprint(String taskId) {
      final r = _row(taskId);
      return act0AuthoredSourceFingerprintV1(
        worldId: r.world.worldId,
        lessonId: r.lesson.lessonId,
        task: r.task,
      )!;
    }

    Act0LearningEvidenceRecordV1 record(String taskId, String fp) {
      final r = _row(taskId);
      final correct = r.task.runner.options.singleWhere((o) => o.isCorrect);
      return Act0LearningEvidenceRecordV1(
        recordId: 'synthetic_asm04_answer_cue|$taskId',
        createdOrder: 1,
        worldId: r.world.worldId,
        lessonId: r.lesson.lessonId,
        taskId: taskId,
        sourceTaskId: taskId,
        choiceId: correct.id,
        expectedChoiceId: correct.id,
        isCorrect: true,
        errorType: 'none',
        conceptFamilyId: r.lesson.lessonId,
        repairFocusId: '',
        skillAtomId:
            act0FirstValueSkillReceiptForRunnerV1(
              runner: r.task.runner,
              option: correct,
              taskFamily: r.task.resolvedTaskFamily,
            )?.skillAtomId ??
            '',
        decisionTimeBucket: '3_to_10s',
        resultKind: 'correct',
        assistanceKind: Act0DecisionAssistanceV1.none,
        authoredSourceFingerprint: fp,
      );
    }

    test('an answer saved under a cue stays history, not current proof', () {
      for (final taskId in ['actions_check_drill', 'actions_raise_drill']) {
        final task = _row(taskId).task;
        // Not covered by the #418 card-focus revision; only this package.
        expect(act0PredecisionCardFocusSourceRevisionV1(task), isNull);
        expect(
          act0PrechoiceAnswerCueSourceRevisionV1(
            task,
            lessonId: _row(taskId).lesson.lessonId,
          ),
          act0PrechoiceAnswerCueRevisionV1,
        );
        final current = fingerprint(taskId);
        expect(current, isNot(mainFingerprints[taskId]));
        final old = record(taskId, mainFingerprints[taskId]!);
        final restored = Act0LearningEvidenceHistoryV1.tryParse(
          jsonDecode(
            Act0LearningEvidenceHistoryV1(records: [old]).toStorageString(),
          ),
        )!;
        expect(restored.records.single.toPayload(), old.toPayload());
        expect(restored.records.single.isCorrect, isTrue);
        expect(
          act0CurrentAuthoredSourceProofV1(restored.records.single),
          isNull,
          reason: taskId,
        );
        expect(
          act0CurrentAuthoredSourceProofV1(
            record(taskId, current),
          )!.isCurrentlyCorrect,
          isTrue,
        );
      }
    });

    test('untouched tasks keep their fingerprint and current proof', () {
      final task = _row('actions_legal_context').task;
      expect(act0PredecisionCardFocusSourceRevisionV1(task), isNull);
      expect(
        act0PrechoiceAnswerCueSourceRevisionV1(task, lessonId: 'x'),
        isNull,
      );
      expect(
        fingerprint('actions_legal_context'),
        mainFingerprints['actions_legal_context'],
      );
      expect(
        act0CurrentAuthoredSourceProofV1(
          record(
            'actions_legal_context',
            mainFingerprints['actions_legal_context']!,
          ),
        )!.isCurrentlyCorrect,
        isTrue,
      );
    });

    test('revision covers exactly the tasks whose pre-choice view changed', () {
      final revised = {
        for (final r in _assessed)
          if (act0PrechoiceAnswerCueSourceRevisionV1(
                r.task,
                lessonId: r.lesson.lessonId,
              ) !=
              null)
            r.task.taskId,
      };
      final changed = {
        ..._pinnedTitleLeaks.keys,
        ..._pinnedSummaryLeaks.keys,
        ..._pinnedCueLeaks.keys,
        ..._pinnedQuestionLeaks.keys,
        for (final r in _assessed)
          if (r.task.taskId.startsWith('hand_rankings_') ||
              act0PrechoiceNeutralLessonTitleByIdV1.containsKey(
                r.lesson.lessonId,
              ))
            r.task.taskId,
      };
      expect(revised, changed);
      // ignore: avoid_print
      print('ASM04_REVISED ${revised.length} of ${_assessed.length}');
    });
  });

  testWidgets('World 4 shows Betting Decisions before the recap answer', (
    tester,
  ) async {
    _phone(tester);
    final sample = Act0ShellStateV1.sample;
    final world4 = sample.worldById('world_4');
    // Source identity, recap question, choices, order, grade and XP unchanged.
    expect(world4.title, act0World4AuthoredTitleV1);
    final recap = _row('w4_checkpoint_review').task;
    expect(recap.runner.question, 'What makes a bet easier to understand?');
    expect(recap.runner.options.map((o) => o.label).toList(), [
      'Purpose and price',
      'Random size',
    ]);
    expect(
      recap.runner.options.singleWhere((o) => o.isCorrect).label,
      'Purpose and price',
    );
    expect(recap.runner.options.map((o) => o.id).toList(), [
      'purpose_price',
      'random_size',
    ]);
    expect(recap.rewardXp, 15);
    expect(
      act0LocalizedWorldTitleAtomV1('world_4', fallback: world4.title),
      'Betting Decisions',
    );
    // The next world's unlock label embeds the World 4 name.
    final world5 = sample.worldById('world_5');
    expect(world5.unlockLabel, contains(act0World4AuthoredTitleV1));
    expect(
      act0DisplayWorldNameCopyV1(world5.unlockLabel),
      'Finish Betting Decisions to open this world.',
    );
    // Real Learn consumer with the whole world list, recap pending.
    final lesson = world4.lessons.singleWhere(
      (l) => l.taskList.any((t) => t.taskId == 'w4_checkpoint_review'),
    );
    await tester.pumpWidget(_learnFixture(world4, lesson, recap));
    await tester.pumpAndSettle();
    final visible = _visibleTexts(tester);
    expect(visible.where((t) => t.contains('Bet Purpose')), isEmpty);
    expect(visible, contains('Betting Decisions'));
  });
}
