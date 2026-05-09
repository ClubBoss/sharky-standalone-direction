import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class SidePotLayout {
  SidePotLayout({required this.boardPosition, required this.potCount}) {
    _centers = List<Offset>.generate(math.max(1, potCount), _computeCenter);
  }

  final Offset boardPosition;
  final int potCount;
  late final List<Offset> _centers;

  Offset getPotCenter(int index) {
    if (_centers.isEmpty) {
      return boardPosition;
    }
    final safeIndex = math.max(0, math.min(_centers.length - 1, index));
    return _centers[safeIndex];
  }

  int get count => _centers.length;

  Offset _computeCenter(int index) {
    if (index == 0) {
      return boardPosition;
    }
    final spread = math.pi / 3;
    final relative = index - 1;
    final total = math.max(1, potCount - 1);
    final angle = -spread / 2 + (spread * relative / total);
    final radius = 60 + relative * 16;
    return Offset(
      boardPosition.dx + radius * math.cos(angle),
      boardPosition.dy - radius * math.sin(angle),
    );
  }
}
