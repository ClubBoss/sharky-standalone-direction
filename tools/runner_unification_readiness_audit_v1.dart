import 'dart:convert';
import 'dart:io';

import 'runtime_world_session_health_audit_v1.dart' as health_audit;
import 'spine_progression_cohesion_audit_v1.dart' as spine_audit;

enum RunnerCanonicalityStatusV1 { canonical, mixed, nonCanonical }

enum RunnerLaunchPathKindV1 { direct, adapted, specialCased }

enum RunnerLaunchHealthStatusV1 { ok, legacy, degraded, broken, unknown }

class RunnerUnificationReadinessRowV1 {
  const RunnerUnificationReadinessRowV1({
    required this.world,
    required this.id,
    required this.itemType,
    required this.progressionType,
    required this.runnerFamily,
    required this.modeFamily,
    required this.canonicality,
    required this.canonicalityReasons,
    required this.launchPathKind,
    required this.launchHealth,
    required this.launchHealthReason,
    required this.orderIndex,
    this.trackKind,
    this.screenFamily,
    this.runnerContract,
  });

  final int world;
  final String id;
  final String itemType;
  final String progressionType;
  final String runnerFamily;
  final String modeFamily;
  final RunnerCanonicalityStatusV1 canonicality;
  final List<String> canonicalityReasons;
  final RunnerLaunchPathKindV1 launchPathKind;
  final RunnerLaunchHealthStatusV1 launchHealth;
  final String launchHealthReason;
  final int orderIndex;
  final String? trackKind;
  final String? screenFamily;
  final String? runnerContract;

  Map<String, Object> toJson() => <String, Object>{
    'world': world,
    'id': id,
    'item_type': itemType,
    'progression_type': progressionType,
    'runner_family': runnerFamily,
    'mode_family': modeFamily,
    'canonicality': canonicality.name,
    'canonicality_reasons': canonicalityReasons,
    'launch_path_kind': _launchPathKindJsonV1(launchPathKind),
    'launch_health': launchHealth.name,
    'launch_health_reason': launchHealthReason,
    'order_index': orderIndex,
    if (trackKind != null) 'track_kind': trackKind!,
    if (screenFamily != null) 'screen_family': screenFamily!,
    if (runnerContract != null) 'runner_contract': runnerContract!,
  };
}

class RunnerUnificationReadinessSummaryV1 {
  const RunnerUnificationReadinessSummaryV1({
    required this.totalRows,
    required this.canonicalityCounts,
    required this.launchHealthCounts,
    required this.launchPathCounts,
    required this.runnerFamilyCounts,
  });

  final int totalRows;
  final Map<String, int> canonicalityCounts;
  final Map<String, int> launchHealthCounts;
  final Map<String, int> launchPathCounts;
  final Map<String, int> runnerFamilyCounts;

  Map<String, Object> toJson() => <String, Object>{
    'total_rows': totalRows,
    'canonicality_counts': canonicalityCounts,
    'launch_health_counts': launchHealthCounts,
    'launch_path_counts': launchPathCounts,
    'runner_family_counts': runnerFamilyCounts,
  };
}

class RunnerUnificationReadinessReportV1 {
  const RunnerUnificationReadinessReportV1({
    required this.rows,
    required this.summary,
  });

  final List<RunnerUnificationReadinessRowV1> rows;
  final RunnerUnificationReadinessSummaryV1 summary;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'v1',
    'summary': summary.toJson(),
    'rows': rows.map((row) => row.toJson()).toList(growable: false),
  };
}

class RunnerUnificationReadinessAuditOptionsV1 {
  const RunnerUnificationReadinessAuditOptionsV1({this.world, this.idContains});

  final int? world;
  final String? idContains;
}

class RunnerUnificationReadinessCliV1 {
  const RunnerUnificationReadinessCliV1({
    required this.wantsJson,
    required this.options,
  });

  final bool wantsJson;
  final RunnerUnificationReadinessAuditOptionsV1 options;

