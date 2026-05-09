import 'package:flutter/material.dart';

import 'player_stat_visualizer_models.dart';
import 'ux_feedback_animations.dart';
import 'ux_feedback_animation_models.dart';
import 'ux_feedback_animation_renderer_flutter.dart' as renderer;

Future<void> showStatGain(BuildContext context, StatGainEvent event) async {
  final overlay = Overlay.of(context);
  final tickerProvider = Navigator.of(context);
  if (overlay != null && tickerProvider is TickerProvider) {
    final host = renderer.AnimationHost(
      overlay: overlay,
      tickerProvider: tickerProvider,
    );
    final type = event.deltaXp >= 0
        ? UxFeedbackType.success
        : UxFeedbackType.error;
    await UxFeedbackAnimations.playFeedback(type, host);
  }

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Stat Gain'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stat: ${event.statName}'),
          Text('XP +${event.deltaXp.toStringAsFixed(1)}'),
          Text('Level ${event.oldLevel} → ${event.newLevel}'),
          if (event.newRank != null) Text('New Rank: ${event.newRank}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}
