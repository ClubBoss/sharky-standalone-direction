/// Represents a single entry in the leaderboard.
///
/// Contains user display information and ranking data.
class LeaderboardEntry {
  /// User's rank position (1 = first place).
  final int rank;

  /// User's display name.
  final String displayName;

  /// User's total XP.
  final int xp;

  /// User's current level.
  final int level;

  /// Whether this entry represents the current user.
  final bool isCurrentUser;

  /// User ID (optional, for future backend integration).
  final String? userId;

  /// Region/country code (optional, for regional leaderboards).
  final String? region;

  const LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.xp,
    required this.level,
    required this.isCurrentUser,
    this.userId,
    this.region,
  });

  /// Creates a LeaderboardEntry from JSON data.
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: json['rank'] as int,
        displayName: json['displayName'] as String,
        xp: json['xp'] as int,
        level: json['level'] as int,
        isCurrentUser: json['isCurrentUser'] as bool? ?? false,
        userId: json['userId'] as String?,
        region: json['region'] as String?,
      );

  /// Converts this LeaderboardEntry to JSON.
  Map<String, dynamic> toJson() => {
    'rank': rank,
    'displayName': displayName,
    'xp': xp,
    'level': level,
    'isCurrentUser': isCurrentUser,
    if (userId != null) 'userId': userId,
    if (region != null) 'region': region,
  };

  @override
  String toString() =>
      'LeaderboardEntry(rank: $rank, name: $displayName, xp: $xp, level: $level)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntry &&
        other.rank == rank &&
        other.displayName == displayName &&
        other.xp == xp &&
        other.level == level &&
        other.isCurrentUser == isCurrentUser &&
        other.userId == userId &&
        other.region == region;
  }

  @override
  int get hashCode =>
      Object.hash(rank, displayName, xp, level, isCurrentUser, userId, region);
}
