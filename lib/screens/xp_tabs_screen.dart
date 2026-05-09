import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/xp_service.dart';
import 'xp_dashboard_screen.dart';
import 'xp_journal_screen.dart';
import 'xp_self_eval_screen.dart';
import 'xp_milestone_screen.dart';
import 'league_screen.dart';
import 'xp_share_screen.dart';

/// Unified XP interface with tabbed navigation.
///
/// Combines six XP-related screens into a single discoverable interface:
/// - История (History): XP Dashboard with event timeline
/// - Журнал (Journal): Reflection notes for deliberate practice
/// - Самооценка (Self-Eval): Skill checklist for self-assessment
/// - Этапы (Milestones): Achievement milestones and rewards
/// - Лига (League): Weekly competitive league ladder
/// - Поделиться (Share): Shareable XP summary card
class XpTabsScreen extends StatefulWidget {
  XpTabsScreen({super.key});

  @override
  State<XpTabsScreen> createState() => _XpTabsScreenState();
}

class _XpTabsScreenState extends State<XpTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.xpTabsTitle),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey[600],
          isScrollable: true,
          tabs: [
            Tab(icon: const Icon(Icons.history), text: l10n.xpHistoryTab),
            Tab(icon: const Icon(Icons.book), text: l10n.xpJournalTab),
            Tab(
              icon: const Icon(Icons.assignment_turned_in),
              text: l10n.xpEvalTab,
            ),
            Tab(
              icon: const Icon(Icons.emoji_events),
              text: l10n.xpMilestonesTab,
            ),
            Tab(icon: const Icon(Icons.leaderboard), text: l10n.xpLeagueTab),
            Tab(icon: const Icon(Icons.share), text: l10n.xpShareTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          XpDashboardScreen(),
          XpJournalScreen(),
          XpSelfEvalScreen(),
          XpMilestoneScreen(xpService: context.read<XpService>()),
          LeagueScreen(userXp: context.read<XpService>().getTotalXp()),
          XpShareScreen(),
        ],
      ),
    );
  }
}
