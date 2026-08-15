// Local-only evidence generator. It mounts the real production preview shell
// and uses its existing direct-state capture entry only for real source-owned
// W1 states; no substitute route or widget is introduced.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _device = String.fromEnvironment(
  'ACTION_EVIDENCE_DEVICE',
  defaultValue: 'compact',
);
const _root = String.fromEnvironment(
  'ACTION_EVIDENCE_OUTPUT',
  defaultValue: 'output/evidence/action_sequence_convergence_v1_$_device',
);
final _textScale =
    double.tryParse(
      const String.fromEnvironment(
        'ACTION_EVIDENCE_TEXT_SCALE',
        defaultValue: '1',
      ),
    ) ??
    1;
final _viewport = switch (_device) {
  'iphone17_class' => const Size(402, 874),
  'tall_phone' => const Size(390, 844),
  'large_phone' => const Size(430, 932),
  _ => const Size(375, 812),
};
const _boundaryKey = Key('action_sequence_raster_boundary');

void main() {
  setUpAll(() async {
    final bytes = await File(
      '/System/Library/Fonts/Supplemental/Arial.ttf',
    ).readAsBytes();
    for (final family in <String>['Roboto', 'Ahem']) {
      await (FontLoader(
        family,
      )..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)))).load();
    }
    for (final candidate in const <(String, String)>[
      (
        'MaterialIcons',
        'build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
      ),
      (
        'CupertinoIcons',
        'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
      ),
    ]) {
      final file = File(candidate.$2);
      if (!file.existsSync()) continue;
      final iconBytes = await file.readAsBytes();
      await (FontLoader(candidate.$1)
            ..addFont(Future<ByteData>.value(ByteData.sublistView(iconBytes))))
          .load();
    }
  });

  testWidgets('captures canonical W1 Action production states', (tester) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.systemFontFamily = 'Roboto';
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.resetSystemFontFamily);
    const realTextStyle = TextStyle(fontFamily: 'Roboto');
    final realTextTheme = ThemeData(
      fontFamily: 'Roboto',
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(textStyle: WidgetStatePropertyAll(realTextStyle)),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(textStyle: WidgetStatePropertyAll(realTextStyle)),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(textStyle: WidgetStatePropertyAll(realTextStyle)),
      ),
    );
    final out = Directory(_root)..createSync(recursive: true);
    final rows = <Map<String, Object?>>[];

    void writeGeometryMetrics() {
      File('${out.path}/raster_geometry_metrics.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(<String, Object?>{
              'viewport': <String, int>{
                'width': _viewport.width.toInt(),
                'height': _viewport.height.toInt(),
              },
              'textScale': _textScale,
              'states': rows,
            }) +
            '\n',
      );
    }

    Future<void> capture({
      required String name,
      required Act0ControlledDemoCaptureSurfaceV1 surface,
      String taskId = 'actions_check_drill',
      String phase = 'selected',
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: realTextTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(_textScale)),
            child: child!,
          ),
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
      Map<String, double>? rectData(Finder finder) {
        if (finder.evaluate().isEmpty) return null;
        final value = tester.getRect(finder.first);
        return <String, double>{
          'left': value.left,
          'top': value.top,
          'width': value.width,
          'height': value.height,
        };
      }

      final promptRect = rectData(
        find.byKey(const Key('act0_integrated_scene_prompt')),
      );
      final silhouetteRect = rectData(
        find.byKey(const Key('act0_integrated_scene_perspective_silhouette')),
      );
      final actionRect = rectData(
        find.byKey(const Key('act0_integrated_scene_action_foreground')),
      );
      final heroRect = rectData(
        find.byWidgetPredicate(
          (widget) =>
              widget.key?.toString().contains('act0_shell_hero_identity_') ??
              false,
        ),
      );
      final depthAnchors = <String, Map<String, double>>{};
      for (final element
          in find
              .byWidgetPredicate(
                (widget) =>
                    widget.key?.toString().contains(
                      'act0_integrated_scene_depth_',
                    ) ??
                    false,
              )
              .evaluate()) {
        final key = element.widget.key?.toString() ?? 'unknown';
        final anchorRect = tester.getRect(
          find.byElementPredicate((candidate) {
            return identical(candidate, element);
          }),
        );
        depthAnchors[key] = <String, double>{
          'centerX': anchorRect.center.dx,
          'centerY': anchorRect.center.dy,
          'width': anchorRect.width,
          'height': anchorRect.height,
        };
      }
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
        'integratedGeometry': <String, Object?>{
                'promptEnvelope': promptRect,
                'tableSceneAllocation': rect?.height,
                'visibleTableBounds': silhouetteRect,
                'heroBounds': heroRect,
                'heroY': heroRect?['top'],
                'actionEnvelope': actionRect,
                'actionEnvelopeTop': actionRect?['top'],
                'explicitTableScale': 1.0,
                'seatAnchors': depthAnchors,
              },
        'overflow': tester.takeException()?.toString(),
      });
      writeGeometryMetrics();
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

    final ctaHitRows = <Map<String, Object?>>[];
    final feedbackAllocationRows = <Map<String, Object?>>[];

    void recordCtaHitGeometry(String state) {
      final target = find.byKey(const Key('act0_shell_feedback_continue_cta'));
      final rect = tester.getRect(target);
      final targetBox = tester.renderObject<RenderBox>(target);
      final insetX = rect.width < 24 ? rect.width / 4 : 8.0;
      final insetY = rect.height < 24 ? rect.height / 4 : 8.0;
      final samples = <String, Offset>{
        'center': rect.center,
        'upperLeft': Offset(rect.left + insetX, rect.top + insetY),
        'upperRight': Offset(rect.right - insetX, rect.top + insetY),
        'lowerLeft': Offset(rect.left + insetX, rect.bottom - insetY),
        'lowerRight': Offset(rect.right - insetX, rect.bottom - insetY),
        'outsideLeft': Offset(rect.left - 6, rect.center.dy),
      };
      bool hitsTarget(Offset point) => tester
          .hitTestOnBinding(point)
          .path
          .any((entry) => identical(entry.target, targetBox));
      ctaHitRows.add(<String, Object?>{
        'state': state,
        'visibleOwner': 'FilledButton#act0_shell_feedback_continue_cta',
        'hitOwner': targetBox.runtimeType.toString(),
        'bounds': <String, double>{
          'left': rect.left,
          'top': rect.top,
          'right': rect.right,
          'bottom': rect.bottom,
          'width': rect.width,
          'height': rect.height,
        },
        'samples': <String, bool>{
          for (final sample in samples.entries)
            sample.key: hitsTarget(sample.value),
        },
      });
    }

    Future<void> recordFeedbackAllocation(String state) async {
      final body = find.byKey(
        const Key('act0_shell_feedback_allocated_body_scroll'),
      );
      final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
      final primaryResult = find.byKey(
        const Key('act0_shell_feedback_primary_result_label'),
      );
      expect(body, findsOneWidget);
      expect(primaryResult, findsOneWidget);
      final bodyEnd = find.byKey(
        Key(
          state == 'wrong_feedback'
              ? 'act0_shell_feedback_missed_cue_treatment'
              : 'act0_shell_feedback_non_miss_treatment',
        ),
      );
      expect(bodyEnd, findsOneWidget);
      final position = Scrollable.of(tester.element(bodyEnd)).position;
      final bodyRect = tester.getRect(body);
      final primaryResultRect = tester.getRect(primaryResult);
      final ctaBefore = tester.getRect(cta);
      final maxScrollExtent = position.maxScrollExtent;
      if (maxScrollExtent > 0) {
        await tester.ensureVisible(bodyEnd);
        await tester.pumpAndSettle();
      }
      final ctaAfter = tester.getRect(cta);
      feedbackAllocationRows.add(<String, Object?>{
        'state': state,
        'bodyViewport': <String, double>{
          'left': bodyRect.left,
          'top': bodyRect.top,
          'width': bodyRect.width,
          'height': bodyRect.height,
        },
        'primaryResultInitiallyVisible':
            primaryResultRect.top >= bodyRect.top &&
            primaryResultRect.bottom <= bodyRect.bottom,
        'maxScrollExtent': maxScrollExtent,
        'reachedBodyEnd':
            maxScrollExtent == 0 ||
            (position.pixels - maxScrollExtent).abs() < 0.5,
        'ctaPinnedWhileBodyScrolled': ctaBefore == ctaAfter,
      });
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
        theme: realTextTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_textScale)),
          child: child!,
        ),
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
    recordCtaHitGeometry('wrong_feedback');
    await recordFeedbackAllocation('wrong_feedback');
    await tapVisible(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await saveMounted('targeted_repair');
    await tapVisible(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await saveMounted('repair_success');
    recordCtaHitGeometry('repair_success');
    await recordFeedbackAllocation('repair_success');
    await tapVisible(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await saveMounted('targeted_recheck');
    await tapVisible(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    await saveMounted('recheck_success');
    recordCtaHitGeometry('recheck_success');
    await recordFeedbackAllocation('recheck_success');
    await tapVisible(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await saveMounted('completion');
    await tester.pumpAndSettle();
    await saveMounted('next_step');

    writeGeometryMetrics();
    final ctaHitGeometryJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(ctaHitRows);
    File(
      '${out.path}/cta_hit_geometry.json',
    ).writeAsStringSync('$ctaHitGeometryJson\n');
    final feedbackAllocationJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(feedbackAllocationRows);
    File(
      '${out.path}/feedback_allocation_geometry.json',
    ).writeAsStringSync('$feedbackAllocationJson\n');
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
    expect(
      ctaHitRows.every((row) {
        final bounds = row['bounds']! as Map<String, double>;
        final samples = row['samples']! as Map<String, bool>;
        return bounds['height']! >= 44 &&
            samples['center']! &&
            samples['upperLeft']! &&
            samples['upperRight']! &&
            samples['lowerLeft']! &&
            samples['lowerRight']! &&
            !samples['outsideLeft']!;
      }),
      isTrue,
      reason: 'Every visible feedback CTA must retain usable hit geometry.',
    );
    expect(
      feedbackAllocationRows.every(
        (row) =>
            row['primaryResultInitiallyVisible'] == true &&
            row['reachedBodyEnd'] == true &&
            row['ctaPinnedWhileBodyScrolled'] == true,
      ),
      isTrue,
      reason:
          'Feedback content must remain reachable while the CTA stays pinned.',
    );
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
  final canvas = image.Image(
    width: images.first.width * images.length,
    height: images.first.height,
  );
  for (var index = 0; index < images.length; index++) {
    image.compositeImage(canvas, images[index], dstX: 375 * index);
  }
  File('${out.path}/$fileName').writeAsBytesSync(image.encodePng(canvas));
}
