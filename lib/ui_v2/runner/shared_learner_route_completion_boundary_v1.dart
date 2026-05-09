import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum SharedLearnerTerminalControlCategoryV1 {
  hidden,
  continueLike,
  retryLike,
  reviewLike,
  resultLike,
  resetLike,
  nextSessionLike,
  backLike,
  closeLike,
}

@immutable
class SharedLearnerTerminalControlActionV1 {
  const SharedLearnerTerminalControlActionV1._({
    required this.category,
    required this.label,
    required this.onPressed,
    required this.isBusy,
  });

  const SharedLearnerTerminalControlActionV1.hidden()
    : this._(
        category: SharedLearnerTerminalControlCategoryV1.hidden,
        label: '',
        onPressed: null,
        isBusy: false,
      );

  factory SharedLearnerTerminalControlActionV1.visible({
    required SharedLearnerTerminalControlCategoryV1 category,
    required String label,
    required VoidCallback? onPressed,
    bool isBusy = false,
  }) {
    assert(category != SharedLearnerTerminalControlCategoryV1.hidden);
    return SharedLearnerTerminalControlActionV1._(
      category: category,
      label: label.trim(),
      onPressed: onPressed,
      isBusy: isBusy,
    );
  }

  final SharedLearnerTerminalControlCategoryV1 category;
  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;

  bool get isVisible =>
      category != SharedLearnerTerminalControlCategoryV1.hidden &&
      label.trim().isNotEmpty;
}

@immutable
class SharedLearnerRouteCompletionBoundaryV1 {
  const SharedLearnerRouteCompletionBoundaryV1({
    required this.primaryAction,
    this.secondaryAction = const SharedLearnerTerminalControlActionV1.hidden(),
  });

  const SharedLearnerRouteCompletionBoundaryV1.hidden()
    : primaryAction = const SharedLearnerTerminalControlActionV1.hidden(),
      secondaryAction = const SharedLearnerTerminalControlActionV1.hidden();

  final SharedLearnerTerminalControlActionV1 primaryAction;
  final SharedLearnerTerminalControlActionV1 secondaryAction;

  bool get showsPrimaryAction => primaryAction.isVisible;
  bool get showsSecondaryAction => secondaryAction.isVisible;
}
