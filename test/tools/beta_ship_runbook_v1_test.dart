import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'beta ship runbook stays bounded under the final-readiness control plane',
    () {
      final readiness = File(
        'docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md',
      ).readAsStringSync();
      final historical = File(
        'docs/plan/TRUE_RELEASE_READINESS_SSOT_v1.md',
      ).readAsStringSync();
      final reset = File(
        'docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md',
      ).readAsStringSync();
      final ladder = File(
        'docs/plan/ROUTE_TO_B_ACTION_LADDER_v1.md',
      ).readAsStringSync();
      final runbook = File(
        'docs/plan/BETA_SHIP_RUNBOOK_CHECKLIST_v1.md',
      ).readAsStringSync();

      expect(runbook, contains('## Canonical Beta Ship Scope'));
      expect(runbook, contains('## Must-Pass Smoke Path'));
      expect(runbook, contains('## Launch Go / Hold Criteria'));
      expect(runbook, contains('## Acceptable Beta Debt'));
      expect(runbook, contains('## Deferred Post-Beta Growth Queue'));
      expect(runbook, contains('this is a bounded beta artifact'));
      expect(runbook, contains('it is not the final-product launch authority'));
      expect(runbook, isNot(contains('85/100')));
      expect(
        runbook,
        contains(
          'dart run tools/canonical_early_path_correctness_audit_v1.dart',
        ),
      );

      expect(readiness, contains('Core Product Readiness'));
      expect(
        reset,
        contains('Main-First Final-Readiness SSOT / Authority Migration'),
      );
      expect(
        ladder,
        contains(
          'Current Active Block: `Main-First Final-Readiness SSOT / Authority Migration`',
        ),
      );
      expect(historical, contains('SUPERSEDED / HISTORICAL'));
      expect(ladder, contains('## Point B'));
    },
  );
}
