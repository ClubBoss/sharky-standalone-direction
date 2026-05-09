import "dart:core" as core;
import 'dart:core';
import '../models/v2/hero_position.dart';

extension HeroPositionX on HeroPosition {
  String get label {
    final s = toString();
    return s.contains('.') ? s.split('.').last : s;
  }
}
