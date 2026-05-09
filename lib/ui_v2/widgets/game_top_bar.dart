import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poker_analyzer/core/state/game_economy.dart';

class GameTopBar extends StatelessWidget {
  const GameTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E1B16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF1F8B4C),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Consumer<GameEconomy>(
            builder: (context, economy, _) {
              return Text(
                '🪙 ${economy.bankroll}',
                style: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          const Text('Chips', style: TextStyle(color: Colors.white70)),
          const Spacer(),
          Row(
            children: const [
              Icon(Icons.local_fire_department, color: Colors.orangeAccent),
              SizedBox(width: 4),
              Text('🔥 3 Days', style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
