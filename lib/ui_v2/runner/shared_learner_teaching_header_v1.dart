import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_compact_header_band_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_prompt_status_capsule_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_grammar_v1.dart';

@immutable
class SharedLearnerTeachingHeaderStyleV1 {
  const SharedLearnerTeachingHeaderStyleV1({
    this.surfaceKey,
    this.statusTextKey,
    this.headlineTextKey,
    this.promptSurfaceKey,
    this.promptStatusTextKey,
    this.promptTextKey,
    this.trailing,
    this.compact = false,
    this.surfaceColor,
    this.borderColor,
    this.statusColor,
    this.headlineColor,
    this.promptForegroundColor,
    this.promptSurfaceColor,
    this.promptBorderColor,
    this.promptBadgeColor,
    this.promptPadding,
    this.detailsLabel = 'Details',
    this.showPromptCapsule = true,
    this.showPromptChevron = true,
    this.maxPromptLines = 1,
    this.promptSoftWrap = false,
    this.promptOverflow = TextOverflow.ellipsis,
    this.surfacePadding,
    this.surfaceBottomChildGap,
  });

  final Key? surfaceKey;
  final Key? statusTextKey;
  final Key? headlineTextKey;
  final Key? promptSurfaceKey;
  final Key? promptStatusTextKey;
  final Key? promptTextKey;
  final Widget? trailing;
  final bool compact;
  final Color? surfaceColor;
  final Color? borderColor;
  final Color? statusColor;
  final Color? headlineColor;
  final Color? promptForegroundColor;
  final Color? promptSurfaceColor;
  final Color? promptBorderColor;
  final Color? promptBadgeColor;
  final EdgeInsetsGeometry? promptPadding;
  final String detailsLabel;
  final bool showPromptCapsule;
  final bool showPromptChevron;
  final int maxPromptLines;
  final bool promptSoftWrap;
  final TextOverflow promptOverflow;
  final EdgeInsetsGeometry? surfacePadding;
  final double? surfaceBottomChildGap;
}

class SharedLearnerTeachingHeaderV1 extends StatelessWidget {
  const SharedLearnerTeachingHeaderV1({
    super.key,
    required this.grammar,
    required this.style,
    this.onOpenDetails,
  });

  final SharedLearnerTeachingGrammarV1 grammar;
  final SharedLearnerTeachingHeaderStyleV1 style;
  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return RunnerCompactHeaderBandV1(
      surfaceKey: style.surfaceKey,
      statusText: grammar.headerStatusText,
      statusTextKey: style.statusTextKey,
      headlineText: grammar.headerHeadlineText,
      headlineTextKey: style.headlineTextKey,
      trailing: style.trailing,
      compact: style.compact,
      surfaceColor: style.surfaceColor,
      borderColor: style.borderColor,
      statusColor: style.statusColor,
      headlineColor: style.headlineColor,
      surfacePadding: style.surfacePadding,
      bottomChildGap: style.surfaceBottomChildGap,
      bottomChild: style.showPromptCapsule
          ? RunnerPromptStatusCapsuleV1(
              surfaceKey: style.promptSurfaceKey,
              statusText: grammar.promptStatusText,
              statusTextKey: style.promptStatusTextKey,
              promptText: grammar.headerPromptText,
              promptTextKey: style.promptTextKey,
              onTap: grammar.enablePromptDetailsAffordance
                  ? onOpenDetails
                  : null,
              compact: true,
              foregroundColor: style.promptForegroundColor,
              surfaceColor: style.promptSurfaceColor,
              borderColor: style.promptBorderColor,
              badgeColor: style.promptBadgeColor,
              padding: style.promptPadding,
              detailsLabel: style.detailsLabel,
              showChevron:
                  style.showPromptChevron &&
                  grammar.enablePromptDetailsAffordance,
              maxPromptLines: style.maxPromptLines,
              promptSoftWrap: style.promptSoftWrap,
              promptOverflow: style.promptOverflow,
            )
          : null,
    );
  }
}
