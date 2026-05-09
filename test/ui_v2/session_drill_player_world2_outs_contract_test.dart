import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
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

  SessionDrillItemV1 _item(
    String id, {
    required String prompt,
    required String outs,
    required String why,
    required List<String> heroHoleCards,
    required List<String> boardCards,
    String street = 'flop',
  }) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"outs_count_choice_v1","prompt":"$prompt","street_v1":"$street","hero_hole_cards_v1":["${heroHoleCards.join('","')}"],"board_cards_v1":["${boardCards.join('","')}"],"available_actions_v1":["4","8","9","15"],"expected":{"actionId":"$outs"},"error_class":"outs_count_choice_mismatch","why_v1":"$why","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets('outs_count_choice_v1 keeps outs selection deterministic', (
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
        'flush_draw',
        prompt: 'Four-flush on the flop. How many outs?',
        outs: '9',
        why: 'A flush draw usually has 9 outs.',
        heroHoleCards: const <String>['Ah', 'Qh'],
        boardCards: const <String>['Kc', '7h', '2h'],
      ),
      _item(
        'gutshot',
        prompt: 'Gutshot straight draw. How many outs?',
        outs: '4',
        why: 'A gutshot usually has 4 outs.',
        heroHoleCards: const <String>['Qc', 'Jd'],
        boardCards: const <String>['Ah', 'Tc', '2d'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s06',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('session_drill_player_outs_count_bar_v1')),
    );

    expect(
      find.byKey(const Key('session_drill_player_outs_count_bar_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_outs_4_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_outs_8_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_outs_9_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_outs_source_street_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_outs_source_hero_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_outs_source_board_v1')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('session_drill_player_outs_8_v1')));
    await tester.pump();
    expect(
      find.byKey(const Key('session_drill_player_result_fail')),
      findsOneWidget,
    );
    expect(
      find.text('Better answer: 9 outs. 8 misses this scene.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_result_fail_why_v1')),
      findsOneWidget,
    );
    expect(
      find.textContaining('Notice: A flush draw usually has 9 outs.'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Next time: Count the live improving cards before you answer.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('session_drill_player_outs_9_v1')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('session_drill_player_outs_4_v1')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_drill_player_load_error')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'w2.s06 exposes outs bridge intro and reaches river thin-value rep',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s06'),
      ))!;
      expect(
        drills.map((item) => item.drillId).toList(),
        equals(const <String>[
          'count_flush_draw_nine_outs',
          'count_open_ended_straight_draw_eight_outs',
          'count_gutshot_four_outs',
        ]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s06',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(
          const Key('session_drill_player_world2_outs_intro_supplement_v1'),
        ),
      );

      expect(
        find.byKey(
          const Key('session_drill_player_world2_outs_intro_supplement_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_world2_outs_intro_supplement_v1_title'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_world2_outs_intro_supplement_v1_body'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_outs_source_street_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_outs_source_hero_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_outs_source_board_v1')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('session_drill_player_outs_9_v1')));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(find.byKey(const Key('session_drill_player_outs_8_v1')));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(find.byKey(const Key('session_drill_player_outs_4_v1')));
      await tester.pump(const Duration(milliseconds: 80));
      await _pumpUntilFound(
        tester,
        find.byKey(
          const Key('session_drill_player_world2_outs_recap_supplement_v1'),
        ),
      );

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(
          const Key('session_drill_player_world2_outs_recap_supplement_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_world2_outs_recap_supplement_v1_body'),
        ),
        findsOneWidget,
      );
    },
  );
}
