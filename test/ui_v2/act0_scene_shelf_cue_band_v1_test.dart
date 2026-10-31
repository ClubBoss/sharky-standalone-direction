import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// The decision shelf's "More" cue owns a band below the answers. Runs with
/// the F7 preview flag ON and OFF: the shelf contract is identical in both.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    var directory = File(Platform.resolvedExecutable).parent;
    while (directory.parent.path != directory.path) {
      final fonts = Directory(
        '${directory.path}/bin/cache/artifacts/material_fonts',
      );
      if (fonts.existsSync()) {
        final loader = FontLoader('Roboto');
        for (final weight in ['Regular', 'Medium', 'Bold']) {
          final file = File('${fonts.path}/Roboto-$weight.ttf');
          if (file.existsSync()) {
            loader.addFont(
              Future.value(ByteData.sublistView(file.readAsBytesSync())),
            );
          }
        }
        await loader.load();
        break;
      }
      directory = directory.parent;
    }
    if (kAct0F7TableScenePreview) {
      await Act0SceneProfileGateV1.premiumStore.warmUp();
    }
  });

  (Act0LessonTaskV1, String, String) find0(String id) {
    for (final w in Act0ShellStateV1.sample.worlds) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          if (t.taskId == id) return (t, l.lessonId, w.worldId);
        }
      }
    }
    throw StateError('missing task $id');
  }

  Future<(Act0RunnerStateV1, List<Act0RunnerOptionV1>)> mount(
    WidgetTester t,
    String id, {
    double height = 852,
  }) async {
    final (task, lessonId, worldId) = find0(id);
    final runner = task.runner.copyWith(
      phase: task.entryPhase,
      teachingStepIndex: task.runner.teachingSteps.length,
    );
    final chosen = <Act0RunnerOptionV1>[];
    t.view.physicalSize = Size(393, height);
    t.view.devicePixelRatio = 1;
    t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.view.resetPadding);
    await t.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Roboto'),
        home: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Act0LessonRunnerShellV1(
              key: ValueKey(id),
              runner: runner,
              selectedWorldId: worldId,
              selectedLessonId: lessonId,
              selectedTaskId: id,
              selectedTaskFamily: task.resolvedTaskFamily,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: chosen.add,
              onContinueReview: () {},
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    return (runner, chosen);
  }

  // Longest graded answers in the catalog, plus long repair/recheck rows.
  const longAnswerTasks = <String>[
    'visible_card_combo_density_transfer_check',
    'paired_board_texture_lite_intro',
    'flush_draws_w5_made_hand_vs_flush_draw_transfer',
    'turn_river_changes_w5_street_repair',
    'w6_wet_board_repair',
    'first_table_guide_one_clear_choice',
    'what_poker_is_matched_chips_transfer',
    'your_first_hand_flop',
  ];

  for (final id in longAnswerTasks) {
    testWidgets('$id: no answer text or tap sits under the cue', (t) async {
      final (runner, chosen) = await mount(t, id);
      final band = find.byKey(const Key('act0_scene_shelf_more_fade'));
      final cue = find.byKey(const Key('act0_scene_shelf_more_cue'));
      final rows = {
        for (final o in runner.options)
          o.id: t.getRect(find.byKey(Key('act0_shell_option_${o.id}'))),
      };
      for (final r in rows.values) {
        expect(r.height, greaterThanOrEqualTo(44), reason: id);
      }
      if (band.evaluate().isEmpty) {
        // Everything fits: every answer is whole above the home indicator.
        for (final r in rows.values) {
          expect(r.bottom, lessThanOrEqualTo(852 - 34 + .5), reason: id);
        }
        return;
      }
      final bandTop = t.getRect(band).top;
      // On arrival each answer is whole or waits entirely below the band.
      for (final MapEntry(key: oid, value: r) in rows.entries) {
        expect(
          r.bottom <= bandTop + .5 || r.top >= bandTop - .5,
          isTrue,
          reason: '$id $oid straddles the band: $r vs $bandTop',
        );
      }
      if (cue.evaluate().isNotEmpty) {
        final cueRect = t.getRect(cue);
        expect(cueRect.height, greaterThanOrEqualTo(44));
        expect(cueRect.width, greaterThanOrEqualTo(44));
        expect(cueRect.width, lessThanOrEqualTo(160), reason: 'compact pill');
        for (final r in rows.values) {
          if (r.bottom <= bandTop + .5) {
            expect(r.overlaps(cueRect), isFalse, reason: id);
          }
        }
        // One tap brings the next hidden answer fully above the band.
        final hidden = rows.entries.firstWhere(
          (e) => e.value.top >= bandTop - .5,
        );
        await t.tap(cue);
        await t.pumpAndSettle();
        expect(chosen, isEmpty, reason: 'the cue never chooses');
        final now = t.getRect(
          find.byKey(Key('act0_shell_option_${hidden.key}')),
        );
        expect(now.bottom, lessThanOrEqualTo(bandTop + .5), reason: id);
        expect(now.top, greaterThanOrEqualTo(0));
        // The revealed answer takes a real tap.
        await t.tapAt(now.center);
        await t.pumpAndSettle();
        expect(chosen.map((o) => o.id), [hidden.key], reason: id);
      }
    });
  }

  testWidgets('a drag on the cue band scrolls the answers, never chooses', (
    t,
  ) async {
    final band = find.byKey(const Key('act0_scene_shelf_more_fade'));
    for (final id in longAnswerTasks) {
      // A shorter screen guarantees overflow with the flag ON or OFF.
      final (runner, chosen) = await mount(t, id, height: 700);
      if (band.evaluate().isEmpty) continue;
      final last = find.byKey(
        Key('act0_shell_option_${runner.options.last.id}'),
      );
      final before = t.getRect(last).top;
      await t.dragFrom(t.getRect(band).center, const Offset(0, -60));
      await t.pumpAndSettle();
      expect(t.getRect(last).top, lessThan(before), reason: id);
      expect(chosen, isEmpty, reason: id);
      return;
    }
    fail('no long-answer task overflowed the shelf in this mode');
  });

  testWidgets('a tap anywhere on the band reveals; its button is pill-sized', (
    t,
  ) async {
    final band = find.byKey(const Key('act0_scene_shelf_more_fade'));
    final semantics = t.ensureSemantics();
    for (final id in longAnswerTasks) {
      final (runner, chosen) = await mount(t, id, height: 700);
      if (band.evaluate().isEmpty) continue;
      final pill = t.getRect(
        find.byKey(const Key('act0_scene_shelf_more_cue')),
      );
      final node = t.getSemantics(find.bySemanticsLabel('More choices below'));
      expect(node.rect.width, lessThanOrEqualTo(pill.width + 1), reason: id);
      expect(node.rect.height, lessThanOrEqualTo(pill.height + 1), reason: id);
      final bandTop = t.getRect(band).top;
      // The next answer that is not fully visible above the band.
      final hidden = runner.options.firstWhere(
        (o) =>
            t.getRect(find.byKey(Key('act0_shell_option_${o.id}'))).bottom >
            bandTop + .5,
      );
      await t.tapAt(Offset(40, t.getRect(band).center.dy));
      await t.pumpAndSettle();
      final now = t.getRect(find.byKey(Key('act0_shell_option_${hidden.id}')));
      expect(
        now.bottom,
        lessThanOrEqualTo(t.getRect(band).top + .5),
        reason: id,
      );
      expect(chosen, isEmpty, reason: id);
      semantics.dispose();
      return;
    }
    semantics.dispose();
    fail('no long-answer task overflowed the shelf in this mode');
  });
}
