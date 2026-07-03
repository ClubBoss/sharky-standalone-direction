import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const reviewPath = 'docs/_reviews/solver_light_selected_checks_v1.md';
  const activeRouteCapsulePath = 'docs/context/ACTIVE_ROUTE_CAPSULE_v1.md';
  const learningRepairCapsulePath =
      'docs/context/LEARNING_REPAIR_CAPSULE_v1.md';

  test(
    'solver-light review records all selected verdicts and dispositions',
    () {
      final review = File(reviewPath).readAsStringSync();

      expect(
        review,
        contains('solver_light_selected_checks_complete_with_repairs_required'),
      );
      for (final section in <String>[
        '## 1. Verdict',
        '## 4. Selected candidate inventory',
        '## 5. Assumption completeness',
        '## 6. SL-001 result',
        '## 7. SL-002 result',
        '## 8. SL-003 result',
        '## 9. SL-004 result',
        '## 10. SL-005 result',
        '## 12. PC ledger resolution',
        '## 13. Final P1-P4 repair ledger',
        '## 14. Route safety',
        '## 20. Next recommendation',
      ]) {
        expect(review, contains(section));
      }

      for (final selectedId in <String>[
        'SL-001',
        'SL-002',
        'SL-003',
        'SL-004',
        'SL-005',
      ]) {
        expect(review, contains(selectedId));
      }

      for (final pcId in <String>[
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
      ]) {
        expect(review, contains(pcId));
      }

      expect(review, contains('route_safe_until_repair'));
      expect(review, contains('Targeted Content Repairs v1'));
      expect(review, isNot(contains('GTO says')));
      expect(review, isNot(contains('solver-approved')));
      expect(review, isNot(contains('exact frequency')));
    },
  );

  test('solver-light capsule closure remains recorded after later repairs', () {
    final activeRoute = File(activeRouteCapsulePath).readAsStringSync();
    final learningRepair = File(learningRepairCapsulePath).readAsStringSync();

    expect(activeRoute, contains('Solver-Light Selected Checks v1'));
    expect(activeRoute, contains('Solver-Light Selected Checks - CLOSED'));
    expect(activeRoute, contains('Targeted Content Repairs - CLOSED'));
    expect(activeRoute, contains('Phase 7 Closure Audit - ACTIVE'));
    expect(
      activeRoute,
      isNot(contains('W13-W36 pre-Human expansion - ACTIVE')),
    );

    expect(learningRepair, contains('SL-001'));
    expect(learningRepair, contains('PC-011'));
    expect(learningRepair, contains('route_safe_until_repair'));
    expect(learningRepair, contains('W13+ remains closed'));
  });
}
