import 'package:flutter/widgets.dart';

typedef SharedLearnerExtrasChildrenBuilderV1 =
    List<Widget> Function(BuildContext context);

class SharedLearnerFamilyExtrasSlotsV1 {
  const SharedLearnerFamilyExtrasSlotsV1({
    this.beforePrimaryActionChildren = const <Widget>[],
    this.afterPrimaryActionChildren = const <Widget>[],
    this.buildPromptRevealExtraChildren,
  });

  const SharedLearnerFamilyExtrasSlotsV1.empty()
    : beforePrimaryActionChildren = const <Widget>[],
      afterPrimaryActionChildren = const <Widget>[],
      buildPromptRevealExtraChildren = null;

  final List<Widget> beforePrimaryActionChildren;
  final List<Widget> afterPrimaryActionChildren;
  final SharedLearnerExtrasChildrenBuilderV1? buildPromptRevealExtraChildren;

  List<Widget> resolvePromptRevealExtraChildren(BuildContext context) =>
      buildPromptRevealExtraChildren?.call(context) ?? const <Widget>[];

  SharedLearnerFamilyExtrasSlotsV1 merge(
    SharedLearnerFamilyExtrasSlotsV1 other,
  ) {
    final mergedRevealBuilder =
        buildPromptRevealExtraChildren == null &&
            other.buildPromptRevealExtraChildren == null
        ? null
        : (BuildContext context) => <Widget>[
            ...resolvePromptRevealExtraChildren(context),
            ...other.resolvePromptRevealExtraChildren(context),
          ];
    return SharedLearnerFamilyExtrasSlotsV1(
      beforePrimaryActionChildren: <Widget>[
        ...beforePrimaryActionChildren,
        ...other.beforePrimaryActionChildren,
      ],
      afterPrimaryActionChildren: <Widget>[
        ...afterPrimaryActionChildren,
        ...other.afterPrimaryActionChildren,
      ],
      buildPromptRevealExtraChildren: mergedRevealBuilder,
    );
  }
}
