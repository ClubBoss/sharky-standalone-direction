/// UI compatibility stubs for missing widgets and constructors.
import 'package:flutter/material.dart';

/// Stub for ActionTimelineWidget - wraps existing widget with basic implementation
class ActionTimelineWidget extends StatelessWidget {
  final dynamic data;
  const ActionTimelineWidget({super.key, this.data});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    child: const Text('ActionTimeline'),
  );
}

/// Stub for BoardDisplay - wraps existing widget with basic implementation
class BoardDisplay extends StatelessWidget {
  final dynamic board;
  const BoardDisplay({super.key, this.board});

  @override
  Widget build(BuildContext context) =>
      Container(padding: const EdgeInsets.all(8), child: const Text('Board'));
}

/// Stub for AnimatedLineChart - wraps existing widget with basic implementation
class AnimatedLineChart extends StatelessWidget {
  final dynamic data;
  const AnimatedLineChart({super.key, this.data});

  @override
  Widget build(BuildContext context) =>
      Container(height: 200, child: const Center(child: Text('Chart')));
}

/// Stub for _TrainingSpotListState - returns empty state
// ignore: unused_element
class _TrainingSpotListState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
