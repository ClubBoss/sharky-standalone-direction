import 'dart:io';

import 'package:test/test.dart';

import '../../tools/release_readiness_snapshot_v1.dart';

void main() {
  test(
    'release owner review truth stays pending, snapshot-backed, and non-governing',
    () {
      final reviewOwner = File('docs/release/release_owner_review_v1.md');
      final decisionTruth = File('docs/release/go_hold_rollback_truth_v1.md');
      final baseline = File('docs/release/release_confidence_baseline_v1.md');
      final checklist = File(
        'docs/release/final_product_release_checklist_v1.md',
      );

      expect(reviewOwner.existsSync(), isTrue);
      expect(decisionTruth.existsSync(), isTrue);
      expect(baseline.existsSync(), isTrue);
      expect(checklist.existsSync(), isTrue);

      final reviewContent = reviewOwner.readAsStringSync();
      final decisionContent = decisionTruth.readAsStringSync();

      expect(reviewContent, contains('Current state: PENDING_HUMAN_REVIEW'));
      expect(
        reviewContent,
        contains('docs/release/go_hold_rollback_truth_v1.md'),
      );
      expect(
        reviewContent,
        contains('docs/release/release_confidence_baseline_v1.md'),
      );
      expect(
        reviewContent,
        contains('docs/release/final_product_release_checklist_v1.md'),
      );
      expect(
        reviewContent,
        contains('docs/release/final_product_smoke_baseline_v1.md'),
      );
      expect(
        reviewContent,
        contains('docs/release/submission_metadata_truth_v1.md'),
      );
      expect(reviewContent, contains('humanReviewOwnerPresent = true'));
      expect(reviewContent, contains('humanReviewStatePending = true'));
      expect(reviewContent, contains('goNoGoStateIsHold = true'));
      expect(
        reviewContent,
        contains('This owner records the required human review surface only'),
      );
      expect(reviewContent, contains('that human review has completed'));
      expect(
        reviewContent,
        contains(
          'If a release-confidence surface implies human review is complete',
        ),
      );

      expect(decisionContent, contains('Current state: HOLD'));
      expect(
        decisionContent,
        contains('docs/release/release_owner_review_v1.md'),
      );

      final snapshot = buildReleaseReadinessSnapshot();
      expect(snapshot['humanReviewOwnerPresent'], isTrue);
      expect(snapshot['humanReviewStatePending'], isTrue);
      expect(snapshot['goNoGoStateIsHold'], isTrue);
      expect(snapshot['baselineDocPresent'], isTrue);
      expect(snapshot['fullProductChecklistPresent'], isTrue);
    },
  );
}
