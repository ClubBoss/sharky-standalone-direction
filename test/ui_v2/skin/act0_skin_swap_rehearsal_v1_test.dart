import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/skin/act0_skin_tokens_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'act0_skin_tokens_rehearsal_v1.dart' as rehearsal;

typedef _Surface = Act0ControlledDemoCaptureSurfaceV1;
const _captureKey = Key('b101_viewport');
const _directory = String.fromEnvironment('B101_CAPTURE_DIR');
const _variant = bool.fromEnvironment('B101_VARIANT_C');
const _defaultParity = bool.fromEnvironment('B101_DEFAULT_PARITY');

// The production API is static const: run this fixture in isolated compiler passes via
// tools/test_authority/skin_swap_rehearsal_v1.py, NOT via a Theme override.
void main() {
  test('the expected token pack is actually compiled', () {
    expect(
      Act0SkinTokensV1.accent,
      _variant
          ? equals(rehearsal.Act0SkinTokensV1.accent)
          : isNot(rehearsal.Act0SkinTokensV1.accent),
    );
    expect(
      Act0SkinTokensV1.background,
      _variant
          ? equals(rehearsal.Act0SkinTokensV1.background)
          : isNot(rehearsal.Act0SkinTokensV1.background),
    );
  });

  const cases = <(String, _Surface, String?)>[
    ('welcome', _Surface.welcome, null),
    ('placement', _Surface.placement, 'act0_shell_placement_screen'),
    ('home', _Surface.home, 'act0_academy_home_leaf'),
    ('runner_theory', _Surface.runnerTheory, 'act0_shell_runner_screen'),
    ('runner_drill', _Surface.runnerDrill, 'act0_shell_runner_screen'),
    ('result', _Surface.sessionSummary, 'act0_shell_block_summary_card'),
    ('review', _Surface.review, 'act0_academy_review_leaf'),
    ('profile', _Surface.profile, 'act0_academy_you_leaf'),
  ];
  for (final (name, surface, marker) in cases) {
    testWidgets('B101 $name paint', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(393, 852);
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.reset);
      final isDrill = surface == _Surface.runnerDrill;
      final isRunner = isDrill || surface == _Surface.runnerTheory;
      final taskId = isDrill ? 'what_poker_is_find_hero' : null;
      final taskLocation = isDrill
          ? [
              for (final world in Act0ShellStateV1.sample.worlds)
                for (final lesson in world.lessons)
                  for (final task in lesson.taskList)
                    if (task.taskId == taskId) (world.worldId, lesson.lessonId),
            ].single
          : null;
      if (isRunner) {
        expect(
          await tester.runAsync(() => Act0F7SceneGateV1.premiumStore.warmUp()),
          isNotNull,
        );
      }
      await tester.pumpWidget(
        RepaintBoundary(
          key: _captureKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData.dark(
              useMaterial3: true,
            ).copyWith(splashFactory: InkRipple.splashFactory),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: Act0ShellPreviewScreenV1(
              enableBetaMetrics: false,
              clock: Act0FixedUtcClockV1(DateTime.utc(2026, 11, 26)),
              debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
                mode: Act0ControlledDemoCaptureModeV1.directState,
                surface: surface,
                worldId: taskLocation?.$1,
                lessonId: taskLocation?.$2,
                taskId: taskId,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Wait for real image decoding rather than allowing a different async
      // placeholder frame to count as a colour change across compilations.
      await tester.runAsync(() async {
        for (final element in find.byType(Image).evaluate()) {
          await precacheImage((element.widget as Image).image, element);
        }
      });
      await tester.pumpAndSettle();
      final target = marker == null
          ? find.byType(Act0WelcomeShellV1)
          : find.byKey(Key(marker));
      expect(target, findsOneWidget);
      expect(tester.takeException(), isNull);

      // Capture only the selected surface's visible bounds, not the navigation
      // bar. A change in shared tab chrome alone is not a passing surface.
      final viewport = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(_captureKey),
      );
      if (!_variant && _directory.isNotEmpty) {
        // Default parity includes the whole screen, including shell chrome.
        final full = await tester.runAsync(
          () async => _rgba(await viewport.toImage()),
        );
        expect(full, isNotNull);
        _compare('${name}_full_viewport', full!, mustChange: false);
      }
      final bounds = tester
          .getRect(target)
          .intersect(Offset.zero & viewport.size);
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
      final paint = await tester.runAsync(() async {
        final layer = viewport.debugLayer! as OffsetLayer;
        return _rgba(await layer.toImage(bounds));
      });
      expect(paint, isNotNull);

      if (isRunner) {
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(runner.selectedTaskId, taskId ?? 'what_poker_is_theory');
        expect(
          runner.runner.phase,
          isDrill ? Act0LessonPhaseV1.drill : Act0LessonPhaseV1.theory,
        );
        // Paint the real scene subtree alone: foreground controls are siblings.
        // The drill is a known registered-six fixture; the theory may use the
        // procedural renderer depending on its teaching table projection. A
        // renderer switch between passes fails rather than skipping parity.
        final registered = find.byKey(const Key('act0_f7_registered_scene'));
        final hasRegistered = registered.evaluate().isNotEmpty;
        if (isDrill) expect(hasRegistered, isTrue);
        final scene = hasRegistered
            ? registered
            : find.byKey(const Key('act0_shell_table'));
        expect(scene, findsOneWidget);
        if (hasRegistered) {
          expect(
            find.byKey(const Key('act0_f7_baked_room_cast_hero')),
            findsOneWidget,
          );
        }
        expect(
          find.byKey(const Key('act0_shell_seat_node_btn')),
          findsOneWidget,
        );
        final box = tester.renderObject<RenderBox>(scene);
        final tablePaint = await tester.runAsync(() => _subtreePaint(box));
        expect(tablePaint, isNotNull);
        // Replaying into an isolated layer moves any retained child layers.
        // Dispose the fixture before another frame can use them.
        await tester.pumpWidget(const SizedBox.shrink());
        final renderer = hasRegistered ? 'registered' : 'procedural';
        _compare(
          'modern_table_${name}_$renderer',
          tablePaint!,
          mustChange: false,
        );
      }
      _compare(name, paint!, mustChange: true);
    });
  }
}

