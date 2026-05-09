import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  SessionDrillItemV1 _item(
    String id, {
    required String bucket,
    required String expected,
    List<String> acceptable = const <String>[],
    String? why,
  }) {
    final acceptableJson = acceptable.isEmpty
        ? ''
        : ',"acceptable_actions":[${acceptable.map((a) => '"$a"').join(',')}]';
    final whyJson = why == null ? '' : ',"why_v1":"$why"';
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"range_bucket_classifier_v1","prompt":"Classify range bucket and choose action.","range_bucket_v1":"$bucket","expected_action":"$expected"$acceptableJson,"error_class":"expected_action_mismatch"$whyJson,"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets(
    'range_bucket_classifier_v1 action bar and expected/acceptable/fail outcomes are deterministic',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1440, 2560);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final drills = <SessionDrillItemV1>[
        _item(
          'bucket_a',
          bucket: 'strong',
          expected: 'raise',
          acceptable: const <String>['call'],
          why:
              'Calling is legal, but raising captures more value with a strong bucket.',
        ),
        _item('bucket_b', bucket: 'missed', expected: 'fold'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w6.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_range_bucket_bar_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_result_fail')),
        findsOneWidget,
      );
      expect(
        find.text('Better line: RAISE. FOLD is weaker here.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_fail_why_v1')),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Notice: Calling is legal, but raising captures more value with a strong bucket.',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Next time: When the strong bucket supports value or pressure, choose the stronger raise line.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_result_soft_pass_info_v1')),
        findsOneWidget,
      );
      expect(
        find.text('CALL works, but RAISE is the stronger line here.'),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_result_soft_pass_reason_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Calling is legal, but raising captures more value with a strong bucket.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_ok')),
        findsOneWidget,
      );
    },
  );
}
