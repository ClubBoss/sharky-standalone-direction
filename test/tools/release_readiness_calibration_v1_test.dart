import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active readiness authority chain points to the project readiness ssot', () {
    const activeFiles = <String>[
      'AGENTS.md',
      'docs/README_SSOT.md',
      'docs/README.md',
      'docs/reference/README.md',
      'docs/plan/MASTER_PLAN_v2.2.md',
      'docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md',
      'docs/plan/ROUTE_TO_B_ACTION_LADDER_v1.md',
      'docs/plan/BETA_SHIP_RUNBOOK_CHECKLIST_v1.md',
      'docs/ROADMAP_FINAL_100_SSOT.md',
      'docs/EXECUTION_RULES.md',
      'docs/governance/EXECUTION_GOVERNANCE_HISTORY.md',
    ];

    for (final path in activeFiles) {
      final content = File(path).readAsStringSync();
      expect(
        content,
        contains('docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md'),
        reason: '$path still misses the active readiness authority pointer',
      );
    }

    final historical = File(
      'docs/plan/TRUE_RELEASE_READINESS_SSOT_v1.md',
    ).readAsStringSync();
    expect(historical, contains('SUPERSEDED / HISTORICAL'));
    expect(
      historical,
      contains('docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md'),
    );
    expect(
      historical,
      isNot(
        contains('This document defines the only valid meaning of release readiness for the product.'),
      ),
    );
  });
}