  static RunnerUnificationReadinessCliV1 parse(List<String> args) {
    var wantsJson = false;
    int? world;
    String? idContains;
    for (final arg in args) {
      if (arg == '--json') {
        wantsJson = true;
        continue;
      }
      if (arg == '--help' || arg == '-h') {
        _printUsageV1();
        exit(0);
      }
      if (arg.startsWith('--world=')) {
        world = int.tryParse(arg.substring('--world='.length));
        if (world == null || world < 0) {
          stderr.writeln('Invalid --world value: $arg');
          exit(64);
        }
        continue;
      }
      if (arg.startsWith('--id-contains=')) {
        final value = arg.substring('--id-contains='.length).trim();
        if (value.isEmpty) {
          stderr.writeln('Invalid --id-contains value: $arg');
          exit(64);
        }
        idContains = value.toLowerCase();
        continue;
      }
      stderr.writeln('Unknown option: $arg');
      _printUsageV1();
      exit(64);
    }
    return RunnerUnificationReadinessCliV1(
      wantsJson: wantsJson,
      options: RunnerUnificationReadinessAuditOptionsV1(
        world: world,
        idContains: idContains,
      ),
    );
  }
}

void main(List<String> args) {
  final cli = RunnerUnificationReadinessCliV1.parse(args);
  final report = buildRunnerUnificationReadinessAuditReportV1(
    options: cli.options,
  );
  stdout.writeln(
    cli.wantsJson
        ? encodeRunnerUnificationReadinessAuditReportJsonV1(report)
        : renderRunnerUnificationReadinessAuditReportV1(report),
  );
}

RunnerUnificationReadinessReportV1
buildRunnerUnificationReadinessAuditReportV1({
  RunnerUnificationReadinessAuditOptionsV1 options =
      const RunnerUnificationReadinessAuditOptionsV1(),
}) {
  final spineReport = spine_audit.buildSpineProgressionCohesionAuditReportV1(
    options: spine_audit.SpineProgressionCohesionAuditOptionsV1(
      world: options.world,
      idContains: options.idContains,
    ),
  );
  final healthReport = health_audit.buildRuntimeWorldSessionHealthReportV1(
    includeCampaignPacks: true,
    includedWorlds: options.world == null ? null : <int>{options.world!},
  );
  final healthByRowKey = <String, health_audit.LearnerPathHealthRowV1>{
    for (final row in healthReport.rows) _rowKeyV1(row.world, row.id): row,
  };
  final filteredSpineRows = spineReport.rows.where((row) {
    if (options.idContains == null) return true;
    return row.id.toLowerCase().contains(options.idContains!);
  });
  final rows = filteredSpineRows
      .map(
        (row) => _mergeRowV1(row, healthByRowKey[_rowKeyV1(row.world, row.id)]),
      )
      .toList(growable: false);

  return RunnerUnificationReadinessReportV1(
    rows: rows,
    summary: _buildSummaryV1(rows),
  );
}

String renderRunnerUnificationReadinessAuditReportV1(
  RunnerUnificationReadinessReportV1 report,
) {
  final out = StringBuffer();
  final canonicalCount = report.summary.canonicalityCounts['canonical'] ?? 0;
  final mixedCount = report.summary.canonicalityCounts['mixed'] ?? 0;
  final nonCanonicalCount =
      report.summary.canonicalityCounts['nonCanonical'] ?? 0;
  final okCount = report.summary.launchHealthCounts['ok'] ?? 0;
  final legacyCount = report.summary.launchHealthCounts['legacy'] ?? 0;
  final degradedCount = report.summary.launchHealthCounts['degraded'] ?? 0;
  final brokenCount = report.summary.launchHealthCounts['broken'] ?? 0;
  final unknownCount = report.summary.launchHealthCounts['unknown'] ?? 0;
  out.writeln(
    'rows=${report.summary.totalRows} '
    'canonical=$canonicalCount mixed=$mixedCount '
    'non_canonical=$nonCanonicalCount ok=$okCount '
    'legacy=$legacyCount degraded=$degradedCount '
    'broken=$brokenCount unknown=$unknownCount',
  );
  out.writeln();
  out.writeln(
    'WORLD | ID | ITEM | PROGRESSION | RUNNER | MODE | CANONICALITY | '
    'LAUNCH_PATH | LAUNCH_HEALTH | CANONICALITY_REASONS | HEALTH_REASON',
  );
  for (final row in report.rows) {
    out.writeln(
      '${row.world} | ${row.id} | ${row.itemType} | ${row.progressionType} | '
      '${row.runnerFamily} | ${row.modeFamily} | ${row.canonicality.name} | '
      '${_launchPathKindJsonV1(row.launchPathKind)} | ${row.launchHealth.name} | '
      '${row.canonicalityReasons.join(',')} | ${row.launchHealthReason}',
    );
  }
  return out.toString().trimRight();
}

