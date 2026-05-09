import 'dart:convert';

import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentActivitySignalStoreV1 {
  RecentActivitySignalStoreV1._();

  static final RecentActivitySignalStoreV1 instance =
      RecentActivitySignalStoreV1._();

  static const String _storageKey = 'recent_activity_signal_store_v1';
  static const int _maxSignals = 48;
  static const Set<String> _supportedSignalNames = <String>{
    'user_choice',
    'correct',
    'time_to_decision',
  };

  Future<void> appendSignal({
    required String name,
    required Map<String, Object?> payload,
  }) async {
    if (!_supportedSignalNames.contains(name)) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final encodedSignals = _readEncodedSignals(prefs);
    encodedSignals.add(<String, Object?>{
      'name': name,
      'payload': payload,
      'recorded_at_ms': DateTime.now().toUtc().millisecondsSinceEpoch,
    });
    await _writeEncodedSignals(prefs, encodedSignals);
  }

  Future<void> appendSignals(Iterable<RecentTelemetrySignalV1> signals) async {
    final filteredSignals = signals
        .where((signal) => _supportedSignalNames.contains(signal.name))
        .toList(growable: false);
    if (filteredSignals.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final encodedSignals = _readEncodedSignals(prefs);
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    for (final signal in filteredSignals) {
      encodedSignals.add(<String, Object?>{
        'name': signal.name,
        'payload': signal.payload,
        'recorded_at_ms': nowMs,
      });
    }
    await _writeEncodedSignals(prefs, encodedSignals);
  }

  Future<List<RecentTelemetrySignalV1>> loadSignals() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedSignals = _readEncodedSignals(prefs);
    return encodedSignals
        .map((entry) {
          final name = (entry['name'] ?? '').toString().trim();
          final rawPayload = entry['payload'];
          if (name.isEmpty || rawPayload is! Map) {
            return null;
          }
          return RecentTelemetrySignalV1(
            name: name,
            payload: Map<String, Object?>.from(
              rawPayload.map(
                (key, value) => MapEntry(key.toString(), value as Object?),
              ),
            ),
          );
        })
        .whereType<RecentTelemetrySignalV1>()
        .toList(growable: false);
  }

  Future<void> clearForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  List<Map<String, Object?>> _readEncodedSignals(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <Map<String, Object?>>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <Map<String, Object?>>[];
      }
      return decoded
          .whereType<Map>()
          .map(
            (entry) => Map<String, Object?>.from(
              entry.map(
                (key, value) => MapEntry(key.toString(), value as Object?),
              ),
            ),
          )
          .toList(growable: true);
    } catch (_) {
      return <Map<String, Object?>>[];
    }
  }

  Future<void> _writeEncodedSignals(
    SharedPreferences prefs,
    List<Map<String, Object?>> encodedSignals,
  ) async {
    final trimmedSignals = encodedSignals.length <= _maxSignals
        ? encodedSignals
        : encodedSignals.sublist(encodedSignals.length - _maxSignals);
    await prefs.setString(_storageKey, jsonEncode(trimmedSignals));
  }
}
