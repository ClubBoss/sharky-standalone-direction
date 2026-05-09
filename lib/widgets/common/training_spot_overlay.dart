import 'package:flutter/material.dart';
import '../../models/training_spot.dart';

class TrainingSpotOverlay extends StatelessWidget {
  final Widget child;
  final void Function(List<TrainingSpot> spots)? onSpotsDropped;

  const TrainingSpotOverlay({
    super.key,
    required this.child,
    this.onSpotsDropped,
  });

  @override
  Widget build(BuildContext context) => DragTarget<List<TrainingSpot>>(
    onAcceptWithDetails: onSpotsDropped == null
        ? null
        : (details) => onSpotsDropped!(details.data),
    builder: (context, _, __) => child,
  );
}
