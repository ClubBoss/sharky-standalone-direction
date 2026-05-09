import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'premium_service.dart';
import 'trial_service_v1.dart';

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

  static const String _migrationDoneKey = 'entitlement_ssot_migrated_v1';

  Future<void> migrateLegacyKeysIfNeededV1() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationDoneKey) ?? false) {
      return;
    }
    // v1 migration is intentionally no-op: keep legacy keys unchanged.
    await prefs.setBool(_migrationDoneKey, true);
  }

  Future<EntitlementStateV1> readPremiumStateV1({int? nowEpochMs}) async {
    await migrateLegacyKeysIfNeededV1();
    final safeNowEpochMs =
        nowEpochMs ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    final premiumActiveFlag = await PremiumService().isPremiumActive();
    final trialStatus = await TrialServiceV1.getTrialStatusV1(
      nowEpochMs: safeNowEpochMs,
    );
    return EntitlementStateV1(
      premiumActiveFlag: premiumActiveFlag,
      trialActive: trialStatus.isTrialActive,
      trialRemainingDays: trialStatus.remainingDays,
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
