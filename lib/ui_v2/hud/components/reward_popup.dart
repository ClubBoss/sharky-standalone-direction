import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

/// An animated popup displaying XP/Chips reward notifications.
///
/// Floats upward for 800ms with fade-in/fade-out, then auto-dismisses via
/// [onDismissed] callback. Designed for non-blocking, ephemeral feedback.
class RewardPopup extends StatefulWidget {
  const RewardPopup({
    required this.xp,
    required this.chips,
    required this.onDismissed,
    super.key,
  });

  final int xp;
  final int chips;
  final VoidCallback onDismissed;

  @override
  State<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends State<RewardPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Fade: 0.0 → 1.0 (first 25%) → 1.0 (middle 50%) → 0.0 (last 25%)
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 50),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    // Slide: upward movement with smooth easing
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -48.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final successColor = brand?.accentSuccess ?? Colors.green;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: successColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: successColor, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.xp > 0) ...[
              Text(
                '+${widget.xp} XP',
                style: AppTypography.h3.copyWith(color: successColor),
              ),
              if (widget.chips > 0) const SizedBox(width: 12),
            ],
            if (widget.chips > 0)
              Text(
                '+${widget.chips} 💰',
                style: AppTypography.h3.copyWith(color: successColor),
              ),
          ],
        ),
      ),
    );
  }
}
