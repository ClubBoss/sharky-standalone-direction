import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'term_definition_overlay.dart';

class InlineTermTapper {
  static TextSpan wrapSpan({
    required BuildContext context,
    required String term,
    required TextStyle style,
  }) {
    return TextSpan(
      text: term,
      style: style,
      recognizer: TapGestureRecognizer()
        ..onTap = () => TermDefinitionOverlay.show(context, term),
    );
  }
}
