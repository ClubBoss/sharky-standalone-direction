import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/services/premium_value_package_v1.dart';

enum PremiumRestoreOutcomeStatusV1 {
  restored,
  alreadyActive,
  noPurchaseFound,
  failed,
}

@immutable
class PremiumRestoreOutcomeV1 {
  const PremiumRestoreOutcomeV1({required this.status, required this.message});

  final PremiumRestoreOutcomeStatusV1 status;
  final String message;
}

class PremiumRestoreFlowV1 {
  static String get _premiumAccessTitle => kPremiumValuePackageV1.title;

  static Future<PremiumRestoreOutcomeV1> run({
    required bool entitlementBefore,
    required Future<void> Function() performRestore,
    required Future<bool> Function() readEntitlementAfter,
    required String? Function() readLastError,
  }) async {
    if (entitlementBefore) {
      return PremiumRestoreOutcomeV1(
        status: PremiumRestoreOutcomeStatusV1.alreadyActive,
        message:
            '$_premiumAccessTitle is already active here. Restore is only needed when premium is missing on this device.',
      );
    }

    await performRestore();

    final entitlementAfter = await readEntitlementAfter();
    if (entitlementAfter) {
      return PremiumRestoreOutcomeV1(
        status: PremiumRestoreOutcomeStatusV1.restored,
        message:
            '$_premiumAccessTitle restored on this store account. Premium-target Today routes and World 5+ are available now.',
      );
    }

    final error = readLastError()?.trim();
    if (error != null && error.isNotEmpty) {
      return PremiumRestoreOutcomeV1(
        status: PremiumRestoreOutcomeStatusV1.failed,
        message:
            'Restore failed on this device: $error. $_premiumAccessTitle stays unchanged.',
      );
    }

    return PremiumRestoreOutcomeV1(
      status: PremiumRestoreOutcomeStatusV1.noPurchaseFound,
      message:
          'No past $_premiumAccessTitle purchase was found for this store account, so access stays on its current path.',
    );
  }
}
