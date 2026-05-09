import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:poker_analyzer/engine/simulation_action_loop.dart';
import 'package:poker_analyzer/engine/simulation_ai_agent.dart';
import 'package:poker_analyzer/engine/simulation_ai_personas.dart';
import 'package:poker_analyzer/engine/simulation_state_engine.dart';
import 'package:poker_analyzer/engine/simulation_timing_engine.dart';
import 'package:poker_analyzer/engine/simulation_replay_engine.dart';
import 'package:poker_analyzer/engine/action_bar_engine.dart';
import 'package:poker_analyzer/engine/action_state_engine.dart';
import 'package:poker_analyzer/engine/betting_state_engine.dart';
import 'package:poker_analyzer/engine/card_motion_spec.dart';
import 'package:poker_analyzer/engine/hand_evaluator.dart';

import 'package:poker_analyzer/engine/motion/motion_engine.dart';
import 'package:poker_analyzer/engine/round_engine.dart';
import 'package:poker_analyzer/engine/showdown_engine.dart';
import 'package:poker_analyzer/engine/side_pot_engine.dart';
import 'package:poker_analyzer/engine/stack_state_engine.dart';
import 'package:poker_analyzer/engine/street_engine.dart';
import 'package:poker_analyzer/engine/table_state_engine.dart';
import 'package:poker_analyzer/engine/turn_engine.dart';
import 'package:poker_analyzer/ui_v2/design/design_typography.dart';
import 'package:poker_analyzer/ui_v3/theme/adaptive_theme_bridge.dart';
import 'package:poker_analyzer/ui_v2/persona/global_persona_controller.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_clip_surface.dart';
import 'package:poker_analyzer/ui_v2/persona/sharky_aura_fx.dart';
import 'package:poker_analyzer/ui_v2/persona/sharky_persona_events.dart';
import 'package:poker_analyzer/ui_v2/persona/persona_reaction_surface.dart';
import 'package:poker_analyzer/ui_v2/table/action_bar_model.dart';
import 'package:poker_analyzer/ui_v2/motion/chip_motion.dart';
import 'package:poker_analyzer/ui_v2/motion/chip_motion_surface.dart';
import 'package:poker_analyzer/ui_v2/motion/pot_motion_controller.dart';
import 'package:poker_analyzer/ui_v2/motion/side_pot_layout.dart';
import 'package:poker_analyzer/ui_v2/motion/winner_motion_translator.dart';
import 'package:poker_analyzer/engine/motion_script_builder.dart';
import 'package:poker_analyzer/engine/simulation_motion_kernel.dart';
import 'package:poker_analyzer/services/adaptive_progression_service.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/services/localization_core.dart';
import 'package:poker_analyzer/services/session_summary_service.dart';
import 'package:poker_analyzer/ui_v3/mascot/mascot_controller.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';
import 'package:poker_analyzer/ui_v3/widgets/adaptive_feedback_banner.dart';
import 'package:poker_analyzer/ui_v3/widgets/session_summary_card.dart';
import 'package:poker_analyzer/ui_v2/table/board_surface.dart';
import 'package:poker_analyzer/ui_v2/table/table_composite_surface.dart';
import 'package:poker_analyzer/engine/table_layout_adapter.dart';
import 'package:poker_analyzer/engine/table_layout_resolver.dart';
import 'package:poker_analyzer/engine/table_seat_slots.dart';
import 'package:poker_analyzer/engine/table_shape.dart';
import 'package:poker_analyzer/engine/blind_posting_engine.dart';
import 'package:poker_analyzer/engine/dealer_phase_engine.dart';
import 'package:poker_analyzer/engine/motion_frame_composer.dart';
import 'package:poker_analyzer/engine/preflop_action_engine.dart';
import 'package:poker_analyzer/engine/postflop_action_engine.dart';

const bool kEnableMascotOverlay = true;

@visibleForTesting
bool kMascotOverlayTestOverride = kEnableMascotOverlay;

bool get _isMascotOverlayEnabled =>
    kEnableMascotOverlay && kMascotOverlayTestOverride;

class SimulationTableScreen extends StatefulWidget {
  static const String routeName = '/v3/simulation-table';

  const SimulationTableScreen({super.key});

  @override
  State<SimulationTableScreen> createState() => _SimulationTableScreenState();
}

