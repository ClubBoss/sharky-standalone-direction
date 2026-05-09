import 'package:flutter/material.dart';

class RunnerSceneSupportLaneV1 extends StatelessWidget {
  const RunnerSceneSupportLaneV1({
    super.key,
    this.surfaceKey,
    required this.child,
    this.compact = false,
    this.contentPadding,
    this.surfaceColor,
    this.borderColor,
  });

  final Key? surfaceKey;
  final Widget child;
  final bool compact;
  final EdgeInsetsGeometry? contentPadding;
  final Color? surfaceColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedSurface =
        surfaceColor ??
        theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.42);
    final resolvedBorder =
        borderColor ?? theme.colorScheme.outlineVariant.withValues(alpha: 0.18);

    return DecoratedBox(
      key: surfaceKey,
      decoration: BoxDecoration(
        color: resolvedSurface,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        border: Border.all(color: resolvedBorder),
      ),
      child: Padding(
        padding:
            contentPadding ??
            EdgeInsets.fromLTRB(
              compact ? 7 : 10,
              compact ? 5 : 8,
              compact ? 7 : 10,
              compact ? 6 : 10,
            ),
        child: child,
      ),
    );
  }
}
