import 'dart:io';

import 'package:test/test.dart';

import '../../tools/release_readiness_snapshot_v1.dart';

void main() {
  test(
    'final product release checklist stays bounded, snapshot-backed, and non-governing',
    () {
      final checklistOwner = File(
        'docs/release/final_product_release_checklist_v1.md',
      );
      final decisionTruth = File('docs/release/go_hold_rollback_truth_v1.md');
      final smokeOwner = File(
        'docs/release/final_product_smoke_baseline_v1.md',
      );

      expect(checklistOwner.existsSync(), isTrue);
      expect(decisionTruth.existsSync(), isTrue);
      expect(smokeOwner.existsSync(), isTrue);

      final checklistContent = checklistOwner.readAsStringSync();
      final decisionContent = decisionTruth.readAsStringSync();

      expect(
        checklistContent,
        contains('current-main full-product release checklist'),
      );
      expect(checklistContent, contains('It is not a GO verdict'));
      expect(checklistContent, contains('fullProductChecklistPresent = true'));
      expect(
        checklistContent,
        contains('fullProductChecklistSaysCurrentMain = true'),
      );
      expect(
        checklistContent,
        contains('fullProductChecklistSaysNotGo = true'),
      );
      expect(checklistContent, contains('goNoGoStateIsHold = true'));
      expect(checklistContent, contains('tool/release_dry_run_gate.sh'));
      expect(checklistContent, contains('tools/release_gate_world1.sh'));
      expect(checklistContent, contains('tool/release_smoke_baseline_v1.sh'));
      expect(
        checklistContent,
        contains('test/guards/app_boot_release_smoke_test.dart'),
      );
      expect(
        checklistContent,
        contains(
          'test/ui_v2/session_result_world1_onboarding_payoff_test.dart',
        ),
      );
      expect(
        checklistContent,
        contains(
          'test/guards/module_launcher_legacy_bridge_boundary_contract_test.dart',
        ),
      );
      expect(
        checklistContent,
        contains('test/ui_v2/legal_screen_v1_test.dart'),
      );
      expect(
        checklistContent,
        contains('This owner records current-main checklist truth only'),
      );
      expect(checklistContent, contains('it does not prove final'));
      expect(
        checklistContent,
        contains('release completion or whole-product machine clearance'),
      );
      expect(
        checklistContent,
        contains('## What This Widens Beyond The Older Bounded Beta Slice'),
      );
      expect(
        checklistContent,
        contains('moduleLauncherBoundaryContractPresent = true'),
      );

      expect(decisionContent, contains('Current state: HOLD'));
      expect(
        decisionContent,
        contains('docs/release/final_product_release_checklist_v1.md'),
      );

      final snapshot = buildReleaseReadinessSnapshot();
      expect(snapshot['fullProductChecklistPresent'], isTrue);
      expect(snapshot['fullProductChecklistSaysCurrentMain'], isTrue);
      expect(snapshot['fullProductChecklistSaysNotGo'], isTrue);
      expect(snapshot['goNoGoStateIsHold'], isTrue);
      expect(snapshot['moduleLauncherBoundaryContractPresent'], isTrue);
    },
  );
}
