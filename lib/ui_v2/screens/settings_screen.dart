import 'package:flutter/material.dart';

import '../components/design_button.dart';
import '../components/design_list_tile.dart';
import '../components/design_panel.dart';
import '../design/design_layout.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(DesignColors.surface),
      body: Padding(
        padding: const EdgeInsets.all(DesignLayout.pagePadding),
        child: DesignPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: DesignTypography.h1,
                  fontWeight: FontWeight.bold,
                  color: Color(DesignColors.accent),
                ),
              ),
              const SizedBox(height: DesignLayout.sectionSpacing),
              const DesignListTile(
                title: 'Notifications',
                subtitle: 'Push, sounds, alerts',
                onTap: null,
              ),
              const SizedBox(height: DesignLayout.itemSpacing),
              const DesignListTile(
                title: 'Privacy & Security',
                subtitle: 'Data, telemetry, access',
                onTap: null,
              ),
              const SizedBox(height: DesignLayout.itemSpacing),
              const DesignListTile(
                title: 'Support + Feedback',
                subtitle: 'Report issues or ideas',
                onTap: null,
              ),
              const SizedBox(height: DesignLayout.sectionSpacing),
              DesignButton(label: 'Save Settings (future)', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
