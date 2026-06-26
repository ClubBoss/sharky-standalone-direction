enum Act0SharkyCoachTierV1 { foundation, developing, sharp }

enum Act0SharkyCoachMomentV1 {
  homeActiveRepair,
  practiceCurrentFix,
  reviewActiveRepair,
  repairResultProof,
  sessionSummaryProof,
  worldOneCompletionPayoff,
}

Act0SharkyCoachTierV1 act0SharkyCoachTierForWorldNumberV1(int worldNumber) {
  if (worldNumber >= 13) {
    return Act0SharkyCoachTierV1.sharp;
  }
  if (worldNumber >= 5) {
    return Act0SharkyCoachTierV1.developing;
  }
  return Act0SharkyCoachTierV1.foundation;
}

String act0SharkyCoachLineForMomentV1(
  Act0SharkyCoachMomentV1 moment, {
  Act0SharkyCoachTierV1 tier = Act0SharkyCoachTierV1.foundation,
}) {
  return switch (tier) {
    Act0SharkyCoachTierV1.foundation => switch (moment) {
      Act0SharkyCoachMomentV1.homeActiveRepair =>
        'You are learning where to look first.',
      Act0SharkyCoachMomentV1.practiceCurrentFix =>
        'Run one quick rep while the clue is fresh.',
      Act0SharkyCoachMomentV1.reviewActiveRepair =>
        'Keep this read warm with one quick rep.',
      Act0SharkyCoachMomentV1.repairResultProof =>
        'Nice. You found the table clue.',
      Act0SharkyCoachMomentV1.sessionSummaryProof => 'Small win, real proof.',
      Act0SharkyCoachMomentV1.worldOneCompletionPayoff =>
        'You banked the first table read.',
    },
    Act0SharkyCoachTierV1.developing => switch (moment) {
      Act0SharkyCoachMomentV1.homeActiveRepair =>
        'Reconnect the clue before adding speed.',
      Act0SharkyCoachMomentV1.practiceCurrentFix =>
        'Repeat the key clue before adding pressure.',
      Act0SharkyCoachMomentV1.reviewActiveRepair =>
        'Review the signal before the next decision.',
      Act0SharkyCoachMomentV1.repairResultProof =>
        'Good. The signal and action lined up.',
      Act0SharkyCoachMomentV1.sessionSummaryProof =>
        'Clean proof. Keep the pattern ready.',
      Act0SharkyCoachMomentV1.worldOneCompletionPayoff =>
        'Foundation read banked.',
    },
    Act0SharkyCoachTierV1.sharp => switch (moment) {
      Act0SharkyCoachMomentV1.homeActiveRepair =>
        'Find the signal. Make the clean decision.',
      Act0SharkyCoachMomentV1.practiceCurrentFix =>
        'Repeat the signal. Keep the decision clean.',
      Act0SharkyCoachMomentV1.reviewActiveRepair =>
        'Recheck the signal. Remove the noise.',
      Act0SharkyCoachMomentV1.repairResultProof =>
        'Signal found. Decision cleaned.',
      Act0SharkyCoachMomentV1.sessionSummaryProof =>
        'Proof logged. Pattern stays ready.',
      Act0SharkyCoachMomentV1.worldOneCompletionPayoff =>
        'Foundation signal banked.',
    },
  };
}
