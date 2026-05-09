import 'package:flutter/material.dart';

class RunnerBottomActionStackV1 extends StatelessWidget {
  const RunnerBottomActionStackV1({
    super.key,
    this.surfaceKey,
    required this.primaryChild,
    this.secondaryChild,
    this.spacing = 8,
  });

  final Key? surfaceKey;
  final Widget primaryChild;
  final Widget? secondaryChild;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: surfaceKey,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        primaryChild,
        if (secondaryChild != null) ...<Widget>[
          SizedBox(height: spacing),
          secondaryChild!,
        ],
      ],
    );
  }
}
