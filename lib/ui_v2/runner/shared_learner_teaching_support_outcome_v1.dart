import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_grammar_v1.dart';

enum SharedLearnerTeachingTextRoleV1 {
  supportPrimaryText,
  supportSecondaryText,
  supportTertiaryText,
  outcomePrimaryText,
  outcomeWhyText,
  outcomeNextText,
  outcomeDetailText,
}

@immutable
class SharedLearnerTeachingSupportOutcomeLineStyleV1 {
  const SharedLearnerTeachingSupportOutcomeLineStyleV1({
    required this.role,
    this.key,
    this.textOverride,
    this.style,
    this.fixedHeight,
    this.topSpacing = 0,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
  });

  final SharedLearnerTeachingTextRoleV1 role;
  final Key? key;
  final String? textOverride;
  final TextStyle? style;
  final double? fixedHeight;
  final double topSpacing;
  final int maxLines;
  final TextOverflow overflow;
}

@immutable
class SharedLearnerTeachingSupportOutcomeStyleV1 {
  const SharedLearnerTeachingSupportOutcomeStyleV1({
    required this.lines,
    this.surfaceKey,
    this.padding = EdgeInsets.zero,
    this.decoration,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  final List<SharedLearnerTeachingSupportOutcomeLineStyleV1> lines;
  final Key? surfaceKey;
  final EdgeInsets padding;
  final Decoration? decoration;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;
  final MainAxisSize mainAxisSize;
}

BoxDecoration buildSharedLearnerTeachingCalmSupportDecorationV1({
  double radius = SharkyTokensV1.radiusMd,
  bool compact = false,
}) {
  return BoxDecoration(
    color: SharkyTokensV1.surfaceCard.withValues(alpha: compact ? 0.58 : 0.64),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: SharkyTokensV1.slate600.withValues(alpha: compact ? 0.24 : 0.30),
    ),
  );
}

TextStyle? buildSharedLearnerTeachingPrimarySupportTextStyleV1(
  TextStyle? base,
) {
  return base?.copyWith(
    color: SharkyTokensV1.textPrimary,
    fontWeight: FontWeight.w600,
  );
}

TextStyle? buildSharedLearnerTeachingSecondarySupportTextStyleV1(
  TextStyle? base, {
  bool tertiary = false,
}) {
  return base?.copyWith(
    color: tertiary
        ? SharkyTokensV1.textMuted.withValues(alpha: 0.94)
        : SharkyTokensV1.textSecondary.withValues(alpha: 0.94),
    fontWeight: FontWeight.w500,
  );
}

class SharedLearnerTeachingSupportOutcomeV1 extends StatelessWidget {
  const SharedLearnerTeachingSupportOutcomeV1({
    super.key,
    required this.grammar,
    required this.style,
  });

  final SharedLearnerTeachingGrammarV1 grammar;
  final SharedLearnerTeachingSupportOutcomeStyleV1 style;

  String _resolveText(
    SharedLearnerTeachingTextRoleV1 role,
    SharedLearnerTeachingGrammarV1 grammar,
  ) {
    switch (role) {
      case SharedLearnerTeachingTextRoleV1.supportPrimaryText:
        return grammar.supportPrimaryText;
      case SharedLearnerTeachingTextRoleV1.supportSecondaryText:
        return grammar.supportSecondaryText;
      case SharedLearnerTeachingTextRoleV1.supportTertiaryText:
        return grammar.supportTertiaryText;
      case SharedLearnerTeachingTextRoleV1.outcomePrimaryText:
        return grammar.outcomePrimaryText;
      case SharedLearnerTeachingTextRoleV1.outcomeWhyText:
        return grammar.outcomeWhyText;
      case SharedLearnerTeachingTextRoleV1.outcomeNextText:
        return grammar.outcomeNextText;
      case SharedLearnerTeachingTextRoleV1.outcomeDetailText:
        return grammar.outcomeDetailText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final line in style.lines) {
      final text = (line.textOverride ?? _resolveText(line.role, grammar))
          .trim();
      if (text.isEmpty) {
        continue;
      }
      if (children.isNotEmpty && line.topSpacing > 0) {
        children.add(SizedBox(height: line.topSpacing));
      }
      final textWidget = Text(
        text,
        key: line.key,
        textAlign: style.textAlign,
        maxLines: line.maxLines,
        overflow: line.overflow,
        style: line.style,
      );
      children.add(
        line.fixedHeight == null
            ? textWidget
            : SizedBox(
                height: line.fixedHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: textWidget,
                ),
              ),
      );
    }
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      key: style.surfaceKey,
      width: double.infinity,
      padding: style.padding,
      decoration: style.decoration,
      child: Column(
        mainAxisSize: style.mainAxisSize,
        crossAxisAlignment: style.crossAxisAlignment,
        children: children,
      ),
    );
  }
}
