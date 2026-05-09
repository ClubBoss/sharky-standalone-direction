import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../infra/telemetry.dart';
import '../services/xp_service.dart';
import '../services/xp_history_export_controller.dart';
import '../services/xp_history_service.dart';
import '../services/xp_milestone_service.dart';
import '../widgets/xp_recapped_milestone_preview_card.dart';
import 'module_catalog_screen.dart';

extension _XpRecapL10n on AppLocalizations {
  bool get _isRu => localeName.toLowerCase().startsWith('ru');

  String get xpExportGoalsTitle =>
      _isRu ? 'Экспорт целей XP' : 'Export XP goals';
  String get xpExportMethodCopy => _isRu ? 'Копировать' : 'Copy';
  String get xpExportTypeImage => _isRu ? 'Изображение' : 'Image';
  String get xpExportTypeCsv => 'CSV';
  String get xpExportSuccessImage =>
      _isRu ? 'Изображение готово к экспорту' : 'Image export ready';
  String get xpExportCsvCopied =>
      _isRu ? 'CSV скопирован в буфер обмена' : 'CSV copied to clipboard';
  String get xpExportCsvShared =>
      _isRu ? 'CSV успешно отправлен' : 'CSV shared';
}

class XpRecapWeeklyPart extends StatefulWidget {
  XpRecapWeeklyPart({super.key});

  @override
  State<XpRecapWeeklyPart> createState() => _XpRecapWeeklyPartState();
}

class _XpRecapWeeklyPartState extends State<XpRecapWeeklyPart> {
  static const int _weeklyGoal = 50;

  late Future<_WeeklyData> _future;
  final GlobalKey _exportKey = GlobalKey();
  bool _isExporting = false;
  int? _lastGoalImpressionRemaining;

  @override
  void initState() {
    super.initState();
    _future = _load(context);
  }

  Future<void> _onRefresh() async {
    // Analytics: user pulled to refresh on goals tab
    unawaited(Telemetry.logEvent('xp_recap_refresh', {'tab': 'goals'}));
    final f = _load(context);
    if (!mounted) return;
    setState(() {
      _future = f;
    });
    await f;
  }

