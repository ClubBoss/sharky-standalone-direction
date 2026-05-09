import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
import '../services/streak_service.dart';
import '../services/evaluation_executor_service.dart';
import '../services/template_storage_service.dart';
import '../services/training_pack_stats_service.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/training_pack_cloud_sync_service.dart';
import '../services/streak_tracker_service.dart';
import '../services/xp_history_service.dart';
import '../services/xp_milestone_service.dart';
import '../services/xp_notification_service.dart';
import '../services/xp_service.dart';
import '../services/challenge_service.dart';
import '../services/league_history_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/sync_status_widget.dart';
import '../utils/responsive.dart';
import '../widgets/training_progress_chart_widget.dart';
import '../widgets/training_progress_bar_widget.dart';
import '../widgets/training_summary_widget.dart';
import '../services/training_progress_service.dart';
import '../services/module_progress_service.dart';
import '../services/training_roadmap_service.dart';
import '../services/training_league_service.dart';
import '../models/challenge_definition.dart';
import '../models/training_league_member.dart';
import '../models/league_tier_badge.dart';
import '../widgets/training_goal_tracker_widget.dart';
import '../widgets/xp_progress_ring_block.dart';
import '../widgets/xp_recapped_milestone_preview_card.dart';
import '../widgets/trophy_wall_widget.dart';
import '../widgets/session_medal_card.dart';
import '../services/rank_service.dart';
import '../models/user_rank.dart';
import '../models/xp_league.dart';
import '../widgets/xp_leaderboard_widget.dart';
import '../widgets/league_suggestion_widget.dart';
import '../widgets/achievements_feed_widget.dart';
import '../widgets/internal_goals_card.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/level_card_widget.dart';
import '../widgets/streak_flame_widget.dart';
import '../widgets/streak_freeze_widget.dart';
import '../widgets/booster_card.dart';
import '../widgets/booster_market_card.dart';
import '../widgets/booster_inventory_card.dart';
import '../widgets/xp_history_card.dart';
import '../widgets/weekly_insights_card.dart';
import '../widgets/training_profile_card.dart';
import '../widgets/training_roadmap_widget.dart';
import '../widgets/training_league_card_widget.dart';
import '../widgets/training_league_leaderboard_widget.dart';
import '../widgets/league_promotion_note.dart';
import '../widgets/league_history_widget.dart';
import '../widgets/xp_timeline_widget.dart';
import '../widgets/session_logger_widget.dart';
import '../widgets/notification_opt_in_card.dart';
import '../widgets/challenge_card_widget.dart';
import '../infra/telemetry.dart';
import '../widgets/session_streak_widget.dart';
import '../services/session_log_service.dart';
import 'achievements_screen.dart';
import 'booster_library_screen.dart';
import 'booster_archive_screen.dart';
import 'xp_tabs_screen.dart';
import 'profile_share_preview_screen.dart';
import 'user_profile_screen.dart';
import 'xp_share_screen.dart';
import '../widgets/skill_focus_card.dart';
import 'module_catalog_screen.dart';
import 'xp_recap_screen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int _evaluated;
  late int _correct;
  final List<MapEntry<TrainingPackStat, String>> _stats = [];
  int? _progressRange = 7;
  final GlobalKey _leagueLeaderboardKey = GlobalKey();

  void _load() {
    final service = EvaluationExecutorService();
    _evaluated = service.totalEvaluated;
    _correct = service.totalCorrect;
  }

  Future<void> _loadStats() async {
    final templates = context.read<TemplateStorageService>().templates;
    final recent = await TrainingPackStatsService.recentlyPractisedTemplates(
      templates,
      days: 30,
    );
    final list = <MapEntry<TrainingPackStat, String>>[];
    for (final t in recent) {
      final stat = await TrainingPackStatsService.getStats(t.id);
      if (stat != null) list.add(MapEntry(stat, t.name));
    }
    list.sort((a, b) => b.key.last.compareTo(a.key.last));
    if (list.length > 5) list.removeRange(5, list.length);
    if (!mounted) return;
    setState(() {
      _stats
        ..clear()
        ..addAll(list);
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
    _scheduleXpReminders();
    ChallengeService.instance.init();
  }

  /// Schedule XP reminders in the background
  Future<void> _scheduleXpReminders() async {
    try {
      await XpNotificationService.scheduleDailyReminderIfNeeded();
      await XpNotificationService.scheduleWeeklyReminderIfNeeded();
    } catch (e) {
      // Silently fail if notifications not available or permissions denied
    }
  }

  Future<void> _reset() async {
    await EvaluationExecutorService().resetAccuracy();
    setState(_load);
  }

  Widget _legendItem(Color color, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    ],
  );

  Widget _buildUserProfileTile() => Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: InkWell(
      onTap: () {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => UserProfileScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.blue[700], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Профиль',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Имя, почта, функции',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    ),
  );

  Widget _buildXpShareTile() => Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: InkWell(
      onTap: () {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => XpShareScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.share, color: Colors.amber[700], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Поделиться успехами',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'XP, серия, лига',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    ),
  );

  Widget _buildXpSection(BuildContext context) => _buildXpOverview(context);

  /// Self-contained XP overview section with achievements.
  Widget _buildXpOverview(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 360;
    final horizontalPadding = isCompact ? 0.0 : 8.0;
    final moduleProgressService = context.read<ModuleProgressService>();
    final progressService = TrainingProgressService(
      store: ModuleProgressStore(progressService: moduleProgressService),
    );
    final scopedSnapshots = progressService.getScopedProgressSnapshots();
    final roadmapService = TrainingRoadmapService(
      moduleProgressService: moduleProgressService,
    );
    final roadmapScopes = roadmapService.buildRoadmap();
    final leagueStatus = TrainingLeagueService.instance.getStatus();
    final leagueLeaderboard = TrainingLeagueService.instance.getLeaderboard();
    TrainingLeagueMember? myLeagueEntry;
    for (final entry in leagueLeaderboard) {
      if (entry.isMe) {
        myLeagueEntry = entry;
        break;
      }
    }
    final leagueBadge = myLeagueEntry != null
        ? LeagueTierBadge.resolve(xp: myLeagueEntry.xp)
        : null;
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final achievementsHeading = isRu ? 'Ваши достижения' : 'Your Achievements';
    final viewAllLabel = isRu ? 'Посмотреть все' : 'View All';
    final challengeService = ChallengeService.instance;
    final dailyLabel = isRu ? 'Челлендж дня' : "Today's Challenge";
    final weeklyLabel = isRu ? 'Задача недели' : 'Weekly Challenge';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ProfileXpDashboard(),
        const SizedBox(height: 12),
        ValueListenableBuilder<ChallengeInstance?>(
          valueListenable: challengeService.listenTo(ChallengeDuration.daily),
          builder: (context, instance, _) {
            if (instance == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ChallengeCardWidget(label: dailyLabel, instance: instance),
            );
          },
        ),
        ValueListenableBuilder<ChallengeInstance?>(
          valueListenable: challengeService.listenTo(ChallengeDuration.weekly),
          builder: (context, instance, _) {
            if (instance == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ).copyWith(top: 12),
              child: ChallengeCardWidget(
                label: weeklyLabel,
                instance: instance,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Divider(height: 24),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(
            achievementsHeading,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const TrophyWallWidget(),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const XpLeaderboardWidget(),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < scopedSnapshots.length; i++)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ).copyWith(bottom: i == scopedSnapshots.length - 1 ? 0 : 12),
            child: TrainingProgressBarWidget(
              snapshot: scopedSnapshots[i],
              color: _scopeColors[scopedSnapshots[i].label],
            ),
          ),
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Divider(height: 24),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: TrainingSummaryWidget(onAction: _handleTrainingSummaryAction),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const AchievementsFeedWidget(),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const InternalGoalsCard(),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const DailyGoalCard(),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const LevelCardWidget(),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const TrainingProfileCard(),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: FilledButton.tonalIcon(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) => ProfileSharePreviewScreen(),
                ),
              );
            },
            icon: const Icon(Icons.share),
            label: Text(isRu ? 'Поделиться профилем' : 'Share Profile'),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Divider(height: 24),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: TrainingRoadmapWidget(scopes: roadmapScopes),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: TrainingLeagueCardWidget(
            status: leagueStatus,
            badge: leagueBadge,
            onViewLeaderboard: () {
              final context = _leagueLeaderboardKey.currentContext;
              if (context != null) {
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              }
            },
          ),
        ),
        if (leagueLeaderboard.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: TrainingLeagueLeaderboardWidget(
              key: _leagueLeaderboardKey,
              members: leagueLeaderboard,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: FilledButton.tonal(
            onPressed: () => AchievementsScreenLauncher.open(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_outlined, size: 20),
                const SizedBox(width: 8),
                Text(viewAllLabel),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleTrainingSummaryAction() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => ModuleCatalogScreen()),
    );
  }

  static const Map<String, Color> _scopeColors = {
    'core': Colors.lightBlueAccent,
    'cash': Colors.amber,
    'mtt': Colors.deepPurpleAccent,
    'live': Colors.teal,
  };

  Widget _buildXpRecapTile() => Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: InkWell(
      onTap: () {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => XpRecapScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.insights, color: Colors.purple[700], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'XP Recap',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Overview of progress, goals, and milestones',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    ),
  );

  Widget _buildChart() {
    if (_stats.isEmpty) {
      return Container(
        height: responsiveSize(context, 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Недостаточно данных',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    final preEv = <FlSpot>[];
    final postEv = <FlSpot>[];
    final preIcm = <FlSpot>[];
    final postIcm = <FlSpot>[];
    for (var i = 0; i < _stats.length; i++) {
      final s = _stats[i].key;
      preEv.add(FlSpot(i.toDouble(), s.preEvPct));
      postEv.add(FlSpot(i.toDouble(), s.postEvPct));
      preIcm.add(FlSpot(i.toDouble(), s.preIcmPct));
      postIcm.add(FlSpot(i.toDouble(), s.postIcmPct));
    }
    final step = (_stats.length / 5).ceil();
    final lines = [
      LineChartBarData(
        spots: preEv,
        color: AppColors.evPre,
        barWidth: 2,
        isCurved: false,
        dotData: const FlDotData(show: true),
      ),
      LineChartBarData(
        spots: postEv,
        color: AppColors.evPost,
        barWidth: 2,
        isCurved: false,
        dotData: const FlDotData(show: true),
      ),
      LineChartBarData(
        spots: preIcm,
        color: AppColors.icmPre,
        barWidth: 2,
        isCurved: false,
        dotData: const FlDotData(show: true),
      ),
      LineChartBarData(
        spots: postIcm,
        color: AppColors.icmPost,
        barWidth: 2,
        isCurved: false,
        dotData: const FlDotData(show: true),
      ),
    ];
    return SizedBox(
      height: 220,
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItems: (spots) {
                        final idx = spots.first.spotIndex;
                        final e = _stats[idx];
                        return [
                          LineTooltipItem(
                            '${e.value}\nEV ${e.key.preEvPct.toStringAsFixed(1)} → ${e.key.postEvPct.toStringAsFixed(1)}\nICM ${e.key.preIcmPct.toStringAsFixed(1)} → ${e.key.postIcmPct.toStringAsFixed(1)}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ];
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) =>
                        const FlLine(color: Colors.white24, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= _stats.length) {
                            return const SizedBox.shrink();
                          }
                          if (index % step != 0 && index != _stats.length - 1) {
                            return const SizedBox.shrink();
                          }
                          final d = _stats[index].key.last;
                          final label =
                              '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
                          return Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.white24),
                      bottom: BorderSide(color: Colors.white24),
                    ),
                  ),
                  lineBarsData: lines,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              _legendItem(AppColors.evPre, 'Pre EV'),
              _legendItem(AppColors.evPost, 'Post EV'),
              _legendItem(AppColors.icmPre, 'Pre ICM'),
              _legendItem(AppColors.icmPost, 'Post ICM'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<StreakService>().count;
    final acc = _evaluated == 0 ? 0 : _correct / _evaluated;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [SyncStatusIcon.of(context)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Streak: $streak',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Accuracy: ${(acc * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildXpSection(context),
              const SizedBox(height: 24),
              const Divider(height: 32),
              const SizedBox(height: 8),
              const Text(
                'Your Progress',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: [
                  _progressRange == 7,
                  _progressRange == 30,
                  _progressRange == null,
                ],
                onPressed: (index) {
                  setState(() {
                    _progressRange = const [7, 30, null][index];
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('7 days'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('30 days'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('All time'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TrainingProgressChartWidget(dayRange: _progressRange),
              const SizedBox(height: 16),
              const TrainingGoalTrackerWidget(),
              const SizedBox(height: 8),
              const _SmartReminderTile(),
              const SizedBox(height: 8),
              const _DailyStreakIndicator(),
              const SizedBox(height: 8),
              const StreakFreezeWidget(),
              const SizedBox(height: 8),
              const BoosterCard(),
              const SizedBox(height: 8),
              const BoosterMarketCard(),
              const SizedBox(height: 8),
              const BoosterInventoryCard(),
              const SizedBox(height: 8),
              const XpHistoryCard(),
              const SizedBox(height: 8),
              const WeeklyInsightsCard(),
              const SizedBox(height: 8),
              const SkillFocusCard(),
              const SizedBox(height: 8),
              const SessionMedalCard(),
              const SizedBox(height: 8),
              const _WeeklyXpGoalCard(),
              const SizedBox(height: 8),
              _buildUserProfileTile(),
              const SizedBox(height: 8),
              _buildXpShareTile(),
              const SizedBox(height: 8),
              _buildXpRecapTile(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _reset,
                child: const Text('Reset Accuracy'),
              ),
              const SizedBox(height: 16),
              _buildChart(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (_) => AchievementsScreen()),
                  );
                },
                child: const Text('Достижения'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (_) => BoosterLibraryScreen()),
                  );
                },
                child: const Text('Booster Library'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (_) => BoosterArchiveScreen()),
                  );
                },
                child: const Text('Booster Archive'),
              ),
              const SizedBox(height: 16),
              Consumer<AuthService>(
                builder: (context, auth, child) {
                  if (auth.isSignedIn) {
                    final email = auth.email;
                    return ElevatedButton(
                      onPressed: auth.signOut,
                      child: Text('Sign Out ($email)'),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final ok = await auth.signInWithGoogle();
                          if (ok) {
                            final cloud = context.read<CloudSyncService>();
                            await cloud.syncDown();
                            await context
                                .read<TrainingPackCloudSyncService>()
                                .syncDownStats();
                          }
                        },
                        child: const Text('Sign In with Google'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final ok = await auth.signInWithApple();
                          if (ok) {
                            final cloud = context.read<CloudSyncService>();
                            await cloud.syncDown();
                            await context
                                .read<TrainingPackCloudSyncService>()
                                .syncDownStats();
                          }
                        },
                        child: const Text('Sign In with Apple'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight daily streak indicator showing current and best streaks.
/// Tapping navigates to XP Dashboard (История tab).
class _DailyStreakIndicator extends StatefulWidget {
  const _DailyStreakIndicator();

  @override
  State<_DailyStreakIndicator> createState() => _DailyStreakIndicatorState();
}

class _DailyStreakIndicatorState extends State<_DailyStreakIndicator> {
  int _currentStreak = 0;
  int _bestStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    final tracker = StreakTrackerService.instance;
    final stats = await tracker.compute();
    final current = stats.currentStreak;
    final best = stats.longestStreak;

    if (!mounted) return;

    setState(() {
      _currentStreak = current;
      _bestStreak = best;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final hasStreak = _currentStreak > 0;
    final streakText = hasStreak
        ? l10n.xpProfileStreakSummary(
            l10n.xpDaysCount(_currentStreak),
            l10n.xpDaysCount(_bestStreak),
          )
        : l10n.xpProfileNoStreak;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (_) => XpTabsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: hasStreak ? Colors.orange[700] : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  streakText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasStreak ? Colors.orange[900] : Colors.grey[700],
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Weekly XP goal progress card showing current week's XP vs 50 XP target.
/// Displays progress bar and week date range. Tapping navigates to XP Dashboard.
class _WeeklyXpGoalCard extends StatefulWidget {
  const _WeeklyXpGoalCard();

  @override
  State<_WeeklyXpGoalCard> createState() => _WeeklyXpGoalCardState();
}

/// Smart Reminder tile: shows when there's been no XP gain in the last 5 days.
class _SmartReminderTile extends StatefulWidget {
  const _SmartReminderTile();

  @override
  State<_SmartReminderTile> createState() => _SmartReminderTileState();
}

class _ProfileXpDashboard extends StatefulWidget {
  const _ProfileXpDashboard();

  @override
  State<_ProfileXpDashboard> createState() => _ProfileXpDashboardState();
}

class _ProfileXpDashboardState extends State<_ProfileXpDashboard> {
  _ProfileXpData? _data;
  bool _loading = true;
  bool _error = false;
  bool _loggedImpression = false;
  LeaguePromotionRecord? _lastPromotion;
  List<LeaguePromotionRecord> _promotionHistory = const [];
  List<XpEvent> _xpTimeline = const <XpEvent>[];
  List<SessionLogEntry> _sessionLogs = const <SessionLogEntry>[];
  SessionStreakStats? _sessionStreak;
  NotificationPermissionStatus? _notificationStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      XpService? xpService;
      try {
        xpService = context.read<XpService>();
      } catch (_) {
        xpService = null;
      }
      xpService ??= XpService();
      await xpService.initialize();

      // Initialize RankService and update rank
      await RankService.instance.init();
      await RankService.instance.updateRank(xpService.getTotalXp());

      final total = xpService.getTotalXp();
      int? next;
      for (final milestone in XpMilestoneService.milestones) {
        if (milestone > total) {
          next = milestone;
          break;
        }
      }
      final milestoneService = XpMilestoneService();
      final unlockedNotClaimed = await milestoneService
          .getUnlockedButUnclaimedMilestones(total);
      int? unclaimed;
      if (unlockedNotClaimed.isNotEmpty) {
        unlockedNotClaimed.sort();
        unclaimed = unlockedNotClaimed.first;
      }
      final percent = next == null || next <= 0
          ? 1.0
          : (total / next).clamp(0.0, 1.0);
      final remaining = next == null ? null : (next - total).clamp(0, next);
      final history = await LeagueHistoryService.instance.getHistory();
      final promotion = history.isEmpty ? null : history.last;
      final xpEvents = await XpHistoryService().getHistory();
      final sessions = await SessionLogService.instance.getLogs();
      final streak = await StreakTrackerService.instance.compute();
      final notificationStatus = await NotificationService.instance
          .getPermissionStatus();
      if (notificationStatus == NotificationPermissionStatus.granted) {
        await NotificationService.scheduleDailyReminder(context);
      }

      if (!mounted) return;
      setState(() {
        _data = _ProfileXpData(
          totalXp: total,
          nextMilestone: next,
          remainingToNext: remaining,
          percent: percent,
          unclaimedMilestone: unclaimed,
        );
        _loading = false;
        _error = false;
        _lastPromotion = promotion;
        _promotionHistory = history;
        _xpTimeline = xpEvents;
        _sessionLogs = sessions;
        _sessionStreak = streak;
        _notificationStatus = notificationStatus;
      });
      _logImpressionIfNeeded();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  void _logImpressionIfNeeded() {
    if (_loggedImpression) return;
    final data = _data;
    if (data == null) return;
    _loggedImpression = true;
    unawaited(
      Telemetry.logEvent('profile_xp_dashboard_impression', {
        'total_xp': data.totalXp,
        'percent': double.parse(data.percent.toStringAsFixed(4)),
      }),
    );
  }

  void _openRecap() {
    unawaited(Telemetry.logEvent('profile_xp_dashboard_tap', {}));
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => XpRecapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRu = locale.languageCode.toLowerCase().startsWith('ru');
    final title = isRu ? 'XP прогресс' : 'XP progress';
    final subtitle = isRu
        ? 'Отслеживайте общий прогресс и ближайшую цель'
        : 'Track total progress and your next goal';
    final recapLabel = isRu ? 'Смотреть отчёт' : 'View recap';
    final errorText = isRu
        ? 'Не удалось загрузить XP'
        : 'Unable to load XP right now';

    if (_loading) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error || _data == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(errorText, style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    final data = _data!;
    final league = XpLeagueExt.fromXp(data.totalXp);
    final localeTag = locale.toLanguageTag();
    final xpPattern = NumberFormat.decimalPattern(localeTag);
    final totalXpLabel = '${xpPattern.format(data.totalXp)} XP';
    final nextMilestoneLabel = data.nextMilestone == null
        ? (isRu ? 'Все вехи достигнуты' : 'All milestones reached')
        : isRu
        ? 'Следующая цель — ${xpPattern.format(data.nextMilestone)} XP'
        : 'Next milestone at ${xpPattern.format(data.nextMilestone)} XP';
    final remainingLabel = data.remainingToNext == null
        ? (isRu ? 'Продолжайте зарабатывать XP!' : 'Keep the streak alive!')
        : isRu
        ? 'Осталось ${xpPattern.format(data.remainingToNext)} XP'
        : '${xpPattern.format(data.remainingToNext)} XP to go';

    final statsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          totalXpLabel,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(nextMilestoneLabel, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          remainingLabel,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );

    final ringSection = SizedBox(
      width: 180,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              _LeagueAvatar(league: league),
              // Streak flame badge positioned bottom-right
              const Positioned(
                bottom: -4,
                right: -4,
                child: StreakFlameWidget(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          XpProgressRingBlock(
            totalXp: data.totalXp,
            milestoneXp: data.nextMilestone ?? data.totalXp,
            percent: data.percent,
            caption: remainingLabel,
            leagueRank: null,
            ringSize: 130,
          ),
          if (_lastPromotion != null) ...[
            const SizedBox(height: 8),
            LeaguePromotionNote(record: _lastPromotion!),
          ],
          const SizedBox(height: 8),
          // User rank badge
          ValueListenableBuilder<UserRank>(
            valueListenable: RankService.instance.notifier,
            builder: (context, rank, _) => _buildRankBadge(rank, isRu),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _openRecap, child: Text(recapLabel)),
          ),
        ],
      ),
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 420;
                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: ringSection),
                      const SizedBox(height: 16),
                      statsColumn,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ringSection,
                    const SizedBox(width: 24),
                    Expanded(child: statsColumn),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            if (_promotionHistory.isNotEmpty) ...[
              LeagueHistoryWidget(history: _promotionHistory),
              const SizedBox(height: 16),
            ],
            if (_xpTimeline.isNotEmpty) ...[
              XpTimelineWidget(events: _xpTimeline),
              const SizedBox(height: 16),
            ],
            SessionLoggerWidget(sessions: _sessionLogs, onSessionLogged: _load),
            const SizedBox(height: 16),
            if (_notificationStatus != null &&
                _notificationStatus !=
                    NotificationPermissionStatus.granted) ...[
              NotificationOptInCard(
                status: _notificationStatus!,
                onStatusChanged: _refreshNotificationStatus,
              ),
              const SizedBox(height: 16),
            ],
            if (_sessionStreak != null) ...[
              SessionStreakWidget(stats: _sessionStreak!),
              const SizedBox(height: 16),
            ],
            LeagueSuggestionWidget(league: league),
            const SizedBox(height: 16),
            _buildMilestonePreviewCard(data),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshNotificationStatus() async {
    final status = await NotificationService.instance.getPermissionStatus();
    if (!mounted) return;
    setState(() {
      _notificationStatus = status;
    });
    if (status == NotificationPermissionStatus.granted) {
      await NotificationService.scheduleDailyReminder(context);
    }
  }

  Widget _buildMilestonePreviewCard(_ProfileXpData data) => Theme(
    data: Theme.of(
      context,
    ).copyWith(cardTheme: const CardThemeData(margin: EdgeInsets.zero)),
    child: XpRecappedMilestonePreviewCard(
      totalXp: data.totalXp,
      unclaimedMilestone: data.unclaimedMilestone,
      upcomingMilestone: data.nextMilestone,
    ),
  );

  Widget _buildRankBadge(UserRank rank, bool isRu) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: rank.color().withAlpha((0.15 * 255).round()),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: rank.color(), width: 1.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(rank.icon(), color: rank.color(), size: 18),
        const SizedBox(width: 6),
        Text(
          rank.label(isRu: isRu),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: rank.color(),
          ),
        ),
      ],
    ),
  );
}

class _ProfileXpData {
  final int totalXp;
  final int? nextMilestone;
  final int? remainingToNext;
  final double percent;
  final int? unclaimedMilestone;

  const _ProfileXpData({
    required this.totalXp,
    required this.nextMilestone,
    required this.remainingToNext,
    required this.percent,
    required this.unclaimedMilestone,
  });
}

class _LeagueAvatar extends StatelessWidget {
  final XpLeague league;
  const _LeagueAvatar({required this.league});

  @override
  Widget build(BuildContext context) {
    final color = league.color();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: color.withAlpha((0.18 * 255).round()),
        child: Icon(Icons.person, color: color, size: 28),
      ),
    );
  }
}

class _SmartReminderTileState extends State<_SmartReminderTile> {
  bool _show = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final history = await XpHistoryService().getHistory();
      DateTime? last;
      for (final e in history) {
        if (last == null || e.timestamp.isAfter(last)) {
          last = e.timestamp;
        }
      }
      final now = DateTime.now();
      bool show;
      if (last == null) {
        // No history at all — consider as needing a nudge
        show = true;
      } else {
        final diffDays = now.difference(last).inDays;
        show = diffDays >= 5;
      }
      if (!mounted) return;
      setState(() {
        _show = show;
        _loading = false;
      });
      if (show) {
        unawaited(
          Telemetry.logEvent('profile_smart_reminder_impression', {
            'days_since_last': last == null ? -1 : now.difference(last).inDays,
          }),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _show = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_show) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final isRu = l10n.localeName.startsWith('ru');
    final title = isRu ? 'Вернитесь в ритм' : 'Get back on track';
    final subtitle = isRu ? 'Нет XP за 5 дней' : 'No XP in 5 days';
    final cta = isRu ? 'Начать' : 'Start';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          unawaited(Telemetry.logEvent('profile_smart_reminder_tap', {}));
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (_) => ModuleCatalogScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple.withAlpha((0.15 * 255).round()),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                cta,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyXpGoalCardState extends State<_WeeklyXpGoalCard> {
  int _weeklyXp = 0;
  bool _isLoading = true;
  static const int _weeklyGoal = 50;

  @override
  void initState() {
    super.initState();
    _loadWeeklyXp();
  }

  Future<void> _loadWeeklyXp() async {
    final historyService = XpHistoryService();
    final history = await historyService.getHistory();

    // Get Monday of current week
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = now.subtract(Duration(days: weekday - 1));
    final mondayNormalized = DateTime(monday.year, monday.month, monday.day);

    // Sum XP from Monday to now
    int total = 0;
    for (final event in history) {
      final eventDate = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );
      if (!eventDate.isBefore(mondayNormalized)) {
        total += event.amount;
      }
    }

    if (!mounted) return;

    setState(() {
      _weeklyXp = total;
      _isLoading = false;
    });
  }

  String _getWeekRange(String locale) {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final format = DateFormat('d MMM', locale);
    return '${format.format(monday)}–${format.format(sunday)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _weeklyXp == 0) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final progress = (_weeklyXp / _weeklyGoal).clamp(0.0, 1.0);
    final isComplete = _weeklyXp >= _weeklyGoal;
    final weekRange = _getWeekRange(l10n.localeName);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (_) => XpTabsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: isComplete ? Colors.amber[700] : Colors.amber[600],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.xpWeeklyProgressLabel(_weeklyXp, _weeklyGoal),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.green : Colors.amber[600]!,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    weekRange,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (isComplete)
                    Text(
                      l10n.xpWeeklyGoalComplete,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
