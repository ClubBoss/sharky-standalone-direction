import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/player_profile_screen_renderer_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

import 'player_profile_sections.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rendererService = PlayerProfileScreenRendererService();
    return Scaffold(
      body: FutureBuilder<PlayerProfileRenderTreeBundle>(
        future: rendererService.run(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Render tree failed to load',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final bundle = snapshot.data;
          if (bundle == null) {
            return const SizedBox.shrink();
          }
          final sections = bundle.screen['sections'];
          final sectionList = sections is List ? sections : const [];
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
                horizontal: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final rawSection in sectionList)
                    if (rawSection is Map<String, Object?>)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        child: buildSection(context, rawSection),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
