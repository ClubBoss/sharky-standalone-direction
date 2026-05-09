import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/ui_v2/onboarding/onboarding_how_it_works_screen.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_welcome_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'intro screens keep welcome CTA and trust-primer copy visible on compact text-scaled layouts',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 780);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 780),
              textScaler: TextScaler.linear(1.35),
            ),
            child: OnboardingWelcomeScreen(onNext: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final welcomeTitle = find.byKey(const Key('onboarding_welcome_title'));
      final welcomeSubtitle = find.byKey(
        const Key('onboarding_welcome_subtitle'),
      );
      final welcomeCta = find.byKey(
        const Key('onboarding_welcome_primary_cta'),
      );
      expect(welcomeTitle, findsOneWidget);
      expect(welcomeSubtitle, findsOneWidget);
      expect(welcomeCta, findsOneWidget);
      await tester.ensureVisible(welcomeCta);
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 780),
              textScaler: TextScaler.linear(1.35),
            ),
            child: const OnboardingHowItWorksScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final primer = find.byKey(const Key('onboarding_staged_model_primer'));
      final learnMore = find.byKey(const Key('onboarding_staged_model_learn_more'));
      expect(primer, findsOneWidget);
      expect(learnMore, findsOneWidget);
      await tester.ensureVisible(learnMore);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
