// Private quarantine proposal: direct callback boundaries, not native or tap proof.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w4_authored_binding_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

// Callback-only synthetic ordering: unchanged recap object is first available.
// This does not prove the canonical learner route or completed prerequisites.
Act0ShellStateV1 callbackState(String id) {
  final s = Act0ShellStateV1.sample;
  if (id != 'actions_review') return s;
  Act0LessonCardV1 arrange(Act0LessonCardV1 l) {
    if (l.lessonId != 'fold_check_call_raise') return l;
    final target = l.taskList.singleWhere((t) => t.taskId == id);
    return l.copyWith(
      isSelectable: true,
      isLocked: false,
      tasks: [target, ...l.taskList.where((t) => t.taskId != id)],
    );
  }

  return Act0ShellStateV1(
    courseTitle: s.courseTitle,
    courseSubtitle: s.courseSubtitle,
    levelLabel: s.levelLabel,
    xp: s.xp,
    xpTarget: s.xpTarget,
    streakDays: s.streakDays,
    dailyGoalLabel: s.dailyGoalLabel,
    dailyGoalValue: s.dailyGoalValue,
    pathProgressLabel: s.pathProgressLabel,
    selectedWorldId: s.selectedWorldId,
    worlds: [
      for (final w in s.worlds)
        w.copyWith(lessons: w.lessons.map(arrange).toList()),
    ],
    lessons: s.lessons.map(arrange).toList(),
    review: s.review,
    profile: s.profile,
  );
}

void main() {
  test('six private W4 sources cannot bind restored canonical tasks', () {
    final worlds = Act0ShellStateV1.sample.worlds;
    expect(act0PrivateW4BindingsV1, hasLength(6));
    for (final binding in act0PrivateW4BindingsV1) {
      final world = worlds.singleWhere((w) => w.worldId == binding.world);
      final lesson = world.lessons.singleWhere(
        (l) => l.lessonId == binding.lesson,
      );
      final task = lesson.taskList.singleWhere((t) => t.taskId == binding.task);
      expect(
        act0W4BindingForTaskV1(
          world: world.worldId,
          lesson: lesson.lessonId,
          task: task,
          runner: task.runner,
        ),
        isNull,
        reason: task.taskId,
      );
    }
  });
  for (final id in [
    'actions_theory',
    'actions_fold_drill',
    'actions_call_drill',
    'actions_raise_drill',
    'actions_review',
  ]) {
    testWidgets(
      'quarantined $id callbacks preserve state and emit no learning event',
      (t) async {
        SharedPreferences.setMockInitialValues({});
        t.view.physicalSize = const Size(393, 852);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final sink = Act0InMemoryTelemetrySinkV1();
        await t.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            supportedLocales: const [Locale('en'), Locale('ru')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Act0ShellPreviewScreenV1(
              initialTab: Act0ShellTabV1.play,
              initialPhase: Act0LessonPhaseV1.drill,
              showPlacementOnStart: false,
              state: callbackState(id),
              telemetrySink: sink,
              debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
                mode: Act0ControlledDemoCaptureModeV1.directState,
                surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
                worldId: 'world_1',
                lessonId: 'fold_check_call_raise',
                taskId: id,
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final dynamic host = t.state(find.byType(Act0ShellPreviewScreenV1));
        expect(host.debugSelectedTaskIdV1(), id);
        final runner = t.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        final phase = host.debugPhaseV1();
        final option = host.debugSelectedOptionIdV1();
        final outcomes = jsonEncode(
          host.debugRepairOutcomeProjectionPayloadV1(),
        );
        final families = jsonEncode(host.debugConceptFamilyStatePayloadV1());
        await t.runAsync(() async {
          await host.debugFlushQuarantineProgressV1().timeout(
            const Duration(seconds: 2),
          );
        });
        final progress = jsonEncode(host.debugQuarantineProgressPayloadV1());
        final prefs = await SharedPreferences.getInstance();
        final before = {for (final k in prefs.getKeys()) k: prefs.get(k)};
        final eventCount = sink.events.length;
        runner.onContinueTheory();
        runner.onChooseOption(runner.runner.options.first);
        runner.onContinueReview();
        await t.pumpAndSettle();
        await t.runAsync(() async {
          await host.debugFlushQuarantineProgressV1().timeout(
            const Duration(seconds: 2),
          );
        });
        expect(jsonEncode(host.debugQuarantineProgressPayloadV1()), progress);
        expect(host.debugSelectedTaskIdV1(), id);
        expect(host.debugPhaseV1(), phase);
        expect(host.debugSelectedOptionIdV1(), option);
        expect(
          jsonEncode(host.debugRepairOutcomeProjectionPayloadV1()),
          outcomes,
        );
        expect(jsonEncode(host.debugConceptFamilyStatePayloadV1()), families);
        expect({for (final k in prefs.getKeys()) k: prefs.get(k)}, before);
        expect(sink.events.length, eventCount);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
      },
    );
  }
}
