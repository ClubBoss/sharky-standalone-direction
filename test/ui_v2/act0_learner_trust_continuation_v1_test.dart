import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

void main() {
  test('earned completion preserves 75 percent and practice need', () {
    const summary = Act0BlockCompletionSummaryV1(
      lessonTitle: 'Guide', xpEarned: 0, errorCount: 1,
      taskCount: 4, correctCount: 3, startLevel: 1, endLevel: 1,
      startXp: 0, endXp: 0, xpTarget: 100,
      nextLessonTitle: 'Next', curriculumCompleted: true,
    );
    expect(summary.accuracyPercent, 75);
    expect(summary.qualifiesForNextLesson, isTrue);
    expect(summary.milestoneTitle, 'Lesson complete');
    expect(summary.masteryStatus, Act0MasteryStatusV1.needsReview);
  });

  for (final id in ['straight_draws_w5_gutshot_draw', 'w10_vs_nit_open_wider']) {
    testWidgets('prerequisite and independent decision $id', (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final world = Act0ShellStateV1.sample.worlds.firstWhere((w) => w.lessons.any((l) => l.taskList.any((task) => task.taskId == id)));
      final lesson = world.lessons.firstWhere((l) => l.taskList.any((task) => task.taskId == id));
      final task = lesson.taskList.singleWhere((task) => task.taskId == id);
      Future<void> mount(bool teaching) async {
        await t.pumpWidget(MaterialApp(home: Scaffold(body: Act0LessonRunnerShellV1(
          key: ValueKey(teaching),
          runner: task.runner.copyWith(phase: Act0LessonPhaseV1.drill, teachingStepIndex: teaching ? 0 : task.runner.teachingSteps.length),
          selectedWorldId: world.worldId, selectedLessonId: lesson.lessonId,
          selectedTaskId: id, selectedTaskFamily: task.resolvedTaskFamily,
          tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
          onBack: () {}, onContinueTheory: () {}, onChooseOption: (_) {}, onContinueReview: () {},
        ))));
        await t.pumpAndSettle();
      }
      if (id.startsWith('straight')) {
        await mount(true);
        expect(find.text('Gutshot means one middle card is missing.'), findsWidgets);
        expect(find.byKey(const Key('act0_shell_option_gutshot')), findsNothing);
      }
      await mount(false);
      expect(find.text(task.runner.question), findsWidgets);
      if (id.startsWith('w10')) {
        expect(find.text('Blinds fold too much to late-position steals.'), findsWidgets);
        expect(find.text(task.runner.hint), findsNothing);
      } else {
        expect(find.text('Gutshot means one middle card is missing.'), findsNothing);
        expect(find.text('Only a 6 helps'), findsNothing);
      }
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('Placement Welcome restart Home launches promised eligible Guide', (t) async {
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    Future<void> tap(String key) async {
      final f = find.byKey(Key(key));
      expect(f, findsOneWidget, reason: key);
      await t.ensureVisible(f);
      await t.tap(f);
      await t.pumpAndSettle();
    }
    Future<void> correct() async {
      final runner = t.widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));
      final o = runner.runner.options.firstWhere((o) => o.isCorrect);
      await tap(o.seatId == null ? 'act0_shell_option_${o.id}' : 'act0_shell_seat_tap_${o.seatId}');
    }
    await t.pumpWidget(const MaterialApp(home: Act0ShellPreviewScreenV1(showPlacementOnStart: true)));
    await t.pumpAndSettle();
    await tap('act0_shell_placement_intro_cta');
    for (final id in ['friends', 'rules']) {
      await tap('act0_shell_placement_option_$id');
      await tap('act0_shell_placement_next_cta');
    }
    await tap('act0_shell_placement_start_diagnostic');
    for (var i = 0; i < 3; i++) {
      if (find.byKey(const Key('act0_shell_placement_result')).evaluate().isNotEmpty) break;
      await correct();
      await tap('act0_shell_feedback_continue_cta');
    }
    await tap('act0_shell_placement_start_recommended');
    for (var i = 0; i < 5; i++) {
      if (find.byKey(const Key('act0_shell_welcome_demo_spot')).evaluate().isNotEmpty) {
        await correct();
      } else if (find.byKey(const Key('act0_shell_welcome_primary_cta')).evaluate().isNotEmpty) {
        await tap('act0_shell_welcome_primary_cta');
      } else {
        break;
      }
    }
    expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
    await t.pumpWidget(const MaterialApp(home: Act0ShellPreviewScreenV1()));
    await t.pumpAndSettle();
    final home = t.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
    final expectedLessonId = home.currentLesson!.lessonId;
    await tap('act0_shell_main_cta');
    final launched = t.widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));
    expect(launched.selectedLessonId, expectedLessonId);
    expect(launched.selectedLessonId, 'what_poker_is');
  });
}
