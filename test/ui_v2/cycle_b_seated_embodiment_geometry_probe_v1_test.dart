// CYCLE B — real runtime geometry probe for the seated-embodiment pilot.
//
// READ-ONLY measurement. Drives the real canonical learning route through the
// deterministic debug-harness entry (identical host to
// act0_b7_canonical_scene_geometry_invariant_v1_test.dart) at the three
// canonical phone viewports and dumps, as JSON on stdout:
//   - every rendered opponent figure rect (act0_scene_player_figure_<seatId>)
//   - the felt / silhouette / board / hero-card / pot / coach-surface rects
//   - the derived visible envelope of each figure after felt-top occlusion
//
// No product code is modified. Output is local-only.
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
  home: Act0ShellPreviewScreenV1(
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
);

Future<void> _settle(WidgetTester tester) async {
  var frames = 0;
  while (tester.binding.hasScheduledFrame && frames < 400) {
    await tester.pump(const Duration(milliseconds: 16));
    frames++;
  }
}

Map<String, double> _rectJson(Rect r) => <String, double>{
  'l': double.parse(r.left.toStringAsFixed(2)),
  't': double.parse(r.top.toStringAsFixed(2)),
  'r': double.parse(r.right.toStringAsFixed(2)),
  'b': double.parse(r.bottom.toStringAsFixed(2)),
  'w': double.parse(r.width.toStringAsFixed(2)),
  'h': double.parse(r.height.toStringAsFixed(2)),
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  for (final entry in _viewportsV1.entries) {
    testWidgets('GEOMETRY PROBE ${entry.key}', (tester) async {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(entry.key));
      await _settle(tester);

      final report = <String, dynamic>{
        'viewport': entry.key,
        'size': <String, double>{
          'w': entry.value.width,
          'h': entry.value.height,
        },
      };

      // --- named scene anchors -------------------------------------------------
      final anchors = <String, Key>{
        'felt': const Key('act0_shell_table_felt'),
        'silhouette': const Key('act0_integrated_scene_perspective_silhouette'),
        'board_0': const Key('act0_shell_card_board_0'),
        'hero_card_0': const Key('act0_shell_card_hero_0'),
        'pot': const Key('act0_shell_wave1_pot_priority_stat'),
        'coach_surface': const Key('act0_wave_a_learning_context'),
        'player_plane': const Key('act0_scene_player_volume_plane'),
        'scene_window': const Key('act0_shell_scene_window'),
        'cycle_envelope': const Key('act0_shell_shared_runner_cycle_envelope'),
      };
      final anchorRects = <String, Rect>{};
      final anchorsJson = <String, dynamic>{};
      anchors.forEach((name, key) {
        final finder = find.byKey(key);
        if (finder.evaluate().isEmpty) {
          anchorsJson[name] = 'ABSENT';
          return;
        }
        final rect = tester.getRect(finder.first);
        anchorRects[name] = rect;
        anchorsJson[name] = _rectJson(rect);
      });
      report['anchors'] = anchorsJson;

      // --- every rendered opponent figure -----------------------------------
      final figureFinder = find.byWidgetPredicate((widget) {
        if (widget is! Act0ScenePlayerFigureV1) return false;
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith('act0_scene_player_figure_');
      });

      final feltTop = anchorRects['felt']?.top;
      final silTop = anchorRects['silhouette']?.top;
      final railOcclusionY = silTop ?? feltTop;

      final figures = <Map<String, dynamic>>[];
      for (final el in figureFinder.evaluate()) {
        final widget = el.widget as Act0ScenePlayerFigureV1;
        final seatId = (widget.key as ValueKey<String>).value.replaceFirst(
          'act0_scene_player_figure_',
          '',
        );
        final rect = tester.getRect(find.byWidget(widget));
        final slot = widget.slot;
        // Visible portion after the table silhouette/felt occludes the lower body.
        double? visibleTop;
        double? visibleBottom;
        double? occludedFraction;
        if (railOcclusionY != null) {
          visibleTop = rect.top;
          visibleBottom = rect.bottom < railOcclusionY
              ? rect.bottom
              : railOcclusionY;
          final visH = (visibleBottom - visibleTop).clamp(0.0, rect.height);
          occludedFraction = rect.height <= 0
              ? 0
              : double.parse(
                  (1 - (visH / rect.height)).clamp(0.0, 1.0).toStringAsFixed(3),
                );
        }
        figures.add(<String, dynamic>{
          'seatId': seatId,
          'depth': double.parse(slot.depth.toStringAsFixed(4)),
          'depthTier': slot.depthTier,
          'isHero': slot.isHero,
          'plateAnchor': <String, double>{
            'dx': double.parse(slot.plateAnchor.dx.toStringAsFixed(4)),
            'dy': double.parse(slot.plateAnchor.dy.toStringAsFixed(4)),
          },
          'characterAnchor': <String, double>{
            'dx': double.parse(slot.characterAnchor.dx.toStringAsFixed(4)),
            'dy': double.parse(slot.characterAnchor.dy.toStringAsFixed(4)),
          },
          'volumeScale': double.parse(slot.volumeScale.toStringAsFixed(4)),
          'destRect': _rectJson(rect),
          'aspect_w_over_h': rect.height <= 0
              ? null
              : double.parse((rect.width / rect.height).toStringAsFixed(4)),
          'visible_after_occlusion': railOcclusionY == null
              ? 'NO_RAIL_REF'
              : <String, double>{
                  't': double.parse(visibleTop!.toStringAsFixed(2)),
                  'b': double.parse(visibleBottom!.toStringAsFixed(2)),
                  'h': double.parse(
                    (visibleBottom - visibleTop).toStringAsFixed(2),
                  ),
                },
          'occluded_fraction_vertical': occludedFraction,
        });
      }
      figures.sort(
        (a, b) => (a['depth'] as double).compareTo(b['depth'] as double),
      );
      report['opponent_figures'] = figures;
      report['rail_occlusion_y'] = railOcclusionY;

      // Also dump the hero foreground volume rect if present.
      final heroFg = find.byKey(const Key('act0_scene_hero_foreground_volume'));
      report['hero_foreground'] = heroFg.evaluate().isEmpty
          ? 'ABSENT'
          : _rectJson(tester.getRect(heroFg.first));

      // ignore: avoid_print
      print('CYCLE_B_GEOMETRY_JSON_BEGIN');
      // ignore: avoid_print
      print(const JsonEncoder.withIndent('  ').convert(report));
      // ignore: avoid_print
      print('CYCLE_B_GEOMETRY_JSON_END');

      expect(figures, isNotEmpty, reason: 'expected rendered opponent figures');
    });
  }
}