  Future<_WeeklyData> _load(BuildContext context) async {
    // total xp
    XpService? xpService;
    try {
      xpService = context.read<XpService>();
    } catch (_) {
      xpService = null;
    }
    xpService ??= XpService();
    await xpService.initialize();
    final total = xpService.getTotalXp();

    // history for weekly xp
    final historyService = XpHistoryService();
    final history = await historyService.getHistory();
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final monday00 = DateTime(monday.year, monday.month, monday.day);
    int weekly = 0;
    for (final e in history) {
      final d = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      if (!d.isBefore(monday00)) weekly += e.amount;
    }

    // milestones availability/next
    final mService = XpMilestoneService();
    final unlockedNotClaimed = await mService.getUnlockedButUnclaimedMilestones(
      total,
    );
    int? unclaimed;
    if (unlockedNotClaimed.isNotEmpty) {
      unlockedNotClaimed.sort();
      unclaimed = unlockedNotClaimed.first;
    }
    int? upcoming;
    for (final m in XpMilestoneService.milestones) {
      if (m > total) {
        upcoming = m;
        break;
      }
    }

    return _WeeklyData(
      totalXp: total,
      weeklyXp: weekly,
      unclaimedMilestone: unclaimed,
      upcomingMilestone: upcoming,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder<_WeeklyData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data =
              snap.data ??
              const _WeeklyData(
                totalXp: 0,
                weeklyXp: 0,
                unclaimedMilestone: null,
                upcomingMilestone: null,
              );

          final now = DateTime.now();
          final monday = now.subtract(Duration(days: now.weekday - 1));
          final sunday = monday.add(const Duration(days: 6));
          final fmt = DateFormat('d MMM', l10n.localeName);

          final progress = (data.weeklyXp / _weeklyGoal).clamp(0.0, 1.0);
          final isComplete = data.weeklyXp >= _weeklyGoal;

          return RepaintBoundary(
            key: _exportKey,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // Weekly goal encouragement banner
                _buildWeeklyGoalBanner(l10n, data.weeklyXp),
                // Top-right export action
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      tooltip: l10n.xpExportGoalsTitle,
                      icon: const Icon(Icons.file_download),
                      onPressed: _isExporting
                          ? null
                          : () async {
                              final result = await _openExportGoalsModal();
                              if (result == null) return;
                              await _exportGoals(result, l10n);
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Weekly goal card
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
                              Icons.emoji_events,
                              color: Colors.amber[700],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.xpRecapWeeklyGoalTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${data.weeklyXp} / $_weeklyGoal XP',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isComplete ? Colors.green : Colors.amber[600]!,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${fmt.format(monday)}–${fmt.format(sunday)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (isComplete)
                              Text(
                                '✓ ${l10n.xpWeeklyGoalComplete}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Milestones card (extracted reusable widget)
                XpRecappedMilestonePreviewCard(
                  totalXp: data.totalXp,
                  unclaimedMilestone: data.unclaimedMilestone,
                  upcomingMilestone: data.upcomingMilestone,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyGoalBanner(AppLocalizations l10n, int weeklyXp) {
    final goal = _weeklyGoal > 0 ? _weeklyGoal : 50; // safe fallback
    final remaining = (goal - weeklyXp).clamp(0, goal);
    if (remaining <= 0) return const SizedBox.shrink();

    // Inline EN/RU strings only
    final isRu = l10n.localeName.startsWith('ru');
    final title = isRu ? 'Продолжайте' : 'Keep going';
    final msg = isRu
        ? 'Осталось всего $remaining XP до цели недели!'
        : "You're only $remaining XP away from your weekly goal!";
    final cta = isRu ? 'Тренироваться' : 'Train now';

    // Telemetry: impression (log once per remaining value)
    if (_lastGoalImpressionRemaining != remaining) {
      _lastGoalImpressionRemaining = remaining;
      unawaited(
        Telemetry.logEvent('xp_recap_weekly_goal_impression', {
          'remaining_xp': remaining,
        }),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: Colors.blue, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  msg,
                  style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              unawaited(
                Telemetry.logEvent('xp_recap_weekly_goal_tap', {
                  'remaining_xp': remaining,
                }),
              );
              unawaited(
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ModuleCatalogScreen()),
                ),
              );
            },
            child: Text(cta),
          ),
        ],
      ),
    );
  }

  Widget _radioTile<T>({
    required T value,
    required T groupValue,
    required String label,
    required ValueChanged<T> onChanged,
  }) => ListTile(
    dense: true,
    leading: Radio<T>(
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    ),
    title: Text(label),
    onTap: () => onChanged(value),
  );

  Future<_GoalsExportResult?> _openExportGoalsModal() async {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<_GoalsExportResult>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        _GoalsExportMethod method = _GoalsExportMethod.copy;
        _GoalsExportType type = _GoalsExportType.image;
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
                  l10n.xpExportGoalsTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                // Method
                _radioTile<_GoalsExportMethod>(
                  value: _GoalsExportMethod.copy,
                  groupValue: method,
                  label: l10n.xpExportMethodCopy,
                  onChanged: (v) => setState(() => method = v),
                ),
                _radioTile<_GoalsExportMethod>(
                  value: _GoalsExportMethod.share,
                  groupValue: method,
                  label: l10n.xpExportMethodShare,
                  onChanged: (v) => setState(() => method = v),
                ),
                const SizedBox(height: 8),
                // Type
                _radioTile<_GoalsExportType>(
                  value: _GoalsExportType.image,
                  groupValue: type,
                  label: l10n.xpExportTypeImage,
                  onChanged: (v) => setState(() => type = v),
                ),
                _radioTile<_GoalsExportType>(
                  value: _GoalsExportType.csv,
                  groupValue: type,
                  label: l10n.xpExportTypeCsv,
                  onChanged: (v) => setState(() => type = v),
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
                          onPressed: () => Navigator.pop(
                            context,
                            _GoalsExportResult(method, type),
                          ),
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

  Future<void> _exportGoals(
    _GoalsExportResult res,
    AppLocalizations l10n,
  ) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    var csvErrorHandled = false;
    try {
      unawaited(
        Telemetry.logEvent('xp_recap_goals_export_tap', {
          'method': res.method == _GoalsExportMethod.copy ? 'copy' : 'share',
          'type': res.type == _GoalsExportType.image ? 'image' : 'csv',
        }),
      );

      if (res.type == _GoalsExportType.image) {
        final bytes = await _captureExportImage();
        if (bytes == null) throw Exception('capture failed');
        if (res.method == _GoalsExportMethod.copy) {
          final dataUri = 'data:image/png;base64,${base64Encode(bytes)}';
          await Clipboard.setData(ClipboardData(text: dataUri));
          _showSnack(l10n.xpExportSuccessImage, success: true);
        } else {
          final tmp = await getTemporaryDirectory();
          final file = File(
            '${tmp.path}/xp_goals_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          await file.writeAsBytes(bytes);
          await Share.shareXFiles([XFile(file.path)]);
          _showSnack(l10n.xpExportSuccessImage, success: true);
        }
      } else {
        final controller = _buildCsvController(
          l10n: l10n,
          onErrorHandled: () => csvErrorHandled = true,
        );
        await controller.export(
          res.method == _GoalsExportMethod.copy
              ? XpHistoryExportAction.copy
              : XpHistoryExportAction.share,
        );
        if (csvErrorHandled) {
          return;
        }
      }

      unawaited(
        Telemetry.logEvent('xp_recap_goals_export_success', {
          'method': res.method == _GoalsExportMethod.copy ? 'copy' : 'share',
          'type': res.type == _GoalsExportType.image ? 'image' : 'csv',
        }),
      );
    } catch (_) {
      if (!csvErrorHandled) {
        _showSnack(l10n.xpShareShareError, success: false);
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<Uint8List?> _captureExportImage() async {
    try {
      final boundary =
          _exportKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  void _showSnack(String text, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: success ? Colors.green[700] : Colors.red[700],
      ),
    );
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

  XpHistoryExportController _buildCsvController({
    required AppLocalizations l10n,
    required VoidCallback onErrorHandled,
  }) => XpHistoryExportController(
    historyService: _WeeklyHistoryService(),
    clipboardWriter: (text) => Clipboard.setData(ClipboardData(text: text)),
    shareHandler: const _GoalsCsvShareHandler(
      tempDirProvider: getTemporaryDirectory,
      now: DateTime.now,
    ).call,
    showSuccess: (message) => _showSnack(message, success: true),
    showError: (message) {
      onErrorHandled();
      _showSnack(message, success: false);
    },
    telemetryLogger: Telemetry.logEvent,
    labelForType: (type) => _labelForType(type, l10n),
    copySuccessMessage: l10n.xpExportCsvCopied,
    shareSuccessMessage: l10n.xpExportCsvShared,
    errorMessage: l10n.xpShareShareError,
    exportTitle: l10n.xpExportGoalsTitle,
    dateFormat: DateFormat('yyyy-MM-dd'),
  );
}

enum _GoalsExportMethod { copy, share }

enum _GoalsExportType { image, csv }

class _GoalsExportResult {
  final _GoalsExportMethod method;
  final _GoalsExportType type;
  const _GoalsExportResult(this.method, this.type);
}

class _WeeklyData {
  final int totalXp;
  final int weeklyXp;
  final int? unclaimedMilestone;
  final int? upcomingMilestone;
  const _WeeklyData({
    required this.totalXp,
    required this.weeklyXp,
    required this.unclaimedMilestone,
    required this.upcomingMilestone,
  });
}

class _GoalsCsvShareHandler {
  const _GoalsCsvShareHandler({
    required this.tempDirProvider,
    required this.now,
  });

  final Future<Directory> Function() tempDirProvider;
  final DateTime Function() now;

  Future<void> call(String csv, String title) async {
    final dir = await tempDirProvider();
    final file = File(
      '${dir.path}/xp_goals_${now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csv);
    await Share.shareXFiles([
      XFile(file.path, mimeType: 'text/csv'),
    ], text: title);
  }
}

class _WeeklyHistoryService extends XpHistoryService {
  @override
  Future<List<XpEvent>> getHistory() async {
    final history = await super.getHistory();
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStart = DateTime(monday.year, monday.month, monday.day);
    return history.where((event) {
      final eventDate = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );
      return !eventDate.isBefore(mondayStart);
    }).toList();
  }
}
