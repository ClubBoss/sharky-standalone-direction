import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

class NextActionStripV1 extends StatelessWidget {
  const NextActionStripV1({
    super.key,
    required this.title,
    required this.value,
    this.compact = false,
    this.titleKey,
    this.valueKey,
    this.borderColor,
    this.trailing,
    this.semanticsLabel,
    this.semanticsValue,
    this.semanticsHint,
  });

  final String title;
  final String value;
  final bool compact;
  final Key? titleKey;
  final Key? valueKey;
  final Color? borderColor;
  final Widget? trailing;
  final String? semanticsLabel;
  final String? semanticsValue;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    final verticalPadding = compact ? AppSpacing.xs : AppSpacing.sm;
    final horizontalPadding = compact ? AppSpacing.sm : AppSpacing.md;
    final titleStyle = AppTypography.caption.copyWith(
      color: SharkyTokensV1.textSecondary,
      fontWeight: FontWeight.w700,
      letterSpacing: compact ? 0.2 : 0.4,
      fontSize: compact ? 11 : null,
    );
    final valueStyle = AppTypography.body.copyWith(
      color: SharkyTokensV1.textPrimary,
      fontSize: compact ? 14 : null,
      height: compact ? 1.2 : null,
      fontWeight: FontWeight.w600,
    );
    return Semantics(
      label: semanticsLabel ?? '$title. $value',
      value: semanticsValue ?? value,
      hint: semanticsHint,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        constraints: BoxConstraints(minHeight: compact ? 0 : 64),
        decoration: BoxDecoration(
          color: SharkyTokensV1.surfaceCard.withOpacity(0.78),
          borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
          border: Border.all(
            color: borderColor ?? SharkyTokensV1.slate600.withOpacity(0.72),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              key: titleKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
            SizedBox(height: compact ? 2 : 4),
            Text(
              value,
              key: valueKey,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
            if (trailing != null) ...[
              SizedBox(height: compact ? 4 : 6),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
