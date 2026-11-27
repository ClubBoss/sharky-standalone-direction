import 'skin/act0_skin_tokens_v1.dart';
import 'skin/act0_skin_components_v1.dart';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:poker_analyzer/ui/settings/privacy_terms.dart';
import 'act0_achievement_seed_projection_v1.dart';
import 'act0_beta_metrics_dialog_v1.dart';
import 'act0_release_support_v1.dart';
import 'act0_beta_metrics_v1.dart';
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
import 'act0_settings_view_model_v1.dart';
import 'academy_leaves/act0_academy_you_leaf_v1.dart';
import 'act0_w14_skill_state_v1.dart';
import 'act0_skill_progress_v1.dart';
import 'act0_leak_dashboard_v1.dart';
import 'act0_w1_rules_check_v1.dart';
import 'act0_practice_reminder_v1.dart';

// Owner-restored green presentation; explicit false keeps independent rollback.
// These adapt the current shell's resolved
// inputs/callbacks, never the historical donor's runtime or persistence.
const act0AcademyHomePreviewV1 = bool.fromEnvironment(
  'SHARKY_ACADEMY_HOME_PREVIEW',
  defaultValue: true,
);
const act0AcademyPracticePreviewV1 = bool.fromEnvironment(
  'SHARKY_ACADEMY_PRACTICE_PREVIEW',
  defaultValue: true,
);
const act0AcademyReviewPreviewV1 = bool.fromEnvironment(
  'SHARKY_ACADEMY_REVIEW_PREVIEW',
  defaultValue: true,
);
const act0AcademyYouPreviewV1 = bool.fromEnvironment(
  'SHARKY_ACADEMY_YOU_PREVIEW',
  defaultValue: true,
);
const act0AcademySettingsPreviewV1 = bool.fromEnvironment(
  'SHARKY_ACADEMY_SETTINGS_PREVIEW',
  defaultValue: true,
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

Widget act0AcademyHomeRuntimeV1(
  BuildContext context, {
  required Act0HomeShellV1 legacy,
  required bool Function() isCurrent,
  required String courseTitle,
  required int earnedLessons,
  required int totalLessons,
  required Act0AcademyHomePhaseV1? phase,
  Act0AcademyHomeNextActionV1? dailyAction,
  bool? dayGoalDone,
  bool returningAfterBreak = false,
  VoidCallback? onSkipRefresh,
  String? resumeLabel,
  VoidCallback? onResumeLesson,
}) {
  if (!act0AcademyRuntimeEnabledV1(context, Act0ShellTabV1.home)) return legacy;
  final lesson = legacy.currentLesson ?? legacy.state.currentLesson;
  return Act0AcademyHomeLeafV1(
    input: Act0AcademyHomeLeafInputV1(
      courseTitle: courseTitle,
      goalRoute: legacy.goalRoute,
      streakDays: 0,
      mood: (legacy.sharkyOverride ?? lesson.runner.sharky).preSessionMood,
      earnedLessonCount: earnedLessons,
      courseLessonCount: totalLessons,
      phase: phase,
      nextAction:
          dailyAction ??
          Act0AcademyHomeNextActionV1(
            title: legacy.nextActionTitle ?? lesson.title,
            subtitle:
                legacy.personalizedReturnReasonLine?.trim().isNotEmpty == true
                ? legacy.personalizedReturnReasonLine!.trim()
                : legacy.nextActionSubtitle ?? lesson.subtitle,
            ctaLabel: legacy.nextActionCtaLabel,
            onPressed: _guard(isCurrent, legacy.onContinue)!,
          ),
      onOpenDevMenu: _guard(isCurrent, legacy.onOpenDevMenu),
      onStartWarmup: _guard(isCurrent, legacy.onStartWarmup),
      onStartDailyPractice: dayGoalDone == null
          ? _guard(isCurrent, legacy.onStartDailyDrill)
          : null,
      dayGoalDone: dayGoalDone,
      returningAfterBreak: returningAfterBreak,
      onSkipRefresh: _guard(isCurrent, onSkipRefresh),
      resumeLabel: resumeLabel,
      onResumeLesson: _guard(isCurrent, onResumeLesson),
    ),
  );
}

Widget act0AcademyPracticeRuntimeV1(
  BuildContext context, {
  required Act0PlayShellV1 legacy,
  Act0AcademyHomeNextActionV1? nextAction,
  VoidCallback? onOpenReview,
  required bool Function() isCurrent,
}) {
  if (!act0AcademyRuntimeEnabledV1(context, Act0ShellTabV1.play)) return legacy;
  return Act0AcademyPracticeLeafV1(
    input: Act0AcademyPracticeLeafInputV1(
      groups: legacy.groups,
      nextAction: nextAction,
      onOpenReview: _guard(isCurrent, onOpenReview),
      recommendedGroupId: legacy.recommendedGroupId,
      recommendedTitle: legacy.recommendedTitle,
      recommendedSubtitle: legacy.recommendedSubtitle,
      recommendedReasonLabel: legacy.recommendedReasonLabel,
      repairQueue: legacy.repairQueueConsumer,
      onStartGroup: _guardValue(isCurrent, legacy.onStartGroup)!,
      onLaunchRepair: _guardValue(isCurrent, legacy.onLaunchRepairQueueTarget),
      completionTitle: legacy.completionTitle,
      completionBody: legacy.completionBody,
    ),
  );
}

Widget act0AcademyReviewRuntimeV1(
  BuildContext context, {
  required Act0ReviewShellV1 legacy,
  Act0AcademyHomeNextActionV1? nextAction,
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
      nextAction: nextAction,
      openMistakes: legacy.review.mistakes,
      repeatedMistake: legacy.repeatedMistake,
      leakDashboard: legacy.leakDashboard,
      pastRepairs: legacy.review.fixedMistakes,
      dueItems: due,
      savedChecks: legacy.sessionDrillRecheckQueueItems
          .map((i) => Act0AcademyReviewSavedCheckV1(checkId: i.jobId))
          .toList(growable: false),
      hasHistory: legacy.mistakeHistoryItems.isNotEmpty,
      reasonRepairs: legacy.reasonRepairs,
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
      nextStep: nextAction == null ? legacy.nextStep : null,
      onOpenRecommendedAction: _guard(
        isCurrent,
        legacy.onOpenRecommendedAction,
      ),
      onOpenLearn: _guard(isCurrent, legacy.onOpenLearn),
      onOpenAttempts: _guard(isCurrent, legacy.onOpenAttempts),
      onOpenOwnHands: _guard(isCurrent, legacy.onOpenOwnHands),
    ),
  );
}

