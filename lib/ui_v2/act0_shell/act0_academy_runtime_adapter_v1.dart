import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:poker_analyzer/ui/settings/privacy_terms.dart';
import 'act0_achievement_seed_projection_v1.dart';
import 'act0_home_shell_v1.dart';
import 'act0_play_shell_v1.dart';
import 'act0_profile_shell_v1.dart';
import 'act0_review_shell_v1.dart';
import 'act0_shell_state_v1.dart';
import 'academy_leaves/act0_academy_home_leaf_v1.dart';
import 'academy_leaves/act0_academy_leaf_style_v1.dart';
import 'academy_leaves/act0_academy_practice_leaf_v1.dart';
import 'academy_leaves/act0_academy_review_leaf_v1.dart';
import 'academy_leaves/act0_academy_settings_leaf_v1.dart';
import 'academy_leaves/act0_academy_you_leaf_v1.dart';

// Independent rollback switches. These adapt the current shell's resolved
// inputs/callbacks, never the historical donor's runtime or persistence.
const act0AcademyHomePreviewV1 = bool.fromEnvironment(
  'SHARKY_ACADEMY_HOME_PREVIEW',
);
const act0AcademyPracticePreviewV1 = bool.fromEnvironment(
  'SHARKY_ACADEMY_PRACTICE_PREVIEW',
);
const act0AcademyReviewPreviewV1 = bool.fromEnvironment(
  'SHARKY_ACADEMY_REVIEW_PREVIEW',
);
const act0AcademyYouPreviewV1 = bool.fromEnvironment(
  'SHARKY_ACADEMY_YOU_PREVIEW',
);
const act0AcademySettingsPreviewV1 = bool.fromEnvironment(
  'SHARKY_ACADEMY_SETTINGS_PREVIEW',
);

bool act0AcademyRuntimeEnabledV1(BuildContext context, Act0ShellTabV1 tab) =>
    act0AcademyLeafSupportsLocaleV1(Localizations.localeOf(context)) &&
    switch (tab) {
      Act0ShellTabV1.home => act0AcademyHomePreviewV1,
      Act0ShellTabV1.play => act0AcademyPracticePreviewV1,
      Act0ShellTabV1.review => act0AcademyReviewPreviewV1,
      Act0ShellTabV1.profile => act0AcademyYouPreviewV1,
      _ => false,
    };

VoidCallback? _guard(bool Function() isCurrent, VoidCallback? action) =>
    action == null
    ? null
    : () {
        if (isCurrent()) action();
      };
ValueChanged<T>? _guardValue<T>(
  bool Function() isCurrent,
  ValueChanged<T>? action,
) => action == null
    ? null
    : (value) {
        if (isCurrent()) action(value);
      };

const _backdrop = AssetImage(act0AcademyLeafLoungeBackdropAssetV1);

Widget act0AcademyHomeRuntimeV1(
  BuildContext context, {
  required Act0HomeShellV1 legacy,
  required bool Function() isCurrent,
  required String courseTitle,
  required int earnedLessons,
  required int totalLessons,
  required Act0AcademyHomePhaseV1? phase,
}) {
  if (!act0AcademyRuntimeEnabledV1(context, Act0ShellTabV1.home)) return legacy;
  final lesson = legacy.currentLesson ?? legacy.state.currentLesson;
  return Act0AcademyHomeLeafV1(
    input: Act0AcademyHomeLeafInputV1(
      courseTitle: courseTitle,
      streakDays: legacy.state.streakDays,
      mood: (legacy.sharkyOverride ?? lesson.runner.sharky).preSessionMood,
      earnedLessonCount: earnedLessons,
      courseLessonCount: totalLessons,
      phase: phase,
      nextAction: Act0AcademyHomeNextActionV1(
        title: legacy.nextActionTitle ?? lesson.title,
        subtitle: legacy.nextActionSubtitle ?? lesson.subtitle,
        ctaLabel: legacy.nextActionCtaLabel,
        onPressed: _guard(isCurrent, legacy.onContinue)!,
      ),
      backdrop: _backdrop,
      onOpenDevMenu: _guard(isCurrent, legacy.onOpenDevMenu),
    ),
  );
}

Widget act0AcademyPracticeRuntimeV1(
  BuildContext context, {
  required Act0PlayShellV1 legacy,
  required bool Function() isCurrent,
}) {
  if (!act0AcademyRuntimeEnabledV1(context, Act0ShellTabV1.play)) return legacy;
  return Act0AcademyPracticeLeafV1(
    input: Act0AcademyPracticeLeafInputV1(
      groups: legacy.groups,
      recommendedGroupId: legacy.recommendedGroupId,
      recommendedTitle: legacy.recommendedTitle,
      recommendedSubtitle: legacy.recommendedSubtitle,
      recommendedReasonLabel: legacy.recommendedReasonLabel,
      repairQueue: legacy.repairQueueConsumer,
      onStartGroup: _guardValue(isCurrent, legacy.onStartGroup)!,
      onLaunchRepair: _guardValue(isCurrent, legacy.onLaunchRepairQueueTarget),
      completionTitle: legacy.completionTitle,
      completionBody: legacy.completionBody,
      backdrop: _backdrop,
    ),
  );
}

