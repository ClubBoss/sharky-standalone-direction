// TEXT_SCALE_POLICY_V1 = SINGLE_CANONICAL_PRODUCT_SCALE.
//
// Sharky v1 ships one canonical typography/layout scale; accessibility text
// scaling is deferred. This guard does not assert anything about how the
// product looks at an enlarged scale - it asserts that an enlarged *system*
// scale cannot reach the layout at all, so no second product layout can appear
// by accident.
//
// The enforcement seam is the single `MediaQuery.withClampedTextScaling`
// wrapper in `Act0ShellPreviewScreenV1`, which every entry point to the active
// learner-facing route passes through. If that wrapper is removed or bypassed,
// this guard fails.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget host(Object k, double systemTextScale) => MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(systemTextScale)),
        child: Act0ShellPreviewScreenV1(
          key: ValueKey<Object>(k),
          state: Act0ShellStateV1.sample,
          showPlacementOnStart: false,
          debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
            worldId: 'world_1',
            lessonId: 'fold_check_call_raise',
            taskId: 'actions_check_drill',
          ),
        ),
      ),
    ),
  );

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  Future<void> settle(WidgetTester t) async {
    var f = 0;
    while (t.binding.hasScheduledFrame && f < 400) {
      await t.pump(const Duration(milliseconds: 16));
      f++;
    }
  }

  const probes = <String>[
    'act0_shell_table_felt',
    'act0_shell_card_board_0',
    'act0_shell_bet_chip_SB',
    'act0_shell_bet_chip_BB',
    'act0_wave_a_learning_context',
    'act0_shell_option_fold',
    'act0_shell_center_pot_stat',
  ];

  Future<List<String>> snapshot(WidgetTester t, double scale, Size size) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    await t.pumpWidget(host('probe-$scale-$size', scale));
    await settle(t);
    return <String>[
      for (final k in probes)
        if (find.byKey(Key(k)).evaluate().isNotEmpty)
          '$k=${t.getRect(find.byKey(Key(k)).first)}'
        else
          '$k=ABSENT',
    ];
  }

  for (final size in const <Size>[
    Size(375, 812),
    Size(402, 874),
    Size(430, 932),
  ]) {
    testWidgets('Act0 route renders at one canonical text scale at $size', (
      t,
    ) async {
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final atOne = await snapshot(t, 1.0, size);
      for (final inflated in const <double>[1.3, 1.4, 2.0]) {
        expect(
          await snapshot(t, inflated, size),
          atOne,
          reason: 'system text scale $inflated must not change layout at $size',
        );
      }
    });
  }
}
