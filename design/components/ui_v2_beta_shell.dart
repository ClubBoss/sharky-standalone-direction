import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/ui_v2_adaptive_dashboard_screen.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/session/ui_v2_session_result_screen.dart';

class UiV2BetaShell extends StatefulWidget {
  const UiV2BetaShell({super.key});

  @override
  State<UiV2BetaShell> createState() => _UiV2BetaShellState();
}

class _UiV2BetaShellState extends State<UiV2BetaShell> {
  final _navigatorKeys = List.generate(3, (_) => GlobalKey<NavigatorState>());
  int _index = 0;

  @override
  Widget build(BuildContext context) {
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
        body: IndexedStack(
          index: _index,
          children: [
            _buildNavigator(0, const UiV2ProgressMapScreenV2()),
            _buildNavigator(1, const UiV2AdaptiveDashboardScreen()),
            _buildNavigator(
              2,
              const UiV2SessionResultScreen(xpGained: 120, chipsEarned: 45),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (value) {
            if (value == _index) {
              _navigatorKeys[value].currentState?.popUntil(
                (route) => route.isFirst,
              );
            } else {
              setState(() => _index = value);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Text('📘'), label: 'Learn'),
            BottomNavigationBarItem(icon: Text('📊'), label: 'Stats'),
            BottomNavigationBarItem(icon: Text('🧑‍💼'), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) =>
          MaterialPageRoute<void>(builder: (context) => child),
    );
  }
}
