import 'package:test/test.dart';

/// Mock telemetry event for testing
class TelemetryEvent {
  final String eventName;
  final Map<String, dynamic> properties;
  final DateTime timestamp;

  TelemetryEvent({
    required this.eventName,
    required this.properties,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'properties': properties,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Mock telemetry logger for testing
class TelemetryLogger {
  final List<TelemetryEvent> _events = [];

  void logEvent(String eventName, Map<String, dynamic> properties) {
    _events.add(
      TelemetryEvent(
        eventName: eventName,
        properties: properties,
        timestamp: DateTime.now(),
      ),
    );
  }

  List<TelemetryEvent> getEvents() => List.unmodifiable(_events);

  void clear() => _events.clear();

  int get eventCount => _events.length;

  List<TelemetryEvent> getEventsByName(String eventName) {
    return _events.where((e) => e.eventName == eventName).toList();
  }
}

/// Telemetry integration test that verifies telemetry logs are written correctly.
///
/// This test validates:
/// 1. Telemetry events are logged with correct structure
/// 2. Events contain required properties
/// 3. Timestamps are recorded accurately
/// 4. Multiple events can be tracked independently
/// 5. Event filtering and querying works correctly
void main() {
  group('Telemetry Integration Tests', () {
    late TelemetryLogger logger;

    setUp(() {
      logger = TelemetryLogger();
    });

    tearDown(() {
      logger.clear();
    });

    test('Telemetry logs training session start event', () {
      logger.logEvent('training_session_start', {
        'session_id': 'session-123',
        'pack_id': 'pack-456',
        'pack_title': 'Preflop 3bet Training',
        'spot_count': 10,
      });

      expect(logger.eventCount, 1);

      final event = logger.getEvents().first;
      expect(event.eventName, 'training_session_start');
      expect(event.properties['session_id'], 'session-123');
      expect(event.properties['pack_id'], 'pack-456');
      expect(event.properties['spot_count'], 10);
    });

    test('Telemetry logs training session complete event', () {
      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(minutes: 5));

      logger.logEvent('training_session_complete', {
        'session_id': 'session-123',
        'duration_seconds': endTime.difference(startTime).inSeconds,
        'spots_completed': 10,
        'correct_count': 7,
        'accuracy': 0.7,
      });

      expect(logger.eventCount, 1);

      final event = logger.getEvents().first;
      expect(event.eventName, 'training_session_complete');
      expect(event.properties['spots_completed'], 10);
      expect(event.properties['correct_count'], 7);
      expect(event.properties['accuracy'], 0.7);
      expect(event.properties['duration_seconds'], greaterThan(0));
    });

    test('Telemetry logs user action events', () {
      logger.logEvent('user_action', {
        'spot_id': 'spot-1',
        'user_action': 'raise',
        'correct_action': 'raise',
        'is_correct': true,
        'time_taken_ms': 3500,
      });

      expect(logger.eventCount, 1);

      final event = logger.getEvents().first;
      expect(event.eventName, 'user_action');
      expect(event.properties['spot_id'], 'spot-1');
      expect(event.properties['is_correct'], true);
      expect(event.properties['time_taken_ms'], 3500);
    });

    test('Telemetry tracks multiple events in sequence', () {
      logger.logEvent('training_session_start', {'session_id': 'session-1'});
      logger.logEvent('user_action', {'spot_id': 'spot-1', 'is_correct': true});
      logger.logEvent('user_action', {
        'spot_id': 'spot-2',
        'is_correct': false,
      });
      logger.logEvent('training_session_complete', {'session_id': 'session-1'});

      expect(logger.eventCount, 4);
    });

    test('Telemetry filters events by name', () {
      logger.logEvent('training_session_start', {'session_id': 'session-1'});
      logger.logEvent('user_action', {'spot_id': 'spot-1', 'is_correct': true});
      logger.logEvent('user_action', {
        'spot_id': 'spot-2',
        'is_correct': false,
      });
      logger.logEvent('training_session_complete', {'session_id': 'session-1'});

      final userActions = logger.getEventsByName('user_action');
      expect(userActions.length, 2);
      expect(userActions[0].properties['spot_id'], 'spot-1');
      expect(userActions[1].properties['spot_id'], 'spot-2');
    });

    test('Telemetry events have timestamps', () {
      final beforeLog = DateTime.now();
      logger.logEvent('test_event', {'data': 'test'});
      final afterLog = DateTime.now();

      final event = logger.getEvents().first;
      expect(
        event.timestamp.isAfter(beforeLog.subtract(Duration(seconds: 1))),
        isTrue,
      );
      expect(
        event.timestamp.isBefore(afterLog.add(Duration(seconds: 1))),
        isTrue,
      );
    });

    test('Telemetry logs pack library events', () {
      logger.logEvent('pack_library_loaded', {
        'pack_count': 50,
        'load_time_ms': 150,
      });

      logger.logEvent('pack_selected', {
        'pack_id': 'pack-789',
        'pack_title': 'ICM Push/Fold',
        'difficulty': 3,
      });

      expect(logger.eventCount, 2);

      final loadEvent = logger.getEventsByName('pack_library_loaded').first;
      expect(loadEvent.properties['pack_count'], 50);

      final selectEvent = logger.getEventsByName('pack_selected').first;
      expect(selectEvent.properties['pack_id'], 'pack-789');
    });

    test('Telemetry logs topic progress updates', () {
      logger.logEvent('topic_progress_update', {
        'topic_id': 'preflop-3bet',
        'seen_count': 10,
        'correct_count': 8,
        'accuracy': 0.8,
        'streak': 5,
      });

      final event = logger.getEvents().first;
      expect(event.eventName, 'topic_progress_update');
      expect(event.properties['topic_id'], 'preflop-3bet');
      expect(event.properties['accuracy'], 0.8);
      expect(event.properties['streak'], 5);
    });

    test('Telemetry logs error events', () {
      logger.logEvent('error', {
        'error_type': 'validation_error',
        'error_message': 'Invalid spot configuration',
        'context': 'training_pack_service',
      });

      final event = logger.getEvents().first;
      expect(event.eventName, 'error');
      expect(event.properties['error_type'], 'validation_error');
      expect(event.properties['context'], 'training_pack_service');
    });

    test('Telemetry serializes events to JSON', () {
      logger.logEvent('test_event', {
        'string_value': 'test',
        'int_value': 42,
        'double_value': 3.14,
        'bool_value': true,
      });

      final event = logger.getEvents().first;
      final json = event.toJson();

      expect(json['eventName'], 'test_event');
      expect(json['properties'], isMap);
      expect(json['timestamp'], isA<String>());
      expect(json['properties']['string_value'], 'test');
      expect(json['properties']['int_value'], 42);
    });

    test('Telemetry tracks session pause and resume', () {
      logger.logEvent('session_paused', {
        'session_id': 'session-123',
        'elapsed_seconds': 120,
      });

      logger.logEvent('session_resumed', {
        'session_id': 'session-123',
        'pause_duration_seconds': 30,
      });

      expect(logger.eventCount, 2);

      final pauseEvent = logger.getEventsByName('session_paused').first;
      expect(pauseEvent.properties['elapsed_seconds'], 120);

      final resumeEvent = logger.getEventsByName('session_resumed').first;
      expect(resumeEvent.properties['pause_duration_seconds'], 30);
    });

    test('Telemetry logs performance metrics', () {
      logger.logEvent('performance_metric', {
        'metric_name': 'spot_evaluation_time',
        'value_ms': 250,
        'context': 'training_session',
      });

      logger.logEvent('performance_metric', {
        'metric_name': 'pack_load_time',
        'value_ms': 500,
        'context': 'pack_library',
      });

      final perfMetrics = logger.getEventsByName('performance_metric');
      expect(perfMetrics.length, 2);
      expect(perfMetrics[0].properties['metric_name'], 'spot_evaluation_time');
      expect(perfMetrics[1].properties['metric_name'], 'pack_load_time');
    });

    test('Telemetry clears all events', () {
      logger.logEvent('event_1', {});
      logger.logEvent('event_2', {});
      logger.logEvent('event_3', {});

      expect(logger.eventCount, 3);

      logger.clear();

      expect(logger.eventCount, 0);
      expect(logger.getEvents(), isEmpty);
    });

    test('Telemetry logs achievement unlock events', () {
      logger.logEvent('achievement_unlocked', {
        'achievement_id': 'first_perfect_session',
        'achievement_name': 'Perfect Session',
        'achievement_tier': 'gold',
      });

      final event = logger.getEvents().first;
      expect(event.eventName, 'achievement_unlocked');
      expect(event.properties['achievement_id'], 'first_perfect_session');
      expect(event.properties['achievement_tier'], 'gold');
    });

    test('Telemetry logs XP gain events', () {
      logger.logEvent('xp_gained', {
        'amount': 100,
        'source': 'training_session_complete',
        'session_id': 'session-123',
      });

      final event = logger.getEvents().first;
      expect(event.eventName, 'xp_gained');
      expect(event.properties['amount'], 100);
      expect(event.properties['source'], 'training_session_complete');
    });

    test('Telemetry handles empty properties', () {
      logger.logEvent('simple_event', {});

      final event = logger.getEvents().first;
      expect(event.eventName, 'simple_event');
      expect(event.properties, isEmpty);
    });

    test('Telemetry logs multiple sessions independently', () {
      // Session 1
      logger.logEvent('training_session_start', {'session_id': 'session-1'});
      logger.logEvent('user_action', {
        'session_id': 'session-1',
        'is_correct': true,
      });
      logger.logEvent('training_session_complete', {'session_id': 'session-1'});

      // Session 2
      logger.logEvent('training_session_start', {'session_id': 'session-2'});
      logger.logEvent('user_action', {
        'session_id': 'session-2',
        'is_correct': false,
      });
      logger.logEvent('training_session_complete', {'session_id': 'session-2'});

      expect(logger.eventCount, 6);

      final session1Events = logger
          .getEvents()
          .where((e) => e.properties['session_id'] == 'session-1')
          .toList();
      final session2Events = logger
          .getEvents()
          .where((e) => e.properties['session_id'] == 'session-2')
          .toList();

      expect(session1Events.length, 3);
      expect(session2Events.length, 3);
    });
  });
}
