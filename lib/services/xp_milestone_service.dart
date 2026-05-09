import 'package:shared_preferences/shared_preferences.dart';
import '../screens/streak_milestone_history_screen.dart';

/// Service for tracking and managing XP milestone achievements.
///
/// Milestones are static thresholds that reward cumulative XP progress.
/// Users can "claim" unlocked milestones for gamification feedback.
class XpMilestoneService {
  static const String _storageKey = 'xp_milestones_claimed';
  static const String _historyKey = 'xp_milestones_claimed_history';

  /// Static list of XP milestone thresholds.
  static const List<int> milestones = [10, 50, 100, 250, 500, 1000];

  /// Get all milestones that are unlocked but not yet claimed.
  ///
  /// Returns milestone values where:
  /// - User's total XP >= milestone value
  /// - Milestone has not been marked as claimed
  Future<List<int>> getUnlockedButUnclaimedMilestones(int totalXp) async {
    final claimed = await _getClaimedMilestones();
    return milestones
        .where((m) => totalXp >= m && !claimed.contains(m))
        .toList();
  }

  /// Get all milestones that have been claimed.
  Future<Set<int>> getClaimedMilestones() async =>
      await _getClaimedMilestones();

  /// Mark a specific milestone as claimed.
  ///
  /// This is typically called when user taps "Claim" in the UI.
  Future<void> markMilestoneClaimed(int value) async {
    if (!milestones.contains(value)) {
      return; // Invalid milestone value, ignore
    }

    final prefs = await SharedPreferences.getInstance();
    final claimed = await _getClaimedMilestones();
    claimed.add(value);
    await prefs.setStringList(
      _storageKey,
      claimed.map((e) => e.toString()).toList(),
    );

    // Save claim timestamp for history
    await _saveClaimTimestamp(value, DateTime.now());
  }

  /// Get milestone status for a specific value.
  ///
  /// Returns:
  /// - 'locked' if totalXp < value
  /// - 'unlocked' if totalXp >= value and not claimed
  /// - 'claimed' if already claimed
  Future<MilestoneStatus> getMilestoneStatus(int value, int totalXp) async {
    if (totalXp < value) {
      return MilestoneStatus.locked;
    }

    final claimed = await _getClaimedMilestones();
    return claimed.contains(value)
        ? MilestoneStatus.claimed
        : MilestoneStatus.unlocked;
  }

  /// Clear all claimed milestones (useful for testing or reset).
  Future<void> clearClaimedMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Private helper to load claimed milestones from storage
  Future<Set<int>> _getClaimedMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  /// Save milestone claim timestamp for history tracking.
  Future<void> _saveClaimTimestamp(int value, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_historyKey) ?? <String>[];

    // Format: "value:ISO8601date"
    final entry = '$value:${date.toIso8601String()}';

    // Avoid duplicates (same milestone on same day)
    final dateStr = date.toIso8601String().split('T').first;
    final isDuplicate = existing.any((e) {
      final parts = e.split(':');
      if (parts.length < 2) return false;
      final existingValue = int.tryParse(parts[0]);
      final existingDateStr = parts[1].split('T').first;
      return existingValue == value && existingDateStr == dateStr;
    });

    if (!isDuplicate) {
      existing.add(entry);
      await prefs.setStringList(_historyKey, existing);
    }
  }

  /// Get chronological list of claimed XP milestone events.
  ///
  /// Returns list of MilestoneEvent objects with XP values and dates claimed.
  /// Sorted chronologically (oldest first).
  Future<List<MilestoneEvent>> getClaimedMilestoneEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_historyKey) ?? <String>[];

      final events = <MilestoneEvent>[];
      for (final entry in raw) {
        final parts = entry.split(':');
        if (parts.length < 2) continue;

        final value = int.tryParse(parts[0]);
        final date = DateTime.tryParse(parts[1]);

        if (value != null && date != null) {
          events.add(MilestoneEvent(value: value, date: date));
        }
      }

      // Sort chronologically (oldest first)
      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    } catch (e) {
      // Graceful fallback on any error
      return [];
    }
  }
}

/// Enum representing the state of a milestone.
enum MilestoneStatus {
  locked, // Not yet reached
  unlocked, // Reached but not claimed
  claimed, // Already claimed
}
