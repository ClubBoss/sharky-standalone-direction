import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/player_profile_bootstrap_service.dart';
import 'package:poker_analyzer/services/smart_cta_planner_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';

const double _radius = 12.0;
const List<BoxShadow> _cardShadow = [
  BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
];

class ValuePropositionWidget extends StatelessWidget {
  const ValuePropositionWidget({super.key});

  Future<_ValuePropositionPayload> _loadPayload() async {
    final results = await Future.wait([
      SmartCtaPlannerService().run(),
      PlayerProfileBootstrapService().build(),
    ]);
    final cta = results[0] as SmartCtaBundle;
    final profile = results[1] as PlayerProfileContextBundle;
    final preferredPaths = profile.trainingProfile['preferred_paths'];
    final preferredPath = preferredPaths is List && preferredPaths.isNotEmpty
        ? preferredPaths.first as String
        : 'Focused module';
    final hintList = [
      cta.secondaryCta,
      cta.microCta,
      'Persona focus: ${profile.personaProfile['tone'] ?? 'balanced'}',
    ];
    return _ValuePropositionPayload(
      header: 'Why continue',
      bullets: hintList.take(3).toList(),
      valueStatement: 'Your improvement focus: $preferredPath',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ValuePropositionPayload>(
      future: _loadPayload(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _placeholder(context, 'Value check loading...');
        }
        if (snapshot.hasError) {
          return _placeholder(context, 'Value summary unavailable');
        }
        final payload = snapshot.data;
        if (payload == null) {
          return _placeholder(context, 'Value summary unavailable');
        }
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightCard,
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
              ...payload.bullets.map(
                (bullet) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          bullet,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                payload.valueStatement,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimaryDark,
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

class _ValuePropositionPayload {
  _ValuePropositionPayload({
    required this.header,
    required this.bullets,
    required this.valueStatement,
  });

  final String header;
  final List<String> bullets;
  final String valueStatement;
}
