import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

class RunnerPromptStatusCapsuleV1 extends StatelessWidget {
  const RunnerPromptStatusCapsuleV1({
    super.key,
    required this.promptText,
    this.surfaceKey,
    this.statusText,
    this.statusTextKey,
    this.promptTextKey,
    this.onTap,
    this.foregroundColor,
    this.surfaceColor,
    this.borderColor,
    this.badgeColor,
    this.padding,
    this.compact = false,
    this.detailsLabel = 'Details',
    this.showChevron = true,
    this.maxPromptLines = 1,
    this.promptSoftWrap = false,
    this.promptOverflow = TextOverflow.ellipsis,
  });

  final Key? surfaceKey;
  final String? statusText;
  final Key? statusTextKey;
  final String promptText;
  final Key? promptTextKey;
  final VoidCallback? onTap;
  final Color? foregroundColor;
  final Color? surfaceColor;
  final Color? borderColor;
  final Color? badgeColor;
  final EdgeInsetsGeometry? padding;
  final bool compact;
  final String detailsLabel;
  final bool showChevron;
  final int maxPromptLines;
  final bool promptSoftWrap;
  final TextOverflow promptOverflow;

  @override
  Widget build(BuildContext context) {
    final resolvedForeground =
        foregroundColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final resolvedSurface =
        surfaceColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: compact ? 0.18 : 0.42,
        );
    final resolvedBorder =
        borderColor ??
        Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: compact ? 0.18 : 0.46);
    final resolvedBadge =
        badgeColor ??
        resolvedForeground.withValues(alpha: compact ? 0.055 : 0.1);
    final detailsColor = resolvedForeground.withValues(
      alpha: compact ? 0.66 : 0.9,
    );
    final status = statusText?.trim();
    final useStackedCompactPromptLayout =
        compact && (promptSoftWrap || maxPromptLines > 1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: surfaceKey,
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: resolvedSurface,
            borderRadius: BorderRadius.circular(compact ? 16 : 18),
            border: Border.all(color: resolvedBorder),
          ),
          child: Padding(
            padding:
                padding ??
                EdgeInsets.fromLTRB(
                  compact ? 6 : 10,
                  compact ? 1.5 : 6,
                  compact ? 6 : 10,
                  compact ? 1.5 : 6,
                ),
            child: useStackedCompactPromptLayout
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status != null && status.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 4.5 : 8,
                            vertical: compact ? 0.5 : 3,
                          ),
                          decoration: BoxDecoration(
                            color: resolvedBadge,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status,
                            key: statusTextKey,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: resolvedForeground,
                              fontWeight: compact
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              fontSize: compact ? 9.0 : 10.6,
                              height: 1.0,
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 3 : 6),
                      ],
                      Text(
                        promptText,
                        key: promptTextKey,
                        maxLines: maxPromptLines,
                        overflow: promptOverflow,
                        softWrap: promptSoftWrap,
                        style: AppTypography.caption.copyWith(
                          color: resolvedForeground,
                          fontWeight: compact
                              ? FontWeight.w600
                              : FontWeight.w700,
                          fontSize: compact ? 9.8 : 11.4,
                          height: compact ? 1.05 : 1.12,
                        ),
                      ),
                      SizedBox(height: compact ? 3 : 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showChevron)
                              Padding(
                                padding: EdgeInsets.only(
                                  right: compact ? 1 : 2,
                                ),
                                child: Icon(
                                  Icons.expand_more_rounded,
                                  size: compact ? 13 : 16,
                                  color: detailsColor,
                                ),
                              ),
                            Text(
                              detailsLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: detailsColor,
                                fontWeight: compact
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                                fontSize: compact ? 9.0 : 10.8,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      if (status != null && status.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 4.5 : 8,
                            vertical: compact ? 0.5 : 3,
                          ),
                          decoration: BoxDecoration(
                            color: resolvedBadge,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status,
                            key: statusTextKey,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: resolvedForeground,
                              fontWeight: compact
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              fontSize: compact ? 9.0 : 10.6,
                              height: 1.0,
                            ),
                          ),
                        ),
                        SizedBox(width: compact ? 5 : 10),
                      ],
                      Expanded(
                        child: Text(
                          promptText,
                          key: promptTextKey,
                          maxLines: maxPromptLines,
                          overflow: promptOverflow,
                          softWrap: promptSoftWrap,
                          style: AppTypography.caption.copyWith(
                            color: resolvedForeground,
                            fontWeight: compact
                                ? FontWeight.w600
                                : FontWeight.w700,
                            fontSize: compact ? 9.8 : 11.4,
                            height: compact ? 1.05 : 1.12,
                          ),
                        ),
                      ),
                      SizedBox(width: compact ? 5 : 10),
                      if (showChevron)
                        Padding(
                          padding: EdgeInsets.only(right: compact ? 1 : 2),
                          child: Icon(
                            Icons.expand_more_rounded,
                            size: compact ? 13 : 16,
                            color: detailsColor,
                          ),
                        ),
                      Text(
                        detailsLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: detailsColor,
                          fontWeight: compact
                              ? FontWeight.w600
                              : FontWeight.w700,
                          fontSize: compact ? 9.0 : 10.8,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
