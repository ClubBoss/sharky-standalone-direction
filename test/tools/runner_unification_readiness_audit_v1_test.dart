import 'dart:convert';

import 'package:test/test.dart';

import '../../tools/runner_unification_readiness_audit_v1.dart';

void main() {
  test(
    'runner unification readiness audit is deterministic on current repo',
    () {
      final first = buildRunnerUnificationReadinessAuditReportV1();
      final second = buildRunnerUnificationReadinessAuditReportV1();

      expect(
        encodeRunnerUnificationReadinessAuditReportJsonV1(first),
        encodeRunnerUnificationReadinessAuditReportJsonV1(second),
      );
      expect(
        renderRunnerUnificationReadinessAuditReportV1(first),
        renderRunnerUnificationReadinessAuditReportV1(second),
      );
    },
  );

  test(
    'representative campaign, session, and track rows expose readiness truth',
    () {
      final report = buildRunnerUnificationReadinessAuditReportV1();
      final byId = <String, RunnerUnificationReadinessRowV1>{
        for (final row in report.rows) row.id: row,
      };

      final world1Campaign = byId['world1_spine_campaign_v1']!;
      expect(world1Campaign.runnerFamily, 'world1FoundationsRunner');
      expect(world1Campaign.canonicality, RunnerCanonicalityStatusV1.canonical);
      expect(world1Campaign.launchPathKind, RunnerLaunchPathKindV1.direct);
      expect(world1Campaign.launchHealth, RunnerLaunchHealthStatusV1.ok);
      expect(
        world1Campaign.launchHealthReason,
        'canonical_campaign_spine_pack',
      );

      final world2Session = byId['w2.s03']!;
      expect(world2Session.runnerFamily, 'sessionDrillPlayer');
      expect(world2Session.canonicality, RunnerCanonicalityStatusV1.canonical);
      expect(
        world2Session.screenFamily,
        'CanonicalTerminalSessionDrillSurfacedRunnerV1',
      );
      expect(world2Session.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(world2Session.launchHealth, RunnerLaunchHealthStatusV1.ok);
      expect(world2Session.launchHealthReason, 'supplements_live');
      expect(
        world2Session.canonicalityReasons,
        contains('canonical_spine_ok'),
      );
      expect(
        world2Session.canonicalityReasons,
        isNot(contains('host_family_split')),
      );

      final world2Campaign = byId['world2_spine_campaign_v1']!;
      expect(world2Campaign.runnerFamily, 'sessionDrillPlayer');
      expect(world2Campaign.canonicality, RunnerCanonicalityStatusV1.canonical);
      expect(
        world2Campaign.screenFamily,
        'CanonicalTerminalSessionDrillSurfacedRunnerV1',
      );
      expect(world2Campaign.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(world2Campaign.launchHealth, RunnerLaunchHealthStatusV1.ok);
      expect(
        world2Campaign.launchHealthReason,
        'session_drill_campaign_entry_pilot',
      );

      final world3Campaign = byId['world3_spine_campaign_v1']!;
      expect(world3Campaign.runnerFamily, 'sessionDrillPlayer');
      expect(world3Campaign.canonicality, RunnerCanonicalityStatusV1.canonical);
      expect(
        world3Campaign.screenFamily,
        'CanonicalTerminalSessionDrillSurfacedRunnerV1',
      );
      expect(world3Campaign.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(world3Campaign.launchHealth, RunnerLaunchHealthStatusV1.ok);
      expect(
        world3Campaign.launchHealthReason,
        'session_drill_campaign_entry_pilot',
      );

      final world9Campaign = byId['world9_spine_followup_v1_b2']!;
      expect(world9Campaign.runnerFamily, 'sessionDrillPlayer');
      expect(world9Campaign.canonicality, RunnerCanonicalityStatusV1.canonical);
      expect(world9Campaign.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(world9Campaign.launchHealth, RunnerLaunchHealthStatusV1.ok);
      expect(
        world9Campaign.launchHealthReason,
        'session_drill_campaign_entry_pilot',
      );

      final world4Session = byId['w4.s01']!;
      expect(world4Session.runnerFamily, 'sessionDrillPlayer');
      expect(world4Session.canonicality, RunnerCanonicalityStatusV1.canonical);
      expect(world4Session.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(world4Session.launchHealth, RunnerLaunchHealthStatusV1.ok);
      expect(
        world4Session.launchHealthReason,
        'canonical_single_step_session',
      );

      final world9Session = byId['w9.s10']!;
      expect(world9Session.runnerFamily, 'sessionDrillPlayer');
      expect(world9Session.canonicality, RunnerCanonicalityStatusV1.canonical);
      expect(world9Session.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(world9Session.launchHealth, RunnerLaunchHealthStatusV1.ok);
      expect(
        world9Session.launchHealthReason,
        'canonical_single_step_session',
      );

      final cashTrack = byId['cash.s01']!;
      expect(cashTrack.runnerFamily, 'sessionDrillPlayer');
      expect(cashTrack.canonicality, RunnerCanonicalityStatusV1.canonical);
      expect(cashTrack.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(cashTrack.launchHealth, RunnerLaunchHealthStatusV1.ok);
      expect(cashTrack.launchHealthReason, 'world10_track_root_entry_pilot');
      expect(cashTrack.canonicalityReasons, contains('track_session_spine'));

      final deepCashTrack = byId['cash.s02']!;
      expect(deepCashTrack.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(
        deepCashTrack.launchHealthReason,
        'world10_track_early_chain_pilot',
      );

      final deepTournamentTrack = byId['tournament.s03']!;
      expect(
        deepTournamentTrack.launchPathKind,
        RunnerLaunchPathKindV1.adapted,
      );
      expect(
        deepTournamentTrack.launchHealthReason,
        'world10_track_early_chain_pilot',
      );

      final remainingDeepTrack = byId['cash.s04']!;
      expect(remainingDeepTrack.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(
        remainingDeepTrack.launchHealthReason,
        'world10_track_tail_chain_pilot',
      );

      final tailTournamentTrack = byId['tournament.s10']!;
      expect(
        tailTournamentTrack.launchPathKind,
        RunnerLaunchPathKindV1.adapted,
      );
      expect(
        tailTournamentTrack.launchHealthReason,
        'world10_track_tail_chain_pilot',
      );

      final noRemainingSpecialCasedTrack = byId['mixed.s08']!;
      expect(
        noRemainingSpecialCasedTrack.launchPathKind,
        RunnerLaunchPathKindV1.adapted,
      );
      expect(
        noRemainingSpecialCasedTrack.launchHealthReason,
        'world10_track_tail_chain_pilot',
      );

      final world10Campaign = byId['world10_spine_campaign_v1']!;
      expect(world10Campaign.runnerFamily, 'sessionDrillPlayer');
      expect(world10Campaign.canonicality, RunnerCanonicalityStatusV1.canonical);
      expect(world10Campaign.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(
        world10Campaign.launchHealthReason,
        'session_drill_campaign_entry_pilot',
      );

      final world10Followup = byId['world10_spine_followup_v1_b0']!;
      expect(world10Followup.runnerFamily, 'sessionDrillPlayer');
      expect(
        world10Followup.canonicality,
        RunnerCanonicalityStatusV1.canonical,
      );
      expect(world10Followup.launchPathKind, RunnerLaunchPathKindV1.adapted);
      expect(
        world10Followup.launchHealthReason,
        'session_drill_campaign_entry_pilot',
      );
    },
  );

  test(
    'json payload carries stable summary structure and launch path coverage',
    () {
      final report = buildRunnerUnificationReadinessAuditReportV1(
        options: const RunnerUnificationReadinessAuditOptionsV1(world: 10),
      );
      final decoded =
          jsonDecode(encodeRunnerUnificationReadinessAuditReportJsonV1(report))
              as Map<String, dynamic>;

      expect(decoded['version'], 'v1');
      final summary = decoded['summary'] as Map<String, dynamic>;
      expect(summary['total_rows'], 34);
      expect(
        (summary['canonicality_counts'] as Map<String, dynamic>)['mixed'] ?? 0,
        0,
      );
      expect(
        (summary['canonicality_counts'] as Map<String, dynamic>)['canonical'],
        34,
      );
      expect(
        (summary['launch_path_counts']
            as Map<String, dynamic>)['special_cased'],
        isNull,
      );
      expect(
        (summary['launch_path_counts'] as Map<String, dynamic>)['adapted'],
        34,
      );
      expect(
        (summary['launch_health_counts'] as Map<String, dynamic>)['ok'],
        34,
      );
      final rows = decoded['rows'] as List<dynamic>;
      expect(rows, isNotEmpty);
      expect(
        rows.any(
          (row) =>
              (row as Map<String, dynamic>)['id'] ==
                  'world10_spine_campaign_v1' &&
              row['launch_path_kind'] == 'adapted',
        ),
        isTrue,
      );
      expect(
        rows.any(
          (row) =>
              (row as Map<String, dynamic>)['id'] ==
                  'world10_spine_followup_v1_b0' &&
              row['launch_path_kind'] == 'adapted',
        ),
        isTrue,
      );
      expect(
        rows.any(
          (row) =>
              (row as Map<String, dynamic>)['id'] == 'cash.s01' &&
              row['launch_path_kind'] == 'adapted',
        ),
        isTrue,
      );
      expect(
        rows.any(
          (row) =>
              (row as Map<String, dynamic>)['id'] == 'cash.s03' &&
              row['launch_path_kind'] == 'adapted',
        ),
        isTrue,
      );
      expect(
        rows.any(
          (row) =>
              (row as Map<String, dynamic>)['id'] == 'cash.s10' &&
              row['launch_path_kind'] == 'adapted',
        ),
        isTrue,
      );
    },
  );

  test(
    'accepted runner surface stays free of unknown health and special-cased launch drift',
    () {
      final report = buildRunnerUnificationReadinessAuditReportV1();

      expect(report.rows, isNotEmpty);
      expect(
        report.rows.where(
          (row) => row.launchHealth == RunnerLaunchHealthStatusV1.unknown,
        ),
        isEmpty,
      );
      expect(
        report.rows.where(
          (row) => row.launchHealth == RunnerLaunchHealthStatusV1.broken,
        ),
        isEmpty,
      );
      expect(
        report.rows.where(
          (row) => row.launchPathKind == RunnerLaunchPathKindV1.specialCased,
        ),
        isEmpty,
      );

      final byId = <String, RunnerUnificationReadinessRowV1>{
        for (final row in report.rows) row.id: row,
      };
      expect(
        byId['world1_spine_campaign_v1']!.launchPathKind,
        RunnerLaunchPathKindV1.direct,
      );
      expect(
        byId['world10_spine_campaign_v1']!.launchPathKind,
        RunnerLaunchPathKindV1.adapted,
      );
      expect(
        byId['world2_spine_campaign_v1']!.launchPathKind,
        RunnerLaunchPathKindV1.adapted,
      );
      expect(
        byId['cash.s01']!.launchPathKind,
        RunnerLaunchPathKindV1.adapted,
      );
    },
  );

  test('W4-W9 session-world cohorts now report canonical runner readiness', () {
    final report = buildRunnerUnificationReadinessAuditReportV1();
    final cohort = report.rows
        .where(
          (row) =>
              row.itemType == 'session' &&
              row.world >= 4 &&
              row.world <= 9 &&
              row.id.startsWith('w${row.world}.s'),
        )
        .toList(growable: false);

    expect(cohort, hasLength(60));
    expect(
      cohort.every(
        (row) =>
            row.canonicality == RunnerCanonicalityStatusV1.canonical &&
            row.launchPathKind == RunnerLaunchPathKindV1.adapted &&
            row.launchHealth == RunnerLaunchHealthStatusV1.ok,
      ),
      isTrue,
    );
  });

  test('W2-W10 campaign cohorts now report canonical runner readiness', () {
    final report = buildRunnerUnificationReadinessAuditReportV1();
    final cohort = report.rows
        .where((row) => row.itemType == 'campaign_pack' && row.world >= 2)
        .toList(growable: false);

    expect(cohort, hasLength(36));
    expect(
      cohort.every(
        (row) =>
            row.canonicality == RunnerCanonicalityStatusV1.canonical &&
            row.launchPathKind == RunnerLaunchPathKindV1.adapted &&
            row.launchHealth == RunnerLaunchHealthStatusV1.ok,
      ),
      isTrue,
    );
  });
}