Widget act0AcademyReviewRuntimeV1(
  BuildContext context, {
  required Act0ReviewShellV1 legacy,
  required bool Function() isCurrent,
}) {
  if (!act0AcademyRuntimeEnabledV1(context, Act0ShellTabV1.review))
    return legacy;
  // Preserve the accepted recommendation selector; chronological list order
  // alone can point at a different source task.
  final selected = act0SelectedDueReviewItemV1(
    legacy.nextStep,
    legacy.dueReviewItems,
  );
  final due = [
    if (selected != null) selected,
    ...legacy.dueReviewItems.where((i) => !identical(i, selected)),
  ];
  return Act0AcademyReviewLeafV1(
    input: Act0AcademyReviewLeafInputV1(
      openMistakes: legacy.review.mistakes,
      pastRepairs: legacy.review.fixedMistakes,
      dueItems: due,
      savedChecks: legacy.sessionDrillRecheckQueueItems
          .map((i) => Act0AcademyReviewSavedCheckV1(checkId: i.jobId))
          .toList(growable: false),
      hasHistory: legacy.mistakeHistoryItems.isNotEmpty,
      onRepairMistake: _guardValue(isCurrent, legacy.onFixMistake),
      onReplayPastRepair: _guardValue(isCurrent, legacy.onReplayFixedMistake),
      onStartDueReview: _guardValue(isCurrent, legacy.onStartDueReview),
      onStartSavedCheck: legacy.onStartSessionDrillRecheck == null
          ? null
          : (check) {
              if (!isCurrent()) return;
              for (final item in legacy.sessionDrillRecheckQueueItems) {
                if (item.jobId == check.checkId) {
                  legacy.onStartSessionDrillRecheck!(item);
                  return;
                }
              }
            },
      onOpenLearn: _guard(isCurrent, legacy.onOpenLearn),
      backdrop: _backdrop,
    ),
  );
}

Widget act0AcademyYouRuntimeV1(
  BuildContext context, {
  required Act0ProfileShellV1 legacy,
  required bool Function() isCurrent,
  required Act0AchievementSeedProjectionV1 earnedProjection,
  required int completedTasks,
  required int openRepairs,
  required int dueReviews,
  required VoidCallback onOpenReview,
  required VoidCallback onOpenLearn,
}) {
  if (!act0AcademyRuntimeEnabledV1(context, Act0ShellTabV1.profile))
    return legacy;
  return Act0AcademyYouLeafV1(
    input: Act0AcademyYouLeafInputV1(
      displayName: legacy.profile.playerName,
      levelLabel: legacy.profile.level,
      xpLine: legacy.profile.xpLine,
      streakDays: legacy.profile.streakDays,
      completedTaskCount: completedTasks,
      earnedMoments: act0AcademyYouEarnedMomentsV1(earnedProjection),
      bankedRepairCount: legacy.crossSessionProof?.totalBankedFixCount ?? 0,
      reinforcedRepairCount: legacy.crossSessionProof?.reinforcedFixCount ?? 0,
      openRepairCount: openRepairs,
      dueReviewCount: dueReviews,
      onOpenReview: _guard(isCurrent, onOpenReview),
      onOpenLearn: _guard(isCurrent, onOpenLearn),
      onRecoveryOptions: _guard(isCurrent, legacy.onRecoveryOptions),
      onOpenSettings: act0AcademySettingsPreviewV1
          ? _guard(
              isCurrent,
              () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => _AcademySettingsRouteV1(
                    onReplayWelcome: _guard(isCurrent, legacy.onReplayWelcome),
                    onRetakePlacement: _guard(
                      isCurrent,
                      legacy.onRetakePlacement,
                    )!,
                    onRecoveryOptions: _guard(
                      isCurrent,
                      legacy.onRecoveryOptions,
                    ),
                  ),
                ),
              ),
            )
          : null,
    ),
  );
}

class _AcademySettingsRouteV1 extends StatefulWidget {
  const _AcademySettingsRouteV1({
    this.onReplayWelcome,
    required this.onRetakePlacement,
    this.onRecoveryOptions,
  });
  final VoidCallback? onReplayWelcome;
  final VoidCallback onRetakePlacement;
  final VoidCallback? onRecoveryOptions;
  @override
  State<_AcademySettingsRouteV1> createState() =>
      _AcademySettingsRouteV1State();
}

class _AcademySettingsRouteV1State extends State<_AcademySettingsRouteV1> {
  var _loadState = Act0AcademySettingsLoadStateV1.loading;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loadState = Act0AcademySettingsLoadStateV1.loading);
    try {
      await AppSettingsService.instance.load();
      if (mounted)
        setState(() => _loadState = Act0AcademySettingsLoadStateV1.ready);
    } catch (_) {
      if (mounted)
        setState(() => _loadState = Act0AcademySettingsLoadStateV1.failed);
    }
  }

  void _returnToShell(VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<AppSettingsSnapshot>(
    valueListenable: AppSettingsService.instance.changes,
    builder: (context, saved, _) => Scaffold(
      backgroundColor: Act0AcademyLeafPaletteV1.ink,
      body: SafeArea(
        child: Act0AcademySettingsLeafV1(
          input: Act0AcademySettingsLeafInputV1(
            loadState: _loadState,
            hapticsEnabled: saved.hapticsEnabled,
            onHapticsChanged: AppSettingsService.instance.setHapticsEnabled,
            // Sound is withheld until actual audibility is verified on this build.
            onRetryLoad: _load,
            onBack: () => Navigator.of(context).pop(),
            onReplayWelcome: widget.onReplayWelcome == null
                ? null
                : () => _returnToShell(widget.onReplayWelcome!),
            onRetakePlacement: () => _returnToShell(widget.onRetakePlacement),
            onRecoveryOptions: widget.onRecoveryOptions == null
                ? null
                : () => _returnToShell(widget.onRecoveryOptions!),
            onOpenPrivacy: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => const PrivacyScreen()),
            ),
            onOpenTerms: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => const TermsScreen()),
            ),
          ),
        ),
      ),
    ),
  );
}
