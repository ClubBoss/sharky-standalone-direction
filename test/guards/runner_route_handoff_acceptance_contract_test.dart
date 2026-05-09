import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/screens/drill_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';

Finder _sessionResultPrimaryActionFinder() {
  final next = find.byKey(const Key('session_result_next_module_cta'));
  if (next.evaluate().isNotEmpty) {
    return next;
  }
  final review = find.byKey(const Key('session_result_review_missed_cta'));
  if (review.evaluate().isNotEmpty) {
    return review;
  }
  return find.byKey(const Key('session_result_primary_cta_v1'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'legacy drill runner finish hands off to canonical result continuation surface',
    (tester) async {
      final items = <Map<String, dynamic>>[
        <String, dynamic>{
          'question': 'Final reveal prompt',
          'explanation': 'Reveal explanation',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DrillRunnerScreen(
            moduleId: 'legacy_alignment_v1',
            debugItemsOverrideV1: items,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('REVEAL ANSWER'), findsOneWidget);
      expect(
        find.byKey(const Key('drill_runner_reveal_completion_action_stack_v1')),
        findsNothing,
      );

      await tester.tap(find.text('REVEAL ANSWER'));
      await tester.pumpAndSettle();

      expect(find.text('FINISH'), findsOneWidget);
      expect(
        find.byKey(const Key('drill_runner_reveal_completion_action_stack_v1')),
        findsOneWidget,
      );

      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();

      expect(find.byType(SessionResultScreen), findsOneWidget);
      expect(
        find.byKey(const Key('session_result_continuation_surface_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_result_action_stack_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_result_back_to_map_cta')),
        findsOneWidget,
      );
      expect(_sessionResultPrimaryActionFinder(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
