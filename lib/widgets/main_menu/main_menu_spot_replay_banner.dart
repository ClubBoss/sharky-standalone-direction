import 'package:flutter/material.dart';

/// Main menu banner that invites the user to quickly replay mistakes.
///
/// Shown only when [count] > 0. Tapping the CTA triggers [onLaunch].
class MainMenuSpotReplayBanner extends StatelessWidget {
  final int count;
  final VoidCallback onLaunch;

  const MainMenuSpotReplayBanner({
    super.key,
    required this.count,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.grey[850],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.replay, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Review Mistakes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have $count hands to replay',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: onLaunch, child: const Text('Start')),
            ],
          ),
        ),
      ),
    );
  }
}
