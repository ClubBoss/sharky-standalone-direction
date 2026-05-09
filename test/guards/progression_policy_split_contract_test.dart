import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/canonical/world1_topology_entry_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'canonical world1 entry stays topology-based while progression launch may stay adaptive after calibration',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
      });

      final progressionLaunchPackId =
          await ProgressService.getNextSpinePackToRunV1();
      final completedPackIds = await ProgressService.getSpineCompletedPackIdsV1();
      final canonicalCampaignEntryPackId = resolveWorld1CanonicalEntryPackIdV1(
        completedPackIds: completedPackIds,
        fallbackPackId: progressionLaunchPackId,
      );

      expect(progressionLaunchPackId, 'world1_spine_followup_v1_b2');
      expect(canonicalCampaignEntryPackId, 'world1_spine_campaign_v1');
      expect(canonicalCampaignEntryPackId, isNot(progressionLaunchPackId));
    },
  );
}
