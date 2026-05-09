// lib/ui_v2/progression/session_summary_card.dart
// Stage H6: Session Summary Card (end-of-session recap)
// - Triggered by UxFeedbackManager.onSessionSummary or manual showSummary()
// - 800ms fade + slide-in, auto-dismiss after 3s or on tap
// - ASCII-only labels/icons, responsive 320–1080 px
// - Telemetry: session_summary_shown on display

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/overlay_manager.dart';
import 'package:poker_analyzer/services/player_progression_service.dart';

class SessionSummaryCardHost extends StatefulWidget {
  const SessionSummaryCardHost({super.key, required this.child});

  final Widget child;

  @override
  State<SessionSummaryCardHost> createState() => _SessionSummaryCardHostState();
}

class _SessionSummaryCardStateData {
  const _SessionSummaryCardStateData({
    required this.xpDelta,
    required this.chipsDelta,
    required this.newLevel,
    required this.streakDelta,
    required this.leagueTier,
  });

  final int xpDelta;
  final int chipsDelta;
  final int newLevel;
  final int streakDelta;
  final String leagueTier;
}

class _SessionSummaryCardHostState extends State<SessionSummaryCardHost>
    with SingleTickerProviderStateMixin {
  _SessionSummaryCardStateData? _data;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _hideTimer;
  Completer<void>? _activeCompleter;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    OverlayManager.instance.registerDelegate(
      OverlayType.summary,
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
      OverlayType.summary,
      _handleOverlay,
    );
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleOverlay(Map<String, Object?> payload) async {
    final data = _SessionSummaryCardStateData(
      xpDelta: (payload['xp_delta'] as num?)?.toInt() ?? 0,
      chipsDelta: (payload['chips_delta'] as num?)?.toInt() ?? 0,
      newLevel: (payload['new_level'] as num?)?.toInt() ?? 0,
      streakDelta: (payload['streak_delta'] as num?)?.toInt() ?? 0,
      leagueTier: payload['league_tier']?.toString() ?? 'Bronze',
    );
    await _show(data);
  }

  Future<void> _show(_SessionSummaryCardStateData data) {
    _hideTimer?.cancel();
    final completer = Completer<void>();
    _activeCompleter = completer;
    if (mounted) {
      setState(() {
        _data = data;
      });
      _controller
        ..reset()
        ..forward();
    }

    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent('session_summary_shown'),
    );

    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        if (!completer.isCompleted) completer.complete();
        return;
      }
      setState(() => _data = null);
      if (!completer.isCompleted) {
        completer.complete();
      }
      _activeCompleter = null;
    });

    return completer.future;
  }

  void _dismiss() {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete();
    }
    _activeCompleter = null;
    if (mounted) {
      setState(() => _data = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _data != null;
    return Stack(
      children: [
        widget.child,
        if (active)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: GestureDetector(
              onTap: _dismiss,
              behavior: HitTestBehavior.opaque,
              child: SafeArea(
                minimum: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: _SummaryCard(data: _data!),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _SessionSummaryCardStateData data;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width.clamp(320.0, 1080.0);
    final isCompact = width < 420;
    final pad = isCompact ? 12.0 : 16.0;
    final titleSize = isCompact ? 14.0 : 16.0;
    // statSize kept for future tuning; current text sizes are constant.

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(pad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _BadgePill(label: _badgeFor(data.leagueTier)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Session Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _Stat(label: 'Level', value: '↑ ${data.newLevel}'),
                    _Stat(label: 'XP', value: '+${data.xpDelta}'),
                    _Stat(label: 'Chips', value: '+${data.chipsDelta}'),
                    _Stat(label: 'Streak', value: '+${data.streakDelta} days'),
                  ],
                ),
                const SizedBox(height: 10),
                _LeagueProgressBar(tier: data.leagueTier),
              ],
            ),
          ),
        ],
      ),
    );
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

class _LeagueProgressBar extends StatelessWidget {
  const _LeagueProgressBar({required this.tier});

  final String tier;

  Color _tierColor(String t) {
    switch (t.toLowerCase()) {
      case 'bronze':
        return const Color(0xffcd7f32);
      case 'silver':
        return const Color(0xffc0c0c0);
      case 'gold':
        return const Color(0xffffd700);
      case 'diamond':
        return const Color(0xffb9f2ff);
      case 'elite':
        return const Color(0xffd6af36);
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final snap = PlayerProgressionService.instance.snapshot();
    final progress = snap.nextLevelXp == 0
        ? 0.0
        : (snap.xpTotal / snap.nextLevelXp).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    final color = _tierColor(tier);
    final bg = Colors.white.withValues(alpha: 0.12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: 12,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                key: const Key('league_progress_fill'),
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          ' $percent% to Next League ',
          key: const Key('league_progress_label'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.start,
        spacing: 2,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
