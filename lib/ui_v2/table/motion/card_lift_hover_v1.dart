import 'package:flutter/widgets.dart';

Widget cardLiftHoverV1({
  required Widget cardWidget,
  required bool isFaceUp,
  Map<String, Object?> visualStyleBundle = const <String, Object?>{},
}) {
  final _ = visualStyleBundle;
  if (!isFaceUp) return cardWidget;
  return Transform.translate(
    offset: const Offset(0, -3),
    child: Transform.scale(scale: 1.03, child: cardWidget),
  );
}
