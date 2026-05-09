import 'package:flutter/material.dart';
import 'dart:async';

import 'package:poker_analyzer/services/emotion_adaptive_engine.dart';
import 'package:poker_analyzer/services/league_service.dart';
import 'package:poker_analyzer/services/xp_progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui_v2/components/celebration_fx.dart';
import 'package:poker_analyzer/ui_v2/components/glow_burst_fx.dart';
import 'package:poker_analyzer/ui_v2/components/mini_toast.dart';

/// UI V2 League Dashboard Screen
///
/// Displays player league tier, rank, and XP progress.
/// ASCII-only visualization with BrandTheme and AppTypography.
class UiV2LeagueDashboardScreen extends StatefulWidget {
  const UiV2LeagueDashboardScreen({super.key});

  @override
  State<UiV2LeagueDashboardScreen> createState() =>
      _UiV2LeagueDashboardScreenState();
}

class _UiV2LeagueDashboardScreenState extends State<UiV2LeagueDashboardScreen> {
  late Future<void> _loadFuture;
  LeagueTier? _displayedTier;
  bool _celebrating = false;
  String _toneLabel = 'Steady and focused';
  final List<_ToastEntry> _toasts = <_ToastEntry>[];
  int _toastSeq = 0;
  String _contextualMessage = '';
  int? _lastLevel;

  @override
  void initState() {
    super.initState();
    _loadFuture = _prepare();
    LeagueService.instance.addTierChangeListener(_handleTierChange);
  }

  Future<void> _prepare() async {
    await XpProgressService.instance.load();
    await LeagueService.instance.evaluateLeague(
      EmotionAdaptiveEngine.instance.momentum,
    );
    _updateContextualMessage();
  }

  String _getTierEmoji(String tierName) {
    switch (tierName.toLowerCase()) {
      case 'bronze':
        return '🥉';
      case 'silver':
        return '🥈';
      case 'gold':
        return '🥇';
      case 'platinum':
        return '💎';
      case 'diamond':
        return '💠';
      case 'master':
        return '👑';
      default:
        return '🏅';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingMedium ?? 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('League Dashboard')),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snap) {
          if (!snap.hasData &&
              snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final xp = XpProgressService.instance.xpTotal;
          final level = XpProgressService.instance.level;
          final tier = LeagueService.instance.getLeagueForXp(xp);
          _scheduleTierSync(tier);
          _checkLevelUp(level);

          return SingleChildScrollView(
            padding: EdgeInsets.all(spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // League Tier Card
                Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _LeagueCard(
                        key: ValueKey(_displayedTier ?? tier),
                        emoji: _getTierEmoji((_displayedTier ?? tier).name),
                        tierName: (_displayedTier ?? tier).name,
                        level: level,
                        xp: xp,
                        toneLabel: _toneLabel,
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: GlowBurstFx(
                          play: _celebrating,
                          color: brand?.primaryBrand ?? Colors.teal,
                          duration: const Duration(milliseconds: 1200),
                          onCompleted: () {
                            if (!mounted) return;
                            setState(() => _celebrating = false);
                          },
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CelebrationFx(
                        play: _celebrating,
                        onCompleted: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),
                // XP Progress
                _XpProgressBar(
                  currentXp: XpProgressService.instance.xpInCurrentLevel,
                  maxXp: XpProgressService.xpPerLevel,
                ),
                SizedBox(height: spacing),
                // Contextual Message
                if (_contextualMessage.isNotEmpty)
                  _ContextualMessageCard(message: _contextualMessage),
                SizedBox(height: spacing),
                // Stats
                _StatsCard(
                  achievements: XpProgressService.instance.achievementsCount,
                  nextLevelXp: XpProgressService.instance.xpForNextLevel,
                ),
                for (final toast in _toasts)
                  Padding(
                    padding: EdgeInsets.only(top: spacing / 2),
                    child: MiniToast(
                      key: ValueKey(toast.id),
                      icon: toast.icon,
                      message: toast.message,
                      onDismissed: () => _removeToast(toast.id),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _scheduleTierSync(LeagueTier tier) {
    if (_displayedTier == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _displayedTier = tier);
      });
    }
  }

  void _checkLevelUp(int level) {
    if (_lastLevel != null && level > _lastLevel!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _celebrating = true;
          _enqueueToast('🎉', 'Level $level reached!');
          _updateContextualMessage();
        });
      });
    }
    _lastLevel = level;
  }

  void _handleTierChange(LeagueTier from, LeagueTier to) {
    if (!mounted) return;
    final tone = EmotionAdaptiveEngine.instance.getAdaptiveTone(
      sentiment: EmotionAdaptiveEngine.instance.momentum,
      consistency: 0.85,
    );
    final label = _tonePhrase(tone);
    setState(() {
      _displayedTier = to;
      _celebrating = true;
      _toneLabel = label;
      _enqueueToast('🥳', 'Promoted to ${to.name}!');
      _updateContextualMessage();
    });
  }

  void _updateContextualMessage() {
    final momentum = EmotionAdaptiveEngine.instance.momentum;
    final xp = XpProgressService.instance.xpInCurrentLevel;
    final maxXp = XpProgressService.xpPerLevel;
    final progress = xp / maxXp;

    String message;
    if (momentum >= 0.4) {
      message = '🔥 On fire! Keep this momentum going!';
    } else if (momentum >= 0.2) {
      message = '💪 Solid run! You\'re building consistency.';
    } else if (progress < 0.2) {
      message = '⏱ Time to review and master the fundamentals.';
    } else if (progress >= 0.8) {
      message = '🚀 Almost there! Push for the next level!';
    } else {
      message = '📈 Steady progress. One step at a time.';
    }

    if (mounted) {
      setState(() => _contextualMessage = message);
    }
  }

  String _tonePhrase(String tone) {
    switch (tone) {
      case 'energetic':
        return 'Crushing momentum!';
      case 'motivating':
        return 'Keep pushing the edge.';
      case 'calm':
      default:
        return 'Steady and focused.';
    }
  }

  void _enqueueToast(String icon, String message) {
    final entry = _ToastEntry(
      id: 'toast_${_toastSeq++}',
      icon: icon,
      message: message,
    );
    setState(() {
      if (_toasts.length >= 3) {
        _toasts.removeAt(0);
      }
      _toasts.add(entry);
    });
  }

  void _removeToast(String id) {
    setState(() => _toasts.removeWhere((element) => element.id == id));
  }

  @override
  void dispose() {
    LeagueService.instance.removeTierChangeListener(_handleTierChange);
    super.dispose();
  }
}

class _LeagueCard extends StatefulWidget {
  final String emoji;
  final String tierName;
  final int level;
  final int xp;
  final String toneLabel;

