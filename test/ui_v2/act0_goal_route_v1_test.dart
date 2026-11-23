import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_home_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_goal_route_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _seed({String? goal}) {
  final first = Act0ShellStateV1.sample.worldById('world_1').lessons.first;
  SharedPreferences.setMockInitialValues({
    'act0_shell_progress_v1': jsonEncode({
      'schemaVersion': 1,
      'selectedWorldId': 'world_1',
      'selectedLessonId': first.lessonId,
      'selectedTaskId': first.courseTaskList.first.taskId,
      'earnedXp': 0,
      if (goal != null) 'learnerGoal': goal,
    }),
  });
}

Future<void> _mount(
  WidgetTester tester,
  Act0ShellTabV1 tab, {
  required bool enabled,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        initialTab: tab,
        showPlacementOnStart: false,
        enableBetaMetrics: false,
        goalRouteV1: enabled,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0AcademyHomeLeafInputV1 _home(WidgetTester tester) => tester
    .widget<Act0AcademyHomeLeafV1>(find.byType(Act0AcademyHomeLeafV1))
    .input;

Act0LearnPathShellV1 _map(WidgetTester tester) =>
    tester.widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1));

void main() {
  testWidgets('flag off keeps the beta route golden and Home and Map inputs', (
    tester,
  ) async {
    Future<List<int>> snapshot(String? savedGoal) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      _seed(goal: savedGoal);
      await _mount(tester, Act0ShellTabV1.home, enabled: false);
      final home = _home(tester);
      expect(home.goalRoute, isNull);
      await _mount(tester, Act0ShellTabV1.learn, enabled: false);
      final map = _map(tester);
      expect(map.goalRoute, isNull);
      expect(
        jsonEncode(map.worlds.map((world) => world.worldId).toList()),
        '["world_1","world_2","world_3","world_4","world_5","world_6",'
        '"world_7","world_8","world_9","world_10","world_11","world_12"]',
      );
      return utf8.encode(
        jsonEncode([
          home.courseTitle,
          home.earnedLessonCount,
          home.courseLessonCount,
          home.nextAction?.title,
          home.nextAction?.subtitle,
          home.nextAction?.ctaLabel,
          map.selectedWorldId,
          map.selectedLessonId,
          map.selectedTaskId,
          for (final world in map.worlds)
            [
              world.worldId,
              world.status.name,
              world.isLocked,
              world.isSelectable,
              world.rewardXp,
              for (final lesson in world.lessons)
                [lesson.lessonId, lesson.state.name, lesson.rewardXp],
            ],
        ]),
      );
    }

    final golden = await snapshot(null);
    for (final goal in Act0LearnerGoalV1.values) {
      expect(await snapshot(goal.id), golden);
    }
  });

  testWidgets('old profile migrates and changes survive a restart', (
    tester,
  ) async {
    _seed();
    await _mount(tester, Act0ShellTabV1.home, enabled: true);
    final home = _home(tester).goalRoute!;
    expect(home.goal, Act0LearnerGoalV1.onlineCash);

    home.onGoalChanged(Act0LearnerGoalV1.mtt);
    await tester.pumpAndSettle();
    final updatedHome = _home(tester).goalRoute!;
    expect(updatedHome.nextSteps[4].worldId, 'world_9');

    await _mount(tester, Act0ShellTabV1.learn, enabled: true);
    final map = _map(tester);
    final route = map.goalRoute!;
    expect(route.goal, Act0LearnerGoalV1.mtt);
    expect(
      route.nextSteps.map((world) => world.worldId),
      updatedHome.nextSteps.map((world) => world.worldId),
    );
    expect(route.route.worlds[4], same(map.worlds[8]));
    expect(route.route.worlds[4].isLocked, isTrue);

    route.onGoalChanged(Act0LearnerGoalV1.onlineCash);
    await tester.pumpAndSettle();
    await _mount(tester, Act0ShellTabV1.home, enabled: true);
    expect(_home(tester).goalRoute!.goal, Act0LearnerGoalV1.onlineCash);
  });
}
