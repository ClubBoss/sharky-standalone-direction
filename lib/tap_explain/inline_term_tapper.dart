import 'package:flutter/widgets.dart';

class InlineTermTapper {
  static TextSpan wrapSpan({
    required BuildContext context,
    required String term,
    TextStyle? style,
  }) {
    return TextSpan(text: term, style: style);
  }
}
