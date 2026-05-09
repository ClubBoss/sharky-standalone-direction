import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/home/direct_loader.dart';
import 'package:poker_analyzer/ui_v2/runner/drill_host_capability_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/factual_runner_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_canonical_completion_bridge_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_runner_item_normalizer_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_canonical_progression_bridge_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_bottom_action_stack_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_compact_header_band_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_completion_surface_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_prompt_status_capsule_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_scene_support_lane_v1.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_source_meta_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/table/table_surface.dart';
import 'package:poker_analyzer/ui_v2/visual/campaign_ui_kit_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';

class DrillRunnerScreen extends StatefulWidget {
  final String moduleId;
  final List<Map<String, dynamic>>? resolvedItemsV1;
  final List<Map<String, dynamic>>? debugItemsOverrideV1;

  const DrillRunnerScreen({
    super.key,
    required this.moduleId,
    this.resolvedItemsV1,
    this.debugItemsOverrideV1,
  });

  @override
  State createState() => _DrillRunnerScreenState();
}

FactualRunnerHostContractV1? buildLegacyDrillRunnerFactualHostContractV1({
  required LegacyDrillRunnerItemV1 item,
  required RunnerHostPromptRevealPresentationResolvedV1 presentation,
  required RunnerHostSectionResponsibilityV1 sections,
}) {
  final family = item.factualFamily;
  if (family == null) {
    return null;
  }
  return FactualRunnerHostContractV1(
    family: family,
    presentation: presentation,
    sections: sections,
    sourceMeta: item.sourceMeta,
  );
}

