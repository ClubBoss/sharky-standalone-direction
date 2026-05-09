import 'package:flutter/foundation.dart';

@immutable
class SharedLearnerTeachingGrammarV1 {
  const SharedLearnerTeachingGrammarV1({
    required this.headerStatusText,
    required this.headerHeadlineText,
    required this.headerPromptText,
    required this.promptStatusText,
    required this.displayedPrompt,
    required this.promptDetailsTitle,
    required this.promptDetailsText,
    required this.canRevealPromptDetails,
    required this.enablePromptDetailsAffordance,
    required this.supportPrimaryText,
    required this.supportSecondaryText,
    required this.supportTertiaryText,
    required this.outcomePrimaryText,
    required this.outcomeWhyText,
    required this.outcomeNextText,
    required this.outcomeDetailText,
  });

  final String? headerStatusText;
  final String headerHeadlineText;
  final String headerPromptText;
  final String? promptStatusText;
  final String displayedPrompt;
  final String promptDetailsTitle;
  final String promptDetailsText;
  final bool canRevealPromptDetails;
  final bool enablePromptDetailsAffordance;
  final String supportPrimaryText;
  final String supportSecondaryText;
  final String supportTertiaryText;
  final String outcomePrimaryText;
  final String outcomeWhyText;
  final String outcomeNextText;
  final String outcomeDetailText;

  SharedLearnerTeachingGrammarV1 copyWith({
    String? headerStatusText,
    String? headerHeadlineText,
    String? headerPromptText,
    String? promptStatusText,
    String? displayedPrompt,
    String? promptDetailsTitle,
    String? promptDetailsText,
    bool? canRevealPromptDetails,
    bool? enablePromptDetailsAffordance,
    String? supportPrimaryText,
    String? supportSecondaryText,
    String? supportTertiaryText,
    String? outcomePrimaryText,
    String? outcomeWhyText,
    String? outcomeNextText,
    String? outcomeDetailText,
  }) {
    return SharedLearnerTeachingGrammarV1(
      headerStatusText: headerStatusText ?? this.headerStatusText,
      headerHeadlineText: headerHeadlineText ?? this.headerHeadlineText,
      headerPromptText: headerPromptText ?? this.headerPromptText,
      promptStatusText: promptStatusText ?? this.promptStatusText,
      displayedPrompt: displayedPrompt ?? this.displayedPrompt,
      promptDetailsTitle: promptDetailsTitle ?? this.promptDetailsTitle,
      promptDetailsText: promptDetailsText ?? this.promptDetailsText,
      canRevealPromptDetails:
          canRevealPromptDetails ?? this.canRevealPromptDetails,
      enablePromptDetailsAffordance:
          enablePromptDetailsAffordance ?? this.enablePromptDetailsAffordance,
      supportPrimaryText: supportPrimaryText ?? this.supportPrimaryText,
      supportSecondaryText: supportSecondaryText ?? this.supportSecondaryText,
      supportTertiaryText: supportTertiaryText ?? this.supportTertiaryText,
      outcomePrimaryText: outcomePrimaryText ?? this.outcomePrimaryText,
      outcomeWhyText: outcomeWhyText ?? this.outcomeWhyText,
      outcomeNextText: outcomeNextText ?? this.outcomeNextText,
      outcomeDetailText: outcomeDetailText ?? this.outcomeDetailText,
    );
  }
}
