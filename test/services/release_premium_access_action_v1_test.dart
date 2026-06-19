import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/entitlement_ledger_v1.dart';
import 'package:poker_analyzer/services/release_premium_access_action_v1.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';

const _freeStatus = SubscriptionStatusV1(
  isPremium: false,
  isEntitled: false,
  isTrialActive: false,
  trialRemainingDays: 0,
  source: SubscriptionSourceV1.none,
  accessState: SubscriptionAccessStateV1.free,
);

const _premiumStatus = SubscriptionStatusV1(
  isPremium: true,
  isEntitled: true,
  isTrialActive: false,
  trialRemainingDays: 0,
  source: SubscriptionSourceV1.premiumService,
  accessState: SubscriptionAccessStateV1.premium,
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EntitlementLedgerServiceV1.instance.debugClearLedgerForTestsOnlyV1();
  });

  tearDown(() async {
    await EntitlementLedgerServiceV1.instance.debugClearLedgerForTestsOnlyV1();
  });

  test('restore returns restored with refreshed premium status', () async {
    final result = await ReleasePremiumAccessActionV1.restoreV1(
      readStatusBefore: () async => _freeStatus,
      checkStoreAvailability: () async => true,
      performRestore: () async {},
      readEntitlementAfter: () async => true,
      readLastError: () => null,
      readStatusAfter: () async => _premiumStatus,
    );

    expect(result.status, ReleasePremiumAccessActionStatusV1.restored);
    expect(result.subscriptionStatus.isPremium, isTrue);
    expect(result.message, isNotNull);
    final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1();
    final access = ledger.toAccess(
      nowEpochMs: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    expect(ledger.source, EntitlementLedgerSourceV1.localRestore);
    expect(ledger.restoreState, EntitlementLedgerRestoreStateV1.restored);
    expect(access.canAccessPremium, isTrue);
    expect(access.publicCommerceSafe, isFalse);
  });

  test('restore no-purchase records no-purchase without access', () async {
    final result = await ReleasePremiumAccessActionV1.restoreV1(
      readStatusBefore: () async => _freeStatus,
      checkStoreAvailability: () async => true,
      performRestore: () async {},
      readEntitlementAfter: () async => false,
      readLastError: () => null,
      readStatusAfter: () async => _freeStatus,
    );

    expect(result.status, ReleasePremiumAccessActionStatusV1.noPurchaseFound);
    final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1();
    final access = ledger.toAccess(
      nowEpochMs: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    expect(ledger.source, EntitlementLedgerSourceV1.localRestore);
    expect(
      ledger.restoreState,
      EntitlementLedgerRestoreStateV1.noPurchaseFound,
    );
    expect(access.canAccessPremium, isFalse);
    expect(access.publicCommerceSafe, isFalse);
  });

  test(
    'restore returns failed when restore leaves access unchanged with error',
    () async {
      final result = await ReleasePremiumAccessActionV1.restoreV1(
        readStatusBefore: () async => _freeStatus,
        checkStoreAvailability: () async => true,
        performRestore: () async {},
        readEntitlementAfter: () async => false,
        readLastError: () => 'Store unavailable',
        readStatusAfter: () async => _freeStatus,
      );

      expect(result.status, ReleasePremiumAccessActionStatusV1.failed);
      expect(result.subscriptionStatus.isEntitled, isFalse);
      expect(result.message, contains('Store unavailable'));
      final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1();
      expect(ledger.restoreState, EntitlementLedgerRestoreStateV1.failed);
      expect(ledger.lastErrorCode, 'restore_failed');
      expect(
        ledger
            .toAccess(nowEpochMs: DateTime.now().toUtc().millisecondsSinceEpoch)
            .canAccessPremium,
        isFalse,
      );
    },
  );

  test(
    'upgrade returns activated only when refreshed status becomes premium',
    () async {
      final result = await ReleasePremiumAccessActionV1.upgradeV1(
        readStatusBefore: () async => _freeStatus,
        checkStoreAvailability: () async => true,
        readLastError: () => null,
        performUpgrade: () async => <String, Object>{
          'validated': true,
          'score': 1.0,
        },
        readStatusAfter: () async => _premiumStatus,
      );

      expect(result.status, ReleasePremiumAccessActionStatusV1.activated);
      expect(result.subscriptionStatus.isPremium, isTrue);
    },
  );

  test(
    'upgrade returns alreadyActive without needing a new purchase',
    () async {
      final result = await ReleasePremiumAccessActionV1.upgradeV1(
        readStatusBefore: () async => _premiumStatus,
        checkStoreAvailability: () async => true,
        readLastError: () => null,
        performUpgrade: () async => throw StateError('should not run'),
        readStatusAfter: () async => _premiumStatus,
      );

      expect(result.status, ReleasePremiumAccessActionStatusV1.alreadyActive);
      expect(result.subscriptionStatus.isPremium, isTrue);
    },
  );

  test('restore fails fast when store is unavailable', () async {
    final result = await ReleasePremiumAccessActionV1.restoreV1(
      readStatusBefore: () async => _freeStatus,
      checkStoreAvailability: () async => false,
      performRestore: () async => throw StateError('should not run'),
      readEntitlementAfter: () async => false,
      readLastError: () => 'Store not available on this device',
      readStatusAfter: () async => _freeStatus,
    );

    expect(result.status, ReleasePremiumAccessActionStatusV1.failed);
    expect(
      result.subscriptionStatus.accessState,
      SubscriptionAccessStateV1.free,
    );
    expect(result.message, 'Store not available on this device');
  });

  test('upgrade fails fast when store is unavailable', () async {
    final result = await ReleasePremiumAccessActionV1.upgradeV1(
      readStatusBefore: () async => _freeStatus,
      checkStoreAvailability: () async => false,
      readLastError: () => 'Store not available on this device',
      performUpgrade: () async => throw StateError('should not run'),
      readStatusAfter: () async => _freeStatus,
    );

    expect(result.status, ReleasePremiumAccessActionStatusV1.failed);
    expect(
      result.subscriptionStatus.accessState,
      SubscriptionAccessStateV1.free,
    );
    expect(result.message, 'Store not available on this device');
  });

  test(
    'upgrade returns failed message when validation does not activate premium',
    () async {
      final result = await ReleasePremiumAccessActionV1.upgradeV1(
        readStatusBefore: () async => _freeStatus,
        checkStoreAvailability: () async => true,
        readLastError: () => null,
        performUpgrade: () async => <String, Object>{
          'validated': false,
          'score': 0.0,
        },
        readStatusAfter: () async => _freeStatus,
      );

      expect(result.status, ReleasePremiumAccessActionStatusV1.failed);
      expect(
        result.subscriptionStatus.accessState,
        SubscriptionAccessStateV1.free,
      );
      expect(result.message, 'Purchase failed');
    },
  );
}
