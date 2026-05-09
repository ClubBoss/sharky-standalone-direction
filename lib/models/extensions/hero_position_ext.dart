import 'dart:core';
import '../v2/hero_position.dart';

extension HeroPositionExt on HeroPosition {
  /// Human-readable label for UI. ASCII-only.
  String get label {
    switch (this) {
      case HeroPosition.utg:
        return 'UTG';
      case HeroPosition.mp:
        return 'MP';
      case HeroPosition.co:
        return 'CO';
      case HeroPosition.btn:
        return 'BTN';
      case HeroPosition.sb:
        return 'SB';
      case HeroPosition.bb:
        return 'BB';
      case HeroPosition.unknown:
        return 'Unknown';
    }
  }
}
