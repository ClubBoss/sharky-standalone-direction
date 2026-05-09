import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/localization_core.dart';

import 'player_explanation_overlay.dart';
import 'player_profile_explanation_layer.dart';
import 'player_profile_models.dart';
import 'player_stat_visualizer.dart';
import 'player_stat_visualizer_models.dart';
import 'player_trait_visualizer.dart';
import 'player_trait_visualizer_models.dart';
import 'ux_feedback_animations.dart';
import 'ux_feedback_animation_models.dart';
import 'ux_feedback_animation_renderer_flutter.dart' as renderer;

final LocalizationCore _localization = LocalizationCore.instance;

Widget buildPlayerProfileScreen(PlayerProfileData data) =>
    _PlayerProfileScreen(data: data);

Future<void> showPlayerProfileTutorial(
  BuildContext context,
  PlayerProfileData data, {
  TickerProvider? tickerProvider,
}) => _showTutorial(context, data, tickerProvider: tickerProvider);

class _PlayerProfileScreen extends StatefulWidget {
  const _PlayerProfileScreen({required this.data});

  final PlayerProfileData data;

  @override
  State<_PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<_PlayerProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _tutorialShown = false;
  StreamSubscription<PlayerProfileSurfaceEvent>? _surfaceSub;
  final _explanationController = PlayerExplanationOverlayController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.data.showTutorial && !_tutorialShown) {
        _tutorialShown = true;
        _showTutorial(context, widget.data, tickerProvider: this);
      }
    });
    _surfaceSub = PlayerProfileSurfaceController.instance.events.listen(
      (event) => unawaited(_handleSurfaceEvent(event)),
    );
  }

  @override
  void dispose() {
    _surfaceSub?.cancel();
    _explanationController.dispose();
    super.dispose();
  }

  Future<void> _handleSurfaceEvent(PlayerProfileSurfaceEvent event) async {
    if (!mounted) return;
    if (event.statGain != null) {
      await PlayerStatVisualizer.showStatGain(context, event.statGain!);
    }
    if (!mounted) return;
    if (event.traitGain != null) {
      await PlayerTraitVisualizer.showTraitGain(context, event.traitGain!);
    }
    if (!mounted) return;
    if (event.showOverlay) {
      final overlayData = await PlayerProfileExplanationLayer.loadData();
      if (!mounted) return;
      await PlayerProfileExplanationLayer.showExplanationLayer(
        context,
        overlayData,
      );
    }
    unawaited(
      Telemetry.logEvent('player_profile_surface_completed', {
        'trigger': event.trigger.analyticsLabel,
        if (event.statGain != null) 'stat': event.statGain!.statName,
        if (event.traitGain != null) 'trait': event.traitGain!.name,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _l(context, 'player_profile_screen_title', 'Player Profile'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: _l(context, 'player_profile_legend_tooltip', 'Legend'),
            onPressed: () => _showLegend(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(
                title: _l(
                  context,
                  'player_profile_mastery_section_title',
                  'Mastery Progress',
                ),
                subtitle: _l(
                  context,
                  'player_profile_mastery_section_subtitle',
                  'Tap the ? icons to understand XP, ranks, and traits.',
                ),
                onHelp: () => _explanationController.show(),
              ),
              if (widget.data.stats.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    _l(
                      context,
                      'player_profile_empty_stats',
                      'No mastery stats available yet.',
                    ),
                  ),
                ),
              if (widget.data.stats.isNotEmpty)
                ...widget.data.stats.map((stat) => _StatTile(stat)),
              const SizedBox(height: 24),
              _SectionHeader(
                title: _l(
                  context,
                  'player_profile_traits_section_title',
                  'Active Traits',
                ),
                subtitle: _l(
                  context,
                  'player_profile_traits_section_subtitle',
                  'Unique bonuses unlocked via synergy events.',
                ),
              ),
              if (widget.data.traits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    _l(
                      context,
                      'player_profile_empty_traits',
                      'Earn traits by progressing multiple skills together.',
                    ),
                  ),
                ),
              if (widget.data.traits.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.data.traits
                      .map((trait) => _TraitChip(trait))
                      .toList(),
                ),
            ],
          ),
          PlayerExplanationOverlay(controller: _explanationController),
        ],
      ),
    );
  }

  Future<void> _showLegend(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l(context, 'player_profile_legend_heading', 'How mastery grows'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _l(
                context,
                'player_profile_legend_body',
                '- XP raises each mastery bar.\n'
                    '- Rank milestones amplify rewards and animations.\n'
                    '- Synergy unlocks rare traits.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.onHelp,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onHelp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (onHelp != null)
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: _l(
                  context,
                  'player_profile_help_tooltip',
                  'Explain XP',
                ),
                onPressed: onHelp,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.stat);

  final PlayerStatProfile stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelLabel = _l(context, 'player_profile_level_label', 'Level');
    final rankLabel = _l(context, 'player_profile_rank_label', 'Rank');
    final xpLabel = _l(context, 'player_profile_xp_label', 'XP');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stat.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Tooltip(
                  message:
                      '$levelLabel ${stat.level} | $rankLabel ${stat.rank}',
                  child: const Icon(Icons.info_outline, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: stat.progress.clamp(0, 1).toDouble(),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '$xpLabel ${stat.xp.toStringAsFixed(1)} | $rankLabel ${stat.rank}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TraitChip extends StatelessWidget {
  const _TraitChip(this.trait);

  final PlayerTraitProfile trait;

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = Color(int.parse(trait.color.replaceFirst('#', '0xff')));
    } catch (_) {
      color = Theme.of(context).colorScheme.secondary;
    }
    return Tooltip(
      message: '${trait.description}\n${trait.bonus}',
      child: Chip(
        backgroundColor: color.withAlpha((0.12 * 255).round()),
        side: BorderSide(color: color),
        label: Text('${trait.name} (${trait.rarity})'),
      ),
    );
  }
}

Future<void> _showTutorial(
  BuildContext context,
  PlayerProfileData data, {
  TickerProvider? tickerProvider,
}) async {
  final overlay = Overlay.of(context);
  if (overlay != null && tickerProvider != null) {
    final host = renderer.AnimationHost(
      overlay: overlay,
      tickerProvider: tickerProvider,
    );
    await UxFeedbackAnimations.playFeedback(UxFeedbackType.success, host);
  }

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        _l(
          context,
          'player_profile_tutorial_welcome',
          'Welcome to your profile',
        ),
      ),
      content: Text(
        _l(
          context,
          'player_profile_tutorial_details',
          'Bars show mastery progression. Tap ? icons for explanations.\n'
              'Traits highlight rare bonuses unlocked through synergy.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_l(context, 'player_profile_tutorial_ack', 'Got it')),
        ),
      ],
    ),
  );
}

