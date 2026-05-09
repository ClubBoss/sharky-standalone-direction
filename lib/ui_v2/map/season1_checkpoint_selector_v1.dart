String selectSeason1CheckpointPackIdV1(int completedPacksCount) {
  final count = completedPacksCount < 0 ? 0 : completedPacksCount;
  if (count < 3) {
    return 'season1_checkpoint_w1_3_v1';
  }
  if (count < 6) {
    return 'season1_checkpoint_w4_6_v1';
  }
  return 'season1_checkpoint_w7_10_v1';
}
