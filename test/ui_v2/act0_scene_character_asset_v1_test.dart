// B7 character vertical slice guard.
//
// The slice inverts one ownership boundary: authored artwork takes anatomy,
// hair, hands, clothing and pose, while code keeps seat identity, projection,
// crop, recession, lighting and determinism. These tests lock the three
// properties that make that inversion safe to scale.
//
// 1. exactly one seat is authored, and which seat is a pure function of the
//    B1 slots, so evidence is reproducible across every viewport;
// 2. the seam degrades to the accepted B3 procedural figure rather than to an
//    empty seat, which is what makes shipping it low risk;
// 3. once the artwork is decoded, the authored painter is actually the one
//    that paints — the failure that silently produced procedural captures
//    while reporting success.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_character_asset_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_player_v1.dart';

const _baseSlots = <Offset>[
  Offset(0.47, 0.86),
  Offset(0.08, 0.69),
  Offset(0.08, 0.31),
  Offset(0.47, 0.06),
  Offset(0.86, 0.31),
  Offset(0.86, 0.69),
];
const _seatIds = <String>['s0', 's1', 's2', 's3', 's4', 's5'];

List<Act0SceneSeatSlotV1> _slots() => act0SceneSeatSlotsV1(
  baseSlots: _baseSlots,
  seatIds: _seatIds,
  heroSeatId: 's0',
);

int _painters<T>(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .where((paint) => paint.painter is T)
    .length;

Future<void> _pumpScene(WidgetTester tester) => tester.pumpWidget(
  MaterialApp(
    home: SizedBox(
      width: 320,
      height: 540,
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: Act0ScenePlayerLayerV1(slots: _slots())),
          const Positioned.fill(child: Act0ScenePlayerHeroV1()),
        ],
      ),
    ),
  ),
);

void main() {
  group('authored opponent seat resolution', () {
    test('is the nearest left-flank opponent, never the hero', () {
      final slots = _slots();
      final seatId = act0SceneAuthoredOpponentSeatIdV1(slots);
      expect(seatId, 's1');
      final chosen = slots.firstWhere((slot) => slot.seatId == seatId);
      expect(chosen.isHero, isFalse);
      expect(chosen.plateAnchor.dx, lessThan(0.5));
      // Every other left-flank opponent must be further away, or the slice is
      // not spending its one authored identity on the largest volume.
      for (final slot in slots) {
        if (slot.isHero || slot.plateAnchor.dx >= 0.5) continue;
        expect(slot.depth, lessThanOrEqualTo(chosen.depth));
      }
    });

    test('is stable under seat reordering', () {
      final reversed = act0SceneSeatSlotsV1(
        baseSlots: _baseSlots.reversed.toList(),
        seatIds: _seatIds.reversed.toList(),
        heroSeatId: 's0',
      );
      expect(act0SceneAuthoredOpponentSeatIdV1(reversed), 's1');
    });

    test('returns null when no left-flank opponent exists', () {
      expect(
        act0SceneAuthoredOpponentSeatIdV1(
          act0SceneSeatSlotsV1(
            baseSlots: const <Offset>[Offset(0.47, 0.86), Offset(0.86, 0.69)],
            seatIds: const <String>['s0', 's4'],
            heroSeatId: 's0',
          ),
        ),
        isNull,
      );
    });
  });

  testWidgets('falls back to the B3 procedural figure before artwork decodes', (
    tester,
  ) async {
    Act0SceneCharacterAssetStoreV1.resetForTest();
    await _pumpScene(tester);
    // `testWidgets` runs in a fake-async zone, so the warm-up this widget
    // starts can never complete here. That is exactly the degraded case, and
    // it must still paint six figures rather than an empty room.
    expect(_painters<Act0SceneCharacterAssetPainterV1>(tester), 0);
    expect(find.byType(CustomPaint), findsWidgets);
    for (final seatId in _seatIds.skip(1)) {
      expect(
        find.byKey(Key('act0_scene_player_figure_$seatId')),
        findsOneWidget,
      );
    }
  });

  testWidgets('paints authored artwork for exactly one seat plus the hero', (
    tester,
  ) async {
    Act0SceneCharacterAssetStoreV1.resetForTest();
    await tester.runAsync(Act0SceneCharacterAssetStoreV1.warmUp);
    expect(
      Act0SceneCharacterAssetStoreV1.isReady,
      isTrue,
      reason: 'the slice assets must be declared in the bundle',
    );
    await _pumpScene(tester);
    // One opponent and one hero foreground: the admitted slice, not a pack.
    expect(_painters<Act0SceneCharacterAssetPainterV1>(tester), 2);
  });
}
