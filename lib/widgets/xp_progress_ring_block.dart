import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/user_rank.dart';
import '../models/xp_league.dart';

/// Shared XP progress ring with caption, XP summary, and optional badge slot.
class XpProgressRingBlock extends StatelessWidget {
  final int totalXp;
  final int milestoneXp;
  final double percent;
  final String caption;
  final int? leagueRank;
  final double ringSize;

  const XpProgressRingBlock({
    super.key,
    required this.totalXp,
    required this.milestoneXp,
    required this.percent,
    required this.caption,
    this.leagueRank,
    this.ringSize = 160,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final clamped = percent.clamp(0.0, 1.0);
    final xpLabel = l10n.xpMilestoneTotalXp(totalXp);
    final milestoneLabel = milestoneXp > 0
        ? l10n.xpRecapNextMilestone(milestoneXp)
        : null;
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final tier = userRankFromXp(totalXp);
    final tierLabel = tier.label(isRu: isRu);
    final league = XpLeagueExt.fromXp(totalXp);
    final leagueLabel = isRu
        ? 'Лига: ${league.emoji()} ${league.label(isRu: true)}'
        : '${league.emoji()} ${league.label()} League';
    final nextLeague = _nextLeague(league);
    double leagueProgress;
    String progressCaption;
    if (nextLeague != null) {
      final currentFloor = league.minXp;
      final nextFloor = nextLeague.minXp;
      final range = (nextFloor - currentFloor).clamp(1, 1 << 30);
      final gained = (totalXp - currentFloor).clamp(0, range);
      leagueProgress = gained / range;
      final nextLabel = nextLeague.label(isRu: isRu);
      final direction = isRu ? 'до' : 'to';
      progressCaption =
          '$totalXp / $nextFloor XP $direction ${nextLeague.emoji()} $nextLabel';
    } else {
      leagueProgress = 1;
      progressCaption = isRu
          ? 'Достигнут максимальный уровень лиги'
          : 'Maximum league achieved';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: clamped),
          duration: const Duration(milliseconds: 450),
          builder: (context, value, _) {
            final pctLabel = '${(value * 100).round()}%';
            return Semantics(
              label: milestoneLabel ?? xpLabel,
              child: SizedBox(
                width: ringSize,
                height: ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: ringSize * 0.1,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    Text(
                      pctLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (totalXp > 0)
                      Positioned(
                        top: ringSize * 0.08,
                        right: ringSize * 0.08,
                        child: Text(
                          league.emoji(),
                          style: TextStyle(fontSize: ringSize * 0.18),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          xpLabel,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          caption,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          tierLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          leagueLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: ringSize,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: leagueProgress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((0.6 * 255).round()),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: ringSize,
          child: Text(
            progressCaption,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
        if (leagueRank != null && leagueRank! > 0) ...[
          const SizedBox(height: 10),
          _XpLeagueBadge(rank: leagueRank!),
        ],
      ],
    );
  }
}

XpLeague? _nextLeague(XpLeague league) {
  final index = XpLeague.values.indexOf(league);
  if (index < 0 || index >= XpLeague.values.length - 1) return null;
  return XpLeague.values[index + 1];
}

class _XpLeagueBadge extends StatelessWidget {
  final int rank;
  const _XpLeagueBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode.toLowerCase().startsWith('ru');
    final label = '#$rank • ${_leagueName(rank, isRu)}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  String _leagueName(int rank, bool isRu) {
    if (rank <= 10) return isRu ? 'Золотая лига' : 'Gold League';
    if (rank <= 40) return isRu ? 'Серебряная лига' : 'Silver League';
    if (rank > 0) return isRu ? 'Бронзовая лига' : 'Bronze League';
    return isRu ? 'Лига' : 'League';
  }
}
