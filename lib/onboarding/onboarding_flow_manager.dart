import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../models/v2/training_pack_template.dart' as runtime_template;
import '../services/pack_library_service.dart';
import '../services/smart_review_service.dart';
import '../services/template_storage_service.dart';
import '../services/user_action_logger.dart';
import '../screens/mistake_review_screen.dart';
import '../screens/v2/training_pack_play_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../sharky/design_tokens_v1.dart';

abstract class OnboardingStep {
  Future<dynamic> run(BuildContext context, OnboardingFlowManager manager);
}

/// Progress indicator widget for onboarding steps
class _OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _OnboardingProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      key: const Key('onboarding_progress_surface_v1'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalSteps,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < currentStep
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStepProgress(currentStep, totalSteps),
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingFlowManager {
  static const _completedKey = 'onboardingCompleted';
  static const _mistakeRepeatKey = 'mistakeRepeatCompleted';
  OnboardingFlowManager._();
  static final instance = OnboardingFlowManager._();

  bool _completed = false;
  bool _mistakeRepeatCompleted = false;
  bool get completed => _completed;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _completed = prefs.getBool(_completedKey) ?? false;
    _mistakeRepeatCompleted = prefs.getBool(_mistakeRepeatKey) ?? false;
  }

  Future<void> _markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
    _completed = true;
  }

  Future<void> _markMistakeRepeatCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mistakeRepeatKey, true);
    _mistakeRepeatCompleted = true;
  }

  Future<bool> _hasCompletedTraining() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys()) {
      if (k.startsWith('completed_tpl_') && prefs.getBool(k) == true) {
        return true;
      }
    }
    return false;
  }

  Future<void> maybeStart(BuildContext context) async {
    await _load();
    if (!_completed) {
      if (await _hasCompletedTraining()) return;

      // Log onboarding start
      await UserActionLogger.instance.logEvent({'event': 'onboarding_started'});

      // Welcome step with skip support
      final welcomeResult = await _WelcomeStep().run(context, this);
      if (welcomeResult == 'skip') {
        await _markCompleted();
        return;
      }

      // Pack step
      await _PackStep().run(context, this);

      final hasMistakes = SmartReviewService.instance.hasMistakes();
      await _CongratsStep(showRepeat: hasMistakes).run(context, this);

      if (hasMistakes && !_mistakeRepeatCompleted) {
        await _MistakeRepeatStep().run(context, this);
        await _MistakeRepeatCongratsStep().run(context, this);
        await _markMistakeRepeatCompleted();
      }

      await _markCompleted();
      await UserActionLogger.instance.logEvent({
        'event': 'onboarding_completed',
      });
    } else if (!_mistakeRepeatCompleted &&
        SmartReviewService.instance.hasMistakes()) {
      await _MistakeRepeatStep().run(context, this);
      await _MistakeRepeatCongratsStep().run(context, this);
      await _markMistakeRepeatCompleted();
    }
  }
}

class _WelcomeStep implements OnboardingStep {
  @override
  Future<dynamic> run(
    BuildContext context,
    OnboardingFlowManager manager,
  ) async => await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => _WelcomeScreen(
        onSkip: () async {
          await manager._markCompleted();
        },
      ),
    ),
  );
}

class _PackStep implements OnboardingStep {
  @override
  Future<void> run(BuildContext context, OnboardingFlowManager manager) async {
    final pack = await PackLibraryService.instance.recommendedStarter();
    if (pack == null) return;
    final runtimeTemplate = runtime_template.TrainingPackTemplate.fromJson(
      pack.toJson(),
    );
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainingPackPlayScreen(
          template: runtimeTemplate,
          original: runtimeTemplate,
        ),
        settings: const RouteSettings(name: 'onboarding_starter_pack'),
      ),
    );
  }
}

class _CongratsStep implements OnboardingStep {
  final bool showRepeat;
  const _CongratsStep({required this.showRepeat});

  @override
  Future<void> run(BuildContext context, OnboardingFlowManager manager) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CongratsScreen(showRepeat: showRepeat),
      ),
    );
  }
}

/// Congrats screen after first training
class _CongratsScreen extends StatelessWidget {
  final bool showRepeat;

