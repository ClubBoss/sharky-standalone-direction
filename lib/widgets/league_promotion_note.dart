import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/xp_league.dart';
import '../services/league_history_service.dart';

class LeaguePromotionNote extends StatelessWidget {
  final LeaguePromotionRecord record;

  const LeaguePromotionNote({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode.toLowerCase().startsWith('ru');
    final league = record.league ?? XpLeague.rookie;
    final label = league.label(isRu: isRu);
    final emoji = league.emoji();
    final formattedDate = DateFormat.yMMMMd(
      locale.toLanguageTag(),
    ).format(record.promotedAt.toLocal());
    final text = isRu
        ? 'Последнее повышение: $emoji $label — $formattedDate'
        : 'Last promoted: $emoji $label on $formattedDate';

    return Text(
      text,
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      textAlign: TextAlign.center,
    );
  }
}
