import 'package:flutter/foundation.dart';

enum SharedLearnerContinuationVisualStateV1 {
  hidden,
  retryLike,
  continueLike,
  resetLike,
  completionLike,
}

@immutable
class SharedLearnerContinuationStateV1 {
  const SharedLearnerContinuationStateV1._({
    required this.visualState,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  const SharedLearnerContinuationStateV1.hidden()
    : this._(
        visualState: SharedLearnerContinuationVisualStateV1.hidden,
        primaryLabel: '',
        secondaryLabel: null,
      );

  factory SharedLearnerContinuationStateV1.visible({
    required SharedLearnerContinuationVisualStateV1 visualState,
    required String primaryLabel,
    String? secondaryLabel,
  }) {
    assert(visualState != SharedLearnerContinuationVisualStateV1.hidden);
    final normalizedPrimaryLabel = primaryLabel.trim();
    final normalizedSecondaryLabel = secondaryLabel?.trim();
    return SharedLearnerContinuationStateV1._(
      visualState: visualState,
      primaryLabel: normalizedPrimaryLabel,
      secondaryLabel:
          normalizedSecondaryLabel == null || normalizedSecondaryLabel.isEmpty
          ? null
          : normalizedSecondaryLabel,
    );
  }

  final SharedLearnerContinuationVisualStateV1 visualState;
  final String primaryLabel;
  final String? secondaryLabel;

  bool get isVisible =>
      visualState != SharedLearnerContinuationVisualStateV1.hidden;

  bool get showsSecondaryLabel =>
      secondaryLabel != null && secondaryLabel!.trim().isNotEmpty;
}
