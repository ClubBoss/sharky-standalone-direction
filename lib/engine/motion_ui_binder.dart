import 'simulation_motion_state_stream.dart';

class UiMotionFrame {
  const UiMotionFrame(this.index, this.atMs, this.kind, this.id);

  final int index;
  final int atMs;
  final String kind;
  final String id;
}

class MotionUiBinder {
  MotionUiBinder(this.stream);

  final MotionStateStream stream;

  List<UiMotionFrame> buildUiFrames() {
    return stream.buildStateStream().map((entry) {
      return UiMotionFrame(
        entry.index,
        entry.atMs,
        entry.event.kind,
        entry.event.value,
      );
    }).toList();
  }
}
