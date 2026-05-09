import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/instructor_mode.dart';
import 'package:poker_analyzer/ui_v2/session_playback_engine.dart';

/// Demo integration showing how to launch Instructor Mode
///
/// This can be added to your HUD overlay or any screen where you want
/// to enable collaborative session review.
class InstructorModeDemo extends StatelessWidget {
  const InstructorModeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instructor Mode Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.school),
              label: const Text('Launch Instructor Review'),
              onPressed: () => _launchInstructorMode(context),
            ),
            const SizedBox(height: 16),
            const Text(
              'Opens a split-view session review with\nannotations and playback controls',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _launchInstructorMode(BuildContext context) {
    // Example session data - replace with your actual session
    final sampleActions = [
      PlaybackAction(
        seat: 0,
        type: PlaybackActionType.bet,
        amount: 100,
        description: 'Player 1 opens UTG',
      ),
      PlaybackAction(
        seat: 2,
        type: PlaybackActionType.call,
        amount: 100,
        description: 'Player 3 calls from CO',
      ),
      PlaybackAction(
        seat: 4,
        type: PlaybackActionType.raise,
        amount: 350,
        description: 'Player 5 3-bets from BB',
      ),
      PlaybackAction(
        seat: 0,
        type: PlaybackActionType.fold,
        amount: 0,
        description: 'Player 1 folds',
      ),
      PlaybackAction(
        seat: 2,
        type: PlaybackActionType.call,
        amount: 250,
        description: 'Player 3 calls',
      ),
      PlaybackAction(
        seat: 4,
        type: PlaybackActionType.win,
        amount: 800,
        description: 'Player 5 wins pot',
      ),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InstructorReviewScreen(
          sessionId: 'demo_session_001',
          actions: sampleActions,
          board: ['Ah', 'Kd', 'Qc', '7s', '2h'],
          positions: ['UTG', 'MP', 'CO', 'BTN', 'SB', 'BB'],
          playerCount: 6,
        ),
      ),
    );
  }
}
