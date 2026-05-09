import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/session_export_service.dart';
import '../services/session_log_service.dart';
import '../services/xp_service.dart';

class SessionLoggerWidget extends StatefulWidget {
  final List<SessionLogEntry> sessions;
  final Future<void> Function()? onSessionLogged;
  final DateTime Function() nowProvider;

  const SessionLoggerWidget({
    super.key,
    required this.sessions,
    this.onSessionLogged,
    DateTime Function()? nowProvider,
  }) : nowProvider = nowProvider ?? DateTime.now;

  @override
  State<SessionLoggerWidget> createState() => _SessionLoggerWidgetState();
}

class _SessionLoggerWidgetState extends State<SessionLoggerWidget> {
  late List<SessionLogEntry> _sessions;
  DateTime? _activeStart;
  Timer? _ticker;
  Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _sessions = List.of(widget.sessions);
    _loadActiveSession();
  }

  @override
  void didUpdateWidget(SessionLoggerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.sessions, widget.sessions)) {
      _sessions = List.of(widget.sessions);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadActiveSession() async {
    final start = await SessionLogService.instance.getActiveSessionStart();
    final activeTags = await SessionLogService.instance.getActiveSessionTags();
    if (!mounted) return;
    setState(() {
      _activeStart = start;
      _selectedTags = activeTags.toSet();
    });
    if (start != null) {
      _startTicker();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _startSession() async {
    final now = widget.nowProvider().toUtc();
    await SessionLogService.instance.startSession(
      now,
      tags: _selectedTags.toList(),
    );
    if (!mounted) return;
    setState(() {
      _activeStart = now;
    });
    _startTicker();
  }

  Future<void> _endSession() async {
    final end = widget.nowProvider().toUtc();
    final entry = await SessionLogService.instance.endSession(endTime: end);
    _ticker?.cancel();
    if (entry != null) {
      await _awardXp(entry.durationMinutes, entry.tags);
      await _reloadSessions();
      if (widget.onSessionLogged != null) {
        await widget.onSessionLogged!();
      }
    }
    if (!mounted) return;
    setState(() {
      _activeStart = null;
    });
  }

  Future<void> _reloadSessions() async {
    final logs = await SessionLogService.instance.getLogs();
    if (!mounted) return;
    setState(() {
      _sessions = logs;
    });
  }

  Future<void> _awardXp(int durationMinutes, List<String> tags) async {
    XpService? xpService;
    try {
      xpService = context.read<XpService>();
    } catch (_) {
      xpService = XpService();
    }
    await xpService.awardSessionXp(
      durationMinutes: durationMinutes,
      tags: tags,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode.toLowerCase().startsWith('ru');
    final title = isRu ? 'Журнал сессий' : 'Session log';
    final startLabel = isRu ? 'Начать новую сессию' : 'Start new session';
    final endLabel = isRu ? 'Завершить сессию' : 'End session';
    final summary = _SessionSummary(_sessions);
    final summaryText = isRu
        ? '${summary.count} сессий • ${summary.totalXp} XP • ${summary.totalHours}ч'
        : '${summary.count} sessions • ${summary.totalXp} XP • ${summary.totalHours}h';
    final exportLabel = isRu ? 'Экспортировать' : 'Export sessions';
    final limited = _sessions.take(5).toList();
    final tagOptions = _tagOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            if (_activeStart == null)
              TextButton(onPressed: _startSession, child: Text(startLabel))
            else
              TextButton(onPressed: _endSession, child: Text(endLabel)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final option in tagOptions)
              FilterChip(
                label: Text(option.label(isRu)),
                selected: _selectedTags.contains(option.slug),
                onSelected: (selected) {
                  setState(() {
                    final updated = Set<String>.from(_selectedTags);
                    if (selected) {
                      if (updated.length < 3 || updated.contains(option.slug)) {
                        updated.add(option.slug);
                      }
                    } else {
                      updated.remove(option.slug);
                    }
                    _selectedTags = updated;
                  });
                  if (_activeStart != null) {
                    SessionLogService.instance.setActiveTags(
                      _selectedTags.toList(),
                    );
                  }
                },
              ),
          ],
        ),
        if (_activeStart != null) ...[
          const SizedBox(height: 6),
          _ActiveSessionBanner(
            start: _activeStart!,
            locale: locale,
            nowProvider: widget.nowProvider,
          ),
        ],
        const SizedBox(height: 8),
        if (limited.isEmpty)
          Text(
            isRu ? 'Пока нет записанных сессий' : 'No sessions logged yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summaryText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    final exporter = SessionExportService(
                      sessions: _sessions,
                      localeCode: locale.languageCode,
                    );
                    // ignore: avoid_print
                    print(exporter.toCsv());
                  },
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: Text(exportLabel),
                ),
              ),
              Column(
                children: limited
                    .map(
                      (entry) => _SessionTile(
                        entry: entry,
                        locale: locale,
                        tagOptions: tagOptions,
                        onEditNotes: _editNotes,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
      ],
    );
  }
}

