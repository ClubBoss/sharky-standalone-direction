import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_replay_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_summary_preview_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w1_rules_check_v1.dart';

import '../support/act0_y5d_catalog_contract_v1.dart';
import '../support/act0_w3_catalog_contract_v1.dart';
import '../support/act0_wave6_contract_v1.dart';
import '../support/act0_table_truth_v1.dart';
import '../support/act0_y5b_catalog_contract_v1.dart';
import '../support/act0_y5c_catalog_contract_v1.dart';
import '../support/act0_source_choreography_test_wait_v1.dart';
import '../support/act0_route_practice_runner_test_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_route_practice_v1.dart';

// Long session through the real app shell on iPhone 14 Pro: a fresh learner
// goes through Worlds 1–7 by default, or 1–12 with
// --dart-define=ACT0_LONG_SESSION_FULL_ROUTE=true. The app is
// restarted in every world, and progress must carry on from where it stopped.
// ACT0_LONG_SESSION_W7_TO_W8 resumes a save at W7 for focused Q7 checks.
// Tier A runs the focused cases and the two route ranges as separate commands.
// Any exception thrown by the app fails the test.
const _continueKeys = [
  'act0_shell_feedback_continue_cta',
  'act0_shell_block_summary_continue_cta',
  'act0_shell_continue_cta',
  'act0_shell_welcome_primary_cta',
  'act0_shell_main_cta',
  'act0_academy_home_leaf_cta',
];

// Material 3 defaults to InkSparkle, whose shader asset is not bundled for
// `flutter test`; its load error fails the test and the long session hangs.
// Production keeps the platform default; the harness uses InkRipple.
final ThemeData longSessionTestThemeV1 = ThemeData(
  splashFactory: InkRipple.splashFactory,
);

Future<void> _mount(WidgetTester t, {bool firstRun = false}) async {
  await t.pumpWidget(
    MaterialApp(
      theme: longSessionTestThemeV1,
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        initialTab: Act0ShellTabV1.home,
        showPlacementOnStart: firstRun,
      ),
    ),
  );
  await t.pumpAndSettle();
}

final _tapLog = <String>[];

Future<bool> _tapFirst(WidgetTester t, List<Finder> finders) async {
  for (final f in finders) {
    if (f.evaluate().isEmpty) continue;
    await t.ensureVisible(f.first);
    await t.pumpAndSettle();
    final hit = f.hitTestable();
    if (hit.evaluate().isEmpty) continue;
    _tapLog.add(RegExp(r"'([a-z0-9_]+)'").firstMatch('$f')?.group(1) ?? '?');
    await t.tap(hit.first, warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 800));
    // Route assertions use the settled screen. Sample fewer intermediate
    // animation frames while preserving the real navigation and dwell timers.
    await t.pumpAndSettle(const Duration(milliseconds: 250));
    return true;
  }
  return false;
}

Future<void> _onboard(WidgetTester t, {required bool useRulesCheck}) async {
  Future<void> tap(String key) async {
    final button = find.byKey(Key(key)).hitTestable();
    expect(button, findsOneWidget);
    await t.tap(button);
    await t.pumpAndSettle();
  }

  if (useRulesCheck) {
    await tap('act0_shell_w1_start_check');
    for (final question in act0W1RulesQuestionsV1) {
      await tap('act0_shell_option_choice_${question.correctChoice}');
    }
    await tap('act0_shell_w1_rules_continue');
  } else {
    await tap('act0_shell_w1_start_basics');
  }
}

