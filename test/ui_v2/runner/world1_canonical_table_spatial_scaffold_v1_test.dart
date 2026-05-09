import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_spatial_scaffold_v1.dart';

void main() {
  test(
    'world1 canonical table spatial scaffold resolves seat geometry and rotation',
    () {
      final scaffold = resolveWorld1CanonicalTableSpatialScaffoldV1(
        const World1CanonicalTableSpatialScaffoldInputV1(
          canvasSize: Size(390, 320),
          portraitLayout: true,
          seatIds: <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'],
          selectedVisualSeatId: 'co',
          targetSeatId: 'hj',
          demoHandLoopVisualStep: true,
          heroSeatId: 'sb',
        ),
      );

      expect(scaffold.compactPhone, isTrue);
      expect(scaffold.ultraCompactPortrait, isFalse);
      expect(scaffold.seatRenderOrderIds.last, 'co');
      final displayButtonSeat = scaffold.displaySeatIdForLogical('btn');
      expect(displayButtonSeat, 'co');
      expect(scaffold.logicalSeatIdForDisplay(displayButtonSeat), 'btn');
      expect(scaffold.targetSeatCenter, isNotNull);
      expect(scaffold.btnCenter, isNot(equals(scaffold.tableCenter)));
      expect(
        scaffold.seatCentersById.keys,
        containsAll(<String>['btn', 'sb', 'bb', 'utg', 'hj', 'co']),
      );
    },
  );

  test(
    'world1 canonical table spatial scaffold resolves normalized alignment',
    () {
      final scaffold = resolveWorld1CanonicalTableSpatialScaffoldV1(
        const World1CanonicalTableSpatialScaffoldInputV1(
          canvasSize: Size(800, 600),
          portraitLayout: false,
          seatIds: <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'],
          selectedVisualSeatId: null,
          targetSeatId: null,
          demoHandLoopVisualStep: false,
          heroSeatId: null,
        ),
      );

      expect(
        scaffold.alignmentForPoint(scaffold.tableCenter),
        Alignment.center,
      );
      expect(
        scaffold.resolveSeatCenter('btn').dy,
        greaterThan(scaffold.resolveSeatCenter('utg').dy),
      );
      expect(
        scaffold.resolveSeatCenter('sb').dx,
        greaterThan(scaffold.resolveSeatCenter('btn').dx),
      );
      expect(
        scaffold.resolveSeatCenter('bb').dx,
        greaterThan(scaffold.resolveSeatCenter('btn').dx),
      );
      expect(
        scaffold.resolveSeatCenter('hj').dx,
        lessThan(scaffold.resolveSeatCenter('btn').dx),
      );
      expect(
        scaffold.resolveSeatCenter('co').dx,
        lessThan(scaffold.resolveSeatCenter('btn').dx),
      );
      expect(
        scaffold.resolveSeatCenter('bb').dy,
        lessThan(scaffold.resolveSeatCenter('sb').dy),
      );
      expect(
        scaffold.resolveSeatCenter('hj').dy,
        lessThan(scaffold.resolveSeatCenter('co').dy),
      );
      expect(scaffold.nonOverlappingSeatSize, greaterThanOrEqualTo(44));
    },
  );

  test('world1 canonical seat ring order helper stays button-first', () {
    expect(
      resolveWorld1CanonicalSeatRingOrderV1(const <String>[
        'co',
        'bb',
        'btn',
        'utg',
        'hj',
        'sb',
      ]),
      <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'],
    );
    expect(
      buildWorld1CanonicalSeatOrderHintV1(const <String>[
        'btn',
        'sb',
        'bb',
        'utg',
        'hj',
        'co',
      ]),
      'Order: Button -> Small Blind -> Big Blind -> UTG -> Hijack -> Cutoff.',
    );
    expect(
      resolveWorld1CanonicalSeatOrderBadgeTextV1('hj', const <String>[
        'btn',
        'sb',
        'bb',
        'utg',
        'hj',
        'co',
      ]),
      '5 Hijack',
    );
  });
}
