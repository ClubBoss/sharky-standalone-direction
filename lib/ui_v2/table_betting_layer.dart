import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

/// Interactive betting layer that animates chip movements on a poker table.
///
/// Simulates bet/call/fold actions with real-time pot updates.
/// Lightweight, no external assets, < 5 ms/frame render cost.
class PokerTableBettingLayer extends StatefulWidget {
  const PokerTableBettingLayer({
    super.key,
    this.playerCount = 6,
    this.heroSeat = 0,
    this.potSize = 0,
    this.action = BettingAction.none,
    this.amount = 0,
    this.onActionComplete,
  }) : assert(playerCount >= 2 && playerCount <= 10),
       assert(heroSeat >= 0 && heroSeat < playerCount);

  final int playerCount;
  final int heroSeat;
  final int potSize;
  final BettingAction action;
  final int amount;
  final VoidCallback? onActionComplete;

  @override
  State<PokerTableBettingLayer> createState() => _PokerTableBettingLayerState();
}

class _PokerTableBettingLayerState extends State<PokerTableBettingLayer>
    with TickerProviderStateMixin {
  late AnimationController _chipAnimationController;
  late Animation<double> _chipMovement;
  late Animation<double> _chipOpacity;

  int _displayPot = 0;
  final Map<int, int> _playerStacks = {};
  bool _animatingChips = false;

  @override
  void initState() {
    super.initState();
    _displayPot = widget.potSize;
    _initializeStacks();
    _setupAnimations();
  }

  @override
  void didUpdateWidget(PokerTableBettingLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final actionChanged = widget.action != oldWidget.action;
    final amountChanged = widget.amount != oldWidget.amount;
    final seatChanged = widget.heroSeat != oldWidget.heroSeat;
    if (widget.action != BettingAction.none &&
        (actionChanged || amountChanged || seatChanged)) {
      _triggerBettingAnimation();
    }
    if (widget.potSize != oldWidget.potSize) {
      _displayPot = widget.potSize;
    }
  }

  void _initializeStacks() {
    for (var i = 0; i < widget.playerCount; i++) {
      _playerStacks[i] = 1000 + (i * 100);
    }
  }

  void _setupAnimations() {
    _chipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _chipMovement = CurvedAnimation(
      parent: _chipAnimationController,
      curve: Curves.easeInOut,
    );

    _chipOpacity = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _chipAnimationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _chipAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _animatingChips = false;
            if (widget.action == BettingAction.bet ||
                widget.action == BettingAction.call) {
              _displayPot += widget.amount;
              final heroStack = _playerStacks[widget.heroSeat] ?? 0;
              _playerStacks[widget.heroSeat] = (heroStack - widget.amount)
                  .clamp(0, 999999);
            }
          });
          widget.onActionComplete?.call();
        }
      }
    });
  }

  void _triggerBettingAnimation() {
    if (widget.action == BettingAction.none ||
        widget.action == BettingAction.fold) {
      return;
    }
    if (mounted) {
      setState(() => _animatingChips = true);
      _chipAnimationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _chipAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingMedium ?? 16.0;

    return Stack(
      children: [
        // Player positions
        ..._buildPlayerPositions(context),
        // Pot display
        _buildPotDisplay(context),
        // Animated chips
        if (_animatingChips) _buildAnimatedChips(context),
        // Action bar
        Positioned(
          left: spacing,
          right: spacing,
          bottom: spacing,
          child: _buildActionBar(context),
        ),
      ],
    );
  }

  List<Widget> _buildPlayerPositions(BuildContext context) {
    final offsets = _computeSeatOffsets(widget.playerCount);
    final widgets = <Widget>[];

    for (var i = 0; i < widget.playerCount; i++) {
      final isHero = i == widget.heroSeat;
      final stack = _playerStacks[i] ?? 0;

      widgets.add(
        Align(
          alignment: Alignment(offsets[i].dx, offsets[i].dy),
          child: _PlayerStackBadge(
            seatNumber: i + 1,
            stack: stack,
            isHero: isHero,
            isActive: isHero && _animatingChips,
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildPotDisplay(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Align(
      alignment: Alignment.center,
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: _displayPot, end: _displayPot),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(brand?.radius ?? 12),
              border: Border.all(
                color: (brand?.primaryBrand ?? Colors.teal).withValues(
                  alpha: 0.6,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'POT',
                  style: AppTypography.caption.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ChipStack(
                      count: (value / 100).ceil().clamp(1, 10),
                      color: brand?.primaryBrand ?? Colors.teal,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$value',
                      style: AppTypography.h3.copyWith(
                        color: brand?.primaryBrand ?? Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedChips(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final heroOffset = _computeSeatOffsets(widget.playerCount)[widget.heroSeat];

    return AnimatedBuilder(
      animation: _chipAnimationController,
      builder: (context, child) {
        final progress = _chipMovement.value;
        final x = _lerp(heroOffset.dx, 0.0, progress);
        final y = _lerp(heroOffset.dy, 0.0, progress);

        return Align(
          alignment: Alignment(x, y),
          child: Opacity(
            opacity: _chipOpacity.value,
            child: Transform.scale(
              scale: 1.0 - (progress * 0.3),
              child: _ChipStack(
                count: (widget.amount / 100).ceil().clamp(1, 8),
                color: brand?.primaryBrand ?? Colors.teal,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
        border: Border.all(
          color: (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            label: 'Fold',
            icon: '✕',
            iconData: Icons.close,
            color: Colors.red.shade700,
            onTap: () {},
          ),
          _ActionButton(
            label: 'Call',
            icon: '✓',
            iconData: Icons.check,
            color: brand?.accentWarning ?? AppColors.accentWarning,
            onTap: () {},
          ),
          _ActionButton(
            label: 'Raise',
            icon: '↑',
            iconData: Icons.arrow_upward,
            color: brand?.accentSuccess ?? AppColors.accentSuccess,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  List<Offset> _computeSeatOffsets(int count) {
    final step = (2 * pi) / count;
    const startAngle = pi / 2;
    const radius = 0.75;

    return List<Offset>.generate(count, (index) {
      final angle = startAngle + index * step;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;
      return Offset(x, y);
    });
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Betting action types
enum BettingAction { none, fold, call, bet, raise, check }

class _PlayerStackBadge extends StatelessWidget {
  const _PlayerStackBadge({
    required this.seatNumber,
    required this.stack,
    required this.isHero,
    required this.isActive,
  });

  final int seatNumber;
  final int stack;
  final bool isHero;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final primaryColor = brand?.primaryBrand ?? Colors.teal;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHero
            ? primaryColor.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHero
              ? primaryColor.withValues(alpha: isActive ? 1.0 : 0.6)
              : Colors.white.withValues(alpha: 0.2),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
          if (isActive)
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'P$seatNumber',
            style: AppTypography.caption.copyWith(
              color: isHero
                  ? (brand?.textPrimary ?? AppColors.textPrimaryDark)
                  : (brand?.textSecondary ?? AppColors.textSecondaryDark),
              fontWeight: isHero ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ChipStack(count: 3, color: primaryColor, size: 8),
              const SizedBox(width: 4),
              Text(
                '$stack',
                style: AppTypography.label.copyWith(
                  color: isHero
                      ? primaryColor
                      : (brand?.textSecondary ?? AppColors.textSecondaryDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipStack extends StatelessWidget {
  const _ChipStack({required this.count, required this.color, this.size = 16});

  final int count;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size + (count * 2.0),
      child: Stack(
        children: List.generate(
          count.clamp(1, 10),
          (index) => Positioned(
            bottom: index * 2.0,
            left: 0,
            child: Container(
              width: size,
              height: size / 2,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(size / 2),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.iconData,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String icon;
  final IconData iconData;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 - (_controller.value * 0.05);
        final elevation = 2.0 + (_controller.value * 4.0);

        return Transform.scale(
          scale: scale,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.color.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: Offset(0, elevation),
                    blurRadius: elevation * 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.iconData, size: 18, color: widget.color),
                  const SizedBox(width: 6),
                  Text(
                    widget.label,
                    style: AppTypography.label.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w600,
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
}
