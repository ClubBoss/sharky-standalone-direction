import 'dart:async';

import 'package:flutter/material.dart';
import '../services/streak_tracker_service.dart';
import '../services/session_medal_service.dart';

/// Session medal categories.
enum SessionMedalKind {
  sessionXp,
  sessionDuration,
  streakMilestone,
  efficiency,
}

/// Medal tier for XP category.
enum SessionXpTier { bronze, silver, gold }

/// Represents a medal to display in the session popup.
class SessionMedal {
  final SessionMedalKind kind;
  final String titleEn;
  final String titleRu;
  final String? subtitleEn; // For showing XP/min rate
  final String? subtitleRu;
  final IconData icon;
  final Color color;

  const SessionMedal({
    required this.kind,
    required this.titleEn,
    required this.titleRu,
    this.subtitleEn,
    this.subtitleRu,
    required this.icon,
    required this.color,
  });

  String title({required bool isRu}) => isRu ? titleRu : titleEn;
  String? subtitle({required bool isRu}) => isRu ? subtitleRu : subtitleEn;
}

/// Rules and helper for computing medals
class SessionMedalRules {
  // XP thresholds per session (legacy, now using XP/min)
  static const int xpBronze = 10;
  static const int xpSilver = 20;
  static const int xpGold = 40;

  // Duration thresholds in minutes
  static const int dur30 = 30;
  static const int dur60 = 60;
  static const int dur120 = 120;

  // Streak milestones (days)
  static const List<int> streakMilestones = [3, 7, 14];

  static List<SessionMedal> compute({
    required int sessionXp,
    required int durationMinutes,
    required int currentStreak,
  }) {
    final List<SessionMedal> medals = [];

    // Check for efficiency medal (XP per minute) - PRIMARY AWARD
    final efficiencyMedal = _computeEfficiencyMedal(sessionXp, durationMinutes);
    if (efficiencyMedal != null) {
      medals.add(efficiencyMedal);
    }

    // Streak first (only exactly on the milestone day)
    if (streakMilestones.contains(currentStreak)) {
      final d = currentStreak;
      medals.add(
        SessionMedal(
          kind: SessionMedalKind.streakMilestone,
          titleEn: 'Streak $d days',
          titleRu: 'Серия $d дн.',
          icon: Icons.local_fire_department,
          color: Colors.deepOrange,
        ),
      );
    }

    // Duration medals (if no efficiency medal yet)
    if (efficiencyMedal == null && durationMinutes >= dur30) {
      if (durationMinutes >= dur120) {
        medals.add(
          const SessionMedal(
            kind: SessionMedalKind.sessionDuration,
            titleEn: '120m+ Session',
            titleRu: 'Сессия 120м+',
            icon: Icons.hourglass_full,
            color: Colors.indigo,
          ),
        );
      } else if (durationMinutes >= dur60) {
        medals.add(
          const SessionMedal(
            kind: SessionMedalKind.sessionDuration,
            titleEn: '60m+ Session',
            titleRu: 'Сессия 60м+',
            icon: Icons.hourglass_bottom,
            color: Colors.blue,
          ),
        );
      } else {
        medals.add(
          const SessionMedal(
            kind: SessionMedalKind.sessionDuration,
            titleEn: '30m+ Session',
            titleRu: 'Сессия 30м+',
            icon: Icons.hourglass_empty,
            color: Colors.teal,
          ),
        );
      }
    }

    // Limit to 2-3 medals max
    return medals.take(3).toList();
  }

  /// Computes efficiency medal based on XP per minute
  static SessionMedal? _computeEfficiencyMedal(
    int sessionXp,
    int durationMinutes,
  ) {
    if (durationMinutes <= 0) return null;

    final xpPerMin = sessionXp / durationMinutes;
    final tier = SessionMedalService.instance.evaluateSession(
      sessionXp: sessionXp,
      durationMinutes: durationMinutes,
    );

    if (tier == null) return null;

    final xpPerMinStr = xpPerMin.toStringAsFixed(1);

    switch (tier) {
      case SessionMedalTier.gold:
        return SessionMedal(
          kind: SessionMedalKind.efficiency,
          titleEn: 'Gold Efficiency',
          titleRu: 'Золотая эффективность',
          subtitleEn: '$xpPerMinStr XP/min',
          subtitleRu: '$xpPerMinStr XP/мин',
          icon: Icons.emoji_events,
          color: const Color(0xFFFFD700), // Gold color
        );
      case SessionMedalTier.silver:
        return SessionMedal(
          kind: SessionMedalKind.efficiency,
          titleEn: 'Silver Efficiency',
          titleRu: 'Серебряная эффективность',
          subtitleEn: '$xpPerMinStr XP/min',
          subtitleRu: '$xpPerMinStr XP/мин',
          icon: Icons.emoji_events,
          color: const Color(0xFFC0C0C0), // Silver color
        );
      case SessionMedalTier.bronze:
        return SessionMedal(
          kind: SessionMedalKind.efficiency,
          titleEn: 'Bronze Efficiency',
          titleRu: 'Бронзовая эффективность',
          subtitleEn: '$xpPerMinStr XP/min',
          subtitleRu: '$xpPerMinStr XP/мин',
          icon: Icons.emoji_events,
          color: const Color(0xFFCD7F32), // Bronze color
        );
    }
  }
}

class SessionMedalPopup {
  static OverlayEntry? _entry;
  static Timer? _timer;
  // Navigator key must be set by app (e.g., in main.dart) or in tests
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Compute medals and show popup. Safe to call from services.
  static Future<void> maybeShowAfterSession({
    required int sessionXp,
    required int durationMinutes,
  }) async {
    final context = navigatorKey?.currentContext;
    if (context == null) return;

    // Compute streak
    int currentStreak = 0;
    try {
      final stats = await StreakTrackerService().compute();
      currentStreak = stats.currentStreak;
    } catch (_) {}

    final medals = SessionMedalRules.compute(
      sessionXp: sessionXp,
      durationMinutes: durationMinutes,
      currentStreak: currentStreak,
    );
    if (medals.isEmpty) return;

    _show(context, medals);
  }

  static void _show(BuildContext context, List<SessionMedal> medals) {
    _entry?.remove();
    _timer?.cancel();

    final overlay = Overlay.of(context, rootOverlay: true);

    final entry = OverlayEntry(
      builder: (_) => _SessionMedalContent(medals: medals, onDismissed: _clear),
    );

    overlay.insert(entry);
    _entry = entry;
  }

  static void _clear() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _SessionMedalContent extends StatefulWidget {
  final List<SessionMedal> medals;
  final VoidCallback onDismissed;
  const _SessionMedalContent({required this.medals, required this.onDismissed});

  @override
  State<_SessionMedalContent> createState() => _SessionMedalContentState();
}

class _SessionMedalContentState extends State<_SessionMedalContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    SessionMedalPopup._timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().whenComplete(() {
          if (mounted) widget.onDismissed();
        });
      } else {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final title = isRu ? 'Новая медаль!' : 'New Medal!';

    return IgnorePointer(
      ignoring: true,
      child: Positioned.fill(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: _controller,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.80 * 255).round()),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withAlpha(60),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: widget.medals
                            .map((m) => _MedalChip(medal: m))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MedalChip extends StatelessWidget {
  final SessionMedal medal;
  const _MedalChip({required this.medal});

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final subtitle = medal.subtitle(isRu: isRu);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: medal.color.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: medal.color.withAlpha(120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(medal.icon, color: medal.color, size: 18),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medal.title(isRu: isRu),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
