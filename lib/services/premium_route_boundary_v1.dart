class PremiumRouteBoundaryV1 {
  PremiumRouteBoundaryV1._();

  static const int freeWorldMax = 4;
  static const int premiumWorldMin = 5;

  static bool isPremiumProgressionWorldV1(int? worldIndex) {
    if (worldIndex == null) {
      return false;
    }
    return worldIndex >= premiumWorldMin;
  }
}
