import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Represents a snapshot of the game state at a specific moment in the replay.
class ReplaySnapshot {
  ReplaySnapshot({
    required this.timestamp,
    required this.eventIndex,
    required this.type,
    required this.seatIndex,
    this.action,
    this.amount,
    this.street,
    this.pot,
    this.description,
  });

  final DateTime timestamp;
  final int eventIndex;
  final String type;
  final int seatIndex;
  final String? action;
  final int? amount;
  final String? street;
  final int? pot;
  final String? description;

  factory ReplaySnapshot.fromJson(Map<String, dynamic> json, int index) {
    return ReplaySnapshot(
      timestamp: DateTime.parse(json['timestamp'] as String),
      eventIndex: index,
      type: json['type'] as String,
      seatIndex: json['seat_index'] as int,
      action: json['action'] as String?,
      amount: json['amount'] as int?,
      street: json['street'] as String?,
      pot: json['pot'] as int?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'event_index': eventIndex,
      'type': type,
      'seat_index': seatIndex,
      if (action != null) 'action': action,
      if (amount != null) 'amount': amount,
      if (street != null) 'street': street,
      if (pot != null) 'pot': pot,
      if (description != null) 'description': description,
    };
  }
}

/// Replay engine that reads simulation metrics and reconstructs round sequence.
///
/// Provides playback controls (play/pause/step/seek) with event streaming
/// for UI updates. Supports multiple playback speeds.
class ReplayEngine {
  ReplayEngine({required this.snapshots, this.playbackSpeed = 1.0})
    : _currentIndex = 0,
      _controller = StreamController<ReplaySnapshot>.broadcast(),
      _isPlaying = false;

  final List<ReplaySnapshot> snapshots;
  double playbackSpeed;

  int _currentIndex;
  final StreamController<ReplaySnapshot> _controller;
  bool _isPlaying;
  Timer? _playbackTimer;

  Stream<ReplaySnapshot> get events => _controller.stream;

  int get currentIndex => _currentIndex;
  int get totalSnapshots => snapshots.length;
  bool get isPlaying => _isPlaying;
  bool get canStepForward => _currentIndex < snapshots.length - 1;
  bool get canStepBackward => _currentIndex > 0;

  ReplaySnapshot get currentSnapshot =>
      snapshots.isEmpty ? _emptySnapshot : snapshots[_currentIndex];

  static ReplaySnapshot get _emptySnapshot => ReplaySnapshot(
    timestamp: DateTime.now(),
    eventIndex: 0,
    type: 'empty',
    seatIndex: 0,
    description: 'No replay data available',
  );

  /// Load replay data from simulation_metrics.json.
  ///
  /// Returns null if file doesn't exist or contains no event history.
  static Future<ReplayEngine?> loadFromFile() async {
    final file = File('tools/_reports/simulation_metrics.json');
    if (!await file.exists()) {
      stderr.writeln('[ReplayEngine] No simulation metrics file found');
      return null;
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      // Check if we have event history
      final events = json['event_history'] as List?;
      if (events == null || events.isEmpty) {
        stdout.writeln('[ReplayEngine] No event history in metrics');
        // Create minimal replay from summary data
        return _createFromSummary(json);
      }

      // Parse event history into snapshots
      final snapshots = <ReplaySnapshot>[];
      for (var i = 0; i < events.length; i++) {
        final event = events[i] as Map<String, dynamic>;
        snapshots.add(ReplaySnapshot.fromJson(event, i));
      }

      stdout.writeln('[ReplayEngine] Loaded ${snapshots.length} snapshots');
      return ReplayEngine(snapshots: snapshots);
    } catch (e) {
      stderr.writeln('[ReplayEngine] Failed to load replay data: $e');
      return null;
    }
  }

  /// Create minimal replay from summary metrics when no event history exists.
  static ReplayEngine _createFromSummary(Map<String, dynamic> json) {
    final roundCount = json['round_count'] as int? ?? 0;
    final aiActionCount = json['ai_action_count'] as int? ?? 0;

    final snapshots = <ReplaySnapshot>[
      ReplaySnapshot(
        timestamp: DateTime.now(),
        eventIndex: 0,
        type: 'summary',
        seatIndex: 0,
        description:
            'Simulation completed: $roundCount rounds, $aiActionCount AI actions',
      ),
    ];

    return ReplayEngine(snapshots: snapshots);
  }

  /// Start automatic playback at current speed.
  void play() {
    if (_isPlaying || !canStepForward) return;

    _isPlaying = true;
    _playbackTimer?.cancel();

    // Base interval is 500ms, adjusted by playback speed
    final intervalMs = (500 / playbackSpeed).round();
    _playbackTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (!canStepForward) {
        pause();
        return;
      }
      stepForward();
    });

    stdout.writeln('[ReplayEngine] Started playback at ${playbackSpeed}x');
  }

  /// Pause automatic playback.
  void pause() {
    if (!_isPlaying) return;

    _isPlaying = false;
    _playbackTimer?.cancel();
    _playbackTimer = null;

    stdout.writeln('[ReplayEngine] Paused playback');
  }

  /// Step forward one snapshot.
  void stepForward() {
    if (!canStepForward) return;

    _currentIndex++;
    _controller.add(currentSnapshot);
  }

  /// Step backward one snapshot.
  void stepBackward() {
    if (!canStepBackward) return;

    _currentIndex--;
    _controller.add(currentSnapshot);
  }

  /// Seek to specific snapshot index.
  void seekToIndex(int index) {
    if (index < 0 || index >= snapshots.length) return;

    _currentIndex = index;
    _controller.add(currentSnapshot);
  }

  /// Seek to specific progress (0.0 to 1.0).
  void seekToProgress(double progress) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final targetIndex = ((snapshots.length - 1) * clampedProgress).round();
    seekToIndex(targetIndex);
  }

  /// Get current progress (0.0 to 1.0).
  double get progress =>
      snapshots.isEmpty ? 0.0 : _currentIndex / (snapshots.length - 1);

  /// Set playback speed (0.5x, 1.0x, 2.0x, etc.).
  void setSpeed(double speed) {
    playbackSpeed = speed.clamp(0.25, 4.0);
    stdout.writeln('[ReplayEngine] Set playback speed to ${playbackSpeed}x');

    // Restart timer if playing
    if (_isPlaying) {
      final wasPlaying = _isPlaying;
      pause();
      if (wasPlaying) play();
    }
  }

  /// Reset to beginning.
  void reset() {
    pause();
    _currentIndex = 0;
    _controller.add(currentSnapshot);
  }

  void dispose() {
    pause();
    _controller.close();
  }
}
