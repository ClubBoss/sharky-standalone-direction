import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/app_root.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start opens Act0 Home without intake/placement flash', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'onboarding_complete': true,
    });

    await tester.pumpWidget(const AppRoot());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 280));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_home_daily_goal_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_home_footer_sharky_line')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('intake_runner')), findsNothing);
    expect(find.byKey(const Key('act0_shell_placement_screen')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
