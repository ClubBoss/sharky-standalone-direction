import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poker_analyzer/services/ai_coaching_analytics_service.dart';
import 'package:poker_analyzer/services/mistake_analytics_service.dart';
import 'package:poker_analyzer/services/saved_hand_stats_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

/// Reviewer Metrics Panel
///
/// Displays session performance summary with success rate, EV metrics,
/// top mistake types, and session-sharing tools.
class ReviewerMetricsPanel extends StatefulWidget {
  const ReviewerMetricsPanel({
    super.key,
    this.sessionStats,
    this.onShareSession,
  });

  final SavedHandSessionStats? sessionStats;
  final VoidCallback? onShareSession;

  @override
  State<ReviewerMetricsPanel> createState() => _ReviewerMetricsPanelState();
}

class _ReviewerMetricsPanelState extends State<ReviewerMetricsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<MistakeTagData> _topMistakes = [];
  bool _isLoading = true;
  String? _exportPath;
  Map<String, dynamic>? _coachRetentionData;
  bool _isLoadingCoachData = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadMistakeData();
    _loadCoachData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMistakeData() async {
    try {
      final analytics = MistakeAnalyticsService();
      final mistakes = await analytics.getTopMistakeTags(max: 5);
      if (mounted) {
        setState(() {
          _topMistakes = mistakes;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCoachData() async {
    try {
      final data = await AiCoachingAnalyticsService.readRetentionReport();
      if (mounted) {
        setState(() {
          _coachRetentionData = data;
          _isLoadingCoachData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCoachData = false);
      }
    }
  }

  Future<void> _copyExportPath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${dir.path}/export/sessions');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final path = exportDir.path;
      await Clipboard.setData(ClipboardData(text: path));
      if (mounted) {
        setState(() => _exportPath = path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📋 Path copied: $path'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to copy path: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _openExportFolder() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${dir.path}/export/sessions');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      // Note: Opening folder programmatically is platform-specific
      // On desktop, we just show the path
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📁 Export folder: ${exportDir.path}'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(label: 'Copy', onPressed: _copyExportPath),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final spacing = brand?.spacingMedium ?? 16.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final slideValue = Curves.easeOut.transform(_animationController.value);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - slideValue)),
          child: Opacity(opacity: _animationController.value, child: child),
        );
      },
      child: Container(
        padding: EdgeInsets.all(spacing),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(brand?.radius ?? 12),
          border: Border.all(
            color: (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Review Summary', style: AppTypography.h1),
                Icon(
                  Icons.analytics_outlined,
                  color: brand?.primaryBrand ?? Colors.teal,
                ),
              ],
            ),
            SizedBox(height: spacing),
            // Session Stats
            _buildSessionStats(context),
            SizedBox(height: spacing),
            // Top Mistakes
            _buildTopMistakes(context),
            SizedBox(height: spacing),
            // Coach Stats (if available)
            if (_coachRetentionData != null) ...[
              _buildCoachStats(context),
              SizedBox(height: spacing),
            ],
            // Share Actions
            _buildShareActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStats(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final stats = widget.sessionStats;

    final totalSessions = stats != null ? 1 : 0;
    final correctCount = stats?.correct ?? 0;
    final incorrectCount = stats?.incorrect ?? 0;
    final totalHands = correctCount + incorrectCount;
    final successRate = totalHands > 0
        ? (correctCount / totalHands * 100).toStringAsFixed(1)
        : '0.0';
    final avgEv = stats?.evAvg?.toStringAsFixed(2) ?? '0.00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Metrics',
          style: AppTypography.h3.copyWith(
            color: brand?.primaryBrand ?? Colors.teal,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _MetricCard(
              icon: '📊',
              iconData: Icons.assessment,
              label: 'Sessions',
              value: '$totalSessions',
              color: Colors.blue,
            ),
            _MetricCard(
              icon: '✅',
              iconData: Icons.check_circle,
              label: 'Success Rate',
              value: '$successRate%',
              color: brand?.accentSuccess ?? AppColors.accentSuccess,
              subtitle: '$correctCount correct',
            ),
            _MetricCard(
              icon: '❌',
              iconData: Icons.error,
              label: 'Mistakes',
              value: '$incorrectCount',
              color: Colors.red,
            ),
            _MetricCard(
              icon: '📈',
              iconData: Icons.trending_up,
              label: 'Avg EV',
              value: avgEv,
              color: brand?.accentWarning ?? AppColors.accentWarning,
              subtitle: avgEv.startsWith('-') ? 'Loss' : 'Gain',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopMistakes(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Mistake Types',
            style: AppTypography.h3.copyWith(
              color: brand?.primaryBrand ?? Colors.teal,
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_topMistakes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Mistake Types',
            style: AppTypography.h3.copyWith(
              color: brand?.primaryBrand ?? Colors.teal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '🎉 No mistakes recorded yet!',
            style: AppTypography.body.copyWith(color: Colors.grey),
          ),
        ],
      );
    }

    final maxCount = _topMistakes.first.mistakeCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Mistake Types',
          style: AppTypography.h3.copyWith(
            color: brand?.primaryBrand ?? Colors.teal,
          ),
        ),
        const SizedBox(height: 12),
        ..._topMistakes.map(
          (mistake) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _MistakeBar(
              tag: mistake.tag,
              count: mistake.mistakeCount,
              evLoss: mistake.evLoss,
              maxCount: maxCount,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoachStats(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    if (_isLoadingCoachData || _coachRetentionData == null) {
      return const SizedBox.shrink();
    }

    final rsPercent =
        (_coachRetentionData!['retention_score_percent'] as num?)?.toDouble() ??
        0.0;
    final trend =
        (_coachRetentionData!['trend_vs_last_7_days'] as num?)?.toDouble() ??
        0.0;
    final recommendations =
        (_coachRetentionData!['recommendations'] as List?)?.cast<String>() ??
        [];

    final trendIcon = trend >= 0 ? '📈' : '📉';
    final trendText =
        '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(1)}% vs last 7d';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Coach Stats',
          style: AppTypography.h3.copyWith(
            color: brand?.primaryBrand ?? Colors.teal,
          ),
        ),
        const SizedBox(height: 12),
        // Retention Score Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(brand?.radius ?? 12),
            border: Border.all(
              color: Colors.lightBlueAccent.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        color: Colors.lightBlueAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Retention Score',
                        style: AppTypography.label.copyWith(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$trendIcon $trendText',
                    style: AppTypography.caption.copyWith(
                      color: trend >= 0 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${rsPercent.toStringAsFixed(1)}%',
                style: AppTypography.h1.copyWith(
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        width: constraints.maxWidth * (rsPercent / 100),
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.lightBlueAccent, Colors.blue],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Recommendations
        if (recommendations.isNotEmpty) ...[
          Text(
            'Focus Areas',
            style: AppTypography.label.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...recommendations
              .take(3)
              .map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          rec,
                          style: AppTypography.caption.copyWith(
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ],
    );
  }

  Widget _buildShareActions(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share & Export',
          style: AppTypography.h3.copyWith(
            color: brand?.primaryBrand ?? Colors.teal,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ShareButton(
                icon: Icons.copy,
                label: 'Copy JSON Path',
                onTap: _copyExportPath,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ShareButton(
                icon: Icons.folder_open,
                label: 'Open Folder',
                onTap: _openExportFolder,
              ),
            ),
          ],
        ),
        if (_exportPath != null) ...[
          const SizedBox(height: 8),
          Text(
            _exportPath!,
            style: AppTypography.caption.copyWith(color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _MetricCard extends StatefulWidget {
  const _MetricCard({
    required this.icon,
    this.iconData,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final String icon;
  final IconData? iconData;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) => _tapController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _tapController,
          builder: (context, child) {
            final scale = 1.0 - (_tapController.value * 0.05);
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(brand?.radius ?? 12),
              border: Border.all(color: widget.color.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.iconData != null)
                      Icon(widget.iconData, color: widget.color, size: 20)
                    else
                      Text(widget.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: AppTypography.caption.copyWith(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: AppTypography.h1.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: AppTypography.caption.copyWith(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MistakeBar extends StatelessWidget {
  const _MistakeBar({
    required this.tag,
    required this.count,
    required this.evLoss,
    required this.maxCount,
  });

  final String tag;
  final int count;
  final double evLoss;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final progress = maxCount > 0 ? (count / maxCount).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                tag,
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$count × • -${evLoss.toStringAsFixed(2)} EV',
              style: AppTypography.caption.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: progress),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: constraints.maxWidth * value,
                      height: 8,
                      decoration: BoxDecoration(
                        color: brand?.primaryBrand ?? Colors.teal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(brand?.radius ?? 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(brand?.radius ?? 12),
          border: Border.all(
            color: (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: brand?.primaryBrand ?? Colors.teal, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTypography.label.copyWith(
                  color: brand?.primaryBrand ?? Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
