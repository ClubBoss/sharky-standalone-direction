import 'package:flutter/material.dart';

/// Visual metadata for a training league tier.
class LeagueTierBadge {
  final String id;
  final String emoji;
  final Color color;
  final String labelEn;
  final String labelRu;
  final int minXp;

  const LeagueTierBadge({
    required this.id,
    required this.emoji,
    required this.color,
    required this.labelEn,
    required this.labelRu,
    required this.minXp,
  });

  String label(String locale) => locale == 'ru' ? labelRu : labelEn;

  static LeagueTierBadge resolve({int? xp, String? tierId}) {
    if (tierId != null) {
      final match = _badges.firstWhere(
        (badge) => badge.id == tierId,
        orElse: () => _badges.last,
      );
      return match;
    }
    final value = xp ?? 0;
    for (final badge in _badges) {
      if (value >= badge.minXp) {
        return badge;
      }
    }
    return _badges.last;
  }

  static LeagueTierBadge fromXp(int xp) => resolve(xp: xp);
}

const List<LeagueTierBadge> _badges = [
  LeagueTierBadge(
    id: 'legend',
    emoji: '🔥',
    color: Color(0xFFE65100),
    labelEn: 'Legend',
    labelRu: 'Легенда',
    minXp: 22000,
  ),
  LeagueTierBadge(
    id: 'champion',
    emoji: '👑',
    color: Color(0xFF8E24AA),
    labelEn: 'Champion',
    labelRu: 'Чемпион',
    minXp: 18000,
  ),
  LeagueTierBadge(
    id: 'diamond',
    emoji: '💎',
    color: Color(0xFF1E88E5),
    labelEn: 'Diamond',
    labelRu: 'Алмаз',
    minXp: 14000,
  ),
  LeagueTierBadge(
    id: 'platinum',
    emoji: '🌟',
    color: Color(0xFF26A69A),
    labelEn: 'Platinum',
    labelRu: 'Платина',
    minXp: 11000,
  ),
  LeagueTierBadge(
    id: 'gold',
    emoji: '🥇',
    color: Color(0xFFFBC02D),
    labelEn: 'Gold',
    labelRu: 'Золото',
    minXp: 8000,
  ),
  LeagueTierBadge(
    id: 'silver',
    emoji: '🥈',
    color: Color(0xFF9E9E9E),
    labelEn: 'Silver',
    labelRu: 'Серебро',
    minXp: 5000,
  ),
  LeagueTierBadge(
    id: 'bronze',
    emoji: '🥉',
    color: Color(0xFFB87333),
    labelEn: 'Bronze',
    labelRu: 'Бронза',
    minXp: 0,
  ),
];
