import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

enum World1CanonicalPortraitOverlayBodyKindV1 {
  hidden,
  placeholderSignals,
  outcomeStatus,
  hintBubble,
  feedbackBubble,
}

class World1CanonicalPortraitOverlayContractInputV1 {
  const World1CanonicalPortraitOverlayContractInputV1({
    required this.portraitLayout,
    required this.handLoopVisualMode,
    required this.showSeatQuizPrelude,
    required this.showIntroSequence,
    required this.outcomeSurfaceVisible,
    required this.showHint,
    required this.hasFeedback,
    required this.showOutcomeHeaderStatus,
    required this.showHintBubble,
    required this.pulseFailure,
    required this.feedbackText,
    required this.hintText,
  });

  final bool portraitLayout;
  final bool handLoopVisualMode;
  final bool showSeatQuizPrelude;
  final bool showIntroSequence;
  final bool outcomeSurfaceVisible;
  final bool showHint;
  final bool hasFeedback;
  final bool showOutcomeHeaderStatus;
  final bool showHintBubble;
  final bool pulseFailure;
  final String? feedbackText;
  final String hintText;
}

class World1CanonicalPortraitOverlayContractResolvedV1 {
  const World1CanonicalPortraitOverlayContractResolvedV1({
    required this.bodyKind,
    required this.feedbackText,
    required this.hintText,
    required this.feedbackTextColor,
  });

  final World1CanonicalPortraitOverlayBodyKindV1 bodyKind;
  final String feedbackText;
  final String hintText;
  final Color feedbackTextColor;
}

World1CanonicalPortraitOverlayContractResolvedV1
resolveWorld1CanonicalPortraitOverlayContractV1(
  World1CanonicalPortraitOverlayContractInputV1 input,
) {
  final hidePortraitSeatQuizStatusOverlay =
      input.portraitLayout &&
      !input.handLoopVisualMode &&
      !input.showSeatQuizPrelude &&
      !input.showIntroSequence &&
      (input.outcomeSurfaceVisible || input.showHint || input.hasFeedback);
  final hidePortraitHandLoopOutcomeOverlay =
      input.portraitLayout &&
      input.handLoopVisualMode &&
      input.outcomeSurfaceVisible;

  if (hidePortraitHandLoopOutcomeOverlay) {
    return const World1CanonicalPortraitOverlayContractResolvedV1(
      bodyKind: World1CanonicalPortraitOverlayBodyKindV1.hidden,
      feedbackText: '',
      hintText: '',
      feedbackTextColor: Colors.transparent,
    );
  }

  if (hidePortraitSeatQuizStatusOverlay) {
    return const World1CanonicalPortraitOverlayContractResolvedV1(
      bodyKind: World1CanonicalPortraitOverlayBodyKindV1.placeholderSignals,
      feedbackText: '',
      hintText: '',
      feedbackTextColor: Colors.transparent,
    );
  }

  if (input.showOutcomeHeaderStatus) {
    return const World1CanonicalPortraitOverlayContractResolvedV1(
      bodyKind: World1CanonicalPortraitOverlayBodyKindV1.outcomeStatus,
      feedbackText: '',
      hintText: '',
      feedbackTextColor: Colors.transparent,
    );
  }

  if (input.showHintBubble) {
    return World1CanonicalPortraitOverlayContractResolvedV1(
      bodyKind: World1CanonicalPortraitOverlayBodyKindV1.hintBubble,
      feedbackText: '',
      hintText: input.hintText,
      feedbackTextColor: Colors.transparent,
    );
  }

  if (input.hasFeedback && !input.outcomeSurfaceVisible) {
    return World1CanonicalPortraitOverlayContractResolvedV1(
      bodyKind: World1CanonicalPortraitOverlayBodyKindV1.feedbackBubble,
      feedbackText: input.feedbackText ?? '',
      hintText: '',
      feedbackTextColor: input.pulseFailure
          ? SharkyTokensV1.semanticLoss
          : SharkyTokensV1.textSecondary,
    );
  }

  return const World1CanonicalPortraitOverlayContractResolvedV1(
    bodyKind: World1CanonicalPortraitOverlayBodyKindV1.hidden,
    feedbackText: '',
    hintText: '',
    feedbackTextColor: Colors.transparent,
  );
}

Widget buildWorld1CanonicalPortraitOverlayBodyV1({
  required World1CanonicalPortraitOverlayContractResolvedV1 contract,
  required Widget outcomeStatusChild,
  required double maxWidth,
}) {
  switch (contract.bodyKind) {
    case World1CanonicalPortraitOverlayBodyKindV1.hidden:
      return const SizedBox.shrink();
    case World1CanonicalPortraitOverlayBodyKindV1.placeholderSignals:
      return Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            SizedBox(width: 1, height: 1),
            SizedBox(key: Key('microtask_hint_bubble'), width: 1, height: 1),
          ],
        ),
      );
    case World1CanonicalPortraitOverlayBodyKindV1.outcomeStatus:
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: outcomeStatusChild,
        ),
      );
    case World1CanonicalPortraitOverlayBodyKindV1.hintBubble:
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            key: const Key('microtask_hint_bubble'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SharkyTokensV1.semanticInfo.withOpacity(0.15),
              borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
              border: Border.all(
                color: SharkyTokensV1.semanticInfo.withOpacity(0.8),
              ),
            ),
            child: Text(
              contract.hintText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: SharkyTokensV1.textPrimary,
              ),
            ),
          ),
        ),
      );
    case World1CanonicalPortraitOverlayBodyKindV1.feedbackBubble:
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.18),
              borderRadius: BorderRadius.circular(SharkyTokensV1.radiusSm),
              border: Border.all(
                color: SharkyTokensV1.slate600.withOpacity(0.18),
              ),
            ),
            child: Text(
              contract.feedbackText,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: contract.feedbackTextColor,
              ),
            ),
          ),
        ),
      );
  }
}
