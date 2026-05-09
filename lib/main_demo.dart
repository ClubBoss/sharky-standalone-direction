// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/poker_analyzer_screen.dart';
import 'services/action_sync_service.dart';
import 'services/all_in_players_service.dart';
import 'services/board_editing_service.dart';
import 'services/board_manager_service.dart';
import 'services/board_reveal_service.dart';
import 'services/board_sync_service.dart';
import 'services/folded_players_service.dart';
import 'services/player_editing_service.dart';
import 'services/player_manager_service.dart';
import 'services/player_profile_service.dart';
import 'services/playback_manager_service.dart';
import 'services/pot_history_service.dart';
import 'services/pot_sync_service.dart';
import 'services/stack_manager_service.dart';
import 'services/transition_lock_service.dart';
import 'services/action_history_service.dart';
import 'services/ignored_mistake_service.dart';
import 'services/training_import_export_service.dart';
import 'services/demo_playback_controller.dart';
import 'screens/weakness_overview_screen.dart';
import 'screens/master_mode_screen.dart';
import 'screens/goal_center_screen.dart';
import 'screens/goal_insights_screen.dart';
import 'screens/memory_insights_screen.dart';
import 'screens/decay_heatmap_screen.dart';
import 'screens/reward_gallery_screen.dart';

final GlobalKey<PokerAnalyzerScreenState> analyzerKey =
    GlobalKey<PokerAnalyzerScreenState>();

void main() {
  runApp(const PokerAnalyzerDemoApp());
}

class PokerAnalyzerDemoApp extends StatefulWidget {
  const PokerAnalyzerDemoApp({super.key, this.demoMode = true});

  final bool demoMode;

  @override
  State<PokerAnalyzerDemoApp> createState() => _PokerAnalyzerDemoAppState();
}

class _PokerAnalyzerDemoAppState extends State<PokerAnalyzerDemoApp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _labelController;

  @override
  void initState() {
    super.initState();
    _labelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _labelController.reverse();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PlayerProfileService()),
      ChangeNotifierProvider(
        create: (context) =>
            PlayerManagerService(context.read<PlayerProfileService>()),
      ),
      ChangeNotifierProvider(create: (_) => AllInPlayersService()),
      ChangeNotifierProvider(create: (_) => FoldedPlayersService()),
      ChangeNotifierProvider(
        create: (context) => ActionSyncService(
          foldedPlayers: context.read<FoldedPlayersService>(),
          allInPlayers: context.read<AllInPlayersService>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) {
          final history = PotHistoryService();
          final potSync = PotSyncService(historyService: history);
          final stackService = StackManagerService(
            Map<int, int>.from(
              context.read<PlayerManagerService>().initialStacks,
            ),
            potSync: potSync,
          );
          return PlaybackManagerService(
            stackService: stackService,
            potSync: potSync,
            actionSync: context.read<ActionSyncService>(),
          );
        },
      ),
      Provider(
        create: (context) => BoardSyncService(
          playerManager: context.read<PlayerManagerService>(),
          actionSync: context.read<ActionSyncService>(),
        ),
      ),
      Provider(create: (_) => ActionHistoryService()),
      ChangeNotifierProvider(create: (_) => IgnoredMistakeService()..load()),
      Provider(create: (_) => TrainingImportExportService()),
    ],
    child: Builder(
      builder: (context) {
        final lockService = TransitionLockService();
        final boardReveal = BoardRevealService(
          lockService: lockService,
          boardSync: context.read<BoardSyncService>(),
        );
        return MultiProvider(
          providers: [
            Provider<TransitionLockService>.value(value: lockService),
            Provider<BoardRevealService>.value(value: boardReveal),
            ChangeNotifierProvider(
              create: (_) => BoardManagerService(
                playerManager: context.read<PlayerManagerService>(),
                actionSync: context.read<ActionSyncService>(),
                playbackManager: context.read<PlaybackManagerService>(),
                lockService: lockService,
                boardSync: context.read<BoardSyncService>(),
                boardReveal: boardReveal,
              ),
            ),
            Provider(
              create: (_) => BoardEditingService(
                boardManager: context.read<BoardManagerService>(),
                boardSync: context.read<BoardSyncService>(),
                playerManager: context.read<PlayerManagerService>(),
                profile: context.read<PlayerProfileService>(),
              ),
            ),
            Provider(
              create: (_) => PlayerEditingService(
                playerManager: context.read<PlayerManagerService>(),
                stackService: context
                    .read<PlaybackManagerService>()
                    .stackService,
                playbackManager: context.read<PlaybackManagerService>(),
                profile: context.read<PlayerProfileService>(),
              ),
            ),
            Provider(
              create: (_) => DemoPlaybackController(
                playbackManager: context.read<PlaybackManagerService>(),
                boardManager: context.read<BoardManagerService>(),
                importExportService: context
                    .read<TrainingImportExportService>(),
                potSync: context.read<PlaybackManagerService>().potSync,
              ),
            ),
          ],
          child: DemoLauncher(
            child: MaterialApp(
              title: 'Poker AI Analyzer Demo',
              debugShowCheckedModeBanner: false,
              theme: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.greenAccent,
                ),
                scaffoldBackgroundColor: Colors.black,
                textTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: 'Roboto',
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
              ),
              routes: {
                WeaknessOverviewScreen.route: (_) =>
                    const WeaknessOverviewScreen(),
                MasterModeScreen.route: (_) => const MasterModeScreen(),
                GoalCenterScreen.route: (_) => const GoalCenterScreen(),
                GoalInsightsScreen.route: (_) => const GoalInsightsScreen(),
                MemoryInsightsScreen.route: (_) => const MemoryInsightsScreen(),
                DecayHeatmapScreen.route: (_) => const DecayHeatmapScreen(),
                RewardGalleryScreen.route: (_) => const RewardGalleryScreen(),
              },
              builder: (context, child) => Stack(
                children: [
                  if (child != null) child,
                  if (widget.demoMode)
                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + 8,
                      left: 8,
                      child: FadeTransition(
                        opacity: _labelController,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Demo Mode Active',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              home: PokerAnalyzerScreen(key: analyzerKey),
            ),
          ),
        );
      },
    ),
  );
}

class DemoLauncher extends StatefulWidget {
  final Widget child;
  const DemoLauncher({super.key, required this.child});

  @override
  State<DemoLauncher> createState() => _DemoLauncherState();
}

class _DemoLauncherState extends State<DemoLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<DemoPlaybackController>();
      final state = analyzerKey.currentState;
      if (state == null) return;
      controller.startDemo(
        loadSpot: state.loadTrainingSpot,
        playAll: state.playAll,
        announceWinner: state.resolveWinner,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        right: 8,
        child: IconButton(
          icon: const Icon(Icons.refresh),
          color: Colors.white70,
          tooltip: 'Reset Demo',
          onPressed: _resetDemo,
        ),
      ),
    ],
  );

  void _resetDemo() {
    final state = analyzerKey.currentState;
    if (state == null) return;
    final dynamic dyn = state;
    Future<void> future = Future<void>.value();
    try {
      future = dyn._autoResetAfterShowdown() as Future<void>;
    } catch (_) {}
    future.whenComplete(() {
      try {
        dyn.resetAll();
      } catch (_) {}
    });
  }
}
