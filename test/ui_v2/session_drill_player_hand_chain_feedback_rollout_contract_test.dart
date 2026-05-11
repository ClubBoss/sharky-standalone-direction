import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  SessionDrillItemV1 _loadChainItem(String drillId, String path) {
    return SessionDrillItemV1(
      drillId: drillId,
      spec: DrillSpecV1.fromJsonString(File(path).readAsStringSync()),
    );
  }

  testWidgets(
    'w1 hand-chain misses keep the stronger-line headline and teaching copy',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1440, 2560);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w1.s10',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _loadChainItem(
                'chain_world1_final_checkpoint_v1',
                'content/worlds/world1/v1/sessions/w1.s10/drills/d.chain_world1_final_checkpoint_v1.json',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_result_fail_detail')),
        findsOneWidget,
      );
      expect(
        find.text('Better line: raise. call is weaker here.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_fail_why_v1')),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Notice: World 1 starts by rewarding clean first-in spots from good seats.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Next time: Read the frame first, then choose the expected line.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('w6 hand-chain misses use the shared corrective explanation seam', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w6.s10',
          debugDrillsOverrideV1: <SessionDrillItemV1>[
            _loadChainItem(
              'chain_world6_range_synthesis_recap_v1',
              'content/worlds/world6/v1/sessions/w6.s10/drills/d.chain_world6_range_synthesis_recap_v1.json',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_raise_v1')),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('session_drill_player_result_fail_detail')),
      findsOneWidget,
    );
    expect(
      find.text('Better line: call. raise is weaker here.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_result_fail_why_v1')),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Notice: World 6 synthesis should not force aggression when the combined range story stays only medium strength.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Next time: Read the frame first, then choose the expected line.',
      ),
      findsOneWidget,
    );
  });
}
