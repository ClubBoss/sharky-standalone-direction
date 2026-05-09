enum UxFeedbackType { success, error, levelUp }

class FeedbackAnimationSpec {
  const FeedbackAnimationSpec({
    required this.type,
    required this.primaryHex,
    required this.secondaryHex,
    required this.durationMs,
    required this.scale,
    required this.icon,
    required this.description,
    required this.hapticPattern,
  });

  final UxFeedbackType type;
  final String primaryHex;
  final String secondaryHex;
  final int durationMs;
  final double scale;
  final String icon;
  final String description;
  final String hapticPattern;
}
