// Local-only evidence generator. It mounts the real production preview shell
// and uses its existing direct-state capture entry only for real source-owned
// W1 states; no substitute route or widget is introduced.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _root = 'output/evidence/action_sequence_convergence_v1';
const _viewport = Size(375, 812);
const _boundaryKey = Key('action_sequence_raster_boundary');

void main() {
  testWidgets('captures canonical W1 Action production states', (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final out = Directory(_root)..createSync(recursive: true);
    final rows = <Map<String, Object?>>[];

    Future<void> capture({
      required String name,
      required Act0ControlledDemoCaptureSurfaceV1 surface,
      String taskId = 'actions_check_drill',
      String phase = 'selected',
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: _boundaryKey,
            child: Act0ShellPreviewScreenV1(
              key: ValueKey<String>('action_sequence_capture_$name'),
              state: Act0ShellStateV1.sample,
              showPlacementOnStart: false,
              debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
                mode: Act0ControlledDemoCaptureModeV1.directState,
                surface: surface,
                worldId: 'world_1',
                lessonId: 'fold_check_call_raise',
                taskId: taskId,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bytes = await _png(tester);
      File('${out.path}/$name.png').writeAsBytesSync(bytes);
      final runnerRoots = find
          .byKey(const Key('act0_shell_runner_screen'))
          .evaluate()
          .length;
      final runnerFinder = find.byType(Act0LessonRunnerShellV1);
      final runner = runnerFinder.evaluate().isEmpty
          ? null
          : tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
      final table = find.byKey(const Key('act0_shell_table'));
      final rect = table.evaluate().isEmpty ? null : tester.getRect(table);
      final stableBounds = find.byKey(
        const Key('act0_task_owned_practice_table_bounds'),
      );
      final stableRect = stableBounds.evaluate().isEmpty
          ? null
          : tester.getRect(stableBounds);
      rows.add(<String, Object?>{
        'name': name,
        'phase': phase,
        'taskId': taskId,
        'owner': 'Act0ShellPreviewScreenV1',
        'sequenceId': 'w1_action_words_check_v1',
        'tableContextRelation': 'related_read',
        'runnerRootCount': runnerRoots,
        'runnerPhase': runner?.runner.phase.name,
        'runnerSelectedTaskId': runner?.selectedTaskId,
        'runnerTeachingStepIndex': runner?.runner.teachingStepIndex,
        'runnerTeachingStepCount': runner?.runner.teachingSteps.length,
        'stablePracticeSelected': stableRect != null,
        'stablePracticeBounds': stableRect == null
            ? null
            : <String, double>{
                'left': stableRect.left,
                'top': stableRect.top,
                'width': stableRect.width,
                'height': stableRect.height,
              },
        'table': rect == null
            ? null
            : <String, double>{
                'left': rect.left,
                'top': rect.top,
                'width': rect.width,
                'height': rect.height,
              },
        'overflow': tester.takeException()?.toString(),
      });
      expect(tester.takeException(), isNull);
    }

    await capture(
      name: 'theory',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerTheory,
      taskId: 'actions_theory',
      phase: 'theory',
    );
    await capture(
      name: 'decision',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
      phase: 'decision',
    );
    await capture(
      name: 'correct_feedback',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerFirstCorrectFeedback,
      phase: 'correct_feedback',
    );
    await capture(
      name: 'wrong_feedback',
      surface: Act0ControlledDemoCaptureSurfaceV1.runnerFirstWrongFeedback,
      phase: 'wrong_feedback',
    );
    await capture(
      name: 'targeted_repair',
      surface: Act0ControlledDemoCaptureSurfaceV1.repairFocus,
      taskId: 'actions_legal_context',
      phase: 'existing_repair_surface',
    );
    await capture(
      name: 'repair_success',
      surface: Act0ControlledDemoCaptureSurfaceV1.repairResult,
      taskId: 'actions_legal_context',
      phase: 'existing_repair_result_surface',
    );

    Future<void> saveMounted(String name) async {
      File('${out.path}/$name.png').writeAsBytesSync(await _png(tester));
    }

    Future<void> tapVisible(Finder target) async {
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      final rect = tester.getRect(target);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(_viewport.height));
      await tester.tap(target);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: _boundaryKey,
          child: Act0ShellPreviewScreenV1(
            key: const ValueKey<String>('action_sequence_live_wrong_route'),
            state: Act0ShellStateV1.sample,
            showPlacementOnStart: false,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface:
                  Act0ControlledDemoCaptureSurfaceV1.runnerFirstWrongFeedback,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_check_drill',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await saveMounted('wrong_feedback');
    await tapVisible(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await saveMounted('targeted_repair');
    await tapVisible(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await saveMounted('repair_success');
    await tapVisible(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await saveMounted('targeted_recheck');
    await tapVisible(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await saveMounted('recheck_success');
    await tapVisible(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await saveMounted('completion');
    await tester.pumpAndSettle();
    await saveMounted('next_step');

    File('${out.path}/raster_geometry_metrics.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
            'viewport': <String, int>{'width': 375, 'height': 812},
            'states': rows,
          }) +
          '\n',
    );
    File('${out.path}/raster_state_inventory.md').writeAsStringSync(
      '''# Canonical Action raster inventory

The harness mounts `Act0ShellPreviewScreenV1`. Theory, decision, and initial
feedback use existing production capture entries. From the real Action wrong
feedback state it taps the actual feedback and option controls through
same-task repair, repair success, same-task recheck, recheck success,
completion, and the next rendered state. The legacy `actions_legal_context`
repair captures are retained only as unrelated existing evidence and are not
used in the Action sequence contact sheets.
''',
    );
    _sheet(out, <String>[
      'theory',
      'decision',
      'correct_feedback',
      'wrong_feedback',
    ], 'canonical_sequence_contact_sheet.png');
    _sheet(out, <String>[
      'wrong_feedback',
      'targeted_repair',
      'repair_success',
      'targeted_recheck',
      'recheck_success',
    ], 'wrong_repair_recheck_contact_sheet.png');
    _sheet(out, <String>[
      'correct_feedback',
      'recheck_success',
      'completion',
      'next_step',
    ], 'correct_completion_contact_sheet.png');
    _sheet(out, <String>[
      'theory',
      'decision',
      'wrong_feedback',
    ], 'runner_control_contact_sheet.png');
  });
}

Future<Uint8List> _png(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_boundaryKey),
  );
  final data = await tester.runAsync(
    () async => (await boundary.toImage(
      pixelRatio: 1,
    )).toByteData(format: ui.ImageByteFormat.png),
  );
  if (data == null) throw StateError('PNG capture failed');
  return Uint8List.view(data.buffer);
}

void _sheet(Directory out, List<String> names, String fileName) {
  final images = names
      .map(
        (name) =>
            image.decodePng(File('${out.path}/$name.png').readAsBytesSync())!,
      )
      .toList();
  final canvas = image.Image(width: 375 * images.length, height: 812);
  for (var index = 0; index < images.length; index++) {
    image.compositeImage(canvas, images[index], dstX: 375 * index);
  }
  File('${out.path}/$fileName').writeAsBytesSync(image.encodePng(canvas));
}
