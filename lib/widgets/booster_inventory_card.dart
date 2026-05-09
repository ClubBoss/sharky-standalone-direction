import 'package:flutter/material.dart';
import '../services/xp_booster_inventory_service.dart';
import '../services/booster_service.dart';

/// Displays the user's XP booster inventory (max 3 items) with Use/Delete controls.
class BoosterInventoryCard extends StatefulWidget {
  const BoosterInventoryCard({super.key});

  @override
  State<BoosterInventoryCard> createState() => _BoosterInventoryCardState();
}

class _BoosterInventoryCardState extends State<BoosterInventoryCard> {
  List<BoosterType> _inventory = const [];
  bool _loading = true;
  ActiveBooster? _activeBooster;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final inv = await XpBoosterInventoryService.instance.getInventory();
    final service = BoosterService.getInstance();
    await service.init();
    final active = await service.getActive();
    if (!mounted) return;
    setState(() {
      _inventory = inv;
      _activeBooster = active;
      _loading = false;
    });
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
          return 'Бустер обучения';
        case BoosterType.play:
          return 'Бустер игры';
        case BoosterType.review:
          return 'Бустер обзора';
      }
    } else {
      switch (type) {
        case BoosterType.study:
          return 'Study Booster';
        case BoosterType.play:
          return 'Play Booster';
        case BoosterType.review:
          return 'Review Booster';
      }
    }
  }

  String _title(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Ваши бустеры' : 'Your Boosters';
  }

  String _emptyMessage(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return isRu ? 'Пока нет бустеров' : 'No boosters yet';
  }

  Future<void> _useBooster(BoosterType type) async {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    // Check if already active
    if (_activeBooster != null && !_activeBooster!.isExpired) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(isRu ? 'Уже активен бустер' : 'Booster already active'),
        ),
      );
      return;
    }

    // Remove from inventory
    final removed = await XpBoosterInventoryService.instance.useBooster(type);
    if (!removed) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            isRu ? 'Не удалось активировать' : 'Failed to activate',
          ),
        ),
      );
      return;
    }

    // Activate via BoosterService
    final service = BoosterService.getInstance();
    await service.init();
    await service.activate(type);

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(isRu ? 'Бустер активирован!' : 'Booster activated!'),
      ),
    );

    await _loadInventory();
  }

  Future<void> _deleteBooster(BoosterType type) async {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    final removed = await XpBoosterInventoryService.instance.removeBooster(
      type,
    );
    if (!removed) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(isRu ? 'Не удалось удалить' : 'Failed to delete'),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(content: Text(isRu ? 'Бустер удалён' : 'Booster deleted')),
    );

    await _loadInventory();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _title(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onSurfaceColor,
                  ),
                ),
                Text(
                  '${_inventory.length} / 3',
                  style: TextStyle(
                    fontSize: 14,
                    color: onSurfaceColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_inventory.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
              ..._inventory.map((type) {
                final hasActive =
                    _activeBooster != null && !_activeBooster!.isExpired;
                final isRu =
                    Localizations.localeOf(context).languageCode == 'ru';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(_icon(type), style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _label(context, type),
                          style: TextStyle(fontSize: 14, color: onSurfaceColor),
                        ),
                      ),
                      Text(
                        '2x XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: hasActive ? null : () => _useBooster(type),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(60, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(
                          isRu ? 'Исп.' : 'Use',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _deleteBooster(type),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: isRu ? 'Удалить' : 'Delete',
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
