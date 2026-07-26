import 'package:flutter/widgets.dart';

class SharedLearnerTableAdjacentFrameV1 extends StatelessWidget {
  const SharedLearnerTableAdjacentFrameV1({
    super.key,
    this.topRegion,
    required this.viewportRegion,
    this.bottomRegion,
    this.expandViewport = false,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final Widget? topRegion;
  final Widget viewportRegion;
  final Widget? bottomRegion;
  final bool expandViewport;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (topRegion != null)
          if (expandViewport)
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(child: topRegion!),
            )
          else
            topRegion!,
        if (expandViewport) Expanded(child: viewportRegion) else viewportRegion,
        if (bottomRegion != null) bottomRegion!,
      ],
    );
  }
}
