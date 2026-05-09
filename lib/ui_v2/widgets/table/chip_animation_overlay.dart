import 'package:flutter/material.dart';
import 'package:poker_analyzer/core/models/poker_puzzle.dart';
import 'package:poker_analyzer/core/services/audio_service.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual/chip_stack_widget.dart';

/// Overlay that handles animated chip movement from villain seat to pot.
/// Uses the Stack pattern to layer flying chips over the poker table.
class ChipAnimationOverlay extends StatefulWidget {
  const ChipAnimationOverlay({
    super.key,
    required this.child,
    required this.puzzle,
    this.villainSeatAlignment = const Alignment(0.0, -0.88),
    this.potAlignment = const Alignment(0.0, 0.15),
  });

  final Widget child;
  final PokerPuzzle puzzle;
  final Alignment villainSeatAlignment;
  final Alignment potAlignment;

  @override
  State<ChipAnimationOverlay> createState() => _ChipAnimationOverlayState();
}

class _ChipAnimationOverlayState extends State<ChipAnimationOverlay>
    with SingleTickerProviderStateMixin {
  final List<_FlyingChip> _activeChips = [];
  String? _lastVillainAction;

  @override
  void initState() {
    super.initState();
    _lastVillainAction = widget.puzzle.villainAction;
  }

  @override
  void didUpdateWidget(ChipAnimationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect if villain action changed and contains "bet" or "raise"
    final currentAction = widget.puzzle.villainAction;
    final actionChanged = currentAction != _lastVillainAction;
    final isBettingAction =
        currentAction.toLowerCase().contains('bet') ||
        currentAction.toLowerCase().contains('raise');

    if (actionChanged && isBettingAction && currentAction.isNotEmpty) {
      _spawnFlyingChip();
      _lastVillainAction = currentAction;
    }
  }

  void _spawnFlyingChip() {
    if (!mounted) return;

    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final chip = _FlyingChip(
      controller: controller,
      amount: widget.puzzle.potSize.toDouble(),
      startAlignment: widget.villainSeatAlignment,
      endAlignment: widget.potAlignment,
      onComplete: () {
        if (mounted) {
          setState(() {
            _activeChips.removeWhere((c) => c.controller == controller);
          });
        }
        controller.dispose();
      },
    );

    setState(() {
      _activeChips.add(chip);
    });

    // Play betting sound effect
    try {
      AudioService.instance.playBet();
    } catch (e) {
      // Audio errors should never crash the UI
      debugPrint('⚠️ Failed to play bet sound: $e');
    }

    controller.forward();
  }

  @override
  void dispose() {
    // Clean up any remaining controllers
    for (final chip in _activeChips) {
      chip.controller.dispose();
    }
    _activeChips.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._activeChips.map((chip) => _AnimatedChipWidget(chip: chip)),
      ],
    );
  }
}

/// Data class representing a flying chip animation
class _FlyingChip {
  _FlyingChip({
    required this.controller,
    required this.amount,
    required this.startAlignment,
    required this.endAlignment,
    required this.onComplete,
  }) {
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete();
      }
    });
  }

  final AnimationController controller;
  final double amount;
  final Alignment startAlignment;
  final Alignment endAlignment;
  final VoidCallback onComplete;
}

/// Animated widget that displays a flying chip
class _AnimatedChipWidget extends StatelessWidget {
  const _AnimatedChipWidget({required this.chip});

  final _FlyingChip chip;

  /// Convert alignment to pixel offset based on constraints
  static Offset _alignmentToOffset(Alignment alignment, Size size) {
    final x = (alignment.x + 1) * size.width / 2;
    final y = (alignment.y + 1) * size.height / 2;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final startOffset = _alignmentToOffset(chip.startAlignment, size);
        final endOffset = _alignmentToOffset(chip.endAlignment, size);

        return AnimatedBuilder(
          animation: chip.controller,
          builder: (context, child) {
            final t = Curves.easeInOutQuart.transform(chip.controller.value);

            // Interpolate position
            final currentOffset = Offset.lerp(startOffset, endOffset, t)!;

            // Scale effect: start small (0.5) -> grow to normal (1.0)
            final scale = 0.5 + (0.5 * t);

            // Fade out at the end (last 20% of animation)
            final opacity = t < 0.8 ? 1.0 : (1.0 - (t - 0.8) * 5);

            return Positioned(
              left:
                  currentOffset.dx -
                  50, // Center the chip (assuming ~100px width)
              top:
                  currentOffset.dy -
                  40, // Center the chip (assuming ~80px height)
              child: RepaintBoundary(
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.scale(scale: scale, child: child!),
                ),
              ),
            );
          },
          child: ChipStackWidget(
            amount: chip.amount,
            maxChipsToShow: 8, // Slightly fewer for flying animation
          ),
        );
      },
    );
  }
}
