import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'value_before_paywall_copy_guard_v1.dart';

void main() {
  test('active Act0 copy owners reject forbidden packaging phrases', () {
    final root = Directory.current.path;
    final findings = <String>[];

    for (final owner in activeAct0LearnerCopyOwnersV1) {
      final source = File('$root/$owner').readAsStringSync();
      findings.addAll(
        forbiddenValueBeforePaywallFindingsV1(source).map(
          (phrase) => '$owner: $phrase',
        ),
      );
    }

    expect(findings, isEmpty);
  });

  test('guard rejects a future unlock or pressure claim', () {
    expect(
      forbiddenValueBeforePaywallFindingsV1(
        'Unlock W13 now. Upgrade to continue before the offer ends today.',
      ),
      containsAll(<String>['unlock w13', 'upgrade to continue', 'ends today']),
    );
  });

  test('legacy exclusion roots are outside active learner copy owners', () {
    for (final root in legacyDormantCopyExclusionRootsV1) {
      expect(
        activeAct0LearnerCopyOwnersV1.any((owner) => owner.startsWith(root)),
        isFalse,
        reason: 'legacy exclusion overlaps active owner: $root',
      );
    }
  });
}
