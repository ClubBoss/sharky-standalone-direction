import 'dart:io';

import 'package:test/test.dart';

import '../../tools/release_readiness_snapshot_v1.dart';

void main() {
  test(
    'final product smoke baseline stays bounded, snapshot-backed, and non-governing',
    () {
      final smokeOwner = File(
        'docs/release/final_product_smoke_baseline_v1.md',
      );
      final decisionTruth = File('docs/release/go_hold_rollback_truth_v1.md');
      final smokeRunner = File('tool/release_smoke_baseline_v1.sh');

      expect(smokeOwner.existsSync(), isTrue);
      expect(decisionTruth.existsSync(), isTrue);
      expect(smokeRunner.existsSync(), isTrue);

      final smokeContent = smokeOwner.readAsStringSync();
      final decisionContent = decisionTruth.readAsStringSync();

      expect(
        smokeContent,
        contains('does not claim complete full-product smoke coverage'),
      );
      expect(smokeContent, contains('tool/release_smoke_baseline_v1.sh'));
      expect(
        smokeContent,
        contains('test/guards/app_boot_release_smoke_test.dart'),
      );
      expect(
        smokeContent,
        contains('test/ui_v2/onboarding_first_win_test.dart'),
      );
      expect(
        smokeContent,
        contains('test/guards/world1_app_root_startup_contract_test.dart'),
      );
      expect(
        smokeContent,
        contains(
          'test/ui_v2/session_result_world1_onboarding_payoff_test.dart',
        ),
      );
      expect(
        smokeContent,
        contains('test/ui_v2/premium_hub_access_state_v1_test.dart'),
      );
      expect(
        smokeContent,
        contains(
          'test/guards/module_launcher_legacy_bridge_boundary_contract_test.dart',
        ),
      );
      expect(smokeContent, contains('test/ui_v2/legal_screen_v1_test.dart'));
      expect(smokeContent, contains('boundedSmokeBaselinePresent = true'));
      expect(
        smokeContent,
        contains('boundedSmokeBaselineSaysNotFullCoverage = true'),
      );
      expect(smokeContent, contains('fullProductSmokePathPresent = true'));
      expect(smokeContent, contains('goNoGoStateIsHold = true'));
      expect(
        smokeContent,
        contains('moduleLauncherBoundaryContractPresent = true'),
      );
      expect(
        smokeContent,
        contains('This owner records bounded smoke coverage only'),
      );
      expect(smokeContent, contains('does not prove full-product'));
      expect(smokeContent, contains('smoke closure'));
      expect(smokeContent, contains('## Bounded Widening On Current Main'));

      expect(decisionContent, contains('Current state: HOLD'));
      expect(
        decisionContent,
        contains('docs/release/final_product_smoke_baseline_v1.md'),
      );

      final snapshot = buildReleaseReadinessSnapshot();
      expect(snapshot['boundedSmokeBaselinePresent'], isTrue);
      expect(snapshot['boundedSmokeBaselineSaysNotFullCoverage'], isTrue);
      expect(snapshot['fullProductSmokePathPresent'], isTrue);
      expect(snapshot['goNoGoStateIsHold'], isTrue);
      expect(snapshot['moduleLauncherBoundaryContractPresent'], isTrue);
    },
  );
}
