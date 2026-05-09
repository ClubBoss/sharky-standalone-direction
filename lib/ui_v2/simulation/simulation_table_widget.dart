import 'package:flutter/material.dart';
// Оставляем импорт, чтобы PlayerAction был доступен, если он нужен
import 'package:poker_analyzer/compat/player_action_compat.dart';

class SimulationTableWidget extends StatelessWidget {
  final dynamic engine;
  final PlayerAction? lastAction;

  const SimulationTableWidget({
    super.key,
    required this.engine,
    this.lastAction,
  });

  @override
  Widget build(BuildContext context) {
    final Stream<dynamic>? stream = engine?.eventStream;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: StreamBuilder<dynamic>(
          stream: stream,
          builder: (_, __) {
            final pot = engine?.pot ?? 0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'POT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '\$$pot',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Simulation Table Module (Disabled)',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