Future<Map<String, dynamic>> _saved(WidgetTester t) async {
  Map<String, dynamic>? result;
  await t.runAsync(() async {
    await Act0ProgressStoreV1(
      key: 'act0_shell_progress_v1',
      isValidPayload: (_) => false,
    ).flush().timeout(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final head = prefs.getString('act0_shell_progress_v1_head');
    expect(head, isNotNull);
    expect(prefs.getString('act0_shell_progress_v1_backup'), head);
    expect(prefs.getString('act0_shell_progress_v1_recovery'), head);
    result =
        jsonDecode((jsonDecode(head!) as Map)['payload'] as String)
            as Map<String, dynamic>;
  });
  return result!;
}

Future<int> _openSavedCourseTask(
  WidgetTester t, {
  required String worldId,
  required String taskId,
  String? legacyLessonId,
  String? legacyTaskId,
  Set<String>? legacyCompletedIds,
  bool restoreActive = false,
  bool finishTeaching = true,
  bool persistSeed = false,
}) async {
  final state = Act0ShellStateV1.sample;
  final world = state.worldById(worldId);
  final lesson = world.lessons.singleWhere(
    (lesson) => lesson.courseTaskList.any((task) => task.taskId == taskId),
  );
  final earlierLessons = [
    for (final earlierWorld in state.worlds.takeWhile(
      (candidate) => candidate.worldId != worldId,
    ))
      ...earlierWorld.lessons,
    ...world.lessons.takeWhile(
      (candidate) => candidate.lessonId != lesson.lessonId,
    ),
  ];
  final completed = legacyCompletedIds == null
      ? [
          for (final earlier in earlierLessons) ...earlier.courseTaskList,
          ...lesson.courseTaskList.takeWhile((task) => task.taskId != taskId),
        ]
      : [
          for (final lesson in world.lessons)
            for (final task in lesson.courseTaskList)
              if (legacyCompletedIds.contains(task.taskId)) task,
        ];
  final xp = completed.fold(0, (sum, task) => sum + task.rewardXp);
  const progressKey = 'act0_shell_progress_v1';
  final payload = jsonEncode({
    'schemaVersion': 20,
    'pendingDecisionAssistance': <Object>[],
    'learningEvidenceHistory': <Object>[],
    'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
        .lineagePayload(),
    'durableRetentionHistory': <Object>[],
    'completedTaskIds': completed.map((task) => task.taskId).toList(),
    'completedLessonIds': legacyCompletedIds == null
        ? earlierLessons.map((lesson) => lesson.lessonId).toList()
        : <String>[],
    'skippedTaskIds': <String>[],
    'earnedXp': xp,
    'selectedWorldId': worldId,
    'selectedLessonId': legacyLessonId ?? lesson.lessonId,
    'selectedTaskId': legacyTaskId ?? taskId,
    if (restoreActive) ...{
      'resumeInRunner': true,
      'resumePhase': 'drill',
      'resumeTeachingStepIndex': lesson.courseTaskList
          .singleWhere((task) => task.taskId == taskId)
          .runner
          .teachingSteps
          .length,
    },
  });
  SharedPreferences.setMockInitialValues({
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    if (!persistSeed) progressKey: payload,
  });
  if (persistSeed) {
    final saved = await t.runAsync(() {
      return Act0ProgressStoreV1(
        key: progressKey,
        isValidPayload: (candidate) => candidate == payload,
      ).save(payload);
    });
    expect(saved, isTrue);
  }
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await _mount(t);
  await t.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await t.pumpAndSettle();
  if (!restoreActive) await _tapFirst(t, [find.text('Learn')]);
  expect(
    await _tapFirst(t, [
      if (!restoreActive)
        find.byKey(const Key('act0_shell_current_mission_cta')),
      find.byKey(const Key('act0_academy_home_leaf_cta')),
    ]),
    isTrue,
    reason: t
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .whereType<String>()
        .take(25)
        .join(' | '),
  );
  final shell = find.byType(Act0LessonRunnerShellV1);
  expect(t.widget<Act0LessonRunnerShellV1>(shell).selectedTaskId, taskId);
  while (finishTeaching &&
      t.widget<Act0LessonRunnerShellV1>(shell).runner.activeTeachingStep !=
          null) {
    expect(
      await _tapFirst(t, [
        find.byKey(const Key('act0_shell_theory_continue_cta')),
        find.byKey(const Key('act0_shell_continue_cta')),
      ]),
      isTrue,
    );
  }
  await pumpSourceChoreographyToDecisionV1(
    t,
    t.widget<Act0LessonRunnerShellV1>(shell).runner.table,
  );
  return xp;
}

const _preSplitIntroTasks = <String>{
  'w1_shared_card_access',
  'w1_chips_starting_pot',
  'w1_chips_matched_pot',
  'w1_chips_read_middle',
};

void main() {
  _registerFocusedCases();
  if (!const bool.fromEnvironment('ACT0_LONG_SESSION_FOCUSED_ONLY')) {
    registerLongSessionRoutes();
  }
}

void _registerFocusedCases() {
  test(
    'H5 is absent from the standard route and validates every pilot point',
    () {
      final state = Act0ShellStateV1.sample;
      final hands = [
        for (final world in state.worlds)
          for (final lesson in world.lessons)
            for (final task in lesson.courseTaskList)
              if (task.multiStreet case final hand?) hand,
      ];
      if (!act0CurriculumPilotEnabledV1) {
        expect(hands, isEmpty);
        expect(state.worlds.last.worldNumber, 12);
        return;
      }
      expect(hands, hasLength(3));
      const pots = [
        [5.5, 9.5, 15.5],
        [20.5, 52.5, 112.5],
        [5.5, 9.5, 27.5],
      ];
      for (final (handIndex, hand) in hands.indexed) {
        expect(hand.decisions, hasLength(3));
        final fullPrefix = hand.decisions.last.table.handTimelinePrefix!;
        expect(() => Act0MultiStreetV1(fullPrefix, []), throwsFormatException);
        for (final (index, decision) in hand.decisions.indexed) {
          final table = decision.table;
          final prefix = table.handTimelinePrefix!;
          expect(prefix.street, PokerStreet.values[index + 1]);
          expect(prefix.board, hasLength(index + 3));
          expect(table.boardCards.map((card) => card.label), prefix.board);
          expect(prefix.decisionError('btn'), isNull);
          final amounts = prefix.contributions.amounts(
            seatIds: table.seats.map((seat) => seat.seatId).toSet(),
            actorSeatId: 'btn',
          );
          expect(amounts.potBb, pots[handIndex][index]);
          expect(amounts.toCallBb, handIndex == 2 && index == 2 ? 12 : 0);
          expect(
            auditTableContributionsV1(
              'h5',
              '$index',
              table,
            ).where((row) => row.result == 'FAIL'),
            isEmpty,
          );
          expect(decision.caption, isNotEmpty);
          expect(
            decision.options.where((option) => option.quality.isPreferred),
            hasLength(1),
          );
          for (final option in decision.options) {
            expect(option.isCorrect, option.quality.passes);
          }
        }
        final first = hand.decisions.first;
        expect(
          () => Act0MultiStreetV1(fullPrefix, [
            for (var i = 0; i < 2; i++)
              (
                boundary: first.table.handTimelinePrefix!.events.length,
                runner: first,
                authoredChoiceId: 'flop_bet',
              ),
          ]),
          throwsFormatException,
        );
      }
    },
  );

  testWidgets(
    'H5 resumes after a flop mistake and archives all three decisions',
    (t) async {
      const taskId = 'h5_w16_3_guided_thin_third_street';
      final xp = await _openSavedCourseTask(
        t,
        worldId: 'world_16',
        taskId: taskId,
        restoreActive: true,
      );
      final shell = find.byType(Act0LessonRunnerShellV1);
      Act0RunnerStateV1 runner() =>
          t.widget<Act0LessonRunnerShellV1>(shell).runner;
      Future<void> tap(String key) async {
        expect(await _tapFirst(t, [find.byKey(Key(key))]), isTrue, reason: key);
      }

      expect(runner().table.boardCards, hasLength(3));
      await tap('act0_shell_option_flop_check');
      await _saved(t);
      await _mount(t);
      await tap('act0_academy_home_leaf_cta');
      expect(runner().selectedOptionId, 'flop_check');
      expect(
        runner().selectedOption!.feedbackReason,
        contains('continues with the recorded play'),
      );
      await tap('act0_shell_feedback_continue_cta');
      expect(runner().table.boardCards, hasLength(4));
      expect(runner().table.potLabel, 'Pot 9.5 BB');
      await tap('act0_shell_option_turn_bet');
      await tap('act0_shell_feedback_continue_cta');
      expect(runner().table.boardCards, hasLength(5));
      await tap('act0_shell_option_river_bet_3');
      await tap('act0_shell_feedback_continue_cta');
      final saved = await _saved(t);
      expect(saved['earnedXp'], xp);
      expect(saved['completedTaskIds'], contains(taskId));
      final history = Act0LearningEvidenceHistoryV1.restore(
        saved['learningEvidenceHistory'],
        saved['learningEvidenceLineage'],
      )!;
      final records = history.records.where(
        (record) => record.taskId == taskId,
      );
      expect(records.map((record) => record.choiceId), [
        'flop_check',
        'turn_bet',
        'river_bet_3',
      ]);
      expect(records.map((record) => record.isCorrect), [false, true, true]);
      final archive = Act0AttemptArchiveV1.restore(
        saved['attemptArchive'],
        snapshotRecords: history.records,
      );
      for (final attempt in archive.attempts) {
        final table = act0VerifiedReplayTableV1(
          attempt.evidence,
          attempt.tableFingerprint,
        );
        expect(
          table?.boardCards.map((card) => card.label),
          attempt.timelineSnapshot!.board,
        );
      }
      final reviewRows = saved['reviewMistakeHistory'] as List;
      expect(
        reviewRows
            .where((row) => row['decisionTaskId'] == taskId)
            .map((row) => row['selectedId']),
        ['flop_check'],
      );
      final recordsByChoice = {
        for (final attempt in archive.attempts)
          attempt.evidence.choiceId: attempt.timelineSnapshot!.board.length,
      };
      expect(recordsByChoice, {
        'flop_check': 3,
        'turn_bet': 4,
        'river_bet_3': 5,
      });
    },
    skip: !act0CurriculumPilotEnabledV1,
  );

  testWidgets('pre-split first lesson resumes the card read with its XP', (
    t,
  ) async {
    final xp = await _openSavedCourseTask(
      t,
      worldId: 'world_1',
      legacyLessonId: 'what_poker_is',
      taskId: 'what_poker_is_find_hero',
      legacyCompletedIds: {'what_poker_is_theory'},
      restoreActive: true,
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedLessonId, 'what_poker_is');
    expect(
      await _tapFirst(t, [find.byKey(const Key('act0_shell_option_top'))]),
      isTrue,
    );
    final saved = await _saved(t);
    expect(saved['earnedXp'], xp);
    expect(saved['completedTaskIds'], ['what_poker_is_theory']);
  });

  testWidgets(
    'pre-split AA save resumes the assisted raise in its new lesson',
    (t) async {
      const taskId = 'first_table_guide_first_decision';
      final xp = await _openSavedCourseTask(
        t,
        worldId: 'world_1',
        legacyLessonId: 'what_poker_is',
        taskId: taskId,
        legacyCompletedIds: {'what_poker_is_theory', 'what_poker_is_find_hero'},
        restoreActive: true,
      );
      final runner = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedLessonId, 'first_table_guide');
      expect(find.text('Raise to 7.5 BB'), findsOneWidget);
      expect(
        await _tapFirst(t, [find.byKey(const Key('act0_shell_option_raise'))]),
        isTrue,
      );
      final saved = await _saved(t);
      expect(saved['earnedXp'], xp);
      final evidence = (saved['learningEvidenceHistory'] as List).cast<Map>();
      final move = evidence.singleWhere((row) => row['taskId'] == taskId);
      expect(move['assistanceKind'], 'theoryRecall');
    },
  );

  testWidgets('W1 save resumes a drill from before the lesson split', (
    t,
  ) async {
    final xp = await _openSavedCourseTask(
      t,
      worldId: 'world_1',
      taskId: 'hand_rankings_full_house_vs_flush_drill',
      legacyLessonId: 'hand_rankings_upper',
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedLessonId, 'hand_rankings_upper');
    expect(
      await _tapFirst(t, [find.byKey(const Key('act0_shell_option_co_flush'))]),
      isTrue,
    );
    final saved = await _saved(t);
    expect(saved['selectedLessonId'], 'hand_rankings_upper');
    expect(saved['selectedTaskId'], 'hand_rankings_full_house_vs_flush_drill');
    expect(saved['earnedXp'], xp);
  });

  testWidgets('W1 save finds a sequence drill in its new lesson', (t) async {
    final xp = await _openSavedCourseTask(
      t,
      worldId: 'world_1',
      taskId: 'hand_rankings_flush_drill',
      legacyLessonId: 'hand_rankings_upper',
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedLessonId, 'hand_rankings_sequences');
    expect(
      await _tapFirst(t, [find.byKey(const Key('act0_shell_option_straight'))]),
      isTrue,
    );
    final saved = await _saved(t);
    expect(saved['earnedXp'], xp);
  });

  testWidgets('pre-L1 saved progress resumes at the first new prerequisite', (
    t,
  ) async {
    // In the previous route the all-in lesson came before ranks. This saved
    // learner completed the first three lessons and had not studied ranks.
    const oldCompleted = <String>[
      'what_poker_is_theory',
      'what_poker_is_find_hero',
      'what_poker_is_table_read_transfer',
      'what_poker_is_table_read_recheck',
      'first_table_guide_one_clear_choice',
      'first_table_guide_route_roles',
      'what_poker_is_pot_stack',
      'what_poker_is_win_ways',
      'what_poker_is_showdown_win',
      'what_poker_is_all_in_meaning',
      'what_poker_is_matched_chips_transfer',
      'what_poker_is_live_win_transfer',
      'what_poker_is_review',
      'cards_ranks_suits_theory',
      'cards_ranks_suits_rank_drill',
      'cards_ranks_suits_suit_drill',
      'cards_ranks_suits_private_board',
      'cards_ranks_suits_board_count',
      'cards_ranks_suits_best_five',
      'cards_ranks_suits_recap',
    ];
    const oldXp = 101;
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': <Object>[],
        'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
            .lineagePayload(),
        'durableRetentionHistory': <Object>[],
        'completedTaskIds': oldCompleted,
        'completedLessonIds': [
          'what_poker_is',
          'what_poker_is_content',
          'cards_ranks_suits',
        ],
        'skippedTaskIds': <String>[],
        'earnedXp': oldXp,
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'cards_ranks_suits',
        'selectedTaskId': 'cards_ranks_suits_recap',
      }),
    });
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await _mount(t);
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await t.pumpAndSettle();
    expect(
      await _tapFirst(
        t,
        _continueKeys.map((key) => find.byKey(Key(key))).toList(),
      ),
      isTrue,
      reason: t
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .whereType<String>()
          .take(25)
          .join(' | '),
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, 'first_table_guide_first_decision');
    final saved = await _saved(t);
    expect((saved['completedTaskIds'] as List).toSet(), oldCompleted.toSet());
    expect(saved['earnedXp'], oldXp);
    expect(saved['skippedTaskIds'], unorderedEquals(_preSplitIntroTasks));
    expect(t.takeException(), isNull);
  });

  testWidgets('pre-Q9 save keeps World 2 credit and opens the new lesson', (
    t,
  ) async {
    const q9 = 'w2_narrow_three_bet';
    final state = Act0ShellStateV1.sample;
    final earlier = [
      for (final world in state.worlds.take(2))
        for (final lesson in world.lessons)
          if (lesson.lessonId != q9) lesson,
    ];
    final completed = [for (final lesson in earlier) ...lesson.courseTaskList];
    final xp = completed.fold(0, (sum, task) => sum + task.rewardXp);
    final w3 = state.worldById('world_3').lessons.first;
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': <Object>[],
        'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
            .lineagePayload(),
        'durableRetentionHistory': <Object>[],
        'completedTaskIds': completed.map((task) => task.taskId).toList(),
        'completedLessonIds': earlier.map((lesson) => lesson.lessonId).toList(),
        'skippedTaskIds': <String>[],
        'earnedXp': xp,
        'selectedWorldId': 'world_3',
        'selectedLessonId': w3.lessonId,
        'selectedTaskId': w3.courseTaskList.first.taskId,
      }),
    });
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await _mount(t);
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await t.pumpAndSettle();
    expect(
      await _tapFirst(
        t,
        _continueKeys.map((key) => find.byKey(Key(key))).toList(),
      ),
      isTrue,
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, '${q9}_intro');
    final saved = await _saved(t);
    expect(
      saved['completedTaskIds'],
      unorderedEquals(completed.map((task) => task.taskId)),
    );
    expect(saved['earnedXp'], xp);
    expect(saved['skippedTaskIds'], isEmpty);
  });

  testWidgets('pre-Q10 save keeps World 6 credit and opens the new lesson', (
    t,
  ) async {
    const q10 = 'w6_continuation_bet';
    final state = Act0ShellStateV1.sample;
    final earlier = [
      for (final world in state.worlds.take(6))
        for (final lesson in world.lessons)
          if (lesson.lessonId != q10) lesson,
    ];
    final completed = [for (final lesson in earlier) ...lesson.courseTaskList];
    final xp = completed.fold(0, (sum, task) => sum + task.rewardXp);
    final w7 = state.worldById('world_7').lessons.first;
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': <Object>[],
        'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
            .lineagePayload(),
        'durableRetentionHistory': <Object>[],
        'completedTaskIds': completed.map((task) => task.taskId).toList(),
        'completedLessonIds': [
          for (final lesson in earlier)
            if (lesson.lessonId != 'range_reading_review') lesson.lessonId,
        ],
        'skippedTaskIds': <String>[],
        'earnedXp': xp,
        'selectedWorldId': 'world_7',
        'selectedLessonId': w7.lessonId,
        'selectedTaskId': w7.courseTaskList.first.taskId,
      }),
    });
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await _mount(t);
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await t.pumpAndSettle();
    expect(
      await _tapFirst(
        t,
        _continueKeys.map((key) => find.byKey(Key(key))).toList(),
      ),
      isTrue,
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, '${q10}_intro');
    final saved = await _saved(t);
    expect(
      saved['completedTaskIds'],
      unorderedEquals(completed.map((task) => task.taskId)),
    );
    expect(saved['earnedXp'], xp);
    expect(saved['skippedTaskIds'], isEmpty);
  });

  testWidgets(
    'pre-beta W12 save skips a retired task and preserves earned XP',
    (tester) async {
      const retiredTaskId = 'w12_tilt_after_river_beat';
      const nextTaskId = 'w12_after_bad_beat_reset';
      expect(wave6RetiredRowsV1, contains(retiredTaskId));
      final xp = await _openSavedCourseTask(
        tester,
        worldId: 'world_12',
        taskId: nextTaskId,
        legacyTaskId: retiredTaskId,
      );
      expect(
        await _tapFirst(tester, [
          find.byKey(
            const Key('act0_shell_option_check_from_fear_of_another_loss'),
          ),
        ]),
        isTrue,
      );
      final saved = await _saved(tester);
      expect(saved['selectedTaskId'], nextTaskId);
      final completed = (saved['completedTaskIds'] as List).toSet();
      expect(completed, isNot(contains(retiredTaskId)));
      final retainedXp = Act0ShellStateV1.sample.worlds
          .expand((world) => world.lessons)
          .expand((lesson) => lesson.courseTaskList)
          .where((task) => completed.contains(task.taskId))
          .fold<int>(0, (sum, task) => sum + task.rewardXp);
      expect(saved['earnedXp'], isNonNegative);
      expect(saved['earnedXp'], xp);
      expect(saved['earnedXp'], retainedXp);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('P8 keeps progress earned before the full hand moved', (
    tester,
  ) async {
    const earlierLessons = [
      'what_poker_is',
      'cards_ranks_suits',
      'hand_rankings_table',
      'hand_rankings_upper',
      'hand_rankings_sequences',
      'your_first_hand',
    ];
    final world = Act0ShellStateV1.sample.worldById('world_1');
    final completed = [
      for (final lesson in world.lessons)
        if (earlierLessons.contains(lesson.lessonId) ||
            lesson.lessonId == 'hand_rankings_comparisons' ||
            lesson.lessonId == 'first_table_guide')
          for (final task in lesson.courseTaskList)
            if (!_preSplitIntroTasks.contains(task.taskId)) task,
    ];
    final completedIds = completed.map((task) => task.taskId).toList();
    final xp = completed.fold(0, (sum, task) => sum + task.rewardXp);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': <Object>[],
        'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
            .lineagePayload(),
        'durableRetentionHistory': <Object>[],
        'completedTaskIds': completedIds,
        'completedLessonIds': earlierLessons,
        'skippedTaskIds': <String>[],
        'earnedXp': xp,
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'your_first_hand',
        'selectedTaskId': 'your_first_hand_recap',
      }),
    });
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _mount(tester);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(
      await _tapFirst(
        tester,
        _continueKeys.map((key) => find.byKey(Key(key))).toList(),
      ),
      isTrue,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .whereType<String>()
          .take(25)
          .join(' | '),
    );
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedLessonId, 'blinds_action_order');
    final saved = await _saved(tester);
    expect(saved['completedTaskIds'], unorderedEquals(completedIds));
    expect(saved['earnedXp'], xp);
    expect(saved['skippedTaskIds'], unorderedEquals(_preSplitIntroTasks));
    expect(tester.takeException(), isNull);
  });

  testWidgets('W9 shows its short-stack premise before answering', (t) async {
    await _openSavedCourseTask(
      t,
      worldId: 'world_9',
      taskId: 'w9_short_stack_survival',
    );
    expect(find.textContaining('You start with 9 BB.'), findsOneWidget);
    expect(
      find.textContaining('BB frequently folds under the stated'),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_option_take_spot')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('W9 long inline history keeps the current decision playable', (
    t,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        theme: longSessionTestThemeV1,
        locale: const Locale('en'),
        home: const Act0ShellPreviewScreenV1(
          initialPhase: Act0LessonPhaseV1.drill,
          showPlacementOnStart: false,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
            worldId: 'world_9',
            lessonId: 'm_ratio_zones_lite',
            taskId: 'w9_m_ratio_table_window_transfer',
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, 'w9_m_ratio_table_window_transfer');
    await pumpSourceChoreographyToDecisionV1(t, runner.runner.table);
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_center_pot_stat')),
        matching: find.text('Pot 2 BB'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_center_to_call_stat')),
      findsNothing,
    );
    final history = find.byKey(const Key('act0_shell_street_replay_scroll'));
    expect(history, findsOneWidget);
    final scroll = t.state<ScrollableState>(
      find.descendant(of: history, matching: find.byType(Scrollable)),
    );
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    expect(scroll.position.pixels, 0);
    final correct = runner.runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    final answer = find.byKey(Key('act0_shell_option_${correct.id}'));
    expect(answer.hitTestable(), findsOneWidget);
    await t.tap(answer);
    await t.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('W9 proved bubble price keeps the decision playable', (t) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        theme: longSessionTestThemeV1,
        locale: const Locale('en'),
        home: const Act0ShellPreviewScreenV1(
          initialPhase: Act0LessonPhaseV1.drill,
          showPlacementOnStart: false,
          debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
            worldId: 'world_9',
            lessonId: 'bubble_risk_premium',
            taskId: 'w9_bubble_table_risk_transfer',
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, 'w9_bubble_table_risk_transfer');
    await pumpSourceChoreographyToDecisionV1(t, runner.runner.table);
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_center_pot_stat')),
        matching: find.text('Pot 21 BB'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_center_to_call_stat')),
        matching: find.text('To call 15.5 BB'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_street_replay_scroll')),
      findsNothing,
    );
    final correct = runner.runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    final answer = find.byKey(Key('act0_shell_option_${correct.id}'));
    expect(answer.hitTestable(), findsOneWidget);
    await t.tap(answer);
    await t.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'W8 exact replay describes the same question without a board clue',
    (t) async {
      const taskId = 'w7_effective_stack_30bb';
      await _openSavedCourseTask(t, worldId: 'world_8', taskId: taskId);
      expect(
        await _tapFirst(t, [find.byKey(const Key('act0_shell_option_200'))]),
        isTrue,
      );

      final state = t.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final replay =
          state.debugReviewSupportCopySnapshotV1() as Map<String, Object?>;
      expect(replay['targetTaskId'], taskId);
      expect(replay['lineKind'], 'exact_replay_repair');
      expect(replay['renderedLine'], 'Try this question again.');
    },
  );

  testWidgets('a correct W5 retry offers to continue the lesson', (t) async {
    const taskId = 'board_texture_basics_w5_dry_board';
    await _openSavedCourseTask(t, worldId: 'world_5', taskId: taskId);
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));

    expect(
      await _tapFirst(t, [find.byKey(const Key('act0_shell_option_wet'))]),
      isTrue,
    );
    expect(
      find.descendant(of: cta, matching: find.text('Try same clue')),
      findsOneWidget,
    );
    expect(await _tapFirst(t, [cta]), isTrue);
    expect(
      await _tapFirst(t, [find.byKey(const Key('act0_shell_option_dry'))]),
      isTrue,
    );

    expect(
      find.descendant(of: cta, matching: find.text('Continue')),
      findsOneWidget,
    );
    expect(find.text('Try the same table clue once more.'), findsNothing);
    expect(await _tapFirst(t, [cta]), isTrue);
    expect(
      t
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      'board_texture_basics_w5_wet_board',
    );
  });

  group('Review attempt archive', () {
    Future<void> openArchive(WidgetTester t) async {
      expect(await _tapFirst(t, [find.text('Review')]), isTrue);
      expect(
        await _tapFirst(t, [
          find.byKey(const Key('act0_review_open_attempts')),
        ]),
        isTrue,
      );
    }

    testWidgets('B39 saved cards miss keeps its Review identity and grade', (
      t,
    ) async {
      const sourceId = 'what_poker_is_find_hero';
      const repairId = 'first_table_guide_shared_cards_repair';
      Act0LessonRunnerShellV1 runner() =>
          t.widget(find.byType(Act0LessonRunnerShellV1));
      Future<void> tap(Finder finder) async {
        expect(await _tapFirst(t, [finder]), isTrue);
      }

      Future<void> answer(String id) async {
        await pumpSourceChoreographyToDecisionV1(t, runner().runner.table);
        await tap(find.byKey(Key('act0_shell_option_$id')));
      }

      Act0AttemptArchiveV1 archive(Map<String, dynamic> snapshot) {
        final history = Act0LearningEvidenceHistoryV1.restore(
          snapshot['learningEvidenceHistory'],
          snapshot['learningEvidenceLineage'],
        )!;
        return Act0AttemptArchiveV1.restore(
          snapshot['attemptArchive'],
          snapshotRecords: history.records,
        );
      }

      await _openSavedCourseTask(
        t,
        worldId: 'world_1',
        taskId: sourceId,
        legacyLessonId: 'what_poker_is',
        legacyCompletedIds: {'what_poker_is_theory'},
        restoreActive: true,
      );
      await answer('top');
      final miss = archive(await _saved(t)).attempts.single;
      expect(miss.evidence.taskId, sourceId);
      expect(miss.evidence.resultKind, 'incorrect');

      await _mount(t);
      await openArchive(t);
      final wrongRow = find.byKey(Key('act0_attempt_archive_entry_${miss.id}'));
      expect(
        find.descendant(
          of: wrongRow,
          matching: find.textContaining(' · Incorrect'),
        ),
        findsOneWidget,
      );
      final background = t
          .widget<Scaffold>(find.byKey(const Key('act0_shell_preview_screen')))
          .backgroundColor!;
      final rowTitle = t.widget<ListTile>(wrongRow).title! as Text;
      final heading = t.widget<Text>(find.text('Attempt archive'));
      for (final text in [heading, rowTitle]) {
        final fg = Color.alphaBlend(
          text.style!.color!,
          background,
        ).computeLuminance();
        final bg = background.computeLuminance();
        expect(
          (fg + 0.05) / (bg + 0.05),
          greaterThanOrEqualTo(4.5),
          reason: text.data,
        );
      }
      await tap(find.byKey(const Key('act0_attempt_archive_back')));
      expect(find.text('Your cards and the board'), findsWidgets);
      expect(find.text('Review: Private and shared cards'), findsOneWidget);
      await tap(find.byKey(const Key('act0_academy_review_leaf_repair_cta')));
      expect(runner().selectedTaskId, repairId);
      while (runner().runner.activeTeachingStep != null) {
        expect(
          await _tapFirst(t, [
            find.byKey(const Key('act0_shell_theory_continue_cta')),
            find.byKey(const Key('act0_shell_continue_cta')),
          ]),
          isTrue,
          reason: 'The Review repair intro must lead to the decision.',
        );
      }
      expect(runner().selectedTaskId, repairId);
      final correct = runner().runner.options.singleWhere((o) => o.isCorrect);
      await answer(correct.id);
      expect(
        find.textContaining(RegExp(r'^fixed$', caseSensitive: false)),
        findsWidgets,
      );
      expect(
        find.textContaining(RegExp(r'^correct read$', caseSensitive: false)),
        findsNothing,
      );

      final saved = await _saved(t);
      final fixed = archive(
        saved,
      ).attempts.firstWhere((a) => a.evidence.taskId == repairId);
      expect(fixed.evidence.resultKind, act0RepairedResultKindV1);
      final history = Act0LearningEvidenceHistoryV1.restore(
        saved['learningEvidenceHistory'],
        saved['learningEvidenceLineage'],
      )!;
      expect(
        Act0AchievementSeedProjectionV1.fromSources(
          learningEvidenceHistory: history,
        ).seedForId(act0AchievementSeedFirstCorrectReadV1).earned,
        isFalse,
      );

      await _mount(t);
      await openArchive(t);
      final fixedRow = find.byKey(
        Key('act0_attempt_archive_entry_${fixed.id}'),
      );
      expect(
        find.descendant(
          of: fixedRow,
          matching: find.textContaining(' · Fixed'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('opens empty from an older save and returns to Review', (
      t,
    ) async {
      await _openSavedCourseTask(
        t,
        worldId: 'world_7',
        taskId: 'visible_king_combo_reduction_intro',
      );

      await _mount(t);
      await openArchive(t);
      expect(find.text('No saved attempts yet.'), findsOneWidget);
      expect(await t.binding.handlePopRoute(), isTrue);
      await t.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_review_open_attempts')),
        findsOneWidget,
      );
    });

    testWidgets(
      'imports, replays, restores around corruption and deletes an own hand',
      (t) async {
        await _openSavedCourseTask(
          t,
          worldId: 'world_7',
          taskId: 'visible_king_combo_reduction_intro',
        );
        await _mount(t);
        await openArchive(t);
        Future<void> tap(String label) async {
          expect(await _tapFirst(t, [find.text(label)]), isTrue, reason: label);
        }

        await tap('Own hands');
        await tap('Import own hand');
        final fixture = File(
          'test/fixtures/hand_history/pokerstars_nlhe_usd_fold.txt',
        ).readAsStringSync();
        final text = find.widgetWithText(TextField, 'PokerStars hand history');
        await t.enterText(text, 'Other provider · PrivateName');
        await tap('Import hand');
        expect(find.textContaining('Unsupported format.'), findsOneWidget);
        await t.enterText(text, fixture.split('*** SUMMARY ***').first);
        await tap('Import hand');
        expect(
          find.textContaining(
            'Incomplete, invalid or unsupported hand details',
          ),
          findsOneWidget,
        );
        await t.enterText(text, fixture);
        await tap('Import hand');
        expect(find.text('Own hand · PokerStars'), findsOneWidget);
        expect(find.text('Betting decisions · Call price'), findsOneWidget);
        expect(find.text('Step 0 of 9'), findsOneWidget);
        final summary = t
            .widget<Act0AttemptReplayScreenV1>(
              find.byType(Act0AttemptReplayScreenV1),
            )
            .streetSummary;
        if (act0StreetSummaryPreviewV1) {
          expect(summary!.heroSeat, '1');
          expect(summary.streets, isEmpty);
          final frame = summary.frameAt(PokerStreet.preflop)!;
          expect(frame.potBb, closeTo(2, 1e-9));
          expect(frame.stacksBb, {'1': 99.0, '2': 99.0});
          expect(frame.foldedSeats, {'2'});
        } else {
          expect(summary, isNull);
        }
        await tap('Next');
        expect(find.textContaining('Button: seat 1.'), findsOneWidget);
        await tap('Next');
        expect(
          find.text(r'Preflop: seat 1 · Small blind $0.05 · Pot $0.05'),
          findsOneWidget,
        );
        await tap('Previous');
        expect(find.textContaining('Button: seat 1.'), findsOneWidget);
        await tap('Back to own hands');
        await tap('Import own hand');
        await t.enterText(text, fixture);
        await tap('Import hand');
        expect(find.text('This hand is already saved.'), findsOneWidget);
        await tap('Cancel');

        final saved = await _saved(t);
        final archive = saved['attemptArchive'] as Map;
        final hand = (archive['importedHands'] as List).single as Map;
        expect(jsonEncode(hand), isNot(contains('TestButton')));
        expect(jsonEncode(hand), isNot(contains('900000000102')));
        expect(archive['entries'], isEmpty);
        await t.pumpWidget(const SizedBox());
        // Seed one damaged record alongside the real save. The retained row
        // must still be reachable through the learner path after remount.
        SharedPreferences.setMockInitialValues({
          'act0_welcome_completed_v1': true,
          'intake_completed_v1': true,
          'act0_shell_progress_v1': jsonEncode({
            ...saved,
            'attemptArchive': {
              ...archive,
              'importedHands': [
                {...hand, 'sourceKey': 'c' * 64, 'potCents': 999},
                hand,
              ],
            },
          }),
        });
        await _mount(t);
        await openArchive(t);
        await tap('Own hands');
        expect(find.text('Replay hand'), findsOneWidget);
        await tap('Replay hand');
        expect(find.text('Own hand · PokerStars'), findsOneWidget);
        await tap('Practice call price');
        expect(
          t
              .widget<Act0LessonRunnerShellV1>(
                find.byType(Act0LessonRunnerShellV1),
              )
              .selectedTaskId,
          'w4_good_price_call',
        );
        await _mount(t);
        await openArchive(t);
        await tap('Own hands');
        await tap('Remove own hand');
        await tap('Cancel');
        expect(find.text('Replay hand'), findsOneWidget);
        await tap('Remove own hand');
        await tap('Remove hand');
        expect(find.text('No saved own hands.'), findsOneWidget);
        final deleted = await _saved(t);
        expect((deleted['attemptArchive'] as Map)['importedHands'], isNull);
        expect(
          deleted['learningEvidenceHistory'],
          saved['learningEvidenceHistory'],
        );
        await _mount(t);
        await openArchive(t);
        await tap('Own hands');
        expect(find.text('No saved own hands.'), findsOneWidget);
      },
    );

    testWidgets('saves the B20 prefix with the submitted attempt journal', (
      t,
    ) async {
      const taskId = 'w11_trigger_bad_price_fold';
      await _openSavedCourseTask(t, worldId: 'world_11', taskId: taskId);
      final runnerWidget = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      final runner = runnerWidget.runner;
      final prefix = runner.table.handTimelinePrefix!;
      final taskSummary = runnerWidget.streetSummary;
      if (act0StreetSummaryPreviewV1) {
        expect(taskSummary!.streets.map((row) => row.potAfterBb), [6, 10]);
        expect(taskSummary.frameAt(PokerStreet.turn), isNull);
      } else {
        expect(taskSummary, isNull);
      }
      expect(
        await _tapFirst(t, [find.byKey(const Key('act0_shell_option_fold'))]),
        isTrue,
      );

      final saved = await _saved(t);
      final history = Act0LearningEvidenceHistoryV1.restore(
        saved['learningEvidenceHistory'],
        saved['learningEvidenceLineage'],
      )!;
      final archive = Act0AttemptArchiveV1.restore(
        saved['attemptArchive'],
        snapshotRecords: history.records,
      );
      final attempt = archive.attempts.singleWhere(
        (row) => row.evidence.taskId == taskId,
      );
      expect(attempt.timelineSnapshot?.toPayload(), prefix.toPayload());
      final replay = Act0AttemptReplayScreenV1(
        attempt: attempt,
        onClose: () {},
      );
      final replaySummary = replay.streetSummary;
      if (act0StreetSummaryPreviewV1) {
        expect(replaySummary!.heroSeat, taskSummary!.heroSeat);
        expect(replaySummary.streets.map((row) => row.potAfterBb), [6, 10]);
        expect(replaySummary.frameAt(PokerStreet.turn), isNull);
      } else {
        expect(replaySummary, isNull);
      }
      expect(attempt.events.map((event) => event.label), [
        ...runner.table.actionTrail.map((event) => event.label),
        'Your choice: ${attempt.choiceLabel}',
      ]);
      final fallback = Act0ArchivedAttemptV1.tryParse({
        ...attempt.toPayload(),
        'handTimeline': {'version': 0},
      })!;
      expect(fallback.timelineSnapshot, isNull);
      expect(
        fallback.events.map((event) => event.label),
        attempt.events.map((event) => event.label),
      );
    });

    testWidgets('keeps the submitted attempt and deletion across restarts', (
      t,
    ) async {
      const taskId = 'visible_king_combo_reduction_intro';
      final xp = await _openSavedCourseTask(
        t,
        worldId: 'world_7',
        taskId: taskId,
      );
      final runner = t
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .runner;
      expect(
        await _tapFirst(t, [
          find.byKey(const Key('act0_shell_option_king_combos_unchanged')),
        ]),
        isTrue,
      );
      final before = await _saved(t);
      final history = Act0LearningEvidenceHistoryV1.restore(
        before['learningEvidenceHistory'],
        before['learningEvidenceLineage'],
      );
      expect(history, isNotNull);
      final snapshot = before['attemptArchive'] as Map;
      final archive = Act0AttemptArchiveV1.restore(
        snapshot,
        snapshotRecords: history!.records,
      );
      final entry = archive.attempts.single.toPayload();
      final evidence = entry['evidence'] as Map;
      final savedEntry = (snapshot['entries'] as List).single as Map;
      expect(savedEntry['recordId'], evidence['recordId']);
      expect(savedEntry.containsKey('evidence'), isFalse);
      expect(evidence['taskId'], taskId);
      expect(evidence['choiceId'], 'king_combos_unchanged');
      expect(evidence['isCorrect'], isFalse);
      expect(evidence['authoredSourceFingerprint'], hasLength(64));
      expect(evidence['recordedAtUtc'], isNotNull);
      expect(entry['taskLabel'], runner.question);
      expect(entry['choiceLabel'], isNotEmpty);
      expect((entry['events'] as List).map((event) => event['label']), [
        ...runner.table.actionTrail.map((item) => item.label),
        'Your choice: ${entry['choiceLabel']}',
      ]);
      final key = Key('act0_attempt_archive_entry_${evidence['recordId']}');
      await _mount(t);
      await openArchive(t);
      final search = find.byKey(const Key('act0_attempt_archive_search'));
      await t.enterText(search, 'no matching attempt');
      await t.pumpAndSettle();
      expect(find.text('No matching attempts.'), findsOneWidget);
      expect(find.byKey(key), findsNothing);
      await t.enterText(search, '  VISIBLE_KING  ');
      await t.pumpAndSettle();
      expect(find.byKey(key), findsOneWidget);
      await t.enterText(search, '');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pumpAndSettle();
      expect(await _tapFirst(t, [find.byKey(key)]), isTrue);
      expect(find.text('Your choice: ${entry['choiceLabel']}'), findsOneWidget);
      expect(find.text('Help: none'), findsOneWidget);
      expect(
        await _tapFirst(t, [
          find.byKey(const Key('act0_attempt_archive_open_replay')),
        ]),
        isTrue,
      );
      expect(
        find.text('Step 0 of ${(entry['events'] as List).length}'),
        findsOneWidget,
      );
      expect(
        await _tapFirst(t, [find.byKey(const Key('act0_attempt_replay_next'))]),
        isTrue,
      );
      final firstEvent = (entry['events'] as List).first as Map;
      expect(
        find.text(
          (firstEvent['displayLabel'] ?? firstEvent['label']) as String,
        ),
        findsOneWidget,
      );
      expect(await t.binding.handlePopRoute(), isTrue);
      await t.pumpAndSettle();
      expect(find.text('Your choice: ${entry['choiceLabel']}'), findsOneWidget);
      final selected = await _saved(t);
      expect(
        (selected['attemptArchive'] as Map)['selectedId'],
        evidence['recordId'],
      );

      await _mount(t);
      await openArchive(t);
      expect(find.text('Your choice: ${entry['choiceLabel']}'), findsOneWidget);
      expect(
        await _tapFirst(t, [
          find.byKey(const Key('act0_attempt_archive_remove')),
        ]),
        isTrue,
      );
      expect(
        await _tapFirst(t, [
          find.byKey(const Key('act0_attempt_archive_confirm_remove')),
        ]),
        isTrue,
      );
      expect(find.text('No saved attempts yet.'), findsOneWidget);
      await _mount(t);
      await openArchive(t);
      expect(find.byKey(key), findsNothing);
      final after = await _saved(t);
      expect((after['attemptArchive'] as Map)['entries'], isEmpty);
      expect(
        after['learningEvidenceHistory'],
        before['learningEvidenceHistory'],
      );
      expect(after['earnedXp'], xp);
      expect(after['completedTaskIds'], before['completedTaskIds']);
    });
  });

  testWidgets('a W7 king miss persists the same exercise for replay', (
    t,
  ) async {
    const taskId = 'visible_king_combo_reduction_intro';
    final xp = await _openSavedCourseTask(
      t,
      worldId: 'world_7',
      taskId: taskId,
    );
    expect(
      await _tapFirst(t, [
        find.byKey(const Key('act0_shell_option_king_combos_unchanged')),
      ]),
      isTrue,
    );
    Map<dynamic, dynamic> repair(Map<String, dynamic> snapshot) =>
        (snapshot['openRepairIntents'] as List).cast<Map>().singleWhere(
          (row) => row['sourceTaskId'] == taskId,
        );
    final before = await _saved(t);
    final intent = repair(before);
    expect(intent['targetTaskId'], taskId);
    expect(intent['mappingType'], 'intentional_exact');
    expect(intent['repairOccurrenceId'], isNotEmpty);
    expect(before['earnedXp'], xp);

    await _mount(t);
    final restored = await _saved(t);
    expect(repair(restored), intent);
    expect(restored['earnedXp'], xp);
    expect(restored['completedTaskIds'], before['completedTaskIds']);
  });

  testWidgets('a W6 suited-combo miss opens the earlier suited comparison', (
    t,
  ) async {
    const taskId = 'w6_checkpoint_table_best_five';
    const targetId = 'w6_pair_vs_suited_weight_compare';
    final firstSuitedComparison = act0RepairGoalContractForSourceV1(
      worldId: 'world_6',
      lessonId: 'range_thinking_checkpoint',
      taskId: targetId,
      choiceId: 'kq_suited',
    );
    expect(firstSuitedComparison?.targetTaskId, targetId);
    expect(firstSuitedComparison?.mappingType, 'intentional_exact');
    final xp = await _openSavedCourseTask(
      t,
      worldId: 'world_6',
      taskId: taskId,
    );
    expect(
      await _tapFirst(t, [
        find.byKey(const Key('act0_shell_option_hero_wins')),
      ]),
      isTrue,
    );

    Map<dynamic, dynamic> sourceRepair(Map<String, dynamic> saved) =>
        (saved['openRepairIntents'] as List).cast<Map>().singleWhere(
          (row) => row['sourceTaskId'] == taskId,
        );
    Map<dynamic, dynamic> sourceAnswer(Map<String, dynamic> saved) =>
        (saved['learningEvidenceHistory'] as List).cast<Map>().singleWhere(
          (row) => row['taskId'] == taskId,
        );
    final before = await _saved(t);
    expect(sourceRepair(before)['targetTaskId'], targetId);
    expect(sourceAnswer(before)['choiceId'], 'hero_wins');
    expect(sourceAnswer(before)['isCorrect'], isFalse);
    expect(before['earnedXp'], xp);
    expect(
      await _tapFirst(t, [
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      ]),
      isTrue,
    );
    expect(
      t
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      targetId,
    );

    await _mount(t);
    final restored = await _saved(t);
    expect(sourceRepair(restored), sourceRepair(before));
    expect(sourceAnswer(restored), sourceAnswer(before));
    expect(restored['earnedXp'], xp);
    expect(restored['completedTaskIds'], before['completedTaskIds']);
  });

  for (final (name, worldId, taskId, choiceId, targetId) in const [
    (
      'a W9 yellow-zone miss reopens yellow-zone planning',
      'world_9',
      'w9_m_ratio_table_window_transfer',
      'wait_for_red',
      'w9_m_ratio_yellow_zone',
    ),
    (
      'a W10 blind-overfold miss reopens the one-lever exercise',
      'world_10',
      'w10_checkpoint_lever_line',
      'fold',
      'w10_vs_nit_open_wider',
    ),
    (
      'a W11 small-blind call miss reopens the value three-bet',
      'world_11',
      'w11_checkpoint_plan_line',
      'call_2_bb',
      'w11_sb_3bet_value',
    ),
    (
      'a W12 outcome-bias miss reopens reviewing the decision',
      'world_12',
      'w12_checkpoint_process_line',
      'fold_after_last_orbit_s_loss',
      'w12_good_fold_bad_result',
    ),
  ]) {
    testWidgets(name, (t) async {
      final xp = await _openSavedCourseTask(
        t,
        worldId: worldId,
        taskId: taskId,
      );
      expect(
        await _tapFirst(t, [find.byKey(Key('act0_shell_option_$choiceId'))]),
        isTrue,
      );

      Map<dynamic, dynamic> sourceRepair(Map<String, dynamic> saved) =>
          (saved['openRepairIntents'] as List).cast<Map>().singleWhere(
            (row) => row['sourceTaskId'] == taskId,
          );
      final before = await _saved(t);
      final intent = sourceRepair(before);
      expect(intent['targetTaskId'], targetId);
      expect(intent['mappingType'], 'repair');
      expect(before['earnedXp'], xp);
      expect(
        await _tapFirst(t, [
          find.byKey(const Key('act0_shell_feedback_continue_cta')),
        ]),
        isTrue,
      );
      expect(
        t
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        targetId,
      );

      await _mount(t);
      final restored = await _saved(t);
      expect(sourceRepair(restored), intent);
      expect(
        restored['learningEvidenceHistory'],
        before['learningEvidenceHistory'],
      );
      expect(restored['earnedXp'], xp);
      expect(restored['completedTaskIds'], before['completedTaskIds']);
    });
  }

  testWidgets('pre-Q8 save keeps Position Thinking credit', (t) async {
    const insertedTasks = {
      'position_six_seats_position_order_reason',
      'button_advantage_button_order_reason',
    };
    final state = Act0ShellStateV1.sample;
    final priorLessons = [
      for (final world in state.worlds.take(3))
        for (final lesson in world.lessons)
          if (lesson.lessonId != 'w3_play_from_blinds') lesson,
    ];
    final priorTasks = [
      for (final lesson in priorLessons)
        for (final task in lesson.courseTaskList)
          if (!insertedTasks.contains(task.taskId)) task,
    ];
    final priorXp = priorTasks.fold(0, (sum, task) => sum + task.rewardXp);
    final w4 = state.worldById('world_4').lessons.first;
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': <Object>[],
        'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
            .lineagePayload(),
        'durableRetentionHistory': <Object>[],
        'completedTaskIds': priorTasks.map((task) => task.taskId).toList(),
        'completedLessonIds': priorLessons
            .map((lesson) => lesson.lessonId)
            .toList(),
        'skippedTaskIds': <String>[],
        'earnedXp': priorXp,
        'selectedWorldId': 'world_4',
        'selectedLessonId': w4.lessonId,
        'selectedTaskId': w4.courseTaskList.first.taskId,
      }),
    });
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await _mount(t);
    await t.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await t.pumpAndSettle();
    expect(
      await _tapFirst(
        t,
        _continueKeys.map((key) => find.byKey(Key(key))).toList(),
      ),
      isTrue,
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, 'position_six_seats_position_order_reason');
    final saved = await _saved(t);
    expect(
      saved['completedTaskIds'],
      unorderedEquals(priorTasks.map((task) => task.taskId)),
    );
    expect(saved['earnedXp'], priorXp);
    expect(saved['skippedTaskIds'], isEmpty);
  });

  testWidgets('W9 text theory opens without a table', (t) async {
    await _openSavedCourseTask(
      t,
      worldId: 'world_9',
      taskId: 'w9_survival_intro',
      finishTeaching: false,
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, 'w9_survival_intro');
    expect(
      runner.runner.activeTeachingStep?.body,
      contains('EV stands for expected value.'),
    );
    expect(
      find.textContaining('expected value', findRichText: true),
      findsWidgets,
      reason: t
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? text.textSpan?.toPlainText())
          .whereType<String>()
          .toList()
          .join(' | '),
    );
    expect(find.byKey(const Key('act0_shell_table')), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('W10 text theory opens without a table', (t) async {
    await _openSavedCourseTask(
      t,
      worldId: 'world_10',
      taskId: 'w10_player_type_intro',
      finishTeaching: false,
    );
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, 'w10_player_type_intro');
    expect(
      runner.runner.activeTeachingStep?.body,
      allOf(
        contains('A nit folds often.'),
        contains('LAG means loose-aggressive'),
      ),
    );
    expect(
      find.textContaining('A nit', findRichText: true),
      findsWidgets,
      reason: t
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? text.textSpan?.toPlainText())
          .whereType<String>()
          .toList()
          .join(' | '),
    );
    expect(find.byKey(const Key('act0_shell_table')), findsNothing);
    expect(t.takeException(), isNull);
  });
}

void registerLongSessionRoutes({({int first, int last})? tierARange}) {
  final fullRoute =
      tierARange == null &&
      const bool.fromEnvironment('ACT0_LONG_SESSION_FULL_ROUTE');
  final w7ToW8 =
      tierARange == null &&
      const bool.fromEnvironment('ACT0_LONG_SESSION_W7_TO_W8');
  final pilot = tierARange == null && act0CurriculumPilotEnabledV1 && !w7ToW8;
  final lastWorld =
      tierARange?.last ??
      (pilot ? act0LastCurriculumWorldV1 : (w7ToW8 ? 8 : (fullRoute ? 12 : 7)));
  final firstWorlds = [
    if (tierARange != null)
      tierARange.first
    else if (pilot)
      13
    else if (w7ToW8)
      7
    else ...[
      1,
      if (fullRoute) 2,
    ],
  ];
  for (final firstWorld in firstWorlds) {
    final expectedWorlds = {
      for (var world = firstWorld; world <= lastWorld; world++) world,
    };
    final useRulesCheck = firstWorld == 2;
    final restoreSaved =
        w7ToW8 || pilot || (tierARange != null && firstWorld > 1);
    final checkNextWorld = tierARange != null && lastWorld < 7;
    testWidgets(
      'a ${restoreSaved ? 'returning' : 'fresh'} learner finishes W$firstWorld–W$lastWorld with mistakes, retries and restarts',
      (t) async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        t.view.physicalSize = const Size(393, 852);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        const b19MissTasks = {
          'mistake_half_pot',
          'turn_heart_completes',
          'harder_river_value_added',
        };
        final confirmedB19Misses = <String>{};
        final catalog = Act0ShellStateV1.sample;
        final priorTaskIds = {
          if (tierARange != null && restoreSaved)
            for (final world in catalog.worlds)
              if (world.worldNumber < firstWorld)
                for (final lesson in world.lessons)
                  for (final task in lesson.courseTaskList) task.taskId,
        };
        final worlds = catalog.worlds
            .where(
              (w) => w.worldNumber >= firstWorld && w.worldNumber <= lastWorld,
            )
            .toList();
        final taskWorld = {
          for (final w in worlds)
            for (final l in w.lessons)
              for (final task in l.courseTaskList) task.taskId: w.worldNumber,
        };
        final nextWorldTaskId = checkNextWorld
            ? catalog
                  .worldById('world_${lastWorld + 1}')
                  .lessons
                  .first
                  .courseTaskList
                  .first
                  .taskId
            : null;
        final repairWorld = {
          for (final w in worlds)
            for (final l in w.lessons)
              for (final task in l.taskList)
                if (task.repairOnly) task.taskId: w.worldNumber,
        };
        final rewards = {
          for (final w in worlds)
            for (final l in w.lessons)
              for (final task in l.taskList) task.taskId: task.rewardXp,
        };
        final answered = <String>{};
        final missedWorlds = <int>{};
        final confirmedMisses = <int>{};
        final restartedWorlds = <int>{};
        final enteredWorlds = <int>{};
        var complete = false;
        const w7Checkpoint = 'w7_checkpoint_river_card_excludes_hand';
        var priorXp = 0;
        if (restoreSaved) {
          priorXp = await _openSavedCourseTask(
            t,
            worldId: 'world_$firstWorld',
            taskId: worlds.first.lessons.first.courseTaskList.first.taskId,
            finishTeaching: tierARange == null,
            persistSeed: tierARange != null,
          );
        } else {
          await _mount(t, firstRun: true);
          await _onboard(t, useRulesCheck: useRulesCheck);
        }

        for (
          var step = 0;
          step < (fullRoute ? 5200 : 3600) && !complete;
          step++
        ) {
          Map<String, dynamic>? routeSnapshot;
          if (act0RoutePracticeFinder.evaluate().isNotEmpty) {
            final runner = t
                .widget<Act0LessonRunnerShellV1>(
                  find.descendant(
                    of: act0RoutePracticeFinder,
                    matching: find.byType(Act0LessonRunnerShellV1),
                  ),
                )
                .runner;
            if (runner.phase == Act0LessonPhaseV1.drill) {
              await answerAct0RoutePracticeV1(t, correct: false);
            } else {
              await tapAct0RoutePracticeKeyV1(
                t,
                'act0_shell_feedback_continue_cta',
              );
            }
            continue;
          }
          final runnerFinder = find.byType(Act0LessonRunnerShellV1);
          if (runnerFinder.evaluate().isNotEmpty) {
            final shell = t.widget<Act0LessonRunnerShellV1>(runnerFinder.first);
            final runner = shell.runner;
            final taskId = shell.selectedTaskId ?? '';
            final atNextWorld = taskId == nextWorldTaskId;
            final world = atNextWorld
                ? lastWorld + 1
                : taskWorld[taskId] ?? repairWorld[taskId];
            if (world == null) break; // Never answer a future-world task.
            if (repairWorld.containsKey(taskId)) {
              expect(confirmedMisses, contains(world), reason: taskId);
            }
            if (enteredWorlds.add(world)) {
              if (!w7ToW8 && taskId == 'visible_ace_combo_reduction_intro') {
                expect(runner.phase, Act0LessonPhaseV1.theory);
                expect(runner.options, hasLength(4));
                expect(
                  find.byKey(
                    const Key('act0_shell_accessibility_answer_group'),
                  ),
                  findsNothing,
                );
                expect(
                  find.byKey(const Key('act0_shell_continue_cta')),
                  findsOneWidget,
                );
              }
              final snapshot = await _saved(t);
              final completed = (snapshot['completedTaskIds'] as List)
                  .cast<String>()
                  .toSet();
              final prerequisites = {
                ...priorTaskIds,
                for (final entry in taskWorld.entries)
                  if (entry.value < world) entry.key,
              };
              expect(
                completed.containsAll(prerequisites),
                isTrue,
                reason:
                    'W$world unlocked before ${prerequisites.difference(completed)}',
              );
            }
            if (atNextWorld) {
              complete = true;
              break;
            }
            if (_tapLog.isEmpty || _tapLog.last != '@$taskId')
              _tapLog.add('@$taskId');
            final deciding =
                runner.phase == Act0LessonPhaseV1.drill &&
                runner.activeTeachingStep == null &&
                runner.selectedOptionId == null &&
                runner.options.isNotEmpty;
            if (deciding) {
              await pumpSourceChoreographyToDecisionV1(t, runner.table);
              final wrong = runner.options.where((o) => !o.isCorrect).toList();
              final b19Miss =
                  pilot &&
                  b19MissTasks.contains(taskId) &&
                  !answered.contains(taskId);
              final injectMiss =
                  b19Miss ||
                  (!missedWorlds.contains(world) &&
                      wrong.isNotEmpty &&
                      (world != 7 || taskId == w7Checkpoint));
              final choice = injectMiss
                  ? wrong.first
                  : runner.options.firstWhere(
                      pilot
                          ? act0RunnerOptionIsPreferredV1
                          : (o) => o.isCorrect,
                    );
              if (injectMiss) missedWorlds.add(world);
              final tapped = await _tapFirst(t, [
                if (runner.sizingConfig.isEnabled)
                  find.byKey(Key('act0_shell_sizing_preset_${choice.id}')),
                find.byKey(Key('act0_shell_option_${choice.id}')),
                if (choice.seatId case final seatId?) ...[
                  find.byKey(Key('act0_shell_seat_tap_$seatId')),
                  find.descendant(
                    of: find.byKey(Key('act0_shell_seat_tap_$seatId')),
                    matching: find.text(seatId.toUpperCase()),
                  ),
                ],
              ]);
              expect(tapped, isTrue, reason: '$taskId: no answer');
              if (runner.sizingConfig.isEnabled) {
                expect(
                  await _tapFirst(t, [
                    find.byKey(const Key('act0_shell_sizing_confirm_cta')),
                  ]),
                  isTrue,
                );
              }
              if (injectMiss) {
                expect(
                  find.byKey(const Key('act0_shell_feedback_continue_cta')),
                  findsOneWidget,
                  reason: '$taskId should show a way to continue from feedback',
                );
                final missSnapshot = await _saved(t);
                final evidence =
                    (missSnapshot['learningEvidenceHistory'] as List)
                        .cast<Map>();
                expect(
                  evidence.any(
                    (r) => r['taskId'] == taskId && r['isCorrect'] == false,
                  ),
                  isTrue,
                );
                if (taskId == w7Checkpoint) {
                  expect(
                    find.textContaining('The 2♠ is on the board').last,
                    findsOneWidget,
                  );
                }
                confirmedMisses.add(world);
                if (b19Miss) confirmedB19Misses.add(taskId);
              }
              answered.add(taskId);
              final worldAnswered = answered
                  .where((id) => taskWorld[id] == world)
                  .length;
              final worldTotal = taskWorld.values
                  .where((n) => n == world)
                  .length;
              if (!restartedWorlds.contains(world) &&
                  (world == 7
                      ? taskId == w7Checkpoint && injectMiss
                      : worldAnswered >= worldTotal ~/ 2)) {
                final before = await _saved(t);
                await _mount(t);
                final after = await _saved(t);
                expect(after['completedTaskIds'], before['completedTaskIds']);
                expect(after['earnedXp'], before['earnedXp']);
                expect(after['selectedWorldId'], before['selectedWorldId']);
                expect(after['selectedTaskId'], before['selectedTaskId']);
                restartedWorlds.add(world);
                // A learner can return to Learn even while an open repair is shown on Home.
                await _tapFirst(t, [find.text('Learn').last]);
                await _tapFirst(t, [
                  find.byKey(const Key('act0_shell_current_mission_cta')),
                ]);
              }
              continue;
            }
          } else {
            routeSnapshot = await _saved(t);
            final completed = (routeSnapshot['completedTaskIds'] as List)
                .cast<String>()
                .toSet();
            complete = !checkNextWorld && completed.containsAll(taskWorld.keys);
            if (complete) break;
          }
          // The summary can promote a saved review above the course route.
          // This traversal follows the map once the in-lesson retry is done.
          var moved = await _tapFirst(t, [
            if (find.text('Practice this clue').evaluate().isNotEmpty)
              find.byKey(const Key('act0_shell_block_summary_map_cta')),
            find.byKey(const Key('act0_shell_theory_continue_cta')),
            for (final key in _continueKeys) find.byKey(Key(key)),
          ]);
          final mission = find.byKey(
            const Key('act0_shell_current_mission_cta'),
          );
          final levels = find.byKey(const Key('act0_shell_levels_menu_button'));
          if (!moved &&
              find
                  .byKey(const Key('act0_academy_review_leaf'))
                  .evaluate()
                  .isNotEmpty) {
            await _tapFirst(t, [find.text('Learn').last]);
          }
          if (!moved && levels.evaluate().isNotEmpty) {
            routeSnapshot ??= await _saved(t);
            final completed = (routeSnapshot['completedTaskIds'] as List)
                .cast<String>()
                .toSet();
            final nextWorld =
                taskWorld.entries
                    .where((entry) => !completed.contains(entry.key))
                    .firstOrNull
                    ?.value ??
                lastWorld + 1;
            // A summary can open the map of the world just completed. Choose
            // the next unlocked world using the same menu a learner uses.
            if (routeSnapshot['selectedWorldId'] != 'world_$nextWorld') {
              expect(await _tapFirst(t, [levels]), isTrue);
              final world = find.byKey(Key('act0_shell_world_$nextWorld'));
              if (world.evaluate().isEmpty) {
                await t.scrollUntilVisible(
                  world,
                  250,
                  scrollable: find.descendant(
                    of: find.byKey(
                      const Key('act0_shell_worlds_content_scroll'),
                    ),
                    matching: find.byType(Scrollable),
                  ),
                );
              }
              expect(
                await _tapFirst(t, [world]),
                isTrue,
                reason: 'The level menu should offer W$nextWorld',
              );
            }
            moved = await _tapFirst(t, [mission]);
          }
          final visible = moved
              ? ''
              : t
                    .widgetList<Text>(find.byType(Text))
                    .map((widget) => widget.data)
                    .whereType<String>()
                    .take(18)
                    .join(' | ');
          expect(
            moved,
            isTrue,
            reason:
                'Step $step stalled; recent taps: ${_tapLog.reversed.take(12).toList()}; visible: $visible',
          );
        }
        final snapshot = await _saved(t);
        final completed = (snapshot['completedTaskIds'] as List)
            .cast<String>()
            .toSet();
        expect(taskWorld.keys.toSet().difference(completed), isEmpty);
        expect(priorTaskIds.difference(completed), isEmpty);
        if (checkNextWorld) {
          expect(enteredWorlds, contains(lastWorld + 1));
        }
        final practiced =
            ((snapshot['routePractice'] as Map?)?['finished'] as List?) ??
            const [];
        expect(
          practiced.toSet(),
          {
            for (final world in worlds)
              for (final step in act0RoutePracticeStepsV1(world)) step.id,
          },
          reason:
              'Every scheduled practice boundary was completed on the route',
        );
        final w1Ids = Act0ShellStateV1.sample
            .worldById('world_1')
            .lessons
            .expand((lesson) => lesson.courseTaskList)
            .map((task) => task.taskId)
            .toSet();
        final expectedCount = pilot
            ? 210
            : w7ToW8
            ? 43 + y5cTasksInWorldV1(7) + y5cTasksInWorldV1(8)
            : (fullRoute
                      ? 452 + wave6TaskDeltaV1 + y5dNewChoicesV1.length
                      : 297) +
                  w3BlindVsBlindChoicesV1.length +
                  y5bNewChoicesV1.length +
                  (fullRoute ? y5cNewChoicesV1.length : y5cTasksInWorldV1(7));
        expect(
          tierARange != null
              ? catalog.worlds
                    .where((world) => world.worldNumber <= 7)
                    .expand((world) => world.lessons)
                    .expand((lesson) => lesson.courseTaskList)
                    .length
              : taskWorld.length,
          useRulesCheck ? expectedCount - w1Ids.length : expectedCount,
        );
        if (useRulesCheck) expect(completed.intersection(w1Ids), isEmpty);
        if (fullRoute && !w7ToW8 && !pilot) {
          expect(completed, contains('w12_checkpoint_full_loop_line'));
          expect(completed, contains('w12_checkpoint_review'));
        }
        expect(missedWorlds, expectedWorlds);
        expect(restartedWorlds, expectedWorlds);
        expect(snapshot['skippedTaskIds'], isEmpty);
        expect(
          snapshot['earnedXp'],
          completed.fold<int>(
            useRulesCheck
                ? act0W1RulesQuestionsV1.length *
                      Act0W1RulesResultV1.xpPerCorrectAnswer
                : priorXp,
            (sum, id) => sum + (rewards[id] ?? 0),
          ),
        );
        expect(confirmedMisses, expectedWorlds);
        if (pilot) expect(confirmedB19Misses, b19MissTasks);
        if (fullRoute || pilot) {
          await _mount(t);
          final restored = await _saved(t);
          expect(restored['completedTaskIds'], snapshot['completedTaskIds']);
          expect(restored['earnedXp'], snapshot['earnedXp']);
        }
        expect(t.takeException(), isNull);
      },
      timeout: Timeout(
        Duration(minutes: fullRoute ? 8 : (tierARange != null ? 6 : 5)),
      ),
    );
  }
}
