import 'package:flutter/material.dart';
import 'package:poker_analyzer/core/services/audio_service.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual/glass_action_button.dart';

/// Premium feedback overlay for poker puzzle results with glassmorphism and animations.
class GameFeedbackOverlay extends StatefulWidget {
  const GameFeedbackOverlay({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.onContinue,
    this.xpReward = 0,
  });

  /// True for correct answer (green), false for incorrect (red)
  final bool isCorrect;

  /// Explanation text (logic for wrong, or empty for correct)
  final String explanation;

  /// Callback when user presses continue
  final VoidCallback onContinue;

  /// XP reward amount (only shown if correct)
  final int xpReward;

  @override
  State<GameFeedbackOverlay> createState() => _GameFeedbackOverlayState();
}

class _GameFeedbackOverlayState extends State<GameFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Trigger audio feedback
    if (widget.isCorrect) {
      AudioService.instance.playWin();
    } else {
      AudioService.instance.playFold();
    }

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.isCorrect;
    final gradientColors = isCorrect
        ? [const Color(0xFF1B5E20), Colors.black]
        : [const Color(0xFFB71C1C), Colors.black];

    final iconColor = isCorrect ? Colors.greenAccent : Colors.redAccent;
    final icon = isCorrect ? Icons.check_circle : Icons.error;
    const iconSize = 80.0;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: iconSize + 20,
                    height: iconSize + 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(icon, size: iconSize, color: iconColor),
                  ),
                ),
                const SizedBox(height: 24),

                // Main Title
                Text(
                  isCorrect ? 'Excellent!' : 'Mistake!',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 8,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // XP Reward (for correct) or Explanation (for wrong)
                if (isCorrect)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.amber[700]!.withOpacity(0.8),
                          Colors.amber[900]!.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber[300]!.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber[700]!.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      '+${widget.xpReward} XP',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  // Explanation text for incorrect answers (scrollable)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.25,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.explanation,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: GlassActionButton(
                    label: 'CONTINUE',
                    color: const Color(0xFF1976D2), // Blue
                    onTap: widget.onContinue,
                    isPreferred: true,
                    icon: Icons.arrow_forward,
                    width: double.infinity,
                    height: 56,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
