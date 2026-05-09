import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/xp_history_service.dart';

/// Displays recent XP gain events with source breakdown.
///
/// Shows the last 10 XP events to give players transparent feedback on their
/// XP flow, reinforcing positive behaviors and clarifying booster value.
class XpHistoryCard extends StatefulWidget {
  const XpHistoryCard({super.key});

  @override
  State<XpHistoryCard> createState() => _XpHistoryCardState();
}

class _XpHistoryCardState extends State<XpHistoryCard> {
  List<XpEvent> _events = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await XpHistoryService().getHistory();
    if (!mounted) return;

    // Take the last 10 events (most recent) and reverse for newest-first display
    final recent = history.length > 10
        ? history.sublist(history.length - 10)
        : history;
    setState(() {
      _events = recent.reversed.toList();
      _loading = false;
    });
  }

  String _icon(String type) {
    switch (type) {
      case 'theory_view':
        return '📖';
      case 'drill_completed':
        return '✅';
      case 'module_completed':
        return '🎓';
      case 'challenge':
        return '🏆';
      case 'session_log':
        return '⏱️';
      default:
        return '⭐';
    }
  }

  String _label(BuildContext context, String type) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    if (isRu) {
      switch (type) {
        case 'theory_view':
          return 'Теория';
        case 'drill_completed':
          return 'Упражнение';
        case 'module_completed':
          return 'Модуль завершён';
        case 'challenge':
          return 'Челлендж';
        case 'session_log':
          return 'Сессия';
        default:
          return 'Другое';
      }
    } else {
      switch (type) {
        case 'theory_view':
          return 'Theory';
        case 'drill_completed':
          return 'Drill';
        case 'module_completed':
          return 'Module Completed';
        case 'challenge':
          return 'Challenge';
        case 'session_log':
          return 'Session';
        default:
          return 'Other';
      }
    }
  }

  String _title(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'История XP' : 'XP History';
  }

  String _emptyMessage(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'История пуста' : 'No XP history yet';
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    if (difference.inMinutes < 1) {
      return isRu ? 'только что' : 'just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return isRu ? '$mins мин назад' : '$mins min ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return isRu ? '$hours ч назад' : '$hours hr ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return isRu ? '$days д назад' : '$days d ago';
    } else {
      // Format as short date
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;
    final onSurfaceColor = theme.colorScheme.onSurfaceVariant;

    return Card(
      color: surfaceColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title(context),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 12),
            if (_events.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _emptyMessage(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: onSurfaceColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              ..._events
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            _icon(event.type),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _label(context, event.type),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: onSurfaceColor,
                                  ),
                                ),
                                Text(
                                  _formatTimestamp(context, event.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: onSurfaceColor.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '+${event.amount}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
          ],
        ),
      ),
    );
  }
}
