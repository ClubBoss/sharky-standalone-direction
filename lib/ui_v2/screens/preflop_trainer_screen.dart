import 'dart:convert';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:poker_analyzer/core/state/game_economy.dart';
import 'package:poker_analyzer/ui_v2/widgets/cards/poker_card.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual/chip_stack_widget.dart';

class PreflopTrainerScreen extends StatefulWidget {
  static const routeName = '/trainer';

  const PreflopTrainerScreen({super.key});

  @override
  State createState() => _PreflopTrainerScreenState();
}

class _PreflopTrainerScreenState extends State<PreflopTrainerScreen> {
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  final List<Map<String, dynamic>> _scenarios = [];
  bool _isLoading = true;
  bool? _lastCorrect;
  String? _lastExplanation;
  bool _deckCompleted = false;
  int _correctSwipes = 0;
  int _totalSwipes = 0;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    try {
      print('Loading drills from content/preflop_drills.json...');
      final content = await rootBundle.loadString(
        'content/preflop_drills.json',
      );
      final parsed = jsonDecode(content) as List<dynamic>;
      final scenarios = parsed
          .map(
            (item) => Map<String, dynamic>.from(item as Map<String, dynamic>),
          )
          .toList();
      if (mounted) {
        setState(() {
          _scenarios
            ..clear()
            ..addAll(scenarios);
          _isLoading = false;
        });
        print('Loaded ${scenarios.length} drills.');
      }
    } catch (error, stack) {
      print('Error loading drills: $error\n$stack');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load drills: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        title: const Text('Preflop Trainer'),
        backgroundColor: const Color(0xFF1B262C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart, color: Colors.blueAccent),
            tooltip: 'View Table',
            onPressed: _showSimulation,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Main swiper area with proper constraints
                Positioned.fill(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 70,
                      ), // Space for instruction banner
                      Expanded(
                        child: Center(child: _buildSwiperArea(constraints)),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * 0.2,
                      ), // Space for feedback
                    ],
                  ),
                ),
                // Instruction banner
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.8),
                            Colors.purpleAccent.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.swipe,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'LEFT = Fold  •  RIGHT = Push',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Feedback area
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _buildFeedback(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwiperArea(BoxConstraints constraints) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

    if (_scenarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            const Text(
              'No drills found.',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadScenarios();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate card dimensions based on available space
    final maxCardWidth = constraints.maxWidth * 0.85;
    final maxCardHeight = constraints.maxHeight * 0.65;
    final cardWidth = maxCardWidth.clamp(280.0, 360.0);
    final cardHeight = maxCardHeight.clamp(380.0, 520.0);

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: AppinioSwiper(
        cardCount: _scenarios.length,
        controller: _swiperController,
        swipeOptions: const SwipeOptions.only(left: true, right: true),
        onSwipeEnd: (previousIndex, _, activity) {
          if (previousIndex < 0 || previousIndex >= _scenarios.length) {
            return;
          }
          _handleSwipe(previousIndex, activity.direction);
        },
        onEnd: _handleEnd,
        cardBuilder: (context, index) {
          return _buildDrillCard(index);
        },
      ),
    );
  }

  Widget _buildDrillCard(int index) {
    final scenario = _scenarios[index];
    final heroHand =
        scenario['heroHand']?.toString() ?? scenario['hand']?.toString() ?? '';
    final position = scenario['position']?.toString() ?? '';
    final entryFee = scenario['entryFee'] as int? ?? 0;

    // Parse hero hand (e.g., "As,Kd" or "AKs")
    final cards = _parseHeroHand(heroHand);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1E3A5F), const Color(0xFF0F1419)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 320,
          height: 450,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Position badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent, width: 1),
                  ),
                  child: Text(
                    position.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Hero cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PokerCard(rank: cards[0].rank, suit: cards[0].suit),
                    const SizedBox(width: 12),
                    PokerCard(rank: cards[1].rank, suit: cards[1].suit),
                  ],
                ),
                const SizedBox(height: 32),
                // Entry fee (if applicable)
                if (entryFee > 0) ...[
                  const Text(
                    'Entry Fee',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ChipStackWidget(amount: entryFee.toDouble()),
                  const SizedBox(height: 8),
                  Text(
                    '\$$entryFee',
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const Spacer(),
                // Card count indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${index + 1} / ${_scenarios.length}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<({String rank, String suit})> _parseHeroHand(String heroHand) {
    // Handle comma-separated format: "As,Kd"
    if (heroHand.contains(',')) {
      final parts = heroHand.split(',').map((e) => e.trim()).toList();
      final cards = <({String rank, String suit})>[];

      for (final part in parts) {
        if (part.length >= 2) {
          final rank = part.substring(0, part.length - 1);
          final suit = part.substring(part.length - 1).toLowerCase();
          cards.add((rank: rank, suit: suit));
        }
      }

      if (cards.length >= 2) return cards.sublist(0, 2);
    }

    // Handle shorthand format: "AKs", "JTo", "99"
    final normalized = heroHand.toUpperCase().trim();
    if (normalized.length >= 2) {
      final rank1 = normalized[0];
      final rank2 = normalized.length > 1 ? normalized[1] : rank1;
      final suffix = normalized.length > 2 ? normalized[2] : '';

      String suit1 = 's';
      String suit2 = 'h';

      if (suffix == 'S') {
        suit2 = 's'; // Suited
      } else if (suffix == 'O') {
        suit2 = 'd'; // Offsuit
      } else if (rank1 == rank2) {
        suit2 = 'd'; // Pocket pair
      }

      return [(rank: rank1, suit: suit1), (rank: rank2, suit: suit2)];
    }

    // Fallback
    return [(rank: 'A', suit: 's'), (rank: 'K', suit: 'd')];
  }

  void _handleSwipe(int index, AxisDirection direction) {
    final scenario = _scenarios[index];
    final expected = (scenario['action'] ?? 'push').toString().toLowerCase();
    if (direction != AxisDirection.left && direction != AxisDirection.right) {
      return;
    }
    final userAction = direction == AxisDirection.left ? 'fold' : 'push';
    final isCorrect = expected == userAction;

    // Haptic feedback
    if (isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    debugPrint(
      'Preflop swipe: ${scenario['heroHand'] ?? scenario['hand']} ($userAction vs $expected) -> ${isCorrect ? 'correct' : 'wrong'}',
    );

    setState(() {
      _deckCompleted = false;
      _lastCorrect = isCorrect;
      _lastExplanation = isCorrect ? null : scenario['explanation']?.toString();
      _totalSwipes++;
      if (isCorrect) {
        _correctSwipes++;
      }
    });
  }

  Future<void> _handleEnd() async {
    setState(() {
      _deckCompleted = true;
      _lastCorrect = null;
      _lastExplanation =
          'Deck complete. Restart the trainer to practice again.';
    });
    final perfect = _totalSwipes > 0 && _correctSwipes == _totalSwipes;
    const baseReward = 100;
    const streakBonus = 10;
    final perfectBonus = perfect ? 20 : 0;
    final totalReward = baseReward + streakBonus + perfectBonus;
    context.read<GameEconomy>().earn(totalReward);
    await _showRewardSheet(totalReward, perfect);
    if (mounted) {
      setState(() {
        _totalSwipes = 0;
        _correctSwipes = 0;
      });
    }
  }

  void _showSimulation() {
    final heroCards = _heroCardsForSimulation();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, __) {
            final currentPosition = _scenarios.isNotEmpty
                ? (_scenarios.first['position']?.toString() ?? 'Villain acts')
                : 'Villain acts';

            // Phase A stub: PokerTableView is unavailable, so show a placeholder.
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  List<String> _heroCardsForSimulation() {
    if (_scenarios.isEmpty) {
      return const ['As', 'Kd'];
    }

    final heroHand =
        _scenarios.first['heroHand']?.toString() ??
        _scenarios.first['hand']?.toString() ??
        '';
    final parsed = _parseHeroHand(heroHand);

    return [
      '${parsed[0].rank}${parsed[0].suit}',
      '${parsed[1].rank}${parsed[1].suit}',
    ];
  }

  Widget _buildFeedback() {
    if (_deckCompleted && _lastExplanation != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.2),
              Colors.purpleAccent.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.celebration, color: Colors.yellowAccent, size: 32),
            const SizedBox(height: 8),
            Text(
              _lastExplanation!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_lastCorrect == null) {
      return const SizedBox.shrink();
    }

    final color = _lastCorrect! ? Colors.greenAccent : Colors.redAccent;
    final icon = _lastCorrect! ? Icons.check_circle : Icons.cancel;
    final title = _lastCorrect! ? 'Correct!' : 'Wrong!';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 56),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          if (!_lastCorrect! && _lastExplanation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _lastExplanation!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showRewardSheet(int reward, bool isPerfect) async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF1B262C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                "Training Complete!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "+$reward Chips",
                style: const TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isPerfect) ...[
                const SizedBox(height: 8),
                const Text(
                  "Perfect Run Bonus! 🔥",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
