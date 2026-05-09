import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_grammar_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_support_outcome_v1.dart';

void main() {
  testWidgets(
    'secondary support cards use calmer surface and readable hierarchy',
    (tester) async {
      final grammar = SharedLearnerTeachingGrammarV1(
        headerStatusText: null,
        headerHeadlineText: '',
        headerPromptText: '',
        promptStatusText: null,
        displayedPrompt: '',
        promptDetailsTitle: '',
        promptDetailsText: '',
        canRevealPromptDetails: false,
        enablePromptDetailsAffordance: false,
        supportPrimaryText: 'Review the action order first.',
        supportSecondaryText: 'This note should sit quietly under the table.',
        supportTertiaryText: '',
        outcomePrimaryText: 'Correct.',
        outcomeWhyText: 'Hero still acts last on this street.',
        outcomeNextText: 'Carry the same order into the next spot.',
        outcomeDetailText: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SharedLearnerTeachingSupportOutcomeV1(
              grammar: grammar,
              style: SharedLearnerTeachingSupportOutcomeStyleV1(
                surfaceKey: const Key('support_surface'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: buildSharedLearnerTeachingCalmSupportDecorationV1(
                  compact: true,
                ),
                lines: <SharedLearnerTeachingSupportOutcomeLineStyleV1>[
                  SharedLearnerTeachingSupportOutcomeLineStyleV1(
                    role: SharedLearnerTeachingTextRoleV1.outcomePrimaryText,
                    style: buildSharedLearnerTeachingPrimarySupportTextStyleV1(
                      const TextStyle(fontSize: 14),
                    ),
                  ),
                  SharedLearnerTeachingSupportOutcomeLineStyleV1(
                    role: SharedLearnerTeachingTextRoleV1.outcomeNextText,
                    topSpacing: 2,
                    style:
                        buildSharedLearnerTeachingSecondarySupportTextStyleV1(
                          const TextStyle(fontSize: 12),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('support_surface')), findsOneWidget);
      expect(find.text('Correct.'), findsOneWidget);
      expect(
        find.text('Carry the same order into the next spot.'),
        findsOneWidget,
      );

      final surface = tester.widget<Container>(
        find.byKey(const Key('support_surface')),
      );
      final decoration = surface.decoration! as BoxDecoration;
      final border = decoration.border! as Border;
      final primaryText = tester.widget<Text>(find.text('Correct.'));
      final secondaryText = tester.widget<Text>(
        find.text('Carry the same order into the next spot.'),
      );

      expect(decoration.color!.opacity, lessThan(0.60));
      expect(border.top.color.opacity, lessThan(0.30));
      expect(primaryText.style!.fontWeight, FontWeight.w600);
      expect(secondaryText.style!.fontWeight, FontWeight.w500);
      expect(secondaryText.style!.color, isNot(primaryText.style!.color));
    },
  );
}
