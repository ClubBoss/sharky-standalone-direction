import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';

const String kModuleStartEntryLabel = 'ENTRY COST';
const String kModuleStartRewardLabel = 'WIN REWARD';

class UiGlassSheet extends StatelessWidget {
  const UiGlassSheet({
    super.key,
    required this.child,
    this.borderRadius = SharkyTokensV1.radiusLg,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: double.infinity,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.96),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    top: 0,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                      ),
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UiPillTag extends StatelessWidget {
  const UiPillTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs * 0.75,
      ),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.65),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusFull),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.label.copyWith(
          color: AppColors.textPrimaryDark,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class UiRewardRow extends StatelessWidget {
  const UiRewardRow({
    super.key,
    required this.entryCostValue,
    required this.winRewardValue,
  });

  final String entryCostValue;
  final String winRewardValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.85),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        gradient: LinearGradient(
          colors: [
            SharkyTokensV1.surfaceCard.withOpacity(0.95),
            SharkyTokensV1.surfaceCard.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _RewardColumn(
            icon: Icons.trending_down,
            iconColor: SharkyTokensV1.semanticLoss,
            label: kModuleStartEntryLabel,
            value: entryCostValue,
          ),
          const SizedBox(width: AppSpacing.lg),
          Container(
            width: 1,
            height: 42,
            color: Colors.white.withOpacity(0.16),
          ),
          const SizedBox(width: AppSpacing.lg),
          _RewardColumn(
            icon: Icons.trending_up,
            iconColor: SharkyTokensV1.semanticWin,
            label: kModuleStartRewardLabel,
            value: winRewardValue,
          ),
        ],
      ),
    );
  }
}

class _RewardColumn extends StatelessWidget {
  const _RewardColumn({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondaryDark,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          NumericText(
            value,
            style: SharkyTokensV1.headingMd.copyWith(
              fontSize: 18,
              color: AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class UiPrimaryCtaButton extends StatelessWidget {
  const UiPrimaryCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: SharkyTokensV1.semanticWin.withOpacity(0.35),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: SharkyTokensV1.semanticWin,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
            ),
          ),
          onPressed: () async => await onPressed(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.play_arrow,
                size: 20,
                color: AppColors.textPrimaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModuleStartBottomSheet extends StatelessWidget {
  const ModuleStartBottomSheet({
    super.key,
    required this.tagLabel,
    required this.title,
    required this.subtitle,
    required this.entryCostValue,
    required this.winRewardValue,
    required this.onPrimary,
    this.primaryLabel = 'PAY TO START',
    this.onClose,
  });

  final String tagLabel;
  final String title;
  final String subtitle;
  final String entryCostValue;
  final String winRewardValue;
  final String primaryLabel;
  final Future<void> Function() onPrimary;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: bottomPadding + AppSpacing.lg,
      ),
      child: UiGlassSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                UiPillTag(label: tagLabel),
                const Spacer(),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondaryDark,
                    ),
                    onPressed: onClose,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.h1.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              subtitle,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl - AppSpacing.md),
            Divider(color: Colors.white.withOpacity(0.08), thickness: 1),
            const SizedBox(height: AppSpacing.md),
            UiRewardRow(
              entryCostValue: entryCostValue,
              winRewardValue: winRewardValue,
            ),
            const SizedBox(height: AppSpacing.lg),
            UiPrimaryCtaButton(label: primaryLabel, onPressed: onPrimary),
          ],
        ),
      ),
    );
  }
}
