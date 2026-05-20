import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/engine_v2/decision/decision_bar_v1.dart';
import 'package:poker_analyzer/personalization/learner_journey_cta_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_truth_invariant_spine_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_truth_reconciliation_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/runner/drill_host_capability_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/factual_runner_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_bottom_action_stack_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_completion_surface_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_reveal_payload_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_source_meta_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_action_surface_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_canonical_consumer_path_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_control_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_continuation_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_feedback_explanation_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_family_extras_slots_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_local_policy_boundary_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_grammar_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/shared_embedded_table_visual_family_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_header_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_prompt_details_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_prompt_reveal_launcher_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_route_completion_boundary_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_prompt_reveal_sheet_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_section_stack_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_support_outcome_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_table_adjacent_frame_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_top_level_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_boundary_signal_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_board_texture_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_corrective_feedback_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_factual_supplement_fallback_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_hand_chain_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_outs_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_seat_context_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_spatial_scenario_state_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_source_meta_entries_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_surface_family_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_supplemental_assembly_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_top_section_content_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_spatial_projection_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_world9_seat_id_projection_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/surfaced_learner_host_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_action_area_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_shell_controller_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_state_entry_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_adapter_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/campaign_ui_kit_v1.dart';
import 'package:poker_analyzer/theme/app_colors.dart';

class CanonicalTerminalSessionDrillSurfacedRunnerV1 extends StatefulWidget {
  const CanonicalTerminalSessionDrillSurfacedRunnerV1({
    super.key,
    required this.sessionId,
    this.debugDrillsOverrideV1,
    this.handoffContextV1,
    this.world1ModuleTitleV1,
    this.world1ModeV1,
    this.world1StartHandIndexV1 = 0,
    this.world1CheckpointIdV1,
    this.world1HintsEnabledV1 = true,
    this.world1InstructionSourceV1,
  });

  final String sessionId;
  final List<SessionDrillItemV1>? debugDrillsOverrideV1;
  final ProgressionHandoffContextV1? handoffContextV1;
  final String? world1ModuleTitleV1;
  final String? world1ModeV1;
  final int world1StartHandIndexV1;
  final int? world1CheckpointIdV1;
  final bool world1HintsEnabledV1;
  final RunnerInstructionSourceV1? world1InstructionSourceV1;

  static Route<void> route({
    required String sessionId,
    ProgressionHandoffContextV1? handoffContextV1,
    String? world1ModuleTitleV1,
    String? world1ModeV1,
    int world1StartHandIndexV1 = 0,
    int? world1CheckpointIdV1,
    bool world1HintsEnabledV1 = true,
    RunnerInstructionSourceV1? world1InstructionSourceV1,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => CanonicalLauncherV1.sessionDrill(
        sessionId: sessionId,
        handoffContextV1: handoffContextV1,
        world1ModuleTitleV1: world1ModuleTitleV1,
        world1ModeV1: world1ModeV1,
        world1StartHandIndexV1: world1StartHandIndexV1,
        world1CheckpointIdV1: world1CheckpointIdV1,
        world1HintsEnabledV1: world1HintsEnabledV1,
        world1InstructionSourceV1: world1InstructionSourceV1,
      ),
    );
  }

  @override
  State<CanonicalTerminalSessionDrillSurfacedRunnerV1> createState() =>
      _CanonicalTerminalSessionDrillSurfacedRunnerV1State();
}

