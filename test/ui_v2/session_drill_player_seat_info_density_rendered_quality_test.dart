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

  Future<void> _tapSeat(WidgetTester tester, int seatIndex) async {
    final table = tester.widget<ModernTableScreenV1>(
      find.byType(ModernTableScreenV1),
    );
    expect(table.onSeatTapV1, isNotNull);
    table.onSeatTapV1!(seatIndex);
  }

  SessionDrillItemV1 _positionItem() {
    return SessionDrillItemV1(
      drillId: 'world2_seat_density_contract_v1',
      spec: DrillSpecV1.fromJsonString(
        '{"id":"world2_seat_density_contract_v1","kind":"position_thinking_choice_v1","prompt":"Hero is on the button versus the big blind. Who acts later after the flop?","player_count_v1":4,"hero_seat_v1":"btn","villain_seat_v1":"bb","active_seats_v1":["btn","bb"],"folded_seats_v1":["co"],"empty_seats_v1":["sb"],"street_v1":"flop","available_actions_v1":["hero","villain"],"expected":{"actionId":"hero"},"error_class":"position_thinking_choice_mismatch","why_v1":"The button acts later after the flop.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
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
    'direct canonical World 2 seat context demotes secondary chips while keeping marker and acting truth readable',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s02',
            debugDrillsOverrideV1: <SessionDrillItemV1>[_positionItem()],
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_table_viewport')),
      );
      await tester.pumpAndSettle();

      final markerFinder = find.byKey(const Key('modern_table_seat_marker_0'));
      final roleFinder = find.byKey(const Key('modern_table_seat_role_0'));
      final stackFinder = find.byKey(
        const Key('modern_table_seat_stack_pill_P1'),
      );
      final forcedBetFinder = find.byKey(
        const Key('modern_table_seat_forced_bet_1'),
      );
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      final actingSeatIndex = table.scenarioSpec?.actingSeatStart;
      final actionFinder = find.byKey(
        Key('modern_table_seat_action_marker_$actingSeatIndex'),
      );

      expect(markerFinder, findsOneWidget);
      expect(roleFinder, findsOneWidget);
      expect(stackFinder, findsOneWidget);
      expect(forcedBetFinder, findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_live_1')), findsNothing);
      expect(actionFinder, findsOneWidget);

      final markerRect = tester.getRect(markerFinder);
      final roleRect = tester.getRect(roleFinder);
      final stackRect = tester.getRect(stackFinder);
      final actionRect = tester.getRect(actionFinder);

      expect(markerRect.height, greaterThan(roleRect.height));
      expect(actionRect.height, greaterThan(roleRect.height));
      expect(roleRect.bottom, lessThan(stackRect.top));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'direct canonical World 9 spatial slice keeps seat-id anchor dominant while secondary post state stays quiet',
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

      final targetMarkerFinder = find.byKey(
        const Key('modern_table_seat_marker_1'),
      );
      final postedBigBlindFinder = find.byKey(
        const Key('modern_table_seat_forced_bet_6'),
      );

      expect(targetMarkerFinder, findsOneWidget);
      expect(postedBigBlindFinder, findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_live_6')), findsNothing);

      final targetMarkerRect = tester.getRect(targetMarkerFinder);
      final postedBigBlindRect = tester.getRect(postedBigBlindFinder);
      expect(targetMarkerRect.height, greaterThan(postedBigBlindRect.height));

      await _tapSeat(tester, 1);
      await tester.pump();
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );
      await tester.pumpAndSettle();

      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      final actingSeatIndex = table.scenarioSpec?.actingSeatStart;
      final actionFinder = find.byKey(
        Key('modern_table_seat_action_marker_$actingSeatIndex'),
      );

      expect(actionFinder, findsOneWidget);
      final actionRect = tester.getRect(actionFinder);
      expect(actionRect.height, greaterThan(postedBigBlindRect.height));
      expect(tester.takeException(), isNull);
    },
  );
}
