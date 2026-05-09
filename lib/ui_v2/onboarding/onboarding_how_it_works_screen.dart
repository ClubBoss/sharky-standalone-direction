import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

/// Onboarding How It Works Screen
///
/// Explains the adaptive training loop: difficulty and repetition adjustments.
class OnboardingHowItWorksScreen extends StatefulWidget {
  const OnboardingHowItWorksScreen({super.key});

  @override
  State<OnboardingHowItWorksScreen> createState() =>
      _OnboardingHowItWorksScreenState();
}

class _OnboardingHowItWorksScreenState extends State<OnboardingHowItWorksScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  void _showTrackContextExplainer() {
    final brand = Theme.of(context).extension<BrandTheme>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final textPrimary = brand?.textPrimary ?? AppColors.textPrimaryDark;
        final textSecondary =
            brand?.textSecondary ?? AppColors.textSecondaryDark;
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                key: const Key('onboarding_staged_model_explainer_sheet'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why the path starts shared',
                    key: const Key('onboarding_staged_model_explainer_title'),
                    style: AppTypography.h3.copyWith(
                      fontWeight: brand?.fontWeightSemiBold ?? FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The first worlds build one durable core: table anchors, action order, position, basic postflop purpose, and simple price awareness. That shared base helps you read the table before format-specific pressure starts changing the best line.',
                    key: const Key('onboarding_staged_model_explainer_core'),
                    style: AppTypography.body.copyWith(
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Formats split later because cash, tournament, and mixed environments change incentives in different ways. 6-max vs 9-max, antes, rake, and ICM pressure can all move the right decision even when the table picture looks similar.',
                    key: const Key('onboarding_staged_model_explainer_split'),
                    style: AppTypography.body.copyWith(
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'What changes later: more format-specific preflop ranges, pressure thresholds, risk management, and endgame rules. The early path teaches the foundation, not the final answer for every format.',
                    key: const Key('onboarding_staged_model_explainer_later'),
                    style: AppTypography.body.copyWith(
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingLarge ?? 24.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: spacing * 2),
              // Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'How It Works',
                  textAlign: TextAlign.center,
                  style: AppTypography.h1.copyWith(
                    fontSize: 28,
                    fontWeight: brand?.fontWeightSemiBold ?? FontWeight.w600,
                    color: brand?.textPrimary ?? AppColors.textPrimaryDark,
                  ),
                ),
              ),
              SizedBox(height: spacing / 2),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Start with one table-first core so your first real decision already has a reason.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: brand?.textSecondary ?? AppColors.textSecondaryDark,
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),
              // Feature Cards
              _buildFeatureCard(
                context: context,
                icon: Icons.trending_up,
                color: brand?.accentSuccess ?? AppColors.accentSuccess,
                title: 'Dynamic Difficulty',
                description:
                    'Training scenarios adjust to your current level so you build the shared core before layering on tougher spots.',
                delay: 0,
              ),
              SizedBox(height: spacing),
              _buildFeatureCard(
                context: context,
                icon: Icons.repeat,
                color: brand?.primaryBrand ?? Colors.teal,
                title: 'Smart Repetition',
                description:
                    'If a table concept is shaky, the system brings it back until the foundation is stable enough for later specialization.',
                delay: 150,
              ),
              SizedBox(height: spacing),
              _buildFeatureCard(
                context: context,
                icon: Icons.insights,
                color: brand?.accentWarning ?? AppColors.accentWarning,
                title: 'Real-Time Feedback',
                description:
                    'Get immediate feedback on the foundation you are practicing now, with deeper format-specific adjustments introduced later.',
                delay: 300,
              ),
              SizedBox(height: spacing * 1.5),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildTrustPrimerCard(context),
              ),
              SizedBox(height: spacing * 2),
              // Bottom illustration
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: (brand?.primaryBrand ?? Colors.teal).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(brand?.radius ?? 12),
                    border: Border.all(
                      color: (brand?.primaryBrand ?? Colors.teal).withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 48,
                        color: brand?.primaryBrand ?? Colors.teal,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Train through a shared core first, then add format-specific layers when the path branches later.',
                          style: AppTypography.body.copyWith(
                            fontWeight:
                                brand?.fontWeightMedium ?? FontWeight.w500,
                            color:
                                brand?.textPrimary ?? AppColors.textPrimaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required int delay,
  }) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(brand?.radius ?? 12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h3.copyWith(
                      fontWeight: brand?.fontWeightSemiBold ?? FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTypography.body.copyWith(
                      color:
                          brand?.textSecondary ?? AppColors.textSecondaryDark,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustPrimerCard(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final primary = brand?.textPrimary ?? AppColors.textPrimaryDark;
    final secondary = brand?.textSecondary ?? AppColors.textSecondaryDark;
    final accent = brand?.primaryBrand ?? Colors.teal;

    return Container(
      key: const Key('onboarding_staged_model_primer'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shared core first',
            key: const Key('onboarding_staged_model_primer_title'),
            style: AppTypography.h3.copyWith(
              fontWeight: brand?.fontWeightSemiBold ?? FontWeight.w600,
              color: primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your first sessions give you one concrete base: find the right seat, see who acts first, and connect that picture to the next decision. It is a foundation-first core, not final policy for every format and stack setup.',
            key: const Key('onboarding_staged_model_primer_core'),
            style: AppTypography.body.copyWith(color: secondary, height: 1.5),
          ),
          const SizedBox(height: 10),
          Text(
            'Why it matters: once Button, blinds, and action order are clear, the hand stops feeling random and your first choice starts having a reason.',
            key: const Key('onboarding_staged_model_primer_why'),
            style: AppTypography.body.copyWith(color: secondary, height: 1.5),
          ),
          const SizedBox(height: 10),
          Text(
            'What changes after that: later sessions add format pressure, stack depth, and specialization. Cash, tournament, and mixed paths come later because the first win is learning to read the table before the format changes the answer.',
            key: const Key('onboarding_staged_model_primer_warning'),
            style: AppTypography.body.copyWith(color: secondary, height: 1.5),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('onboarding_staged_model_learn_more'),
              onPressed: _showTrackContextExplainer,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Why shared core first?'),
            ),
          ),
        ],
      ),
    );
  }
}
