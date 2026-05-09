import 'dart:core';
import 'package:poker_analyzer/models/game_type.dart';

extension GameTypeExt on GameType {
  /// Human‑readable label used in UI. ASCII‑only.
  String get label {
    switch (name) {
      case 'cash':
        return 'Cash';
      case 'mtt':
        return 'MTT';
      case 'sng':
        return 'SNG';
      case 'spin':
        return 'Spin';
      default:
        return _titleCase(name);
    }
  }
}

String _titleCase(String s) {
  if (s.isEmpty) return s;
  if (s.length == 1) return s.toUpperCase();
  return s[0].toUpperCase() + s.substring(1).toLowerCase();
}
