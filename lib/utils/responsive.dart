import 'package:flutter/widgets.dart';

import 'context_extensions.dart';

bool isCompactWidth(BuildContext context) =>
    context.mediaQuery.size.width < 360;

double responsiveSize(BuildContext context, double value) =>
    isCompactWidth(context) ? value / 2 : value;

EdgeInsets responsiveAll(BuildContext context, double value) =>
    EdgeInsets.all(isCompactWidth(context) ? value / 2 : value);

Orientation currentOrientation(BuildContext context) =>
    context.mediaQuery.orientation;

bool isPortrait(BuildContext context) =>
    context.mediaQuery.orientation == Orientation.portrait;

bool isLandscape(BuildContext context) =>
    context.mediaQuery.orientation == Orientation.landscape;
