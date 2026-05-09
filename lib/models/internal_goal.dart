import 'package:flutter/foundation.dart';

/// Type of internal goal for categorization.
enum InternalGoalType {
  xp, // Earn XP
  drills, // Complete drills
  modules, // Complete modules
  challenges, // Complete weekly challenges
}

/// Represents an internal player objective (e.g., daily/weekly goal).
/// In-memory only, no persistence.
@immutable
class InternalGoal {
  final String id;
  final String titleEn;
  final String titleRu;
  final int progress;
  final int target;
  final bool completed;
  final InternalGoalType type;

  const InternalGoal({
    required this.id,
    required this.titleEn,
    required this.titleRu,
    required this.progress,
    required this.target,
    required this.completed,
    required this.type,
  });

  /// Create a copy with updated fields.
  InternalGoal copyWith({
    String? id,
    String? titleEn,
    String? titleRu,
    int? progress,
    int? target,
    bool? completed,
    InternalGoalType? type,
  }) => InternalGoal(
    id: id ?? this.id,
    titleEn: titleEn ?? this.titleEn,
    titleRu: titleRu ?? this.titleRu,
    progress: progress ?? this.progress,
    target: target ?? this.target,
    completed: completed ?? this.completed,
    type: type ?? this.type,
  );

  /// Progress as percentage (0.0 to 1.0).
  double get progressPercent {
    if (target <= 0) return 0.0;
    return (progress / target).clamp(0.0, 1.0);
  }

  /// Get localized title.
  String title({required bool isRu}) => isRu ? titleRu : titleEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InternalGoal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          titleEn == other.titleEn &&
          titleRu == other.titleRu &&
          progress == other.progress &&
          target == other.target &&
          completed == other.completed &&
          type == other.type;

  @override
  int get hashCode =>
      Object.hash(id, titleEn, titleRu, progress, target, completed, type);
}
