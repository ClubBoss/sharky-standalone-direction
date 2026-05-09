import 'ui_motion_tick_engine.dart';

class UiTimelineEntry {
  const UiTimelineEntry(this.index, this.atMs, this.label);

  final int index;
  final int atMs;
  final String label;
}

class UiMotionTimelineBinder {
  UiMotionTimelineBinder(this.engine);

  final UiMotionTickEngine engine;

  List<UiTimelineEntry> buildTimeline() {
    final ticks = engine.buildTicks();
    return ticks
        .map(
          (tick) => UiTimelineEntry(tick.tick, tick.atMs, 'tick:${tick.tick}'),
        )
        .toList();
  }
}