  const _LeagueCard({
    super.key,
    required this.emoji,
    required this.tierName,
    required this.level,
    required this.xp,
    required this.toneLabel,
  });

  @override
  State<_LeagueCard> createState() => _LeagueCardState();
}

class _LeagueCardState extends State<_LeagueCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _evaluateShimmer();
  }

  @override
  void didUpdateWidget(_LeagueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _evaluateShimmer();
    }
  }

  void _evaluateShimmer() {
    final momentum = EmotionAdaptiveEngine.instance.momentum;
    if (momentum >= 0.3) {
      _shimmerController.repeat(reverse: true);
    } else {
      _shimmerController.stop();
      _shimmerController.value = 0;
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final radius = brand?.radius ?? 12.0;
    final spacing = brand?.spacingMedium ?? 16.0;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerOpacity = _shimmerController.value * 0.3;
        return Container(
          padding: EdgeInsets.all(spacing),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                brand?.primaryBrand ?? Colors.teal,
                (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              // Base shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
              if (_shimmerController.isAnimating)
                BoxShadow(
                  color: (brand?.primaryBrand ?? Colors.teal).withValues(
                    alpha: shimmerOpacity,
                  ),
                  blurRadius: 20 + (shimmerOpacity * 30),
                  spreadRadius: 2,
                ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Text(widget.emoji, style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 8),
          Text(
            widget.tierName.toUpperCase(),
            style: AppTypography.h1.copyWith(
              color: brand?.textPrimary ?? AppColors.textPrimaryDark,
            ),
          ),
          Text(
            'Level ${widget.level}',
            style: AppTypography.body.copyWith(
              color: brand?.textSecondary ?? AppColors.textSecondaryDark,
            ),
          ),
          Text(
            '${widget.xp} XP',
            style: AppTypography.caption.copyWith(
              color: brand?.textSecondary ?? AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              widget.toneLabel,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: brand?.textSecondary ?? AppColors.textSecondaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int maxXp;

  const _XpProgressBar({required this.currentXp, required this.maxXp});

  @override
  Widget build(BuildContext context) {
    final progress = currentXp / maxXp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up, size: 18),
            const SizedBox(width: 6),
            Text('XP Progress', style: AppTypography.h3),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: currentXp),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          builder: (context, value, child) =>
              Text('$value / $maxXp XP', style: AppTypography.caption),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int achievements;
  final int nextLevelXp;

  const _StatsCard({required this.achievements, required this.nextLevelXp});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatRow(
              icon: '🏆',
              label: 'Achievements',
              value: achievements.toString(),
            ),
            const Divider(),
            _StatRow(
              icon: '⬆️',
              label: 'XP to Next Level',
              value: nextLevelXp.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToastEntry {
  final String id;
  final String icon;
  final String message;

  const _ToastEntry({
    required this.id,
    required this.icon,
    required this.message,
  });
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(icon, style: AppTypography.label),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.body),
          ],
        ),
        Text(value, style: AppTypography.h3),
      ],
    );
  }
}

class _ContextualMessageCard extends StatelessWidget {
  final String message;

  const _ContextualMessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.15),
              (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(brand?.radius ?? 12),
          border: Border.all(
            color: (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
