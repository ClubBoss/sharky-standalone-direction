import 'dart:io';

import 'package:test/test.dart';

import '../../tools/release_readiness_snapshot_v1.dart';

void main() {
  test(
    'rollback ownership truth stays explicitly owned, unresolved, and snapshot-backed',
    () {
      final rollbackOwner = File('docs/release/rollback_ownership_truth_v1.md');
      final decisionTruth = File('docs/release/go_hold_rollback_truth_v1.md');
      final humanReviewOwner = File('docs/release/release_owner_review_v1.md');

      expect(rollbackOwner.existsSync(), isTrue);
      expect(decisionTruth.existsSync(), isTrue);
      expect(humanReviewOwner.existsSync(), isTrue);

      final rollbackContent = rollbackOwner.readAsStringSync();
      final decisionContent = decisionTruth.readAsStringSync();
      final humanReviewContent = humanReviewOwner.readAsStringSync();

      expect(rollbackContent, contains('Current state: UNRESOLVED_BUT_OWNED'));
      expect(
        rollbackContent,
        contains('docs/release/release_owner_review_v1.md'),
      );
      expect(
        rollbackContent,
        contains('docs/release/go_hold_rollback_truth_v1.md'),
      );
      expect(rollbackContent, contains('rollback trigger'));
      expect(rollbackContent, contains('rollback operator / owner'));
      expect(rollbackContent, contains('rollback target or build reference'));
      expect(rollbackContent, contains('verification steps after rollback'));
      expect(
        rollbackContent,
        contains(
          'This is ownership truth only, not proof of a finished rollback runbook',
        ),
      );

      expect(decisionContent, contains('Current state: HOLD'));
      expect(
        decisionContent,
        contains(
          'No active artifact currently proves a finalized production rollback runbook',
        ),
      );
      expect(
        decisionContent,
        contains('docs/release/rollback_ownership_truth_v1.md'),
      );

      expect(
        humanReviewContent,
        contains('Current state: PENDING_HUMAN_REVIEW'),
      );
      expect(
        humanReviewContent,
        contains('Verify the current HOLD/rollback truth remains honest'),
      );

      final snapshot = buildReleaseReadinessSnapshot();
      expect(snapshot['goNoGoStateIsHold'], isTrue);
      expect(snapshot['rollbackTruthSaysUnresolved'], isTrue);
      expect(snapshot['rollbackOwnershipOwnerPresent'], isTrue);
      expect(snapshot['rollbackOwnershipSaysUnresolvedButOwned'], isTrue);
      expect(snapshot['humanReviewOwnerPresent'], isTrue);
      expect(snapshot['humanReviewStatePending'], isTrue);
    },
  );
}
