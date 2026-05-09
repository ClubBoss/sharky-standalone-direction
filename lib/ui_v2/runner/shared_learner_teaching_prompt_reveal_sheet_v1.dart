import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_grammar_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_prompt_details_v1.dart';

@immutable
class SharedLearnerTeachingPromptRevealSheetStyleV1 {
  const SharedLearnerTeachingPromptRevealSheetStyleV1({
    this.padding = const EdgeInsets.fromLTRB(18, 16, 18, 22),
    this.maxHeightFactor,
    this.headerTitle,
    this.headerTitleStyle,
    this.headerBottomSpacing = 4,
    this.showCloseButton = false,
    this.closeIcon = const Icon(Icons.close_rounded),
    this.detailsStyle = const SharedLearnerTeachingPromptDetailsStyleV1(),
  });

  final EdgeInsets padding;
  final double? maxHeightFactor;
  final String? headerTitle;
  final TextStyle? headerTitleStyle;
  final double headerBottomSpacing;
  final bool showCloseButton;
  final Widget closeIcon;
  final SharedLearnerTeachingPromptDetailsStyleV1 detailsStyle;
}

class SharedLearnerTeachingPromptRevealSheetV1 extends StatelessWidget {
  const SharedLearnerTeachingPromptRevealSheetV1({
    super.key,
    required this.grammar,
    required this.style,
    this.onClose,
    this.extraChildren = const <Widget>[],
  });

  final SharedLearnerTeachingGrammarV1 grammar;
  final SharedLearnerTeachingPromptRevealSheetStyleV1 style;
  final VoidCallback? onClose;
  final List<Widget> extraChildren;

  @override
  Widget build(BuildContext context) {
    final promptDetails = SharedLearnerTeachingPromptDetailsV1(
      grammar: grammar,
      style: style.detailsStyle,
    );
    final bodyChildren = <Widget>[
      promptDetails,
      ...extraChildren,
    ];
    final headerChildren = <Widget>[
      if (style.headerTitle != null || style.showCloseButton) ...[
        Row(
          children: [
            Expanded(
              child: style.headerTitle == null
                  ? const SizedBox.shrink()
                  : Text(
                      style.headerTitle!,
                      style: style.headerTitleStyle,
                    ),
            ),
            if (style.showCloseButton)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onClose,
                icon: style.closeIcon,
              ),
          ],
        ),
        SizedBox(height: style.headerBottomSpacing),
      ],
    ];

    final sheetContent = style.maxHeightFactor == null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...headerChildren,
              ...bodyChildren,
            ],
          )
        : Builder(
            builder: (context) {
              final media = MediaQuery.of(context);
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: media.size.height * style.maxHeightFactor!,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...headerChildren,
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: bodyChildren,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

    return SafeArea(
      child: Padding(
        padding: style.padding,
        child: sheetContent,
      ),
    );
  }
}
