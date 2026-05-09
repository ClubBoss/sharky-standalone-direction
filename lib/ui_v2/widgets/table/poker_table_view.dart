import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/core/models/poker_puzzle.dart';
import 'package:poker_analyzer/ui_v2/widgets/cards/poker_card.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual/chip_stack_widget.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual/poker_table_painter.dart';
import 'package:poker_analyzer/ui_v2/widgets/table/chip_animation_overlay.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual/glass_player_seat.dart';

class PokerTableView extends StatelessWidget {
  const PokerTableView({super.key, required this.puzzle});

  final PokerPuzzle puzzle;

  static const int _totalPlayers = 6;
  static const int _heroSeatIndex = 0;
  static const int _dealerIndexDefault = 3; // Typically across from hero

  // Aggressive 6-max seating positions for sleek, tall vertical racetrack table
  static const Map<int, Alignment> _sixMaxSeats = {
    0: Alignment(0.0, 1.0), // Hero - Bottom pole
    1: Alignment(0.92, 0.40), // Right Bottom (pulled closer vertically)
    2: Alignment(0.92, -0.50), // Right Top (pulled closer vertically)
    3: Alignment(
      0.0,
      -0.98,
    ), // Top Center - Near absolute pole (Active Villain)
    4: Alignment(-0.92, -0.50), // Left Top (pulled closer vertically)
    5: Alignment(-0.92, 0.40), // Left Bottom (pulled closer vertically)
  };

  /// Get seat alignment from lookup map for 6-max stadium table
  Alignment _getSeatAlignment(int seatIndex) {
    return _sixMaxSeats[seatIndex] ?? const Alignment(0.0, 0.0);
  }

  /// Calculate dealer button position relative to a seat
  Alignment _getDealerButtonAlignment(int dealerSeatIndex) {
    final seatAlignment = _getSeatAlignment(dealerSeatIndex);

    // Offset button further toward center to avoid overlapping avatar faces
    final offsetX = seatAlignment.x * 0.65;
    final offsetY = seatAlignment.y * 0.65;

    return Alignment(offsetX, offsetY);
  }

  @override
  Widget build(BuildContext context) {
    return ChipAnimationOverlay(
      puzzle: puzzle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Enforce sleek tall iPhone aspect ratio (GGPoker-style)
          final tableWidth = constraints.maxWidth;
          final tableHeight =
              tableWidth / 0.48; // Sleek, tall vertical racetrack

          return Center(
            child: SizedBox(
              width: tableWidth,
              height: tableHeight.clamp(0.0, constraints.maxHeight),
              child: AspectRatio(
                aspectRatio: 0.48, // Sleek vertical racetrack (GGPoker-style)
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildTableBackground(),
                    _buildBoard(),
                    _buildPot(),
                    _buildAllSeats(),
                    _buildDealerButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableBackground() {
    return CustomPaint(
      painter: PokerTablePainter(
        feltCenterColor: const Color(0xFF4B8B6E),
        feltEdgeColor: const Color(0xFF2D5743),
        railDarkColor: const Color(0xFF1A0F0A),
        railHighlightColor: const Color(0xFF3D2817),
        railBorderColor: const Color(0xFF6B4423),
        showBettingLine: true,
      ),
      child: Container(), // Empty container for the painter to fill
    );
  }

  Widget _buildBoard() {
    if (puzzle.boardCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: const Alignment(0.0, -0.22), // Moved higher to avoid pot
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: puzzle.boardCards.map((card) {
            final rank = _rankOf(card);
            final suit = _suitOf(card);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale:
                    0.45, // Scaled down to 45% for critical separation from glass seats
                child: PokerCard(rank: rank, suit: suit),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPot() {
    return Align(
      alignment: const Alignment(0.0, 0.32), // Moved lower for better spacing
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: ChipStackWidget(amount: puzzle.potSize.toDouble()),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${puzzle.potSize}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Pot',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSeats() {
    return Stack(
      clipBehavior: Clip.none,
      children: List.generate(_totalPlayers, (seatIndex) {
        final alignment = _getSeatAlignment(seatIndex);
        final isHero = seatIndex == _heroSeatIndex;
        final isActive = seatIndex == 3; // Active villain (configurable)
        final posName = _getPositionName(
          seatIndex,
          _dealerIndexDefault,
          _totalPlayers,
        );

        final playerInitials = isHero ? 'ME' : 'V${seatIndex + 1}';
        final stackAmount = isHero ? '1000 BB' : '500 BB';

        return Align(
          alignment: alignment,
          child: GlassPlayerSeat(
            playerInitials: playerInitials,
            positionLabel: posName,
            stackAmount: stackAmount,
            isHero: isHero,
            isActive: isActive,
            actionLabel: isActive ? puzzle.villainAction : null,
            thinkingTimePercent: isActive ? 0.0 : 0.0,
          ),
        );
      }),
    );
  }

  Widget _buildDealerButton() {
    final alignment = _getDealerButtonAlignment(_dealerIndexDefault);

    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'D',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  String _rankOf(String card) {
    if (card.isEmpty) return '?';
    return card.substring(0, card.length - 1);
  }

  String _suitOf(String card) {
    if (card.isEmpty) return 's';
    return card.characters.last;
  }
}

String _getPositionName(int seatIndex, int dealerIndex, int totalPlayers) {
  final normalized = ((seatIndex % totalPlayers) + totalPlayers) % totalPlayers;
  final btn = ((dealerIndex % totalPlayers) + totalPlayers) % totalPlayers;
  final sb = (btn + 1) % totalPlayers;
  final bb = (btn + 2) % totalPlayers;
  final utg = (btn + 3) % totalPlayers;
  final mp = (btn + 4) % totalPlayers;
  final co = (btn + 5) % totalPlayers;

  if (normalized == btn) return 'BTN';
  if (normalized == sb) return 'SB';
  if (normalized == bb) return 'BB';
  if (normalized == utg) return 'UTG';
  if (normalized == mp) return 'MP';
  if (normalized == co) return 'CO';
  return 'Seat ${normalized + 1}';
}
