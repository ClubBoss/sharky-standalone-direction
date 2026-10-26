import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_hybrid_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime.utc(2026, 10, 27, 12);
Finder _key(String s) => find.byKey(Key(s));

/// Explicit saved-state QA fixtures. These never represent earned learning.
Map<String, Object> practiceHybridFixture(String mode) {
  final state = Act0ShellStateV1.sample;
  final first = state.worlds.first;
  final complete = mode == 'cross_world'
      ? first.lessons
      : first.lessons.take(mode == 'fresh' ? 0 : 5);
  final selected = mode == 'cross_world' ? state.worlds[1] : first;
  final progress = <String, dynamic>{
    'schemaVersion': 18,
    'completedTaskIds': [
      for (final lesson in complete)
        for (final task in lesson.taskList) task.taskId,
    ],
    'completedLessonIds': [for (final lesson in complete) lesson.lessonId],
    'selectedWorldId': selected.worldId,
    'selectedLessonId': selected.lessons.first.lessonId,
    'selectedTaskId': selected.lessons.first.taskList.first.taskId,
    'earnedXp': 0,
    'persistedStreakDays': 0,
    'dailyCompletedRepCount': mode == 'done' ? 3 : 0,
    'lastEarnedDailyDay': mode == 'done' ? '2026-10-27' : '',
    'dailyCompletedTaskIds': <String>[],
    'lastActiveDay': '2026-10-27',
    'resumeInRunner': false,
  };
  if (mode == 'repair') {
    final saved =
        jsonDecode(
              File(
                'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final repair =
        jsonDecode(saved['act0_shell_progress_v1'] as String)
            as Map<String, dynamic>;
    repair['lastActiveDay'] = '2026-10-27';
    repair['resumeInRunner'] = false;
    return {
      for (final e in saved.entries)
        e.key: e.key == 'act0_shell_progress_v1'
            ? jsonEncode(repair)
            : e.value as Object,
    };
  }
  return {
    'act0_shell_progress_v1': jsonEncode(progress),
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
  };
}

Future<void> _mount(WidgetTester t, String mode) async {
  SharedPreferences.setMockInitialValues(practiceHybridFixture(mode));
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(t.view.resetPadding);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.home,
        showPlacementOnStart: false,
        clock: Act0FixedUtcClockV1(_now),
      ),
    ),
  );
  await t.pumpAndSettle();
  await t.tap(
    find.descendant(
      of: _key('act0_shell_bottom_nav'),
      matching: find.text('Practice'),
    ),
  );
  await t.pumpAndSettle();
}

Act0PlayShellV1 _source(WidgetTester t) =>
    t.widget<Act0PlayShellV1>(find.byType(Act0PlayShellV1));
Future<void> _tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pumpAndSettle();
}

