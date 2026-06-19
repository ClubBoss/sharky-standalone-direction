import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/payments/payment_service.dart';
import 'package:poker_analyzer/services/entitlement_ledger_v1.dart';
import 'package:poker_analyzer/services/entitlement_ssot_v1.dart';
import 'package:poker_analyzer/services/premium_service.dart';
import 'package:poker_analyzer/services/trial_service_v1.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SubscriptionServiceV1.debugResetTelemetryEmissionV1();
    await PremiumService().clear();
    await EntitlementLedgerServiceV1.instance.debugClearLedgerForTestsOnlyV1();
  });

  tearDown(() async {
    await EntitlementLedgerServiceV1.instance.debugClearLedgerForTestsOnlyV1();
  });

  test('ledger defaults to free with public paywall hidden', () async {
    const nowEpochMs = 1700000000000;

    final access = await EntitlementLedgerServiceV1.instance.readAccessV1(
      nowEpochMs: nowEpochMs,
    );

    expect(access.canAccessPremium, isFalse);
    expect(access.why, EntitlementAccessWhyV1.free);
    expect(access.entitlementStatus, EntitlementLedgerStatusV1.free);
    expect(access.isTrialActive, isFalse);
    expect(access.trialRemainingDays, 0);
    expect(access.publicCommerceSafe, isFalse);
    expect(access.shouldExposePublicPaywall, isFalse);
    expect(access.shouldHidePublicPaywall, isTrue);
    expect(access.shouldHidePremiumHub, isTrue);
  });

  test(
    'migration imports premium_is_active true as legacy premium only',
    () async {
      const nowEpochMs = 1700000000000;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('premium_is_active', true);

      final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
        nowEpochMs: nowEpochMs,
      );
      final access = ledger.toAccess(nowEpochMs: nowEpochMs);

      expect(ledger.entitlementStatus, EntitlementLedgerStatusV1.premiumActive);
      expect(ledger.source, EntitlementLedgerSourceV1.migrationPremiumFlag);
      expect(ledger.migrationSourceKeys, contains('premium_is_active'));
      expect(access.canAccessPremium, isTrue);
      expect(access.why, EntitlementAccessWhyV1.legacyPremiumFlag);
      expect(access.publicCommerceSafe, isFalse);
      expect(access.shouldExposePublicPaywall, isFalse);
      expect(access.shouldHidePremiumHub, isTrue);
    },
  );

  test('migration imports active trial_entitlement_v1', () async {
    const nowEpochMs = 1700000000000;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'trial_entitlement_v1',
      jsonEncode(<String, int>{
        'schemaVersion': 1,
        'startEpochMs': nowEpochMs,
        'durationDays': 7,
      }),
    );

    final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
      nowEpochMs: nowEpochMs,
    );
    final access = ledger.toAccess(nowEpochMs: nowEpochMs);

    expect(ledger.entitlementStatus, EntitlementLedgerStatusV1.trialActive);
    expect(ledger.source, EntitlementLedgerSourceV1.migrationTrial);
    expect(ledger.trialState.state, EntitlementTrialStateKindV1.active);
    expect(ledger.expiresAtEpochMs, nowEpochMs + (7 * 24 * 60 * 60 * 1000));
    expect(ledger.migrationSourceKeys, contains('trial_entitlement_v1'));
    expect(access.canAccessPremium, isTrue);
    expect(access.why, EntitlementAccessWhyV1.trialActive);
    expect(access.isTrialActive, isTrue);
    expect(access.trialRemainingDays, 7);
  });

  test(
    'migration imports expired trial_entitlement_v1 without access',
    () async {
      const nowEpochMs = 1700000000000;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'trial_entitlement_v1',
        jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - (9 * 24 * 60 * 60 * 1000),
          'durationDays': 7,
        }),
      );

      final access = await EntitlementLedgerServiceV1.instance.readAccessV1(
        nowEpochMs: nowEpochMs,
      );

      expect(access.entitlementStatus, EntitlementLedgerStatusV1.trialExpired);
      expect(access.canAccessPremium, isFalse);
      expect(access.why, EntitlementAccessWhyV1.expired);
      expect(access.isTrialActive, isFalse);
      expect(access.trialRemainingDays, 0);
    },
  );

  test(
    'migration records purchased_products as non-authoritative cache',
    () async {
      const nowEpochMs = 1700000000000;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('purchased_products', <String>[
        PaymentService.productPremiumPack,
        PaymentService.productCoinsPackSmall,
      ]);

      final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
        nowEpochMs: nowEpochMs,
      );
      final access = ledger.toAccess(nowEpochMs: nowEpochMs);

      expect(ledger.entitlementStatus, EntitlementLedgerStatusV1.free);
      expect(
        ledger.productCacheProductIds,
        contains(PaymentService.productPremiumPack),
      );
      expect(
        ledger.productCacheProductIds,
        contains(PaymentService.productCoinsPackSmall),
      );
      expect(ledger.migrationSourceKeys, contains('purchased_products'));
      expect(access.canAccessPremium, isFalse);
      expect(access.publicCommerceSafe, isFalse);
    },
  );

  test('migration is idempotent', () async {
    const nowEpochMs = 1700000000000;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premium_is_active', true);
    await prefs.setStringList('purchased_products', <String>[
      PaymentService.productPremiumPack,
    ]);

    final first = await EntitlementLedgerServiceV1.instance.readLedgerV1(
      nowEpochMs: nowEpochMs,
    );
    final second = await EntitlementLedgerServiceV1.instance.readLedgerV1(
      nowEpochMs: nowEpochMs,
    );

    expect(jsonEncode(first.toJson()), jsonEncode(second.toJson()));
  });

  test('EntitlementSSOTV1 reads from ledger projection', () async {
    const nowEpochMs = 1700000000000;
    await EntitlementLedgerServiceV1.instance.debugSetLedgerForTestsOnlyV1(
      EntitlementLedgerV1.free(nowEpochMs: nowEpochMs).copyWith(
        entitlementStatus: EntitlementLedgerStatusV1.premiumActive,
        source: EntitlementLedgerSourceV1.testOnly,
        environment: EntitlementLedgerEnvironmentV1.test,
        isPublicCommerceSafe: false,
      ),
    );

    final state = await EntitlementSSOTV1.instance.readPremiumStateV1(
      nowEpochMs: nowEpochMs,
    );

    expect(state.premiumActiveFlag, isTrue);
    expect(state.isEntitledToPremium, isTrue);
    expect(state.trialActive, isFalse);
    expect(state.trialRemainingDays, 0);
  });

  test(
    'SubscriptionServiceV1 preserves existing status shape through ledger',
    () async {
      const nowEpochMs = 1700000000000;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'trial_entitlement_v1',
        jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs,
          'durationDays': 7,
        }),
      );

      final status = await SubscriptionServiceV1.getStatusV1(
        nowEpochMs: nowEpochMs,
      );

      expect(status.schemaVersion, 1);
      expect(status.isPremium, isFalse);
      expect(status.isEntitled, isTrue);
      expect(status.isTrialActive, isTrue);
      expect(status.trialRemainingDays, 7);
      expect(status.source, SubscriptionSourceV1.trial);
      expect(status.accessState, SubscriptionAccessStateV1.trial);
    },
  );

  test('public paywall and Premium Hub remain hidden for MVP states', () async {
    const nowEpochMs = 1700000000000;
    await PremiumService().enablePremium();

    final access = await EntitlementLedgerServiceV1.instance.readAccessV1(
      nowEpochMs: nowEpochMs,
    );

    expect(access.canAccessPremium, isTrue);
    expect(access.shouldExposePremiumPreview, isTrue);
    expect(access.shouldExposePublicPaywall, isFalse);
    expect(access.shouldHidePublicPaywall, isTrue);
    expect(access.shouldHidePremiumHub, isTrue);
    expect(access.publicCommerceSafe, isFalse);
  });

  test(
    'trial start writes ledger and trial status remains compatible',
    () async {
      const nowEpochMs = 1700000000000;

      await TrialServiceV1.markPlacementCompletedV1();
      final status = await TrialServiceV1.startTrialIfEligibleV1(
        nowEpochMs: nowEpochMs,
      );
      final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
        nowEpochMs: nowEpochMs,
      );
      final access = ledger.toAccess(nowEpochMs: nowEpochMs);

      expect(status.isTrialActive, isTrue);
      expect(status.remainingDays, 7);
      expect(ledger.entitlementStatus, EntitlementLedgerStatusV1.trialActive);
      expect(ledger.source, EntitlementLedgerSourceV1.localTrial);
      expect(ledger.trialState.state, EntitlementTrialStateKindV1.active);
      expect(ledger.expiresAtEpochMs, nowEpochMs + (7 * 24 * 60 * 60 * 1000));
      expect(access.canAccessPremium, isTrue);
      expect(access.publicCommerceSafe, isFalse);
      expect(access.shouldHidePremiumHub, isTrue);
    },
  );

  test(
    'trial rollback is recorded in ledger without granting access',
    () async {
      const nowEpochMs = 1700000000000;
      const rollbackEpochMs = nowEpochMs - (10 * 60 * 1000);

      await TrialServiceV1.markPlacementCompletedV1();
      await TrialServiceV1.startTrialIfEligibleV1(nowEpochMs: nowEpochMs);
      final rollbackStatus = await TrialServiceV1.getTrialStatusV1(
        nowEpochMs: rollbackEpochMs,
      );
      final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
        nowEpochMs: rollbackEpochMs,
      );
      final access = ledger.toAccess(nowEpochMs: rollbackEpochMs);

      expect(rollbackStatus.reason, 'clock_rollback');
      expect(
        ledger.entitlementStatus,
        EntitlementLedgerStatusV1.verificationFailed,
      );
      expect(ledger.source, EntitlementLedgerSourceV1.localTrial);
      expect(ledger.restoreState, EntitlementLedgerRestoreStateV1.none);
      expect(
        ledger.trialState.state,
        EntitlementTrialStateKindV1.blockedByRollback,
      );
      expect(ledger.lastErrorCode, 'clock_rollback');
      expect(access.canAccessPremium, isFalse);
      expect(access.publicCommerceSafe, isFalse);
    },
  );

  test(
    'restore pending and no-purchase outcome are recorded without access',
    () async {
      const nowEpochMs = 1700000000000;

      await EntitlementLedgerServiceV1.instance.recordRestorePendingV1(
        nowEpochMs: nowEpochMs,
      );
      var ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
        nowEpochMs: nowEpochMs,
      );
      expect(ledger.restoreState, EntitlementLedgerRestoreStateV1.pending);
      expect(
        ledger.entitlementStatus,
        EntitlementLedgerStatusV1.verificationPending,
      );
      expect(ledger.toAccess(nowEpochMs: nowEpochMs).canAccessPremium, isFalse);

      await EntitlementLedgerServiceV1.instance.recordNoPurchaseFoundRestoreV1(
        nowEpochMs: nowEpochMs + 1,
      );
      ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
        nowEpochMs: nowEpochMs + 1,
      );
      final access = ledger.toAccess(nowEpochMs: nowEpochMs + 1);

      expect(
        ledger.restoreState,
        EntitlementLedgerRestoreStateV1.noPurchaseFound,
      );
      expect(ledger.entitlementStatus, EntitlementLedgerStatusV1.free);
      expect(access.canAccessPremium, isFalse);
      expect(access.publicCommerceSafe, isFalse);
    },
  );

  test('restore failure records error without granting access', () async {
    const nowEpochMs = 1700000000000;

    await EntitlementLedgerServiceV1.instance.recordVerificationFailedV1(
      nowEpochMs: nowEpochMs,
      restoreState: EntitlementLedgerRestoreStateV1.failed,
      errorCode: 'store_unavailable',
    );
    final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
      nowEpochMs: nowEpochMs,
    );
    final access = ledger.toAccess(nowEpochMs: nowEpochMs);

    expect(
      ledger.entitlementStatus,
      EntitlementLedgerStatusV1.verificationFailed,
    );
    expect(ledger.restoreState, EntitlementLedgerRestoreStateV1.failed);
    expect(ledger.lastErrorCode, 'store_unavailable');
    expect(access.canAccessPremium, isFalse);
    expect(access.publicCommerceSafe, isFalse);
  });

  test(
    'local restore success writes non-public-commerce-safe premium',
    () async {
      const nowEpochMs = 1700000000000;

      await EntitlementLedgerServiceV1.instance.recordLocalRestoreSuccessV1(
        nowEpochMs: nowEpochMs,
        storeProductId: PaymentService.productPremiumPack,
      );
      final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
        nowEpochMs: nowEpochMs,
      );
      final access = ledger.toAccess(nowEpochMs: nowEpochMs);

      expect(ledger.entitlementStatus, EntitlementLedgerStatusV1.premiumActive);
      expect(ledger.source, EntitlementLedgerSourceV1.localRestore);
      expect(ledger.restoreState, EntitlementLedgerRestoreStateV1.restored);
      expect(ledger.storeProductId, PaymentService.productPremiumPack);
      expect(access.canAccessPremium, isTrue);
      expect(access.publicCommerceSafe, isFalse);
      expect(access.shouldExposePublicPaywall, isFalse);
      expect(access.shouldHidePremiumHub, isTrue);
    },
  );

  test(
    'premium product convergence writes local non-public-safe entitlement',
    () async {
      const nowEpochMs = 1700000000000;

      await EntitlementLedgerServiceV1.instance.recordLocalProductConvergenceV1(
        productId: PaymentService.productProSubscription,
        grantsPremium: true,
        nowEpochMs: nowEpochMs,
      );
      final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
        nowEpochMs: nowEpochMs,
      );
      final access = ledger.toAccess(nowEpochMs: nowEpochMs);

      expect(ledger.entitlementStatus, EntitlementLedgerStatusV1.premiumActive);
      expect(ledger.source, EntitlementLedgerSourceV1.localProductConvergence);
      expect(ledger.storeProductId, PaymentService.productProSubscription);
      expect(ledger.subscriptionState.verified, isFalse);
      expect(access.canAccessPremium, isTrue);
      expect(access.isSubscriptionVerified, isFalse);
      expect(access.publicCommerceSafe, isFalse);
    },
  );

  test('non-entitlement product convergence never grants premium', () async {
    const nowEpochMs = 1700000000000;

    await EntitlementLedgerServiceV1.instance.recordLocalProductConvergenceV1(
      productId: PaymentService.productCoinsPackSmall,
      grantsPremium: false,
      nowEpochMs: nowEpochMs,
    );
    final ledger = await EntitlementLedgerServiceV1.instance.readLedgerV1(
      nowEpochMs: nowEpochMs,
    );
    final access = ledger.toAccess(nowEpochMs: nowEpochMs);

    expect(ledger.entitlementStatus, EntitlementLedgerStatusV1.free);
    expect(
      ledger.productCacheProductIds,
      contains(PaymentService.productCoinsPackSmall),
    );
    expect(access.canAccessPremium, isFalse);
    expect(access.publicCommerceSafe, isFalse);
  });
}
