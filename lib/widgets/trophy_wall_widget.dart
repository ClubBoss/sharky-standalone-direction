import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/league_tier_badge.dart';
import '../models/xp_trophy.dart';
import '../services/xp_history_service.dart';
import '../services/xp_service.dart';
import '../services/xp_trophy_service.dart';

/// Read-only wall showing unlocked XP trophies.
class TrophyWallWidget extends StatefulWidget {
  const TrophyWallWidget({super.key});

  @override
  State<TrophyWallWidget> createState() => _TrophyWallWidgetState();
}

class _TrophyWallWidgetState extends State<TrophyWallWidget> {
  late final XpTrophyService _service;
  late final XpService _xpService;
  late bool _isRu;
  List<XpEvent> _xpHistory = const [];
  int? _currentXp;

  @override
  void initState() {
    super.initState();
    _service = XpTrophyService.instance;
    _xpService = XpService();
    // Initialize service (loads persisted trophies) and listen for changes
    _service.init();
    _service.notifier.addListener(_onTrophiesChanged);
    _refreshXpContext();
  }

  void _onTrophiesChanged() {
    if (!mounted) return;
    setState(() {});
    _refreshXpContext();
  }

  @override
  void dispose() {
    _service.notifier.removeListener(_onTrophiesChanged);
    super.dispose();
  }

  Future<void> _refreshXpContext() async {
    await _xpService.initialize();
    final history = await XpHistoryService().getHistory();
    final total = _xpService.getTotalXp();
    if (!mounted) return;
    setState(() {
      _xpHistory = history;
      _currentXp = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isRu = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('ru');
    final unlocked = _service.unlocked;
    final unlockedByType = {for (final entry in unlocked) entry.type: entry};

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isRu ? 'Трофеи' : 'Trophies',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final tiles = XpTrophy.all
                    .map(
                      (trophy) => _buildTile(
                        trophy: trophy,
                        entry: unlockedByType[trophy],
                      ),
                    )
                    .toList();
                final columns = _columnsForWidth(constraints.maxWidth);
                final tileWidth = _tileWidthFor(constraints.maxWidth, columns);
                return Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: tiles
                      .map((tile) => SizedBox(width: tileWidth, child: tile))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  int _columnsForWidth(double width) {
    if (width == double.infinity || width.isNaN) return 2;
    final minTileWidth = 140;
    final raw = (width / minTileWidth).floor();
    return raw.clamp(2, 4).toInt();
  }

  double _tileWidthFor(double width, int columns) {
    if (width == double.infinity || width.isNaN) return 160;
    final spacing = (columns - 1) * 8;
    final available = math.max(width - spacing, 120.0);
    return available / columns;
  }

  Widget _buildTile({required XpTrophy trophy, XpTrophyEntry? entry}) {
    final isUnlocked = entry != null;
    final title = trophy.title(isRu: _isRu);
    final desc = trophy.description(isRu: _isRu);
    final statusLabel = isUnlocked
        ? (_isRu ? 'Открыто' : 'Unlocked')
        : (_isRu ? 'Заблокировано' : 'Locked');

    final accent = isUnlocked ? Colors.amber[400]! : Colors.grey[600]!;
    final bgColor = isUnlocked
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.05);
    final textColor = isUnlocked ? Colors.white : Colors.white70;
    final borderColor = isUnlocked
        ? Colors.amber[200]!.withValues(alpha: 0.8)
        : Colors.grey[800]!;
    LeagueTierBadge? badge;
    String? badgeTooltip;
    if (isUnlocked) {
      final xpAtUnlock = _xpAtUnlock(entry);
      badge = LeagueTierBadge.resolve(xp: xpAtUnlock);
      badgeTooltip = _badgeTooltip(badge);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isUnlocked ? 1 : 0.4,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isUnlocked ? 0.25 : 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    trophy.iconName,
                    style: TextStyle(fontSize: 22, color: accent),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: isUnlocked ? Colors.white70 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isUnlocked
                    ? Icons.verified_rounded
                    : Icons.lock_outline_rounded,
                size: 16,
                color: isUnlocked ? accent : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ),
              if (isUnlocked)
                Text(
                  _formatDate(entry.achievedAt),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFeatures: [FontFeature.tabularFigures()],
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
          if (isUnlocked && badge != null && badgeTooltip != null) ...[
            const SizedBox(height: 6),
            Tooltip(
              message: badgeTooltip,
              child: Semantics(
                label: badgeTooltip,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${badge.emoji} ${badge.label(_isRu ? 'ru' : 'en')}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime timestamp) {
    final local = timestamp.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$year-$month-$day';
  }

  int _xpAtUnlock(XpTrophyEntry entry) {
    final total = _currentXp ?? _xpService.getTotalXp();
    if (_xpHistory.isEmpty) return total;
    final xpAfter = _xpHistory
        .where((event) => event.timestamp.isAfter(entry.achievedAt))
        .fold<int>(0, (sum, event) => sum + event.amount);
    final xp = total - xpAfter;
    if (xp < 0) return 0;
    return xp;
  }

  String _badgeTooltip(LeagueTierBadge badge) {
    final label = badge.label(_isRu ? 'ru' : 'en');
    return _isRu
        ? 'Открыто как ${badge.emoji} $label'
        : 'Unlocked as ${badge.emoji} $label';
  }
}
