import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/trial_offer_policy_v1.dart';

void main() {
  test(
    'main trial offer requires both eligibility and first useful loop proof',
    () {
      expect(
        TrialOfferPolicyV1.showMainTrialOfferV1(
          isEligible: false,
          completedHandsInCampaign: 0,
        ),
        isFalse,
      );
      expect(
        TrialOfferPolicyV1.showMainTrialOfferV1(
          isEligible: true,
          completedHandsInCampaign: 0,
        ),
        isFalse,
      );
      expect(
        TrialOfferPolicyV1.showMainTrialOfferV1(
          isEligible: true,
          completedHandsInCampaign: 1,
        ),
        isTrue,
      );
    },
  );
}
