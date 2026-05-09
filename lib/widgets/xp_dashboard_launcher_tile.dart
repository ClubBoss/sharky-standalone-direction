import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/xp_tabs_screen.dart';

/// Launcher tile for the unified XP dashboard system.
///
/// Displays an entry point in profile/settings screens that navigates
/// to the tabbed XP interface (history, journal, self-eval).
class XpDashboardLauncherTile extends StatelessWidget {
  const XpDashboardLauncherTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber.withValues(alpha: 0.2),
          child: const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
        ),
        title: Text(
          l10n.xpDashboardLauncherTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          l10n.xpDashboardLauncherSubtitle,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const XpTabsScreen()),
          );
        },
      ),
    );
  }
}
