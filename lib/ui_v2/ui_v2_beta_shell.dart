import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_canonical_path_root_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

class UiV2BetaShell extends StatefulWidget {
  const UiV2BetaShell({super.key});

  @override
  State<UiV2BetaShell> createState() => _UiV2BetaShellState();
}

class _UiV2BetaShellState extends State<UiV2BetaShell> {
  final _navigatorKeys = List.generate(3, (_) => GlobalKey<NavigatorState>());
  late final List<NavigatorObserver> _tabObservers;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tabObservers = List<NavigatorObserver>.generate(
      3,
      (_) => _ShellTabNavObserver(onStackChanged: _handleTabStackChanged),
    );
  }

  void _handleTabStackChanged() {
    if (!mounted) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      setState(() {});
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final showDrillsTabV1 = kDebugMode;
    final bottomNavIndexV1 = showDrillsTabV1 ? _index : (_index == 2 ? 1 : 0);
    final currentNavigator = _navigatorKeys[_index].currentState;
    final showBottomBar = !(currentNavigator?.canPop() ?? false);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final currentNavigator = _navigatorKeys[_index].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        } else {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        key: const Key('main_shell_v1'),
        body: IndexedStack(
          index: _index,
          children: [
            _buildNavigator(0, buildCanonicalPathRootV1()),
            _buildNavigator(1, const _DrillsTabV1()),
            _buildNavigator(2, const _ProfileTabV1()),
          ],
        ),
        bottomNavigationBar: showBottomBar
            ? BottomNavigationBar(
                currentIndex: bottomNavIndexV1,
                onTap: (value) {
                  final resolvedIndex = showDrillsTabV1
                      ? value
                      : (value == 0 ? 0 : 2);
                  if (resolvedIndex == _index) {
                    _navigatorKeys[resolvedIndex].currentState?.popUntil(
                      (route) => route.isFirst,
                    );
                  } else {
                    setState(() => _index = resolvedIndex);
                  }
                },
                items: showDrillsTabV1
                    ? const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.route_outlined),
                          activeIcon: Icon(Icons.route),
                          label: 'Path',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.fitness_center_outlined),
                          activeIcon: Icon(Icons.fitness_center),
                          label: 'Drills',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person_outline),
                          activeIcon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                      ]
                    : const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.route_outlined),
                          activeIcon: Icon(Icons.route),
                          label: 'Path',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person_outline),
                          activeIcon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                      ],
              )
            : null,
      ),
    );
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      observers: [_tabObservers[index]],
      onGenerateRoute: (settings) =>
          MaterialPageRoute<void>(builder: (context) => child),
    );
  }
}

class _ShellTabNavObserver extends NavigatorObserver {
  _ShellTabNavObserver({required this.onStackChanged});

  final VoidCallback onStackChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onStackChanged();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onStackChanged();
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onStackChanged();
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    onStackChanged();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

class _DrillsTabV1 extends StatefulWidget {
  const _DrillsTabV1();

  @override
  State<_DrillsTabV1> createState() => _DrillsTabV1State();
}

class _DrillsTabV1State extends State<_DrillsTabV1> {
  bool _opening = false;
  late Future<String> _nextLabelFuture;

  @override
  void initState() {
    super.initState();
    _nextLabelFuture = _loadNextLabel();
  }

  Future<String> _loadNextLabel() async {
    final nextPackId = await ProgressService.getNextSpinePackToRunV1();
    return ProgressService.segmentLabelForPackIdV1(nextPackId);
  }

  Future<void> _openQuickDrill() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final packId = await ProgressService.getNextSpinePackToRunV1();
      final activePackId = await ProgressService.getSpineActivePackIdV1();
      final startHandIndex = activePackId == packId
          ? await ProgressService.getSpineNextHandIndexV1()
          : 0;
      if (!mounted) return;
      await pushWorld1FoundationsRunnerV1<void>(
        context,
        moduleId: packId,
        moduleTitle: 'Quick Drill',
        mode: kWorld1RunnerModeCampaignSpine,
        startHandIndex: startHandIndex,
      );
    } finally {
      if (mounted) {
        setState(() => _opening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Drills', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick drill: ~30-60s',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<String>(
                      future: _nextLabelFuture,
                      builder: (context, snapshot) {
                        final focus = snapshot.data?.trim() ?? 'Next lesson';
                        return Text(
                          'Focus: $focus',
                          key: const Key('drills_focus_label_v1'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  key: const Key('drills_quick_drill_cta_v1'),
                  onPressed: _opening ? null : _openQuickDrill,
                  child: Text(_opening ? 'OPENING...' : 'PRACTICE NOW'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSnapshotV1 {
  const _ProfileSnapshotV1({
    required this.currentWorld,
    required this.currentWorldDone,
    required this.currentWorldTotal,
    required this.totalCompleted,
    required this.nextLabel,
    required this.chipsBalance,
    required this.chipsEarnedTotal,
    required this.chipsSpentTotal,
  });

  final int currentWorld;
  final int currentWorldDone;
  final int currentWorldTotal;
  final int totalCompleted;
  final String nextLabel;
  final int chipsBalance;
  final int chipsEarnedTotal;
  final int chipsSpentTotal;
}

class _ProfileTabV1 extends StatefulWidget {
  const _ProfileTabV1();

  @override
  State<_ProfileTabV1> createState() => _ProfileTabV1State();
}

class _ProfileTabV1State extends State<_ProfileTabV1> {
  late Future<_ProfileSnapshotV1> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
  }

  Future<_ProfileSnapshotV1> _loadSnapshot() async {
    final completed = await ProgressService.getSpineCompletedPackIdsV1();
    final nextPackId = await ProgressService.getNextSpinePackToRunV1();
    final chips = await ProgressService.getChipsLedgerSnapshotV1();
    final currentWorld = ProgressService.worldIndexForPackIdV1(nextPackId);
    final currentWorldPackIds = canonicalTruthCampaignPackOrderForWorldV1(
      currentWorld,
    );
    final currentWorldDone = currentWorldPackIds
        .where(completed.contains)
        .length;
    final nextLabel = ProgressService.segmentLabelForPackIdV1(nextPackId);
    return _ProfileSnapshotV1(
      currentWorld: currentWorld,
      currentWorldDone: currentWorldDone,
      currentWorldTotal: currentWorldPackIds.length,
      totalCompleted: completed.length,
      nextLabel: nextLabel,
      chipsBalance: chips.balance,
      chipsEarnedTotal: chips.earnedTotal,
      chipsSpentTotal: chips.spentTotal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<_ProfileSnapshotV1>(
            future: _snapshotFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Current world (${data.currentWorld}) progress: ${data.currentWorldDone}/${data.currentWorldTotal} lessons',
                        key: const Key('profile_world1_progress_v1'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Total lessons completed: ${data.totalCompleted}',
                        key: const Key('profile_total_completed_v1'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      key: const Key('profile_chips_summary_v1'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Chips  Balance: ${data.chipsBalance}  Earned: ${data.chipsEarnedTotal}  Spent: ${data.chipsSpentTotal}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Next: ${data.nextLabel}',
                        key: const Key('profile_next_label_v1'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
