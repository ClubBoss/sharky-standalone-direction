import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a single XP award event in the user's history.
///
/// Fields:
/// - [type]: descriptive label (e.g., "theory_view", "drill_completed", "module_completed")
/// - [amount]: XP awarded (e.g., 1, 5, 10)
/// - [timestamp]: ISO 8601 timestamp when the event occurred
/// - [reflectionNote]: optional user reflection/note for deliberate practice
class XpEvent {
  final String type;
  final int amount;
  final DateTime timestamp;
  final String? reflectionNote;

  XpEvent({
    required this.type,
    required this.amount,
    required this.timestamp,
    this.reflectionNote,
  });

  /// Serialize to JSON for SharedPreferences storage.
  Map<String, dynamic> toJson() => {
    'type': type,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    if (reflectionNote != null && reflectionNote!.isNotEmpty)
      'reflectionNote': reflectionNote,
  };

  /// Deserialize from JSON stored in SharedPreferences.
  factory XpEvent.fromJson(Map<String, dynamic> json) => XpEvent(
    type: json['type'] as String,
    amount: json['amount'] as int,
    timestamp: DateTime.parse(json['timestamp'] as String),
    reflectionNote: json['reflectionNote'] as String?,
  );

  /// Create a copy with updated fields.
  XpEvent copyWith({
    String? type,
    int? amount,
    DateTime? timestamp,
    String? reflectionNote,
  }) => XpEvent(
    type: type ?? this.type,
    amount: amount ?? this.amount,
    timestamp: timestamp ?? this.timestamp,
    reflectionNote: reflectionNote ?? this.reflectionNote,
  );
}

/// A lightweight service for tracking recent XP award events.
///
/// Maintains a rolling history of the last 30 XP events in SharedPreferences.
/// This enables future features like XP dashboards, analytics, or streak tracking.
///
/// Usage:
/// ```dart
/// final history = XpHistoryService();
/// await history.addEvent(type: 'drill_completed', amount: 5);
/// final events = await history.getHistory();
/// ```
class XpHistoryService {
  static const String _storageKey = 'xp_history';
  static const int _maxEvents = 30;

  /// Add a new XP event to history.
  ///
  /// Maintains a rolling list of up to [_maxEvents] entries; drops the oldest
  /// event when the limit is exceeded.
  Future<void> addEvent({required String type, required int amount}) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    // Create new event with current timestamp
    final event = XpEvent(
      type: type,
      amount: amount,
      timestamp: DateTime.now(),
    );

    // Append new event and trim to max size
    history.add(event);
    if (history.length > _maxEvents) {
      history.removeAt(0); // Drop oldest event
    }

    // Persist updated history
    final encoded = history.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(encoded));
  }

  /// Retrieve the full XP event history.
  ///
  /// Returns a list of up to [_maxEvents] events, ordered chronologically
  /// (oldest first). Returns an empty list if no history exists.
  Future<List<XpEvent>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => XpEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If JSON is corrupted, return empty list and allow fresh start
      return [];
    }
  }

  /// Clear all XP history (useful for testing or user reset).
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Update the reflection note for an event at a specific index.
  ///
  /// Index is 0-based and corresponds to the list returned by [getHistory].
  /// If index is out of bounds, this method does nothing.
  Future<void> updateReflection(int index, String? note) async {
    final history = await getHistory();

    if (index < 0 || index >= history.length) {
      return; // Index out of bounds, silently ignore
    }

    // Update the event with new reflection note
    history[index] = history[index].copyWith(reflectionNote: note);

    // Persist updated history
    final prefs = await SharedPreferences.getInstance();
    final encoded = history.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(encoded));
  }
}
