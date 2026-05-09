import 'package:flutter/widgets.dart';

class SharedLearnerTableAdjacentFrameV1 extends StatelessWidget {
  const SharedLearnerTableAdjacentFrameV1({
    super.key,
    this.topRegion,
    required this.viewportRegion,
    this.bottomRegion,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final Widget? topRegion;
  final Widget viewportRegion;
  final Widget? bottomRegion;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (topRegion != null) topRegion!,
        viewportRegion,
        if (bottomRegion != null) bottomRegion!,
      ],
    );
  }
}
