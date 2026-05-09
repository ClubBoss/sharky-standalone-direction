import 'package:flutter/material.dart';

import '../components/design_button.dart';
import '../components/design_card.dart';
import '../components/design_panel.dart';
import '../design/design_layout.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';

class ImportSpotsScreen extends StatelessWidget {
  const ImportSpotsScreen({super.key});

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
                'Import Spots',
                style: TextStyle(
                  fontSize: DesignTypography.h1,
                  fontWeight: FontWeight.bold,
                  color: Color(DesignColors.accent),
                ),
              ),
              const SizedBox(height: DesignLayout.sectionSpacing),
              const DesignCard(
                child: Text(
                  'Import preview / file picker (future)',
                  style: TextStyle(
                    fontSize: DesignTypography.body,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: DesignLayout.sectionSpacing),
              DesignButton(label: 'Import (future)', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
