import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/campaign/world1_scenario_truth_pilot_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_defaults_v1.dart';
import 'package:poker_analyzer/services/world2_action_choice_policy_validator_v1.dart';
import 'package:poker_analyzer/services/world2_board_tap_truth_validator_v1.dart';
import 'package:poker_analyzer/services/world2_board_texture_truth_validator_v1.dart';
import 'package:poker_analyzer/services/world2_hand_chain_mixed_subset_validator_v1.dart';
import 'package:poker_analyzer/services/world2_initiative_truth_validator_v1.dart';
import 'package:poker_analyzer/services/world2_outs_truth_validator_v1.dart';
import 'package:poker_analyzer/services/world2_position_truth_validator_v1.dart';
import 'package:poker_analyzer/services/world2_seat_tap_truth_validator_v1.dart';
import 'package:poker_analyzer/services/world2_showdown_truth_validator_v1.dart';

class CanonicalEarlyPathCorrectnessFamilyRowV1 {
  const CanonicalEarlyPathCorrectnessFamilyRowV1({
    required this.id,
    required this.familySourceCount,
    required this.checkedCount,
    required this.residueCount,
    required this.checkedSources,
    required this.residueSources,
    required this.issues,
  });

  final String id;
  final int familySourceCount;
  final int checkedCount;
  final int residueCount;
  final List<String> checkedSources;
  final List<String> residueSources;
  final List<String> issues;

  Map<String, Object> toJson() => <String, Object>{
    'id': id,
    'family_source_count': familySourceCount,
    'checked_count': checkedCount,
    'residue_count': residueCount,
    'checked_sources': checkedSources,
    'residue_sources': residueSources,
    'issues': issues,
  };
}

class CanonicalEarlyPathCorrectnessSummaryV1 {
  const CanonicalEarlyPathCorrectnessSummaryV1({
    required this.totalIssues,
    required this.familyCount,
    required this.totalFamilySources,
    required this.totalCheckedSources,
    required this.totalResidueSources,
  });

  final int totalIssues;
  final int familyCount;
  final int totalFamilySources;
  final int totalCheckedSources;
  final int totalResidueSources;

  Map<String, Object> toJson() => <String, Object>{
    'total_issues': totalIssues,
    'family_count': familyCount,
    'total_family_sources': totalFamilySources,
    'total_checked_sources': totalCheckedSources,
    'total_residue_sources': totalResidueSources,
  };
}

class CanonicalEarlyPathCorrectnessAuditReportV1 {
  const CanonicalEarlyPathCorrectnessAuditReportV1({
    required this.rows,
    required this.summary,
  });

  final List<CanonicalEarlyPathCorrectnessFamilyRowV1> rows;
  final CanonicalEarlyPathCorrectnessSummaryV1 summary;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'v1',
    'rows': rows.map((row) => row.toJson()).toList(growable: false),
    'summary': summary.toJson(),
  };
}

class CanonicalEarlyPathCorrectnessAuditCliV1 {
  const CanonicalEarlyPathCorrectnessAuditCliV1({required this.wantsJson});

  final bool wantsJson;

  static CanonicalEarlyPathCorrectnessAuditCliV1 parse(List<String> args) {
    var wantsJson = false;
    for (final arg in args) {
      if (arg == '--json') {
        wantsJson = true;
        continue;
      }
      if (arg == '--help' || arg == '-h') {
        _printUsageV1();
        exit(0);
      }
      stderr.writeln('Unknown option: $arg');
      _printUsageV1();
      exit(64);
    }
    return CanonicalEarlyPathCorrectnessAuditCliV1(wantsJson: wantsJson);
  }
}

Future<void> main(List<String> args) async {
  final cli = CanonicalEarlyPathCorrectnessAuditCliV1.parse(args);
  final report = await buildCanonicalEarlyPathCorrectnessAuditReportV1();
  stdout.writeln(
    cli.wantsJson
        ? encodeCanonicalEarlyPathCorrectnessAuditJsonV1(report)
        : renderCanonicalEarlyPathCorrectnessAuditV1(report),
  );
}

