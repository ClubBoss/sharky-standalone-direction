import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  Future<void> _pumpUntilSessionReady(
    WidgetTester tester, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 180,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (find
          .byKey(const Key('session_drill_player_load_error'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      if (find
              .byKey(const Key('session_drill_player_table_viewport'))
              .evaluate()
              .isNotEmpty ||
          find.byType(ModernTableScreenV1).evaluate().isNotEmpty) {
        return;
      }
    }
  }

  Future<void> _pumpBounded(
    WidgetTester tester, {
    int ticks = 12,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var i = 0; i < ticks; i++) {
      await tester.pump(step);
    }
  }

  testWidgets(
    'surfaced World 2 sessions project source hero cards into the embedded table scene',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      Future<void> openAndAssert({
        required String sessionId,
        List<String>? heroLabels,
        required List<String> boardLabels,
        List<String>? villainLabels,
        String? showdownWinnerActionId,
        bool expectsShowdownCleanup = false,
        int? expectedVisibleBoardCount,
        String? expectedPrompt,
        String? expectedStreetLabel,
        double? maxHeaderHeight,
        double? minTableViewportHeight,
      }) async {
        final drills = (await tester.runAsync(
          () => const DrillRuntimeAdapterV1().loadSessionDrills(sessionId),
        ))!;
        await tester.pumpWidget(
          MaterialApp(
            home: SessionDrillPlayerV1Screen(
              key: ValueKey('session-$sessionId'),
              sessionId: sessionId,
              debugDrillsOverrideV1: drills,
            ),
          ),
        );
        await _pumpUntilSessionReady(tester);
        await _pumpBounded(tester);

        expect(
          find.byKey(const Key('session_drill_player_load_error')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('session_drill_player_table_viewport')),
          findsOneWidget,
        );
        expect(find.byType(ModernTableScreenV1), findsOneWidget);
        final modernTable = tester.widget<ModernTableScreenV1>(
          find.byType(ModernTableScreenV1),
        );
        expect(
          find.byKey(const Key('modern_table_scene_top_zone')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('modern_table_scene_state_lane')),
          expectsShowdownCleanup ? findsNothing : findsOneWidget,
        );
        if (expectedStreetLabel != null) {
          expect(
            find.descendant(
              of: find.byKey(const Key('modern_table_scene_state_lane')),
              matching: find.textContaining(expectedStreetLabel),
            ),
            findsOneWidget,
          );
        }
        expect(
          find.byKey(const Key('modern_table_scene_prompt')),
          expectsShowdownCleanup ? findsNothing : findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_drill_player_prompt')),
          findsNothing,
        );
        expect(find.text('Clear Result'), findsNothing);
        if (maxHeaderHeight != null) {
          expect(
            tester
                .getSize(
                  find.byKey(const Key('session_drill_player_surfaced_header')),
                )
                .height,
            lessThanOrEqualTo(maxHeaderHeight),
          );
        }
        if (minTableViewportHeight != null) {
          expect(
            tester
                .getSize(
                  find.byKey(const Key('session_drill_player_table_viewport')),
                )
                .height,
            greaterThanOrEqualTo(minTableViewportHeight),
          );
        }
        if (expectedPrompt != null && !expectsShowdownCleanup) {
          final promptText = tester.widget<Text>(
            find.byKey(const Key('modern_table_scene_prompt')),
          );
          expect(promptText.data, expectedPrompt);
          if (sessionId == 'w2.s01') {
            await tester.tap(
              find.byKey(const Key('session_drill_player_surfaced_header')),
            );
            await tester.pumpAndSettle();
            expect(
              find.byKey(const Key('session_drill_player_prompt_sheet_title')),
              findsOneWidget,
            );
            expect(
              find.byKey(const Key('session_drill_player_prompt_sheet_body')),
              findsOneWidget,
            );
            expect(find.text('Showdown'), findsOneWidget);
            await tester.tapAt(const Offset(8, 8));
            await tester.pumpAndSettle();
          }
        }
        if (heroLabels != null) {
          expect(
            find.byKey(const Key('modern_table_hero_cards')),
            findsOneWidget,
          );
          expect(modernTable.debugHeroCardLabels, heroLabels);
        }
        expect(
          modernTable.debugBoardCardLabels?.take(boardLabels.length).toList(),
          boardLabels,
        );
        if (villainLabels != null) {
          expect(modernTable.debugVillainCardLabels, villainLabels);
          expect(
            find.byKey(const Key('modern_table_villain_cards')),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: find.byKey(const Key('modern_table_villain_card_0')),
              matching: find.text(villainLabels[0]),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: find.byKey(const Key('modern_table_villain_card_1')),
              matching: find.text(villainLabels[1]),
            ),
            findsOneWidget,
          );
        }
        if (showdownWinnerActionId != null) {
          expect(
            modernTable.debugShowdownWinnerActionId,
            showdownWinnerActionId,
          );
          expect(
            find.byKey(const Key('modern_table_seat_action_marker_0')),
            findsNothing,
          );
          expect(
            find.byKey(const Key('modern_table_seat_action_marker_1')),
            findsNothing,
          );
          final winnerKey = switch (showdownWinnerActionId) {
            'hero' => const Key('modern_table_showdown_winner_hero'),
            'villain' => const Key('modern_table_showdown_winner_villain'),
            'board_plays' => const Key('modern_table_showdown_winner_board'),
            _ => null,
          };
          expect(winnerKey, isNotNull);
          expect(find.byKey(winnerKey!), findsOneWidget);
          expect(
            find.descendant(
              of: find.byKey(winnerKey),
              matching: find.text('WINNER'),
            ),
            findsOneWidget,
          );
        }
        if (heroLabels != null) {
          expect(
            find.descendant(
              of: find.byKey(const Key('modern_table_hero_card_0')),
              matching: find.text(heroLabels[0]),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: find.byKey(const Key('modern_table_hero_card_1')),
              matching: find.text(heroLabels[1]),
            ),
            findsOneWidget,
          );
        }
        expect(
          find.byKey(const Key('modern_table_board_card_0')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('modern_table_board_card_1')),
          findsOneWidget,
        );
        if (expectedVisibleBoardCount != null) {
          for (var i = 0; i < expectedVisibleBoardCount; i++) {
            expect(
              find.byKey(Key('modern_table_board_card_$i')),
              findsOneWidget,
            );
          }
          for (var i = expectedVisibleBoardCount; i < 5; i++) {
            expect(find.byKey(Key('modern_table_board_card_$i')), findsNothing);
          }
        }
        expect(tester.takeException(), isNull);
      }

      await openAndAssert(
        sessionId: 'w2.s01',
        heroLabels: const <String>['A♥', 'Q♦'],
        boardLabels: const <String>['A♦', 'K♣'],
        villainLabels: const <String>['7♣', '7♠'],
        showdownWinnerActionId: 'hero',
        expectsShowdownCleanup: true,
        expectedVisibleBoardCount: 5,
        expectedPrompt:
            'Showdown check: Hero has top pair. Villain only has a pair of sevens. Who wins?',
        maxHeaderHeight: 32,
        minTableViewportHeight: 540,
      );

      await openAndAssert(
        sessionId: 'w2.s04',
        boardLabels: const <String>['A♠', '7♦', '2♣'],
        expectedVisibleBoardCount: 3,
        expectedPrompt:
            'Flop A-7-2 rainbow. Choose CALL for the calmer board or RAISE for the more pressure-building board.',
        expectedStreetLabel: 'FLOP',
        maxHeaderHeight: 36,
        minTableViewportHeight: 540,
      );

      await openAndAssert(
        sessionId: 'w2.s06',
        heroLabels: const <String>['A♥', 'Q♥'],
        boardLabels: const <String>['K♣', '7♥', '2♥'],
        expectedVisibleBoardCount: 3,
        expectedPrompt:
            'Hero has AhQh on Kc7h2h. How many outs improve hero to a flush on the turn?',
        expectedStreetLabel: 'FLOP',
        maxHeaderHeight: 36,
        minTableViewportHeight: 540,
      );

      await openAndAssert(
        sessionId: 'w2.s14',
        boardLabels: const <String>['J♥', 'T♥', '4♥'],
        expectedVisibleBoardCount: 3,
        expectedPrompt:
            'Step 1: On this flop, which action matches the more pressure-building texture?',
        expectedStreetLabel: 'FLOP',
        maxHeaderHeight: 36,
        minTableViewportHeight: 540,
      );

      expect(
        find.byKey(const Key('session_drill_player_world2_outs_intro_card_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_outs_source_street_v1')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'surfaced World 2 sessions project truthful seat role and seat state semantics into the embedded table scene',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s02',
            debugDrillsOverrideV1: (await tester.runAsync(
              () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s02'),
            ))!,
          ),
        ),
      );
      await _pumpUntilSessionReady(tester);
      await _pumpBounded(tester);

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );
      expect(find.byType(ModernTableScreenV1), findsOneWidget);

      final modernTable = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(modernTable.debugSeatRoleLabels, const <int, String>{
        0: 'HERO',
        1: 'VILLAIN',
      });
      expect(modernTable.debugSeatMarkerLabels, const <int, String>{
        0: 'BTN',
        1: 'BB',
        3: 'SB',
      });

      expect(find.byKey(const Key('modern_table_seat_role_0')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_role_0')),
          matching: find.text('HERO'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_role_1')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_role_1')),
          matching: find.text('VILLAIN'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_marker_0')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_0')),
          matching: find.text('BTN'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_marker_1')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_forced_bet_1')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_1')),
          matching: find.text('POSTED'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_live_1')), findsNothing);
      expect(
        find.byKey(const Key('modern_table_seat_marker_3')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_3')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_forced_bet_3')),
        findsNothing,
      );
      final actingSeatIndex = modernTable.scenarioSpec?.actingSeatStart;
      expect(actingSeatIndex, isNotNull);
      expect(
        find.byKey(Key('modern_table_seat_action_marker_$actingSeatIndex')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(
            Key('modern_table_seat_action_marker_$actingSeatIndex'),
          ),
          matching: find.text('ACT'),
        ),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('modern_table_seat_folded_2')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_live_2')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_folded_2')),
          matching: find.text('FOLDED'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_empty_3')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_live_3')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
