import 'package:flutter/material.dart';

class RewardCardStyle {
  final List<Color> gradient;
  final IconData icon;
  final String badgeText;
  final Color badgeColor;

  RewardCardStyle({
    required this.gradient,
    required this.icon,
    required this.badgeText,
    required this.badgeColor,
  });
}

/// Provides visual style parameters for reward cards.
class RewardCardStyleTunerService {
  RewardCardStyleTunerService({Map<String, RewardCardStyle>? trackStyles})
    : _trackStyles = trackStyles ?? _defaultTrackStyles;

  final Map<String, RewardCardStyle> _trackStyles;

  static final RewardCardStyle _defaultStyle = RewardCardStyle(
    gradient: [const Color(0xFF512DA8), const Color(0xFF303F9F)],
    icon: Icons.emoji_events,
    badgeText: 'Завершено!',
    badgeColor: const Color(0xFF2E7D32),
  );

  static final Map<String, RewardCardStyle> _defaultTrackStyles = {
    'preflop': RewardCardStyle(
      gradient: [const Color(0xFF1565C0), const Color(0xFF0D47A1)],
      icon: Icons.play_arrow,
      badgeText: 'Готово',
      badgeColor: const Color(0xFF2E7D32),
    ),
    'postflop': RewardCardStyle(
      gradient: [const Color(0xFF00897B), const Color(0xFF00695C)],
      icon: Icons.filter_alt,
      badgeText: 'Готово',
      badgeColor: const Color(0xFF2E7D32),
    ),
  };

  /// Returns a style configuration for a given [trackId].
  RewardCardStyle getStyle(String trackId) =>
      _trackStyles[trackId] ?? _defaultStyle;
}
