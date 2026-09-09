// CYCLE B — real runtime proof for the far-centre seated-embodiment pilot.
//
// Drives the real canonical learning route (same host as
// act0_b7_canonical_scene_geometry_invariant_v1_test.dart) at the three
// canonical phone viewports, through DECIDE / CORRECT / WRONG->REPAIR, and
//   - writes a golden PNG of each real Flutter frame (run with
//     `flutter test --update-goldens` to (re)generate under
//     test/ui_v2/goldens/cycle_b/), and
//   - re-dumps the far-centre figure rect so geometry drift is provable.
//
// The pilot asset swap is UTG-only; every other seat stays procedural.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_player_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _viewportsV1 = <String, Size>{
  'compact_375x812': Size(375, 812),
  'canonical_402x874': Size(402, 874),
  'large_430x932': Size(430, 932),
};

Widget _host(Object remountKey) => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: RepaintBoundary(
    child: Act0ShellPreviewScreenV1(
      key: ValueKey<Object>(remountKey),
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
);

Future<void> _settle(WidgetTester tester) async {
  var frames = 0;
  while (tester.binding.hasScheduledFrame && frames < 600) {
    await tester.pump(const Duration(milliseconds: 16));
    frames++;
  }
}

Future<void> _hop(WidgetTester tester, Key key) async {
  expect(find.byKey(key), findsWidgets, reason: 'route control $key');
  await tester.tap(find.byKey(key).first, warnIfMissed: false);
  await _settle(tester);
}

Rect? _figureRect(WidgetTester tester) {
  final finder = find.byWidgetPredicate(
    (w) =>
        w is Act0ScenePlayerFigureV1 &&
        Act0ScenePilotCharacterAssetV1.isFarCentrePilotSeat(w.slot),
  );
  if (finder.evaluate().isEmpty) return null;
  return tester.getRect(finder.first);
}

Future<void> _shot(WidgetTester tester, String name) async {
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('goldens/cycle_b/$name.png'),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  for (final entry in _viewportsV1.entries) {
    testWidgets('pilot runtime proof — ${entry.key}', (tester) async {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Run A — decision then correct feedback.
      await tester.pumpWidget(_host('${entry.key}_a'));
      await _settle(tester);
      // Await the real asset decode so the golden captures the production
      // render, not the one-frame procedural fallback (a capture-tool timing
      // artifact, not a product-art result).
      await tester.runAsync(
        () => precacheImage(
          const AssetImage(Act0ScenePilotCharacterAssetV1.farCentreAssetPath),
          tester.element(find.byType(Act0ShellPreviewScreenV1)),
        ),
      );
      await _settle(tester);
      final decideRect = _figureRect(tester);
      expect(
        decideRect,
        isNotNull,
        reason: 'far-centre pilot seat must render',
      );
      await _shot(tester, '${entry.key}_decide');
      await _hop(tester, const Key('act0_shell_option_check'));
      await _shot(tester, '${entry.key}_correct');
      final correctRect = _figureRect(tester);

      // Run B — decision then wrong feedback then repair.
      await tester.pumpWidget(_host('${entry.key}_b'));
      await _settle(tester);
      await _hop(tester, const Key('act0_shell_option_fold'));
      await _shot(tester, '${entry.key}_wrong');
      await _hop(tester, const Key('act0_shell_feedback_continue_cta'));
      await _shot(tester, '${entry.key}_repair');
      final repairRect = _figureRect(tester);

      // Geometry-drift guard: the pilot must not move the seat it inhabits.
      for (final other in <Rect?>[correctRect, repairRect]) {
        expect(other, isNotNull);
        expect((other!.left - decideRect!.left).abs(), lessThanOrEqualTo(0.5));
        expect((other.top - decideRect.top).abs(), lessThanOrEqualTo(0.5));
        expect((other.width - decideRect.width).abs(), lessThanOrEqualTo(0.5));
        expect(
          (other.height - decideRect.height).abs(),
          lessThanOrEqualTo(0.5),
        );
      }

      // ignore: avoid_print
      print(
        'CYCLE_B_PILOT_RECT ${entry.key} '
        '${const JsonEncoder().convert({'l': decideRect!.left.toStringAsFixed(2), 't': decideRect.top.toStringAsFixed(2), 'w': decideRect.width.toStringAsFixed(2), 'h': decideRect.height.toStringAsFixed(2)})}',
      );
    });
  }
}
