import 'package:flutter/material.dart';

import 'dev_menu/booster_section.dart';
import 'dev_menu/coverage_section.dart';
import 'dev_menu/dev_menu_section.dart';
import 'dev_menu/pack_generation_section.dart';
import 'dev_menu/debug_tools_section.dart';
import 'dev_menu/ui_v2_section.dart';
import 'dev_menu/player_progress_section.dart';
import 'dev_menu/economy_section.dart';
import 'package:poker_analyzer/services/daily_challenge_engine.dart';
import 'package:poker_analyzer/services/user_action_logger.dart';

class DevMenuScreen extends StatelessWidget {
  DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = <DevMenuSection>[
      DevMenuSection(
        title: 'Engagement Tools',
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await EngagementNotifications.sendTestNotification();
                },
                child: const Text('Send Test Notification'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final c = await DailyChallengeEngine.instance
                      .forceNewChallenge();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('New challenge: ${c.label}')),
                    );
                  }
                },
                child: const Text('Force New Daily Challenge'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final status = await StreakTrackerV2.getStatus();
                  if (context.mounted) {
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Streak Info'),
                        content: Text(
                          'Current: ${status['current']}\nBest: ${status['best']}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                  await UserActionLogger.instance.logEvent({
                    'event': 'streak_info_shown',
                  });
                },
                child: const Text('Show Streak Info'),
              ),
            ],
          ),
        ),
      ),
      DevMenuSection(
        title: 'Economy Debug',
        builder: (_) => const EconomySection(),
      ),
      DevMenuSection(
        title: 'UI Experiments',
        builder: (_) => const UiV2Section(),
      ),
      DevMenuSection(
        title: 'Player Progress (Experimental)',
        builder: (_) => const PlayerProgressSection(),
      ),
      DevMenuSection(
        title: 'Training Pack Generator',
        builder: (_) => PackGenerationSection(),
      ),
      DevMenuSection(
        title: 'Coverage Tools',
        builder: (_) => CoverageSection(),
      ),
      DevMenuSection(title: 'Booster Tools', builder: (_) => BoosterSection()),
      DevMenuSection(title: 'Debug Tools', builder: (_) => DebugToolsSection()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dev Menu')),
      backgroundColor: const Color(0xFF121212),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final s in sections)
            ExpansionTile(title: Text(s.title), children: [s.builder(context)]),
        ],
      ),
    );
  }
}
