enum Act0GrowthDestinationV1 { home, learn }

const act0GrowthLearnLinkV1 = 'sharky://open/v1/learn';

Act0GrowthDestinationV1 act0GrowthDestinationForLinkV1(String link) =>
    link == act0GrowthLearnLinkV1
    ? Act0GrowthDestinationV1.learn
    : Act0GrowthDestinationV1.home;
