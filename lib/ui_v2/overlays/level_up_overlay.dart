// lib/ui_v2/overlays/level_up_overlay.dart
// Stage H3: Level Up Overlay — reactive celebration overlay
// - 2s total animation: 1s confetti burst + 1s "LEVEL UP!" slide/fade
// - No images; AnimatedBuilder + Transform + Opacity
// - Auto-dismiss after 2s; responsive 320–1080 px
// - Telemetry: level_up_overlay_shown

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/overlay_manager.dart';

class LevelUpOverlayHost extends StatefulWidget {
  const LevelUpOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  State<LevelUpOverlayHost> createState() => _LevelUpOverlayHostState();
}

class _LevelUpOverlayHostState extends State<LevelUpOverlayHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _visible = false;
  late List<_ConfettiSpec> _confetti;
  Timer? _hideTimer;
  Completer<void>? _activeCompleter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    OverlayManager.instance.registerDelegate(
      OverlayType.levelUp,
      _handleOverlay,
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete();
    }
    OverlayManager.instance.unregisterDelegate(
      OverlayType.levelUp,
      _handleOverlay,
    );
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleOverlay(Map<String, Object?> payload) async {
    await _show();
  }

  Future<void> _show() {
    _hideTimer?.cancel();
    final completer = Completer<void>();
    _activeCompleter = completer;
    _confetti = _generateConfetti();
    if (mounted) {
      setState(() => _visible = true);
    }
    _controller
      ..reset()
      ..forward();

    // Non-blocking telemetry
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent('level_up_overlay_shown'),
    );

    // Auto hide after 2s
    _hideTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) {
        if (!completer.isCompleted) completer.complete();
        return;
      }
      setState(() => _visible = false);
      if (!completer.isCompleted) {
        completer.complete();
      }
      _activeCompleter = null;
    });

    return completer.future;
  }

  List<_ConfettiSpec> _generateConfetti() {
    final rnd = math.Random();
    final count = 16;
    final specs = <_ConfettiSpec>[];
    for (int i = 0; i < count; i++) {
      final angle = rnd.nextDouble() * 2 * math.pi;
      final speed = 80 + rnd.nextDouble() * 120; // px/s
      final size = 6 + rnd.nextDouble() * 8;
      final hue = rnd.nextInt(360);
      specs.add(
        _ConfettiSpec(
          angle: angle,
          speed: speed,
          size: size,
          color: HSLColor.fromAHSL(1.0, hue.toDouble(), 0.8, 0.55).toColor(),
        ),
      );
    }
    return specs;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_visible)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value; // 0..1 over 2s
                  return CustomMultiChildLayout(
                    delegate: _OverlayLayoutDelegate(),
                    children: [
                      // Confetti in first second
                      LayoutId(
                        id: 'confetti',
                        child: Opacity(
                          opacity: t <= 0.5 ? (1.0 - (t / 0.5)) : 0.0,
                          child: _ConfettiField(
                            progress: (t / 0.5).clamp(0.0, 1.0),
                            specs: _confetti,
                          ),
                        ),
                      ),
                      // Text in second second
                      LayoutId(
                        id: 'banner',
                        child: _LevelUpBanner(
                          progress: ((t - 0.5) / 0.5).clamp(0.0, 1.0),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _OverlayLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    if (hasChild('confetti')) {
      layoutChild('confetti', BoxConstraints.tight(size));
      positionChild('confetti', Offset.zero);
    }
    if (hasChild('banner')) {
      final bannerSize = layoutChild(
        'banner',
        BoxConstraints(maxWidth: size.width, maxHeight: size.height),
      );
      positionChild(
        'banner',
        Offset(
          (size.width - bannerSize.width) / 2,
          (size.height - bannerSize.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}

class _ConfettiField extends StatelessWidget {
  const _ConfettiField({required this.progress, required this.specs});

  final double progress; // 0..1 over first second
  final List<_ConfettiSpec> specs;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConfettiPainter(progress: progress, specs: specs),
      size: Size.infinite,
    );
  }
}

class _ConfettiSpec {
  const _ConfettiSpec({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });

  final double angle;
  final double speed;
  final double size;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.specs});

  final double progress; // 0..1
  final List<_ConfettiSpec> specs;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final s in specs) {
      final dist = s.speed * progress; // px from center
      final dx = math.cos(s.angle) * dist;
      final dy = math.sin(s.angle) * dist;
      final pos = center + Offset(dx, dy);
      final p = Paint()..color = s.color.withValues(alpha: (1.0 - progress));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(s.angle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: s.size, height: s.size),
        p,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.specs != specs;
  }
}

class _LevelUpBanner extends StatelessWidget {
  const _LevelUpBanner({required this.progress});

  final double progress; // 0..1 for second second

  @override
  Widget build(BuildContext context) {
    // Responsive text size
    final w = MediaQuery.of(context).size.width.clamp(320.0, 1080.0);
    final base = (w / 16).clamp(18.0, 54.0);

    final fade = Curves.easeOut.transform(progress);
    final slide = (1.0 - Curves.easeOut.transform(progress)) * 12; // px down

    return Opacity(
      opacity: fade,
      child: Transform.translate(
        offset: Offset(0, slide),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.66),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'LEVEL UP!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: base,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
