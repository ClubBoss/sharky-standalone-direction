import 'card_motion_spec.dart';
import 'motion_channels.dart';
import 'motion_timeline_assembler.dart';

class MotionOrchestratorInput {
  const MotionOrchestratorInput({
    required this.timeline,
    required this.seat,
    required this.board,
    required this.pot,
    required this.seatChannelIds,
    required this.boardChannelIds,
    required this.potChannelIds,
  });

  final List<MotionTimelineEntry> timeline;
  final List<MotionTimelineEntry> seat;
  final List<MotionTimelineEntry> board;
  final List<MotionTimelineEntry> pot;
  final List<String> seatChannelIds;
  final List<String> boardChannelIds;
  final List<String> potChannelIds;

  factory MotionOrchestratorInput.fromSequences(
    List<CardMotionSequence> sequences,
  ) {
    final timeline = assembleTimeline(sequences);
    final channels = partitionTimeline(timeline);
    return MotionOrchestratorInput(
      timeline: timeline,
      seat: channels.seat,
      board: channels.board,
      pot: channels.pot,
      seatChannelIds: channels.seat.map((entry) => entry.spec.id).toList(),
      boardChannelIds: channels.board.map((entry) => entry.spec.id).toList(),
      potChannelIds: channels.pot.map((entry) => entry.spec.id).toList(),
    );
  }
}
