import 'dart:async';

import 'completed_training_pack_registry.dart';

/// Aggregated statistics of completed training sessions.
class CompletionStats {
  final int totalSessions;
  final double averageAccuracy;
  final Duration? averageDuration;

  CompletionStats({
    required this.totalSessions,
    required this.averageAccuracy,
    this.averageDuration,
  });
}

/// Summarizes completed training sessions using stored fingerprints.
class TrainingSessionCompletionStatsService {
  final CompletedTrainingPackRegistry registry;

  TrainingSessionCompletionStatsService({
    CompletedTrainingPackRegistry? registry,
  }) : registry = registry ?? CompletedTrainingPackRegistry();

  /// Computes aggregated statistics across all completed sessions.
  Future<CompletionStats> computeStats() async {
    final fingerprints = await registry.listCompletedFingerprints();
    int total = 0;
    double accuracySum = 0;
    int accuracyCount = 0;
    int durationSumMs = 0;
    int durationCount = 0;

    for (final fp in fingerprints) {
      final data = await registry.getCompletedPackData(fp);
      if (data == null) continue;
      total++;

      final acc = data['accuracy'];
      if (acc is num) {
        accuracySum += acc.toDouble();
        accuracyCount++;
      }

      final dur = data['durationMs'] ?? data['duration'];
      if (dur is num) {
        durationSumMs += dur.toInt();
        durationCount++;
      } else if (dur is String) {
        // Attempt to parse numeric string or ISO8601 duration.
        final parsed = int.tryParse(dur);
        if (parsed != null) {
          durationSumMs += parsed;
          durationCount++;
        } else {
          final parsedDuration = _parseDurationString(dur);
          if (parsedDuration != null) {
            durationSumMs += parsedDuration.inMilliseconds;
            durationCount++;
          }
        }
      }
    }

    final avgAcc = accuracyCount > 0 ? accuracySum / accuracyCount : 0.0;
    final avgDur = durationCount > 0
        ? Duration(milliseconds: (durationSumMs / durationCount).round())
        : null;

    return CompletionStats(
      totalSessions: total,
      averageAccuracy: avgAcc,
      averageDuration: avgDur,
    );
  }
}

Duration? _parseDurationString(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  Duration? fromIso8601() {
    final match = RegExp(
      r'^P(?:(\d+)D)?T?(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (match == null) return null;
    final days = int.tryParse(match.group(1) ?? '0') ?? 0;
    final hours = int.tryParse(match.group(2) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(3) ?? '0') ?? 0;
    final secondsRaw = double.tryParse(match.group(4) ?? '0') ?? 0;
    final millis = (secondsRaw * 1000).round();
    return Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      milliseconds: millis,
    );
  }

  Duration? fromColonSeparated() {
    final parts = trimmed.split(':');
    if (parts.length < 2 || parts.length > 3) return null;
    if (!parts.every((p) => RegExp(r'^\d+(?:\.\d+)?$').hasMatch(p))) {
      return null;
    }
    final secondsRaw = double.tryParse(parts.last) ?? 0;
    final minutes = int.tryParse(parts[parts.length - 2]) ?? 0;
    final hours = parts.length == 3 ? int.tryParse(parts.first) ?? 0 : 0;
    final millis = (secondsRaw * 1000).round();
    return Duration(hours: hours, minutes: minutes, milliseconds: millis);
  }

  return fromIso8601() ?? fromColonSeparated();
}
