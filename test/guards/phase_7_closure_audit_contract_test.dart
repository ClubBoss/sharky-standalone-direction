import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const reviewPath = 'docs/_reviews/phase_7_closure_audit_v1.md';
  const activeRouteCapsulePath = 'docs/context/ACTIVE_ROUTE_CAPSULE_v1.md';
  const learningRepairCapsulePath =
      'docs/context/LEARNING_REPAIR_CAPSULE_v1.md';
  const targetedRepairPath = 'docs/_reviews/targeted_content_repairs_v1.md';
  const campaignPlanPath =
      'docs/plan/PRE_HUMAN_AND_HUMAN_PROVEN_CAMPAIGN_v1.md';
  const campaignStatePath = 'docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md';

  test('Phase 7 closure audit records final route-safe disposition', () {
    final reviewFile = File(reviewPath);
    expect(reviewFile.existsSync(), isTrue);
    final review = reviewFile.readAsStringSync();

    expect(review, contains('phase_7_closed_with_explicit_deferrals'));
    expect(review, contains('close_phase_7'));
    expect(review, contains('Motion Direction System v1'));
    expect(review, contains('unresolved actionable P1-P4: 0'));
    expect(review, contains('fixed: 7'));
    expect(review, contains('accepted: 3'));
    expect(review, contains('deferred: 1'));
    expect(review, contains('pre_existing_stale_harness'));
    expect(review, contains('unrelated_tooling_debt'));
    expect(review, contains('hygiene_backlog_candidate'));
    expect(review, isNot(contains('active_closure_blocker')));
  });

  test('PC and SLCR ledgers have complete final dispositions', () {
    final review = File(reviewPath).readAsStringSync();

    for (final id in <String>[
      'PC-001',
      'PC-002',
      'PC-003',
      'PC-004',
      'PC-005',
      'PC-006',
      'PC-007',
      'PC-008',
      'PC-009',
      'PC-010',
      'PC-011',
      'SLCR-001',
      'SLCR-002',
      'SLCR-003',
      'SLCR-004',
      'SLCR-005',
      'SLCR-006',
      'SLCR-007',
      'SLCR-008',
    ]) {
      expect(review, contains(id), reason: '$id must be dispositioned');
    }

    final fixedIds = <String>[
      'PC-001 / SLCR-001',
      'PC-002 / SLCR-004',
      'PC-003 / SLCR-002',
      'PC-004 / SLCR-003',
      'PC-005 / SLCR-005',
      'PC-006 / SLCR-006',
      'PC-009 / SLCR-007',
    ];
    for (final id in fixedIds) {
      expect(review, contains('| $id | fixed |'));
    }

    for (final id in <String>['PC-007', 'PC-008', 'PC-010']) {
      expect(review, contains('| $id | intentional safe simplification |'));
    }
    expect(
      review,
      contains('| PC-011 / SLCR-008 | explicit source-truth defer |'),
    );
  });

  test('campaign authority advances without reopening closed scopes', () {
    final activeRoute = File(activeRouteCapsulePath).readAsStringSync();
    final learningRepair = File(learningRepairCapsulePath).readAsStringSync();
    final campaignPlan = File(campaignPlanPath).readAsStringSync();
    final campaignState = File(campaignStatePath).readAsStringSync();

    expect(
      campaignPlan,
      contains('Canonical Contract and Test Authority Restoration'),
    );
    expect(
      campaignState,
      contains('PHP-3C — outside-handoff authority debt disposition'),
    );
    expect(
      campaignState,
      contains(
        'ACTIVE** — PHP-3C is bounded to this candidate; PHP-4 and Human remain unauthorized',
      ),
    );
    expect(campaignState, contains('F-17 | **CLASSIFIED**'));
    expect(campaignState, contains('F-18 | **STALE_TEST**'));
    expect(campaignState, contains('Human Proof | **NOT AUTHORIZED**'));
    expect(activeRoute, contains('Phase 7 - Content & Correctness is CLOSED'));
    expect(
      activeRoute,
      contains('reopening any previously closed capability.**'),
    );
    expect(
      activeRoute,
      contains('Modern Table remains in permanent Maintenance Mode'),
    );

    expect(learningRepair, contains('phase_7_closed_with_explicit_deferrals'));
    expect(learningRepair, contains('no unresolved Phase 7 blocker'));
    expect(learningRepair, contains('W13+ remains closed'));
    expect(learningRepair, contains('Practice mapping remains blocked'));
    expect(learningRepair, contains('pre_existing_stale_harness'));

    final targetedRepair = File(targetedRepairPath).readAsStringSync();
    expect(targetedRepair, contains('Fixed count: 7 merged items'));
    expect(targetedRepair, contains('Accepted count: 3 merged items'));
    expect(targetedRepair, contains('Deferred count: 1 merged item'));
  });
}
