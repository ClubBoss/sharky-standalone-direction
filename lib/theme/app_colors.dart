import 'package:flutter/material.dart';

/// AppColors for code under lib/** (v2 UI components).
class AppColors {
  // Base surfaces
  static const darkBackground = Color(0xFF10141A);
  static const lightBackground = Color(0xFFF7F9FC);
  static const darkCard = Color(0xFF1B222C);
  static const lightCard = Color(0xFFFFFFFF);
  static const background = darkBackground;
  static const cardBackground = darkCard;
  static const button = Color(0xFF0BAF5D);
  static Color accent = const Color(0xFF4FD1C5);
  static final errorBg = const Color(0x33FF4D4F);
  static const evPre = Color(0xFF009733);
  static const evPost = Color(0xFFC9A559);
  static const icmPre = Color(0xFF404B1E);
  static const icmPost = Color(0xFF675729);
  static const textPrimaryDark = Color(0xFFF5F7FA);
  static const textSecondaryDark = Color(0xFFCBD5E1);
  static const textPrimaryLight = Colors.black;
  static const textSecondaryLight = Colors.black54;
  static const surface = Color(0xFF161B22);
  // Additional tokens for refined surfaces and outlines
  static const surfaceVariant = Color(0xFF232325);
  static const outlineSoft = Color(0x33FFFFFF);
  static const progressBackground = Color(0x33FFFFFF);
  static const success = Color(0xFF2ECC71);
  static const info = Color(0xFF42A5F5);
  static const warning = Color(0xFFFCC419);
  static const error = Color(0xFFEF5350);
  static const overlay = Color(0xAA0D1117);
  static const shadow = Color(0x55000000);
  static const neutral = Color(0xFF4A5568);
  static const transparent = Colors.transparent;

  // Brand additions (append-only for v2 theme)
  static const primaryBrand = Color(0xFF00B894); // teal-green
  static const accentSuccess = Color(0xFF2ECC71);
  static const accentWarning = Color(0xFFF1C40F);
  static const neutralBg = Color(0xFF121212);
}
