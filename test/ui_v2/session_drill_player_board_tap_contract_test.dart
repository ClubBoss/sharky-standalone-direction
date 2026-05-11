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

  Future<void> _tapBoardSlot(WidgetTester tester, int slotIndex) async {
    final table = tester.widget<ModernTableScreenV1>(
      find.byType(ModernTableScreenV1),
    );
    final boardSlot = switch (slotIndex) {
      0 => 'flop_left',
      1 => 'flop_mid',
      2 => 'flop_right',
      3 => 'turn',
      4 => 'river',
      _ => throw ArgumentError.value(slotIndex, 'slotIndex'),
    };
    expect(table.onBoardSlotTapV1, isNotNull);
    table.onBoardSlotTapV1!(boardSlot);
  }

  SessionDrillItemV1 _item(
    String id, {
    required String prompt,
    required String boardSlot,
    required String why,
  }) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"board_tap","prompt":"$prompt","intent_v1":"position_ip_advantage","expected":{"boardSlot":"$boardSlot"},"error_class":"expected_action_mismatch","why_v1":"$why","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets('board_tap keeps symbolic board-slot taps deterministic', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 1.0;

    final drills = <SessionDrillItemV1>[
      _item(
        'tap_flop_left_context',
        prompt: 'Tap the left flop slot before choosing c-bet or check.',
        boardSlot: 'flop_left',
        why: 'Board context is required before flop action selection.',
      ),
      _item(
        'tap_turn_context',
        prompt: 'Tap the turn slot before deciding second barrel or checkback.',
        boardSlot: 'turn',
        why: 'Turn context must be locked before continuation choice.',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s04',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await _pumpUntilFound(tester, find.byType(ModernTableScreenV1));

    expect(find.byType(ModernTableScreenV1), findsOneWidget);
    expect(find.byKey(const Key('modern_table_board_slot_0')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_board_slot_3')), findsOneWidget);

    await _tapBoardSlot(tester, 1);
    await tester.pump();
    expect(
      find.byKey(const Key('session_drill_player_result_fail')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_result_fail_detail')),
      findsOneWidget,
    );
    expect(find.text('Incorrect.'), findsNothing);
    expect(find.textContaining('Better answer: FLOP LEFT.'), findsOneWidget);
    expect(
      find.byKey(const Key('session_drill_player_result_fail_why_v1')),
      findsOneWidget,
    );
    expect(find.textContaining('Notice:'), findsOneWidget);
    expect(find.textContaining('Next time:'), findsOneWidget);

    await _tapBoardSlot(tester, 0);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Tap the turn slot before deciding second barrel or checkback.',
      ),
      findsWidgets,
    );

    await _tapBoardSlot(tester, 3);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('session_drill_player_result_fail')),
      findsNothing,
    );
  });

  testWidgets('authored board_tap drills can surface through the World 2 host', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 1.0;

    final boardTapDrills = <SessionDrillItemV1>[
      for (final path in <String>[
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_left_context.json',
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.tap_flop_right_context.json',
      ])
        SessionDrillItemV1(
          drillId: DrillSpecV1.fromJsonString(File(path).readAsStringSync()).id,
          spec: DrillSpecV1.fromJsonString(File(path).readAsStringSync()),
        ),
    ];

    expect(
      boardTapDrills.map((item) => item.drillId),
      containsAll(<String>['tap_flop_left_context', 'tap_flop_right_context']),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s04',
          debugDrillsOverrideV1: boardTapDrills,
        ),
      ),
    );
    await _pumpUntilFound(tester, find.byType(ModernTableScreenV1));

    expect(find.byType(ModernTableScreenV1), findsOneWidget);
    expect(find.byKey(const Key('modern_table_board_slot_0')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_board_slot_2')), findsOneWidget);
  });
}
