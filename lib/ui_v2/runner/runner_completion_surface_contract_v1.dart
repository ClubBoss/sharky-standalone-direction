import 'package:flutter/foundation.dart';

@immutable
class RunnerCompletionSurfaceContractV1 {
  const RunnerCompletionSurfaceContractV1({
    required this.statusHeader,
    required this.bodyText,
    required this.primaryCtaLabel,
    this.secondaryCtaLabel,
  });

  final String statusHeader;
  final String bodyText;
  final String primaryCtaLabel;
  final String? secondaryCtaLabel;

  bool get showsSecondaryCta =>
      secondaryCtaLabel != null && secondaryCtaLabel!.trim().isNotEmpty;
}

RunnerCompletionSurfaceContractV1 buildRunnerCompletionSurfaceContractV1({
  required String statusHeader,
  required String bodyText,
  required bool hasPrimaryNext,
  required String primaryNextLabel,
  String fallbackPrimaryLabel = 'BACK TO MAP',
  bool showSecondaryBackToMap = true,
}) {
  final primaryCtaLabel = hasPrimaryNext
      ? primaryNextLabel.trim()
      : fallbackPrimaryLabel.trim();
  final secondaryCtaLabel = hasPrimaryNext && showSecondaryBackToMap
      ? 'BACK TO MAP'
      : null;
  return RunnerCompletionSurfaceContractV1(
    statusHeader: statusHeader.trim(),
    bodyText: bodyText.trim(),
    primaryCtaLabel: primaryCtaLabel,
    secondaryCtaLabel: secondaryCtaLabel,
  );
}
