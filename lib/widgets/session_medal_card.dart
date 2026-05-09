import 'package:flutter/material.dart';
import '../services/session_medal_service.dart';

/// Card displaying recent session medals earned in the last 7 days.
/// Shows medal counts by tier and recent medal awards with timestamps.
class SessionMedalCard extends StatefulWidget {
  const SessionMedalCard({super.key});

  @override
  State<SessionMedalCard> createState() => _SessionMedalCardState();
}

class _SessionMedalCardState extends State<SessionMedalCard> {
  List<SessionMedalAward> _recentMedals = [];
  Map<SessionMedalTier, int> _medalCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedals();
  }

  Future<void> _loadMedals() async {
    setState(() => _isLoading = true);
    try {
      final medals = await SessionMedalService.instance.getRecentMedals(
        days: 7,
      );
      final counts = await SessionMedalService.instance.getMedalCounts(days: 7);
      setState(() {
        _recentMedals = medals;
        _medalCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final title = isRu ? 'Медали за сессии' : 'Session Medals';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 24,
                  color: Color(0xFFFFD700),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  isRu ? '7 дней' : '7 days',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_recentMedals.isEmpty)
              _buildEmptyState(isRu)
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMedalCounts(isRu),
                  const SizedBox(height: 16),
                  _buildRecentMedals(isRu),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isRu) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: Colors.grey.withAlpha(128),
          ),
          const SizedBox(height: 8),
          Text(
            isRu
                ? 'Завершите сессию, чтобы заработать медали!'
                : 'Complete a session to earn medals!',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  Widget _buildMedalCounts(bool isRu) {
    final goldCount = _medalCounts[SessionMedalTier.gold] ?? 0;
    final silverCount = _medalCounts[SessionMedalTier.silver] ?? 0;
    final bronzeCount = _medalCounts[SessionMedalTier.bronze] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMedalCountChip(
          tier: SessionMedalTier.gold,
          count: goldCount,
          isRu: isRu,
        ),
        _buildMedalCountChip(
          tier: SessionMedalTier.silver,
          count: silverCount,
          isRu: isRu,
        ),
        _buildMedalCountChip(
          tier: SessionMedalTier.bronze,
          count: bronzeCount,
          isRu: isRu,
        ),
      ],
    );
  }

  Widget _buildMedalCountChip({
    required SessionMedalTier tier,
    required int count,
    required bool isRu,
  }) {
    Color color;
    switch (tier) {
      case SessionMedalTier.gold:
        color = const Color(0xFFFFD700);
        break;
      case SessionMedalTier.silver:
        color = const Color(0xFFC0C0C0);
        break;
      case SessionMedalTier.bronze:
        color = const Color(0xFFCD7F32);
        break;
    }

    final name = isRu ? tier.nameRu : tier.nameEn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMedals(bool isRu) {
    final title = isRu ? 'Недавние медали' : 'Recent Medals';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...(_recentMedals.take(5).map((award) => _buildMedalRow(award, isRu))),
      ],
    );
  }

  Widget _buildMedalRow(SessionMedalAward award, bool isRu) {
    Color color;
    switch (award.tier) {
      case SessionMedalTier.gold:
        color = const Color(0xFFFFD700);
        break;
      case SessionMedalTier.silver:
        color = const Color(0xFFC0C0C0);
        break;
      case SessionMedalTier.bronze:
        color = const Color(0xFFCD7F32);
        break;
    }

    final name = isRu ? award.tier.nameRu : award.tier.nameEn;
    final xpPerMinStr = award.xpPerMinute.toStringAsFixed(1);
    final subtitle = isRu
        ? '$xpPerMinStr XP/мин • ${award.sessionXp} XP'
        : '$xpPerMinStr XP/min • ${award.sessionXp} XP';
    final timestamp = _formatTimestamp(award.awardedAt, isRu);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            timestamp,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp, bool isRu) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return isRu ? 'только что' : 'just now';
    } else if (diff.inMinutes < 60) {
      return isRu ? '${diff.inMinutes} мин назад' : '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return isRu ? '${diff.inHours} ч назад' : '${diff.inHours} hr ago';
    } else {
      return isRu ? '${diff.inDays} дн назад' : '${diff.inDays} day ago';
    }
  }
}
