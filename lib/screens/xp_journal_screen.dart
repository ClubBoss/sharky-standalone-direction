import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/xp_history_service.dart';

/// XP Journal screen for reviewing and reflecting on XP events.
///
/// Features:
/// - Shows all XP events with labels, amounts, and timestamps
/// - Each event has an editable reflection note field
/// - Auto-saves reflections on focus loss or Enter key
/// - Helps users track deliberate practice and learning insights
class XpJournalScreen extends StatefulWidget {
  XpJournalScreen({super.key});

  @override
  State<XpJournalScreen> createState() => _XpJournalScreenState();
}

class _XpJournalScreenState extends State<XpJournalScreen> {
  final XpHistoryService _historyService = XpHistoryService();
  List<XpEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _historyService.getHistory();
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  Future<void> _updateReflection(int index, String? note) async {
    await _historyService.updateReflection(index, note);
    // Update local state to reflect change
    setState(() {
      if (index >= 0 && index < _events.length) {
        _events[index] = _events[index].copyWith(reflectionNote: note);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.xpJournalTitle), elevation: 2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? _buildEmptyState(l10n)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _events.length,
              itemBuilder: (context, index) => _JournalEntryCard(
                event: _events[index],
                index: index,
                onReflectionChanged: _updateReflection,
              ),
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          l10n.xpJournalEmptyTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.xpJournalEmptyMessage,
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    ),
  );
}

/// Card widget for a single journal entry with editable reflection.
class _JournalEntryCard extends StatefulWidget {
  final XpEvent event;
  final int index;
  final Future<void> Function(int index, String? note) onReflectionChanged;

  const _JournalEntryCard({
    required this.event,
    required this.index,
    required this.onReflectionChanged,
  });

  @override
  State<_JournalEntryCard> createState() => _JournalEntryCardState();
}

class _JournalEntryCardState extends State<_JournalEntryCard> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _initialValue;

  @override
  void initState() {
    super.initState();
    _initialValue = widget.event.reflectionNote;
    _controller = TextEditingController(text: _initialValue ?? '');

    // Save on focus loss
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _saveReflection();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveReflection() async {
    final newValue = _controller.text.trim();
    // Only save if changed
    if (newValue != (_initialValue ?? '')) {
      await widget.onReflectionChanged(
        widget.index,
        newValue.isEmpty ? null : newValue,
      );
      _initialValue = newValue.isEmpty ? null : newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eventInfo = _getEventInfo(l10n, widget.event.type);
    final formattedDate = _formatDate(context, widget.event.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icon, label, XP, date
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: eventInfo.color.withValues(alpha: 0.1),
                  radius: 20,
                  child: Icon(eventInfo.icon, color: eventInfo.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            eventInfo.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '+${widget.event.amount} XP',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Reflection note field
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.xpJournalReflectionLabel,
                hintText: l10n.xpJournalReflectionHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onSubmitted: (_) => _saveReflection(),
            ),
          ],
        ),
      ),
    );
  }

  _EventInfo _getEventInfo(AppLocalizations l10n, String type) {
    switch (type) {
      case 'drill_completed':
        return _EventInfo(
          label: l10n.xpEventDrillCompleted,
          icon: Icons.fitness_center,
          color: Colors.blue,
        );
      case 'module_completed':
        return _EventInfo(
          label: l10n.xpEventModuleCompleted,
          icon: Icons.emoji_events,
          color: Colors.amber,
        );
      case 'theory_view':
        return _EventInfo(
          label: l10n.xpEventTheoryViewed,
          icon: Icons.menu_book,
          color: Colors.purple,
        );
      default:
        return _EventInfo(
          label: l10n.xpEventGeneric,
          icon: Icons.star,
          color: Colors.grey,
        );
    }
  }

  String _formatDate(BuildContext context, DateTime timestamp) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final eventDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    final timeStr = DateFormat.Hm(locale).format(timestamp);

    if (eventDate == today) {
      return l10n.xpRelativeTodayAt(timeStr);
    } else if (eventDate == yesterday) {
      return l10n.xpRelativeYesterdayAt(timeStr);
    } else if (now.difference(timestamp).inDays < 7) {
      final weekday = DateFormat('EEEE', locale).format(timestamp);
      return l10n.xpRelativeWeekdayAt(weekday, timeStr);
    } else {
      final datePart = DateFormat.yMMMd(locale).format(timestamp);
      return l10n.xpRelativeDateTime(datePart, timeStr);
    }
  }
}

/// Helper class for event display information.
class _EventInfo {
  final String label;
  final IconData icon;
  final Color color;

  _EventInfo({required this.label, required this.icon, required this.color});
}
