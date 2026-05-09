import 'package:flutter/material.dart';

/// Lightweight radial glow burst effect for level-ups and achievements.
/// Uses implicit animations and no external assets.
class GlowBurstFx extends StatefulWidget {
  final bool play;
  final Duration duration;
  final Color color;
  final VoidCallback? onCompleted;

  const GlowBurstFx({
    super.key,
    required this.play,
    this.duration = const Duration(milliseconds: 1000),
    this.color = Colors.teal,
    this.onCompleted,
  });

  @override
  State<GlowBurstFx> createState() => _GlowBurstFxState();
}

class _GlowBurstFxState extends State<GlowBurstFx>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(
      begin: 0.3,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call();
      }
    });
    if (widget.play) {
      _controller.forward(from: 0);
      _wasPlaying = true;
    }
  }

  @override
  void didUpdateWidget(GlowBurstFx oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !_wasPlaying) {
      _controller.forward(from: 0);
      _wasPlaying = true;
    } else if (!widget.play && _wasPlaying) {
      _controller.reset();
      _wasPlaying = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.play && !_wasPlaying) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Opacity(
            opacity: _opacity.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _scale.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.6),
                      widget.color.withValues(alpha: 0.3),
                      widget.color.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
