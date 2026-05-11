import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/canonical_early_path_correctness_audit_v1.dart';

void main() {
  test('canonical early-path correctness audit v1 is deterministic', () async {
    final first = await buildCanonicalEarlyPathCorrectnessAuditReportV1();
    final second = await buildCanonicalEarlyPathCorrectnessAuditReportV1();

    expect(
      encodeCanonicalEarlyPathCorrectnessAuditJsonV1(first),
      encodeCanonicalEarlyPathCorrectnessAuditJsonV1(second),
    );
    expect(
      renderCanonicalEarlyPathCorrectnessAuditV1(first),
      renderCanonicalEarlyPathCorrectnessAuditV1(second),
    );
  });

  test('canonical early-path correctness audit v1 stays clean', () async {
    final report = await buildCanonicalEarlyPathCorrectnessAuditReportV1();
    final rowById = <String, CanonicalEarlyPathCorrectnessFamilyRowV1>{
      for (final row in report.rows) row.id: row,
    };

    expect(report.summary.totalIssues, 0);
    expect(report.summary.familyCount, 11);
    expect(report.summary.totalCheckedSources, 246);
    expect(report.summary.totalResidueSources, 0);
    expect(rowById.keys, contains('world1_scenario_truth_pilot_v1'));
    expect(rowById.keys, contains('world2_showdown_truth_v1'));
    expect(rowById.keys, contains('world2_seat_tap_truth_v1'));
    expect(rowById.keys, contains('world2_position_truth_v1'));
    expect(rowById.keys, contains('world2_initiative_truth_v1'));
    expect(rowById.keys, contains('world2_board_texture_truth_v1'));
    expect(rowById.keys, contains('world2_board_tap_truth_v1'));
    expect(rowById.keys, contains('world2_outs_truth_v1'));
    expect(rowById.keys, contains('world2_action_choice_policy_v1'));
    expect(rowById.keys, contains('world2_hand_chain_mixed_subset_v1'));
    expect(rowById.keys, contains('world3_early_arc_runtime_truth_v1'));

    expect(
      rowById['world1_scenario_truth_pilot_v1']!.checkedCount,
      greaterThan(0),
    );
    expect(rowById['world2_showdown_truth_v1']!.checkedCount, 4);
    expect(rowById['world2_showdown_truth_v1']!.residueCount, 0);
    expect(rowById['world2_seat_tap_truth_v1']!.checkedCount, 17);
    expect(rowById['world2_position_truth_v1']!.checkedCount, 4);
    expect(rowById['world2_initiative_truth_v1']!.checkedCount, 4);
    expect(rowById['world2_initiative_truth_v1']!.residueCount, 0);
    expect(rowById['world2_board_texture_truth_v1']!.checkedCount, 4);
    expect(rowById['world2_board_texture_truth_v1']!.residueCount, 0);
    expect(rowById['world2_board_tap_truth_v1']!.checkedCount, 9);
    expect(rowById['world2_outs_truth_v1']!.checkedCount, 3);
    expect(rowById['world2_action_choice_policy_v1']!.checkedCount, 87);
    expect(rowById['world2_action_choice_policy_v1']!.residueCount, 0);
    expect(rowById['world2_hand_chain_mixed_subset_v1']!.checkedCount, 8);
    expect(rowById['world3_early_arc_runtime_truth_v1']!.checkedCount, 10);
  });

  test(
    'canonical early-path correctness audit v1 json stays structured',
    () async {
      final report = await buildCanonicalEarlyPathCorrectnessAuditReportV1();
      final decoded =
          jsonDecode(encodeCanonicalEarlyPathCorrectnessAuditJsonV1(report))
              as Map<String, dynamic>;

      expect(decoded['version'], 'v1');
      expect(decoded['rows'], isA<List<dynamic>>());
      expect(decoded['summary'], isA<Map<String, dynamic>>());
    },
  );
}
