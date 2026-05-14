class TrialOfferPolicyV1 {
  TrialOfferPolicyV1._();

  static bool showMainTrialOfferV1({
    required bool isEligible,
    required int completedHandsInCampaign,
  }) {
    if (!isEligible) {
      return false;
    }
    return completedHandsInCampaign > 0;
  }
}
