import 'package:flutter/widgets.dart';

const double kSharedLearnerTeachingCompactSupportSpacingV1 = 6;

@immutable
class SharedLearnerTeachingSectionStackV1 extends StatelessWidget {
  const SharedLearnerTeachingSectionStackV1({
    super.key,
    this.preTeachingBlocks = const <Widget>[],
    this.teachingBlock,
    this.localBlocksBeforeAction = const <Widget>[],
    this.actionSurface,
    this.postActionBlocks = const <Widget>[],
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.sectionSpacing = 0,
  });

  final List<Widget> preTeachingBlocks;
  final Widget? teachingBlock;
  final List<Widget> localBlocksBeforeAction;
  final Widget? actionSurface;
  final List<Widget> postActionBlocks;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double sectionSpacing;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    void appendGroup(List<Widget> group) {
      if (group.isEmpty) {
        return;
      }
      if (children.isNotEmpty && sectionSpacing > 0) {
        children.add(SizedBox(height: sectionSpacing));
      }
      children.addAll(group);
    }

    appendGroup(preTeachingBlocks);
    if (teachingBlock != null) {
      appendGroup(<Widget>[teachingBlock!]);
    }
    appendGroup(localBlocksBeforeAction);
    if (actionSurface != null) {
      appendGroup(<Widget>[actionSurface!]);
    }
    appendGroup(postActionBlocks);

    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}
