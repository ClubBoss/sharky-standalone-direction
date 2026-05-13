import 'dart:async' show unawaited;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global_evaluation_screen.dart';
import 'package:provider/provider.dart';
import '../services/hand_history_file_service.dart';
import '../services/saved_hand_manager_service.dart';
import '../services/saved_hand_export_service.dart';
import '../services/training_spot_of_day_service.dart';
import '../models/training_spot.dart';
import '../services/user_preferences_service.dart';
import '../main_demo.dart';
import '../tutorial/tutorial_flow.dart';
import '../tutorial/tutorial_completion_screen.dart';
import 'onboarding_screen.dart';
import 'training_history_screen.dart';
import '../services/streak_service.dart';
import 'achievements_screen.dart';
import '../services/goals_service.dart';
import '../widgets/focus_of_the_week_card.dart';
import '../widgets/sync_status_widget.dart';
import 'weakness_overview_screen.dart';
import 'ready_to_train_screen.dart';
import '../ui_v2/act0_shell/act0_canonical_path_root_v1.dart';
import '../ui/history/history_screen.dart';
import '../ui/session_player/models.dart';
import '../ui/session_player/mvs_player.dart';
import '../widgets/lesson_suggestion_banner.dart';
import '../widgets/smart_decay_goal_banner.dart';
import '../widgets/smart_mistake_goal_banner.dart';
import '../widgets/recovery_prompt_banner.dart';
import '../widgets/user_goal_reengagement_banner.dart';
import '../widgets/smart_recap_suggestion_banner.dart';
import '../widgets/recap_banner_widget.dart';
import '../widgets/goal_suggestion_row.dart';
import '../services/smart_goal_aggregator_service.dart';
import '../models/goal_recommendation.dart';
import '../widgets/skill_tree_main_menu_entry.dart';
import '../widgets/main_menu/main_menu_streak_card.dart';
import '../widgets/main_menu/main_menu_spot_of_day_section.dart';
import '../widgets/main_menu/main_menu_daily_goal_card.dart';
import '../widgets/main_menu/main_menu_progress_card.dart';
import '../widgets/main_menu/main_menu_suggested_banner.dart';
import '../widgets/main_menu/main_menu_grid.dart';
import '../widgets/main_menu/main_menu_featured_module_banner.dart';
import '../widgets/main_menu/main_menu_spot_replay_banner.dart';
import 'session_analysis_import_screen.dart';

class MainMenuScreen extends StatefulWidget {
  MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _demoMode = false;
  TrainingSpot? _spotOfDay;
  final GlobalKey _trainingButtonKey = GlobalKey();
  final GlobalKey _newHandButtonKey = GlobalKey();
  final GlobalKey _historyButtonKey = GlobalKey();
  bool _tutorialCompleted = false;
  bool _showStreakPopup = false;
  bool _suggestedDismissed = false;
  DateTime? _dismissedDate;
  static const _dismissedKey = 'suggested_weekly_dismissed_date';
  List<GoalRecommendation> _goalSuggestions = [];
  bool _loadingSuggestions = true;
  bool _resumeAvailable = false;
  List<UiSpot> _replaySpots = [];
  List<UiSpot> _replayWrongSpots = [];

