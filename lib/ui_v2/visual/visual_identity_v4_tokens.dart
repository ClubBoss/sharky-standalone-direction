class VisualIdentityV4Tokens {
  const VisualIdentityV4Tokens({
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.shadowLow,
    required this.shadowMedium,
    required this.shadowHigh,
    required this.contrastLow,
    required this.contrastMedium,
    required this.contrastHigh,
  });

  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;

  final double shadowLow;
  final double shadowMedium;
  final double shadowHigh;

  final double contrastLow;
  final double contrastMedium;
  final double contrastHigh;

  Map<String, double> exportTokens() {
    // TODO Phase-7: V4 token export logic
    return {
      'rS': radiusSmall,
      'rM': radiusMedium,
      'rL': radiusLarge,
      'sL': shadowLow,
      'sM': shadowMedium,
      'sH': shadowHigh,
      'cL': contrastLow,
      'cM': contrastMedium,
      'cH': contrastHigh,
    };
  }
}