class _DrillRunnerScreenState extends State<DrillRunnerScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  LegacyDrillCanonicalProgressionStateV1 _progressionV1 =
      const LegacyDrillCanonicalProgressionStateV1.initial();
  bool _successCueActive = false;

  int get _currentIndex => _progressionV1.currentIndex;
  bool get _isAnswerRevealed => _progressionV1.isAnswerRevealed;
  int get _correctAnswers => _progressionV1.correctAnswers;
  int? get _selectedQuizIndex => _progressionV1.selectedQuizIndex;
  int? get _correctQuizIndex => _progressionV1.correctQuizIndex;
  bool? get _selectedQuizCorrect => _progressionV1.selectedQuizCorrect;
  bool get _quizLocked => _progressionV1.quizLocked;

  bool get _isWorld1TableFirst =>
      kWorld1CanonicalModuleOrder.contains(widget.moduleId);

  @override
  void initState() {
    super.initState();
    final seededItemsV1 = widget.resolvedItemsV1 ?? widget.debugItemsOverrideV1;
    if (seededItemsV1 != null) {
      _items = List<Map<String, dynamic>>.from(seededItemsV1);
      _isLoading = false;
      _progressionV1 = const LegacyDrillCanonicalProgressionStateV1.initial();
      return;
    }
    _loadDrillItems();
  }

  DrillHostCapabilityContractV1 _legacyItemHostContractV1({
    required LegacyDrillRunnerItemV1 item,
    required bool isCompleted,
  }) {
    return resolveDrillHostCapabilityContractV1(
      DrillHostCapabilityContractInputV1(
        sessionId: widget.moduleId,
        spec: DrillSpecV1(
          id: 'legacy_${_currentIndex + 1}',
          kind: DrillKindV1.actionChoice,
          prompt: item.prompt,
          expected: const DrillExpectedV1(actionId: 'continue'),
          errorClass: 'legacy_drill_runner_transition',
        ),
        currentDrillIndex: _currentIndex,
        currentChainStepIndex: 0,
        isCompleted: isCompleted,
        showsSurfacedScenarioHostV1: false,
        showsEmbeddedScenarioTableV1: _isWorld1TableFirst,
        sections: RunnerHostSectionResponsibilityV1(
          showSourceMeta: item.sourceMeta.hasEntries,
        ),
      ),
    );
  }

  FactualRunnerHostContractV1? _legacyFactualHostContractV1({
    required LegacyDrillRunnerItemV1 item,
    required RunnerHostPromptRevealPresentationResolvedV1 presentation,
    required RunnerHostSectionResponsibilityV1 sections,
  }) {
    return buildLegacyDrillRunnerFactualHostContractV1(
      item: item,
      presentation: presentation,
      sections: sections,
    );
  }

  Future<void> _loadDrillItems() async {
    final List<Map<String, dynamic>> loaded = [];
    await _loadJsonl('drills.jsonl', loaded);
    await _loadJsonl('quiz.jsonl', loaded);

    if (loaded.isNotEmpty) {
      loaded.shuffle();
    }

    setState(() {
      _items = loaded;
      _isLoading = false;
      _progressionV1 = const LegacyDrillCanonicalProgressionStateV1.initial();
    });
  }

  Future<void> _loadJsonl(
    String fileName,
    List<Map<String, dynamic>> target,
  ) async {
    try {
      final content = await DirectLoader.loadContentFile(
        widget.moduleId,
        fileName,
      );
      final lines = LineSplitter.split(content);
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          target.add(jsonDecode(line) as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing $fileName line: $e');
        }
      }
    } catch (e) {
      print('Missing $fileName for ${widget.moduleId}: $e');
    }
  }

  void _advanceDrill({bool countedAsCorrect = false}) {
    final advanceResultV1 = LegacyDrillCanonicalProgressionBridgeV1.advance(
      _progressionV1,
      itemCount: _items.length,
      countedAsCorrect: countedAsCorrect,
    );
    if (!advanceResultV1.completesRun) {
      setState(() {
        _progressionV1 = advanceResultV1.nextState;
      });
    } else {
      pushReplacementSessionResultV1<void, void>(
        context,
        correctCount: advanceResultV1.finalCorrectCount,
        totalCount: _items.length,
        moduleId: widget.moduleId,
      );
    }
  }

  void _triggerSuccessCue() {
    if (!mounted) return;
    setState(() {
      _successCueActive = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      setState(() {
        _successCueActive = false;
      });
    });
  }

  void _showQuizResult({
    required LegacyDrillRunnerItemV1 item,
    required bool isCorrect,
    required int selectedIndex,
    required int correctIndex,
  }) {
    if (!_quizLocked) {
      UiSoundV1.fire(isCorrect ? UiSoundEventV1.success : UiSoundEventV1.error);
      unawaited(
        UiHapticsV1.fire(
          isCorrect ? UiHapticEventV1.success : UiHapticEventV1.error,
        ),
      );
      if (isCorrect) {
        _triggerSuccessCue();
      }
      setState(() {
        _progressionV1 =
            LegacyDrillCanonicalProgressionBridgeV1.resolveQuizSelection(
              _progressionV1,
              isCorrect: isCorrect,
              selectedIndex: selectedIndex,
              correctIndex: correctIndex,
            );
      });
    }
    final completionContractV1 = _legacyItemHostContractV1(
      item: item,
      isCompleted: _currentIndex >= _items.length - 1,
    );
    final sheetPlanV1 =
        LegacyDrillCanonicalCompletionBridgeV1.resolveQuizResultSheetPlan(
          isCorrect: isCorrect,
          isFinalItem: completionContractV1.showsCompletionContinuationSurface,
          correctFeedback: item.correctFeedback,
          incorrectFeedback: item.incorrectFeedback,
        );
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: isCorrect
          ? SharkyTokensV1.semanticWin.withOpacity(0.92)
          : SharkyTokensV1.semanticLoss.withOpacity(0.92),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isCorrect
                    ? SharkyTokensV1.semanticWin.withOpacity(0.9)
                    : SharkyTokensV1.semanticLoss.withOpacity(0.9),
                width: 1.2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sheetPlanV1.titleText,
                style: AppTypography.h1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                sheetPlanV1.feedbackText,
                style: AppTypography.body.copyWith(color: Colors.white),
              ),
              SizedBox(height: AppSpacing.md),
              _buildLegacyCompletionActionStackV1(
                surfaceKey: const Key(
                  'drill_runner_quiz_completion_action_stack_v1',
                ),
                contract: _buildLegacyContinuationContractV1(
                  primaryLabel: sheetPlanV1.primaryLabel,
                ),
                onPrimaryPressed: () {
                  Navigator.pop(context);
                  _advanceDrill(
                    countedAsCorrect: sheetPlanV1.primaryCountsAsCorrect,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPromptDetailsSheetV1({
    required RunnerHostPromptRevealPresentationResolvedV1 presentation,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: SharkyTokensV1.surfaceApp,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details',
                  style: AppTypography.h3.copyWith(
                    color: SharkyTokensV1.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  presentation.detailsPrompt,
                  key: ValueKey<String>(
                    'drill_runner_prompt_details_${presentation.reveal.sourceId}',
                  ),
                  style: AppTypography.body.copyWith(
                    color: SharkyTokensV1.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceMetaBlockV1(
    BuildContext context,
    RunnerHostSourceMetaContractV1 sourceMeta,
  ) {
    return Wrap(
      key: const Key('drill_runner_source_meta_block_v1'),
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in sourceMeta.entries)
          Chip(
            key: Key(entry.testKey),
            label: Text(entry.text),
            labelStyle:
                (entry.useBodySmall
                        ? AppTypography.caption
                        : AppTypography.caption)
                    .copyWith(
                      color: SharkyTokensV1.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
            visualDensity: VisualDensity.compact,
            backgroundColor: SharkyTokensV1.surfaceApp.withOpacity(0.48),
            side: BorderSide(color: SharkyTokensV1.slate500.withOpacity(0.35)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }

  Widget _buildPromptSupportLaneV1(
    BuildContext context, {
    required RunnerHostPromptRevealPresentationResolvedV1 presentation,
    required bool showsPromptDetailsButton,
    required bool showsSourceMeta,
    required RunnerHostSourceMetaContractV1 sourceMeta,
  }) {
    if (!showsPromptDetailsButton && !showsSourceMeta) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[
      if (showsPromptDetailsButton)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            key: ValueKey<String>(
              'drill_runner_prompt_details_button_${presentation.reveal.sourceId}',
            ),
            onPressed: () =>
                _showPromptDetailsSheetV1(presentation: presentation),
            child: const Text('Details'),
          ),
        ),
      if (showsSourceMeta) _buildSourceMetaBlockV1(context, sourceMeta),
    ];

    return RunnerSceneSupportLaneV1(
      surfaceKey: const Key('drill_runner_prompt_support_lane_v1'),
      compact: true,
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      surfaceColor: SharkyTokensV1.surfaceApp.withOpacity(0.48),
      borderColor: SharkyTokensV1.slate500.withOpacity(0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildLegacyPromptCapsuleV1({required String promptText}) {
    return RunnerPromptStatusCapsuleV1(
      surfaceKey: const Key('drill_runner_prompt_capsule_v1'),
      promptText: promptText,
      promptTextKey: const Key('drill_runner_prompt_text_v1'),
      compact: false,
      showChevron: false,
      detailsLabel: '',
      surfaceColor: Colors.transparent,
      borderColor: Colors.transparent,
      badgeColor: Colors.transparent,
      foregroundColor: SharkyTokensV1.textPrimary,
      maxPromptLines: 4,
      promptSoftWrap: true,
      promptOverflow: TextOverflow.visible,
    );
  }

  String _legacyPromptHeaderStatusV1({
    required int currentIndex,
    required int total,
  }) {
    final safeTotal = total == 0 ? 1 : total;
    return 'Progress $currentIndex/$safeTotal';
  }

  Widget _buildLegacyPromptShellV1({
    required Key promptKey,
    required String promptText,
    required bool useCanonicalHeaderBand,
    String? statusText,
  }) {
    if (useCanonicalHeaderBand) {
      return RunnerCompactHeaderBandV1(
        surfaceKey: promptKey,
        statusText: statusText,
        statusTextKey: const Key('drill_runner_prompt_header_status_v1'),
        headlineText: 'Prompt',
        headlineTextKey: const Key('drill_runner_prompt_header_title_v1'),
        compact: false,
        surfaceColor: SharkyTokensV1.surfaceCard.withOpacity(0.78),
        borderColor: SharkyTokensV1.slate600.withOpacity(0.7),
        headlineColor: SharkyTokensV1.textPrimary,
        bottomChild: _buildLegacyPromptCapsuleV1(promptText: promptText),
      );
    }

    return Container(
      key: promptKey,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.76),
        border: Border.all(color: SharkyTokensV1.slate500.withOpacity(0.45)),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildLegacyPromptCapsuleV1(promptText: promptText)],
        ),
      ),
    );
  }

  RunnerCompletionSurfaceContractV1 _buildLegacyContinuationContractV1({
    required String primaryLabel,
    String? secondaryLabel,
  }) {
    return RunnerCompletionSurfaceContractV1(
      statusHeader: '',
      bodyText: '',
      primaryCtaLabel: primaryLabel,
      secondaryCtaLabel: secondaryLabel,
    );
  }

  Widget _buildLegacyCompletionActionStackV1({
    required Key surfaceKey,
    required RunnerCompletionSurfaceContractV1 contract,
    required VoidCallback onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
  }) {
    return RunnerBottomActionStackV1(
      surfaceKey: surfaceKey,
      spacing: AppSpacing.sm,
      primaryChild: SizedBox(
        height: 56,
        child: CampaignPrimaryCtaV1(
          controlKey: const Key('drill_runner_completion_primary_cta_v1'),
          onPressed: onPrimaryPressed,
          label: contract.primaryCtaLabel,
          microAnimationsEnabled: false,
          textStyle: AppTypography.h3.copyWith(
            fontWeight: FontWeight.w800,
            color: SharkyTokensV1.textPrimary,
          ),
        ),
      ),
      secondaryChild: contract.showsSecondaryCta && onSecondaryPressed != null
          ? SizedBox(
              height: 48,
              child: CampaignSecondaryCtaV1(
                controlKey: const Key(
                  'drill_runner_completion_secondary_cta_v1',
                ),
                onPressed: onSecondaryPressed,
                label: contract.secondaryCtaLabel!,
                microAnimationsEnabled: false,
                textStyle: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: SharkyTokensV1.textPrimary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLegacyPromptSupportContentV1({
    required BuildContext context,
    required Widget promptShell,
    required LegacyDrillRunnerItemV1 item,
    required RunnerHostPromptRevealPresentationResolvedV1 presentation,
    required bool showsPromptDetailsButton,
    required bool showsSourceMeta,
    required FactualRunnerHostContractV1? factualHostContractV1,
    required bool usesExpandedPromptShell,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (factualHostContractV1 != null)
          SizedBox.shrink(
            key: ValueKey<String>(
              'drill_runner_factual_family_${factualHostContractV1.family.name}',
            ),
          ),
        if (usesExpandedPromptShell)
          Expanded(flex: 3, child: promptShell)
        else
          promptShell,
        if (showsPromptDetailsButton || showsSourceMeta) ...[
          SizedBox(height: AppSpacing.md),
          _buildPromptSupportLaneV1(
            context,
            presentation: presentation,
            showsPromptDetailsButton: showsPromptDetailsButton,
            showsSourceMeta: showsSourceMeta,
            sourceMeta: item.sourceMeta,
          ),
        ],
      ],
    );
  }

  Widget _buildLegacyActionContentV1({
    required LegacyDrillRunnerItemV1 item,
    required bool showsActionZone,
    required DrillHostCapabilityContractV1 completionContractV1,
    required String explanation,
    required bool compactForTableFirst,
  }) {
    final revealCompletionPlanV1 =
        LegacyDrillCanonicalCompletionBridgeV1.resolveRevealCompletionPlan(
          isFinalItem: completionContractV1.showsCompletionContinuationSurface,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: compactForTableFirst ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (showsActionZone && item.isQuiz) ...[
          ..._buildQuizOptions(item),
        ] else if (showsActionZone) ...[
          if (!_isAnswerRevealed) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                backgroundColor: SharkyTokensV1.brandPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    SharkyTokensV1.radiusMd,
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  _progressionV1 =
                      LegacyDrillCanonicalProgressionBridgeV1.revealAnswer(
                        _progressionV1,
                      );
                });
              },
              child: const Text(
                'REVEAL ANSWER',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: SharkyTokensV1.surfaceElevated.withOpacity(0.9),
                border: Border.all(
                  color: SharkyTokensV1.slate500.withOpacity(0.72),
                ),
                borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
                boxShadow: SharkyTokensV1.elevation1,
              ),
              child: Text(
                explanation,
                style: AppTypography.body.copyWith(
                  color: SharkyTokensV1.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _buildLegacyCompletionActionStackV1(
              surfaceKey: const Key(
                'drill_runner_reveal_completion_action_stack_v1',
              ),
              contract: _buildLegacyContinuationContractV1(
                primaryLabel: revealCompletionPlanV1.primaryLabel,
                secondaryLabel: revealCompletionPlanV1.secondaryLabel,
              ),
              onPrimaryPressed: () {
                if (revealCompletionPlanV1.firesSuccessEffectsOnPrimary) {
                  UiSoundV1.fire(UiSoundEventV1.success);
                  unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
                  _triggerSuccessCue();
                }
                _advanceDrill(
                  countedAsCorrect:
                      revealCompletionPlanV1.primaryCountsAsCorrect,
                );
              },
              onSecondaryPressed: revealCompletionPlanV1.showsSecondaryAction
                  ? () => _advanceDrill(countedAsCorrect: false)
                  : null,
            ),
          ],
        ] else ...[
          const SizedBox.shrink(),
        ],
      ],
    );
  }

  Widget _buildTableFirstHostSurfaceV1({
    required _DrillRunnerTableFirstHostSurfaceContractV1 contract,
  }) {
    return KeyedSubtree(
      key: const Key('table_first_practice_shell'),
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
                      SharkyTokensV1.surfaceCard.withOpacity(0.62),
                      SharkyTokensV1.surfaceApp.withOpacity(0.92),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RunnerCompactHeaderBandV1(
                  key: const Key('table_first_step_header'),
                  statusText: contract.moduleId,
                  statusTextKey: const Key('table_first_step_header_status_v1'),
                  headlineText:
                      'Step ${contract.stepIndex} of ${contract.stepTotal}',
                  headlineTextKey: const Key(
                    'table_first_step_header_title_v1',
                  ),
                  compact: false,
                  surfaceColor: SharkyTokensV1.surfaceCard.withOpacity(0.82),
                  borderColor: SharkyTokensV1.slate600.withOpacity(0.75),
                  headlineColor: SharkyTokensV1.textPrimary,
                  statusColor: SharkyTokensV1.textSecondary,
                  bottomChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: contract.showSuccessCue ? 1.0 : 0.0,
                        child: Container(
                          key: const Key('microtask_success_badge'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: SharkyTokensV1.semanticWin.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(
                              SharkyTokensV1.radiusSm,
                            ),
                            border: Border.all(
                              color: SharkyTokensV1.semanticWin.withOpacity(
                                0.75,
                              ),
                            ),
                          ),
                          child: Text(
                            '+1 correct',
                            style: AppTypography.caption.copyWith(
                              color: SharkyTokensV1.semanticWin,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        key: const Key('table_first_practice_stepper'),
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (contract.stepIndex / contract.stepTotal)
                              .clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: SharkyTokensV1.slate600.withOpacity(
                            0.45,
                          ),
                          color: SharkyTokensV1.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Container(
                    key: const Key('table_first_overlay_card'),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: SharkyTokensV1.surfaceCard.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(
                        SharkyTokensV1.radiusMd,
                      ),
                      border: Border.all(
                        color: SharkyTokensV1.slate500.withOpacity(0.45),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: contract.promptSupportContent),
                        const SizedBox(height: AppSpacing.md),
                        contract.actionContent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: _buildDrillLoadingSurfaceV1()),
      );
    }

    if (_items.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: SharkyTokensV1.surfaceCard.withOpacity(0.76),
              borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
              border: Border.all(
                color: SharkyTokensV1.slate500.withOpacity(0.45),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'No drills found.',
              style: AppTypography.body.copyWith(
                color: SharkyTokensV1.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    final rawItem = _items[_currentIndex];
    final item = normalizeLegacyDrillRunnerItemV1(rawItem);
    final explanation = item.explanation;
    final hostContractV1 = _legacyItemHostContractV1(
      item: item,
      isCompleted: false,
    );
    final promptRevealPresentationV1 =
        resolveRunnerHostPromptRevealPresentationV1(
          RunnerHostPromptRevealPresentationInputV1(
            sourceId: hostContractV1.promptSourceId,
            canonicalPrompt: item.prompt,
            shortPromptOverride: item.prompt,
            detailsPromptOverride: item.detailsPrompt,
          ),
        );
    final factualHostContractV1 = _legacyFactualHostContractV1(
      item: item,
      presentation: promptRevealPresentationV1,
      sections: hostContractV1.sections,
    );
    final presentationV1 =
        factualHostContractV1?.promptReveal ?? promptRevealPresentationV1;
    final question = presentationV1.shortPrompt;
    final completionContractV1 = _legacyItemHostContractV1(
      item: item,
      isCompleted: _currentIndex >= _items.length - 1 && _isAnswerRevealed,
    );
    final stepIndex = _currentIndex + 1;
    final stepTotal = _items.length == 0 ? 1 : _items.length;
    final showInlineProgress = !hostContractV1.showsEmbeddedScenarioTable;
    final promptHeaderStatusV1 = showInlineProgress
        ? _legacyPromptHeaderStatusV1(currentIndex: stepIndex, total: stepTotal)
        : null;
    final showsPromptDetailsButton =
        hostContractV1.hasCapability(
          DrillHostCapabilityV1.promptDetailsReveal,
        ) &&
        presentationV1.canReveal &&
        presentationV1.detailsPrompt != presentationV1.shortPrompt;
    final showsSourceMeta =
        (factualHostContractV1?.showsSourceMeta ??
            hostContractV1.hasCapability(
              DrillHostCapabilityV1.sourceMetaSection,
            )) &&
        item.sourceMeta.hasEntries;
    final promptShellV1 = hostContractV1.showsEmbeddedScenarioTable
        ? _buildLegacyPromptCapsuleV1(promptText: question)
        : _buildLegacyPromptShellV1(
            promptKey: ValueKey<String>(
              'drill_runner_prompt_${hostContractV1.promptSourceId}',
            ),
            promptText: question,
            useCanonicalHeaderBand: true,
            statusText: promptHeaderStatusV1,
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Practice Drill',
          style: AppTypography.h3.copyWith(color: SharkyTokensV1.textPrimary),
        ),
        backgroundColor: SharkyTokensV1.surfaceCard,
        foregroundColor: SharkyTokensV1.textPrimary,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          final bottomInset =
              AppSpacing.lg + MediaQuery.of(context).viewPadding.bottom;
          final promptSupportContentV1 = _buildLegacyPromptSupportContentV1(
            context: context,
            promptShell: promptShellV1,
            item: item,
            presentation: presentationV1,
            showsPromptDetailsButton: showsPromptDetailsButton,
            showsSourceMeta: showsSourceMeta,
            factualHostContractV1: factualHostContractV1,
            usesExpandedPromptShell: true,
          );
          final drillPromptSupportContentV1 =
              _buildLegacyPromptSupportContentV1(
                context: context,
                promptShell: promptShellV1,
                item: item,
                presentation: presentationV1,
                showsPromptDetailsButton: showsPromptDetailsButton,
                showsSourceMeta: showsSourceMeta,
                factualHostContractV1: factualHostContractV1,
                usesExpandedPromptShell: false,
              );
          final actionContentV1 = _buildLegacyActionContentV1(
            item: item,
            showsActionZone: hostContractV1.showsActionZone,
            completionContractV1: completionContractV1,
            explanation: explanation,
            compactForTableFirst: false,
          );
          final drillContent = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hostContractV1.showsEmbeddedScenarioTable) ...[
                _buildInlineProgressSurfaceV1(
                  stepIndex: stepIndex,
                  stepTotal: stepTotal,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Expanded(flex: 3, child: drillPromptSupportContentV1),
              const SizedBox(height: AppSpacing.md),
              actionContentV1,
            ],
          );

          final tableFirstHostSurfaceV1 =
              _DrillRunnerTableFirstHostSurfaceContractV1(
                moduleId: widget.moduleId,
                stepIndex: stepIndex,
                stepTotal: stepTotal,
                showSuccessCue: _successCueActive,
                promptSupportContent: promptSupportContentV1,
                actionContent: _buildLegacyActionContentV1(
                  item: item,
                  showsActionZone: hostContractV1.showsActionZone,
                  completionContractV1: completionContractV1,
                  explanation: explanation,
                  compactForTableFirst: true,
                ),
              );

          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              bottomInset,
            ),
            child: hostContractV1.showsEmbeddedScenarioTable
                ? _buildTableFirstHostSurfaceV1(
                    contract: tableFirstHostSurfaceV1,
                  )
                : drillContent,
          );
        },
      ),
    );
  }

  List<Widget> _buildQuizOptions(LegacyDrillRunnerItemV1 item) {
    final options = item.options!;
    final correctIndex = item.correctOptionIndex!;

    return [
      Column(
        children: List.generate(options.length, (index) {
          final isSelected = _selectedQuizIndex == index;
          final isDisabled = _quizLocked && !isSelected;
          final isCorrect = _quizLocked && _correctQuizIndex == index;
          final isIncorrect =
              _quizLocked && isSelected && _selectedQuizCorrect == false;
          final stateLabel = isCorrect
              ? 'correct'
              : (isIncorrect
                    ? 'incorrect'
                    : (isDisabled
                          ? 'disabled'
                          : (isSelected ? 'selected' : 'default')));
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Semantics(
              label: 'Drill option ${index + 1}',
              value: stateLabel,
              hint: isDisabled ? 'disabled' : 'double tap to select',
              button: true,
              enabled: !isDisabled,
              child: ElevatedButton(
                key: ValueKey<String>('drill_option_$index'),
                style: _optionStyle(
                  isSelected: isSelected,
                  isDisabled: isDisabled,
                  isCorrect: isCorrect,
                  isIncorrect: isIncorrect,
                ),
                onPressed: isDisabled
                    ? null
                    : () {
                        UiSoundV1.fire(UiSoundEventV1.tap);
                        _showQuizResult(
                          item: item,
                          isCorrect: index == correctIndex,
                          selectedIndex: index,
                          correctIndex: correctIndex,
                        );
                      },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    options[index],
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _optionTextColor(
                        isSelected: isSelected,
                        isDisabled: isDisabled,
                        isCorrect: isCorrect,
                        isIncorrect: isIncorrect,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ];
  }

  ButtonStyle _optionStyle({
    required bool isSelected,
    required bool isDisabled,
    required bool isCorrect,
    required bool isIncorrect,
  }) {
    final baseColor = SharkyTokensV1.surfaceCard.withOpacity(0.82);
    final selectedColor = SharkyTokensV1.brandPrimary.withOpacity(0.24);
    final correctColor = SharkyTokensV1.semanticWin.withOpacity(0.24);
    final incorrectColor = SharkyTokensV1.semanticLoss.withOpacity(0.22);
    final disabledColor = SharkyTokensV1.surfaceElevated.withOpacity(0.6);
    final borderColor = isCorrect
        ? SharkyTokensV1.semanticWin
        : (isIncorrect
              ? SharkyTokensV1.semanticLoss
              : (isSelected
                    ? SharkyTokensV1.brandPrimary
                    : SharkyTokensV1.slate600));
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(const Size(0, 52)),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(vertical: 16),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        ),
      ),
      side: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return BorderSide(color: borderColor, width: 1.8);
        }
        return BorderSide(color: borderColor, width: 1.4);
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.white.withOpacity(0.08);
        }
        if (states.contains(MaterialState.hovered)) {
          return Colors.white.withOpacity(0.04);
        }
        return null;
      }),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (isDisabled) return disabledColor;
        if (isCorrect) return correctColor;
        if (isIncorrect) return incorrectColor;
        if (isSelected) return selectedColor;
        if (states.contains(MaterialState.pressed)) {
          return SharkyTokensV1.surfaceElevated.withOpacity(0.92);
        }
        return baseColor;
      }),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      elevation: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) return 0;
        return 0;
      }),
    );
  }

  Color _optionTextColor({
    required bool isSelected,
    required bool isDisabled,
    required bool isCorrect,
    required bool isIncorrect,
  }) {
    if (isDisabled) return SharkyTokensV1.textMuted;
    if (isCorrect) return SharkyTokensV1.semanticWin;
    if (isIncorrect) return SharkyTokensV1.semanticLoss;
    if (isSelected) return SharkyTokensV1.textPrimary;
    return SharkyTokensV1.textPrimary;
  }

  Widget _buildDrillLoadingSurfaceV1() {
    return Container(
      key: const Key('drill_runner_loading_surface_v1'),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.82),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.58)),
        boxShadow: SharkyTokensV1.elevation2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preparing drill flow',
            style: AppTypography.h3.copyWith(
              color: SharkyTokensV1.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Loading the next prompt, options, and explanation surface.',
            style: AppTypography.body.copyWith(
              color: SharkyTokensV1.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(SharkyTokensV1.radiusFull),
            child: LinearProgressIndicator(
              minHeight: 6,
              backgroundColor: SharkyTokensV1.slate600.withOpacity(0.45),
              color: SharkyTokensV1.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineProgressSurfaceV1({
    required int stepIndex,
    required int stepTotal,
  }) {
    return Container(
      key: const Key('drill_runner_inline_progress_surface_v1'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.78),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step $stepIndex of $stepTotal',
            style: AppTypography.h3.copyWith(
              color: SharkyTokensV1.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(SharkyTokensV1.radiusFull),
            child: LinearProgressIndicator(
              key: const Key('drill_runner_inline_progress_bar_v1'),
              value: (stepIndex / stepTotal).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: SharkyTokensV1.slate600.withOpacity(0.45),
              color: SharkyTokensV1.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrillRunnerTableFirstHostSurfaceContractV1 {
  const _DrillRunnerTableFirstHostSurfaceContractV1({
    required this.moduleId,
    required this.stepIndex,
    required this.stepTotal,
    required this.showSuccessCue,
    required this.promptSupportContent,
    required this.actionContent,
  });

  final String moduleId;
  final int stepIndex;
  final int stepTotal;
  final bool showSuccessCue;
  final Widget promptSupportContent;
  final Widget actionContent;
}
