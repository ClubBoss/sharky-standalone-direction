import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_grammar_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_prompt_reveal_sheet_v1.dart';

typedef SharedLearnerPromptRevealExtraChildrenBuilderV1 =
    List<Widget> Function(BuildContext sheetContext);

@immutable
class SharedLearnerPromptRevealLauncherStyleV1 {
  const SharedLearnerPromptRevealLauncherStyleV1({
    required this.backgroundColor,
    required this.shape,
    required this.sheetStyle,
    this.isScrollControlled = false,
  });

  final Color backgroundColor;
  final ShapeBorder shape;
  final SharedLearnerTeachingPromptRevealSheetStyleV1 sheetStyle;
  final bool isScrollControlled;
}

Future<void> showSharedLearnerPromptRevealSheetV1({
  required BuildContext context,
  required SharedLearnerTeachingGrammarV1 grammar,
  required SharedLearnerPromptRevealLauncherStyleV1 style,
  SharedLearnerPromptRevealExtraChildrenBuilderV1? buildExtraChildren,
}) async {
  if (!grammar.canRevealPromptDetails) {
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: style.isScrollControlled,
    backgroundColor: style.backgroundColor,
    shape: style.shape,
    builder: (sheetContext) {
      final extraChildren =
          buildExtraChildren?.call(sheetContext) ?? const <Widget>[];
      return SharedLearnerTeachingPromptRevealSheetV1(
        grammar: grammar,
        style: style.sheetStyle,
        onClose: () => Navigator.of(sheetContext).pop(),
        extraChildren: extraChildren,
      );
    },
  );
}
