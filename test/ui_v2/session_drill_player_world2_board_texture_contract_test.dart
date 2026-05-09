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
    final statusFinder = find.byKey(
      const Key('session_drill_player_status_header'),
    );
    final promptFinder = find.byKey(const Key('session_drill_player_prompt'));
    final loadErrorFinder = find.byKey(
      const Key('session_drill_player_load_error'),
    );
    final status = statusFinder.evaluate().isNotEmpty
        ? tester.widget(statusFinder).toStringShort()
        : '<missing>';
    final prompt = promptFinder.evaluate().isNotEmpty
        ? tester.widget(promptFinder).toStringShort()
        : '<missing>';
    final loadError = loadErrorFinder.evaluate().isNotEmpty
        ? tester.widget(loadErrorFinder).toStringShort()
        : '<missing>';
    fail(
      'Timed out waiting for ${finder.description}; '
      'status=$status; prompt=$prompt; loadError=$loadError',
    );
  }

  SessionDrillItemV1 _item(
    String id, {
    required String prompt,
    required String texture,
    required String expected,
    required String why,
    required List<String> boardCards,
    String street = 'flop',
  }) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"board_texture_classifier_v1","prompt":"$prompt","street_v1":"$street","board_cards_v1":["${boardCards[0]}","${boardCards[1]}","${boardCards[2]}"],"board_texture_v1":"$texture","available_actions_v1":["call","raise"],"expected_action":"$expected","error_class":"expected_action_mismatch","why_v1":"$why","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets(
    'w2.s04 texture bridge keeps calm-vs-pressure classification deterministic',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _item(
          'dry_board',
          prompt: 'A-7-2 rainbow. Which board is calmer?',
          texture: 'dry',
          expected: 'call',
          why: 'Dry rainbow boards build less immediate draw pressure.',
          boardCards: const <String>['As', '7d', '2c'],
        ),
        _item(
          'wet_board',
          prompt: 'J-T-9 two-tone. Which board builds more pressure?',
          texture: 'connected',
          expected: 'raise',
          why: 'Connected two-tone boards create more draws and pressure.',
          boardCards: const <String>['Jh', 'Ts', '9h'],
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
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );

      expect(
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_source_street_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_source_board_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_result_fail')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Better line: CALL. RAISE is weaker here.'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Notice: Dry rainbow boards build less immediate draw pressure.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Next time: On calmer textures, prefer the controlled call instead of forcing extra chips in.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await tester.pump(const Duration(milliseconds: 80));

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await tester.pump(const Duration(milliseconds: 80));
      expect(
        find.text('J-T-9 two-tone. Which board builds more pressure?'),
        findsAtLeastNWidgets(1),
      );
    },
  );

  testWidgets(
    'w2.s04 exposes board texture bridge intro and recap through supplements',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s04'),
      ))!;
      expect(
        drills.map((item) => item.drillId).toList(),
        equals(const <String>[
          'classify_dry_ace_seven_deuce_rainbow',
          'classify_coordinated_jack_ten_nine_two_tone',
          'classify_paired_king_king_three_rainbow',
        ]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s04',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(
          const Key('session_drill_player_world2_texture_intro_supplement_v1'),
        ),
      );

      expect(
        find.byKey(
          const Key('session_drill_player_world2_texture_intro_supplement_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key(
            'session_drill_player_world2_texture_intro_supplement_v1_title',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key(
            'session_drill_player_world2_texture_intro_supplement_v1_body',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_source_street_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_source_board_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await tester.pump(const Duration(milliseconds: 80));
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await tester.pump(const Duration(milliseconds: 80));
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      );
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await tester.pump(const Duration(milliseconds: 80));
      await _pumpUntilFound(
        tester,
        find.byKey(
          const Key('session_drill_player_world2_texture_recap_supplement_v1'),
        ),
      );

      expect(
        find.byKey(
          const Key('session_drill_player_world2_texture_recap_supplement_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key(
            'session_drill_player_world2_texture_recap_supplement_v1_body',
          ),
        ),
        findsOneWidget,
      );
    },
  );
}
