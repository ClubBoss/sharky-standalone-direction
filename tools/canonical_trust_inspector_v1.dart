import 'dart:convert';
import 'dart:io';

import 'runner_unification_readiness_audit_v1.dart' as readiness_audit;

enum CanonicalTrustIssueCodeV1 {
  launchTargetDrift,
  nextTargetDivergence,
  actionSetMismatch,
  handoffSurfaceMismatch,
}

enum CanonicalTrustSeverityV1 { warning, error }

class CanonicalTrustIssueV1 {
  const CanonicalTrustIssueV1({
    required this.code,
    required this.severity,
    required this.entity,
    required this.expected,
    required this.actual,
  });

  final CanonicalTrustIssueCodeV1 code;
  final CanonicalTrustSeverityV1 severity;
  final String entity;
  final String expected;
  final String actual;

  Map<String, Object> toJson() => <String, Object>{
    'code': _issueCodeJsonV1(code),
    'severity': severity.name,
    'entity': entity,
    'expected': expected,
    'actual': actual,
  };
}

class CanonicalTrustSummaryV1 {
  const CanonicalTrustSummaryV1({
    required this.totalIssues,
    required this.errorCount,
    required this.warningCount,
    required this.inspectedEntityCount,
    required this.reasonCounts,
  });

  final int totalIssues;
  final int errorCount;
  final int warningCount;
  final int inspectedEntityCount;
  final Map<String, int> reasonCounts;

  Map<String, Object> toJson() => <String, Object>{
    'total_issues': totalIssues,
    'error_count': errorCount,
    'warning_count': warningCount,
    'inspected_entity_count': inspectedEntityCount,
    'reason_counts': reasonCounts,
  };
}

class CanonicalTrustInspectorReportV1 {
  const CanonicalTrustInspectorReportV1({
    required this.inspectedEntities,
    required this.issues,
    required this.summary,
  });

  final List<String> inspectedEntities;
  final List<CanonicalTrustIssueV1> issues;
  final CanonicalTrustSummaryV1 summary;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'v1',
    'inspected_entities': inspectedEntities,
    'summary': summary.toJson(),
    'issues': issues.map((issue) => issue.toJson()).toList(growable: false),
  };
}

class CanonicalTrustInspectorCliV1 {
  const CanonicalTrustInspectorCliV1({required this.wantsJson});

  final bool wantsJson;

  static CanonicalTrustInspectorCliV1 parse(List<String> args) {
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
    return CanonicalTrustInspectorCliV1(wantsJson: wantsJson);
  }
}

void main(List<String> args) {
  final cli = CanonicalTrustInspectorCliV1.parse(args);
  final report = buildCanonicalTrustInspectorReportV1();
  stdout.writeln(
    cli.wantsJson
        ? encodeCanonicalTrustInspectorReportJsonV1(report)
        : renderCanonicalTrustInspectorReportV1(report),
  );
}

CanonicalTrustInspectorReportV1 buildCanonicalTrustInspectorReportV1({
  String repoRoot = '.',
}) {
  final readiness = readiness_audit
      .buildRunnerUnificationReadinessAuditReportV1();
  final issues = <CanonicalTrustIssueV1>[
    ..._buildLaunchTargetIssuesV1(readiness),
    ..._buildNextTargetIssuesV1(repoRoot),
    ..._buildActionAvailabilityIssuesV1(repoRoot),
    ..._buildHandoffSurfaceIssuesV1(repoRoot),
  ]..sort(_compareIssuesV1);

  final inspectedEntities = <String>[
    for (final row in readiness.rows) 'launch:${row.id}',
    'next_target:learning_path_summary_cache_v2',
    'action_surface:session_result_screen_v1',
    'handoff_surface:drill_runner_to_session_result_v1',
  ];

  return CanonicalTrustInspectorReportV1(
    inspectedEntities: List<String>.unmodifiable(inspectedEntities),
    issues: List<CanonicalTrustIssueV1>.unmodifiable(issues),
    summary: _buildSummaryV1(issues, inspectedEntities.length),
  );
}

String renderCanonicalTrustInspectorReportV1(
  CanonicalTrustInspectorReportV1 report,
) {
  final out = StringBuffer()
    ..writeln(
      'inspected_entities=${report.summary.inspectedEntityCount} '
      'issues=${report.summary.totalIssues} '
      'errors=${report.summary.errorCount} '
      'warnings=${report.summary.warningCount}',
    )
    ..writeln();

  if (report.issues.isEmpty) {
    out.writeln('No learner-facing trust issues detected in v1 scope.');
    return out.toString().trimRight();
  }

  out.writeln('CODE | SEVERITY | ENTITY | EXPECTED | ACTUAL');
  for (final issue in report.issues) {
    out.writeln(
      '${_issueCodeJsonV1(issue.code)} | ${issue.severity.name} | '
      '${issue.entity} | ${issue.expected} | ${issue.actual}',
    );
  }
  return out.toString().trimRight();
}

