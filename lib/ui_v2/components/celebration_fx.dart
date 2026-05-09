import 'dart:math';

import 'package:flutter/material.dart';

class CelebrationFx extends StatefulWidget {
  final bool play;
  final Duration duration;
  final List<String> emojis;
  final VoidCallback? onCompleted;
  final int seed;

  const CelebrationFx({
    super.key,
    required this.play,
    this.duration = const Duration(milliseconds: 1200),
    this.emojis = const ['🎉', '✨', '🏅', '💎', '⭐', '🔥'],
    this.onCompleted,
    this.seed = 7,
  });

  @override
  State<CelebrationFx> createState() => _CelebrationFxState();
}

class _CelebrationFxState extends State<CelebrationFx>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _progress;
  late final List<_FxParticle> _particles;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _particles = _buildParticles();
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
  void didUpdateWidget(CelebrationFx oldWidget) {
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
            opacity: _opacity.value,
            child: SizedBox.expand(
              child: CustomPaint(
                painter: _FxPainter(
                  particles: _particles,
                  progress: _progress.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<_FxParticle> _buildParticles() {
    final rnd = Random(widget.seed);
    final particles = <_FxParticle>[];
    for (var i = 0; i < widget.emojis.length; i++) {
      final emoji = widget.emojis[i];
      particles.add(
        _FxParticle(
          emoji: emoji,
          start: Offset(
            rnd.nextDouble() * 0.6 - 0.3,
            0.4 + rnd.nextDouble() * 0.2,
          ),
          end: Offset(
            rnd.nextDouble() * 0.8 - 0.4,
            -0.4 - rnd.nextDouble() * 0.2,
          ),
          scale: 0.8 + rnd.nextDouble() * 0.6,
        ),
      );
    }
    return particles;
  }
}

class _FxParticle {
  final String emoji;
  final Offset start;
  final Offset end;
  final double scale;

  const _FxParticle({
    required this.emoji,
    required this.start,
    required this.end,
    required this.scale,
  });
}

class _FxPainter extends CustomPainter {
  final List<_FxParticle> particles;
  final double progress;

  _FxPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (final particle in particles) {
      final offset = Offset(
        _lerp(particle.start.dx, particle.end.dx, progress) * size.width +
            size.width / 2,
        _lerp(particle.start.dy, particle.end.dy, progress) * size.height +
            size.height / 2,
      );
      final scale = particle.scale * (1 - progress * 0.2);
      textPainter.text = TextSpan(
        text: particle.emoji,
        style: TextStyle(fontSize: 28 * scale, color: Colors.white),
      );
      textPainter.layout();
      final drawOffset =
          offset - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, drawOffset);
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _FxPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}
