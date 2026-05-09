import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 60,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for ${finder.description}');
  }

  testWidgets(
    'w9.s05 surfaces authored position exploit drills without placeholder residue',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w9.s05'),
      ))!;

      expect(
        drills.map((item) => item.drillId).toList(),
        equals(const <String>[
          'find_seat_s2_position',
          'find_btn_position',
          'tap_flop_position',
          'tap_turn_position',
          'tap_river_position',
          'tap_hole_right_position',
          'choose_call_position_control',
          'choose_raise_position_pressure',
        ]),
      );
      expect(
        drills.map((item) => item.spec.kind).toList(),
        equals(const <DrillKindV1>[
          DrillKindV1.seatTap,
          DrillKindV1.seatTap,
          DrillKindV1.boardTap,
          DrillKindV1.boardTap,
          DrillKindV1.boardTap,
          DrillKindV1.holeCardsTap,
          DrillKindV1.actionChoice,
          DrillKindV1.actionChoice,
        ]),
      );
      expect(
        drills.every(
          (item) =>
              !item.spec.prompt.toLowerCase().contains('todo') &&
              !(item.spec.whyV1 ?? '').toLowerCase().contains('todo'),
        ),
        isTrue,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w9.s05',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_prompt')),
        findsOneWidget,
      );
      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_seat_marker_1')),
        findsOneWidget,
      );
      expect(find.text('Position exploit setup: tap seat S2.'), findsOneWidget);
      expect(drills.first.spec.scenarioTableContextV1, isNotNull);
      expect(find.textContaining('TODO'), findsNothing);
    },
  );

  testWidgets(
    'w9.s03 renders stacked seatId markers and preserved blind overlays',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w9.s03'),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w9.s03',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);

      final btnMarker = find.byKey(const Key('modern_table_seat_marker_0'));
      expect(btnMarker, findsOneWidget);
      expect(
        find.descendant(of: btnMarker, matching: find.text('S1')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: btnMarker, matching: find.text('BTN')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: btnMarker, matching: find.text('S1/BTN')),
        findsNothing,
      );

      final coMarker = find.byKey(const Key('modern_table_seat_marker_1'));
      expect(coMarker, findsOneWidget);
      expect(
        find.descendant(of: coMarker, matching: find.text('S2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: coMarker, matching: find.text('CO')),
        findsOneWidget,
      );

      final hjMarker = find.byKey(const Key('modern_table_seat_marker_2'));
      expect(hjMarker, findsOneWidget);
      expect(
        find.descendant(of: hjMarker, matching: find.text('S3')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hjMarker, matching: find.text('HJ')),
        findsOneWidget,
      );

      final sbMarker = find.byKey(const Key('modern_table_seat_marker_5'));
      expect(sbMarker, findsOneWidget);
      expect(
        find.descendant(of: sbMarker, matching: find.text('S6')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sbMarker, matching: find.text('SB')),
        findsOneWidget,
      );

      final bbMarker = find.byKey(const Key('modern_table_seat_marker_6'));
      expect(bbMarker, findsOneWidget);
      expect(
        find.descendant(of: bbMarker, matching: find.text('S7')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bbMarker, matching: find.text('BB')),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('modern_table_seat_forced_bet_5')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_forced_bet_6')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w9.s10 surfaces authored exploit synthesis drills without placeholder residue',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w9.s10'),
      ))!;

      expect(
        drills.map((item) => item.drillId).toList(),
        equals(const <String>[
          'find_seat_s3_exploit_synth',
          'find_btn_exploit_synth',
          'tap_flop_exploit_synth',
          'tap_turn_exploit_synth',
          'tap_river_exploit_synth',
          'tap_hole_right_exploit_synth',
          'choose_call_exploit_synth',
          'choose_raise_exploit_synth',
        ]),
      );
      expect(
        drills.map((item) => item.spec.kind).toList(),
        equals(const <DrillKindV1>[
          DrillKindV1.seatTap,
          DrillKindV1.seatTap,
          DrillKindV1.boardTap,
          DrillKindV1.boardTap,
          DrillKindV1.boardTap,
          DrillKindV1.holeCardsTap,
          DrillKindV1.actionChoice,
          DrillKindV1.actionChoice,
        ]),
      );
      expect(
        drills.every(
          (item) =>
              !item.spec.prompt.toLowerCase().contains('todo') &&
              !(item.spec.whyV1 ?? '').toLowerCase().contains('todo'),
        ),
        isTrue,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w9.s10',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_prompt')),
        findsOneWidget,
      );
      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_seat_marker_2')),
        findsOneWidget,
      );
      expect(
        find.text('Exploit synthesis setup: tap seat S3.'),
        findsOneWidget,
      );
      expect(drills.first.spec.scenarioTableContextV1, isNotNull);
      expect(find.textContaining('TODO'), findsNothing);
    },
  );
}
