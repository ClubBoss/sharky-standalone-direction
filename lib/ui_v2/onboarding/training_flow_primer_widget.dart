import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/smart_cta_planner_service.dart';
import 'package:poker_analyzer/services/training_path_visualizer_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _radius = 12.0;
const List<BoxShadow> _cardShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6)),
];

class TrainingFlowPrimerWidget extends StatelessWidget {
  const TrainingFlowPrimerWidget({super.key});

  Future<_PrimerPayload> _loadPayload() async {
    final results = await Future.wait([
      SmartCtaPlannerService().run(),
      TrainingPathVisualizerService().build(),
    ]);
    final cta = results[0] as SmartCtaBundle;
    final path = results[1] as TrainingPathVisualization;
    final recommendedModule = path.pathNodes.isNotEmpty
        ? path.pathNodes.first['module'] as String? ?? 'Next module'
        : 'Next module';
    return _PrimerPayload(
      header: 'Your next step',
      primaryCta: cta.primaryCta,
      recommendedModule: recommendedModule,
      hint: 'Keep the energy steady with structured focus.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PrimerPayload>(
      future: _loadPayload(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _placeholder(context, 'Primer loading...');
        }
        if (snapshot.hasError) {
          return _placeholder(context, 'Primer unavailable');
        }
        final payload = snapshot.data;
        if (payload == null) {
          return _placeholder(context, 'Primer unavailable');
        }
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: _cardShadow,
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payload.header,
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                payload.primaryCta,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Recommended module: ${payload.recommendedModule}',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                payload.hint,
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

  Widget _placeholder(BuildContext context, String message) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
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

class _PrimerPayload {
  _PrimerPayload({
    required this.header,
    required this.primaryCta,
    required this.recommendedModule,
    required this.hint,
  });

  final String header;
  final String primaryCta;
  final String recommendedModule;
  final String hint;
}
