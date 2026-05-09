import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../infra/telemetry.dart';

import '../l10n/app_localizations.dart';
import '../services/xp_history_export_controller.dart';
import '../services/xp_history_service.dart';

extension _XpHistoryL10n on AppLocalizations {
  bool get _isRu => localeName.toLowerCase().startsWith('ru');

  String get xpExportHistoryTitle =>
      _isRu ? 'Экспорт истории XP' : 'Export XP history';
  String get xpExportMethodCopy => _isRu ? 'Копировать' : 'Copy';
  String get xpExportCsvCopied =>
      _isRu ? 'CSV скопирован в буфер обмена' : 'CSV copied to clipboard';
  String get xpExportCsvShared =>
      _isRu ? 'CSV успешно отправлен' : 'CSV shared';
}

class XpRecapHistoryPart extends StatefulWidget {
  XpRecapHistoryPart({super.key});

  @override
  State<XpRecapHistoryPart> createState() => _XpRecapHistoryPartState();
}

class _XpRecapHistoryPartState extends State<XpRecapHistoryPart> {
  late Future<List<XpEvent>> _future;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _onRefresh() async {
    // Analytics: user pulled to refresh on history tab
    unawaited(Telemetry.logEvent('xp_recap_refresh', {'tab': 'history'}));
    final f = _load();
    if (!mounted) return;
    setState(() {
      _future = f;
    });
    await f;
  }

  Future<List<XpEvent>> _load() async {
    final historyService = XpHistoryService();
    final history = await historyService.getHistory();
    return List<XpEvent>.from(history.reversed).take(20).toList();
  }

  String _formatDate(DateTime dt, String locale) {
    final f = DateFormat('d MMM, HH:mm', locale);
    return f.format(dt);
  }

  String _labelForType(String type, AppLocalizations l10n) {
    switch (type) {
      case 'theory_view':
        return l10n.xpDashboardTheoryLabel;
      case 'drill_completed':
        return l10n.xpEventDrillCompleted;
      case 'module_completed':
        return l10n.xpEventModuleCompleted;
      default:
        return l10n.xpEventGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder<List<XpEvent>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snap.data ?? const <XpEvent>[];
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.xpRecapRecentEventsTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: l10n.xpExportHistoryTitle,
                            icon: const Icon(Icons.file_download),
                            onPressed: _isExporting
                                ? null
                                : () async {
                                    final method = await _openExportModal();
                                    if (method == null) return;
                                    await _exportHistory(method);
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (events.isEmpty)
                        Text(
                          l10n.xpRecapNoRecentEvents,
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      else
                        ...events.map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  e.type == 'drill_completed'
                                      ? Icons.fitness_center
                                      : e.type == 'module_completed'
                                      ? Icons.assignment_turned_in
                                      : Icons.menu_book,
                                  color: Colors.grey[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '+${e.amount} XP • ${_labelForType(e.type, l10n)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDate(
                                          e.timestamp,
                                          l10n.localeName,
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_HistoryExportMethod?> _openExportModal() async {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<_HistoryExportMethod>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        _HistoryExportMethod method = _HistoryExportMethod.copy;
        return StatefulBuilder(
          builder: (context, setState) => SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.xpExportHistoryTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<_HistoryExportMethod>(
                  groupValue: method,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => method = value);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        dense: true,
                        onTap: () =>
                            setState(() => method = _HistoryExportMethod.copy),
                        leading: const Radio<_HistoryExportMethod>(
                          value: _HistoryExportMethod.copy,
                        ),
                        title: Text(l10n.xpExportMethodCopy),
                      ),
                      ListTile(
                        dense: true,
                        onTap: () =>
                            setState(() => method = _HistoryExportMethod.share),
                        leading: const Radio<_HistoryExportMethod>(
                          value: _HistoryExportMethod.share,
                        ),
                        title: Text(l10n.xpExportMethodShare),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, method),
                          child: Text(l10n.export),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportHistory(_HistoryExportMethod method) async {
    final l10n = AppLocalizations.of(context)!;
    if (_isExporting) return;
    setState(() => _isExporting = true);

    final controller = XpHistoryExportController(
      historyService: XpHistoryService(),
      clipboardWriter: (text) => Clipboard.setData(ClipboardData(text: text)),
      shareHandler: const _FileShareHandler(
        tempDirProvider: getTemporaryDirectory,
        now: DateTime.now,
      ).call,
      showSuccess: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green[700]),
        );
      },
      showError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
        );
      },
      telemetryLogger: Telemetry.logEvent,
      labelForType: (type) => _labelForType(type, l10n),
      copySuccessMessage: l10n.xpExportCsvCopied,
      shareSuccessMessage: l10n.xpExportCsvShared,
      errorMessage: l10n.xpShareShareError,
      exportTitle: l10n.xpExportHistoryTitle,
    );

    try {
      await controller.export(
        method == _HistoryExportMethod.copy
            ? XpHistoryExportAction.copy
            : XpHistoryExportAction.share,
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

enum _HistoryExportMethod { copy, share }

class _FileShareHandler {
  const _FileShareHandler({required this.tempDirProvider, required this.now});

  final Future<Directory> Function() tempDirProvider;
  final DateTime Function() now;

  Future<void> call(String csv, String title) async {
    final dir = await tempDirProvider();
    final path = '${dir.path}/xp_history_${now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csv);
    await Share.shareXFiles([
      XFile(file.path, mimeType: 'text/csv'),
    ], text: title);
  }
}
