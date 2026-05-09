import 'package:flutter/material.dart';

/// Premium GGPoker-style player seat widget with glassmorphism and active state effects.
class GlassPlayerSeat extends StatefulWidget {
  const GlassPlayerSeat({
    super.key,
    required this.playerInitials,
    required this.positionLabel,
    required this.stackAmount,
    required this.isHero,
    this.isActive = false,
    this.actionLabel,
    this.thinkingTimePercent = 0.0,
  });

  /// Player name initials (e.g., "ME", "V1")
  final String playerInitials;

  /// Position badge text (e.g., "BTN", "SB", "BB", "CO")
  final String positionLabel;

  /// Player stack display (e.g., "1000 BB", "500 USD")
  final String stackAmount;

  /// True if this is the hero/main player
  final bool isHero;

  /// True if this player is currently acting
  final bool isActive;

  /// Optional action label (e.g., "FOLD", "BET", "CALL")
  final String? actionLabel;

  /// Thinking time indicator (0.0 to 1.0)
  final double thinkingTimePercent;

  @override
  State<GlassPlayerSeat> createState() => _GlassPlayerSeatState();
}

class _GlassPlayerSeatState extends State<GlassPlayerSeat>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Pulse glow animation when active
    if (widget.isActive) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GlassPlayerSeat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine color scheme based on hero status
    final isHero = widget.isHero;
    final borderGradient = isHero
        ? _createGradient([Colors.amber[700]!, Colors.amber[600]!])
        : _createGradient([Colors.grey[500]!, Colors.grey[400]!]);

    final containerBackgroundGradient = isHero
        ? _createGradient([
            Colors.blue[900]!.withOpacity(0.5),
            Colors.blue[800]!.withOpacity(0.3),
          ])
        : _createGradient([
            Colors.black.withOpacity(0.6),
            Colors.grey[900]!.withOpacity(0.4),
          ]);

    const avatarSize = 44.0;
    const containerPadding = 6.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 85),
      child: SizedBox(
        width: 100,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Active state glow effect
            if (widget.isActive)
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  final value = _glowController.value;
                  final intensity = 0.3 + (value * 0.4); // 0.3 to 0.7

                  return Container(
                    width: avatarSize + 40,
                    height: avatarSize + 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(intensity),
                          blurRadius: 20,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(
                            intensity * 0.5,
                          ),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Main container
            Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: containerBackgroundGradient,
                border: Border.all(width: 2, color: Colors.transparent),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  if (widget.isActive)
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 0),
                    ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Subtle glass texture overlay
                  Positioned.fill(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ).createShader(bounds);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content: Avatar + Labels
                  Padding(
                    padding: const EdgeInsets.all(containerPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar with thinking time ring
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Thinking time circular progress
                            if (widget.thinkingTimePercent > 0)
                              SizedBox(
                                width: avatarSize + 8,
                                height: avatarSize + 8,
                                child: CircularProgressIndicator(
                                  value: widget.thinkingTimePercent,
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.amber[400]!.withOpacity(0.7),
                                  ),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
                                ),
                              ),

                            // Avatar circle
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    isHero
                                        ? Colors.blue[600]!
                                        : Colors.grey[700]!,
                                    isHero
                                        ? Colors.blue[900]!
                                        : Colors.grey[900]!,
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.playerInitials,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1, 1),
                                        blurRadius: 3,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Stack amount label
                        Text(
                          widget.stackAmount,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Action label (if present and active)
                        if (widget.isActive && widget.actionLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orangeAccent.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                            child: Flexible(
                              child: Text(
                                widget.actionLabel!.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Position badge - overlapping the border (pill-shaped)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: borderGradient,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.positionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: Create a gradient between two colors
  LinearGradient _createGradient(List<Color> colors) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }
}
