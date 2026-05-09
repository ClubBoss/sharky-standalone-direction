// lib/ui_v2/league/league_dashboard_v2.dart
// Stage H2: League Dashboard UI V2
// Responsive, animated dashboard for player progression (ASCII-only labels)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/player_progression_service.dart';

class LeagueDashboardV2 extends StatefulWidget {
  const LeagueDashboardV2({super.key});

  @override
  State<LeagueDashboardV2> createState() => _LeagueDashboardV2State();
}

class _LeagueDashboardV2State extends State<LeagueDashboardV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // We keep a periodic refresh to reflect new rewards applied elsewhere.
  Timer? _pollTimer;
  ProgressionState _state = PlayerProgressionService.instance.snapshot();

  double _progressFor(ProgressionState s) {
    final total = (s.nextLevelXp).toDouble();
    final prevThreshold = total - _xpIncrementForLevelSafe(s.level);
    final clamped = (s.xpTotal - prevThreshold).clamp(0, s.nextLevelXp);
    final denom = (s.nextLevelXp - prevThreshold).toDouble();
    if (denom <= 0) return 0.0;
    return (clamped.toDouble() / denom).clamp(0.0, 1.0);
  }

  int _xpIncrementForLevelSafe(int level) {
    // Keep in sync with PlayerProgressionService._xpIncrementForLevel
    // 1000 * 1.15^(level-1), rounded
    final base = 1000.0;
    final inc = base * (powSafe(1.15, (level - 1)));
    return inc.round();
  }

  double powSafe(double a, int b) {
    double r = 1.0;
    for (int i = 0; i < b; i++) {
      r *= a;
    }
    return r;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Emit telemetry on first view (non-blocking)
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent('league_dashboard_viewed'),
    );

    // Start entrance animation
    _controller.forward();

    // Poll every 1s for fresh state (simple approach without streams)
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = PlayerProgressionService.instance.snapshot();
      if (_didChange(_state, next)) {
        setState(() {
          _state = next;
        });
      }
    });
  }

  bool _didChange(ProgressionState a, ProgressionState b) {
    return a.level != b.level ||
        a.xpTotal != b.xpTotal ||
        a.nextLevelXp != b.nextLevelXp ||
        a.chipTotal != b.chipTotal ||
        a.leagueTier != b.leagueTier ||
        a.streak != b.streak;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(320.0, 1080.0);
        final isCompact = width < 420;
        final pad = isCompact ? 12.0 : 20.0;
        final titleSize = isCompact ? 16.0 : 20.0;
        final levelSize = isCompact ? 28.0 : 34.0;
        final barHeight = isCompact ? 14.0 : 18.0;
        final rowGap = isCompact ? 8.0 : 10.0;

        final progress = _progressFor(_state);
        final badge = _badgeFor(_state.leagueTier);

        return FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Container(
              constraints: const BoxConstraints(minWidth: 320, maxWidth: 1080),
              padding: EdgeInsets.all(pad),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header: badge + level
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _BadgePill(label: badge),
                      const SizedBox(width: 12),
                      Text(
                        'Level',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _state.level.toString(),
                        style: TextStyle(
                          fontSize: levelSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      _SummaryKvp(
                        label: 'XP',
                        value: _state.xpTotal.toString(),
                        alignEnd: true,
                      ),
                      SizedBox(width: isCompact ? 8 : 16),
                      _SummaryKvp(
                        label: 'Chips',
                        value: _state.chipTotal.toString(),
                        alignEnd: true,
                      ),
                    ],
                  ),
                  SizedBox(height: rowGap * 1.5),

                  // XP progress bar with tween
                  _XpBar(
                    progress: progress,
                    height: barHeight,
                    label: _xpLabel(_state),
                  ),

                  SizedBox(height: rowGap * 1.5),

                  // Streak row
                  Row(
                    children: [
                      const _Dot(color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Streak: ${_state.streak} days',
                        style: TextStyle(
                          fontSize: isCompact ? 13 : 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _xpLabel(ProgressionState s) {
    final inc = _xpIncrementForLevelSafe(s.level);
    final prevThreshold = s.nextLevelXp - inc;
    final gained = (s.xpTotal - prevThreshold).clamp(0, s.nextLevelXp);
    final need = (s.nextLevelXp - prevThreshold).clamp(0, s.nextLevelXp);
    return '${gained.toString()} / ${need.toString()}';
  }

  String _badgeFor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return '[BRONZE]';
      case 'silver':
        return '[SILVER]';
      case 'gold':
        return '[GOLD]';
      case 'diamond':
        return '[DIAMOND]';
      case 'elite':
        return '[ELITE]';
      default:
        return '[LEAGUE]';
    }
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _XpBar extends StatefulWidget {
  const _XpBar({
    required this.progress,
    required this.height,
    required this.label,
  });

  final double progress; // 0..1
  final double height;
  final String label;

  @override
  State<_XpBar> createState() => _XpBarState();
}

class _XpBarState extends State<_XpBar> {
  double _displayed = 0.0;

  @override
  void didUpdateWidget(covariant _XpBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.progress - widget.progress).abs() > 0.001) {
      // Smoothly tween using implicit AnimatedContainer below; we update displayed step-by-step.
      _displayed = widget.progress;
    }
  }

  @override
  void initState() {
    super.initState();
    _displayed = widget.progress;
  }

  @override
  Widget build(BuildContext context) {
    final trackColor = Colors.grey.shade300;
    final fillColor = Colors.blueAccent.shade400;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: _displayed.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  'XP ${widget.label}',
                  style: TextStyle(
                    fontSize: widget.height * 0.62,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryKvp extends StatelessWidget {
  const _SummaryKvp({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: textAlign,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