String encodeCanonicalTrustInspectorReportJsonV1(
  CanonicalTrustInspectorReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

List<CanonicalTrustIssueV1> _buildLaunchTargetIssuesV1(
  readiness_audit.RunnerUnificationReadinessReportV1 readiness,
) {
  final issues = <CanonicalTrustIssueV1>[];
  for (final row in readiness.rows) {
    final hasHealthDrift =
        row.launchHealth != readiness_audit.RunnerLaunchHealthStatusV1.ok;
    final hasPathDrift =
        row.launchPathKind ==
        readiness_audit.RunnerLaunchPathKindV1.specialCased;
    if (!hasHealthDrift && !hasPathDrift) {
      continue;
    }
    issues.add(
      CanonicalTrustIssueV1(
        code: CanonicalTrustIssueCodeV1.launchTargetDrift,
        severity: _launchSeverityV1(row),
        entity: row.id,
        expected: 'launch_health=ok and launch_path_kind in {direct,adapted}',
        actual:
            'launch_health=${row.launchHealth.name}, '
            'launch_path_kind=${_launchPathKindJsonV1(row.launchPathKind)}',
      ),
    );
  }
  return issues;
}

List<CanonicalTrustIssueV1> _buildNextTargetIssuesV1(String repoRoot) {
  final cacheSource = File(
    '$repoRoot/lib/services/learning_path_summary_cache_v2.dart',
  ).readAsStringSync();
  final launcherSource = File(
    '$repoRoot/lib/services/learning_path_launcher_service.dart',
  ).readAsStringSync();

  final missing = <String>[
    if (!cacheSource.contains('await gatekeeper.updateStageUnlocks(t.id);'))
      'missing_gatekeeper_unlock_refresh',
    if (!cacheSource.contains('progress.unlockedStageIds()'))
      'missing_progress_unlock_source',
    if (!cacheSource.contains('gatekeeper.isStageUnlocked(stageId)'))
      'missing_gatekeeper_unlock_filter',
    if (!launcherSource.contains('final stage = summary.nextStageToTrain;'))
      'missing_summary_next_stage_handoff',
    if (!launcherSource.contains('await stageLauncher.launch(context, stage);'))
      'missing_stage_launcher_delegation',
  ];
  if (missing.isEmpty) {
    return const <CanonicalTrustIssueV1>[];
  }
  return <CanonicalTrustIssueV1>[
    CanonicalTrustIssueV1(
      code: CanonicalTrustIssueCodeV1.nextTargetDivergence,
      severity: CanonicalTrustSeverityV1.error,
      entity: 'learning_path_next_target_truth_spine_v1',
      expected:
          'summary-cache next target stays aligned with gatekeeper-backed progression truth and launcher delegation',
      actual: missing.join(','),
    ),
  ];
}

List<CanonicalTrustIssueV1> _buildActionAvailabilityIssuesV1(String repoRoot) {
  final source = File(
    '$repoRoot/lib/ui_v2/screens/session_result_screen.dart',
  ).readAsStringSync();
  final missing = <String>[
    if (!source.contains("'session_result_continuation_surface_v1'"))
      'missing_continuation_surface_key',
    if (!source.contains("'session_result_action_stack_v1'"))
      'missing_action_stack_key',
    if (!source.contains('Future<void> _runPrimaryExecutionIntentV1('))
      'missing_primary_execution_handler',
    if (!source.contains('primaryExecutionIntent: primaryExecutionIntent'))
      'missing_primary_execution_intent_binding',
  ];
  if (missing.isEmpty) {
    return const <CanonicalTrustIssueV1>[];
  }
  return <CanonicalTrustIssueV1>[
    CanonicalTrustIssueV1(
      code: CanonicalTrustIssueCodeV1.actionSetMismatch,
      severity: CanonicalTrustSeverityV1.error,
      entity: 'session_result_primary_action_surface_v1',
      expected:
          'canonical result continuation surface exposes an action stack with bound primary execution intent',
      actual: missing.join(','),
    ),
  ];
}

List<CanonicalTrustIssueV1> _buildHandoffSurfaceIssuesV1(String repoRoot) {
  final drillRunner = File(
    '$repoRoot/lib/ui_v2/screens/drill_runner_screen.dart',
  ).readAsStringSync();
  final handoffGuard = File(
    '$repoRoot/test/guards/runner_route_handoff_acceptance_contract_test.dart',
  ).readAsStringSync();
  final missing = <String>[
    if (!drillRunner.contains('pushReplacementSessionResultV1<void, void>(') &&
        !drillRunner.contains('SessionResultScreen('))
      'missing_session_result_handoff',
    if (!handoffGuard.contains("Key('session_result_continuation_surface_v1')"))
      'missing_continuation_surface_guard',
    if (!handoffGuard.contains("Key('session_result_action_stack_v1')"))
      'missing_action_stack_guard',
  ];
  if (missing.isEmpty) {
    return const <CanonicalTrustIssueV1>[];
  }
  return <CanonicalTrustIssueV1>[
    CanonicalTrustIssueV1(
      code: CanonicalTrustIssueCodeV1.handoffSurfaceMismatch,
      severity: CanonicalTrustSeverityV1.warning,
      entity: 'drill_runner_to_session_result_handoff_v1',
      expected:
          'legacy drill finish handoff reaches canonical result continuation surface with explicit guard coverage',
      actual: missing.join(','),
    ),
  ];
}

CanonicalTrustSummaryV1 _buildSummaryV1(
  List<CanonicalTrustIssueV1> issues,
  int inspectedEntityCount,
) {
  var errorCount = 0;
  var warningCount = 0;
  final reasonCounts = <String, int>{};
  for (final issue in issues) {
    switch (issue.severity) {
      case CanonicalTrustSeverityV1.error:
        errorCount++;
      case CanonicalTrustSeverityV1.warning:
        warningCount++;
    }
    reasonCounts.update(
      _issueCodeJsonV1(issue.code),
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }
  return CanonicalTrustSummaryV1(
    totalIssues: issues.length,
    errorCount: errorCount,
    warningCount: warningCount,
    inspectedEntityCount: inspectedEntityCount,
    reasonCounts: Map<String, int>.unmodifiable(reasonCounts),
  );
}

CanonicalTrustSeverityV1 _launchSeverityV1(
  readiness_audit.RunnerUnificationReadinessRowV1 row,
) {
  switch (row.launchHealth) {
    case readiness_audit.RunnerLaunchHealthStatusV1.broken:
    case readiness_audit.RunnerLaunchHealthStatusV1.unknown:
      return CanonicalTrustSeverityV1.error;
    case readiness_audit.RunnerLaunchHealthStatusV1.legacy:
    case readiness_audit.RunnerLaunchHealthStatusV1.degraded:
    case readiness_audit.RunnerLaunchHealthStatusV1.ok:
      return row.launchPathKind ==
              readiness_audit.RunnerLaunchPathKindV1.specialCased
          ? CanonicalTrustSeverityV1.warning
          : CanonicalTrustSeverityV1.warning;
  }
}

String _issueCodeJsonV1(CanonicalTrustIssueCodeV1 code) {
  switch (code) {
    case CanonicalTrustIssueCodeV1.launchTargetDrift:
      return 'LAUNCH_TARGET_DRIFT';
    case CanonicalTrustIssueCodeV1.nextTargetDivergence:
      return 'NEXT_TARGET_DIVERGENCE';
    case CanonicalTrustIssueCodeV1.actionSetMismatch:
      return 'ACTION_SET_MISMATCH';
    case CanonicalTrustIssueCodeV1.handoffSurfaceMismatch:
      return 'HANDOFF_SURFACE_MISMATCH';
  }
}

String _launchPathKindJsonV1(
  readiness_audit.RunnerLaunchPathKindV1 launchPathKind,
) {
  switch (launchPathKind) {
    case readiness_audit.RunnerLaunchPathKindV1.direct:
      return 'direct';
    case readiness_audit.RunnerLaunchPathKindV1.adapted:
      return 'adapted';
    case readiness_audit.RunnerLaunchPathKindV1.specialCased:
      return 'special_cased';
  }
}

int _compareIssuesV1(CanonicalTrustIssueV1 a, CanonicalTrustIssueV1 b) {
  final codeCompare = _issueCodeJsonV1(
    a.code,
  ).compareTo(_issueCodeJsonV1(b.code));
  if (codeCompare != 0) return codeCompare;
  final severityCompare = a.severity.index.compareTo(b.severity.index);
  if (severityCompare != 0) return severityCompare;
  return a.entity.compareTo(b.entity);
}

void _printUsageV1() {
  stdout.writeln(
    'Usage: dart run tools/canonical_trust_inspector_v1.dart [--json]',
  );
}
