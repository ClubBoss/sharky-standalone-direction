// CYCLE C — PHASE C5: 9-max headroom falsifier.
//
// Drives the SAME tiered grammar (Act0SceneTieredOpponentLayerV1) with Hero + 8
// synthetic opponents, distributed across the same three tiers, over the real
// canonical stage rect. Diagnostic figures only. Captures 402 + 375 and reports
// the minimum rendered head-band and worst inter-figure overlap.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_player_v1.dart';

const _viewports = <String, Size>{
  'compact_375x812': Size(375, 812),
  'canonical_402x874': Size(402, 874),
};

// 8 opponents: 2 far-ish centre-biased, 3 per upper flank pair, plus near
// flanks — mapped onto the SAME tier classifier by their plate anchor + depth.
List<Act0SceneSeatSlotV1> _nineMaxOpponents() {
  final specs = <(String, Offset, double)>[
    ('utg', const Offset(0.44, 0.06), 0.06),
    ('utg1', const Offset(0.58, 0.09), 0.09),
    ('lj', const Offset(0.20, 0.26), 0.26),
    ('hj', const Offset(0.80, 0.26), 0.26),
    ('mb', const Offset(0.12, 0.44), 0.44),
    ('co', const Offset(0.88, 0.44), 0.44),
    ('sb', const Offset(0.16, 0.66), 0.66),
    ('bb', const Offset(0.84, 0.66), 0.66),
  ];
  return [
    for (final (id, anchor, depth) in specs)
      Act0SceneSeatSlotV1(
        seatId: id,
        depth: depth,
        plateAnchor: anchor,
        characterAnchor: anchor,
        betAnchor: anchor,
        cardAnchor: anchor,
        plateScale: 1,
        volumeScale: Act0ScenePerspectiveV1.canonical.volumeScaleAt(depth),
        isHero: false,
      ),
  ];
}

void main() {
  for (final entry in _viewports.entries) {
    testWidgets('9-max headroom — ${entry.key}', (tester) async {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const camera = Act0SceneCameraV1.cycleCRebalanceV2;
      final stage = camera.stageRect(entry.value);
      final slots = _nineMaxOpponents();

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(
            child: Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: Color(0xFF0B1B2C)),
                ),
                // Same room + a felt stand-in so occlusion reads.
                Positioned.fromRect(
                  rect: stage,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF15402F),
                      borderRadius: BorderRadius.circular(stage.width * 0.32),
                    ),
                  ),
                ),
                Positioned(
                  left: -stage.width * 0.16,
                  right: -stage.width * 0.16,
                  top: stage.top - stage.height * 0.06,
                  bottom:
                      entry.value.height - stage.bottom - stage.height * 0.04,
                  child: Act0SceneTieredOpponentLayerV1(
                    slots: slots,
                    plane: Act0SceneTieredPlaneV1.back,
                  ),
                ),
                Positioned.fromRect(
                  rect: stage,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x9915402F),
                      borderRadius: BorderRadius.circular(stage.width * 0.32),
                    ),
                  ),
                ),
                Positioned(
                  left: -stage.width * 0.16,
                  right: -stage.width * 0.16,
                  top: stage.top - stage.height * 0.06,
                  bottom:
                      entry.value.height - stage.bottom - stage.height * 0.04,
                  child: Act0SceneTieredOpponentLayerV1(
                    slots: slots,
                    plane: Act0SceneTieredPlaneV1.front,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final rects = <String, Rect>{};
      for (final s in slots) {
        final f = find.byKey(Key('act0_scene_player_figure_${s.seatId}'));
        if (f.evaluate().isNotEmpty) rects[s.seatId] = tester.getRect(f.first);
      }
      // Worst pairwise overlap area fraction (of the smaller box).
      double worstOverlap = 0;
      final ids = rects.keys.toList();
      for (var i = 0; i < ids.length; i++) {
        for (var j = i + 1; j < ids.length; j++) {
          final a = rects[ids[i]]!;
          final b = rects[ids[j]]!;
          final o = a.intersect(b);
          if (o.width > 0 && o.height > 0) {
            final frac =
                (o.width * o.height) /
                (a.width * a.height < b.width * b.height
                    ? a.width * a.height
                    : b.width * b.height);
            if (frac > worstOverlap) worstOverlap = frac;
          }
        }
      }
      final minW = rects.values
          .map((r) => r.width)
          .reduce((a, b) => a < b ? a : b);

      // ignore: avoid_print
      print(
        'CYCLE_C_9MAX ${entry.key} '
        '${const JsonEncoder().convert({
          'count': rects.length,
          'minBoxW': minW.toStringAsFixed(1),
          'worstOverlapFrac': worstOverlap.toStringAsFixed(2),
          'rects': {for (final e in rects.entries) e.key: '${e.value.left.toStringAsFixed(0)},${e.value.top.toStringAsFixed(0)} '
                '${e.value.width.toStringAsFixed(0)}x${e.value.height.toStringAsFixed(0)}'},
        })}',
      );

      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/cycle_c/9max_${entry.key}.png'),
      );
      expect(rects.length, 8);
    });
  }
}
