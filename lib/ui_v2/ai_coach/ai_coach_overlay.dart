import 'dart:async';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/ai_coach/ai_coach_engine.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

/// Visual overlay for AI coaching feedback with hint cards and EV bubbles.
///
/// Displays contextual coaching messages with 250ms fade animations.
/// Shows feedback like "Good fold", "Raise missed value", "EV +0.3 BB".
class AiCoachOverlay extends StatefulWidget {
  const AiCoachOverlay({
    required this.feedbackStream,
    this.visible = true,
    super.key,
  });

  final Stream<CoachingFeedback> feedbackStream;
  final bool visible;

  @override
  State<AiCoachOverlay> createState() => _AiCoachOverlayState();
}

class _AiCoachOverlayState extends State<AiCoachOverlay>
    with SingleTickerProviderStateMixin {
  StreamSubscription<CoachingFeedback>? _subscription;
  CoachingFeedback? _currentFeedback;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _subscription = widget.feedbackStream.listen((feedback) {
      if (!mounted || !widget.visible) return;

      setState(() {
        _currentFeedback = feedback;
      });

      // Trigger animation
      _fadeController.forward(from: 0.0);

      // Auto-hide after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (!mounted) return;
        _fadeController.reverse();
      });
    });

    // Clear feedback when animation fully dismissed to remove text from tree
    _fadeController.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _currentFeedback = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible || _currentFeedback == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _currentFeedback == null
                ? const SizedBox()
                : _buildFeedbackCard(context, _currentFeedback!),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, CoachingFeedback feedback) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final isPositive = feedback.isOptimal || feedback.evDifference >= 0;
    final cardColor = isPositive
        ? (brand?.accentSuccess ?? Colors.green)
        : (brand?.accentWarning ?? Colors.orange);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
        border: Border.all(color: cardColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and message
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.check_circle : Icons.lightbulb,
                  color: cardColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feedback.message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // EV badge
              _buildEvBadge(feedback.evDifference, cardColor),
            ],
          ),

          const SizedBox(height: 12),

          // Rationale text
          Text(
            feedback.rationale,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          // Suggested action if not optimal
          if (!feedback.isOptimal && feedback.suggestedAction != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_forward, color: cardColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Try: ${feedback.suggestedAction}',
                    style: TextStyle(
                      color: cardColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Confidence indicator
          const SizedBox(height: 12),
          _buildConfidenceBar(feedback.confidenceScore, cardColor),
        ],
      ),
    );
  }

  Widget _buildEvBadge(double evDiff, Color accentColor) {
    final isPositive = evDiff >= 0;
    final evText = isPositive
        ? '+${evDiff.toStringAsFixed(1)}'
        : evDiff.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'EV $evText BB',
        style: TextStyle(
          color: accentColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(double confidence, Color accentColor) {
    final confidencePercent = (confidence * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
            Text(
              '$confidencePercent%',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(accentColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

/// Compact coaching hint bubble for minimal UI intrusion.
///
/// Smaller alternative to full feedback card, suitable for rapid feedback.
class AiCoachHintBubble extends StatelessWidget {
  const AiCoachHintBubble({
    required this.message,
    required this.isPositive,
    this.evDifference,
    super.key,
  });

  final String message;
  final bool isPositive;
  final double? evDifference;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final bubbleColor = isPositive
        ? (brand?.accentSuccess ?? Colors.green)
        : (brand?.accentWarning ?? Colors.orange);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bubbleColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bubbleColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.check_circle : Icons.info,
            color: bubbleColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (evDifference != null) ...[
            const SizedBox(width: 6),
            Text(
              evDifference! >= 0
                  ? '+${evDifference!.toStringAsFixed(1)}'
                  : evDifference!.toStringAsFixed(1),
              style: TextStyle(
                color: bubbleColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
