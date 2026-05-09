import 'package:flutter/material.dart';

class RunnerCompactHeaderBandV1 extends StatelessWidget {
  const RunnerCompactHeaderBandV1({
    super.key,
    this.surfaceKey,
    this.statusText,
    this.statusTextKey,
    required this.headlineText,
    this.headlineTextKey,
    this.trailing,
    this.bottomChild,
    this.compact = false,
    this.surfaceColor,
    this.borderColor,
    this.statusColor,
    this.headlineColor,
    this.surfacePadding,
    this.bottomChildGap,
  });

  final Key? surfaceKey;
  final String? statusText;
  final Key? statusTextKey;
  final String headlineText;
  final Key? headlineTextKey;
  final Widget? trailing;
  final Widget? bottomChild;
  final bool compact;
  final Color? surfaceColor;
  final Color? borderColor;
  final Color? statusColor;
  final Color? headlineColor;
  final EdgeInsetsGeometry? surfacePadding;
  final double? bottomChildGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedSurface =
        surfaceColor ??
        theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: compact ? 0.18 : 0.28,
        );
    final resolvedBorder =
        borderColor ??
        theme.colorScheme.outlineVariant.withValues(
          alpha: compact ? 0.18 : 0.32,
        );
    final resolvedStatus =
        statusColor ??
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9);
    final resolvedHeadline = headlineColor ?? theme.colorScheme.onSurface;
    final trimmedStatus = statusText?.trim();

    return Container(
      key: surfaceKey,
      width: double.infinity,
      padding:
          surfacePadding ??
          EdgeInsets.fromLTRB(
            compact ? 6 : 10,
            compact ? 4 : 8,
            compact ? 6 : 10,
            compact ? 4 : 8,
          ),
      decoration: BoxDecoration(
        color: resolvedSurface,
        borderRadius: BorderRadius.circular(compact ? 15 : 18),
        border: Border.all(color: resolvedBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trimmedStatus != null && trimmedStatus.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: compact ? 2 : 6),
              child: Text(
                trimmedStatus,
                key: statusTextKey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: resolvedStatus,
                  fontWeight: compact ? FontWeight.w600 : FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  headlineText,
                  key: headlineTextKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: resolvedHeadline,
                    fontWeight: compact ? FontWeight.w700 : FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: compact ? 5 : 8),
                trailing!,
              ],
            ],
          ),
          if (bottomChild != null) ...[
            SizedBox(height: bottomChildGap ?? (compact ? 4 : 8)),
            bottomChild!,
          ],
        ],
      ),
    );
  }
}
