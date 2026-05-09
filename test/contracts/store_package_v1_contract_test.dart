import 'dart:io';

import 'package:test/test.dart';

import '../../tools/release_readiness_snapshot_v1.dart';

void main() {
  test('store package owner stays bounded, metadata-linked, and non-governing', () {
    final storePackage = File('docs/release/store_package_v1.md');
    final metadataTruth = File('docs/release/submission_metadata_truth_v1.md');
    final decisionTruth = File('docs/release/go_hold_rollback_truth_v1.md');
    final reviewOwner = File('docs/release/release_owner_review_v1.md');
    final baseline = File('docs/release/release_confidence_baseline_v1.md');

    expect(storePackage.existsSync(), isTrue);
    expect(metadataTruth.existsSync(), isTrue);
    expect(decisionTruth.existsSync(), isTrue);
    expect(reviewOwner.existsSync(), isTrue);
    expect(baseline.existsSync(), isTrue);

    final storeContent = storePackage.readAsStringSync();

    expect(storeContent, contains('Current Bounded Proof On Main'));
    expect(
      storeContent,
      contains(
        'This owner records bounded store-package truth on current `main`.',
      ),
    );
    expect(
      storeContent,
      contains('docs/release/submission_metadata_truth_v1.md'),
    );
    expect(storeContent, contains('docs/release/go_hold_rollback_truth_v1.md'));
    expect(storeContent, contains('docs/release/release_owner_review_v1.md'));
    expect(
      storeContent,
      contains('docs/release/release_confidence_baseline_v1.md'),
    );
    expect(storeContent, contains('support@sharky.app'));
    expect(storeContent, contains('STORE_PACKAGE_GUARD=1'));
    expect(storeContent, contains('out/modern_table_screenshots_v1.zip'));
    expect(storeContent, contains('docs/release/store_assets_v1.md'));
    expect(storeContent, contains('assets/store/README.md'));
    expect(
      storeContent,
      contains(
        'dart test test/contracts/store_package_telemetry_guard_test.dart -r expanded --concurrency=1 --timeout 2m',
      ),
    );
    expect(
      storeContent,
      contains(
        'remain owned by `docs/release/submission_metadata_truth_v1.md` and remain',
      ),
    );
    expect(
      storeContent,
      contains('This owner does not claim store readiness.'),
    );
    expect(
      storeContent,
      contains('This owner does not claim final release completion.'),
    );
    expect(storeContent, contains('This owner does not claim GO.'));
    expect(storeContent, isNot(contains('www.example.com')));
    expect(storeContent, isNot(contains('Sharky Labs')));

    final snapshot = buildReleaseReadinessSnapshot();
    final guards = snapshot['guards'] as Map<String, Object>;
    final enforcement = snapshot['enforcement'] as Map<String, Object>;
    expect(guards['store_docs'], 'present');
    expect(guards['telemetry'], 'present');
    expect(enforcement['STORE_PACKAGE_GUARD'], 'documented');
    expect(snapshot['storeAssetsPresent'], isTrue);
    expect(snapshot['goNoGoStateIsHold'], isTrue);
  });
}
