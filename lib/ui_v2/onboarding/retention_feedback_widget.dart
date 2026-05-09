import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/first3_retention_model_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

class RetentionFeedbackWidget extends StatelessWidget {
  const RetentionFeedbackWidget({super.key});

  Future<First3RetentionBundle> _loadRetention() =>
      First3RetentionModelService().run();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<First3RetentionBundle>(
      future: _loadRetention(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _placeholder(context, 'Retention metrics warming up...');
        }
        if (snapshot.hasError) {
          return _placeholder(context, 'Retention feedback unavailable');
        }
        final bundle = snapshot.data;
        if (bundle == null) {
          return _placeholder(context, 'Retention feedback unavailable');
        }
        final brand = Theme.of(context).extension<BrandTheme>();
        final radius = brand?.radius ?? 12.0;
        final blur = (brand?.elevationMed ?? 4.0) * 1.5;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: blur,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Retention score ${(bundle.retentionScore * 100).toStringAsFixed(0)}%',
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metricPill('Clarity', bundle.retentionClarity),
                  _metricPill('Engagement', bundle.retentionEngagement),
                  _metricPill('Confidence', bundle.retentionConfidence),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Retention tier: ${bundle.retentionTier}',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricPill(String label, double value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: AppColors.outlineSoft),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              (value * 100).toStringAsFixed(0),
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, String message) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final radius = brand?.radius ?? 12.0;
    final blur = brand?.elevationLow ?? 2.0;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: blur,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Text(
        message,
        style: AppTypography.body.copyWith(color: AppColors.textSecondaryDark),
      ),
    );
  }
}
