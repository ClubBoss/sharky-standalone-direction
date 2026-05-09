import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_grammar_v1.dart';

@immutable
class SharedLearnerTeachingPromptDetailsStyleV1 {
  const SharedLearnerTeachingPromptDetailsStyleV1({
    this.surfaceKey,
    this.titleKey,
    this.bodyKey,
    this.padding = EdgeInsets.zero,
    this.titleBodySpacing = 8,
    this.decoration,
    this.titleStyle,
    this.bodyStyle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final Key? surfaceKey;
  final Key? titleKey;
  final Key? bodyKey;
  final EdgeInsets padding;
  final double titleBodySpacing;
  final Decoration? decoration;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;
  final CrossAxisAlignment crossAxisAlignment;
}

class SharedLearnerTeachingPromptDetailsV1 extends StatelessWidget {
  const SharedLearnerTeachingPromptDetailsV1({
    super.key,
    required this.grammar,
    required this.style,
  });

  final SharedLearnerTeachingGrammarV1 grammar;
  final SharedLearnerTeachingPromptDetailsStyleV1 style;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: style.surfaceKey,
      width: double.infinity,
      padding: style.padding,
      decoration: style.decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: style.crossAxisAlignment,
        children: [
          Text(
            grammar.promptDetailsTitle,
            key: style.titleKey,
            style: style.titleStyle,
          ),
          SizedBox(height: style.titleBodySpacing),
          Text(
            grammar.promptDetailsText,
            key: style.bodyKey,
            style: style.bodyStyle,
          ),
        ],
      ),
    );
  }
}
