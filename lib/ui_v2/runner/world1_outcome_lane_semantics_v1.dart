import 'package:flutter/foundation.dart';

@immutable
class World1OutcomeLaneSemanticsV1 {
  const World1OutcomeLaneSemanticsV1({
    required this.primaryLabel,
    required this.showsRetrySecondary,
  });

  final String primaryLabel;
  final bool showsRetrySecondary;

  String? get secondaryLabel => showsRetrySecondary ? 'RETRY' : null;
}

World1OutcomeLaneSemanticsV1 resolveWorld1OutcomeLaneSemanticsV1({
  required bool isCorrect,
  required bool continueAdvancesFlow,
  String? primaryCtaLabelOverride,
  bool? showRetrySecondaryOverride,
}) {
  final normalizedOverride = primaryCtaLabelOverride?.trim() ?? '';
  final primaryLabel = normalizedOverride.isNotEmpty
      ? normalizedOverride
      : (continueAdvancesFlow ? 'NEXT' : 'RETRY');
  final showsRetrySecondary =
      showRetrySecondaryOverride ??
      (!isCorrect && primaryLabel.toUpperCase() != 'RETRY');
  return World1OutcomeLaneSemanticsV1(
    primaryLabel: primaryLabel,
    showsRetrySecondary: showsRetrySecondary,
  );
}
