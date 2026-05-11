import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/main.dart' show navigatorKey;
import 'package:poker_analyzer/onboarding/onboarding_flow_manager.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('result and onboarding cohort expose premium finish surfaces', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const MaterialApp(
        home: SessionResultScreen(
          correctCount: 3,
          totalCount: 4,
          moduleId: 'intro_welcome',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_result_visual_anchor_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_result_finish_label_v1')),
      findsOneWidget,
    );

    var started = false;
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            if (!started) {
              started = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                OnboardingFlowManager.instance.maybeStart(context);
              });
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('onboarding_progress_surface_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('onboarding_welcome_surface_v1')),
      findsOneWidget,
    );
  });
}
