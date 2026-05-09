import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/persona_greeting_service.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_entry_widget.dart';

void main() {
  testWidgets(
    'onboarding entry widget gives Sharky a concrete guided identity when bundle loads',
    (tester) async {
      final bundle = PersonaGreetingBundle(
        greetingLine: 'Hey friendly learner, welcome to your first table read.',
        microIntroLine: 'Micro intro: Start by spotting who acts first.',
        motivationalHint:
            'Motivation You are building a reason for the next move.',
        recommendedFirstAction: 'Tap the seat that acts first.',
        greetingPriority: 0.8,
        timestamp: DateTime.utc(2026, 4, 2),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingEntryWidget(bundleFuture: Future.value(bundle)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('onboarding_entry_persona_label')),
        findsOneWidget,
      );
      expect(find.text('Meet Sharky'), findsOneWidget);
      expect(
        find.byKey(const Key('onboarding_entry_identity_promise')),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'keeps the first session concrete: read one table picture',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_entry_action_label')),
        findsOneWidget,
      );
      expect(find.text('Your first concrete step'), findsOneWidget);
      expect(
        find.byKey(const Key('onboarding_entry_action_value')),
        findsOneWidget,
      );
      expect(find.text('Tap the seat that acts first.'), findsOneWidget);
      expect(
        find.byKey(const Key('onboarding_entry_action_why')),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'gives the next decision a reason instead of a guess',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_entry_motivation')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'onboarding entry widget keeps Sharky identity concrete when guided bundle fails',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingEntryWidget(showUnavailableFallback: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('onboarding_entry_placeholder_label')),
        findsOneWidget,
      );
      expect(find.text('Meet Sharky'), findsOneWidget);
      expect(
        find.byKey(const Key('onboarding_entry_placeholder_title')),
        findsOneWidget,
      );
      expect(
        find.text('Sharky could not load your guided start'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('onboarding_entry_placeholder_body')),
        findsOneWidget,
      );
      expect(
        find.textContaining('first step stays table-first and concrete'),
        findsOneWidget,
      );
    },
  );
}