String encodeRunnerUnificationReadinessAuditReportJsonV1(
  RunnerUnificationReadinessReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

RunnerUnificationReadinessRowV1 _mergeRowV1(
  spine_audit.SpineProgressionCohesionRowV1 row,
  health_audit.LearnerPathHealthRowV1? health,
) {
  final canonicality = switch (row.cohesionStatus) {
    spine_audit.SpineCohesionStatusV1.canonical =>
      RunnerCanonicalityStatusV1.canonical,
    spine_audit.SpineCohesionStatusV1.mixed => RunnerCanonicalityStatusV1.mixed,
    spine_audit.SpineCohesionStatusV1.divergent =>
      RunnerCanonicalityStatusV1.nonCanonical,
  };
  final launchHealth = switch (health?.status) {
    health_audit.LearnerPathHealthStatusV1.ok => RunnerLaunchHealthStatusV1.ok,
    health_audit.LearnerPathHealthStatusV1.legacy =>
      RunnerLaunchHealthStatusV1.legacy,
    health_audit.LearnerPathHealthStatusV1.degraded =>
      RunnerLaunchHealthStatusV1.degraded,
    health_audit.LearnerPathHealthStatusV1.broken =>
      RunnerLaunchHealthStatusV1.broken,
    null => RunnerLaunchHealthStatusV1.unknown,
  };
  return RunnerUnificationReadinessRowV1(
    world: row.world,
    id: row.id,
    itemType: row.itemType,
    progressionType: row.progressionType,
    runnerFamily: row.hostFamily,
    modeFamily: row.modeFamily,
    canonicality: canonicality,
    canonicalityReasons: List<String>.unmodifiable(row.reasonCodes),
    launchPathKind: _launchPathKindForRowV1(row, health),
    launchHealth: launchHealth,
    launchHealthReason: health?.reason ?? 'missing_runtime_health_truth',
    orderIndex: row.orderIndex,
    trackKind: row.trackKind,
    screenFamily: row.screenFamily,
    runnerContract: row.runnerContract,
  );
}

RunnerLaunchPathKindV1 _launchPathKindForRowV1(
  spine_audit.SpineProgressionCohesionRowV1 row,
  health_audit.LearnerPathHealthRowV1? health,
) {
  if (row.itemType == 'campaign_pack' &&
      row.hostFamily == 'sessionDrillPlayer') {
    return RunnerLaunchPathKindV1.adapted;
  }
  switch (row.progressionType) {
    case 'campaign_spine_pack':
      return RunnerLaunchPathKindV1.direct;
    case 'session_world':
      return RunnerLaunchPathKindV1.adapted;
    case 'track_session':
      if (health?.reason == 'world10_track_root_entry_pilot' ||
          health?.reason == 'world10_track_early_chain_pilot' ||
          health?.reason == 'world10_track_tail_chain_pilot') {
        return RunnerLaunchPathKindV1.adapted;
      }
      return RunnerLaunchPathKindV1.specialCased;
  }
  return RunnerLaunchPathKindV1.direct;
}

RunnerUnificationReadinessSummaryV1 _buildSummaryV1(
  List<RunnerUnificationReadinessRowV1> rows,
) {
  final canonicalityCounts = <String, int>{};
  final launchHealthCounts = <String, int>{};
  final launchPathCounts = <String, int>{};
  final runnerFamilyCounts = <String, int>{};
  for (final row in rows) {
    canonicalityCounts.update(
      row.canonicality.name,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    launchHealthCounts.update(
      row.launchHealth.name,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    launchPathCounts.update(
      _launchPathKindJsonV1(row.launchPathKind),
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    runnerFamilyCounts.update(
      row.runnerFamily,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }
  return RunnerUnificationReadinessSummaryV1(
    totalRows: rows.length,
    canonicalityCounts: Map<String, int>.unmodifiable(canonicalityCounts),
    launchHealthCounts: Map<String, int>.unmodifiable(launchHealthCounts),
    launchPathCounts: Map<String, int>.unmodifiable(launchPathCounts),
    runnerFamilyCounts: Map<String, int>.unmodifiable(runnerFamilyCounts),
  );
}

String _launchPathKindJsonV1(RunnerLaunchPathKindV1 kind) {
  switch (kind) {
    case RunnerLaunchPathKindV1.direct:
      return 'direct';
    case RunnerLaunchPathKindV1.adapted:
      return 'adapted';
    case RunnerLaunchPathKindV1.specialCased:
      return 'special_cased';
  }
}

String _rowKeyV1(int world, String id) => '$world|${id.trim().toLowerCase()}';

void _printUsageV1() {
  stdout.writeln(
    'Usage: dart run tools/runner_unification_readiness_audit_v1.dart '
    '[--json] [--world=<n>] [--id-contains=<term>]',
  );
}
