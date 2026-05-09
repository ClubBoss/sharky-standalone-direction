import 'motion_timeline_assembler.dart';
export 'motion_channels.dart';

class _TimelineEntryWrapper {
  const _TimelineEntryWrapper(this.entry, this.order);

  final MotionTimelineEntry entry;
  final int order;
}

List<MotionTimelineEntry> mergeTimelines(
  List<List<MotionTimelineEntry>> timelines,
) {
  final wrapped = <_TimelineEntryWrapper>[];
  var order = 0;
  for (final timeline in timelines) {
    for (final entry in timeline) {
      wrapped.add(_TimelineEntryWrapper(entry, order++));
    }
  }

  wrapped.sort((a, b) {
    final result = a.entry.startMs.compareTo(b.entry.startMs);
    if (result != 0) return result;
    return a.order.compareTo(b.order);
  });

  return wrapped.map((wrapper) => wrapper.entry).toList();
}
