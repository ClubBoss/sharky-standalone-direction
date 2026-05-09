import 'package:flutter/material.dart';
import 'dark_alert_dialog.dart';

import 'confetti_overlay.dart';

/// Simple dialog displayed when a skill track is completed.
class TrackCelebrationDialog extends StatelessWidget {
  final String trackId;
  final VoidCallback? onNext;
  const TrackCelebrationDialog({super.key, required this.trackId, this.onNext});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showConfettiOverlay(context);
    });
    return DarkAlertDialog(
      title: const Text(
        '🎉 Трек завершён!',
        style: TextStyle(color: Colors.white),
      ),
      content: Text(trackId, style: const TextStyle(color: Colors.white70)),
      actions: [
        if (onNext != null)
          TextButton(
            onPressed: onNext,
            child: const Text('Открыть следующий трек'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

Future<void> showTrackCelebrationDialog(
  BuildContext context,
  String trackId, {
  VoidCallback? onNext,
}) => showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => TrackCelebrationDialog(trackId: trackId, onNext: onNext),
);
