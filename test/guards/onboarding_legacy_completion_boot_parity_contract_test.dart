import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'legacy-only onboarding completion normalizes to canonical boot shell parity',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboarding_complete': true,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1':
            ProgressService.spineCalibrationBandAdvanced,
        'campaign_bankroll_balance_v1': 80,
      });
      ProgressService.world1DailyCompletionInSession.value = false;

      await tester.pumpWidget(const AppRoot());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('main_shell_v1')), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('world1_state_current')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('intake_runner')), findsNothing);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboardingCompleted'), isTrue);
      expect(prefs.getBool('intake_completed_v1'), isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
