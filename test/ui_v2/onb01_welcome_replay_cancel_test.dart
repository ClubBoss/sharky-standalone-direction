import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';

const _key = 'act0_shell_progress_v1';
final _store = Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true);

Future<void> _mount(
  WidgetTester tester,
  Act0ShellTabV1 tab, {
  bool priorProgress = false,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await _store.flush();
  });
  final world = Act0ShellStateV1.sample.worlds.first;
  SharedPreferences.setMockInitialValues({
    'unrelated': 'keep',
    'intake_completed_v1': true,
    'act0_welcome_completed_v1': true,
    _key: jsonEncode({
      'schemaVersion': 18,
      'completedTaskIds': priorProgress
          ? world.lessons.first.taskList.map((t) => t.taskId).toList()
          : [],
      'skippedTaskIds': [],
      'completedLessonIds': [],
      'selectedWorldId': world.worldId,
      'selectedLessonId': world.lessons.first.lessonId,
      'selectedTaskId': world.lessons.first.taskList.first.taskId,
      'earnedXp': priorProgress ? 20 : 0,
    }),
  });
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: tab,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<Map<String, Object?>> _prefs(WidgetTester tester) async {
  await tester.runAsync(
    () => _store.flush().timeout(const Duration(seconds: 2)),
  );
  final p = await SharedPreferences.getInstance();
  return {for (final key in p.getKeys()) key: p.get(key)};
}

void main() {
  // Existing host, SYNTHETIC persisted schema18 positiveprogress bootstrap.
  // Replay cancellation only: no newuser/native/restart acceptance claim.
  testWidgets(
    'Welcome replay demo Back returns without changing saved learning',
    (tester) async {
      await _mount(tester, Act0ShellTabV1.profile, priorProgress: true);
      Act0AcademyYouLeafInputV1 you() => tester
          .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
          .input;
      final count = you().completedTaskCount;
      final xp = you().xpLine;
      expect(
        count,
        greaterThan(0),
        reason: 'Positive preservation control, not all-zero proof.',
      );
      final before = await _prefs(tester);
      final dynamic host = tester.state(find.byType(Act0ShellPreviewScreenV1));
      final task = host.debugSelectedTaskIdV1();
      final lesson = host.debugSelectedLessonIdV1();
      Future<void> tapKey(String key) async {
        final target = find.byKey(Key(key));
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      await tapKey('act0_academy_you_leaf_settings');
      await tapKey('act0_academy_settings_leaf_welcome');
      expect(find.byType(Act0WelcomeShellV1), findsOneWidget);
      expect(
        tester
            .widget<Act0WelcomeShellV1>(find.byType(Act0WelcomeShellV1))
            .replayMode,
        isTrue,
      );
      await tapKey('act0_shell_welcome_primary_cta');
      expect(
        find.byKey(const Key('act0_shell_welcome_demo_spot')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .runner
            .selectedOptionId,
        isNull,
      );
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsNothing,
      );
      expect(await _prefs(tester), before);
      await tapKey('act0_shell_runner_back');
      expect(find.byType(Act0WelcomeShellV1), findsNothing);
      expect(find.byType(Act0AcademyYouLeafV1), findsOneWidget);
      expect(you().completedTaskCount, count);
      expect(you().xpLine, xp);
      expect(host.debugSelectedTaskIdV1(), task);
      expect(host.debugSelectedLessonIdV1(), lesson);
      expect(await _prefs(tester), before);
      expect(tester.takeException(), isNull);
    },
  );
}