class _ActiveSessionBanner extends StatelessWidget {
  final DateTime start;
  final Locale locale;
  final DateTime Function() nowProvider;

  const _ActiveSessionBanner({
    required this.start,
    required this.locale,
    required this.nowProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isRu = locale.languageCode.toLowerCase().startsWith('ru');
    final now = nowProvider();
    final minutes = now.difference(start.toLocal()).inMinutes;
    final clamped = minutes < 0 ? 0 : minutes;
    final label = isRu
        ? 'Сессия в процессе • $clamped мин'
        : 'Session in progress • $clamped min';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SessionSummary {
  final int count;
  final int totalXp;
  final String totalHours;

  _SessionSummary(List<SessionLogEntry> sessions)
    : count = sessions.length,
      totalXp = sessions.fold<int>(0, (sum, e) => sum + e.xpEarned),
      totalHours = _formatHours(
        sessions.fold<int>(0, (sum, e) => sum + e.durationMinutes),
      );

  static String _formatHours(int totalMinutes) {
    final hours = totalMinutes / 60;
    return hours.toStringAsFixed(1);
  }
}

class _SessionTile extends StatelessWidget {
  final SessionLogEntry entry;
  final Locale locale;
  final List<_TagOption> tagOptions;
  final Future<void> Function(SessionLogEntry) onEditNotes;

  const _SessionTile({
    required this.entry,
    required this.locale,
    required this.tagOptions,
    required this.onEditNotes,
  });

  @override
  Widget build(BuildContext context) {
    final isRu = locale.languageCode.toLowerCase().startsWith('ru');
    final dateLabel = DateFormat.yMMMMd(
      locale.toLanguageTag(),
    ).format(entry.startTime.toLocal());
    final timeLabel = DateFormat.Hm(
      locale.toLanguageTag(),
    ).format(entry.startTime.toLocal());
    final durationLabel = isRu
        ? '${entry.durationMinutes} мин.'
        : '${entry.durationMinutes} min';
    final xpLabel = '+${entry.xpEarned} XP';
    final locationLabel = entry.location?.isNotEmpty == true
        ? entry.location!
        : (isRu ? 'Локация не указана' : 'No location');
    final notesPreview = entry.notes;
    final actionLabel = entry.notes == null
        ? (isRu ? 'Добавить заметки' : 'Add Notes')
        : (isRu ? 'Редактировать заметки' : 'Edit Notes');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule, size: 20),
          title: Text(
            '$dateLabel · $timeLabel',
            style: const TextStyle(fontSize: 13),
          ),
          trailing: Text(
            xpLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$durationLabel · $locationLabel'),
              if (entry.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entry.tags.map((tag) {
                      final option = tagOptions.firstWhere(
                        (opt) => opt.slug == tag,
                        orElse: () => _TagOption(tag, tag, tag),
                      );
                      return Chip(
                        label: Text(option.label(isRu)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      );
                    }).toList(),
                  ),
                ),
              if (notesPreview != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.notes, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          notesPreview.length > 60
                              ? '${notesPreview.substring(0, 60)}…'
                              : notesPreview,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => onEditNotes(entry),
            icon: const Icon(Icons.edit_note, size: 18),
            label: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}

class _TagOption {
  final String slug;
  final String labelEn;
  final String labelRu;

  const _TagOption(this.slug, this.labelEn, this.labelRu);

  String label(bool isRu) => isRu ? labelRu : labelEn;
}

const List<_TagOption> _tagOptions = [
  _TagOption('cash', 'Cash', 'Кэш'),
  _TagOption('mtt', 'MTT', 'MTT'),
  _TagOption('live', 'Live', 'Live'),
  _TagOption('theory', 'Theory', 'Теория'),
  _TagOption('solver', 'Solver', 'Солвер'),
  _TagOption('review', 'Review', 'Разбор'),
];

class SessionNotesDialog extends StatefulWidget {
  final String? initialNotes;
  final bool isRu;

  const SessionNotesDialog({super.key, this.initialNotes, required this.isRu});

  @override
  State<SessionNotesDialog> createState() => _SessionNotesDialogState();
}

class _SessionNotesDialogState extends State<SessionNotesDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isRu ? 'Заметки о сессии' : 'Session notes';
    final cancel = widget.isRu ? 'Отмена' : 'Cancel';
    final save = widget.isRu ? 'Сохранить' : 'Save';
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 6,
          maxLength: 2000,
          decoration: InputDecoration(
            hintText: widget.isRu
                ? 'Добавьте размышления о сессии'
                : 'Add your reflections',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(save),
        ),
      ],
    );
  }
}
