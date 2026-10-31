import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Review-history strip scope at the 393x852 reference.
///
/// Review-phase tasks with a hand history route the strip to the feedback
/// owner, but the canonical runner's fixed lower slot (Wave A geometry)
/// suppresses it. This pins that current behaviour so it cannot change
/// silently: no strip, and the feedback and its Continue stay reachable.
/// Showing the strip needs an owner-admitted lower-slot layout decision.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (kAct0F7TableScenePreview) {
      await Act0SceneProfileGateV1.premiumStore.warmUp();
    }
  });

  ({String world, String lesson, Act0LessonTaskV1 task}) find0(String id) {
    for (final w in Act0ShellStateV1.sample.worlds) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          if (t.taskId == id)
            return (world: w.worldId, lesson: l.lessonId, task: t);
        }
      }
    }
    throw StateError(id);
  }

  for (final id in const [
    'your_first_hand_showdown',
    'your_first_hand_recap',
    'first_table_guide_route_roles',
    'showdown_review',
  ]) {
    testWidgets('$id: review feedback holds the strip; Continue reachable', (
      t,
    ) async {
      final src = find0(id);
      final runner = src.task.runner;
      expect(src.task.phase, Act0LessonPhaseV1.review);
      expect(runner.table.actionTrail, isNotEmpty);
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPadding);
      final correct = runner.options.firstWhere((o) => o.isCorrect);
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              key: ValueKey(id),
              runner: runner.copyWith(
                phase: Act0LessonPhaseV1.review,
                selectedOptionId: correct.id,
                teachingStepIndex: runner.teachingSteps.length,
              ),
              selectedWorldId: src.world,
              selectedLessonId: src.lesson,
              selectedTaskId: id,
              selectedTaskFamily: src.task.resolvedTaskFamily,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await t.pump(const Duration(seconds: 8));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byKey(const Key('act0_shell_action_trail')), findsNothing);
      final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
      final fallback = find.byKey(const Key('act0_shell_continue_cta'));
      final target = cta.evaluate().isNotEmpty ? cta : fallback;
      expect(target, findsWidgets);
      final rect = t.getRect(target.first);
      expect(rect.bottom, lessThanOrEqualTo(852 - 34 + 0.5));
      expect(rect.top, greaterThanOrEqualTo(0));
    });
  }
}
