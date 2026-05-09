import 'package:flutter/material.dart';
import 'dart:async';
import '../services/booster_service.dart';
import '../services/xp_booster_inventory_service.dart';

/// BoosterCard displays the active XP booster with countdown timer.
/// Auto-hides when no booster is active.
class BoosterCard extends StatefulWidget {
  final bool enableAutoRefresh;
  const BoosterCard({super.key, this.enableAutoRefresh = true});

  @override
  State<BoosterCard> createState() => _BoosterCardState();
}

class _BoosterCardState extends State<BoosterCard> {
  ActiveBooster? _activeBooster;
  bool _isLoading = true;
  Timer? _refreshTimer;
  bool _isDisposed = false;
  List<BoosterType> _inventory = const [];

  @override
  void initState() {
    super.initState();
    _loadBoosterStatus();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBoosterStatus() async {
    final service = BoosterService.getInstance();
    await service.init();
    final booster = await service.getActive();
    final inv = await XpBoosterInventoryService.instance.getInventory();
    if (mounted && !_isDisposed) {
      setState(() {
        _activeBooster = booster;
        _isLoading = false;
        _inventory = inv;
      });
    }

    // Set up periodic refresh timer
    _refreshTimer?.cancel();
    if (widget.enableAutoRefresh &&
        booster != null &&
        mounted &&
        !_isDisposed) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (!mounted || _isDisposed) {
          timer.cancel();
          return;
        }
        _loadBoosterStatus();
      });
    }
  }

  Future<void> _promptUseBooster() async {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    BoosterType? selected;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(isRu ? 'Выбрать бустер' : 'Choose a Booster'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _inventory
                .map(
                  (t) => ListTile(
                    leading: Text(
                      _getBoosterIcon(t),
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(_getBoosterLabel(context, t)),
                    onTap: () {
                      selected = t;
                      Navigator.of(ctx).pop();
                    },
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isRu ? 'Отмена' : 'Cancel'),
          ),
        ],
      ),
    );
    if (selected == null) return;
    // Activate and remove from inventory
    final service = BoosterService.getInstance();
    await service.init();
    await service.activate(selected!);
    await XpBoosterInventoryService.instance.useBooster(selected!);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(isRu ? 'Бустер активирован!' : 'Booster activated!'),
      ),
    );
    await _loadBoosterStatus();
  }

  String _getBoosterLabel(BuildContext context, BoosterType type) {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == 'ru') {
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

  String _getBoosterIcon(BoosterType type) {
    switch (type) {
      case BoosterType.study:
        return '📚';
      case BoosterType.play:
        return '🎮';
      case BoosterType.review:
        return '🔍';
    }
  }

  String _formatTimeRemaining(BuildContext context, Duration remaining) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);

    if (languageCode == 'ru') {
      if (hours > 0) {
        return '$hoursч $minutesм осталось';
      } else {
        return '$minutesм осталось';
      }
    } else {
      if (hours > 0) {
        return '${hours}h ${minutes}m remaining';
      } else {
        return '${minutes}m remaining';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_activeBooster == null || _activeBooster!.isExpired) {
      // No active booster; show inventory action if there are stored boosters
      if (_inventory.isEmpty) return const SizedBox.shrink();
      final isRu = Localizations.localeOf(context).languageCode == 'ru';
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
              Icon(Icons.inventory_2, color: onSurfaceColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isRu
                      ? 'Доступные бустеры: ${_inventory.length} '
                      : 'Available boosters: ${_inventory.length} ',
                  style: TextStyle(fontSize: 14, color: onSurfaceColor),
                ),
              ),
              FilledButton(
                onPressed: _promptUseBooster,
                child: Text(isRu ? 'Использовать бустер' : 'Use Booster'),
              ),
            ],
          ),
        ),
      );
    }

    final booster = _activeBooster!;
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
            Row(
              children: [
                Text(
                  _getBoosterIcon(booster.type),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getBoosterLabel(context, booster.type),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimeRemaining(context, booster.timeRemaining),
                        style: TextStyle(
                          fontSize: 14,
                          color: onSurfaceColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.flash_on, color: Colors.orange, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
