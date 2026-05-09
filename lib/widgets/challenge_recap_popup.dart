import 'dart:async';
import 'package:flutter/material.dart';
import '../models/xp_trophy.dart';

/// Lightweight animated overlay shown after completing a challenge.
class ChallengeRecapPopup extends StatefulWidget {
  final String challengeTitle;
  final int awardedXp;
  final List<XpTrophy> unlockedTrophies;
  final Duration timeUntilNext;

  const ChallengeRecapPopup({
    super.key,
    required this.challengeTitle,
    required this.awardedXp,
    this.unlockedTrophies = const [],
    required this.timeUntilNext,
  });

  /// Global navigator key for showing popup overlay.
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Shows the challenge recap popup as an overlay.
  static Future<void> show({
    required String challengeTitle,
    required int awardedXp,
    List<XpTrophy> unlockedTrophies = const [],
    required Duration timeUntilNext,
  }) async {
    final context = navigatorKey?.currentContext;
    if (context == null || !context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ChallengeRecapPopup(
        challengeTitle: challengeTitle,
        awardedXp: awardedXp,
        unlockedTrophies: unlockedTrophies,
        timeUntilNext: timeUntilNext,
      ),
    );
  }

  @override
  State<ChallengeRecapPopup> createState() => _ChallengeRecapPopupState();
}

class _ChallengeRecapPopupState extends State<ChallengeRecapPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Auto-dismiss after 4.5 seconds
    _autoDismissTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _formatTimeUntilNext(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    if (isRu) {
      return 'Следующий через $hoursч $minutesм';
    }
    return 'Next in ${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isRu ? 'Вызов завершён!' : 'Challenge Complete!',
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
              // Challenge title
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.challengeTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // XP earned
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle,
                          size: 18,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.awardedXp} XP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Trophy chips (if any)
              if (widget.unlockedTrophies.isNotEmpty) ...[
                Text(
                  isRu ? 'Открытые трофеи:' : 'Unlocked Trophies:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.unlockedTrophies
                      .map(
                        (trophy) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                trophy.icon(),
                                size: 16,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                trophy.title(isRu: isRu),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Time until next
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTimeUntilNext(widget.timeUntilNext),
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isRu ? 'OK' : 'OK'),
            ),
          ],
        ),
      ),
    );
  }
}
