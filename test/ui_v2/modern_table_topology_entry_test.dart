import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_table_topology_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';

void main() {
  testWidgets('canonical table renders 9 max and 10 max seat layouts', (
    tester,
  ) async {
    Future<void> pumpTable(int seatCount) async {
      await tester.pumpWidget(
        MaterialApp(home: ModernTableScreenV1(seatCount: seatCount)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }

    await pumpTable(9);
    for (var i = 0; i < 9; i++) {
      expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
    }
    expect(find.byKey(const Key('modern_table_seat_9')), findsNothing);

    await pumpTable(10);
    for (var i = 0; i < 10; i++) {
      expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
    }
  });

  testWidgets('canonical table keeps 9 max on the full-ring topology path', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 9)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(
      canonicalTableTopologyProfileForSeatCountV1(9).id,
      CanonicalTableTopologyProfileIdV1.fullRing9Max,
    );
    for (var i = 0; i < 9; i++) {
      expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
    }
    expect(find.byKey(const Key('modern_table_seat_9')), findsNothing);
  });

  testWidgets('canonical table keeps 10 max on the full-ring topology path', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 10)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(
      canonicalTableTopologyProfileForSeatCountV1(10).id,
      CanonicalTableTopologyProfileIdV1.fullRing10Max,
    );
    for (var i = 0; i < 10; i++) {
      expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
    }
    expect(find.byKey(const Key('modern_table_seat_10')), findsNothing);
  });

  testWidgets('canonical table keeps 6 max on the short-handed topology path', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 6)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(
      canonicalTableTopologyProfileForSeatCountV1(6).id,
      CanonicalTableTopologyProfileIdV1.shortHanded6Max,
    );
    for (var i = 0; i < 6; i++) {
      expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
    }
    expect(find.byKey(const Key('modern_table_seat_6')), findsNothing);
  });

  testWidgets('canonical table keeps 2 max on the heads-up topology path', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 2)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(
      canonicalTableTopologyProfileForSeatCountV1(2).id,
      CanonicalTableTopologyProfileIdV1.headsUp2Max,
    );
    for (var i = 0; i < 2; i++) {
      expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
    }
    expect(find.byKey(const Key('modern_table_seat_2')), findsNothing);
  });

  testWidgets(
    'canonical table keeps 5 max on the derived transitional topology path',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ModernTableScreenV1(seatCount: 5)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(
        canonicalTableTopologyProfileForSeatCountV1(5).id,
        CanonicalTableTopologyProfileIdV1.transitionalDerived,
      );
      for (var i = 0; i < 5; i++) {
        expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
      }
      expect(find.byKey(const Key('modern_table_seat_5')), findsNothing);
    },
  );

  testWidgets(
    'canonical table keeps 4 max on the derived transitional topology path',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ModernTableScreenV1(seatCount: 4)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(
        canonicalTableTopologyProfileForSeatCountV1(4).id,
        CanonicalTableTopologyProfileIdV1.transitionalDerived,
      );
      for (var i = 0; i < 4; i++) {
        expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
      }
      expect(find.byKey(const Key('modern_table_seat_4')), findsNothing);
    },
  );

  testWidgets(
    'canonical table keeps 3 max on the derived transitional topology path',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ModernTableScreenV1(seatCount: 3)),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(
        canonicalTableTopologyProfileForSeatCountV1(3).id,
        CanonicalTableTopologyProfileIdV1.transitionalDerived,
      );
      for (var i = 0; i < 3; i++) {
        expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
      }
      expect(find.byKey(const Key('modern_table_seat_3')), findsNothing);
    },
  );
}
