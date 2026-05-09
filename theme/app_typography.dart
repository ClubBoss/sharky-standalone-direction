import 'package:flutter/material.dart';

/// Minimal typography tokens for v2 UI components.
/// This file intentionally keeps a small surface area to avoid ripple changes.
abstract class AppTypography {
  static const TextStyle h1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle body = TextStyle(fontSize: 14, color: Colors.white70);

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.white60,
  );
}