  Widget _buildStreakIndicator(BuildContext context) {
    final streak = context.watch<StreakService>().count;
    if (streak <= 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AchievementsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              'Стрик: $streak дней',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final prefs = context.read<UserPreferencesService>();
    _demoMode = prefs.demoMode;
    _tutorialCompleted = prefs.tutorialCompleted;
    context.read<StreakService>().addListener(_onStreakChanged);
    _loadSpot();
    _loadDismissed();
    _loadGoalSuggestions();
    _loadResumeFlag();
    _loadReplaySpots();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(context.read<StreakService>().updateStreak());
        unawaited(context.read<GoalsService>().ensureDailyGoal());
        _maybeShowOnboarding();
      }
    });
  }

  Future<void> _loadSpot() async {
    final service = TrainingSpotOfDayService();
    final spot = await service.getSpot();
    if (mounted) {
      setState(() => _spotOfDay = spot);
    }
  }

  Future<void> _loadGoalSuggestions() async {
    final service = SmartGoalAggregatorService();
    final list = await service.getRecommendations();
    if (!mounted) return;
    setState(() {
      _goalSuggestions = list;
      _loadingSuggestions = false;
    });
  }

  Future<void> _loadResumeFlag() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _resumeAvailable = prefs.getBool('resume_active') ?? false;
    });
  }

  Future<void> _loadReplaySpots() async {
    try {
      final file = File('out/sessions_history.jsonl');
      if (!await file.exists()) return;
      final lines = await file.readAsLines();
      final data = _latestReplaySpotsFromLines(lines);
      if (!mounted) return;
      setState(() {
        _replaySpots = data.spots;
        _replayWrongSpots = data.wrong;
      });
    } catch (_) {}
  }

  ({List<UiSpot> spots, List<UiSpot> wrong}) _latestReplaySpotsFromLines(
    List<String> lines,
  ) {
    var latestSpots = <UiSpot>[];
    var wrongOnly = <UiSpot>[];
    for (var i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      try {
        final obj = jsonDecode(line);
        if (obj is Map<String, dynamic>) {
          final parsed = _parseSpots(obj['spots']);
          if (parsed.isNotEmpty) {
            latestSpots = parsed;
            final wrong = <int>[];
            final rawWrong = obj['wrongIdx'];
            if (rawWrong is List) {
              for (final w in rawWrong) {
                if (w is int) wrong.add(w);
              }
            }
            wrongOnly = wrong.isEmpty
                ? latestSpots
                : [
                    for (final i in wrong)
                      if (i >= 0 && i < latestSpots.length) latestSpots[i],
                  ];
            break;
          }
        }
      } catch (_) {}
    }
    return (spots: latestSpots, wrong: wrongOnly);
  }

  @visibleForTesting
  Future<void> loadReplaySpotsForTest(List<String> lines) async {
    final data = _latestReplaySpotsFromLines(lines);
    _replaySpots = data.spots;
    _replayWrongSpots = data.wrong;
  }

  @visibleForTesting
  List<UiSpot> get replaySpotsForTest => _replaySpots;

  @visibleForTesting
  List<UiSpot> get replayWrongSpotsForTest => _replayWrongSpots;

  List<UiSpot> _parseSpots(Object? raw) {
    final out = <UiSpot>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          final k = e['k'], h = e['h'], p = e['p'], st = e['s'], a = e['a'];
          if (k is int &&
              k >= 0 &&
              k < SpotKind.values.length &&
              h is String &&
              p is String &&
              st is String &&
              a is String) {
            out.add(
              UiSpot(
                kind: SpotKind.values[k],
                hand: h,
                pos: p,
                stack: st,
                action: a,
                vsPos: e['v'] as String?,
                limpers: e['l'] as String?,
                explain: e['e'] as String?,
              ),
            );
          }
        }
      }
    }
    return out;
  }

  Future<void> _discardResume() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('resume_active', false);
    await prefs.remove('resume_spots');
    await prefs.remove('resume_index');
    await prefs.remove('resume_answers');
    if (!mounted) return;
    setState(() => _resumeAvailable = false);
  }

  Future<void> _loadDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_dismissedKey);
    if (!mounted) return;
    if (str != null) {
      final dt = DateTime.tryParse(str);
      if (dt != null && DateTime.now().difference(dt).inDays < 7) {
        setState(() {
          _suggestedDismissed = true;
          _dismissedDate = dt;
        });
      } else {
        await prefs.remove(_dismissedKey);
      }
    }
  }

  void _maybeShowOnboarding() {
    if (context.read<UserPreferencesService>().tutorialCompleted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
      if (mounted) {
        setState(
          () => _tutorialCompleted = context
              .read<UserPreferencesService>()
              .tutorialCompleted,
        );
      }
    });
  }

  Future<void> _dismissSuggestedBanner() async {
    final now = DateTime.now();
    setState(() {
      _suggestedDismissed = true;
      _dismissedDate = now;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedKey, now.toIso8601String());
  }

  Future<void> _clearDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dismissedKey);
    if (!mounted) return;
    setState(() {
      _suggestedDismissed = false;
      _dismissedDate = null;
    });
  }

  void _onStreakChanged() {
    final service = context.read<StreakService>();
    if (service.consumeIncreaseFlag()) {
      setState(() => _showStreakPopup = true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _showStreakPopup = false);
      });
    }
  }

  Future<void> _toggleDemoMode(bool value) async {
    setState(() => _demoMode = value);
    await context.read<UserPreferencesService>().setDemoMode(value);
    if (value) {
      unawaited(
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PokerAnalyzerDemoApp()),
        ),
      );
    }
  }

  void _startTutorial() {
    late final TutorialFlow flow;
    flow = TutorialFlow(
      [
        TutorialStep(
          targetKey: _trainingButtonKey,
          description: 'Выберите тренировочный пак',
          onNext: (ctx, tutorial) {
            unawaited(
              Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => buildCanonicalPathRootV1()),
              ),
            );
          },
        ),
        TutorialStep(
          targetKey: _newHandButtonKey,
          description: 'Откройте первый доступный модуль на карте',
          onNext: (ctx, tutorial) {
            final nav = Navigator.of(ctx);
            nav.pop();
            tutorial.showCurrentStep(nav.context);
          },
        ),
        TutorialStep(
          targetKey: _newHandButtonKey,
          description: 'Затем решите раздачу',
          onNext: (_, __) {},
        ),
        TutorialStep(
          targetKey: _historyButtonKey,
          description: 'Просмотрите статистику ваших сессий',
          onNext: (ctx, tutorial) {
            unawaited(
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => TrainingHistoryScreen(tutorial: tutorial),
                ),
              ),
            );
          },
        ),
        TutorialStep(
          targetKey: TrainingHistoryScreen.exportCsvKey,
          description: 'Экспортируйте результаты для дальнейшего изучения',
          onNext: (_, __) {},
        ),
      ],
      onComplete: () {
        setState(() => _tutorialCompleted = true);
        unawaited(
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TutorialCompletionScreen(
                onRepeat: () {
                  final nav = Navigator.of(context);
                  nav.popUntil((route) => route.isFirst);
                  flow.start(nav.context);
                },
              ),
            ),
          ),
        );
      },
    );

    flow.start(context);
  }

  @override
  void dispose() {
    context.read<StreakService>().removeListener(_onStreakChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF121212),
    appBar: AppBar(
      title: const Text('Poker AI Analyzer'),
      centerTitle: true,
      actions: [
        SyncStatusIcon.of(context),
        _buildStreakIndicator(context),
        if (!_tutorialCompleted)
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _startTutorial,
          ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MainMenuFeaturedModuleBanner(),
                // Spot mistakes replay launcher: visible only when mistakes are queued.
                MainMenuSpotReplayBanner(
                  count: _replayWrongSpots.length,
                  onLaunch: () {
                    if (_replayWrongSpots.isEmpty && _replaySpots.isEmpty) {
                      return;
                    }
                    final spots = _replayWrongSpots.isNotEmpty
                        ? _replayWrongSpots
                        : _replaySpots;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            Scaffold(body: MvsSessionPlayer(spots: spots)),
                      ),
                    ).then((_) {
                      if (mounted) _loadReplaySpots();
                    });
                  },
                ),
                const LessonSuggestionBanner(),
                const SmartDecayGoalBanner(),
                const SmartMistakeGoalBanner(),
                if (!_loadingSuggestions && _goalSuggestions.isNotEmpty)
                  GoalSuggestionRow(recommendations: _goalSuggestions),
                const GoalReengagementBanner(),
                const SmartRecapSuggestionBanner(),
                const RecoveryPromptBanner(),
                const RecapBannerWidget(),
                MainMenuSuggestedBanner(
                  suggestedDismissed: _suggestedDismissed,
                  dismissedDate: _dismissedDate,
                  onDismissed: _dismissSuggestedBanner,
                  onClearDismissed: _clearDismissed,
                ),
                MainMenuStreakCard(showPopup: _showStreakPopup),
                const MainMenuDailyGoalCard(),
                const FocusOfTheWeekCard(),
                const MainMenuProgressCard(),
                if (_spotOfDay != null)
                  MainMenuSpotOfDaySection(spot: _spotOfDay!),
                const SkillTreeMainMenuEntry(),
                if (_resumeAvailable)
                  ListTile(
                    leading: const Icon(Icons.play_circle, color: Colors.white),
                    title: const Text('Resume session'),
                    trailing: TextButton(
                      onPressed: _discardResume,
                      child: const Text('Discard'),
                    ),
                    onTap: () async {
                      final player = await MvsSessionPlayer.fromSaved();
                      if (player == null) {
                        await _discardResume();
                        if (mounted) await _loadReplaySpots();
                        return;
                      }
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(body: player),
                        ),
                      );
                      if (mounted) {
                        await _loadReplaySpots();
                        await _loadResumeFlag();
                      }
                    },
                  ),
                if (_replaySpots.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          FilledButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Replay last'),
                            onPressed: () {
                              unawaited(
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                      body: MvsSessionPlayer(
                                        spots: _replaySpots,
                                      ),
                                    ),
                                  ),
                                ).then((_) {
                                  if (mounted) {
                                    unawaited(_loadReplaySpots());
                                  }
                                }),
                              );
                            },
                          ),
                          if (_replayWrongSpots.isNotEmpty)
                            FilledButton.icon(
                              icon: const Icon(Icons.error),
                              label: const Text('Replay last errors'),
                              onPressed: () {
                                unawaited(
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        body: MvsSessionPlayer(
                                          spots: _replayWrongSpots,
                                        ),
                                      ),
                                    ),
                                  ).then((_) {
                                    if (mounted) {
                                      unawaited(_loadReplaySpots());
                                    }
                                  }),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReadyToTrainScreen()),
                      );
                      if (mounted) {
                        await _loadReplaySpots();
                        await _loadResumeFlag();
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Тренироваться'),
                  ),
                ),
                const SizedBox(height: 16),
                MainMenuGrid(
                  trainingButtonKey: _trainingButtonKey,
                  newHandButtonKey: _newHandButtonKey,
                  historyButtonKey: _historyButtonKey,
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.white),
                  trailing: const Icon(Icons.chevron_right),
                  title: const Text('History'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                    if (mounted) {
                      await _loadReplaySpots();
                      await _loadResumeFlag();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.white),
                  trailing: const Icon(Icons.chevron_right),
                  title: const Text('Анализ ошибок'),
                  onTap: () {
                    Navigator.pushNamed(context, WeaknessOverviewScreen.route);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _demoMode,
                  title: const Text('Demo Mode'),
                  onChanged: _toggleDemoMode,
                  activeThumbColor: Colors.orange,
                ),
                const SizedBox(height: 32),
                const Text(
                  '🛠️ Инструменты',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final manager = Provider.of<SavedHandManagerService>(
                      context,
                      listen: false,
                    );
                    final service = await HandHistoryFileService.create(
                      manager,
                    );
                    await service.importFromFiles(context);
                  },
                  child: const Text('Импортировать Hand History'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionAnalysisImportScreen(),
                      ),
                    );
                  },
                  child: const Text('Анализ сессии EV/ICM'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final exporter = Provider.of<SavedHandExportService>(
                      context,
                      listen: false,
                    );
                    final path = await exporter.exportAllHandsMarkdown();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          path != null
                              ? 'Файл сохранён: all_saved_hands.md'
                              : 'Нет сохранённых раздач',
                        ),
                      ),
                    );
                  },
                  child: const Text('Экспорт всех раздач'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final exporter = Provider.of<SavedHandExportService>(
                      context,
                      listen: false,
                    );
                    final path = await exporter.exportAllHandsPdf();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          path != null
                              ? 'Файл сохранён: all_saved_hands.pdf'
                              : 'Нет сохранённых раздач',
                        ),
                      ),
                    );
                  },
                  child: const Text('Экспорт PDF раздач'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GlobalEvaluationScreen(),
                      ),
                    );
                  },
                  child: const Text('Глобальный пересчёт EV/ICM'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
