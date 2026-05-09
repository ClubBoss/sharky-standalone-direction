import 'package:flutter/widgets.dart'
    show StatelessWidget, Widget, Text, Positioned, Key, BuildContext;

class CohesionDebugOverlayV4 extends StatelessWidget {
  const CohesionDebugOverlayV4({
    Key? key,
    required this.colorStatus,
    required this.shapeStatus,
    required this.motionStatus,
  }) : super(key: key);

  final String colorStatus;
  final String shapeStatus;
  final String motionStatus;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Text(
        'C4 color=$colorStatus; shape=$shapeStatus; motion=$motionStatus',
      ),
    );
  }
}
