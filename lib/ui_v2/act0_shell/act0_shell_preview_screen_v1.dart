import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/onboarding/onboarding_preferences_service.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';

enum _Act0LearningNextActionKindV1 {
  repairDeepLeak,
  repairWeakSpot,
  reviewQuickFix,
  continueLesson,
  dailyDrill,
  categoryPractice,
  dailyDone,
}

class _Act0LearningRecommendationV1 {
  const _Act0LearningRecommendationV1({
    required this.kind,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.hint,
    required this.outcome,
    this.mistake,
    this.lessonId,
    this.taskId,
    this.practiceGroupId,
  });

  final _Act0LearningNextActionKindV1 kind;
  final String label;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String hint;
  final String outcome;
  final Act0MistakeCardV1? mistake;
  final String? lessonId;
  final String? taskId;
  final String? practiceGroupId;
}

class Act0ShellPreviewScreenV1 extends StatefulWidget {
  const Act0ShellPreviewScreenV1({
    super.key,
    this.initialTab = Act0ShellTabV1.home,
    this.initialPhase = Act0LessonPhaseV1.theory,
    this.state,
    this.showPlacementOnStart = true,
    // Dev2 is now the canonical detached Act0 shell. The classic variant stays
    // available for explicit fallback comparisons.
    this.tableVisualVariant = Act0ShellTableVisualVariantV1.refinedDev2,
  });

  final Act0ShellTabV1 initialTab;
  final Act0LessonPhaseV1 initialPhase;
  final Act0ShellStateV1? state;
  final bool showPlacementOnStart;
  final Act0ShellTableVisualVariantV1 tableVisualVariant;

  @override
  State<Act0ShellPreviewScreenV1> createState() =>
      _Act0ShellPreviewScreenV1State();
}

class _Act0ShellPreviewScreenV1State extends State<Act0ShellPreviewScreenV1> {
  static const String _progressPrefsKey = 'act0_shell_progress_v1';
  static const int _homeHandoffDismissDays = 7;

  late Act0ShellTabV1 _tab;
  late Act0LessonPhaseV1 _phase;
  late String _selectedWorldId;
  late String _selectedLessonId;
  late String _selectedTaskId;
  String? _learnPopupTaskId;
  late Set<String> _completedLessonIds;
  late Set<String> _completedTaskIds;
  final Set<String> _skippedTaskIds = <String>{};
  final Set<String> _visibleSkippedTaskIds = <String>{};
  bool _showWorldMenu = false;
  String? _learnDetailWorldId;
  String? _learnDetailLessonId;
  String? _selectedOptionId;
  String? _reviewConfidence;
  int _teachingStepIndex = 0;
  int _earnedXp = 0;
  int _lessonRunXp = 0;
  bool _showPlayHub = true;
  bool _returnToPlayHubOnBack = false;
  final Map<String, _Act0MistakeRecordV1> _mistakeRecords =
      <String, _Act0MistakeRecordV1>{};
  final Set<String> _resolvedMistakeTaskIds = <String>{};
  final Set<String> _cleanTaskIds = <String>{};
  final Set<String> _lessonRunMistakeTaskIds = <String>{};
  final Set<String> _lessonRunPendingRetryTaskIds = <String>{};
  final Set<String> _lessonRunRetriedTaskIds = <String>{};
  final Set<String> _lessonRunQuickFixTaskIds = <String>{};
  final Set<String> _lessonRunDeepLeakTaskIds = <String>{};
  final Set<String> _dailyCompletedTaskIds = <String>{};
  int _persistedStreakDays = 0;
  String _lastDailyDate = '';
  String? _activePracticeGroupId;
  String? _activeRepairTaskId;
  Act0BlockCompletionSummaryV1? _blockCompletionSummary;
  bool _showPlacement = false;
  bool _placementDiagnosticActive = false;
  bool _placementIntroVisible = true;
  bool _placementTrialPreviewSelected = false;
  int _placementQuestionIndex = 0;
  int _placementDiagnosticIndex = 0;
  int _placementDiagnosticCorrect = 0;
  bool _placementHandoffActive = false;
  final Map<String, Set<String>> _placementAnswerIds = <String, Set<String>>{};
  final Map<String, int> _profileSkillValues = <String, int>{};
  final List<Act0SkillGainV1> _recentSkillGains = <Act0SkillGainV1>[];
  Act0PlacementResultV1? _placementResult;
  int _progressPersistGeneration = 0;
  String _dismissedHomeHandoffKey = '';
  String _dismissedHomeHandoffDay = '';
  int _learnLessonOpenSequenceV1 = 0;
  String? _learnPendingAutoOpenLessonIdV1;

  Set<String> get _pathClosedTaskIds => <String>{
    ..._completedTaskIds,
    ..._skippedTaskIds,
  };

