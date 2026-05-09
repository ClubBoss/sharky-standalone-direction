import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/xp_history_service.dart';

class XpTimelineWidget extends StatelessWidget {
  final List<XpEvent> events;

  const XpTimelineWidget({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context)!;
    final grouped = _groupEvents(events, locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.xpTimelineTitle,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: grouped.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final bucket = grouped[index];
              return _TimelineSection(bucket: bucket, locale: locale);
            },
          ),
        ),
      ],
    );
  }

  List<_TimelineBucket> _groupEvents(List<XpEvent> events, Locale locale) {
    final sorted = [...events]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final limited = sorted.take(30).toList();
    final perDay = <DateTime, List<XpEvent>>{};
    for (final event in limited) {
      final day = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );
      perDay.putIfAbsent(day, () => []).add(event);
    }
    final buckets =
        perDay.entries
            .map(
              (entry) => _TimelineBucket(date: entry.key, events: entry.value),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return buckets;
  }
}

class _TimelineBucket {
  final DateTime date;
  final List<XpEvent> events;

  _TimelineBucket({required this.date, required this.events});
}

class _TimelineSection extends StatelessWidget {
  final _TimelineBucket bucket;
  final Locale locale;

  const _TimelineSection({required this.bucket, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isRu = locale.languageCode.toLowerCase().startsWith('ru');
    final header = DateFormat.yMMMMd(
      locale.toLanguageTag(),
    ).format(bucket.date.toLocal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        ...bucket.events.map((event) {
          final leading = _iconFor(event.type);
          final label = _labelFor(event.type, isRu);
          final timeLabel = DateFormat.Hm(
            locale.toLanguageTag(),
          ).format(event.timestamp.toLocal());
          return ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Text(leading, style: const TextStyle(fontSize: 20)),
            title: Text(label, style: const TextStyle(fontSize: 13)),
            subtitle: Text(
              timeLabel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }),
      ],
    );
  }

  String _labelFor(String type, bool isRu) {
    switch (type) {
      case 'drill_completed':
        return isRu ? 'Дрилл завершён' : 'Drill completed';
      case 'module_completed':
        return isRu ? 'Модуль завершён' : 'Module completed';
      case 'theory_view':
        return isRu ? 'Теория изучена' : 'Theory viewed';
      case 'trophy_unlocked':
        return isRu ? 'Получен трофей' : 'Trophy unlocked';
      default:
        return isRu ? 'Событие XP' : 'XP event';
    }
  }

  String _iconFor(String type) {
    switch (type) {
      case 'drill_completed':
        return '🛠️';
      case 'module_completed':
        return '📦';
      case 'theory_view':
        return '📘';
      case 'trophy_unlocked':
        return '🏆';
      default:
        return '✨';
    }
  }
}
