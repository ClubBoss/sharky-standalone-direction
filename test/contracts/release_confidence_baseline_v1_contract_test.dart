import 'dart:io';

import 'package:test/test.dart';

import '../../tools/release_readiness_snapshot_v1.dart';

void main() {
  test(
    'release confidence baseline stays bounded, snapshot-backed, and non-governing',
    () {
      final baseline = File('docs/release/release_confidence_baseline_v1.md');
      final rules = File('docs/EXECUTION_RULES.md');
      final checklist = File(
        'docs/release/final_product_release_checklist_v1.md',
      );
      final smoke = File('docs/release/final_product_smoke_baseline_v1.md');
      final decision = File('docs/release/go_hold_rollback_truth_v1.md');
      final review = File('docs/release/release_owner_review_v1.md');
      final submission = File('docs/release/submission_metadata_truth_v1.md');

      expect(baseline.existsSync(), isTrue);
      expect(rules.existsSync(), isTrue);
      expect(checklist.existsSync(), isTrue);
      expect(smoke.existsSync(), isTrue);
      expect(decision.existsSync(), isTrue);
      expect(review.existsSync(), isTrue);
      expect(submission.existsSync(), isTrue);

      final baselineContent = baseline.readAsStringSync();

      expect(
        baselineContent,
        contains('Scope: bounded multi-surface release-confidence baseline'),
      );
      expect(baselineContent, contains('Verdict policy: not a GO verdict'));
      expect(baselineContent, contains('Current Bounded Proof On Main'));
      expect(baselineContent, contains('baselineDocPresent = true'));
      expect(baselineContent, contains('baselineDocSaysNotGo = true'));
      expect(baselineContent, contains('baselineDocSaysBoundedScope = true'));
      expect(baselineContent, contains('goNoGoStateIsHold = true'));
      expect(baselineContent, contains('docs/EXECUTION_RULES.md'));
      expect(
        baselineContent,
        contains('docs/release/final_product_release_checklist_v1.md'),
      );
      expect(
        baselineContent,
        contains('docs/release/final_product_smoke_baseline_v1.md'),
      );
      expect(
        baselineContent,
        contains('docs/release/go_hold_rollback_truth_v1.md'),
      );
      expect(
        baselineContent,
        contains('docs/release/release_owner_review_v1.md'),
      );
      expect(
        baselineContent,
        contains('docs/release/submission_metadata_truth_v1.md'),
      );
      expect(
        baselineContent,
        contains(
          'This owner records the bounded release-confidence baseline only.',
        ),
      );
      expect(
        baselineContent,
        contains('moduleLauncherBoundaryContractPresent = true'),
      );
      expect(
        baselineContent,
        contains('widens proof beyond the older bounded beta slice'),
      );
      expect(
        baselineContent,
        contains('This owner does not claim release completion.'),
      );
      expect(baselineContent, contains('This owner does not claim GO.'));
      expect(
        baselineContent,
        contains('This owner does not claim whole-product machine clearance.'),
      );

      final snapshot = buildReleaseReadinessSnapshot();
      expect(snapshot['baselineDocPresent'], isTrue);
      expect(snapshot['baselineDocSaysNotGo'], isTrue);
      expect(snapshot['baselineDocSaysBoundedScope'], isTrue);
      expect(snapshot['goNoGoStateIsHold'], isTrue);
      expect(snapshot['fullProductChecklistPresent'], isTrue);
      expect(snapshot['boundedSmokeBaselinePresent'], isTrue);
      expect(snapshot['humanReviewOwnerPresent'], isTrue);
      expect(snapshot['moduleLauncherBoundaryContractPresent'], isTrue);
    },
  );
}
