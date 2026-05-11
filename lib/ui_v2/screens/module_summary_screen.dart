import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/table/table_surface.dart';
import 'package:poker_analyzer/ui_v2/widgets/section_header.dart';
import 'package:poker_analyzer/ui_v2/widgets/section_surface.dart';

class ModuleSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> moduleData;

  const ModuleSummaryScreen({super.key, required this.moduleData});

  @override
  Widget build(BuildContext context) {
    final title =
        (moduleData['title'] ?? moduleData['name'] ?? 'Untitled Module')
            .toString();
    final description =
        (moduleData['description'] ?? 'No description available.').toString();
    final id = (moduleData['id'] ?? 'unknown_id').toString();
    final tier = (moduleData['tier'] ?? 'Free').toString();
    final isWorld1 = kWorld1CanonicalModuleOrder.contains(id);
    final showFoundationsCheck = isWorld1 && hasWorld1MicroTaskPack(id);
    final isAvailable = moduleData['isAvailable'] as bool? ?? true;
    final isUnlocked = moduleData['isUnlocked'] as bool? ?? true;
    final summaryContent = SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: ListView(
          children: [
            SectionSurface(
              key: const Key('module_summary_hero_card_v1'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: SharkyTokensV1.brandPrimary.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(
                            SharkyTokensV1.radiusMd,
                          ),
                        ),
                        child: Icon(
                          Icons.play_lesson_rounded,
                          color: SharkyTokensV1.brandPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Module overview',
                              style: AppTypography.caption.copyWith(
                                color: SharkyTokensV1.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              title,
                              style: AppTypography.h1.copyWith(
                                color: SharkyTokensV1.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    key: const Key('module_summary_tier_pill_v1'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: SharkyTokensV1.brandPrimary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(
                        SharkyTokensV1.radiusFull,
                      ),
                      border: Border.all(
                        color: SharkyTokensV1.brandPrimary.withOpacity(0.72),
                      ),
                    ),
                    child: Text(
                      'TIER $tier',
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.brandPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    description,
                    style: AppTypography.body.copyWith(
                      color: SharkyTokensV1.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    key: const Key('module_summary_metadata_v1'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: SharkyTokensV1.surfaceElevated.withOpacity(0.52),
                      borderRadius: BorderRadius.circular(
                        SharkyTokensV1.radiusSm,
                      ),
                      border: Border.all(
                        color: SharkyTokensV1.slate600.withOpacity(0.36),
                      ),
                    ),
                    child: Text(
                      'Module ID: $id',
                      style: AppTypography.caption.copyWith(
                        color: SharkyTokensV1.textMuted,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionSurface(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'Start here',
                    subtitle: 'Read theory first, then continue into practice',
                  ),
                  if (showFoundationsCheck) ...[
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        key: const Key('module_summary_foundations_check_cta'),
                        style: _secondaryCtaStyle(),
                        onPressed: () async {
                          UiSoundV1.fire(UiSoundEventV1.tap);
                          await pushWorld1FoundationsRunnerV1<void>(
                            context,
                            moduleId: id,
                            moduleTitle: title,
                          );
                        },
                        child: Text(
                          'FOUNDATIONS CHECK',
                          style: AppTypography.label.copyWith(
                            color: SharkyTokensV1.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      key: const Key('module_summary_start_theory_cta'),
                      style: _primaryCtaStyle(),
                      onPressed: () {
                        UiSoundV1.fire(UiSoundEventV1.tap);
                        navigateToLearningModuleV1(
                          context,
                          id,
                          moduleTitle: title,
                        );
                      },
                      child: Text(
                        'START THEORY',
                        style: AppTypography.label.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: SharkyTokensV1.textSecondary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isWorld1
          ? KeyedSubtree(
              key: const Key('table_first_summary_shell'),
              child: TableSurface(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              SharkyTokensV1.surfaceCard.withOpacity(0.6),
                              SharkyTokensV1.surfaceApp.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ),
                    summaryContent,
                  ],
                ),
              ),
            )
          : summaryContent,
    );
  }
}

ButtonStyle _primaryCtaStyle() {
  return ButtonStyle(
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
      ),
    ),
    minimumSize: MaterialStateProperty.all(const Size(0, 56)),
    overlayColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) {
        return Colors.white.withOpacity(0.14);
      }
      if (states.contains(MaterialState.hovered)) {
        return Colors.white.withOpacity(0.08);
      }
      if (states.contains(MaterialState.focused)) {
        return Colors.white.withOpacity(0.1);
      }
      return null;
    }),
    side: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return BorderSide(
          color: SharkyTokensV1.semanticWin.withOpacity(
            SharkyTokensV1.opacityDisabled,
          ),
          width: 1.2,
        );
      }
      return BorderSide(
        color: SharkyTokensV1.semanticWin.withOpacity(0.84),
        width: 1.2,
      );
    }),
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return SharkyTokensV1.brandPrimary.withOpacity(
          SharkyTokensV1.opacityDisabled,
        );
      }
      return SharkyTokensV1.brandPrimary;
    }),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  );
}

ButtonStyle _secondaryCtaStyle() {
  return ButtonStyle(
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
      ),
    ),
    side: MaterialStateProperty.all(
      BorderSide(color: SharkyTokensV1.slate600.withOpacity(0.9)),
    ),
    foregroundColor: MaterialStateProperty.all(SharkyTokensV1.textPrimary),
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) {
        return SharkyTokensV1.surfaceElevated.withOpacity(0.95);
      }
      if (states.contains(MaterialState.hovered)) {
        return SharkyTokensV1.surfaceElevated.withOpacity(0.9);
      }
      return SharkyTokensV1.surfaceCard.withOpacity(0.8);
    }),
  );
}
