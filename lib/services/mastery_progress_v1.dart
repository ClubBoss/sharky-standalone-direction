class MasteryProgressV1 {
  const MasteryProgressV1({
    this.schemaVersion = 1,
    required this.worldId,
    required this.totalSessions,
    required this.completedSessions,
    required this.rollingAccuracy,
  });

  final int schemaVersion;
  final String worldId;
  final int totalSessions;
  final int completedSessions;
  final double rollingAccuracy;

  Map<String, Object> toJson() => <String, Object>{
    'schemaVersion': schemaVersion,
    'worldId': worldId,
    'totalSessions': totalSessions,
    'completedSessions': completedSessions,
    'rollingAccuracy': rollingAccuracy,
  };

  static MasteryProgressV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final schemaVersion = _parseInt(raw['schemaVersion']) ?? 1;
    final worldId = raw['worldId']?.toString().trim() ?? '';
    final totalSessions = _parseInt(raw['totalSessions']);
    final completedSessions = _parseInt(raw['completedSessions']);
    final rollingAccuracy = _parseDouble(raw['rollingAccuracy']);
    if (schemaVersion != 1 ||
        worldId.isEmpty ||
        totalSessions == null ||
        completedSessions == null ||
        rollingAccuracy == null) {
      return null;
    }
    if (totalSessions < 0 || completedSessions < 0) {
      return null;
    }
    if (rollingAccuracy < 0 || rollingAccuracy > 1) {
      return null;
    }
    return MasteryProgressV1(
      schemaVersion: schemaVersion,
      worldId: worldId,
      totalSessions: totalSessions,
      completedSessions: completedSessions,
      rollingAccuracy: rollingAccuracy,
    );
  }

  static int? _parseInt(Object? raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  static double? _parseDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '');
  }
}

bool isEligibleForHighTierV1(MasteryProgressV1 progress) {
  return progress.completedSessions >= progress.totalSessions &&
      progress.rollingAccuracy >= 0.80;
}

class MasteryWorldSnapshotV1 {
  const MasteryWorldSnapshotV1({
    required this.totalSessions,
    required this.completedSessions,
    required this.rollingAccuracy,
    required this.isEligibleForHighTier,
  });

  final int totalSessions;
  final int completedSessions;
  final double rollingAccuracy;
  final bool isEligibleForHighTier;
}

class MasterySnapshotV1 {
  const MasterySnapshotV1({this.schemaVersion = 1, required this.perWorld});

  final int schemaVersion;
  final Map<String, MasteryWorldSnapshotV1> perWorld;
}

// Append-only order for consumers that rely on enum index stability.
enum MasteryBadgeV1 { none, inProgress, complete, highTier }

MasteryBadgeV1 masteryBadgeForWorldSnapshotV1(
  MasteryWorldSnapshotV1? snapshot,
) {
  if (snapshot == null || snapshot.totalSessions <= 0) {
    return MasteryBadgeV1.none;
  }
  if (snapshot.isEligibleForHighTier) {
    return MasteryBadgeV1.highTier;
  }
  if (snapshot.completedSessions >= snapshot.totalSessions) {
    return MasteryBadgeV1.complete;
  }
  return MasteryBadgeV1.inProgress;
}

enum MasteryTierV1 { micro, high }

class MasteryTierConfigV1 {
  const MasteryTierConfigV1({
    this.tierConfigVersion = 1,
    required this.timerHintMs,
    required this.hintsOff,
    required this.lives,
  });

  final int tierConfigVersion;
  final int? timerHintMs;
  final bool hintsOff;
  final int lives;
}

MasteryTierConfigV1 masteryTierConfigForSessionV1({
  required String sessionId,
  required MasteryProgressV1? progressForWorld,
}) {
  final normalizedSessionId = sessionId.trim().toLowerCase();
  if (!RegExp(r'^w[0-9]\.s\d{2}$').hasMatch(normalizedSessionId)) {
    return const MasteryTierConfigV1(
      timerHintMs: null,
      hintsOff: false,
      // Not consumed by runtime yet; keep permissive default for safety.
      lives: 2,
    );
  }
  if (progressForWorld == null) {
    return const MasteryTierConfigV1(
      timerHintMs: null,
      hintsOff: false,
      // Not consumed by runtime yet; keep permissive default for safety.
      lives: 2,
    );
  }
  final eligibleHigh = isEligibleForHighTierV1(progressForWorld);
  if (eligibleHigh) {
    return const MasteryTierConfigV1(
      timerHintMs: 8000,
      hintsOff: true,
      lives: 1,
    );
  }
  return const MasteryTierConfigV1(
    timerHintMs: null,
    hintsOff: false,
    // Not consumed by runtime yet; keep permissive default for safety.
    lives: 2,
  );
}
