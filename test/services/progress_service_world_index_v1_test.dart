import 'package:poker_analyzer/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('worldIndexForPackIdV1 resolves act0 and higher-world pack ids', () {
    expect(
      ProgressService.worldIndexForPackIdV1('world1_act0_table_literacy'),
      1,
    );
    expect(
      ProgressService.worldIndexForPackIdV1('world2_spine_campaign_v1'),
      2,
    );
    expect(
      ProgressService.worldIndexForPackIdV1('world10_spine_campaign_v1'),
      10,
    );
  });

  test('isCampaignWorldDoneByCompletedSetV1 accepts any surfaced world2 followup branch', () {
    expect(
      ProgressService.campaignWorldCompletionPackIdsV1(2),
      equals(<String>{
        'world2_spine_followup_v1_b0',
        'world2_spine_followup_v1_b1',
        'world2_spine_followup_v1_b2',
      }),
    );
    expect(
      ProgressService.isCampaignWorldDoneByCompletedSetV1(
        world: 2,
        completedPackIds: <String>{'world2_spine_followup_v1_b0'},
      ),
      isTrue,
    );
    expect(
      ProgressService.isCampaignWorldDoneByCompletedSetV1(
        world: 2,
        completedPackIds: <String>{'world2_spine_followup_v1_b1'},
      ),
      isTrue,
    );
    expect(
      ProgressService.isCampaignWorldDoneByCompletedSetV1(
        world: 2,
        completedPackIds: <String>{'world2_spine_followup_v1_b2'},
      ),
      isTrue,
    );
    expect(
      ProgressService.isCampaignWorldDoneByCompletedSetV1(
        world: 2,
        completedPackIds: <String>{'world2_spine_campaign_v1'},
      ),
      isFalse,
    );
  });

  test('campaign rank counts world2 completion from any surfaced followup branch', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2,world2_spine_campaign_v1,world2_spine_followup_v1_b0',
    });

    expect(await ProgressService.campaignRankLabelV1(), equals('Minnow'));
    expect(
      await ProgressService.campaignRankProgressLabelV1(),
      equals('Rank: Minnow (2/10 worlds)'),
    );
    expect(
      await ProgressService.campaignNextRankUnlockHintV1(),
      equals('Next: Angler at World 3'),
    );
  });

  test('campaign complete delegates world1 completion to canonical helper', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1,world1_spine_followup_v1_b2',
    });
    expect(await ProgressService.isCampaignCompleteV1(), isTrue);

    SharedPreferences.setMockInitialValues(<String, Object>{
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow,world1_spine_campaign_v1',
    });
    expect(await ProgressService.isCampaignCompleteV1(), isFalse);
  });
}
