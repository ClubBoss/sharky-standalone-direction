import 'motion_timeline_assembler.dart';

class MotionChannels {
  const MotionChannels({
    required this.seat,
    required this.board,
    required this.pot,
  });

  final List<MotionTimelineEntry> seat;
  final List<MotionTimelineEntry> board;
  final List<MotionTimelineEntry> pot;
}

MotionChannels partitionTimeline(List<MotionTimelineEntry> timeline) {
  final seat = <MotionTimelineEntry>[];
  final board = <MotionTimelineEntry>[];
  final pot = <MotionTimelineEntry>[];
  for (final entry in timeline) {
    final id = entry.spec.id;
    if (id.startsWith('seat:')) {
      seat.add(entry);
    } else if (id.startsWith('board:')) {
      board.add(entry);
    } else if (id.startsWith('pot:')) {
      pot.add(entry);
    }
  }
  return MotionChannels(seat: seat, board: board, pot: pot);
}
