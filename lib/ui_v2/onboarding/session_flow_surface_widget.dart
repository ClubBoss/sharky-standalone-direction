import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/player_profile_bootstrap_service.dart';
import 'package:poker_analyzer/services/training_path_visualizer_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _radius = 12.0;
const List<BoxShadow> _cardShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
];

class SessionFlowSurfaceWidget extends StatelessWidget {
  const SessionFlowSurfaceWidget({super.key});

  Future<_SessionPayload> _loadPayload() async {
    final results = await Future.wait([
      TrainingPathVisualizerService().build(),
      PlayerProfileBootstrapService().build(),
    ]);
    final visualization = results[0] as TrainingPathVisualization;
    final profile = results[1] as PlayerProfileContextBundle;
    final nextModule = visualization.pathNodes.isNotEmpty
        ? visualization.pathNodes.first['module'] as String? ?? 'Next module'
        : 'Next module';
    final tone = profile.personaProfile['tone'] as Map<String, Object?>?;
    final toneLabel = tone?['friendly'] == true
        ? 'Friendly tone'
        : tone?['supportive'] == true
        ? 'Supportive tone'
        : 'Balanced tone';
    final engagementHint =
        profile.personaProfile['engagement'] is Map<String, Object?>
        ? (profile.personaProfile['engagement']!
                  as Map<String, Object?>)['focus'] ??
              'Steady focus'
        : 'Steady focus';
    return _SessionPayload(
      header: 'Your upcoming session',
      moduleName: nextModule,
      guidance: '$toneLabel & $engagementHint',
      microHint: (profile.hintProfile['tier'] ?? 'medium') == 'high'
          ? 'Micro hint: keep leverage high momentum.'
          : 'Micro hint: stay calm and keep a steady pace.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SessionPayload>(
      future: _loadPayload(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _placeholder(context, 'Session surface loading...');
        }
        if (snapshot.hasError) {
          return _placeholder(context, 'Session surface unavailable');
        }
        final payload = snapshot.data;
        if (payload == null) {
          return _placeholder(context, 'Session surface unavailable');
        }
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: _cardShadow,
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payload.header,
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                payload.moduleName,
                style: AppTypography.h1.copyWith(color: AppColors.primaryBrand),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                payload.guidance,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                payload.microHint,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholder(BuildContext context, String message) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: _cardShadow,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Text(
        message,
        style: AppTypography.body.copyWith(color: AppColors.textSecondaryDark),
      ),
    );
  }
}

class _SessionPayload {
  _SessionPayload({
    required this.header,
    required this.moduleName,
    required this.guidance,
    required this.microHint,
  });

  final String header;
  final String moduleName;
  final String guidance;
  final String microHint;
}
