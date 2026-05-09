import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_completion_appearance_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_control_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_route_completion_boundary_v1.dart';

@immutable
class SharedLearnerLocalPolicyBoundaryV1 {
  const SharedLearnerLocalPolicyBoundaryV1({
    required this.continuationControlContract,
    required this.routeCompletionBoundary,
  });

  const SharedLearnerLocalPolicyBoundaryV1.hidden()
    : continuationControlContract =
          const SharedLearnerContinuationControlContractV1(
            continuationState: SharedLearnerContinuationStateV1.hidden(),
            isPrimaryBusy: false,
          ),
      routeCompletionBoundary =
          const SharedLearnerRouteCompletionBoundaryV1.hidden();

  final SharedLearnerContinuationControlContractV1 continuationControlContract;
  final SharedLearnerRouteCompletionBoundaryV1 routeCompletionBoundary;

  SharedLearnerContinuationStateV1 get continuationState =>
      continuationControlContract.continuationState;

  SharedLearnerCompletionAppearancePolicyV1 resolveActionAppearance({
    required bool showsPrimaryActionSurface,
  }) {
    return SharedLearnerCompletionAppearancePolicyV1.resolve(
      showsPrimaryActionSurface: showsPrimaryActionSurface,
      showsTrailingContinuation: continuationState.isVisible,
      continuationState: continuationState,
    );
  }
}
