import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/user_path_profile.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/ui_v3/theme/app_text_styles.dart';
import 'package:poker_analyzer/ui_v3/theme/personalization_profile.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart'
    hide PersonalizationPalette;
import 'package:poker_analyzer/ui_v3/widgets/daily_goal_xp_bar.dart';
import 'package:poker_analyzer/ui_v3/widgets/reward_popup.dart';
import 'package:poker_analyzer/ui_v3/widgets/streak_bar.dart';

/// Unified hub showing player progress and streak health.
class ProgressHubScreen extends StatefulWidget {
  const ProgressHubScreen({super.key, this.profile});

  final UserPathProfile? profile;

  @override
  State<ProgressHubScreen> createState() => _ProgressHubScreenState();
}

class _ProgressHubScreenState extends State<ProgressHubScreen>
    with SingleTickerProviderStateMixin {
  late final Stopwatch _designLiftStopwatch;
  late final AnimationController _cardAnimation;
  late final PersonalizationBridge _personalizationBridge;
  PersonalizationSnapshot _personalization = PersonalizationSnapshot.fallback;
  PersonalizationPalette _palette = PersonalizationPalette.fromSnapshot(
    PersonalizationSnapshot.fallback,
  );
  late List<_ProgressCardData> _cards;
  bool _telemetrySent = false;
  bool _contentTelemetrySent = false;

  @override
  void initState() {
    super.initState();
    _designLiftStopwatch = Stopwatch()..start();
    _cards = _buildCards();
    _personalizationBridge = PersonalizationBridge();
    _cardAnimation = AnimationController(
      vsync: this,
      duration: VisualThemeV3.speedSlow,
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _emitTelemetry());
    _loadPersonalization();
  }

  @override
  void dispose() {
    _cardAnimation.dispose();
    if (_designLiftStopwatch.isRunning) {
      _designLiftStopwatch.stop();
    }
    super.dispose();
  }

  List<_ProgressCardData> _buildCards() {
    final discipline = widget.profile?.discipline ?? 'Cash Games';
    return <_ProgressCardData>[
      _ProgressCardData(
        id: 'discipline',
        title: 'Current Discipline',
        value: discipline,
        subtitle: 'Personalized focus',
        icon: Icons.assistant_navigation,
        progress: 0.72,
        badge: 'Active',
      ),
      const _ProgressCardData(
        id: 'streak',
        title: 'Weekly Streak',
        value: '4 days',
        subtitle: 'Keep the streak alive',
        icon: Icons.local_fire_department,
        progress: 0.57,
        badge: 'Stable',
      ),
      const _ProgressCardData(
        id: 'lesson_depth',
        title: 'Lesson Depth',
        value: '12 / 18',
        subtitle: 'Lessons completed',
        icon: Icons.menu_book,
        progress: 0.66,
        badge: 'On Track',
      ),
      const _ProgressCardData(
        id: 'packs',
        title: 'Pack Completion',
        value: '3 packs',
        subtitle: 'Target: 5 packs',
        icon: Icons.layers,
        progress: 0.6,
        badge: 'Goal',
      ),
      const _ProgressCardData(
        id: 'micro_wins',
        title: 'Micro Wins',
        value: '8 wins',
        subtitle: 'This week',
        icon: Icons.emoji_events,
        progress: 0.45,
        badge: 'Boost',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    return Theme(
      data: VisualThemeV3.theme,
      child: RewardPopupListener(
        child: Scaffold(
          appBar: AppBar(title: const Text('Progress Hub')),
          body: Container(
            color: VisualThemeV3.surfaceLight,
            decoration: BoxDecoration(gradient: palette.backgroundGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VisualThemeV3.spacingL,
                  vertical: VisualThemeV3.spacingL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, palette),
                    const SizedBox(height: VisualThemeV3.spacingL),
                    _buildStatusStrip(),
                    const SizedBox(height: VisualThemeV3.spacingL),
                    Expanded(child: _buildProgressGrid(palette)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PersonalizationPalette palette) {
    final timestamp = widget.profile?.timestamp;
    final subtitle = timestamp == null
        ? 'Monitor your momentum and stay aligned with your goals.'
        : 'Last synced ${timestamp.toLocal().toIso8601String()}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress Hub', style: AppTextStyles.pageTitle(context)),
        const SizedBox(height: VisualThemeV3.spacingS),
        const SizedBox(height: VisualThemeV3.spacingXL),
        Text(subtitle, style: AppTextStyles.pageSubtitle(context)),
        const SizedBox(height: VisualThemeV3.spacingS),
        Text(
          'Next up: ${_personalization.recommendedModule}',
          style: AppTextStyles.cardDetail(
            context,
          ).copyWith(color: palette.accent),
        ),
        const SizedBox(height: VisualThemeV3.spacingS),
        Wrap(
          spacing: VisualThemeV3.spacingS,
          runSpacing: VisualThemeV3.spacingS,
          children: [
            const _StatusBadge(
              label: 'Design Lift v2',
              tone: _BadgeTone.positive,
            ),
            const _StatusBadge(
              label: 'Telemetry Online',
              tone: _BadgeTone.neutral,
            ),
            _StatusBadge(
              label: 'Mood: ${_personalization.mood}',
              tone: _BadgeTone.neutral,
              backgroundOverride: palette.badgeBackground,
              foregroundOverride: palette.badgeForeground,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusStrip() {
    const tileWidth = 320.0;
    return Wrap(
      spacing: VisualThemeV3.spacingM,
      runSpacing: VisualThemeV3.spacingM,
      alignment: WrapAlignment.start,
      children: const [
        SizedBox(width: tileWidth, child: DailyGoalXpBar()),
        SizedBox(width: tileWidth, child: StreakBarLive()),
      ],
    );
  }

  Widget _buildProgressGrid(PersonalizationPalette palette) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final columnCount = isCompact ? 1 : 2;
        final itemWidth =
            (constraints.maxWidth -
                (VisualThemeV3.spacingM * (columnCount - 1))) /
            columnCount;

        return SingleChildScrollView(
          child: Wrap(
            spacing: VisualThemeV3.spacingM,
            runSpacing: VisualThemeV3.spacingM,
            children: [
              for (var i = 0; i < _cards.length; i++)
                SizedBox(
                  width: isCompact ? double.infinity : itemWidth,
                  child: _ProgressCard(
                    data: _cards[i],
                    animation: CurvedAnimation(
                      parent: _cardAnimation,
                      curve: Interval(
                        (i * 0.1).clamp(0.0, 1.0),
                        (0.4 + i * 0.1).clamp(0.5, 1.0),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    palette: palette,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadPersonalization() async {
    final snapshot = await _personalizationBridge.loadSnapshot();
    if (!mounted) return;
    setState(() {
      _personalization = snapshot;
      _palette = PersonalizationPalette.fromSnapshot(snapshot);
      _cards = _cards
          .map(
            (card) => card.id == 'discipline'
                ? card.copyWith(
                    value: snapshot.recommendedModule,
                    badge: 'AI Focus',
                  )
                : card,
          )
          .toList();
    });
    _emitContentSurfaceTelemetry(snapshot);
  }

  void _emitContentSurfaceTelemetry(PersonalizationSnapshot snapshot) {
    if (_contentTelemetrySent) return;
    _contentTelemetrySent = true;
    FirebaseLiteTelemetryService.instance.logEvent(
      'content_surface_unified',
      params: <String, Object>{
        'screen': 'progress_hub',
        'mood': snapshot.mood,
        'recommended_module': snapshot.recommendedModule,
      },
    );
  }

  void _emitTelemetry() {
    if (_telemetrySent) return;
    _telemetrySent = true;
    if (_designLiftStopwatch.isRunning) {
      _designLiftStopwatch.stop();
    }
    FirebaseLiteTelemetryService.instance.logEvent(
      'design_lift_progresshub_completed',
      params: <String, Object>{
        'widgets_updated': _cards.length + 2, // header + status strip + cards
        'duration_ms': _designLiftStopwatch.elapsedMilliseconds,
      },
    );
  }
}

class _ProgressCardData {
  const _ProgressCardData({
    required this.id,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.badge,
  });

  final String id;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final double progress;
  final String badge;

  _ProgressCardData copyWith({String? value, double? progress, String? badge}) {
    return _ProgressCardData(
      id: id,
      title: title,
      value: value ?? this.value,
      subtitle: subtitle,
      icon: icon,
      progress: progress ?? this.progress,
      badge: badge ?? this.badge,
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.data,
    required this.animation,
    required this.palette,
  });

  final _ProgressCardData data;
  final Animation<double> animation;
  final PersonalizationPalette palette;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(VisualThemeV3.cardRadius);
    final colorScheme = Theme.of(context).colorScheme;
    final accent = palette.accent;
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero),
        ),
        child: Material(
          color: VisualThemeV3.primary,
          elevation: VisualThemeV3.elevationMedium,
          borderRadius: borderRadius,
          child: Container(
            padding: const EdgeInsets.all(VisualThemeV3.spacingM),
            decoration: BoxDecoration(
              color: VisualThemeV3.cardLight,

              gradient: palette.cardGradient,
              borderRadius: borderRadius,
              border: Border.all(color: accent.withValues(alpha: 0.3)),
              boxShadow: const [VisualThemeV3.shadowLight],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(data.icon, color: accent),
                    const Spacer(),
                    _StatusBadge(
                      label: data.badge,
                      tone: _BadgeTone.neutral,
                      backgroundOverride: palette.badgeBackground,
                      foregroundOverride: palette.badgeForeground,
                    ),
                  ],
                ),
                const SizedBox(height: VisualThemeV3.spacingS),
                Text(
                  data.title,
                  style: AppTextStyles.statusLabel(context, color: accent),
                ),
                const SizedBox(height: VisualThemeV3.spacingXS),
                Text(data.value, style: AppTextStyles.cardTitle(context)),
                const SizedBox(height: VisualThemeV3.spacingXS),
                Text(data.subtitle, style: AppTextStyles.cardDetail(context)),
                const SizedBox(height: VisualThemeV3.spacingM),
                ClipRRect(
                  borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
                  child: LinearProgressIndicator(
                    value: data.progress.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.35),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
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

enum _BadgeTone { positive, neutral, warning }

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    this.tone = _BadgeTone.neutral,
    this.backgroundOverride,
    this.foregroundOverride,
  });

  final String label;
  final _BadgeTone tone;
  final Color? backgroundOverride;
  final Color? foregroundOverride;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color background;
    final Color foreground;
    switch (tone) {
      case _BadgeTone.positive:
        background =
            backgroundOverride ?? VisualThemeV3.success.withValues(alpha: 0.15);
        foreground = foregroundOverride ?? VisualThemeV3.success;
        break;
      case _BadgeTone.warning:
        background =
            backgroundOverride ?? VisualThemeV3.warning.withValues(alpha: 0.15);
        foreground = foregroundOverride ?? VisualThemeV3.warning;
        break;
      case _BadgeTone.neutral:
        background =
            backgroundOverride ?? colorScheme.surface.withValues(alpha: 0.6);
        foreground = foregroundOverride ?? colorScheme.onSurface;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VisualThemeV3.spacingS,
        vertical: VisualThemeV3.spacingXS,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
      ),
      child: Text(
        label,
        style: AppTextStyles.statusLabel(context, color: foreground),
      ),
    );
  }
}
