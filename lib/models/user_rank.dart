import 'package:flutter/material.dart';

/// User rank based on cumulative XP earned.
/// NOTE: Enums are append-only — new ranks added at the end.
enum UserRank {
  bronze, // 0-999 XP
  silver, // 1000-4999 XP
  gold, // 5000-14999 XP
  platinum, // 15000-24999 XP
  diamond, // 25000+ XP
}

extension UserRankMetadata on UserRank {
  /// Minimum XP threshold to reach this rank.
  int get minXp {
    switch (this) {
      case UserRank.bronze:
        return 0;
      case UserRank.silver:
        return 1000;
      case UserRank.gold:
        return 5000;
      case UserRank.platinum:
        return 15000;
      case UserRank.diamond:
        return 25000;
    }
  }

  /// Maximum XP for this rank (null if no upper limit).
  int? get maxXp {
    switch (this) {
      case UserRank.bronze:
        return 999;
      case UserRank.silver:
        return 4999;
      case UserRank.gold:
        return 14999;
      case UserRank.platinum:
        return 24999;
      case UserRank.diamond:
        return null; // No upper limit
    }
  }

  /// Human-readable title (EN / RU).
  String title({required bool isRu}) {
    switch (this) {
      case UserRank.bronze:
        return isRu ? 'Бронзовый' : 'Bronze';
      case UserRank.silver:
        return isRu ? 'Серебряный' : 'Silver';
      case UserRank.gold:
        return isRu ? 'Золотой' : 'Gold';
      case UserRank.platinum:
        return isRu ? 'Платиновый' : 'Platinum';
      case UserRank.diamond:
        return isRu ? 'Алмазный' : 'Diamond';
    }
  }

  /// Localized label for profile display (e.g., "Silver Member").
  String label({required bool isRu}) {
    final rankTitle = title(isRu: isRu);
    return isRu ? '$rankTitle уровень' : '$rankTitle Member';
  }

  /// Icon representing the rank.
  IconData icon() {
    switch (this) {
      case UserRank.bronze:
        return Icons.workspace_premium;
      case UserRank.silver:
        return Icons.workspace_premium;
      case UserRank.gold:
        return Icons.workspace_premium;
      case UserRank.platinum:
        return Icons.workspace_premium;
      case UserRank.diamond:
        return Icons.workspace_premium;
    }
  }

  /// Color accent for the rank badge.
  Color color() {
    switch (this) {
      case UserRank.bronze:
        return const Color(0xFFCD7F32); // Bronze
      case UserRank.silver:
        return const Color(0xFFC0C0C0); // Silver
      case UserRank.gold:
        return const Color(0xFFFFD700); // Gold
      case UserRank.platinum:
        return const Color(0xFFE5E4E2); // Platinum
      case UserRank.diamond:
        return const Color(0xFFB9F2FF); // Diamond blue
    }
  }
}

/// Compute rank from total XP.
UserRank userRankFromXp(int totalXp) {
  if (totalXp >= UserRank.diamond.minXp) return UserRank.diamond;
  if (totalXp >= UserRank.platinum.minXp) return UserRank.platinum;
  if (totalXp >= UserRank.gold.minXp) return UserRank.gold;
  if (totalXp >= UserRank.silver.minXp) return UserRank.silver;
  return UserRank.bronze;
}