class _SimulationTableScreenState extends State<SimulationTableScreen>
    with TickerProviderStateMixin {
  static const Set<Street> _postflopStreets = {
    Street.flop,
    Street.turn,
    Street.river,
  };
  late SimulationState _state;
  late ActionLoop _loop;
  late final SimulationAIAgent _fallbackAgent;
  late SimulationTimingEngine _timing;
  late AnimationController _aiProgressController;
  late Map<String, int> _stacks;
  late SimulationReplayEngine _replay;
  late final MascotController _mascotController;
  late final AIAgentFactory _aiFactory;
  late final Map<String, PersonaAgent> _aiAgentsBySeat;
  final SimulationMotionKernel _motionKernel = SimulationMotionKernel();
  Timer? _streetTransitionTimer;
  bool _streetTransitionInProgress = false;
  late final Ticker _motionTicker;
  Duration? _lastMotionTick;
  double _elapsedMs = 0.0;
  late final ActionBarEngine _actionBarEngine;
  ActionBarModel _actionModel = const ActionBarModel();
  final List<int> _handSeats = const <int>[0, 1, 2, 3, 4, 5];
  List<TableSeatSlot>? _latestSlots;
  Offset? _latestBoardPosition;
  List<Offset> _latestBoardCardOffsets = [];
  StreetEngine _street = const StreetEngine(Street.preflop);
  TurnEngine _turn = const TurnEngine(
    activeSeat: 0,
    status: TurnStatus.waitingForPlayer,
  );
  final StackStateEngine _stackState = StackStateEngine(6);
  late final BettingStateEngine _betting;
  final TableStateEngine _tableState = TableStateEngine(6);
  int _activeSeat = 0;
  final RoundEngine _roundEngine = RoundEngine(
    seatCount: const <int>[0, 1, 2, 3, 4, 5].length,
  );
  final HandEvaluator _evaluator = const HandEvaluator();
  late final ShowdownEngine _showdown;
  final SidePotEngine _sidePot = const SidePotEngine();
  bool _motionScriptBound = false;
  double _pendingRaiseAmount = 50.0;
  bool _showRaiseConfirm = false;
  late final MotionEngine _motionEngine;
  AdaptiveThemeBridge? _adaptiveTheme;
  late final StreamSubscription<MotionCommand> _motionCommandSub;
  final GlobalKey<ChipMotionSurfaceState> _chipMotionKey =
      GlobalKey<ChipMotionSurfaceState>();
  final PotMotionController _potMotionController = PotMotionController();
  SidePotLayout _sidePotLayout = SidePotLayout(
    boardPosition: Offset.zero,
    potCount: 1,
  );
  final DealerPhaseEngine _dealerPhaseEngine = DealerPhaseEngine();
  final BlindPostingEngine _blindPostingEngine = BlindPostingEngine();
  final PreflopActionEngine _preflopActionEngine = PreflopActionEngine();
  final PostflopActionEngine _postflopActionEngine = PostflopActionEngine();
  // ignore: unused_field
  DealerPhaseResult _dealerPhaseResult = const DealerPhaseResult(
    dealerSeat: 0,
    smallBlindSeat: 1,
    bigBlindSeat: 2,
    handId: 0,
  );

  final List<String> _players = <String>['SB', 'BB', 'HJ', 'CO', 'BTN'];
  final List<String> _board = <String>['Ah', 'Kh', 'Qd'];
  static const List<BoardCardData> _boardVisuals = [
    BoardCardData(rank: 'A', suit: 'S'),
    BoardCardData(rank: 'K', suit: 'H'),
    BoardCardData(rank: '7', suit: 'D'),
    BoardCardData(rank: '2', suit: 'C'),
    BoardCardData(rank: 'J', suit: 'H'),
  ];
  static const List<HoleCardFaces> _holeCards = [
    HoleCardFaces(seatIndex: 0, rank1: 'A', suit1: 'S', rank2: 'K', suit2: 'D'),
    HoleCardFaces(seatIndex: 1, rank1: 'Q', suit1: 'H', rank2: 'J', suit2: 'C'),
    HoleCardFaces(seatIndex: 2, rank1: '9', suit1: 'S', rank2: '9', suit2: 'H'),
    HoleCardFaces(seatIndex: 3, rank1: 'T', suit1: 'D', rank2: '8', suit2: 'D'),
    HoleCardFaces(seatIndex: 4, rank1: '5', suit1: 'C', rank2: '5', suit2: 'S'),
    HoleCardFaces(seatIndex: 5, rank1: '3', suit1: 'H', rank2: '2', suit2: 'C'),
  ];
  final List<_LogEntry> _logEntries = <_LogEntry>[];
  final Map<String, Offset> _playerOffsets = <String, Offset>{};
  static const List<String> _aiSeats = <String>['CO', 'BTN'];
  final LocalizationCore _localization = LocalizationCore.instance;
  static const int _startingStack = 500;

  String? _currentPlayer;
  List<String> _allowedMoves = const <String>[];
  int _lastWager = 0;
  bool _aiThinking = false;
  _ChipFlight? _chipFlight;
  MotionFrameSnapshot? _motionSnapshot;
  String _currentLanguage = 'en';
  bool _telemetryEnabled = false;
  DateTime? _aiDecisionStart;
  double _lastAiDecisionMs = 0;
  double _avgAiDecisionMs = 0;
  int _aiDecisionCount = 0;
  DateTime? _frameTimingStart;
  double _lastFrameBuildMs = 0;
  DateTime? _lastPotUpdateTime;
  double _lastPotLatencyMs = 0;
  bool _showSessionSummary = false;
  SessionMetrics? _sessionMetrics;

  // Φ1 Visual Engagement state
  bool _potShimmerActive = false;
  String? _handResultFlash; // 'win' or 'loss'
  double _handResultOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _adaptiveTheme = null;
    _actionBarEngine = ActionBarEngine(
      onFold: _onFold,
      onCall: _onCall,
      onRaise: _onRaiseRequest,
    );
    _motionEngine = MotionEngine();
    _motionCommandSub = _motionEngine.commandStream.listen(
      _handleMotionCommand,
    );
    _betting = BettingStateEngine(6, _stackState);
    _showdown = ShowdownEngine(_evaluator, _stackState);
    _roundEngine.resetRound();
    _state = SimulationState(
      players: _players,
      board: List<String>.from(_board),
    );
    _loop = ActionLoop(ActionQueue(<Map<String, Object?>>[]), _state);
    _rebuildActionModel();
    _aiFactory = AIAgentFactory(seed: 2025);
    final personaAssignments = <PersonaAgent>[
      _aiFactory.createById('crazy_carl'),
      _aiFactory.createUnknown(),
    ];
    _aiAgentsBySeat = <String, PersonaAgent>{
      for (var i = 0; i < _aiSeats.length; i++)
        _aiSeats[i]: personaAssignments[i % personaAssignments.length],
    };
    _fallbackAgent = SimulationAIAgent(aggression: 0.55, seed: 4021);
    final delaySamples = _aiAgentsBySeat.values
        .map((bundle) => bundle.persona.delayMs)
        .toList();
    final initialDelay = delaySamples.isEmpty
        ? 1200
        : delaySamples.reduce((a, b) => a + b) ~/ delaySamples.length;
    _timing = SimulationTimingEngine(delayMs: initialDelay);
    _aiProgressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _timing.delayMs),
    );
    _replay = SimulationReplayEngine();
    _mascotController = MascotController()..setIdle(opacity: 0.0);

    _registerDefaultTranslations();
    _localization.loadGlossary();

    _timing.onAiActionReady.listen((_) {
      if (!mounted) return;
      _processAiAction();
    });

    _timing.onRoundComplete.listen((_) {
      if (!mounted) return;
      _updateState(() {
        _aiThinking = false;
        _aiProgressController.stop();
      }, measure: false);
    });

    _stacks = {for (final player in _players) player: _startingStack};
    _refreshTurn();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_prepareAiDecision()) {
        _updateState(() {}, measure: false);
        _timing.scheduleNextAction(() {});
      }
      _syncMascotState();
    });
    _motionTicker = createTicker(_handleMotionTick)..start();
    _startNewHand();
  }

  @override
  void dispose() {
    _streetTransitionTimer?.cancel();
    _aiProgressController.dispose();
    _timing.dispose();
    _motionTicker.dispose();
    _motionEngine.dispose();
    _motionCommandSub.cancel();
    _mascotController.dispose();
    _potMotionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: VisualThemeV3.theme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          // TODO(Φ-AI): plug adaptive surface modifiers here in a future step.
          // ignore: unused_local_variable
          final adaptive = _adaptiveTheme;
          return Scaffold(
            appBar: AppBar(
              leading: VisualThemeV3.brand.hasLogo
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        VisualThemeV3.brand.logoPath,
                        fit: BoxFit.contain,
                        width: 28,
                        height: 28,
                      ),
                    )
                  : null,
              title: Text(_label('Simulation Table')),
              actions: [
                TextButton(
                  onPressed: _toggleTelemetry,
                  child: Text(
                    _telemetryEnabled
                        ? _label('Telemetry ON')
                        : _label('Telemetry OFF'),
                    style: TextStyle(
                      color:
                          Theme.of(context).appBarTheme.foregroundColor ??
                          Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _toggleLanguage,
                  child: Text(
                    _currentLanguage.toUpperCase(),
                    style: TextStyle(
                      color:
                          Theme.of(context).appBarTheme.foregroundColor ??
                          Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: VisualThemeV3.brandBackgroundGradient,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight.isFinite
                        ? constraints.maxHeight
                        : MediaQuery.of(context).size.height;
                    final isCompact = width < 460;
                    final padding = EdgeInsets.symmetric(
                      horizontal: isCompact
                          ? VisualThemeV3.spacingM
                          : VisualThemeV3.spacingL,
                      vertical: VisualThemeV3.spacingM,
                    );
                    final content = SingleChildScrollView(
                      padding: padding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AdaptiveFeedbackBanner(
                            notifier: AdaptiveProgressionService
                                .instance
                                .feedbackNotifier,
                          ),
                          Text(
                            '${_label('Pot')} \$: ${_state.pot}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: VisualThemeV3.spacingS),
                          Center(
                            child: Text(
                              '${_label('Board')}: [${_board.join(' ')}]',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: VisualThemeV3.spacingL),
                          SizedBox(height: 320, child: _buildPlayerRing()),
                          const SizedBox(height: VisualThemeV3.spacingL),
                          if (_aiThinking) ...[
                            FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _aiProgressController,
                                curve: Curves.easeIn,
                              ),
                              child: Text(
                                _label('AI thinking...'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedBuilder(
                              animation: _aiProgressController,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _aiProgressController.value.clamp(
                                    0.0,
                                    1.0,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildActionsRow(),
                          if (_showSessionSummary &&
                              _sessionMetrics != null) ...[
                            const SizedBox(height: 16),
                            SessionSummaryCard(
                              metrics: _sessionMetrics!,
                              onContinue: _dismissSessionSummary,
                            ),
                          ],
                          if (_replay.hasHistory) ...[
                            const SizedBox(height: 16),
                            _buildReplayControls(),
                          ],
                          const SizedBox(height: 16),
                          if (_loop.isRoundComplete)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: VisualThemeV3.success.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(
                                  VisualThemeV3.cardRadius,
                                ),
                              ),
                              child: Text(
                                _label('Round complete'),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: VisualThemeV3.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          Text(
                            _label('Action log'),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: VisualThemeV3.spacingS),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.04,
                              ),
                              borderRadius: BorderRadius.circular(
                                VisualThemeV3.cardRadius,
                              ),
                              boxShadow: const [VisualThemeV3.shadowLight],
                            ),
                            child: _logEntries.isEmpty
                                ? Text(_label('No actions yet.'))
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _logEntries
                                        .map(
                                          (entry) => AnimatedOpacity(
                                            key: entry.id,
                                            opacity: entry.visible ? 1 : 0,
                                            duration: VisualThemeV3.speedSlow,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 4,
                                              ),
                                              child: Text(entry.localized),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),
                        ],
                      ),
                    );

                    final reactionState =
                        GlobalPersonaController.instance.reactionState;
                    final beat =
                        GlobalPersonaController.instance.lastMotionBeat;
                    final fusionFrame =
                        GlobalPersonaController.instance.latestFusionFrame;
                    final resolver = const TableLayoutResolver(
                      adapter: TableLayoutAdapter(),
                    );
                    final resolved = resolver.resolve(
                      shape: TableShapeSpec.sixMax(),
                      width: width,
                      height: height,
                      safeArea: MediaQuery.of(context).padding,
                    );
                    final slots = buildTableSeatSlots(resolved);
                    _activateMotionScript(slots, resolved.boardPosition);
                    _latestSlots = slots;
                    _latestBoardCardOffsets = _computeBoardCardOffsets(
                      resolved.boardPosition,
                    );
                    _latestBoardPosition = resolved.boardPosition;
                    _updateSidePotLayout();
                    final fusion =
                        GlobalPersonaController.instance.fusion ??
                        const PersonaFusionState(
                          macro: PersonaExpression.idle,
                          micro: PersonaMicroExpression.idleBounce,
                          intensity: 0.0,
                          beat: 0.0,
                          signal: SharkyMotionSignalType.none,
                        );
                    return SharkyAuraFX(
                      fusion: fusion,
                      child: Stack(
                        children: [
                          content,
                          Positioned(
                            top: VisualThemeV3.spacingM,
                            right: VisualThemeV3.spacingM,
                            child: IgnorePointer(
                              child: Text(
                                'Turn: Seat ${_turn.activeSeat}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: DesignTypography.body,
                                ),
                              ),
                            ),
                          ),
                          TableCompositeSurface(
                            layout: resolved,
                            motion: _motionSnapshot,
                            actionModel: _actionModel,
                            seatStates: _buildSeatStates(),
                            onAction: _actionBarEngine.handle,
                            onSelectRaise: _selectRaise,
                            showRaiseConfirm: _showRaiseConfirm,
                            raiseAmount: _pendingRaiseAmount,
                            onConfirmRaise: _confirmRaise,
                            onCancelRaise: _cancelRaise,
                            boardCards: _boardVisuals,
                            holeCards: _holeCards,
                            potAmount: _betting.pot,
                          ),
                          Positioned.fill(
                            child: ChipMotionSurface(
                              key: _chipMotionKey,
                              boardPosition:
                                  _latestBoardPosition ?? Offset.zero,
                              potController: _potMotionController,
                            ),
                          ),
                          PersonaReactionSurface(
                            reaction: reactionState,
                            beat: beat,
                            fusionFrame: fusionFrame,
                          ),
                          Positioned.fill(
                            child: PersonaClipSurface(
                              params: PersonaClipParams(
                                clipFrame: GlobalPersonaController
                                    .instance
                                    .lastClipFrame,
                                fusionFrame: fusionFrame,
                                beat: beat,
                                tone: Colors.white,
                                controller: GlobalPersonaController.instance,
                                meta: null,
                              ),
                            ),
                          ),
                          if (_handResultFlash != null)
                            AnimatedOpacity(
                              opacity: _handResultOpacity,
                              duration: VisualThemeV3.speedSlow,
                              child: Container(
                                color: _handResultFlash == 'win'
                                    ? VisualThemeV3.glowColorSuccess
                                    : VisualThemeV3.glowColorError,
                                child: Center(
                                  child: Text(
                                    _handResultFlash == 'win' ? 'WIN!' : 'LOSS',
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            const Shadow(
                                              blurRadius: 8,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          if (_telemetryEnabled)
                            Positioned(
                              top: VisualThemeV3.spacingM,
                              right: isCompact
                                  ? VisualThemeV3.spacingM
                                  : VisualThemeV3.spacingL,
                              child: _buildTelemetryOverlay(context, isCompact),
                            ),
                          if (_isMascotOverlayEnabled)
                            Positioned(
                              bottom: 16,
                              right: isCompact ? 12 : 24,
                              child: AnimatedBuilder(
                                animation: _mascotController,
                                builder: (context, _) =>
                                    _buildMascotOverlay(context, isCompact),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerRing() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final radius = size / 2 - 32;
        final center = Offset(size / 2, size / 2);
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final boardDisplay = '[${_board.join(' ')}]';
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                for (var i = 0; i < _players.length; i++)
                  _buildPlayerPosition(context, i, radius, size),
                if (_chipFlight != null)
                  AnimatedPositioned(
                    duration: VisualThemeV3.speedNormal,
                    curve: Curves.easeOutQuart,
                    left:
                        (_chipFlight!.toCenter
                            ? center.dx
                            : _playerOffsets[_chipFlight!.player]?.dx ??
                                  center.dx) -
                        12,
                    top:
                        (_chipFlight!.toCenter
                            ? center.dy
                            : _playerOffsets[_chipFlight!.player]?.dy ??
                                  center.dy) -
                        12,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.secondary.withValues(alpha: 0.9),
                        border: Border.all(
                          color: colorScheme.secondary,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text('\$'),
                    ),
                  ),
                Align(
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: VisualThemeV3.speedFast,
                    padding: const EdgeInsets.all(VisualThemeV3.spacingM),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                        VisualThemeV3.cardRadius,
                      ),
                      boxShadow: const [VisualThemeV3.shadowLight],
                      gradient: _potShimmerActive
                          ? VisualThemeV3.shimmerGradient
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$ ${_label('Center Pot')}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${_state.pot}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: VisualThemeV3.spacingS),
                        Text(boardDisplay),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Positioned _buildPlayerPosition(
    BuildContext context,
    int index,
    double radius,
    double size,
  ) {
    final player = _players[index];
    final angle = (2 * math.pi * index / _players.length) - math.pi / 2;
    final x = radius * math.cos(angle) + size / 2;
    final y = radius * math.sin(angle) + size / 2;
    final isActive = player == _currentPlayer;
    final stack = _stacks[player] ?? 0;
    final stackLabel = _label('Stack');
    final stackDisplay = '$stackLabel: $stack';
    _playerOffsets[player] = Offset(x, y);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Positioned(
      left: x - 48,
      top: y - 32,
      child: AnimatedContainer(
        duration: VisualThemeV3.speedSlow,
        width: 96,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.secondary.withValues(alpha: 0.24)
              : theme.cardColor.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius - 4),
          border: Border.all(
            color: isActive
                ? colorScheme.secondary
                : colorScheme.primary.withValues(alpha: 0.15),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: VisualThemeV3.accent,
                    blurRadius: VisualThemeV3.glowIntensity,
                    spreadRadius: 2,
                  ),
                  VisualThemeV3.shadowLight,
                ]
              : const [VisualThemeV3.shadowLight],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              player,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            if (_aiAgentsBySeat.containsKey(player))
              Text(
                _aiAgentsBySeat[player]!.persona.fullLabel,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            Text(stackDisplay),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsRow() {
    if (_loop.isRoundComplete) {
      return const SizedBox.shrink();
    }
    if (_isAiTurn) {
      return Center(child: Text(_label('AI acting...')));
    }
    const buttons = <String>['bet', 'call', 'fold', 'check'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: VisualThemeV3.spacingM,
      runSpacing: VisualThemeV3.spacingM,
      children: buttons.map((type) {
        final enabled = _allowedMoves.contains(type);
        return ElevatedButton(
          onPressed: enabled ? () => _handleAction(type) : null,
          child: Text(_actionButtonLabel(type)),
        );
      }).toList(),
    );
  }

  void _handleAction(String type) {
    if (_loop.isRoundComplete) return;
    final player = _currentPlayer;
    if (player == null || _aiSeats.contains(player)) return;
    if (!_allowedMoves.contains(type)) return;

    int amount = 0;
    switch (type) {
      case 'bet':
        amount = 40;
        break;
      case 'call':
        amount = _lastWager;
        break;
      case 'raise':
        amount = _lastWager + 40;
        break;
      default:
        amount = 0;
    }

    final action = <String, Object?>{
      'player': player,
      'type': type,
      'amount': amount,
    };

    bool queued = false;
    _updateState(() {
      _applyResolvedAction(action, isAi: false);
      // Trigger flash for user fold (Φ1)
      if (type == 'fold') {
        _triggerHandResultFlash(false);
      }
      queued = _prepareAiDecision();
    });
    if (queued) {
      _timing.scheduleNextAction(() {});
    }
  }

  void _refreshTurn() {
    if (_loop.isRoundComplete) {
      _currentPlayer = null;
      _allowedMoves = const <String>[];
      return;
    }
    final info = _loop.nextAction();
    _currentPlayer = info['player']?.toString();
    final moves = info['allowed_moves'];
    if (moves is List) {
      _allowedMoves = moves.map((move) => move.toString()).toList();
    } else {
      _allowedMoves = const <String>[];
    }
  }

  bool get _isAiTurn {
    if (_currentPlayer == null) return false;
    return _aiSeats.contains(_currentPlayer);
  }

  void _updateState(VoidCallback updater, {bool measure = true}) {
    if (measure) {
      _frameTimingStart = DateTime.now();
    }
    setState(updater);
    if (measure) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_frameTimingStart == null) {
          return;
        }
        final now = DateTime.now();
        _lastFrameBuildMs = now
            .difference(_frameTimingStart!)
            .inMilliseconds
            .toDouble();
        _frameTimingStart = null;
        _logPerformanceMetrics();
      });
    }
    _syncMascotState();
  }

  void _syncMascotState() {
    if (_loop.isRoundComplete) {
      _mascotController.celebrate();
      return;
    }
    if (_aiThinking) {
      _mascotController.setThinking();
      return;
    }
    _mascotController.setIdle();
  }

  void _handleMotionTick(Duration elapsed) {
    final previous = _lastMotionTick;
    _lastMotionTick = elapsed;
    final deltaSeconds = previous == null
        ? 0.0
        : (elapsed - previous).inMicroseconds / Duration.microsecondsPerSecond;
    final dtSeconds = deltaSeconds.isNegative ? 0.0 : deltaSeconds;
    _motionKernel.tick(dtSeconds);
    GlobalPersonaController.instance.tickClip(dtSeconds * 1000);
    _elapsedMs += dtSeconds * 1000;
    final snapshot = _motionKernel.motionFrameComposer?.compose(_elapsedMs);
    if (!mounted) {
      return;
    }
    setState(() => _motionSnapshot = snapshot);
    GlobalPersonaController.instance.updateMotionBeat(
      _motionKernel.motionPlayback?.lastBeat ?? 0.0,
    );
  }

  void _onFold() => _handleActionIntent('fold', isRaise: false);

  void _onCall() => _handleActionIntent('call', isRaise: false);

  void _onRaise() => _handleActionIntent('raise', isRaise: true);

  void _onRaiseRequest() => _selectRaise(_pendingRaiseAmount);

  void _confirmRaise() {
    if (!mounted) return;
    final validated = _validatePendingRaise(_pendingRaiseAmount);
    setState(() {
      _pendingRaiseAmount = validated;
      _showRaiseConfirm = false;
    });
    _nodeSync();
    _onRaise();
  }

  void _cancelRaise() {
    if (!mounted) return;
    setState(() => _showRaiseConfirm = false);
  }

  void _selectRaise(double amount) {
    final validated = _validatePendingRaise(amount);
    if (!mounted) return;
    setState(() {
      _pendingRaiseAmount = validated;
      _showRaiseConfirm = true;
    });
  }

  void _handleActionIntent(String action, {required bool isRaise}) {
    if (action == 'fold') {
      _tableState.markFold(_activeSeat);
      _betting.applyFold(_activeSeat);
      _motionEngine.onFold(_activeSeat);
      _emitMotionCue(PersonaMotionCue.fold);
    } else if (action == 'call') {
      final callAmount = _betting.toCall(_activeSeat);
      _betting.applyCall(_activeSeat);
      _motionEngine.onCall(_activeSeat, callAmount);
      _emitMotionCue(PersonaMotionCue.call);
    } else if (isRaise) {
      final raiseAmount = _pendingRaiseAmount;
      _betting.applyRaise(_activeSeat, _pendingRaiseAmount);
      _motionEngine.onBetPlaced(_activeSeat, raiseAmount);
      _emitMotionCue(PersonaMotionCue.raise);
    }
    _syncSimulationPot();
    _roundEngine.markActed(_activeSeat);
    _advanceTurn();
    _notifyActiveSeat();
    _notifyPersonaAction(action);
    final activeSeats = _tableState.activeSeats;
    if (_roundEngine.roundComplete(
      activeSeats,
      _betting,
      _stackState,
      _tableState,
    )) {
      _street = _street.advanceStreet();
      _roundEngine.resetRound();
      if (_street.current == Street.showdown) {
        _executeShowdown();
      } else {
        _betting.resetForNextStreet();
        _preparePostflopStreet();
        _startStreetTransitionMotion();
      }
      GlobalPersonaController.instance.router.apply(
        SharkyPersonaEvents.onStreetChange(_street.current.name),
      );
      _emitMotionCue(PersonaMotionCue.street);
    } else {
      _playActionMotion();
    }
    _syncAfterAction();
  }

  void _startStreetTransitionMotion() {
    if (_streetTransitionInProgress) {
      return;
    }
    _setStreetTransitionActive(true);
    final boardPosition = _latestBoardPosition ?? Offset.zero;
    final cardPositions = _boardOffsetsForMotion(boardPosition);
    final transitionScript = MotionScriptBuilder.buildStreetTransition(
      _street.current,
      boardCardPositions: cardPositions,
      boardPosition: boardPosition,
    );
    if (transitionScript.isEmpty) {
      _completeStreetTransition();
      return;
    }
    _forceMotionScript(transitionScript);
    final durationMs = _estimateMotionScriptDuration(transitionScript);
    _streetTransitionTimer?.cancel();
    _streetTransitionTimer = Timer(
      Duration(milliseconds: durationMs.ceil() + 40),
      () {
        if (!mounted) return;
        _completeStreetTransition();
      },
    );
  }

  void _completeStreetTransition() {
    if (!_streetTransitionInProgress) {
      return;
    }
    _streetTransitionTimer?.cancel();
    _streetTransitionTimer = null;
    _setStreetTransitionActive(false);
    _refreshTurn();
    _rebuildMotionScript();
    _nodeSync();
  }

  void _setStreetTransitionActive(bool active) {
    if (_streetTransitionInProgress == active) {
      return;
    }
    _streetTransitionInProgress = active;
    if (active) {
      _allowedMoves = const <String>[];
    }
    _rebuildActionModel();
  }

  List<Offset> _boardOffsetsForMotion(Offset boardPosition) {
    if (_latestBoardCardOffsets.isNotEmpty) {
      return _latestBoardCardOffsets;
    }
    return List<Offset>.generate(5, (_) => boardPosition);
  }

  double _estimateMotionScriptDuration(List<CardMotionSequence> script) {
    var maxEnd = 0.0;
    for (final sequence in script) {
      var cumulativeDelay = 0.0;
      for (final spec in sequence) {
        cumulativeDelay += spec.delayMs;
        final end = cumulativeDelay + spec.durationMs;
        if (end > maxEnd) {
          maxEnd = end;
        }
      }
    }
    return maxEnd;
  }

  double _validatePendingRaise(double amount) {
    final min = _betting.minRaiseAmount();
    final stack = _stackState.stacks[_activeSeat];
    final lower = math.min(min, stack);
    final upper = math.max(min, stack);
    if (!_actionModel.canRaise || upper <= lower) {
      return math.min(stack, upper);
    }
    final clamped = amount.clamp(lower, upper);
    return stack < min ? math.min(clamped, stack) : clamped;
  }

  void _syncSimulationPot() {
    if (_betting.pot.isNaN) {
      return;
    }
    _state.pot = _betting.pot.toInt();
  }

  void _advanceTurn() {
    _activeSeat = _tableState.nextActiveSeat(_activeSeat);
    _turn = TurnEngine(activeSeat: _activeSeat, status: _turn.status);
    _rebuildActionModel();
    _nodeSync();
  }

  void _playActionMotion() {
    final seats = _latestSlots;
    final board = _latestBoardPosition;
    if (seats == null || board == null) {
      return;
    }
    final baseScript = MotionScriptBuilder.demo(
      seats: seats,
      boardPosition: board,
    );
    final boardOffsets = _boardOffsetsForMotion(board);
    final reveal = MotionScriptBuilder.buildStreetReveal(
      _street.current,
      boardCardPositions: boardOffsets,
      boardPosition: board,
    );
    _forceMotionScript([...baseScript, ...reveal]);
    setState(() {
      _elapsedMs = 0.0;
      _motionSnapshot = null;
      _rebuildActionModel();
    });
  }

  static const double _chipMotionDurationMs = 250.0;

  void _handleMotionCommand(MotionCommand command) {
    final nowMs = DateTime.now().millisecondsSinceEpoch.toDouble();
    if (command.type == 'potpull') {
      final translator = WinnerMotionTranslator(
        sidePotLayout: _sidePotLayout,
        seatOffset: _seatOffset,
        durationMs: _chipMotionDurationMs,
      );
      final motions = translator.build(command: command, nowMs: nowMs);
      for (final motion in motions) {
        _chipMotionKey.currentState?.addMotion(motion);
      }
      _potMotionController.startFadeSequence();
      return;
    }
    final start = _seatOffset(command.seat);
    final tier = _sidePotLayout.count > 0
        ? math.max(0, math.min(_sidePotLayout.count - 1, command.potTier))
        : 0;
    final end = _sidePotLayout.getPotCenter(tier);
    final seed = command.timestamp.millisecondsSinceEpoch ^ command.seat;
    final random = math.Random(seed);
    final logBase = math.log(command.amount + 1);
    final count = math.max(
      1,
      math.min(8, logBase.isFinite ? logBase.floor() : 1),
    );
    for (var i = 0; i < count; i++) {
      final jitterStart = Offset(
        start.dx + (random.nextDouble() * 12 - 6),
        start.dy + (random.nextDouble() * 12 - 6),
      );
      final control = Offset(
        (jitterStart.dx + end.dx) * 0.5 + (random.nextDouble() * 12 - 6),
        (jitterStart.dy + end.dy) * 0.5 - 40 + (random.nextDouble() * 8 - 4),
      );
      final motion = ChipMotion(
        startOffset: jitterStart,
        controlOffset: control,
        endOffset: end,
        startTimeMs: nowMs,
        endTimeMs: nowMs + _chipMotionDurationMs,
        amount: command.amount,
      );
      _chipMotionKey.currentState?.addMotion(motion);
    }
  }

  Offset _seatOffset(int seat) {
    if (_latestSlots == null) {
      return Offset.zero;
    }
    for (final slot in _latestSlots!) {
      if (slot.index == seat) {
        return slot.position;
      }
    }
    return Offset.zero;
  }

  void _activateMotionScript(List<TableSeatSlot> seats, Offset boardPosition) {
    if (_motionScriptBound) {
      return;
    }
    _applyMotionScript(
      MotionScriptBuilder.demoWithDualDeal(
        seats: seats,
        boardPosition: boardPosition,
      ),
    );
  }

  void _applyMotionScript(List<CardMotionSequence> script) {
    _motionKernel.bindMotionScript(script);
    _motionScriptBound = true;
  }

  void _forceMotionScript(List<CardMotionSequence> script) {
    _motionScriptBound = false;
    _applyMotionScript(script);
  }

  void _rebuildMotionScript({List<CardMotionSequence>? extras}) {
    final seats = _latestSlots;
    final board = _latestBoardPosition;
    if (seats == null || board == null) {
      return;
    }
    final allExtras = <CardMotionSequence>[];
    if (extras != null) {
      allExtras.addAll(extras);
    }
    final script = MotionScriptBuilder.demoWithDualDeal(
      seats: seats,
      boardPosition: board,
      extras: allExtras,
    );
    _forceMotionScript(script);
    setState(() {
      _elapsedMs = 0.0;
      _motionSnapshot = null;
      _rebuildActionModel();
    });
  }

  ActionBarModel _buildActionModel() {
    final engine = ActionStateEngine(
      activeSeat: _turn.activeSeat,
      maxSeat: _handSeats.length,
      betting: _betting,
      table: _tableState,
    );
    final model = engine.rebuildFromSimulationState(_state);
    _updateSidePotLayout();
    return model;
  }

  void _updateSidePotLayout() {
    final board = _latestBoardPosition ?? Offset.zero;
    final allInCount = _handSeats.where(_stackState.isAllIn).length;
    final potCount = math.max(1, 1 + allInCount);
    _sidePotLayout = SidePotLayout(boardPosition: board, potCount: potCount);
  }

  List<SeatVisualState> _buildSeatStates() {
    return List<SeatVisualState>.generate(_handSeats.length, (index) {
      return SeatVisualState(
        seatIndex: index,
        isActive: index == _turn.activeSeat,
        isFolded: _tableState.isFolded(index),
        isActed: _roundEngine.hasActed(index),
        isAllIn: _stackState.isAllIn(index),
      );
    });
  }

  void _notifyPersonaAction(String action) {
    GlobalPersonaController.instance.router.apply(
      SharkyPersonaEvents.onAction(action),
    );
  }

  void _emitMotionCue(PersonaMotionCue cue) {
    final controller = GlobalPersonaController.instance;
    final signal = SharkyMotionSignal(cue, _currentMotionBeat);
    controller.onMotionCue(cue, _currentMotionBeat);
    controller.maybeTriggerFromCue(signal);
    _nodeSync();
  }

  double get _currentMotionBeat =>
      _motionKernel.motionPlayback?.lastBeat ?? 0.0;

  List<Offset> _computeBoardCardOffsets(Offset center) {
    const widths = 56.0;
    const height = 120.0;
    const offsets = [-1.8, -0.9, 0.0, 0.9, 1.8];
    final offsetY = height * 0.01;
    return offsets.map((x) => center + Offset(x * widths, offsetY)).toList();
  }

  void _notifyActiveSeat() {
    GlobalPersonaController.instance.router.apply(
      SharkyPersonaEvents.onActiveSeat(_turn.activeSeat),
    );
  }

  void _nodeSync() {
    final controller = GlobalPersonaController.instance;
    final state = PersonaNodeSyncState(
      activeSeat: _activeSeat,
      turnSeat: _turn.activeSeat,
      street: _street.current.name,
      beat: _currentMotionBeat,
    );
    controller.updateNodeSync(state);
  }

  int get _seatCount => _handSeats.length;

  int get _preflopUtgSeat =>
      _seatCount == 0 ? 0 : (_dealerPhaseResult.bigBlindSeat + 1) % _seatCount;

  bool get _isPostflopStreet => _postflopStreets.contains(_street.current);

  void _updatePreflopActiveSeat() {
    if (_seatCount == 0) return;
    final next = _preflopActionEngine.nextToAct(
      smallBlindSeat: _dealerPhaseResult.smallBlindSeat,
      bigBlindSeat: _dealerPhaseResult.bigBlindSeat,
      utgSeat: _preflopUtgSeat,
      table: _tableState,
      betting: _betting,
      round: _roundEngine,
      seatCount: _seatCount,
    );
    _activeSeat = next;
    _turn = TurnEngine(activeSeat: next, status: TurnStatus.waitingForPlayer);
  }

  int _findUtgSeatInPlay() {
    if (_seatCount == 0) return 0;
    for (var offset = 0; offset < _seatCount; offset++) {
      final candidate =
          (_dealerPhaseResult.bigBlindSeat + 1 + offset) % _seatCount;
      if (!_tableState.isFolded(candidate)) {
        return candidate;
      }
    }
    final active = _tableState.activeSeats;
    return active.isNotEmpty ? active.first : _preflopUtgSeat;
  }

  void _updatePostflopActiveSeat({bool updateTurn = true}) {
    if (_seatCount == 0) return;
    final next = _postflopActionEngine.nextToAct(
      currentActiveSeat: _activeSeat,
      table: _tableState,
      betting: _betting,
      round: _roundEngine,
      seatCount: _seatCount,
    );
    _activeSeat = next;
    if (updateTurn) {
      _turn = TurnEngine(activeSeat: next, status: TurnStatus.waitingForPlayer);
    }
  }

  void _preparePostflopStreet() {
    _activeSeat = _findUtgSeatInPlay();
    _updatePostflopActiveSeat();
  }

  void _startNewHand() {
    final result = _dealerPhaseEngine.startNewHand(_seatCount);
    _dealerPhaseResult = result;
    _street = const StreetEngine(Street.preflop);
    _tableState.folded.clear();
    _roundEngine.resetRound();
    _betting.resetForNextStreet();
    _blindPostingEngine.postBlinds(
      smallBlindSeat: result.smallBlindSeat,
      bigBlindSeat: result.bigBlindSeat,
      stacks: _stackState,
      betting: _betting,
      smallBlindAmount: 1,
      bigBlindAmount: 2,
    );
    _updatePreflopActiveSeat();
    _rebuildActionModel();
    _nodeSync();
  }

  void _rebuildActionModel() {
    final baseModel = _buildActionModel();
    _actionModel = _streetTransitionInProgress
        ? _lockedActionModel(baseModel)
        : baseModel;
    if (!_actionModel.legalRaise && _showRaiseConfirm) {
      _showRaiseConfirm = false;
    }
  }

  ActionBarModel _lockedActionModel(ActionBarModel base) {
    return ActionBarModel(
      canFold: false,
      canCall: false,
      canRaise: false,
      legalFold: base.legalFold,
      legalCall: base.legalCall,
      legalRaise: base.legalRaise,
      callAmount: base.callAmount,
      minRaiseAmount: base.minRaiseAmount,
      maxRaiseAmount: base.maxRaiseAmount,
      presets: base.presets,
    );
  }

  void _syncAfterAction() {
    if (_street.current == Street.preflop) {
      _updatePreflopActiveSeat();
    } else if (_isPostflopStreet) {
      _updatePostflopActiveSeat();
    }
    _nodeSync();
    _rebuildActionModel();
    if (!mounted) return;
    setState(() {});
  }

  void _executeShowdown() {
    final potAmount = _betting.pot;
    final hands = List<List<Object>>.generate(
      _handSeats.length,
      (index) => <Object>[index],
    );
    final contributions = List<double>.from(_betting.contributed);
    final pots = _sidePot.buildSidePots(contributions);
    _showdown.distributeSidePots(pots, hands);
    final seatOffsets = _latestSlots != null
        ? List<Offset>.generate(
            _handSeats.length,
            (index) => _latestSlots!
                .firstWhere(
                  (slot) => slot.index == index,
                  orElse: () =>
                      TableSeatSlot(index: index, position: Offset.zero),
                )
                .position,
          )
        : List<Offset>.filled(_handSeats.length, Offset.zero);
    final boardOffset = _latestBoardPosition ?? Offset.zero;
    final chipFlow = <CardMotionSequence>[];
    for (final pot in pots) {
      final winners = _showdown.computeWinnersForEligible(
        hands,
        pot.eligibleSeats,
      );
      if (winners.isEmpty) continue;
      chipFlow.add(
        MotionScriptBuilder.buildSidePotDistribution(
          seatOffsets,
          winners,
          boardOffset,
        ),
      );
    }
    final boardOffsetsToUse = _latestBoardCardOffsets.isNotEmpty
        ? _latestBoardCardOffsets
        : _computeBoardCardOffsets(boardOffset);
    final resetSequence = MotionScriptBuilder.buildHandResetBundle(
      boardOffsetsToUse,
      boardOffset,
    );
    chipFlow.add(resetSequence);
    _motionEngine.onPotPull(_turn.activeSeat, potAmount);
    _emitMotionCue(PersonaMotionCue.winner);
    _betting.pot = 0.0;
    _syncSimulationPot();
    _stackState.resetForNextHand();
    _rebuildMotionScript(extras: chipFlow);
    _timing.scheduleNextAction(() {
      if (!mounted) return;
      _startNewHand();
      _rebuildMotionScript();
    });
  }

  Future<void> _loadSessionSummary() async {
    final metrics = await SessionSummaryService.instance.fetchLastSession();
    if (!mounted) return;
    setState(() {
      _sessionMetrics = metrics;
      _showSessionSummary = true;
    });
  }

  void _dismissSessionSummary() {
    setState(() {
      _showSessionSummary = false;
    });
  }

  bool _prepareAiDecision() {
    _refreshTurn();
    if (!_isAiTurn || _loop.isRoundComplete) {
      _aiThinking = false;
      _aiDecisionStart = null;
      return false;
    }
    _aiThinking = true;
    final personaDelay = _currentPlayer != null
        ? _aiAgentsBySeat[_currentPlayer!]?.persona.delayMs
        : null;
    final delayMs = personaDelay ?? _timing.delayMs;
    _aiProgressController
      ..duration = Duration(milliseconds: delayMs)
      ..reset()
      ..forward();
    _aiDecisionStart = DateTime.now();
    return true;
  }

  void _processAiAction() {
    if (_loop.isRoundComplete) {
      _updateState(() {
        _aiThinking = false;
        _aiProgressController.stop();
      }, measure: false);
      _timing.signalRoundComplete();
      _loadSessionSummary();
      return;
    }

    _refreshTurn();
    if (!_isAiTurn) {
      _updateState(() {
        _aiThinking = false;
        _aiProgressController.stop();
      }, measure: false);
      return;
    }

    final actingPlayer = _currentPlayer ?? _state.players[_state.currentIndex];
    final personaAgent = _aiAgentsBySeat[actingPlayer];
    final agent = personaAgent?.agent ?? _fallbackAgent;
    final decision = agent.decideAction(_state);
    final telemetryPayload =
        (decision['telemetry'] as Map<String, Object?>?) ?? const {};
    final enrichedTelemetry = personaAgent == null
        ? telemetryPayload
        : {
            ...telemetryPayload,
            'persona_id': personaAgent.persona.id,
            'persona_label': personaAgent.persona.displayName,
          };
    FirebaseLiteTelemetryService.instance.logAiDecision({
      ...enrichedTelemetry,
      'round_pot': _state.pot,
    });

    final action = <String, Object?>{
      'player': decision['player'],
      'type': decision['type'],
      'amount': decision['amount'],
    };

    _updateState(() {
      _aiThinking = false;
      _aiProgressController.stop();
      _applyResolvedAction(action, isAi: true);
      _updateAiDecisionMetrics();
    });

    if (_loop.isRoundComplete) {
      _timing.signalRoundComplete();
      _loadSessionSummary();
    } else {
      final queued = _prepareAiDecision();
      if (queued) {
        _timing.scheduleNextAction(() {});
      }
    }
  }

  void _applyResolvedAction(
    Map<String, Object?> action, {
    required bool isAi,
    bool record = true,
    bool animate = true,
  }) {
    final actionForState = Map<String, Object?>.from(action);
    _loop.resolve(actionForState);
    final amount = (actionForState['amount'] as num?)?.toInt() ?? 0;
    final player = actionForState['player']?.toString() ?? '';
    final type = (actionForState['type'] ?? 'unknown').toString();

    if (type == 'bet' || type == 'raise') {
      _lastWager = amount;
    } else if (type == 'call' && amount > 0) {
      _lastWager = amount;
    }

    if (amount > 0) {
      final currentStack = _stacks[player] ?? 0;
      _stacks[player] = (currentStack - amount).clamp(0, 100000);
      if (animate) {
        _triggerChipFlight(player);
        // Trigger pot shimmer (Φ1)
        _triggerPotShimmer();
      }
      if (record) {
        final now = DateTime.now();
        if (_lastPotUpdateTime != null) {
          _lastPotLatencyMs = now
              .difference(_lastPotUpdateTime!)
              .inMilliseconds
              .toDouble();
        }
        _lastPotUpdateTime = now;
      }
    }

    if (record) {
      final stored = Map<String, Object?>.from(actionForState)
        ..['is_ai'] = isAi;
      _replay.recordAction(stored);
    }

    _appendLog(
      seat: player,
      type: type,
      amount: amount,
      isAi: isAi,
      animated: animate,
    );

    if (_loop.isRoundComplete) {
      _currentPlayer = null;
      _allowedMoves = const <String>[];
    } else {
      _refreshTurn();
    }
  }

  void _appendLog({
    required String seat,
    required String type,
    required int amount,
    required bool isAi,
    bool animated = true,
  }) {
    final entry = _LogEntry(seat: seat, type: type, amount: amount, isAi: isAi)
      ..updateLocalized(_localization, _currentLanguage);
    if (!animated) {
      entry.visible = true;
      _logEntries.add(entry);
      return;
    }
    _logEntries.add(entry);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateState(() => entry.visible = true, measure: false);
    });
  }

  void _triggerChipFlight(String player) {
    _updateState(() {
      _chipFlight = _ChipFlight(player: player, toCenter: false);
    }, measure: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _chipFlight == null) return;
      _updateState(() {
        _chipFlight = _chipFlight!.copyWith(toCenter: true);
      }, measure: false);
      Future<void>.delayed(VisualThemeV3.speedNormal, () {
        if (!mounted) return;
        _updateState(() => _chipFlight = null, measure: false);
      });
    });
  }

  void _triggerPotShimmer() {
    _updateState(() => _potShimmerActive = true, measure: false);
    Future<void>.delayed(VisualThemeV3.speedFast, () {
      if (!mounted) return;
      _updateState(() => _potShimmerActive = false, measure: false);
    });
  }

  void _triggerHandResultFlash(bool isWin) {
    _updateState(() {
      _handResultFlash = isWin ? 'win' : 'loss';
      _handResultOpacity = 1.0;
    }, measure: false);
    Future<void>.delayed(VisualThemeV3.speedSlow, () {
      if (!mounted) return;
      _updateState(() => _handResultOpacity = 0.0, measure: false);
      Future<void>.delayed(VisualThemeV3.speedSlow, () {
        if (!mounted) return;
        _updateState(() => _handResultFlash = null, measure: false);
      });
    });
  }

  void _updateAiDecisionMetrics() {
    if (_aiDecisionStart == null) {
      return;
    }
    final elapsed = DateTime.now()
        .difference(_aiDecisionStart!)
        .inMilliseconds
        .toDouble();
    _lastAiDecisionMs = elapsed;
    _aiDecisionCount += 1;
    _avgAiDecisionMs =
        ((_avgAiDecisionMs * (_aiDecisionCount - 1)) + elapsed) /
        _aiDecisionCount;
    _aiDecisionStart = null;
  }

  Widget _buildReplayControls() {
    final summaryText = _replay.summary(_label('actions played'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(summaryText, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          children: [
            OutlinedButton(
              onPressed: _canStepBack ? _handleReplayPrev : null,
              child: Text(_label('Prev')),
            ),
            OutlinedButton(
              onPressed: _canStepForward ? _handleReplayNext : null,
              child: Text(_label('Next')),
            ),
            OutlinedButton(
              onPressed: _replay.hasHistory ? _handleReplayRestart : null,
              child: Text(_label('Restart')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMascotOverlay(BuildContext context, bool isCompact) {
    final opacity = _mascotController.opacity;
    if (opacity <= 0.01) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = isCompact ? 150.0 : 180.0;
    return AnimatedOpacity(
      opacity: opacity,
      duration: VisualThemeV3.speedNormal,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(VisualThemeV3.spacingM),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _label('Poker Shark'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: VisualThemeV3.spacingL),
            Text(
              '${_label('Pose')}: ${_mascotController.poseLabel}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: VisualThemeV3.spacingS),
            Container(
              padding: const EdgeInsets.all(VisualThemeV3.spacingM),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(
                  VisualThemeV3.cardRadius / 2,
                ),
              ),
              child: Text(
                _mascotController.assetName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryOverlay(BuildContext context, bool isCompact) {
    final width = isCompact ? 190.0 : 220.0;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final headerStyle = (theme.textTheme.titleSmall ?? const TextStyle())
        .copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        );
    final valueStyle = (theme.textTheme.bodySmall ?? const TextStyle())
        .copyWith(color: colorScheme.onPrimary, fontSize: 12);
    return IgnorePointer(
      ignoring: true,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(VisualThemeV3.spacingS),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius - 4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_label('Telemetry Metrics'), style: headerStyle),
            const SizedBox(height: VisualThemeV3.spacingS),
            Text(
              '${_label('AI delay (ms)')}: '
              'L ${_lastAiDecisionMs.toStringAsFixed(1)} / '
              'A ${_avgAiDecisionMs.toStringAsFixed(1)}',
              style: valueStyle,
            ),
            Text(
              '${_label('Frame build (ms)')}: '
              '${_lastFrameBuildMs.toStringAsFixed(1)}',
              style: valueStyle,
            ),
            Text(
              '${_label('Pot latency (ms)')}: '
              '${_lastPotLatencyMs.toStringAsFixed(1)}',
              style: valueStyle,
            ),
          ],
        ),
      ),
    );
  }

  bool get _canStepBack => _replay.currentIndex > 0;
  bool get _canStepForward => _replay.currentIndex < _replay.totalActions;

  void _handleReplayPrev() {
    if (!_replay.stepBack()) {
      return;
    }
    _updateState(_rebuildFromReplay, measure: false);
  }

  void _handleReplayNext() {
    if (!_replay.stepForward()) {
      return;
    }
    _updateState(_rebuildFromReplay, measure: false);
  }

  void _handleReplayRestart() {
    if (!_replay.hasHistory) {
      return;
    }
    _replay.resetReplay();
    _updateState(_rebuildFromReplay, measure: false);
  }

  void _rebuildFromReplay() {
    final applied = _replay.appliedActions;
    _aiThinking = false;
    _aiProgressController.stop();
    _aiProgressController.value = 0.0;
    _chipFlight = null;
    _timing.reset();
    _aiDecisionStart = null;
    _elapsedMs = 0.0;
    _motionSnapshot = null;
    _lastMotionTick = null;

    _state = SimulationState(
      players: _players,
      board: List<String>.from(_board),
    );
    _loop = ActionLoop(ActionQueue(<Map<String, Object?>>[]), _state);
    _stacks = {for (final player in _players) player: _startingStack};
    _logEntries.clear();
    _currentPlayer = null;
    _allowedMoves = const <String>[];
    _lastWager = 0;

    for (final action in applied) {
      final isAi = action['is_ai'] == true;
      final replayAction = Map<String, Object?>.from(action);
      replayAction.remove('is_ai');
      _applyResolvedAction(
        replayAction,
        isAi: isAi,
        record: false,
        animate: false,
      );
    }

    _refreshTurn();
  }

  String _label(String key) => _localization.translate(key, _currentLanguage);

  String _actionButtonLabel(String type) {
    final base = _localization.translate(
      _LogEntry.actionLabelFromType(type),
      _currentLanguage,
    );
    // ASCII-only icons: ^ for bet/raise, v for fold; others no icon
    final icon = () {
      switch (type) {
        case 'bet':
        case 'raise':
          return '^ ';
        case 'fold':
          return 'v ';
        default:
          return '';
      }
    }();
    return (icon + base).toUpperCase();
  }

  void _registerDefaultTranslations() {
    const translations = <String, String>{
      'Simulation Table': 'Стол симуляции',
      'Pot': 'Банк',
      'Board': 'Борд',
      'AI thinking...': 'ИИ думает...',
      'AI acting...': 'ИИ выполняет действие...',
      'Round complete': 'Раунд завершен',
      'Action log': 'Журнал действий',
      'No actions yet.': 'Пока нет действий.',
      'Bet': 'Ставка',
      'Call': 'Колл',
      'Fold': 'Сброс',
      'Check': 'Чек',
      'AI': 'ИИ',
      'Center Pot': 'Центральный банк',
      'Stack': 'Стек',
      'Prev': 'Назад',
      'Next': 'Вперед',
      'Restart': 'Сброс',
      'actions played': 'ходов завершено',
      'Telemetry ON': 'Телеметрия ВКЛ',
      'Telemetry OFF': 'Телеметрия ВЫКЛ',
      'Telemetry Metrics': 'Метрики телеметрии',
      'AI delay (ms)': 'Задержка ИИ (мс)',
      'Frame build (ms)': 'Перерисовка (мс)',
      'Pot latency (ms)': 'Задержка банка (мс)',
    };
    translations.forEach((source, translated) {
      _localization.addTranslation(
        source: source,
        languageCode: 'ru',
        translation: translated,
      );
    });
  }

  void _toggleLanguage() {
    _updateState(() {
      _currentLanguage = _currentLanguage == 'en' ? 'ru' : 'en';
      for (final entry in _logEntries) {
        entry.updateLocalized(_localization, _currentLanguage);
      }
    }, measure: false);
  }

  void _toggleTelemetry() {
    _updateState(() {
      _telemetryEnabled = !_telemetryEnabled;
    }, measure: false);
    if (_telemetryEnabled) {
      _logPerformanceMetrics();
    }
  }

  void _logPerformanceMetrics() {
    if (!_telemetryEnabled) {
      return;
    }
    FirebaseLiteTelemetryService.instance.logPerformanceMetrics({
      'ai_last_ms': double.parse(_lastAiDecisionMs.toStringAsFixed(2)),
      'ai_avg_ms': double.parse(_avgAiDecisionMs.toStringAsFixed(2)),
      'frame_last_ms': double.parse(_lastFrameBuildMs.toStringAsFixed(2)),
      'pot_latency_ms': double.parse(_lastPotLatencyMs.toStringAsFixed(2)),
      'language': _currentLanguage,
      'actions_index': _replay.currentIndex,
      'actions_total': _replay.totalActions,
    });
  }
}

class _LogEntry {
  _LogEntry({
    required this.seat,
    required this.type,
    required this.amount,
    required this.isAi,
  }) : id = UniqueKey();

  final Key id;
  final String seat;
  final String type;
  final int amount;
  final bool isAi;
  bool visible = false;
  String localized = '';

  void updateLocalized(LocalizationCore localization, String language) {
    final actor = isAi
        ? '${localization.translate('AI', language)} ${seat.toUpperCase()}'
        : seat.toUpperCase();
    final actionLabel = localization
        .translate(actionLabelFromType(type), language)
        .toUpperCase();
    final amountPart = amount > 0 ? ' $amount' : '';
    localized = '$actor -> $actionLabel$amountPart';
  }

  static String actionLabelFromType(String type) {
    switch (type) {
      case 'bet':
      case 'raise':
        return 'Bet';
      case 'call':
        return 'Call';
      case 'fold':
        return 'Fold';
      case 'check':
      default:
        return 'Check';
    }
  }
}

class _ChipFlight {
  const _ChipFlight({required this.player, required this.toCenter});

  final String player;
  final bool toCenter;

  _ChipFlight copyWith({bool? toCenter}) {
    return _ChipFlight(player: player, toCenter: toCenter ?? this.toCenter);
  }
}