Future<CanonicalEarlyPathCorrectnessAuditReportV1>
buildCanonicalEarlyPathCorrectnessAuditReportV1({
  String repoRoot = '.',
}) async {
  final sessionsRoot = '$repoRoot/content/worlds/world2/v1/sessions';
  final rows = <CanonicalEarlyPathCorrectnessFamilyRowV1>[
    _buildWorld1ScenarioTruthRowV1(),
    _buildWorld2ShowdownRowV1(sessionsRoot),
    _buildWorld2SeatTapRowV1(sessionsRoot),
    _buildWorld2PositionRowV1(sessionsRoot),
    _buildWorld2InitiativeRowV1(sessionsRoot),
    _buildWorld2BoardTextureRowV1(sessionsRoot),
    _buildWorld2BoardTapRowV1(sessionsRoot),
    _buildWorld2OutsRowV1(sessionsRoot),
    _buildWorld2ActionChoiceRowV1('$repoRoot/content/worlds/world2/v1'),
    _buildWorld2HandChainRowV1(sessionsRoot),
    await _buildWorld3RuntimeTruthRowV1(repoRoot),
  ];

  final summary = CanonicalEarlyPathCorrectnessSummaryV1(
    totalIssues: rows.fold<int>(0, (sum, row) => sum + row.issues.length),
    familyCount: rows.length,
    totalFamilySources: rows.fold<int>(
      0,
      (sum, row) => sum + row.familySourceCount,
    ),
    totalCheckedSources: rows.fold<int>(0, (sum, row) => sum + row.checkedCount),
    totalResidueSources: rows.fold<int>(0, (sum, row) => sum + row.residueCount),
  );

  return CanonicalEarlyPathCorrectnessAuditReportV1(
    rows: List<CanonicalEarlyPathCorrectnessFamilyRowV1>.unmodifiable(rows),
    summary: summary,
  );
}

String renderCanonicalEarlyPathCorrectnessAuditV1(
  CanonicalEarlyPathCorrectnessAuditReportV1 report,
) {
  final out = StringBuffer()
    ..writeln(
      'families=${report.summary.familyCount} '
      'sources=${report.summary.totalFamilySources} '
      'checked=${report.summary.totalCheckedSources} '
      'residue=${report.summary.totalResidueSources} '
      'issues=${report.summary.totalIssues}',
    )
    ..writeln()
    ..writeln('ID | SOURCES | CHECKED | RESIDUE | ISSUES');

  for (final row in report.rows) {
    out.writeln(
      '${row.id} | ${row.familySourceCount} | ${row.checkedCount} | '
      '${row.residueCount} | ${row.issues.length}',
    );
  }

  if (report.summary.totalIssues == 0) {
    out.writeln();
    out.writeln('No canonical early-path correctness issues detected in v1 scope.');
    return out.toString().trimRight();
  }

  out.writeln();
  out.writeln('ISSUES');
  for (final row in report.rows) {
    for (final issue in row.issues) {
      out.writeln('${row.id}: $issue');
    }
  }
  return out.toString().trimRight();
}

String encodeCanonicalEarlyPathCorrectnessAuditJsonV1(
  CanonicalEarlyPathCorrectnessAuditReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

CanonicalEarlyPathCorrectnessFamilyRowV1 _buildWorld1ScenarioTruthRowV1() {
  const pilotPackIds = <String>[
    'world1_spine_campaign_v1',
    'world1_spine_followup_v1_b0',
    'world1_spine_followup_v1_b1',
    'world1_spine_followup_v1_b2',
  ];

  final checkedSources = <String>[];
  final issues = <String>[];

  for (final packId in pilotPackIds) {
    final pack = kCampaignPacksV1[packId];
    if (pack == null) {
      issues.add('missing pack=$packId');
      continue;
    }
    final steps = pack12(pack);
    var packActionableCount = 0;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      if ((step.allowedActions ?? const <String>[]).isEmpty) {
        continue;
      }
      packActionableCount += 1;
      for (final family in World1ScenarioTruthFamilyV1.values) {
        checkedSources.add('$packId#step${i + 1}#${family.name}');
        issues.addAll(
          validateWorld1ScenarioTruthPilotStepV1(
            packId: packId,
            stepIndex: i,
            step: step,
            family: family,
          ),
        );
      }
    }
    if (packActionableCount == 0) {
      issues.add('pack=$packId has no actionable scenario-truth steps');
    }
  }

  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world1_scenario_truth_pilot_v1',
    familySourceCount: checkedSources.length,
    checkedCount: checkedSources.length,
    residueCount: 0,
    checkedSources: List<String>.unmodifiable(checkedSources),
    residueSources: const <String>[],
    issues: List<String>.unmodifiable(issues),
  );
}

