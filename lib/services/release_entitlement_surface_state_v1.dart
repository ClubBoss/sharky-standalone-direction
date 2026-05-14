import 'package:flutter/foundation.dart';

import 'subscription_status_v1.dart';
import 'trial_service_v1.dart';

@immutable
class ReleaseEntitlementSurfaceStateV1 {
  const ReleaseEntitlementSurfaceStateV1({
    required this.subscriptionStatus,
    required this.trialStatus,
  });

  final SubscriptionStatusV1 subscriptionStatus;
  final TrialStatusV1 trialStatus;

  bool get isPremium =>
      subscriptionStatus.accessState == SubscriptionAccessStateV1.premium;

  bool get isTrialActive => trialStatus.isTrialActive;

  bool get isTrialEligible => trialStatus.isEligible;

  bool get showMonetizationRow => true;
}

class ReleaseEntitlementSurfaceStateServiceV1 {
  ReleaseEntitlementSurfaceStateServiceV1._();

  static Future<ReleaseEntitlementSurfaceStateV1> readV1({
    required int nowEpochMs,
  }) async {
    final trialStatus = await TrialServiceV1.getTrialStatusV1(
      nowEpochMs: nowEpochMs,
    );
    final subscriptionStatus = await SubscriptionServiceV1.getStatusV1(
      nowEpochMs: nowEpochMs,
    );
    return ReleaseEntitlementSurfaceStateV1(
      subscriptionStatus: subscriptionStatus,
      trialStatus: trialStatus,
    );
  }
}
