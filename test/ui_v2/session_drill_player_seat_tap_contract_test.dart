import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  Future<void> _pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 40,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for ${finder.description}');
  }

  Future<void> _tapSeat(WidgetTester tester, int seatIndex) async {
    final table = tester.widget<ModernTableScreenV1>(
      find.byType(ModernTableScreenV1),
    );
    expect(table.onSeatTapV1, isNotNull);
    table.onSeatTapV1!(seatIndex);
  }

  SessionDrillItemV1 _authoredItem(String path) {
    final raw = File(path).readAsStringSync();
    final spec = DrillSpecV1.fromJsonString(raw);
    return SessionDrillItemV1(drillId: spec.id, spec: spec);
  }

  testWidgets(
    'seat_tap keeps symbolic seat role and seat id taps deterministic',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _authoredItem(
          'content/worlds/world2/v1/sessions/w2.s02/drills/d.find_btn.json',
        ),
        _authoredItem(
          'content/worlds/world2/v1/sessions/w2.s02/drills/d.find_seat_s0.json',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s02',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(tester, find.byType(ModernTableScreenV1));

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_0')), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_1')), findsOneWidget);

      await _tapSeat(tester, 1);
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_result_fail')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_fail_detail')),
        findsOneWidget,
      );
      expect(find.textContaining('Incorrect.'), findsNothing);
      expect(find.textContaining('Better answer: BTN.'), findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_result_fail_why_v1')),
        findsOneWidget,
      );
      expect(find.textContaining('Notice:'), findsOneWidget);
      expect(find.textContaining('Next time:'), findsOneWidget);

      await _tapSeat(tester, 0);
      await tester.pumpAndSettle();
      expect(
        find.text('Tap seat S0 before evaluating open or fold.'),
        findsWidgets,
      );

      await _tapSeat(tester, 1);
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_result_fail')),
        findsOneWidget,
      );

      await _tapSeat(tester, 0);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('authored seat_tap drills can surface through the World 2 host', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 1.0;

    final seatTapDrills = <SessionDrillItemV1>[
      _authoredItem(
        'content/worlds/world2/v1/sessions/w2.s01/drills/d.find_sb.json',
      ),
      _authoredItem(
        'content/worlds/world2/v1/sessions/w2.s02/drills/d.find_seat_s1.json',
      ),
    ];

    expect(
      seatTapDrills.map((item) => item.drillId),
      containsAll(<String>['find_sb', 'find_seat_s1']),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s01',
          debugDrillsOverrideV1: seatTapDrills,
        ),
      ),
    );
    await _pumpUntilFound(tester, find.byType(ModernTableScreenV1));

    expect(find.byType(ModernTableScreenV1), findsOneWidget);
    expect(find.byKey(const Key('modern_table_seat_0')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_seat_5')), findsOneWidget);
  });
}
