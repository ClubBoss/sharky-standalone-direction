import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../infra/telemetry.dart';
import 'xp_recap_summary_part.dart';
import 'xp_recap_history_part.dart';
import 'xp_recap_weekly_part.dart';

/// Экран "Обзор XP": краткая сводка прогресса с полосой XP,
/// журналом последних действий, прогрессом недельной цели и превью следующего этапа.
class XpRecapScreen extends StatefulWidget {
  XpRecapScreen({super.key});

  @override
  State<XpRecapScreen> createState() => _XpRecapScreenState();
}

class _XpRecapScreenState extends State<XpRecapScreen> {
  TabController? _controller;
  int _lastReportedIndex = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ctrl = DefaultTabController.of(context);
    if (_controller == ctrl) return;
    if (_controller != null) {
      _controller!.removeListener(_onTabChanged);
    }
    _controller = ctrl;
    _controller?.addListener(_onTabChanged);

    // Fire initial tab opened after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final idx = _controller?.index ?? 0;
      _reportTab(idx);
    });
  }

  void _onTabChanged() {
    if (!mounted) return;
    final idx = _controller?.index;
    if (idx == null) return;
    // Avoid duplicate logs during animation
    if (_lastReportedIndex == idx) return;
    _reportTab(idx);
  }

  void _reportTab(int index) {
    _lastReportedIndex = index;
    final tab = switch (index) {
      0 => 'summary',
      1 => 'history',
      _ => 'goals',
    };
    Telemetry.logEvent('xp_recap_tab_opened', {'tab': tab});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.xpRecapTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.xpRecapTabSummary),
              Tab(text: l10n.xpRecapTabHistory),
              Tab(text: l10n.xpRecapTabGoals),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            XpRecapSummaryPart(),
            XpRecapHistoryPart(),
            XpRecapWeeklyPart(),
          ],
        ),
      ),
    );
  }
}
