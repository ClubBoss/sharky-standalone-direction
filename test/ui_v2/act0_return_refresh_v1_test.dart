import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_home_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_return_refresh_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_route_practice_runner_test_v1.dart';
import '../support/act0_source_choreography_test_wait_v1.dart';

void main() {
  const pool = <String, List<String>>{
    'a': ['position'],
    'b': ['position'],
    'c': ['pot'],
    'd': ['cards'],
    'e': ['blinds'],
    'f': ['board'],
    'g': ['hands'],
  };
  List<String>? plan(
    String last,
    String today, {
    Map<String, Iterable<String>> drills = pool,
    Map<String, DateTime> history = const {},
  }) => act0ReturnRefreshPlanV1(
    lastActiveDay: last,
    today: today,
    finishedDrills: drills,
    lastSeenByDrill: history,
  );

  test('six vs seven civil days; invalid and future keys never offer', () {
    expect(plan('2026-11-18', '2026-11-24'), isNull);
    expect(plan('2026-11-18', '2026-11-25'), hasLength(5));
    expect(plan('', '2026-11-25'), isNull);
    expect(plan('2026-02-30', '2026-03-09'), isNull);
    expect(plan('2026-11-26', '2026-11-25'), isNull);
  });
  test('spring and autumn DST boundaries count civil days', () {
    expect(plan('2026-03-04', '2026-03-10'), isNull);
    expect(plan('2026-03-04', '2026-03-11'), hasLength(5));
    expect(plan('2026-10-29', '2026-11-04'), isNull);
    expect(plan('2026-10-29', '2026-11-05'), hasLength(5));
  });
  test('empty, tiny and insufficient distinct skills have no offer', () {
    expect(plan('2026-11-18', '2026-11-25', drills: {}), isNull);
    expect(
      plan(
        '2026-11-18',
        '2026-11-25',
        drills: {
          'a': ['a'],
          'b': ['b'],
        },
      ),
      isNull,
    );
    expect(
      plan(
        '2026-11-18',
        '2026-11-25',
        drills: {
          'a': ['a'],
          'b': ['a'],
          'c': ['b'],
        },
      ),
      isNull,
    );
  });
  test('longest unseen skill first, one drill per skill, stable ties', () {
    final history = {
      'a': DateTime.utc(2026, 11, 1),
      'b': DateTime.utc(2026, 11, 15),
      'c': DateTime.utc(2026, 11, 3),
      'd': DateTime.utc(2026, 11, 5),
      'e': DateTime.utc(2026, 11, 6),
      'f': DateTime.utc(2026, 11, 7),
    };
    // Position was seen recently in b, despite a being the oldest drill.
    final result = plan('2026-11-18', '2026-11-25', history: history);
    expect(result, ['g', 'c', 'd', 'e', 'f']);
    expect(
      plan(
        '2026-11-18',
        '2026-11-25',
        drills: Map.fromEntries(pool.entries.toList().reversed),
        history: Map.fromEntries(history.entries.toList().reversed),
      ),
      result,
    );
    final three = plan(
      '2026-11-18',
      '2026-11-25',
      drills: {
        'a': ['a'],
        'b': ['b'],
        'c': ['c'],
      },
    );
    expect(three, ['a', 'b', 'c']);
  });

  const progressKey = 'act0_shell_progress_v1';
  final now = DateTime(2026, 11, 25, 12).toUtc();
  final world = Act0ShellStateV1.sample.worldById('world_1');
  final lessons = world.lessons;
  final completed = [for (final lesson in lessons) ...lesson.courseTaskList];
  final completedIds = completed.map((t) => t.taskId).toList();
  final xp = completed.fold<int>(0, (sum, task) => sum + task.rewardXp);

  void seed() {
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      progressKey: jsonEncode({
        'schemaVersion': 20,
        'w1StartChosen': true,
        'w1RulesBestScore': 9,
        'completedTaskIds': completedIds,
        'tasksWithDeferredXp': [
          for (final task in completed)
            if (task.phase == Act0LessonPhaseV1.drill && task.rewardXp > 0)
              task.taskId,
        ],
        'completedLessonIds': lessons.map((l) => l.lessonId).toList(),
        'selectedWorldId': world.worldId,
        'selectedLessonId': lessons.last.lessonId,
        'selectedTaskId': lessons.last.courseTaskList.last.taskId,
        'earnedXp':
            xp -
            completed
                .where((task) => task.phase == Act0LessonPhaseV1.drill)
                .fold<int>(0, (sum, task) => sum + task.rewardXp),
        'lastActiveDay': '2026-11-18',
        'dailyPracticeQueue': {
          'taskIds': <String>[],
          'answeredTaskIds': <String>[],
          'cleanTaskIds': <String>[],
        },
      }),
    });
  }

  Future<void> mount(WidgetTester tester, {bool? enabled}) async {
    final clock = Act0FixedUtcClockV1(now);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: enabled == null
            ? Act0ShellPreviewScreenV1(
                showPlacementOnStart: false,
                clock: clock,
              )
            : Act0ShellPreviewScreenV1(
                returnRefreshV1: enabled,
                showPlacementOnStart: false,
                clock: clock,
              ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Act0AcademyHomeLeafInputV1 home(WidgetTester tester) => tester
      .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
      .input;
  Future<Map<String, dynamic>> saved() async =>
      jsonDecode(
            (await SharedPreferences.getInstance()).getString(progressKey)!,
          )
          as Map<String, dynamic>;

  testWidgets(
    'flag OFF preserves Home action and never stores refresh marker',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      seed();
      await mount(tester);
      final original = home(tester).nextAction!;
      await tester.pumpWidget(const SizedBox.shrink());
      seed();
      await mount(tester, enabled: false);
      expect(home(tester).nextAction!.title, original.title);
      expect(home(tester).nextAction!.subtitle, original.subtitle);
      expect(home(tester).nextAction!.ctaLabel, original.ctaLabel);
      expect(home(tester).onSkipRefresh, isNull);
      expect(find.textContaining('Quick refresh'), findsNothing);
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pumpAndSettle();
      expect((await saved()).containsKey('returnRefreshOfferDay'), isFalse);
    },
  );

  testWidgets('skip launches original action and dismisses across restart', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    seed();
    await mount(tester, enabled: false);
    await tapAct0RoutePracticeKeyV1(tester, 'act0_academy_home_leaf_cta');
    final expectedNextTask = tester
        .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
        .selectedTaskId;
    await tester.pumpWidget(const SizedBox.shrink());
    seed();
    await mount(tester, enabled: true);
    expect(find.textContaining('Quick refresh'), findsOneWidget);
    expect(home(tester).onSkipRefresh, isNotNull);
    final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
    state.debugPersistProgressV1();
    await tester.pumpAndSettle();
    expect((await saved())['returnRefreshOfferDay'], '2026-11-25');
    await tapAct0RoutePracticeKeyV1(tester, 'act0_home_skip_refresh');
    expect((await saved()).containsKey('returnRefreshOfferDay'), isFalse);
    expect(
      tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      expectedNextTask,
    );
    await mount(tester, enabled: true);
    expect(find.textContaining('Quick refresh'), findsNothing);
    expect(home(tester).onSkipRefresh, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'refresh uses finished drills and leaves course progress and XP unchanged',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      seed();
      await mount(tester, enabled: true);
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pumpAndSettle();
      final before = await saved();
      expect(before['returnRefreshOfferDay'], '2026-11-25');
      expect(before['lastActiveDay'], '2026-11-25');
      // A pending offer survives a restart before the learner accepts it.
      await mount(tester, enabled: true);
      expect(find.textContaining('Quick refresh'), findsOneWidget);
      await tapAct0RoutePracticeKeyV1(tester, 'act0_academy_home_leaf_cta');
      final attempted = <String>{};
      final runnerFinder = find.byType(Act0LessonRunnerShellV1);
      while (runnerFinder.evaluate().isNotEmpty && attempted.length < 5) {
        final shell = tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
        expect(completedIds, contains(shell.selectedTaskId));
        expect(attempted.add(shell.selectedTaskId!), isTrue);
        final runner = shell.runner;
        expect(runner.phase, Act0LessonPhaseV1.drill);
        await pumpSourceChoreographyToDecisionV1(tester, runner.table);
        final choice = runner.options.firstWhere((o) => o.isCorrect);
        if (runner.sizingConfig.isEnabled) {
          await tapAct0RoutePracticeKeyV1(
            tester,
            'act0_shell_sizing_preset_${choice.id}',
          );
          await tapAct0RoutePracticeKeyV1(
            tester,
            'act0_shell_sizing_confirm_cta',
          );
        } else {
          await tapAct0RoutePracticeKeyV1(
            tester,
            choice.seatId == null
                ? 'act0_shell_option_${choice.id}'
                : 'act0_shell_seat_tap_${choice.seatId}',
          );
        }
        expect(
          tester
              .widget<Act0LessonRunnerShellV1>(runnerFinder)
              .completionSummary,
          isNull,
        );
        await tapAct0RoutePracticeKeyV1(
          tester,
          'act0_shell_feedback_continue_cta',
        );
      }
      expect(attempted.length, inInclusiveRange(3, 5));
      expect(runnerFinder, findsNothing);
      expect(find.textContaining('Quick refresh'), findsNothing);
      final after = await saved();
      for (final field in [
        'earnedXp',
        'completedTaskIds',
        'completedLessonIds',
        'dailyPracticeQueue',
        'tasksWithDeferredXp',
      ]) {
        if (field == 'completedTaskIds' ||
            field == 'completedLessonIds' ||
            field == 'tasksWithDeferredXp') {
          expect(
            after[field],
            unorderedEquals(before[field] as List),
            reason: field,
          );
        } else {
          expect(after[field], before[field], reason: field);
        }
      }
      expect(after.containsKey('returnRefreshOfferDay'), isFalse);
      await mount(tester, enabled: true);
      expect(find.textContaining('Quick refresh'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
