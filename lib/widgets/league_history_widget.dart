import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/xp_league.dart';
import '../services/league_history_service.dart';

class LeagueHistoryWidget extends StatelessWidget {
  final List<LeaguePromotionRecord> history;

  const LeagueHistoryWidget({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();
    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode.toLowerCase().startsWith('ru');
    final title = isRu ? 'История продвижений' : 'League history';

    final items = [...history]
      ..sort((a, b) => a.promotedAt.compareTo(b.promotedAt));

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        initiallyExpanded: false,
        children: items
            .map((record) => _HistoryEntry(record: record, isRu: isRu))
            .toList(),
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  final LeaguePromotionRecord record;
  final bool isRu;

  const _HistoryEntry({required this.record, required this.isRu});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final league = record.league ?? XpLeague.rookie;
    final emoji = league.emoji();
    final label = league.label(isRu: isRu);
    final formattedDate = DateFormat.yMMMMd(
      locale.toLanguageTag(),
    ).format(record.promotedAt.toLocal());
    final subtitle = isRu
        ? 'Повышение: $formattedDate'
        : 'Promoted on $formattedDate';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
    );
  }
}
