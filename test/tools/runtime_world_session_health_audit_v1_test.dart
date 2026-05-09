import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/runtime_world_session_health_audit_v1.dart';

void main() {
  test('report is deterministic on current repo', () {
    final first = renderRuntimeWorldSessionHealthReportV1(
      buildRuntimeWorldSessionHealthReportV1(),
    );
    final second = renderRuntimeWorldSessionHealthReportV1(
      buildRuntimeWorldSessionHealthReportV1(),
    );

    expect(second, equals(first));
    expect(first, contains('WORLD\tOK\tLEGACY\tDEGRADED\tBROKEN'));
    expect(first, contains('KIND\tWORLD\tID\tROUTE\tMODE\tSTATUS\tREASON'));
    expect(first, contains('\n0\t'));
    expect(first, contains('\n10\t'));
  });

  test('representative learner-facing paths classify from repo truth', () {
    final report = buildRuntimeWorldSessionHealthReportV1();
    final byId = <String, LearnerPathHealthRowV1>{
      for (final row in report.rows) row.id: row,
    };

    expect(
      byId['world1_act0_table_literacy']?.status,
      LearnerPathHealthStatusV1.ok,
    );
    expect(
      byId['world1_act0_table_literacy']?.reason,
      'world1_modernized_runner',
    );
    expect(
      byId['world1_spine_campaign_v1']?.status,
      LearnerPathHealthStatusV1.ok,
    );
    expect(
      byId['world1_spine_campaign_v1']?.reason,
      'canonical_campaign_spine_pack',
    );
    expect(
      byId['world10_spine_campaign_v1']?.status,
      LearnerPathHealthStatusV1.ok,
    );
    expect(
      byId['world10_spine_campaign_v1']?.reason,
      'session_drill_campaign_entry_pilot',
    );
    expect(byId['world10_spine_followup_v1_b0']?.route, 'sessionDrillPlayer');
    expect(
      byId['world10_spine_followup_v1_b0']?.reason,
      'session_drill_campaign_entry_pilot',
    );
    expect(byId['world10_spine_followup_v1_b2']?.route, 'sessionDrillPlayer');
    expect(
      byId['world10_spine_followup_v1_b2']?.reason,
      'session_drill_campaign_entry_pilot',
    );
    expect(byId['w0.s01']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w0.s01']?.reason, 'canonical_single_step_session');
    expect(byId['w1.s01']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w1.s01']?.reason, 'canonical_single_step_session');
    expect(byId['w2.s01']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w2.s01']?.reason, 'canonical_single_step_session');
    expect(byId['w2.s02']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w2.s02']?.reason, 'supplements_live');
    expect(byId['w2.s03']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w2.s03']?.reason, 'supplements_live');
    expect(byId['w2.s04']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w2.s04']?.reason, 'supplements_live');
    expect(byId['w2.s05']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w2.s05']?.reason, 'canonical_single_step_session');
    expect(byId['w2.s07']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w2.s07']?.reason, 'reusable_factual_host');
    expect(byId['w4.s01']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w4.s01']?.reason, 'canonical_single_step_session');
    expect(byId['w6.s05']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w6.s05']?.reason, 'canonical_single_step_session');
    expect(byId['w9.s10']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w9.s10']?.reason, 'canonical_single_step_session');
    expect(byId['w1.s01']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w1.s01']?.reason, 'canonical_single_step_session');
    expect(byId['w2.s01']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['w2.s01']?.reason, 'canonical_single_step_session');
    expect(byId['cash.s01']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['cash.s01']?.reason, 'world10_track_root_entry_pilot');
    expect(byId['tournament.s01']?.reason, 'world10_track_root_entry_pilot');
    expect(byId['mixed.s01']?.reason, 'world10_track_root_entry_pilot');
    expect(byId['cash.s02']?.reason, 'world10_track_early_chain_pilot');
    expect(byId['cash.s03']?.reason, 'world10_track_early_chain_pilot');
    expect(byId['tournament.s02']?.reason, 'world10_track_early_chain_pilot');
    expect(byId['mixed.s03']?.reason, 'world10_track_early_chain_pilot');
    expect(byId['cash.s04']?.reason, 'world10_track_tail_chain_pilot');
    expect(byId['mixed.s10']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['mixed.s10']?.reason, 'world10_track_tail_chain_pilot');
    expect(byId['tournament.s05']?.status, LearnerPathHealthStatusV1.ok);
    expect(byId['tournament.s05']?.reason, 'world10_track_tail_chain_pilot');
    expect(
      byId['world2_spine_followup_v1_b1']?.reason,
      'session_drill_campaign_entry_pilot',
    );
    expect(byId['world2_spine_campaign_v1']?.route, 'sessionDrillPlayer');
    expect(
      byId['world2_spine_campaign_v1']?.reason,
      'session_drill_campaign_entry_pilot',
    );
    expect(byId['world2_spine_followup_v1_b2']?.route, 'sessionDrillPlayer');
    expect(
      byId['world2_spine_followup_v1_b2']?.reason,
      'session_drill_campaign_entry_pilot',
    );
    expect(byId['world3_spine_campaign_v1']?.route, 'sessionDrillPlayer');
    expect(
      byId['world3_spine_campaign_v1']?.reason,
      'session_drill_campaign_entry_pilot',
    );
    expect(byId['world6_spine_followup_v1_b0']?.route, 'sessionDrillPlayer');
    expect(
      byId['world6_spine_followup_v1_b0']?.reason,
      'session_drill_campaign_entry_pilot',
    );
    expect(byId['world9_spine_followup_v1_b2']?.route, 'sessionDrillPlayer');
    expect(
      byId['world9_spine_followup_v1_b2']?.reason,
      'session_drill_campaign_entry_pilot',
    );
  });

  test('missing session backing is reported broken', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'runtime_world_session_health_audit_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    final metaDir = Directory('${tempRoot.path}/content/_meta')
      ..createSync(recursive: true);
    File('${metaDir.path}/world_drills_manifest_v1.json').writeAsStringSync(
      jsonEncode(<String, Object?>{
        'version': 1,
        'worlds': <Object?>[
          <String, Object?>{
            'world': 2,
            'sessions': <Object?>[
              <String, Object?>{
                'id': 'w2.s02',
                'path': 'content/worlds/world2/v1/sessions/w2.s02/',
                'drills': <Object?>[
                  <String, Object?>{
                    'id': 'choose_hero_in_position_btn_vs_bb',
                    'path':
                        'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_hero_in_position_btn_vs_bb.json',
                  },
                ],
              },
            ],
          },
        ],
      }),
    );

    final report = buildRuntimeWorldSessionHealthReportV1(
      rootPath: tempRoot.path,
      includeCampaignPacks: false,
      includedWorlds: const <int>{2},
    );
    final broken = report.rows.singleWhere((row) => row.id == 'w2.s02');

    expect(broken.status, LearnerPathHealthStatusV1.broken);
    expect(broken.reason, 'missing_session_dir');
  });
}
