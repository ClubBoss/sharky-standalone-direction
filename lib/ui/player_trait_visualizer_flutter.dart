import 'package:flutter/material.dart';

import 'player_trait_visualizer_models.dart';
import 'ux_feedback_animations.dart';
import 'ux_feedback_animation_models.dart';
import 'ux_feedback_animation_renderer_flutter.dart' as renderer;

Future<void> showTraitGain(BuildContext context, TraitGainEvent event) async {
  final overlay = Overlay.of(context);
  final tickerProvider = Navigator.of(context);
  if (overlay != null && tickerProvider is TickerProvider) {
    final host = renderer.AnimationHost(
      overlay: overlay,
      tickerProvider: tickerProvider,
    );
    final type = event.rarity.toLowerCase().contains('legendary')
        ? UxFeedbackType.levelUp
        : UxFeedbackType.success;
    await UxFeedbackAnimations.playFeedback(type, host);
  }

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Trait Unlocked'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${event.name} · ${event.rarity}'),
          const SizedBox(height: 8),
          Text(event.description),
          const SizedBox(height: 8),
          Text(event.temporary ? 'Temporary effect' : 'Permanent boost'),
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
