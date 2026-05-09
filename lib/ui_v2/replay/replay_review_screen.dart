import 'package:flutter/material.dart';

class ReplayReviewScreen extends StatelessWidget {
  final dynamic replayPath;
  final int heroSeat;

  const ReplayReviewScreen({
    super.key,
    required this.replayPath,
    required this.heroSeat,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Replay Review Module (Disabled)")),
    );
  }
}
