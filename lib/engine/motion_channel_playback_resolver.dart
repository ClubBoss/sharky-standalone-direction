import 'motion_orchestrator_input.dart';
import 'motion_playback_adapter.dart';

class MotionChannelPlaybackSnapshot {
  const MotionChannelPlaybackSnapshot({
    required this.seat,
    required this.board,
    required this.pot,
  });

  final Map<String, MotionPlaybackSample?> seat;
  final Map<String, MotionPlaybackSample?> board;
  final Map<String, MotionPlaybackSample?> pot;
}

class MotionChannelPlaybackResolver {
  const MotionChannelPlaybackResolver(this.adapter, this.input);

  final MotionPlaybackAdapter adapter;
  final MotionOrchestratorInput input;

  MotionChannelPlaybackSnapshot resolve(double timeMs) {
    final seat = <String, MotionPlaybackSample?>{};
    for (final id in input.seatChannelIds) {
      seat[id] = adapter.sample(id, timeMs);
    }
    final board = <String, MotionPlaybackSample?>{};
    for (final id in input.boardChannelIds) {
      board[id] = adapter.sample(id, timeMs);
    }
    final pot = <String, MotionPlaybackSample?>{};
    for (final id in input.potChannelIds) {
      pot[id] = adapter.sample(id, timeMs);
    }
    return MotionChannelPlaybackSnapshot(
      seat: Map.unmodifiable(seat),
      board: Map.unmodifiable(board),
      pot: Map.unmodifiable(pot),
    );
  }
}
