import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import '../theme/v4_token_registry.dart';

class MiniToast extends StatefulWidget {
  final String icon;
  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  const MiniToast({
    super.key,
    required this.icon,
    required this.message,
    required this.onDismissed,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<MiniToast> createState() => _MiniToastState();
}

class _MiniToastState extends State<MiniToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.2,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.6),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.2,
      ),
    ]).animate(_controller);

    _offset = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.2,
      ),
      TweenSequenceItem(tween: ConstantTween<Offset>(Offset.zero), weight: 0.6),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -0.1),
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.2,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDismissed();
      }
    });

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
    final color = brand?.primaryBrand ?? Colors.teal;
    const tokens = V4TokenRegistry();
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(tokens.v4RadiusS),
            border: Border.all(color: color, width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: tokens.v4ShadowOpacity),
                blurRadius: tokens.v4ShadowBlur,
                offset: Offset(0, tokens.v4ShadowOffset),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.v4SpacingM,
              vertical: tokens.v4SpacingS,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.icon,
                  style: AppTypography.body.copyWith(color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.message,
                  style: AppTypography.body.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
