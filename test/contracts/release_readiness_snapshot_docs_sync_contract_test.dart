import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('release readiness snapshot documented', () {
    final rules = File('docs/EXECUTION_RULES.md');
    final baseline = File('docs/release/release_confidence_baseline_v1.md');
    final checklist = File(
      'docs/release/final_product_release_checklist_v1.md',
    );
    final smokeBaseline = File(
      'docs/release/final_product_smoke_baseline_v1.md',
    );
    final decisionTruth = File('docs/release/go_hold_rollback_truth_v1.md');
    final humanReviewOwner = File('docs/release/release_owner_review_v1.md');
    final rollbackOwnershipOwner = File(
      'docs/release/rollback_ownership_truth_v1.md',
    );
    final operationalBaseline = File(
      'docs/release/operational_confidence_baseline_v1.md',
    );
    final operationalPacketOwner = File(
      'docs/release/operational_review_packet_truth_v1.md',
    );
    final releaseReadme = File('docs/release/RELEASE_README.md');
    final smokeRunner = File('tool/release_smoke_baseline_v1.sh');
    if (!rules.existsSync()) {
      fail('Missing docs/EXECUTION_RULES.md');
    }
    final content = rules.readAsStringSync();
    final snapshotPath = 'tools/release_readiness_snapshot_v1.dart';
    final command = 'dart run tools/release_readiness_snapshot_v1.dart';
    final baselinePath = 'docs/release/release_confidence_baseline_v1.md';
    final checklistPath = 'docs/release/final_product_release_checklist_v1.md';
    final smokeBaselinePath = 'docs/release/final_product_smoke_baseline_v1.md';
    final decisionPath = 'docs/release/go_hold_rollback_truth_v1.md';
    final humanReviewPath = 'docs/release/release_owner_review_v1.md';
    final rollbackOwnershipPath = 'docs/release/rollback_ownership_truth_v1.md';
    final operationalBaselinePath =
        'docs/release/operational_confidence_baseline_v1.md';
    final operationalPacketOwnerPath =
        'docs/release/operational_review_packet_truth_v1.md';
    final smokeRunnerPath = 'tool/release_smoke_baseline_v1.sh';
    final missing = <String>[];
    if (!content.contains(snapshotPath)) {
      missing.add('missing snapshot path "$snapshotPath"');
    }
    if (!content.contains(command)) {
      missing.add('missing command "$command"');
    }
    if (!content.contains(baselinePath)) {
      missing.add('missing baseline path "$baselinePath"');
    }
    if (!content.contains(checklistPath)) {
      missing.add('missing checklist path "$checklistPath"');
    }
    if (!content.contains(smokeBaselinePath)) {
      missing.add('missing smoke baseline path "$smokeBaselinePath"');
    }
    if (!content.contains(decisionPath)) {
      missing.add('missing decision path "$decisionPath"');
    }
    if (!content.contains(humanReviewPath)) {
      missing.add('missing human review path "$humanReviewPath"');
    }
    if (!content.contains(rollbackOwnershipPath)) {
      missing.add('missing rollback ownership path "$rollbackOwnershipPath"');
    }
    if (!content.contains(operationalBaselinePath)) {
      missing.add(
        'missing operational baseline path "$operationalBaselinePath"',
      );
    }
    if (!content.contains(operationalPacketOwnerPath)) {
      missing.add(
        'missing operational review packet owner path "$operationalPacketOwnerPath"',
      );
    }
    if (!content.contains(smokeRunnerPath)) {
      missing.add('missing smoke runner path "$smokeRunnerPath"');
    }
    if (!content.contains('not a GO verdict')) {
      missing.add('missing not-a-GO note in docs/EXECUTION_RULES.md');
    }
    if (!content.contains('The active runtime gate remains')) {
      missing.add(
        'missing bounded runtime gate note in docs/EXECUTION_RULES.md',
      );
    }
    final snapshotFile = File(snapshotPath);
    if (!snapshotFile.existsSync()) {
      missing.add('snapshot file not found at $snapshotPath');
    }
    if (!baseline.existsSync()) {
      missing.add('baseline file not found at $baselinePath');
    }
    if (!checklist.existsSync()) {
      missing.add('checklist file not found at $checklistPath');
    }
    if (!smokeBaseline.existsSync()) {
      missing.add('smoke baseline file not found at $smokeBaselinePath');
    }
    if (!decisionTruth.existsSync()) {
      missing.add('decision file not found at $decisionPath');
    }
    if (!humanReviewOwner.existsSync()) {
      missing.add('human review owner not found at $humanReviewPath');
    }
    if (!rollbackOwnershipOwner.existsSync()) {
      missing.add(
        'rollback ownership owner not found at $rollbackOwnershipPath',
      );
    }
    if (!operationalBaseline.existsSync()) {
      missing.add(
        'operational baseline file not found at $operationalBaselinePath',
      );
    }
    if (!operationalPacketOwner.existsSync()) {
      missing.add(
        'operational review packet owner not found at $operationalPacketOwnerPath',
      );
    }
    if (!releaseReadme.existsSync()) {
      missing.add(
        'release readme file not found at docs/release/RELEASE_README.md',
      );
    } else if (!releaseReadme.readAsStringSync().contains(
      'Status: HISTORICAL SNAPSHOT / NOT ACTIVE OPS OWNER',
    )) {
      missing.add('release readme is not marked historical-only');
    }
    if (!smokeRunner.existsSync()) {
      missing.add('smoke runner not found at $smokeRunnerPath');
    }
    if (missing.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln('Release readiness snapshot doc sync failed:')
        ..writeln(missing.map((line) => '- $line').join('\n'));
      fail(buffer.toString());
    }
  });
}
