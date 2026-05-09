import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/localization_core.dart';

import 'player_profile_explanation_layer.dart';
import 'ux_feedback_animations.dart';
import 'ux_feedback_animation_models.dart';
import 'ux_feedback_animation_renderer_flutter.dart' as renderer;

final LocalizationCore _localization = LocalizationCore.instance;

Future<void> showExplanationLayer(
  BuildContext context,
  PlayerProfileExplanationData data,
) async {
  final overlay = Overlay.of(context);
  final navigator = Navigator.of(context);
  if (overlay != null && navigator is TickerProvider) {
    final host = renderer.AnimationHost(
      overlay: overlay,
      tickerProvider: navigator,
    );
    await UxFeedbackAnimations.playFeedback(UxFeedbackType.levelUp, host);
  }

  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              _t(context, 'player_profile_mastery_title'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...data.stats.map((stat) => _StatTile(stat)),
            if (data.traits.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _t(context, 'player_profile_traits_section'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.traits
                    .map((trait) => _TraitChip(trait))
                    .toList(),
              ),
            ],
          ],
        ),
      );
    },
  );
}

Future<void> showTutorialOverlay(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(_t(context, 'player_profile_tutorial_title')),
      content: Text(_t(context, 'player_profile_tutorial_body')),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_t(context, 'player_profile_close')),
        ),
      ],
    ),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.stat);

  final StatExplanation stat;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stat.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Tooltip(
                  message:
                      '${_t(context, "player_profile_rank_label")} ${stat.rank}\n'
                      '${_t(context, "player_profile_progress_label")} ${(stat.progress * 100).toStringAsFixed(1)}%',
                  child: const Icon(Icons.help_outline, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: stat.progress.clamp(0, 1),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text(
              '${_t(context, "player_profile_level_label")} ${stat.level} '
              '• ${_t(context, "player_profile_xp_label")} ${stat.xp.toStringAsFixed(1)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _TraitChip extends StatelessWidget {
  const _TraitChip(this.trait);

  final TraitExplanation trait;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${trait.description}\n${trait.bonus}',
      child: Chip(label: Text('${trait.name} (${trait.rarity})')),
    );
  }
}

String _t(BuildContext context, String key) {
  final locale = Localizations.maybeLocaleOf(context);
  final language = locale?.languageCode ?? 'en';
  return _localization.translate(key, language);
}
