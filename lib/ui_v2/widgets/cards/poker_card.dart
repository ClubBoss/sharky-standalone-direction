import 'package:flutter/material.dart';

class PokerCard extends StatelessWidget {
  final String rank;
  final String suit;

  const PokerCard({super.key, required this.rank, required this.suit});

  static const _suitMap = {'s': '♠', 'h': '♥', 'd': '♦', 'c': '♣'};

  static const _redSuits = {'h', 'd'};

  Color get _suitColor => _redSuits.contains(suit.toLowerCase())
      ? const Color(0xFFE53935)
      : const Color(0xFF212121);

  String get _symbol => _suitMap[suit.toLowerCase()] ?? '♠';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 84,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rank,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _suitColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(_symbol, style: TextStyle(fontSize: 20, color: _suitColor)),
          ],
        ),
      ),
    );
  }
}
