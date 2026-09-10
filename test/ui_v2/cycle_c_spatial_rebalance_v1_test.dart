// CYCLE C — BOUNDED_SPATIAL_REBALANCE_V1 real runtime proof.
//
// Drives the real canonical learning route (same host as the B7 geometry
// invariant test) at the canonical phone viewports, dumps every rendered
// opponent figure rect + scene anchors as JSON, writes golden PNGs of the real
// Flutter frames, and checks a diagnostic R2.3 coach-budget box can coexist.
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

// Diagnostic R2.3 top-system budget: progress strip + Sharky portrait + speech
// bubble with up to 3 body lines + a clue line. Held as a fraction of height.
const _coachBudgetFraction = 0.21;

Widget _host(Object remountKey, {bool coachBudgetOverlay = false}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          RepaintBoundary(
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
          if (coachBudgetOverlay)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, c) => Container(
                    key: const Key('cycle_c_coach_budget_box'),
                    height:
                        MediaQuery.sizeOf(context).height *
                        _coachBudgetFraction,
                    color: const Color(0x33FF00AA),
                  ),
                ),
              ),
            ),
        ],
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

Future<void> _shot(WidgetTester tester, String name) async {
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('goldens/cycle_c/$name.png'),
  );
}

Map<String, double> _r(Rect r) => {
  'l': double.parse(r.left.toStringAsFixed(1)),
  't': double.parse(r.top.toStringAsFixed(1)),
  'r': double.parse(r.right.toStringAsFixed(1)),
  'b': double.parse(r.bottom.toStringAsFixed(1)),
  'w': double.parse(r.width.toStringAsFixed(1)),
  'h': double.parse(r.height.toStringAsFixed(1)),
};

Map<String, dynamic> _dump(WidgetTester tester, String vp, Size size) {
  final anchors = <String, Key>{
    'felt': const Key('act0_shell_table_felt'),
    'silhouette': const Key('act0_integrated_scene_perspective_silhouette'),
    'board_0': const Key('act0_shell_card_board_0'),
    'hero_card_0': const Key('act0_shell_card_hero_0'),
    'pot': const Key('act0_shell_wave1_pot_priority_stat'),
    'coach_surface': const Key('act0_wave_a_learning_context'),
  };
  final out = <String, dynamic>{'viewport': vp};
  final aj = <String, dynamic>{};
  anchors.forEach((n, k) {
    final f = find.byKey(k);
    aj[n] = f.evaluate().isEmpty ? 'ABSENT' : _r(tester.getRect(f.first));
  });
  out['anchors'] = aj;
  final figs = <Map<String, dynamic>>[];
  for (final seatId in const ['utg', 'bb', 'hj', 'sb', 'co']) {
    final f = find.byKey(Key('act0_scene_player_figure_$seatId'));
    if (f.evaluate().isEmpty) {
      figs.add({'seatId': seatId, 'rect': 'ABSENT'});
      continue;
    }
    final rect = tester.getRect(f.first);
    final onW =
        (rect.right.clamp(0.0, size.width) - rect.left.clamp(0.0, size.width))
            .clamp(0.0, size.width);
    figs.add({
      'seatId': seatId,
      'rect': _r(rect),
      'onscreen_w': double.parse(onW.toStringAsFixed(1)),
      'onscreen_frac': double.parse((onW / rect.width).toStringAsFixed(2)),
    });
  }
  out['figures'] = figs;
  return out;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  for (final entry in _viewportsV1.entries) {
    testWidgets('cycle C spatial rebalance — ${entry.key}', (tester) async {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host('${entry.key}_a'));
      await _settle(tester);
      await tester.runAsync(
        () => precacheImage(
          const AssetImage(Act0ScenePilotCharacterAssetV1.farCentreAssetPath),
          tester.element(find.byType(Act0ShellPreviewScreenV1)),
        ),
      );
      await _settle(tester);

      final decide = _dump(tester, entry.key, entry.value);
      // ignore: avoid_print
      print('CYCLE_C_JSON ${const JsonEncoder().convert(decide)}');
      await _shot(tester, '${entry.key}_decide');
      await _hop(tester, const Key('act0_shell_option_check'));
      await _shot(tester, '${entry.key}_correct');
      final correct = _dump(tester, entry.key, entry.value);

      await tester.pumpWidget(_host('${entry.key}_b'));
      await _settle(tester);
      await _hop(tester, const Key('act0_shell_option_fold'));
      await _shot(tester, '${entry.key}_wrong');
      await _hop(tester, const Key('act0_shell_feedback_continue_cta'));
      await _shot(tester, '${entry.key}_repair');
      final repair = _dump(tester, entry.key, entry.value);

      // Coach-budget coexistence check (diagnostic overlay).
      await tester.pumpWidget(
        _host('${entry.key}_coach', coachBudgetOverlay: true),
      );
      await _settle(tester);
      await tester.runAsync(
        () => precacheImage(
          const AssetImage(Act0ScenePilotCharacterAssetV1.farCentreAssetPath),
          tester.element(find.byType(Act0ShellPreviewScreenV1)),
        ),
      );
      await _settle(tester);
      await _shot(tester, '${entry.key}_coachbudget');
      final coachBox = tester.getRect(
        find.byKey(const Key('cycle_c_coach_budget_box')),
      );
      final utg = find.byKey(const Key('act0_scene_player_figure_utg'));
      final utgRect = tester.getRect(utg.first);
      // ignore: avoid_print
      print(
        'CYCLE_C_COACH ${entry.key} budgetBottom=${coachBox.bottom.toStringAsFixed(1)} '
        'utgTop=${utgRect.top.toStringAsFixed(1)} '
        'gap=${(utgRect.top - coachBox.bottom).toStringAsFixed(1)}',
      );

      // Geometry stability across learning states (far-centre pilot seat).
      final d = (decide['figures'] as List).firstWhere(
        (f) => f['seatId'] == 'utg',
      )['rect'];
      for (final s in <Map<String, dynamic>>[correct, repair]) {
        final o = (s['figures'] as List).firstWhere(
          (f) => f['seatId'] == 'utg',
        )['rect'];
        if (d is Map && o is Map) {
          for (final k in const ['l', 't', 'w', 'h']) {
            expect(
              ((d[k] as num) - (o[k] as num)).abs(),
              lessThanOrEqualTo(0.6),
              reason: 'utg $k drifted between states',
            );
          }
        }
      }

      for (final seatId in const ['utg', 'bb', 'hj', 'sb', 'co']) {
        expect(
          find.byKey(Key('act0_scene_player_figure_$seatId')),
          findsOneWidget,
          reason: '$seatId must render',
        );
      }
    });
  }
}
