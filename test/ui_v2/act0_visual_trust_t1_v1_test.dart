import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_character_asset_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_salience_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_scene_v3.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

void main() {
  test('Coach footprint supports feedback without assessment guidance', () {
    for (final phase in Act0SceneAttentionPhaseV1.values) {
      final scaffold = act0SharkySceneCoachScaffoldForAttentionPhaseV1(phase);
      expect(scaffold.avatarSize, lessThanOrEqualTo(44));
      if (phase == Act0SceneAttentionPhaseV1.decision) {
        expect(scaffold.tier, Act0SharkyCoachScaffoldTierV1.off);
      }
    }
  });
  testWidgets(
    'opaque player pixels survive every phase, depth and folded state',
    (t) async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.white, BlendMode.src);
      final picture = recorder.endRecording();
      final image = (await t.runAsync(() => picture.toImage(8, 8)))!;
      addTearDown(image.dispose);
      addTearDown(picture.dispose);
      final failures = <String>[];
      final reds = <String, int>{};
      for (final phase in Act0SceneAttentionPhaseV1.values) {
        for (final folded in [false, true]) {
          for (final haze in [0.0, 0.5, 1.0]) {
            final motion = Act0SceneAttentionMotionV1.settled(phase);
            await t.pumpWidget(
              Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: RepaintBoundary(
                    key: const Key('pixels'),
                    child: SizedBox(
                      width: 8,
                      height: 8,
                      child: Act0SceneRecedeMotionV1(
                        motion: motion,
                        plane: Act0SceneRecedePlaneV1.player,
                        child: CustomPaint(
                          painter: Act0SceneCharacterPainterV1(
                            image: image,
                            artFit: Act0SceneCharacterArtFitV1.standard,
                            haze: haze,
                            folded: folded,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            final boundary = t.renderObject<RenderRepaintBoundary>(
              find.byKey(const Key('pixels')),
            );
            final raster = (await t.runAsync(() => boundary.toImage()))!;
            final bytes = (await t.runAsync(
              () => raster.toByteData(format: ui.ImageByteFormat.rawRgba),
            ))!;
            final alpha = bytes.getUint8((4 * 8 + 4) * 4 + 3);
            reds['${phase.name}/$folded/$haze'] = bytes.getUint8(
              (4 * 8 + 4) * 4,
            );
            if (alpha != 255)
              failures.add(
                '${phase.name}/folded=$folded/haze=$haze: alpha=$alpha',
              );
            raster.dispose();
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
      for (final phase in Act0SceneAttentionPhaseV1.values) {
        for (final haze in [0.0, 0.5, 1.0]) {
          expect(
            reds['${phase.name}/true/$haze'],
            lessThan(reds['${phase.name}/false/$haze']!),
          );
        }
      }
    },
  );

  testWidgets(
    '14 Pro table information paints above near bodies and clears the dock',
    (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPadding);
      final selected = <String>[];
      final task = Act0ShellStateV1.sample
          .lessonById('what_poker_is')
          .taskList
          .firstWhere((t) => t.taskId == 'what_poker_is_table_read_transfer');
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Act0LessonRunnerShellV1(
                runner: task.runner.copyWith(
                  phase: Act0LessonPhaseV1.drill,
                  teachingStepIndex: task.runner.teachingSteps.length,
                ),
                selectedWorldId: 'world_1',
                selectedLessonId: 'what_poker_is',
                selectedTaskId: task.taskId,
                selectedTaskFamily: task.resolvedTaskFamily,
                tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (option) => selected.add(option.id),
                onContinueReview: () {},
                theoryRecallStep: task.runner.teachingSteps.first,
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      final stack = t.widget<Stack>(
        find
            .descendant(
              of: find.byKey(
                const Key('act0_integrated_scene_perspective_table'),
              ),
              matching: find.byType(Stack),
            )
            .first,
      );
      int indexOf(String key) => stack.children.indexWhere(
        (child) => find
            .descendant(
              of: find.byWidget(child),
              matching: find.byKey(Key(key)),
              matchRoot: true,
            )
            .evaluate()
            .isNotEmpty,
      );
      final layerOrderValid =
          indexOf('act0_shell_table') >
          indexOf('act0_scene_player_front_plane');
      final hero = t.getRect(
        find.byKey(
          Key(
            'act0_shell_seat_node_${task.runner.table.seats.firstWhere((s) => s.isHero).seatId}',
          ),
        ),
      );
      final dock = t.getRect(
        find.byKey(const Key('act0_integrated_scene_action_foreground')),
      );
      debugPrint('T1_MEASURE hero=$hero dock=$dock');
      for (final id in ['sb', 'co']) {
        final nearHud = t.getRect(find.byKey(Key('act0_shell_seat_node_$id')));
        expect(
          nearHud.bottom + 8,
          lessThan(hero.top),
          reason: '$id information must clear the near face / Hero corridor',
        );
      }
      expect(
        t.widget<Scrollbar>(find.byType(Scrollbar).first).thumbVisibility,
        isTrue,
      );
      expect(layerOrderValid, isTrue);
      expect(hero.bottom + 8, lessThanOrEqualTo(dock.top));
      for (final option in task.runner.options) {
        final target = find.byKey(Key('act0_shell_option_${option.id}'));
        expect(t.getSize(target).height, greaterThanOrEqualTo(44));
        await t.ensureVisible(target);
        await t.pumpAndSettle();
        expect(target.hitTestable(), findsOneWidget);
      }
      await t.tap(
        find.byKey(Key('act0_shell_option_${task.runner.options.last.id}')),
      );
      await t.pumpAndSettle();
      expect(selected, [task.runner.options.last.id]);
      expect(
        t.getRect(
          find.byKey(
            Key(
              'act0_shell_seat_node_${task.runner.table.seats.firstWhere((s) => s.isHero).seatId}',
            ),
          ),
        ),
        hero,
      );
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    '14 Pro authored Action theory keeps blind chips clear of owned seats',
    (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPadding);

      await t.pumpWidget(
        MaterialApp(
          home: const Act0ShellPreviewScreenV1(
            state: Act0ShellStateV1.sample,
            showPlacementOnStart: false,
            debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerTheory,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_theory',
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      for (final id in const <String>['sb', 'bb']) {
        final seat = find.byKey(Key('act0_shell_seat_node_$id'));
        final chip = find.byKey(Key('act0_shell_bet_chip_owner_$id'));
        expect(seat, findsOneWidget, reason: '$id seat missing');
        expect(chip, findsOneWidget, reason: '$id posted chip missing');
        final seatBounds = t.getRect(seat);
        final chipBounds = t.getRect(chip);
        expect(
          seatBounds.overlaps(chipBounds),
          isFalse,
          reason: '$id seat=$seatBounds chip=$chipBounds',
        );
      }
    },
  );
}
