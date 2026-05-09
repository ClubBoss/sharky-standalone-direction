import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_state_v1.dart';

@immutable
class SharedLearnerContinuationControlContractV1 {
  const SharedLearnerContinuationControlContractV1({
    required this.continuationState,
    required this.isPrimaryBusy,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.statusHeader,
    this.bodyText,
  });

  final SharedLearnerContinuationStateV1 continuationState;
  final bool isPrimaryBusy;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final String? statusHeader;
  final String? bodyText;

  String get primaryLabel => continuationState.primaryLabel;
  String? get secondaryLabel => continuationState.secondaryLabel;

  bool get showsSecondaryAction =>
      secondaryLabel != null &&
      secondaryLabel!.trim().isNotEmpty &&
      onSecondaryPressed != null;

  bool get showsCompletionChrome =>
      continuationState.visualState ==
          SharedLearnerContinuationVisualStateV1.completionLike &&
      ((statusHeader?.trim().isNotEmpty ?? false) ||
          (bodyText?.trim().isNotEmpty ?? false));
}
