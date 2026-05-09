import 'dart:async';
import 'package:flutter/material.dart';
import '../services/booster_market_service.dart';
import '../services/booster_service.dart';

/// Displays the Daily Booster claim card with 24h cooldown.
class BoosterMarketCard extends StatefulWidget {
  final bool enableAutoRefresh;
  const BoosterMarketCard({super.key, this.enableAutoRefresh = true});

  @override
  State<BoosterMarketCard> createState() => _BoosterMarketCardState();
}

class _BoosterMarketCardState extends State<BoosterMarketCard> {
  bool _loading = true;
  bool _canClaim = false;
  Duration _remaining = Duration.zero;
  BoosterType _nextType = BoosterType.study;
  Timer? _timer;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final svc = BoosterMarketService.instance;
    final can = await svc.canClaimNow();
    final remaining = await svc.timeUntilNext();
    final nextType = await svc.nextType();
    if (!mounted || _disposed) return;
    setState(() {
      _canClaim = can;
      _remaining = remaining;
      _nextType = nextType;
      _loading = false;
    });

    _timer?.cancel();
    if (widget.enableAutoRefresh && !_canClaim && mounted && !_disposed) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
    }
  }

  String _icon(BoosterType type) {
    switch (type) {
      case BoosterType.study:
        return '📚';
      case BoosterType.play:
        return '🎮';
      case BoosterType.review:
        return '🔍';
    }
  }

  String _label(BuildContext context, BoosterType type) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    if (isRu) {
      switch (type) {
        case BoosterType.study:
          return 'Бустер обучения 2x';
        case BoosterType.play:
          return 'Бустер игры 2x';
        case BoosterType.review:
          return 'Бустер обзора 2x';
      }
    } else {
      switch (type) {
        case BoosterType.study:
          return 'Study Booster 2x';
        case BoosterType.play:
          return 'Play Booster 2x';
        case BoosterType.review:
          return 'Review Booster 2x';
      }
    }
  }

  String _title(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Ежедневный бустер' : 'Daily Booster';
  }

  String _reward(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Бесплатный 2x XP' : 'Free 2x XP';
  }

  String _cooldownLabel(BuildContext context, Duration d) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final rem = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    if (isRu) {
      final ruRem = hours > 0 ? '$hoursч $minutesм' : '$minutesм';
      return 'Забрано, через $ruRem';
    }
    return 'Claimed, next in $rem';
  }

  Future<void> _claim() async {
    final svc = BoosterMarketService.instance;
    final ok = await svc.claimBooster();
    if (!mounted || _disposed) return;
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (ok) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            isRu ? 'Бустер добавлен в инвентарь' : 'Booster added to inventory',
          ),
        ),
      );
    } else {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(isRu ? 'Нельзя получить сейчас' : 'Cannot claim now'),
        ),
      );
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();
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
        child: Row(
          children: [
            Text(_icon(_nextType), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
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
                  const SizedBox(height: 4),
                  Text(
                    _label(context, _nextType),
                    style: TextStyle(fontSize: 14, color: onSurfaceColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _reward(context),
                    style: TextStyle(
                      fontSize: 12,
                      color: onSurfaceColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _canClaim
                ? FilledButton(
                    onPressed: _claim,
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'ru'
                          ? 'Забрать'
                          : 'Claim',
                    ),
                  )
                : FilledButton.tonal(
                    onPressed: null,
                    child: Text(_cooldownLabel(context, _remaining)),
                  ),
          ],
        ),
      ),
    );
  }
}
