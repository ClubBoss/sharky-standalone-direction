import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
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
    'w8.s05 surfaces authored covering drills without placeholder residue',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w8.s05'),
      ))!;

      expect(
        drills.map((item) => item.drillId).toList(),
        equals(const <String>[
          'find_bb_cover',
          'find_sb_cover',
          'tap_flop_covering',
          'tap_turn_covering',
          'tap_river_covering',
          'tap_hole_left_covering',
          'choose_call_covering',
          'choose_fold_covered',
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
            sessionId: 'w8.s05',
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
      expect(
        find.text('Covering-versus-covered setup: tap BB.'),
        findsOneWidget,
      );
      expect(find.textContaining('TODO'), findsNothing);
    },
  );

  testWidgets(
    'w8.s10 surfaces authored ICM synthesis drills without placeholder residue',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w8.s10'),
      ))!;

      expect(
        drills.map((item) => item.drillId).toList(),
        equals(const <String>[
          'find_sb_icm_synth',
          'find_btn_icm_synth',
          'tap_flop_icm_synth',
          'tap_turn_icm_synth',
          'tap_river_icm_synth',
          'tap_hole_left_icm_synth',
          'choose_call_icm_synth',
          'choose_raise_icm_synth',
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
            sessionId: 'w8.s10',
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
      expect(find.text('ICM synthesis setup: tap SB.'), findsOneWidget);
      expect(find.textContaining('TODO'), findsNothing);
    },
  );
}
