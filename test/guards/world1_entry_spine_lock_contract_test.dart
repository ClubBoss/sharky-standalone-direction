import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding-complete still boots to campaign plan until complete', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'intake_profile_v1':
          '{"version":"v1","focusLabel":"baseline","skillBand":"beginner","placementScore":0}',
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_calibration_completed_v1': false,
      'spine_calibration_band_v1': 0,
      // Explicitly keep campaign incomplete: no completed pack registry set.
    });
    ProgressService.world1DailyCompletionInSession.value = false;

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();

    expect(find.byType(UniversalIntakePlanScreen), findsOneWidget);
    final startCta = find.byKey(const Key('today_plan_start_cta'));
    expect(startCta, findsOneWidget);

    await tester.ensureVisible(startCta.first);
    await tester.tap(startCta.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);
  });
}
