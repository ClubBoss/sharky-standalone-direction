import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

import '../design/design_tokens.dart';
import '../design/design_typography.dart';
import '../motion/motion_primitives.dart';
import '../theme/v4_token_registry.dart';
import '../components/help_info_icon_v4.dart';
import '../app_root.dart';

class HoleCardsWidget extends StatefulWidget {
  const HoleCardsWidget({
    required this.rank1,
    required this.suit1,
    required this.rank2,
    required this.suit2,
    this.overlap = VisualThemeV3.spacingS,
    this.motionProgress = 1.0,
    this.isV4Active = false,
    super.key,
  });

  final String rank1;
  final String suit1;
  final String rank2;
  final String suit2;
  final double overlap;
  final double motionProgress;
  final bool isV4Active;

  @override
  State<HoleCardsWidget> createState() => _HoleCardsWidgetState();
}

class _HoleCardsWidgetState extends State<HoleCardsWidget> {
  bool _hover = false;

  Color _suitColor(String suit) {
    switch (suit) {
      case 'H':
      case 'D':
        return Color(DesignColors.accentStrong);
      case 'S':
      case 'C':
      default:
        return Color(DesignColors.textPrimary);
    }
  }

  Widget _card(BuildContext context, String rank, String suit) {
    const tokens = V4TokenRegistry();
    final hoverOffset = widget.isV4Active && _hover
        ? -tokens.cardHoverOffset
        : 0.0;
    final hoverShadow = widget.isV4Active && _hover
        ? tokens.cardHoverElevation
        : 0.0;
    return Container(
      width: 56,
      height: 80,
      padding: EdgeInsets.all(tokens.cardPadding),
      decoration: BoxDecoration(
        color: V4ThemeBuilder.resolveCardSurface(
          widget.isV4Active,
          Theme.of(context),
        ),
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        boxShadow: [
          VisualThemeV3.shadowLight.copyWith(
            blurRadius: VisualThemeV3.shadowLight.blurRadius + hoverShadow,
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: tokens.motionShort,
        transform: Matrix4.translationValues(0, hoverOffset, 0),
        curve: Curves.easeOut,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rank,
              style: TextStyle(
                fontSize: DesignTypography.body,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              suit,
              style: TextStyle(
                fontSize: DesignTypography.caption,
                color: _suitColor(suit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedCard(BuildContext context, String rank, String suit) {
    final progress = widget.motionProgress.clamp(0.0, 1.0);
    final visual = MotionPrimitives.fadeScale(t: progress);
    final scale = visual['scale'] ?? 1.0;
    final opacity = visual['opacity'] ?? 1.0;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(scale: scale, child: _card(context, rank, suit)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: IgnorePointer(
        child: SizedBox(
          width: 56 + widget.overlap,
          height: 80,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: _animatedCard(context, widget.rank1, widget.suit1),
              ),
              Positioned(
                left: widget.overlap,
                child: _animatedCard(context, widget.rank2, widget.suit2),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: HelpInfoIconV4(
                  componentId: 'hole_cards_v4',
                  binder: appRoot.exportInlineExplanationBinderV4,
                  isV4Active: widget.isV4Active,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class V4ThemeBuilder {
  static Color resolveCardSurface(bool isV4Active, ThemeData theme) {
    if (!isV4Active) {
      return theme.cardColor.withValues(alpha: 0.92);
    }
    return theme.colorScheme.surface;
  }
}
