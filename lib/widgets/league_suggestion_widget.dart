import 'package:flutter/material.dart';

import '../models/xp_league.dart';
import '../screens/xp_tabs_screen.dart';
import '../screens/xp_recap_screen.dart';
import '../screens/achievements_screen.dart';

class LeagueSuggestionWidget extends StatelessWidget {
  final XpLeague league;

  const LeagueSuggestionWidget({super.key, required this.league});

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('ru');
    final color = league.color().withAlpha((0.12 * 255).round());
    final borderColor = league.color().withAlpha((0.4 * 255).round());
    final config = _suggestionForLeague(league, isRu);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(league.emoji(), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    config.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: league.color().withAlpha((0.85 * 255).round()),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () => config.onTap(context),
              child: Text(config.cta),
            ),
          ],
        ),
      ),
    );
  }

  _LeagueSuggestionConfig _suggestionForLeague(XpLeague league, bool isRu) {
    switch (league) {
      case XpLeague.rookie:
      case XpLeague.whale:
      case XpLeague.fish:
        return _LeagueSuggestionConfig(
          message: isRu ? 'Начните обучение' : 'Start learning!',
          subtitle: isRu
              ? 'Сделайте первые шаги и заработайте XP'
              : 'Take your first steps and earn XP',
          cta: isRu ? 'К тренировкам' : 'Start Training',
          onTap: (ctx) {
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const XpRecapScreen()),
            );
          },
        );
      case XpLeague.gambler:
      case XpLeague.amateur:
      case XpLeague.grinder:
      case XpLeague.semiPro:
      case XpLeague.pro:
        return _LeagueSuggestionConfig(
          message: isRu
              ? 'Выполните челлендж недели'
              : 'Complete the weekly challenge',
          subtitle: isRu
              ? 'Заработайте больше XP и удерживайте серию'
              : 'Keep the streak going and earn extra XP',
          cta: isRu ? 'Цель недели' : 'Weekly Goal',
          onTap: (ctx) {
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const XpRecapScreen()),
            );
          },
        );
      case XpLeague.shark:
      case XpLeague.beast:
      case XpLeague.legend:
        return _LeagueSuggestionConfig(
          message: isRu
              ? 'Соревнуйтесь в таблице лидеров'
              : 'Compete on the leaderboard',
          subtitle: isRu
              ? 'Проверьте свою позицию среди лучших'
              : 'See how you stack up against the best',
          cta: isRu ? 'К лидерам' : 'View Leaderboard',
          onTap: (ctx) {
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const XpTabsScreen()),
            );
          },
        );
      case XpLeague.endBoss:
        return _LeagueSuggestionConfig(
          message: isRu ? 'Пора на пьедестал' : 'Keep your edge sharp',
          subtitle: isRu
              ? 'Проверьте прогресс и оставайтесь лидером'
              : 'Review your progress and stay on top',
          cta: isRu ? 'Проверить' : 'Check Progress',
          onTap: (ctx) {
            Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const AchievementsScreen()),
            );
          },
        );
    }
  }
}

typedef _LeagueAction = void Function(BuildContext context);

class _LeagueSuggestionConfig {
  final String message;
  final String subtitle;
  final String cta;
  final _LeagueAction onTap;

  const _LeagueSuggestionConfig({
    required this.message,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });
}
