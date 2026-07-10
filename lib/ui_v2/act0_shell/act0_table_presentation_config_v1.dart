import 'act0_shell_state_v1.dart';

/// Data-only input for reusable Act0 table presentation consumers.
///
/// It deliberately excludes runner phase, route, progress, correctness, and
/// private runner enums. The canonical poker state stays in [Act0TableStateV1].
enum Act0TableIdentityPolicyV1 {
  currentProduction,
  learnerOnly,
  learnerPosition,
  learnerPositionAndDealerOrder,
}

/// Maps source-owned teaching semantics to presentation policy. It does not
/// inspect English copy, route identity, widget state, or layout.
Act0TableIdentityPolicyV1 act0TableIdentityPolicyForTeachingSemanticsV1(
  Act0TableIdentityTeachingSemanticsV1 semantics,
) => switch (semantics) {
  Act0TableIdentityTeachingSemanticsV1.legacy =>
    Act0TableIdentityPolicyV1.currentProduction,
  Act0TableIdentityTeachingSemanticsV1.learnerOnly =>
    Act0TableIdentityPolicyV1.learnerOnly,
  Act0TableIdentityTeachingSemanticsV1.position =>
    Act0TableIdentityPolicyV1.learnerPosition,
  Act0TableIdentityTeachingSemanticsV1.dealerOrder =>
    Act0TableIdentityPolicyV1.learnerPositionAndDealerOrder,
};

class Act0TablePresentationConfigV1 {
  const Act0TablePresentationConfigV1({
    this.maxTableHeight,
    this.useRefinedVisualVariant = true,
    this.showFocusBadge = true,
    this.showRepairCallout = false,
    this.compactBottomDockClearance = false,
    this.identityPolicy = Act0TableIdentityPolicyV1.currentProduction,
    this.highlightedCardIds = const <String>[],
  });

  final double? maxTableHeight;
  final bool useRefinedVisualVariant;
  final bool showFocusBadge;
  final bool showRepairCallout;
  final bool compactBottomDockClearance;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final List<String> highlightedCardIds;
}
