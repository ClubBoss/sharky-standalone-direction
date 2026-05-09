import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/ui/persona_reactions_overlay.dart';
import 'package:poker_analyzer/ui/player_profile_screen_flutter.dart';

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

class PersonaReactionsService {
  PersonaReactionsService._({
    PersonaReactionsOverlayController? overlayController,
  }) : _overlayController =
           overlayController ?? PersonaReactionsOverlayController.instance {
    _subscribe();
  }

  static final PersonaReactionsService instance = PersonaReactionsService._();

  final PersonaReactionsOverlayController _overlayController;
  final Map<_ReactionMood, int> _reactionCounts = {
    _ReactionMood.celebrate: 0,
    _ReactionMood.encourage: 0,
    _ReactionMood.think: 0,
  };

  StreamSubscription<PlayerProfileSurfaceEvent>? _subscription;

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _subscribe() {
    _subscription ??= PlayerProfileSurfaceController.instance.events.listen(
      _handleEvent,
    );
  }

  void _handleEvent(PlayerProfileSurfaceEvent event) {
    switch (event.trigger) {
      case PlayerProfileSurfaceTrigger.rankUp:
      case PlayerProfileSurfaceTrigger.drillCompleted:
      case PlayerProfileSurfaceTrigger.quizCompleted:
        _showCelebrate(event);
        break;
      case PlayerProfileSurfaceTrigger.sessionEnd:
        if (_isFailure(event)) {
          _showEncourage();
        } else {
          _showNeutral();
        }
        break;
    }
  }

  bool _isFailure(PlayerProfileSurfaceEvent event) {
    final hasGains = event.statGain != null || event.traitGain != null;
    return !hasGains;
  }

  void _showCelebrate(PlayerProfileSurfaceEvent event) {
    final stat = event.statGain?.statName ?? 'progress';
    final message = 'Sharky is pumped! $stat got a boost.';
    _overlayController.showCelebrate(message);
    _increment(_ReactionMood.celebrate);
  }

  void _showEncourage() {
    const message = 'Sharky says: Every setback sets up a comeback.';
    _overlayController.showEncourage(message);
    _increment(_ReactionMood.encourage);
  }

  void _showNeutral() {
    const message = 'Sharky is thinking about the next move...';
    _overlayController.showThinking(message);
    _increment(_ReactionMood.think);
  }

  void _increment(_ReactionMood mood) {
    _reactionCounts[mood] = (_reactionCounts[mood] ?? 0) + 1;
    _writeTelemetry();
  }

  Future<void> _writeTelemetry() async {
    final payload = <String, Object?>{
      'event': 'persona_reactions_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'celebrate_count': _reactionCounts[_ReactionMood.celebrate],
      'encourage_count': _reactionCounts[_ReactionMood.encourage],
      'thinking_count': _reactionCounts[_ReactionMood.think],
    };
    await _withReportsWritable(() async {
      final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
      sink.writeln(jsonEncode(payload));
      await sink.close();
    });
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}

enum _ReactionMood { celebrate, encourage, think }
