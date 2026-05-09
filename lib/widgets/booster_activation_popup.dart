import 'dart:async';
import 'package:flutter/material.dart';
import '../services/booster_service.dart';
import '../services/xp_booster_inventory_service.dart';
import 'challenge_recap_popup.dart';

/// Optional source enum for analytics/debugging.
enum BoosterRewardSource { challenge, streak, trophy }

/// Popup shown when a user unlocks an XP booster via rewards.
class BoosterActivationPopup extends StatefulWidget {
  final BoosterType type;
  final BoosterRewardSource? source;

  const BoosterActivationPopup({super.key, required this.type, this.source});

  /// Global navigator key to show the popup without an explicit context.
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Test hook: if set, this handler will be called instead of showing UI.
  @visibleForTesting
  static Future<void> Function({
    required BoosterType type,
    BoosterRewardSource? source,
  })?
  debugOverrideShow;

  /// Shows the booster activation popup as a dialog overlay.
  static Future<void> show({
    required BoosterType type,
    BoosterRewardSource? source,
  }) async {
    // Test override
    final override = debugOverrideShow;
    if (override != null) {
      await override(type: type, source: source);
      return;
    }

    final context =
        (navigatorKey ?? ChallengeRecapPopup.navigatorKey)?.currentContext;
    if (context == null || !context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BoosterActivationPopup(type: type, source: source),
    );
  }

  @override
  State<BoosterActivationPopup> createState() => _BoosterActivationPopupState();
}

class _BoosterActivationPopupState extends State<BoosterActivationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    // Auto-dismiss after 6 seconds
    _autoDismiss = Timer(const Duration(seconds: 6), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _title(bool isRu) =>
      isRu ? 'Бустер XP разблокирован!' : 'XP Booster Unlocked!';

  String _typeLabel(BoosterType type, bool isRu) {
    switch (type) {
      case BoosterType.study:
        return isRu ? 'Бустер обучения 2x' : 'Study Booster 2x';
      case BoosterType.play:
        return isRu ? 'Бустер игры 2x' : 'Play Booster 2x';
      case BoosterType.review:
        return isRu ? 'Бустер обзора 2x' : 'Review Booster 2x';
    }
  }

  String _durationLabel(bool isRu) =>
      isRu ? 'Длительность: 15м' : 'Duration: 15m';

  String _reasonLabel(BoosterRewardSource? source, bool isRu) {
    switch (source) {
      case BoosterRewardSource.challenge:
        return isRu ? 'Награда за вызов' : 'Challenge reward';
      case BoosterRewardSource.streak:
        return isRu ? 'Серия 7+ дней' : '7+ day streak';
      case BoosterRewardSource.trophy:
        return isRu ? 'Первый трофей' : 'First trophy unlocked';
      case null:
        return isRu ? 'Награда' : 'Reward';
    }
  }

  Future<void> _onActivate() async {
    final inv = XpBoosterInventoryService.instance;
    final added = await inv.addBooster(widget.type);
    if (!mounted) return;
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (added) {
      messenger?.showSnackBar(
        SnackBar(content: Text(isRu ? 'Бустер сохранён!' : 'Booster stored!')),
      );
      Navigator.of(context).maybePop();
    } else {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(isRu ? 'Инвентарь заполнен!' : 'Inventory full!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                _title(isRu),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type and duration
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.orange.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _typeLabel(widget.type, isRu),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _durationLabel(isRu),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Reason
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _reasonLabel(widget.source, isRu),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: _onActivate,
              child: Text(isRu ? 'Добавить в инвентарь' : 'Add to Inventory'),
            ),
          ],
        ),
      ),
    );
  }
}