String _l(BuildContext context, String key, String fallback) {
  final locale = Localizations.maybeLocaleOf(context);
  final language = locale?.languageCode ?? 'en';
  final value = _localization.translate(key, language);
  return value == '[$key]' ? fallback : value;
}

enum PlayerProfileSurfaceTrigger {
  sessionEnd,
  drillCompleted,
  quizCompleted,
  rankUp,
}

extension on PlayerProfileSurfaceTrigger {
  String get analyticsLabel {
    switch (this) {
      case PlayerProfileSurfaceTrigger.sessionEnd:
        return 'session_end';
      case PlayerProfileSurfaceTrigger.drillCompleted:
        return 'drill_completed';
      case PlayerProfileSurfaceTrigger.quizCompleted:
        return 'quiz_completed';
      case PlayerProfileSurfaceTrigger.rankUp:
        return 'rank_up';
    }
  }
}

class PlayerProfileSurfaceEvent {
  const PlayerProfileSurfaceEvent({
    required this.trigger,
    this.statGain,
    this.traitGain,
    this.showOverlay = true,
  });

  final PlayerProfileSurfaceTrigger trigger;
  final StatGainEvent? statGain;
  final TraitGainEvent? traitGain;
  final bool showOverlay;
}

class PlayerProfileSurfaceController {
  PlayerProfileSurfaceController._();

  static final PlayerProfileSurfaceController instance =
      PlayerProfileSurfaceController._();

  final StreamController<PlayerProfileSurfaceEvent> _controller =
      StreamController<PlayerProfileSurfaceEvent>.broadcast();

  Stream<PlayerProfileSurfaceEvent> get events => _controller.stream;

  void sessionEnd({StatGainEvent? statGain, TraitGainEvent? traitGain}) {
    _dispatch(
      PlayerProfileSurfaceEvent(
        trigger: PlayerProfileSurfaceTrigger.sessionEnd,
        statGain: statGain,
        traitGain: traitGain,
      ),
    );
  }

  void drillCompleted({StatGainEvent? statGain}) {
    _dispatch(
      PlayerProfileSurfaceEvent(
        trigger: PlayerProfileSurfaceTrigger.drillCompleted,
        statGain: statGain,
      ),
    );
  }

  void quizCompleted({StatGainEvent? statGain}) {
    _dispatch(
      PlayerProfileSurfaceEvent(
        trigger: PlayerProfileSurfaceTrigger.quizCompleted,
        statGain: statGain,
      ),
    );
  }

  void rankUp({StatGainEvent? statGain, TraitGainEvent? traitGain}) {
    _dispatch(
      PlayerProfileSurfaceEvent(
        trigger: PlayerProfileSurfaceTrigger.rankUp,
        statGain: statGain,
        traitGain: traitGain,
      ),
    );
  }

  void _dispatch(PlayerProfileSurfaceEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }
}