class _CanonicalTerminalSessionDrillSurfacedRunnerV1State
    extends State<CanonicalTerminalSessionDrillSurfacedRunnerV1> {
  static const Set<String> _kWorld2SingleStepScenarioSessionIdsV1 = <String>{
    'w2.s01',
    'w2.s02',
    'w2.s03',
    'w2.s04',
    'w2.s06',
  };
  static const Set<String> _kWorld2HandChainScenarioSessionIdsV1 = <String>{
    'w2.s07',
    'w2.s08',
    'w2.s09',
    'w2.s10',
    'w2.s11',
    'w2.s12',
    'w2.s13',
    'w2.s14',
  };
  static const Set<String> _kWorld3EarlyHandChainScenarioSessionIdsV1 =
      <String>{
        'w3.s01',
        'w3.s02',
        'w3.s03',
        'w3.s04',
        'w3.s05',
        'w3.s06',
        'w3.s07',
        'w3.s08',
        'w3.s09',
        'w3.s10',
      };
  static const Set<String> _kEmbeddedHandChainScenarioSessionIdsV1 = <String>{
    ..._kWorld2HandChainScenarioSessionIdsV1,
    ..._kWorld3EarlyHandChainScenarioSessionIdsV1,
    'w3.s11',
    'w3.s12',
    'w3.s13',
    'w3.s14',
  };
  static const Set<String> _kWorld5TurnTextureSessionIdsV1 = <String>{'w5.s04'};
  static const Set<String> _kWorld5RiverTextureSessionIdsV1 = <String>{
    'w5.s05',
    'w5.s08',
  };
  static const Set<String> _kSpatialProjectionPilotSessionIdsV1 = <String>{
    'w4.s01',
    'w4.s02',
    'w4.s03',
    'w4.s04',
    'w4.s05',
    'w4.s06',
    'w4.s07',
    'w4.s08',
    'w4.s09',
    'w4.s10',
    'w6.s01',
    'w6.s02',
    'w6.s03',
    'w6.s04',
    'w6.s05',
    'w6.s06',
    'w6.s07',
    'w6.s08',
    'w6.s09',
    'w6.s10',
    'w7.s01',
    'w7.s02',
    'w7.s03',
    'w7.s04',
    'w7.s05',
    'w7.s06',
    'w7.s07',
    'w7.s08',
    'w7.s09',
    'w7.s10',
    'w8.s01',
    'w8.s02',
    'w8.s03',
    'w8.s04',
    'w8.s05',
    'w8.s06',
    'w8.s07',
    'w8.s08',
    'w8.s09',
    'w8.s10',
    'w9.s01',
    'w9.s02',
    'w9.s03',
    'w9.s04',
    'w9.s05',
    'w9.s06',
    'w9.s07',
    'w9.s08',
    'w9.s09',
    'w9.s10',
    'cash.s01',
    'cash.s02',
    'cash.s03',
    'cash.s04',
    'cash.s05',
    'cash.s06',
    'cash.s07',
    'cash.s08',
    'cash.s09',
    'cash.s10',
    'tournament.s01',
    'tournament.s02',
    'tournament.s03',
    'tournament.s04',
    'tournament.s05',
    'tournament.s06',
    'tournament.s07',
    'tournament.s08',
    'tournament.s09',
    'tournament.s10',
    'mixed.s01',
    'mixed.s02',
    'mixed.s03',
    'mixed.s04',
    'mixed.s05',
    'mixed.s06',
    'mixed.s07',
    'mixed.s08',
    'mixed.s09',
    'mixed.s10',
  };

  final _adapter = const DrillRuntimeAdapterV1();
  final _evaluator = const DrillEvaluatorV1();

  List<SessionDrillItemV1> _drills = const [];
  bool _loading = true;
  String? _loadError;
  int _currentIndex = 0;
  int _currentChainStepIndexV1 = 0;
  bool? _lastPass;
  String? _lastErrorClass;
  String? _lastFailureDetail;
  String? _lastChosenActionIdV1;
  DrillUserEventV1? _lastChosenEventV1;
  String? _lastSoftPassInfo;
  String? _lastSoftPassDetailV1;
  bool _completed = false;
  bool _completionSignaled = false;
  CanonicalTerminalWorld1RuntimeConfigV1? _world1RuntimeConfigV1;
  World1CanonicalResolvedHostLaunchV1? _world1ResolvedHostLaunchV1;
  World1CanonicalHostShellControllerV1? _world1HostShellControllerV1;

  SessionDrillItemV1? get _currentDrill =>
      _drills.isEmpty ? null : _drills[_currentIndex];

  bool get _usesWorld1AdapterLaunchV1 =>
      hasWorld1MicroTaskPack(widget.sessionId);

  static const List<MicroTaskStep> _world1FallbackStepsV1 = <MicroTaskStep>[
    MicroTaskStep(
      prompt: 'Find the Button seat.',
      hint: 'Dealer button is bottom center.',
      expectedSeatIds: <String>['btn'],
    ),
    MicroTaskStep(
      prompt: 'Find the Big Blind seat.',
      hint: 'Tap the right-lower blind seat.',
      expectedSeatIds: <String>['bb'],
    ),
    MicroTaskStep(
      prompt: 'Skip empty seats and tap Hijack.',
      hint: 'Ignore empty UTG and continue to Hijack.',
      expectedSeatIds: <String>['hj'],
    ),
  ];

  DrillScenarioHandChainStepContextV1?
  get _currentFactualHandChainStepContextV1 {
    final drill = _currentDrill;
    final chainContext = drill?.spec.scenarioFactualHandChainContextV1;
    if (chainContext == null) return null;
    return chainContext.stepAtIndexV1(_currentChainStepIndexV1);
  }

  SessionDrillCanonicalHandChainScenarioStateV1?
  get _currentResolvedHandChainScenarioStateV1 =>
      resolveSessionDrillCanonicalHandChainScenarioStateV1(
        authoredStepV1: _currentChainStepV1,
        factualStepV1: _currentFactualHandChainStepContextV1,
      );

  SessionDrillCanonicalBoardTextureScenarioStateV1?
  get _currentResolvedTextureScenarioStateV1 {
    final current = _currentDrill;
    if (current == null) {
      return null;
    }
    return resolveSessionDrillCanonicalBoardTextureScenarioStateV1(
      sessionId: widget.sessionId,
      spec: current.spec,
    );
  }

  SessionDrillCanonicalOutsScenarioStateV1?
  get _currentResolvedOutsScenarioStateV1 {
    final current = _currentDrill;
    if (current == null) {
      return null;
    }
    return resolveSessionDrillCanonicalOutsScenarioStateV1(current.spec);
  }

  SessionDrillCanonicalSeatContextScenarioStateV1?
  get _currentResolvedSeatContextScenarioStateV1 {
    final current = _currentDrill;
    if (current == null) {
      return null;
    }
    return resolveSessionDrillCanonicalSeatContextScenarioStateV1(current.spec);
  }

  SessionDrillCanonicalSpatialScenarioStateV1?
  get _currentResolvedSpatialScenarioStateV1 {
    final current = _currentDrill;
    if (current == null || !_isSpatialProjectionPilotDrillV1(current.spec)) {
      return null;
    }
    return resolveSessionDrillCanonicalSpatialScenarioStateV1(current.spec);
  }

  List<String>? get _currentFactualHandChainActionIdsV1 =>
      _currentResolvedHandChainScenarioStateV1?.coreV1.availableActionsV1;

  String? get _currentFactualHandChainPromptV1 =>
      _currentResolvedHandChainScenarioStateV1?.promptV1;

  String? get _currentFactualHandChainWhyV1 =>
      _currentResolvedHandChainScenarioStateV1?.whyV1;

  String? get _currentFactualHandChainFeedbackCorrectV1 =>
      _currentResolvedHandChainScenarioStateV1?.coreV1.feedbackCorrectV1;

  String? get _currentFactualHandChainFeedbackIncorrectV1 =>
      _currentResolvedHandChainScenarioStateV1?.coreV1.feedbackIncorrectV1;

  DrillChainStepV1? get _currentChainStepV1 {
    final drill = _currentDrill;
    if (drill == null || drill.spec.kind != DrillKindV1.handChain) return null;
    final steps = drill.spec.chainStepsV1;
    if (steps == null || steps.isEmpty) return null;
    if (_currentChainStepIndexV1 < 0 ||
        _currentChainStepIndexV1 >= steps.length) {
      return null;
    }
    return steps[_currentChainStepIndexV1];
  }

  @override
  void initState() {
    super.initState();
    if (_usesWorld1AdapterLaunchV1) {
      _primeWorld1InlineLaunchV1();
      _loading = false;
      _loadError = null;
      return;
    }
    final override = widget.debugDrillsOverrideV1;
    if (override != null) {
      _drills = override;
      _loading = false;
      _loadError = null;
      return;
    }
    _load();
  }

  void _primeWorld1InlineLaunchV1() {
    final runtimeConfigV1 = resolveCanonicalTerminalWorld1RuntimeConfigV1(
      CanonicalTerminalWorld1RuntimeConfigInputV1(
        moduleId: widget.sessionId,
        moduleTitleV1: widget.world1ModuleTitleV1,
        modeV1: widget.world1ModeV1,
        startHandIndexV1: widget.world1StartHandIndexV1,
        checkpointIdV1: widget.world1CheckpointIdV1,
        hintsEnabledV1: widget.world1HintsEnabledV1,
        instructionSourceV1: widget.world1InstructionSourceV1,
      ),
    );
    final resolvedHostLaunchV1 = resolveWorld1CanonicalResolvedHostLaunchV1(
      entryInput: World1CanonicalHostStateEntryInputV1(
        moduleId: widget.sessionId,
        explicitMode: runtimeConfigV1.modeV1,
        isCheckpoint: runtimeConfigV1.checkpointIdV1 != null,
        isDailyRun: runtimeConfigV1.modeV1 == kWorld1RunnerModeDailyRun,
        isTablePractice:
            runtimeConfigV1.modeV1 == kWorld1RunnerModeTablePractice,
        startHandIndex: runtimeConfigV1.startHandIndexV1,
        isGlobalCheckpointPack:
            widget.sessionId == ProgressService.checkpointPackIdV1,
        checkpointSteps: runtimeConfigV1.checkpointIdV1 == null
            ? const <MicroTaskStep>[]
            : kWorld1CheckpointTaskPacks[runtimeConfigV1.checkpointIdV1] ??
                  const <MicroTaskStep>[],
        packSteps: runtimeConfigV1.checkpointIdV1 == null
            ? world1MicroTaskPackFor(widget.sessionId)
            : const <MicroTaskStep>[],
        fallbackSteps: _world1FallbackStepsV1,
        campaignSpineModeId: kWorld1RunnerModeCampaignSpine,
        reviewQueueModeId: kWorld1RunnerModeReviewQueue,
        checkpointModeId: kWorld1RunnerModeCheckpoint,
        dailyRunModeId: kWorld1RunnerModeDailyRun,
        tablePracticeModeId: kWorld1RunnerModeTablePractice,
        defaultModeId: kWorld1RunnerModeFoundationsCheck,
      ),
      learningEffectSliceMarker: world1LearningEffectSliceMarkerV1(
        moduleId: widget.sessionId,
        mode: runtimeConfigV1.modeV1!,
      ),
    );
    final sessionIdentityV1 = resolveWorld1CanonicalHostSessionIdentityV1(
      widget.sessionId,
      checkpointId: runtimeConfigV1.checkpointIdV1,
      startHandIndex: runtimeConfigV1.startHandIndexV1,
    );
    _world1RuntimeConfigV1 = runtimeConfigV1;
    _world1ResolvedHostLaunchV1 = resolvedHostLaunchV1;
    _world1HostShellControllerV1 = World1CanonicalHostShellControllerV1(
      createCanonicalInitialLaunchBoundaryShellSignalV1(
        sessionIdentity: sessionIdentityV1,
      ),
    );
  }

  @override
  void dispose() {
    _world1HostShellControllerV1?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final drills = await _adapter.loadSessionDrills(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _drills = drills;
        _loading = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = '$e';
      });
    }
  }

  void _handleEvent(DrillUserEventV1 event) {
    if (_completed) return;
    final current = _currentDrill;
    if (current == null) return;
    final result = _evaluator.evaluate(current.spec, event);
    final softPassInfo = result.isSoftPass
        ? _buildSoftPassInfo(current.spec)
        : null;
    final softPassDetailV1 = result.isSoftPass
        ? (_sourceFeedbackAcceptableV1 ??
              _buildSoftPassDetailV1(
                current.spec,
                chosenActionId: event.actionId,
              ))
        : null;
    if (result.isPass &&
        current.spec.kind == DrillKindV1.handChain &&
        (current.spec.chainStepsV1?.isNotEmpty ?? false) &&
        _currentChainStepIndexV1 < current.spec.chainStepsV1!.length - 1) {
      setState(() {
        _currentChainStepIndexV1 += 1;
        _lastPass = null;
        _lastErrorClass = null;
        _lastFailureDetail = null;
        _lastChosenActionIdV1 = null;
        _lastChosenEventV1 = null;
        _lastSoftPassInfo = softPassInfo;
        _lastSoftPassDetailV1 = softPassDetailV1;
      });
      return;
    }
    if (result.isPass) {
      if (_currentIndex < _drills.length - 1) {
        setState(() {
          _currentIndex += 1;
          _currentChainStepIndexV1 = 0;
          _lastPass = null;
          _lastErrorClass = null;
          _lastFailureDetail = null;
          _lastChosenActionIdV1 = null;
          _lastChosenEventV1 = null;
          _lastSoftPassInfo = softPassInfo;
          _lastSoftPassDetailV1 = softPassDetailV1;
        });
      } else {
        setState(() {
          _completed = true;
          _lastPass = true;
          _lastErrorClass = null;
          _lastFailureDetail = null;
          _lastChosenActionIdV1 = null;
          _lastChosenEventV1 = null;
          _lastSoftPassInfo = softPassInfo;
          _lastSoftPassDetailV1 = softPassDetailV1;
        });
        if (!_completionSignaled) {
          _completionSignaled = true;
          unawaited(ProgressService.markModuleCompleted(widget.sessionId));
          unawaited(
            Telemetry.logEvent('session_drills_complete_v1', <String, dynamic>{
              'session_id': widget.sessionId,
              'drills_count': _drills.length,
            }),
          );
        }
      }
      return;
    }
    setState(() {
      _lastPass = false;
      _lastErrorClass = result.errorClass;
      _lastFailureDetail = _buildFailureDetail(current.spec, event);
      _lastChosenActionIdV1 = event.actionId;
      _lastChosenEventV1 = event;
      _lastSoftPassInfo = null;
      _lastSoftPassDetailV1 = null;
    });
  }

  void _resetCurrentResult() {
    setState(() {
      _lastPass = null;
      _lastErrorClass = null;
      _lastFailureDetail = null;
      _lastChosenActionIdV1 = null;
      _lastChosenEventV1 = null;
      _lastSoftPassInfo = null;
      _lastSoftPassDetailV1 = null;
    });
  }

  void _handleCompletionContinueV1() {
    Navigator.of(context).popUntil((route) {
      final routeName = route.settings.name;
      if (routeName == Navigator.defaultRouteName) {
        return true;
      }
      return route.isFirst;
    });
  }

  Future<void> _handleCompletionNextSessionV1(String nextSessionId) async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CanonicalTerminalSessionDrillSurfacedRunnerV1.route(
        sessionId: nextSessionId,
      ),
    );
  }

  Widget _buildCompletionContinuationSurfaceV1(BuildContext context) {
    final completionSurfaceContractV1 =
        _buildCompletionContinuationSurfaceContractV1();
    final localPolicyBoundaryV1 = _buildSessionDrillSharedLocalPolicyBoundaryV1(
      continuationState: SharedLearnerContinuationStateV1.visible(
        visualState: SharedLearnerContinuationVisualStateV1.completionLike,
        primaryLabel:
            completionSurfaceContractV1?.primaryCtaLabel ?? 'BACK TO MAP',
        secondaryLabel: completionSurfaceContractV1?.secondaryCtaLabel,
      ),
    );
    final routeCompletionBoundaryV1 =
        localPolicyBoundaryV1.routeCompletionBoundary;
    final continuationControlContractV1 =
        localPolicyBoundaryV1.continuationControlContract;
    if (!continuationControlContractV1.showsCompletionChrome) {
      return const SizedBox.shrink();
    }
    final current = _currentDrill;
    if (current == null) {
      return const SizedBox.shrink();
    }
    final nextSessionId = _progressionChromeContractV1(
      current.spec,
    ).nextSessionId;
    return Container(
      key: const Key('session_drill_player_completion_surface_v1'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withOpacity(0.86),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        border: Border.all(color: SharkyTokensV1.slate600.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            continuationControlContractV1.statusHeader!,
            key: const Key('session_drill_player_completion_status_header_v1'),
            textAlign: TextAlign.center,
            style: AppTypography.h3.copyWith(
              color: SharkyTokensV1.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            continuationControlContractV1.bodyText!,
            key: const Key('session_drill_player_completion_why_v1'),
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: SharkyTokensV1.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          RunnerBottomActionStackV1(
            surfaceKey: const Key(
              'session_drill_player_completion_action_stack_v1',
            ),
            spacing: AppSpacing.sm,
            primaryChild: SizedBox(
              height: 48,
              child: CampaignPrimaryCtaV1(
                controlKey:
                    routeCompletionBoundaryV1.primaryAction.category ==
                        SharedLearnerTerminalControlCategoryV1.nextSessionLike
                    ? const Key('session_drill_player_next_session_cta')
                    : const Key('session_drill_player_back_to_map_cta'),
                onPressed: routeCompletionBoundaryV1.primaryAction.onPressed,
                label: routeCompletionBoundaryV1.primaryAction.label,
                compact: true,
                textStyle: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w800,
                  color: SharkyTokensV1.textPrimary,
                  letterSpacing: 0.35,
                ),
              ),
            ),
            secondaryChild: routeCompletionBoundaryV1.showsSecondaryAction
                ? SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      key: const Key('session_drill_player_back_to_map_cta'),
                      onPressed:
                          routeCompletionBoundaryV1.secondaryAction.onPressed,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: SharkyTokensV1.slate600.withOpacity(0.9),
                        ),
                        foregroundColor: SharkyTokensV1.textPrimary,
                        backgroundColor: SharkyTokensV1.surfaceElevated
                            .withOpacity(0.82),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            SharkyTokensV1.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        routeCompletionBoundaryV1.secondaryAction.label,
                        style: AppTypography.label.copyWith(
                          fontWeight: FontWeight.w800,
                          color: SharkyTokensV1.textPrimary,
                          letterSpacing: 0.35,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  RunnerCompletionSurfaceContractV1?
  _buildCompletionContinuationSurfaceContractV1() {
    final current = _currentDrill;
    if (current == null) {
      return null;
    }
    final chromeV1 = _progressionChromeContractV1(current.spec);
    final nextSessionId = chromeV1.nextSessionId;
    return buildRunnerCompletionSurfaceContractV1(
      statusHeader: 'Session complete',
      bodyText: chromeV1.completionBodyText,
      hasPrimaryNext: nextSessionId != null,
      primaryNextLabel: learnerJourneyPrimaryNextLessonCtaLabelV1(),
    );
  }

  SessionDrillRunnerProgressionChromeContractV1 _progressionChromeContractV1(
    DrillSpecV1 spec,
  ) {
    final chainSteps = spec.kind == DrillKindV1.handChain
        ? (spec.chainStepsV1?.length ?? 0)
        : 0;
    return resolveSessionDrillRunnerProgressionChromeContractV1(
      SessionDrillRunnerProgressionChromeInputV1(
        sessionId: widget.sessionId,
        stepLabel: _surfaceSessionStepLabelV1(spec),
        currentDrillIndex: _currentIndex,
        totalDrills: _drills.length,
        drillId: _currentDrill?.drillId ?? '<missing>',
        currentChainStepIndex: _currentChainStepIndexV1,
        totalChainSteps: chainSteps,
        isWorld2SurfacedScenarioSession: _isWorld2SurfacedScenarioSessionV1,
      ),
    );
  }

  String _buildSoftPassInfo(DrillSpecV1 spec) {
    final chainWhy =
        _currentFactualHandChainWhyV1 ?? _currentChainStepV1?.whyV1;
    if (chainWhy != null && chainWhy.isNotEmpty) {
      return chainWhy;
    }
    final why = spec.whyV1;
    if (why == null || why.isEmpty) {
      return 'Reason: it gives up value or fold pressure for the price.';
    }
    return why;
  }

  String _buildSoftPassDetailV1(
    DrillSpecV1 spec, {
    required String? chosenActionId,
  }) {
    return buildSharedLearnerFeedbackExplanationV1(
      verdict: SharedLearnerFeedbackVerdictV1.softPass,
      comparisonStyle: _softPassComparisonStyleV1(spec),
      expectedLabel: _expectedFeedbackLabelV1(spec),
      chosenLabel: _chosenFeedbackLabelV1(spec, chosenActionId),
    ).headlineText;
  }

  SharedLearnerFeedbackComparisonStyleV1 _softPassComparisonStyleV1(
    DrillSpecV1 spec,
  ) {
    switch (spec.kind) {
      case DrillKindV1.positionThinkingChoice:
      case DrillKindV1.initiativeAggressorChoice:
      case DrillKindV1.outsCountChoice:
      case DrillKindV1.showdownWinnerChoice:
      case DrillKindV1.seatTap:
      case DrillKindV1.boardTap:
      case DrillKindV1.holeCardsTap:
        return SharedLearnerFeedbackComparisonStyleV1.correctAnswer;
      case DrillKindV1.betSizingChoice:
      case DrillKindV1.actionChoice:
      case DrillKindV1.boardTextureClassifier:
      case DrillKindV1.rangeBucketClassifier:
      case DrillKindV1.handChain:
        return SharedLearnerFeedbackComparisonStyleV1.strongerLine;
    }
  }

  String _expectedFeedbackLabelV1(DrillSpecV1 spec) {
    if (spec.kind == DrillKindV1.showdownWinnerChoice &&
        spec.expected.actionId != null) {
      return _showdownActionLabelV1(spec.expected.actionId!);
    }
    if (spec.kind == DrillKindV1.betSizingChoice &&
        spec.expected.presetId != null) {
      return _presetLabelV1(spec.expected.presetId!);
    }
    if (spec.kind == DrillKindV1.handChain) {
      final resolvedState = _currentResolvedHandChainScenarioStateV1;
      final step = _currentChainStepV1;
      final expectedPresetId =
          resolvedState?.expectedPresetIdV1 ?? step?.expectedPresetIdV1;
      if (expectedPresetId != null && expectedPresetId.isNotEmpty) {
        return _presetLabelV1(expectedPresetId);
      }
      final expectedActionId =
          resolvedState?.coreV1.expectedActionIdV1 ??
          step?.scenarioCoreV1.expectedActionIdV1;
      if (expectedActionId != null && expectedActionId.isNotEmpty) {
        return expectedActionId.replaceAll('_', ' ').toUpperCase();
      }
      final rangeBucket = step?.rangeBucketV1;
      if (rangeBucket != null && rangeBucket.isNotEmpty) {
        return rangeBucket.replaceAll('_', ' ').toUpperCase();
      }
    }
    return (spec.expected.actionId ??
            spec.expectedActionV1 ??
            'the stronger line')
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  String? _chosenFeedbackLabelV1(DrillSpecV1 spec, String? chosenActionId) {
    final normalized = chosenActionId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    if (spec.kind == DrillKindV1.showdownWinnerChoice) {
      return _showdownActionLabelV1(normalized);
    }
    if (spec.kind == DrillKindV1.betSizingChoice ||
        (spec.kind == DrillKindV1.handChain && normalized.contains('pot'))) {
      return _presetLabelV1(normalized);
    }
    return normalized.replaceAll('_', ' ').toUpperCase();
  }

  String? get _sourceFeedbackAcceptableV1 {
    final current = _currentDrill;
    if (current == null) return null;
    return current.spec.scenarioCoreV1.feedbackAcceptableV1;
  }

  bool get _isWorld2TextureScenarioPilotV1 {
    final current = _currentDrill;
    return widget.sessionId == 'w2.s04' &&
        current != null &&
        current.spec.kind == DrillKindV1.boardTextureClassifier;
  }

  bool get _isWorld2ShowdownScenarioPilotV1 {
    final current = _currentDrill;
    return widget.sessionId == 'w2.s01' &&
        current != null &&
        current.spec.kind == DrillKindV1.showdownWinnerChoice;
  }

  bool get _isIdleSurfacedShowdownV1 {
    final current = _currentDrill;
    return current != null &&
        _isWorld2ShowdownScenarioPilotV1 &&
        _lastPass == null &&
        !_completed;
  }

  bool get _isWorld2PositionScenarioPilotV1 {
    final current = _currentDrill;
    return widget.sessionId == 'w2.s02' &&
        current != null &&
        current.spec.kind == DrillKindV1.positionThinkingChoice;
  }

  bool get _isWorld2InitiativeScenarioPilotV1 {
    final current = _currentDrill;
    return widget.sessionId == 'w2.s03' &&
        current != null &&
        current.spec.kind == DrillKindV1.initiativeAggressorChoice;
  }

  bool get _isWorld2OutsScenarioPilotV1 {
    final current = _currentDrill;
    return widget.sessionId == 'w2.s06' &&
        current != null &&
        current.spec.kind == DrillKindV1.outsCountChoice;
  }

  bool get _isWorld2SingleStepScenarioPilotV1 {
    final current = _currentDrill;
    return current != null &&
        _kWorld2SingleStepScenarioSessionIdsV1.contains(widget.sessionId) &&
        current.spec.kind != DrillKindV1.handChain;
  }

  bool get _isEmbeddedHandChainScenarioPilotV1 {
    final current = _currentDrill;
    return current != null &&
        current.spec.kind == DrillKindV1.handChain &&
        _kEmbeddedHandChainScenarioSessionIdsV1.contains(widget.sessionId);
  }

  bool get _isWorld2SurfacedScenarioSessionV1 =>
      _isWorld2SingleStepScenarioPilotV1 ||
      (widget.sessionId.startsWith('w2.s') &&
          _isEmbeddedHandChainScenarioPilotV1);

  List<String> _resolvedSourceActionIdsV1(List<String> fallback) {
    final chainActions =
        _currentFactualHandChainActionIdsV1 ??
        _currentChainStepV1?.scenarioCoreV1.availableActionsV1;
    if (chainActions != null && chainActions.isNotEmpty) {
      return chainActions;
    }
    return _currentDrill?.spec.scenarioCoreV1.availableActionsV1 ?? fallback;
  }

  String? _resolvedSeatTapRoleForIndexV1(DrillSpecV1 spec, int seatIndex) {
    final adapterRole = _adapter.roleForSeat(widget.sessionId, seatIndex);
    if (adapterRole != null) {
      return adapterRole;
    }
    if (_isSpatialProjectionPilotDrillV1(spec)) {
      final reconciledTruth = _embeddedReconciledTableTruthV1(spec);
      final seatOrder = reconciledTruth?.seatOrderV1;
      if (seatOrder == null || seatIndex < 0 || seatIndex >= seatOrder.length) {
        return null;
      }
      return seatOrder[seatIndex];
    }
    if (spec.kind != DrillKindV1.seatTap ||
        !widget.sessionId.startsWith('w2.s')) {
      return null;
    }
    switch (seatIndex) {
      case 0:
        return 'btn';
      case 3:
        return 'bb';
      case 5:
        return 'sb';
      default:
        return null;
    }
  }

  void _assertScenarioActionFeedbackPayloadV1(
    String surfaceId,
    DrillSpecV1 spec, {
    bool requireStreet = true,
  }) {
    final core = spec.scenarioCoreV1;
    final availableActions = core.availableActionsV1;
    if (availableActions == null || availableActions.isEmpty) {
      throw StateError('$surfaceId requires available_actions_v1');
    }
    if (requireStreet && (core.streetV1 == null || core.streetV1!.isEmpty)) {
      throw StateError('$surfaceId requires street_v1');
    }
    if (core.feedbackCorrectV1 == null || core.feedbackIncorrectV1 == null) {
      throw StateError(
        '$surfaceId requires feedback_correct_v1 and feedback_incorrect_v1',
      );
    }
  }

  void _assertScenarioSeatContextPayloadV1(
    String surfaceId,
    DrillSpecV1 spec, {
    bool requireLastAggressor = false,
    bool requireInitiativeOwner = false,
  }) {
    if (spec.playerCountV1 == null) {
      throw StateError('$surfaceId requires player_count_v1');
    }
    if (spec.heroSeatV1 == null || spec.villainSeatV1 == null) {
      throw StateError('$surfaceId requires hero_seat_v1 and villain_seat_v1');
    }
    if (spec.activeSeatsV1 == null || spec.activeSeatsV1!.length < 2) {
      throw StateError(
        '$surfaceId requires active_seats_v1 with at least 2 seats',
      );
    }
    if (requireLastAggressor && spec.lastAggressorV1 == null) {
      throw StateError('$surfaceId requires last_aggressor_v1');
    }
    if (requireInitiativeOwner && spec.initiativeOwnerV1 == null) {
      throw StateError('$surfaceId requires initiative_owner_v1');
    }
  }

  void _assertHandChainScenarioSeatContextPayloadV1(
    String surfaceId,
    DrillChainStepV1 step, {
    bool requireLastAggressor = false,
    bool requireInitiativeOwner = false,
  }) {
    if (step.playerCountV1 == null) {
      throw StateError('$surfaceId requires player_count_v1');
    }
    if (step.heroSeatV1 == null || step.villainSeatV1 == null) {
      throw StateError('$surfaceId requires hero_seat_v1 and villain_seat_v1');
    }
    if (step.activeSeatsV1 == null || step.activeSeatsV1!.length < 2) {
      throw StateError(
        '$surfaceId requires active_seats_v1 with at least 2 seats',
      );
    }
    if (requireLastAggressor && step.lastAggressorV1 == null) {
      throw StateError('$surfaceId requires last_aggressor_v1');
    }
    if (requireInitiativeOwner && step.initiativeOwnerV1 == null) {
      throw StateError('$surfaceId requires initiative_owner_v1');
    }
  }

  bool get _isBoardOnlyHandChainSessionV1 => widget.sessionId == 'w2.s08';

  bool get _isFactualReusableHandChainLaneV1 =>
      widget.sessionId == 'w2.s07' || widget.sessionId == 'w2.s08';

  bool _stepRequiresBoardContextByIndexV1() {
    if (widget.sessionId == 'w2.s08') return true;
    if (widget.sessionId == 'w2.s10' ||
        widget.sessionId == 'w2.s12' ||
        widget.sessionId == 'w2.s13' ||
        widget.sessionId == 'w2.s14') {
      return _currentChainStepIndexV1 >= 2;
    }
    return _currentChainStepIndexV1 >= 1;
  }

  bool _handChainStepNeedsBoardContextV1() {
    return widget.sessionId == 'w2.s08' ||
        widget.sessionId == 'w2.s10' ||
        widget.sessionId == 'w2.s12' ||
        widget.sessionId == 'w2.s13' ||
        widget.sessionId == 'w2.s14';
  }

  bool _handChainStepRequiresInitiativeFieldsV1() {
    if (_kWorld3EarlyHandChainScenarioSessionIdsV1.contains(widget.sessionId) ||
        widget.sessionId == 'w3.s11' ||
        widget.sessionId == 'w3.s12' ||
        widget.sessionId == 'w3.s13' ||
        widget.sessionId == 'w3.s14') {
      return false;
    }
    if (widget.sessionId == 'w2.s09' ||
        widget.sessionId == 'w2.s10' ||
        widget.sessionId == 'w2.s12' ||
        widget.sessionId == 'w2.s13' ||
        widget.sessionId == 'w2.s14') {
      return _currentChainStepIndexV1 >= 1;
    }
    return _currentChainStepIndexV1 == 1;
  }

  void _assertWorld2HandChainScenarioPayloadV1(DrillSpecV1 spec) {
    if (!_isEmbeddedHandChainScenarioPilotV1 ||
        spec.kind != DrillKindV1.handChain) {
      return;
    }
    final step = _currentChainStepV1;
    if (step == null) {
      throw StateError(
        '${widget.sessionId} hand_chain_v1 requires a current step',
      );
    }
    final core = step.scenarioCoreV1;
    final availableActions = core.availableActionsV1;
    if (availableActions == null || availableActions.isEmpty) {
      throw StateError(
        '${widget.sessionId} hand_chain_v1 requires available_actions_v1',
      );
    }
    if (core.feedbackCorrectV1 == null || core.feedbackIncorrectV1 == null) {
      throw StateError(
        '${widget.sessionId} hand_chain_v1 requires feedback_correct_v1 and feedback_incorrect_v1',
      );
    }
    if (_handChainStepNeedsBoardContextV1()) {
      final boardContext = step.scenarioTableContextV1?.boardContextV1;
      final boardCards = boardContext?.boardCardsV1;
      final actionIds = core.availableActionsV1 ?? const <String>[];
      final needsBoardContext =
          _stepRequiresBoardContextByIndexV1() ||
          actionIds.any(
            (value) => const <String>{'call', 'raise'}.contains(value),
          );
      if (needsBoardContext && (boardCards == null || boardCards.length != 3)) {
        throw StateError(
          '${widget.sessionId} hand_chain_v1 requires exactly 3 board_cards_v1 when board context is authored',
        );
      }
      final isOutsStep = actionIds.any(
        (value) => const <String>{'4', '8', '9', '15'}.contains(value),
      );
      if (isOutsStep) {
        final heroHoleCards = boardContext?.heroHoleCardsV1;
        if (heroHoleCards == null || heroHoleCards.length != 2) {
          throw StateError(
            'w2.s08 hand_chain_v1 outs step requires exactly 2 hero_hole_cards_v1',
          );
        }
      }
    }
    if (_isBoardOnlyHandChainSessionV1) {
      return;
    }
    final seatContext = step.scenarioTableContextV1?.seatContextV1;
    if (seatContext == null) {
      throw StateError(
        '${widget.sessionId} hand_chain_v1 requires scenario seat context on each step',
      );
    }
    _assertHandChainScenarioSeatContextPayloadV1(
      '${widget.sessionId} hand_chain_v1',
      step,
      requireInitiativeOwner: _handChainStepRequiresInitiativeFieldsV1(),
      requireLastAggressor: _handChainStepRequiresInitiativeFieldsV1(),
    );
    final activeSeats = seatContext.activeSeatsV1;
    final foldedSeats = seatContext.foldedSeatsV1 ?? const <String>[];
    final emptySeats = seatContext.emptySeatsV1 ?? const <String>[];
    final allSeats = <String>{...activeSeats, ...foldedSeats, ...emptySeats};
    if (allSeats.length !=
        activeSeats.length + foldedSeats.length + emptySeats.length) {
      throw StateError(
        '${widget.sessionId} hand_chain_v1 requires active/folded/empty seat lists to be disjoint',
      );
    }
    final expectedSeatCount = allSeats.isEmpty
        ? activeSeats.length
        : allSeats.length;
    if (seatContext.playerCountV1 != expectedSeatCount) {
      throw StateError(
        '${widget.sessionId} hand_chain_v1 requires player_count_v1 to match authored seat-state count',
      );
    }
    if (!allSeats.contains(seatContext.heroSeatV1) ||
        !allSeats.contains(seatContext.villainSeatV1)) {
      throw StateError(
        '${widget.sessionId} hand_chain_v1 requires hero/villain seats to appear in authored seat-state',
      );
    }
    final followUp = step.scenarioActionFollowUpV1;
    if (followUp != null) {
      final boardCards = followUp.tableContextV1.boardContextV1?.boardCardsV1;
      if (boardCards == null || boardCards.length != 3) {
        throw StateError(
          '${widget.sessionId} hand_chain_v1 follow-up action step requires exactly 3 board_cards_v1',
        );
      }
    }
  }

  void _assertWorld2TextureScenarioPayloadV1(DrillSpecV1 spec) {
    if (!_isWorld2TextureScenarioPilotV1) return;
    _assertScenarioActionFeedbackPayloadV1(
      'w2.s04 board_texture_classifier_v1',
      spec,
    );
    final boardCards = spec.boardCardsV1;
    if (boardCards == null || boardCards.length != 3) {
      throw StateError(
        'w2.s04 board_texture_classifier_v1 requires exactly 3 board_cards_v1',
      );
    }
  }

  void _assertWorld2ShowdownScenarioPayloadV1(DrillSpecV1 spec) {
    if (!_isWorld2ShowdownScenarioPilotV1) return;
    _assertScenarioActionFeedbackPayloadV1(
      'w2.s01 showdown_winner_choice_v1',
      spec,
    );
    final boardCards = spec.boardCardsV1;
    if (boardCards == null || boardCards.length != 5) {
      throw StateError(
        'w2.s01 showdown_winner_choice_v1 requires exactly 5 board_cards_v1 cards',
      );
    }
    if (spec.heroHoleCardsV1 == null || spec.villainHoleCardsV1 == null) {
      throw StateError(
        'w2.s01 showdown_winner_choice_v1 requires hero_hole_cards_v1 and villain_hole_cards_v1',
      );
    }
  }

  void _assertWorld2PositionScenarioPayloadV1(DrillSpecV1 spec) {
    if (!_isWorld2PositionScenarioPilotV1) return;
    _assertScenarioActionFeedbackPayloadV1(
      'w2.s02 position_thinking_choice_v1',
      spec,
    );
    _assertScenarioSeatContextPayloadV1(
      'w2.s02 position_thinking_choice_v1',
      spec,
    );
    final playerCount = spec.playerCountV1;
    final activeSeats = spec.activeSeatsV1;
    final foldedSeats = spec.foldedSeatsV1 ?? const <String>[];
    final emptySeats = spec.emptySeatsV1 ?? const <String>[];
    final heroSeat = spec.heroSeatV1;
    final villainSeat = spec.villainSeatV1;
    if (playerCount == null || activeSeats == null) {
      throw StateError(
        'w2.s02 position_thinking_choice_v1 requires player_count_v1 and active_seats_v1',
      );
    }
    final allSeats = <String>{...activeSeats, ...foldedSeats, ...emptySeats};
    if (allSeats.length !=
        activeSeats.length + foldedSeats.length + emptySeats.length) {
      throw StateError(
        'w2.s02 position_thinking_choice_v1 requires active/folded/empty seat lists to be disjoint',
      );
    }
    final expectedSeatCount = allSeats.isEmpty
        ? activeSeats.length
        : allSeats.length;
    if (playerCount != expectedSeatCount) {
      throw StateError(
        'w2.s02 position_thinking_choice_v1 requires player_count_v1 to match authored seat-state count',
      );
    }
    if (heroSeat == null || !activeSeats.contains(heroSeat)) {
      throw StateError(
        'w2.s02 position_thinking_choice_v1 requires hero_seat_v1 to be in active_seats_v1',
      );
    }
    if (villainSeat == null || !activeSeats.contains(villainSeat)) {
      throw StateError(
        'w2.s02 position_thinking_choice_v1 requires villain_seat_v1 to be in active_seats_v1',
      );
    }
  }

  void _assertWorld2InitiativeScenarioPayloadV1(DrillSpecV1 spec) {
    if (!_isWorld2InitiativeScenarioPilotV1) return;
    _assertScenarioActionFeedbackPayloadV1(
      'w2.s03 initiative_aggressor_choice_v1',
      spec,
    );
    _assertScenarioSeatContextPayloadV1(
      'w2.s03 initiative_aggressor_choice_v1',
      spec,
      requireLastAggressor: true,
      requireInitiativeOwner: true,
    );
    final playerCount = spec.playerCountV1;
    final activeSeats = spec.activeSeatsV1;
    final heroSeat = spec.heroSeatV1;
    final villainSeat = spec.villainSeatV1;
    if (playerCount == null || activeSeats == null) {
      throw StateError(
        'w2.s03 initiative_aggressor_choice_v1 requires player_count_v1 and active_seats_v1',
      );
    }
    if (playerCount != activeSeats.length) {
      throw StateError(
        'w2.s03 initiative_aggressor_choice_v1 requires player_count_v1 to match active_seats_v1 length',
      );
    }
    if (heroSeat == null || !activeSeats.contains(heroSeat)) {
      throw StateError(
        'w2.s03 initiative_aggressor_choice_v1 requires hero_seat_v1 to be in active_seats_v1',
      );
    }
    if (villainSeat == null || !activeSeats.contains(villainSeat)) {
      throw StateError(
        'w2.s03 initiative_aggressor_choice_v1 requires villain_seat_v1 to be in active_seats_v1',
      );
    }
  }

  void _assertWorld2OutsScenarioPayloadV1(DrillSpecV1 spec) {
    if (!_isWorld2OutsScenarioPilotV1) return;
    _assertScenarioActionFeedbackPayloadV1('w2.s06 outs_count_choice_v1', spec);
    if (spec.heroHoleCardsV1 == null) {
      throw StateError(
        'w2.s06 outs_count_choice_v1 requires hero_hole_cards_v1',
      );
    }
    final boardCards = spec.boardCardsV1;
    if (boardCards == null || boardCards.length != 3) {
      throw StateError(
        'w2.s06 outs_count_choice_v1 requires exactly 3 board_cards_v1',
      );
    }
  }

  int _resolvedScenarioActingSeatIndexV1(DrillSpecV1 spec) {
    final activeSeats = spec.activeSeatsV1!;
    final expectedActionId = spec.scenarioCoreV1.expectedActionIdV1;
    if (expectedActionId == 'hero') {
      return activeSeats.indexOf(spec.heroSeatV1!);
    }
    if (expectedActionId == 'villain') {
      return activeSeats.indexOf(spec.villainSeatV1!);
    }
    return 0;
  }

  ScenarioSpecV1 _buildWorld2PositionScenarioSpecV1(DrillSpecV1 spec) {
    final resolvedSeatContext =
        resolveSessionDrillCanonicalSeatContextScenarioStateV1(spec)!;
    final reconciledTruth = _embeddedReconciledTableTruthV1(spec)!;
    return buildValidatedSessionDrillProjectedScenarioV1(
      errorPrefix: 'w2.s02 position_thinking_choice_v1',
      reconciledTruthV1: reconciledTruth,
      streetV1: Street.values.firstWhere(
        (value) => value.name == resolvedSeatContext.streetV1,
      ),
      legalActionsV1: resolvedSeatContext.availableActionsV1,
      solutionBestActionV1: resolvedSeatContext.expectedActionIdV1,
    );
  }

  SessionDrillReconciledTableTruthV1? _embeddedReconciledTableTruthV1(
    DrillSpecV1 spec,
  ) {
    if (_isSpatialProjectionPilotDrillV1(spec)) {
      final resolvedSpatialState =
          resolveSessionDrillCanonicalSpatialScenarioStateV1(spec);
      if (resolvedSpatialState?.playerCountV1 == null ||
          resolvedSpatialState?.heroSeatV1 == null ||
          resolvedSpatialState?.villainSeatV1 == null ||
          resolvedSpatialState?.activeSeatsV1 == null) {
        return null;
      }
      return reconcileSessionDrillTableTruthV1(
        errorPrefix: '${widget.sessionId} spatial projection',
        playerCountV1: resolvedSpatialState!.playerCountV1!,
        heroSeatV1: resolvedSpatialState.heroSeatV1!,
        villainSeatV1: resolvedSpatialState.villainSeatV1!,
        activeSeatsV1: resolvedSpatialState.activeSeatsV1!,
        foldedSeatsV1: resolvedSpatialState.foldedSeatsV1 ?? const <String>[],
        emptySeatsV1: resolvedSpatialState.emptySeatsV1 ?? const <String>[],
        actingSeatV1: resolvedSpatialState.heroSeatV1!,
        blindLevelV1: resolvedSpatialState.blindLevelV1,
        seatOrderPolicyV1:
            SessionDrillSeatOrderPolicyV1.activeFoldedEmptyAuthored,
      );
    }
    if (_isWorld2PositionScenarioPilotV1) {
      final resolvedSeatContext =
          resolveSessionDrillCanonicalSeatContextScenarioStateV1(spec);
      if (resolvedSeatContext == null) {
        return null;
      }
      return reconcileSessionDrillTableTruthV1(
        errorPrefix: 'w2.s02 position_thinking_choice_v1',
        playerCountV1: resolvedSeatContext.playerCountV1,
        heroSeatV1: resolvedSeatContext.heroSeatV1,
        villainSeatV1: resolvedSeatContext.villainSeatV1,
        activeSeatsV1: resolvedSeatContext.activeSeatsV1,
        foldedSeatsV1: resolvedSeatContext.foldedSeatsV1 ?? const <String>[],
        emptySeatsV1: resolvedSeatContext.emptySeatsV1 ?? const <String>[],
        actingSeatV1: resolvedSeatContext.actingSeatV1,
        blindLevelV1: resolvedSeatContext.blindLevelV1,
        seatOrderPolicyV1:
            SessionDrillSeatOrderPolicyV1.canonicalAuthoredArcOrder,
      );
    }
    if (_isWorld2InitiativeScenarioPilotV1) {
      final resolvedSeatContext =
          resolveSessionDrillCanonicalSeatContextScenarioStateV1(spec);
      if (resolvedSeatContext == null) {
        return null;
      }
      return reconcileSessionDrillTableTruthV1(
        errorPrefix: 'w2.s03 initiative_aggressor_choice_v1',
        playerCountV1: resolvedSeatContext.playerCountV1,
        heroSeatV1: resolvedSeatContext.heroSeatV1,
        villainSeatV1: resolvedSeatContext.villainSeatV1,
        activeSeatsV1: resolvedSeatContext.activeSeatsV1,
        actingSeatV1: resolvedSeatContext.actingSeatV1,
        blindLevelV1: resolvedSeatContext.blindLevelV1,
        seatOrderPolicyV1:
            SessionDrillSeatOrderPolicyV1.activeFoldedEmptyAuthored,
      );
    }
    if (_isEmbeddedHandChainScenarioPilotV1) {
      final step = _currentChainStepV1;
      if (step == null) {
        return null;
      }
      return _maybeReconciledHandChainTableTruthV1(step);
    }
    return null;
  }

  SessionDrillReconciledTableTruthV1? _maybeReconciledHandChainTableTruthV1(
    DrillChainStepV1 step,
  ) {
    final resolvedState = resolveSessionDrillCanonicalHandChainScenarioStateV1(
      authoredStepV1: step,
      factualStepV1: _currentFactualHandChainStepContextV1,
    );
    final tableContext = resolvedState?.tableContextV1;
    final seatContext = tableContext?.seatContextV1;
    if (seatContext == null) {
      return null;
    }
    final initiativeActor = seatContext.initiativeOwnerV1;
    final actingSeatIdV1 = initiativeActor == 'hero'
        ? seatContext.heroSeatV1
        : initiativeActor == 'villain'
        ? seatContext.villainSeatV1
        : resolvedState?.coreV1.expectedActionIdV1 == 'villain'
        ? seatContext.villainSeatV1
        : seatContext.heroSeatV1;
    return reconcileSessionDrillTableTruthV1(
      errorPrefix: '${widget.sessionId} hand_chain_v1',
      playerCountV1: seatContext.playerCountV1,
      heroSeatV1: seatContext.heroSeatV1,
      villainSeatV1: seatContext.villainSeatV1,
      activeSeatsV1: seatContext.activeSeatsV1,
      foldedSeatsV1: seatContext.foldedSeatsV1 ?? const <String>[],
      emptySeatsV1: seatContext.emptySeatsV1 ?? const <String>[],
      actingSeatV1: actingSeatIdV1,
      blindLevelV1: seatContext.blindLevelV1,
      seatOrderPolicyV1:
          SessionDrillSeatOrderPolicyV1.canonicalAuthoredArcOrder,
    );
  }

  SessionDrillReconciledTableTruthV1 _reconciledHandChainTableTruthV1(
    DrillChainStepV1 step,
  ) {
    final reconciledTruth = _maybeReconciledHandChainTableTruthV1(step);
    if (reconciledTruth != null) {
      return reconciledTruth;
    }
    throw StateError(
      '${widget.sessionId} hand_chain_v1 requires scenario seat context',
    );
  }

  ScenarioSpecV1 _buildWorld2InitiativeScenarioSpecV1(DrillSpecV1 spec) {
    final resolvedSeatContext =
        resolveSessionDrillCanonicalSeatContextScenarioStateV1(spec)!;
    final reconciledTruth = _embeddedReconciledTableTruthV1(spec)!;
    return buildValidatedSessionDrillProjectedScenarioV1(
      errorPrefix: 'w2.s03 initiative_aggressor_choice_v1',
      reconciledTruthV1: reconciledTruth,
      streetV1: Street.values.firstWhere(
        (value) => value.name == resolvedSeatContext.streetV1,
      ),
      legalActionsV1: resolvedSeatContext.availableActionsV1,
      solutionBestActionV1: resolvedSeatContext.expectedActionIdV1,
    );
  }

  ScenarioSpecV1 _buildWorld2TextureScenarioSpecV1(DrillSpecV1 spec) {
    final resolvedTextureState =
        resolveSessionDrillCanonicalBoardTextureScenarioStateV1(
          sessionId: widget.sessionId,
          spec: spec,
        );
    return ScenarioSpecV1(
      seatCount: 2,
      heroSeat: 0,
      initialStacks: const <int>[1000, 1000],
      actingSeatStart: 0,
      decisionNodeV1: DecisionNodeV1(
        street: Street.values.firstWhere(
          (value) =>
              value.name ==
              (resolvedTextureState?.streetV1 ?? spec.scenarioCoreV1.streetV1),
        ),
        legalActions:
            resolvedTextureState?.availableActionsV1 ??
            spec.scenarioCoreV1.availableActionsV1!,
        solutionBestAction:
            resolvedTextureState?.expectedActionIdV1 ??
            spec.scenarioCoreV1.expectedActionIdV1!,
      ),
    );
  }

  ScenarioSpecV1 _buildWorld2OutsScenarioSpecV1(DrillSpecV1 spec) {
    final resolvedOutsState = resolveSessionDrillCanonicalOutsScenarioStateV1(
      spec,
    )!;
    return ScenarioSpecV1(
      seatCount: 2,
      heroSeat: 0,
      initialStacks: const <int>[1000, 1000],
      actingSeatStart: 0,
      decisionNodeV1: DecisionNodeV1(
        street: Street.values.firstWhere(
          (value) => value.name == resolvedOutsState.streetV1,
        ),
        legalActions: resolvedOutsState.availableActionsV1!,
        solutionBestAction: resolvedOutsState.expectedActionIdV1!,
      ),
    );
  }

  bool _isWorld5BoardTextureScenarioV1(DrillSpecV1 spec) {
    return widget.sessionId.startsWith('w5.s') &&
        spec.kind == DrillKindV1.boardTextureClassifier;
  }

  ScenarioSpecV1 _buildWorld5BoardTextureScenarioSpecV1(DrillSpecV1 spec) {
    final resolvedTextureState =
        resolveSessionDrillCanonicalBoardTextureScenarioStateV1(
          sessionId: widget.sessionId,
          spec: spec,
        )!;
    return ScenarioSpecV1(
      seatCount: 2,
      heroSeat: 0,
      initialStacks: const <int>[1000, 1000],
      actingSeatStart: 0,
      decisionNodeV1: DecisionNodeV1(
        street: Street.values.firstWhere(
          (value) => value.name == resolvedTextureState.streetV1,
        ),
        legalActions: const <String>[],
        solutionBestAction: resolvedTextureState.expectedActionIdV1 ?? 'call',
      ),
    );
  }

  ScenarioSpecV1 _buildSpatialProjectionScenarioSpecV1(DrillSpecV1 spec) {
    final resolvedSpatialState =
        resolveSessionDrillCanonicalSpatialScenarioStateV1(spec);
    final reconciledTruth = _embeddedReconciledTableTruthV1(spec);
    final projectedStreetV1 =
        resolvedSpatialState?.projectedStreetV1 ??
        resolveSessionDrillProjectedStreetV1(
          expectedV1: spec.expected,
          boardCardsV1: spec.scenarioBoardContextV1?.boardCardsV1,
        );
    if (reconciledTruth != null) {
      return buildValidatedSessionDrillProjectedScenarioV1(
        errorPrefix: '${widget.sessionId} spatial projection',
        reconciledTruthV1: reconciledTruth,
        streetV1: projectedStreetV1,
        legalActionsV1: const <String>[],
        solutionBestActionV1: 'call',
      );
    }
    return ScenarioSpecV1(
      seatCount: 2,
      heroSeat: 0,
      initialStacks: const <int>[1000, 1000],
      actingSeatStart: 0,
      decisionNodeV1: DecisionNodeV1(
        street: projectedStreetV1,
        legalActions: const <String>[],
        solutionBestAction: 'call',
      ),
    );
  }

  ScenarioSpecV1 _buildWorld2HandChainScenarioSpecV1(DrillChainStepV1 step) {
    final resolvedState = resolveSessionDrillCanonicalHandChainScenarioStateV1(
      authoredStepV1: step,
      factualStepV1: _currentFactualHandChainStepContextV1,
    );
    final tableContext = resolvedState?.tableContextV1;
    final seatContext = tableContext?.seatContextV1;
    if (seatContext == null) {
      final boardContext = tableContext?.boardContextV1;
      if (widget.sessionId == 'w2.s08' && boardContext?.boardCardsV1 != null) {
        final core = resolvedState?.coreV1 ?? step.scenarioCoreV1;
        return ScenarioSpecV1(
          seatCount: 2,
          heroSeat: 0,
          initialStacks: const <int>[1000, 1000],
          actingSeatStart: 0,
          decisionNodeV1: DecisionNodeV1(
            street: Street.values.firstWhere(
              (value) => value.name == core.streetV1,
            ),
            legalActions: core.availableActionsV1!,
            solutionBestAction: core.expectedActionIdV1!,
          ),
        );
      }
      throw StateError(
        '${widget.sessionId} hand_chain_v1 requires scenario seat context',
      );
    }
    final reconciledTruth = _reconciledHandChainTableTruthV1(step);
    final resolvedCoreV1 = resolvedState!.coreV1;
    return buildValidatedSessionDrillProjectedScenarioV1(
      errorPrefix: '${widget.sessionId} hand_chain_v1',
      reconciledTruthV1: reconciledTruth,
      streetV1: Street.values.firstWhere(
        (value) => value.name == resolvedCoreV1.streetV1,
      ),
      legalActionsV1: resolvedCoreV1.availableActionsV1!,
      solutionBestActionV1: resolvedCoreV1.expectedActionIdV1!,
    );
  }

  Map<int, String>? _embeddedScenarioSeatRoleLabelsV1(DrillSpecV1 spec) {
    return _embeddedReconciledTableTruthV1(spec)?.roleLabelsV1();
  }

  Map<int, String>? _embeddedScenarioSeatMarkerLabelsV1(DrillSpecV1 spec) {
    final reconciledTruth = _embeddedReconciledTableTruthV1(spec);
    if (reconciledTruth == null) {
      return null;
    }
    return reconciledTruth.markerLabelsV1(
      includeSeatIdsV1: _isWorld9SeatIdProjectionPilotDrillV1(spec),
    );
  }

  String _buildFailureDetail(DrillSpecV1 spec, DrillUserEventV1 event) {
    switch (spec.kind) {
      case DrillKindV1.seatTap:
        final expected = spec.expected.role != null
            ? 'role=${spec.expected.role}'
            : 'seatId=${spec.expected.seatId ?? '?'}';
        final got = event.role != null
            ? 'role=${event.role}'
            : 'seatId=${event.seatId ?? '?'}';
        return 'expected $expected, got $got';
      case DrillKindV1.actionChoice:
        return 'expected actionId=${spec.expected.actionId ?? '?'}, got actionId=${event.actionId ?? '?'}';
      case DrillKindV1.betSizingChoice:
        return 'expected presetId=${spec.expected.presetId ?? '?'}, got presetId=${event.actionId ?? '?'}';
      case DrillKindV1.showdownWinnerChoice:
        return 'expected winner=${spec.expected.actionId ?? '?'}, got winner=${event.actionId ?? '?'}';
      case DrillKindV1.positionThinkingChoice:
        return 'expected actor=${spec.expected.actionId ?? '?'}, got actor=${event.actionId ?? '?'}';
      case DrillKindV1.initiativeAggressorChoice:
        return 'expected aggressor=${spec.expected.actionId ?? '?'}, got actor=${event.actionId ?? '?'}';
      case DrillKindV1.outsCountChoice:
        return 'expected outs=${spec.expected.actionId ?? '?'}, got outs=${event.actionId ?? '?'}';
      case DrillKindV1.boardTextureClassifier:
      case DrillKindV1.rangeBucketClassifier:
        return 'expected_action=${spec.expectedActionV1 ?? '?'}, got actionId=${event.actionId ?? '?'}';
      case DrillKindV1.handChain:
        final step = _currentChainStepV1;
        if (step == null) return 'hand_chain step unavailable';
        if (step.expectedActionV1 != null) {
          return 'expected_action=${step.expectedActionV1}, got actionId=${event.actionId ?? '?'}';
        }
        if (step.expectedPresetIdV1 != null) {
          return 'expected_preset_id=${step.expectedPresetIdV1}, got presetId=${event.actionId ?? '?'}';
        }
        return 'expected_range_bucket=${step.rangeBucketV1 ?? '?'}, got bucketId=${event.actionId ?? '?'}';
      case DrillKindV1.boardTap:
        return 'expected boardSlot=${spec.expected.boardSlot ?? '?'}, got boardSlot=${event.boardSlot ?? '?'}';
      case DrillKindV1.holeCardsTap:
        final expectedCardSlot = spec.expected.cardSlot ?? '?';
        final gotCardSlot = event.cardSlot ?? '?';
        if (spec.expected.cardId != null) {
          return 'expected cardSlot=$expectedCardSlot cardId=${spec.expected.cardId}, got cardSlot=$gotCardSlot cardId=${event.cardId ?? '?'}';
        }
        return 'expected cardSlot=$expectedCardSlot, got cardSlot=$gotCardSlot';
    }
  }

  String? get _sourceFeedbackCorrectV1 {
    final current = _currentDrill;
    if (current == null) return null;
    final chainValue =
        _currentFactualHandChainFeedbackCorrectV1 ??
        _currentChainStepV1?.scenarioCoreV1.feedbackCorrectV1;
    if (chainValue != null && chainValue.isNotEmpty) return chainValue;
    return current.spec.scenarioCoreV1.feedbackCorrectV1;
  }

  String? get _sourceFeedbackIncorrectV1 {
    final current = _currentDrill;
    if (current == null) return null;
    final chosenActionId = _lastChosenActionIdV1?.trim().toLowerCase();
    final actionSpecific = chosenActionId == null
        ? null
        : current
              .spec
              .scenarioCoreV1
              .feedbackIncorrectByActionV1?[chosenActionId];
    if (actionSpecific != null && actionSpecific.isNotEmpty) {
      return actionSpecific;
    }
    final chainValue =
        _currentFactualHandChainFeedbackIncorrectV1 ??
        _currentChainStepV1?.scenarioCoreV1.feedbackIncorrectV1;
    if (chainValue != null && chainValue.isNotEmpty) return chainValue;
    return current.spec.scenarioCoreV1.feedbackIncorrectV1;
  }

  SessionDrillCanonicalCorrectiveFeedbackV1?
  get _canonicalCorrectiveFeedbackV1 {
    final current = _currentDrill;
    if (current == null) return null;
    return resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: widget.sessionId,
      spec: current.spec,
      isFail: _lastPass == false,
      currentHandChainStepV1: _currentChainStepV1,
      currentHandChainWhyV1: _currentFactualHandChainWhyV1,
      chosenActionIdV1: _lastChosenActionIdV1,
      chosenEventV1: _lastChosenEventV1,
    );
  }

  bool get _showWhyV1OnFailV1 {
    if (_lastPass != false) return false;
    final current = _currentDrill;
    if (current == null) return false;
    return _currentFactualHandChainWhyV1 != null ||
        _currentChainStepV1?.whyV1 != null ||
        current.spec.whyV1 != null;
  }

  String? get _correctReinforcementV1 {
    if (_lastPass != true) return null;
    final current = _currentDrill;
    if (current == null) return null;
    final intent = current.spec.intentV1;
    if (intent == null || intent.isEmpty) return null;
    return 'Correct — reinforces $intent';
  }

  bool get _isBetSizingFamilySessionV1 {
    return widget.sessionId == 'w1.s01' ||
        widget.sessionId == 'w4.s01' ||
        widget.sessionId == 'w4.s02' ||
        widget.sessionId == 'w4.s03' ||
        widget.sessionId == 'w4.s04' ||
        widget.sessionId == 'w4.s05' ||
        widget.sessionId == 'w4.s06' ||
        widget.sessionId == 'w4.s07' ||
        widget.sessionId == 'w4.s08' ||
        widget.sessionId == 'w4.s09' ||
        widget.sessionId == 'w4.s10';
  }

  bool get _showBetSizingIntroCardV1 {
    final current = _currentDrill;
    if (_completed || current == null) return false;
    if (!_isBetSizingFamilySessionV1) return false;
    if (current.spec.kind != DrillKindV1.betSizingChoice) return false;
    if (_drills.isEmpty) return false;
    return current.drillId == _drills.first.drillId && _lastPass == null;
  }

  bool get _showWorld2ShowdownIntroCardV1 {
    final current = _currentDrill;
    if (_completed || current == null) return false;
    if (widget.sessionId != 'w2.s01') return false;
    if (current.spec.kind != DrillKindV1.showdownWinnerChoice) return false;
    return current.drillId == 'choose_hero_top_pair_showdown' &&
        _lastPass == null;
  }

  bool get _showWorld3PreflopBridgeIntroCardV1 {
    final current = _currentDrill;
    if (_completed || current == null) return false;
    if (widget.sessionId != 'w3.s01') return false;
    return current.drillId == _drills.first.drillId && _lastPass == null;
  }

  bool get _showBetSizingRecapCardV1 {
    if (!_completed || !_isBetSizingFamilySessionV1) return false;
    final betSizingDrills = _drills
        .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
        .length;
    return betSizingDrills >= 4;
  }

  bool get _showWorld2PositionIntroCardV1 {
    final current = _currentDrill;
    if (_completed || current == null) return false;
    if (widget.sessionId != 'w2.s02') return false;
    if (current.spec.kind != DrillKindV1.positionThinkingChoice) return false;
    return current.drillId == 'choose_hero_in_position_btn_vs_bb' &&
        _lastPass == null;
  }

  bool get _showWorld2ShowdownRecapCardV1 {
    if (!_completed || widget.sessionId != 'w2.s01') return false;
    final showdownDrills = _drills
        .where((item) => item.spec.kind == DrillKindV1.showdownWinnerChoice)
        .length;
    return showdownDrills >= 3;
  }

  bool get _showWorld2PositionRecapCardV1 {
    if (!_completed || widget.sessionId != 'w2.s02') return false;
    final positionDrills = _drills
        .where((item) => item.spec.kind == DrillKindV1.positionThinkingChoice)
        .length;
    return positionDrills >= 3;
  }

  bool get _showWorld2InitiativeIntroCardV1 {
    final current = _currentDrill;
    if (_completed || current == null) return false;
    if (widget.sessionId != 'w2.s03') return false;
    if (current.spec.kind != DrillKindV1.initiativeAggressorChoice) {
      return false;
    }
    return current.drillId == 'choose_hero_has_initiative_open_vs_call' &&
        _lastPass == null;
  }

  bool get _showWorld2InitiativeRecapCardV1 {
    if (!_completed || widget.sessionId != 'w2.s03') return false;
    final initiativeDrills = _drills
        .where(
          (item) => item.spec.kind == DrillKindV1.initiativeAggressorChoice,
        )
        .length;
    return initiativeDrills >= 3;
  }

  bool get _showWorld2BoardTextureIntroCardV1 {
    final current = _currentDrill;
    if (_completed || current == null) return false;
    if (widget.sessionId != 'w2.s04') return false;
    if (current.spec.kind != DrillKindV1.boardTextureClassifier) return false;
    return current.drillId == 'classify_dry_ace_seven_deuce_rainbow' &&
        _lastPass == null;
  }

  bool get _showWorld2BoardTextureRecapCardV1 {
    if (!_completed || widget.sessionId != 'w2.s04') return false;
    final textureDrills = _drills
        .where((item) => item.spec.kind == DrillKindV1.boardTextureClassifier)
        .length;
    return textureDrills >= 3;
  }

  bool get _showWorld2ReviewIntroCardV1 {
    final current = _currentDrill;
    if (_completed || current == null) return false;
    if (widget.sessionId != 'w2.s05') return false;
    if (_drills.isEmpty) return false;
    return current.drillId == _drills.first.drillId && _lastPass == null;
  }

  bool get _showWorld2ReviewRecapCardV1 {
    if (!_completed || widget.sessionId != 'w2.s05') return false;
    return _drills.length >= 4;
  }

  bool get _showWorld2OutsIntroCardV1 {
    final current = _currentDrill;
    if (_completed || current == null) return false;
    if (widget.sessionId != 'w2.s06') return false;
    if (current.spec.kind != DrillKindV1.outsCountChoice) return false;
    return current.drillId == 'count_flush_draw_nine_outs' && _lastPass == null;
  }

  bool get _showWorld2OutsRecapCardV1 {
    if (!_completed || widget.sessionId != 'w2.s06') return false;
    final outsDrills = _drills
        .where((item) => item.spec.kind == DrillKindV1.outsCountChoice)
        .length;
    return outsDrills >= 3;
  }

  bool get _showWorld2CapstoneRecapCardV1 {
    if (!_completed || widget.sessionId != 'w2.s12') return false;
    final handChainDrills = _drills
        .where((item) => item.spec.kind == DrillKindV1.handChain)
        .length;
    return handChainDrills >= 1;
  }

  bool get _showWorld2BlockCompletionReviewCardV1 {
    if (!_completed || widget.sessionId != 'w2.s14') return false;
    final handChainDrills = _drills
        .where((item) => item.spec.kind == DrillKindV1.handChain)
        .length;
    return handChainDrills >= 1;
  }

  bool get _showWorld3BlockCompletionReviewCardV1 {
    if (!_completed || widget.sessionId != 'w3.s14') return false;
    final handChainDrills = _drills
        .where((item) => item.spec.kind == DrillKindV1.handChain)
        .length;
    return handChainDrills >= 1;
  }

  bool get _showWorld4BlockCompletionReviewCardV1 {
    if (!_completed || widget.sessionId != 'w4.s10') return false;
    final betSizingDrills = _drills
        .where((item) => item.spec.kind == DrillKindV1.betSizingChoice)
        .length;
    return betSizingDrills >= 1;
  }

  bool get _showWorld10TrackRootIntroCardV1 {
    if (_completed || widget.handoffContextV1 == null) return false;
    return const <String>{
      'cash.s01',
      'tournament.s01',
      'mixed.s01',
    }.contains(widget.sessionId.trim().toLowerCase());
  }

  Widget _buildBetSizingIntroCardV1(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('session_drill_player_intro_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bet Size Practice',
            key: const Key('session_drill_player_intro_title_v1'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This mode teaches what different sizes are trying to accomplish.',
            key: const Key('session_drill_player_intro_line_1_v1'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Focus on the tradeoff: keep weaker hands in, charge more, or apply pressure.',
            key: const Key('session_drill_player_intro_line_2_v1'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Short repeats help you match a size to its purpose.',
            key: const Key('session_drill_player_intro_line_3_v1'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBetSizingRecapCardV1(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('session_drill_player_recap_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Size Recap',
            key: const Key('session_drill_player_recap_title_v1'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'BET 1/3 keeps weaker hands in. BET 1/2 balances value and price.',
            key: const Key('session_drill_player_recap_line_1_v1'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'BET POT applies pressure. RAISE MIN reopens cheaply.',
            key: const Key('session_drill_player_recap_line_2_v1'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2ShowdownIntroCardV1(BuildContext context) {
    final theme = Theme.of(context);
    final intro = _currentDrill?.spec.scenarioCoreV1.introV1;
    return Container(
      key: const Key('session_drill_player_world2_showdown_intro_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Showdown Bridge',
            key: const Key(
              'session_drill_player_world2_showdown_intro_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            intro ??
                'This bridge teaches who is stronger at showdown before deeper framework work.',
            key: const Key(
              'session_drill_player_world2_showdown_intro_line_1_v1',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Focus on the winner first: hero, villain, or board plays.',
            key: const Key(
              'session_drill_player_world2_showdown_intro_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Short reps build the comparison habit before bigger decisions.',
            key: const Key(
              'session_drill_player_world2_showdown_intro_line_3_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2ShowdownRecapCardV1(BuildContext context) {
    final theme = Theme.of(context);
    final recap =
        _currentDrill?.spec.scenarioCoreV1.recapV1 ??
        (_drills.isNotEmpty ? _drills.last.spec.scenarioCoreV1.recapV1 : null);
    return Container(
      key: const Key('session_drill_player_world2_showdown_recap_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Showdown Recap',
            key: const Key(
              'session_drill_player_world2_showdown_recap_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recap ??
                'Rank by made hand first: straight beats two pair and top pair beats second pair.',
            key: const Key(
              'session_drill_player_world2_showdown_recap_line_1_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'If the board already makes the best five-card hand, board plays and both players tie.',
            key: const Key(
              'session_drill_player_world2_showdown_recap_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld3PreflopBridgeIntroCardV1(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('session_drill_player_world3_preflop_bridge_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.handoffContextV1 != null) ...[
            Text(
              widget.handoffContextV1!.statusLine,
              key: const Key(
                'session_drill_player_world3_preflop_bridge_handoff_v1',
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.18,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'Preflop Bridge',
            key: const Key(
              'session_drill_player_world3_preflop_bridge_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'World 3 opens the preflop framework by turning hand buckets into one clean first action.',
            key: const Key(
              'session_drill_player_world3_preflop_bridge_line_1_v1',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Read the hand category first, then choose the simplest open, call, or fold that fits.',
            key: const Key(
              'session_drill_player_world3_preflop_bridge_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Short repeats keep the framework small before deeper sizing, board, and range work arrives.',
            key: const Key(
              'session_drill_player_world3_preflop_bridge_line_3_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld10TrackRootIntroCardV1(BuildContext context) {
    final theme = Theme.of(context);
    final current = _currentDrill;
    final trackClusterContractV1 = current == null
        ? null
        : _buildWorld10TrackClusterSurfaceContractV1(current.spec);
    final title = trackClusterContractV1?.introCardTitle ?? 'Track Bridge';
    final line1 =
        trackClusterContractV1?.introCardLine1 ??
        'Start with one stable baseline before adding more surface pressure.';
    final line2 =
        trackClusterContractV1?.introCardLine2 ??
        'Focus on one clean adjustment at a time.';
    return Container(
      key: const Key('session_drill_player_world10_track_bridge_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.handoffContextV1!.statusLine,
            key: const Key(
              'session_drill_player_world10_track_bridge_handoff_v1',
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            key: const Key(
              'session_drill_player_world10_track_bridge_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            line1,
            key: const Key(
              'session_drill_player_world10_track_bridge_line_1_v1',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            line2,
            key: const Key(
              'session_drill_player_world10_track_bridge_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2PositionIntroCardV1(BuildContext context) {
    final intro = _currentDrill?.spec.scenarioCoreV1.introV1;
    final theme = Theme.of(context);
    return Container(
      key: const Key('session_drill_player_world2_position_intro_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Position Bridge',
            key: const Key(
              'session_drill_player_world2_position_intro_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            intro ??
                'Position means acting later after the flop, not just sitting in a different seat.',
            key: const Key(
              'session_drill_player_world2_position_intro_line_1_v1',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Focus on who gets to see the other player act first.',
            key: const Key(
              'session_drill_player_world2_position_intro_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Acting later matters because you make the next decision with more information.',
            key: const Key(
              'session_drill_player_world2_position_intro_line_3_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2PositionRecapCardV1(BuildContext context) {
    final recap =
        _currentDrill?.spec.scenarioCoreV1.recapV1 ??
        (_drills.isNotEmpty ? _drills.last.spec.scenarioCoreV1.recapV1 : null);
    final theme = Theme.of(context);
    return Container(
      key: const Key('session_drill_player_world2_position_recap_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Position Recap',
            key: const Key(
              'session_drill_player_world2_position_recap_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recap ??
                'In position means you act later after the flop. Out of position means you act first.',
            key: const Key(
              'session_drill_player_world2_position_recap_line_1_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Later position matters because you see the other player act before you commit.',
            key: const Key(
              'session_drill_player_world2_position_recap_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2InitiativeIntroCardV1(BuildContext context) {
    final intro = _currentDrill?.spec.scenarioCoreV1.introV1;
    final theme = Theme.of(context);
    return Container(
      key: const Key('session_drill_player_world2_initiative_intro_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Initiative Bridge',
            key: const Key(
              'session_drill_player_world2_initiative_intro_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            intro ??
                'Initiative usually belongs to the player who made the last aggressive action.',
            key: const Key(
              'session_drill_player_world2_initiative_intro_line_1_v1',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Focus on who raised last, not just who is still in the hand.',
            key: const Key(
              'session_drill_player_world2_initiative_intro_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'That player is more likely to keep the pressure on the next street.',
            key: const Key(
              'session_drill_player_world2_initiative_intro_line_3_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2InitiativeRecapCardV1(BuildContext context) {
    final recap =
        _currentDrill?.spec.scenarioCoreV1.recapV1 ??
        (_drills.isNotEmpty ? _drills.last.spec.scenarioCoreV1.recapV1 : null);
    final theme = Theme.of(context);
    return Container(
      key: const Key('session_drill_player_world2_initiative_recap_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Initiative Recap',
            key: const Key(
              'session_drill_player_world2_initiative_recap_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recap ??
                'The last aggressor usually keeps initiative on the next street.',
            key: const Key(
              'session_drill_player_world2_initiative_recap_line_1_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Initiative matters because that player is more likely to continue pressure first.',
            key: const Key(
              'session_drill_player_world2_initiative_recap_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2BoardTextureIntroCardV1(BuildContext context) {
    final theme = Theme.of(context);
    final intro = _currentDrill?.spec.scenarioCoreV1.introV1;
    return Container(
      key: const Key('session_drill_player_world2_texture_intro_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Board Texture Bridge',
            key: const Key(
              'session_drill_player_world2_texture_intro_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            intro ??
                'Some boards stay calm and dry. Others create more draws and pressure right away.',
            key: const Key(
              'session_drill_player_world2_texture_intro_line_1_v1',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Use CALL for the calmer board and RAISE for the more pressure-building board.',
            key: const Key(
              'session_drill_player_world2_texture_intro_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'You are not choosing a poker action here. You are classifying how much board pressure is building.',
            key: const Key(
              'session_drill_player_world2_texture_intro_line_3_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2BoardTextureRecapCardV1(BuildContext context) {
    final theme = Theme.of(context);
    final recap =
        _currentDrill?.spec.scenarioCoreV1.recapV1 ??
        (_drills.isNotEmpty ? _drills.last.spec.scenarioCoreV1.recapV1 : null);
    return Container(
      key: const Key('session_drill_player_world2_texture_recap_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Texture Recap',
            key: const Key(
              'session_drill_player_world2_texture_recap_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recap ??
                'Dry or paired boards usually stay calmer. Connected two-tone boards build more pressure fast.',
            key: const Key(
              'session_drill_player_world2_texture_recap_line_1_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'That pressure matters because more draws and better turn cards can change the next decision.',
            key: const Key(
              'session_drill_player_world2_texture_recap_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2ReviewIntroCardV1(BuildContext context) {
    final theme = Theme.of(context);
    return _buildTextLedNarrativeCardV1(
      key: const Key('session_drill_player_world2_review_intro_card_v1'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'World 2 Review',
            key: const Key('session_drill_player_world2_review_intro_title_v1'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: SharkyTokensV1.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This connector revisits the four World 2 bridges in one short chain: showdown, position, initiative, and texture.',
            key: const Key(
              'session_drill_player_world2_review_intro_line_1_v1',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: SharkyTokensV1.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Use the same compact rules you just learned instead of treating each mini-session like a separate island.',
            key: const Key(
              'session_drill_player_world2_review_intro_line_2_v1',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: SharkyTokensV1.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2ReviewRecapCardV1(BuildContext context) {
    final theme = Theme.of(context);
    return _buildTextLedNarrativeCardV1(
      key: const Key('session_drill_player_world2_review_recap_card_v1'),
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'World 2 Recap',
            key: const Key('session_drill_player_world2_review_recap_title_v1'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: SharkyTokensV1.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Compare who wins first, then who acts later, then who kept initiative, then how much board pressure is building.',
            key: const Key(
              'session_drill_player_world2_review_recap_line_1_v1',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: SharkyTokensV1.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'That sequence turns four bridge slices into one clearer World 2 learning block.',
            key: const Key(
              'session_drill_player_world2_review_recap_line_2_v1',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: SharkyTokensV1.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextLedNarrativeCardV1({
    required Key key,
    required Widget child,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SharkyTokensV1.surfaceCard.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
        border: Border.all(
          color: SharkyTokensV1.slate600.withValues(alpha: 0.42),
        ),
        boxShadow: SharkyTokensV1.elevation1,
      ),
      child: child,
    );
  }

  Widget _buildWorld2OutsIntroCardV1(BuildContext context) {
    final intro = _currentDrill?.spec.scenarioCoreV1.introV1;
    final theme = Theme.of(context);
    return Container(
      key: const Key('session_drill_player_world2_outs_intro_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outs Bridge',
            key: const Key('session_drill_player_world2_outs_intro_title_v1'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            intro ??
                'Outs are the unseen cards that improve your hand in a clear way.',
            key: const Key('session_drill_player_world2_outs_intro_line_1_v1'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Count the improving cards first. Do not jump to math or odds yet.',
            key: const Key('session_drill_player_world2_outs_intro_line_2_v1'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Cleaner draw boards give you clearer improvement paths than static made-hand boards.',
            key: const Key('session_drill_player_world2_outs_intro_line_3_v1'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2OutsRecapCardV1(BuildContext context) {
    final recap =
        _currentDrill?.spec.scenarioCoreV1.recapV1 ??
        (_drills.isNotEmpty ? _drills.last.spec.scenarioCoreV1.recapV1 : null);
    final theme = Theme.of(context);
    return Container(
      key: const Key('session_drill_player_world2_outs_recap_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outs Recap',
            key: const Key('session_drill_player_world2_outs_recap_title_v1'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recap ??
                'A flush draw usually has 9 outs. An open-ended straight draw usually has 8. A gutshot usually has 4.',
            key: const Key('session_drill_player_world2_outs_recap_line_1_v1'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'More coordinated boards create clearer improvement paths, which is why texture matters before equity math.',
            key: const Key('session_drill_player_world2_outs_recap_line_2_v1'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2CapstoneRecapCardV1(BuildContext context) {
    final theme = Theme.of(context);
    final lastStepRecap = _drills.isNotEmpty
        ? _drills.last.spec.chainStepsV1?.last.scenarioCoreV1.recapV1
        : null;
    return Container(
      key: const Key('session_drill_player_world2_capstone_recap_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'World 2 Capstone Recap',
            key: const Key(
              'session_drill_player_world2_capstone_recap_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lastStepRecap ??
                'Read the whole scene in order: position first, then initiative, then board pressure, then the simple action that fits the spot.',
            key: const Key(
              'session_drill_player_world2_capstone_recap_line_1_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'That is the core World 2 habit: connect seat truth, pressure, and improvement paths before acting.',
            key: const Key(
              'session_drill_player_world2_capstone_recap_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld2BlockCompletionReviewCardV1(BuildContext context) {
    final theme = Theme.of(context);
    final handoffContextV1 = buildProgressionHandoffContextForPackV1(
      'world3_spine_campaign_v1',
    );
    return Container(
      key: const Key('session_drill_player_world2_block_completion_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (handoffContextV1 != null) ...[
            Text(
              handoffContextV1.statusLine,
              key: const Key(
                'session_drill_player_world2_block_completion_handoff_v1',
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.18,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'World 2 Complete',
            key: const Key(
              'session_drill_player_world2_block_completion_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You can now read the same scene in a useful order: position, initiative, board pressure, improvement paths, then the simple action that fits the price.',
            key: const Key(
              'session_drill_player_world2_block_completion_line_1_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Next route: World 3 turns hand category into the first clean open, call, or fold decision.',
            key: const Key(
              'session_drill_player_world2_block_completion_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Best quick review: replay the compact review in w2.s05, the capstone in w2.s12, or the continue-versus-fold pair in w2.s13 and w2.s14.',
            key: const Key(
              'session_drill_player_world2_block_completion_line_3_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld3BlockCompletionReviewCardV1(BuildContext context) {
    final theme = Theme.of(context);
    final handoffContextV1 = buildProgressionHandoffContextForPackV1(
      'world4_spine_campaign_v1',
    );
    return Container(
      key: const Key('session_drill_player_world3_block_completion_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (handoffContextV1 != null) ...[
            Text(
              handoffContextV1.statusLine,
              key: const Key(
                'session_drill_player_world3_block_completion_handoff_v1',
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.18,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'World 3 Complete',
            key: const Key(
              'session_drill_player_world3_block_completion_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You can now classify the same preflop hand by seat, opener state, and facing-action pressure before choosing one clean response.',
            key: const Key(
              'session_drill_player_world3_block_completion_line_1_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Next route: World 4 turns action purpose into one clean size choice for value, pressure, and price.',
            key: const Key(
              'session_drill_player_world3_block_completion_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Best quick review: replay the front bridge in w3.s01, the mixed checkpoint in w3.s06, or the late capstone pair in w3.s13 and w3.s14.',
            key: const Key(
              'session_drill_player_world3_block_completion_line_3_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWorld4BlockCompletionReviewCardV1(BuildContext context) {
    final theme = Theme.of(context);
    final handoffContextV1 = buildProgressionHandoffContextForPackV1(
      'world5_spine_campaign_v1',
    );
    return Container(
      key: const Key('session_drill_player_world4_block_completion_card_v1'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (handoffContextV1 != null) ...[
            Text(
              handoffContextV1.statusLine,
              key: const Key(
                'session_drill_player_world4_block_completion_handoff_v1',
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.18,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'World 4 Complete',
            key: const Key(
              'session_drill_player_world4_block_completion_title_v1',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You can now match the same action goal to a size: keep weaker hands in, charge more, apply pressure, or reopen cheaply.',
            key: const Key(
              'session_drill_player_world4_block_completion_line_1_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Next route: World 5 turns board texture into the first clean pressure read before choosing a response.',
            key: const Key(
              'session_drill_player_world4_block_completion_line_2_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Best quick review: replay the opener in w4.s01, the continuation slice in w4.s03, or the tail checkpoint in w4.s10.',
            key: const Key(
              'session_drill_player_world4_block_completion_line_3_v1',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildShowdownWinnerBarV1() {
    final actionIds = _resolvedSourceActionIdsV1(const <String>[
      'hero',
      'villain',
      'board_plays',
    ]);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Wrap(
        key: const Key('session_drill_player_showdown_winner_bar_v1'),
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final actionId in actionIds)
            OutlinedButton(
              key: Key('session_drill_player_showdown_${actionId}_v1'),
              onPressed: () =>
                  _handleEvent(DrillUserEventV1.actionChoice(actionId)),
              child: Text(_showdownActionLabelV1(actionId)),
            ),
        ],
      ),
    );
  }

  Widget _buildPositionThinkingBarV1() {
    final actionIds = _resolvedSourceActionIdsV1(const <String>[
      'hero',
      'villain',
    ]);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Wrap(
        key: const Key('session_drill_player_position_thinking_bar_v1'),
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final actionId in actionIds)
            OutlinedButton(
              key: Key('session_drill_player_position_${actionId}_v1'),
              onPressed: () =>
                  _handleEvent(DrillUserEventV1.actionChoice(actionId)),
              child: Text(actionId.toUpperCase()),
            ),
        ],
      ),
    );
  }

  Widget _buildInitiativeAggressorBarV1() {
    final actionIds = _resolvedSourceActionIdsV1(const <String>[
      'hero',
      'villain',
    ]);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Wrap(
        key: const Key('session_drill_player_initiative_bar_v1'),
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final actionId in actionIds)
            OutlinedButton(
              key: Key('session_drill_player_initiative_${actionId}_v1'),
              onPressed: () =>
                  _handleEvent(DrillUserEventV1.actionChoice(actionId)),
              child: Text(actionId.toUpperCase()),
            ),
        ],
      ),
    );
  }

  Widget _buildOutsCountBarV1() {
    final actionIds = _resolvedSourceActionIdsV1(const <String>[
      '4',
      '8',
      '9',
      '15',
    ]);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Wrap(
        key: const Key('session_drill_player_outs_count_bar_v1'),
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final actionId in actionIds)
            OutlinedButton(
              key: Key('session_drill_player_outs_${actionId}_v1'),
              onPressed: () =>
                  _handleEvent(DrillUserEventV1.actionChoice(actionId)),
              child: Text('$actionId OUTS'),
            ),
        ],
      ),
    );
  }

  _SessionDrillTeachingContractV1 _buildSessionDrillTeachingContractV1({
    required DrillSpecV1 spec,
    required _SessionDrillSurfacedPathWiringContractV1 wiring,
  }) {
    final revealPayloadV1 =
        wiring.factualHostContract?.reveal ??
        resolveRunnerRevealPayloadV1(
          RunnerRevealPayloadInputV1(
            sourceId: wiring.hostCapabilityContract.promptSourceId,
            detailsPrompt:
                wiring.factualHostContract?.detailsPrompt ??
                wiring.detailsPrompt,
          ),
        );
    final promptDetailsTitleV1 = _surfaceSessionStepLabelV1(spec);
    if (_isIdleSurfacedShowdownV1) {
      return _SessionDrillTeachingContractV1(
        handoffStatusText: widget.handoffContextV1?.statusLine,
        headlineText: _surfaceSessionTitleV1(),
        statusHeaderText: _statusHeaderTextV1(spec),
        promptStatusText: _isWorld2ShowdownScenarioPilotV1
            ? 'SD'
            : promptDetailsTitleV1,
        sharedTeachingGrammarV1: SharedLearnerTeachingGrammarV1(
          headerStatusText: widget.handoffContextV1?.statusLine,
          headerHeadlineText: _surfaceSessionTitleV1(),
          headerPromptText: wiring.topPromptText.trim(),
          promptStatusText: _isWorld2ShowdownScenarioPilotV1
              ? 'SD'
              : promptDetailsTitleV1,
          displayedPrompt: wiring.topPromptText.trim(),
          promptDetailsTitle: promptDetailsTitleV1,
          promptDetailsText: revealPayloadV1.revealedText.trim(),
          canRevealPromptDetails: revealPayloadV1.canReveal,
          enablePromptDetailsAffordance: revealPayloadV1.isAffordanceEnabled,
          supportPrimaryText: '',
          supportSecondaryText: '',
          supportTertiaryText: '',
          outcomePrimaryText: '',
          outcomeWhyText: '',
          outcomeNextText: '',
          outcomeDetailText: '',
        ),
        supportPrimaryKey: null,
        supportSecondaryKey: null,
        supportTertiaryKey: null,
      );
    }
    final showFail = _lastPass == false;
    final showCompletedPass = _lastPass == true && _completed;

    String? primaryText;
    Key? primaryKey;
    if (_lastPass == null) {
      primaryText = '...';
      primaryKey = const Key('session_drill_player_result_idle');
    } else if (showCompletedPass) {
      primaryText = 'OK';
      primaryKey = const Key('session_drill_player_result_ok');
    } else if (showFail) {
      primaryText = 'FAIL (${_lastErrorClass ?? 'unknown'})';
      primaryKey = const Key('session_drill_player_result_fail');
    }

    final sourceCorrect = _sourceFeedbackCorrectV1;
    final sourceIncorrect = _sourceFeedbackIncorrectV1;
    final correctiveFeedbackV1 = _canonicalCorrectiveFeedbackV1;
    final secondaryText = showFail
        ? (correctiveFeedbackV1?.detailText ??
              sourceIncorrect ??
              _lastFailureDetail)
        : (_lastSoftPassInfo != null
              ? (_lastSoftPassDetailV1 ?? 'There is a stronger line here.')
              : (sourceCorrect ?? _correctReinforcementV1));
    final secondaryKey = showFail
        ? const Key('session_drill_player_result_fail_detail')
        : (_lastSoftPassInfo != null
              ? const Key('session_drill_player_result_soft_pass_info_v1')
              : (_correctReinforcementV1 != null
                    ? const Key(
                        'session_drill_player_result_pass_reinforcement_v1',
                      )
                    : null));
    final tertiaryText = _showWhyV1OnFailV1
        ? (correctiveFeedbackV1?.whyText ??
              (_currentFactualHandChainWhyV1 ??
                  _currentChainStepV1?.whyV1 ??
                  _currentDrill!.spec.whyV1!))
        : (showFail ? _lastFailureDetail : _lastSoftPassInfo);
    final tertiaryKey = _showWhyV1OnFailV1
        ? const Key('session_drill_player_result_fail_why_v1')
        : (_lastSoftPassInfo != null
              ? const Key('session_drill_player_result_soft_pass_reason_v1')
              : null);
    final outcomeDetailSegmentsV1 = <String>[
      if ((secondaryText ?? '').trim().isNotEmpty) secondaryText!.trim(),
      if ((tertiaryText ?? '').trim().isNotEmpty &&
          tertiaryText!.trim().toLowerCase() !=
              (secondaryText ?? '').trim().toLowerCase())
        tertiaryText.trim(),
    ];
    final sharedTeachingGrammarV1 = SharedLearnerTeachingGrammarV1(
      headerStatusText: widget.handoffContextV1?.statusLine,
      headerHeadlineText: _surfaceSessionTitleV1(),
      headerPromptText: wiring.topPromptText.trim(),
      promptStatusText: _isWorld2ShowdownScenarioPilotV1
          ? 'SD'
          : promptDetailsTitleV1,
      displayedPrompt: wiring.topPromptText.trim(),
      promptDetailsTitle: promptDetailsTitleV1,
      promptDetailsText: revealPayloadV1.revealedText.trim(),
      canRevealPromptDetails: revealPayloadV1.canReveal,
      enablePromptDetailsAffordance: revealPayloadV1.isAffordanceEnabled,
      supportPrimaryText: primaryText?.trim() ?? '',
      supportSecondaryText: secondaryText?.trim() ?? '',
      supportTertiaryText: tertiaryText?.trim() ?? '',
      outcomePrimaryText: primaryText?.trim() ?? '',
      outcomeWhyText: tertiaryText?.trim() ?? '',
      outcomeNextText: secondaryText?.trim() ?? '',
      outcomeDetailText: outcomeDetailSegmentsV1.join('\n'),
    );

    return _SessionDrillTeachingContractV1(
      handoffStatusText: widget.handoffContextV1?.statusLine,
      headlineText: _surfaceSessionTitleV1(),
      statusHeaderText: _statusHeaderTextV1(spec),
      promptStatusText: _isWorld2ShowdownScenarioPilotV1
          ? 'SD'
          : promptDetailsTitleV1,
      sharedTeachingGrammarV1: sharedTeachingGrammarV1,
      supportPrimaryKey: primaryKey,
      supportSecondaryKey: secondaryKey,
      supportTertiaryKey: tertiaryKey,
    );
  }

  Widget _buildFeedbackBlockV1(
    BuildContext context, {
    required _SessionDrillTeachingContractV1 teachingContractV1,
    Key? surfaceKey,
    bool useTextLedNarrativeDecoration = false,
  }) {
    final theme = Theme.of(context);
    final sharedTeachingGrammarV1 = teachingContractV1.sharedTeachingGrammarV1;
    if (_isIdleSurfacedShowdownV1) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 70,
      child: SharedLearnerTeachingSupportOutcomeV1(
        grammar: sharedTeachingGrammarV1,
        style: SharedLearnerTeachingSupportOutcomeStyleV1(
          surfaceKey: surfaceKey,
          padding: useTextLedNarrativeDecoration
              ? const EdgeInsets.fromLTRB(12, 8, 12, 8)
              : EdgeInsets.zero,
          decoration: useTextLedNarrativeDecoration
              ? buildSharedLearnerTeachingCalmSupportDecorationV1(compact: true)
              : null,
          lines: <SharedLearnerTeachingSupportOutcomeLineStyleV1>[
            SharedLearnerTeachingSupportOutcomeLineStyleV1(
              role: SharedLearnerTeachingTextRoleV1.outcomePrimaryText,
              key: teachingContractV1.supportPrimaryKey,
              fixedHeight: 22,
              maxLines: 1,
              style: buildSharedLearnerTeachingPrimarySupportTextStyleV1(
                theme.textTheme.bodyMedium,
              ),
            ),
            SharedLearnerTeachingSupportOutcomeLineStyleV1(
              role: SharedLearnerTeachingTextRoleV1.outcomeNextText,
              key: teachingContractV1.supportSecondaryKey,
              fixedHeight: 22,
              maxLines: 1,
              style: buildSharedLearnerTeachingSecondarySupportTextStyleV1(
                theme.textTheme.bodySmall,
              ),
            ),
            SharedLearnerTeachingSupportOutcomeLineStyleV1(
              role: SharedLearnerTeachingTextRoleV1.outcomeWhyText,
              key: teachingContractV1.supportTertiaryKey,
              fixedHeight: 22,
              maxLines: 1,
              style: buildSharedLearnerTeachingSecondarySupportTextStyleV1(
                theme.textTheme.bodySmall,
                tertiary: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioMetaLaneV1(List<Widget> chips) {
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              chips[i],
            ],
          ],
        ),
      ),
    );
  }

  List<String> _betSizingPresetIdsV1(DrillSpecV1 spec) {
    return DecisionBarV1.pilotBetSizingPresetIdsV1;
  }

  String _presetLabelV1(String presetId) {
    return DecisionBarV1.pilotBetSizingDecisionLabelForPresetIdV1(presetId) ??
        presetId.toUpperCase();
  }

  Widget _buildBetSizingPresetBarV1(DrillSpecV1 spec) {
    final presetIds = _betSizingPresetIdsV1(spec);
    if (presetIds.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: kCanonicalLearnerActionSurfacePaddingV1,
      child: Wrap(
        key: const Key('session_drill_player_bet_sizing_preset_bar_v1'),
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final presetId in presetIds)
            OutlinedButton(
              key: Key('session_drill_player_preset_${presetId}_v1'),
              onPressed: () =>
                  _handleEvent(DrillUserEventV1.actionChoice(presetId)),
              child: Text(_presetLabelV1(presetId)),
            ),
        ],
      ),
    );
  }

  Widget _buildBoardTextureActionBarV1() {
    final actionIds = canonicalLearnerPrimaryActionOrderV1(
      _resolvedSourceActionIdsV1(const <String>['fold', 'call', 'raise']),
      (actionId) => actionId,
    );
    return Padding(
      padding: kCanonicalLearnerActionSurfacePaddingV1,
      child: Wrap(
        key: const Key('session_drill_player_texture_action_bar_v1'),
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final actionId in actionIds)
            OutlinedButton(
              key: Key('session_drill_player_texture_${actionId}_v1'),
              onPressed: () =>
                  _handleEvent(DrillUserEventV1.actionChoice(actionId)),
              child: Text(actionId.toUpperCase()),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentActionSurfaceV1(DrillSpecV1 spec) {
    if (spec.kind == DrillKindV1.betSizingChoice) {
      return _buildBetSizingPresetBarV1(spec);
    }
    if (spec.kind == DrillKindV1.showdownWinnerChoice) {
      return _buildShowdownWinnerBarV1();
    }
    if (spec.kind == DrillKindV1.positionThinkingChoice) {
      return _buildPositionThinkingBarV1();
    }
    if (spec.kind == DrillKindV1.initiativeAggressorChoice) {
      return _buildInitiativeAggressorBarV1();
    }
    if (spec.kind == DrillKindV1.outsCountChoice) {
      return _buildOutsCountBarV1();
    }
    if (spec.kind == DrillKindV1.actionChoice ||
        spec.kind == DrillKindV1.boardTextureClassifier ||
        spec.kind == DrillKindV1.rangeBucketClassifier) {
      return _buildBoardTextureActionBarV1();
    }
    if (spec.kind != DrillKindV1.handChain) {
      return const SizedBox.shrink();
    }
    final resolvedState = _currentResolvedHandChainScenarioStateV1;
    final step = _currentChainStepV1;
    if (resolvedState == null && step == null) {
      return const SizedBox.shrink();
    }
    final expectedPresetId =
        resolvedState?.expectedPresetIdV1 ?? step?.expectedPresetIdV1;
    if (expectedPresetId != null) {
      final ids = <String>[
        expectedPresetId,
        ...(resolvedState?.acceptablePresetIdsV1 ??
            step?.acceptablePresetIds ??
            const <String>[]),
      ].toSet().toList()..sort();
      return Padding(
        padding: kCanonicalLearnerActionSurfacePaddingV1,
        child: Wrap(
          key: const Key('session_drill_player_hand_chain_preset_bar_v1'),
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final presetId in ids)
              OutlinedButton(
                key: Key(
                  'session_drill_player_hand_chain_preset_${presetId}_v1',
                ),
                onPressed: () => _handleEvent(
                  DrillUserEventV1.actionChoice(
                    presetId,
                    chainStepIndex: _currentChainStepIndexV1,
                  ),
                ),
                child: Text(_presetLabelV1(presetId)),
              ),
          ],
        ),
      );
    }
    if ((resolvedState?.rangeBucketV1 ?? step?.rangeBucketV1) != null) {
      return _buildRangeBucketActionBarV1(isHandChainV1: true);
    }
    final sourceActionIds =
        resolvedState?.coreV1.availableActionsV1 ??
        step?.scenarioCoreV1.availableActionsV1;
    if (sourceActionIds != null && sourceActionIds.isNotEmpty) {
      final orderedActionIds = canonicalLearnerPrimaryActionOrderV1(
        sourceActionIds,
        (actionId) => actionId,
      );
      return Padding(
        padding: kCanonicalLearnerActionSurfacePaddingV1,
        child: Wrap(
          key: const Key('session_drill_player_hand_chain_action_bar_v1'),
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final actionId in orderedActionIds)
              OutlinedButton(
                key: Key(
                  'session_drill_player_hand_chain_action_${actionId}_v1',
                ),
                onPressed: () => _handleEvent(
                  DrillUserEventV1.actionChoice(
                    actionId,
                    chainStepIndex: _currentChainStepIndexV1,
                  ),
                ),
                child: Text(actionId.toUpperCase()),
              ),
          ],
        ),
      );
    }
    return Padding(
      padding: kCanonicalLearnerActionSurfacePaddingV1,
      child: Wrap(
        key: const Key('session_drill_player_texture_action_bar_v1'),
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final actionId in <String>['fold', 'call', 'raise'])
            OutlinedButton(
              key: Key('session_drill_player_texture_${actionId}_v1'),
              onPressed: () => _handleEvent(
                DrillUserEventV1.actionChoice(
                  actionId,
                  chainStepIndex: _currentChainStepIndexV1,
                ),
              ),
              child: Text(actionId.toUpperCase()),
            ),
        ],
      ),
    );
  }

  Widget _buildWorld2TextureScenarioMetaV1(BuildContext context) {
    return _buildSurfacedSourceMetaForFamilyV1(
      context,
      FactualRunnerHostFamilyV1.texture,
    );
  }

  String _showdownActionLabelV1(String actionId) {
    switch (actionId) {
      case 'hero':
        return 'HERO';
      case 'villain':
        return 'VILLAIN';
      case 'board_plays':
        return 'BOARD PLAYS';
    }
    return actionId.toUpperCase();
  }

  Widget _buildWorld2ShowdownScenarioMetaV1(BuildContext context) {
    final current = _currentDrill;
    if (current == null) return const SizedBox.shrink();
    final showdownContext = current.spec.scenarioShowdownContextV1;
    if (showdownContext == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return _buildScenarioMetaLaneV1([
      Chip(
        key: const Key('session_drill_player_showdown_source_street_v1'),
        label: Text('Street: ${showdownContext.streetV1.toUpperCase()}'),
        visualDensity: VisualDensity.compact,
      ),
      Chip(
        key: const Key('session_drill_player_showdown_source_hero_v1'),
        label: Text('Hero: ${showdownContext.heroHoleCardsV1.join(' ')}'),
        labelStyle: theme.textTheme.bodySmall,
        visualDensity: VisualDensity.compact,
      ),
      Chip(
        key: const Key('session_drill_player_showdown_source_villain_v1'),
        label: Text('Villain: ${showdownContext.villainHoleCardsV1.join(' ')}'),
        labelStyle: theme.textTheme.bodySmall,
        visualDensity: VisualDensity.compact,
      ),
      Chip(
        key: const Key('session_drill_player_showdown_source_board_v1'),
        label: Text('Board: ${showdownContext.boardCardsV1.join(' ')}'),
        labelStyle: theme.textTheme.bodySmall,
        visualDensity: VisualDensity.compact,
      ),
    ]);
  }

  Widget _buildWorld2PositionScenarioMetaV1(BuildContext context) {
    return _buildSurfacedSourceMetaForFamilyV1(
      context,
      FactualRunnerHostFamilyV1.position,
    );
  }

  Widget _buildWorld2InitiativeScenarioMetaV1(BuildContext context) {
    return _buildSurfacedSourceMetaForFamilyV1(
      context,
      FactualRunnerHostFamilyV1.initiative,
    );
  }

  Widget _buildWorld2OutsScenarioMetaV1(BuildContext context) {
    return _buildSurfacedSourceMetaForFamilyV1(
      context,
      FactualRunnerHostFamilyV1.outs,
    );
  }

  Widget _buildHandChainScenarioMetaV1(BuildContext context) {
    return _buildSurfacedSourceMetaForFamilyV1(
      context,
      FactualRunnerHostFamilyV1.factualHandChain,
    );
  }

  Widget _buildSurfacedSourceMetaForFamilyV1(
    BuildContext context,
    FactualRunnerHostFamilyV1 family,
  ) {
    final entries = _buildSurfacedSourceMetaEntriesForFamilyV1(family);
    if (entries.isEmpty) return const SizedBox.shrink();
    return _buildSurfacedSourceMetaBlockV1(context, entries);
  }

  List<RunnerHostSourceMetaEntryV1> _buildSurfacedSourceMetaEntriesForFamilyV1(
    FactualRunnerHostFamilyV1 family,
  ) {
    final input = buildSessionDrillCanonicalSourceMetaInputForFamilyV1(
      family: family,
      currentDrill: _currentDrill,
      resolvedTextureStateV1: _currentResolvedTextureScenarioStateV1,
      resolvedOutsStateV1: _currentResolvedOutsScenarioStateV1,
      resolvedSeatContextStateV1: _currentResolvedSeatContextScenarioStateV1,
      resolvedHandChainStateV1: _currentResolvedHandChainScenarioStateV1,
    );
    return buildSessionDrillCanonicalSourceMetaEntriesV1(input);
  }

  Widget _buildSurfacedSourceMetaBlockV1(
    BuildContext context,
    List<RunnerHostSourceMetaEntryV1> entries,
  ) {
    final theme = Theme.of(context);
    return _buildScenarioMetaLaneV1([
      for (final entry in entries)
        Chip(
          key: Key(entry.testKey),
          label: Text(entry.text),
          labelStyle: entry.useBodySmall ? theme.textTheme.bodySmall : null,
          visualDensity: VisualDensity.compact,
        ),
    ]);
  }

  Widget _buildRangeBucketActionBarV1({required bool isHandChainV1}) {
    const bucketIds = <String>['strong', 'medium', 'weak', 'draw', 'missed'];
    return Padding(
      padding: kCanonicalLearnerActionSurfacePaddingV1,
      child: Wrap(
        key: const Key('session_drill_player_range_bucket_bar_v1'),
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final bucketId in bucketIds)
            OutlinedButton(
              key: Key('session_drill_player_bucket_${bucketId}_v1'),
              onPressed: () => _handleEvent(
                DrillUserEventV1.actionChoice(
                  bucketId,
                  chainStepIndex: isHandChainV1
                      ? _currentChainStepIndexV1
                      : null,
                ),
              ),
              child: Text(bucketId.toUpperCase()),
            ),
        ],
      ),
    );
  }

  Key? _embeddedScenarioTableKeyV1(DrillSpecV1 spec) {
    if (_isSpatialProjectionPilotDrillV1(spec)) {
      return const Key('session_drill_player_spatial_table_v1');
    }
    if (_isWorld5BoardTextureScenarioV1(spec)) {
      return ValueKey<String>(
        'session_drill_player_world5_texture_table_v1:${widget.sessionId}:${spec.id}',
      );
    }
    if (_isWorld2PositionScenarioPilotV1) {
      return const Key('session_drill_player_position_table_v1');
    }
    if (_isWorld2InitiativeScenarioPilotV1) {
      return const Key('session_drill_player_initiative_table_v1');
    }
    if (_isEmbeddedHandChainScenarioPilotV1) {
      return const Key('session_drill_player_hand_chain_table_v1');
    }
    return null;
  }

  Key? _embeddedScenarioResetKeyV1(DrillSpecV1 spec) {
    if (_isEmbeddedHandChainScenarioPilotV1) {
      final drillId = _currentDrill?.drillId ?? spec.id;
      return ValueKey<String>(
        'session_drill_player_hand_chain_table_reset_v1:${widget.sessionId}:$drillId:step$_currentChainStepIndexV1',
      );
    }
    return null;
  }

  ScenarioSpecV1? _embeddedScenarioSpecV1(DrillSpecV1 spec) {
    if (_isSpatialProjectionPilotDrillV1(spec)) {
      return _buildSpatialProjectionScenarioSpecV1(spec);
    }
    if (_isWorld5BoardTextureScenarioV1(spec)) {
      return _buildWorld5BoardTextureScenarioSpecV1(spec);
    }
    if (_isWorld2PositionScenarioPilotV1) {
      return _buildWorld2PositionScenarioSpecV1(spec);
    }
    if (_isWorld2OutsScenarioPilotV1) {
      return _buildWorld2OutsScenarioSpecV1(spec);
    }
    if (_isWorld2InitiativeScenarioPilotV1) {
      return _buildWorld2InitiativeScenarioSpecV1(spec);
    }
    if (_isWorld2TextureScenarioPilotV1) {
      return _buildWorld2TextureScenarioSpecV1(spec);
    }
    if (_isEmbeddedHandChainScenarioPilotV1 &&
        (_isBoardOnlyHandChainSessionV1
            ? _currentChainStepV1
                      ?.scenarioTableContextV1
                      ?.boardContextV1
                      ?.boardCardsV1 !=
                  null
            : _currentChainStepV1?.playerCountV1 != null)) {
      return _buildWorld2HandChainScenarioSpecV1(_currentChainStepV1!);
    }
    return null;
  }

  String _surfaceSessionTitleV1() {
    final current = _currentDrill;
    if (current == null) {
      return 'Drill Player ${widget.sessionId}';
    }
    return _progressionChromeContractV1(current.spec).titleText;
  }

  String _surfaceSessionStepLabelV1(DrillSpecV1 spec) {
    switch (spec.kind) {
      case DrillKindV1.showdownWinnerChoice:
        return 'Showdown';
      case DrillKindV1.actionChoice:
        return 'Decision';
      case DrillKindV1.seatTap:
      case DrillKindV1.positionThinkingChoice:
        return 'Position';
      case DrillKindV1.initiativeAggressorChoice:
        return 'Initiative';
      case DrillKindV1.outsCountChoice:
        return 'Outs';
      case DrillKindV1.boardTextureClassifier:
        return 'Board Texture';
      case DrillKindV1.handChain:
        final step = _currentChainStepV1;
        final seatContext = step?.scenarioTableContextV1?.seatContextV1;
        final boardContext = step?.scenarioTableContextV1?.boardContextV1;
        final followUp = step?.scenarioActionFollowUpV1;
        if (followUp != null) {
          return 'Decision';
        }
        if (step?.initiativeOwnerV1 != null ||
            seatContext?.initiativeOwnerV1 != null) {
          return 'Initiative';
        }
        if (boardContext?.heroHoleCardsV1 != null &&
            boardContext!.heroHoleCardsV1!.isNotEmpty) {
          return 'Outs';
        }
        if (boardContext?.boardCardsV1 != null &&
            boardContext!.boardCardsV1!.isNotEmpty) {
          return 'Board Texture';
        }
        if (step?.heroSeatV1 != null || seatContext?.heroSeatV1 != null) {
          return 'Position';
        }
        return 'Scenario';
      default:
        return 'Drill';
    }
  }

  String _statusHeaderTextV1(DrillSpecV1 spec) {
    return _progressionChromeContractV1(spec).statusText;
  }

  List<String>? _embeddedScenarioBoardLabelsV1(DrillSpecV1 spec) {
    if (_isSpatialProjectionPilotDrillV1(spec)) {
      final boardCards = _currentResolvedSpatialScenarioStateV1?.boardCardsV1;
      return boardCards == null
          ? null
          : boardCards
                .map(_uiCardLabelForProjectionV1)
                .whereType<String>()
                .toList(growable: false);
    }
    if (_isWorld5BoardTextureScenarioV1(spec)) {
      return _currentResolvedTextureScenarioStateV1?.boardCardsV1
          .map(_uiCardLabelForProjectionV1)
          .whereType<String>()
          .toList(growable: false);
    }
    if (spec.kind == DrillKindV1.handChain) {
      final boardCards = _currentChainStepV1
          ?.scenarioTableContextV1
          ?.boardContextV1
          ?.boardCardsV1;
      return boardCards == null
          ? null
          : boardCards
                .map(_uiCardLabelForProjectionV1)
                .whereType<String>()
                .toList();
    }
    if (_isWorld2TextureScenarioPilotV1) {
      final boardCards = _currentResolvedTextureScenarioStateV1?.boardCardsV1;
      return boardCards == null
          ? null
          : boardCards
                .map(_uiCardLabelForProjectionV1)
                .whereType<String>()
                .toList();
    }
    if (_isWorld2ShowdownScenarioPilotV1) {
      final boardCards = spec.scenarioShowdownContextV1?.boardCardsV1;
      return boardCards == null
          ? null
          : boardCards
                .map(_uiCardLabelForProjectionV1)
                .whereType<String>()
                .toList();
    }
    if (_isWorld2OutsScenarioPilotV1) {
      final boardCards = _currentResolvedOutsScenarioStateV1?.boardCardsV1;
      return boardCards == null
          ? null
          : boardCards
                .map(_uiCardLabelForProjectionV1)
                .whereType<String>()
                .toList();
    }
    return null;
  }

  List<String>? _embeddedScenarioHeroLabelsV1(DrillSpecV1 spec) {
    if (_isSpatialProjectionPilotDrillV1(spec)) {
      final heroHoleCards =
          _currentResolvedSpatialScenarioStateV1?.heroHoleCardsV1;
      return heroHoleCards == null
          ? null
          : heroHoleCards
                .map(_uiCardLabelForProjectionV1)
                .whereType<String>()
                .toList(growable: false);
    }
    if (spec.kind == DrillKindV1.handChain) {
      final heroHoleCards = _currentChainStepV1
          ?.scenarioTableContextV1
          ?.boardContextV1
          ?.heroHoleCardsV1;
      return heroHoleCards == null
          ? null
          : heroHoleCards
                .map(_uiCardLabelForProjectionV1)
                .whereType<String>()
                .toList();
    }
    if (_isWorld2ShowdownScenarioPilotV1) {
      final heroHoleCards = spec.scenarioShowdownContextV1?.heroHoleCardsV1;
      return heroHoleCards == null
          ? null
          : heroHoleCards
                .map(_uiCardLabelForProjectionV1)
                .whereType<String>()
                .toList();
    }
    if (_isWorld2OutsScenarioPilotV1) {
      final heroHoleCards =
          _currentResolvedOutsScenarioStateV1?.heroHoleCardsV1;
      return heroHoleCards == null
          ? null
          : heroHoleCards
                .map(_uiCardLabelForProjectionV1)
                .whereType<String>()
                .toList();
    }
    return null;
  }

  List<String>? _embeddedScenarioVillainLabelsV1(DrillSpecV1 spec) {
    if (_isWorld2ShowdownScenarioPilotV1) {
      final villainHoleCards =
          spec.scenarioShowdownContextV1?.villainHoleCardsV1;
      return villainHoleCards == null
          ? null
          : villainHoleCards
                .map(_uiCardLabelForProjectionV1)
                .whereType<String>()
                .toList();
    }
    return null;
  }

  String? _embeddedScenarioShowdownWinnerActionIdV1(DrillSpecV1 spec) {
    if (!_isWorld2ShowdownScenarioPilotV1) {
      return null;
    }
    return spec.expected.actionId;
  }

  String? _embeddedScenarioSceneProofLabelV1(DrillSpecV1 spec) {
    if (!_shouldShowEmbeddedScenarioTableV1(spec)) {
      return null;
    }
    final label = _surfaceSessionStepLabelV1(spec).trim();
    if (label.isEmpty) {
      return null;
    }
    return label.toUpperCase();
  }

  String? _uiCardLabelForProjectionV1(String cardId) {
    if (cardId.length < 2) return null;
    final rank = cardId[0].toUpperCase();
    final suit = switch (cardId.substring(1).toLowerCase()) {
      's' => '♠',
      'h' => '♥',
      'd' => '♦',
      'c' => '♣',
      _ => null,
    };
    if (suit == null) return null;
    return '$rank$suit';
  }

  FactualRunnerHostFamilyV1? _resolveSurfacedFactualFamilyV1() {
    if (_showWorld2InitiativeRecapCardV1) {
      return FactualRunnerHostFamilyV1.initiative;
    }
    if (_showWorld2BoardTextureRecapCardV1) {
      return FactualRunnerHostFamilyV1.texture;
    }
    if (_isWorld2PositionScenarioPilotV1) {
      return FactualRunnerHostFamilyV1.position;
    }
    if (_isWorld2OutsScenarioPilotV1) {
      return FactualRunnerHostFamilyV1.outs;
    }
    if (_isWorld2InitiativeScenarioPilotV1) {
      return FactualRunnerHostFamilyV1.initiative;
    }
    if (_isWorld2TextureScenarioPilotV1) {
      return FactualRunnerHostFamilyV1.texture;
    }
    if (_isFactualReusableHandChainLaneV1 &&
        !_completed &&
        _currentDrill?.spec.kind == DrillKindV1.handChain) {
      return FactualRunnerHostFamilyV1.factualHandChain;
    }
    return null;
  }

  FactualRunnerHostFamilyV1? get _currentSurfacedFactualFamilyV1 =>
      _resolveSurfacedFactualFamilyV1();

  _SessionDrillWorld2SurfacedFamilyResolverV1?
  _buildWorld2SurfacedFamilyResolverV1({
    required bool showsEmbeddedFeedbackBelowTableV1,
  }) {
    final family = _resolveSurfacedFactualFamilyV1();
    if (family == null) {
      return null;
    }
    final core = _buildSurfacedFamilyCoreContractV1(
      family: family,
      showsEmbeddedFeedbackBelowTableV1: showsEmbeddedFeedbackBelowTableV1,
    );
    return _SessionDrillWorld2SurfacedFamilyResolverV1(
      family: family,
      sections: core.sections,
      sourceMetaEntries: core.sourceMetaEntries,
      supplements: core.supplements,
    );
  }

  _SessionDrillSurfacedPathWiringContractV1 _buildSurfacedPathWiringContractV1({
    required DrillSpecV1 spec,
    required bool showsSurfacedWorld2HostV1,
    required bool showsEmbeddedScenarioTableV1,
    required bool showsEmbeddedFeedbackBelowTableV1,
    required BuildContext context,
  }) {
    final world2SurfacedFamilyResolverV1 = showsSurfacedWorld2HostV1
        ? _buildWorld2SurfacedFamilyResolverV1(
            showsEmbeddedFeedbackBelowTableV1:
                showsEmbeddedFeedbackBelowTableV1,
          )
        : null;
    final hostCapabilityContractV1 = resolveDrillHostCapabilityContractV1(
      DrillHostCapabilityContractInputV1(
        sessionId: widget.sessionId,
        spec: spec,
        currentDrillIndex: _currentIndex,
        currentChainStepIndex: _currentChainStepIndexV1,
        isCompleted: _completed,
        showsSurfacedScenarioHostV1: showsSurfacedWorld2HostV1,
        showsEmbeddedScenarioTableV1: showsEmbeddedScenarioTableV1,
        sections:
            world2SurfacedFamilyResolverV1?.sections ??
            _buildCurrentSurfacedSectionsV1(
              showsEmbeddedFeedbackBelowTableV1:
                  showsEmbeddedFeedbackBelowTableV1,
            ),
      ),
    );
    final promptRevealPresentationV1 =
        resolveRunnerHostPromptRevealPresentationV1(
          RunnerHostPromptRevealPresentationInputV1(
            sourceId: hostCapabilityContractV1.promptSourceId,
            canonicalPrompt: spec.prompt,
            shortPromptOverride:
                _currentFactualHandChainPromptV1 ?? _currentChainStepV1?.prompt,
          ),
        );
    final factualHostContractV1 = showsSurfacedWorld2HostV1
        ? _buildWorld2SurfacedFactualHostContractV1(
            resolver: world2SurfacedFamilyResolverV1,
            presentation: promptRevealPresentationV1,
            hostCapabilityContractV1: hostCapabilityContractV1,
          )
        : _buildCurrentSurfacedFactualHostContractV1(
            presentation: promptRevealPresentationV1,
            hostCapabilityContractV1: hostCapabilityContractV1,
          );
    final topPromptTextV1 =
        factualHostContractV1?.shortPrompt ??
        promptRevealPresentationV1.shortPrompt;
    final postTableWidgetsV1 = showsSurfacedWorld2HostV1
        ? _buildWorld2NonFactualSurfacedPostTableWidgetsV1(context)
        : const <Widget>[];
    return _SessionDrillSurfacedPathWiringContractV1(
      hostCapabilityContract: hostCapabilityContractV1,
      factualHostContract: factualHostContractV1,
      topPromptText: topPromptTextV1,
      detailsPrompt: promptRevealPresentationV1.detailsPrompt,
      extrasSlots: SharedLearnerFamilyExtrasSlotsV1(
        beforePrimaryActionChildren: postTableWidgetsV1,
      ),
    );
  }

  _SessionDrillWorld2SurfacedFamilyAdapterV1?
  _buildSurfacedWorld2PathAdapterV1({
    required DrillSpecV1 spec,
    required bool showsSurfacedWorld2HostV1,
    required bool showsEmbeddedFeedbackBelowTableV1,
    required Widget embeddedTableV1,
    required Widget? actionSurfaceV1,
    required _SessionDrillSurfacedPathWiringContractV1 wiring,
    required _SessionDrillTeachingContractV1 teachingContractV1,
  }) {
    if (!showsSurfacedWorld2HostV1) {
      return null;
    }
    return _SessionDrillWorld2SurfacedFamilyAdapterV1(
      spec: spec,
      sessionTitle: teachingContractV1.headlineText,
      stepLabel: teachingContractV1.promptDetailsTitle,
      promptStatusText: teachingContractV1.promptStatusText,
      handoffStatusText: teachingContractV1.handoffStatusText,
      isCompactShowdownHeader: _isWorld2ShowdownScenarioPilotV1,
      prompt: wiring.factualHostContract?.detailsPrompt ?? wiring.detailsPrompt,
      compactPromptText: teachingContractV1.displayedPrompt,
      factualHostContract: wiring.factualHostContract,
      hostCapabilityContract: wiring.hostCapabilityContract,
      table: embeddedTableV1,
      actionSurface: actionSurfaceV1,
      extrasSlots: wiring.extrasSlots,
      showsEmbeddedFeedbackBelowTable: showsEmbeddedFeedbackBelowTableV1,
      teachingContract: teachingContractV1,
    );
  }

  RunnerHostSectionResponsibilityV1 _buildCurrentSurfacedSectionsV1({
    required bool showsEmbeddedFeedbackBelowTableV1,
  }) {
    final current = _currentDrill;
    if (current != null) {
      final world10TrackClusterContractV1 =
          _buildWorld10TrackClusterSurfaceContractV1(
            current.spec,
            showsEmbeddedFeedbackBelowTableV1:
                showsEmbeddedFeedbackBelowTableV1,
          );
      if (world10TrackClusterContractV1 != null) {
        return world10TrackClusterContractV1.sections;
      }
    }
    final family = _currentSurfacedFactualFamilyV1;
    if (family == null) {
      return const RunnerHostSectionResponsibilityV1();
    }
    return _buildSurfacedFamilyCoreContractV1(
      family: family,
      showsEmbeddedFeedbackBelowTableV1: showsEmbeddedFeedbackBelowTableV1,
    ).sections;
  }

  FactualRunnerHostContractV1? _buildWorld2SurfacedFactualHostContractV1({
    required _SessionDrillWorld2SurfacedFamilyResolverV1? resolver,
    required RunnerHostPromptRevealPresentationResolvedV1 presentation,
    required DrillHostCapabilityContractV1 hostCapabilityContractV1,
  }) {
    if (resolver == null) return null;
    return FactualRunnerHostContractV1(
      family: resolver.family,
      presentation: presentation,
      sections: hostCapabilityContractV1.sections,
      sourceMeta: RunnerHostSourceMetaContractV1(
        entries: resolver.sourceMetaEntries,
      ),
      supplements: resolver.supplements,
    );
  }

  FactualRunnerHostContractV1? _buildCurrentSurfacedFactualHostContractV1({
    required RunnerHostPromptRevealPresentationResolvedV1 presentation,
    required DrillHostCapabilityContractV1 hostCapabilityContractV1,
  }) {
    final family = _currentSurfacedFactualFamilyV1;
    if (family == null) return null;
    final core = _buildSurfacedFamilyCoreContractV1(
      family: family,
      showsEmbeddedFeedbackBelowTableV1:
          hostCapabilityContractV1.sections.showEmbeddedFeedbackBelowTable,
    );
    return FactualRunnerHostContractV1(
      family: family,
      presentation: presentation,
      sections: hostCapabilityContractV1.sections,
      sourceMeta: RunnerHostSourceMetaContractV1(
        entries: core.sourceMetaEntries,
      ),
      supplements: core.supplements,
    );
  }

  _SessionDrillSurfacedFamilyCoreContractV1 _buildSurfacedFamilyCoreContractV1({
    required FactualRunnerHostFamilyV1 family,
    required bool showsEmbeddedFeedbackBelowTableV1,
  }) {
    return _SessionDrillSurfacedFamilyCoreContractV1(
      sections: RunnerHostSectionResponsibilityV1(
        showIntro: switch (family) {
          FactualRunnerHostFamilyV1.position => _showWorld2PositionIntroCardV1,
          FactualRunnerHostFamilyV1.outs => _showWorld2OutsIntroCardV1,
          FactualRunnerHostFamilyV1.factualHandChain => false,
          FactualRunnerHostFamilyV1.initiative =>
            _showWorld2InitiativeIntroCardV1,
          FactualRunnerHostFamilyV1.texture =>
            _showWorld2BoardTextureIntroCardV1,
        },
        showSourceMeta: true,
        showRecap: switch (family) {
          FactualRunnerHostFamilyV1.position => _showWorld2PositionRecapCardV1,
          FactualRunnerHostFamilyV1.outs => _showWorld2OutsRecapCardV1,
          FactualRunnerHostFamilyV1.factualHandChain => false,
          FactualRunnerHostFamilyV1.initiative =>
            _showWorld2InitiativeRecapCardV1,
          FactualRunnerHostFamilyV1.texture =>
            _showWorld2BoardTextureRecapCardV1,
        },
        showEmbeddedFeedbackBelowTable: showsEmbeddedFeedbackBelowTableV1,
      ),
      sourceMetaEntries: _buildSurfacedSourceMetaEntriesForFamilyV1(family),
      supplements: _buildSurfacedSupplementContractForFamilyV1(family),
    );
  }

  FactualRunnerHostSupplementContractV1
  _buildSurfacedSupplementContractForFamilyV1(
    FactualRunnerHostFamilyV1 family,
  ) {
    switch (family) {
      case FactualRunnerHostFamilyV1.outs:
        return _buildWorld2OutsSupplementContractV1();
      case FactualRunnerHostFamilyV1.position:
        return _buildWorld2PositionSupplementContractV1();
      case FactualRunnerHostFamilyV1.initiative:
        return _buildWorld2InitiativeSupplementContractV1();
      case FactualRunnerHostFamilyV1.texture:
        return _buildWorld2TextureSupplementContractV1();
      case FactualRunnerHostFamilyV1.factualHandChain:
        return const FactualRunnerHostSupplementContractV1();
    }
  }

  FactualRunnerHostSupplementContractV1 _buildWorld2OutsSupplementContractV1() {
    if (!_showWorld2OutsIntroCardV1 && !_showWorld2OutsRecapCardV1) {
      return const FactualRunnerHostSupplementContractV1();
    }
    final intro = _currentDrill?.spec.scenarioCoreV1.introV1;
    final recap =
        _currentDrill?.spec.scenarioCoreV1.recapV1 ??
        (_drills.isNotEmpty ? _drills.last.spec.scenarioCoreV1.recapV1 : null);
    return FactualRunnerHostSupplementContractV1(
      introCards: <FactualRunnerHostSupplementCardV1>[
        if (_showWorld2OutsIntroCardV1)
          FactualRunnerHostSupplementCardV1(
            testKey: 'session_drill_player_world2_outs_intro_supplement_v1',
            eyebrow: 'Outs',
            title: 'Outs Bridge',
            body: [
              intro ??
                  'Outs are the unseen cards that improve your hand in a clear way.',
              'Count the improving cards first. Do not jump to math or odds yet.',
              'Cleaner draw boards give you clearer improvement paths than static made-hand boards.',
            ].join('\n'),
          ),
      ],
      recapCards: <FactualRunnerHostSupplementCardV1>[
        if (_showWorld2OutsRecapCardV1)
          FactualRunnerHostSupplementCardV1(
            testKey: 'session_drill_player_world2_outs_recap_supplement_v1',
            eyebrow: 'Outs',
            title: 'Outs Recap',
            body: [
              recap ??
                  'A flush draw usually has 9 outs. An open-ended straight draw usually has 8. A gutshot usually has 4.',
              'More coordinated boards create clearer improvement paths, which is why texture matters before equity math.',
            ].join('\n'),
          ),
      ],
    );
  }

  FactualRunnerHostSupplementContractV1
  _buildWorld2PositionSupplementContractV1() {
    if (!_showWorld2PositionIntroCardV1) {
      return const FactualRunnerHostSupplementContractV1();
    }
    final intro = _currentDrill?.spec.scenarioCoreV1.introV1;
    return FactualRunnerHostSupplementContractV1(
      introCards: <FactualRunnerHostSupplementCardV1>[
        if (_showWorld2PositionIntroCardV1)
          FactualRunnerHostSupplementCardV1(
            testKey: 'session_drill_player_world2_position_intro_supplement_v1',
            eyebrow: 'Position',
            title: 'Position Bridge',
            body: [
              intro ??
                  'Position means acting later after the flop, not just sitting in a different seat.',
              'Focus on who gets to see the other player act first.',
              'Acting later matters because you make the next decision with more information.',
            ].join('\n'),
          ),
      ],
      recapCards: const <FactualRunnerHostSupplementCardV1>[],
    );
  }

  FactualRunnerHostSupplementContractV1
  _buildWorld2InitiativeSupplementContractV1() {
    if (!_showWorld2InitiativeIntroCardV1 &&
        !_showWorld2InitiativeRecapCardV1) {
      return const FactualRunnerHostSupplementContractV1();
    }
    final intro = _currentDrill?.spec.scenarioCoreV1.introV1;
    final recap =
        _currentDrill?.spec.scenarioCoreV1.recapV1 ??
        (_drills.isNotEmpty ? _drills.last.spec.scenarioCoreV1.recapV1 : null);
    return FactualRunnerHostSupplementContractV1(
      introCards: <FactualRunnerHostSupplementCardV1>[
        if (_showWorld2InitiativeIntroCardV1)
          FactualRunnerHostSupplementCardV1(
            testKey:
                'session_drill_player_world2_initiative_intro_supplement_v1',
            eyebrow: 'Initiative',
            title: 'Initiative Bridge',
            body: [
              intro ??
                  'Initiative usually belongs to the player who made the last aggressive action.',
              'Focus on who raised last, not just who is still in the hand.',
              'That player is more likely to keep the pressure on the next street.',
            ].join('\n'),
          ),
      ],
      recapCards: <FactualRunnerHostSupplementCardV1>[
        if (_showWorld2InitiativeRecapCardV1)
          FactualRunnerHostSupplementCardV1(
            testKey:
                'session_drill_player_world2_initiative_recap_supplement_v1',
            eyebrow: 'Initiative',
            title: 'Initiative Recap',
            body: [
              recap ??
                  'The last aggressor usually keeps initiative on the next street.',
              'Initiative matters because that player is more likely to continue pressure first.',
            ].join('\n'),
          ),
      ],
    );
  }

  FactualRunnerHostSupplementContractV1
  _buildWorld2TextureSupplementContractV1() {
    if (!_showWorld2BoardTextureIntroCardV1 &&
        !_showWorld2BoardTextureRecapCardV1) {
      return const FactualRunnerHostSupplementContractV1();
    }
    final intro = _currentDrill?.spec.scenarioCoreV1.introV1;
    final recap =
        _currentDrill?.spec.scenarioCoreV1.recapV1 ??
        (_drills.isNotEmpty ? _drills.last.spec.scenarioCoreV1.recapV1 : null);
    return FactualRunnerHostSupplementContractV1(
      introCards: <FactualRunnerHostSupplementCardV1>[
        if (_showWorld2BoardTextureIntroCardV1)
          FactualRunnerHostSupplementCardV1(
            testKey: 'session_drill_player_world2_texture_intro_supplement_v1',
            eyebrow: 'Texture',
            title: 'Board Texture Bridge',
            body: [
              intro ??
                  'Some boards stay calm and dry. Others create more draws and pressure right away.',
              'Use CALL for the calmer board and RAISE for the more pressure-building board.',
              'You are not choosing a poker action here. You are classifying how much board pressure is building.',
            ].join('\n'),
          ),
      ],
      recapCards: <FactualRunnerHostSupplementCardV1>[
        if (_showWorld2BoardTextureRecapCardV1)
          FactualRunnerHostSupplementCardV1(
            testKey: 'session_drill_player_world2_texture_recap_supplement_v1',
            eyebrow: 'Texture',
            title: 'Texture Recap',
            body: [
              recap ??
                  'Dry or paired boards usually stay calmer. Connected two-tone boards build more pressure fast.',
              'That pressure matters because more draws and better turn cards can change the next decision.',
            ].join('\n'),
          ),
      ],
    );
  }

  Widget _buildFactualSupplementCardV1(
    BuildContext context,
    FactualRunnerHostSupplementCardV1 card, {
    required bool isIntro,
  }) {
    final theme = Theme.of(context);
    return Container(
      key: Key(card.testKey),
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isIntro ? 8 : 0, top: isIntro ? 0 : 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((card.eyebrow ?? '').isNotEmpty) ...[
            Text(
              card.eyebrow!,
              key: Key('${card.testKey}_eyebrow'),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            card.title,
            key: Key('${card.testKey}_title'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.body,
            key: Key('${card.testKey}_body'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSurfacedFactualFallbackWidgetsForSlotsV1(
    BuildContext context, {
    required List<SessionDrillFactualSupplementFallbackSlotV1> slots,
  }) {
    final widgets = <Widget>[];
    for (final slot in slots) {
      switch (slot) {
        case SessionDrillFactualSupplementFallbackSlotV1.positionIntro:
          widgets.add(_buildWorld2PositionIntroCardV1(context));
        case SessionDrillFactualSupplementFallbackSlotV1.outsIntro:
          widgets.add(_buildWorld2OutsIntroCardV1(context));
        case SessionDrillFactualSupplementFallbackSlotV1.initiativeIntro:
          widgets.add(_buildWorld2InitiativeIntroCardV1(context));
        case SessionDrillFactualSupplementFallbackSlotV1.textureIntro:
          widgets.add(_buildWorld2BoardTextureIntroCardV1(context));
        case SessionDrillFactualSupplementFallbackSlotV1.positionRecap:
          widgets.add(_buildWorld2PositionRecapCardV1(context));
        case SessionDrillFactualSupplementFallbackSlotV1.outsRecap:
          widgets.add(_buildWorld2OutsRecapCardV1(context));
        case SessionDrillFactualSupplementFallbackSlotV1.initiativeRecap:
          widgets.add(_buildWorld2InitiativeRecapCardV1(context));
        case SessionDrillFactualSupplementFallbackSlotV1.textureRecap:
          widgets.add(_buildWorld2BoardTextureRecapCardV1(context));
        case SessionDrillFactualSupplementFallbackSlotV1.sourceMeta:
          break;
      }
    }
    return widgets;
  }

  List<Widget> _buildSurfacedFactualIntroWidgetsV1(
    BuildContext context,
    FactualRunnerHostContractV1? contract,
  ) {
    if (contract == null || !contract.showIntro) return const <Widget>[];
    if (contract.introSupplementCards.isNotEmpty) {
      return contract.introSupplementCards
          .map(
            (card) =>
                _buildFactualSupplementCardV1(context, card, isIntro: true),
          )
          .toList(growable: false);
    }
    final fallbackV1 = buildSessionDrillCanonicalFactualSupplementFallbackV1(
      family: contract.family,
      showsIntro: contract.showIntro,
      showsRecap: contract.showRecap,
      authoredIntroPresent: contract.introSupplementCards.isNotEmpty,
      authoredRecapPresent: contract.recapSupplementCards.isNotEmpty,
      showsSourceMeta: contract.showsSourceMeta,
    );
    return _buildSurfacedFactualFallbackWidgetsForSlotsV1(
      context,
      slots: fallbackV1.introSlots,
    );
  }

  List<Widget> _buildSurfacedFactualPostTableExtraWidgetsV1(
    BuildContext context,
    FactualRunnerHostContractV1? contract,
  ) {
    if (contract == null || !contract.showRecap) return const <Widget>[];
    if (contract.recapSupplementCards.isNotEmpty) {
      return contract.recapSupplementCards
          .map(
            (card) =>
                _buildFactualSupplementCardV1(context, card, isIntro: false),
          )
          .toList(growable: false);
    }
    final fallbackV1 = buildSessionDrillCanonicalFactualSupplementFallbackV1(
      family: contract.family,
      showsIntro: contract.showIntro,
      showsRecap: contract.showRecap,
      authoredIntroPresent: contract.introSupplementCards.isNotEmpty,
      authoredRecapPresent: contract.recapSupplementCards.isNotEmpty,
      showsSourceMeta: contract.showsSourceMeta,
    );
    return _buildSurfacedFactualFallbackWidgetsForSlotsV1(
      context,
      slots: fallbackV1.recapSlots,
    );
  }

  List<Widget> _buildWorld2NonFactualSurfacedPostTableWidgetsV1(
    BuildContext context,
  ) {
    return <Widget>[
      if (_showWorld2ShowdownRecapCardV1)
        _buildWorld2ShowdownRecapCardV1(context),
      if (_showWorld2InitiativeRecapCardV1 &&
          !_isWorld2InitiativeScenarioPilotV1)
        _buildWorld2InitiativeRecapCardV1(context),
      if (_showWorld2BoardTextureRecapCardV1 &&
          !_isWorld2TextureScenarioPilotV1)
        _buildWorld2BoardTextureRecapCardV1(context),
      if (_showWorld2ReviewRecapCardV1) _buildWorld2ReviewRecapCardV1(context),
      if (_showWorld2CapstoneRecapCardV1)
        _buildWorld2CapstoneRecapCardV1(context),
      if (_showWorld2BlockCompletionReviewCardV1)
        _buildWorld2BlockCompletionReviewCardV1(context),
      if (_showWorld3BlockCompletionReviewCardV1)
        _buildWorld3BlockCompletionReviewCardV1(context),
      if (_showWorld4BlockCompletionReviewCardV1)
        _buildWorld4BlockCompletionReviewCardV1(context),
    ];
  }

  List<Widget> _buildSurfacedSupplementalWidgetsForSlotsV1(
    BuildContext context, {
    required List<SessionDrillSupplementalAssemblySlotV1> slots,
    required FactualRunnerHostContractV1? factualHostContractV1,
  }) {
    final widgets = <Widget>[];
    for (final slot in slots) {
      switch (slot) {
        case SessionDrillSupplementalAssemblySlotV1.world2ShowdownIntro:
          widgets.add(_buildWorld2ShowdownIntroCardV1(context));
        case SessionDrillSupplementalAssemblySlotV1.world3PreflopBridgeIntro:
          widgets.add(_buildWorld3PreflopBridgeIntroCardV1(context));
        case SessionDrillSupplementalAssemblySlotV1.world10TrackRootIntro:
          widgets.add(_buildWorld10TrackRootIntroCardV1(context));
        case SessionDrillSupplementalAssemblySlotV1.world2ShowdownScenarioMeta:
          widgets.add(_buildWorld2ShowdownScenarioMetaV1(context));
        case SessionDrillSupplementalAssemblySlotV1.factualIntroGroup:
          widgets.addAll(
            _buildSurfacedFactualIntroWidgetsV1(context, factualHostContractV1),
          );
        case SessionDrillSupplementalAssemblySlotV1.factualSourceMetaGroup:
          if (factualHostContractV1 != null) {
            widgets.add(
              _buildSurfacedSourceMetaBlockV1(
                context,
                factualHostContractV1.sourceMetaEntries,
              ),
            );
          }
        case SessionDrillSupplementalAssemblySlotV1.factualRecapGroup:
          widgets.addAll(
            _buildSurfacedFactualPostTableExtraWidgetsV1(
              context,
              factualHostContractV1,
            ),
          );
      }
    }
    return widgets;
  }

  _SessionDrillWorld2SurfacedHostContentContractV1
  _buildWorld2SurfacedHostContentContractV1(
    BuildContext context, {
    required DrillSpecV1 spec,
    required FactualRunnerHostContractV1? factualHostContractV1,
    required bool showsCompactSupplementalContextV1,
    required bool allowsCompactFactualIntroV1,
    required bool showsEmbeddedFeedbackBelowTableV1,
  }) {
    final world10TrackClusterContractV1 =
        _buildWorld10TrackClusterSurfaceContractV1(spec);
    final factualFallbackV1 = factualHostContractV1 == null
        ? null
        : buildSessionDrillCanonicalFactualSupplementFallbackV1(
            family: factualHostContractV1.family,
            showsIntro: factualHostContractV1.showIntro,
            showsRecap: factualHostContractV1.showRecap,
            authoredIntroPresent:
                factualHostContractV1.introSupplementCards.isNotEmpty,
            authoredRecapPresent:
                factualHostContractV1.recapSupplementCards.isNotEmpty,
            showsSourceMeta: factualHostContractV1.showsSourceMeta,
          );
    final supplementalAssemblyV1 =
        buildSessionDrillCanonicalSurfacedSupplementalAssemblyV1(
          showsCompactSupplementalContext: showsCompactSupplementalContextV1,
          allowsCompactFactualIntro: allowsCompactFactualIntroV1,
          showWorld2ShowdownIntro:
              _isWorld2ShowdownScenarioPilotV1 &&
              _showWorld2ShowdownIntroCardV1,
          showWorld3PreflopBridgeIntro: _showWorld3PreflopBridgeIntroCardV1,
          showWorld10TrackRootIntro:
              world10TrackClusterContractV1?.sections.showIntro ?? false,
          showWorld2ShowdownScenarioMeta: _isWorld2ShowdownScenarioPilotV1,
          factualContractPresent: factualHostContractV1 != null,
          factualShowsIntro: factualHostContractV1?.showIntro ?? false,
          factualShowsSourceMeta:
              factualFallbackV1?.showSourceMetaFallback ?? false,
          factualShowsRecap: factualHostContractV1?.showRecap ?? false,
          showsEmbeddedFeedbackBelowTable: showsEmbeddedFeedbackBelowTableV1,
          factualEmbeddedFeedbackBelowTable:
              factualHostContractV1?.showEmbeddedFeedbackBelowTable ?? false,
        );
    final preActionWidgetsV1 = _buildSurfacedSupplementalWidgetsForSlotsV1(
      context,
      slots: supplementalAssemblyV1.preActionSlots,
      factualHostContractV1: factualHostContractV1,
    );
    final postTableExtraWidgetsV1 = _buildSurfacedSupplementalWidgetsForSlotsV1(
      context,
      slots: supplementalAssemblyV1.postActionSlots,
      factualHostContractV1: factualHostContractV1,
    );
    return _SessionDrillWorld2SurfacedHostContentContractV1(
      showsEmbeddedFeedbackBelowTable:
          supplementalAssemblyV1.showsEmbeddedFeedbackBelowTable,
      extrasSlots: SharedLearnerFamilyExtrasSlotsV1(
        beforePrimaryActionChildren: postTableExtraWidgetsV1,
        afterPrimaryActionChildren: preActionWidgetsV1,
      ),
    );
  }

  _SessionDrillWorld2SurfacedHeaderPromptContractV1
  _buildWorld2SurfacedHeaderPromptContractV1({
    required _SessionDrillWorld2SurfacedFamilyAdapterV1 adapter,
    required _SessionDrillTeachingContractV1 teachingContractV1,
  }) {
    final sharedTeachingGrammarV1 = teachingContractV1.sharedTeachingGrammarV1;
    return _SessionDrillWorld2SurfacedHeaderPromptContractV1(
      handoffStatusText: sharedTeachingGrammarV1.headerStatusText,
      headlineText: sharedTeachingGrammarV1.headerHeadlineText,
      promptStatusText: null,
      promptText: sharedTeachingGrammarV1.headerPromptText,
      actingFocusLabel: _buildWorld2SurfacedActingFocusLabelV1(adapter.spec),
      promptSheetTitle: sharedTeachingGrammarV1.promptDetailsTitle,
      promptSheetBody: sharedTeachingGrammarV1.promptDetailsText,
      canReveal: sharedTeachingGrammarV1.canRevealPromptDetails,
      revealAffordanceEnabled:
          sharedTeachingGrammarV1.enablePromptDetailsAffordance,
    );
  }

  _SessionDrillWorld2SurfacedHeaderPromptContractV1
  _buildEmbeddedSurfacedHeaderPromptContractV1({
    required _SessionDrillTeachingContractV1 teachingContractV1,
  }) {
    final sharedTeachingGrammarV1 = teachingContractV1.sharedTeachingGrammarV1;
    return _SessionDrillWorld2SurfacedHeaderPromptContractV1(
      handoffStatusText: sharedTeachingGrammarV1.headerStatusText,
      headlineText: sharedTeachingGrammarV1.headerHeadlineText,
      promptStatusText: null,
      promptText: sharedTeachingGrammarV1.headerPromptText,
      actingFocusLabel: null,
      promptSheetTitle: sharedTeachingGrammarV1.promptDetailsTitle,
      promptSheetBody: sharedTeachingGrammarV1.promptDetailsText,
      canReveal: sharedTeachingGrammarV1.canRevealPromptDetails,
      revealAffordanceEnabled:
          sharedTeachingGrammarV1.enablePromptDetailsAffordance,
    );
  }

  Widget _buildSharedSurfacedHeaderPromptV1({
    required _SessionDrillWorld2SurfacedHeaderPromptContractV1 contract,
    required Key promptTextKey,
  }) {
    final promptDetailsGrammarV1 = SharedLearnerTeachingGrammarV1(
      headerStatusText: contract.handoffStatusText,
      headerHeadlineText: contract.headlineText,
      headerPromptText: contract.promptText,
      promptStatusText: contract.promptStatusText,
      displayedPrompt: contract.promptText,
      promptDetailsTitle: contract.promptSheetTitle,
      promptDetailsText: contract.promptSheetBody,
      canRevealPromptDetails: contract.canReveal,
      enablePromptDetailsAffordance: contract.revealAffordanceEnabled,
      supportPrimaryText: '',
      supportSecondaryText: '',
      supportTertiaryText: '',
      outcomePrimaryText: '',
      outcomeWhyText: '',
      outcomeNextText: '',
      outcomeDetailText: '',
    );
    void showCompactPromptSheetV1() {
      final sheetTheme = Theme.of(context);
      showSharedLearnerPromptRevealSheetV1(
        context: context,
        grammar: promptDetailsGrammarV1,
        style: SharedLearnerPromptRevealLauncherStyleV1(
          backgroundColor: AppColors.darkCard,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          sheetStyle: SharedLearnerTeachingPromptRevealSheetStyleV1(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
            detailsStyle: SharedLearnerTeachingPromptDetailsStyleV1(
              titleKey: const Key('session_drill_player_prompt_sheet_title'),
              bodyKey: const Key('session_drill_player_prompt_sheet_body'),
              titleStyle: sheetTheme.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w700,
              ),
              bodyStyle: sheetTheme.textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ),
      );
    }

    return SharedLearnerTeachingHeaderV1(
      grammar: promptDetailsGrammarV1,
      onOpenDetails: showCompactPromptSheetV1,
      style: SharedLearnerTeachingHeaderStyleV1(
        surfaceKey: const Key('session_drill_player_surfaced_header'),
        statusTextKey: const Key('session_drill_player_handoff_status_v1'),
        headlineTextKey: const Key('session_drill_player_header_title_v1'),
        promptSurfaceKey: const Key('session_drill_player_prompt_capsule_v1'),
        promptStatusTextKey: const Key('session_drill_player_status_header'),
        promptTextKey: promptTextKey,
        trailing: contract.actingFocusLabel == null
            ? null
            : _buildWorld2SurfacedActingFocusChipV1(contract.actingFocusLabel!),
        compact: true,
        surfaceColor: AppColors.surfaceVariant.withOpacity(0.20),
        borderColor: Colors.white.withOpacity(0.025),
        headlineColor: AppColors.textPrimaryDark,
        statusColor: AppColors.textSecondaryDark,
        promptForegroundColor: AppColors.textSecondaryDark,
        promptSurfaceColor: Colors.white.withOpacity(0.025),
        promptBorderColor: Colors.white.withOpacity(0.05),
        promptBadgeColor: Colors.white.withOpacity(0.055),
        promptPadding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
        maxPromptLines: 2,
        promptSoftWrap: true,
      ),
    );
  }

  String? _buildWorld2SurfacedActingFocusLabelV1(DrillSpecV1 spec) {
    final reconciledTruth = _embeddedReconciledTableTruthV1(spec);
    if (reconciledTruth == null) {
      return null;
    }
    final roleLabel = reconciledTruth
        .roleLabelsV1()?[reconciledTruth.actingSeatIndexV1];
    if (roleLabel != null && roleLabel.trim().isNotEmpty) {
      return 'ACTING $roleLabel';
    }
    final markerLabel = reconciledTruth.markerLabelsV1(
      includeSeatIdsV1: _isWorld9SeatIdProjectionPilotDrillV1(spec),
    )?[reconciledTruth.actingSeatIndexV1];
    if (markerLabel != null && markerLabel.trim().isNotEmpty) {
      return 'ACTING ${markerLabel.trim().toUpperCase()}';
    }
    return null;
  }

  Widget _buildWorld2SurfacedActingFocusChipV1(String label) {
    return DecoratedBox(
      key: const Key('session_drill_player_acting_focus_chip_v1'),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          label,
          key: const Key('session_drill_player_acting_focus_text_v1'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.18,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSurfacedWorld2TrainerSurfaceV1(
    BuildContext context, {
    required BoxConstraints constraints,
    required _SessionDrillWorld2SurfacedFamilyAdapterV1 adapter,
  }) {
    final theme = Theme.of(context);
    final isCompactShowdownHeaderV1 = adapter.isCompactShowdownHeader;
    final compactSurfacedPortraitV1 =
        constraints.maxHeight > constraints.maxWidth;
    final allowsCompactFactualIntroV1 =
        compactSurfacedPortraitV1 &&
        constraints.maxWidth <= 430 &&
        adapter.factualHostContract?.family == FactualRunnerHostFamilyV1.outs;
    final showsCompactSupplementalContextV1 =
        !compactSurfacedPortraitV1 || constraints.maxWidth > 430;
    final surfacedHeaderHeightV1 = compactSurfacedPortraitV1
        ? (constraints.maxHeight * (isCompactShowdownHeaderV1 ? 0.036 : 0.04))
              .clamp(28.0, 36.0)
        : double.nan;
    final minTableViewportHeightV1 = compactSurfacedPortraitV1
        ? (constraints.maxHeight * 0.74).clamp(552.0, 672.0)
        : 0.0;
    final defaultBottomBandMaxHeight =
        (constraints.maxHeight * kCanonicalLearnerBottomBandHeightFractionV1)
            .clamp(
              kCanonicalLearnerBottomBandMinHeightV1,
              kCanonicalLearnerBottomBandMaxHeightV1,
            );
    final bottomBandMaxHeight = allowsCompactFactualIntroV1
        ? (constraints.maxHeight * 0.24).clamp(176.0, 220.0)
        : defaultBottomBandMaxHeight;
    final surfacedHostContentContractV1 =
        _buildWorld2SurfacedHostContentContractV1(
          context,
          spec: adapter.spec,
          factualHostContractV1: adapter.factualHostContract,
          showsCompactSupplementalContextV1: showsCompactSupplementalContextV1,
          allowsCompactFactualIntroV1: allowsCompactFactualIntroV1,
          showsEmbeddedFeedbackBelowTableV1:
              adapter.showsEmbeddedFeedbackBelowTable,
        );
    final surfacedHeaderPromptContractV1 =
        _buildWorld2SurfacedHeaderPromptContractV1(
          adapter: adapter,
          teachingContractV1: adapter.teachingContract,
        );
    final surfacedShellContractV1 = _SessionDrillWorld2SurfacedShellContractV1(
      outerPadding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        isCompactShowdownHeaderV1 ? 1 : 2,
      ),
      borderRadius: BorderRadius.circular(isCompactShowdownHeaderV1 ? 20 : 18),
      shellGradientColors: isCompactShowdownHeaderV1
          ? [
              AppColors.darkCard.withOpacity(0.985),
              AppColors.surface.withOpacity(0.97),
            ]
          : [
              theme.colorScheme.surface.withValues(alpha: 0.985),
              theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.97),
            ],
      shadowColor:
          (isCompactShowdownHeaderV1
                  ? AppColors.shadow
                  : theme.colorScheme.shadow)
              .withValues(alpha: isCompactShowdownHeaderV1 ? 0.18 : 0.08),
      shadowBlurRadius: isCompactShowdownHeaderV1 ? 14 : 10,
      headerPadding: EdgeInsets.fromLTRB(7, 0, 7, 0),
      minTableViewportHeight: minTableViewportHeightV1,
      tableViewportPadding: EdgeInsets.fromLTRB(
        isCompactShowdownHeaderV1 ? 1 : 2,
        0,
        isCompactShowdownHeaderV1 ? 1 : 2,
        0,
      ),
      bottomBandMaxHeight: bottomBandMaxHeight,
      bottomBandPadding: kCanonicalLearnerBottomBandPaddingV1,
      supportLaneSurfaceColor: Colors.white.withValues(
        alpha: isCompactShowdownHeaderV1 ? 0.035 : 0.03,
      ),
      supportLaneBorderColor: Colors.white.withValues(alpha: 0.06),
      headerPrompt: surfacedHeaderPromptContractV1,
      hostContent: surfacedHostContentContractV1,
      table: adapter.table,
      actionSurface: adapter.actionSurface,
      extrasSlots: adapter.extrasSlots,
    );
    final extrasSlotsV1 = surfacedShellContractV1.hostContent.extrasSlots.merge(
      surfacedShellContractV1.extrasSlots,
    );
    return SharedLearnerCanonicalConsumerPathV1(
      shellContract: SurfacedLearnerHostShellContractV1(
        outerPadding: surfacedShellContractV1.outerPadding,
        borderRadius: surfacedShellContractV1.borderRadius,
        shellGradientColors: surfacedShellContractV1.shellGradientColors,
        shadowColor: surfacedShellContractV1.shadowColor,
        shadowBlurRadius: surfacedShellContractV1.shadowBlurRadius,
        headerPadding: surfacedShellContractV1.headerPadding,
        header: _buildSharedSurfacedHeaderPromptV1(
          contract: surfacedShellContractV1.headerPrompt,
          promptTextKey: const Key('session_drill_player_surfaced_prompt_v1'),
        ),
        body: const SizedBox.shrink(),
        bottomBandMaxHeight: surfacedShellContractV1.bottomBandMaxHeight,
        bottomBandPadding: surfacedShellContractV1.bottomBandPadding,
        bottomBandSurfaceKey: const Key(
          'session_drill_player_scene_support_lane_v1',
        ),
        bottomBandCompact: true,
        wrapBottomBandInSupportLane: true,
        bottomBandSurfaceColor: surfacedShellContractV1.supportLaneSurfaceColor,
        bottomBandBorderColor: surfacedShellContractV1.supportLaneBorderColor,
        bottomBandSafeAreaMinimum: kCanonicalLearnerBottomBandSafeAreaMinimumV1,
        bottomBandChild: SharedLearnerTeachingSectionStackV1(
          sectionSpacing: kCanonicalLearnerFeedbackActionGapV1,
          teachingBlock:
              surfacedShellContractV1
                  .hostContent
                  .showsEmbeddedFeedbackBelowTable
              ? SizedBox(
                  key: const Key('session_drill_player_feedback_block_v1'),
                  width: double.infinity,
                  child: _buildFeedbackBlockV1(
                    context,
                    teachingContractV1: adapter.teachingContract,
                  ),
                )
              : null,
          localBlocksBeforeAction: <Widget>[
            SharedLearnerActionSurfaceOwnerV1(
              preActionChildren: <Widget>[
                ...extrasSlotsV1.beforePrimaryActionChildren,
              ],
              postActionChildren: extrasSlotsV1.afterPrimaryActionChildren,
              localPolicyBoundary:
                  const SharedLearnerLocalPolicyBoundaryV1.hidden(),
              buildPrimaryActionSurface: (_, __) =>
                  surfacedShellContractV1.actionSurface,
              buildTrailingContinuation: (_, __) => null,
            ),
          ],
        ),
      ),
      frameViewportRegion: Expanded(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: surfacedShellContractV1.minTableViewportHeight,
          ),
          child: Padding(
            key: const Key('session_drill_player_table_viewport'),
            padding: surfacedShellContractV1.tableViewportPadding,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 1),
              child: surfacedShellContractV1.table,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSharedEmbeddedScenarioFrameSurfaceV1({
    required Widget topSection,
    required Widget embeddedTable,
    required bool showsEmbeddedFeedbackBelowTable,
    required _SessionDrillTeachingContractV1 teachingContractV1,
    required SharedLearnerFamilyExtrasSlotsV1 extrasSlots,
    required Widget? actionSurface,
    required SharedLearnerLocalPolicyBoundaryV1 localPolicyBoundary,
  }) {
    return SharedLearnerTableAdjacentFrameV1(
      topRegion: topSection,
      viewportRegion: Expanded(child: embeddedTable),
      bottomRegion: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildBottomSectionContinuationChildrenV1(
          context: context,
          showsEmbeddedFeedbackBelowTable: showsEmbeddedFeedbackBelowTable,
          teachingContractV1: teachingContractV1,
          extrasSlots: extrasSlots,
          actionSurface: actionSurface,
          localPolicyBoundary: localPolicyBoundary,
        ),
      ),
    );
  }

  List<Widget> _buildBottomSectionContinuationChildrenV1({
    required BuildContext context,
    required bool showsEmbeddedFeedbackBelowTable,
    required _SessionDrillTeachingContractV1 teachingContractV1,
    required SharedLearnerFamilyExtrasSlotsV1 extrasSlots,
    required Widget? actionSurface,
    required SharedLearnerLocalPolicyBoundaryV1 localPolicyBoundary,
  }) {
    final continuationState = localPolicyBoundary.continuationState;
    final routeCompletionBoundary = localPolicyBoundary.routeCompletionBoundary;
    final useTextLedReviewModeCohesion =
        _showWorld2ReviewIntroCardV1 || _showWorld2ReviewRecapCardV1;
    final reviewCompletionSupportChild =
        continuationState.visualState ==
                SharedLearnerContinuationVisualStateV1.completionLike &&
            _showWorld2ReviewRecapCardV1
        ? Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: _buildWorld2ReviewRecapCardV1(context),
          )
        : null;
    final trailingContinuationChild = switch (continuationState.visualState) {
      SharedLearnerContinuationVisualStateV1.hidden => null,
      SharedLearnerContinuationVisualStateV1.completionLike =>
        _buildCompletionContinuationSurfaceV1(context),
      SharedLearnerContinuationVisualStateV1.resetLike => Row(
        children: [
          OutlinedButton(
            onPressed: routeCompletionBoundary.primaryAction.onPressed,
            child: Text(routeCompletionBoundary.primaryAction.label),
          ),
        ],
      ),
      _ => null,
    };
    return [
      if (showsEmbeddedFeedbackBelowTable)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
          child: SizedBox(
            width: double.infinity,
            child: _buildFeedbackBlockV1(
              context,
              teachingContractV1: teachingContractV1,
              surfaceKey: useTextLedReviewModeCohesion
                  ? const Key('session_drill_player_feedback_block_surface_v1')
                  : null,
              useTextLedNarrativeDecoration: useTextLedReviewModeCohesion,
            ),
          ),
        ),
      SharedLearnerActionSurfaceOwnerV1(
        preActionChildren: extrasSlots.beforePrimaryActionChildren,
        postActionChildren: <Widget>[
          ...extrasSlots.afterPrimaryActionChildren,
          if (reviewCompletionSupportChild != null)
            reviewCompletionSupportChild,
        ],
        localPolicyBoundary: localPolicyBoundary,
        buildPrimaryActionSurface: (_, __) => actionSurface,
        buildTrailingContinuation: (_, __) => trailingContinuationChild,
      ),
    ];
  }

  Widget _buildWorld10TrackTopSectionContentV1({
    required _SessionDrillWorld10TrackTopSectionContractV1 contract,
    required bool showsEmbeddedScenarioTableV1,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (contract.handoffStatusLine != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              contract.handoffStatusLine!,
              key: const Key('session_drill_player_handoff_status_v1'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.18,
              ),
            ),
          ),
        if (contract.showsCompletedState)
          const Text(
            'Session complete',
            key: Key('session_drill_player_complete'),
          )
        else
          Text(
            contract.statusHeaderText,
            key: const Key('session_drill_player_status_header'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.22,
            ),
          ),
        const SizedBox(height: 4),
        if (contract.showsIntroCard) _buildWorld10TrackRootIntroCardV1(context),
        Text(
          contract.promptText,
          key: const Key('session_drill_player_prompt'),
          style: showsEmbeddedScenarioTableV1
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.06,
                )
              : null,
        ),
        if (contract.showsFeedbackAboveTable) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildFeedbackBlockV1(
              context,
              teachingContractV1: contract.teachingContract,
            ),
          ),
        ],
      ],
    );
  }

  _SessionDrillWorld10TrackTopSectionContractV1?
  _buildWorld10TrackTopSectionContractV1({
    required _SessionDrillWorld10TrackClusterSurfaceContractV1?
    world10TrackClusterContractV1,
    required bool showsEmbeddedFeedbackBelowTableV1,
    required _SessionDrillTeachingContractV1 teachingContractV1,
  }) {
    if (world10TrackClusterContractV1 == null) {
      return null;
    }
    return _SessionDrillWorld10TrackTopSectionContractV1(
      handoffStatusLine:
          teachingContractV1.handoffStatusText != null && !_completed
          ? teachingContractV1.handoffStatusText
          : null,
      showsCompletedState: _completed,
      statusHeaderText: teachingContractV1.statusHeaderText,
      showsIntroCard: world10TrackClusterContractV1.sections.showIntro,
      promptText: teachingContractV1.displayedPrompt,
      showsFeedbackAboveTable: !showsEmbeddedFeedbackBelowTableV1,
      teachingContract: teachingContractV1,
    );
  }

  Widget _buildGenericTopSectionContentV1({
    required BuildContext context,
    required _SessionDrillTeachingContractV1 teachingContractV1,
    required SessionDrillCanonicalTopSectionContentPolicyV1 policyV1,
  }) {
    final theme = Theme.of(context);
    final useTextLedReviewModeCohesion = policyV1.showTextLedReviewModeCohesion;
    final leadingSupportChildren = <Widget>[
      if (policyV1.showWorld2ReviewIntroCard)
        _buildWorld2ReviewIntroCardV1(context),
    ];
    final supplementalChildren = _buildGenericTopSectionSupplementalChildrenV1(
      context: context,
      teachingContractV1: teachingContractV1,
      policyV1: policyV1,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (policyV1.showHandoffStatusLine)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              teachingContractV1.handoffStatusText!,
              key: const Key('session_drill_player_handoff_status_v1'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.18,
              ),
            ),
          ),
        if (policyV1.showCompletedState)
          const Text(
            'Session complete',
            key: Key('session_drill_player_complete'),
          )
        else
          Text(
            teachingContractV1.statusHeaderText,
            key: const Key('session_drill_player_status_header'),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: policyV1.statusLetterSpacing,
            ),
          ),
        SizedBox(height: policyV1.statusSpacingAfter),
        ...leadingSupportChildren,
        if (useTextLedReviewModeCohesion)
          _buildTextLedNarrativeCardV1(
            key: const Key('session_drill_player_text_led_prompt_card_v1'),
            margin: const EdgeInsets.only(top: 2),
            child: Text(
              teachingContractV1.displayedPrompt,
              key: const Key('session_drill_player_prompt'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: SharkyTokensV1.textPrimary,
              ),
            ),
          )
        else
          Text(
            teachingContractV1.displayedPrompt,
            key: const Key('session_drill_player_prompt'),
            style: policyV1.showPromptAsEmbeddedTitle
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.06,
                  )
                : null,
          ),
        ...supplementalChildren,
      ],
    );
  }

  Widget _buildEmbeddedSurfacedTopChromeV1({
    required _SessionDrillTeachingContractV1 teachingContractV1,
  }) {
    final contract = _buildEmbeddedSurfacedHeaderPromptContractV1(
      teachingContractV1: teachingContractV1,
    );
    return _buildSharedSurfacedHeaderPromptV1(
      contract: contract,
      promptTextKey: const Key('session_drill_player_prompt'),
    );
  }

  List<Widget> _buildGenericTopSectionSupplementalChildrenV1({
    required BuildContext context,
    required _SessionDrillTeachingContractV1 teachingContractV1,
    required SessionDrillCanonicalTopSectionContentPolicyV1 policyV1,
  }) {
    return <Widget>[
      if (policyV1.showBetSizingIntroCard) _buildBetSizingIntroCardV1(context),
      if (policyV1.showWorld2ShowdownIntroCard)
        _buildWorld2ShowdownIntroCardV1(context),
      if (policyV1.showWorld3PreflopBridgeIntroCard)
        _buildWorld3PreflopBridgeIntroCardV1(context),
      if (policyV1.showWorld10TrackRootIntroCard)
        _buildWorld10TrackRootIntroCardV1(context),
      if (policyV1.showWorld2PositionIntroCard)
        _buildWorld2PositionIntroCardV1(context),
      if (policyV1.showWorld2InitiativeIntroCard)
        _buildWorld2InitiativeIntroCardV1(context),
      if (policyV1.showWorld2BoardTextureIntroCard)
        _buildWorld2BoardTextureIntroCardV1(context),
      if (policyV1.showWorld2OutsIntroCard)
        _buildWorld2OutsIntroCardV1(context),
      if (policyV1.showWorld2ShowdownScenarioMeta)
        _buildWorld2ShowdownScenarioMetaV1(context),
      if (policyV1.showWorld2PositionScenarioMeta)
        _buildWorld2PositionScenarioMetaV1(context),
      if (policyV1.showWorld2InitiativeScenarioMeta)
        _buildWorld2InitiativeScenarioMetaV1(context),
      if (policyV1.showWorld2OutsScenarioMeta)
        _buildWorld2OutsScenarioMetaV1(context),
      if (policyV1.showWorld2TextureScenarioMeta)
        _buildWorld2TextureScenarioMetaV1(context),
      if (policyV1.showHandChainScenarioMeta)
        _buildHandChainScenarioMetaV1(context),
      if (policyV1.showFeedbackAboveTable) ...[
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: _buildFeedbackBlockV1(
            context,
            teachingContractV1: teachingContractV1,
            surfaceKey: policyV1.showTextLedReviewModeCohesion
                ? const Key('session_drill_player_feedback_block_surface_v1')
                : null,
            useTextLedNarrativeDecoration:
                policyV1.showTextLedReviewModeCohesion,
          ),
        ),
      ],
      if (policyV1.showBetSizingRecapCard) _buildBetSizingRecapCardV1(context),
      if (policyV1.showWorld2ShowdownRecapCard)
        _buildWorld2ShowdownRecapCardV1(context),
      if (policyV1.showWorld2PositionRecapCard)
        _buildWorld2PositionRecapCardV1(context),
      if (policyV1.showWorld2InitiativeRecapCard)
        _buildWorld2InitiativeRecapCardV1(context),
      if (policyV1.showWorld2BoardTextureRecapCard)
        _buildWorld2BoardTextureRecapCardV1(context),
      if (policyV1.showWorld2ReviewRecapCard)
        _buildWorld2ReviewRecapCardV1(context),
      if (policyV1.showWorld2OutsRecapCard)
        _buildWorld2OutsRecapCardV1(context),
      if (policyV1.showWorld2CapstoneRecapCard)
        _buildWorld2CapstoneRecapCardV1(context),
      if (policyV1.showWorld2BlockCompletionReviewCard)
        _buildWorld2BlockCompletionReviewCardV1(context),
      if (policyV1.showWorld3BlockCompletionReviewCard)
        _buildWorld3BlockCompletionReviewCardV1(context),
      if (policyV1.showWorld4BlockCompletionReviewCard)
        _buildWorld4BlockCompletionReviewCardV1(context),
    ];
  }

  Widget _buildTopSectionSurfaceV1({
    required BuildContext context,
    required DrillSpecV1 spec,
    required _SessionDrillTeachingContractV1 teachingContractV1,
    required double topSectionMaxHeight,
    required SessionDrillCanonicalRenderSurfaceFamilyV1 renderSurfaceFamilyV1,
    required SessionDrillCanonicalTopSectionContentPolicyV1
    topSectionContentPolicyV1,
    required bool showsEmbeddedScenarioTableV1,
    required bool showsEmbeddedFeedbackBelowTableV1,
    required _SessionDrillWorld10TrackClusterSurfaceContractV1?
    world10TrackClusterContractV1,
    required _SessionDrillWorld10TrackTopSectionContractV1?
    world10TopSectionContractV1,
  }) {
    final theme = Theme.of(context);
    final usesEmbeddedSurfacedHeaderV1 =
        renderSurfaceFamilyV1 ==
            SessionDrillCanonicalRenderSurfaceFamilyV1.generic &&
        showsEmbeddedScenarioTableV1;
    final supplementalChildren = usesEmbeddedSurfacedHeaderV1
        ? _buildGenericTopSectionSupplementalChildrenV1(
            context: context,
            teachingContractV1: teachingContractV1,
            policyV1: topSectionContentPolicyV1,
          )
        : const <Widget>[];
    final supplementalContentV1 = supplementalChildren.isEmpty
        ? null
        : DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.42,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.46),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: supplementalChildren,
              ),
            ),
          );
    if (usesEmbeddedSurfacedHeaderV1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: _buildEmbeddedSurfacedTopChromeV1(
              teachingContractV1: teachingContractV1,
            ),
          ),
          if (supplementalContentV1 != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
              child: supplementalContentV1,
            ),
        ],
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: topSectionMaxHeight),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          12,
          renderSurfaceFamilyV1 ==
                  SessionDrillCanonicalRenderSurfaceFamilyV1.world2Surfaced
              ? 4
              : 6,
          12,
          renderSurfaceFamilyV1 ==
                  SessionDrillCanonicalRenderSurfaceFamilyV1.world2Surfaced
              ? 0
              : 2,
        ),
        child: DecoratedBox(
          decoration:
              renderSurfaceFamilyV1 ==
                  SessionDrillCanonicalRenderSurfaceFamilyV1.world2Surfaced
              ? const BoxDecoration()
              : showsEmbeddedScenarioTableV1
              ? BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.42,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.46,
                    ),
                  ),
                )
              : const BoxDecoration(),
          child: Padding(
            padding:
                renderSurfaceFamilyV1 ==
                    SessionDrillCanonicalRenderSurfaceFamilyV1.world2Surfaced
                ? const EdgeInsets.fromLTRB(2, 0, 2, 0)
                : showsEmbeddedScenarioTableV1
                ? const EdgeInsets.fromLTRB(12, 8, 12, 8)
                : EdgeInsets.zero,
            child:
                renderSurfaceFamilyV1 ==
                    SessionDrillCanonicalRenderSurfaceFamilyV1
                        .world10TrackFinite
                ? _buildWorld10TrackTopSectionContentV1(
                    contract: world10TopSectionContractV1!,
                    showsEmbeddedScenarioTableV1: showsEmbeddedScenarioTableV1,
                  )
                : _buildGenericTopSectionContentV1(
                    context: context,
                    teachingContractV1: teachingContractV1,
                    policyV1: topSectionContentPolicyV1,
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_usesWorld1AdapterLaunchV1) {
      final runtimeConfigV1 = _world1RuntimeConfigV1!;
      return World1FoundationsMicroTaskRunnerScreen(
        moduleId: widget.sessionId,
        moduleTitle: runtimeConfigV1.moduleTitleV1!,
        hostShellControllerV1: _world1HostShellControllerV1,
        resolvedHostLaunchV1: _world1ResolvedHostLaunchV1,
        mode: runtimeConfigV1.modeV1!,
        startHandIndex: runtimeConfigV1.startHandIndexV1,
        checkpointId: runtimeConfigV1.checkpointIdV1,
        hintsEnabledV1: runtimeConfigV1.hintsEnabledV1,
        instructionSourceV1: runtimeConfigV1.instructionSourceV1,
      );
    }
    final current = _currentDrill;
    final showsEmbeddedScenarioTableV1 =
        current != null && _shouldShowEmbeddedScenarioTableV1(current.spec);
    final usesEmbeddedSurfacedChromeReductionV1 =
        showsEmbeddedScenarioTableV1 &&
        (current == null ||
            _buildWorld10TrackClusterSurfaceContractV1(current.spec) == null);
    final surfaceSelectionV1 =
        buildSessionDrillCanonicalSurfaceSelectionStateV1(
          showsEmbeddedScenarioTable: showsEmbeddedScenarioTableV1,
          isWorld2SurfacedScenarioSession: _isWorld2SurfacedScenarioSessionV1,
          isCompleted: _completed,
        );
    if (current != null) {
      _assertWorld2ShowdownScenarioPayloadV1(current.spec);
      _assertWorld2TextureScenarioPayloadV1(current.spec);
      _assertWorld2PositionScenarioPayloadV1(current.spec);
      _assertWorld2InitiativeScenarioPayloadV1(current.spec);
      _assertWorld2OutsScenarioPayloadV1(current.spec);
      _assertWorld2HandChainScenarioPayloadV1(current.spec);
    }
    return SharedLearnerTopLevelShellV1(
      contract: SharedLearnerTopLevelShellContractV1(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: usesEmbeddedSurfacedChromeReductionV1
              ? Colors.transparent
              : AppColors.darkBackground,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: usesEmbeddedSurfacedChromeReductionV1
              ? 40
              : (_isWorld2ShowdownScenarioPilotV1 ? 46 : kToolbarHeight),
          titleSpacing: usesEmbeddedSurfacedChromeReductionV1
              ? 0
              : (_isWorld2ShowdownScenarioPilotV1 ? 12 : null),
          title: usesEmbeddedSurfacedChromeReductionV1
              ? null
              : Text(
                  _surfaceSessionTitleV1(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        wrapBodyInSafeArea: false,
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _loadError!,
                  key: const Key('session_drill_player_load_error'),
                ),
              ),
            )
          : current == null
          ? const Center(child: Text('No drills found'))
          : LayoutBuilder(
              builder: (context, constraints) {
                final theme = Theme.of(context);
                final showsSurfacedWorld2HostV1 =
                    surfaceSelectionV1.showsSurfacedWorld2Host;
                final showsEmbeddedFeedbackBelowTableV1 =
                    surfaceSelectionV1.showsEmbeddedFeedbackBelowTable;
                final usesHandChainEmbeddedScenarioTopSectionV1 =
                    current.spec.kind == DrillKindV1.handChain &&
                    surfaceSelectionV1.topSectionDensity ==
                        SessionDrillCanonicalTopSectionDensityV1
                            .embeddedScenario;
                final topSectionMaxHeight = switch (surfaceSelectionV1
                    .topSectionDensity) {
                  SessionDrillCanonicalTopSectionDensityV1.world2Surfaced =>
                    (constraints.maxHeight * 0.088).clamp(54.0, 76.0),
                  SessionDrillCanonicalTopSectionDensityV1.embeddedScenario =>
                    usesHandChainEmbeddedScenarioTopSectionV1
                        ? (constraints.maxHeight * 0.17).clamp(112.0, 150.0)
                        : (constraints.maxHeight * 0.115).clamp(72.0, 108.0),
                  SessionDrillCanonicalTopSectionDensityV1.generic =>
                    double.infinity,
                };
                final surfacedPathWiringV1 = _buildSurfacedPathWiringContractV1(
                  spec: current.spec,
                  showsSurfacedWorld2HostV1: showsSurfacedWorld2HostV1,
                  showsEmbeddedScenarioTableV1: showsEmbeddedScenarioTableV1,
                  showsEmbeddedFeedbackBelowTableV1:
                      showsEmbeddedFeedbackBelowTableV1,
                  context: context,
                );
                final hostCapabilityContractV1 =
                    surfacedPathWiringV1.hostCapabilityContract;
                final renderOrchestrationV1 =
                    _buildRenderOrchestrationContractV1(
                      spec: current.spec,
                      showsEmbeddedFeedbackBelowTableV1:
                          showsEmbeddedFeedbackBelowTableV1,
                      hostCapabilityContractV1: hostCapabilityContractV1,
                    );
                final factualHostContractV1 =
                    surfacedPathWiringV1.factualHostContract;
                final topPromptTextV1 = surfacedPathWiringV1.topPromptText;
                final teachingContractV1 = _buildSessionDrillTeachingContractV1(
                  spec: current.spec,
                  wiring: surfacedPathWiringV1,
                );
                final world10TopSectionContractV1 =
                    _buildWorld10TrackTopSectionContractV1(
                      world10TrackClusterContractV1:
                          renderOrchestrationV1.world10TrackCluster,
                      showsEmbeddedFeedbackBelowTableV1:
                          showsEmbeddedFeedbackBelowTableV1,
                      teachingContractV1: teachingContractV1,
                    );
                final embeddedTableV1 = _buildEmbeddedScenarioTableSurfaceV1(
                  spec: current.spec,
                  constraints: constraints,
                  showsEmbeddedScenarioTableV1: showsEmbeddedScenarioTableV1,
                  showsSurfacedWorld2HostV1: showsSurfacedWorld2HostV1,
                  topPromptTextV1: topPromptTextV1,
                );
                final surfacedWorld2AdapterV1 =
                    _buildSurfacedWorld2PathAdapterV1(
                      spec: current.spec,
                      showsSurfacedWorld2HostV1: showsSurfacedWorld2HostV1,
                      showsEmbeddedFeedbackBelowTableV1:
                          showsEmbeddedFeedbackBelowTableV1,
                      embeddedTableV1: embeddedTableV1,
                      actionSurfaceV1: renderOrchestrationV1.actionSurface,
                      wiring: surfacedPathWiringV1,
                      teachingContractV1: teachingContractV1,
                    );
                final renderSurfaceFamilyV1 =
                    resolveSessionDrillCanonicalRenderSurfaceFamilyV1(
                      hasSurfacedWorld2Adapter: surfacedWorld2AdapterV1 != null,
                      hasWorld10TrackCluster:
                          renderOrchestrationV1.world10TrackCluster != null,
                    );
                final topSectionContentPolicyV1 =
                    buildSessionDrillCanonicalTopSectionContentPolicyV1(
                      renderSurfaceFamily: renderSurfaceFamilyV1,
                      handoffContextPresent: widget.handoffContextV1 != null,
                      isCompleted: _completed,
                      showsEmbeddedScenarioTable: showsEmbeddedScenarioTableV1,
                      showsEmbeddedFeedbackBelowTable:
                          showsEmbeddedFeedbackBelowTableV1,
                      specKind: current.spec.kind,
                      showBetSizingIntroCard: _showBetSizingIntroCardV1,
                      showWorld2ShowdownIntroCard:
                          _showWorld2ShowdownIntroCardV1,
                      showWorld3PreflopBridgeIntroCard:
                          _showWorld3PreflopBridgeIntroCardV1,
                      showWorld10TrackRootIntroCard:
                          renderOrchestrationV1
                              .world10TrackCluster
                              ?.sections
                              .showIntro ??
                          false,
                      showWorld2PositionIntroCard:
                          _showWorld2PositionIntroCardV1,
                      showWorld2InitiativeIntroCard:
                          _showWorld2InitiativeIntroCardV1,
                      showWorld2BoardTextureIntroCard:
                          _showWorld2BoardTextureIntroCardV1,
                      showWorld2ReviewIntroCard: _showWorld2ReviewIntroCardV1,
                      showWorld2OutsIntroCard: _showWorld2OutsIntroCardV1,
                      showWorld2ShowdownScenarioMeta:
                          _isWorld2ShowdownScenarioPilotV1,
                      showWorld2PositionScenarioMeta:
                          _isWorld2PositionScenarioPilotV1,
                      showWorld2InitiativeScenarioMeta:
                          _isWorld2InitiativeScenarioPilotV1,
                      showWorld2OutsScenarioMeta: _isWorld2OutsScenarioPilotV1,
                      showWorld2TextureScenarioMeta:
                          _isWorld2TextureScenarioPilotV1,
                      showBetSizingRecapCard: _showBetSizingRecapCardV1,
                      showWorld2ShowdownRecapCard:
                          _showWorld2ShowdownRecapCardV1,
                      showWorld2PositionRecapCard:
                          _showWorld2PositionRecapCardV1,
                      showWorld2InitiativeRecapCard:
                          _showWorld2InitiativeRecapCardV1,
                      showWorld2BoardTextureRecapCard:
                          _showWorld2BoardTextureRecapCardV1,
                      showWorld2ReviewRecapCard: _showWorld2ReviewRecapCardV1,
                      showWorld2OutsRecapCard: _showWorld2OutsRecapCardV1,
                      showWorld2CapstoneRecapCard:
                          _showWorld2CapstoneRecapCardV1,
                      showWorld2BlockCompletionReviewCard:
                          _showWorld2BlockCompletionReviewCardV1,
                      showWorld3BlockCompletionReviewCard:
                          _showWorld3BlockCompletionReviewCardV1,
                      showWorld4BlockCompletionReviewCard:
                          _showWorld4BlockCompletionReviewCardV1,
                    );
                final topSectionV1 = _buildTopSectionSurfaceV1(
                  context: context,
                  spec: current.spec,
                  teachingContractV1: teachingContractV1,
                  topSectionMaxHeight: topSectionMaxHeight,
                  renderSurfaceFamilyV1: renderSurfaceFamilyV1,
                  topSectionContentPolicyV1: topSectionContentPolicyV1,
                  showsEmbeddedScenarioTableV1: showsEmbeddedScenarioTableV1,
                  showsEmbeddedFeedbackBelowTableV1:
                      showsEmbeddedFeedbackBelowTableV1,
                  world10TrackClusterContractV1:
                      renderOrchestrationV1.world10TrackCluster,
                  world10TopSectionContractV1: world10TopSectionContractV1,
                );
                return _buildSurfacedRenderSurfaceV1(
                  context: context,
                  constraints: constraints,
                  contract: _buildSurfacedRenderInputContractV1(
                    surfacedWorld2Adapter: surfacedWorld2AdapterV1,
                    orchestration: renderOrchestrationV1,
                    topSection: topSectionV1,
                    embeddedTable: embeddedTableV1,
                    showsEmbeddedFeedbackBelowTable:
                        showsEmbeddedFeedbackBelowTableV1,
                    teachingContract: teachingContractV1,
                    extrasSlots: surfacedPathWiringV1.extrasSlots,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSurfacedRenderSurfaceV1({
    required BuildContext context,
    required BoxConstraints constraints,
    required _SessionDrillSurfacedRenderInputContractV1 contract,
  }) {
    final renderSurfaceFamilyV1 =
        resolveSessionDrillCanonicalRenderSurfaceFamilyV1(
          hasSurfacedWorld2Adapter: contract.surfacedWorld2Adapter != null,
          hasWorld10TrackCluster: contract.world10TrackCluster != null,
        );
    switch (renderSurfaceFamilyV1) {
      case SessionDrillCanonicalRenderSurfaceFamilyV1.world2Surfaced:
        return _buildSurfacedWorld2TrainerSurfaceV1(
          context,
          constraints: constraints,
          adapter: contract.surfacedWorld2Adapter!,
        );
      case SessionDrillCanonicalRenderSurfaceFamilyV1.world10TrackFinite:
      case SessionDrillCanonicalRenderSurfaceFamilyV1.generic:
        return _buildSharedEmbeddedScenarioFrameSurfaceV1(
          topSection: contract.topSection,
          embeddedTable: contract.embeddedTable,
          showsEmbeddedFeedbackBelowTable:
              contract.showsEmbeddedFeedbackBelowTable,
          teachingContractV1: contract.teachingContract,
          extrasSlots: contract.extrasSlots,
          actionSurface: contract.actionSurface,
          localPolicyBoundary: contract.localPolicyBoundary,
        );
    }
  }

  Widget _buildEmbeddedScenarioTableSurfaceV1({
    required DrillSpecV1 spec,
    required BoxConstraints constraints,
    required bool showsEmbeddedScenarioTableV1,
    required bool showsSurfacedWorld2HostV1,
    required String topPromptTextV1,
  }) {
    if (!showsEmbeddedScenarioTableV1) {
      return const SizedBox.shrink();
    }
    final usesSharedLiveCompatibleFamilyV1 =
        constraints.maxHeight > constraints.maxWidth;
    final visualFamilyV1 = resolveSharedEmbeddedTableVisualFamilyV1(
      preset: usesSharedLiveCompatibleFamilyV1
          ? SharedEmbeddedTableVisualFamilyPresetV1.surfacedLiveCompatible
          : SharedEmbeddedTableVisualFamilyPresetV1.surfacedLegacyEmbedded,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        showsSurfacedWorld2HostV1 && _isWorld2ShowdownScenarioPilotV1 ? 4 : 8,
        showsSurfacedWorld2HostV1 ? 0 : 2,
        showsSurfacedWorld2HostV1 && _isWorld2ShowdownScenarioPilotV1 ? 4 : 8,
        0,
      ),
      child: KeyedSubtree(
        key: _embeddedScenarioResetKeyV1(spec),
        child: ModernTableScreenV1(
          embeddedV1: true,
          key: _embeddedScenarioTableKeyV1(spec),
          embeddedSceneGeometryProfileV1:
              visualFamilyV1.embeddedSceneGeometryProfileV1,
          seatStateVisualProfileV1: visualFamilyV1.seatStateVisualProfileV1,
          sceneLanePromptProfileV1: visualFamilyV1.sceneLanePromptProfileV1,
          useReferenceParityLiveProfileV1:
              visualFamilyV1.useReferenceParityLiveProfileV1,
          scenarioSpec: _embeddedScenarioSpecV1(spec),
          debugSceneProofLabel: _embeddedScenarioSceneProofLabelV1(spec),
          debugScenePromptLabel: showsSurfacedWorld2HostV1
              ? topPromptTextV1
              : null,
          debugEmbeddedInstructionLabelV1:
              visualFamilyV1.useSceneOwnedInstructionV1 &&
                  topPromptTextV1.trim().isNotEmpty
              ? topPromptTextV1.trim()
              : null,
          debugBoardCardLabels: _embeddedScenarioBoardLabelsV1(spec),
          debugHeroCardLabels: _embeddedScenarioHeroLabelsV1(spec),
          debugVillainCardLabels: _embeddedScenarioVillainLabelsV1(spec),
          debugShowdownWinnerActionId:
              _embeddedScenarioShowdownWinnerActionIdV1(spec),
          debugSeatRoleLabels: _embeddedScenarioSeatRoleLabelsV1(spec),
          debugSeatMarkerLabels: _embeddedScenarioSeatMarkerLabelsV1(spec),
          onSeatTapV1: (seatIndex) {
            _handleEvent(
              DrillUserEventV1.seatTap(
                seatId: _adapter.seatIdForIndex(seatIndex),
                role: _resolvedSeatTapRoleForIndexV1(spec, seatIndex),
              ),
            );
          },
          onActionTapV1: (actionId) {
            _handleEvent(
              DrillUserEventV1.actionChoice(
                actionId,
                chainStepIndex: spec.kind == DrillKindV1.handChain
                    ? _currentChainStepIndexV1
                    : null,
              ),
            );
          },
          onBoardSlotTapV1: (boardSlot) {
            _handleEvent(DrillUserEventV1.boardTap(boardSlot));
          },
          onHoleCardTapDetailV1: (cardSlot, cardId) {
            _handleEvent(
              DrillUserEventV1.holeCardsTap(cardSlot: cardSlot, cardId: cardId),
            );
          },
        ),
      ),
    );
  }

  _SessionDrillRenderOrchestrationContractV1
  _buildRenderOrchestrationContractV1({
    required DrillSpecV1 spec,
    required bool showsEmbeddedFeedbackBelowTableV1,
    required DrillHostCapabilityContractV1 hostCapabilityContractV1,
  }) {
    final world10TrackClusterContractV1 =
        _buildWorld10TrackClusterSurfaceContractV1(
          spec,
          showsEmbeddedFeedbackBelowTableV1: showsEmbeddedFeedbackBelowTableV1,
        );
    final showsWorld10ActionZoneV1 =
        world10TrackClusterContractV1?.showsActionZone ??
        hostCapabilityContractV1.showsActionZone;
    final showsWorld10CompletionContinuationSurfaceV1 =
        world10TrackClusterContractV1?.showsCompletionContinuationSurface ??
        hostCapabilityContractV1.showsCompletionContinuationSurface;
    final continuationStateV1 = _buildSessionDrillSharedContinuationStateV1(
      showsContinuationArea:
          showsWorld10CompletionContinuationSurfaceV1 ||
          !showsWorld10ActionZoneV1,
      showsCompletionContinuationSurface:
          showsWorld10CompletionContinuationSurfaceV1,
    );
    final localPolicyBoundaryV1 = _buildSessionDrillSharedLocalPolicyBoundaryV1(
      continuationState: continuationStateV1,
    );
    return _SessionDrillRenderOrchestrationContractV1(
      world10TrackCluster: world10TrackClusterContractV1,
      actionSurface: showsWorld10ActionZoneV1
          ? _buildCurrentActionSurfaceV1(spec)
          : null,
      localPolicyBoundary: localPolicyBoundaryV1,
    );
  }

  SharedLearnerContinuationStateV1 _buildSessionDrillSharedContinuationStateV1({
    required bool showsContinuationArea,
    required bool showsCompletionContinuationSurface,
  }) {
    if (!showsContinuationArea) {
      return const SharedLearnerContinuationStateV1.hidden();
    }
    if (showsCompletionContinuationSurface) {
      final contractV1 = _buildCompletionContinuationSurfaceContractV1();
      return SharedLearnerContinuationStateV1.visible(
        visualState: SharedLearnerContinuationVisualStateV1.completionLike,
        primaryLabel: contractV1?.primaryCtaLabel ?? 'BACK TO MAP',
        secondaryLabel: contractV1?.secondaryCtaLabel,
      );
    }
    return SharedLearnerContinuationStateV1.visible(
      visualState: SharedLearnerContinuationVisualStateV1.resetLike,
      primaryLabel: 'Clear Result',
    );
  }

  SharedLearnerLocalPolicyBoundaryV1
  _buildSessionDrillSharedLocalPolicyBoundaryV1({
    required SharedLearnerContinuationStateV1 continuationState,
  }) {
    final current = _currentDrill;
    final nextSessionId = current == null
        ? null
        : _progressionChromeContractV1(current.spec).nextSessionId;
    final completionSurfaceContractV1 =
        continuationState.visualState ==
            SharedLearnerContinuationVisualStateV1.completionLike
        ? _buildCompletionContinuationSurfaceContractV1()
        : null;
    final onPrimaryPressed =
        continuationState.visualState ==
            SharedLearnerContinuationVisualStateV1.resetLike
        ? _resetCurrentResult
        : (nextSessionId != null
              ? () {
                  unawaited(_handleCompletionNextSessionV1(nextSessionId));
                }
              : _handleCompletionContinueV1);
    final onSecondaryPressed =
        completionSurfaceContractV1?.showsSecondaryCta == true
        ? _handleCompletionContinueV1
        : null;
    return SharedLearnerLocalPolicyBoundaryV1(
      continuationControlContract: SharedLearnerContinuationControlContractV1(
        continuationState: continuationState,
        isPrimaryBusy: false,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        statusHeader: completionSurfaceContractV1?.statusHeader,
        bodyText: completionSurfaceContractV1?.bodyText,
      ),
      routeCompletionBoundary: _buildSessionDrillRouteCompletionBoundaryV1(
        continuationState: continuationState,
        nextSessionId: nextSessionId,
        primaryLabel: continuationState.primaryLabel,
        secondaryLabel: completionSurfaceContractV1?.showsSecondaryCta == true
            ? continuationState.secondaryLabel
            : null,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
      ),
    );
  }

  SharedLearnerRouteCompletionBoundaryV1
  _buildSessionDrillRouteCompletionBoundaryV1({
    required SharedLearnerContinuationStateV1 continuationState,
    required String? nextSessionId,
    required String primaryLabel,
    required String? secondaryLabel,
    required VoidCallback? onPrimaryPressed,
    required VoidCallback? onSecondaryPressed,
  }) {
    if (!continuationState.isVisible) {
      return const SharedLearnerRouteCompletionBoundaryV1.hidden();
    }
    final primaryCategory = switch (continuationState.visualState) {
      SharedLearnerContinuationVisualStateV1.resetLike =>
        SharedLearnerTerminalControlCategoryV1.resetLike,
      SharedLearnerContinuationVisualStateV1.completionLike =>
        nextSessionId != null
            ? SharedLearnerTerminalControlCategoryV1.nextSessionLike
            : SharedLearnerTerminalControlCategoryV1.backLike,
      _ => SharedLearnerTerminalControlCategoryV1.continueLike,
    };
    return SharedLearnerRouteCompletionBoundaryV1(
      primaryAction: SharedLearnerTerminalControlActionV1.visible(
        category: primaryCategory,
        label: primaryLabel,
        onPressed: onPrimaryPressed,
      ),
      secondaryAction: secondaryLabel == null || onSecondaryPressed == null
          ? const SharedLearnerTerminalControlActionV1.hidden()
          : SharedLearnerTerminalControlActionV1.visible(
              category: SharedLearnerTerminalControlCategoryV1.backLike,
              label: secondaryLabel,
              onPressed: onSecondaryPressed,
            ),
    );
  }

  _SessionDrillSurfacedRenderInputContractV1
  _buildSurfacedRenderInputContractV1({
    required _SessionDrillWorld2SurfacedFamilyAdapterV1? surfacedWorld2Adapter,
    required _SessionDrillRenderOrchestrationContractV1 orchestration,
    required Widget topSection,
    required Widget embeddedTable,
    required bool showsEmbeddedFeedbackBelowTable,
    required _SessionDrillTeachingContractV1 teachingContract,
    required SharedLearnerFamilyExtrasSlotsV1 extrasSlots,
  }) {
    return _SessionDrillSurfacedRenderInputContractV1(
      surfacedWorld2Adapter: surfacedWorld2Adapter,
      world10TrackCluster: orchestration.world10TrackCluster,
      topSection: topSection,
      embeddedTable: embeddedTable,
      showsEmbeddedFeedbackBelowTable: showsEmbeddedFeedbackBelowTable,
      teachingContract: teachingContract,
      extrasSlots: extrasSlots,
      actionSurface: orchestration.actionSurface,
      localPolicyBoundary: orchestration.localPolicyBoundary,
    );
  }

  bool _shouldShowEmbeddedScenarioTableV1(DrillSpecV1 spec) {
    final world10TrackClusterContractV1 =
        _buildWorld10TrackClusterSurfaceContractV1(spec);
    if (world10TrackClusterContractV1 != null) {
      return world10TrackClusterContractV1.showsEmbeddedScenarioTable;
    }
    if (_isSpatialProjectionPilotDrillV1(spec)) {
      return true;
    }
    if (_isWorld5BoardTextureScenarioV1(spec)) {
      return true;
    }
    return _isWorld2SurfacedScenarioSessionV1 ||
        _isEmbeddedHandChainScenarioPilotV1;
  }

  bool _isSpatialProjectionPilotDrillV1(DrillSpecV1 spec) {
    if (!_kSpatialProjectionPilotSessionIdsV1.contains(widget.sessionId)) {
      return false;
    }
    if (_isWorld9SeatIdProjectionPilotDrillV1(spec)) {
      return true;
    }
    final evaluation = SessionDrillSpatialProjectionContractV1.evaluate(
      hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
      layoutFamily: kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
      drill: spec,
    );
    if (evaluation.applies) {
      return evaluation.hasRequiredScenePayload;
    }
    return spec.kind != DrillKindV1.handChain &&
        spec.scenarioTableContextV1 != null;
  }

  bool _isWorld9SeatIdProjectionPilotDrillV1(DrillSpecV1 spec) {
    final evaluation = SessionDrillWorld9SeatIdProjectionContractV1.evaluate(
      sessionId: widget.sessionId,
      hostSurface: kSessionDrillSpatialProjectionHostSurfaceV1,
      layoutFamily: kSessionDrillSpatialProjectionRequiredLayoutFamilyV1,
      drill: spec,
    );
    return evaluation.applies && evaluation.hasRequiredScenePayload;
  }

  _SessionDrillWorld10TrackClusterSurfaceContractV1?
  _buildWorld10TrackClusterSurfaceContractV1(
    DrillSpecV1 spec, {
    bool? showsEmbeddedFeedbackBelowTableV1,
  }) {
    final normalizedSessionId = widget.sessionId.trim().toLowerCase();
    final trackKind = canonicalTruthWorld10TrackKindForSessionIdV1(
      normalizedSessionId,
    );
    if (trackKind == null) {
      return null;
    }
    return _SessionDrillWorld10TrackClusterSurfaceContractV1(
      trackKind: trackKind,
      showsEmbeddedScenarioTable: _isSpatialProjectionPilotDrillV1(spec),
      showsTrackRootIntroCard:
          !_completed &&
          widget.handoffContextV1 != null &&
          const <String>{
            'cash.s01',
            'tournament.s01',
            'mixed.s01',
          }.contains(normalizedSessionId),
      sections: RunnerHostSectionResponsibilityV1(
        showIntro:
            !_completed &&
            widget.handoffContextV1 != null &&
            const <String>{
              'cash.s01',
              'tournament.s01',
              'mixed.s01',
            }.contains(normalizedSessionId),
        showSourceMeta: false,
        showRecap: false,
        showEmbeddedFeedbackBelowTable:
            showsEmbeddedFeedbackBelowTableV1 ?? true,
      ),
      showsActionZone: !_completed,
      showsCompletionContinuationSurface: _completed,
      introCardTitle: switch (trackKind) {
        'cash' => 'Cash Track Bridge',
        'tournament' => 'Tournament Track Bridge',
        'mixed' => 'Mixed Track Bridge',
        _ => 'Track Bridge',
      },
      introCardLine1: switch (trackKind) {
        'cash' =>
          'Start with deeper-stack decisions where value, fold equity, and position stay stable.',
        'tournament' =>
          'Start with survival pressure, stack depth, and ICM changing the right policy.',
        'mixed' =>
          'Start with a balanced mix of cash fundamentals and tournament pressure.',
        _ =>
          'Start with one stable baseline before adding more surface pressure.',
      },
      introCardLine2: switch (trackKind) {
        'cash' => 'Focus on one clean value or pressure adjustment at a time.',
        'tournament' =>
          'Focus on protecting stack utility before chasing thin edges.',
        'mixed' =>
          'Focus on when the environment asks for a different default.',
        _ => 'Focus on one clean adjustment at a time.',
      },
    );
  }
}

class _SessionDrillWorld10TrackClusterSurfaceContractV1 {
  const _SessionDrillWorld10TrackClusterSurfaceContractV1({
    required this.trackKind,
    required this.showsEmbeddedScenarioTable,
    required this.showsTrackRootIntroCard,
    required this.sections,
    required this.showsActionZone,
    required this.showsCompletionContinuationSurface,
    required this.introCardTitle,
    required this.introCardLine1,
    required this.introCardLine2,
  });

  final String trackKind;
  final bool showsEmbeddedScenarioTable;
  final bool showsTrackRootIntroCard;
  final RunnerHostSectionResponsibilityV1 sections;
  final bool showsActionZone;
  final bool showsCompletionContinuationSurface;
  final String introCardTitle;
  final String introCardLine1;
  final String introCardLine2;
}

class _SessionDrillWorld10TrackTopSectionContractV1 {
  const _SessionDrillWorld10TrackTopSectionContractV1({
    required this.handoffStatusLine,
    required this.showsCompletedState,
    required this.statusHeaderText,
    required this.showsIntroCard,
    required this.promptText,
    required this.showsFeedbackAboveTable,
    required this.teachingContract,
  });

  final String? handoffStatusLine;
  final bool showsCompletedState;
  final String statusHeaderText;
  final bool showsIntroCard;
  final String promptText;
  final bool showsFeedbackAboveTable;
  final _SessionDrillTeachingContractV1 teachingContract;
}

class _SessionDrillWorld2SurfacedHostContentContractV1 {
  const _SessionDrillWorld2SurfacedHostContentContractV1({
    required this.showsEmbeddedFeedbackBelowTable,
    required this.extrasSlots,
  });

  final bool showsEmbeddedFeedbackBelowTable;
  final SharedLearnerFamilyExtrasSlotsV1 extrasSlots;
}

class _SessionDrillWorld2SurfacedHeaderPromptContractV1 {
  const _SessionDrillWorld2SurfacedHeaderPromptContractV1({
    required this.handoffStatusText,
    required this.headlineText,
    required this.promptStatusText,
    required this.promptText,
    required this.actingFocusLabel,
    required this.promptSheetTitle,
    required this.promptSheetBody,
    required this.canReveal,
    required this.revealAffordanceEnabled,
  });

  final String? handoffStatusText;
  final String headlineText;
  final String? promptStatusText;
  final String promptText;
  final String? actingFocusLabel;
  final String promptSheetTitle;
  final String promptSheetBody;
  final bool canReveal;
  final bool revealAffordanceEnabled;
}

class _SessionDrillWorld2SurfacedFamilyAdapterV1 {
  const _SessionDrillWorld2SurfacedFamilyAdapterV1({
    required this.spec,
    required this.sessionTitle,
    required this.stepLabel,
    required this.promptStatusText,
    required this.handoffStatusText,
    required this.isCompactShowdownHeader,
    required this.prompt,
    required this.compactPromptText,
    required this.factualHostContract,
    required this.hostCapabilityContract,
    required this.table,
    required this.actionSurface,
    required this.extrasSlots,
    required this.showsEmbeddedFeedbackBelowTable,
    required this.teachingContract,
  });

  final DrillSpecV1 spec;
  final String sessionTitle;
  final String stepLabel;
  final String promptStatusText;
  final String? handoffStatusText;
  final bool isCompactShowdownHeader;
  final String prompt;
  final String compactPromptText;
  final FactualRunnerHostContractV1? factualHostContract;
  final DrillHostCapabilityContractV1 hostCapabilityContract;
  final Widget table;
  final Widget? actionSurface;
  final SharedLearnerFamilyExtrasSlotsV1 extrasSlots;
  final bool showsEmbeddedFeedbackBelowTable;
  final _SessionDrillTeachingContractV1 teachingContract;
}

class _SessionDrillWorld2SurfacedFamilyResolverV1 {
  const _SessionDrillWorld2SurfacedFamilyResolverV1({
    required this.family,
    required this.sections,
    required this.sourceMetaEntries,
    required this.supplements,
  });

  final FactualRunnerHostFamilyV1 family;
  final RunnerHostSectionResponsibilityV1 sections;
  final List<RunnerHostSourceMetaEntryV1> sourceMetaEntries;
  final FactualRunnerHostSupplementContractV1 supplements;
}

class _SessionDrillSurfacedFamilyCoreContractV1 {
  const _SessionDrillSurfacedFamilyCoreContractV1({
    required this.sections,
    required this.sourceMetaEntries,
    required this.supplements,
  });

  final RunnerHostSectionResponsibilityV1 sections;
  final List<RunnerHostSourceMetaEntryV1> sourceMetaEntries;
  final FactualRunnerHostSupplementContractV1 supplements;
}

class _SessionDrillSurfacedPathWiringContractV1 {
  const _SessionDrillSurfacedPathWiringContractV1({
    required this.hostCapabilityContract,
    required this.factualHostContract,
    required this.topPromptText,
    required this.detailsPrompt,
    required this.extrasSlots,
  });

  final DrillHostCapabilityContractV1 hostCapabilityContract;
  final FactualRunnerHostContractV1? factualHostContract;
  final String topPromptText;
  final String detailsPrompt;
  final SharedLearnerFamilyExtrasSlotsV1 extrasSlots;
}

class _SessionDrillSurfacedRenderInputContractV1 {
  const _SessionDrillSurfacedRenderInputContractV1({
    required this.surfacedWorld2Adapter,
    required this.world10TrackCluster,
    required this.topSection,
    required this.embeddedTable,
    required this.showsEmbeddedFeedbackBelowTable,
    required this.teachingContract,
    required this.extrasSlots,
    required this.actionSurface,
    required this.localPolicyBoundary,
  });

  final _SessionDrillWorld2SurfacedFamilyAdapterV1? surfacedWorld2Adapter;
  final _SessionDrillWorld10TrackClusterSurfaceContractV1? world10TrackCluster;
  final Widget topSection;
  final Widget embeddedTable;
  final bool showsEmbeddedFeedbackBelowTable;
  final _SessionDrillTeachingContractV1 teachingContract;
  final SharedLearnerFamilyExtrasSlotsV1 extrasSlots;
  final Widget? actionSurface;
  final SharedLearnerLocalPolicyBoundaryV1 localPolicyBoundary;
}

class _SessionDrillTeachingContractV1 {
  const _SessionDrillTeachingContractV1({
    required this.handoffStatusText,
    required this.headlineText,
    required this.statusHeaderText,
    required this.promptStatusText,
    required this.sharedTeachingGrammarV1,
    required this.supportPrimaryKey,
    required this.supportSecondaryKey,
    required this.supportTertiaryKey,
  });

  final String? handoffStatusText;
  final String headlineText;
  final String statusHeaderText;
  final String promptStatusText;
  final SharedLearnerTeachingGrammarV1 sharedTeachingGrammarV1;
  final Key? supportPrimaryKey;
  final Key? supportSecondaryKey;
  final Key? supportTertiaryKey;

  String? get headerStatusText => sharedTeachingGrammarV1.headerStatusText;
  String get headerHeadlineText => sharedTeachingGrammarV1.headerHeadlineText;
  String get displayedPrompt => sharedTeachingGrammarV1.displayedPrompt;
  String get promptDetailsTitle => sharedTeachingGrammarV1.promptDetailsTitle;
  String get promptDetailsText => sharedTeachingGrammarV1.promptDetailsText;
  bool get canRevealPromptDetails =>
      sharedTeachingGrammarV1.canRevealPromptDetails;
  bool get enablePromptDetailsAffordance =>
      sharedTeachingGrammarV1.enablePromptDetailsAffordance;
  String get supportPrimaryText => sharedTeachingGrammarV1.supportPrimaryText;
  String get supportSecondaryText =>
      sharedTeachingGrammarV1.supportSecondaryText;
  String get supportTertiaryText => sharedTeachingGrammarV1.supportTertiaryText;
  String get outcomePrimaryText => sharedTeachingGrammarV1.outcomePrimaryText;
  String get outcomeWhyText => sharedTeachingGrammarV1.outcomeWhyText;
  String get outcomeNextText => sharedTeachingGrammarV1.outcomeNextText;
  String get outcomeDetailText => sharedTeachingGrammarV1.outcomeDetailText;
}

class _SessionDrillRenderOrchestrationContractV1 {
  const _SessionDrillRenderOrchestrationContractV1({
    required this.world10TrackCluster,
    required this.actionSurface,
    required this.localPolicyBoundary,
  });

  final _SessionDrillWorld10TrackClusterSurfaceContractV1? world10TrackCluster;
  final Widget? actionSurface;
  final SharedLearnerLocalPolicyBoundaryV1 localPolicyBoundary;
}

class _SessionDrillWorld2SurfacedShellContractV1 {
  const _SessionDrillWorld2SurfacedShellContractV1({
    required this.outerPadding,
    required this.borderRadius,
    required this.shellGradientColors,
    required this.shadowColor,
    required this.shadowBlurRadius,
    required this.headerPadding,
    required this.minTableViewportHeight,
    required this.tableViewportPadding,
    required this.bottomBandMaxHeight,
    required this.bottomBandPadding,
    required this.supportLaneSurfaceColor,
    required this.supportLaneBorderColor,
    required this.headerPrompt,
    required this.hostContent,
    required this.table,
    required this.actionSurface,
    required this.extrasSlots,
  });

  final EdgeInsets outerPadding;
  final BorderRadius borderRadius;
  final List<Color> shellGradientColors;
  final Color shadowColor;
  final double shadowBlurRadius;
  final EdgeInsets headerPadding;
  final double minTableViewportHeight;
  final EdgeInsets tableViewportPadding;
  final double bottomBandMaxHeight;
  final EdgeInsets bottomBandPadding;
  final Color supportLaneSurfaceColor;
  final Color supportLaneBorderColor;
  final _SessionDrillWorld2SurfacedHeaderPromptContractV1 headerPrompt;
  final _SessionDrillWorld2SurfacedHostContentContractV1 hostContent;
  final Widget table;
  final Widget? actionSurface;
  final SharedLearnerFamilyExtrasSlotsV1 extrasSlots;
}
