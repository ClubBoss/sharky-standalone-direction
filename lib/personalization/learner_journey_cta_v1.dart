import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';

String learnerJourneyPrimaryReviewCtaLabelV1() => 'REVIEW';

String learnerJourneyPrimaryNextLessonCtaLabelV1() => 'NEXT LESSON';

String learnerJourneyPersonalizedActionCtaLabelV1(
  PersonalizedNextActionV1 action,
) {
  switch (action) {
    case PersonalizedNextActionV1.reviewFocus:
      return learnerJourneyPrimaryReviewCtaLabelV1();
    case PersonalizedNextActionV1.repeatPack:
      return 'REPEAT PACK';
    case PersonalizedNextActionV1.continueCampaign:
    case PersonalizedNextActionV1.nextModule:
      return learnerJourneyPrimaryNextLessonCtaLabelV1();
  }
}
