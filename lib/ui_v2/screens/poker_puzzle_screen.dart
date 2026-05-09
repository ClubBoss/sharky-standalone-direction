import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:poker_analyzer/core/models/poker_puzzle.dart';
import 'package:poker_analyzer/core/state/game_economy.dart';
import 'package:poker_analyzer/ui_v2/widgets/table/poker_table_view.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual/glass_action_button.dart';
import 'package:poker_analyzer/ui_v2/widgets/feedback/game_feedback_overlay.dart';
import 'package:poker_analyzer/ui_v2/widgets/bet/bet_sizing_panel.dart';
import 'package:poker_analyzer/ui_v2/home/direct_loader.dart';

class PokerPuzzleScreen extends StatefulWidget {
  const PokerPuzzleScreen({super.key, this.moduleId});

  final String? moduleId;

  @override
  State<PokerPuzzleScreen> createState() => _PokerPuzzleScreenState();
}

class _PokerPuzzleScreenState extends State<PokerPuzzleScreen> {
  List<PokerPuzzle> _puzzles = [];
  int _currentIndex = 0;
  int _correctAnswers = 0;
  bool _isLoading = true;
  bool _isRaising = false;

  @override
  void initState() {
    super.initState();
    _loadPuzzles();
  }

  Future<void> _loadPuzzles() async {
    final moduleId = widget.moduleId;
    debugPrint(
      moduleId == null
          ? 'Attempting to load: content/puzzles.json'
          : 'Attempting to load: assets/content/$moduleId/puzzles.json',
    );
    try {
      final content = moduleId == null
          ? await rootBundle.loadString('content/puzzles.json')
          : await DirectLoader.loadContentFile(moduleId, 'puzzles.json');

      if (content.trimLeft().startsWith('# Error')) {
        debugPrint('Error loading puzzles for module $moduleId: $content');
        setState(() => _isLoading = false);
        return;
      }

      debugPrint(
        'Loaded puzzles content: ${content.substring(0, 100.clamp(0, content.length))}...',
      );
      final List<dynamic> jsonList = jsonDecode(content);
      debugPrint('Parsed ${jsonList.length} puzzles from JSON');
      setState(() {
        _puzzles = jsonList.map((json) => PokerPuzzle.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error loading puzzles: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  void _handleAction(PuzzleAction action) {
    HapticFeedback.lightImpact();
    final puzzle = _puzzles[_currentIndex];
    if (action == puzzle.correctAction) {
      HapticFeedback.mediumImpact();
      _correctAnswers++;
      _showFeedbackOverlay(isCorrect: true, explanation: '', xpReward: 100);
    } else {
      HapticFeedback.heavyImpact();
      _showFeedbackOverlay(
        isCorrect: false,
        explanation: puzzle.explanation,
        xpReward: 0,
      );
    }
  }

  Future<void> _showFeedbackOverlay({
    required bool isCorrect,
    required String explanation,
    required int xpReward,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GameFeedbackOverlay(
        isCorrect: isCorrect,
        explanation: explanation,
        xpReward: xpReward,
        onContinue: () {
          Navigator.pop(context);
          _nextPuzzle();
        },
      ),
    );
  }

  void _nextPuzzle() {
    if (_currentIndex < _puzzles.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finishSession();
    }
  }

  void _finishSession() {
    final reward = (_puzzles.isEmpty)
        ? 0
        : (_correctAnswers / _puzzles.length * 30).round();
    context.read<GameEconomy>().earn(reward);
    _showRewardSheet(reward);
  }

  Future<void> _showRewardSheet(int reward) async {
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
                "Session Complete!",
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

  Widget _buildActionButton(PuzzleAction action) {
    switch (action) {
      case PuzzleAction.fold:
        return PokerActionButtons.fold(onTap: () => _handleAction(action));
      case PuzzleAction.call:
        return PokerActionButtons.call(onTap: () => _handleAction(action));
      case PuzzleAction.raise:
        return PokerActionButtons.raise(
          onTap: () {
            setState(() => _isRaising = true);
            _showBetSizingPanel();
          },
        );
    }
  }

  Future<void> _showBetSizingPanel() {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BetSizingPanel(
        minBet: 10,
        maxBet: 1000,
        potSize: _puzzles[_currentIndex].potSize.toDouble(),
        onBetConfirmed: (betAmount) {
          Navigator.pop(context);
          setState(() => _isRaising = false);
          _handleAction(PuzzleAction.raise);
        },
        onCancel: () {
          Navigator.pop(context);
          setState(() => _isRaising = false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_puzzles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Situation Challenge")),
        body: const Center(child: Text("No puzzles found")),
      );
    }

    final puzzle = _puzzles[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Situation Challenge")),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. THE TABLE (Takes all available space)
            Expanded(
              flex: 3, // Takes ~60% of screen
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 8.0,
                ),
                child: PokerTableView(puzzle: puzzle),
              ),
            ),
            // 2. INFO TEXT (Middle)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                puzzle.villainAction,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // 3. BUTTONS (Bottom)
            if (!_isRaising)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                  left: 12,
                  right: 12,
                  top: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildActionButton(PuzzleAction.fold)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildActionButton(PuzzleAction.call)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildActionButton(PuzzleAction.raise)),
                  ],
                ),
              ),
            if (!_isRaising) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
