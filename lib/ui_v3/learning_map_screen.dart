import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/user_path_profile.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_table_screen.dart';
import 'package:poker_analyzer/ui_v3/theme/app_text_styles.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';
import 'package:poker_analyzer/ui_v3/widgets/daily_goal_xp_bar.dart';
import 'package:poker_analyzer/ui_v3/widgets/streak_bar.dart';
import 'package:poker_analyzer/ui_v3/widgets/reward_popup.dart';

/// Stage Φ3 learning map visualization.
class LearningMapScreen extends StatefulWidget {
  static const String routeName = '/v3/learning-map';

  const LearningMapScreen({super.key, this.activeProfile});

  final UserPathProfile? activeProfile;

  @override
  State<LearningMapScreen> createState() => _LearningMapScreenState();
}

class _LearningMapScreenState extends State<LearningMapScreen>
    with SingleTickerProviderStateMixin {
  late final Stopwatch _designLiftStopwatch;
  bool _designLiftTelemetryEmitted = false;
  late final List<_LearningNode> _nodes;

  @override
  void initState() {
    super.initState();
    _designLiftStopwatch = Stopwatch()..start();
    _nodes = _buildNodes();
    FirebaseLiteTelemetryService.instance.logEvent('learning_map_opened');
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _emitDesignLiftTelemetry(),
    );
  }

  List<_LearningNode> _buildNodes() {
    final discipline = widget.activeProfile?.discipline;
    return <_LearningNode>[
      _LearningNode(
        id: 'core',
        title: 'Core Fundamentals',
        packCount: 6,
        status: _NodeStatus.completed,
        highlight: true,
      ),
      _LearningNode(
        id: 'bridge',
        title: 'Bridge Skills',
        packCount: 4,
        status: _NodeStatus.available,
        highlight: true,
      ),
      _LearningNode(
        id: 'cash',
        title: 'Cash Path',
        packCount: 8,
        status: discipline == 'Cash Games'
            ? _NodeStatus.available
            : _NodeStatus.locked,
        highlight: discipline == 'Cash Games',
      ),
      _LearningNode(
        id: 'mtt',
        title: 'MTT Path',
        packCount: 9,
        status: discipline == 'MTT Tournaments'
            ? _NodeStatus.available
            : _NodeStatus.locked,
        highlight: discipline == 'MTT Tournaments',
      ),
      _LearningNode(
        id: 'live',
        title: 'Live Mastery',
        packCount: 5,
        status: discipline == 'Live Events'
            ? _NodeStatus.available
            : _NodeStatus.locked,
        highlight: discipline == 'Live Events',
      ),
    ];
  }

  @override
  void dispose() {
    _designLiftStopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: VisualThemeV3.theme,
      child: RewardPopupListener(
        child: Scaffold(
          appBar: AppBar(title: const Text('Learning Map')),
          body: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final horizontalPadding = isCompact
            ? VisualThemeV3.spacingM
            : VisualThemeV3.spacingL;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: VisualThemeV3.spacingL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: VisualThemeV3.spacingM),
              const SizedBox(height: VisualThemeV3.spacingXL),
              _buildProgressStrip(isCompact),
              const SizedBox(height: VisualThemeV3.spacingL),
              Expanded(child: _buildMap(context, isCompact)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Learning Map', style: AppTextStyles.pageTitle(context)),
        const SizedBox(height: VisualThemeV3.spacingS),
        Text(
          'Visualize your journey from Core to discipline mastery.',
          style: AppTextStyles.pageSubtitle(context),
        ),
      ],
    );
  }

  Widget _buildProgressStrip(bool isCompact) {
    if (isCompact) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DailyGoalXpBar(),
          SizedBox(height: VisualThemeV3.spacingM),
          StreakBarLive(),
        ],
      );
    }

    const tileWidth = 320.0;
    return Wrap(
      spacing: VisualThemeV3.spacingM,
      runSpacing: VisualThemeV3.spacingM,
      children: const [
        SizedBox(width: tileWidth, child: DailyGoalXpBar()),
        SizedBox(width: tileWidth, child: StreakBarLive()),
      ],
    );
  }

  Widget _buildMap(BuildContext context, bool isCompact) {
    if (isCompact) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: VisualThemeV3.spacingS),
        itemBuilder: (context, index) =>
            _buildNodeCard(context, _nodes[index], isCompact),
        separatorBuilder: (_, __) =>
            const SizedBox(height: VisualThemeV3.spacingM),
        itemCount: _nodes.length,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: VisualThemeV3.spacingS),
      child: Row(
        children: [
          for (var i = 0; i < _nodes.length; i++)
            Padding(
              padding: EdgeInsets.only(
                right: i == _nodes.length - 1 ? 0 : VisualThemeV3.spacingM,
              ),
              child: _buildNodeCard(context, _nodes[i], isCompact),
            ),
        ],
      ),
    );
  }

  Widget _buildNodeCard(
    BuildContext context,
    _LearningNode node,
    bool isCompact,
  ) {
    final isLocked = node.status == _NodeStatus.locked;
    final colorScheme = Theme.of(context).colorScheme;
    final titleColor = node.highlight
        ? VisualThemeV3.textPrimaryLight
        : VisualThemeV3.primaryText;
    final detailColor = node.highlight
        ? VisualThemeV3.textSecondaryLight
        : VisualThemeV3.secondaryText;
    final statusColor = node.highlight
        ? VisualThemeV3.textPrimaryLight
        : VisualThemeV3.neutral;
    final cardHeight = isCompact ? 200.0 : 220.0;
    final borderRadius = BorderRadius.circular(VisualThemeV3.cardRadius);

    final card = SizedBox(
      height: cardHeight,
      child: Material(
        color: VisualThemeV3.primary,
        elevation: VisualThemeV3.elevationMedium,
        shadowColor: VisualThemeV3.primary.withValues(alpha: 0.18),
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: isLocked ? null : () => _showNodeDetails(context, node),
          child: AnimatedContainer(
            duration: VisualThemeV3.speedNormal,
            decoration: BoxDecoration(
              gradient: node.highlight
                  ? VisualThemeV3.marketingAccentGradient
                  : VisualThemeV3.brandBackgroundGradient,
              borderRadius: borderRadius,
              border: Border.all(
                color: isLocked ? colorScheme.outline : VisualThemeV3.primary,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(VisualThemeV3.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.title,
                  style: AppTextStyles.cardTitle(context, color: titleColor),
                ),
                const SizedBox(height: VisualThemeV3.spacingSM),
                Text(
                  'Packs: ${node.packCount}',
                  style: AppTextStyles.cardDetail(context, color: detailColor),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _buildStatusBadge(
                    context,
                    node,
                    statusColor,
                    isLocked,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isCompact) {
      return card;
    }
    return SizedBox(width: VisualThemeV3.spacingXL, child: card);
  }

  Widget _buildStatusBadge(
    BuildContext context,
    _LearningNode node,
    Color statusColor,
    bool isLocked,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = node.highlight
        ? statusColor.withValues(alpha: 0.2)
        : colorScheme.surface.withValues(alpha: 0.6);
    final label = isLocked ? 'Locked' : node.status.name;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VisualThemeV3.spacingS,
        vertical: VisualThemeV3.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
      ),
      child: Text(
        label,
        style: AppTextStyles.statusLabel(context, color: statusColor),
      ),
    );
  }

  void _emitDesignLiftTelemetry() {
    if (_designLiftTelemetryEmitted) return;
    _designLiftTelemetryEmitted = true;
    if (_designLiftStopwatch.isRunning) {
      _designLiftStopwatch.stop();
    }
    FirebaseLiteTelemetryService.instance.logEvent(
      'design_lift_learningmap_completed',
      params: <String, Object>{
        'widgets_updated': _nodes.length + 2, // header + progress + nodes
        'duration_ms': _designLiftStopwatch.elapsedMilliseconds,
      },
    );
  }

  Future<void> _showNodeDetails(
    BuildContext context,
    _LearningNode node,
  ) async {
    FirebaseLiteTelemetryService.instance.logEvent(
      'node_selected',
      params: {'node_id': node.id, 'packs': node.packCount},
    );

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(VisualThemeV3.spacingL),
          decoration: BoxDecoration(
            gradient: VisualThemeV3.brandBackgroundGradient,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(VisualThemeV3.cardRadius),
            ),
            boxShadow: const [VisualThemeV3.shadowHigh],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(node.title, style: AppTextStyles.cardTitle(context)),
              const SizedBox(height: VisualThemeV3.spacingS),
              Text(
                'Pack count: ${node.packCount}',
                style: AppTextStyles.cardDetail(context),
              ),
              const SizedBox(height: VisualThemeV3.spacingM),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SimulationTableScreen(),
                      ),
                    );
                  },
                  child: const Text('Start'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _NodeStatus { locked, available, completed }

class _LearningNode {
  const _LearningNode({
    required this.id,
    required this.title,
    required this.packCount,
    required this.status,
    required this.highlight,
  });

  final String id;
  final String title;
  final int packCount;
  final _NodeStatus status;
  final bool highlight;
}
