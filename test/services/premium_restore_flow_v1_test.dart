import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/premium_restore_flow_v1.dart';
import 'package:poker_analyzer/services/premium_value_package_v1.dart';

void main() {
  test('restore flow returns already active without calling restore', () async {
    var restoreCalled = false;
    final outcome = await PremiumRestoreFlowV1.run(
      entitlementBefore: true,
      performRestore: () async {
        restoreCalled = true;
      },
      readEntitlementAfter: () async => true,
      readLastError: () => null,
    );

    expect(restoreCalled, isFalse);
    expect(outcome.status, PremiumRestoreOutcomeStatusV1.alreadyActive);
    expect(outcome.message, contains(kPremiumValuePackageV1.title));
    expect(outcome.message, contains('already active here'));
  });

  test(
    'restore flow returns restored when entitlement appears after restore',
    () async {
      final outcome = await PremiumRestoreFlowV1.run(
        entitlementBefore: false,
        performRestore: () async {},
        readEntitlementAfter: () async => true,
        readLastError: () => null,
      );

      expect(outcome.status, PremiumRestoreOutcomeStatusV1.restored);
      expect(outcome.message, contains(kPremiumValuePackageV1.title));
      expect(outcome.message, contains('Optional table-clue practice'));
      expect(outcome.message, contains('store account'));
    },
  );

  test(
    'restore flow returns no purchase found when restore finishes empty',
    () async {
      final outcome = await PremiumRestoreFlowV1.run(
        entitlementBefore: false,
        performRestore: () async {},
        readEntitlementAfter: () async => false,
        readLastError: () => null,
      );

      expect(outcome.status, PremiumRestoreOutcomeStatusV1.noPurchaseFound);
      expect(outcome.message, contains(kPremiumValuePackageV1.title));
      expect(outcome.message, contains('stays on its current path'));
    },
  );

  test('restore flow returns failed when restore reports an error', () async {
    final outcome = await PremiumRestoreFlowV1.run(
      entitlementBefore: false,
      performRestore: () async {},
      readEntitlementAfter: () async => false,
      readLastError: () => 'Store not available on this device',
    );

    expect(outcome.status, PremiumRestoreOutcomeStatusV1.failed);
    expect(outcome.message, contains('Store not available on this device'));
    expect(outcome.message, contains(kPremiumValuePackageV1.title));
    expect(outcome.message, contains('stays unchanged'));
  });
}
