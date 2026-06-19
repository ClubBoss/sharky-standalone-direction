import 'package:flutter/foundation.dart';
import 'entitlement_ledger_v1.dart';

@immutable
class EntitlementStateV1 {
  const EntitlementStateV1({
    this.schemaVersion = 1,
    required this.premiumActiveFlag,
    required this.trialActive,
    required this.trialRemainingDays,
  });

  final int schemaVersion;
  final bool premiumActiveFlag;
  final bool trialActive;
  final int trialRemainingDays;

  bool get isEntitledToPremium => premiumActiveFlag || trialActive;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'schemaVersion': schemaVersion,
    'premiumActiveFlag': premiumActiveFlag,
    'trialActive': trialActive,
    'trialRemainingDays': trialRemainingDays,
    'isEntitledToPremium': isEntitledToPremium,
  };
}

class EntitlementSSOTV1 {
  EntitlementSSOTV1._();

  static final EntitlementSSOTV1 instance = EntitlementSSOTV1._();

  Future<void> migrateLegacyKeysIfNeededV1() async {
    await EntitlementLedgerServiceV1.instance.readLedgerV1();
  }

  Future<EntitlementStateV1> readPremiumStateV1({int? nowEpochMs}) async {
    final safeNowEpochMs =
        nowEpochMs ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    final access = await EntitlementLedgerServiceV1.instance.readAccessV1(
      nowEpochMs: safeNowEpochMs,
    );
    return EntitlementStateV1(
      premiumActiveFlag:
          access.entitlementStatus == EntitlementLedgerStatusV1.premiumActive,
      trialActive: access.isTrialActive,
      trialRemainingDays: access.trialRemainingDays,
    );
  }

  Future<bool> isEntitledToPremiumV1({int? nowEpochMs}) async {
    final state = await readPremiumStateV1(nowEpochMs: nowEpochMs);
    return state.isEntitledToPremium;
  }

  Future<Map<String, dynamic>> premiumStateDebugV1({int? nowEpochMs}) async {
    final state = await readPremiumStateV1(nowEpochMs: nowEpochMs);
    return state.toJson();
  }
}
