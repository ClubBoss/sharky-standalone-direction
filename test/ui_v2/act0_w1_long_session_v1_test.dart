import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_source_choreography_test_wait_v1.dart';

// Long session through the real app shell on iPhone 14 Pro: a fresh learner
// goes through Worlds 1–7 by default, or 1–12 with
// --dart-define=ACT0_LONG_SESSION_FULL_ROUTE=true. The app is
// restarted in every world, and progress must carry on from where it stopped.
// Any exception thrown by the app fails the test.
const _continueKeys = [
  'act0_shell_feedback_continue_cta',
  'act0_shell_block_summary_continue_cta',
  'act0_shell_continue_cta',
  'act0_shell_welcome_primary_cta',
  'act0_shell_main_cta',
  'act0_academy_home_leaf_cta',
];

Future<void> _mount(WidgetTester t, {bool firstRun = false}) async {
  await t.pumpWidget(
    MaterialApp(
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

// First run exactly as a new learner does it: placement "new", then Welcome
// with its demo answer, then Home.
Future<void> _onboard(WidgetTester t) async {
  for (final k in [
    'act0_shell_placement_intro_cta',
    'act0_shell_placement_option_new',
    'act0_shell_placement_next_cta',
    'act0_shell_welcome_primary_cta',
  ]) {
    await t.tap(find.byKey(Key(k)));
    await t.pumpAndSettle();
  }
  final demo = t
      .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
      .runner
      .options
      .firstWhere((o) => o.isCorrect);
  await t.tap(find.byKey(Key('act0_shell_option_${demo.id}')));
  await t.pumpAndSettle();
  await t.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
  await t.pumpAndSettle();
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

void main() {
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
    expect(runner.selectedTaskId, 'hand_rankings_theory');
    final saved = await _saved(t);
    expect((saved['completedTaskIds'] as List).toSet(), oldCompleted.toSet());
    expect(saved['earnedXp'], oldXp);
    expect(saved['skippedTaskIds'], isEmpty);
    expect(t.takeException(), isNull);
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
      const MaterialApp(
        locale: Locale('en'),
        home: Act0ShellPreviewScreenV1(
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

  const fullRoute = bool.fromEnvironment('ACT0_LONG_SESSION_FULL_ROUTE');
  const lastWorld = fullRoute ? 12 : 7;
  final expectedWorlds = {
    for (var world = 1; world <= lastWorld; world++) world,
  };
  testWidgets(
    'a fresh learner finishes W1–W$lastWorld with mistakes, retries and restarts',
    (t) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final worlds = Act0ShellStateV1.sample.worlds
          .where((w) => w.worldNumber >= 1 && w.worldNumber <= lastWorld)
          .toList();
      final taskWorld = {
        for (final w in worlds)
          for (final l in w.lessons)
            for (final task in l.taskList) task.taskId: w.worldNumber,
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
      await _mount(t, firstRun: true);
      await _onboard(t);

      for (
        var step = 0;
        step < (fullRoute ? 5200 : 3600) && !complete;
        step++
      ) {
        final runnerFinder = find.byType(Act0LessonRunnerShellV1);
        if (runnerFinder.evaluate().isNotEmpty) {
          final shell = t.widget<Act0LessonRunnerShellV1>(runnerFinder.first);
          final runner = shell.runner;
          final taskId = shell.selectedTaskId ?? '';
          final world = taskWorld[taskId];
          if (world == null) break; // Never answer a future-world task.
          if (enteredWorlds.add(world)) {
            if (taskId == 'visible_ace_combo_reduction_intro') {
              expect(runner.phase, Act0LessonPhaseV1.theory);
              expect(runner.options, hasLength(4));
              expect(
                find.byKey(const Key('act0_shell_accessibility_answer_group')),
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
            final prerequisites = taskWorld.entries
                .where((e) => e.value < world)
                .map((e) => e.key)
                .toSet();
            expect(
              completed.containsAll(prerequisites),
              isTrue,
              reason:
                  'W$world unlocked before ${prerequisites.difference(completed)}',
            );
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
            final injectMiss =
                !missedWorlds.contains(world) && wrong.isNotEmpty;
            final choice = injectMiss
                ? wrong.first
                : runner.options.firstWhere((o) => o.isCorrect);
            if (injectMiss) missedWorlds.add(world);
            final tapped = await _tapFirst(t, [
              if (runner.sizingConfig.isEnabled)
                find.byKey(Key('act0_shell_sizing_preset_${choice.id}')),
              find.byKey(Key('act0_shell_option_${choice.id}')),
              if (choice.seatId != null)
                find.byKey(Key('act0_shell_seat_tap_${choice.seatId}')),
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
              final evidence = (missSnapshot['learningEvidenceHistory'] as List)
                  .cast<Map>();
              expect(
                evidence.any(
                  (r) => r['taskId'] == taskId && r['isCorrect'] == false,
                ),
                isTrue,
              );
              confirmedMisses.add(world);
            }
            answered.add(taskId);
            final worldAnswered = answered
                .where((id) => taskWorld[id] == world)
                .length;
            final worldTotal = taskWorld.values.where((n) => n == world).length;
            if (!restartedWorlds.contains(world) &&
                worldAnswered >= worldTotal ~/ 2) {
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
          final snapshot = await _saved(t);
          final completed = (snapshot['completedTaskIds'] as List)
              .cast<String>()
              .toSet();
          complete = completed.containsAll(taskWorld.keys);
          if (complete) break;
        }
        final moved = await _tapFirst(t, [
          find.byKey(const Key('act0_shell_theory_continue_cta')),
          for (final key in _continueKeys) find.byKey(Key(key)),
        ]);
        expect(
          moved,
          isTrue,
          reason:
              'Step $step stalled; recent taps: ${_tapLog.reversed.take(12).toList()}',
        );
      }
      final snapshot = await _saved(t);
      final completed = (snapshot['completedTaskIds'] as List)
          .cast<String>()
          .toSet();
      expect(taskWorld.keys.toSet().difference(completed), isEmpty);
      expect(taskWorld.length, fullRoute ? 369 : 255);
      if (fullRoute) {
        expect(completed, contains('w12_checkpoint_full_loop_line'));
        expect(completed, contains('w12_checkpoint_review'));
      }
      expect(missedWorlds, expectedWorlds);
      expect(restartedWorlds, expectedWorlds);
      expect(snapshot['skippedTaskIds'], isEmpty);
      expect(
        snapshot['earnedXp'],
        completed.fold<int>(0, (sum, id) => sum + (rewards[id] ?? 0)),
      );
      expect(confirmedMisses, expectedWorlds);
      if (fullRoute) {
        await _mount(t);
        final restored = await _saved(t);
        expect(restored['completedTaskIds'], snapshot['completedTaskIds']);
        expect(restored['earnedXp'], snapshot['earnedXp']);
      }
      expect(t.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: fullRoute ? 8 : 5)),
  );
}
