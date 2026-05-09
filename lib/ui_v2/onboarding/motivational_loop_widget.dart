import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/adaptive_onboarding_script_service.dart';
import 'package:poker_analyzer/services/smart_cta_planner_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

class MotivationalLoopWidget extends StatelessWidget {
  const MotivationalLoopWidget({super.key});

  Future<_LoopPayload> _loadPayload() async {
    final script = await AdaptiveOnboardingScriptService().run();
    final cta = await SmartCtaPlannerService().run();
    return _LoopPayload(
      scriptMicroGuidance: script.microGuidanceBlock,
      primaryCta: cta.primaryCta,
      secondaryCta: cta.secondaryCta,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LoopPayload>(
      future: _loadPayload(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _placeholder(context, 'Motivational loop warming up...');
        }
        if (snapshot.hasError) {
          return _placeholder(context, 'Motivational loop unavailable');
        }
        final payload = snapshot.data;
        if (payload == null) {
          return _placeholder(context, 'Motivational loop unavailable');
        }
        final brand = Theme.of(context).extension<BrandTheme>();
        final radius = brand?.radius ?? 12.0;
        final blur = (brand?.elevationMed ?? 4.0) * 2;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightCard,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: blur,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payload.primaryCta,
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                payload.secondaryCta,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadii.m),
                ),
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  payload.scriptMicroGuidance,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholder(BuildContext context, String message) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final radius = brand?.radius ?? 12.0;
    final blur = (brand?.elevationLow ?? 2.0) * 1.5;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: blur,
            offset: const Offset(0, 4),
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

class _LoopPayload {
  _LoopPayload({
    required this.primaryCta,
    required this.secondaryCta,
    required this.scriptMicroGuidance,
  });

  final String primaryCta;
  final String secondaryCta;
  final String scriptMicroGuidance;
}

class AppRadii {
  AppRadii._();

  static const double m = 12.0;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6)),
  ];
}
