import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_how_it_works_screen.dart';

void main() {
  testWidgets(
    'how it works screen explains shared core first and opens deeper context explainer',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OnboardingHowItWorksScreen()),
      );

      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('onboarding_staged_model_primer')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_staged_model_primer_title')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_staged_model_primer_core')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_staged_model_primer_why')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_staged_model_primer_warning')),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Start with one table-first core so your first real decision already has a reason.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('find the right seat'), findsOneWidget);
      expect(
        find.textContaining('first choice starts having a reason'),
        findsOneWidget,
      );
      expect(
        find.textContaining('format pressure, stack depth'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Cash, tournament, and mixed paths come later'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'build the shared core before layering on tougher spots',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'foundation is stable enough for later specialization',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'deeper format-specific adjustments introduced later',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('EV calculations and strategic guidance'),
        findsNothing,
      );

      await tester.ensureVisible(
        find.byKey(const Key('onboarding_staged_model_learn_more')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('onboarding_staged_model_learn_more')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('onboarding_staged_model_explainer_sheet')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_staged_model_explainer_title')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_staged_model_explainer_core')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_staged_model_explainer_split')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_staged_model_explainer_later')),
        findsOneWidget,
      );
    },
  );
}
