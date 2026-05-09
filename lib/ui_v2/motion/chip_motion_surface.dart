import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'chip_motion.dart';
import 'pot_motion_controller.dart';

class ChipMotionSurface extends StatefulWidget {
  const ChipMotionSurface({
    super.key,
    this.boardPosition = Offset.zero,
    this.potController,
  });

  final Offset boardPosition;
  final PotMotionController? potController;

  @override
  ChipMotionSurfaceState createState() => ChipMotionSurfaceState();
}

class ChipMotionSurfaceState extends State<ChipMotionSurface>
    with SingleTickerProviderStateMixin {
  final List<ChipMotion> _motions = [];
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    widget.potController?.addListener(_onPotUpdated);
  }

  void addMotion(ChipMotion motion) {
    setState(() => _motions.add(motion));
  }

  void _onPotUpdated() {
    setState(() {});
  }

  void _onTick(Duration elapsed) {
    final nowMs = DateTime.now().millisecondsSinceEpoch.toDouble();
    final finished = _motions.where((motion) => motion.isDone(nowMs)).toList();
    if (finished.isNotEmpty) {
      for (final _ in finished) {
        widget.potController?.onChipArrived();
      }
      setState(() => _motions.removeWhere((motion) => motion.isDone(nowMs)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final nowMs = DateTime.now().millisecondsSinceEpoch.toDouble();
    final children = <Widget>[];
    children.addAll(
      _motions.map((motion) {
        final offset = motion.computePosition(nowMs);
        return Positioned(left: offset.dx, top: offset.dy, child: _buildChip());
      }).toList(),
    );
    children.add(_buildPotMarker());
    return Stack(children: children);
  }

  Widget _buildChip() => const DecoratedBox(
    decoration: BoxDecoration(color: Color(0xFFF2C94C), shape: BoxShape.circle),
    child: SizedBox(width: 16, height: 16),
  );

  Widget _buildPotMarker() {
    final intensity = widget.potController?.intensity ?? 0.0;
    final opacity = (0.3 + 0.7 * intensity).clamp(0.3, 1.0);
    final position = widget.boardPosition;
    return Positioned(
      left: position.dx - 12,
      top: position.dy - 12,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFD97706),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    widget.potController?.removeListener(_onPotUpdated);
    super.dispose();
  }
}
