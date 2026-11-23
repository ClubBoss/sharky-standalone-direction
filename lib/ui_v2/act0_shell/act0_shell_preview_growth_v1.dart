part of 'act0_shell_preview_screen_v1.dart';

bool act0IsStoreReviewMilestoneV1(
  Act0BlockCompletionSummaryV1 summary, {
  required bool hadRunMistake,
}) =>
    summary.isWorldComplete &&
    summary.curriculumCompleted &&
    summary.masteryStatus == Act0MasteryStatusV1.cleanPass &&
    !summary.hasSafeReviewTarget &&
    !hadRunMistake &&
    summary.xpEarned > 0;

extension _Act0GrowthV1 on _Act0ShellPreviewScreenV1State {
  Future<void> _registerGrowthLinksV1(Future<void> bootstrap) async {
    await bootstrap;
    if (!mounted) return;
    _growthLinksRegistered = true;
    act0GrowthChannelV1.setMethodCallHandler((call) async {
      if (call.method == 'openLink' && call.arguments is String) {
        _openGrowthLinkV1(call.arguments as String);
      }
    });
    try {
      final initialLink = await act0GrowthChannelV1.invokeMethod<String>(
        'takeLink',
      );
      if (initialLink != null) _openGrowthLinkV1(initialLink);
    } on MissingPluginException {
      // The native bridge is absent in Dart-only runners.
    }
  }

  void _openGrowthLinkV1(String link) {
    if (!mounted ||
        !_bootSurfaceReady ||
        _recoveryBusyV1 ||
        _progressLoadFailed ||
        _firstStartPreferencesLoadFailedV1 ||
        _showWelcome ||
        _showPlacement ||
        _showW1StartV1) {
      return;
    }
    final destination = act0GrowthDestinationForLinkV1(link);
    _selectShellTabV1(switch (destination) {
      Act0GrowthDestinationV1.home => Act0ShellTabV1.home,
      Act0GrowthDestinationV1.learn => Act0ShellTabV1.learn,
    });
  }

  void _queueStoreReviewV1(Act0BlockCompletionSummaryV1 summary) {
    if (!act0GrowthSupportedV1 ||
        widget.state != null ||
        widget.debugHarnessEntry != null ||
        !act0IsStoreReviewMilestoneV1(
          summary,
          hadRunMistake: _lessonRunMistakeTaskIds.isNotEmpty,
        )) {
      return;
    }
    _storeReviewTimer?.cancel();
    _storeReviewTimer = Timer(const Duration(seconds: 2), () {
      unawaited(
        _storeReview.requestAfterMilestone(
          now: widget.clock.nowUtc(),
          canPresent: () =>
              mounted &&
              identical(_blockCompletionSummary, summary) &&
              _tab == Act0ShellTabV1.play &&
              !_recoveryBusyV1 &&
              WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.resumed &&
              ModalRoute.isCurrentOf(context) == true,
        ),
      );
    });
  }
}