void main() {
  test('export source-backed native QA fixtures with explicit provenance', () {
    final out = Directory('output/practice_hybrid_v1_20261027/fixtures')
      ..createSync(recursive: true);
    for (final mode in [
      'fresh',
      'progressed',
      'done',
      'repair',
      'cross_world',
    ]) {
      File(
        '${out.path}/$mode.json',
      ).writeAsStringSync(jsonEncode(practiceHybridFixture(mode)));
    }
  });
  testWidgets('preview gate is default OFF; source shell remains present', (
    t,
  ) async {
    await _mount(t, 'fresh');
    expect(
      find.byType(Act0PracticeHybridV1),
      kAct0PracticeHybridV1 ? findsOneWidget : findsNothing,
    );
    expect(find.byType(Act0PlayShellV1), findsOneWidget);
  });
  testWidgets(
    'fresh: unavailable daily and honest live Learn fallback, neutral Review',
    (t) async {
      await _mount(t, 'fresh');
      expect(
        _source(t).groups.singleWhere((g) => g.groupId == 'daily').isEnabled,
        isFalse,
      );
      expect(find.text('Review your mistakes'), findsNothing);
      expect(find.text('Continue learning'), findsOneWidget);
      await _tap(t, _key('act0_practice_hybrid_start'));
      expect(find.byType(Act0PlayShellV1), findsNothing);
      expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
    },
    skip: !kAct0PracticeHybridV1,
  );
  testWidgets(
    'eligible rep: copy and exact world/lesson/task agree; back returns to Practice',
    (t) async {
      await _mount(t, 'progressed');
      final source = _source(t);
      final group = source.groups.singleWhere(
        (g) => g.groupId == source.recommendedGroupId,
      );
      expect(group.groupId, 'daily');
      expect(group.isEnabled, isTrue);
      expect(
        find.text('Short reps from your available practice topics.'),
        findsOneWidget,
      );
      expect(find.textContaining('spaced spots'), findsNothing);
      expect(
        t.widget<Text>(_key('act0_practice_hybrid_title')).data,
        source.recommendedTitle,
      );
      await _tap(t, _key('act0_practice_hybrid_start'));
      final runner = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedWorldId, group.targetWorldId);
      expect(runner.selectedLessonId, group.targetLessonId);
      expect(runner.selectedTaskId, group.targetTaskId);
      await _tap(t, _key('act0_shell_runner_back'));
      expect(find.byType(Act0PracticeHybridV1), findsOneWidget);
    },
    skip: !kAct0PracticeHybridV1,
  );
  testWidgets(
    'cross-world rep preserves actual source world instead of current world claim',
    (t) async {
      await _mount(t, 'cross_world');
      final source = _source(t);
      final group = source.groups.singleWhere(
        (g) => g.groupId == source.recommendedGroupId,
      );
      expect(group.targetWorldId, 'world_1');
      expect(find.textContaining('from your current world'), findsNothing);
      await _tap(t, _key('act0_practice_hybrid_start'));
      final runner = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedWorldId, group.targetWorldId);
      expect(runner.selectedLessonId, group.targetLessonId);
      expect(runner.selectedTaskId, group.targetTaskId);
    },
    skip: !kAct0PracticeHybridV1,
  );
  testWidgets(
    'active repair reuses mapped source repair; Review handoff and back use shared tab action',
    (t) async {
      await _mount(t, 'repair');
      final source = _source(t);
      expect(source.recommendedGroupId, 'weak_spots');
      expect(
        t.widget<Text>(_key('act0_practice_hybrid_title')).data,
        source.recommendedTitle,
      );
      await _tap(t, _key('act0_practice_hybrid_start'));
      final runner = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedWorldId, 'world_3');
      expect(runner.selectedLessonId, 'position_checkpoint');
      expect(
        runner.selectedTaskId,
        'position_checkpoint_position_checkpoint_table_notice',
      );
      await _tap(t, _key('act0_shell_runner_back'));
      // Existing repair back contract returns to Review, not voluntary reps.
      expect(find.byType(Act0PlayShellV1), findsNothing);
      final nav = _key('act0_shell_bottom_nav');
      await _tap(t, find.descendant(of: nav, matching: find.text('Practice')));
      expect(find.byType(Act0PracticeHybridV1), findsOneWidget);
      await _tap(t, _key('act0_practice_hybrid_review'));
      expect(find.byType(Act0PlayShellV1), findsNothing);
      await _tap(t, find.descendant(of: nav, matching: find.text('Practice')));
      expect(find.byType(Act0PracticeHybridV1), findsOneWidget);
    },
    skip: !kAct0PracticeHybridV1,
  );
  testWidgets(
    'completed daily remains honest and permits source-owned optional extra',
    (t) async {
      await _mount(t, 'done');
      final source = _source(t);
      final group = source.groups.singleWhere(
        (g) => g.groupId == source.recommendedGroupId,
      );
      expect(group.sessionLabel, 'Complete');
      expect(
        find.text('Your daily set is complete. Extra reps are optional.'),
        findsOneWidget,
      );
      expect(find.textContaining('Table read improved'), findsNothing);
      expect(find.textContaining('Come back tomorrow'), findsNothing);
      expect(
        t.widget<Text>(_key('act0_practice_hybrid_title')).data,
        'Daily short reps complete',
      );
      await _tap(t, _key('act0_practice_hybrid_start'));
      expect(
        t
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        group.targetTaskId,
      );
    },
    skip: !kAct0PracticeHybridV1,
  );
  testWidgets(
    'real topics: Actions launches exact target, Blinds locked, See all expands inventory',
    (t) async {
      await _mount(t, 'progressed');
      final actions = _source(
        t,
      ).groups.singleWhere((g) => g.groupId == 'actions');
      expect(actions.isEnabled, isTrue);
      expect(
        t
            .widget<TextButton>(_key('act0_practice_hybrid_topic_blinds'))
            .onPressed,
        isNull,
      );
      await _tap(t, _key('act0_practice_hybrid_expand'));
      expect(_key('act0_practice_hybrid_topic_showdown'), findsOneWidget);
      await _tap(t, _key('act0_practice_hybrid_topic_actions'));
      final runner = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedWorldId, actions.targetWorldId);
      expect(runner.selectedLessonId, actions.targetLessonId);
      expect(runner.selectedTaskId, actions.targetTaskId);
      expect(runner.selectedTaskId, 'actions_legal_context');
    },
    skip: !kAct0PracticeHybridV1,
  );
}
