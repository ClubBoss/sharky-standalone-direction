import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'poker_analyzer_screen.dart';
import 'settings_screen.dart';
import 'training_packs_screen.dart';
import '../models/training_spot.dart';
import 'package:provider/provider.dart';
import '../services/action_sync_service.dart';
import '../services/player_manager_service.dart';
import '../services/player_profile_service.dart';
import '../services/playback_manager_service.dart';
import '../services/stack_manager_service.dart';
import '../services/pot_sync_service.dart';
import '../services/pot_history_service.dart';
import '../services/board_manager_service.dart';
import '../services/board_sync_service.dart';
import '../services/board_editing_service.dart';
import '../services/player_editing_service.dart';
import '../services/transition_lock_service.dart';
import '../services/board_reveal_service.dart';
import '../services/all_in_players_service.dart';
import '../services/folded_players_service.dart';
import '../widgets/sync_status_widget.dart';

class PlayerInputScreen extends StatefulWidget {
  PlayerInputScreen({super.key});

  @override
  State<PlayerInputScreen> createState() => _PlayerInputScreenState();
}

class _PlayerInputScreenState extends State<PlayerInputScreen> {
  final TextEditingController _controller = TextEditingController();
  int _selectedPlayers = 6;

  Widget _buildAnalyzerStack({
    GlobalKey<PokerAnalyzerScreenState>? key,
  }) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PlayerProfileService()),
      ChangeNotifierProvider(
        create: (ctx) => PlayerManagerService(ctx.read<PlayerProfileService>()),
      ),
      ChangeNotifierProvider(create: (_) => AllInPlayersService()),
      ChangeNotifierProvider(create: (_) => FoldedPlayersService()),
      ChangeNotifierProvider(
        create: (ctx) => ActionSyncService(
          foldedPlayers: ctx.read<FoldedPlayersService>(),
          allInPlayers: ctx.read<AllInPlayersService>(),
        ),
      ),
    ],
    child: Builder(
      builder: (ctx) => ChangeNotifierProvider(
        create: (_) {
          final history = PotHistoryService();
          final potSync = PotSyncService(historyService: history);
          final stackService = StackManagerService(
            Map<int, int>.from(ctx.read<PlayerManagerService>().initialStacks),
            potSync: potSync,
          );
          return PlaybackManagerService(
            stackService: stackService,
            potSync: potSync,
            actionSync: ctx.read<ActionSyncService>(),
          );
        },
        child: Builder(
          builder: (ctx2) => Provider(
            create: (_) => BoardSyncService(
              playerManager: ctx2.read<PlayerManagerService>(),
              actionSync: ctx2.read<ActionSyncService>(),
            ),
            child: Builder(
              builder: (ctx3) {
                final lockService = TransitionLockService();
                final reveal = BoardRevealService(
                  lockService: lockService,
                  boardSync: ctx3.read<BoardSyncService>(),
                );
                return MultiProvider(
                  providers: [
                    Provider<BoardRevealService>.value(value: reveal),
                    ChangeNotifierProvider(
                      create: (_) => BoardManagerService(
                        playerManager: ctx3.read<PlayerManagerService>(),
                        actionSync: ctx3.read<ActionSyncService>(),
                        playbackManager: ctx3.read<PlaybackManagerService>(),
                        lockService: lockService,
                        boardSync: ctx3.read<BoardSyncService>(),
                        boardReveal: reveal,
                      ),
                    ),
                    Provider(
                      create: (_) => BoardEditingService(
                        boardManager: ctx3.read<BoardManagerService>(),
                        boardSync: ctx3.read<BoardSyncService>(),
                        playerManager: ctx3.read<PlayerManagerService>(),
                        profile: ctx3.read<PlayerProfileService>(),
                      ),
                    ),
                    Provider(
                      create: (_) => PlayerEditingService(
                        playerManager: ctx3.read<PlayerManagerService>(),
                        stackService: ctx3
                            .read<PlaybackManagerService>()
                            .stackService,
                        playbackManager: ctx3.read<PlaybackManagerService>(),
                        profile: ctx3.read<PlayerProfileService>(),
                      ),
                    ),
                  ],
                  child: PokerAnalyzerScreen(key: key),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF121212),
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: const Text('Poker AI Analyzer'),
      centerTitle: true,
      actions: [
        SyncStatusIcon.of(context),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            );
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextFormField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Введите описание раздачи',
              hintText: 'Пример: UTG рейз 2bb, MP колл, BB пуш 20bb...',
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Игроков за столом: ',
                style: TextStyle(color: Colors.white),
              ),
              DropdownButton<int>(
                value: _selectedPlayers,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                items: List.generate(8, (index) => index + 2)
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e,
                        child: Text(e.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPlayers = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final data = await Navigator.push<Map<String, dynamic>?>(
                context,
                MaterialPageRoute(builder: (_) => TrainingPacksScreen()),
              );
              if (data != null) {
                final key = GlobalKey<PokerAnalyzerScreenState>();
                unawaited(
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _buildAnalyzerStack(key: key),
                    ),
                  ),
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final state = key.currentState;
                  state?.loadTrainingSpot(
                    TrainingSpot.fromJson(Map<String, dynamic>.from(data)),
                  );
                });
              }
            },
            child: const Text('📦 Выбрать тренировку'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                unawaited(
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => _buildAnalyzerStack(),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Анализировать'),
          ),
        ],
      ),
    ),
  );
}
