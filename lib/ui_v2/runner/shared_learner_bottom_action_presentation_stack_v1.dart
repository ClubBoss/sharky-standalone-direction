import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';

class SharedLearnerBottomActionPresentationStackV1 extends StatelessWidget {
  const SharedLearnerBottomActionPresentationStackV1({
    super.key,
    this.preActionChildren = const <Widget>[],
    this.actionSurface,
    this.trailingChildren = const <Widget>[],
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.contentSpacing = AppSpacing.xs,
    this.padding = EdgeInsets.zero,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = SharkyTokensV1.radiusMd,
  });

  final List<Widget> preActionChildren;
  final Widget? actionSurface;
  final List<Widget> trailingChildren;
  final CrossAxisAlignment crossAxisAlignment;
  final double contentSpacing;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      ...preActionChildren,
      if (actionSurface != null) actionSurface!,
      ...trailingChildren,
    ];
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            SharkyTokensV1.surfaceCard.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? SharkyTokensV1.slate600.withValues(alpha: 0.38),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) SizedBox(height: contentSpacing),
              children[index],
            ],
          ],
        ),
      ),
    );
  }
}
