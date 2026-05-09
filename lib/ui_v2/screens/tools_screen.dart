import 'package:flutter/material.dart';

import '../components/design_list_tile.dart';
import '../components/design_panel.dart';
import '../design/design_layout.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

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
                'Tools',
                style: TextStyle(
                  fontSize: DesignTypography.h1,
                  fontWeight: FontWeight.bold,
                  color: Color(DesignColors.accent),
                ),
              ),
              const SizedBox(height: DesignLayout.sectionSpacing),
              const DesignListTile(
                title: 'Debug Tools (future)',
                subtitle: 'Logs, dumps, profiling',
                onTap: null,
              ),
              const SizedBox(height: DesignLayout.itemSpacing),
              const DesignListTile(
                title: 'Export / Import Modules',
                subtitle: 'Bundles and presets',
                onTap: null,
              ),
              const SizedBox(height: DesignLayout.itemSpacing),
              const DesignListTile(
                title: 'Customization Studio',
                subtitle: 'Themes, sounds, cues',
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
