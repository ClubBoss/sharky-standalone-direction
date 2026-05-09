import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_welcome_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'compact portrait welcome keeps trust meaning readable and primary CTA visible',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      var tapped = false;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            textScaler: TextScaler.linear(1.15),
          ),
          child: MaterialApp(
            home: OnboardingWelcomeScreen(
              onNext: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      final titleFinder = find.byKey(const Key('onboarding_welcome_title'));
      final subtitleFinder = find.byKey(
        const Key('onboarding_welcome_subtitle'),
      );
      final ctaFinder = find.byKey(const Key('onboarding_welcome_primary_cta'));

      expect(titleFinder, findsOneWidget);
      expect(subtitleFinder, findsOneWidget);
      expect(ctaFinder, findsOneWidget);

      final titleText = tester.widget<Text>(titleFinder);
      final subtitleText = tester.widget<Text>(subtitleFinder);

      expect(titleText.data, 'Welcome to\nPoker Analyzer');
      expect(
        subtitleText.data,
        'Master poker strategy through\nadaptive, AI-powered training',
      );

      final titleParagraph = tester.renderObject<RenderParagraph>(titleFinder);
      final subtitleParagraph = tester.renderObject<RenderParagraph>(
        subtitleFinder,
      );
      expect(titleParagraph.didExceedMaxLines, isFalse);
      expect(subtitleParagraph.didExceedMaxLines, isFalse);

      final titleRect = tester.getRect(titleFinder);
      final subtitleRect = tester.getRect(subtitleFinder);
      final ctaRect = tester.getRect(ctaFinder);

      expect(titleRect.top >= 0, isTrue);
      expect(subtitleRect.top >= titleRect.bottom, isTrue);
      expect(ctaRect.top >= subtitleRect.bottom, isTrue);
      expect(ctaRect.bottom <= 640, isTrue);

      await tester.tap(ctaFinder);
      await tester.pump();

      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
