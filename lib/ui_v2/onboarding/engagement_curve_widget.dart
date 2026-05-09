import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/first3_retention_model_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _radius = 12.0;
const List<BoxShadow> _cardShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6)),
];

class EngagementCurveWidget extends StatelessWidget {
  const EngagementCurveWidget({super.key});

  Future<First3RetentionBundle> _loadData() =>
      First3RetentionModelService().run();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<First3RetentionBundle>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _placeholder(context, 'Curve warming up...');
        }
        if (snapshot.hasError) {
          return _placeholder(context, 'Curve unavailable');
        }
        final bundle = snapshot.data;
        if (bundle == null) {
          return _placeholder(context, 'Curve unavailable');
        }
        final engagementValues = [
          bundle.retentionEngagement,
          bundle.retentionClarity,
          bundle.retentionConfidence,
        ];
        final hint =
            'Engagement tier ${bundle.retentionTier} — keep focus steady';
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightCard,
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: _cardShadow,
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Engagement ${(bundle.retentionScore * 100).toStringAsFixed(0)}%',
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: engagementValues
                    .map((value) => _bar(context, value))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                hint,
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

  Widget _bar(BuildContext context, double value) {
    final height = (value * 80).clamp(10.0, 80.0);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primaryBrand.withOpacity(value),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, String message) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: _cardShadow,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Text(
        message,
        style: AppTypography.body.copyWith(color: AppColors.textSecondaryDark),
      ),
    );
  }
}
