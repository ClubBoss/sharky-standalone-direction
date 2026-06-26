enum Act0SharkyCoachMomentV1 {
  homeActiveRepair,
  practiceCurrentFix,
  reviewActiveRepair,
  repairResultProof,
  sessionSummaryProof,
}

String act0SharkyCoachLineForMomentV1(Act0SharkyCoachMomentV1 moment) {
  return switch (moment) {
    Act0SharkyCoachMomentV1.homeActiveRepair => 'One clue at a time.',
    Act0SharkyCoachMomentV1.practiceCurrentFix =>
      'Run it once more while the clue is fresh.',
    Act0SharkyCoachMomentV1.reviewActiveRepair =>
      'This is the spot to clean up.',
    Act0SharkyCoachMomentV1.repairResultProof =>
      'Good. You saw the table this time.',
    Act0SharkyCoachMomentV1.sessionSummaryProof => 'Small win, real proof.',
  };
}
