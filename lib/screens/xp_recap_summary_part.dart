import 'dart:async' show unawaited;
import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../infra/telemetry.dart';

import '../l10n/app_localizations.dart';
import '../services/xp_milestone_service.dart';
import '../services/xp_service.dart';
import '../services/league_engine.dart';
import '../services/challenge_service.dart';
import '../services/session_log_service.dart';
import '../models/challenge_definition.dart';
import '../widgets/xp_progress_ring_block.dart';
import '../widgets/xp_recapped_milestone_preview_card.dart';
import 'module_catalog_screen.dart';

extension _XpSummaryL10n on AppLocalizations {
  bool get _isRu => localeName.toLowerCase().startsWith('ru');

  String get xpExportSummaryTitle =>
      _isRu ? 'Настройки экспорта XP' : 'XP Export Settings';
  String get xpExportCaptionLabelSummary => _isRu ? 'Подпись' : 'Caption';
  String get xpExportMethodLabelSummary => _isRu ? 'Метод' : 'Method';
  String get xpExportMethodSaveSummary => _isRu ? 'Сохранить' : 'Save';
  String get xpExportMethodShareSummary => _isRu ? 'Поделиться' : 'Share';
  String get xpExportMethodCopySummary => _isRu ? 'Скопировать' : 'Copy';
}

class XpRecapSummaryPart extends StatefulWidget {
  XpRecapSummaryPart({super.key});

  @override
  State<XpRecapSummaryPart> createState() => _XpRecapSummaryPartState();
}

class _XpRecapSummaryPartState extends State<XpRecapSummaryPart> {
  late Future<_SummaryData> _future;
  final GlobalKey _cardKey = GlobalKey();
  bool _isSaving = false;

  // Persisted export settings (defaults applied if not set)
  static const _prefCaptionKey = 'xp_recap_export_caption_key';
  static const _prefShowLeague = 'xp_recap_export_show_league';
  static const _prefShowMilestones = 'xp_recap_export_show_milestones';

  static const String _capBeast = 'beast';
  static const String _capSummit = 'summit';
  static const String _capGreat = 'great';
  static const String _capKeepGoing = 'keepGoing';
  static const String _capLetsGo = 'letsGo';
  static const String _capStarting = 'starting';

  String _captionKey = _capBeast; // default
  bool _showLeague = true; // default
  bool _showMilestones = true; // default

  // Export method selection for modal
  _ExportMethod _defaultMethod = _ExportMethod.save;

  @override
  void initState() {
    super.initState();
    _future = _load(context);
    _loadPrefs();
  }

  Future<void> _onRefresh() async {
    // Analytics: user pulled to refresh on summary tab
    unawaited(Telemetry.logEvent('xp_recap_refresh', {'tab': 'summary'}));
    final f = _load(context);
    if (!mounted) return;
    setState(() {
      _future = f;
    });
    await f;
  }

  Future<_SummaryData> _load(BuildContext context) async {
    XpService? xpService;
    try {
      xpService = context.read<XpService>();
    } catch (_) {
      xpService = null;
    }
    xpService ??= XpService();
    await xpService.initialize();
    final total = xpService.getTotalXp();

    int? upcoming;
    for (final m in XpMilestoneService.milestones) {
      if (m > total) {
        upcoming = m;
        break;
      }
    }
    final int? nextMilestone =
        upcoming ??
        (XpMilestoneService.milestones.isNotEmpty
            ? XpMilestoneService.milestones.last
            : null);
    final double nextProgress = (nextMilestone != null && nextMilestone > 0)
        ? (total / nextMilestone).clamp(0.0, 1.0)
        : 0.0;
    final milestoneService = XpMilestoneService();
    final unlockedNotClaimed = await milestoneService
        .getUnlockedButUnclaimedMilestones(total);
    int? unclaimedMilestone;
    if (unlockedNotClaimed.isNotEmpty) {
      unlockedNotClaimed.sort();
      unclaimedMilestone = unlockedNotClaimed.first;
    }

    int leagueRank = 0;
    try {
      // Simulate a simple league rank based on total XP
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final weekSeed =
          DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 60 * 60 * 1000);
      final leagueEngine = LeagueEngine();
      final leagueEntries = leagueEngine.simulateWeeklyLeague(
        userXp: total,
        userId: userId,
        weekSeed: weekSeed,
      );
      leagueRank = leagueEntries.firstWhere((e) => e.isUser).rank;
    } catch (_) {
      leagueRank = 0;
    }

