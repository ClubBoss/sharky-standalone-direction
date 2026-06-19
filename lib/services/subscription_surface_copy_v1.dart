import 'package:poker_analyzer/services/premium_value_package_v1.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';

class SubscriptionSurfaceCopyV1 {
  SubscriptionSurfaceCopyV1._();

  static String todayStatusLine(SubscriptionStatusV1 status) {
    return switch (status.accessState) {
      SubscriptionAccessStateV1.premium =>
        'Premium active: extra table-clue practice is available after the free foundation.',
      SubscriptionAccessStateV1.trial =>
        'Trial active: ${status.trialRemainingDays} days left for optional table-clue practice after the free foundation.',
      SubscriptionAccessStateV1.free => kPremiumValuePackageV1.freeRuleLine,
    };
  }

  static String todayPreviewStatusLine(SubscriptionStatusV1 status) {
    return switch (status.accessState) {
      SubscriptionAccessStateV1.premium =>
        'Premium is active now on this account.',
      SubscriptionAccessStateV1.trial =>
        'Trial is active now. Premium keeps optional table-clue practice available after the trial ends.',
      SubscriptionAccessStateV1.free => kPremiumValuePackageV1.freeRuleLine,
    };
  }

  static String hubStatusLine(SubscriptionStatusV1 status) {
    return switch (status.accessState) {
      SubscriptionAccessStateV1.premium =>
        'Premium active: extra table-clue practice is available after the free foundation.',
      SubscriptionAccessStateV1.trial =>
        'Trial active: optional table-clue practice stays available during the active trial.',
      SubscriptionAccessStateV1.free =>
        'Free active: the opening path and first useful hand stay open.',
    };
  }

  static String hubPackageSummaryLine(SubscriptionStatusV1 status) {
    return switch (status.accessState) {
      SubscriptionAccessStateV1.premium =>
        'Your account already has premium access on current main.',
      SubscriptionAccessStateV1.trial =>
        'Your account is on trial now. Premium keeps optional table-clue practice available after the trial ends.',
      SubscriptionAccessStateV1.free =>
        'Premium can add more table-clue practice after the free foundation.',
    };
  }
}
