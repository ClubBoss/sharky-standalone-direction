import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_bottom_action_presentation_stack_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_local_policy_boundary_v1.dart';

typedef SharedLearnerActionSurfaceBuilderV1 =
    Widget? Function(
      BuildContext context,
      SharedLearnerLocalPolicyBoundaryV1 localPolicyBoundary,
    );

class SharedLearnerActionSurfaceOwnerV1 extends StatelessWidget {
  const SharedLearnerActionSurfaceOwnerV1({
    super.key,
    this.preActionChildren = const <Widget>[],
    this.postActionChildren = const <Widget>[],
    required this.localPolicyBoundary,
    this.buildPrimaryActionSurface,
    this.buildTrailingContinuation,
    this.continuationPadding = const EdgeInsets.fromLTRB(12, 8, 12, 12),
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final List<Widget> preActionChildren;
  final List<Widget> postActionChildren;
  final SharedLearnerLocalPolicyBoundaryV1 localPolicyBoundary;
  final SharedLearnerActionSurfaceBuilderV1? buildPrimaryActionSurface;
  final SharedLearnerActionSurfaceBuilderV1? buildTrailingContinuation;
  final EdgeInsetsGeometry continuationPadding;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final actionSurfaceCandidate = buildPrimaryActionSurface?.call(
      context,
      localPolicyBoundary,
    );
    final appearancePolicy = localPolicyBoundary.resolveActionAppearance(
      showsPrimaryActionSurface: actionSurfaceCandidate != null,
    );
    final actionSurface = appearancePolicy.showsPrimaryActionSurface
        ? actionSurfaceCandidate
        : null;
    final continuationChild = appearancePolicy.showsTrailingContinuation
        ? buildTrailingContinuation?.call(context, localPolicyBoundary)
        : null;
    return SharedLearnerBottomActionPresentationStackV1(
      preActionChildren: preActionChildren,
      actionSurface: actionSurface,
      crossAxisAlignment: crossAxisAlignment,
      trailingChildren: <Widget>[
        ...postActionChildren,
        if (continuationChild != null)
          Padding(padding: continuationPadding, child: continuationChild),
      ],
    );
  }
}
