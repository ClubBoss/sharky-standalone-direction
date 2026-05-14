import 'package:poker_analyzer/services/premium_value_package_v1.dart';
import 'package:poker_analyzer/services/subscription_status_v1.dart';

class SubscriptionSurfaceCopyV1 {
  SubscriptionSurfaceCopyV1._();

  static String todayStatusLine(SubscriptionStatusV1 status) {
    return switch (status.accessState) {
      SubscriptionAccessStateV1.premium =>
        'Premium active: premium-target Today routes and World 5+ are unlocked.',
      SubscriptionAccessStateV1.trial =>
        'Trial active: ${status.trialRemainingDays} days left on premium-target Today routes and World 5+.',
      SubscriptionAccessStateV1.free => kPremiumValuePackageV1.freeRuleLine,
    };
  }

  static String todayPreviewStatusLine(SubscriptionStatusV1 status) {
    return switch (status.accessState) {
      SubscriptionAccessStateV1.premium =>
        'Premium is active now on this account.',
      SubscriptionAccessStateV1.trial =>
        'Trial is active now. Premium keeps premium-target Today routes and World 5+ open after the trial ends.',
      SubscriptionAccessStateV1.free =>
        'Free stays on the opening path plus one Today route per UTC day on current main.',
    };
  }

  static String hubStatusLine(SubscriptionStatusV1 status) {
    return switch (status.accessState) {
      SubscriptionAccessStateV1.premium =>
        'Premium active: premium-target Today routes and World 5+ are unlocked.',
      SubscriptionAccessStateV1.trial =>
        'Trial active: premium-target Today routes and World 5+ stay open during the active trial.',
      SubscriptionAccessStateV1.free =>
        'Free access stays on the opening path plus one Today route per UTC day.',
    };
  }

  static String hubPackageSummaryLine(SubscriptionStatusV1 status) {
    return switch (status.accessState) {
      SubscriptionAccessStateV1.premium =>
        'Your account already has premium access on current main.',
      SubscriptionAccessStateV1.trial =>
        'Your account is on trial now. Premium keeps the same premium-target access after the trial ends.',
      SubscriptionAccessStateV1.free =>
        'Premium adds premium-target Today routes and World 5+ progression on current main.',
    };
  }
}
