import 'package:flutter/material.dart';

/// Premium glassmorphic action button with gradient, 3D effects, and optional pulsating animation.
/// Designed for GGPoker-style UI with candy/glass aesthetics.
class GlassActionButton extends StatefulWidget {
  const GlassActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.isPreferred = false,
    this.icon,
    this.width = 140,
    this.height = 56,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isPreferred;
  final IconData? icon;
  final double width;
  final double height;

  @override
  State<GlassActionButton> createState() => _GlassActionButtonState();
}

class _GlassActionButtonState extends State<GlassActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isPreferred) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlassActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPreferred && !oldWidget.isPreferred) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isPreferred && oldWidget.isPreferred) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = widget.isPreferred ? _scaleAnimation.value : 1.0;
          return Transform.scale(
            scale: _isPressed ? 0.95 : scale,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // Outer glow
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: widget.isPreferred ? 20 : 12,
                offset: const Offset(0, 6),
              ),
              // Depth shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withOpacity(0.9),
                      widget.color,
                      widget.color.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
              // Inner highlight (3D convex effect)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: widget.height * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              // Inner shadow at bottom for depth
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: widget.height * 0.3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              // Label and icon
              Center(
                child: widget.icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
              ),
              // Pulsating ring for preferred action
              if (widget.isPreferred)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              0.6 * _pulseController.value,
                            ),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pre-configured button styles for common poker actions
class PokerActionButtons {
  static const foldColor = Color(0xFFD32F2F); // Red
  static const callColor = Color(0xFF1976D2); // Blue
  static const raiseColor = Color(0xFF388E3C); // Green
  static const checkColor = Color(0xFFFFA726); // Orange

  static Widget fold({required VoidCallback? onTap, bool isPreferred = false}) {
    return GlassActionButton(
      label: 'FOLD',
      color: foldColor,
      onTap: onTap,
      isPreferred: isPreferred,
      icon: Icons.close,
    );
  }

  static Widget call({required VoidCallback? onTap, bool isPreferred = false}) {
    return GlassActionButton(
      label: 'CALL',
      color: callColor,
      onTap: onTap,
      isPreferred: isPreferred,
      icon: Icons.check,
    );
  }

  static Widget raise({
    required VoidCallback? onTap,
    bool isPreferred = false,
  }) {
    return GlassActionButton(
      label: 'RAISE',
      color: raiseColor,
      onTap: onTap,
      isPreferred: isPreferred,
      icon: Icons.arrow_upward,
    );
  }

  static Widget check({
    required VoidCallback? onTap,
    bool isPreferred = false,
  }) {
    return GlassActionButton(
      label: 'CHECK',
      color: checkColor,
      onTap: onTap,
      isPreferred: isPreferred,
      icon: Icons.done_all,
    );
  }

  static Widget allIn({
    required VoidCallback? onTap,
    bool isPreferred = false,
  }) {
    return GlassActionButton(
      label: 'ALL IN',
      color: const Color(0xFFE91E63), // Pink/Magenta
      onTap: onTap,
      isPreferred: isPreferred,
      icon: Icons.whatshot,
      width: 160,
    );
  }
}