  bool get _usesPersistedProgress => widget.state == null;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _phase = widget.initialPhase;
    _showPlacement = widget.showPlacementOnStart;
    _showPlayHub = widget.initialTab != Act0ShellTabV1.play;
    final state = widget.state ?? Act0ShellStateV1.sample;
    _selectedWorldId = state.selectedWorldId;
    _selectedLessonId = state.currentLesson.lessonId;
    _completedLessonIds = {
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          if (lesson.state == Act0LessonStateV1.completed) lesson.lessonId,
    };
    _completedTaskIds = {
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          if (lesson.state == Act0LessonStateV1.completed)
            for (final task in lesson.taskList) task.taskId,
    };
    _selectedTaskId = _firstIncompleteTask(state.currentLesson).taskId;
    _learnPopupTaskId = null;
    _resetLessonRunMetrics();
    if (_usesPersistedProgress) {
      unawaited(_restorePersistedProgress());
    }
  }

  @override
  void dispose() {
    _learnLessonOpenSequenceV1++;
    _persistProgress();
    super.dispose();
  }

  bool _handleLearnLessonSelectV1({
    required Act0LessonCardV1 lesson,
    required String lessonId,
  }) {
    if (_learnDetailLessonId == lessonId) {
      setState(() {
        _learnDetailLessonId = null;
        _learnPopupTaskId = null;
        _learnPendingAutoOpenLessonIdV1 = null;
      });
      return false;
    }
    _learnLessonOpenSequenceV1++;
    setState(() {
      if (lesson.isSelectable) {
        _selectedLessonId = lessonId;
        _selectedTaskId = _firstIncompleteTask(lesson).taskId;
        _learnPopupTaskId = null;
        _teachingStepIndex = 0;
        _resetLessonRunMetrics();
      }
      // Phase 1: collapse previous expanded block before scrolling to target.
      _learnDetailLessonId = null;
      _learnDetailWorldId = null;
      _learnPendingAutoOpenLessonIdV1 = lessonId;
    });
    return true;
  }

  void _handleLearnLessonOpenAfterScrollV1(String lessonId) {
    if (!mounted || _learnPendingAutoOpenLessonIdV1 != lessonId) {
      return;
    }
    setState(() {
      // Phase 2: open only after child reports scroll settled at target.
      _learnDetailLessonId = lessonId;
      _learnPendingAutoOpenLessonIdV1 = null;
    });
  }

  Future<void> _restorePersistedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressPrefsKey);
    if (raw == null || raw.isEmpty || !mounted) {
      return;
    }
    final parsed = _Act0PersistedProgressV1.tryParse(raw);
    if (parsed == null) {
      return;
    }
    final state = widget.state ?? Act0ShellStateV1.sample;
    final validTaskIds = <String>{
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          for (final task in lesson.taskList) task.taskId,
    };
    final validLessonIds = <String>{
      for (final world in state.worlds)
        for (final lesson in world.lessons) lesson.lessonId,
    };
    final completedTaskIds = parsed.completedTaskIds
        .where(validTaskIds.contains)
        .toSet();
    final skippedTaskIds = parsed.skippedTaskIds
        .where(validTaskIds.contains)
        .toSet();
    final completedLessonIds = parsed.completedLessonIds
        .where(validLessonIds.contains)
        .toSet();
    final closedTaskIds = <String>{...completedTaskIds, ...skippedTaskIds};
    final worldsAfterProgress = _progressWorldsWithTaskIds(
      state,
      closedTaskIds,
    );
    final persistedWorld = _worldById(
      worldsAfterProgress,
      worldsAfterProgress.any(
            (world) => world.worldId == parsed.selectedWorldId,
          )
          ? parsed.selectedWorldId
          : state.selectedWorldId,
    );
    final selectedWorld = persistedWorld.status == Act0WorldStateV1.current
        ? persistedWorld
        : worldsAfterProgress.firstWhere(
            (world) =>
                world.status == Act0WorldStateV1.current && world.isSelectable,
            orElse: () => persistedWorld,
          );
    final persistedLesson =
        selectedWorld.lessons.any(
          (lesson) => lesson.lessonId == parsed.selectedLessonId,
        )
        ? _lessonById(selectedWorld.lessons, parsed.selectedLessonId)
        : null;
    final selectedLesson =
        persistedLesson != null &&
            !_lessonCompleteWithTaskIds(persistedLesson, closedTaskIds)
        ? persistedLesson
        : _firstPlayableLesson(selectedWorld);
    final selectedTask =
        selectedLesson.taskList.any(
              (task) => task.taskId == parsed.selectedTaskId,
            ) &&
            !closedTaskIds.contains(parsed.selectedTaskId)
        ? _taskByIdWithTaskIds(
            selectedLesson,
            parsed.selectedTaskId,
            closedTaskIds,
          )
        : _firstIncompleteTaskWithTaskIds(selectedLesson, closedTaskIds);
    final resumeInRunner =
        parsed.resumeInRunner && !widget.showPlacementOnStart;
    final restoredSelectedOptionId =
        parsed.resumeSelectedOptionId != null &&
            selectedTask.runner.options.any(
              (option) => option.id == parsed.resumeSelectedOptionId,
            )
        ? parsed.resumeSelectedOptionId
        : null;
    final restoredPhase =
        _phaseFromStorage(parsed.resumePhase) ?? selectedTask.phase;
    final effectivePhase =
        restoredPhase == Act0LessonPhaseV1.review &&
            restoredSelectedOptionId == null
        ? Act0LessonPhaseV1.drill
        : restoredPhase;
    final restoredTeachingStepIndex = resumeInRunner
        ? parsed.resumeTeachingStepIndex.clamp(
            0,
            selectedTask.runner.teachingSteps.length,
          )
        : 0;

    if (!mounted) {
      return;
    }
    final today = _todayDateString();
    final isNewDay = parsed.lastActiveDay != today;
    final isStreakContinued =
        !isNewDay || _isConsecutiveDay(parsed.lastActiveDay, today);
    final restoredStreakDays = isNewDay
        ? (isStreakContinued && parsed.lastActiveDay.isNotEmpty
              ? parsed.persistedStreakDays
              : 0)
        : parsed.persistedStreakDays;
    setState(() {
      _completedTaskIds = completedTaskIds;
      _completedLessonIds = completedLessonIds;
      _skippedTaskIds
        ..clear()
        ..addAll(skippedTaskIds);
      _visibleSkippedTaskIds
        ..clear()
        ..addAll(skippedTaskIds);
      _earnedXp = parsed.earnedXp;
      _selectedWorldId = selectedWorld.worldId;
      _selectedLessonId = selectedLesson.lessonId;
      _selectedTaskId = selectedTask.taskId;
      _phase = resumeInRunner ? effectivePhase : selectedTask.phase;
      _selectedOptionId =
          resumeInRunner && effectivePhase == Act0LessonPhaseV1.review
          ? restoredSelectedOptionId
          : null;
      _teachingStepIndex = restoredTeachingStepIndex;
      _tab = resumeInRunner ? Act0ShellTabV1.play : widget.initialTab;
      _showPlayHub = !resumeInRunner;
      _blockCompletionSummary = null;
      _persistedStreakDays = restoredStreakDays;
      _lastDailyDate = isNewDay ? today : parsed.lastActiveDay;
      _dismissedHomeHandoffKey = parsed.dismissedHomeHandoffKey;
      _dismissedHomeHandoffDay = parsed.dismissedHomeHandoffDay;
      // Daily deck resets on new day
      if (isNewDay) {
        _dailyCompletedTaskIds.clear();
      }
    });
  }

  static String _todayDateString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  static bool _isConsecutiveDay(String prevDay, String today) {
    if (prevDay.isEmpty) return false;
    try {
      final prev = DateTime.parse(prevDay);
      final todayDate = DateTime.parse(today);
      final diff = todayDate.difference(prev).inDays;
      return diff == 1;
    } catch (_) {
      return false;
    }
  }

  static Act0LessonPhaseV1? _phaseFromStorage(String raw) {
    switch (raw) {
      case 'theory':
        return Act0LessonPhaseV1.theory;
      case 'drill':
        return Act0LessonPhaseV1.drill;
      case 'review':
        return Act0LessonPhaseV1.review;
      default:
        return null;
    }
  }

  void _persistProgress() {
    if (!_usesPersistedProgress) {
      return;
    }
    final today = _todayDateString();
    final dailyDone = _dailyCompletedTaskIds.length >= 3;
    final currentStreak = dailyDone
        ? (_lastDailyDate == today
              ? _persistedStreakDays
              : (_isConsecutiveDay(_lastDailyDate, today)
                    ? (_persistedStreakDays + 1).clamp(0, 365)
                    : 1))
        : _persistedStreakDays;
    final snapshot = _Act0PersistedProgressV1(
      completedTaskIds: _completedTaskIds,
      skippedTaskIds: _skippedTaskIds,
      completedLessonIds: _completedLessonIds,
      selectedWorldId: _selectedWorldId,
      selectedLessonId: _selectedLessonId,
      selectedTaskId: _selectedTaskId,
      earnedXp: _earnedXp,
      lastActiveDay: today,
      persistedStreakDays: currentStreak,
      resumeInRunner:
          _tab == Act0ShellTabV1.play &&
          !_showPlayHub &&
          _blockCompletionSummary == null &&
          !_showPlacement,
      resumePhase: _phase.name,
      resumeTeachingStepIndex: _teachingStepIndex,
      resumeSelectedOptionId: _selectedOptionId,
      dismissedHomeHandoffKey: _dismissedHomeHandoffKey,
      dismissedHomeHandoffDay: _dismissedHomeHandoffDay,
    );
    final generation = ++_progressPersistGeneration;
    unawaited(_writePersistedProgress(snapshot, generation));
  }

  Future<void> _writePersistedProgress(
    _Act0PersistedProgressV1 snapshot,
    int generation,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (generation != _progressPersistGeneration) {
      return;
    }
    await prefs.setString(_progressPrefsKey, snapshot.toStorageString());
  }

  Future<void> _invalidatePersistedProgressWrites() async {
    if (!_usesPersistedProgress) {
      return;
    }
    _progressPersistGeneration += 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressPrefsKey);
  }

  void _restorePreviewToFreshStart({
    bool showPlacement = true,
    Act0ShellTabV1 tab = Act0ShellTabV1.home,
  }) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final completedLessonIds = <String>{
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          if (lesson.state == Act0LessonStateV1.completed) lesson.lessonId,
    };
    final completedTaskIds = <String>{
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          if (lesson.state == Act0LessonStateV1.completed)
            for (final task in lesson.taskList) task.taskId,
    };
    setState(() {
      _tab = tab;
      _phase = Act0LessonPhaseV1.theory;
      _selectedWorldId = state.selectedWorldId;
      _selectedLessonId = state.currentLesson.lessonId;
      _selectedTaskId = _firstIncompleteTask(state.currentLesson).taskId;
      _learnPopupTaskId = null;
      _completedLessonIds = completedLessonIds;
      _completedTaskIds = completedTaskIds;
      _skippedTaskIds.clear();
      _visibleSkippedTaskIds.clear();
      _showWorldMenu = false;
      _learnDetailWorldId = null;
      _learnDetailLessonId = null;
      _learnPopupTaskId = null;
      _selectedOptionId = null;
      _reviewConfidence = null;
      _teachingStepIndex = 0;
      _earnedXp = 0;
      _lessonRunXp = 0;
      _showPlayHub = tab != Act0ShellTabV1.play;
      _returnToPlayHubOnBack = false;
      _mistakeRecords.clear();
      _resolvedMistakeTaskIds.clear();
      _cleanTaskIds.clear();
      _lessonRunMistakeTaskIds.clear();
      _lessonRunPendingRetryTaskIds.clear();
      _lessonRunRetriedTaskIds.clear();
      _lessonRunQuickFixTaskIds.clear();
      _lessonRunDeepLeakTaskIds.clear();
      _dailyCompletedTaskIds.clear();
      _activePracticeGroupId = null;
      _activeRepairTaskId = null;
      _blockCompletionSummary = null;
      _dismissedHomeHandoffKey = '';
      _dismissedHomeHandoffDay = '';
      _showPlacement = showPlacement;
      _placementDiagnosticActive = false;
      _placementIntroVisible = true;
      _placementTrialPreviewSelected = false;
      _placementQuestionIndex = 0;
      _placementDiagnosticIndex = 0;
      _placementDiagnosticCorrect = 0;
      _placementHandoffActive = false;
      _placementAnswerIds.clear();
      _profileSkillValues.clear();
      _recentSkillGains.clear();
      _placementResult = null;
      _resetLessonRunMetrics();
    });
  }

  void _openDevMapSkippingPlacement() {
    setState(() {
      _showPlacement = false;
      _placementDiagnosticActive = false;
      _placementIntroVisible = false;
      _placementTrialPreviewSelected = false;
      _placementDiagnosticIndex = 0;
      _placementDiagnosticCorrect = 0;
      _tab = Act0ShellTabV1.learn;
      _showPlayHub = true;
      _returnToPlayHubOnBack = false;
      _showWorldMenu = false;
      _learnDetailWorldId = null;
      _learnDetailLessonId = null;
    });
  }

  void _openPlacementFlow() {
    setState(() {
      _showPlacement = true;
      _placementDiagnosticActive = false;
      _placementIntroVisible = true;
      _placementTrialPreviewSelected = false;
      _placementQuestionIndex = 0;
      _placementDiagnosticIndex = 0;
      _placementDiagnosticCorrect = 0;
      _placementHandoffActive = false;
      _placementAnswerIds.clear();
      _profileSkillValues.clear();
      _recentSkillGains.clear();
      _placementResult = null;
      _selectedOptionId = null;
      _phase = Act0LessonPhaseV1.theory;
      _teachingStepIndex = 0;
      _showPlayHub = true;
      _returnToPlayHubOnBack = false;
      _activePracticeGroupId = null;
      _activeRepairTaskId = null;
      _blockCompletionSummary = null;
    });
  }

  void _openDevSurface({required Act0ShellTabV1 tab, bool showPlayHub = true}) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final worlds = _progressWorlds(state);
    _normalizeSelection(worlds);
    final selectedWorld = _worldById(worlds, _selectedWorldId);
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final selectedTask = _taskById(selectedLesson, _selectedTaskId);
    setState(() {
      _showPlacement = false;
      _placementDiagnosticActive = false;
      _placementTrialPreviewSelected = false;
      _tab = tab;
      _showPlayHub = tab == Act0ShellTabV1.play ? showPlayHub : true;
      _returnToPlayHubOnBack = false;
      _blockCompletionSummary = null;
      _activeRepairTaskId = null;
      _selectedOptionId = null;
      _phase = selectedTask.phase;
      _teachingStepIndex = 0;
      if (tab != Act0ShellTabV1.learn) {
        _learnDetailLessonId = null;
        _learnDetailWorldId = null;
        _showWorldMenu = false;
      }
    });
  }

  Future<void> _handleResetAppProgress() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset progress?'),
          content: const Text(
            'This clears app progress and returns the dev shell to Today.',
          ),
          actions: [
            TextButton(
              key: const Key('act0_shell_dev_menu_reset_cancel'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('act0_shell_dev_menu_reset_confirm'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (shouldReset != true || !mounted) {
      return;
    }
    await _invalidatePersistedProgressWrites();
    await ProgressService.debugReset();
    await OnboardingPreferencesService.resetOnboarding();
    if (!mounted) {
      return;
    }
    _restorePreviewToFreshStart(showPlacement: false);
    _persistProgress();
  }

  Future<void> _openDevMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Act0ShellTokensV1.surface,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  key: const Key('act0_shell_dev_menu_reset_progress'),
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: const Text('Reset app progress'),
                  subtitle: const Text('Clear app prefs and return to Today.'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _handleResetAppProgress();
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_placement'),
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Open placement'),
                  subtitle: const Text(
                    'Jump into the placement flow manually.',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openPlacementFlow();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_home'),
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Open Today'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(tab: Act0ShellTabV1.home);
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_map'),
                  leading: const Icon(Icons.map_outlined),
                  title: const Text('Open Learn map'),
                  subtitle: const Text('Jump to Learn and skip placement.'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevMapSkippingPlacement();
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_play_hub'),
                  leading: const Icon(Icons.sports_esports_outlined),
                  title: const Text('Open Play hub'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(
                      tab: Act0ShellTabV1.play,
                      showPlayHub: true,
                    );
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_runner'),
                  leading: const Icon(Icons.play_circle_outline_rounded),
                  title: const Text('Open current runner'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(
                      tab: Act0ShellTabV1.play,
                      showPlayHub: false,
                    );
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_review'),
                  leading: const Icon(Icons.fact_check_outlined),
                  title: const Text('Open Review'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(tab: Act0ShellTabV1.review);
                  },
                ),
                ListTile(
                  key: const Key('act0_shell_dev_menu_open_profile'),
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Open Profile'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openDevSurface(tab: Act0ShellTabV1.profile);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseState = widget.state ?? Act0ShellStateV1.sample;
    final progress = _progressSnapshot(baseState);
    final state = _stateWithProgress(baseState, progress);
    final worlds = _progressWorlds(baseState);
    _normalizeSelection(worlds);
    final selectedWorld = _worldById(worlds, _selectedWorldId);
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final isPlayTab = _tab == Act0ShellTabV1.play;
    final isPlayRunner =
        isPlayTab && !_showPlayHub && _blockCompletionSummary == null;
    final playSelectedTask = isPlayTab
        ? _taskById(selectedLesson, _selectedTaskId)
        : null;
    final playRunner = isPlayRunner
        ? _repairRunnerForTask(playSelectedTask!).copyWith(
            lessonId: selectedLesson.lessonId,
            lessonTitle: selectedLesson.title,
            lessonSubtitle: selectedLesson.subtitle,
            beatIndex: _taskIndex(selectedLesson, playSelectedTask.taskId) + 1,
            beatCount: selectedLesson.taskList.length,
            phase: _phase,
            selectedOptionId: _selectedOptionId,
            teachingStepIndex: _teachingStepIndex,
            nextLessonId: _nextLessonId(
              selectedWorld.lessons,
              selectedLesson.lessonId,
            ),
          )
        : null;
    final completionSummary =
        isPlayRunner &&
            widget.tableVisualVariant ==
                Act0ShellTableVisualVariantV1.refinedDev2
        ? Act0RunnerCompletionSummaryV1(
            xpGain: playSelectedTask!.rewardXp,
            startLevel: progress.level,
            endLevel: _progressSnapshot(
              baseState,
              earnedXpDelta: _earnedXp + playSelectedTask.rewardXp,
            ).level,
            startXp: progress.xp,
            endXp: _progressSnapshot(
              baseState,
              earnedXpDelta: _earnedXp + playSelectedTask.rewardXp,
            ).xp,
            xpTarget: baseState.xpTarget,
          )
        : null;
    final showTopBar =
        !_showPlacement &&
        !(_tab == Act0ShellTabV1.play &&
            widget.tableVisualVariant ==
                Act0ShellTableVisualVariantV1.refinedDev2);
    return Scaffold(
      key: const Key('act0_shell_preview_screen'),
      backgroundColor: Act0ShellTokensV1.background,
      body: SafeArea(
        child: Column(
          children: [
            if (showTopBar)
              _TopBarV1(state: state, goalLabel: _compactDailyLabel()),
            Expanded(
              child: _showPlacement && !_placementDiagnosticActive
                  ? Act0PlacementShellV1(
                      questions: _placementQuestionsV1,
                      showIntro: _placementIntroVisible,
                      currentQuestionIndex: _placementQuestionIndex,
                      selectedOptionIds: _placementAnswerIds,
                      result: _placementResult,
                      trialPreviewSelected: _placementTrialPreviewSelected,
                      onSelectOption: (question, optionId) => setState(() {
                        _togglePlacementOption(question, optionId);
                      }),
                      onStartPlacement: () => setState(() {
                        _placementIntroVisible = false;
                        _placementQuestionIndex = 0;
                      }),
                      onBack: () => setState(() {
                        if (_placementQuestionIndex > 0) {
                          _placementQuestionIndex -= 1;
                        } else {
                          _placementIntroVisible = true;
                        }
                      }),
                      onNext: () => setState(() {
                        _placementIntroVisible = false;
                        if (_placementQuestionIndex <
                            _placementQuestionsV1.length) {
                          _placementQuestionIndex += 1;
                        }
                      }),
                      onStartDiagnostic: () => setState(() {
                        _startPlacementDiagnostic(_progressWorlds(baseState));
                      }),
                      onStartRecommended: () => setState(() {
                        _startPlacementRecommendation(
                          _progressWorlds(baseState),
                          fromZero: false,
                        );
                      }),
                      onStartFromZero: () => setState(() {
                        _startPlacementRecommendation(
                          _progressWorlds(baseState),
                          fromZero: true,
                        );
                      }),
                      onStartTrialPreview: () => setState(() {
                        _placementTrialPreviewSelected = true;
                      }),
                    )
                  : switch (_tab) {
                      Act0ShellTabV1.home => Act0HomeShellV1(
                        state: state,
                        currentLesson: _firstPlayableLesson(selectedWorld),
                        pathProgressLabel: selectedWorld.progressLabel,
                        nextActionLabel: _homeNextActionLabel(),
                        nextActionTitle: _homeNextActionTitle(
                          _firstPlayableLesson(selectedWorld),
                        ),
                        nextActionSubtitle: _homeNextActionSubtitle(
                          _firstPlayableLesson(selectedWorld),
                        ),
                        nextActionCtaLabel: _homeNextActionCtaLabel(),
                        nextActionHint: _homeCtaHint(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        handoffLabel: _homeHandoffLabel(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        handoffHeadline: _homeHandoffHeadline(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        handoffDetail: _homeHandoffDetail(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        handoffOutcome: _homeHandoffOutcome(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        handoffPills: _homeHandoffPills(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        showHandoffPanel: _homeHandoffVisible(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        onDismissHandoff: () => setState(() {
                          _dismissHomeHandoff(
                            selectedWorld,
                            _firstPlayableLesson(selectedWorld),
                          );
                        }),
                        dailyGoalValue: _dailyGoalValueLabel(),
                        dailyGoalCtaLabel: _homeDailyGoalCtaLabel(
                          selectedWorld,
                          _firstPlayableLesson(selectedWorld),
                        ),
                        sharkyOverride: _homeSharkyOverride(),
                        onOpenDevMenu: _openDevMenu,
                        onStartDailyDrill: _dailyCompletedTaskIds.length < 3
                            ? () => setState(() {
                                final recommendation = _learningRecommendation(
                                  selectedWorld: selectedWorld,
                                  selectedLesson: _firstPlayableLesson(
                                    selectedWorld,
                                  ),
                                );
                                final shouldRepairFirst =
                                    recommendation.kind ==
                                        _Act0LearningNextActionKindV1
                                            .repairDeepLeak ||
                                    recommendation.kind ==
                                        _Act0LearningNextActionKindV1
                                            .repairWeakSpot;
                                if (shouldRepairFirst) {
                                  _startRecommendation(
                                    recommendation,
                                    selectedWorld,
                                    returnToPlayHub: false,
                                  );
                                  return;
                                }
                                final world = _worldById(
                                  _progressedWorlds(
                                    widget.state ?? Act0ShellStateV1.sample,
                                  ),
                                  _selectedWorldId,
                                );
                                final baseState =
                                    widget.state ?? Act0ShellStateV1.sample;
                                final lesson = _lessonById(
                                  world.lessons,
                                  _selectedLessonId,
                                );
                                final groups = _practiceGroups(
                                  state: baseState,
                                  world: world,
                                  selectedLesson: lesson,
                                );
                                final dailyGroup = groups.firstWhere(
                                  (g) => g.groupId == 'daily',
                                  orElse: () => groups.first,
                                );
                                _startPracticeGroup(dailyGroup, world);
                                _tab = Act0ShellTabV1.play;
                                _showPlayHub = false;
                              })
                            : null,
                        onContinue: () => setState(() {
                          _startHomeNextAction(selectedWorld);
                        }),
                      ),
                      Act0ShellTabV1.learn => Act0LearnPathShellV1(
                        moduleTitle: selectedWorld.title,
                        moduleProgressLabel: selectedWorld.progressLabel,
                        sharkyGuideTitle: _learnGuideTitle(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        sharkyGuideLine: _learnGuideLine(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        sharkyGuideDetail: _learnGuideDetail(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        sharkyGuideMood: _learnGuideMood(
                          selectedWorld,
                          _lessonById(selectedWorld.lessons, _selectedLessonId),
                        ),
                        worlds: worlds,
                        selectedWorldId: _selectedWorldId,
                        showWorldMenu: _showWorldMenu,
                        worldDetailId: _learnDetailWorldId,
                        lessons: selectedWorld.lessons,
                        selectedLessonId: _selectedLessonId,
                        selectedTaskId: _selectedTaskId,
                        activePopupTaskId: _learnPopupTaskId,
                        completedTaskIds: _completedTaskIds,
                        skippedTaskIds: _visibleSkippedTaskIds,
                        pathClosedTaskIds: _pathClosedTaskIds,
                        detailLessonId: _learnDetailLessonId,
                        lessonOutcomeLabels: _lessonOutcomeLabels(
                          selectedWorld.lessons,
                        ),
                        onSelectWorld: (worldId) {
                          final world = _worldById(worlds, worldId);
                          setState(() {
                            if (world.isSelectable) {
                              _selectedWorldId = worldId;
                              _showWorldMenu = false;
                              _learnDetailWorldId = null;
                              _learnDetailLessonId = null;
                              _learnPopupTaskId = null;
                              if (world.lessons.isNotEmpty &&
                                  !world.lessons.any(
                                    (lesson) =>
                                        lesson.lessonId == _selectedLessonId,
                                  )) {
                                final lesson = _firstPlayableLesson(world);
                                _selectedLessonId = lesson.lessonId;
                                _selectedTaskId = _firstIncompleteTask(
                                  lesson,
                                ).taskId;
                                _teachingStepIndex = 0;
                              }
                            } else {
                              _learnDetailWorldId = worldId;
                              _learnDetailLessonId = null;
                            }
                          });
                        },
                        onOpenWorldMenu: () => setState(() {
                          _showWorldMenu = true;
                          _learnDetailLessonId = null;
                          _learnPopupTaskId = null;
                        }),
                        onCloseWorldMenu: () => setState(() {
                          _showWorldMenu = false;
                          _learnDetailWorldId = null;
                          _learnPopupTaskId = null;
                        }),
                        onDismissWorldDetail: () => setState(() {
                          _learnDetailWorldId = null;
                          _learnPopupTaskId = null;
                        }),
                        onSelectLesson: (lessonId) {
                          final lesson = selectedWorld.lessons
                              .cast<Act0LessonCardV1?>()
                              .firstWhere(
                                (candidate) => candidate?.lessonId == lessonId,
                                orElse: () => null,
                              );
                          if (lesson == null) {
                            return false;
                          }
                          return _handleLearnLessonSelectV1(
                            lesson: lesson,
                            lessonId: lessonId,
                          );
                        },
                        onOpenLessonAfterScroll:
                            _handleLearnLessonOpenAfterScrollV1,
                        onDismissDetail: () => setState(() {
                          _learnDetailLessonId = null;
                          _learnPopupTaskId = null;
                          _learnPendingAutoOpenLessonIdV1 = null;
                        }),
                        onSelectTask: (lessonId, taskId) {
                          final lesson = _lessonById(
                            selectedWorld.lessons,
                            lessonId,
                          );
                          if (!lesson.taskList.any(
                            (task) => task.taskId == taskId,
                          )) {
                            return;
                          }
                          final taskAvailable = _taskAvailable(lesson, taskId);
                          setState(() {
                            if (taskAvailable) {
                              _selectedLessonId = lessonId;
                              _selectedTaskId = taskId;
                              _selectedOptionId = null;
                              _teachingStepIndex = 0;
                              _resetLessonRunMetrics();
                            }
                            _learnPopupTaskId = taskId;
                          });
                        },
                        onDismissTaskPopup: () => setState(() {
                          _learnPopupTaskId = null;
                        }),
                        onStartTask: (lessonId, taskId) {
                          final lesson = _lessonById(
                            selectedWorld.lessons,
                            lessonId,
                          );
                          if (!lesson.isSelectable ||
                              !_taskAvailable(lesson, taskId)) {
                            return;
                          }
                          setState(() {
                            _selectedLessonId = lessonId;
                            _selectedTaskId = taskId;
                            _tab = Act0ShellTabV1.play;
                            _showPlayHub = false;
                            _returnToPlayHubOnBack = false;
                            _phase = _taskById(lesson, taskId).phase;
                            _selectedOptionId = null;
                            _teachingStepIndex = 0;
                            _resetLessonRunMetrics();
                            _activePracticeGroupId = null;
                            _learnDetailLessonId = null;
                            _learnPopupTaskId = null;
                            _learnDetailWorldId = null;
                          });
                        },
                      ),
                      Act0ShellTabV1.play =>
                        _showPlayHub && _blockCompletionSummary == null
                            ? Act0PlayShellV1(
                                groups: _practiceGroups(
                                  state: state,
                                  world: selectedWorld,
                                  selectedLesson: selectedLesson,
                                ),
                                recommendedTitle: _recommendedPlayTitle(),
                                recommendedSubtitle: _recommendedPlaySubtitle(
                                  selectedLesson,
                                  playSelectedTask!,
                                ),
                                recommendedReasonLabel:
                                    _recommendedPlayReasonLabel(
                                      selectedWorld,
                                      selectedLesson,
                                    ),
                                recommendedOutcome: _recommendedPlayOutcome(
                                  selectedWorld,
                                  selectedLesson,
                                ),
                                recommendedOutcomeLead:
                                    _recommendedPlayOutcomeLead(
                                      selectedWorld,
                                      selectedLesson,
                                    ),
                                masteryLabel: _playMasteryLabel(),
                                screenSubtitle: _playScreenSubtitle(
                                  selectedWorld,
                                  selectedLesson,
                                ),
                                onStartGroup: (group) => setState(() {
                                  _startPracticeGroup(group, selectedWorld);
                                }),
                              )
                            : _blockCompletionSummary != null
                            ? Act0BlockCompletionShellV1(
                                summary: _blockCompletionSummary!,
                                onReplay: () => setState(() {
                                  _showPlayHub = false;
                                  _selectedTaskId =
                                      selectedLesson.taskList.first.taskId;
                                  _phase = _taskById(
                                    selectedLesson,
                                    _selectedTaskId,
                                  ).phase;
                                  _selectedOptionId = null;
                                  _teachingStepIndex = 0;
                                  _resetLessonRunMetrics();
                                }),
                                onBackToMap: () => setState(() {
                                  _tab = Act0ShellTabV1.learn;
                                  _learnDetailLessonId = null;
                                  _learnDetailWorldId = null;
                                  _showWorldMenu = false;
                                  _blockCompletionSummary = null;
                                }),
                                onContinue: () => setState(() {
                                  final progressedWorlds = _progressWorlds(
                                    baseState,
                                  );
                                  final nextLessonId = _nextLessonId(
                                    selectedWorld.lessons,
                                    selectedLesson.lessonId,
                                  );
                                  if (nextLessonId == null) {
                                    final nextWorld = _nextSelectableWorld(
                                      progressedWorlds,
                                      _selectedWorldId,
                                    );
                                    if (nextWorld == null) {
                                      _tab = Act0ShellTabV1.learn;
                                      _showPlayHub = true;
                                      _learnDetailLessonId = null;
                                      _learnDetailWorldId = null;
                                      _showWorldMenu = false;
                                      _blockCompletionSummary = null;
                                      return;
                                    }
                                    final nextLesson = _firstPlayableLesson(
                                      nextWorld,
                                    );
                                    _selectedWorldId = nextWorld.worldId;
                                    _selectedLessonId = nextLesson.lessonId;
                                    _selectedTaskId = _firstIncompleteTask(
                                      nextLesson,
                                    ).taskId;
                                    _phase = _taskById(
                                      nextLesson,
                                      _selectedTaskId,
                                    ).phase;
                                    _showPlayHub = false;
                                    _selectedOptionId = null;
                                    _teachingStepIndex = 0;
                                    _learnDetailLessonId = null;
                                    _learnDetailWorldId = null;
                                    _showWorldMenu = false;
                                    _blockCompletionSummary = null;
                                    _resetLessonRunMetrics();
                                    return;
                                  }
                                  final progressedWorld = _worldById(
                                    progressedWorlds,
                                    _selectedWorldId,
                                  );
                                  final nextLesson = _lessonById(
                                    progressedWorld.lessons,
                                    nextLessonId,
                                  );
                                  _selectedLessonId = nextLesson.lessonId;
                                  _selectedTaskId = _firstIncompleteTask(
                                    nextLesson,
                                  ).taskId;
                                  _phase = _taskById(
                                    nextLesson,
                                    _selectedTaskId,
                                  ).phase;
                                  _showPlayHub = false;
                                  _selectedOptionId = null;
                                  _teachingStepIndex = 0;
                                  _blockCompletionSummary = null;
                                  _resetLessonRunMetrics();
                                }),
                              )
                            : Act0LessonRunnerShellV1(
                                runner: playRunner!,
                                selectedTaskFamily:
                                    playSelectedTask?.resolvedTaskFamily,
                                tableVisualVariant: widget.tableVisualVariant,
                                completionSummary: completionSummary,
                                relaxTheoryAdvanceLock: _completedTaskIds
                                    .contains(playSelectedTask!.taskId),
                                showLearningRailFocusLabels:
                                    _activeRepairTaskId ==
                                    playSelectedTask.taskId,
                                onBack: () => setState(() {
                                  if (_placementDiagnosticActive) {
                                    _placementDiagnosticActive = false;
                                    _showPlacement = true;
                                    _showPlayHub = true;
                                    _placementDiagnosticIndex = 0;
                                    _placementDiagnosticCorrect = 0;
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.theory;
                                    _teachingStepIndex = 0;
                                    return;
                                  }
                                  if (_activeRepairTaskId != null) {
                                    _tab = Act0ShellTabV1.review;
                                    _showPlayHub = true;
                                    _returnToPlayHubOnBack = false;
                                    _activeRepairTaskId = null;
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.theory;
                                    _teachingStepIndex = 0;
                                    return;
                                  }
                                  if (_returnToPlayHubOnBack) {
                                    _showPlayHub = true;
                                  } else {
                                    _tab = Act0ShellTabV1.learn;
                                  }
                                }),
                                onPreviousTheory: () => setState(() {
                                  if (_teachingStepIndex > 0) {
                                    _teachingStepIndex -= 1;
                                  }
                                }),
                                onUndoInteraction: () => setState(() {
                                  if (_phase == Act0LessonPhaseV1.review) {
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.drill;
                                    _teachingStepIndex =
                                        playRunner.teachingSteps.length;
                                    return;
                                  }
                                  if (_phase == Act0LessonPhaseV1.drill &&
                                      playRunner.teachingSteps.isNotEmpty) {
                                    _selectedOptionId = null;
                                    _teachingStepIndex =
                                        playRunner.teachingSteps.length - 1;
                                  }
                                }),
                                onContinueTheory: () => setState(() {
                                  if (_advanceTeachingStep(playRunner)) {
                                    return;
                                  }
                                  _completeCurrentTask(playSelectedTask);
                                  if (_maybeShowBlockCompletionSummary(
                                    selectedWorld: selectedWorld,
                                    selectedLesson: selectedLesson,
                                    selectedTask: playSelectedTask,
                                  )) {
                                    return;
                                  }
                                  _advanceAfterTask(
                                    selectedWorld,
                                    selectedLesson,
                                  );
                                }),
                                onChooseOption: (option) => setState(() {
                                  _fireAnswerEffects(option);
                                  if (!_placementDiagnosticActive) {
                                    _recordAnswer(
                                      selectedLesson,
                                      playSelectedTask,
                                      option,
                                    );
                                  }
                                  _selectedOptionId = option.id;
                                  _phase = Act0LessonPhaseV1.review;
                                  _teachingStepIndex = 0;
                                }),
                                onChooseSeat: (seatId) => setState(() {
                                  for (final option in playRunner.options) {
                                    if (option.seatId == seatId) {
                                      _fireAnswerEffects(option);
                                      if (!_placementDiagnosticActive) {
                                        _recordAnswer(
                                          selectedLesson,
                                          playSelectedTask,
                                          option,
                                        );
                                      }
                                      _selectedOptionId = option.id;
                                      _phase = Act0LessonPhaseV1.review;
                                      _teachingStepIndex = 0;
                                      return;
                                    }
                                  }
                                }),
                                onContinueReview: () => setState(() {
                                  if (_placementDiagnosticActive) {
                                    if (playRunner.selectedOption?.isCorrect ??
                                        false) {
                                      _placementDiagnosticCorrect += 1;
                                    }
                                    if (_startNextPlacementDiagnostic(
                                      _progressWorlds(baseState),
                                    )) {
                                      return;
                                    }
                                    _placementResult = _buildPlacementResult();
                                    _seedProfileSkillStats(
                                      _placementResult!.skillStats,
                                    );
                                    _placementDiagnosticActive = false;
                                    _showPlacement = true;
                                    _showPlayHub = true;
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.theory;
                                    _teachingStepIndex = 0;
                                    return;
                                  }
                                  if (_activeRepairTaskId ==
                                      playSelectedTask.taskId) {
                                    final repaired =
                                        playRunner.selectedOption?.isCorrect ??
                                        false;
                                    if (repaired) {
                                      _completeCurrentTask(playSelectedTask);
                                    }
                                    _tab = Act0ShellTabV1.review;
                                    _showPlayHub = true;
                                    _returnToPlayHubOnBack = false;
                                    _activeRepairTaskId = null;
                                    _selectedOptionId = null;
                                    _phase = Act0LessonPhaseV1.theory;
                                    _teachingStepIndex = 0;
                                    return;
                                  }
                                  if (_shouldRetryInsideLesson(
                                    playSelectedTask,
                                    playRunner,
                                  )) {
                                    _startInsideLessonRetry(
                                      playSelectedTask,
                                      playRunner,
                                    );
                                    return;
                                  }
                                  _completeCurrentTask(playSelectedTask);
                                  if (_maybeShowBlockCompletionSummary(
                                    selectedWorld: selectedWorld,
                                    selectedLesson: selectedLesson,
                                    selectedTask: playSelectedTask,
                                  )) {
                                    _selectedOptionId = null;
                                    _teachingStepIndex = 0;
                                    return;
                                  }
                                  _advanceAfterTask(
                                    selectedWorld,
                                    selectedLesson,
                                  );
                                  _selectedOptionId = null;
                                  _teachingStepIndex = 0;
                                }),
                              ),
                      Act0ShellTabV1.review => Act0ReviewShellV1(
                        review: _reviewState(state.review),
                        selected: _reviewConfidence,
                        onSelected: (value) => setState(() {
                          _reviewConfidence = value;
                        }),
                        onFixMistake: (mistake) => setState(() {
                          _startTaskByIds(
                            selectedWorld,
                            mistake.lessonId,
                            mistake.taskId,
                          );
                          _activeRepairTaskId = mistake.taskId;
                          _teachingStepIndex = 0;
                        }),
                        onReplayFixedMistake: (mistake) => setState(() {
                          _startMistakeRepair(
                            selectedWorld,
                            mistake,
                            returnToPlayHub: false,
                            practiceGroupId: 'weak_spots',
                          );
                        }),
                      ),
                      Act0ShellTabV1.profile => Act0ProfileShellV1(
                        profile: _profileState(state.profile, progress),
                        onRetakePlacement: _openPlacementFlow,
                        onGoToHome: () =>
                            setState(() => _tab = Act0ShellTabV1.home),
                      ),
                    },
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          (_showPlacement && !_placementDiagnosticActive) ||
              (_tab == Act0ShellTabV1.play && !_showPlayHub)
          ? null
          : _BottomNavV1(
              current: _tab,
              onSelected: (tab) => setState(() {
                _tab = tab;
                if (tab == Act0ShellTabV1.play) {
                  _showPlayHub = true;
                  _blockCompletionSummary = null;
                  _placementHandoffActive = false;
                }
                if (tab != Act0ShellTabV1.play) {
                  _phase = Act0LessonPhaseV1.theory;
                  _selectedOptionId = null;
                  _teachingStepIndex = 0;
                  _blockCompletionSummary = null;
                  _showPlayHub = true;
                  _activeRepairTaskId = null;
                }
                if (tab != Act0ShellTabV1.home) {
                  _placementHandoffActive = false;
                }
                if (tab == Act0ShellTabV1.learn) {
                  // Auto-expand the current lesson so new users see their
                  // progress point immediately without extra taps.
                  _learnDetailLessonId ??= _selectedLessonId;
                }
                if (tab != Act0ShellTabV1.learn) {
                  _learnDetailLessonId = null;
                  _learnDetailWorldId = null;
                  _showWorldMenu = false;
                }
              }),
            ),
    );
  }

  List<Act0WorldCardV1> _progressWorlds(Act0ShellStateV1 state) {
    return _progressWorldsWithTaskIds(state, _pathClosedTaskIds);
  }

  List<Act0WorldCardV1> _progressWorldsWithTaskIds(
    Act0ShellStateV1 state,
    Set<String> completedTaskIds,
  ) {
    var previousWorldComplete = true;
    var lockedWorldSeen = false;
    final worlds = <Act0WorldCardV1>[];
    for (final world in state.worlds) {
      final progressed = _progressWorld(
        world,
        previousWorldComplete,
        isImmediateLockedWorld: !previousWorldComplete && !lockedWorldSeen,
        completedTaskIds: completedTaskIds,
      );
      worlds.add(progressed);
      if (progressed.status == Act0WorldStateV1.locked) {
        lockedWorldSeen = true;
      }
      previousWorldComplete = progressed.status == Act0WorldStateV1.completed;
    }
    return worlds;
  }

  List<Act0WorldCardV1> _progressedWorlds(Act0ShellStateV1 state) =>
      _progressWorlds(state);

  List<Act0PracticeGroupV1> _practiceGroups({
    required Act0ShellStateV1 state,
    required Act0WorldCardV1 world,
    required Act0LessonCardV1 selectedLesson,
  }) {
    final currentTask = _firstIncompleteTask(selectedLesson);
    final weakSpot = _topOpenMistake();
    final quickFix = _quickFixMistakes().isEmpty
        ? null
        : _quickFixMistakes().first;
    final openMistakeCount = _openMistakes().length;
    final recommendation = _learningRecommendation(
      selectedWorld: world,
      selectedLesson: selectedLesson,
    );
    final dailyDeckEntry = _nextDailyDeckEntry(
      state: state,
      fallbackWorld: world,
      fallbackLesson: selectedLesson,
    );
    return <Act0PracticeGroupV1>[
      Act0PracticeGroupV1(
        groupId: 'continue',
        title: 'Continue lesson',
        subtitle: '${selectedLesson.title}: ${currentTask.title}',
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.continueLesson,
        ),
        categoryLabel: 'Next lesson step',
        isEnabled: selectedLesson.isSelectable,
        targetLessonId: selectedLesson.lessonId,
        targetTaskId: currentTask.taskId,
        sessionLabel: 'Best next',
        durationLabel: '~5 min',
        isRecommended: recommendation.practiceGroupId == 'continue',
      ),
      Act0PracticeGroupV1(
        groupId: 'placement',
        title: 'Find my level',
        subtitle: 'Answer a short table spot before we tune your start point.',
        ctaLabel: 'Start check',
        categoryLabel: 'Placement',
        isEnabled: true,
        targetLessonId: selectedLesson.lessonId,
        targetTaskId: currentTask.taskId,
        countLabel: 'Preview',
        sessionLabel: 'Diagnostic',
        durationLabel: '~3 min',
        isRecommended: recommendation.practiceGroupId == 'placement',
      ),
      Act0PracticeGroupV1(
        groupId: 'weak_spots',
        title: weakSpot?.title ?? quickFix?.title ?? 'Fix weak spots',
        subtitle: weakSpot == null && quickFix == null
            ? 'Mistakes you make will appear here.'
            : weakSpot?.reason ??
                  'One light review keeps this quick fix stable.',
        ctaLabel: weakSpot != null
            ? _recommendationCtaLabel(
                _Act0LearningNextActionKindV1.repairWeakSpot,
              )
            : (quickFix != null
                  ? _recommendationCtaLabel(
                      _Act0LearningNextActionKindV1.reviewQuickFix,
                    )
                  : 'Review'),
        categoryLabel: 'Repair',
        isEnabled: weakSpot != null || quickFix != null,
        targetLessonId: weakSpot?.lessonId ?? quickFix?.lessonId,
        targetTaskId: weakSpot?.taskId ?? quickFix?.taskId,
        countLabel: openMistakeCount == 0 ? '' : '$openMistakeCount open',
        sessionLabel: weakSpot == null ? 'Quick fix' : 'Weak spot',
        durationLabel: '~4 min',
        isRecommended: recommendation.practiceGroupId == 'weak_spots',
      ),
      Act0PracticeGroupV1(
        groupId: 'daily',
        title: _dailyCompletedTaskIds.length >= 3
            ? 'Daily set complete'
            : 'Quick daily drill',
        subtitle: _dailyCompletedTaskIds.length >= 3
            ? 'Nice. Keep going or repair weak spots next.'
            : dailyDeckEntry.isSpaced
            ? 'Finish three spaced spots across completed worlds.'
            : 'Finish three short spots for today.',
        ctaLabel: _dailyCompletedTaskIds.length >= 3
            ? _recommendationCtaLabel(_Act0LearningNextActionKindV1.dailyDone)
            : _recommendationCtaLabel(_Act0LearningNextActionKindV1.dailyDrill),
        categoryLabel: 'Daily',
        isEnabled: true,
        targetWorldId: dailyDeckEntry.worldId,
        targetLessonId: dailyDeckEntry.lessonId,
        targetTaskId: dailyDeckEntry.taskId,
        countLabel: _dailyGoalValueLabel(),
        sessionLabel: _dailyCompletedTaskIds.length >= 3
            ? 'Complete'
            : '3 spot set',
        durationLabel: '~3 min',
        isRecommended: recommendation.practiceGroupId == 'daily',
      ),
      _groupForLesson(
        world,
        groupId: 'actions',
        lessonId: 'fold_check_call_raise',
        title: 'Actions',
        subtitle: 'Fold, check, call, and raise in context.',
        ctaLabel: 'Practice',
        categoryLabel: 'Action',
        preferDrill: true,
        sessionLabel: 'Core drill',
        durationLabel: '~3 min',
        isRecommended: recommendation.practiceGroupId == 'actions',
      ),
      _groupForLesson(
        world,
        groupId: 'positions',
        lessonId: 'positions',
        title: 'Positions',
        subtitle: 'Find seats and action order faster.',
        ctaLabel: 'Practice',
        categoryLabel: 'Seats',
        preferDrill: true,
        sessionLabel: 'Seat drill',
        durationLabel: '~2 min',
        isRecommended: recommendation.practiceGroupId == 'positions',
      ),
      _groupForLesson(
        world,
        groupId: 'streets',
        lessonId: 'your_first_hand',
        title: 'Streets',
        subtitle: 'Preflop, flop, turn, river, showdown.',
        ctaLabel: 'Practice',
        categoryLabel: 'Hand flow',
        preferDrill: true,
        sessionLabel: 'Street drill',
        durationLabel: '~2 min',
        isRecommended: recommendation.practiceGroupId == 'streets',
      ),
      _groupForLesson(
        world,
        groupId: 'rankings',
        lessonId: 'hand_rankings_table',
        title: 'Hand rankings',
        subtitle: 'Read made hands on the board.',
        ctaLabel: 'Practice',
        categoryLabel: 'Cards',
        preferDrill: true,
        sessionLabel: 'Card drill',
        durationLabel: '~2 min',
        isRecommended: recommendation.practiceGroupId == 'rankings',
      ),
      _groupForLesson(
        world,
        groupId: 'showdown',
        lessonId: 'showdown_winning',
        title: 'Showdown',
        subtitle: 'Reveal, compare, and split pots.',
        ctaLabel: 'Practice',
        categoryLabel: 'Winning',
        preferDrill: true,
        sessionLabel: 'Finish drill',
        durationLabel: '~2 min',
        isRecommended: recommendation.practiceGroupId == 'showdown',
      ),
    ];
  }

  _Act0DailyDeckEntryV1 _nextDailyDeckEntry({
    required Act0ShellStateV1 state,
    required Act0WorldCardV1 fallbackWorld,
    required Act0LessonCardV1 fallbackLesson,
  }) {
    final deck = _dailyDeckEntries(state);
    if (deck.isEmpty) {
      final fallbackTask =
          _preferredPracticeTask(fallbackLesson, preferDrill: true) ??
          _firstIncompleteTask(fallbackLesson);
      return _Act0DailyDeckEntryV1(
        worldId: fallbackWorld.worldId,
        lessonId: fallbackLesson.lessonId,
        taskId: fallbackTask.taskId,
        isSpaced: false,
      );
    }
    return deck.firstWhere(
      (entry) => !_dailyCompletedTaskIds.contains(entry.taskId),
      orElse: () => deck.first,
    );
  }

  List<_Act0DailyDeckEntryV1> _dailyDeckEntries(Act0ShellStateV1 state) {
    final completedWorlds = _progressedWorlds(state)
        .where(
          (world) =>
              world.status == Act0WorldStateV1.completed &&
              world.worldNumber <= 6,
        )
        .toList(growable: false);
    if (completedWorlds.isEmpty) {
      return const <_Act0DailyDeckEntryV1>[];
    }
    final tasksByWorldId = <String, List<_Act0DailyDeckEntryV1>>{};
    for (final world in completedWorlds) {
      final entries = <_Act0DailyDeckEntryV1>[];
      for (final lesson in world.lessons) {
        if (!lesson.isSelectable) {
          continue;
        }
        for (final task in lesson.taskList) {
          if (task.phase != Act0LessonPhaseV1.drill) {
            continue;
          }
          entries.add(
            _Act0DailyDeckEntryV1(
              worldId: world.worldId,
              lessonId: lesson.lessonId,
              taskId: task.taskId,
              isSpaced: true,
            ),
          );
        }
      }
      if (entries.isNotEmpty) {
        tasksByWorldId[world.worldId] = entries;
      }
    }
    if (tasksByWorldId.isEmpty) {
      return const <_Act0DailyDeckEntryV1>[];
    }
    final worldOrder = completedWorlds
        .map((world) => world.worldId)
        .where(tasksByWorldId.containsKey)
        .toList(growable: false);
    final deck = <_Act0DailyDeckEntryV1>[];
    var hasAny = true;
    while (hasAny) {
      hasAny = false;
      for (final worldId in worldOrder) {
        final entries = tasksByWorldId[worldId]!;
        if (entries.isEmpty) {
          continue;
        }
        deck.add(entries.removeAt(0));
        hasAny = true;
      }
    }
    return deck;
  }

  _Act0LearningRecommendationV1 _learningRecommendation({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
  }) {
    final topMistake = _topOpenMistake();
    if (topMistake != null) {
      final isDeep = topMistake.severityLabel == 'Deep leak';
      return _Act0LearningRecommendationV1(
        kind: isDeep
            ? _Act0LearningNextActionKindV1.repairDeepLeak
            : _Act0LearningNextActionKindV1.repairWeakSpot,
        label: isDeep ? 'Deep leak' : 'Needs review',
        title: isDeep ? 'Fix a deep leak' : 'Repair one weak spot',
        subtitle: isDeep
            ? 'This spot missed twice. Repair it before moving on.'
            : 'Fix this mistake before it becomes a habit.',
        ctaLabel: _recommendationCtaLabel(
          isDeep
              ? _Act0LearningNextActionKindV1.repairDeepLeak
              : _Act0LearningNextActionKindV1.repairWeakSpot,
        ),
        hint: 'Next route: repair this spot now.',
        outcome: isDeep
            ? 'Deep leak first: repair ${_playDrillTitleForLesson(topMistake.lessonId)}.'
            : 'On repair: return to ${_playDrillTitleForLesson(topMistake.lessonId)}.',
        mistake: topMistake,
        lessonId: topMistake.lessonId,
        taskId: topMistake.taskId,
        practiceGroupId: 'weak_spots',
      );
    }

    final quickFix = _quickFixMistakes().isEmpty
        ? null
        : _quickFixMistakes().first;
    if (quickFix != null) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.reviewQuickFix,
        label: 'Quick fix',
        title: 'Review a quick fix',
        subtitle: 'You repaired this once. One light review keeps it stable.',
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.reviewQuickFix,
        ),
        hint: 'Next route: light review in Review.',
        outcome:
            'Light review: keep ${_playDrillTitleForLesson(quickFix.lessonId)} warm.',
        mistake: quickFix,
        lessonId: quickFix.lessonId,
        taskId: quickFix.taskId,
        practiceGroupId: 'weak_spots',
      );
    }

    final currentTask = _firstIncompleteTask(selectedLesson);

    if (_dailyCompletedTaskIds.length >= 3 && _openMistakes().isEmpty) {
      final streakSaved = _streakSaveEarned();
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.dailyDone,
        label: streakSaved ? 'Streak saved' : 'Done for today',
        title: streakSaved ? 'Streak saved today' : 'Great session',
        subtitle: streakSaved
            ? 'You protected momentum by repairing and finishing the daily set.'
            : 'Come back tomorrow to keep the streak going.',
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.dailyDone,
        ),
        hint: '',
        outcome: streakSaved
            ? 'Momentum protected. One clean daily tomorrow extends it.'
            : 'Streak active. Same time tomorrow locks it in.',
        lessonId: selectedLesson.lessonId,
        taskId: null,
        practiceGroupId: 'daily',
      );
    }

    if (!_completedTaskIds.contains(currentTask.taskId)) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.continueLesson,
        label: _cleanTaskIds.isEmpty && _completedTaskIds.isEmpty
            ? 'Start here'
            : 'Continue',
        title: selectedLesson.title,
        subtitle: selectedLesson.subtitle,
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.continueLesson,
        ),
        hint: 'Next route: continue this lesson now.',
        outcome:
            _nextLesson(selectedWorld.lessons, selectedLesson.lessonId) == null
            ? 'On return: keep the clean pass moving.'
            : 'On return: ${_nextLesson(selectedWorld.lessons, selectedLesson.lessonId)!.title} stays next to unlock.',
        lessonId: selectedLesson.lessonId,
        taskId: currentTask.taskId,
        practiceGroupId: 'continue',
      );
    }

    if (_dailyCompletedTaskIds.length < 3) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.dailyDrill,
        label: 'Daily set',
        title: 'Quick daily drill',
        subtitle: 'Run three short spots to keep today clean.',
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.dailyDrill,
        ),
        hint: 'Next route: quick daily drill in Play.',
        outcome: 'Daily set: 3 crisp reps, no extra noise.',
        lessonId: selectedLesson.lessonId,
        taskId: _preferredPracticeTask(
          selectedLesson,
          preferDrill: true,
        )?.taskId,
        practiceGroupId: 'daily',
      );
    }

    if (_dailyCompletedTaskIds.length >= 3 && _openMistakes().isEmpty) {
      final streakSaved = _streakSaveEarned();
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.dailyDone,
        label: streakSaved ? 'Streak saved' : 'Done for today',
        title: streakSaved ? 'Streak saved today' : 'Great session',
        subtitle: streakSaved
            ? 'You protected momentum by repairing and finishing the daily set.'
            : 'Come back tomorrow to keep the streak going.',
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.dailyDone,
        ),
        hint: '',
        outcome: streakSaved
            ? 'Momentum protected. One clean daily tomorrow extends it.'
            : 'Streak active. Same time tomorrow locks it in.',
        lessonId: selectedLesson.lessonId,
        taskId: null,
        practiceGroupId: 'daily',
      );
    }

    final actionsLesson = _lessonById(
      selectedWorld.lessons,
      'fold_check_call_raise',
    );
    return _Act0LearningRecommendationV1(
      kind: _Act0LearningNextActionKindV1.categoryPractice,
      label: 'Keep going',
      title: 'Actions',
      subtitle: 'Lock in one core action pattern.',
      ctaLabel: _recommendationCtaLabel(
        _Act0LearningNextActionKindV1.categoryPractice,
      ),
      hint: 'Next route: category practice in Play.',
      outcome: 'Category practice: keep your strongest reads warm.',
      lessonId: actionsLesson.lessonId,
      taskId: _preferredPracticeTask(actionsLesson, preferDrill: true)?.taskId,
      practiceGroupId: 'actions',
    );
  }

  String _recommendationCtaLabel(_Act0LearningNextActionKindV1 kind) {
    return switch (kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => 'Fix this now',
      _Act0LearningNextActionKindV1.repairWeakSpot => 'Fix this now',
      _Act0LearningNextActionKindV1.reviewQuickFix => 'Review now',
      _Act0LearningNextActionKindV1.continueLesson => 'Continue',
      _Act0LearningNextActionKindV1.dailyDrill => 'Start daily set',
      _Act0LearningNextActionKindV1.dailyDone => 'View progress',
      _Act0LearningNextActionKindV1.categoryPractice => 'Practice',
    };
  }

  String _homeNextActionLabel() {
    if (_placementHandoffActive) {
      return 'First guided start';
    }
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    return _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    ).label;
  }

  String _homeNextActionTitle(Act0LessonCardV1 currentLesson) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    return _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    ).title;
  }

  String _homeNextActionSubtitle(Act0LessonCardV1 currentLesson) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    return _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    ).subtitle;
  }

  String _homeNextActionCtaLabel() {
    if (_placementHandoffActive) {
      return 'Start first rep';
    }
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    return _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    ).ctaLabel;
  }

  String? _homeCtaHint(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return 'One tap opens the first guided rep chosen from your placement result.';
    }
    final hint = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    ).hint;
    return hint.isEmpty ? null : hint;
  }

  String _homeHandoffLabel(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return 'First route';
    }
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    return switch (recommendation.kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => 'Repair first',
      _Act0LearningNextActionKindV1.repairWeakSpot => 'Repair first',
      _Act0LearningNextActionKindV1.reviewQuickFix => 'Quick review',
      _Act0LearningNextActionKindV1.dailyDrill => 'Daily reps',
      _Act0LearningNextActionKindV1.categoryPractice => 'Practice focus',
      _Act0LearningNextActionKindV1.continueLesson => 'Best next action',
      _Act0LearningNextActionKindV1.dailyDone =>
        _streakSaveEarned() ? 'Streak saved' : 'Great session',
    };
  }

  String _homeHandoffIdentity(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    final focusTaskId =
        recommendation.mistake?.taskId ?? recommendation.taskId ?? '';
    final focusLessonId =
        recommendation.mistake?.lessonId ??
        recommendation.lessonId ??
        currentLesson.lessonId;
    final practiceGroupId = recommendation.practiceGroupId ?? '';
    return <String>[
      recommendation.kind.name,
      selectedWorld.worldId,
      focusLessonId,
      focusTaskId,
      practiceGroupId,
    ].join('|');
  }

  bool _homeHandoffVisible(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final identity = _homeHandoffIdentity(selectedWorld, currentLesson);
    if (_dismissedHomeHandoffKey.isEmpty ||
        _dismissedHomeHandoffKey != identity ||
        _dismissedHomeHandoffDay.isEmpty) {
      return true;
    }
    final today = _todayDateString();
    if (_dismissedHomeHandoffDay == today) {
      return false;
    }
    try {
      final dismissedDay = DateTime.parse(_dismissedHomeHandoffDay);
      final todayDate = DateTime.parse(today);
      return todayDate.difference(dismissedDay).inDays >=
          _homeHandoffDismissDays;
    } catch (_) {
      return true;
    }
  }

  void _dismissHomeHandoff(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    _dismissedHomeHandoffKey = _homeHandoffIdentity(
      selectedWorld,
      currentLesson,
    );
    _dismissedHomeHandoffDay = _todayDateString();
    _persistProgress();
  }

  String _homeDailyGoalCtaLabel(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    final shouldRepairFirst =
        recommendation.kind == _Act0LearningNextActionKindV1.repairDeepLeak ||
        recommendation.kind == _Act0LearningNextActionKindV1.repairWeakSpot;
    return shouldRepairFirst ? 'Repair weak spot →' : 'Practice now →';
  }

  String _homeHandoffHeadline(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return 'Placement complete. Start your first guided rep now.';
    }
    final nextLesson = _nextLesson(
      selectedWorld.lessons,
      currentLesson.lessonId,
    );
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      return 'Repair ${recommendation.mistake!.title}, then reopen ${nextLesson?.title ?? currentLesson.title}.';
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      return 'Review this quick fix before it turns into a weak spot.';
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.dailyDrill) {
      return 'Daily set: three crisp reps, then keep the path moving.';
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.dailyDone) {
      if (_streakSaveEarned()) {
        return 'Streak saved by effort. Repair plus daily set protected momentum.';
      }
      return 'Great session. Come back tomorrow to keep the streak going.';
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.categoryPractice) {
      return 'All clear. Pick one category and keep it sharp.';
    }
    if (nextLesson == null) {
      return 'Finish this lesson, then lock it in with ${_playDrillTitleForLesson(currentLesson.lessonId)}.';
    }
    return 'Finish this lesson to unlock ${nextLesson.title}.';
  }

  String _homeHandoffDetail(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return 'One tap opens the guided rep chosen from your placement result.';
    }
    final nextLesson = _nextLesson(
      selectedWorld.lessons,
      currentLesson.lessonId,
    );
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      return 'Fast reset: ${_playDrillTitleForLesson(recommendation.mistake!.lessonId)} in Play.';
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      return 'Light review: ${_playDrillTitleForLesson(recommendation.lessonId ?? currentLesson.lessonId)} stays warm.';
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.dailyDrill) {
      return 'Short daily practice now; full lessons can wait.';
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.dailyDone) {
      if (_streakSaveEarned()) {
        return 'Momentum protected today. One clean daily tomorrow keeps it alive.';
      }
      return 'Streak active. Same time tomorrow locks it in.';
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.categoryPractice) {
      return 'Start with Actions, then rotate to another category.';
    }
    if (nextLesson == null) {
      return 'Lock it in with ${_playDrillTitleForLesson(currentLesson.lessonId)} in Play.';
    }
    return 'Then run ${_playDrillTitleForLesson(currentLesson.lessonId)} in Play.';
  }

  String _homeHandoffOutcome(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    return _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    ).outcome;
  }

  List<String> _homeHandoffPills(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return <String>['Route ready', '1-tap rep'];
    }
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    final mistake = recommendation.mistake;
    final activeLessonId = mistake?.lessonId ?? currentLesson.lessonId;
    if (mistake == null) {
      return switch (recommendation.kind) {
        _Act0LearningNextActionKindV1.reviewQuickFix => <String>[
          'Quick fix',
          _playMasteryLabel(),
        ],
        _Act0LearningNextActionKindV1.dailyDrill => <String>[
          '3 spot set',
          _playMasteryLabel(),
        ],
        _Act0LearningNextActionKindV1.categoryPractice => <String>[
          'Category practice',
          _playMasteryLabel(),
        ],
        _ => <String>[_playMasteryLabel()],
      };
    }
    return <String>['Replay: ${_playDrillTitleForLesson(activeLessonId)}'];
  }

  String _playMasteryLabel() {
    final topMistake = _topOpenMistake();
    if (topMistake?.severityLabel == 'Deep leak') {
      return 'Deep leak';
    }
    if (topMistake != null) {
      return 'Needs review';
    }
    if (_quickFixMistakes().isNotEmpty) {
      return 'Quick fix';
    }
    if (_cleanTaskIds.length >= 3) {
      return 'Clean pass';
    }
    if (_completedTaskIds.isNotEmpty) {
      return 'Solid';
    }
    return 'Learning';
  }

  String _playScreenSubtitle(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    return switch (recommendation.kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak =>
        'A deep leak needs repair before new drills.',
      _Act0LearningNextActionKindV1.repairWeakSpot =>
        'Fix one weak spot. Then keep the path moving.',
      _Act0LearningNextActionKindV1.reviewQuickFix =>
        'One light review keeps a quick fix stable.',
      _Act0LearningNextActionKindV1.dailyDone =>
        'Daily set complete. Come back tomorrow.',
      _ => 'Pick one drill. Sharpen one edge.',
    };
  }

  String _dailyGoalValueLabel() {
    final count = _dailyCompletedTaskIds.length.clamp(0, 3);
    if (count < 3) {
      return '$count/3 daily spots';
    }
    return _streakSaveEarned() ? 'Streak saved today' : 'Done for today';
  }

  String _compactDailyLabel() {
    final count = _dailyCompletedTaskIds.length.clamp(0, 3);
    if (count < 3) {
      return 'Today $count/3';
    }
    return _streakSaveEarned() ? 'Saved \u2713' : 'Done \u2713';
  }

  bool _streakSaveEarned() {
    return _dailyCompletedTaskIds.length >= 3 &&
        _resolvedMistakeTaskIds.isNotEmpty;
  }

  Act0SharkyCueV1? _homeSharkyOverride() {
    final state = widget.state ?? Act0ShellStateV1.sample;

    // Daily done after successful repair — celebrate saved streak effort
    if (_streakSaveEarned()) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Nice save. You earned your streak by fixing leaks.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'Saved by effort today. Repeat one clean set tomorrow.',
        preSessionMood: Act0SharkyMoodV1.celebrate,
      );
    }

    // Daily goal complete — highest priority
    if (_dailyCompletedTaskIds.length >= 3) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Good session today. Come back tomorrow.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'The pattern is forming. One more day builds the habit.',
        preSessionMood: Act0SharkyMoodV1.celebrate,
      );
    }

    // First ever session — zero completed tasks
    if (_completedTaskIds.isEmpty) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Let\'s see how the table looks to you.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'Every strong player started exactly here.',
        preSessionMood: Act0SharkyMoodV1.neutral,
      );
    }

    // Streak milestone — 3+ day streak and daily not yet done
    if (state.streakDays >= 3 && _dailyCompletedTaskIds.isEmpty) {
      return Act0SharkyCueV1(
        preSessionLine: '${state.streakDays} days running. Keep it alive.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'Consistency is the edge. You have it.',
        preSessionMood: Act0SharkyMoodV1.happy,
      );
    }

    // Repair queue just cleared — all prior mistakes resolved
    if (_resolvedMistakeTaskIds.isNotEmpty && _openMistakes().isEmpty) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Repair queue clear. Clean slate.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'No open leaks. That is a real edge.',
        preSessionMood: Act0SharkyMoodV1.happy,
      );
    }

    // Clean run — 5+ correct answers with no open mistakes
    if (_cleanTaskIds.length >= 5 && _openMistakes().isEmpty) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Clean run. The reads are sharpening.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'Accuracy builds trust. You are building it.',
        preSessionMood: Act0SharkyMoodV1.happy,
      );
    }

    // Open mistakes — repair prompt
    final topMistake = _topOpenMistake();
    if (topMistake != null) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Fix one weak spot before you stop.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Good spot to fix.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'One repair now saves two repairs tomorrow.',
        preSessionMood: Act0SharkyMoodV1.repair,
      );
    }

    return null;
  }

  void _startHomeNextAction(Act0WorldCardV1 selectedWorld) {
    _placementHandoffActive = false;
    final lesson = _lessonById(selectedWorld.lessons, _selectedLessonId);
    _startRecommendation(
      _learningRecommendation(
        selectedWorld: selectedWorld,
        selectedLesson: lesson,
      ),
      selectedWorld,
      returnToPlayHub: false,
    );
  }

  Act0PracticeGroupV1 _groupForLesson(
    Act0WorldCardV1 world, {
    required String groupId,
    required String lessonId,
    required String title,
    required String subtitle,
    required String ctaLabel,
    required String categoryLabel,
    required String sessionLabel,
    String? countLabel,
    String durationLabel = '',
    bool preferDrill = false,
    bool isRecommended = false,
  }) {
    final lesson = world.lessons.cast<Act0LessonCardV1?>().firstWhere(
      (candidate) => candidate?.lessonId == lessonId,
      orElse: () => null,
    );
    final task = lesson == null
        ? null
        : _preferredPracticeTask(lesson, preferDrill: preferDrill);
    return Act0PracticeGroupV1(
      groupId: groupId,
      title: title,
      subtitle: subtitle,
      ctaLabel: ctaLabel,
      categoryLabel: categoryLabel,
      isEnabled: lesson != null && lesson.isSelectable && task != null,
      targetLessonId: lesson?.lessonId,
      targetTaskId: task?.taskId,
      countLabel:
          countLabel ??
          (lesson == null ? '' : '${lesson.taskList.length} steps'),
      sessionLabel: sessionLabel,
      durationLabel: durationLabel,
      isRecommended: isRecommended,
    );
  }

  Act0LessonTaskV1? _preferredPracticeTask(
    Act0LessonCardV1 lesson, {
    bool preferDrill = false,
  }) {
    final firstIncomplete = _firstIncompleteTask(lesson);
    if (!preferDrill || firstIncomplete.phase == Act0LessonPhaseV1.drill) {
      return firstIncomplete;
    }
    return lesson.taskList.firstWhere(
      (task) =>
          task.phase == Act0LessonPhaseV1.drill &&
          _taskAvailable(lesson, task.taskId),
      orElse: () => firstIncomplete,
    );
  }

  String _recommendedPlayTitle() {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    return _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    ).title;
  }

  String _recommendedPlaySubtitle(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    return _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    ).subtitle;
  }

  String _recommendedPlayOutcome(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    return _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    ).outcome;
  }

  String _recommendedPlayReasonLabel(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    return switch (recommendation.kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => 'Repair first',
      _Act0LearningNextActionKindV1.repairWeakSpot => 'Repair first',
      _Act0LearningNextActionKindV1.reviewQuickFix => 'Quick review',
      _Act0LearningNextActionKindV1.dailyDrill => 'Daily set',
      _Act0LearningNextActionKindV1.categoryPractice => 'Practice focus',
      _Act0LearningNextActionKindV1.continueLesson => 'Best next action',
      _Act0LearningNextActionKindV1.dailyDone => 'Great session',
    };
  }

  String _recommendedPlayOutcomeLead(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    return switch (recommendation.kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => 'Fix this first.',
      _Act0LearningNextActionKindV1.repairWeakSpot => 'Fix this now.',
      _Act0LearningNextActionKindV1.reviewQuickFix => 'Review this now.',
      _Act0LearningNextActionKindV1.dailyDrill => 'Daily set first.',
      _Act0LearningNextActionKindV1.categoryPractice => 'Practice this now.',
      _Act0LearningNextActionKindV1.continueLesson => 'Keep the lesson moving.',
      _Act0LearningNextActionKindV1.dailyDone => 'Done for today.',
    };
  }

  String _learnGuideTitle(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    return _homeHandoffLabel(selectedWorld, selectedLesson);
  }

  String _learnGuideLine(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    return _homeHandoffHeadline(selectedWorld, selectedLesson);
  }

  String _learnGuideDetail(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    return _homeHandoffDetail(selectedWorld, selectedLesson);
  }

  Act0SharkyMoodV1 _learnGuideMood(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    return switch (recommendation.kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => Act0SharkyMoodV1.repair,
      _Act0LearningNextActionKindV1.repairWeakSpot => Act0SharkyMoodV1.repair,
      _Act0LearningNextActionKindV1.reviewQuickFix => Act0SharkyMoodV1.thinking,
      _Act0LearningNextActionKindV1.continueLesson => Act0SharkyMoodV1.happy,
      _Act0LearningNextActionKindV1.dailyDrill => Act0SharkyMoodV1.happy,
      _Act0LearningNextActionKindV1.categoryPractice =>
        Act0SharkyMoodV1.thinking,
      _Act0LearningNextActionKindV1.dailyDone => Act0SharkyMoodV1.celebrate,
    };
  }

  Map<String, String> _lessonOutcomeLabels(List<Act0LessonCardV1> lessons) {
    return <String, String>{
      for (final lesson in lessons)
        lesson.lessonId: _lessonOutcomeLabel(lessons, lesson),
    };
  }

  String _lessonOutcomeLabel(
    List<Act0LessonCardV1> lessons,
    Act0LessonCardV1 lesson,
  ) {
    final nextLesson = _nextLesson(lessons, lesson.lessonId);
    return switch (lesson.state) {
      Act0LessonStateV1.completed =>
        nextLesson == null
            ? 'Already clear. Replay any step when you want a clean pass.'
            : 'Already clear. Next open lesson: ${nextLesson.title}.',
      Act0LessonStateV1.current =>
        nextLesson == null
            ? 'On clear: move into Play and lock the pattern in.'
            : 'On clear: unlock ${nextLesson.title}.',
      Act0LessonStateV1.locked => 'Opens after the current lesson is cleared.',
    };
  }

  Act0LessonCardV1? _nextLesson(
    List<Act0LessonCardV1> lessons,
    String lessonId,
  ) {
    final nextLessonId = _nextLessonId(lessons, lessonId);
    if (nextLessonId == null) {
      return null;
    }
    return _lessonById(lessons, nextLessonId);
  }

  String _playDrillTitleForLesson(String lessonId) {
    return switch (lessonId) {
      'what_poker_is' => 'Actions',
      'cards_ranks_suits' => 'Hand rankings',
      'your_first_hand' => 'Streets',
      'fold_check_call_raise' => 'Actions',
      'blinds_action_order' => 'Positions',
      'positions' => 'Positions',
      'hand_rankings_table' => 'Hand rankings',
      'showdown_winning' => 'Showdown',
      _ => 'Quick daily drill',
    };
  }

  void _startPracticeGroup(
    Act0PracticeGroupV1 group,
    Act0WorldCardV1 selectedWorld,
  ) {
    final lessonId = group.targetLessonId;
    final taskId = group.targetTaskId;
    if (!group.isEnabled || lessonId == null || taskId == null) {
      return;
    }
    if (group.groupId == 'weak_spots') {
      final weakSpot = _topOpenMistake();
      if (weakSpot != null) {
        _startMistakeRepair(
          selectedWorld,
          weakSpot,
          returnToPlayHub: true,
          practiceGroupId: group.groupId,
        );
        return;
      }
      final quickFix = _quickFixMistakes().isEmpty
          ? null
          : _quickFixMistakes().first;
      if (quickFix != null) {
        _startMistakeRepair(
          selectedWorld,
          quickFix,
          returnToPlayHub: true,
          practiceGroupId: group.groupId,
        );
        return;
      }
      return;
    }
    var launchWorld = selectedWorld;
    final targetWorldId = group.targetWorldId;
    if (targetWorldId != null) {
      final baseState = widget.state ?? Act0ShellStateV1.sample;
      launchWorld = _worldById(_progressedWorlds(baseState), targetWorldId);
    }
    _startTaskByIds(launchWorld, lessonId, taskId);
    _activePracticeGroupId = group.groupId;
  }

  void _startMistakeRepair(
    Act0WorldCardV1 selectedWorld,
    Act0MistakeCardV1 mistake, {
    required bool returnToPlayHub,
    String? practiceGroupId,
  }) {
    _startTaskByIds(selectedWorld, mistake.lessonId, mistake.taskId);
    _activeRepairTaskId = mistake.taskId;
    _returnToPlayHubOnBack = returnToPlayHub;
    _activePracticeGroupId = practiceGroupId;
    _teachingStepIndex = 0;
  }

  void _startRecommendation(
    _Act0LearningRecommendationV1 recommendation,
    Act0WorldCardV1 selectedWorld, {
    required bool returnToPlayHub,
  }) {
    final mistake = recommendation.mistake;
    if (mistake != null &&
        (recommendation.kind == _Act0LearningNextActionKindV1.repairDeepLeak ||
            recommendation.kind ==
                _Act0LearningNextActionKindV1.repairWeakSpot)) {
      _startMistakeRepair(
        selectedWorld,
        mistake,
        returnToPlayHub: returnToPlayHub,
        practiceGroupId: recommendation.practiceGroupId,
      );
      return;
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      final quickFix = _quickFixMistakes().isEmpty
          ? null
          : _quickFixMistakes().first;
      if (quickFix != null) {
        _startMistakeRepair(
          selectedWorld,
          quickFix,
          returnToPlayHub: returnToPlayHub,
          practiceGroupId: recommendation.practiceGroupId,
        );
      }
      return;
    }
    final lessonId = recommendation.lessonId;
    final taskId = recommendation.taskId;
    if (lessonId == null || taskId == null) {
      return;
    }
    _startTaskByIds(selectedWorld, lessonId, taskId);
    _returnToPlayHubOnBack = returnToPlayHub;
    _activePracticeGroupId = recommendation.practiceGroupId;
  }

  void _startPlacementDiagnostic(List<Act0WorldCardV1> worlds) {
    _placementDiagnosticIndex = 0;
    _placementDiagnosticCorrect = 0;
    _placementIntroVisible = false;
    _startPlacementDiagnosticAt(worlds, _placementDiagnosticIndex);
  }

  bool _startNextPlacementDiagnostic(List<Act0WorldCardV1> worlds) {
    final nextIndex = _placementDiagnosticIndex + 1;
    if (nextIndex >= _placementDiagnosticSpotsV1.length) {
      return false;
    }
    _placementDiagnosticIndex = nextIndex;
    _startPlacementDiagnosticAt(worlds, _placementDiagnosticIndex);
    return true;
  }

  void _startPlacementDiagnosticAt(
    List<Act0WorldCardV1> worlds,
    int diagnosticIndex,
  ) {
    final spot = _placementDiagnosticSpotsV1[diagnosticIndex];
    final world = _worldById(worlds, 'world_1');
    final lesson = _lessonById(world.lessons, spot.lessonId);
    final task = _taskById(lesson, spot.taskId);
    _selectedWorldId = world.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = task.taskId;
    _tab = Act0ShellTabV1.play;
    _showPlacement = false;
    _placementDiagnosticActive = true;
    _placementIntroVisible = false;
    _showPlayHub = false;
    _returnToPlayHubOnBack = false;
    _phase = task.phase;
    _selectedOptionId = null;
    // Placement diagnostic is assessment-only. Skip lesson teaching copy here;
    // the same task still teaches normally when launched from the learning path.
    _teachingStepIndex = task.runner.teachingSteps.length;
    _resetLessonRunMetrics();
  }

  void _startPlacementRecommendation(
    List<Act0WorldCardV1> worlds, {
    required bool fromZero,
  }) {
    final world = _worldById(worlds, 'world_1');
    final result = _placementResult;
    final lessonId = fromZero || result == null
        ? 'what_poker_is'
        : result.recommendedLessonId;
    final lesson = _lessonById(world.lessons, lessonId);
    final taskId = fromZero || result == null
        ? lesson.taskList.first.taskId
        : result.recommendedTaskId;
    final task = _taskByIdWithTaskIds(lesson, taskId, _pathClosedTaskIds);
    if (fromZero) {
      _skippedTaskIds.clear();
      _visibleSkippedTaskIds.clear();
    }
    if (!fromZero && result != null) {
      final skipPlan = _buildPlacementSkipPlan(
        world: world,
        recommendedLessonId: lesson.lessonId,
        recommendedTaskId: task.taskId,
      );
      _skippedTaskIds.addAll(skipPlan.taskIds);
      _visibleSkippedTaskIds.removeAll(skipPlan.taskIds);
      unawaited(_animatePlacementSkipReveal(skipPlan.orderedTaskIds));
    }
    _selectedWorldId = world.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = task.taskId;
    _showPlacement = false;
    _placementDiagnosticActive = false;
    _placementIntroVisible = false;
    _placementHandoffActive = true;
    _tab = Act0ShellTabV1.home;
    _showPlayHub = true;
    _returnToPlayHubOnBack = false;
    _showWorldMenu = false;
    _learnDetailWorldId = null;
    _learnDetailLessonId = null;
    _learnPopupTaskId = null;
    _phase = task.phase;
    _selectedOptionId = null;
    _teachingStepIndex = 0;
    _resetLessonRunMetrics();
    _persistProgress();
  }

  _Act0PlacementSkipPlanV1 _buildPlacementSkipPlan({
    required Act0WorldCardV1 world,
    required String recommendedLessonId,
    required String recommendedTaskId,
  }) {
    final orderedTaskIds = <String>[];
    final lessonIndex = world.lessons.indexWhere(
      (lesson) => lesson.lessonId == recommendedLessonId,
    );
    if (lessonIndex < 0) {
      return const _Act0PlacementSkipPlanV1(
        taskIds: <String>{},
        orderedTaskIds: <String>[],
      );
    }

    for (var i = 0; i < lessonIndex; i++) {
      final lesson = world.lessons[i];
      for (final task in lesson.taskList) {
        orderedTaskIds.add(task.taskId);
      }
    }

    final recommendedLesson = world.lessons[lessonIndex];
    final recommendedTaskIndex = recommendedLesson.taskList.indexWhere(
      (task) => task.taskId == recommendedTaskId,
    );
    if (recommendedTaskIndex > 0) {
      for (var i = 0; i < recommendedTaskIndex; i++) {
        orderedTaskIds.add(recommendedLesson.taskList[i].taskId);
      }
    }

    return _Act0PlacementSkipPlanV1(
      taskIds: orderedTaskIds.toSet(),
      orderedTaskIds: orderedTaskIds,
    );
  }

  Future<void> _animatePlacementSkipReveal(List<String> orderedTaskIds) async {
    for (final taskId in orderedTaskIds) {
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (!mounted) {
        return;
      }
      if (!_skippedTaskIds.contains(taskId) ||
          _visibleSkippedTaskIds.contains(taskId)) {
        continue;
      }
      setState(() {
        _visibleSkippedTaskIds.add(taskId);
      });
    }
  }

  Act0PlacementResultV1 _buildPlacementResult() {
    var score = _placementDiagnosticCorrect * 2;
    for (final question in _placementQuestionsV1) {
      score += _placementQuestionScore(question);
    }

    if (score >= 8) {
      return Act0PlacementResultV1(
        level: Act0PlacementResultLevelV1.readyForBasics,
        levelLabel: 'Ready for action basics',
        summary:
            'You know some poker language. Start where actions and order become real decisions.',
        reportHeadline: _placementReportHeadline(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        reportBody: _placementReportBody(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        coachTitle: _placementCoachTitle(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        coachLine: _placementCoachLine(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        profileSummary: _placementProfileSummary(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        diagnosticCorrect: _placementDiagnosticCorrect,
        diagnosticTotal: _placementDiagnosticSpotsV1.length,
        profileSignals: _placementProfileSignals(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        analysisHighlights: _placementAnalysisHighlights(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        firstSessionPlan: _placementFirstSessionPlan(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        skillStats: _placementSkillStats(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        strengths: <String>['Experience', 'Decision comfort'],
        weakSpots: <String>['Actions', 'Positions'],
        recommendedLessonId: 'fold_check_call_raise',
        recommendedTaskId: 'actions_legal_context',
        recommendedTitle: 'Fold, check, call, raise',
        recommendedReason:
            'Your answers show enough table comfort to start action vocabulary.',
        premiumPitch:
            'Premium can turn your diagnostic into daily weak-spot drills, review queues, and progress insights.',
        trialValuePoints: <String>[
          'Daily action reps from your misses',
          'Personal review queue after every block',
          'Progress insights by category',
        ],
      );
    }
    if (score >= 4) {
      return Act0PlacementResultV1(
        level: Act0PlacementResultLevelV1.rustyBeginner,
        levelLabel: 'Rusty beginner',
        summary:
            'You have a starting point. Lock the table flow before action decisions get harder.',
        reportHeadline: _placementReportHeadline(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        reportBody: _placementReportBody(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        coachTitle: _placementCoachTitle(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        coachLine: _placementCoachLine(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        profileSummary: _placementProfileSummary(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        diagnosticCorrect: _placementDiagnosticCorrect,
        diagnosticTotal: _placementDiagnosticSpotsV1.length,
        profileSignals: _placementProfileSignals(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        analysisHighlights: _placementAnalysisHighlights(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        firstSessionPlan: _placementFirstSessionPlan(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        skillStats: _placementSkillStats(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        strengths: <String>['Motivation', 'Some table language'],
        weakSpots: <String>['Blinds', 'Streets'],
        recommendedLessonId: 'your_first_hand',
        recommendedTaskId: 'your_first_hand_preflop',
        recommendedTitle: 'Your first hand, dealt',
        recommendedReason:
            'You are ready to see how a hand moves through each street.',
        premiumPitch:
            'Premium can keep your review focused on the spots you miss instead of repeating everything.',
        trialValuePoints: <String>[
          'Guided street-order practice',
          'Repair drills for missed table cues',
          'A seven-day plan after placement',
        ],
      );
    }
    return Act0PlacementResultV1(
      level: Act0PlacementResultLevelV1.newPlayer,
      levelLabel: 'New player',
      summary:
          'Start from zero. We will build the table, pot, blinds, cards, and goal one step at a time.',
      reportHeadline: _placementReportHeadline(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      reportBody: _placementReportBody(Act0PlacementResultLevelV1.newPlayer),
      coachTitle: _placementCoachTitle(Act0PlacementResultLevelV1.newPlayer),
      coachLine: _placementCoachLine(Act0PlacementResultLevelV1.newPlayer),
      profileSummary: _placementProfileSummary(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      diagnosticCorrect: _placementDiagnosticCorrect,
      diagnosticTotal: _placementDiagnosticSpotsV1.length,
      profileSignals: _placementProfileSignals(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      analysisHighlights: _placementAnalysisHighlights(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      firstSessionPlan: _placementFirstSessionPlan(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      skillStats: _placementSkillStats(Act0PlacementResultLevelV1.newPlayer),
      strengths: <String>['Fresh start', 'Clear path'],
      weakSpots: <String>['Table', 'Pot', 'Blinds'],
      recommendedLessonId: 'what_poker_is',
      recommendedTaskId: 'what_poker_is_theory',
      recommendedTitle: 'What poker is',
      recommendedReason:
          'The foundation path explains the table before asking for decisions.',
      premiumPitch:
          'Premium can add personal repair drills and a seven-day guided plan after this foundation.',
      trialValuePoints: <String>[
        'Step-by-step beginner path',
        'Extra repairs when a concept misses',
        'Simple progress insights',
      ],
    );
  }

  void _togglePlacementOption(
    Act0PlacementQuestionV1 question,
    String optionId,
  ) {
    final selectedIds = Set<String>.from(
      _placementAnswerIds[question.questionId] ?? const <String>{},
    );
    if (!question.allowsMultiple) {
      _placementAnswerIds[question.questionId] = <String>{optionId};
      return;
    }
    if (selectedIds.contains(optionId)) {
      selectedIds.remove(optionId);
    } else {
      selectedIds.add(optionId);
    }
    if (selectedIds.isEmpty) {
      _placementAnswerIds.remove(question.questionId);
      return;
    }
    _placementAnswerIds[question.questionId] = selectedIds;
  }

  int _placementQuestionScore(Act0PlacementQuestionV1 question) {
    final selectedIds = _placementAnswerIds[question.questionId];
    if (selectedIds == null || selectedIds.isEmpty) {
      return 0;
    }
    var score = 0;
    for (final option in question.options) {
      if (selectedIds.contains(option.optionId) && option.score > score) {
        score = option.score;
      }
    }
    return score;
  }

  Act0PlacementQuestionV1? _placementQuestionById(String questionId) {
    for (final question in _placementQuestionsV1) {
      if (question.questionId == questionId) {
        return question;
      }
    }
    return null;
  }

  List<Act0PlacementOptionV1> _selectedPlacementOptions(String questionId) {
    final question = _placementQuestionById(questionId);
    final selectedIds = _placementAnswerIds[questionId];
    if (question == null || selectedIds == null || selectedIds.isEmpty) {
      return const <Act0PlacementOptionV1>[];
    }
    return <Act0PlacementOptionV1>[
      for (final option in question.options)
        if (selectedIds.contains(option.optionId)) option,
    ];
  }

  bool _placementHasSelection(String questionId, String optionId) {
    final selectedIds = _placementAnswerIds[questionId];
    if (selectedIds == null || selectedIds.isEmpty) {
      return false;
    }
    return selectedIds.contains(optionId);
  }

  String _placementPrimaryLabel(String questionId, String fallback) {
    final options = _selectedPlacementOptions(questionId);
    if (options.isEmpty) {
      return fallback;
    }
    return options.first.label;
  }

  String _placementJoinedLabels(String questionId, String fallback) {
    final labels = <String>[
      for (final option in _selectedPlacementOptions(questionId))
        option.label.toLowerCase(),
    ];
    if (labels.isEmpty) {
      return fallback;
    }
    if (labels.length == 1) {
      return labels.first;
    }
    if (labels.length == 2) {
      return '${labels.first} + ${labels.last}';
    }
    return '${labels.sublist(0, labels.length - 1).join(', ')}, and ${labels.last}';
  }

  String _placementCoachingRead() {
    if (_placementHasSelection('goal', 'guided') &&
        _placementHasSelection('goal', 'daily_plan')) {
      return 'a guided path with one clear daily step';
    }
    if (_placementHasSelection('goal', 'guided')) {
      return 'a guided start before heavier drills';
    }
    if (_placementHasSelection('goal', 'diagnose')) {
      return 'fast leak-finding with close repairs';
    }
    if (_placementHasSelection('goal', 'practice')) {
      return 'tight repetitions once the concept is visible';
    }
    return 'a calm, progressive beginner path';
  }

  String _placementConfusionRead() {
    return _placementJoinedLabels('confidence', 'rules, blinds, and turns');
  }

  String _placementFormatRead() {
    return _placementJoinedLabels('format', 'learn the game from scratch');
  }

  String _placementExperienceRead() {
    if (_placementHasSelection('experience', 'new')) {
      return 'fresh start with little table repetition';
    }
    if (_placementHasSelection('experience', 'friends')) {
      return 'light real-world exposure that still needs structure';
    }
    if (_placementHasSelection('experience', 'online')) {
      return 'real table exposure and enough comfort to move faster';
    }
    return 'an early-stage poker profile';
  }

  String _placementRhythmRead() {
    if (_placementHasSelection('frequency', 'often')) {
      return 'current repetition is high enough for faster action reps';
    }
    if (_placementHasSelection('frequency', 'weekly')) {
      return 'you have some rhythm, but fundamentals still need anchoring';
    }
    return 'the app should assume low repetition and explain the table cleanly';
  }

  String _placementReportHeadline(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 'Foundation before decisions',
      Act0PlacementResultLevelV1.rustyBeginner => 'Lock hand flow before speed',
      Act0PlacementResultLevelV1.readyForBasics =>
        'Move into actions, keep structure close',
    };
  }

  String _placementReportBody(Act0PlacementResultLevelV1 level) {
    final confusion = _placementConfusionRead();
    final coaching = _placementCoachingRead();
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer =>
        'This does not read like a strategy gap. It reads like a table-model gap: $confusion should become obvious before Sharky asks for real decisions. The best fit is $coaching.',
      Act0PlacementResultLevelV1.rustyBeginner =>
        'You already have enough exposure to skip a full reset, but the risk is guessing through the hand. Sharky should stabilize the flow first, especially around $confusion, then speed up.',
      Act0PlacementResultLevelV1.readyForBasics =>
        'You show enough comfort to start on actions instead of spending too long on table setup. The main goal is to make $confusion feel automatic while Sharky keeps the structure visible.',
    };
  }

  String _placementCoachTitle(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 'Sharky says',
      Act0PlacementResultLevelV1.rustyBeginner => 'Sharky says',
      Act0PlacementResultLevelV1.readyForBasics => 'Sharky says',
    };
  }

  String _placementCoachLine(Act0PlacementResultLevelV1 level) {
    final confusion = _placementConfusionRead();
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer =>
        'You do not need harder strategy yet. First I want to make $confusion feel calm and obvious.',
      Act0PlacementResultLevelV1.rustyBeginner =>
        'You already have enough exposure. Now I want to stop the hand from feeling blurry before decisions speed up.',
      Act0PlacementResultLevelV1.readyForBasics =>
        'You are ready to move into action language, but I will still keep structure visible while your reads settle.',
    };
  }

  String _placementProfileSummary(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer =>
        'Base stats seeded from placement. More traits unlock as you play real spots.',
      Act0PlacementResultLevelV1.rustyBeginner =>
        'This is an early read, not a final judgment. The profile will tighten as your runs grow.',
      Act0PlacementResultLevelV1.readyForBasics =>
        'Core stats are seeded now. More specific reads like 3-bet and blind defense will calibrate later.',
    };
  }

  List<String> _placementProfileSignals(Act0PlacementResultLevelV1 level) {
    final signals = <String>[
      switch (level) {
        Act0PlacementResultLevelV1.newPlayer => 'Foundation start',
        Act0PlacementResultLevelV1.rustyBeginner => 'Bridge to action',
        Act0PlacementResultLevelV1.readyForBasics => 'Action-ready entry',
      },
      _placementPrimaryLabel('experience', 'New'),
      _placementPrimaryLabel('frequency', 'Rarely'),
      if (_placementHasSelection('format', 'home_games'))
        'Home-game confidence',
      if (_placementHasSelection('format', 'cash')) 'Cash-game examples',
      if (_placementHasSelection('format', 'tournaments'))
        'Tournament examples',
      if (_placementHasSelection('goal', 'daily_plan')) 'Daily plan friendly',
      if (_placementHasSelection('goal', 'diagnose')) 'Leak-finding bias',
      if (_placementHasSelection('goal', 'guided')) 'Guided coaching',
    ];
    return signals;
  }

  List<String> _placementAnalysisHighlights(Act0PlacementResultLevelV1 level) {
    return <String>[
      'Experience read: ${_placementExperienceRead()}.',
      'Current rhythm: ${_placementRhythmRead()}.',
      'Main friction area: ${_placementConfusionRead()}.',
      'Preferred use case: ${_placementFormatRead()}.',
      'Best coaching fit: ${_placementCoachingRead()}.',
      if (level == Act0PlacementResultLevelV1.readyForBasics)
        'Diagnostic confirms enough table comfort to begin with action vocabulary.',
      if (level == Act0PlacementResultLevelV1.rustyBeginner)
        'Diagnostic says the foundation exists, but the hand still needs a cleaner mental map.',
      if (level == Act0PlacementResultLevelV1.newPlayer)
        'Diagnostic says the app should teach the table itself before faster decision reps.',
    ];
  }

  List<Act0PlacementSkillStatV1> _placementSkillStats(
    Act0PlacementResultLevelV1 level,
  ) {
    var tableFlow = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 24,
      Act0PlacementResultLevelV1.rustyBeginner => 46,
      Act0PlacementResultLevelV1.readyForBasics => 62,
    };
    var handReading = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 18,
      Act0PlacementResultLevelV1.rustyBeginner => 40,
      Act0PlacementResultLevelV1.readyForBasics => 56,
    };
    var actionDecisions = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 10,
      Act0PlacementResultLevelV1.rustyBeginner => 30,
      Act0PlacementResultLevelV1.readyForBasics => 68,
    };
    var pressureControl = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 8,
      Act0PlacementResultLevelV1.rustyBeginner => 24,
      Act0PlacementResultLevelV1.readyForBasics => 38,
    };

    if (_placementHasSelection('confidence', 'rules')) {
      tableFlow -= 10;
    }
    if (_placementHasSelection('confidence', 'cards')) {
      handReading -= 8;
    }
    if (_placementHasSelection('confidence', 'board')) {
      handReading -= 6;
    }
    if (_placementHasSelection('confidence', 'decisions')) {
      actionDecisions -= 10;
    }
    if (_placementHasSelection('confidence', 'pressure')) {
      pressureControl -= 10;
    }
    if (_placementHasSelection('experience', 'online')) {
      actionDecisions += 6;
      tableFlow += 4;
    }
    if (_placementHasSelection('experience', 'friends') ||
        _placementHasSelection('experience', 'watching')) {
      handReading += 4;
    }

    int clampStat(int value) => value.clamp(8, 82);

    final tableSense = tableFlow + 2;
    final boardReading = handReading - 6;
    final handReadingScore = handReading;
    final bettingDecisions = actionDecisions + (pressureControl ~/ 2);
    final positionPlay = tableFlow - 12;
    final blindPlay = ((tableFlow + pressureControl) ~/ 2) - 10;

    return <Act0PlacementSkillStatV1>[
      Act0PlacementSkillStatV1.core(
        label: 'Table sense',
        value: clampStat(tableSense),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Board reading',
        value: clampStat(boardReading),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Hand reading',
        value: clampStat(handReadingScore),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Betting decisions',
        value: clampStat(bettingDecisions),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Position play',
        value: clampStat(positionPlay),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Blind play',
        value: clampStat(blindPlay),
      ),
    ];
  }

  List<String> _placementFirstSessionPlan(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => <String>[
        'Session 1: meet the table, seats, chips, and the goal of a hand.',
        'Session 2: walk through one full beginner hand without pressure.',
        'Session 3: confirm blinds, turns, and simple table cues in a short check.',
      ],
      Act0PlacementResultLevelV1.rustyBeginner => <String>[
        'Session 1: rebuild preflop-to-river flow so the hand stops feeling fuzzy.',
        'Session 2: reinforce streets and what changes after the flop.',
        'Session 3: hand off into action basics once the flow stays stable.',
      ],
      Act0PlacementResultLevelV1.readyForBasics => <String>[
        'Session 1: anchor legal actions and when each option is available.',
        'Session 2: connect action words to seat order and pressure.',
        'Session 3: turn misses into repair reps instead of replaying the whole intro.',
      ],
    };
  }

  void _startTaskByIds(
    Act0WorldCardV1 selectedWorld,
    String lessonId,
    String taskId,
  ) {
    final lesson = _lessonById(selectedWorld.lessons, lessonId);
    if (!lesson.isSelectable || !_taskAvailable(lesson, taskId)) {
      return;
    }
    final task = _taskById(lesson, taskId);
    _selectedWorldId = selectedWorld.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = task.taskId;
    _tab = Act0ShellTabV1.play;
    _showPlayHub = false;
    _returnToPlayHubOnBack = true;
    _activePracticeGroupId = null;
    _phase = task.phase;
    _selectedOptionId = null;
    _teachingStepIndex = 0;
    _blockCompletionSummary = null;
  }

  void _recordAnswer(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
    Act0RunnerOptionV1 option,
  ) {
    if (_activePracticeGroupId == 'daily') {
      _dailyCompletedTaskIds.add(selectedTask.taskId);
    }
    final category = _categoryForLesson(selectedLesson.lessonId);
    final contextLabels = _repairContextLabels(selectedTask.runner, option);
    if (option.isCorrect) {
      _incrementSkillStatsForCorrectAnswer(selectedLesson, selectedTask);
      _cleanTaskIds.add(selectedTask.taskId);
      _lessonRunPendingRetryTaskIds.remove(selectedTask.taskId);
      if (_mistakeRecords.containsKey(selectedTask.taskId)) {
        _resolvedMistakeTaskIds.add(selectedTask.taskId);
        if (_activeRepairTaskId != selectedTask.taskId &&
            _lessonRunRetriedTaskIds.contains(selectedTask.taskId)) {
          _lessonRunQuickFixTaskIds.add(selectedTask.taskId);
          _lessonRunDeepLeakTaskIds.remove(selectedTask.taskId);
        }
      }
      return;
    }
    _lessonRunMistakeTaskIds.add(selectedTask.taskId);
    if (_activeRepairTaskId != selectedTask.taskId &&
        !_lessonRunRetriedTaskIds.contains(selectedTask.taskId)) {
      _lessonRunPendingRetryTaskIds.add(selectedTask.taskId);
    } else if (_activeRepairTaskId != selectedTask.taskId &&
        _lessonRunRetriedTaskIds.contains(selectedTask.taskId)) {
      _lessonRunDeepLeakTaskIds.add(selectedTask.taskId);
      _lessonRunQuickFixTaskIds.remove(selectedTask.taskId);
    }
    _resolvedMistakeTaskIds.remove(selectedTask.taskId);
    final previous = _mistakeRecords[selectedTask.taskId];
    _mistakeRecords[selectedTask.taskId] = _Act0MistakeRecordV1(
      taskId: selectedTask.taskId,
      lessonId: selectedLesson.lessonId,
      title: selectedTask.title,
      weaknessLabel: category,
      selectedOptionId: option.id,
      selectedLabel: option.label,
      betterLabel: option.betterAnswerLabel,
      reason: _hardenMistakeReason(
        rawReason: option.feedbackReason,
        betterLabel: option.betterAnswerLabel,
        contextLabels: contextLabels,
      ),
      contextLabels: contextLabels,
      repairActionLabel: _repairActionLabel(selectedTask),
      attempts: (previous?.attempts ?? 0) + 1,
    );
  }

  String _hardenMistakeReason({
    required String rawReason,
    required String betterLabel,
    required List<String> contextLabels,
  }) {
    final reason = rawReason.trim();
    final lowerReason = reason.toLowerCase();
    if (lowerReason.contains('next cue:')) {
      return reason;
    }
    final focus = contextLabels.firstWhere(
      (label) => label.trim().isNotEmpty,
      orElse: () => '',
    );
    final cue = betterLabel.trim().isEmpty
        ? (focus.isEmpty
              ? 'Next cue: compare seat, pressure, and legal actions before you continue.'
              : 'Next cue: check $focus, then compare seat, pressure, and legal actions.')
        : (focus.isEmpty
              ? 'Next cue: pause on seat and pressure, then choose $betterLabel.'
              : 'Next cue: check $focus, then choose $betterLabel.');
    if (reason.isEmpty) {
      return cue;
    }
    return '$reason $cue';
  }

  bool _shouldRetryInsideLesson(
    Act0LessonTaskV1 selectedTask,
    Act0RunnerStateV1 runner,
  ) {
    final selectedOption = runner.selectedOption;
    if (selectedOption == null || selectedOption.isCorrect) {
      return false;
    }
    if (_activeRepairTaskId == selectedTask.taskId ||
        _placementDiagnosticActive) {
      return false;
    }
    return _lessonRunPendingRetryTaskIds.contains(selectedTask.taskId) &&
        !_lessonRunRetriedTaskIds.contains(selectedTask.taskId);
  }

  void _startInsideLessonRetry(
    Act0LessonTaskV1 selectedTask,
    Act0RunnerStateV1 runner,
  ) {
    _lessonRunPendingRetryTaskIds.remove(selectedTask.taskId);
    _lessonRunRetriedTaskIds.add(selectedTask.taskId);
    _selectedOptionId = null;
    _phase = runner.options.isEmpty
        ? selectedTask.phase
        : Act0LessonPhaseV1.drill;
    _teachingStepIndex = runner.teachingSteps.length;
  }

  String _repairActionLabel(Act0LessonTaskV1 task) {
    return switch (task.stepKind) {
      Act0LessonStepKindV1.learn => 'Replay the concept slowly',
      Act0LessonStepKindV1.practice => 'Replay this practice spot',
      Act0LessonStepKindV1.fixMistakes => 'Repair the weak spot',
      Act0LessonStepKindV1.review => 'Review the takeaway',
      Act0LessonStepKindV1.proveIt => 'Prove it again',
    };
  }

  List<String> _repairContextLabels(
    Act0RunnerStateV1 runner,
    Act0RunnerOptionV1 option,
  ) {
    if (option.repairFocusLabels.isNotEmpty) {
      return option.repairFocusLabels;
    }
    return <String>[
      if (runner.table.centerLabel.isNotEmpty) runner.table.centerLabel,
      if (runner.table.potLabel.isNotEmpty) runner.table.potLabel,
      if (runner.table.toCallLabel.isNotEmpty) runner.table.toCallLabel,
    ];
  }

  Act0RunnerStateV1 _repairRunnerForTask(Act0LessonTaskV1 selectedTask) {
    final record = _activeRepairTaskId == selectedTask.taskId
        ? _mistakeRecords[selectedTask.taskId]
        : null;
    if (record == null) {
      return selectedTask.runner;
    }
    final option = _optionById(
      selectedTask.runner.options,
      record.selectedOptionId,
    );
    final focusLabels = option == null
        ? record.contextLabels
        : _repairContextLabels(selectedTask.runner, option);
    final focusTable = option == null
        ? selectedTask.runner.table
        : _repairFocusedTable(selectedTask.runner.table, option, record);
    return selectedTask.runner.copyWith(
      sharky: selectedTask.runner.sharky.copyWith(
        preSessionLine: selectedTask.runner.sharky.repairLine,
        preSessionMood: Act0SharkyMoodV1.repair,
      ),
      table: focusTable,
      teachingSteps: <Act0TeachingStepV1>[
        Act0TeachingStepV1(
          title: 'Repair this spot',
          body:
              'You chose ${record.selectedLabel}. Better: ${record.betterLabel}.',
          table: focusTable,
          focusSeatIds: option?.repairFocusSeatIds ?? const <String>[],
          focusCardIds: option?.repairFocusCardIds ?? const <String>[],
          focusLabels: focusLabels,
          ctaLabel: 'Practice',
        ),
        ...selectedTask.runner.teachingSteps,
      ],
    );
  }

  Act0RunnerOptionV1? _optionById(
    List<Act0RunnerOptionV1> options,
    String optionId,
  ) {
    for (final option in options) {
      if (option.id == optionId) {
        return option;
      }
    }
    return null;
  }

  Act0TableStateV1 _repairFocusedTable(
    Act0TableStateV1 table,
    Act0RunnerOptionV1 option,
    _Act0MistakeRecordV1 record,
  ) {
    return table.copyWith(
      highlightedSeatIds: option.repairFocusSeatIds.isEmpty
          ? table.highlightedSeatIds
          : option.repairFocusSeatIds,
      highlightedCardIds: option.repairFocusCardIds.isEmpty
          ? table.highlightedCardIds
          : option.repairFocusCardIds,
      focusCalloutLabel:
          'Repair: ${record.selectedLabel} misses this. Better: ${record.betterLabel}.',
    );
  }

  Act0ReviewStateV1 _reviewState(Act0ReviewStateV1 base) {
    final open = _openMistakes();
    final fixed = _fixedMistakes();
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    return Act0ReviewStateV1(
      title: 'Repair board',
      subtitle: recommendation.subtitle,
      weaknessLabel: open.isEmpty
          ? base.weaknessLabel
          : open.first.weaknessLabel,
      reason: open.isEmpty ? base.reason : open.first.reason,
      stats: <Act0ReviewStatV1>[
        Act0ReviewStatV1(label: 'Open', value: '${open.length}'),
        Act0ReviewStatV1(label: 'Deep', value: '${_deepLeakMistakes().length}'),
        Act0ReviewStatV1(
          label: 'Quick',
          value: '${_quickFixMistakes().length}',
        ),
        Act0ReviewStatV1(label: 'Fixed', value: '${fixed.length}'),
        Act0ReviewStatV1(
          label: 'Strong',
          value: '${_strongCategories().length}',
        ),
      ],
      chosenLabel: open.isEmpty ? base.chosenLabel : open.first.selectedLabel,
      betterLabel: open.isEmpty ? base.betterLabel : open.first.betterLabel,
      mistakes: open,
      fixedMistakes: fixed,
      strongSpots: _strongCategories(),
    );
  }

  Act0ProfileStateV1 _profileState(
    Act0ProfileStateV1 base,
    _Act0ProgressSnapshotV1 progress,
  ) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    final totalTasks = _allLessons().fold<int>(
      0,
      (count, lesson) => count + lesson.taskList.length,
    );
    final completedCount = _completedTaskIds.length.clamp(0, totalTasks);
    final wrongAttempts = _mistakeRecords.values.fold<int>(
      0,
      (count, mistake) => count + mistake.attempts,
    );
    final totalAttempts = _cleanTaskIds.length + wrongAttempts;
    final accuracy = totalAttempts == 0
        ? base.accuracyLine
        : '${((_cleanTaskIds.length / totalAttempts) * 100).round()}% practice accuracy';
    final streakDays = _effectiveStreakDays(state);
    final streakSaved = _streakSaveEarned();
    return Act0ProfileStateV1(
      playerName: base.playerName,
      level: 'Level ${progress.level}',
      xpLine:
          '${progress.xp} / ${(widget.state ?? Act0ShellStateV1.sample).xpTarget} XP',
      lessonsLine: '$completedCount of $totalTasks tasks complete',
      accuracyLine: accuracy,
      streakLine: streakDays == 0
          ? 'No streak yet'
          : streakSaved
          ? (streakDays == 1
                ? '1 day streak · saved today'
                : '$streakDays day streak · saved today')
          : (streakDays == 1 ? '1 day streak' : '$streakDays day streak'),
      streakDays: streakDays,
      consistencyActiveDays: base.consistencyActiveDays,
      achievements: <Act0AchievementV1>[
        Act0AchievementV1(
          label: 'First table read',
          locked: completedCount == 0,
        ),
        Act0AchievementV1(label: 'Three day streak', locked: streakDays < 3),
        Act0AchievementV1(
          label: 'Repair queue clear',
          locked: _openMistakes().isNotEmpty,
        ),
        Act0AchievementV1(label: 'Streak save earned', locked: !streakSaved),
        Act0AchievementV1(
          label: 'Clean practice run',
          locked: _cleanTaskIds.length < 3,
        ),
      ],
      strongCategories: _strongCategories(),
      weakCategories: _weakCategories(),
      recentProgress: _recentProgress(),
      recentSkillGains: _profileRecentSkillGains(base.recentSkillGains),
      skillStats: _profileSkillStats(base.skillStats),
      streakLast7: base.streakLast7,
      recommendedFocusTitle: recommendation.title,
      recommendedFocusBody: recommendation.subtitle,
      recommendedFocusCtaLabel: recommendation.ctaLabel,
      worldsClearedCount: _progressedWorlds(
        state,
      ).where((w) => w.status == Act0WorldStateV1.completed).length,
      worldsActiveCount: _progressedWorlds(
        state,
      ).where((w) => w.status == Act0WorldStateV1.current).length,
      totalWorldsCount: _progressedWorlds(state).length,
      mistakesFixedLine: _resolvedMistakeTaskIds.isEmpty
          ? ''
          : 'Fixed ${_resolvedMistakeTaskIds.length} mistake${_resolvedMistakeTaskIds.length == 1 ? '' : 's'}',
    );
  }

  Act0MistakeCardV1? _topOpenMistake() {
    final open = _openMistakes();
    return open.isEmpty ? null : open.first;
  }

  List<Act0MistakeCardV1> _openMistakes() {
    final open = <Act0MistakeCardV1>[
      for (final record in _mistakeRecords.values)
        if (!_resolvedMistakeTaskIds.contains(record.taskId)) record.toCard(),
    ];
    open.sort((a, b) {
      final priority = _mistakePriority(b).compareTo(_mistakePriority(a));
      if (priority != 0) {
        return priority;
      }
      return a.taskId.compareTo(b.taskId);
    });
    return open;
  }

  int _mistakePriority(Act0MistakeCardV1 mistake) {
    final severity = switch (mistake.severityLabel) {
      'Deep leak' => 300,
      'Needs repair' => 200,
      'Quick fix' => 100,
      _ => 0,
    };
    return severity + mistake.attempts.clamp(0, 99);
  }

  List<Act0MistakeCardV1> _fixedMistakes() => [
    for (final record in _mistakeRecords.values)
      if (_resolvedMistakeTaskIds.contains(record.taskId))
        record.toCard(resolved: true),
  ];

  List<Act0MistakeCardV1> _quickFixMistakes() => [
    for (final mistake in _fixedMistakes())
      if (mistake.severityLabel == 'Quick fix') mistake,
  ];

  List<Act0MistakeCardV1> _deepLeakMistakes() => [
    for (final mistake in _openMistakes())
      if (mistake.severityLabel == 'Deep leak') mistake,
  ];

  List<String> _strongCategories() {
    final categories = <String>{};
    for (final taskId in _cleanTaskIds) {
      if (_mistakeRecords.containsKey(taskId) &&
          !_resolvedMistakeTaskIds.contains(taskId)) {
        continue;
      }
      final lesson = _lessonForTaskId(taskId);
      if (lesson != null) {
        categories.add(_categoryForLesson(lesson.lessonId));
      }
    }
    return categories.take(4).toList();
  }

  List<String> _weakCategories() {
    final categories = <String>{};
    for (final mistake in _openMistakes()) {
      categories.add(mistake.weaknessLabel);
    }
    return categories.take(4).toList();
  }

  List<String> _recentProgress() {
    final items = <String>[];
    for (final taskId in _completedTaskIds.toList().reversed) {
      final task = _taskForId(taskId);
      if (task != null) {
        items.add(task.title);
      }
      if (items.length == 4) {
        break;
      }
    }
    return items;
  }

  void _seedProfileSkillStats(List<Act0PlacementSkillStatV1> stats) {
    for (final stat in stats) {
      _profileSkillValues[_canonicalSkillLabel(stat.label)] = stat.value;
    }
  }

  void _incrementSkillStatsForCorrectAnswer(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    final deltas = _skillDeltaForAnswer(selectedLesson, selectedTask);
    for (final entry in deltas.entries) {
      final current = _profileSkillValues[entry.key] ?? 0;
      _profileSkillValues[entry.key] = (current + entry.value).clamp(0, 99);
      _pushRecentSkillGain(
        label: entry.key,
        gain: entry.value,
        source: selectedTask.title,
      );
    }
  }

  Map<String, int> _skillDeltaForTask(String lessonId, String taskId) {
    return switch (lessonId) {
      'what_poker_is' => <String, int>{'Table sense': 5},
      'your_first_hand' => <String, int>{'Board reading': 3, 'Hand reading': 3},
      'fold_check_call_raise' => <String, int>{
        'Betting decisions': 4,
        'Table sense': 1,
      },
      'blinds_action_order' => <String, int>{'Blind play': 4, 'Table sense': 2},
      'positions' => <String, int>{'Position play': 4, 'Table sense': 2},
      'hand_rankings_table' => <String, int>{'Hand reading': 4},
      'showdown_winning' => <String, int>{
        'Hand reading': 4,
        'Board reading': 1,
      },
      _ =>
        taskId.contains('blind')
            ? <String, int>{'Blind play': 3}
            : <String, int>{'Table sense': 2},
    };
  }

  Map<String, int> _skillDeltaForAnswer(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    final deltas = <String, int>{
      ..._skillDeltaForTask(selectedLesson.lessonId, selectedTask.taskId),
    };

    final question = selectedTask.runner.question.toLowerCase();
    final title = selectedTask.title.toLowerCase();
    final signals = <String>[
      selectedTask.runner.question,
      selectedTask.title,
      selectedTask.summary ?? '',
      ...selectedTask.runner.reviewContextLabels,
    ].join(' ').toLowerCase();

    void bump(String label, int amount) {
      deltas[label] = (deltas[label] ?? 0) + amount;
    }

    if (question.contains('seat') ||
        question.contains('button') ||
        question.contains('utg') ||
        question.contains('cutoff') ||
        title.contains('seat')) {
      bump('Position play', 2);
      bump('Table sense', 1);
    }

    if (signals.contains('blind') || question.contains('bb')) {
      bump('Blind play', 2);
      bump('Table sense', 1);
    }

    if (question.contains('flop') ||
        question.contains('turn') ||
        question.contains('river') ||
        question.contains('board') ||
        signals.contains('board cards')) {
      bump('Board reading', 2);
    }

    if (question.contains('hand ranks') ||
        question.contains('hand is stronger') ||
        question.contains('ranks higher') ||
        question.contains('showdown')) {
      bump('Hand reading', 2);
    }

    if (question.contains('action') ||
        question.contains('check') ||
        question.contains('call') ||
        question.contains('raise') ||
        question.contains('fold')) {
      bump('Betting decisions', 2);
    }

    if (signals.contains('to call') ||
        signals.contains('pot') ||
        signals.contains('hero acts')) {
      bump('Betting decisions', 1);
    }

    return deltas;
  }

  void _pushRecentSkillGain({
    required String label,
    required int gain,
    required String source,
  }) {
    _recentSkillGains.insert(
      0,
      Act0SkillGainV1(label: label, gain: gain, source: source),
    );
    if (_recentSkillGains.length > 6) {
      _recentSkillGains.removeRange(6, _recentSkillGains.length);
    }
  }

  List<Act0SkillGainV1> _profileRecentSkillGains(
    List<Act0SkillGainV1> baseGains,
  ) {
    return _recentSkillGains.isEmpty
        ? baseGains
        : _recentSkillGains.take(4).toList();
  }

  List<Act0PlacementSkillStatV1> _profileSkillStats(
    List<Act0PlacementSkillStatV1> baseStats,
  ) {
    const statOrder = <String>[
      'Table sense',
      'Board reading',
      'Hand reading',
      'Betting decisions',
      'Position play',
      'Blind play',
    ];

    final seededValues = <String, int>{
      for (final stat in baseStats)
        _canonicalSkillLabel(stat.label): stat.value,
      ..._profileSkillValues,
    };

    return <Act0PlacementSkillStatV1>[
      for (final label in statOrder)
        Act0PlacementSkillStatV1.core(
          label: label,
          value: seededValues[label] ?? 0,
          locked: !seededValues.containsKey(label),
        ),
    ];
  }

  String _canonicalSkillLabel(String label) {
    return switch (label) {
      'Situational awareness' || 'Hand flow' || 'Table flow' => 'Table sense',
      'Action decisions' ||
      'Betting choices' ||
      'Calm under pressure' => 'Betting decisions',
      'Blind defense' || '3-bet pots' || '3-bet game' => 'Blind play',
      'Showdown reading' => 'Hand reading',
      _ => label,
    };
  }

  List<Act0LessonCardV1> _allLessons() => [
    for (final world in (widget.state ?? Act0ShellStateV1.sample).worlds)
      ...world.lessons,
  ];

  Act0LessonCardV1? _lessonForTaskId(String taskId) {
    for (final lesson in _allLessons()) {
      if (lesson.taskList.any((task) => task.taskId == taskId)) {
        return lesson;
      }
    }
    return null;
  }

  Act0LessonTaskV1? _taskForId(String taskId) {
    final lesson = _lessonForTaskId(taskId);
    if (lesson == null) {
      return null;
    }
    return lesson.taskList.firstWhere(
      (task) => task.taskId == taskId,
      orElse: () => lesson.taskList.first,
    );
  }

  String _categoryForLesson(String lessonId) {
    return switch (lessonId) {
      'what_poker_is' => 'Table',
      'cards_ranks_suits' => 'Cards',
      'your_first_hand' => 'Streets',
      'fold_check_call_raise' => 'Actions',
      'blinds_action_order' => 'Blinds',
      'positions' => 'Positions',
      'hand_rankings_table' => 'Rankings',
      'showdown_winning' => 'Showdown',
      _ => 'Practice',
    };
  }

  Act0WorldCardV1 _progressWorld(
    Act0WorldCardV1 world,
    bool previousWorldComplete, {
    required bool isImmediateLockedWorld,
    Set<String>? completedTaskIds,
  }) {
    final progressTaskIds = completedTaskIds ?? _completedTaskIds;
    if (world.lessons.isEmpty) {
      return world.copyWith(
        status: previousWorldComplete
            ? Act0WorldStateV1.current
            : Act0WorldStateV1.locked,
        isSelectable: previousWorldComplete,
        isLocked: !previousWorldComplete,
      );
    }
    final allComplete = world.lessons.every(
      (lesson) => _lessonCompleteWithTaskIds(lesson, progressTaskIds),
    );
    final available = previousWorldComplete;
    final currentLessonId = available && !allComplete
        ? world.lessons
              .firstWhere(
                (lesson) =>
                    !_lessonCompleteWithTaskIds(lesson, progressTaskIds),
              )
              .lessonId
        : null;
    final lessons = [
      for (final lesson in world.lessons)
        _progressLesson(
          lesson,
          worldAvailable: available,
          currentLessonId: currentLessonId,
          completedTaskIds: progressTaskIds,
        ),
    ];
    final completedCount = lessons
        .where((lesson) => lesson.state == Act0LessonStateV1.completed)
        .length;
    final status = !available
        ? Act0WorldStateV1.locked
        : allComplete
        ? Act0WorldStateV1.completed
        : Act0WorldStateV1.current;
    return world.copyWith(
      status: status,
      progressLabel: !available
          ? act0LockedWorldProgressLabelV1(
              isImmediateNext: isImmediateLockedWorld,
            )
          : allComplete
          ? '${lessons.length} of ${lessons.length} lessons complete'
          : '$completedCount of ${lessons.length} lessons complete',
      primaryCtaLabel: !available
          ? act0LockedWorldPrimaryCtaLabelV1(
              isImmediateNext: isImmediateLockedWorld,
            )
          : allComplete
          ? 'Replay lessons'
          : 'Open lessons',
      unlockLabel: available ? 'Available now' : world.unlockLabel,
      isSelectable: available,
      isLocked: !available,
      lessons: lessons,
    );
  }

  Act0LessonCardV1 _progressLesson(
    Act0LessonCardV1 lesson, {
    required bool worldAvailable,
    required String? currentLessonId,
    Set<String>? completedTaskIds,
  }) {
    final completed = _lessonCompleteWithTaskIds(
      lesson,
      completedTaskIds ?? _completedTaskIds,
    );
    final current = lesson.lessonId == currentLessonId;
    final state = completed
        ? Act0LessonStateV1.completed
        : current
        ? Act0LessonStateV1.current
        : Act0LessonStateV1.locked;
    return lesson.copyWith(
      state: state,
      primaryCtaLabel: completed
          ? 'Replay'
          : current
          ? 'Start +${lesson.rewardXp} XP'
          : 'Locked',
      isSelectable: worldAvailable && (completed || current),
      isLocked: !worldAvailable || state == Act0LessonStateV1.locked,
    );
  }

  void _completeCurrentTask(Act0LessonTaskV1 selectedTask) {
    final alreadyCompleted = _completedTaskIds.contains(_selectedTaskId);
    _skippedTaskIds.remove(_selectedTaskId);
    _visibleSkippedTaskIds.remove(_selectedTaskId);
    _completedTaskIds.add(_selectedTaskId);
    if (!alreadyCompleted) {
      _earnedXp += selectedTask.rewardXp;
      _lessonRunXp += selectedTask.rewardXp;
    }
    final worlds = _progressWorlds(widget.state ?? Act0ShellStateV1.sample);
    final world = _worldById(worlds, _selectedWorldId);
    final lesson = _lessonById(world.lessons, _selectedLessonId);
    if (_lessonComplete(lesson)) {
      _completedLessonIds.add(lesson.lessonId);
    }
    _persistProgress();
  }

  bool _advanceTeachingStep(Act0RunnerStateV1 runner) {
    if (_teachingStepIndex < runner.teachingSteps.length) {
      _teachingStepIndex += 1;
      return true;
    }
    return false;
  }

  bool _maybeShowBlockCompletionSummary({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
    required Act0LessonTaskV1 selectedTask,
  }) {
    if (widget.tableVisualVariant !=
        Act0ShellTableVisualVariantV1.refinedDev2) {
      return false;
    }
    if (_nextTask(selectedLesson, _selectedTaskId) != null) {
      return false;
    }
    _blockCompletionSummary = Act0BlockCompletionSummaryV1(
      lessonTitle: selectedLesson.title,
      xpEarned: _lessonRunXp,
      errorCount: _lessonRunMistakeTaskIds.length,
      taskCount: selectedLesson.taskList.length,
      correctCount:
          (selectedLesson.taskList.length - _lessonRunMistakeTaskIds.length)
              .clamp(0, selectedLesson.taskList.length),
      startLevel: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp - _lessonRunXp,
      ).level,
      endLevel: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp,
      ).level,
      startXp: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp - _lessonRunXp,
      ).xp,
      endXp: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp,
      ).xp,
      xpTarget: (widget.state ?? Act0ShellStateV1.sample).xpTarget,
      sharkyLine: selectedTask.runner.sharky.summaryLine,
      nextLessonTitle: () {
        final progressedWorlds = _progressWorlds(
          widget.state ?? Act0ShellStateV1.sample,
        );
        final nextLessonId = _nextLessonId(
          selectedWorld.lessons,
          selectedLesson.lessonId,
        );
        if (nextLessonId != null) {
          return _lessonById(
            progressedWorlds
                .firstWhere((world) => world.worldId == selectedWorld.worldId)
                .lessons,
            nextLessonId,
          ).title;
        }
        final nextWorld = _nextSelectableWorld(
          progressedWorlds,
          selectedWorld.worldId,
        );
        if (nextWorld == null) {
          return null;
        }
        return _firstPlayableLesson(nextWorld).title;
      }(),
      quickFixCount: _lessonRunQuickFixTaskIds.length,
      deepLeakCount: _lessonRunDeepLeakTaskIds.length,
    );
    _fireBlockCompletionEffects(_blockCompletionSummary!);
    return true;
  }

  void _fireAnswerEffects(Act0RunnerOptionV1 option) {
    UiSoundV1.fire(
      option.isCorrect ? UiSoundEventV1.success : UiSoundEventV1.error,
    );
    unawaited(
      UiHapticsV1.fire(
        option.isCorrect ? UiHapticEventV1.success : UiHapticEventV1.error,
      ),
    );
  }

  void _fireBlockCompletionEffects(Act0BlockCompletionSummaryV1 summary) {
    if (!summary.qualifiesForNextLesson) {
      UiSoundV1.fire(UiSoundEventV1.error);
      unawaited(UiHapticsV1.fire(UiHapticEventV1.error));
      return;
    }
    UiSoundV1.fire(UiSoundEventV1.success);
    unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
  }

  void _resetLessonRunMetrics() {
    _lessonRunXp = 0;
    _lessonRunMistakeTaskIds.clear();
    _lessonRunPendingRetryTaskIds.clear();
    _lessonRunRetriedTaskIds.clear();
    _lessonRunQuickFixTaskIds.clear();
    _lessonRunDeepLeakTaskIds.clear();
    _blockCompletionSummary = null;
  }

  void _advanceAfterTask(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    final nextTask = _nextTask(selectedLesson, _selectedTaskId);
    if (nextTask != null) {
      _selectedTaskId = nextTask.taskId;
      _phase = nextTask.phase;
      _tab = Act0ShellTabV1.play;
      _showPlayHub = false;
      _teachingStepIndex = 0;
      _persistProgress();
      return;
    }

    final progressedWorlds = _progressWorlds(
      widget.state ?? Act0ShellStateV1.sample,
    );
    var nextWorld = _worldById(progressedWorlds, selectedWorld.worldId);
    var nextLesson = _firstPlayableLesson(nextWorld);
    if (nextWorld.status == Act0WorldStateV1.completed) {
      final currentWorldIndex = progressedWorlds.indexWhere(
        (world) => world.worldId == selectedWorld.worldId,
      );
      final nextWorldIndex = currentWorldIndex + 1;
      if (nextWorldIndex < progressedWorlds.length &&
          progressedWorlds[nextWorldIndex].isSelectable) {
        nextWorld = progressedWorlds[nextWorldIndex];
        nextLesson = _firstPlayableLesson(nextWorld);
        _selectedWorldId = nextWorld.worldId;
      }
    }
    _selectedLessonId = nextLesson.lessonId;
    _selectedTaskId = _firstIncompleteTask(nextLesson).taskId;
    _phase = _taskById(nextLesson, _selectedTaskId).phase;
    _teachingStepIndex = 0;
    _tab = Act0ShellTabV1.learn;
    _learnDetailLessonId = null;
    _learnDetailWorldId = null;
    _showWorldMenu = false;
    _persistProgress();
  }

  void _normalizeSelection(List<Act0WorldCardV1> worlds) {
    final normalizedWorld = _worldById(worlds, _selectedWorldId);
    if (_selectedWorldId != normalizedWorld.worldId) {
      _selectedWorldId = normalizedWorld.worldId;
      if (_learnDetailWorldId != null &&
          _learnDetailWorldId != _selectedWorldId) {
        _learnDetailWorldId = null;
      }
    }

    final normalizedLesson =
        normalizedWorld.lessons.any(
          (lesson) => lesson.lessonId == _selectedLessonId,
        )
        ? _lessonById(normalizedWorld.lessons, _selectedLessonId)
        : _firstPlayableLesson(normalizedWorld);
    final lessonChanged = _selectedLessonId != normalizedLesson.lessonId;
    if (lessonChanged) {
      _selectedLessonId = normalizedLesson.lessonId;
      _learnDetailLessonId = null;
      _learnPopupTaskId = null;
    }

    final taskExists = normalizedLesson.taskList.any(
      (task) => task.taskId == _selectedTaskId,
    );
    final normalizedTask = taskExists
        ? _taskById(normalizedLesson, _selectedTaskId)
        : _firstIncompleteTask(normalizedLesson);
    if (_selectedTaskId != normalizedTask.taskId) {
      _selectedTaskId = normalizedTask.taskId;
      _selectedOptionId = null;
      _teachingStepIndex = 0;
      _phase = normalizedTask.phase;
    }

    if (_learnPopupTaskId != null &&
        !normalizedLesson.taskList.any(
          (task) => task.taskId == _learnPopupTaskId,
        )) {
      _learnPopupTaskId = null;
    }
  }

  Act0WorldCardV1 _worldById(List<Act0WorldCardV1> worlds, String worldId) {
    return worlds.firstWhere(
      (world) => world.worldId == worldId,
      orElse: () => worlds.first,
    );
  }

  Act0LessonCardV1 _lessonById(
    List<Act0LessonCardV1> lessons,
    String lessonId,
  ) {
    return lessons.firstWhere(
      (lesson) => lesson.lessonId == lessonId,
      orElse: () => lessons.first,
    );
  }

  Act0LessonCardV1 _firstPlayableLesson(Act0WorldCardV1 world) {
    return world.lessons.firstWhere(
      (lesson) =>
          lesson.isSelectable && lesson.state == Act0LessonStateV1.current,
      orElse: () => world.lessons.firstWhere(
        (lesson) => lesson.isSelectable,
        orElse: () => world.lessons.first,
      ),
    );
  }

  Act0LessonTaskV1 _firstIncompleteTask(Act0LessonCardV1 lesson) {
    return _firstIncompleteTaskWithTaskIds(lesson, _pathClosedTaskIds);
  }

  Act0LessonTaskV1 _firstIncompleteTaskWithTaskIds(
    Act0LessonCardV1 lesson,
    Set<String> completedTaskIds,
  ) {
    return lesson.taskList.firstWhere(
      (task) => !completedTaskIds.contains(task.taskId),
      orElse: () => lesson.taskList.first,
    );
  }

  bool _taskAvailable(Act0LessonCardV1 lesson, String taskId) {
    if (_completedTaskIds.contains(taskId)) {
      return true;
    }
    if (_skippedTaskIds.contains(taskId)) {
      return true;
    }
    return _firstIncompleteTask(lesson).taskId == taskId;
  }

  Act0LessonTaskV1 _taskById(Act0LessonCardV1 lesson, String taskId) {
    return _taskByIdWithTaskIds(lesson, taskId, _pathClosedTaskIds);
  }

  Act0LessonTaskV1 _taskByIdWithTaskIds(
    Act0LessonCardV1 lesson,
    String taskId,
    Set<String> completedTaskIds,
  ) {
    return lesson.taskList.firstWhere(
      (task) => task.taskId == taskId,
      orElse: () => _firstIncompleteTaskWithTaskIds(lesson, completedTaskIds),
    );
  }

  int _taskIndex(Act0LessonCardV1 lesson, String taskId) {
    final index = lesson.taskList.indexWhere((task) => task.taskId == taskId);
    return index < 0 ? 0 : index;
  }

  Act0LessonTaskV1? _nextTask(Act0LessonCardV1 lesson, String taskId) {
    final index = _taskIndex(lesson, taskId);
    if (index < 0 || index + 1 >= lesson.taskList.length) {
      return null;
    }
    return lesson.taskList[index + 1];
  }

  bool _lessonComplete(Act0LessonCardV1 lesson) {
    return _lessonCompleteWithTaskIds(lesson, _completedTaskIds);
  }

  bool _lessonCompleteWithTaskIds(
    Act0LessonCardV1 lesson,
    Set<String> completedTaskIds,
  ) {
    return lesson.taskList.every(
      (task) => completedTaskIds.contains(task.taskId),
    );
  }

  int _lessonIndex(List<Act0LessonCardV1> lessons, String lessonId) {
    final index = lessons.indexWhere((lesson) => lesson.lessonId == lessonId);
    return index < 0 ? 0 : index;
  }

  String? _nextLessonId(List<Act0LessonCardV1> lessons, String lessonId) {
    final index = _lessonIndex(lessons, lessonId);
    if (index < 0 || index + 1 >= lessons.length) {
      return null;
    }
    return lessons[index + 1].lessonId;
  }

  Act0WorldCardV1? _nextSelectableWorld(
    List<Act0WorldCardV1> worlds,
    String worldId,
  ) {
    final currentIndex = worlds.indexWhere((world) => world.worldId == worldId);
    if (currentIndex < 0) {
      return null;
    }
    for (var index = currentIndex + 1; index < worlds.length; index++) {
      final world = worlds[index];
      if (world.isSelectable) {
        return world;
      }
    }
    return null;
  }

  _Act0ProgressSnapshotV1 _progressSnapshot(
    Act0ShellStateV1 state, {
    int? earnedXpDelta,
  }) {
    final xpTarget = state.xpTarget <= 0 ? 1 : state.xpTarget;
    final baseLevel = _parseLevelNumber(state.levelLabel);
    final totalXp = state.xp + (earnedXpDelta ?? _earnedXp);
    return _Act0ProgressSnapshotV1(
      level: baseLevel + (totalXp ~/ xpTarget),
      xp: totalXp % xpTarget,
    );
  }

  int _parseLevelNumber(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return int.tryParse(match?.group(1) ?? '') ?? 1;
  }

  Act0ShellStateV1 _stateWithProgress(
    Act0ShellStateV1 base,
    _Act0ProgressSnapshotV1 progress,
  ) {
    final levelLabel = 'Level ${progress.level}';
    return Act0ShellStateV1(
      courseTitle: base.courseTitle,
      courseSubtitle: base.courseSubtitle,
      levelLabel: levelLabel,
      xp: progress.xp,
      xpTarget: base.xpTarget,
      streakDays: _effectiveStreakDays(base),
      dailyGoalLabel: base.dailyGoalLabel,
      dailyGoalValue: base.dailyGoalValue,
      pathProgressLabel: base.pathProgressLabel,
      selectedWorldId: base.selectedWorldId,
      worlds: base.worlds,
      lessons: base.lessons,
      review: base.review,
      profile: Act0ProfileStateV1(
        playerName: base.profile.playerName,
        level: levelLabel,
        xpLine: '${progress.xp} / ${base.xpTarget} XP',
        lessonsLine: base.profile.lessonsLine,
        accuracyLine: base.profile.accuracyLine,
        consistencyActiveDays: base.profile.consistencyActiveDays,
        achievements: base.profile.achievements,
      ),
    );
  }

  int _effectiveStreakDays(Act0ShellStateV1 base) {
    if (_persistedStreakDays > 0) {
      // Persisted streak is source of truth once the user has prior data
      final today = _todayDateString();
      if (_dailyCompletedTaskIds.length >= 3 && _lastDailyDate != today) {
        return (_persistedStreakDays + 1).clamp(0, 365);
      }
      return _persistedStreakDays;
    }
    // Fall back to state-provided streak (preview / no-prefs mode)
    return _dailyCompletedTaskIds.length >= 3
        ? (base.streakDays + 1).clamp(0, 365)
        : base.streakDays;
  }
}

class _Act0ProgressSnapshotV1 {
  const _Act0ProgressSnapshotV1({required this.level, required this.xp});

  final int level;
  final int xp;
}

class _Act0DailyDeckEntryV1 {
  const _Act0DailyDeckEntryV1({
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.isSpaced,
  });

  final String worldId;
  final String lessonId;
  final String taskId;
  final bool isSpaced;
}

class _Act0PlacementSkipPlanV1 {
  const _Act0PlacementSkipPlanV1({
    required this.taskIds,
    required this.orderedTaskIds,
  });

  final Set<String> taskIds;
  final List<String> orderedTaskIds;
}

class _Act0PersistedProgressV1 {
  const _Act0PersistedProgressV1({
    required this.completedTaskIds,
    required this.skippedTaskIds,
    required this.completedLessonIds,
    required this.selectedWorldId,
    required this.selectedLessonId,
    required this.selectedTaskId,
    required this.earnedXp,
    this.lastActiveDay = '',
    this.persistedStreakDays = 0,
    this.resumeInRunner = false,
    this.resumePhase = '',
    this.resumeTeachingStepIndex = 0,
    this.resumeSelectedOptionId,
    this.dismissedHomeHandoffKey = '',
    this.dismissedHomeHandoffDay = '',
  });

  final Set<String> completedTaskIds;
  final Set<String> skippedTaskIds;
  final Set<String> completedLessonIds;
  final String selectedWorldId;
  final String selectedLessonId;
  final String selectedTaskId;
  final int earnedXp;
  final String lastActiveDay;
  final int persistedStreakDays;
  final bool resumeInRunner;
  final String resumePhase;
  final int resumeTeachingStepIndex;
  final String? resumeSelectedOptionId;
  final String dismissedHomeHandoffKey;
  final String dismissedHomeHandoffDay;

  String toStorageString() {
    final sortedTaskIds = completedTaskIds.toList(growable: false)..sort();
    final sortedSkippedTaskIds = skippedTaskIds.toList(growable: false)..sort();
    final sortedLessonIds = completedLessonIds.toList(growable: false)..sort();
    return jsonEncode(<String, Object>{
      'schemaVersion': 5,
      'completedTaskIds': sortedTaskIds,
      'skippedTaskIds': sortedSkippedTaskIds,
      'completedLessonIds': sortedLessonIds,
      'selectedWorldId': selectedWorldId,
      'selectedLessonId': selectedLessonId,
      'selectedTaskId': selectedTaskId,
      'earnedXp': earnedXp,
      'lastActiveDay': lastActiveDay,
      'persistedStreakDays': persistedStreakDays,
      'resumeInRunner': resumeInRunner,
      'resumePhase': resumePhase,
      'resumeTeachingStepIndex': resumeTeachingStepIndex,
      'dismissedHomeHandoffKey': dismissedHomeHandoffKey,
      'dismissedHomeHandoffDay': dismissedHomeHandoffDay,
      if (resumeSelectedOptionId != null)
        'resumeSelectedOptionId': resumeSelectedOptionId!,
    });
  }

  static _Act0PersistedProgressV1? tryParse(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) {
      return null;
    }
    final map = decoded.cast<String, Object?>();
    final schemaVersion = map['schemaVersion'];
    // Accept v1-v5 as the shell snapshot evolves.
    if (schemaVersion != 1 &&
        schemaVersion != 2 &&
        schemaVersion != 3 &&
        schemaVersion != 4 &&
        schemaVersion != 5) {
      return null;
    }
    final completedTaskIds = _stringSet(map['completedTaskIds']);
    final skippedTaskIds = _stringSet(map['skippedTaskIds']);
    final completedLessonIds = _stringSet(map['completedLessonIds']);
    final selectedWorldId = (map['selectedWorldId'] ?? '').toString();
    final selectedLessonId = (map['selectedLessonId'] ?? '').toString();
    final selectedTaskId = (map['selectedTaskId'] ?? '').toString();
    final earnedXpRaw = map['earnedXp'];
    final earnedXp = earnedXpRaw is int
        ? earnedXpRaw
        : int.tryParse(earnedXpRaw?.toString() ?? '') ?? 0;
    // v2 fields — gracefully default for v1 records
    final lastActiveDay = (map['lastActiveDay'] ?? '').toString();
    final streakRaw = map['persistedStreakDays'];
    final persistedStreakDays = streakRaw is int
        ? streakRaw
        : int.tryParse(streakRaw?.toString() ?? '') ?? 0;
    final resumeInRunner = map['resumeInRunner'] == true;
    final resumePhase = (map['resumePhase'] ?? '').toString();
    final resumeTeachingStepRaw = map['resumeTeachingStepIndex'];
    final resumeTeachingStepIndex = resumeTeachingStepRaw is int
        ? resumeTeachingStepRaw
        : int.tryParse(resumeTeachingStepRaw?.toString() ?? '') ?? 0;
    final resumeSelectedOptionIdRaw = map['resumeSelectedOptionId'];
    final resumeSelectedOptionId = resumeSelectedOptionIdRaw == null
        ? null
        : resumeSelectedOptionIdRaw.toString();
    final dismissedHomeHandoffKey = (map['dismissedHomeHandoffKey'] ?? '')
        .toString();
    final dismissedHomeHandoffDay = (map['dismissedHomeHandoffDay'] ?? '')
        .toString();
    if (selectedWorldId.isEmpty ||
        selectedLessonId.isEmpty ||
        selectedTaskId.isEmpty) {
      return null;
    }
    return _Act0PersistedProgressV1(
      completedTaskIds: completedTaskIds,
      skippedTaskIds: skippedTaskIds,
      completedLessonIds: completedLessonIds,
      selectedWorldId: selectedWorldId,
      selectedLessonId: selectedLessonId,
      selectedTaskId: selectedTaskId,
      earnedXp: earnedXp < 0 ? 0 : earnedXp,
      lastActiveDay: lastActiveDay,
      persistedStreakDays: persistedStreakDays < 0 ? 0 : persistedStreakDays,
      resumeInRunner: resumeInRunner,
      resumePhase: resumePhase,
      resumeTeachingStepIndex: resumeTeachingStepIndex < 0
          ? 0
          : resumeTeachingStepIndex,
      resumeSelectedOptionId: resumeSelectedOptionId,
      dismissedHomeHandoffKey: dismissedHomeHandoffKey,
      dismissedHomeHandoffDay: dismissedHomeHandoffDay,
    );
  }

  static Set<String> _stringSet(Object? raw) {
    if (raw is! List) {
      return <String>{};
    }
    return raw
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toSet();
  }
}

class _Act0MistakeRecordV1 {
  const _Act0MistakeRecordV1({
    required this.taskId,
    required this.lessonId,
    required this.title,
    required this.weaknessLabel,
    required this.selectedOptionId,
    required this.selectedLabel,
    required this.betterLabel,
    required this.reason,
    required this.contextLabels,
    required this.repairActionLabel,
    required this.attempts,
  });

  final String taskId;
  final String lessonId;
  final String title;
  final String weaknessLabel;
  final String selectedOptionId;
  final String selectedLabel;
  final String betterLabel;
  final String reason;
  final List<String> contextLabels;
  final String repairActionLabel;
  final int attempts;

  Act0MistakeCardV1 toCard({bool resolved = false}) {
    return Act0MistakeCardV1(
      taskId: taskId,
      lessonId: lessonId,
      title: title,
      weaknessLabel: weaknessLabel,
      selectedOptionId: selectedOptionId,
      selectedLabel: selectedLabel,
      betterLabel: betterLabel,
      reason: reason,
      attempts: attempts,
      severityLabel: resolved
          ? attempts <= 1
                ? 'Quick fix'
                : 'Repaired'
          : attempts >= 2
          ? 'Deep leak'
          : 'Needs repair',
      contextLabels: contextLabels,
      repairActionLabel: repairActionLabel,
      resolved: resolved,
    );
  }
}

class _TopBarV1 extends StatelessWidget {
  const _TopBarV1({required this.state, required this.goalLabel});

  final Act0ShellStateV1 state;
  final String goalLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_top_bar'),
      height: Act0ShellTokensV1.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: Act0ShellTokensV1.pageX),
      decoration: Act0ShellTokensV1.glassDecoration(),
      child: Row(
        children: [
          Container(
            width: Act0ShellTokensV1.brandTile,
            height: Act0ShellTokensV1.brandTile,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.primary,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusSm),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Act0ShellTokensV1.primary.withValues(alpha: 0.34),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: Act0ShellTokensV1.onPrimary,
              size: 17,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Text(
            goalLabel,
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.xp} XP',
                  style: Act0ShellTokensV1.muted.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  child: LinearProgressIndicator(
                    minHeight: Act0ShellTokensV1.progressHeight,
                    value: state.xpProgress,
                    backgroundColor: Act0ShellTokensV1.surface3,
                    color: Act0ShellTokensV1.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface2,
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
              border: Border.all(color: Act0ShellTokensV1.border),
            ),
            child: Text(
              '${state.streakDays}d',
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.gold,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavV1 extends StatelessWidget {
  const _BottomNavV1({required this.current, required this.onSelected});

  final Act0ShellTabV1 current;
  final ValueChanged<Act0ShellTabV1> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('act0_shell_bottom_nav'),
      height: Act0ShellTokensV1.bottomNavHeight,
      child: DecoratedBox(
        decoration: Act0ShellTokensV1.glassDecoration(top: true),
        child: Row(
          children: [
            _NavItemV1(
              tab: Act0ShellTabV1.home,
              current: current,
              icon: Icons.home_rounded,
              label: 'Home',
              onSelected: onSelected,
            ),
            _NavItemV1(
              tab: Act0ShellTabV1.learn,
              current: current,
              icon: Icons.menu_book_rounded,
              label: 'Learn',
              onSelected: onSelected,
            ),
            _NavItemV1(
              tab: Act0ShellTabV1.play,
              current: current,
              icon: Icons.spa_rounded,
              label: 'Play',
              onSelected: onSelected,
            ),
            _NavItemV1(
              tab: Act0ShellTabV1.review,
              current: current,
              icon: Icons.refresh_rounded,
              label: 'Review',
              onSelected: onSelected,
            ),
            _NavItemV1(
              tab: Act0ShellTabV1.profile,
              current: current,
              icon: Icons.person_rounded,
              label: 'You',
              onSelected: onSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemV1 extends StatelessWidget {
  const _NavItemV1({
    required this.tab,
    required this.current,
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  final Act0ShellTabV1 tab;
  final Act0ShellTabV1 current;
  final IconData icon;
  final String label;
  final ValueChanged<Act0ShellTabV1> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = tab == current;
    final color = selected
        ? Act0ShellTokensV1.primary
        : Act0ShellTokensV1.textMuted;
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(tab),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 21, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _placementQuestionsV1 = <Act0PlacementQuestionV1>[
  Act0PlacementQuestionV1(
    questionId: 'age',
    eyebrow: 'Start with you',
    title: 'What sounds most like you right now?',
    subtitle:
        'This helps Sharky sound more like coaching and less like a setup form.',
    helper:
        'No wrong answer here. It only changes tone, pacing, and examples in the first steps.',
    icon: Icons.person_search_rounded,
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'age_18_24',
        label: 'I am brand new and want this to feel simple',
        score: 0,
        profileTag: 'NewSimple',
        subtitle: 'Keep it calm, clear, and step by step from the start.',
        icon: Icons.spa_rounded,
        badge: 'Best first start',
      ),
      Act0PlacementOptionV1(
        optionId: 'age_25_34',
        label: 'I know some words, but real hands still feel messy',
        score: 0,
        profileTag: 'KnowsSome',
        subtitle: 'Use practical examples and tighten the flow of a hand.',
        icon: Icons.hub_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'age_35_plus',
        label: 'I can follow poker, but I want sharper decisions',
        score: 0,
        profileTag: 'SharperDecisions',
        subtitle:
            'Move faster where possible, but keep the reasoning explicit.',
        icon: Icons.track_changes_rounded,
      ),
    ],
  ),
  Act0PlacementQuestionV1(
    questionId: 'experience',
    eyebrow: 'Starting point',
    title: 'Where are you starting from?',
    subtitle: 'Be honest. This only changes where Sharky should begin.',
    helper:
        'The goal is not to rank you. The goal is to avoid wasting your first sessions.',
    icon: Icons.flag_rounded,
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'new',
        label: 'I have not really played yet',
        score: 0,
        profileTag: 'New',
        subtitle: 'Start from zero and build the table language cleanly.',
        icon: Icons.school_rounded,
        badge: 'Best for zero',
      ),
      Act0PlacementOptionV1(
        optionId: 'friends',
        label: 'I played casually, mostly guessing with friends',
        score: 1,
        profileTag: 'Casual',
        subtitle:
            'You know some words, but the structure still needs tightening.',
        icon: Icons.groups_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'watching',
        label: 'I watch poker content, but real decisions still freeze me',
        score: 1,
        profileTag: 'Watching',
        subtitle:
            'Translate passive knowledge into something usable at the table.',
        icon: Icons.live_tv_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'online',
        label: 'I have played online or live and want sharper structure',
        score: 3,
        profileTag: 'Played',
        subtitle:
            'Skip part of the intro and move faster into action language.',
        icon: Icons.insights_rounded,
        badge: 'Faster start',
      ),
    ],
  ),
  Act0PlacementQuestionV1(
    questionId: 'frequency',
    eyebrow: 'Current rhythm',
    title: 'How often do you play?',
    subtitle: 'This helps Sharky choose between warm-up and sharper reps.',
    helper:
        'If poker is not in your hands often, the app should not assume hidden muscle memory.',
    icon: Icons.calendar_today_rounded,
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'rarely',
        label: 'Almost never or not yet',
        score: 0,
        profileTag: 'Rarely',
        subtitle:
            'Lean into table basics and a very clean first-hand structure.',
        icon: Icons.hourglass_bottom_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'weekly',
        label: 'On and off, some weeks yes and some weeks no',
        score: 1,
        profileTag: 'Weekly',
        subtitle:
            'There is some rhythm, but fundamentals still need anchoring.',
        icon: Icons.view_week_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'often',
        label: 'Pretty regularly',
        score: 2,
        profileTag: 'Frequent',
        subtitle:
            'You can handle tighter reps and a faster move into decisions.',
        icon: Icons.speed_rounded,
      ),
    ],
  ),
  Act0PlacementQuestionV1(
    questionId: 'format',
    eyebrow: 'Your use case',
    title: 'What do you want poker for?',
    subtitle:
        'This shapes examples, language, and the kind of situations Sharky shows first.',
    helper:
        'Choose everything that feels true right now. Sharky will look for the dominant pattern, not force a single lane.',
    icon: Icons.route_rounded,
    allowsMultiple: true,
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'basics',
        label: 'I want the game to finally make sense',
        score: 0,
        profileTag: 'Basics',
        subtitle: 'Start with table literacy before strategy words and jargon.',
        icon: Icons.menu_book_rounded,
        badge: 'Core',
      ),
      Act0PlacementOptionV1(
        optionId: 'cash',
        label: 'I want to feel confident in cash-game spots',
        score: 2,
        profileTag: 'Cash',
        subtitle:
            'Bias examples toward chips, pressure, and practical decisions.',
        icon: Icons.attach_money_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'tournaments',
        label: 'I care more about tournament decisions',
        score: 2,
        profileTag: 'Tournament',
        subtitle:
            'Bias examples toward survival, pressure, and changing leverage.',
        icon: Icons.emoji_events_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'home_games',
        label: 'I do not want to feel lost in home games',
        score: 1,
        profileTag: 'HomeGames',
        subtitle:
            'Focus on hand flow, confidence, and keeping up with the table.',
        icon: Icons.table_restaurant_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'content',
        label: 'I want poker videos and hand talk to stop sounding cryptic',
        score: 1,
        profileTag: 'Content',
        subtitle:
            'Use examples that decode table language instead of assuming it.',
        icon: Icons.subscriptions_rounded,
      ),
    ],
  ),
  Act0PlacementQuestionV1(
    questionId: 'confidence',
    eyebrow: 'Where to help first',
    title: 'What feels most confusing?',
    subtitle: 'Pick every part that makes you hesitate or guess.',
    helper:
        'Sharky will use this to bias your first explanations, review hints, and early repair spots.',
    icon: Icons.lightbulb_rounded,
    allowsMultiple: true,
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'rules',
        label: 'Knowing whose turn it is and how a hand even moves',
        score: 0,
        profileTag: 'Rules',
        subtitle:
            'You want the table flow, blinds, and action order to stop feeling fuzzy.',
        icon: Icons.account_tree_rounded,
        badge: 'Foundation',
      ),
      Act0PlacementOptionV1(
        optionId: 'cards',
        label: 'Reading cards, pairs, and hand strength fast enough',
        score: 1,
        profileTag: 'Cards',
        subtitle:
            'You want stronger recognition and more confidence at showdown.',
        icon: Icons.style_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'decisions',
        label: 'Knowing when to fold, call, or raise without second-guessing',
        score: 2,
        profileTag: 'Decisions',
        subtitle:
            'You mostly want help making the right action at the right time.',
        icon: Icons.touch_app_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'board',
        label: 'Seeing what changed on the flop, turn, or river',
        score: 1,
        profileTag: 'Board',
        subtitle: 'You want the board to feel readable instead of noisy.',
        icon: Icons.view_module_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'pressure',
        label: 'Staying clear when people bet and pressure starts building',
        score: 2,
        profileTag: 'Pressure',
        subtitle:
            'You want calmer decisions when the table stops feeling passive.',
        icon: Icons.local_fire_department_rounded,
      ),
    ],
  ),
  Act0PlacementQuestionV1(
    questionId: 'goal',
    eyebrow: 'Coaching style',
    title: 'How should Sharky coach you?',
    subtitle: 'Choose the style that would keep you coming back.',
    helper:
        'Choose everything that sounds motivating. Sharky should feel like the right kind of pressure, not the wrong kind.',
    icon: Icons.favorite_rounded,
    allowsMultiple: true,
    options: <Act0PlacementOptionV1>[
      Act0PlacementOptionV1(
        optionId: 'guided',
        label: 'Keep me calm and guided at the start',
        score: 0,
        profileTag: 'Guided',
        subtitle:
            'Short explanations first, then gentle practice that makes sense.',
        icon: Icons.explore_rounded,
        badge: 'Calm start',
      ),
      Act0PlacementOptionV1(
        optionId: 'practice',
        label: 'Let me learn mostly by doing',
        score: 1,
        profileTag: 'Practice',
        subtitle: 'Less talking, more repetition once the concept is visible.',
        icon: Icons.fitness_center_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'diagnose',
        label: 'Show me quickly where I leak',
        score: 2,
        profileTag: 'Diagnostic',
        subtitle: 'Surface weak spots quickly and keep repair close by.',
        icon: Icons.search_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'daily_plan',
        label: 'Give me a short plan I can actually stick to',
        score: 1,
        profileTag: 'DailyPlan',
        subtitle: 'A compact habit loop with one clear next step each day.',
        icon: Icons.today_rounded,
      ),
      Act0PlacementOptionV1(
        optionId: 'honest',
        label: 'Be direct with me when I am guessing',
        score: 1,
        profileTag: 'Direct',
        subtitle: 'More clarity and sharper feedback, without turning harsh.',
        icon: Icons.record_voice_over_rounded,
      ),
    ],
  ),
];

class _Act0PlacementDiagnosticSpotV1 {
  const _Act0PlacementDiagnosticSpotV1({
    required this.lessonId,
    required this.taskId,
  });

  final String lessonId;
  final String taskId;
}

const _placementDiagnosticSpotsV1 = <_Act0PlacementDiagnosticSpotV1>[
  _Act0PlacementDiagnosticSpotV1(
    lessonId: 'what_poker_is',
    taskId: 'what_poker_is_find_hero',
  ),
  _Act0PlacementDiagnosticSpotV1(
    lessonId: 'your_first_hand',
    taskId: 'your_first_hand_flop',
  ),
  _Act0PlacementDiagnosticSpotV1(
    lessonId: 'blinds_action_order',
    taskId: 'blinds_first_actor',
  ),
];

// fromBeatV1 later: map BeatV1.caption/hint/options/feedback/table adapter
// into Act0RunnerStateV1, then replace Act0ShellStateV1.sample at the preview
// boundary without changing production Today, Map, Runner, or Result routes.
