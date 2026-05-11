import 'dart:convert';

import 'package:test/test.dart';

import '../../tools/spine_progression_cohesion_audit_v1.dart';

void main() {
  test('audit report is deterministic on current repo truth', () {
    final first = buildSpineProgressionCohesionAuditReportV1();
    final second = buildSpineProgressionCohesionAuditReportV1();

    expect(
      encodeSpineProgressionCohesionAuditReportJsonV1(first),
      encodeSpineProgressionCohesionAuditReportJsonV1(second),
    );
    expect(
      renderSpineProgressionCohesionAuditReportV1(first),
      renderSpineProgressionCohesionAuditReportV1(second),
    );
  });

  test('campaign, session, and track families are all represented', () {
    final report = buildSpineProgressionCohesionAuditReportV1();
    final byId = <String, SpineProgressionCohesionRowV1>{
      for (final row in report.rows) row.id: row,
    };

    expect(byId['world1_spine_campaign_v1'], isNotNull);
    expect(byId['w2.s03'], isNotNull);
    expect(byId['cash.s01'], isNotNull);
  });

  test('representative rows classify with expected cohesion fields', () {
    final report = buildSpineProgressionCohesionAuditReportV1();
    final byId = <String, SpineProgressionCohesionRowV1>{
      for (final row in report.rows) row.id: row,
    };

    final world1Campaign = byId['world1_spine_campaign_v1']!;
    expect(world1Campaign.world, 1);
    expect(world1Campaign.itemType, 'campaign_pack');
    expect(world1Campaign.progressionType, 'campaign_spine_pack');
    expect(world1Campaign.hostFamily, 'world1FoundationsRunner');
    expect(
      world1Campaign.screenFamily,
      'World1FoundationsMicroTaskRunnerScreen',
    );
    expect(world1Campaign.modeFamily, 'campaignSpine');
    expect(
      world1Campaign.runnerContract,
      'sessionDrillRunnerProgressionChrome',
    );
    expect(
      world1Campaign.hostGrammarProfile,
      'world1SharedLearnerHostGrammarV1',
    );
    expect(
      world1Campaign.hostGrammarPrimitives,
      containsAll(<String>[
        'progression_chrome',
        'completion_surface',
        'prompt_status_capsule',
        'seat_state_badge',
        'compact_header_band',
        'scene_support_lane',
        'bottom_action_hierarchy',
      ]),
    );
    expect(world1Campaign.remainingHostGaps, isEmpty);
    expect(world1Campaign.cohesionStatus, SpineCohesionStatusV1.canonical);
    expect(world1Campaign.reasonCodes, contains('canonical_spine_ok'));
    expect(world1Campaign.reasonCodes, contains('shared_host_grammar_adopted'));

    final world1SeatQuiz = byId['world1_act0_table_literacy']!;
    expect(world1SeatQuiz.world, 1);
    expect(world1SeatQuiz.modeFamily, 'seatQuiz');
    expect(
      world1SeatQuiz.hostGrammarProfile,
      'world1SharedLearnerHostGrammarV1',
    );
    expect(world1SeatQuiz.reasonCodes, contains('shared_host_grammar_adopted'));

    final world2Session = byId['w2.s03']!;
    expect(world2Session.world, 2);
    expect(world2Session.itemType, 'session');
    expect(world2Session.progressionType, 'session_world');
    expect(world2Session.hostFamily, 'sessionDrillPlayer');
    expect(
      world2Session.screenFamily,
      'CanonicalTerminalSessionDrillSurfacedRunnerV1',
    );
    expect(world2Session.modeFamily, 'sessionDrillSingleStep');
    expect(world2Session.runnerContract, 'sessionDrillRunnerProgressionChrome');
    expect(world2Session.hostGrammarProfile, 'canonicalLearnerHostGrammarV1');
    expect(world2Session.cohesionStatus, SpineCohesionStatusV1.canonical);
    expect(
      world2Session.reasonCodes,
      isNot(contains('progression_shape_mismatch')),
    );
    expect(world2Session.reasonCodes, isNot(contains('mode_family_split')));
    expect(world2Session.reasonCodes, contains('canonical_spine_ok'));
    expect(world2Session.reasonCodes, contains('shared_host_grammar_adopted'));
    expect(world2Session.reasonCodes, isNot(contains('host_family_split')));

    final world2Campaign = byId['world2_spine_campaign_v1']!;
    expect(world2Campaign.hostFamily, 'sessionDrillPlayer');
    expect(
      world2Campaign.screenFamily,
      'CanonicalTerminalSessionDrillSurfacedRunnerV1',
    );
    expect(world2Campaign.modeFamily, 'campaignSpine');
    expect(world2Campaign.cohesionStatus, SpineCohesionStatusV1.canonical);
    expect(
      world2Campaign.reasonCodes,
      isNot(contains('progression_shape_mismatch')),
    );
    expect(world2Campaign.reasonCodes, isNot(contains('mode_family_split')));
    expect(world2Campaign.reasonCodes, contains('canonical_spine_ok'));

    final world3Campaign = byId['world3_spine_campaign_v1']!;
    expect(world3Campaign.hostFamily, 'sessionDrillPlayer');
    expect(
      world3Campaign.screenFamily,
      'CanonicalTerminalSessionDrillSurfacedRunnerV1',
    );
    expect(world3Campaign.modeFamily, 'campaignSpine');
    expect(world3Campaign.cohesionStatus, SpineCohesionStatusV1.canonical);
    expect(
      world3Campaign.reasonCodes,
      isNot(contains('progression_shape_mismatch')),
    );
    expect(world3Campaign.reasonCodes, isNot(contains('mode_family_split')));
    expect(world3Campaign.reasonCodes, contains('canonical_spine_ok'));

    final world3Session = byId['w3.s03']!;
    expect(world3Session.hostFamily, 'sessionDrillPlayer');
    expect(world3Session.modeFamily, 'handChain');
    expect(world3Session.cohesionStatus, SpineCohesionStatusV1.canonical);
    expect(
      world3Session.reasonCodes,
      isNot(contains('progression_shape_mismatch')),
    );
    expect(world3Session.reasonCodes, isNot(contains('mode_family_split')));
    expect(world3Session.reasonCodes, contains('canonical_spine_ok'));

    final world9Campaign = byId['world9_spine_followup_v1_b2']!;
    expect(world9Campaign.hostFamily, 'sessionDrillPlayer');
    expect(
      world9Campaign.screenFamily,
      'CanonicalTerminalSessionDrillSurfacedRunnerV1',
    );
    expect(world9Campaign.modeFamily, 'campaignSpine');
    expect(world9Campaign.cohesionStatus, SpineCohesionStatusV1.canonical);
    expect(
      world9Campaign.reasonCodes,
      isNot(contains('progression_shape_mismatch')),
    );
    expect(world9Campaign.reasonCodes, isNot(contains('mode_family_split')));
    expect(world9Campaign.reasonCodes, contains('canonical_spine_ok'));

    final world4Session = byId['w4.s01']!;
    expect(world4Session.hostFamily, 'sessionDrillPlayer');
    expect(world4Session.modeFamily, 'sessionDrillSingleStep');
    expect(world4Session.cohesionStatus, SpineCohesionStatusV1.canonical);
    expect(
      world4Session.reasonCodes,
      isNot(contains('progression_shape_mismatch')),
    );
    expect(world4Session.reasonCodes, isNot(contains('mode_family_split')));
    expect(world4Session.reasonCodes, contains('canonical_spine_ok'));

    final world9Session = byId['w9.s10']!;
    expect(world9Session.hostFamily, 'sessionDrillPlayer');
    expect(world9Session.modeFamily, 'sessionDrillSingleStep');
    expect(world9Session.cohesionStatus, SpineCohesionStatusV1.canonical);
    expect(
      world9Session.reasonCodes,
      isNot(contains('progression_shape_mismatch')),
    );
    expect(world9Session.reasonCodes, isNot(contains('mode_family_split')));
    expect(world9Session.reasonCodes, contains('canonical_spine_ok'));

    final cashTrack = byId['cash.s01']!;
    expect(cashTrack.world, 10);
    expect(cashTrack.itemType, 'track_session');
    expect(cashTrack.progressionType, 'track_session');
    expect(cashTrack.trackKind, 'cash');
    expect(cashTrack.hostFamily, 'sessionDrillPlayer');
    expect(cashTrack.modeFamily, 'sessionDrillSingleStep');
    expect(cashTrack.runnerContract, 'sessionDrillRunnerProgressionChrome');
    expect(cashTrack.hostGrammarProfile, 'canonicalLearnerHostGrammarV1');
    expect(cashTrack.cohesionStatus, SpineCohesionStatusV1.canonical);
    expect(
      cashTrack.reasonCodes,
      isNot(contains('not_in_canonical_truth_map')),
    );
    expect(
      cashTrack.reasonCodes,
      isNot(contains('progression_shape_mismatch')),
    );
    expect(cashTrack.reasonCodes, isNot(contains('mode_family_split')));
    expect(cashTrack.reasonCodes, contains('canonical_spine_ok'));
    expect(cashTrack.reasonCodes, contains('track_session_spine'));
  });

  test('json payload carries stable summary and row structure', () {
    final report = buildSpineProgressionCohesionAuditReportV1(
      options: const SpineProgressionCohesionAuditOptionsV1(world: 10),
    );
    final decoded =
        jsonDecode(encodeSpineProgressionCohesionAuditReportJsonV1(report))
            as Map<String, dynamic>;

    expect(decoded['version'], 'v1');
    expect((decoded['summary'] as Map<String, dynamic>)['total_rows'], 34);
    expect(
      ((decoded['summary'] as Map<String, dynamic>)['status_counts']
              as Map<String, dynamic>)['mixed'] ??
          0,
      0,
    );
    expect(
      ((decoded['summary'] as Map<String, dynamic>)['status_counts']
          as Map<String, dynamic>)['canonical'],
      34,
    );
    final rows = decoded['rows'] as List<dynamic>;
    expect(rows, isNotEmpty);
    expect(
      rows.any((row) => (row as Map<String, dynamic>)['id'] == 'cash.s01'),
      isTrue,
    );
    expect(
      rows.any(
        (row) =>
            (row as Map<String, dynamic>)['progression_type'] ==
            'track_session',
      ),
      isTrue,
    );
    expect(
      rows.every(
        (row) =>
            (row as Map<String, dynamic>)['runner_contract'] ==
                'sessionDrillRunnerProgressionChrome' ||
            (row as Map<String, dynamic>)['runner_contract'] == null,
      ),
      isTrue,
    );
    expect(
      rows.every(
        (row) =>
            (row as Map<String, dynamic>)['host_grammar_profile'] ==
            'canonicalLearnerHostGrammarV1',
      ),
      isTrue,
    );
    expect(
      rows.every(
        (row) =>
            ((row as Map<String, dynamic>)['host_grammar_primitives']
                    as List<dynamic>)
                .contains('seat_state_badge') &&
            ((row)['host_grammar_primitives'] as List<dynamic>).contains(
              'compact_header_band',
            ) &&
            ((row)['host_grammar_primitives'] as List<dynamic>).contains(
              'scene_support_lane',
            ) &&
            ((row)['host_grammar_primitives'] as List<dynamic>).contains(
              'bottom_action_hierarchy',
            ),
      ),
      isTrue,
    );
  });

  test(
    'W2 and W3 session cohorts stay canonical while campaign packs also stay canonical',
    () {
      final world2Sessions = buildSpineProgressionCohesionAuditReportV1(
        options: const SpineProgressionCohesionAuditOptionsV1(
          world: 2,
          idContains: 'w2.s',
        ),
      );
      expect(world2Sessions.summary.totalRows, 14);
      expect(world2Sessions.summary.statusCounts['canonical'], 14);
      expect(world2Sessions.summary.statusCounts['mixed'] ?? 0, 0);
      expect(
        world2Sessions.rows.every(
          (row) =>
              row.cohesionStatus == SpineCohesionStatusV1.canonical &&
              !row.reasonCodes.contains('progression_shape_mismatch') &&
              !row.reasonCodes.contains('mode_family_split'),
        ),
        isTrue,
      );

      final world3Sessions = buildSpineProgressionCohesionAuditReportV1(
        options: const SpineProgressionCohesionAuditOptionsV1(
          world: 3,
          idContains: 'w3.s',
        ),
      );
      expect(world3Sessions.summary.totalRows, 14);
      expect(world3Sessions.summary.statusCounts['canonical'], 14);
      expect(world3Sessions.summary.statusCounts['mixed'] ?? 0, 0);

      final world2Campaign = buildSpineProgressionCohesionAuditReportV1(
        options: const SpineProgressionCohesionAuditOptionsV1(
          world: 2,
          idContains: 'world2_spine_',
        ),
      );
      expect(world2Campaign.summary.totalRows, 4);
      expect(world2Campaign.summary.statusCounts['canonical'], 4);
      expect(world2Campaign.summary.statusCounts['mixed'] ?? 0, 0);
    },
  );

  test('W2-W10 campaign cohorts stay canonical', () {
    for (final world in const <int>[2, 3, 4, 5, 6, 7, 8, 9, 10]) {
      final report = buildSpineProgressionCohesionAuditReportV1(
        options: SpineProgressionCohesionAuditOptionsV1(
          world: world,
          idContains: 'world${world}_spine_',
        ),
      );
      expect(report.summary.totalRows, 4);
      expect(report.summary.statusCounts['canonical'], 4);
      expect(report.summary.statusCounts['mixed'] ?? 0, 0);
    }
  });

  test('W4-W9 single-step session cohorts stay canonical', () {
    for (final world in const <int>[4, 5, 6, 7, 8, 9]) {
      final report = buildSpineProgressionCohesionAuditReportV1(
        options: SpineProgressionCohesionAuditOptionsV1(
          world: world,
          idContains: 'w$world.s',
        ),
      );
      expect(report.summary.totalRows, 10);
      expect(report.summary.statusCounts['canonical'], 10);
      expect(report.summary.statusCounts['mixed'] ?? 0, 0);
      expect(
        report.rows.every(
          (row) =>
              row.cohesionStatus == SpineCohesionStatusV1.canonical &&
              !row.reasonCodes.contains('progression_shape_mismatch') &&
              !row.reasonCodes.contains('mode_family_split'),
        ),
        isTrue,
        reason: 'World $world session cohort drifted from canonical cohesion.',
      );
    }
  });
}
