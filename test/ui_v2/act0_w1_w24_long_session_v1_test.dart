import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_practice_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_daily_practice_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_path_progress_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_widget_test_theme_v1.dart';
import 'act0_w1_long_session_v1_test.dart' show registerLongSessionRoutes;

void main() {
  final worlds = Act0ShellStateV1.sample.worlds;
  final baseWorlds = worlds.take(12).toList();
  final baseRoute = [
    for (final world in baseWorlds)
      for (final lesson in world.lessons)
        for (final task in lesson.courseTaskList)
          [world.worldId, lesson.lessonId, task.taskId, task.rewardXp],
  ];
  final baseIds = baseRoute.map((row) => row[2] as String).toSet();

  // Always run the release-prefix contract, including in the pilot build.
  test('W1–W12 route/XP unchanged; W13 unlock requires W12 and pilot', () {
    final lastWorld = act0CurriculumPilotEnabledV1 ? 24 : 12;
    expect(act0LastCurriculumWorldV1, lastWorld);
    expect(act0DailyPracticeLastWorldV1, lastWorld);
    expect(
      worlds.map((world) => world.worldNumber),
      orderedEquals(List.generate(lastWorld, (index) => index + 1)),
    );
    // Same current ordered route/XP baseline as act0_curriculum_pilot_v1_test.
    expect(
      sha256.convert(utf8.encode(jsonEncode(baseRoute))).toString(),
      '4188b79e962253220a409352ab8859c06b09f6ccc0f543421ff5b11a2aa018d1',
    );
    final incomplete = {...baseIds}..remove(baseRoute.last[2]);
    List<Act0WorldCardV1> project(Set<String> ids) => act0ProgressWorldsV1(
      worlds,
      pathClosedTaskIds: ids,
      earnedTaskIds: ids,
    );
    final before = project(incomplete);
    final after = project(baseIds);
    expect(before[11].status, Act0WorldStateV1.current);
    expect(after[11].status, Act0WorldStateV1.completed);
    if (act0CurriculumPilotEnabledV1) {
      expect(before[12].worldNumber, 13);
      expect(before[12].isSelectable, isFalse);
      expect(after[12].status, Act0WorldStateV1.current);
      expect(after[12].isSelectable, isTrue);
    } else {
      expect(after.last.worldNumber, 12);
      expect(
        after.every((world) => world.status == Act0WorldStateV1.completed),
        isTrue,
      );
    }
  });

  // Isolate the pool boundary from the expensive, unseeded route below. Mark
  // the base drills seen today so an eligible W13 drill must surface in the
  // real Daily Practice queue, rather than merely checking a flag constant.
  testWidgets('Daily Practice admits completed W13 drills only in the pilot', (
    t,
  ) async {
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final throughWorld = act0CurriculumPilotEnabledV1 ? 13 : 12;
    final completed = worlds
        .take(throughWorld)
        .expand((w) => w.lessons)
        .expand((l) => l.courseTaskList)
        .toList();
    final completedIds = completed.map((task) => task.taskId).toSet();
    final pilotIds = completedIds.difference(baseIds);
    // A stale pilot completion must not leak into a flag-OFF deck.
    const pilotSource = 'w13_3_guided_flush_draw_turn';
    final last = worlds[throughWorld - 1];
    final clock = Act0FixedUtcClockV1(DateTime(2026, 11, 26, 12).toUtc());
    final day = act0DailyDealDayV1(clock.nowUtc().toLocal());
    final seenToday = {
      ...baseIds,
      for (final world in baseWorlds)
        for (final lesson in world.lessons)
          for (final task in lesson.courseTaskList)
            if (act0DailyDealTemplateForSourceV1(task.taskId)
                case final template?)
              act0DailyDealIdV1((
                day: day,
                template: template,
                lessonId: lesson.lessonId,
                sourceTaskId: task.taskId,
              )),
    };
    const progressKey = 'act0_shell_progress_v1';
    SharedPreferences.setMockInitialValues({
      progressKey: jsonEncode({
        'schemaVersion': 17,
        'completedTaskIds': {...completedIds, pilotSource}.toList(),
        'selectedWorldId': last.worldId,
        'selectedLessonId': last.lessons.last.lessonId,
        'selectedTaskId': last.lessons.last.courseTaskList.last.taskId,
        'earnedXp': completed.fold<int>(0, (sum, task) => sum + task.rewardXp),
        'lastActiveDay': '2026-11-26',
        'dailyCompletedTaskIds': seenToday.toList(),
      }),
    });
    Future<void> settle() => t.pumpAndSettle(
      const Duration(milliseconds: 250),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
    await t.pumpWidget(
      MaterialApp(
        theme: act0WidgetTestThemeV1,
        home: Act0ShellPreviewScreenV1(
          initialTab: Act0ShellTabV1.home,
          showPlacementOnStart: false,
          clock: clock,
        ),
      ),
    );
    await settle();
    final practice = find.descendant(
      of: find.byKey(const Key('act0_shell_bottom_nav')),
      matching: find.text('Practice'),
    );
    expect(practice, findsOneWidget);
    await t.tap(practice);
    await settle();
    final input = t
        .widget<Act0AcademyPracticeLeafV1>(
          find.byType(Act0AcademyPracticeLeafV1),
        )
        .input;
    final daily = input.groups.singleWhere((group) => group.groupId == 'daily');
    expect(daily.isEnabled, isTrue);
    // The leaf forwards this source-owned callback unchanged to the real
    // queue launcher. It avoids depending on which group is recommended.
    input.onStartGroup(daily);
    await settle();
    final runner = t.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, daily.targetTaskId);
    final snapshot = await t.runAsync(() async {
      await Act0ProgressStoreV1(
        key: progressKey,
        isValidPayload: (_) => false,
      ).flush().timeout(const Duration(seconds: 3));
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 3),
      );
      await prefs.reload().timeout(const Duration(seconds: 3));
      final head = jsonDecode(prefs.getString('${progressKey}_head')!) as Map;
      return jsonDecode(head['payload'] as String) as Map;
    });
    final queue = Act0DailyPracticeQueueV1.tryParse(
      snapshot!['dailyPracticeQueue'],
    )!;
    expect(queue.taskIds, isNotEmpty);
    expect(queue.nextTaskId, daily.targetTaskId);
    final sources = queue.taskIds
        .map((id) => act0DailyDealRecipeV1(id)?.sourceTaskId ?? id)
        .toSet();
    expect(completedIds, containsAll(sources));
    expect(
      sources.intersection(pilotIds).isNotEmpty,
      act0CurriculumPilotEnabledV1,
    );
    if (!act0CurriculumPilotEnabledV1) {
      expect(sources, isNot(contains(pilotSource)));
      expect(baseIds, containsAll(sources));
    }
    expect(t.takeException(), isNull);
  });

  // Unlike the W13-only pilot driver, this starts from empty storage at W1
  // and crosses W12 → W13 without a seeded save. The shared driver registers
  // this widget test with skip: !act0CurriculumPilotEnabledV1.
  registerLongSessionRoutes(volumeRoute: true);
}
