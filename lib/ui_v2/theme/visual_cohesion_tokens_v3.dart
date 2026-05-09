import 'package:flutter/material.dart';

class VisualCohesionTokensV3 {
  const VisualCohesionTokensV3();

  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;

  static const double spacingS = 6.0;
  static const double spacingM = 12.0;
  static const double spacingL = 20.0;

  static const double elevationS = 2.0;
  static const double elevationM = 6.0;
  static const double elevationL = 12.0;

  static const List<BoxShadow> shadowSoft = [
    BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> shadowStrong = [
    BoxShadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 6)),
  ];
}
