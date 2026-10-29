import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'act0_pw_c3_parity_v1_test.dart' as journey;

Act0LessonTaskV1 sourceTask(String id) => Act0ShellStateV1.sample
    .lessonById('what_poker_is')
    .taskList
    .firstWhere((t) => t.taskId == id);

void main() {
  Act0RunnerStateV1 sourceRunner(String id) {
    final task = sourceTask(id);
    return task.runner.copyWith(
      phase: task.phase,
      teachingStepIndex: task.phase == Act0LessonPhaseV1.theory
          ? 0
          : task.runner.teachingSteps.length,
    );
  }

  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (kAct0F7TableScenePreview)
      await Act0SceneProfileGateV1.premiumStore.warmUp();
  });
  Future<void> mount(
    WidgetTester t,
    Act0RunnerStateV1 runner, {
    String id = 'what_poker_is_table_read_transfer',
    ValueChanged<Act0RunnerOptionV1>? choose,
  }) async {
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.view.resetPadding);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: const Key('f7_capture'),
            child: Act0LessonRunnerShellV1(
              runner: runner,
              selectedWorldId: 'world_1',
              selectedLessonId: 'what_poker_is',
              selectedTaskId: id,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              selectedTaskFamily: sourceTask(id).resolvedTaskFamily,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: choose ?? (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }

  test(
    'source compatibility census is presentation-only and exports review geometry',
    () {
      final p = act0PremiumTableSceneProfileV1;
      final out = Directory('output/f7_20261029')..createSync(recursive: true);
      File(
        '${out.path}/calibration_seed.json',
      ).writeAsStringSync(jsonEncode(p.calibrationData));
      final rows = <Map<String, Object?>>[];
      for (final world in Act0ShellStateV1.sample.worlds) {
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            final table = task.runner.table;
            rows.add({
              'world': world.worldId,
              'lesson': lesson.lessonId,
              'task': task.taskId,
              'supported': p.supportsScenario([
                table,
                for (final s in task.runner.teachingSteps)
                  if (s.table != null) s.table!,
              ]),
              'format': table.tableFormat.name,
              'players': table.playerCount,
              'hero': table.heroSeatId,
              'boardCount': table.boardCards.length,
              'street': table.streetLabel,
              'folded': [
                for (final s in table.seats)
                  if (s.isFolded || !s.isInHand) s.seatId,
              ],
              'empty': [
                for (final s in table.seats)
                  if (!s.isOccupied) s.seatId,
              ],
            });
          }
        }
      }
      File(
        '${out.path}/source_compatibility.json',
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(rows));
      expect(rows.any((r) => r['supported'] == true), isTrue);
    },
  );
  testWidgets(
    'real source flop, cards, actor ownership and original OFF path',
    (t) async {
      final runner = sourceRunner('what_poker_is_table_read_transfer');
      await mount(t, runner);
      expect(
        find.byKey(const Key('act0_f7_registered_scene')),
        kAct0F7TableScenePreview ? findsOneWidget : findsNothing,
      );
      if (kAct0F7TableScenePreview) {
        expect(
          find.byKey(const Key('act0_scene_player_volume_plane')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('act0_scene_hero_foreground_volume')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('act0_scene_hybrid_shell_ready')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('act0_integrated_scene_perspective_silhouette')),
          findsNothing,
        );
        for (final id in [
          'hero_0',
          'hero_1',
          'board_0',
          'board_1',
          'board_2',
        ]) {
          expect(find.byKey(Key('act0_shell_card_$id')), findsOneWidget);
        }
        expect(
          find.byKey(const Key('act0_shell_marker_btn_dealer')),
          findsOneWidget,
        );
        for (final s in runner.table.seats)
          expect(
            find.byKey(Key('act0_shell_seat_node_${s.seatId}')),
            findsOneWidget,
          );
      } else {
        expect(
          find.byKey(const Key('act0_integrated_scene_perspective_table')),
          findsOneWidget,
        );
      }
    },
  );
  testWidgets(
    'source preflop and highlighted feedback share fixed image registration',
    (t) async {
      final runner = sourceTask('what_poker_is_theory').runner;
      await mount(t, runner, id: 'what_poker_is_theory');
      final tableRunner = sourceRunner('what_poker_is_table_read_transfer');
      await mount(t, tableRunner);
      final rect = kAct0F7TableScenePreview
          ? t.getRect(find.byKey(const Key('act0_f7_registered_scene')))
          : null;
      final wrong = tableRunner.options.firstWhere((o) => !o.isCorrect);
      await mount(
        t,
        tableRunner.copyWith(
          phase: Act0LessonPhaseV1.review,
          selectedOptionId: wrong.id,
        ),
      );
      if (rect != null)
        expect(
          t.getRect(find.byKey(const Key('act0_f7_registered_scene'))),
          rect,
        );
    },
  );
  testWidgets('existing option callback receives the unchanged source choice', (
    t,
  ) async {
    final runner = sourceRunner('what_poker_is_table_read_transfer');
    Act0RunnerOptionV1? choice;
    await mount(t, runner, choose: (o) => choice = o);
    final option = runner.options.first;
    await t.ensureVisible(find.text(option.label).last);
    await t.tap(find.text(option.label).last);
    await t.pumpAndSettle();
    expect(choice, same(option));
  });
  testWidgets(
    'connected first-use route supplies real preflop and flop decisions',
    (t) async {
      await journey.mount(t);
      await journey.experience(t, 'new');
      await journey.welcome(t, wrong: false);
      final home = t.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      File('output/f7_20261029/native_home_cta.json').writeAsStringSync(
        jsonEncode({
          'label': home.nextActionCtaLabel,
          'visibleText': [
            for (final e in find.byType(Text).evaluate())
              if ((e.widget as Text).data != null) (e.widget as Text).data!,
          ],
        }),
      );
    home.onContinue();
      await t.pumpAndSettle();
      final steps = <Map<String, Object?>>[];
      var reached = false;
      for (var i = 0; i < 22; i++) {
        final r = t.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        steps.add({
          ...journey.runnerReceipt(r),
          'teachingStep': r.runner.teachingStepIndex,
          'street': r.runner.table.streetLabel,
          'boardCount': r.runner.table.boardCards.length,
          'buttons': [
            for (final e in find.byType(Text).evaluate())
              if ((e.widget as Text).data != null) (e.widget as Text).data!,
          ],
        });
        if (r.selectedTaskId == 'what_poker_is_table_read_transfer' &&
            r.runner.phase == Act0LessonPhaseV1.drill) {
          reached = true;
          break;
        }
        switch (r.runner.phase) {
          case Act0LessonPhaseV1.theory:
            r.onContinueTheory();
          case Act0LessonPhaseV1.drill:
            r.onChooseOption(r.runner.options.firstWhere((o) => o.isCorrect));
          case Act0LessonPhaseV1.review:
            r.onContinueReview();
        }
        await t.pumpAndSettle();
      }
      File(
        'output/f7_20261029/connected_source_route.json',
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(steps));
      expect(reached, isTrue);
      expect(steps.any((s) => s['street'] == 'Preflop'), isTrue);
    },
  );
}
