import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_how_it_works_screen.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_interface_guide_screen.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_preferences_service.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_welcome_screen.dart';

/// Onboarding Coordinator
///
/// Manages the onboarding flow with PageView, Skip/Next navigation,
/// and completion tracking via SharedPreferences.
class OnboardingCoordinator extends StatefulWidget {
  const OnboardingCoordinator({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingCoordinator> createState() => _OnboardingCoordinatorState();
}

class _OnboardingCoordinatorState extends State<OnboardingCoordinator> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await OnboardingPreferencesService.setOnboardingComplete();
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingMedium ?? 16.0;

    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            physics: const ClampingScrollPhysics(),
            children: [
              OnboardingWelcomeScreen(onNext: _nextPage),
              const OnboardingHowItWorksScreen(),
              const OnboardingInterfaceGuideScreen(),
            ],
          ),
          // Navigation Controls (only show on pages 2 and 3)
          if (_currentPage > 0)
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(spacing),
                child: Column(
                  children: [
                    // Top navigation bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        _NavButton(
                          icon: Icons.arrow_back,
                          label: 'Back',
                          onPressed: _previousPage,
                        ),
                        // Page indicator
                        Row(
                          children: List.generate(
                            _totalPages,
                            (index) => _PageDot(
                              isActive: index == _currentPage,
                              brand: brand,
                            ),
                          ),
                        ),
                        // Skip button
                        _NavButton(
                          icon: Icons.close,
                          label: 'Skip',
                          onPressed: _completeOnboarding,
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Bottom Next/Finish button
                    _AnimatedButton(
                      label: _currentPage == _totalPages - 1
                          ? 'Get Started'
                          : 'Next',
                      icon: _currentPage == _totalPages - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                      onPressed: _nextPage,
                      isPrimary: true,
                    ),
                    SizedBox(height: spacing),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Navigation Button
class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
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
        final scale = 1.0 - (_controller.value * 0.1);
        final opacity = 1.0 - (_controller.value * 0.3);
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (brand?.primaryBrand ?? Colors.teal).withValues(
                alpha: 0.3,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: brand?.textPrimary ?? AppColors.textPrimaryDark,
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: AppTypography.caption.copyWith(
                  color: brand?.textPrimary ?? AppColors.textPrimaryDark,
                  fontWeight: brand?.fontWeightMedium ?? FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page Indicator Dot
class _PageDot extends StatelessWidget {
  const _PageDot({required this.isActive, required this.brand});

  final bool isActive;
  final BrandTheme? brand;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? (brand?.primaryBrand ?? Colors.teal)
            : (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: (brand?.primaryBrand ?? Colors.teal).withValues(
                    alpha: 0.4,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

/// Animated Button with tap feedback
class _AnimatedButton extends StatefulWidget {
  const _AnimatedButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isPrimary
                ? (brand?.primaryBrand ?? Colors.teal)
                : Colors.transparent,
            foregroundColor: widget.isPrimary
                ? (brand?.textPrimary ?? AppColors.textPrimaryDark)
                : (brand?.primaryBrand ?? Colors.teal),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
            children: [
              Text(
                widget.label,
                style: AppTypography.h3.copyWith(
                  fontWeight: brand?.fontWeightSemiBold ?? FontWeight.w600,
                  color: widget.isPrimary
                      ? (brand?.textPrimary ?? AppColors.textPrimaryDark)
                      : (brand?.primaryBrand ?? Colors.teal),
                ),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
