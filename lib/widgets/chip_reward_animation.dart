import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';
import '../theme/app_colors.dart';
import 'chip_stack_moving_widget.dart';

/// Animation of the pot chips rewarding the winning player.
class ChipRewardAnimation extends StatelessWidget {
  /// Global start position of the pot.
  final Offset start;

  /// Global end position at the winner's stack.
  final Offset end;

  /// Amount of chips moving.
  final int amount;

  /// Scale factor applied to the animation.
  final double scale;

  /// Optional bezier control point for the curved path.
  final Offset? control;

  /// Callback invoked when the animation completes.
  final VoidCallback? onCompleted;

  /// Fraction of the animation after which fading begins.
  final double fadeStart;

  const ChipRewardAnimation({
    Key? key,
    required this.start,
    required this.end,
    required this.amount,
    this.scale = 1.0,
    this.control,
    this.onCompleted,
    this.fadeStart = 0.6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ChipStackMovingWidget(
    start: start,
    end: end,
    amount: amount,
    color: AppColors.accent,
    scale: scale,
    control: control,
    fadeStart: fadeStart,
    showLabel: true,
    labelStyle: TextStyle(
      color: VisualThemeV3.textPrimaryDark,
      fontWeight: FontWeight.bold,
      fontSize: 16 * scale,
      shadows: [
        Shadow(
          color: VisualThemeV3.textPrimaryLight.withValues(alpha: 0.54),
          blurRadius: 2,
        ),
      ],
    ),
    onCompleted: onCompleted,
  );
}
