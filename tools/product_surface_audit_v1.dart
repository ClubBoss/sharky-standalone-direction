import 'dart:convert';
import 'dart:io';

enum ProductSurfaceAuditSeverityV1 {
  p0('P0', 3),
  p1('P1', 2),
  p2('P2', 1);

  const ProductSurfaceAuditSeverityV1(this.label, this.rank);

  final String label;
  final int rank;
}

class ProductSurfaceAuditFindingV1 {
  const ProductSurfaceAuditFindingV1({
    required this.reasonCode,
    required this.family,
    required this.severity,
    required this.failureClass,
    required this.fixStrategy,
    required this.message,
    required this.evidencePaths,
    required this.firstUserSpine,
    this.worldIds = const <String>[],
  });

  final String reasonCode;
  final String family;
  final ProductSurfaceAuditSeverityV1 severity;
  final String failureClass;
  final String fixStrategy;
  final String message;
  final List<String> evidencePaths;
  final bool firstUserSpine;
  final List<String> worldIds;

  Map<String, Object> toJson() => <String, Object>{
    'reason_code': reasonCode,
    'family': family,
    'severity': severity.label,
    'failure_class': failureClass,
    'fix_strategy': fixStrategy,
    'message': message,
    'evidence_paths': evidencePaths,
    'first_user_spine': firstUserSpine,
    if (worldIds.isNotEmpty) 'world_ids': worldIds,
  };
}

class ProductSurfaceAuditTopClusterV1 {
  const ProductSurfaceAuditTopClusterV1({
    required this.family,
    required this.severity,
    required this.failureClass,
    required this.fixStrategy,
    required this.count,
  });

  final String family;
  final ProductSurfaceAuditSeverityV1 severity;
  final String failureClass;
  final String fixStrategy;
  final int count;

  Map<String, Object> toJson() => <String, Object>{
    'family': family,
    'severity': severity.label,
    'failure_class': failureClass,
    'fix_strategy': fixStrategy,
    'count': count,
  };
}

class ProductSurfaceAuditSummaryV1 {
  const ProductSurfaceAuditSummaryV1({
    required this.totalIssues,
    required this.familyCounts,
    required this.severityCounts,
    required this.failureClassCounts,
    required this.fixStrategyCounts,
    required this.firstUserSpineTotal,
    required this.firstUserSpineFamilyCounts,
    required this.topClusters,
  });

  final int totalIssues;
  final Map<String, int> familyCounts;
  final Map<String, int> severityCounts;
  final Map<String, int> failureClassCounts;
  final Map<String, int> fixStrategyCounts;
  final int firstUserSpineTotal;
  final Map<String, int> firstUserSpineFamilyCounts;
  final List<ProductSurfaceAuditTopClusterV1> topClusters;

  Map<String, Object> toJson() => <String, Object>{
    'total_issues': totalIssues,
    'family_counts': familyCounts,
    'severity_counts': severityCounts,
    'failure_class_counts': failureClassCounts,
    'fix_strategy_counts': fixStrategyCounts,
    'first_user_spine_total': firstUserSpineTotal,
    'first_user_spine_family_counts': firstUserSpineFamilyCounts,
    'top_clusters': topClusters.map((cluster) => cluster.toJson()).toList(),
  };
}

class ProductSurfaceAuditReportV1 {
  const ProductSurfaceAuditReportV1({
    required this.inspectedFamilies,
    required this.findings,
    required this.summary,
  });

  final List<String> inspectedFamilies;
  final List<ProductSurfaceAuditFindingV1> findings;
  final ProductSurfaceAuditSummaryV1 summary;

  Map<String, Object> toJson() => <String, Object>{
    'version': 'PRODUCT_SURFACE_AUDIT_V1',
    'inspected_families': inspectedFamilies,
    'summary': summary.toJson(),
    'findings': findings.map((finding) => finding.toJson()).toList(),
  };
}

class ProductSurfaceAuditCliOptionsV1 {
  const ProductSurfaceAuditCliOptionsV1({
    required this.wantsJson,
    required this.rootPath,
    required this.familyFilter,
  });

  final bool wantsJson;
  final String rootPath;
  final String? familyFilter;
}

class _SurfaceExpectationV1 {
  const _SurfaceExpectationV1({
    required this.label,
    required this.indicatorPaths,
    required this.protectsCriticalText,
    required this.fixStrategy,
  });

  final String label;
  final List<String> indicatorPaths;
  final bool protectsCriticalText;
  final String fixStrategy;
}

class _SurfaceFamilySpecV1 {
  const _SurfaceFamilySpecV1({
    required this.id,
    required this.cliLabel,
    required this.displayName,
    required this.firstUserSpine,
    required this.ownerPaths,
    required this.requiredTestPaths,
    required this.futureExpectations,
    required this.degradedStateIndicatorPaths,
    required this.defaultFixStrategy,
    required this.missingOwnerFailureClass,
    this.worldIds = const <String>[],
    this.resultAnchors = const <String>[],
    this.internalTokenFailureClass = 'copy_language_problem',
  });

  final String id;
  final String cliLabel;
  final String displayName;
  final bool firstUserSpine;
  final List<String> ownerPaths;
  final List<String> requiredTestPaths;
  final List<_SurfaceExpectationV1> futureExpectations;
  final List<String> degradedStateIndicatorPaths;
  final String defaultFixStrategy;
  final String missingOwnerFailureClass;
  final List<String> worldIds;
  final List<String> resultAnchors;
  final String internalTokenFailureClass;
}

class _RouteFeedbackSignalRuleV1 {
  const _RouteFeedbackSignalRuleV1({
    required this.familyId,
    required this.evidencePath,
    required this.reasonCode,
    required this.failureClass,
    required this.severity,
    required this.fixStrategy,
    required this.message,
    this.requiredSubstrings = const <String>[],
    this.anyOfSubstrings = const <String>[],
  });

  final String familyId;
  final String evidencePath;
  final String reasonCode;
  final String failureClass;
  final ProductSurfaceAuditSeverityV1 severity;
  final String fixStrategy;
  final String message;
  final List<String> requiredSubstrings;
  final List<String> anyOfSubstrings;
}