CanonicalEarlyPathCorrectnessFamilyRowV1 _buildWorld2ShowdownRowV1(
  String rootPath,
) {
  final report = validateWorld2ShowdownTruthDirectoryV1(rootPath);
  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world2_showdown_truth_v1',
    familySourceCount: report.familySources.length,
    checkedCount: report.checkedCount,
    residueCount: report.skippedCount,
    checkedSources: report.checkedSources,
    residueSources: report.skippedSources,
    issues: report.issues,
  );
}

CanonicalEarlyPathCorrectnessFamilyRowV1 _buildWorld2SeatTapRowV1(
  String rootPath,
) {
  final report = validateWorld2SeatTapTruthDirectoryV1(rootPath);
  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world2_seat_tap_truth_v1',
    familySourceCount: report.familySources.length,
    checkedCount: report.checkedCount,
    residueCount: report.skippedCount,
    checkedSources: report.checkedSources,
    residueSources: report.skippedSources,
    issues: report.issues,
  );
}

CanonicalEarlyPathCorrectnessFamilyRowV1 _buildWorld2PositionRowV1(
  String rootPath,
) {
  final report = validateWorld2PositionTruthDirectoryV1(rootPath);
  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world2_position_truth_v1',
    familySourceCount: report.familySources.length,
    checkedCount: report.checkedCount,
    residueCount: report.skippedCount,
    checkedSources: report.checkedSources,
    residueSources: report.skippedSources,
    issues: report.issues,
  );
}

CanonicalEarlyPathCorrectnessFamilyRowV1 _buildWorld2InitiativeRowV1(
  String rootPath,
) {
  final report = validateWorld2InitiativeTruthDirectoryV1(rootPath);
  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world2_initiative_truth_v1',
    familySourceCount: report.familySources.length,
    checkedCount: report.checkedCount,
    residueCount: report.skippedCount,
    checkedSources: report.checkedSources,
    residueSources: report.skippedSources,
    issues: report.issues,
  );
}

CanonicalEarlyPathCorrectnessFamilyRowV1 _buildWorld2BoardTextureRowV1(
  String rootPath,
) {
  final report = validateWorld2BoardTextureTruthDirectoryV1(rootPath);
  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world2_board_texture_truth_v1',
    familySourceCount: report.familySources.length,
    checkedCount: report.checkedCount,
    residueCount: report.skippedCount,
    checkedSources: report.checkedSources,
    residueSources: report.skippedSources,
    issues: report.issues,
  );
}

CanonicalEarlyPathCorrectnessFamilyRowV1 _buildWorld2BoardTapRowV1(
  String rootPath,
) {
  final report = validateWorld2BoardTapTruthDirectoryV1(rootPath);
  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world2_board_tap_truth_v1',
    familySourceCount: report.familySources.length,
    checkedCount: report.checkedCount,
    residueCount: report.skippedCount,
    checkedSources: report.checkedSources,
    residueSources: report.skippedSources,
    issues: report.issues,
  );
}

CanonicalEarlyPathCorrectnessFamilyRowV1 _buildWorld2OutsRowV1(
  String rootPath,
) {
  final report = validateWorld2OutsTruthDirectoryV1(rootPath);
  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world2_outs_truth_v1',
    familySourceCount: report.familySources.length,
    checkedCount: report.checkedCount,
    residueCount: report.skippedCount,
    checkedSources: report.checkedSources,
    residueSources: report.skippedSources,
    issues: report.issues,
  );
}