    // Compute streak risk hours left (<= 24h left to keep streak)
    int? streakRiskHoursLeft;
    try {
      final logs = await SessionLogService.instance.getLogs();
      if (logs.isNotEmpty) {
        logs.sort((a, b) => a.startTime.compareTo(b.startTime));
        final lastEntry = logs.last;
        final last = DateTime(
          lastEntry.startTime.year,
          lastEntry.startTime.month,
          lastEntry.startTime.day,
        );
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final diffDays = today.difference(last).inDays;
        // If last active was yesterday, user has until end of today to keep streak.
        if (diffDays == 1) {
          final nextMidnight = today.add(const Duration(days: 1));
          final hours = nextMidnight.difference(now).inHours;
          if (hours >= 0 && hours <= 24) {
            streakRiskHoursLeft = hours;
          }
        }
      }
    } catch (_) {
      // Ignore risk calculation errors gracefully
    }

    return _SummaryData(
      totalXp: total,
      nextMilestone: nextMilestone,
      nextMilestoneProgress: nextProgress,
      leagueRank: leagueRank,
      streakRiskHoursLeft: streakRiskHoursLeft,
      unclaimedMilestone: unclaimedMilestone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder<_SummaryData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          if (data == null) {
            return _paddedList([
              // No data state
              _xpCard(l10n, 0, null, null, 0, leagueRank: 0),
            ]);
          }
          return _paddedList([
            if (data.streakRiskHoursLeft != null)
              _buildStreakRiskBanner(l10n, data.streakRiskHoursLeft!),
            _xpCard(
              l10n,
              data.totalXp,
              data.nextMilestone,
              data.unclaimedMilestone,
              data.nextMilestoneProgress,
              leagueRank: data.leagueRank,
            ),
            const SizedBox(height: 16),
            _buildWeeklyChallengeCard(l10n),
          ]);
        },
      ),
    );
  }

  Widget _paddedList(List<Widget> children) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    children: children,
  );

  Widget _xpCard(
    AppLocalizations l10n,
    int totalXp,
    int? nextMilestone,
    int? unclaimedMilestone,
    double nextProgress, {
    required int leagueRank,
  }) => RepaintBoundary(
    key: _cardKey,
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (nextMilestone != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '${(nextProgress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      IconButton(
                        tooltip: l10n.xpShareTab,
                        icon: const Icon(Icons.settings),
                        onPressed: _isSaving ? null : _openExportSettings,
                      ),
                      IconButton(
                        tooltip: l10n.xpShareSaveButton,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_alt),
                        onPressed: _isSaving
                            ? null
                            : () {
                                unawaited(
                                  Telemetry.logEvent('xp_recap_export_tap', {
                                    'action': 'save',
                                  }),
                                );
                                _saveToGallery();
                              },
                      ),
                      IconButton(
                        tooltip: l10n.xpShareShareButton,
                        icon: const Icon(Icons.share),
                        onPressed: _isSaving
                            ? null
                            : () {
                                unawaited(
                                  Telemetry.logEvent('xp_recap_export_tap', {
                                    'action': 'share',
                                  }),
                                );
                                _shareCard();
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: XpProgressRingBlock(
                totalXp: totalXp,
                milestoneXp: nextMilestone ?? totalXp,
                percent: nextProgress,
                caption: _captionText(l10n),
                leagueRank: _showLeague ? leagueRank : null,
              ),
            ),
            if (_showMilestones) ...[
              const SizedBox(height: 16),
              _buildMilestonePreviewCard(
                totalXp,
                unclaimedMilestone,
                nextMilestone,
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: nextProgress,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  String _captionText(AppLocalizations l10n) {
    switch (_captionKey) {
      case _capSummit:
        return l10n.xpShareCaptionSummit;
      case _capGreat:
        return l10n.xpShareCaptionGreat;
      case _capKeepGoing:
        return l10n.xpShareCaptionKeepGoing;
      case _capLetsGo:
        return l10n.xpShareCaptionLetsGo;
      case _capStarting:
        return l10n.xpShareCaptionGettingStarted;
      case _capBeast:
      default:
        return l10n.xpShareCaptionBeast;
    }
  }

  Widget _buildStreakRiskBanner(AppLocalizations l10n, int hoursLeft) {
    // Minimal EN/RU localization inline to avoid modifying l10n files.
    final isRu = l10n.localeName.startsWith('ru');
    final title = isRu ? 'Серия под угрозой' : 'Streak at risk';
    final msg = isRu
        ? 'Осталось $hoursLeft ч, чтобы сохранить серию.'
        : '$hoursLeft h left to keep your streak.';
    final cta = isRu ? 'Тренироваться' : 'Train now';

    // Telemetry: impression
    unawaited(
      Telemetry.logEvent('xp_recap_streak_risk_impression', {
        'hours_left': hoursLeft,
      }),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.orange,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
                Telemetry.logEvent('xp_recap_streak_risk_tap', {
                  'hours_left': hoursLeft,
                }),
              );
              // Navigate to training catalog for quick session
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ModuleCatalogScreen()),
              );
            },
            child: Text(cta),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonePreviewCard(
    int totalXp,
    int? unclaimedMilestone,
    int? upcomingMilestone,
  ) => Theme(
    data: Theme.of(
      context,
    ).copyWith(cardTheme: const CardThemeData(margin: EdgeInsets.zero)),
    child: XpRecappedMilestonePreviewCard(
      totalXp: totalXp,
      unclaimedMilestone: unclaimedMilestone,
      upcomingMilestone: upcomingMilestone,
    ),
  );

  Widget _buildWeeklyChallengeCard(AppLocalizations l10n) {
    final isRu = l10n.localeName.startsWith('ru');
    final service = ChallengeService.instance;

    return FutureBuilder(
      future: service.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        return ValueListenableBuilder<ChallengeInstance?>(
          valueListenable: service.listenTo(ChallengeDuration.weekly),
          builder: (context, instance, _) {
            if (instance == null) return const SizedBox.shrink();
            final def = instance.definition;
            final percent = instance.progressRatio;
            final completed = instance.completed;
            final rewardLabel = isRu
                ? 'Награда: +${def.rewardXp} XP'
                : 'Reward: +${def.rewardXp} XP';
            final progressLabel =
                '${instance.progress}/${def.goal} ${def.metric == ChallengeMetric.xp ? 'XP' : ''}'
                    .trim();
            final timeLeft = instance.timeLeft;
            final timeLabel = _formatTimeLeft(timeLeft, isRu);

            return Card(
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
                          completed ? Icons.check_circle : Icons.flag,
                          color: completed ? Colors.green : Colors.amber[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isRu ? 'Еженедельный вызов' : 'Weekly Challenge',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      def.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      def.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completed ? Colors.green : Colors.amber[600]!,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          progressLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(percent * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rewardLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    if (!completed) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ModuleCatalogScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: Text(isRu ? 'Тренироваться' : 'Train now'),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Text(
                        isRu
                            ? 'Бонус за вызов уже зачислен! Отличная работа.'
                            : 'Challenge bonus already awarded! Great job.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimeLeft(Duration duration, bool isRu) {
    if (duration <= Duration.zero) {
      return isRu ? '0ч' : '0h';
    }
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    if (days > 0) {
      final dayLabel = isRu ? 'д' : 'd';
      final hourLabel = isRu ? 'ч' : 'h';
      return '$days$dayLabel $hours$hourLabel';
    }
    final totalHours = duration.inHours;
    if (totalHours > 0) {
      final label = isRu ? 'ч' : 'h';
      return '$totalHours$label';
    }
    final minutes = duration.inMinutes.clamp(0, 59);
    final label = isRu ? 'мин' : 'm';
    return '$minutes$label';
  }

  Future<void> _saveToGallery() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      final image = await _captureCard();
      if (image == null) {
        throw Exception('capture failed');
      }
      final result = await ImageGallerySaver.saveImage(
        image,
        quality: 100,
        name: 'pa_xp_summary_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (!mounted) return;
      if ((result['isSuccess'] as bool?) == true) {
        // Analytics: export save success
        unawaited(
          Telemetry.logEvent('xp_recap_export_success', {'action': 'save'}),
        );
        _showSuccess(l10n.xpShareSaveSuccess);
      } else {
        throw Exception('save failed');
      }
    } catch (_) {
      if (!mounted) return;
      _showError(l10n.xpShareSaveError);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareCard() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      final image = await _captureCard();
      if (image == null) {
        throw Exception('capture failed');
      }
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/xp_summary_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(image);
      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)]);
      // Analytics: export share success (after share intent)
      unawaited(
        Telemetry.logEvent('xp_recap_export_success', {'action': 'share'}),
      );
    } catch (_) {
      if (!mounted) return;
      _showError(l10n.xpShareShareError);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<Uint8List?> _captureCard() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green[700]),
    );
  }

  Future<void> _copyToClipboard() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      final image = await _captureCard();
      if (image == null) {
        throw Exception('capture failed');
      }
      // Encode PNG as a data URI for clipboard compatibility fallback.
      final dataUri = 'data:image/png;base64,${base64Encode(image)}';
      await Clipboard.setData(ClipboardData(text: dataUri));
      if (!mounted) return;
      // Analytics: export copy success
      unawaited(
        Telemetry.logEvent('xp_recap_export_success', {'action': 'copy'}),
      );
      _showSuccess(l10n.copied);
    } catch (_) {
      if (!mounted) return;
      _showError(l10n.xpShareShareError);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _captionKey = p.getString(_prefCaptionKey) ?? _capBeast;
      _showLeague = p.getBool(_prefShowLeague) ?? true;
      _showMilestones = p.getBool(_prefShowMilestones) ?? true;
    });
  }

  Future<void> _savePrefs({
    required String captionKey,
    required bool showLeague,
    required bool showMilestones,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefCaptionKey, captionKey);
    await p.setBool(_prefShowLeague, showLeague);
    await p.setBool(_prefShowMilestones, showMilestones);
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

  Future<void> _openExportSettings() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showModalBottomSheet<_ExportConfigResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String caption = _captionKey;
        bool showLeague = _showLeague;
        bool showMilestones = _showMilestones;
        _ExportMethod method = _defaultMethod;
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
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
                    l10n.xpExportSummaryTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: caption,
                      decoration: InputDecoration(
                        labelText: l10n.xpExportCaptionLabelSummary,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: _capBeast,
                          child: Text(l10n.xpShareCaptionBeast),
                        ),
                        DropdownMenuItem(
                          value: _capSummit,
                          child: Text(l10n.xpShareCaptionSummit),
                        ),
                        DropdownMenuItem(
                          value: _capGreat,
                          child: Text(l10n.xpShareCaptionGreat),
                        ),
                        DropdownMenuItem(
                          value: _capKeepGoing,
                          child: Text(l10n.xpShareCaptionKeepGoing),
                        ),
                        DropdownMenuItem(
                          value: _capLetsGo,
                          child: Text(l10n.xpShareCaptionLetsGo),
                        ),
                        DropdownMenuItem(
                          value: _capStarting,
                          child: Text(l10n.xpShareCaptionGettingStarted),
                        ),
                      ],
                      onChanged: (v) =>
                          setModalState(() => caption = v ?? caption),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.xpExportMethodLabelSummary,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  _radioTile<_ExportMethod>(
                    value: _ExportMethod.save,
                    groupValue: method,
                    label: l10n.xpExportMethodSaveSummary,
                    onChanged: (v) => setModalState(() => method = v),
                  ),
                  _radioTile<_ExportMethod>(
                    value: _ExportMethod.share,
                    groupValue: method,
                    label: l10n.xpExportMethodShareSummary,
                    onChanged: (v) => setModalState(() => method = v),
                  ),
                  _radioTile<_ExportMethod>(
                    value: _ExportMethod.copy,
                    groupValue: method,
                    label: l10n.xpExportMethodCopySummary,
                    onChanged: (v) => setModalState(() => method = v),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: showLeague,
                    onChanged: (v) => setModalState(() => showLeague = v),
                    title: Text(l10n.xpLeagueTab),
                  ),
                  SwitchListTile(
                    value: showMilestones,
                    onChanged: (v) => setModalState(() => showMilestones = v),
                    title: Text(l10n.xpShareMilestonesLabel),
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
                            onPressed: () {
                              Navigator.pop(
                                context,
                                _ExportConfigResult(
                                  captionKey: caption,
                                  showLeague: showLeague,
                                  showMilestones: showMilestones,
                                  method: method,
                                ),
                              );
                            },
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
          ),
        );
      },
    );

    if (result == null) return; // cancelled

    // Persist only on Export
    await _savePrefs(
      captionKey: result.captionKey,
      showLeague: result.showLeague,
      showMilestones: result.showMilestones,
    );

    if (!mounted) return;
    setState(() {
      _captionKey = result.captionKey;
      _showLeague = result.showLeague;
      _showMilestones = result.showMilestones;
    });

    // Ensure UI updates before capture
    await Future.delayed(const Duration(milliseconds: 16));
    // Log export tap based on chosen method
    unawaited(
      Telemetry.logEvent('xp_recap_export_tap', {
        'action': result.method == _ExportMethod.share
            ? 'share'
            : result.method == _ExportMethod.copy
            ? 'copy'
            : 'save',
      }),
    );

    // Call chosen export flow
    if (result.method == _ExportMethod.share) {
      await _shareCard();
    } else if (result.method == _ExportMethod.copy) {
      await _copyToClipboard();
    } else {
      await _saveToGallery();
    }
  }
}

class _ExportConfigResult {
  final String captionKey;
  final bool showLeague;
  final bool showMilestones;
  final _ExportMethod method;
  const _ExportConfigResult({
    required this.captionKey,
    required this.showLeague,
    required this.showMilestones,
    required this.method,
  });
}

class _SummaryData {
  final int totalXp;
  final int? nextMilestone;
  final int? unclaimedMilestone;
  final double nextMilestoneProgress;
  final int leagueRank;
  final int? streakRiskHoursLeft;
  const _SummaryData({
    required this.totalXp,
    required this.nextMilestone,
    required this.unclaimedMilestone,
    required this.nextMilestoneProgress,
    required this.leagueRank,
    this.streakRiskHoursLeft,
  });
}

enum _ExportMethod { save, share, copy }
