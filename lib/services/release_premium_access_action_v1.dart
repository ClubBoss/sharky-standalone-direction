import 'package:flutter/foundation.dart';

import 'premium_restore_flow_v1.dart';
import 'subscription_status_v1.dart';

enum ReleasePremiumAccessActionStatusV1 {
  activated,
  restored,
  alreadyActive,
  noPurchaseFound,
  failed,
}

@immutable
class ReleasePremiumAccessActionResultV1 {
  const ReleasePremiumAccessActionResultV1({
    required this.status,
    required this.subscriptionStatus,
    this.message,
  });

  final ReleasePremiumAccessActionStatusV1 status;
  final SubscriptionStatusV1 subscriptionStatus;
  final String? message;
}

class ReleasePremiumAccessActionV1 {
  ReleasePremiumAccessActionV1._();

  @visibleForTesting
  static Future<ReleasePremiumAccessActionResultV1> Function()?
  debugOverrideRestoreV1;

  @visibleForTesting
  static Future<ReleasePremiumAccessActionResultV1> Function()?
  debugOverrideUpgradeV1;

  static Future<ReleasePremiumAccessActionResultV1> restoreV1({
    required Future<SubscriptionStatusV1> Function() readStatusBefore,
    Future<bool> Function()? checkStoreAvailability,
    required Future<void> Function() performRestore,
    required Future<bool> Function() readEntitlementAfter,
    required String? Function() readLastError,
    required Future<SubscriptionStatusV1> Function() readStatusAfter,
  }) async {
    final override = debugOverrideRestoreV1;
    if (override != null) {
      return override();
    }
    final statusBefore = await readStatusBefore();
    if (checkStoreAvailability != null && !(await checkStoreAvailability())) {
      return ReleasePremiumAccessActionResultV1(
        status: ReleasePremiumAccessActionStatusV1.failed,
        subscriptionStatus: statusBefore,
        message: readLastError() ?? 'Store not available on this device',
      );
    }
    final outcome = await PremiumRestoreFlowV1.run(
      entitlementBefore: statusBefore.isEntitled,
      performRestore: performRestore,
      readEntitlementAfter: readEntitlementAfter,
      readLastError: readLastError,
    );
    final statusAfter = await readStatusAfter();
    return ReleasePremiumAccessActionResultV1(
      status: switch (outcome.status) {
        PremiumRestoreOutcomeStatusV1.restored =>
          ReleasePremiumAccessActionStatusV1.restored,
        PremiumRestoreOutcomeStatusV1.alreadyActive =>
          ReleasePremiumAccessActionStatusV1.alreadyActive,
        PremiumRestoreOutcomeStatusV1.noPurchaseFound =>
          ReleasePremiumAccessActionStatusV1.noPurchaseFound,
        PremiumRestoreOutcomeStatusV1.failed =>
          ReleasePremiumAccessActionStatusV1.failed,
      },
      subscriptionStatus: statusAfter,
      message: outcome.message,
    );
  }

  static Future<ReleasePremiumAccessActionResultV1> upgradeV1({
    required Future<SubscriptionStatusV1> Function() readStatusBefore,
    Future<bool> Function()? checkStoreAvailability,
    String? Function()? readLastError,
    required Future<Map<String, Object>> Function() performUpgrade,
    required Future<SubscriptionStatusV1> Function() readStatusAfter,
  }) async {
    final override = debugOverrideUpgradeV1;
    if (override != null) {
      return override();
    }
    final statusBefore = await readStatusBefore();
    if (statusBefore.isPremium) {
      return ReleasePremiumAccessActionResultV1(
        status: ReleasePremiumAccessActionStatusV1.alreadyActive,
        subscriptionStatus: statusBefore,
      );
    }

    if (checkStoreAvailability != null && !(await checkStoreAvailability())) {
      return ReleasePremiumAccessActionResultV1(
        status: ReleasePremiumAccessActionStatusV1.failed,
        subscriptionStatus: statusBefore,
        message: readLastError?.call() ?? 'Store not available on this device',
      );
    }

    final result = await performUpgrade();
    final validated = result['validated'] == true;
    final statusAfter = await readStatusAfter();
    return ReleasePremiumAccessActionResultV1(
      status: validated && statusAfter.isPremium
          ? ReleasePremiumAccessActionStatusV1.activated
          : ReleasePremiumAccessActionStatusV1.failed,
      subscriptionStatus: statusAfter,
      message: validated && statusAfter.isPremium
          ? null
          : readLastError?.call() ?? 'Purchase failed',
    );
  }

  @visibleForTesting
  static void debugResetOverridesV1() {
    debugOverrideRestoreV1 = null;
    debugOverrideUpgradeV1 = null;
  }
}