CanonicalEarlyPathCorrectnessFamilyRowV1 _buildWorld2ActionChoiceRowV1(
  String rootPath,
) {
  final report = validateWorld2ActionChoicePolicyDirectoryV1(rootPath);
  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world2_action_choice_policy_v1',
    familySourceCount: report.familySources.length,
    checkedCount: report.checkedCount,
    residueCount: report.excludedCount,
    checkedSources: report.checkedSources,
    residueSources: report.excludedSources,
    issues: report.issues,
  );
}

CanonicalEarlyPathCorrectnessFamilyRowV1 _buildWorld2HandChainRowV1(
  String rootPath,
) {
  final report = validateWorld2HandChainMixedSubsetDirectoryV1(rootPath);
  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world2_hand_chain_mixed_subset_v1',
    familySourceCount: report.familySources.length,
    checkedCount: report.checkedCount,
    residueCount: report.skippedCount,
    checkedSources: report.checkedSources,
    residueSources: report.skippedSources,
    issues: report.issues,
  );
}

Future<CanonicalEarlyPathCorrectnessFamilyRowV1> _buildWorld3RuntimeTruthRowV1(
  String repoRoot,
) async {
  const sessionIds = <String>[
    'w3.s01',
    'w3.s02',
    'w3.s03',
    'w3.s04',
    'w3.s05',
    'w3.s06',
    'w3.s07',
    'w3.s08',
    'w3.s09',
    'w3.s10',
  ];

  final checkedSources = <String>[];
  final issues = <String>[];

  for (final sessionId in sessionIds) {
    checkedSources.add(sessionId);
    final sessionPath =
        '$repoRoot/content/worlds/world3/v1/sessions/${sessionId.toLowerCase()}';
    final indexFile = File('$sessionPath/drills/index.md');
    if (!indexFile.existsSync()) {
      issues.add('$sessionId missing drills/index.md');
      continue;
    }
    final drillIds = parseDrillIdsFromIndexV1(indexFile.readAsStringSync());
    if (drillIds.length != 1) {
      issues.add('$sessionId expected exactly 1 drill id but found ${drillIds.length}');
      continue;
    }

    final drillId = drillIds.single;
    final drillFile = File('$sessionPath/drills/d.$drillId.json');
    if (!drillFile.existsSync()) {
      issues.add('$sessionId missing drill file for $drillId');
      continue;
    }

    final defaultsPath = sessionDrillProjectionDefaultsPathForSessionPathV1(
      sessionPath,
    );
    final defaultsFile = File(defaultsPath);
    final mergedRaw = mergeSessionDrillProjectionDefaultsIntoDrillJsonV1(
      sessionId: sessionId,
      drillId: drillId,
      drillRaw: drillFile.readAsStringSync(),
      defaultsRaw: defaultsFile.existsSync() ? defaultsFile.readAsStringSync() : null,
    );
    final spec = DrillSpecV1.fromJsonString(mergedRaw);

    if (spec.kind != DrillKindV1.handChain) {
      issues.add('$sessionId expected hand_chain_v1 but found ${spec.kind.name}');
      continue;
    }
    final steps = spec.chainStepsV1;
    if (steps == null || steps.length != 3) {
      issues.add('$sessionId expected exactly 3 chain steps');
      continue;
    }
    if (!steps.every((step) => step.street == 'preflop')) {
      issues.add('$sessionId expected every chain step to stay preflop');
    }
  }

  return CanonicalEarlyPathCorrectnessFamilyRowV1(
    id: 'world3_early_arc_runtime_truth_v1',
    familySourceCount: sessionIds.length,
    checkedCount: checkedSources.length,
    residueCount: 0,
    checkedSources: List<String>.unmodifiable(checkedSources),
    residueSources: const <String>[],
    issues: List<String>.unmodifiable(issues),
  );
}

void _printUsageV1() {
  stdout.writeln(
    'Usage: dart tools/canonical_early_path_correctness_audit_v1.dart [--json]',
  );
}
