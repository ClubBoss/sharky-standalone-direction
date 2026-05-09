import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';

void main() {
  testWidgets(
    'action order review launch reshapes the first lesson block into corrective practice',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  moduleTheoryHostRouteV1(
                    moduleId: actionOrderBtnLastModuleId,
                    moduleTitle: 'Action Order',
                    handoffContextV1: const ProgressionHandoffContextV1(
                      statusLine: 'Review: Action Order',
                      continuationHeadline: 'Review: Action Order',
                      continuationReasonLine:
                          'Review target: Action Order. Goal: Re-anchor on the button as the final actor before you choose.',
                      continuationTargetEntryId: actionOrderBtnLastModuleId,
                      continuationFocusId: 'action_order',
                      continuationReasonCode: 'progression_review_fit',
                      continuationWeaknessLabel: 'Action Order',
                      continuationReviewGoal:
                          'Re-anchor on the button as the final actor before you choose.',
                    ),
                  ),
                );
              },
              child: const Text('start'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('start'));
      await tester.pumpAndSettle();

      expect(find.text('Action Order Review'), findsOneWidget);
      expect(find.text('Weak pattern: Action Order'), findsOneWidget);
      expect(
        find.text(
          'Goal: Re-anchor on the button as the final actor before you choose.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Practice rule: Anchor the button first, then eliminate the earlier seats until only the last actor remains.',
        ),
        findsOneWidget,
      );
    },
  );
}