Widget act0AcademyYouRuntimeV1(
  BuildContext context, {
  required List<Act0WorldCardV1> worlds,
  required int independentAnswers,
  required int repairedAnswers,
  List<Act0W14SkillStateV1> skills = const [],
  List<Act0SkillProgressV1> skillProgress = const [],
  Map<String, VoidCallback> skillPractice = const {},
  Act0LeakDashboardV1 Function()? openLeakDashboard,
  bool passedW1RulesCheck = false,
  VoidCallback? onW1RulesCheck,
  required Act0ProfileShellV1 legacy,
  Act0BetaLearningMetricsV1 Function()? betaLearningMetrics,
  DateTime Function()? nowUtc,
  VoidCallback? onDeleteLocalData,
  required bool Function() isCurrent,
  required Act0AchievementSeedProjectionV1 earnedProjection,
  required int completedTasks,
  required int practiceDaysLastWeek,
  required int openRepairs,
  required int dueReviews,
  required VoidCallback onOpenReview,
  required VoidCallback onOpenLearn,
}) {
  if (!act0AcademyRuntimeEnabledV1(context, Act0ShellTabV1.profile))
    return legacy;
  return Act0AcademyYouLeafV1(
    input: Act0AcademyYouLeafInputV1(
      worlds: worlds,
      independentAnswers: independentAnswers,
      repairedAnswers: repairedAnswers,
      skills: skills,
      skillProgress: skillProgress,
      skillPractice: {
        for (final entry in skillPractice.entries)
          entry.key: _guard(isCurrent, entry.value)!,
      },
      openLeakDashboard: openLeakDashboard == null
          ? null
          : () => isCurrent() ? openLeakDashboard() : null,
      checkedW1Topics: passedW1RulesCheck
          ? act0W1RulesQuestionsV1
                .map((question) => question.topic)
                .toSet()
                .toList()
          : const <String>[],
      displayName: legacy.profile.playerName,
      levelLabel: legacy.profile.level,
      xpLine: legacy.profile.xpLine,
      practiceDaysLastWeek: practiceDaysLastWeek,
      completedTaskCount: completedTasks,
      learningRecord: legacy.learningRecord,
      onOpenPractice: _guard(isCurrent, legacy.onOpenPractice),
      earnedMoments: act0AcademyYouEarnedMomentsV1(earnedProjection),
      bankedRepairCount: legacy.crossSessionProof?.totalBankedFixCount ?? 0,
      reinforcedRepairCount: legacy.crossSessionProof?.reinforcedFixCount ?? 0,
      openRepairCount: openRepairs,
      dueReviewCount: dueReviews,
      onOpenReview: _guard(isCurrent, onOpenReview),
      onOpenLearn: _guard(isCurrent, onOpenLearn),
      onOpenSettings: act0AcademySettingsPreviewV1
          ? _guard(
              isCurrent,
              () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => _AcademySettingsRouteV1(
                    onOpenBetaMetrics:
                        betaLearningMetrics == null || nowUtc == null
                        ? null
                        : (routeContext) {
                            if (!isCurrent()) return;
                            showDialog<void>(
                              context: routeContext,
                              animationStyle:
                                  MediaQuery.disableAnimationsOf(routeContext)
                                  ? AnimationStyle.noAnimation
                                  : null,
                              builder: (_) => Act0BetaMetricsDialogV1(
                                learning: betaLearningMetrics(),
                                nowUtc: nowUtc,
                              ),
                            );
                          },
                    onDeleteLocalData: _guard(isCurrent, onDeleteLocalData),
                    onReplayWelcome: _guard(isCurrent, legacy.onReplayWelcome),
                    onW1RulesCheck: _guard(isCurrent, onW1RulesCheck),
                    onRetakePlacement: _guard(
                      isCurrent,
                      legacy.onRetakePlacement,
                    ),
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
    this.onW1RulesCheck,
    required this.onRetakePlacement,
    this.onRecoveryOptions,
    this.onDeleteLocalData,
    this.onOpenBetaMetrics,
  });
  final VoidCallback? onReplayWelcome;
  final VoidCallback? onW1RulesCheck;
  final VoidCallback? onRetakePlacement;
  final VoidCallback? onRecoveryOptions;
  final VoidCallback? onDeleteLocalData;
  final void Function(BuildContext)? onOpenBetaMetrics;
  @override
  State<_AcademySettingsRouteV1> createState() =>
      _AcademySettingsRouteV1State();
}

class _AcademySettingsRouteV1State extends State<_AcademySettingsRouteV1>
    with WidgetsBindingObserver {
  var _loadState = Act0AcademySettingsLoadStateV1.loading;
  bool _savingReminder = false;
  bool _reminderPermissionDenied = false;
  int _permissionRequest = 0;
  late final _version = Act0ReleaseSupportV1.version();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _refreshReminderPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshReminderPermission();
  }

  Future<void> _refreshReminderPermission() async {
    final request = ++_permissionRequest;
    try {
      final denied = await Act0PracticeReminderV1.permissionDenied();
      if (mounted && request == _permissionRequest) {
        setState(() => _reminderPermissionDenied = denied);
      }
    } catch (_) {
      // An unavailable platform channel does not establish a denial.
    }
  }

  Future<void> _load() async {
    setState(() => _loadState = Act0AcademySettingsLoadStateV1.loading);
    try {
      await AppSettingsService.instance.load();
      try {
        await Act0PracticeReminderV1.refreshTime();
      } catch (_) {
        // The platform may be unavailable; keep the default time.
      }
      if (mounted)
        setState(() => _loadState = Act0AcademySettingsLoadStateV1.ready);
    } catch (_) {
      if (mounted)
        setState(() => _loadState = Act0AcademySettingsLoadStateV1.failed);
    }
  }

  Future<void> _setPracticeReminder(bool enabled) async {
    setState(() => _savingReminder = true);
    try {
      await Act0PracticeReminderV1.setEnabled(enabled);
      if (mounted) await _refreshReminderPermission();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The reminder could not be updated. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingReminder = false);
    }
  }

  Future<void> _pickReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: Act0PracticeReminderV1.time.value,
      builder: (_, child) =>
          Act0SkinDarkAreaV1(paintBackground: false, child: child!),
    );
    if (!mounted || selected == null) return;
    setState(() => _savingReminder = true);
    try {
      await Act0PracticeReminderV1.setTime(selected);
      if (mounted) await _refreshReminderPermission();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The reminder time could not be saved.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingReminder = false);
    }
  }

  void _returnToShell(VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      AppSettingsService.instance.changes,
      Act0PracticeReminderV1.enabled,
      Act0PracticeReminderV1.time,
    ]),
    builder: (context, _) {
      final view = Act0SettingsViewModelV1(
        loadState: _loadState,
        version: _version,
        hapticsEnabled:
            AppSettingsService.instance.changes.value.hapticsEnabled,
        reminderSupported: Act0PracticeReminderV1.isSupported,
        reminderEnabled: Act0PracticeReminderV1.enabled.value,
        savingReminder: _savingReminder,
      );
      return Scaffold(
        backgroundColor: Act0SkinTokensV1.background,
        body: SafeArea(
          child: Act0AcademySettingsLeafV1(
            input: Act0AcademySettingsLeafInputV1(
              loadState: view.loadState,
              version: view.version,
              hapticsEnabled: view.hapticsEnabled,
              practiceReminderEnabled: view.practiceReminderEnabled,
              reminderPermissionDenied: _reminderPermissionDenied,
              reminderTime: Act0PracticeReminderV1.time.value.format(context),
              onPickReminderTime: view.canChangeReminder
                  ? _pickReminderTime
                  : null,
              onPracticeReminderChanged: view.canChangeReminder
                  ? _setPracticeReminder
                  : null,
              onHapticsChanged: (value) async {
                try {
                  await AppSettingsService.instance.setHapticsEnabled(value);
                } catch (_) {
                  if (context.mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preference was not saved. Try again.'),
                      ),
                    );
                }
              },
              // Sound is withheld until actual audibility is verified on this build.
              onRetryLoad: _load,
              onOpenBetaMetrics: widget.onOpenBetaMetrics == null
                  ? null
                  : () => widget.onOpenBetaMetrics!(context),
              onOpenSupport: widget.onOpenBetaMetrics != null
                  ? null
                  : () => showDialog<void>(
                      context: context,
                      animationStyle: MediaQuery.disableAnimationsOf(context)
                          ? AnimationStyle.noAnimation
                          : null,
                      builder: (_) => Act0BetaMetricsDialogV1(
                        learning: null,
                        nowUtc: DateTime.now,
                      ),
                    ),
              onBack: () => Navigator.of(context).pop(),
              onReplayWelcome: widget.onReplayWelcome == null
                  ? null
                  : () => _returnToShell(widget.onReplayWelcome!),
              onW1RulesCheck: widget.onW1RulesCheck == null
                  ? null
                  : () => _returnToShell(widget.onW1RulesCheck!),
              onRetakePlacement: widget.onRetakePlacement == null
                  ? null
                  : () => _returnToShell(widget.onRetakePlacement!),
              onRecoveryOptions: widget.onRecoveryOptions == null
                  ? null
                  : () => _returnToShell(widget.onRecoveryOptions!),
              onDeleteLocalData: widget.onDeleteLocalData == null
                  ? null
                  : () => _returnToShell(widget.onDeleteLocalData!),
              onOpenPrivacy: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              ),
              onOpenTerms: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              ),
            ),
          ),
        ),
      );
    },
  );
}
