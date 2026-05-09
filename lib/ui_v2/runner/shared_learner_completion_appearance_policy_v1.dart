import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_state_v1.dart';

enum SharedLearnerActionPresentationModeV1 {
  hidden,
  primaryOnly,
  primaryWithTrailingContinuation,
  trailingContinuationOnly,
}

@immutable
class SharedLearnerCompletionAppearancePolicyV1 {
  const SharedLearnerCompletionAppearancePolicyV1({
    required this.mode,
    required this.continuationState,
  });

  factory SharedLearnerCompletionAppearancePolicyV1.resolve({
    required bool showsPrimaryActionSurface,
    required bool showsTrailingContinuation,
    required SharedLearnerContinuationStateV1 continuationState,
  }) {
    return SharedLearnerCompletionAppearancePolicyV1(
      mode: switch ((showsPrimaryActionSurface, showsTrailingContinuation)) {
        (false, false) => SharedLearnerActionPresentationModeV1.hidden,
        (true, false) => SharedLearnerActionPresentationModeV1.primaryOnly,
        (true, true) =>
          SharedLearnerActionPresentationModeV1.primaryWithTrailingContinuation,
        (false, true) =>
          SharedLearnerActionPresentationModeV1.trailingContinuationOnly,
      },
      continuationState: continuationState,
    );
  }

  final SharedLearnerActionPresentationModeV1 mode;
  final SharedLearnerContinuationStateV1 continuationState;

  bool get showsPrimaryActionSurface =>
      mode == SharedLearnerActionPresentationModeV1.primaryOnly ||
      mode ==
          SharedLearnerActionPresentationModeV1.primaryWithTrailingContinuation;

  bool get showsTrailingContinuation =>
      mode ==
          SharedLearnerActionPresentationModeV1
              .primaryWithTrailingContinuation ||
      mode == SharedLearnerActionPresentationModeV1.trailingContinuationOnly;

  bool get showsCompletionLikeTrailingContinuation =>
      showsTrailingContinuation &&
      continuationState.visualState ==
          SharedLearnerContinuationVisualStateV1.completionLike;
}
