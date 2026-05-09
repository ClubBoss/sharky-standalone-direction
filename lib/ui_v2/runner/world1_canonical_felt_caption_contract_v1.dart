import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

enum World1CanonicalFeltCaptionBodyKindV1 {
  hidden,
  zeroOpacityPlaceholder,
  promptContainer,
}

class World1CanonicalFeltCaptionContractInputV1 {
  const World1CanonicalFeltCaptionContractInputV1({
    required this.portraitLayout,
    required this.affectedStateFamily,
    required this.usesFeltCaptionHost,
    required this.isMounted,
    required this.showSeatQuizPrelude,
    required this.showIntroSequence,
    required this.handLoopVisualMode,
    required this.outcomeSurfaceVisible,
    required this.debugCaptionOverridePresent,
    required this.isDemoHandLoopVisualStep,
    required this.reviewQueuePrefix,
    required this.compactPortrait,
    required this.rotatedSbBbDensityRefine,
    required this.mountedPromptText,
    required this.fallbackPromptText,
    required this.mountedMaxWidth,
    required this.fallbackMaxWidth,
  });

  final bool portraitLayout;
  final bool affectedStateFamily;
  final bool usesFeltCaptionHost;
  final bool isMounted;
  final bool showSeatQuizPrelude;
  final bool showIntroSequence;
  final bool handLoopVisualMode;
  final bool outcomeSurfaceVisible;
  final bool debugCaptionOverridePresent;
  final bool isDemoHandLoopVisualStep;
  final bool reviewQueuePrefix;
  final bool compactPortrait;
  final bool rotatedSbBbDensityRefine;
  final String mountedPromptText;
  final String fallbackPromptText;
  final double mountedMaxWidth;
  final double fallbackMaxWidth;
}

class World1CanonicalFeltCaptionContractResolvedV1 {
  const World1CanonicalFeltCaptionContractResolvedV1({
    required this.showsPositionedCaption,
    required this.bodyKind,
    required this.maxWidth,
    required this.promptText,
    required this.useReviewPrefix,
    required this.containerKey,
    required this.verticalPadding,
    required this.backgroundColor,
    required this.borderColor,
    required this.boxShadow,
    required this.maxLines,
    required this.textStyle,
    required this.reviewPrefixStyle,
  });

  final bool showsPositionedCaption;
  final World1CanonicalFeltCaptionBodyKindV1 bodyKind;
  final double maxWidth;
  final String promptText;
  final bool useReviewPrefix;
  final Key? containerKey;
  final double verticalPadding;
  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow>? boxShadow;
  final int maxLines;
  final TextStyle textStyle;
  final TextStyle reviewPrefixStyle;
}