  const _CongratsScreen({required this.showRepeat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _OnboardingProgressIndicator(currentStep: 3, totalSteps: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _OnboardingSurfaceCardV1(
                      key: const Key('onboarding_congrats_surface_v1'),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.celebration,
                            size: 80,
                            color: SharkyTokensV1.brandPrimary,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            l10n.onboardingCongratulations,
                            style: AppTypography.h1.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            showRepeat
                                ? l10n.onboardingFirstTrainingCompleteWithRepeat
                                : l10n.onboardingFirstTrainingComplete,
                            style: AppTypography.body.copyWith(
                              color: Colors.white70,
                              fontSize: 18,
                              height: 1.45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await UserActionLogger.instance.logEvent({
                                  'event': 'onboarding_step_completed',
                                  'step': 'congrats',
                                });
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              style: _onboardingPrimaryCtaStyleV1(),
                              child: Text(
                                showRepeat
                                    ? l10n.onboardingContinue
                                    : l10n.onboardingFinish,
                                style: AppTypography.label.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _MistakeRepeatStep implements OnboardingStep {
  @override
  Future<void> run(BuildContext context, OnboardingFlowManager manager) async {
    // First, show explanation
    final shouldContinue = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const _MistakeRepeatExplanationScreen(),
      ),
    );

    if (shouldContinue != true) return;

    // Then run the actual review
    final templates = context.read<TemplateStorageService>();
    final spots = await SmartReviewService.instance.getMistakeSpots(
      templates,
      context: context,
    );
    if (spots.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MistakeReviewScreen()),
    );
  }
}

/// Explanation screen for mistake repeat system
class _MistakeRepeatExplanationScreen extends StatelessWidget {
  const _MistakeRepeatExplanationScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _OnboardingProgressIndicator(currentStep: 4, totalSteps: 4),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.refresh,
                        size: 64,
                        color: SharkyTokensV1.brandPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _OnboardingSurfaceCardV1(
                      key: const Key(
                        'onboarding_mistake_explainer_surface_v1',
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.onboardingMistakeSystemTitle,
                            style: AppTypography.h1.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          _ExplanationCard(
                            icon: Icons.flag,
                            title: l10n.onboardingHowItWorksTitle,
                            description: l10n.onboardingHowItWorksDescription,
                          ),
                          const SizedBox(height: 16),
                          _ExplanationCard(
                            icon: Icons.calendar_today,
                            title: l10n.onboardingWhenRepeatsTitle,
                            description:
                                l10n.onboardingWhenRepeatsDescription,
                          ),
                          const SizedBox(height: 16),
                          _ExplanationCard(
                            icon: Icons.trending_up,
                            title: l10n.onboardingWhyNeededTitle,
                            description: l10n.onboardingWhyNeededDescription,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: SharkyTokensV1.brandPrimary.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                SharkyTokensV1.radiusMd,
                              ),
                              border: Border.all(
                                color: SharkyTokensV1.brandPrimary.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: SharkyTokensV1.brandPrimary,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    l10n.onboardingDontWorry,
                                    style: AppTypography.body.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await UserActionLogger.instance.logEvent({
                            'event': 'onboarding_step_completed',
                            'step': 'mistake_repeat_explanation',
                          });
                          if (context.mounted) {
                            Navigator.pop(context, true);
                          }
                        },
                        style: _onboardingPrimaryCtaStyleV1(),
                        child: Text(
                          l10n.onboardingRepeatMistakes,
                          style: AppTypography.label.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          await UserActionLogger.instance.logEvent({
                            'event': 'onboarding_skipped',
                            'step': 'mistake_repeat_explanation',
                          });
                          if (context.mounted) {
                            Navigator.pop(context, false);
                          }
                        },
                        child: Text(
                          l10n.onboardingSkip,
                          style: AppTypography.label.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable explanation card widget
class _ExplanationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ExplanationCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: SharkyTokensV1.surfaceCard.withOpacity(0.72),
      borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
      border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.32)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SharkyTokensV1.brandPrimary.withOpacity(0.18),
            borderRadius: BorderRadius.circular(SharkyTokensV1.radiusSm),
          ),
          child: Icon(icon, color: SharkyTokensV1.brandPrimary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.h3.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTypography.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MistakeRepeatCongratsStep implements OnboardingStep {
  @override
  Future<void> run(BuildContext context, OnboardingFlowManager manager) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _FinalCongratsScreen()),
    );
  }
}

/// Final congrats screen after completing onboarding
class _FinalCongratsScreen extends StatelessWidget {
  const _FinalCongratsScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _OnboardingSurfaceCardV1(
                key: const Key('onboarding_final_congrats_surface_v1'),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 100,
                      color: SharkyTokensV1.brandPrimary,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '🎯 Отлично!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.onboardingMistakesReviewed,
                      style: AppTypography.body.copyWith(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: SharkyTokensV1.brandPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          SharkyTokensV1.radiusMd,
                        ),
                        border: Border.all(
                          color: SharkyTokensV1.brandPrimary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: SharkyTokensV1.brandPrimary,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.onboardingCompletedMessage,
                            style: AppTypography.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await UserActionLogger.instance.logEvent({
                            'event': 'onboarding_completed',
                          });
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        style: _onboardingPrimaryCtaStyleV1(),
                        child: Text(
                          l10n.onboardingStartTraining,
                          style: AppTypography.label.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
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
      ),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  final VoidCallback? onSkip;

  const _WelcomeScreen({this.onSkip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (onSkip != null)
            TextButton(
              onPressed: () async {
                await UserActionLogger.instance.logEvent({
                  'event': 'onboarding_skipped',
                  'step': 'welcome',
                });
                onSkip?.call();
                if (context.mounted) {
                  Navigator.pop(context, 'skip');
                }
              },
              child: Text(
                l10n.onboardingSkip,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _OnboardingProgressIndicator(currentStep: 1, totalSteps: 4),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _OnboardingSurfaceCardV1(
                    key: const Key('onboarding_welcome_surface_v1'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.casino_outlined,
                          size: 80,
                          color: SharkyTokensV1.brandPrimary,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          l10n.onboardingWelcome,
                          style: AppTypography.h1.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.onboardingWelcomeSubtitle,
                          style: AppTypography.body.copyWith(
                            color: Colors.white70,
                            fontSize: 18,
                            height: 1.45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await UserActionLogger.instance.logEvent({
                                'event': 'onboarding_step_completed',
                                'step': 'welcome',
                              });
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            style: _onboardingPrimaryCtaStyleV1(),
                            child: Text(
                              l10n.onboardingStart,
                              style: AppTypography.label.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSurfaceCardV1 extends StatelessWidget {
  const _OnboardingSurfaceCardV1({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.78),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusLg),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.38)),
        boxShadow: SharkyTokensV1.elevation2,
      ),
      child: child,
    );
  }
}

ButtonStyle _onboardingPrimaryCtaStyleV1() {
  return ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    backgroundColor: SharkyTokensV1.brandPrimary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
    ),
  );
}
