import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const fixture =
    'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json';
Map<String, Object> prefs({bool fresh = false, bool skipped = false}) {
  final raw =
      (jsonDecode(File(fixture).readAsStringSync()) as Map<String, dynamic>);
  final p =
      jsonDecode(raw['act0_shell_progress_v1'] as String)
          as Map<String, dynamic>;
  if (fresh || skipped) {
    p['completedTaskIds'] = <String>[];
    p['completedLessonIds'] = <String>[];
    p['earnedXp'] = 0;
    p['skippedTaskIds'] = skipped
        ? Act0ShellStateV1.sample
              .worldById('world_1')
              .lessons
              .first
              .taskList
              .map((t) => t.taskId)
              .toList()
        : <String>[];
    p['openRepairIntents'] = <Object>[];
    (p['multiRepairQueue'] as Map<String, dynamic>)['entries'] = <Object>[];
  }
  raw['act0_shell_progress_v1'] = jsonEncode(p);
  return {for (final e in raw.entries) e.key: e.value as Object};
}

Future<void> mount(WidgetTester t, Map<String, Object> data) async {
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.view.resetPadding);
  SharedPreferences.setMockInitialValues(data);
  await t.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.learn,
        showPlacementOnStart: false,
      ),
    ),
  );
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

Future<void> tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

void main() {
  testWidgets('fresh earned projection and reversible Learn flag at 14 Pro', (
    t,
  ) async {
    await mount(t, prefs(fresh: true));
    expect(
      find.byKey(const Key('act0_learn_cinematic_body')),
      kAct0LearnCinematicPathAV1 ? findsOneWidget : findsNothing,
    );
    if (kAct0LearnCinematicPathAV1) {
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is AnnotatedRegion<SystemUiOverlayStyle> &&
              w.value == SystemUiOverlayStyle.light,
        ),
        findsWidgets,
      );
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('0 of 9 lessons complete'), findsOneWidget);
      expect(
        t.getSize(find.byKey(const Key('act0_learn_cinematic_header'))).height,
        104,
      );
      final cta = t.getRect(
        find.byKey(const Key('act0_shell_current_mission_cta')),
      );
      expect(cta.height, greaterThanOrEqualTo(44));
      expect(
        cta.bottom,
        lessThan(
          t.getTopLeft(find.byKey(const Key('act0_shell_bottom_nav'))).dy,
        ),
      );
    }
  });
  testWidgets(
    'existing eligible inline/full-path/launch contracts remain source-owned',
    (t) async {
      await mount(t, prefs());
      final shell = t.widget<Act0LearnPathShellV1>(
        find.byType(Act0LearnPathShellV1),
      );
      final current = shell.lessons.firstWhere(
        (l) => l.state == Act0LessonStateV1.current,
      );
      final task = current.taskList.firstWhere(
        (q) => !shell.pathClosedTaskIds.contains(q.taskId),
        orElse: () => current.taskList.first,
      );
      expect(find.text('11%'), findsOneWidget);
      final prior = shell.lessons.firstWhere(
        (l) => l.lessonId != current.lessonId && l.isSelectable,
      );
      final row = find.byKey(
        Key('act0_learn_cinematic_lesson_${prior.lessonId}'),
      );
      final disclosure = find.byKey(
        Key('act0_learn_cinematic_disclosure_${prior.lessonId}'),
      );
      expect(t.widget<RotatedBox>(disclosure).quarterTurns, 1);
      await tap(t, row);
      expect(t.widget<RotatedBox>(disclosure).quarterTurns, 3);
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_panel')),
        findsOneWidget,
      );
      await tap(t, find.text('Close lesson'));
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_panel')),
        findsNothing,
      );
      await tap(t, find.byKey(const Key('act0_shell_learn_v5_view_full_path')));
      expect(find.text('Collapse full path'), findsOneWidget);
      final locked = shell.lessons.firstWhere((l) => !l.isSelectable);
      expect(
        find.byKey(Key('act0_learn_cinematic_disclosure_${locked.lessonId}')),
        findsNothing,
      );
      await tap(
        t,
        find.byKey(Key('act0_learn_cinematic_lesson_${locked.lessonId}')),
      );
      expect(
        find.byKey(const Key('act0_shell_selected_lesson_panel')),
        findsNothing,
      );
      await tap(t, find.byKey(const Key('act0_shell_learn_v5_view_full_path')));
      await tap(t, find.byKey(const Key('act0_shell_current_mission_cta')));
      expect(
        t
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        task.taskId,
      );
      await tap(t, find.byKey(const Key('act0_shell_runner_back')));
      expect(find.byType(Act0LearnPathShellV1), findsOneWidget);
      (t.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic)
          .debugPersistProgressV1();
      await t.pump(const Duration(milliseconds: 250));
      final saved = await SharedPreferences.getInstance();
      final p =
          jsonDecode(saved.getString('act0_shell_progress_v1')!)
              as Map<String, dynamic>;
      expect(
        p['selectedTaskId'],
        t
            .widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1))
            .selectedTaskId,
      );
      expect(p['earnedXp'], 30);
    },
    skip: !kAct0LearnCinematicPathAV1,
  );
  testWidgets(
    'Placement skips cannot become earned course completion',
    (t) async {
      await mount(t, prefs(skipped: true));
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('0 of 9 lessons complete'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_learn_cinematic_skipped')),
        findsOneWidget,
      );
      expect(find.text('1 skipped by placement'), findsOneWidget);
    },
    skip: !kAct0LearnCinematicPathAV1,
  );
}
