import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 80,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for ${finder.description}');
  }

  Future<void> _pumpUntilGone(
    WidgetTester tester,
    Finder finder, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 80,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (finder.evaluate().isEmpty) {
        return;
      }
    }
    fail('Timed out waiting for ${finder.description} to disappear');
  }

  Future<void> _tapSeat(WidgetTester tester, int seatIndex) async {
    final table = tester.widget<ModernTableScreenV1>(
      find.byType(ModernTableScreenV1),
    );
    expect(table.onSeatTapV1, isNotNull);
    table.onSeatTapV1!(seatIndex);
  }

  SessionDrillItemV1 _spatializedActionBearingDrill({
    required SessionDrillItemV1 spatialAnchorDrill,
    required SessionDrillItemV1 actionBearingDrill,
  }) {
    final anchorSpec = spatialAnchorDrill.spec;
    final actionSpec = actionBearingDrill.spec;
    return SessionDrillItemV1(
      drillId: actionBearingDrill.drillId,
      spec: DrillSpecV1(
        id: actionSpec.id,
        kind: actionSpec.kind,
        prompt: actionSpec.prompt,
        expected: actionSpec.expected,
        errorClass: actionSpec.errorClass,
        intentV1: actionSpec.intentV1,
        questionShapeV1: actionSpec.questionShapeV1,
        initiativePolicyShapeV1: actionSpec.initiativePolicyShapeV1,
        boardTexturePolicyShapeV1: actionSpec.boardTexturePolicyShapeV1,
        boardTexturePolicyTargetV1: actionSpec.boardTexturePolicyTargetV1,
        whyV1: actionSpec.whyV1,
        acceptableActions: actionSpec.acceptableActions,
        acceptablePresetIds: actionSpec.acceptablePresetIds,
        boardTextureV1: actionSpec.boardTextureV1,
        availableActionsV1: actionSpec.availableActionsV1,
        streetV1: anchorSpec.streetV1 ?? actionSpec.streetV1,
        boardCardsV1: anchorSpec.boardCardsV1,
        playerCountV1: anchorSpec.playerCountV1,
        heroSeatV1: anchorSpec.heroSeatV1,
        villainSeatV1: anchorSpec.villainSeatV1,
        activeSeatsV1: anchorSpec.activeSeatsV1,
        foldedSeatsV1: anchorSpec.foldedSeatsV1,
        emptySeatsV1: anchorSpec.emptySeatsV1,
        lastAggressorV1: anchorSpec.lastAggressorV1,
        initiativeOwnerV1: anchorSpec.initiativeOwnerV1,
        smallBlindSeatV1: anchorSpec.smallBlindSeatV1,
        bigBlindSeatV1: anchorSpec.bigBlindSeatV1,
        smallBlindAmountV1: anchorSpec.smallBlindAmountV1,
        bigBlindAmountV1: anchorSpec.bigBlindAmountV1,
        anteAmountV1: anchorSpec.anteAmountV1,
        pressureOwnerV1: actionSpec.pressureOwnerV1,
        heroHoleCardsV1: anchorSpec.heroHoleCardsV1,
        villainHoleCardsV1: anchorSpec.villainHoleCardsV1,
        introV1: actionSpec.introV1,
        recapV1: actionSpec.recapV1,
        feedbackCorrectV1: actionSpec.feedbackCorrectV1,
        feedbackIncorrectV1: actionSpec.feedbackIncorrectV1,
        expectedActionV1: actionSpec.expectedActionV1,
        rangeBucketV1: actionSpec.rangeBucketV1,
        chainIdV1: actionSpec.chainIdV1,
        chainStepsV1: actionSpec.chainStepsV1,
      ),
    );
  }

  testWidgets(
    'w9.s05 direct canonical path keeps prompt and off-button seat-anchor markers readable on phone size',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w9.s05'),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w9.s05',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_spatial_table_v1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );
      expect(find.byType(ModernTableScreenV1), findsOneWidget);

      final headerFinder = find.byKey(
        const Key('session_drill_player_surfaced_header'),
      );
      final promptCapsuleFinder = find.byKey(
        const Key('session_drill_player_prompt_capsule_v1'),
      );
      final promptFinder = find.byKey(const Key('session_drill_player_prompt'));
      final tableFinder = find.byKey(
        const Key('session_drill_player_spatial_table_v1'),
      );
      final heroRingFinder = find.byKey(
        const Key('modern_table_seat_hero_ring_5'),
      );
      final buttonMarkerFinder = find.byKey(
        const Key('modern_table_seat_marker_0'),
      );
      final targetMarkerFinder = find.byKey(
        const Key('modern_table_seat_marker_1'),
      );

      expect(headerFinder, findsOneWidget);
      expect(promptCapsuleFinder, findsOneWidget);
      expect(promptFinder, findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_status_header')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('modern_table_scene_proof_badge')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_scene_proof_badge')),
          matching: find.text('POSITION'),
        ),
        findsOneWidget,
      );
      expect(tableFinder, findsOneWidget);
      expect(heroRingFinder, findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsNothing,
      );
      expect(buttonMarkerFinder, findsOneWidget);
      expect(targetMarkerFinder, findsOneWidget);
      expect(
        find.descendant(of: buttonMarkerFinder, matching: find.text('BTN')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: targetMarkerFinder, matching: find.text('S2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: targetMarkerFinder, matching: find.text('CO')),
        findsOneWidget,
      );
      expect(find.text('Position exploit setup: tap seat S2.'), findsOneWidget);

      final headerRect = tester.getRect(headerFinder);
      final promptRect = tester.getRect(promptFinder);
      final tableRect = tester.getRect(tableFinder);
      final targetMarkerRect = tester.getRect(targetMarkerFinder);
      expect(headerRect.height, lessThanOrEqualTo(62));
      expect(promptRect.height, lessThanOrEqualTo(22));
      expect(headerRect.bottom, lessThan(tableRect.top));
      expect(promptRect.bottom, lessThan(tableRect.top));
      expect(tableRect.height, greaterThan(headerRect.height * 6));
      expect(targetMarkerRect.height, greaterThanOrEqualTo(20));
      expect(targetMarkerRect.width, greaterThanOrEqualTo(28));
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isNull);
      expect(appBar.toolbarHeight, equals(40));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'w9.s05 direct canonical path keeps the first action-bearing state readable on the same spatial session',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w9.s05'),
      ))!;
      final spatialAnchorDrill = drills.firstWhere(
        (item) => item.drillId == 'find_seat_s2_position',
      );
      final actionBearingDrill = drills.firstWhere(
        (item) => item.drillId == 'choose_call_position_control',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w9.s05',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              spatialAnchorDrill,
              _spatializedActionBearingDrill(
                spatialAnchorDrill: spatialAnchorDrill,
                actionBearingDrill: actionBearingDrill,
              ),
            ],
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_spatial_table_v1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Position exploit setup: tap seat S2.'), findsOneWidget);
      await _tapSeat(tester, 1);
      await tester.pump();
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );
      await tester.pumpAndSettle();

      final headerFinder = find.byKey(
        const Key('session_drill_player_surfaced_header'),
      );
      final promptFinder = find.byKey(const Key('session_drill_player_prompt'));
      final tableFinder = find.byKey(
        const Key('session_drill_player_spatial_table_v1'),
      );
      final actionBarFinder = find.byKey(
        const Key('session_drill_player_texture_action_bar_v1'),
      );
      final heroRingFinder = find.byKey(
        const Key('modern_table_seat_hero_ring_5'),
      );
      final targetMarkerFinder = find.byKey(
        const Key('modern_table_seat_marker_1'),
      );

      expect(headerFinder, findsOneWidget);
      expect(promptFinder, findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_status_header')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('modern_table_scene_proof_badge')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_scene_proof_badge')),
          matching: find.text('DECISION'),
        ),
        findsOneWidget,
      );
      expect(tableFinder, findsOneWidget);
      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(heroRingFinder, findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsNothing,
      );
      expect(targetMarkerFinder, findsOneWidget);
      expect(
        find.text('In controlled position exploit spot, choose call.'),
        findsOneWidget,
      );
      expect(
        find.descendant(of: targetMarkerFinder, matching: find.text('CO')),
        findsOneWidget,
      );

      final headerRect = tester.getRect(headerFinder);
      final promptRect = tester.getRect(promptFinder);
      final tableRect = tester.getRect(tableFinder);
      expect(headerRect.height, lessThanOrEqualTo(62));
      expect(promptRect.height, lessThanOrEqualTo(22));
      expect(headerRect.bottom, lessThan(tableRect.top));
      expect(promptRect.bottom, lessThan(tableRect.top));
      expect(tableRect.height, greaterThan(headerRect.height * 6));

      expect(actionBarFinder, findsOneWidget);

      final actionBarRect = tester.getRect(actionBarFinder);
      expect(actionBarRect.top - tableRect.bottom, greaterThanOrEqualTo(8));
      expect(actionBarRect.height, greaterThan(40));
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isNull);
      expect(appBar.toolbarHeight, equals(40));
      expect(tester.takeException(), isNull);
    },
  );
}