const String _kProductSurfaceReadinessDocV1 =
    'docs/plan/PRODUCT_SURFACE_READINESS_v1.md';

final RegExp _kInternalWorldTokenV1 = RegExp(r'\bw\d+\.s\d+\b');
final RegExp _kInternalWorldLabelV1 = RegExp(r'\bworld\d+\b');
final RegExp _kInternalVersionTokenV1 = RegExp(r'_v\d+\b');
final RegExp _kInternalAnchorTokenV1 = RegExp(
  r'\banchor\b',
  caseSensitive: false,
);
final RegExp _kInternalTopologyTokenV1 = RegExp(
  r'\b(topology|seat[_ -]?[a-z]{1,3}|bb|sb|utg)\b',
  caseSensitive: false,
);
final RegExp _kSimpleStructuralLiteralV1 = RegExp(r'^[a-z0-9_./:+#-]+$');
final RegExp _kStringLiteralPatternV1 = RegExp(
  r'''(?:"((?:\\.|[^"\\])*)"|'((?:\\.|[^'\\])*)')''',
  multiLine: true,
);

const List<_SurfaceFamilySpecV1> _kSurfaceFamiliesV1 = <_SurfaceFamilySpecV1>[
  _SurfaceFamilySpecV1(
    id: 'today_plan_intake',
    cliLabel: 'today',
    displayName: 'Today Plan / intake',
    firstUserSpine: true,
    ownerPaths: <String>['lib/ui_v2/screens/universal_intake_plan_screen.dart'],
    requiredTestPaths: <String>[
      'test/guards/world1_intake_plan_flow_contract_test.dart',
      'test/ui_v2/today_plan_entitlement_truth_v1_test.dart',
      'test/guards/world_campaign_map_home_contract_test.dart',
    ],
    futureExpectations: <_SurfaceExpectationV1>[
      _SurfaceExpectationV1(
        label: 'today_non_overlap_contract',
        indicatorPaths: <String>[
          'test/guards/world1_today_plan_text_safety_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
      _SurfaceExpectationV1(
        label: 'today_cta_safe_area_contract',
        indicatorPaths: <String>[
          'test/guards/world1_plan_result_compact_height_no_overflow_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'host/shell fix',
      ),
      _SurfaceExpectationV1(
        label: 'today_small_screen_text_fit_contract',
        indicatorPaths: <String>[
          'test/guards/world1_today_chip_ultra_narrow_contract_test.dart',
          'test/guards/world1_plan_result_compact_height_no_overflow_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
      _SurfaceExpectationV1(
        label: 'today_text_scale_contract',
        indicatorPaths: <String>[
          'test/guards/world1_today_plan_text_safety_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
    ],
    degradedStateIndicatorPaths: <String>[
      'test/ui_v2/today_plan_entitlement_truth_v1_test.dart',
      'test/guards/world_campaign_map_home_contract_test.dart',
    ],
    defaultFixStrategy: 'state mapping fix',
    missingOwnerFailureClass: 'host_layout_problem',
    worldIds: <String>['world1'],
  ),
  _SurfaceFamilySpecV1(
    id: 'first_user_intro_trust_primer',
    cliLabel: 'intro',
    displayName: 'First-user intro / trust-primer',
    firstUserSpine: true,
    ownerPaths: <String>[
      'lib/ui_v2/onboarding/onboarding_how_it_works_screen.dart',
      'lib/ui_v2/onboarding/onboarding_welcome_screen.dart',
    ],
    requiredTestPaths: <String>[
      'test/ui_v2/onboarding_how_it_works_trust_primer_test.dart',
      'test/ui_v2/onboarding_first_win_test.dart',
      'test/guards/result_onboarding_visual_cohesion_contract_test.dart',
    ],
    futureExpectations: <_SurfaceExpectationV1>[
      _SurfaceExpectationV1(
        label: 'intro_readability_contract',
        indicatorPaths: <String>[
          'test/ui_v2/onboarding_how_it_works_trust_primer_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'copy fix',
      ),
      _SurfaceExpectationV1(
        label: 'intro_cta_safe_area_contract',
        indicatorPaths: <String>[
          'test/ui_v2/onboarding_intro_text_safety_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'host/shell fix',
      ),
      _SurfaceExpectationV1(
        label: 'intro_small_screen_text_fit_contract',
        indicatorPaths: <String>[
          'test/ui_v2/onboarding_intro_text_safety_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
      _SurfaceExpectationV1(
        label: 'intro_text_scale_contract',
        indicatorPaths: <String>[
          'test/ui_v2/onboarding_intro_text_safety_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
    ],
    degradedStateIndicatorPaths: <String>[
      'test/ui_v2/onboarding_first_win_test.dart',
    ],
    defaultFixStrategy: 'copy fix',
    missingOwnerFailureClass: 'intro_onboarding_absence',
  ),
  _SurfaceFamilySpecV1(
    id: 'runner_prompt_table_surface',
    cliLabel: 'runner',
    displayName: 'Runner prompt / table surface',
    firstUserSpine: true,
    ownerPaths: <String>[
      'lib/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart',
      'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
    ],
    requiredTestPaths: <String>[
      'test/ui_v2/runner_host_prompt_reveal_presentation_v1_test.dart',
      'test/ui_v2/factual_runner_host_contract_v1_test.dart',
      'test/ui_v2/runner/world1_canonical_table_instruction_surface_v1_test.dart',
    ],
    futureExpectations: <_SurfaceExpectationV1>[
      _SurfaceExpectationV1(
        label: 'runner_rendered_non_overlap_contract',
        indicatorPaths: <String>[
          'test/ui_v2/runner/canonical_table_runner_surface_contract_v1_test.dart',
          'test/guards/world1_foundations_microtask_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
      _SurfaceExpectationV1(
        label: 'runner_prompt_safe_zone_contract',
        indicatorPaths: <String>[
          'test/ui_v2/runner/world1_canonical_table_instruction_surface_v1_test.dart',
          'test/guards/world1_foundations_microtask_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'host/shell fix',
      ),
      _SurfaceExpectationV1(
        label: 'runner_small_screen_text_fit_contract',
        indicatorPaths: <String>[
          'test/ui_v2/runner/world1_canonical_portrait_overlay_contract_v1_test.dart',
          'test/guards/world1_foundations_microtask_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
      _SurfaceExpectationV1(
        label: 'runner_text_scale_contract',
        indicatorPaths: <String>[
          'test/guards/world1_foundations_microtask_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
    ],
    degradedStateIndicatorPaths: <String>[
      'test/ui_v2/runner/session_drill_canonical_factual_supplement_fallback_v1_test.dart',
    ],
    defaultFixStrategy: 'host/shell fix',
    missingOwnerFailureClass: 'host_layout_problem',
    worldIds: <String>['world1'],
  ),
  _SurfaceFamilySpecV1(
    id: 'result_next_step_surface',
    cliLabel: 'result',
    displayName: 'Result / next-step surface',
    firstUserSpine: true,
    ownerPaths: <String>['lib/ui_v2/screens/session_result_screen.dart'],
    requiredTestPaths: <String>[
      'test/ui_v2/session_result_screen_contract_test.dart',
      'test/guards/world1_result_whats_next_block_contract_test.dart',
      'test/guards/result_onboarding_visual_cohesion_contract_test.dart',
    ],
    futureExpectations: <_SurfaceExpectationV1>[
      _SurfaceExpectationV1(
        label: 'result_readability_contract',
        indicatorPaths: <String>[
          'test/ui_v2/session_result_world1_onboarding_payoff_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'copy fix',
      ),
      _SurfaceExpectationV1(
        label: 'result_cta_safe_area_contract',
        indicatorPaths: <String>[
          'test/guards/next_module_visibility_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'host/shell fix',
      ),
      _SurfaceExpectationV1(
        label: 'result_small_screen_text_fit_contract',
        indicatorPaths: <String>[
          'test/guards/world1_plan_result_compact_height_no_overflow_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
      _SurfaceExpectationV1(
        label: 'result_text_scale_contract',
        indicatorPaths: <String>[
          'test/ui_v2/session_result_text_scale_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
    ],
    degradedStateIndicatorPaths: <String>[
      'test/guards/session_result_non_spine_entry_routing_contract_test.dart',
      'test/guards/session_result_spine_continuation_parity_contract_test.dart',
    ],
    defaultFixStrategy: 'copy fix',
    missingOwnerFailureClass: 'result_payoff_problem',
    worldIds: <String>['world1'],
    resultAnchors: <String>[
      'session_result_continuation_surface_v1',
      'session_result_action_stack_v1',
      'session_result_visual_anchor_v1',
      'session_result_finish_label_v1',
      'session_result_next_module_cta',
    ],
  ),
  _SurfaceFamilySpecV1(
    id: 'premium_trial_access_state_surface',
    cliLabel: 'premium',
    displayName: 'Premium / trial / access-state surface',
    firstUserSpine: true,
    ownerPaths: <String>[
      'lib/ui_v2/screens/universal_intake_plan_screen.dart',
      'lib/services/premium_service.dart',
    ],
    requiredTestPaths: <String>[
      'test/ui_v2/today_plan_entitlement_truth_v1_test.dart',
      'test/ui_v2/premium_hub_access_state_v1_test.dart',
      'test/services/premium_restore_flow_v1_test.dart',
    ],
    futureExpectations: <_SurfaceExpectationV1>[
      _SurfaceExpectationV1(
        label: 'premium_access_state_readability_contract',
        indicatorPaths: <String>[
          'test/ui_v2/premium_hub_access_state_v1_test.dart',
          'test/ui_v2/today_plan_entitlement_truth_v1_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'state mapping fix',
      ),
      _SurfaceExpectationV1(
        label: 'premium_cta_safe_area_contract',
        indicatorPaths: <String>[
          'test/ui_v2/today_plan_premium_access_text_safety_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'host/shell fix',
      ),
      _SurfaceExpectationV1(
        label: 'premium_small_screen_text_fit_contract',
        indicatorPaths: <String>[
          'test/ui_v2/today_plan_premium_access_text_safety_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
      _SurfaceExpectationV1(
        label: 'premium_text_scale_contract',
        indicatorPaths: <String>[
          'test/ui_v2/today_plan_premium_access_text_safety_contract_test.dart',
        ],
        protectsCriticalText: true,
        fixStrategy: 'layout fix',
      ),
    ],
    degradedStateIndicatorPaths: <String>[
      'test/ui_v2/premium_hub_access_state_v1_test.dart',
      'test/services/premium_restore_flow_v1_test.dart',
    ],
    defaultFixStrategy: 'state mapping fix',
    missingOwnerFailureClass: 'premium_access_state_problem',
    worldIds: <String>['world1'],
  ),
];

void main(List<String> args) {
  final options = _parseCliOptionsV1(args);
  try {
    final report = buildProductSurfaceAuditReportV1(
      rootPath: options.rootPath,
      familyFilter: options.familyFilter,
    );
    stdout.write(
      options.wantsJson
          ? encodeProductSurfaceAuditReportJsonV1(report)
          : renderProductSurfaceAuditReportV1(report),
    );
    exitCode = 0;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  } on FileSystemException catch (error) {
    stderr.writeln(error.message);
    exitCode = 66;
  }
}

ProductSurfaceAuditReportV1 buildProductSurfaceAuditReportV1({
  String rootPath = '.',
  String? familyFilter,
}) {
  final readinessDoc = File(
    _joinRootV1(rootPath, _kProductSurfaceReadinessDocV1),
  );
  if (!readinessDoc.existsSync()) {
    throw FileSystemException(
      'Required governing truth file is missing',
      readinessDoc.path,
    );
  }

  final families = _selectFamiliesV1(familyFilter);
  final findings = <ProductSurfaceAuditFindingV1>[];
  for (final family in families) {
    findings.addAll(_scanSurfaceFamilyV1(family, rootPath: rootPath));
  }
  final summary = _buildSummaryV1(findings, inspectedFamilies: families);
  return ProductSurfaceAuditReportV1(
    inspectedFamilies: families
        .map((family) => family.id)
        .toList(growable: false),
    findings: findings,
    summary: summary,
  );
}

String renderProductSurfaceAuditReportV1(ProductSurfaceAuditReportV1 report) {
  final buffer = StringBuffer()
    ..writeln('PRODUCT_SURFACE_AUDIT_V1')
    ..writeln('TOTAL_ISSUES\t${report.summary.totalIssues}')
    ..writeln('INSPECTED_FAMILIES\t${report.inspectedFamilies.length}');

  _writeCountsV1(buffer, 'FAMILY_COUNTS', report.summary.familyCounts);
  _writeCountsV1(buffer, 'SEVERITY_COUNTS', report.summary.severityCounts);
  _writeCountsV1(
    buffer,
    'FAILURE_CLASS_COUNTS',
    report.summary.failureClassCounts,
  );
  _writeCountsV1(
    buffer,
    'FIX_STRATEGY_COUNTS',
    report.summary.fixStrategyCounts,
  );
  buffer
    ..writeln('FIRST_USER_SPINE_TOTAL\t${report.summary.firstUserSpineTotal}')
    ..writeln('FIRST_USER_SPINE_FAMILY_COUNTS');
  for (final entry
      in report.summary.firstUserSpineFamilyCounts.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key))) {
    buffer.writeln('FIRST_USER_SPINE\t${entry.key}\t${entry.value}');
  }

  buffer.writeln('TOP_P0_P1_CLUSTERS');
  if (report.summary.topClusters.isEmpty) {
    buffer.writeln('TOP_CLUSTER\tNONE');
  } else {
    for (final cluster in report.summary.topClusters) {
      buffer.writeln(
        'TOP_CLUSTER\t${cluster.severity.label}\t${cluster.family}\t'
        '${cluster.failureClass}\t${cluster.fixStrategy}\t${cluster.count}',
      );
    }
  }

  buffer.writeln('FINDINGS');
  if (report.findings.isEmpty) {
    buffer.writeln('FINDING\tNONE');
    return buffer.toString();
  }

  final findingsByFamily = <String, List<ProductSurfaceAuditFindingV1>>{};
  for (final finding in report.findings) {
    findingsByFamily.putIfAbsent(
      finding.family,
      () => <ProductSurfaceAuditFindingV1>[],
    )..add(finding);
  }
  final sortedFamilies = findingsByFamily.keys.toList()..sort();
  for (final family in sortedFamilies) {
    buffer.writeln('FAMILY\t$family');
    final familyFindings = findingsByFamily[family]!
      ..sort((a, b) {
        final severityCompare = b.severity.rank.compareTo(a.severity.rank);
        if (severityCompare != 0) {
          return severityCompare;
        }
        final classCompare = a.failureClass.compareTo(b.failureClass);
        if (classCompare != 0) {
          return classCompare;
        }
        return a.message.compareTo(b.message);
      });
    for (final finding in familyFindings) {
      buffer.writeln(
        'FINDING\t${finding.severity.label}\t${finding.failureClass}\t'
        '${finding.fixStrategy}\t${finding.reasonCode}\t${finding.message}',
      );
      for (final path in finding.evidencePaths) {
        buffer.writeln('EVIDENCE\t$path');
      }
    }
  }

  return buffer.toString();
}

String encodeProductSurfaceAuditReportJsonV1(
  ProductSurfaceAuditReportV1 report,
) {
  return const JsonEncoder.withIndent('  ').convert(report.toJson());
}

ProductSurfaceAuditCliOptionsV1 _parseCliOptionsV1(List<String> args) {
  var wantsJson = false;
  var rootPath = '.';
  String? familyFilter;

  for (final arg in args) {
    if (arg == '--json') {
      wantsJson = true;
      continue;
    }
    if (arg == '--help' || arg == '-h') {
      _printUsageV1();
      exit(0);
    }
    if (arg.startsWith('--root=')) {
      rootPath = arg.substring('--root='.length);
      continue;
    }
    if (arg.startsWith('--family=')) {
      familyFilter = arg.substring('--family='.length);
      continue;
    }
    throw const FormatException(
      'product_surface_audit_v1: supported options are --json, --family=<today|intro|runner|result|premium>, --root=<path>',
    );
  }

  final allowedFamilies = _kSurfaceFamiliesV1
      .map((family) => family.cliLabel)
      .toSet();
  if (familyFilter != null && !allowedFamilies.contains(familyFilter)) {
    throw FormatException('Invalid --family value: $familyFilter');
  }

  return ProductSurfaceAuditCliOptionsV1(
    wantsJson: wantsJson,
    rootPath: rootPath,
    familyFilter: familyFilter,
  );
}

List<_SurfaceFamilySpecV1> _selectFamiliesV1(String? familyFilter) {
  if (familyFilter == null) {
    return _kSurfaceFamiliesV1;
  }
  return _kSurfaceFamiliesV1
      .where((family) => family.cliLabel == familyFilter)
      .toList(growable: false);
}

List<ProductSurfaceAuditFindingV1> _scanSurfaceFamilyV1(
  _SurfaceFamilySpecV1 family, {
  required String rootPath,
}) {
  final findings = <ProductSurfaceAuditFindingV1>[];

  final ownerPresence = <String, bool>{
    for (final path in family.ownerPaths)
      path: File(_joinRootV1(rootPath, path)).existsSync(),
  };
  final testPresence = <String, bool>{
    for (final path in family.requiredTestPaths)
      path: File(_joinRootV1(rootPath, path)).existsSync(),
  };

  for (final entry in ownerPresence.entries) {
    if (entry.value) {
      continue;
    }
    findings.add(
      ProductSurfaceAuditFindingV1(
        reasonCode: 'missing_owner_seam',
        family: family.id,
        severity: ProductSurfaceAuditSeverityV1.p0,
        failureClass: family.missingOwnerFailureClass,
        fixStrategy: family.defaultFixStrategy,
        message: '${family.displayName} is missing owner seam ${entry.key}.',
        evidencePaths: <String>[entry.key],
        firstUserSpine: family.firstUserSpine,
        worldIds: family.worldIds,
      ),
    );
  }

  for (final entry in testPresence.entries) {
    if (entry.value) {
      continue;
    }
    findings.add(
      ProductSurfaceAuditFindingV1(
        reasonCode: 'missing_required_test_seam',
        family: family.id,
        severity: ProductSurfaceAuditSeverityV1.p1,
        failureClass: _missingRequiredTestFailureClassV1(family.id),
        fixStrategy: _missingRequiredTestFixStrategyV1(family.id),
        message:
            '${family.displayName} is missing required test seam ${entry.key}.',
        evidencePaths: <String>[entry.key],
        firstUserSpine: family.firstUserSpine,
        worldIds: family.worldIds,
      ),
    );
  }

  final presentOwnerPaths = ownerPresence.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList(growable: false);
  final presentTestPaths = testPresence.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList(growable: false);

  if (presentOwnerPaths.isEmpty || presentTestPaths.isEmpty) {
    findings.add(
      ProductSurfaceAuditFindingV1(
        reasonCode: 'surface_family_truth_mismatch',
        family: family.id,
        severity: family.id == 'first_user_intro_trust_primer'
            ? ProductSurfaceAuditSeverityV1.p0
            : ProductSurfaceAuditSeverityV1.p1,
        failureClass: _surfaceTruthMismatchFailureClassV1(family.id),
        fixStrategy: family.defaultFixStrategy,
        message:
            '${family.displayName} is governed but owner/test seams are incomplete.',
        evidencePaths: <String>[
          ...family.ownerPaths,
          ...family.requiredTestPaths,
        ],
        firstUserSpine: family.firstUserSpine,
        worldIds: family.worldIds,
      ),
    );
  }

  if (family.id == 'first_user_intro_trust_primer') {
    final hasOwner = presentOwnerPaths.isNotEmpty;
    final hasTest = presentTestPaths.isNotEmpty;
    if (!hasOwner || !hasTest) {
      findings.add(
        ProductSurfaceAuditFindingV1(
          reasonCode: 'first_user_intro_missing_from_spine',
          family: family.id,
          severity: !hasOwner && !hasTest
              ? ProductSurfaceAuditSeverityV1.p0
              : ProductSurfaceAuditSeverityV1.p1,
          failureClass: 'intro_onboarding_absence',
          fixStrategy: !hasOwner ? 'source fix' : 'copy fix',
          message:
              'First-user spine lacks complete intro / trust-primer support.',
          evidencePaths: <String>[
            ...family.ownerPaths,
            ...family.requiredTestPaths,
          ],
          firstUserSpine: true,
          worldIds: family.worldIds,
        ),
      );
    }
  }

  for (final expectation in family.futureExpectations) {
    final indicatorPresence = expectation.indicatorPaths.any(
      (path) => File(_joinRootV1(rootPath, path)).existsSync(),
    );
    if (indicatorPresence) {
      continue;
    }
    findings.add(
      ProductSurfaceAuditFindingV1(
        reasonCode: _isRenderedTextSafetyExpectationLabelV1(expectation.label)
            ? 'missing_rendered_text_safety_seam'
            : 'missing_future_audit_expectation',
        family: family.id,
        severity:
            expectation.protectsCriticalText &&
                _kHighRiskCriticalFamiliesV1.contains(family.id)
            ? ProductSurfaceAuditSeverityV1.p1
            : ProductSurfaceAuditSeverityV1.p2,
        failureClass: _isRenderedTextSafetyExpectationLabelV1(expectation.label)
            ? 'missing_rendered_text_safety_seam'
            : _futureExpectationFailureClassV1(expectation.label, family.id),
        fixStrategy: expectation.fixStrategy,
        message:
            '${family.displayName} has no repo seam for ${expectation.label}.',
        evidencePaths: expectation.indicatorPaths.isEmpty
            ? <String>['(missing expected seam)']
            : expectation.indicatorPaths,
        firstUserSpine: family.firstUserSpine,
        worldIds: family.worldIds,
      ),
    );
  }

  final hasCriticalProtection = family.futureExpectations
      .where((expectation) => expectation.protectsCriticalText)
      .any(
        (expectation) => expectation.indicatorPaths.any(
          (path) => File(_joinRootV1(rootPath, path)).existsSync(),
        ),
      );
  if (!hasCriticalProtection) {
    findings.add(
      ProductSurfaceAuditFindingV1(
        reasonCode: 'critical_text_visibility_protection_missing',
        family: family.id,
        severity: _kHighRiskCriticalFamiliesV1.contains(family.id)
            ? ProductSurfaceAuditSeverityV1.p1
            : ProductSurfaceAuditSeverityV1.p2,
        failureClass: _criticalProtectionFailureClassV1(family.id),
        fixStrategy: _criticalProtectionFixStrategyV1(family.id),
        message:
            '${family.displayName} has no concrete seam protecting learner-critical text visibility.',
        evidencePaths: family.futureExpectations
            .expand((expectation) => expectation.indicatorPaths)
            .toSet()
            .toList(growable: false),
        firstUserSpine: family.firstUserSpine,
        worldIds: family.worldIds,
      ),
    );
  }

  final hasDegradedCoverage = family.degradedStateIndicatorPaths.any(
    (path) => File(_joinRootV1(rootPath, path)).existsSync(),
  );
  if (!hasDegradedCoverage) {
    findings.add(
      ProductSurfaceAuditFindingV1(
        reasonCode: 'degraded_state_coverage_gap',
        family: family.id,
        severity: ProductSurfaceAuditSeverityV1.p1,
        failureClass: 'degraded_fallback_state_problem',
        fixStrategy: 'state mapping fix',
        message:
            '${family.displayName} has no explicit degraded / fallback coverage seam.',
        evidencePaths: family.degradedStateIndicatorPaths,
        firstUserSpine: family.firstUserSpine,
        worldIds: family.worldIds,
      ),
    );
  }

  if (family.id == 'result_next_step_surface' && presentOwnerPaths.isNotEmpty) {
    final ownerFile = File(_joinRootV1(rootPath, presentOwnerPaths.first));
    final contents = ownerFile.readAsStringSync();
    final missingAnchors = family.resultAnchors
        .where((anchor) => !contents.contains(anchor))
        .toList(growable: false);
    if (missingAnchors.isNotEmpty) {
      findings.add(
        ProductSurfaceAuditFindingV1(
          reasonCode: 'result_closure_structure_missing',
          family: family.id,
          severity: ProductSurfaceAuditSeverityV1.p1,
          failureClass: 'result_payoff_problem',
          fixStrategy: 'copy fix',
          message:
              '${family.displayName} is missing result closure anchors: ${missingAnchors.join(', ')}.',
          evidencePaths: <String>[presentOwnerPaths.first],
          firstUserSpine: family.firstUserSpine,
          worldIds: family.worldIds,
        ),
      );
    }
  }

  if (family.id == 'premium_trial_access_state_surface') {
    final hasPremiumOwner =
        ownerPresence['lib/services/premium_service.dart'] == true;
    final hasPremiumTests = presentTestPaths.any(
      (path) =>
          path.contains('premium_hub_access_state') ||
          path.contains('premium_restore_flow'),
    );
    if (!hasPremiumOwner || !hasPremiumTests) {
      findings.add(
        ProductSurfaceAuditFindingV1(
          reasonCode: 'premium_access_truth_gap',
          family: family.id,
          severity: ProductSurfaceAuditSeverityV1.p1,
          failureClass: 'premium_access_state_problem',
          fixStrategy: 'state mapping fix',
          message:
              '${family.displayName} lacks complete premium access-state ownership or coverage.',
          evidencePaths: <String>[
            'lib/services/premium_service.dart',
            'test/ui_v2/premium_hub_access_state_v1_test.dart',
            'test/services/premium_restore_flow_v1_test.dart',
          ],
          firstUserSpine: family.firstUserSpine,
          worldIds: family.worldIds,
        ),
      );
    }
  }

  for (final ownerPath in presentOwnerPaths) {
    findings.addAll(
      _scanInternalTokenLeakageCandidatesV1(
        family,
        ownerPath: ownerPath,
        rootPath: rootPath,
      ),
    );
  }

  findings.addAll(_scanRouteFeedbackSignalsV1(family, rootPath: rootPath));

  return findings;
}

Iterable<ProductSurfaceAuditFindingV1> _scanRouteFeedbackSignalsV1(
  _SurfaceFamilySpecV1 family, {
  required String rootPath,
}) sync* {
  for (final rule in _kRouteFeedbackSignalRulesV1) {
    if (rule.familyId != family.id) {
      continue;
    }
    final file = File(_joinRootV1(rootPath, rule.evidencePath));
    if (!file.existsSync()) {
      continue;
    }
    final contents = file.readAsStringSync();
    final hasRequiredSubstrings = rule.requiredSubstrings.every(
      contents.contains,
    );
    final hasAnyOfSubstring =
        rule.anyOfSubstrings.isEmpty ||
        rule.anyOfSubstrings.any(contents.contains);
    if (!hasRequiredSubstrings || !hasAnyOfSubstring) {
      continue;
    }
    yield ProductSurfaceAuditFindingV1(
      reasonCode: rule.reasonCode,
      family: family.id,
      severity: rule.severity,
      failureClass: rule.failureClass,
      fixStrategy: rule.fixStrategy,
      message: rule.message,
      evidencePaths: <String>[rule.evidencePath],
      firstUserSpine: family.firstUserSpine,
      worldIds: family.worldIds,
    );
  }
}

Iterable<ProductSurfaceAuditFindingV1> _scanInternalTokenLeakageCandidatesV1(
  _SurfaceFamilySpecV1 family, {
  required String ownerPath,
  required String rootPath,
}) sync* {
  final file = File(_joinRootV1(rootPath, ownerPath));
  if (!file.existsSync()) {
    return;
  }

  final contents = file.readAsStringSync();
  final seenMessages = <String>{};
  for (final match in _kStringLiteralPatternV1.allMatches(contents)) {
    final literal = (match.group(1) ?? match.group(2) ?? '').trim();
    if (!_looksLearnerFacingLiteralV1(literal)) {
      continue;
    }
    final lower = literal.toLowerCase();
    if (!_looksSuspiciousInternalLiteralV1(lower)) {
      continue;
    }
    final message =
        '${family.displayName} may leak internal learner-facing token: "$literal".';
    if (!seenMessages.add(message)) {
      continue;
    }
    yield ProductSurfaceAuditFindingV1(
      reasonCode: 'internal_token_leakage_candidate',
      family: family.id,
      severity: _kP1InternalLeakFamiliesV1.contains(family.id)
          ? ProductSurfaceAuditSeverityV1.p1
          : ProductSurfaceAuditSeverityV1.p2,
      failureClass: family.internalTokenFailureClass,
      fixStrategy: 'copy fix',
      message: message,
      evidencePaths: <String>[ownerPath],
      firstUserSpine: family.firstUserSpine,
      worldIds: family.worldIds,
    );
  }
}

ProductSurfaceAuditSummaryV1 _buildSummaryV1(
  List<ProductSurfaceAuditFindingV1> findings, {
  required List<_SurfaceFamilySpecV1> inspectedFamilies,
}) {
  final familyCounts = <String, int>{
    for (final family in inspectedFamilies) family.id: 0,
  };
  final severityCounts = <String, int>{
    for (final severity in ProductSurfaceAuditSeverityV1.values)
      severity.label: 0,
  };
  final failureClassCounts = <String, int>{};
  final fixStrategyCounts = <String, int>{};
  final firstUserSpineFamilyCounts = <String, int>{
    for (final family in inspectedFamilies.where(
      (family) => family.firstUserSpine,
    ))
      family.id: 0,
  };
  var firstUserSpineTotal = 0;

  for (final finding in findings) {
    familyCounts.update(
      finding.family,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    severityCounts.update(
      finding.severity.label,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    failureClassCounts.update(
      finding.failureClass,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    fixStrategyCounts.update(
      finding.fixStrategy,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
    if (finding.firstUserSpine) {
      firstUserSpineTotal++;
      firstUserSpineFamilyCounts.update(
        finding.family,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
  }

  final clusterCounts = <String, int>{};
  final clusterSeeds = <String, ProductSurfaceAuditTopClusterV1>{};
  for (final finding in findings) {
    if (finding.severity == ProductSurfaceAuditSeverityV1.p2) {
      continue;
    }
    final key =
        '${finding.family}|${finding.severity.label}|${finding.failureClass}|${finding.fixStrategy}';
    clusterCounts.update(key, (count) => count + 1, ifAbsent: () => 1);
    clusterSeeds.putIfAbsent(
      key,
      () => ProductSurfaceAuditTopClusterV1(
        family: finding.family,
        severity: finding.severity,
        failureClass: finding.failureClass,
        fixStrategy: finding.fixStrategy,
        count: 0,
      ),
    );
  }

  final topClusters =
      clusterCounts.entries
          .map((entry) {
            final seed = clusterSeeds[entry.key]!;
            return ProductSurfaceAuditTopClusterV1(
              family: seed.family,
              severity: seed.severity,
              failureClass: seed.failureClass,
              fixStrategy: seed.fixStrategy,
              count: entry.value,
            );
          })
          .toList(growable: false)
        ..sort((a, b) {
          final severityCompare = b.severity.rank.compareTo(a.severity.rank);
          if (severityCompare != 0) {
            return severityCompare;
          }
          final countCompare = b.count.compareTo(a.count);
          if (countCompare != 0) {
            return countCompare;
          }
          final familyCompare = a.family.compareTo(b.family);
          if (familyCompare != 0) {
            return familyCompare;
          }
          return a.failureClass.compareTo(b.failureClass);
        });

  return ProductSurfaceAuditSummaryV1(
    totalIssues: findings.length,
    familyCounts: familyCounts,
    severityCounts: severityCounts,
    failureClassCounts: failureClassCounts,
    fixStrategyCounts: fixStrategyCounts,
    firstUserSpineTotal: firstUserSpineTotal,
    firstUserSpineFamilyCounts: firstUserSpineFamilyCounts,
    topClusters: topClusters.take(5).toList(growable: false),
  );
}

bool _looksLearnerFacingLiteralV1(String literal) {
  if (literal.isEmpty || literal.length < 4) {
    return false;
  }
  if (literal.contains('package:') ||
      literal.contains('assets/') ||
      literal.contains('/') ||
      literal.contains(r'$')) {
    return false;
  }
  if (_kSimpleStructuralLiteralV1.hasMatch(literal)) {
    return false;
  }
  return literal.contains(' ') || RegExp(r'[A-Z]').hasMatch(literal);
}

bool _looksSuspiciousInternalLiteralV1(String lowerLiteral) {
  if (_kInternalWorldTokenV1.hasMatch(lowerLiteral) ||
      _kInternalWorldLabelV1.hasMatch(lowerLiteral) ||
      _kInternalVersionTokenV1.hasMatch(lowerLiteral) ||
      _kInternalAnchorTokenV1.hasMatch(lowerLiteral)) {
    return true;
  }
  if (lowerLiteral.contains('topology')) {
    return true;
  }
  if (lowerLiteral.contains('seat ') &&
      (lowerLiteral.contains('bb') ||
          lowerLiteral.contains('sb') ||
          lowerLiteral.contains('utg'))) {
    return true;
  }
  return _kInternalTopologyTokenV1.hasMatch(lowerLiteral) &&
      lowerLiteral.contains('tap');
}

bool _isRenderedTextSafetyExpectationLabelV1(String label) {
  return label.contains('non_overlap') ||
      label.contains('safe_zone') ||
      label.contains('safe_area') ||
      label.contains('text_fit') ||
      label.contains('text_scale') ||
      label.contains('readability');
}

String _joinRootV1(String rootPath, String relativePath) {
  if (rootPath == '.' || rootPath.isEmpty) {
    return relativePath;
  }
  return '$rootPath/$relativePath';
}

void _writeCountsV1(
  StringBuffer buffer,
  String heading,
  Map<String, int> counts,
) {
  buffer.writeln(heading);
  for (final entry
      in counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
    buffer.writeln('$heading\t${entry.key}\t${entry.value}');
  }
}

String _missingRequiredTestFailureClassV1(String familyId) {
  switch (familyId) {
    case 'result_next_step_surface':
      return 'result_payoff_problem';
    case 'premium_trial_access_state_surface':
      return 'premium_access_state_problem';
    case 'first_user_intro_trust_primer':
      return 'intro_onboarding_absence';
    default:
      return 'hierarchy_cta_problem';
  }
}

String _missingRequiredTestFixStrategyV1(String familyId) {
  switch (familyId) {
    case 'today_plan_intake':
      return 'state mapping fix';
    case 'runner_prompt_table_surface':
      return 'host/shell fix';
    default:
      return 'source fix';
  }
}

String _surfaceTruthMismatchFailureClassV1(String familyId) {
  switch (familyId) {
    case 'premium_trial_access_state_surface':
      return 'premium_access_state_problem';
    case 'result_next_step_surface':
      return 'result_payoff_problem';
    case 'first_user_intro_trust_primer':
      return 'intro_onboarding_absence';
    default:
      return 'source_content_problem';
  }
}

String _futureExpectationFailureClassV1(String label, String familyId) {
  if (label.contains('prompt_safe_zone')) {
    return 'prompt_safe_zone_violation';
  }
  if (label.contains('cta_safe_area')) {
    return 'cta_visibility_failure';
  }
  if (label.contains('readability')) {
    return familyId == 'result_next_step_surface'
        ? 'result_meaning_clipped'
        : 'small_screen_readability_failure';
  }
  if (label.contains('text_fit') || label.contains('text_scale')) {
    return 'small_screen_readability_failure';
  }
  if (label.contains('non_overlap')) {
    return 'critical_text_occlusion';
  }
  return 'geometry_occlusion_clipping_problem';
}

String _criticalProtectionFailureClassV1(String familyId) {
  switch (familyId) {
    case 'runner_prompt_table_surface':
      return 'prompt_safe_zone_violation';
    case 'result_next_step_surface':
      return 'result_meaning_clipped';
    case 'today_plan_intake':
    case 'premium_trial_access_state_surface':
      return 'cta_visibility_failure';
    default:
      return 'critical_text_occlusion';
  }
}

String _criticalProtectionFixStrategyV1(String familyId) {
  switch (familyId) {
    case 'runner_prompt_table_surface':
      return 'host/shell fix';
    case 'result_next_step_surface':
      return 'layout fix';
    case 'today_plan_intake':
    case 'premium_trial_access_state_surface':
      return 'layout fix';
    default:
      return 'copy fix';
  }
}

void _printUsageV1() {
  stdout.writeln(
    'Usage: dart run tools/product_surface_audit_v1.dart '
    '[--json] [--family=<today|intro|runner|result|premium>] [--root=<path>]',
  );
}

const Set<String> _kHighRiskCriticalFamiliesV1 = <String>{
  'today_plan_intake',
  'runner_prompt_table_surface',
  'result_next_step_surface',
};

const Set<String> _kP1InternalLeakFamiliesV1 = <String>{
  'today_plan_intake',
  'runner_prompt_table_surface',
  'result_next_step_surface',
  'premium_trial_access_state_surface',
};

const List<_RouteFeedbackSignalRuleV1>
_kRouteFeedbackSignalRulesV1 = <_RouteFeedbackSignalRuleV1>[
  _RouteFeedbackSignalRuleV1(
    familyId: 'runner_prompt_table_surface',
    evidencePath:
        'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
    reasonCode: 'wrong_feedback_family_mapping',
    failureClass: 'stage_inappropriate_feedback',
    severity: ProductSurfaceAuditSeverityV1.p1,
    fixStrategy: 'source fix',
    message:
        'World 1 first-user runner still maps seat-quiz runtime feedback through a generic slice.',
    requiredSubstrings: <String>[
      'slice: World1SeatQuizFeedbackSliceV1.generic',
    ],
  ),
  _RouteFeedbackSignalRuleV1(
    familyId: 'runner_prompt_table_surface',
    evidencePath: 'lib/ui_v2/runner/world1_seat_quiz_feedback_copy_v1.dart',
    reasonCode: 'legacy_feedback_leak',
    failureClass: 'legacy_feedback_leak',
    severity: ProductSurfaceAuditSeverityV1.p1,
    fixStrategy: 'copy fix',
    message:
        'World 1 seat-quiz feedback copy still exposes a generic fallback slice and generic fix line.',
    requiredSubstrings: <String>[
      'case World1SeatQuizFeedbackSliceV1.generic:',
      'Fix: Start from the seat anchor, then follow seat order.',
    ],
  ),
  _RouteFeedbackSignalRuleV1(
    familyId: 'runner_prompt_table_surface',
    evidencePath:
        'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
    reasonCode: 'legacy_feedback_leak',
    failureClass: 'legacy_feedback_leak',
    severity: ProductSurfaceAuditSeverityV1.p1,
    fixStrategy: 'copy fix',
    message:
        'World 1 first-user runner still carries bare Correct./Incorrect. runtime outcome copy.',
    requiredSubstrings: <String>["'Correct.'", "'Incorrect.'"],
  ),
  _RouteFeedbackSignalRuleV1(
    familyId: 'runner_prompt_table_surface',
    evidencePath: 'lib/ui_v2/runner/world1_hand_loop_feedback_copy_v1.dart',
    reasonCode: 'ungated_generic_outcome_copy',
    failureClass: 'ungated_generic_outcome_copy',
    severity: ProductSurfaceAuditSeverityV1.p1,
    fixStrategy: 'copy fix',
    message:
        'World 1 hand-loop feedback still falls back to generic expected-action outcome copy.',
    requiredSubstrings: <String>['expected action before you continue'],
  ),
  _RouteFeedbackSignalRuleV1(
    familyId: 'runner_prompt_table_surface',
    evidencePath: 'lib/campaign/world1_scenario_truth_pilot_v1.dart',
    reasonCode: 'ungated_legal_suboptimal_outcome_copy',
    failureClass: 'ungated_generic_outcome_copy',
    severity: ProductSurfaceAuditSeverityV1.p1,
    fixStrategy: 'copy fix',
    message:
        'World 1 early action-choice truth still uses legal-suboptimal policy verdict copy on the beginner route.',
    requiredSubstrings: <String>['Legal, but worse than our recommended play.'],
  ),
  _RouteFeedbackSignalRuleV1(
    familyId: 'runner_prompt_table_surface',
    evidencePath:
        'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
    reasonCode: 'generic_category_followup_copy',
    failureClass: 'early_world_tone_mismatch',
    severity: ProductSurfaceAuditSeverityV1.p1,
    fixStrategy: 'copy fix',
    message:
        'World 1 early runner still synthesizes generic category follow-up copy instead of beginner teaching.',
    anyOfSubstrings: <String>[
      'Category: \$categoryLabel',
      'Improve \$categoryLabel decisions next.',
    ],
  ),
  _RouteFeedbackSignalRuleV1(
    familyId: 'runner_prompt_table_surface',
    evidencePath:
        'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
    reasonCode: 'early_world_tone_mismatch',
    failureClass: 'early_world_tone_mismatch',
    severity: ProductSurfaceAuditSeverityV1.p1,
    fixStrategy: 'copy fix',
    message:
        'World 1 first-user runner still uses checkpoint-style or review-queue tone in learner-facing runtime copy.',
    anyOfSubstrings: <String>[
      'Checkpoint: review your top mistakes.',
      'Checkpoint L3:',
      'Checkpoint L6:',
    ],
  ),
];
