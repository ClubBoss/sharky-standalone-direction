import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// S12.V T1 HUD candidate: only locally measured Flutter geometry.
/// Does not substitute for fresh native Standard/Compact raster acceptance.
void main() {
  for (final viewport in const <Size>[
    Size(375, 812),
    Size(402, 874),
    Size(430, 932),
  ]) {
    for (final street in const <(String, int)>[
      ('your_first_hand_turn', 4),
      ('your_first_hand_river', 5),
    ]) {
      testWidgets(
        'blind HUD clears board and Hero at ' +
            viewport.toString() +
            ' ' +
            street.$1,
        (tester) async {
          tester.view.physicalSize = viewport;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              home: Act0ShellPreviewScreenV1(
                state: Act0ShellStateV1.sample,
                showPlacementOnStart: false,
                debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
                  mode: Act0ControlledDemoCaptureModeV1.directState,
                  surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
                  worldId: 'world_1',
                  lessonId: 'your_first_hand',
                  taskId: street.$1,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final bbPlate = find.byKey(
            const Key('act0_shell_blind_hud_plate_bb'),
          );
          final sbPlate = find.byKey(
            const Key('act0_shell_blind_hud_plate_sb'),
          );
          final board = find.byKey(const Key('act0_shell_card_board_0'));
          final hero = find.byKey(const Key('act0_shell_card_hero_0'));
          expect(board, findsOneWidget);
          expect(hero, findsOneWidget);
          expect(bbPlate, findsOneWidget);
          expect(sbPlate, findsOneWidget);
          final bb = tester.getRect(bbPlate);
          final sb = tester.getRect(sbPlate);
          final firstBoardCard = tester.getRect(board);
          final firstHeroCard = tester.getRect(hero);
          expect(bb.width, lessThan(60));
          expect(sb.width, lessThan(60));
          final bbText = tester.widget<Text>(
            find.descendant(of: bbPlate, matching: find.byType(Text)).first,
          );
          final sbText = tester.widget<Text>(
            find.descendant(of: sbPlate, matching: find.byType(Text)).first,
          );
          expect(bbText.semanticsLabel, contains('Big blind'));
          expect(sbText.semanticsLabel, contains('Small blind'));
          expect(
            bb.right + 2,
            lessThanOrEqualTo(firstBoardCard.left),
            reason: 'BB badge must not overlap the first board card',
          );
          expect(
            sb.right + 2,
            lessThanOrEqualTo(firstHeroCard.left),
            reason: 'SB badge must remain clear of Hero cards',
          );
          expect(
            find.byKey(const Key('act0_shell_seat_sublabel_bb')),
            findsNothing,
          );
          expect(
            find.byKey(const Key('act0_shell_seat_sublabel_sb')),
            findsNothing,
          );
          for (var index = 0; index < street.$2; index++) {
            expect(
              find.byKey(Key('act0_shell_card_board_' + index.toString())),
              findsOneWidget,
            );
          }
          expect(
            find.byKey(const Key('act0_shell_wave1_pot_priority_stat')),
            findsOneWidget,
          );
        },
      );
    }
  }
}
