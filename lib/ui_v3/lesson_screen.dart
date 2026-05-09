import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:poker_analyzer/models/theory_mini_lesson_node.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/pinned_learning_service.dart';
import 'package:poker_analyzer/services/recap_completion_tracker.dart';
import 'package:poker_analyzer/services/review_completion_logger.dart';
import 'package:poker_analyzer/services/theory_booster_recall_engine.dart';
import 'package:poker_analyzer/services/theory_lesson_completion_logger.dart';
import 'package:poker_analyzer/services/theory_recall_impact_tracker.dart';
import 'package:poker_analyzer/services/theory_streak_service.dart';
import 'package:poker_analyzer/ui_v3/theme/app_text_styles.dart';
import 'package:poker_analyzer/ui_v3/theme/personalization_profile.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart'
    hide PersonalizationPalette;

/// V3-styled viewer for a [TheoryMiniLessonNode].
class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.lesson,
    this.recapTag,
    this.initialPosition,
  });

  final TheoryMiniLessonNode lesson;
  final String? recapTag;
  final int? initialPosition;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  late final DateTime _started;
  late final ScrollController _scrollController;
  late final AnimationController _entryController;
  late final Animation<Offset> _lessonSlide;
  late final Stopwatch _designLiftStopwatch;
  bool _pinned = false;
  bool _isReview = false;
  bool _tracked = false;
  bool _telemetrySent = false;
  bool _contentTelemetrySent = false;
  late final PersonalizationBridge _personalizationBridge;
  PersonalizationSnapshot _personalization = PersonalizationSnapshot.fallback;
  PersonalizationPalette _palette = PersonalizationPalette.fromSnapshot(
    PersonalizationSnapshot.fallback,
  );

  @override
  void initState() {
    super.initState();
    _started = DateTime.now();
    _designLiftStopwatch = Stopwatch()..start();
    _scrollController = ScrollController(
      initialScrollOffset: (widget.initialPosition ?? 0).toDouble(),
    );
    _entryController = AnimationController(
      vsync: this,
      duration: VisualThemeV3.speedSlow,
    )..forward();
    _lessonSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );
    _pinned = PinnedLearningService.instance.isPinned(
      'lesson',
      widget.lesson.id,
    );
    _personalizationBridge = PersonalizationBridge();
    PinnedLearningService.instance.addListener(_syncPinnedState);
    unawaited(
      PinnedLearningService.instance.recordOpen('lesson', widget.lesson.id),
    );
    unawaited(
      TheoryBoosterRecallEngine.instance.recordLaunch(widget.lesson.id),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emitDesignLiftTelemetry();
    });
    _loadPersonalization();
  }

  void _syncPinnedState() {
    final pinned = PinnedLearningService.instance.isPinned(
      'lesson',
      widget.lesson.id,
    );
    if (pinned != _pinned) {
      setState(() => _pinned = pinned);
    }
  }

  Future<void> _togglePinned() async {
    await PinnedLearningService.instance.toggle('lesson', widget.lesson.id);
    _syncPinnedState();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_pinned ? 'Pinned' : 'Unpinned'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is bool && args) {
      _isReview = true;
    } else if (args is Map && args['isReview'] == true) {
      _isReview = true;
    }
    if (!_tracked) {
      String? tag = widget.recapTag;
      if (tag == null) {
        if (args is String) {
          tag = args;
        } else if (args is Map && args['tag'] is String) {
          tag = args['tag'] as String;
        }
      }
      if (tag != null) {
        unawaited(
          TheoryRecallImpactTracker.instance.record(tag, widget.lesson.id),
        );
      }
      _tracked = true;
    }
  }

  @override
  void dispose() {
    if (_designLiftStopwatch.isRunning) {
      _designLiftStopwatch.stop();
    }
    _entryController.dispose();
    PinnedLearningService.instance.removeListener(_syncPinnedState);
    PinnedLearningService.instance.setLastPosition(
      'lesson',
      widget.lesson.id,
      _scrollController.offset.round(),
    );
    _scrollController.dispose();
    final tag = widget.recapTag;
    if (tag != null) {
      final duration = DateTime.now().difference(_started);
      unawaited(
        RecapCompletionTracker.instance.logCompletion(
          widget.lesson.id,
          tag,
          duration,
        ),
      );
      unawaited(TheoryStreakService.instance.recordToday());
    }
    unawaited(
      TheoryLessonCompletionLogger.instance.markCompleted(widget.lesson.id),
    );
    if (_isReview) {
      unawaited(ReviewCompletionLogger.instance.logReview(widget.lesson.id));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    return Theme(
      data: VisualThemeV3.theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.lesson.resolvedTitle),
          actions: [
            IconButton(
              icon: Icon(_pinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: _togglePinned,
              tooltip: _pinned ? 'Unpin lesson' : 'Pin lesson',
            ),
          ],
        ),
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
                  const SizedBox(height: VisualThemeV3.spacingM),
                  _buildMetaRow(palette),
                  const SizedBox(height: VisualThemeV3.spacingL),
                  Expanded(child: _buildLessonContent(palette)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PersonalizationPalette palette) {
    final tags = widget.lesson.tags;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lesson', style: AppTextStyles.statusLabel(context)),
        const SizedBox(height: VisualThemeV3.spacingXS),
        Text(
          widget.lesson.resolvedTitle,
          style: AppTextStyles.pageTitle(context),
        ),
        const SizedBox(height: VisualThemeV3.spacingS),
        const SizedBox(height: VisualThemeV3.spacingXL),
        Text(
          'Review mini-lessons to reinforce your current streak.',
          style: AppTextStyles.pageSubtitle(context),
        ),
        const SizedBox(height: VisualThemeV3.spacingXS),
        Text(
          'AI focus: ${_personalization.recommendedModule}',
          style: AppTextStyles.cardDetail(
            context,
          ).copyWith(color: palette.accent),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: VisualThemeV3.spacingS),
          Wrap(
            spacing: VisualThemeV3.spacingS,
            runSpacing: VisualThemeV3.spacingS,
            children: [
              for (final tag in tags.take(4))
                _TagPill(
                  label: tag,
                  backgroundColor: palette.badgeBackground,
                  foregroundColor: palette.badgeForeground,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMetaRow(PersonalizationPalette palette) {
    final targetStreet = widget.lesson.targetStreet ?? 'All Streets';
    final stage = widget.lesson.stage ?? 'Unranked';
    final cards = <Widget>[
      _LessonMetaCard(
        title: 'AI Focus',
        value: _personalization.recommendedModule,
        icon: Icons.auto_awesome,
        accentColor: palette.accent,
      ),
      _LessonMetaCard(
        title: 'Target Street',
        value: targetStreet,
        icon: Icons.route,
      ),
      _LessonMetaCard(
        title: 'Stage',
        value: stage,
        icon: Icons.stacked_line_chart,
      ),
      _LessonActionCard(
        title: _pinned ? 'Pinned' : 'Pin Lesson',
        subtitle: _pinned ? 'Quick access enabled' : 'Add to pinned hub',
        icon: _pinned ? Icons.push_pin : Icons.push_pin_outlined,
        onTap: _togglePinned,
      ),
    ];

    return Wrap(
      spacing: VisualThemeV3.spacingM,
      runSpacing: VisualThemeV3.spacingM,
      children: cards,
    );
  }

  Widget _buildLessonContent(PersonalizationPalette palette) {
    return SlideTransition(
      position: _lessonSlide,
      child: Material(
        color: VisualThemeV3.primary,
        elevation: VisualThemeV3.elevationMedium,
        shadowColor: VisualThemeV3.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
          onTap: () {}, // enables ripple for tap feedback when scrolling stops
          splashColor: palette.accent.withValues(alpha: 0.12),
          child: AnimatedContainer(
            duration: VisualThemeV3.speedNormal,
            decoration: BoxDecoration(
              gradient: palette.cardGradient,
              color: VisualThemeV3.cardLight,
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
              border: Border.all(
                color: VisualThemeV3.surfaceDark.withValues(alpha: 0.2),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.all(VisualThemeV3.spacingL),
            child: Markdown(
              controller: _scrollController,
              data: widget.lesson.resolvedContent,
              physics: const BouncingScrollPhysics(),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                    h1: AppTextStyles.cardTitle(context),
                    h2: AppTextStyles.cardTitle(context),
                    p: AppTextStyles.cardDetail(context),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void _emitDesignLiftTelemetry() {
    if (_telemetrySent) return;
    _telemetrySent = true;
    if (_designLiftStopwatch.isRunning) {
      _designLiftStopwatch.stop();
    }
    FirebaseLiteTelemetryService.instance.logEvent(
      'design_lift_lessonscreen_completed',
      params: <String, Object>{
        'widgets_updated': 4, // header, meta chips, meta cards, lesson card
        'duration_ms': _designLiftStopwatch.elapsedMilliseconds,
      },
    );
  }

  Future<void> _loadPersonalization() async {
    final snapshot = await _personalizationBridge.loadSnapshot();
    if (!mounted) return;
    setState(() {
      _personalization = snapshot;
      _palette = PersonalizationPalette.fromSnapshot(snapshot);
    });
    _emitContentSurfaceTelemetry(snapshot);
  }

  void _emitContentSurfaceTelemetry(PersonalizationSnapshot snapshot) {
    if (_contentTelemetrySent) return;
    _contentTelemetrySent = true;
    FirebaseLiteTelemetryService.instance.logEvent(
      'content_surface_unified',
      params: <String, Object>{
        'screen': 'lesson',
        'mood': snapshot.mood,
        'recommended_module': snapshot.recommendedModule,
      },
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VisualThemeV3.spacingS,
        vertical: VisualThemeV3.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
      ),
      child: Text(
        label,
        style: AppTextStyles.statusLabel(context, color: foregroundColor),
      ),
    );
  }
}

class _LessonMetaCard extends StatelessWidget {
  const _LessonMetaCard({
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(VisualThemeV3.cardRadius);
    final tone = accentColor ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 220,
      child: Material(
        color: VisualThemeV3.primary,
        elevation: VisualThemeV3.elevationLow,
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.all(VisualThemeV3.spacingM),
          decoration: BoxDecoration(
            gradient: VisualThemeV3.brandBackgroundGradient,
            borderRadius: borderRadius,
            border: Border.all(color: tone.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: tone),
              const SizedBox(width: VisualThemeV3.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.statusLabel(context, color: tone),
                    ),
                    const SizedBox(height: VisualThemeV3.spacingXS),
                    Text(
                      value,
                      style: AppTextStyles.cardTitle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonActionCard extends StatelessWidget {
  const _LessonActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(VisualThemeV3.cardRadius);
    return SizedBox(
      width: 220,
      child: Material(
        color: VisualThemeV3.primary,
        elevation: VisualThemeV3.elevationLow,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          splashColor: VisualThemeV3.accentSecondary.withValues(alpha: 0.12),
          child: AnimatedContainer(
            duration: VisualThemeV3.speedFast,
            padding: const EdgeInsets.all(VisualThemeV3.spacingM),
            decoration: BoxDecoration(
              gradient: VisualThemeV3.marketingAccentGradient,
              borderRadius: borderRadius,
              boxShadow: const [VisualThemeV3.shadowMedium],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: VisualThemeV3.primary),
                const SizedBox(height: VisualThemeV3.spacingS),
                Text(
                  title,
                  style: AppTextStyles.cardTitle(
                    context,
                    color: VisualThemeV3.primary,
                  ),
                ),
                const SizedBox(height: VisualThemeV3.spacingXS),
                Text(
                  subtitle,
                  style: AppTextStyles.cardDetail(
                    context,
                    color: VisualThemeV3.primary.withValues(alpha: 0.9),
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
