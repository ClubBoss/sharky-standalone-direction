import 'package:flutter/material.dart';

class PanelV3 extends StatelessWidget {
  const PanelV3({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Material(elevation: 0, color: Colors.transparent, child: child);
}
