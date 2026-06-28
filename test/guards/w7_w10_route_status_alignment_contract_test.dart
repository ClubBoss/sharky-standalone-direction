import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const blockedW7W10Packs = <String>{
    'world7_spine_campaign_v1',
    'world7_spine_followup_v1_b0',
    'world7_spine_followup_v1_b1',
    'world7_spine_followup_v1_b2',
    'world8_spine_campaign_v1',
    'world8_spine_followup_v1_b0',
    'world8_spine_followup_v1_b1',
    'world8_spine_followup_v1_b2',
    'world9_spine_campaign_v1',
    'world9_spine_followup_v1_b0',
    'world9_spine_followup_v1_b1',
    'world9_spine_followup_v1_b2',
    'world10_spine_campaign_v1',
    'world10_spine_followup_v1_b0',
    'world10_spine_followup_v1_b1',
    'world10_spine_followup_v1_b2',
  };

  test('Act0 keeps W7-W12 world cards locked and non-selectable', () {
    for (var worldNumber = 7; worldNumber <= 12; worldNumber++) {
      final world = Act0ShellStateV1.sample.worldById('world_$worldNumber');

      expect(world.isLocked, isTrue, reason: 'world_$worldNumber locked');
      expect(
        world.isSelectable,
        isFalse,
        reason: 'world_$worldNumber non-selectable',
      );
    }
  });

  test(
    'learner-facing progression does not promote W7-W10 after W6 completion',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'intake_profile_v1':
            '{"version":"v1","focusLabel":"baseline","skillBand":"advanced","placementScore":3}',
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1':
            'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_followup_v1_b2,world3_spine_followup_v1_b2,world4_spine_followup_v1_b2,world5_spine_followup_v1_b2,world6_spine_campaign_v1,world6_spine_followup_v1_b2',
        'spine_calibration_completed_v1': true,
        'spine_calibration_band_v1': 2,
        'world2_calibration_completed_v1': true,
        'world3_calibration_completed_v1': true,
        'world4_calibration_completed_v1': true,
        'world5_calibration_completed_v1': true,
        'world6_calibration_completed_v1': true,
        'world7_calibration_completed_v1': false,
      });

      final nextPack = await ProgressService.getNextSpinePackToRunV1();

      expect(blockedW7W10Packs, isNot(contains(nextPack)));
      expect(nextPack, 'world6_spine_followup_v1_b2');
    },
  );

  test(
    'stale active W7-W10 pack state is not returned to learner route',
    () async {
      for (final activePack in blockedW7W10Packs) {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'onboardingCompleted': true,
          'intake_completed_v1': true,
          'spine_campaign_active_pack_id_v1': activePack,
          'spine_campaign_next_hand_index_v1': 0,
        });

        final nextPack = await ProgressService.getNextSpinePackToRunV1();

        expect(
          nextPack,
          isNot(activePack),
          reason: '$activePack must not bypass the W7-W10 learner gate',
        );
        expect(nextPack, 'world6_spine_followup_v1_b2');
      }
    },
  );
}
