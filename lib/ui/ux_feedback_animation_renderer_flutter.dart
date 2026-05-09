import 'package:flutter/material.dart';

import 'ux_feedback_animation_models.dart';

class AnimationHost {
  AnimationHost({required this.overlay, required this.tickerProvider});

  final OverlayState overlay;
  final TickerProvider tickerProvider;
}

Future<void> playFeedback(
  FeedbackAnimationSpec spec,
  AnimationHost host,
) async {
  final controller = AnimationController(
    vsync: host.tickerProvider,
    duration: Duration(milliseconds: spec.durationMs),
  );
  final entry = OverlayEntry(
    builder: (context) => _FeedbackOverlay(controller: controller, spec: spec),
  );

  host.overlay.insert(entry);
  await controller.forward();
  await Future<void>.delayed(const Duration(milliseconds: 120));
  controller.dispose();
  entry.remove();
}

class _FeedbackOverlay extends StatefulWidget {
  const _FeedbackOverlay({required this.controller, required this.spec});

  final AnimationController controller;
  final FeedbackAnimationSpec spec;

  @override
  State<_FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<_FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _scaleAnimation = Tween<double>(begin: 0.8, end: widget.spec.scale).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: widget.controller, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color start = Color(
      int.parse(widget.spec.primaryHex.replaceFirst('#', '0xFF')),
    );
    final Color end = Color(
      int.parse(widget.spec.secondaryHex.replaceFirst('#', '0xFF')),
    );
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, child) => Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(colors: [start, end]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_iconFor(widget.spec.icon), color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    widget.spec.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'trophy':
        return Icons.emoji_events;
      case 'error':
        return Icons.close_rounded;
      case 'level':
        return Icons.auto_awesome;
      default:
        return Icons.bolt;
    }
  }
}
