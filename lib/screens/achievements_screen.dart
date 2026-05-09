import 'package:flutter/material.dart';

import '../models/league_tier_badge.dart';
import '../widgets/trophy_wall_widget.dart';

class AchievementsScreen extends StatelessWidget {
  AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final title = localeCode == 'ru' ? 'Достижения' : 'Achievements';
    final sampleBadge = LeagueTierBadge.resolve(xp: 0);
    final badgeHint = localeCode == 'ru'
        ? 'Значки лиги (например ${sampleBadge.emoji}) показывают лигу на момент получения.'
        : 'League badges (like ${sampleBadge.emoji}) show your tier when trophies were unlocked.';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Unlocked Trophies / Полученные трофеи',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              badgeHint,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            const TrophyWallWidget(),
          ],
        ),
      ),
    );
  }
}

class AchievementsScreenLauncher {
  static void open(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AchievementsScreen()),
    );
  }
}
