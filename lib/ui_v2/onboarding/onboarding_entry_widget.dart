import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/persona_greeting_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

const double _defaultRadius = 12.0;
const double _defaultElevation = 6.0;

class OnboardingEntryWidget extends StatelessWidget {
  const OnboardingEntryWidget({
    super.key,
    this.bundleFuture,
    this.showUnavailableFallback = false,
  });

  final Future<PersonaGreetingBundle>? bundleFuture;
  final bool showUnavailableFallback;

  @override
  Widget build(BuildContext context) {
    if (showUnavailableFallback) {
      return _placeholder(
        context,
        title: 'Sharky could not load your guided start',
        body:
            'Your guided opener is unavailable right now, but the first step stays table-first and concrete.',
      );
    }
    return FutureBuilder<PersonaGreetingBundle>(
      future: bundleFuture ?? PersonaGreetingService().run(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _placeholder(
            context,
            title: 'Sharky is setting up your first table read',
            body:
                'You will start with one table picture, one clear next step, and one reason it matters.',
          );
        }
        if (snapshot.hasError) {
          return _placeholder(
            context,
            title: 'Sharky could not load your guided start',
            body:
                'Your guided opener is unavailable right now, but the first step stays table-first and concrete.',
          );
        }
        final bundle = snapshot.data;
        if (bundle == null) {
          return _placeholder(
            context,
            title: 'Sharky could not load your guided start',
            body:
                'Your guided opener is unavailable right now, but the first step stays table-first and concrete.',
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightCard,
            borderRadius: BorderRadius.circular(
              Theme.of(context).extension<BrandTheme>()?.radius ??
                  _defaultRadius,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius:
                    (Theme.of(context).extension<BrandTheme>()?.elevationMed ??
                        _defaultElevation) *
                    2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meet Sharky',
                key: const Key('onboarding_entry_persona_label'),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                bundle.greetingLine,
                key: const Key('onboarding_entry_greeting'),
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Sharky keeps the first session concrete: read one table picture, then make one reasoned move.',
                key: const Key('onboarding_entry_identity_promise'),
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                bundle.microIntroLine,
                key: const Key('onboarding_entry_micro_intro'),
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(
                    Theme.of(context).extension<BrandTheme>()?.radius ??
                        _defaultRadius,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your first concrete step',
                      key: const Key('onboarding_entry_action_label'),
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      bundle.recommendedFirstAction,
                      key: const Key('onboarding_entry_action_value'),
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'That first table read gives the next decision a reason instead of a guess.',
                      key: const Key('onboarding_entry_action_why'),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Divider(color: AppColors.outlineSoft, height: AppSpacing.sm),
              SizedBox(height: AppSpacing.xs),
              Text(
                bundle.motivationalHint,
                key: const Key('onboarding_entry_motivation'),
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

  Widget _placeholder(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          Theme.of(context).extension<BrandTheme>()?.radius ?? _defaultRadius,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius:
                (Theme.of(context).extension<BrandTheme>()?.elevationMed ??
                    _defaultElevation) *
                1.5,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Meet Sharky',
            key: const Key('onboarding_entry_placeholder_label'),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            key: const Key('onboarding_entry_placeholder_title'),
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            key: const Key('onboarding_entry_placeholder_body'),
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
