import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

/// Onboarding Interface Guide Screen
///
/// Shows table/HUD visuals with captions explaining the UI elements.
class OnboardingInterfaceGuideScreen extends StatefulWidget {
  const OnboardingInterfaceGuideScreen({super.key});

  @override
  State<OnboardingInterfaceGuideScreen> createState() =>
      _OnboardingInterfaceGuideScreenState();
}

class _OnboardingInterfaceGuideScreenState
    extends State<OnboardingInterfaceGuideScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

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
                  'Your Training Interface',
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
                  'Navigate your poker training with ease',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: brand?.textSecondary ?? AppColors.textSecondaryDark,
                  ),
                ),
              ),
              SizedBox(height: spacing * 2),
              // HUD Section
              _buildInterfaceSection(
                context: context,
                icon: Icons.dashboard,
                color: brand?.primaryBrand ?? Colors.teal,
                title: 'HUD Overlay',
                description:
                    'Track your energy, XP, level, and league tier in real-time. Monitor performance metrics as you play.',
                delay: 0,
              ),
              SizedBox(height: spacing),
              // Table Section
              _buildInterfaceSection(
                context: context,
                icon: Icons.table_restaurant,
                color: brand?.accentSuccess ?? AppColors.accentSuccess,
                title: 'Poker Table',
                description:
                    'Interactive table simulation with player positions, cards, and pot. Make decisions just like real poker.',
                delay: 150,
              ),
              SizedBox(height: spacing),
              // Action Buttons Section
              _buildInterfaceSection(
                context: context,
                icon: Icons.touch_app,
                color: brand?.accentWarning ?? AppColors.accentWarning,
                title: 'Action Controls',
                description:
                    'Fold, Call, or Raise with intuitive buttons. Each action shows pot odds and recommended plays.',
                delay: 300,
              ),
              SizedBox(height: spacing),
              // Progress Section
              _buildInterfaceSection(
                context: context,
                icon: Icons.insights,
                color: Colors.purple,
                title: 'Progress Map',
                description:
                    'Visualize your learning journey through skill trees. Unlock new concepts as you master fundamentals.',
                delay: 450,
              ),
              SizedBox(height: spacing * 2),
              // Visual Preview
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(brand?.radius ?? 12),
                    border: Border.all(
                      color: (brand?.primaryBrand ?? Colors.teal).withValues(
                        alpha: 0.3,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Simulated HUD badges
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniHudBadge(
                              context,
                              Icons.bolt,
                              '10/12',
                              brand?.accentWarning ?? AppColors.accentWarning,
                            ),
                            _buildMiniHudBadge(
                              context,
                              Icons.star,
                              'L5',
                              brand?.primaryBrand ?? Colors.teal,
                            ),
                            _buildMiniHudBadge(
                              context,
                              Icons.emoji_events,
                              'Gold',
                              brand?.accentSuccess ?? AppColors.accentSuccess,
                            ),
                          ],
                        ),
                      ),
                      // Center table indicator
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: (brand?.primaryBrand ?? Colors.teal)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: (brand?.primaryBrand ?? Colors.teal)
                                  .withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            'POKER TABLE',
                            style: AppTypography.caption.copyWith(
                              color: brand?.primaryBrand ?? Colors.teal,
                              fontWeight:
                                  brand?.fontWeightSemiBold ?? FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Bottom action buttons indicator
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMiniActionButton(context, 'FOLD', Colors.red),
                            _buildMiniActionButton(
                              context,
                              'CALL',
                              brand?.accentWarning ?? AppColors.accentWarning,
                            ),
                            _buildMiniActionButton(
                              context,
                              'RAISE',
                              brand?.accentSuccess ?? AppColors.accentSuccess,
                            ),
                          ],
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

  Widget _buildInterfaceSection({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(brand?.radius ?? 12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h3.copyWith(
                      fontSize: 16,
                      fontWeight: brand?.fontWeightSemiBold ?? FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color:
                          brand?.textSecondary ?? AppColors.textSecondaryDark,
                      height: 1.4,
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

  Widget _buildMiniHudBadge(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              color: color,
              fontWeight: brand?.fontWeightMedium ?? FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniActionButton(
    BuildContext context,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