World1CanonicalFeltCaptionContractResolvedV1
resolveWorld1CanonicalFeltCaptionContractV1(
  World1CanonicalFeltCaptionContractInputV1 input,
) {
  final showsPositionedCaption =
      (input.portraitLayout ||
          (input.affectedStateFamily && input.usesFeltCaptionHost)) &&
      !input.showSeatQuizPrelude &&
      !input.showIntroSequence;
  final isDemo = input.isDemoHandLoopVisualStep;
  final useReviewPrefix = input.reviewQueuePrefix && !isDemo;
  final textStyle = AppTypography.caption.copyWith(
    color: isDemo ? SharkyTokensV1.textSecondary : SharkyTokensV1.textPrimary,
    fontWeight: isDemo ? FontWeight.w700 : FontWeight.w800,
    fontSize: isDemo
        ? (input.rotatedSbBbDensityRefine
              ? (input.compactPortrait ? 10.3 : 10.8)
              : (input.compactPortrait ? 10.6 : 11.0))
        : (input.compactPortrait ? 11.2 : 11.6),
    height: isDemo ? 1.15 : 1.12,
  );
  final reviewPrefixStyle = AppTypography.caption.copyWith(
    color: SharkyTokensV1.brandGlow,
    fontWeight: FontWeight.w900,
    fontSize: input.compactPortrait ? 10.6 : 11.0,
    height: 1.12,
    letterSpacing: 0.4,
  );

  if (!showsPositionedCaption) {
    return World1CanonicalFeltCaptionContractResolvedV1(
      showsPositionedCaption: false,
      bodyKind: World1CanonicalFeltCaptionBodyKindV1.hidden,
      maxWidth: 0,
      promptText: '',
      useReviewPrefix: false,
      containerKey: null,
      verticalPadding: 0,
      backgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      boxShadow: null,
      maxLines: 0,
      textStyle: textStyle,
      reviewPrefixStyle: reviewPrefixStyle,
    );
  }

  if (input.affectedStateFamily && input.usesFeltCaptionHost) {
    if (!input.isMounted) {
      return World1CanonicalFeltCaptionContractResolvedV1(
        showsPositionedCaption: true,
        bodyKind: World1CanonicalFeltCaptionBodyKindV1.hidden,
        maxWidth: input.mountedMaxWidth,
        promptText: '',
        useReviewPrefix: false,
        containerKey: null,
        verticalPadding: 0,
        backgroundColor: Colors.transparent,
        borderColor: Colors.transparent,
        boxShadow: null,
        maxLines: 0,
        textStyle: textStyle,
        reviewPrefixStyle: reviewPrefixStyle,
      );
    }
    return World1CanonicalFeltCaptionContractResolvedV1(
      showsPositionedCaption: true,
      bodyKind: World1CanonicalFeltCaptionBodyKindV1.promptContainer,
      maxWidth: input.mountedMaxWidth,
      promptText: input.mountedPromptText,
      useReviewPrefix: useReviewPrefix,
      containerKey: isDemo ? const Key('microtask_demo_prompt_box_v1') : null,
      verticalPadding: isDemo ? (input.rotatedSbBbDensityRefine ? 2.5 : 4) : 6,
      backgroundColor: isDemo
          ? SharkyTokensV1.surfaceApp.withOpacity(0.72)
          : (useReviewPrefix
                ? SharkyTokensV1.surfaceElevated.withOpacity(0.9)
                : SharkyTokensV1.surfaceElevated.withOpacity(0.88)),
      borderColor: isDemo
          ? SharkyTokensV1.slate500.withOpacity(0.4)
          : (useReviewPrefix
                ? SharkyTokensV1.brandGlow.withOpacity(0.42)
                : SharkyTokensV1.slate600.withOpacity(0.7)),
      boxShadow: isDemo ? null : SharkyTokensV1.elevation1,
      maxLines: isDemo ? 1 : 2,
      textStyle: textStyle,
      reviewPrefixStyle: reviewPrefixStyle,
    );
  }

  if (!input.handLoopVisualMode) {
    return World1CanonicalFeltCaptionContractResolvedV1(
      showsPositionedCaption: true,
      bodyKind: World1CanonicalFeltCaptionBodyKindV1.hidden,
      maxWidth: input.fallbackMaxWidth,
      promptText: '',
      useReviewPrefix: false,
      containerKey: null,
      verticalPadding: 0,
      backgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      boxShadow: null,
      maxLines: 0,
      textStyle: textStyle,
      reviewPrefixStyle: reviewPrefixStyle,
    );
  }

  if (input.outcomeSurfaceVisible && !input.debugCaptionOverridePresent) {
    return World1CanonicalFeltCaptionContractResolvedV1(
      showsPositionedCaption: true,
      bodyKind: World1CanonicalFeltCaptionBodyKindV1.zeroOpacityPlaceholder,
      maxWidth: input.fallbackMaxWidth,
      promptText: '',
      useReviewPrefix: false,
      containerKey: null,
      verticalPadding: 0,
      backgroundColor: Colors.transparent,
      borderColor: Colors.transparent,
      boxShadow: null,
      maxLines: 0,
      textStyle: textStyle,
      reviewPrefixStyle: reviewPrefixStyle,
    );
  }

  return World1CanonicalFeltCaptionContractResolvedV1(
    showsPositionedCaption: true,
    bodyKind: World1CanonicalFeltCaptionBodyKindV1.promptContainer,
    maxWidth: input.fallbackMaxWidth,
    promptText: input.fallbackPromptText,
    useReviewPrefix: useReviewPrefix,
    containerKey: isDemo ? const Key('microtask_demo_prompt_box_v1') : null,
    verticalPadding: isDemo ? (input.rotatedSbBbDensityRefine ? 2.5 : 4) : 6,
    backgroundColor: isDemo
        ? SharkyTokensV1.surfaceApp.withOpacity(0.72)
        : (useReviewPrefix
              ? SharkyTokensV1.surfaceElevated.withOpacity(0.9)
              : SharkyTokensV1.surfaceElevated.withOpacity(0.88)),
    borderColor: isDemo
        ? SharkyTokensV1.slate500.withOpacity(0.4)
        : (useReviewPrefix
              ? SharkyTokensV1.brandGlow.withOpacity(0.42)
              : SharkyTokensV1.slate600.withOpacity(0.7)),
    boxShadow: isDemo ? null : SharkyTokensV1.elevation1,
    maxLines: isDemo ? 1 : 2,
    textStyle: textStyle,
    reviewPrefixStyle: reviewPrefixStyle,
  );
}

Widget buildWorld1CanonicalFeltCaptionBodyV1(
  World1CanonicalFeltCaptionContractResolvedV1 contract,
) {
  switch (contract.bodyKind) {
    case World1CanonicalFeltCaptionBodyKindV1.hidden:
      return const SizedBox.shrink();
    case World1CanonicalFeltCaptionBodyKindV1.zeroOpacityPlaceholder:
      return const Opacity(
        opacity: 0,
        child: SizedBox(key: Key('microtask_step_prompt'), width: 1, height: 1),
      );
    case World1CanonicalFeltCaptionBodyKindV1.promptContainer:
      return KeyedSubtree(
        key: const Key('microtask_felt_caption_container_v1'),
        child: Container(
          key: contract.containerKey,
          constraints: BoxConstraints(maxWidth: contract.maxWidth),
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: contract.verticalPadding,
          ),
          decoration: BoxDecoration(
            color: contract.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: contract.borderColor),
            boxShadow: contract.boxShadow,
          ),
          child: contract.useReviewPrefix
              ? Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: 'REVIEW  ',
                        style: contract.reviewPrefixStyle,
                      ),
                      TextSpan(text: contract.promptText),
                    ],
                  ),
                  key: const Key('microtask_step_prompt'),
                  textAlign: TextAlign.center,
                  maxLines: contract.maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: contract.textStyle,
                )
              : Text(
                  contract.promptText,
                  key: const Key('microtask_step_prompt'),
                  textAlign: TextAlign.center,
                  maxLines: contract.maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: contract.textStyle,
                ),
        ),
      );
  }
}