Future<Uint8List> _rgba(ui.Image image) async {
  try {
    final data = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    // Dimensions are part of the comparison, not merely byte count.
    final header = ByteData(8)
      ..setUint32(0, image.width)
      ..setUint32(4, image.height);
    return Uint8List.fromList([
      ...header.buffer.asUint8List(),
      ...data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    ]);
  } finally {
    image.dispose();
  }
}

Future<Uint8List> _subtreePaint(RenderBox box) async {
  final layer = OffsetLayer();
  final handle = LayerHandle<OffsetLayer>(layer);
  final bounds = Offset.zero & box.size;
  try {
    _CapturePaintingContext(layer, bounds).paintSubtree(box);
    return await _rgba(await layer.toImage(bounds));
  } finally {
    layer.removeAllChildren();
    handle.layer = null;
  }
}

class _CapturePaintingContext extends PaintingContext {
  _CapturePaintingContext(OffsetLayer layer, Rect bounds)
    : super(layer, bounds);

  void paintSubtree(RenderBox box) {
    paintChild(box, Offset.zero);
    stopRecordingIfNeeded();
  }
}

void _compare(String name, Uint8List paint, {required bool mustChange}) {
  expect(paint.length, greaterThan(8));
  // A direct flutter test is a fixture smoke test only; the rehearsal driver
  // supplies a fresh directory and refuses to compare without a baseline.
  if (_directory.isEmpty) {
    expect(_variant || _defaultParity, isFalse);
    return;
  }
  final baseline = File('$_directory/$name.rgba');
  if (!_variant && !_defaultParity) {
    baseline.writeAsBytesSync(paint);
    return;
  }
  expect(baseline.existsSync(), isTrue, reason: '$name: missing default paint');
  final before = baseline.readAsBytesSync();
  expect(paint.length, before.length, reason: '$name changed dimensions');
  expect(paint.sublist(0, 8), orderedEquals(before.sublist(0, 8)));
  var changedPixels = 0;
  for (var i = 8; i < paint.length; i += 4) {
    if (paint[i] != before[i] ||
        paint[i + 1] != before[i + 1] ||
        paint[i + 2] != before[i + 2] ||
        paint[i + 3] != before[i + 3]) {
      changedPixels++;
    }
  }
  expect(
    changedPixels,
    _variant && mustChange ? greaterThan(0) : 0,
    reason: _defaultParity
        ? '$name: default paint changed after literal-to-token migration'
        : mustChange
        ? '$name: no rendered colour changed; check SKIN_SWAP_GAPS_v1.md'
        : '$name: frozen Modern Table pixels changed',
  );
}
