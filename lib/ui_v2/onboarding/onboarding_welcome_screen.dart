import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

/// Onboarding Welcome Screen
///
/// First screen in onboarding flow with greeting and "Start Learning" CTA.
class OnboardingWelcomeScreen extends StatefulWidget {
  const OnboardingWelcomeScreen({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<OnboardingWelcomeScreen> createState() =>
      _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

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
    final media = MediaQuery.of(context);
    final textScale = media.textScaler.scale(1.0);
    final compactLayout = media.size.height <= 700 || textScale > 1.05;
    final spacing = compactLayout ? 18.0 : (brand?.spacingLarge ?? 24.0);
    final heroPadding = compactLayout ? 18.0 : 24.0;
    final heroIconSize = compactLayout ? 52.0 : 64.0;
    final titleFontSize = compactLayout ? 28.0 : 32.0;
    final subtitleFontSize = compactLayout ? 14.0 : 16.0;
    final outerPadding = compactLayout ? 16.0 : spacing;
    final topSpacerFlex = compactLayout ? 2 : 4;
    final bottomSpacerFlex = compactLayout ? 1 : 3;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(outerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(flex: topSpacerFlex),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Hero Icon
                      Container(
                        padding: EdgeInsets.all(heroPadding),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              brand?.primaryBrand ?? Colors.teal,
                              (brand?.primaryBrand ?? Colors.teal).withValues(
                                alpha: 0.6,
                              ),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (brand?.primaryBrand ?? Colors.teal)
                                  .withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.school,
                          size: heroIconSize,
                          color:
                              brand?.textPrimary ?? AppColors.textPrimaryDark,
                        ),
                      ),
                      SizedBox(height: spacing),
                      // Welcome Title
                      Text(
                        'Welcome to\nPoker Analyzer',
                        key: const Key('onboarding_welcome_title'),
                        textAlign: TextAlign.center,
                        style: AppTypography.h1.copyWith(
                          fontSize: titleFontSize,
                          fontWeight:
                              brand?.fontWeightSemiBold ?? FontWeight.w600,
                          height: 1.2,
                          color:
                              brand?.textPrimary ?? AppColors.textPrimaryDark,
                        ),
                      ),
                      SizedBox(height: spacing / 2),
                      // Subtitle
                      Text(
                        'Master poker strategy through\nadaptive, AI-powered training',
                        key: const Key('onboarding_welcome_subtitle'),
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          fontSize: subtitleFontSize,
                          color:
                              brand?.textSecondary ??
                              AppColors.textSecondaryDark,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(flex: bottomSpacerFlex),
              // Start Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: _AnimatedButton(
                  buttonKey: const Key('onboarding_welcome_primary_cta'),
                  label: 'Start Learning',
                  icon: Icons.arrow_forward,
                  onPressed: widget.onNext,
                  isPrimary: true,
                  compact: compactLayout,
                ),
              ),
              SizedBox(height: spacing / 2),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated Button with tap feedback
class _AnimatedButton extends StatefulWidget {
  const _AnimatedButton({
    this.buttonKey,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.compact = false,
  });

  final Key? buttonKey;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool compact;

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 - (_controller.value * 0.05);
        return Transform.scale(scale: scale, child: child);
      },
      child: ElevatedButton(
        key: widget.buttonKey,
        onPressed: _handleTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isPrimary
              ? (brand?.primaryBrand ?? Colors.teal)
              : Colors.transparent,
          foregroundColor: widget.isPrimary
              ? (brand?.textPrimary ?? AppColors.textPrimaryDark)
              : (brand?.primaryBrand ?? Colors.teal),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 24 : 32,
            vertical: widget.compact ? 14 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(brand?.radius ?? 12),
            side: widget.isPrimary
                ? BorderSide.none
                : BorderSide(
                    color: (brand?.primaryBrand ?? Colors.teal).withValues(
                      alpha: 0.5,
                    ),
                    width: 2,
                  ),
          ),
          elevation: widget.isPrimary ? 6 : 0,
          shadowColor: widget.isPrimary
              ? (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.4)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.label,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: AppTypography.h3.copyWith(
                  fontSize: widget.compact ? 18 : AppTypography.h3.fontSize,
                  fontWeight: brand?.fontWeightSemiBold ?? FontWeight.w600,
                  color: widget.isPrimary
                      ? (brand?.textPrimary ?? AppColors.textPrimaryDark)
                      : (brand?.primaryBrand ?? Colors.teal),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(widget.icon, size: widget.compact ? 18 : 20),
          ],
        ),
      ),
    );
  }
}
