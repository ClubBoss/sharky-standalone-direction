import 'package:flutter/material.dart';

import '../widgets/poker_analyzer_controls.dart';

/// Panel containing action controls and evaluation information.
class PokerAnalyzerActionPanel extends StatelessWidget {
  PokerAnalyzerActionPanel({super.key});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.grey.shade900,
    child: const PokerAnalyzerControls(),
  );
}
