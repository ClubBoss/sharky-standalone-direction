// VISUAL_SSOT_V1
// Canonical Modern Table implementation used by Tools/ProgressMap.
// All Modern Table visual work must stay here and in
// test/ui_v2/modern_table_entry_test.dart.
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/content/scenario_asset_index_v1.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_table_topology_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_seat_state_badge_v1.dart';

// VISUAL SSOT v1 — FROZEN. Changes require explicit SSOT v2.
// VISUAL_SSOT_V1: visual-only constants; no FSM/engine changes.
class _ModernTableVisualSsotV1 {
  const _ModernTableVisualSsotV1();

  static const double tableAspectRatio = 1.38;
  static const double tableWidthRatio = 0.92;
  static const double boardWidthRatio = 0.64;
  static const double cardAspectRatio = 5 / 7;
  static const double heroCardScale = 1.46;
  static const double heroCardRotationLeftDeg = -3;
  static const double heroCardRotationRightDeg = 3;
  static const double heroShadowOpacity = 0.35;
  static const double heroShadowBlur = 11;
  static const Offset heroShadowOffset = Offset(0, 6);
  static const double heroOverlapRatio = 0.24;
}

class _LayoutNumbersV1 {
  const _LayoutNumbersV1();

  static const double headerHeight = 56;
  static const double reasonMinHeight = 24;
  static const double actionBarHeight = 130;
  static const double scenePaddingH = 16;
  static const double scenePaddingV = 0;
  static const double seatRadius = 1.04;
  static const double seatSize = 88;
  static const double heroSeatSize = 112;
  static const double actionButtonRadius = 18;
  static const double potBottomSeatClearanceFactor = 0.1;
  static const double potBottomMinFraction = 0.12;
  static const double boardPaddingV = 7;
  static const double boardPaddingH = 10;
  static const double boardRadius = 20;
  static const double ovalInset = 6;
  static const double boardCardAspectRatio =
      _ModernTableVisualSsotV1.cardAspectRatio;
  static const double potLabelHeight = 28;
  static const double heroCardScale = _ModernTableVisualSsotV1.heroCardScale;
  static const double heroCardBottomPadding = 8;
  static const double heroCardPotGap = 8;
  static const double heroCardBoardGap = 6;
  static const double embeddedStateZoneHeight = 52;
  static const double embeddedStateZoneGap = 3;
  static const double showdownTopSeatBoardClearance = 32;
}

const double kOvalOpticalCenterShiftFrac = 0.05;
const bool kEnableMetricsOverlay = bool.fromEnvironment(
  'ENABLE_TABLE_METRICS_OVERLAY',
  defaultValue: false,
);

class _SceneScaleBucket {
  const _SceneScaleBucket({
    required this.ovalAspectRatio,
    required this.sceneFillFactor,
    required this.potToBoardGap,
    required this.heroOverlap,
  });

  final double ovalAspectRatio;
  final double sceneFillFactor;
  final double potToBoardGap;
  final double heroOverlap;
}

class _SceneScaleNumbersV1 {
  const _SceneScaleNumbersV1();

  static const double ovalWidthRatio = _ModernTableVisualSsotV1.tableWidthRatio;
  static const _SceneScaleBucket seBucket = _SceneScaleBucket(
    ovalAspectRatio: _ModernTableVisualSsotV1.tableAspectRatio,
    sceneFillFactor: 0.985,
    potToBoardGap: 7,
    heroOverlap: _ModernTableVisualSsotV1.heroOverlapRatio,
  );
  static const _SceneScaleBucket midBucket = _SceneScaleBucket(
    ovalAspectRatio: _ModernTableVisualSsotV1.tableAspectRatio,
    sceneFillFactor: 0.9,
    potToBoardGap: 14,
    heroOverlap: _ModernTableVisualSsotV1.heroOverlapRatio,
  );
  static const _SceneScaleBucket maxBucket = _SceneScaleBucket(
    ovalAspectRatio: _ModernTableVisualSsotV1.tableAspectRatio,
    sceneFillFactor: 0.86,
    potToBoardGap: 20,
    heroOverlap: _ModernTableVisualSsotV1.heroOverlapRatio,
  );

  static _SceneScaleBucket bucketForSize(Size size) {
    if (size.height <= 700) {
      return seBucket;
    }
    if (size.height <= 900) {
      return midBucket;
    }
    return maxBucket;
  }
}

// Scene layer order SSOT:
// felt/background -> board -> pot -> seats -> hero cards.
List<Widget> _buildSceneLayers({
  required Widget felt,
  required Widget board,
  required Widget? villainCards,
  required Widget? pot,
  required List<Widget> seats,
  required Widget? heroCards,
}) {
  return [
    felt,
    board,
    if (villainCards != null) villainCards,
    if (pot != null) pot,
    ...seats,
    if (heroCards != null) heroCards,
  ];
}

Rect _computeOvalRect({
  required Size screenSize,
  required BoxConstraints constraints,
  required double bottomPadding,
  double headerHeightBudget = _LayoutNumbersV1.headerHeight,
  double actionBarHeightBudget = _LayoutNumbersV1.actionBarHeight,
  double topReserved = 0,
  double bottomReserved = 0,
  double? widthRatioOverride,
  double? sceneFillFactorOverride,
  double? aspectRatioOverride,
}) {
  final bucket = _SceneScaleNumbersV1.bucketForSize(screenSize);
  final sceneVerticalPaddingBudget =
      _LayoutNumbersV1.reasonMinHeight + (_LayoutNumbersV1.scenePaddingV * 2);
  final rawSceneHeight =
      screenSize.height -
      headerHeightBudget -
      actionBarHeightBudget -
      bottomPadding -
      topReserved -
      bottomReserved -
      sceneVerticalPaddingBudget;
  final sceneHeight = math.max(
    0.0,
    constraints.maxHeight.isFinite
        ? math.min(constraints.maxHeight, rawSceneHeight)
        : rawSceneHeight,
  );
  const sceneTop = 0.0;
  final maxWidth = constraints.maxWidth.isFinite
      ? constraints.maxWidth
      : screenSize.width;
  final width =
      maxWidth * (widthRatioOverride ?? _SceneScaleNumbersV1.ovalWidthRatio);
  final targetHeight = width * (aspectRatioOverride ?? bucket.ovalAspectRatio);
  final heightCap =
      sceneHeight * (sceneFillFactorOverride ?? bucket.sceneFillFactor);
  final height = math.min(targetHeight, heightCap);
  final center = Offset(
    maxWidth / 2,
    sceneTop +
        topReserved +
        (sceneHeight / 2) -
        (sceneHeight * kOvalOpticalCenterShiftFrac),
  );
  return Rect.fromCenter(center: center, width: width, height: height);
}

BoxDecoration _glassPillDecoration({
  required double radius,
  double fillOpacity = 0.6,
  double borderOpacity = 1.0,
}) {
  final topFill = math.min(1.0, fillOpacity + 0.06);
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.black.withOpacity(topFill),
        Colors.black.withOpacity(fillOpacity),
      ],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: Colors.white.withOpacity(0.12 * borderOpacity),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 7,
        offset: const Offset(0, 3),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.08 * borderOpacity),
        blurRadius: 4,
        offset: const Offset(-1, -1),
      ),
    ],
  );
}

class _SeatAnchor {
  const _SeatAnchor(this.normalized, {this.radialScale = 1.0});

  final Offset normalized;
  final double radialScale;
}

class _SeatAnchorsV1 {
  const _SeatAnchorsV1();

  static const int heroSlotId = 0;
  static const List<_SeatAnchor> anchors = [
    _SeatAnchor(Offset(0.00, 0.86), radialScale: 1.02), // hero / btn
    _SeatAnchor(Offset(0.00, -0.92), radialScale: 1.06), // utg
    _SeatAnchor(Offset(0.74, -0.52), radialScale: 1.10), // hj
    _SeatAnchor(Offset(-0.74, -0.52), radialScale: 1.10), // bb
    _SeatAnchor(Offset(0.68, 0.40), radialScale: 1.02), // co
    _SeatAnchor(Offset(-0.68, 0.40), radialScale: 1.02), // sb
    _SeatAnchor(Offset(0.44, -0.68), radialScale: 0.96), // lj
    _SeatAnchor(Offset(-0.44, -0.68), radialScale: 0.94), // utg1
    _SeatAnchor(Offset(0.44, 0.68), radialScale: 1.04), // right lower shoulder
    _SeatAnchor(Offset(-0.76, -0.16), radialScale: 1.00), // mp
  ];

  static const List<int> fillOrder = [heroSlotId, 1, 2, 3, 4, 5, 6, 7, 8, 9];
}

class _SeatLayout {
  const _SeatLayout({required this.center, required this.size});

  final Offset center;
  final double size;
}

class _CardClusterLayoutV1 {
  const _CardClusterLayoutV1({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

typedef HoleCardTapCallbackV1 = void Function(String cardSlot, String? cardId);

enum ModernTableSeatStateVisualProfileV1 { dense, learnerEmbedded }

enum ModernTableSceneLanePromptProfileV1 {
  standard,
  compactStateOnly,
  guidedTeaching,
}

enum ModernTableEmbeddedSceneGeometryProfileV1 {
  standard,
  screenOwnedLivePortrait,
}

class ModernTableScreenV1 extends StatefulWidget {
  const ModernTableScreenV1({
    super.key,
    this.seatCount = 6,
    this.embeddedV1 = false,
    this.actingSeat,
    this.selectedSeatV1,
    this.showsActingSeatV1 = true,
    this.scenarioSpec,
    this.scenarioJson,
    this.scenarioAssetPath,
    this.debugBoardCardLabels,
    this.debugHeroCardLabels,
    this.debugVillainCardLabels,
    this.debugShowdownWinnerActionId,
    this.debugSeatRoleLabels,
    this.debugSeatMarkerLabels,
    this.debugSeatContributionAmountsV1,
    this.debugPriceSetterSeatIndexV1,
    this.debugPriceSetterCueLabelV1,
    this.debugSceneProofLabel,
    this.debugScenePromptLabel,
    this.debugEmbeddedInstructionLabelV1,
    this.debugPotDisplayLabelV1,
    this.debugScenePriceLabelV1,
    this.seatStateVisualProfileV1 = ModernTableSeatStateVisualProfileV1.dense,
    this.sceneLanePromptProfileV1 =
        ModernTableSceneLanePromptProfileV1.standard,
    this.embeddedSceneGeometryProfileV1 =
        ModernTableEmbeddedSceneGeometryProfileV1.standard,
    this.useReferenceParityLiveProfileV1 = false,
    this.onSeatTapV1,
    this.onActionTapV1,
    this.onBoardSlotTapV1,
    this.onHoleCardTapV1,
    this.onHoleCardTapDetailV1,
  }) : assert(seatCount >= 2 && seatCount <= 10);

  final int seatCount;
  final bool embeddedV1;
  final int? actingSeat;
  final int? selectedSeatV1;
  final bool showsActingSeatV1;
  final ScenarioSpecV1? scenarioSpec;
  final String? scenarioJson;
  final String? scenarioAssetPath;
  final List<String>? debugBoardCardLabels;
  final List<String>? debugHeroCardLabels;
  final List<String>? debugVillainCardLabels;
  final String? debugShowdownWinnerActionId;
  final Map<int, String>? debugSeatRoleLabels;
  final Map<int, String>? debugSeatMarkerLabels;
  final Map<int, int>? debugSeatContributionAmountsV1;
  final int? debugPriceSetterSeatIndexV1;
  final String? debugPriceSetterCueLabelV1;
  final String? debugSceneProofLabel;
  final String? debugScenePromptLabel;
  final String? debugEmbeddedInstructionLabelV1;
  final String? debugPotDisplayLabelV1;
  final String? debugScenePriceLabelV1;
  final ModernTableSeatStateVisualProfileV1 seatStateVisualProfileV1;
  final ModernTableSceneLanePromptProfileV1 sceneLanePromptProfileV1;
  final ModernTableEmbeddedSceneGeometryProfileV1
  embeddedSceneGeometryProfileV1;
  final bool useReferenceParityLiveProfileV1;
  final ValueChanged<int>? onSeatTapV1;
  final ValueChanged<String>? onActionTapV1;
  final ValueChanged<String>? onBoardSlotTapV1;
  final ValueChanged<String>? onHoleCardTapV1;
  final HoleCardTapCallbackV1? onHoleCardTapDetailV1;

  @override
  ModernTableScreenV1State createState() => ModernTableScreenV1State();
}

class ModernTableScreenV1State extends State<ModernTableScreenV1> {
  int? _selectedSeat;
  late ScenarioReplayerFsmV1 _engine;
  late ScenarioState _currentState;
  StreetActiveState? _lastStreetActiveState;
  late ScenarioSpecV1 _scenarioSpec;
  double _betFraction = 0.5;
  bool _continuing = false;
  bool _terminalOutcome = false;
  String? _scenarioError;
  bool _assetLoading = false;
  String? _inlineScenarioJson;
  String? _inlineScenarioAssetPath;
  bool _loaderBusy = false;
  late final TextEditingController _loaderController;
  late final TextEditingController _assetLoaderController;

  bool get _isShowdownSceneV1 =>
      widget.debugShowdownWinnerActionId != null &&
      (widget.debugVillainCardLabels?.length ?? 0) >= 2;

  bool get _usesCompactStateOnlySceneLaneV1 =>
      widget.sceneLanePromptProfileV1 ==
      ModernTableSceneLanePromptProfileV1.compactStateOnly;

  bool get _usesGuidedTeachingSceneLaneV1 =>
      widget.sceneLanePromptProfileV1 ==
      ModernTableSceneLanePromptProfileV1.guidedTeaching;

  bool get _usesScreenOwnedEmbeddedSceneV1 =>
      widget.embeddedSceneGeometryProfileV1 ==
      ModernTableEmbeddedSceneGeometryProfileV1.screenOwnedLivePortrait;

  bool get _usesReferenceParityLiveProfileV1 =>
      widget.embeddedV1 && widget.useReferenceParityLiveProfileV1;

  double get _embeddedSceneLaneTopReserveV1 => _usesCompactStateOnlySceneLaneV1
      ? (_usesReferenceParityLiveProfileV1
            ? 0.0
            : (_usesScreenOwnedEmbeddedSceneV1 ? 58.0 : 68.0))
      : (_usesGuidedTeachingSceneLaneV1
            ? (_usesScreenOwnedEmbeddedSceneV1 ? 152.0 : 182.0)
            : (_usesReferenceParityLiveProfileV1
                  ? 0.0
                  : (_usesScreenOwnedEmbeddedSceneV1 ? 68.0 : 120.0)));

  double get _embeddedSceneBottomReserveV1 => _usesReferenceParityLiveProfileV1
      ? 20.0
      : (_usesScreenOwnedEmbeddedSceneV1 ? 34.0 : 0.0);

  void _resetEngine() {
    _scenarioError = null;
    _assetLoading = false;
    if (widget.scenarioSpec != null) {
      _scenarioSpec = widget.scenarioSpec!;
      _startEngine();
      return;
    }
    final jsonSource = _inlineScenarioJson ?? widget.scenarioJson;
    if (jsonSource != null) {
      try {
        final decoded = jsonDecode(jsonSource) as Map<String, Object?>;
        _scenarioSpec = ScenarioSpecV1.fromJson(decoded);
      } catch (error) {
        _scenarioError = 'Scenario load error: ${_sanitizeError(error)}';
        _scenarioSpec = _buildDefaultScenarioSpec();
      }
      _startEngine();
      return;
    }
    final assetPathSource =
        _inlineScenarioAssetPath ?? widget.scenarioAssetPath;
    if (assetPathSource != null) {
      _scenarioSpec = _buildDefaultScenarioSpec();
      _startEngine();
      _loadAssetScenario(assetPathSource);
      return;
    }
    _scenarioSpec = _buildDefaultScenarioSpec();
    _startEngine();
  }

  void _startEngine() {
    _engine = ScenarioReplayerFsmV1.start(_scenarioSpec);
    _currentState = _engine.state;
    if (_currentState is StreetActiveState) {
      _lastStreetActiveState = _currentState as StreetActiveState;
    }
    _terminalOutcome = false;
  }

  void _loadAssetScenario(String path) {
    _assetLoading = true;
    rootBundle
        .loadString(path)
        .then((content) {
          final decoded = jsonDecode(content) as Map<String, Object?>;
          final assetSpec = ScenarioSpecV1.fromJson(decoded);
          if (!mounted) {
            return;
          }
          setState(() {
            _scenarioSpec = assetSpec;
            _scenarioError = null;
            _assetLoading = false;
            _startEngine();
          });
        })
        .catchError((error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _scenarioError = 'Scenario load error: ${_sanitizeError(error)}';
            _assetLoading = false;
            _startEngine();
          });
        });
  }

  @override
  void initState() {
    _loaderController = TextEditingController();
    _assetLoaderController = TextEditingController();
    super.initState();
    _resetEngine();
  }

  @override
  void didUpdateWidget(covariant ModernTableScreenV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seatCount != widget.seatCount) {
      _resetEngine();
    }
  }

  @override
  void dispose() {
    _loaderController.dispose();
    _assetLoaderController.dispose();
    super.dispose();
  }

  int get _seatCountForLayout => _scenarioSpec.seatCount;

  int? get _effectiveSelectedSeatV1 => widget.selectedSeatV1 ?? _selectedSeat;

  void _toggleSeat(int index) {
    if (widget.embeddedV1 &&
        widget.onSeatTapV1 == null &&
        widget.selectedSeatV1 == null) {
      return;
    }
    widget.onSeatTapV1?.call(index);
    setState(() {
      _selectedSeat = _selectedSeat == index ? null : index;
    });
  }

  void _handleAction(String action) {
    if (_currentState is! StreetActiveState || _continuing) {
      return;
    }
    widget.onActionTapV1?.call(action.trim().toLowerCase());
    _currentState = _engine.applyUserAction(action);
    setState(() {
      _selectedSeat = null;
      _terminalOutcome = false;
    });
  }

  void _continueAction() {
    if (_continuing) {
      return;
    }
    _continuing = true;
    final prevState = _currentState;
    _currentState = _engine.advance();
    if (_currentState is StreetActiveState) {
      _lastStreetActiveState = _currentState as StreetActiveState;
      _terminalOutcome = false;
    }
    if (prevState is OutcomeState && _currentState is OutcomeState) {
      _terminalOutcome = true;
    } else if (_currentState is! OutcomeState) {
      _terminalOutcome = false;
    }
    setState(() {
      _selectedSeat = null;
      _continuing = false;
    });
  }

  void _handleLoaderLoad() {
    if (_loaderBusy) {
      return;
    }
    final payload = _loaderController.text.trim();
    if (payload.isEmpty) {
      return;
    }
    setState(() {
      _loaderBusy = true;
      _inlineScenarioJson = payload;
      _inlineScenarioAssetPath = null;
      _resetEngine();
      _loaderBusy = false;
    });
  }

  void _handleLoaderClear() {
    if (_loaderBusy) {
      return;
    }
    setState(() {
      _loaderBusy = true;
      _inlineScenarioJson = null;
      _inlineScenarioAssetPath = null;
      _loaderController.clear();
      _assetLoaderController.clear();
      _resetEngine();
      _loaderBusy = false;
    });
  }

  void _showScenarioLoaderDialog() {
    _loaderController.text = _inlineScenarioJson ?? '';
    _assetLoaderController.text = _inlineScenarioAssetPath ?? '';
    final assetPicks = [
      for (final path in kScenarioAssetPathsV1)
        if (path.startsWith('assets/')) path,
    ];
    const requiredPicks = [
      'assets/scenarios/demo_hu.json',
      'assets/scenarios/demo_6max.json',
      'assets/scenarios/demo_two_nodes.json',
    ];
    final quickPicks = <String>[...assetPicks];
    for (final path in requiredPicks) {
      if (!quickPicks.contains(path)) {
        quickPicks.add(path);
      }
    }
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Scenario Loader'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inline JSON'),
                const SizedBox(height: 6),
                TextField(
                  key: const Key('modern_table_loader_field'),
                  controller: _loaderController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Paste scenario JSON here',
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Asset path'),
                const SizedBox(height: 6),
                TextField(
                  key: const Key('modern_table_loader_asset'),
                  controller: _assetLoaderController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'assets/scenarios/demo.json',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  key: const Key('modern_table_loader_quick_picks'),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick picks',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < quickPicks.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 6,
                                  bottom: 4,
                                ),
                                child: ActionChip(
                                  key: Key('modern_table_loader_quick_pick_$i'),
                                  label: Text(quickPicks[i].split('/').last),
                                  onPressed: () {
                                    _assetLoaderController.text = quickPicks[i];
                                    _handleLoaderLoadAsset(quickPicks[i]);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              key: const Key('modern_table_loader_asset_load'),
              onPressed: () {
                _handleLoaderLoadAsset(_assetLoaderController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Load Asset'),
            ),
            TextButton(
              key: const Key('modern_table_loader_clear'),
              onPressed: () {
                _handleLoaderClear();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              key: const Key('modern_table_loader_load'),
              onPressed: () {
                _handleLoaderLoad();
                Navigator.of(context).pop();
              },
              child: const Text('Load JSON'),
            ),
          ],
        );
      },
    );
  }

  void _handleLoaderLoadAsset(String path) {
    if (_loaderBusy) {
      return;
    }
    final trimmed = path.trim();
    if (trimmed.isEmpty) {
      return;
    }
    setState(() {
      _loaderBusy = true;
      _inlineScenarioAssetPath = trimmed;
      _inlineScenarioJson = null;
      _resetEngine();
      _loaderBusy = false;
    });
  }

  void _restartAction() {
    if (_continuing) {
      return;
    }
    _continuing = true;
    _resetEngine();
    setState(() {
      _selectedSeat = null;
      _terminalOutcome = false;
      _continuing = false;
    });
  }

  bool get _isStreetActive => _currentState is StreetActiveState;

  bool _isActionAllowed(String label) {
    final actions = _lastStreetActiveState?.legalActions ?? [];
    return actions.any((a) => a.toLowerCase() == label.toLowerCase());
  }

  int _boardCardsVisibleCount(Street? street) {
    switch (street) {
      case Street.flop:
        return 3;
      case Street.turn:
        return 4;
      case Street.river:
        return 5;
      case Street.preflop:
      default:
        return 0;
    }
  }

  int _resolvedBoardCardsVisibleCountV1() {
    if (_isShowdownSceneV1) {
      return (widget.debugBoardCardLabels?.length ?? 0).clamp(0, 5);
    }
    return _boardCardsVisibleCount(_lastStreetActiveState?.street);
  }

  double get _villainCardScaleV1 => _isShowdownSceneV1 ? 0.72 : 1.02;

  void _setBetFraction(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (clamped == _betFraction) {
      return;
    }
    setState(() {
      _betFraction = clamped;
    });
  }

  Widget _betSliderRow() {
    final betPercent = (_betFraction * 100).round();
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Container(
              key: const Key('modern_table_bet_slider_stub'),
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineSoft),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const knobSize = 28.0;
                    final trackWidth = constraints.maxWidth;
                    final knobLeft = (trackWidth - knobSize) * _betFraction;
                    return GestureDetector(
                      key: const Key('modern_table_bet_slider_gesture'),
                      behavior: HitTestBehavior.opaque,
                      onPanDown: (details) {
                        _setBetFraction(details.localPosition.dx / trackWidth);
                      },
                      onPanUpdate: (details) {
                        _setBetFraction(details.localPosition.dx / trackWidth);
                      },
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            key: const Key('modern_table_bet_slider_track'),
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF334155), Color(0xFF111827)],
                                stops: [0.0, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0x334B5563),
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3D000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: knobLeft,
                            child: Container(
                              key: const Key('modern_table_bet_slider_knob'),
                              width: knobSize,
                              height: knobSize,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: const Alignment(-0.2, -0.4),
                                  radius: 0.9,
                                  colors: [
                                    const Color(0xFFF8FAFC),
                                    AppColors.primaryBrand,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xCCFFFFFF),
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x55000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            key: const Key('modern_table_bet_slider_value'),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: _glassPillDecoration(radius: 14, fillOpacity: 0.55),
            child: Text(
              'BET $betPercent%',
              textWidthBasis: TextWidthBasis.longestLine,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontFamily: 'monospace',
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE2E8F0),
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final view = View.of(context);
    final viewSize = view.physicalSize / view.devicePixelRatio;
    final effectiveScreenSize = media.size.isEmpty ? viewSize : media.size;
    final activeAssetPath =
        _inlineScenarioAssetPath ?? widget.scenarioAssetPath;
    final scenarioName = _inlineScenarioJson != null
        ? 'inline json'
        : (activeAssetPath != null && activeAssetPath.isNotEmpty)
        ? activeAssetPath.split('/').last
        : 'default';
    final scenarioSource =
        _inlineScenarioJson != null || widget.scenarioJson != null
        ? 'json'
        : (activeAssetPath != null && activeAssetPath.isNotEmpty)
        ? 'asset'
        : 'default';
    final body = MediaQuery(
      data: media,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bottomPadding = widget.embeddedV1
              ? 0.0
              : MediaQuery.of(context).padding.bottom;
          return Column(
            children: [
              if (!widget.embeddedV1)
                SizedBox(
                  key: const Key('modern_table_header'),
                  height: _LayoutNumbersV1.headerHeight,
                  child: SafeArea(
                    top: true,
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Street: ${_lastStreetActiveState?.street.name ?? 'preflop'}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Step 1/1',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    key: const Key('modern_table_clarity'),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant
                                          .withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.outlineSoft,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x22000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Clarity: tactical focus',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.textSecondaryDark,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              key: const Key('modern_table_scenario_chip'),
                              onTap: _showScenarioLoaderDialog,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant.withOpacity(
                                    0.7,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.outlineSoft,
                                  ),
                                ),
                                child: Text(
                                  'Scenario: $scenarioName',
                                  key: const Key('modern_table_scenario_label'),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.textPrimaryDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.embeddedV1 && _isShowdownSceneV1
                          ? 8
                          : widget.embeddedV1 &&
                                _usesReferenceParityLiveProfileV1
                          ? 0
                          : widget.embeddedV1 && _usesScreenOwnedEmbeddedSceneV1
                          ? 6
                          : _LayoutNumbersV1.scenePaddingH,
                      vertical: _LayoutNumbersV1.scenePaddingV,
                    ),
                    child: MediaQuery.withClampedTextScaling(
                      minScaleFactor: 1.0,
                      maxScaleFactor: 1.15,
                      child: RepaintBoundary(
                        child: Container(
                          key: const Key('modern_table_scene'),
                          decoration: BoxDecoration(
                            color: _usesReferenceParityLiveProfileV1
                                ? Colors.transparent
                                : _usesScreenOwnedEmbeddedSceneV1
                                ? AppColors.surface.withOpacity(0.18)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              _usesReferenceParityLiveProfileV1
                                  ? 0
                                  : (_usesScreenOwnedEmbeddedSceneV1 ? 34 : 48),
                            ),
                            boxShadow: _usesReferenceParityLiveProfileV1
                                ? const <BoxShadow>[]
                                : _usesScreenOwnedEmbeddedSceneV1
                                ? const <BoxShadow>[]
                                : const [
                                    BoxShadow(
                                      color: Color(0x22000000),
                                      blurRadius: 24,
                                      offset: Offset(0, 12),
                                    ),
                                  ],
                          ),
                          child: LayoutBuilder(
                            builder: (context, innerConstraints) {
                              if (innerConstraints.maxHeight <= 0) {
                                return const SizedBox.shrink();
                              }
                              final screenSize = effectiveScreenSize;
                              final sceneTopReserve =
                                  widget.embeddedV1 && !_isShowdownSceneV1
                                  ? _embeddedSceneLaneTopReserveV1
                                  : 0.0;
                              final scaleBucket =
                                  _SceneScaleNumbersV1.bucketForSize(
                                    screenSize,
                                  );
                              final ovalRect = _computeOvalRect(
                                screenSize: screenSize,
                                constraints: innerConstraints,
                                bottomPadding: bottomPadding,
                                headerHeightBudget: widget.embeddedV1
                                    ? (_usesReferenceParityLiveProfileV1
                                          ? 0.0
                                          : 20.0)
                                    : _LayoutNumbersV1.headerHeight,
                                actionBarHeightBudget: widget.embeddedV1
                                    ? (_usesReferenceParityLiveProfileV1
                                          ? 0.0
                                          : 28.0)
                                    : _LayoutNumbersV1.actionBarHeight,
                                topReserved: sceneTopReserve,
                                bottomReserved: _embeddedSceneBottomReserveV1,
                                widthRatioOverride:
                                    _usesReferenceParityLiveProfileV1
                                    ? 1.0
                                    : _usesScreenOwnedEmbeddedSceneV1
                                    ? 0.98
                                    : null,
                                sceneFillFactorOverride:
                                    _usesReferenceParityLiveProfileV1
                                    ? 1.0
                                    : _usesScreenOwnedEmbeddedSceneV1
                                    ? 0.98
                                    : null,
                                aspectRatioOverride:
                                    _usesReferenceParityLiveProfileV1
                                    ? 1.48
                                    : null,
                              );
                              if (ovalRect.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final width = ovalRect.width;
                              final height = ovalRect.height;
                              final radiusY =
                                  _LayoutNumbersV1.seatRadius * height / 2;
                              final bottomAnchor = _SeatAnchorsV1
                                  .anchors[_SeatAnchorsV1.heroSlotId];
                              final bottomSeatCenterY =
                                  (height / 2) +
                                  (radiusY *
                                      bottomAnchor.radialScale *
                                      bottomAnchor.normalized.dy);
                              final topAnchor = _SeatAnchorsV1.anchors[1];
                              final topSeatCenterY =
                                  (height / 2) +
                                  (radiusY *
                                      topAnchor.radialScale *
                                      topAnchor.normalized.dy);
                              final topSeatBottom =
                                  topSeatCenterY +
                                  (_LayoutNumbersV1.seatSize / 2);
                              final bottomSeatTop =
                                  bottomSeatCenterY -
                                  (_LayoutNumbersV1.heroSeatSize / 2);
                              const flopGap = 2.0;
                              const turnGap = 5.0;
                              final boardWidth =
                                  width *
                                  _ModernTableVisualSsotV1.boardWidthRatio;
                              final innerBoardWidth =
                                  boardWidth -
                                  (_LayoutNumbersV1.boardPaddingH * 2) -
                                  2;
                              final cardSpacing = (flopGap * 2) + (turnGap * 2);
                              final slotWidth =
                                  (innerBoardWidth - cardSpacing) / 5;
                              const slotPadding = 4.0;
                              final boardCardWidth = slotWidth - slotPadding;
                              final boardCardHeight =
                                  boardCardWidth /
                                  _LayoutNumbersV1.boardCardAspectRatio;
                              final slotHeight = boardCardHeight + slotPadding;
                              final boardHeight =
                                  slotHeight +
                                  (_LayoutNumbersV1.boardPaddingV * 2);
                              final ovalInset = _LayoutNumbersV1.ovalInset;
                              final maxPotBottom =
                                  height -
                                  _LayoutNumbersV1.potLabelHeight -
                                  ovalInset;
                              final maxBoardBottom =
                                  maxPotBottom - scaleBucket.potToBoardGap;
                              final minBoardTopBase =
                                  ovalInset +
                                  _LayoutNumbersV1.potLabelHeight +
                                  scaleBucket.potToBoardGap;
                              final minBoardTop = math.max(
                                minBoardTopBase,
                                topSeatBottom +
                                    ovalInset +
                                    (_isShowdownSceneV1
                                        ? _LayoutNumbersV1
                                              .showdownTopSeatBoardClearance
                                        : 0.0),
                              );
                              final minBoardCenterY =
                                  minBoardTop + (boardHeight / 2);
                              final maxBoardCenterYCandidate = math.min(
                                maxBoardBottom - (boardHeight / 2),
                                topSeatBottom - (boardHeight / 2) - ovalInset,
                              );
                              final maxBoardCenterY = math.max(
                                minBoardCenterY,
                                maxBoardCenterYCandidate,
                              );
                              final targetBoardCenterY = _isShowdownSceneV1
                                  ? (height / 2) + (height * 0.062)
                                  : (_usesReferenceParityLiveProfileV1
                                        ? (height / 2) + (height * 0.092)
                                        : (height / 2) - (height * 0.04));
                              final boardCenterY = targetBoardCenterY.clamp(
                                minBoardCenterY,
                                maxBoardCenterY,
                              );
                              final boardBottom =
                                  boardCenterY + (boardHeight / 2);
                              final boardTop = boardCenterY - (boardHeight / 2);
                              final boardOffsetY = boardCenterY - (height / 2);
                              final potBottomMin =
                                  height -
                                  bottomSeatTop +
                                  (_LayoutNumbersV1.seatSize *
                                      _LayoutNumbersV1
                                          .potBottomSeatClearanceFactor);
                              final potBottomTarget = math.max(
                                potBottomMin,
                                height * _LayoutNumbersV1.potBottomMinFraction,
                              );
                              final potTopFromBoard =
                                  boardTop -
                                  scaleBucket.potToBoardGap -
                                  _LayoutNumbersV1.potLabelHeight;
                              final potTopFromBottomSeat =
                                  height -
                                  potBottomTarget -
                                  _LayoutNumbersV1.potLabelHeight;
                              final potTopMin = math.min(
                                ovalInset,
                                height -
                                    _LayoutNumbersV1.potLabelHeight -
                                    ovalInset,
                              );
                              final potTopMax = math.max(
                                ovalInset,
                                height -
                                    _LayoutNumbersV1.potLabelHeight -
                                    ovalInset,
                              );
                              final potTop = math
                                  .min(potTopFromBoard, potTopFromBottomSeat)
                                  .clamp(potTopMin, potTopMax);
                              final potBottom =
                                  height -
                                  potTop -
                                  _LayoutNumbersV1.potLabelHeight;
                              final count = math.min(
                                _seatCountForLayout,
                                _SeatAnchorsV1.anchors.length,
                              );
                              final heroSeatIndex = _scenarioSpec.heroSeat;
                              final slotIds = _slotIdsForSeatCount(
                                count,
                                heroSeatIndex,
                              );
                              final heroCards = _buildHeroCards(
                                tableSize: Size(width, height),
                                heroSeatIndex: heroSeatIndex,
                                slotIds: slotIds,
                                potBottom: potBottom,
                                boardHeight: boardHeight,
                                heroCardWidth:
                                    boardCardWidth *
                                    _LayoutNumbersV1.heroCardScale,
                                heroCardHeight:
                                    boardCardHeight *
                                    _LayoutNumbersV1.heroCardScale,
                                heroOverlap: scaleBucket.heroOverlap,
                              );
                              final villainCards = _buildVillainCards(
                                tableSize: Size(width, height),
                                topSeatBottom: topSeatBottom,
                                boardTop: boardTop,
                                boardCardWidth: boardCardWidth,
                                boardCardHeight: boardCardHeight,
                              );
                              final feltLayer = RepaintBoundary(
                                child: SizedBox.expand(
                                  child: CustomPaint(
                                    key: const Key('modern_table_oval_paint'),
                                    painter: const _OvalFeltPainter(),
                                  ),
                                ),
                              );
                              final boardLayer = RepaintBoundary(
                                child: Center(
                                  child: IgnorePointer(
                                    ignoring: widget.onBoardSlotTapV1 == null,
                                    child: Transform.translate(
                                      offset: Offset(0, boardOffsetY),
                                      child: SizedBox(
                                        width: boardWidth,
                                        child: _BoardOverlay(
                                          cardWidth: boardCardWidth,
                                          cardHeight: boardCardHeight,
                                          flopGap: flopGap,
                                          turnGap: turnGap,
                                          dealtCount:
                                              _resolvedBoardCardsVisibleCountV1(),
                                          useReferenceParityLiveProfileV1:
                                              _usesReferenceParityLiveProfileV1,
                                          debugBoardCardLabels:
                                              widget.debugBoardCardLabels,
                                          onBoardSlotTapV1:
                                              widget.onBoardSlotTapV1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              final potLayer = widget.embeddedV1
                                  ? null
                                  : Positioned(
                                      key: const Key('modern_table_pot'),
                                      bottom: potBottom,
                                      child: IgnorePointer(
                                        ignoring: true,
                                        child: _PotMetaV1(
                                          pot: _lastStreetActiveState?.pot ?? 0,
                                          anteAmount: _scenarioSpec
                                              .blindLevelStateV1
                                              ?.anteAmountV1,
                                        ),
                                      ),
                                    );
                              final seatLayers = _buildSeatMarkers(
                                Size(width, height),
                                slotIds,
                                heroSeatIndex,
                              );
                              final layers = _buildSceneLayers(
                                felt: feltLayer,
                                board: boardLayer,
                                villainCards: villainCards,
                                pot: potLayer,
                                seats: seatLayers,
                                heroCards: heroCards,
                              );
                              final bucketLabel = screenSize.height <= 700
                                  ? 'SE'
                                  : screenSize.height <= 900
                                  ? 'Mid'
                                  : 'Max';
                              final sceneWidth = innerConstraints.maxWidth;
                              final ovalWidthRatio = sceneWidth == 0
                                  ? 0.0
                                  : width / sceneWidth;
                              final ovalAspectRatio = width == 0
                                  ? 0.0
                                  : height / width;
                              final metricsText =
                                  'viewport: ${screenSize.width.toStringAsFixed(0)}x'
                                  '${screenSize.height.toStringAsFixed(0)}\n'
                                  'bucket: $bucketLabel\n'
                                  'ovalW/sceneW: ${ovalWidthRatio.toStringAsFixed(2)}\n'
                                  'ovalH/ovalW: ${ovalAspectRatio.toStringAsFixed(2)}\n'
                                  'header: ${_LayoutNumbersV1.headerHeight.toStringAsFixed(0)} '
                                  'action: ${_LayoutNumbersV1.actionBarHeight.toStringAsFixed(0)} '
                                  'bottom: ${bottomPadding.toStringAsFixed(0)}\n'
                                  'scenario: $scenarioName';
                              return Stack(
                                fit: StackFit.expand,
                                clipBehavior: Clip.none,
                                children: [
                                  if (widget.embeddedV1 && !_isShowdownSceneV1)
                                    _buildSceneStateLaneV1(
                                      context: context,
                                      ovalRect: ovalRect,
                                      pot: _lastStreetActiveState?.pot ?? 0,
                                      potDisplayLabel:
                                          widget.debugPotDisplayLabelV1,
                                      scenePriceLabel:
                                          widget.debugScenePriceLabelV1,
                                    ),
                                  Positioned.fromRect(
                                    rect: ovalRect,
                                    child: SizedBox(
                                      key: const Key('modern_table_oval'),
                                      width: width,
                                      height: height,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.center,
                                        children: layers,
                                      ),
                                    ),
                                  ),
                                  if (_usesReferenceParityLiveProfileV1)
                                    _buildReferenceParitySceneInstructionV1(
                                      context: context,
                                      ovalRect: ovalRect,
                                      topSeatBottom: topSeatBottom,
                                      boardTop: boardTop,
                                      promptLabel: widget
                                          .debugEmbeddedInstructionLabelV1
                                          ?.trim(),
                                    ),
                                  if (kDebugMode && !widget.embeddedV1)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: TextButton.icon(
                                        key: const Key(
                                          'modern_table_inline_loader_open',
                                        ),
                                        onPressed: _showScenarioLoaderDialog,
                                        icon: const Icon(Icons.tune, size: 16),
                                        label: const Text('Loader'),
                                        style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (kDebugMode && !widget.embeddedV1)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        key: const Key(
                                          'modern_table_debug_banner',
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.35),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'VISUAL_SSOT_V1 · $scenarioSource',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppColors.textPrimaryDark
                                                    .withOpacity(0.7),
                                                height: 1.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                  if (kDebugMode &&
                                      !widget.embeddedV1 &&
                                      kEnableMetricsOverlay)
                                    Positioned(
                                      top: 36,
                                      left: 8,
                                      child: IgnorePointer(
                                        ignoring: true,
                                        child: Container(
                                          key: const Key(
                                            'modern_table_debug_metrics',
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface
                                                .withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: AppColors.outlineSoft
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                          child: Text(
                                            metricsText,
                                            key: const Key(
                                              'modern_table_debug_metrics_text',
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  fontFamily: 'monospace',
                                                  height: 1.2,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (!widget.embeddedV1)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: _LayoutNumbersV1.reasonMinHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        key: const Key('modern_table_reason'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _reasonSectionChildren(),
                      ),
                    ),
                  ),
                ),
              if (!widget.embeddedV1)
                SizedBox(
                  height: _LayoutNumbersV1.actionBarHeight + bottomPadding,
                  child: RepaintBoundary(
                    child: Container(
                      key: const Key('modern_table_action_bar'),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xFF0B1220), Color(0x000B1220)],
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: _LayoutNumbersV1.actionBarHeight,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Color(0xFF020617),
                                          Color(0x00020617),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SafeArea(
                                  top: false,
                                  bottom: false,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Column(
                                      key: const Key('modern_table_actions'),
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          height: 1,
                                          color: AppColors.outlineSoft
                                              .withOpacity(0.35),
                                        ),
                                        _betSliderRow(),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 22,
                                              child: _foldButton(context),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 28,
                                              child: _callButton(context),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              flex: 50,
                                              child: _raiseButton(context),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: bottomPadding,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Color(0xFF020617),
                                    Color(0xFF0B1220),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
    if (widget.embeddedV1) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modern Table (V1)'),
        actions: [
          if (kDebugMode)
            IconButton(
              key: const Key('modern_table_loader_open'),
              icon: const Icon(Icons.developer_mode),
              tooltip: 'Scenario Loader',
              onPressed: _showScenarioLoaderDialog,
            ),
        ],
      ),
      body: body,
    );
  }

  bool _isActionEnabled(String label) =>
      (_isStreetActive &&
      !_continuing &&
      _isActionAllowed(label) &&
      _scenarioError == null);

  Widget _foldButton(BuildContext context) {
    return OutlinedButton(
      key: const Key('modern_table_action_fold'),
      onPressed: _isActionEnabled('Fold') ? () => _handleAction('Fold') : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        visualDensity: VisualDensity.compact,
        backgroundColor: AppColors.surfaceVariant.withOpacity(0.05),
        foregroundColor: AppColors.textSecondaryDark,
        side: BorderSide(color: AppColors.outlineSoft.withOpacity(0.6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            _LayoutNumbersV1.actionButtonRadius,
          ),
        ),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.35,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      child: _actionButtonContent('Fold'),
    );
  }

  Widget _callButton(BuildContext context) {
    return FilledButton.tonal(
      key: const Key('modern_table_action_call'),
      onPressed: _isActionEnabled('Call') ? () => _handleAction('Call') : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        visualDensity: VisualDensity.compact,
        backgroundColor: AppColors.surfaceVariant.withOpacity(0.3),
        foregroundColor: AppColors.textPrimaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            _LayoutNumbersV1.actionButtonRadius,
          ),
        ),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.35,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      child: _actionButtonContent('Call'),
    );
  }

  Widget _raiseButton(BuildContext context) {
    final raiseAllowed = _isStreetActive && _isActionAllowed('Raise');
    final callAllowed = _isStreetActive && _isActionAllowed('Call');
    final pct = (_betFraction * 100).round().clamp(0, 100);
    final label = raiseAllowed
        ? 'RAISE $pct%'
        : callAllowed
        ? 'CALL'
        : 'RAISE';
    return FilledButton(
      key: const Key('modern_table_action_raise'),
      onPressed: _isActionEnabled('Raise')
          ? () => _handleAction('Raise')
          : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        visualDensity: VisualDensity.compact,
        backgroundColor: AppColors.primaryBrand.withOpacity(0.98),
        foregroundColor: const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            _LayoutNumbersV1.actionButtonRadius,
          ),
        ),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.35,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      child: _actionButtonContent(
        label,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
    );
  }

  Widget _actionButtonContent(String label, {TextWidthBasis? textWidthBasis}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded =
            constraints.hasBoundedWidth && constraints.hasBoundedHeight;
        return ClipRRect(
          borderRadius: BorderRadius.circular(
            _LayoutNumbersV1.actionButtonRadius,
          ),
          child: Stack(
            alignment: Alignment.center,
            fit: bounded ? StackFit.expand : StackFit.passthrough,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x24FFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
              Center(
                child: Text(
                  label,
                  textWidthBasis: textWidthBasis,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _reasonSectionChildren() {
    final evaluation = _currentState is EvaluationState
        ? _currentState as EvaluationState
        : null;
    final outcome = _currentState is OutcomeState
        ? _currentState as OutcomeState
        : null;
    final text = evaluation != null
        ? 'Evaluation: ${evaluation.action == _scenarioSpec.decisionNodeV1.solutionBestAction ? 'correct' : 'wrong'}'
        : outcome != null
        ? 'Outcome: continue'
        : 'Pot: ${_lastStreetActiveState?.pot ?? 0} · Acting: P${(_lastStreetActiveState?.actingSeat ?? 0) + 1}';
    final children = <Widget>[
      Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryDark),
      ),
    ];
    if (_scenarioError != null) {
      return [
        Text(
          _scenarioError!,
          key: const Key('modern_table_error'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.red),
        ),
      ];
    }
    if (evaluation != null || outcome != null) {
      children.addAll([
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('modern_table_reason_continue'),
          onPressed: _terminalOutcome ? _restartAction : _continueAction,
          child: Text(_terminalOutcome ? 'Restart' : 'Continue'),
        ),
      ]);
    }
    return children;
  }

  String _sanitizeError(Object error) {
    final message = error is FormatException
        ? error.message
        : error is StateError
        ? error.message
        : error.toString();
    return message.replaceAll('\n', ' ');
  }

  _SeatLayout _seatLayoutForIndex(
    Size tableSize,
    int index, {
    required List<int> slotIds,
    required int heroSeatIndex,
  }) {
    final isHero = heroSeatIndex == index;
    final seatSize = isHero
        ? _LayoutNumbersV1.heroSeatSize
        : _LayoutNumbersV1.seatSize;
    final center = Offset(tableSize.width / 2, tableSize.height / 2);
    final radiusX = _LayoutNumbersV1.seatRadius * tableSize.width / 2;
    final radiusY = _LayoutNumbersV1.seatRadius * tableSize.height / 2;
    final anchor = _SeatAnchorsV1.anchors[slotIds[index]];
    final seatCenter = Offset(
      center.dx + (radiusX * anchor.radialScale * anchor.normalized.dx),
      center.dy + (radiusY * anchor.radialScale * anchor.normalized.dy),
    );
    return _SeatLayout(center: seatCenter, size: seatSize);
  }

  _CardClusterLayoutV1 _computeHeroCardsLayoutV1({
    required Size tableSize,
    required int heroSeatIndex,
    required List<int> slotIds,
    required double potBottom,
    required double boardHeight,
    required double heroCardWidth,
    required double heroCardHeight,
    required double heroOverlap,
  }) {
    final heroLayout = _seatLayoutForIndex(
      tableSize,
      heroSeatIndex,
      slotIds: slotIds,
      heroSeatIndex: heroSeatIndex,
    );
    final boardBottom = (tableSize.height / 2) + (boardHeight / 2);
    final potTop =
        tableSize.height - potBottom - _LayoutNumbersV1.potLabelHeight;
    final heroTopMin =
        potTop +
        _LayoutNumbersV1.potLabelHeight +
        _LayoutNumbersV1.heroCardPotGap;
    final heroBoardMin = boardBottom + _LayoutNumbersV1.heroCardBoardGap;
    final heroSeatTop = heroLayout.center.dy - (heroLayout.size / 2);
    final targetHeroCenterY = tableSize.height * 0.72;
    final heroBaseTop = targetHeroCenterY - (heroCardHeight / 2);
    final maxTop =
        tableSize.height -
        heroCardHeight -
        _LayoutNumbersV1.heroCardBottomPadding;
    final unclampedTop = math.min<double>(
      maxTop,
      math.max(heroBaseTop, math.max(heroTopMin, heroBoardMin)),
    );
    final heroMaxTop = heroSeatTop + (heroLayout.size * heroOverlap);
    final heroCardTop = math.max(
      heroTopMin,
      math.min(unclampedTop, heroMaxTop),
    );
    final heroCardLeft = (tableSize.width / 2) - (heroCardWidth * 1.03);
    return _CardClusterLayoutV1(
      left: heroCardLeft,
      top: heroCardTop,
      width: heroCardWidth * 2.1,
      height: heroCardHeight + 10,
    );
  }

  _CardClusterLayoutV1 _computeVillainCardsLayoutV1({
    required Size tableSize,
    required double topSeatBottom,
    required double boardTop,
    required double boardCardWidth,
    required double boardCardHeight,
  }) {
    final villainCardWidth = boardCardWidth * _villainCardScaleV1;
    final villainCardHeight = boardCardHeight * _villainCardScaleV1;
    final topMin = topSeatBottom + (_isShowdownSceneV1 ? 4 : 4);
    final topMax =
        boardTop - villainCardHeight - (_isShowdownSceneV1 ? 36 : 14);
    final villainTop = _isShowdownSceneV1
        ? math.max(topMin, topMin + ((topMax - topMin) * 0.28))
        : math.max(topMin, math.min(topMax, topMin + 4));
    final villainLeft = (tableSize.width / 2) - (villainCardWidth * 1.08);
    return _CardClusterLayoutV1(
      left: villainLeft,
      top: villainTop,
      width: villainCardWidth * (_isShowdownSceneV1 ? 1.66 : 2.05),
      height: villainCardHeight + 8,
    );
  }

  Widget? _buildHeroCards({
    required Size tableSize,
    required int heroSeatIndex,
    required List<int> slotIds,
    required double potBottom,
    required double boardHeight,
    required double heroCardWidth,
    required double heroCardHeight,
    required double heroOverlap,
  }) {
    if (heroSeatIndex < 0 || heroSeatIndex >= slotIds.length) {
      return null;
    }
    final heroCardsLayout = _computeHeroCardsLayoutV1(
      tableSize: tableSize,
      heroSeatIndex: heroSeatIndex,
      slotIds: slotIds,
      potBottom: potBottom,
      boardHeight: boardHeight,
      heroCardWidth: heroCardWidth,
      heroCardHeight: heroCardHeight,
      heroOverlap: heroOverlap,
    );
    final heroCard0Label =
        widget.debugHeroCardLabels != null &&
            widget.debugHeroCardLabels!.isNotEmpty
        ? widget.debugHeroCardLabels!.first
        : 'A♠';
    final heroCard1Label =
        widget.debugHeroCardLabels != null &&
            widget.debugHeroCardLabels!.length > 1
        ? widget.debugHeroCardLabels![1]
        : 'K♠';
    final heroCard0Id = _cardIdFromUiLabelV1(heroCard0Label);
    final heroCard1Id = _cardIdFromUiLabelV1(heroCard1Label);
    return Positioned(
      key: const Key('modern_table_hero_cards'),
      left: heroCardsLayout.left,
      top: heroCardsLayout.top,
      child: SizedBox(
        width: heroCardsLayout.width,
        height: heroCardsLayout.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.debugShowdownWinnerActionId == 'hero')
              Positioned(
                top: -10,
                left: heroCardWidth * 0.48,
                child: _buildShowdownWinnerChipV1(
                  key: const Key('modern_table_showdown_winner_hero'),
                ),
              ),
            Positioned(
              left: heroCardWidth * 0.06,
              right: heroCardWidth * 0.12,
              bottom: 2,
              child: IgnorePointer(
                child: Container(
                  height: heroCardHeight * 0.28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(heroCardHeight * 0.22),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x1422C55E), Color(0x28111C2D)],
                    ),
                    border: Border.all(
                      color: const Color(0x24FFFFFF),
                      width: 0.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 8,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _HeroCard(
              key: const Key('modern_table_hero_card_0'),
              width: heroCardWidth,
              height: heroCardHeight,
              label: heroCard0Label,
              offset: 0,
              rotationDegrees: _ModernTableVisualSsotV1.heroCardRotationLeftDeg,
              surfaceKey: const Key('modern_table_hero_card_surface_0'),
              onTapV1:
                  widget.onHoleCardTapV1 == null &&
                      widget.onHoleCardTapDetailV1 == null
                  ? null
                  : () {
                      widget.onHoleCardTapV1?.call('p0');
                      widget.onHoleCardTapDetailV1?.call('p0', heroCard0Id);
                    },
            ),
            Positioned(
              left: heroCardWidth * 0.53,
              child: _HeroCard(
                key: const Key('modern_table_hero_card_1'),
                width: heroCardWidth,
                height: heroCardHeight,
                label: heroCard1Label,
                offset: 4,
                rotationDegrees:
                    _ModernTableVisualSsotV1.heroCardRotationRightDeg,
                surfaceKey: const Key('modern_table_hero_card_surface_1'),
                onTapV1:
                    widget.onHoleCardTapV1 == null &&
                        widget.onHoleCardTapDetailV1 == null
                    ? null
                    : () {
                        widget.onHoleCardTapV1?.call('p1');
                        widget.onHoleCardTapDetailV1?.call('p1', heroCard1Id);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildVillainCards({
    required Size tableSize,
    required double topSeatBottom,
    required double boardTop,
    required double boardCardWidth,
    required double boardCardHeight,
  }) {
    final villainLabels = widget.debugVillainCardLabels;
    if (villainLabels == null || villainLabels.length < 2) {
      return null;
    }
    final villainCardWidth = boardCardWidth * _villainCardScaleV1;
    final villainCardHeight = boardCardHeight * _villainCardScaleV1;
    final villainLayout = _computeVillainCardsLayoutV1(
      tableSize: tableSize,
      topSeatBottom: topSeatBottom,
      boardTop: boardTop,
      boardCardWidth: boardCardWidth,
      boardCardHeight: boardCardHeight,
    );
    return Positioned(
      key: const Key('modern_table_villain_cards'),
      left: villainLayout.left,
      top: villainLayout.top,
      child: SizedBox(
        width: villainLayout.width,
        height: villainLayout.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.debugShowdownWinnerActionId == 'villain')
              Positioned(
                top: -10,
                left: villainCardWidth * 0.46,
                child: _buildShowdownWinnerChipV1(
                  key: const Key('modern_table_showdown_winner_villain'),
                ),
              ),
            Positioned(
              left: villainCardWidth * 0.12,
              right: villainCardWidth * 0.12,
              bottom: 1,
              child: IgnorePointer(
                child: Container(
                  height: villainCardHeight * 0.22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      villainCardHeight * 0.18,
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x1022C55E), Color(0x1C0F172A)],
                    ),
                    border: Border.all(
                      color: const Color(0x20FFFFFF),
                      width: 0.75,
                    ),
                  ),
                ),
              ),
            ),
            _HeroCard(
              key: const Key('modern_table_villain_card_0'),
              width: villainCardWidth,
              height: villainCardHeight,
              label: villainLabels[0],
              offset: 0,
              rotationDegrees: -2,
              surfaceKey: const Key('modern_table_villain_card_surface_0'),
            ),
            Positioned(
              left: villainCardWidth * (_isShowdownSceneV1 ? 0.40 : 0.55),
              child: _HeroCard(
                key: const Key('modern_table_villain_card_1'),
                width: villainCardWidth,
                height: villainCardHeight,
                label: villainLabels[1],
                offset: 2,
                rotationDegrees: 2,
                surfaceKey: const Key('modern_table_villain_card_surface_1'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneStateLaneV1({
    required BuildContext context,
    required Rect ovalRect,
    required int pot,
    String? potDisplayLabel,
    String? scenePriceLabel,
  }) {
    final laneWidth = _usesGuidedTeachingSceneLaneV1
        ? math.min(
            ovalRect.width * (_usesScreenOwnedEmbeddedSceneV1 ? 0.88 : 0.92),
            ovalRect.width - (_usesScreenOwnedEmbeddedSceneV1 ? 12 : 8),
          )
        : math.min(
            ovalRect.width * (_usesScreenOwnedEmbeddedSceneV1 ? 0.72 : 0.76),
            ovalRect.width - (_usesScreenOwnedEmbeddedSceneV1 ? 20 : 28),
          );
    final sceneProofLabel = widget.debugSceneProofLabel?.trim();
    final showsSceneProof =
        sceneProofLabel != null && sceneProofLabel.isNotEmpty;
    final scenePromptLabel = widget.debugScenePromptLabel?.trim();
    final allowsPromptText = !_usesCompactStateOnlySceneLaneV1;
    final showsScenePrompt =
        allowsPromptText &&
        scenePromptLabel != null &&
        scenePromptLabel.isNotEmpty;
    final anteAmount = _scenarioSpec.blindLevelStateV1?.anteAmountV1;
    final sideBadges = <Widget>[
      if (anteAmount != null) _AnteIndicatorBadgeV1(amount: anteAmount),
      if (scenePriceLabel != null && scenePriceLabel.trim().isNotEmpty)
        _ScenePriceBadgeV1(label: scenePriceLabel.trim()),
      _PotLabel(pot: pot, displayLabel: potDisplayLabel?.trim()),
    ];
    final usesIntegratedLiveStateLaneV1 =
        _usesScreenOwnedEmbeddedSceneV1 && !_usesGuidedTeachingSceneLaneV1;
    if (_usesReferenceParityLiveProfileV1) {
      return const SizedBox.shrink();
    }
    return Positioned(
      key: const Key('modern_table_scene_state_lane'),
      top: math.max(
        _usesScreenOwnedEmbeddedSceneV1 ? 8.0 : 10.0,
        ovalRect.top -
            _embeddedSceneLaneTopReserveV1 -
            (_usesScreenOwnedEmbeddedSceneV1 ? 8.0 : 0.0),
      ),
      left: math.max(
        _usesGuidedTeachingSceneLaneV1
            ? (_usesScreenOwnedEmbeddedSceneV1 ? 8.0 : 10.0)
            : (_usesScreenOwnedEmbeddedSceneV1 ? 10.0 : 14.0),
        ovalRect.center.dx - (laneWidth / 2),
      ),
      width: laneWidth,
      child: IgnorePointer(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _usesCompactStateOnlySceneLaneV1
                ? (_usesScreenOwnedEmbeddedSceneV1
                      ? (usesIntegratedLiveStateLaneV1 ? 4 : 10)
                      : 12)
                : (_usesGuidedTeachingSceneLaneV1
                      ? (_usesScreenOwnedEmbeddedSceneV1 ? 10 : 12)
                      : (_usesScreenOwnedEmbeddedSceneV1
                            ? (usesIntegratedLiveStateLaneV1 ? 4 : 10)
                            : 12)),
            vertical: _usesCompactStateOnlySceneLaneV1
                ? (_usesScreenOwnedEmbeddedSceneV1
                      ? (usesIntegratedLiveStateLaneV1 ? 0 : 4)
                      : 5)
                : (_usesGuidedTeachingSceneLaneV1
                      ? (_usesScreenOwnedEmbeddedSceneV1 ? 6 : 8)
                      : (_usesScreenOwnedEmbeddedSceneV1
                            ? (usesIntegratedLiveStateLaneV1 ? 0 : 4)
                            : 5)),
          ),
          decoration: usesIntegratedLiveStateLaneV1
              ? const BoxDecoration()
              : _glassPillDecoration(
                  radius: 18,
                  fillOpacity: _usesGuidedTeachingSceneLaneV1
                      ? (_usesScreenOwnedEmbeddedSceneV1 ? 0.28 : 0.38)
                      : (_usesScreenOwnedEmbeddedSceneV1 ? 0.08 : 0.28),
                  borderOpacity: _usesGuidedTeachingSceneLaneV1
                      ? (_usesScreenOwnedEmbeddedSceneV1 ? 0.18 : 0.28)
                      : (_usesScreenOwnedEmbeddedSceneV1 ? 0.03 : 0.16),
                ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useStackedBadges =
                  _usesGuidedTeachingSceneLaneV1 ||
                  sideBadges.length > 1 &&
                      (constraints.maxWidth < 312 || showsScenePrompt);
              final sceneTextColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showsSceneProof) ...[
                    Container(
                      key: const Key('modern_table_scene_proof_badge'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        sceneProofLabel,
                        key: const Key('modern_table_scene_proof_text'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xD5E2E8F0),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.14,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Board state · ${_lastStreetActiveState?.street.name.toUpperCase() ?? 'PREFLOP'}',
                    key: const Key('modern_table_scene_board_state'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xC9E2E8F0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (showsScenePrompt) ...[
                    const SizedBox(height: 2),
                    Text(
                      scenePromptLabel,
                      key: const Key('modern_table_scene_prompt'),
                      maxLines: _usesGuidedTeachingSceneLaneV1 ? 2 : 1,
                      overflow: _usesGuidedTeachingSceneLaneV1
                          ? TextOverflow.ellipsis
                          : TextOverflow.fade,
                      softWrap: _usesGuidedTeachingSceneLaneV1,
                      style:
                          (_usesGuidedTeachingSceneLaneV1
                                  ? Theme.of(context).textTheme.labelMedium
                                  : Theme.of(context).textTheme.labelSmall)
                              ?.copyWith(
                                color: const Color(0xFFDDE7F5),
                                fontWeight: FontWeight.w700,
                                height: _usesGuidedTeachingSceneLaneV1
                                    ? 1.18
                                    : 1.0,
                              ),
                    ),
                  ],
                ],
              );
              if (!useStackedBadges) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: sceneTextColumn),
                    const SizedBox(width: 8),
                    ...[
                      for (var i = 0; i < sideBadges.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Padding(
                          padding: EdgeInsets.only(
                            top: showsScenePrompt ? 1 : 0,
                          ),
                          child: sideBadges[i],
                        ),
                      ],
                    ],
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  sceneTextColumn,
                  if (sideBadges.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: sideBadges,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReferenceParitySceneInstructionV1({
    required BuildContext context,
    required Rect ovalRect,
    required double topSeatBottom,
    required double boardTop,
    required String? promptLabel,
  }) {
    if (promptLabel == null || promptLabel.isEmpty) {
      return const SizedBox.shrink();
    }
    final instructionWidth = math.min(ovalRect.width * 0.88, 324.0);
    final minInstructionTop = math.max(ovalRect.top + 16, topSeatBottom + 12);
    final instructionTop = math.max(minInstructionTop, boardTop - 108);
    final boardStateLabel =
        'Board state · ${_lastStreetActiveState?.street.name.toUpperCase() ?? 'PREFLOP'}';
    final sceneBadges = <Widget>[
      if ((widget.debugScenePriceLabelV1 ?? '').trim().isNotEmpty)
        _buildLiveReferenceParitySceneBadgeV1(
          key: const Key('microtask_live_scene_price_badge_v1'),
          label: widget.debugScenePriceLabelV1!.trim(),
          fill: const Color(0xFF465271).withOpacity(0.78),
          border: const Color(0xFF5F6B89).withOpacity(0.72),
          foreground: const Color(0xFFDCE6FF),
        ),
      if ((widget.debugPotDisplayLabelV1 ?? '').trim().isNotEmpty)
        _buildLiveReferenceParitySceneBadgeV1(
          key: const Key('microtask_live_scene_pot_badge_v1'),
          label: widget.debugPotDisplayLabelV1!.trim(),
          fill: const Color(0xFF121519).withOpacity(0.88),
          border: const Color(0xFF9F7A2A).withOpacity(0.82),
          foreground: const Color(0xFFF1D58B),
        ),
    ];
    return Positioned(
      key: const Key('microtask_live_scene_instruction_v1'),
      top: instructionTop,
      left: ovalRect.center.dx - (instructionWidth / 2),
      width: instructionWidth,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              key: const Key('microtask_live_scene_board_state_band_v1'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  boardStateLabel,
                  key: const Key('microtask_live_scene_board_state_text_v1'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFB6C3DB).withOpacity(0.94),
                    fontWeight: FontWeight.w600,
                    fontSize: 10.0,
                    height: 1.0,
                  ),
                ),
                if (sceneBadges.isNotEmpty) ...[
                  const SizedBox(height: 11),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: sceneBadges,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1020).withOpacity(0.84),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF304C82).withOpacity(0.30),
                  width: 1,
                ),
              ),
              child: Text(
                promptLabel,
                key: const Key('modern_table_scene_prompt'),
                textAlign: TextAlign.center,
                maxLines: 5,
                softWrap: true,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFE7EEF9),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.0,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveReferenceParitySceneBadgeV1({
    required Key key,
    required String label,
    required Color fill,
    required Color border,
    required Color foreground,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ThemeData.light().textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 9.6,
          height: 1.0,
        ),
      ),
    );
  }

  List<Widget> _buildSeatMarkers(
    Size tableSize,
    List<int> slotIds,
    int heroSeatIndex,
  ) {
    final count = math.min(_seatCountForLayout, slotIds.length);
    final seats = <Widget>[];
    final occupancies = _scenarioSpec.resolvedSeatOccupanciesV1;
    final blindLevelState = _scenarioSpec.blindLevelStateV1;
    for (var i = 0; i < count; i++) {
      final isHero = heroSeatIndex == i;
      final stack = _scenarioSpec.initialStacks[i];
      final occupancy = occupancies[i];
      final isFolded = occupancy == ScenarioSeatOccupancyV1.folded;
      final isEmpty = occupancy == ScenarioSeatOccupancyV1.empty;
      final roleLabel = widget.debugSeatRoleLabels?[i];
      final authoredBlindMarkerLabel =
          !_isShowdownSceneV1 && blindLevelState != null
          ? _authoredBlindMarkerLabelV1(
              blindLevelState: blindLevelState,
              seatIndex: i,
            )
          : null;
      final markerLabel = _isShowdownSceneV1
          ? null
          : widget.debugSeatMarkerLabels?[i] ?? authoredBlindMarkerLabel;
      final normalizedMarkerLabel = markerLabel?.trim().toUpperCase();
      final showsBlindMarkerV1 =
          _normalizedBlindKindV1(normalizedMarkerLabel) != null;
      final contributionAmountV1 =
          widget.debugSeatContributionAmountsV1?[i] ?? 0;
      final showsPriceSetterCueV1 =
          widget.debugPriceSetterSeatIndexV1 == i &&
          widget.debugPriceSetterCueLabelV1 != null &&
          contributionAmountV1 > 0 &&
          !isEmpty &&
          !isFolded;
      final forcedBetLabel = _resolveForcedBetLabelV1(
        blindLevelState: blindLevelState,
        seatIndex: i,
        isShowdownSceneV1: _isShowdownSceneV1,
        isEmpty: isEmpty,
        isFolded: isFolded,
        normalizedMarkerLabel: normalizedMarkerLabel,
      );
      final layout = _seatLayoutForIndex(
        tableSize,
        i,
        slotIds: slotIds,
        heroSeatIndex: heroSeatIndex,
      );
      final liveHeroLiftV1 = _usesReferenceParityLiveProfileV1 && isHero
          ? (tableSize.height <= 560 ? -38.0 : -16.0)
          : 0.0;
      final adjustedSeatCenterV1 = layout.center.translate(0, liveHeroLiftV1);
      final postedBlindTokenCenterV1 = contributionAmountV1 > 0
          ? _resolvePostedBlindTokenCenterV1(
              seatCenter: adjustedSeatCenterV1,
              tableCenter: Offset(tableSize.width / 2, tableSize.height / 2),
              seatSize: layout.size,
            )
          : null;
      final anchor = _SeatAnchorsV1.anchors[slotIds[i]];
      final visualYOffset = (-anchor.normalized.dy * 2.0).clamp(-3.0, 3.0);
      if (postedBlindTokenCenterV1 != null) {
        final tokenSizeV1 = isHero ? 24.0 : 20.0;
        seats.add(
          Positioned(
            left: postedBlindTokenCenterV1.dx - (tokenSizeV1 / 2),
            top: postedBlindTokenCenterV1.dy - (tokenSizeV1 / 2),
            child: _BlindPostedBetTokenV1(
              key: Key(
                showsBlindMarkerV1
                    ? 'modern_table_seat_posted_blind_token_$i'
                    : 'modern_table_seat_contribution_token_$i',
              ),
              label: _formatBbUnitsForSceneV1(contributionAmountV1),
              size: tokenSizeV1,
              isBlindContributionV1: showsBlindMarkerV1,
            ),
          ),
        );
        if (showsPriceSetterCueV1) {
          seats.add(
            Positioned(
              left: postedBlindTokenCenterV1.dx + (tokenSizeV1 * 0.08),
              top: postedBlindTokenCenterV1.dy - tokenSizeV1 - 2,
              child: IgnorePointer(
                child: _PriceSetterCueV1(
                  key: Key('modern_table_seat_price_setter_$i'),
                  label: widget.debugPriceSetterCueLabelV1!,
                ),
              ),
            ),
          );
        }
      }
      seats.add(
        Positioned(
          left: adjustedSeatCenterV1.dx - (layout.size / 2),
          top: adjustedSeatCenterV1.dy - (layout.size / 2),
          child: GestureDetector(
            key: Key('modern_table_seat_$i'),
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleSeat(i),
            child: SizedBox(
              width: layout.size,
              height: layout.size,
              child: _SeatWidget(
                index: i,
                stack: stack,
                isSelected: _effectiveSelectedSeatV1 == i,
                isActing:
                    widget.showsActingSeatV1 &&
                    !_isShowdownSceneV1 &&
                    _lastStreetActiveState?.actingSeat == i,
                isHero: isHero,
                isFolded: isFolded,
                isEmpty: isEmpty,
                roleLabel: roleLabel,
                markerLabel: markerLabel,
                showsBlindMarkerV1: showsBlindMarkerV1,
                forcedBetLabel: forcedBetLabel,
                visualProfileV1: widget.seatStateVisualProfileV1,
                embeddedSceneProfileV1: _usesScreenOwnedEmbeddedSceneV1,
                visualYOffset: visualYOffset,
              ),
            ),
          ),
        ),
      );
    }
    return seats;
  }

  String? _authoredBlindMarkerLabelV1({
    required ScenarioBlindLevelStateV1 blindLevelState,
    required int seatIndex,
  }) {
    if (seatIndex == blindLevelState.smallBlindSeatIndexV1) {
      return 'SB';
    }
    if (seatIndex == blindLevelState.bigBlindSeatIndexV1) {
      return 'BB';
    }
    return null;
  }

  String? _normalizedBlindKindV1(String? normalizedMarkerLabel) {
    if (normalizedMarkerLabel == null || normalizedMarkerLabel.isEmpty) {
      return null;
    }
    if (normalizedMarkerLabel == 'SB' ||
        normalizedMarkerLabel.endsWith('/SB')) {
      return 'SB';
    }
    if (normalizedMarkerLabel == 'BB' ||
        normalizedMarkerLabel.endsWith('/BB')) {
      return 'BB';
    }
    return null;
  }

  String? _resolveForcedBetLabelV1({
    required ScenarioBlindLevelStateV1? blindLevelState,
    required int seatIndex,
    required bool isShowdownSceneV1,
    required bool isEmpty,
    required bool isFolded,
    required String? normalizedMarkerLabel,
  }) {
    if (isShowdownSceneV1 || isEmpty) {
      return null;
    }
    if (blindLevelState != null) {
      if (seatIndex == blindLevelState.smallBlindSeatIndexV1) {
        return 'POST SB ${blindLevelState.smallBlindAmountV1}';
      }
      if (seatIndex == blindLevelState.bigBlindSeatIndexV1) {
        return 'POST BB ${blindLevelState.bigBlindAmountV1}';
      }
      return null;
    }
    final blindKind = _normalizedBlindKindV1(normalizedMarkerLabel);
    if (blindKind != null) {
      return 'POST $blindKind';
    }
    if (isFolded) {
      return null;
    }
    return null;
  }

  Offset _resolvePostedBlindTokenCenterV1({
    required Offset seatCenter,
    required Offset tableCenter,
    required double seatSize,
  }) {
    final vectorToTable = tableCenter - seatCenter;
    final distance = vectorToTable.distance;
    if (distance <= 0.0001) {
      return seatCenter;
    }
    final unit = Offset(
      vectorToTable.dx / distance,
      vectorToTable.dy / distance,
    );
    final travel = seatSize * 0.34;
    return seatCenter + (unit * travel);
  }

  Widget _buildShowdownWinnerChipV1({required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
        ),
        border: Border.all(color: const Color(0xAAFFF7D6), width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33251000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'WINNER',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF201100),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          fontSize: 10,
        ),
      ),
    );
  }

  List<int> _slotIdsForSeatCount(int count, int heroSeatIndex) {
    final maxSeats = math.min(count, _SeatAnchorsV1.anchors.length);
    return canonicalTableSlotIdsForSeatCountV1(
      maxSeats,
      heroSeatIndex: heroSeatIndex,
    );
  }

  ScenarioSpecV1 _buildDefaultScenarioSpec() {
    return ScenarioSpecV1(
      seatCount: widget.seatCount,
      heroSeat: 0,
      initialStacks: List<int>.filled(widget.seatCount, 1000),
      actingSeatStart: widget.actingSeat ?? 0,
      decisionNodeV1: const DecisionNodeV1(
        street: Street.preflop,
        legalActions: ['Fold', 'Call', 'Raise'],
        solutionBestAction: 'Call',
      ),
    );
  }
}

String? _cardIdFromUiLabelV1(String label) {
  if (label.length != 2) return null;
  final rank = label[0];
  final suitGlyph = label[1];
  String? suit;
  switch (suitGlyph) {
    case '♠':
      suit = 's';
      break;
    case '♥':
      suit = 'h';
      break;
    case '♦':
      suit = 'd';
      break;
    case '♣':
      suit = 'c';
      break;
  }
  if (suit == null) return null;
  const validRanks = 'AKQJT98765432';
  if (!validRanks.contains(rank)) return null;
  return '$rank$suit';
}

class _SeatWidget extends StatelessWidget {
  const _SeatWidget({
    required this.index,
    required this.stack,
    this.isSelected = false,
    this.isActing = false,
    this.isHero = false,
    this.isFolded = false,
    this.isEmpty = false,
    this.roleLabel,
    this.markerLabel,
    this.showsBlindMarkerV1 = false,
    this.forcedBetLabel,
    this.visualProfileV1 = ModernTableSeatStateVisualProfileV1.dense,
    this.embeddedSceneProfileV1 = false,
    this.visualYOffset = 0.0,
  });

  final int index;
  final int stack;
  final bool isSelected;
  final bool isActing;
  final bool isHero;
  final bool isFolded;
  final bool isEmpty;
  final String? roleLabel;
  final String? markerLabel;
  final bool showsBlindMarkerV1;
  final String? forcedBetLabel;
  final ModernTableSeatStateVisualProfileV1 visualProfileV1;
  final bool embeddedSceneProfileV1;
  final double visualYOffset;

  List<String> _markerLabelLinesV1() {
    final marker = markerLabel?.trim();
    if (marker == null || marker.isEmpty) {
      return const <String>[];
    }
    final parts = marker
        .split('/')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return parts.isEmpty ? <String>[marker] : parts;
  }

  @override
  Widget build(BuildContext context) {
    final usesLearnerEmbeddedProfileV1 =
        visualProfileV1 == ModernTableSeatStateVisualProfileV1.learnerEmbedded;
    final usesReferenceParityLiveProfileV1 =
        usesLearnerEmbeddedProfileV1 && embeddedSceneProfileV1;
    final seatSize = isHero
        ? _LayoutNumbersV1.heroSeatSize
        : _LayoutNumbersV1.seatSize;
    final ringSize = seatSize - 8;
    final seatSurfaceWidth = usesLearnerEmbeddedProfileV1
        ? (usesReferenceParityLiveProfileV1
              ? (isHero ? 46.0 : 42.0)
              : (isHero ? 70.0 : 58.0))
        : (isHero ? 76.0 : 64.0);
    final seatSurfacePadding = usesLearnerEmbeddedProfileV1
        ? (usesReferenceParityLiveProfileV1
              ? const EdgeInsets.symmetric(vertical: 1.5, horizontal: 1.5)
              : const EdgeInsets.symmetric(vertical: 2.5, horizontal: 5))
        : const EdgeInsets.symmetric(vertical: 3, horizontal: 6);
    final baseOpacity = isHero
        ? (usesLearnerEmbeddedProfileV1 ? 0.82 : 0.8)
        : isActing
        ? (usesLearnerEmbeddedProfileV1 ? 0.82 : 0.72)
        : 0.55;
    final surfaceOpacity =
        baseOpacity *
        (isEmpty
            ? 0.28
            : isFolded
            ? (usesLearnerEmbeddedProfileV1 ? 0.34 : 0.5)
            : 1.0);
    final baseSurface = isHero
        ? AppColors.surface
        : isActing
        ? Color.lerp(AppColors.surfaceVariant, AppColors.surface, 0.2) ??
              AppColors.surfaceVariant
        : AppColors.surfaceVariant;
    final surfaceColor = baseSurface.withOpacity(surfaceOpacity);
    final borderColor =
        (isSelected ? AppColors.primaryBrand : AppColors.outlineSoft)
            .withOpacity(
              isEmpty
                  ? 0.35
                  : isFolded
                  ? 0.5
                  : 1.0,
            );
    final textOpacity = isEmpty
        ? 0.35
        : isFolded
        ? (usesLearnerEmbeddedProfileV1 ? 0.28 : 0.5)
        : 1.0;
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final labelFontSize = math.max(10.0, labelStyle?.fontSize ?? 10.0);
    final avatarSize = 26.0;
    final avatarRingWidth = isHero
        ? (usesLearnerEmbeddedProfileV1 ? 1.6 : 2.0)
        : isActing
        ? (usesLearnerEmbeddedProfileV1 ? 3.6 : 3.0)
        : 1.4;
    final avatarRingColor = isHero
        ? AppColors.accentWarning
        : isActing
        ? (usesLearnerEmbeddedProfileV1
              ? const Color(0xFFFFF7D6)
              : const Color(0xFFF2E8FF))
        : AppColors.outlineSoft.withOpacity(0.58);
    final showsForcedBetBadgeV1 =
        forcedBetLabel != null &&
        forcedBetLabel!.isNotEmpty &&
        !usesLearnerEmbeddedProfileV1;
    final liveSeatLabel =
        !usesLearnerEmbeddedProfileV1 &&
            !isEmpty &&
            !isFolded &&
            !isActing &&
            !isHero &&
            !showsForcedBetBadgeV1
        ? 'LIVE'
        : null;
    final isDeadSeat = (isFolded || isEmpty) && !isHero && !isActing;
    final integratedGroundWidth = isHero
        ? (usesReferenceParityLiveProfileV1
              ? 42.0
              : (usesLearnerEmbeddedProfileV1 ? 68.0 : 74.0))
        : (usesReferenceParityLiveProfileV1 ? 34.0 : 58.0);
    final integratedGroundHeight = isHero
        ? (usesReferenceParityLiveProfileV1
              ? 10.0
              : (usesLearnerEmbeddedProfileV1 ? 18.0 : 20.0))
        : (usesReferenceParityLiveProfileV1 ? 9.0 : 16.0);
    final integratedGroundOffset = usesReferenceParityLiveProfileV1
        ? (isHero ? 7.0 : 5.0)
        : (isHero ? 8.0 : 6.0);
    final seatFeltGlowWidth = usesLearnerEmbeddedProfileV1
        ? (usesReferenceParityLiveProfileV1
              ? (isHero ? 52.0 : 40.0)
              : (isHero ? 82.0 : 62.0))
        : (isHero ? 92.0 : 70.0);
    final seatFeltGlowHeight = usesLearnerEmbeddedProfileV1
        ? (usesReferenceParityLiveProfileV1
              ? (isHero ? 16.0 : 12.0)
              : (isHero ? 32.0 : 24.0))
        : (isHero ? 38.0 : 28.0);
    final seatFeltGlowOffset = usesReferenceParityLiveProfileV1
        ? (isHero ? 3.0 : 2.0)
        : (isHero ? 4.0 : 3.0);
    final markerLabelLinesV1 = _markerLabelLinesV1();
    final showsCompositeMarkerV1 = markerLabelLinesV1.length > 1;
    final showsAuxMarkerV1 = !showsBlindMarkerV1 && !showsCompositeMarkerV1;
    final hidesDuplicateBlindRoleBadgeV1 =
        showsBlindMarkerV1 &&
        roleLabel != null &&
        roleLabel!.trim().toUpperCase() == markerLabel?.trim().toUpperCase();
    final showsSeatIdentityLabelV1 = !usesLearnerEmbeddedProfileV1 || isEmpty;
    final showsStackPillV1 =
        !isEmpty && !(usesLearnerEmbeddedProfileV1 && isFolded);
    final markerDecorationV1 = usesLearnerEmbeddedProfileV1
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: showsBlindMarkerV1
                  ? const <Color>[Color(0xFFF8E7A8), Color(0xFFE5C86A)]
                  : const <Color>[Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
            ),
            border: Border.all(
              color: showsBlindMarkerV1
                  ? const Color(0x8880672A)
                  : const Color(0x55334155),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0x22000000,
                ).withOpacity(showsBlindMarkerV1 ? 1.0 : 0.45),
                blurRadius: showsBlindMarkerV1 ? 4 : 2,
                offset: Offset(0, showsBlindMarkerV1 ? 2 : 1),
              ),
            ],
          )
        : (showsBlindMarkerV1
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xFFFDE68A), Color(0xFFF59E0B)],
                  ),
                  border: Border.all(
                    color: const Color(0xCCFEF3C7),
                    width: 1.1,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x55D97706),
                      blurRadius: 9,
                      offset: Offset(0, 3),
                    ),
                  ],
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                  ),
                  border: Border.all(
                    color: const Color(0x660B1220),
                    width: 1.0,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 7,
                      offset: Offset(0, 2.8),
                    ),
                  ],
                ));
    final markerTextColorV1 = usesLearnerEmbeddedProfileV1
        ? const Color(0xFF1F2937)
        : (showsBlindMarkerV1
              ? const Color(0xFF3F2A00)
              : AppColors.textPrimaryDark);
    if (usesReferenceParityLiveProfileV1) {
      final surfaceDiameter = isHero ? 43.0 : 37.0;
      final actingRingSize = isHero ? 54.0 : 45.0;
      final roleText = isEmpty
          ? 'EMPTY'
          : (roleLabel?.trim().isNotEmpty == true
                ? roleLabel!.trim()
                : 'P${index + 1}');
      final markerBottom = isHero ? 12.0 : 9.0;
      return SizedBox(
        width: seatSize,
        height: seatSize,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!isEmpty)
                Positioned(
                  bottom: isHero ? 13 : 10,
                  child: IgnorePointer(
                    child: Container(
                      width: isHero ? 48 : 38,
                      height: isHero ? 10 : 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: RadialGradient(
                          center: const Alignment(0, 0.2),
                          radius: 1.0,
                          colors: [
                            AppColors.primaryBrand.withOpacity(
                              isHero ? 0.06 : 0.04,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (isHero)
                Container(
                  key: Key('modern_table_seat_hero_ring_$index'),
                  width: actingRingSize + 8,
                  height: actingRingSize + 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accentWarning.withOpacity(0.96),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x66F1C40F).withOpacity(0.12),
                        blurRadius: 2.8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              if (isSelected)
                Container(
                  width: actingRingSize + 2,
                  height: actingRingSize + 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBrand,
                      width: 1.5,
                    ),
                  ),
                ),
              if (isActing)
                _ActingPulseRing(
                  key: Key('modern_table_seat_acting_ring_$index'),
                  size: actingRingSize,
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: surfaceDiameter + 8,
                    height: surfaceDiameter + 8,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          key: Key('modern_table_seat_surface_$index'),
                          width: surfaceDiameter,
                          height: surfaceDiameter,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: const Alignment(0, -0.18),
                              radius: 0.92,
                              colors: [
                                const Color(0xFF355B75).withOpacity(
                                  isFolded ? 0.34 : (isHero ? 0.82 : 0.72),
                                ),
                                const Color(0xFF213247).withOpacity(
                                  isFolded ? 0.26 : (isHero ? 0.9 : 0.84),
                                ),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                isHero ? 0.32 : (isActing ? 0.3 : 0.2),
                              ),
                              width: isHero ? 0.95 : 0.7,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2.6,
                                offset: const Offset(0, 1.2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            roleText,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: const Color(0xFFDCE7F4).withOpacity(
                                    isEmpty ? 0.46 : (isFolded ? 0.54 : 0.96),
                                  ),
                                  fontWeight: FontWeight.w700,
                                  fontSize: isHero ? 9.4 : 8.6,
                                  letterSpacing: 0.06,
                                  height: 1.0,
                                ),
                          ),
                        ),
                        if (markerLabel != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: markerBottom,
                            child: Center(
                              child: Container(
                                key: Key('modern_table_seat_marker_$index'),
                                constraints: BoxConstraints(
                                  minWidth: showsCompositeMarkerV1 ? 30 : 0,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: showsCompositeMarkerV1 ? 5.5 : 6,
                                  vertical: showsCompositeMarkerV1 ? 3.5 : 2.5,
                                ),
                                decoration: markerDecorationV1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: markerLabelLinesV1
                                      .map(
                                        (line) => Text(
                                          line,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: markerTextColorV1,
                                                fontWeight: FontWeight.w700,
                                                fontSize: showsCompositeMarkerV1
                                                    ? 7.2
                                                    : 7.8,
                                                height: showsCompositeMarkerV1
                                                    ? 0.92
                                                    : 1.0,
                                                letterSpacing: 0.08,
                                              ),
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (showsStackPillV1)
                    Container(
                      key: Key('modern_table_seat_stack_pill_P${index + 1}'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.5,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF5C6474,
                        ).withOpacity(isFolded ? 0.22 : 0.44),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        stack.toString(),
                        textWidthBasis: TextWidthBasis.longestLine,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(
                            0xFFE5ECF5,
                          ).withOpacity(isFolded ? 0.42 : 0.82),
                          fontSize: 7.0,
                          fontFamily: 'monospace',
                          fontFeatures: const [FontFeature.tabularFigures()],
                          height: 1.0,
                        ),
                      ),
                    ),
                  if (isActing)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Container(
                        key: Key('modern_table_seat_acting_$index'),
                        width: 26,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.accentWarning.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(2),
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
    return SizedBox(
      width: seatSize,
      height: seatSize,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!isEmpty)
              Positioned(
                bottom: seatFeltGlowOffset,
                child: IgnorePointer(
                  child: Container(
                    width: seatFeltGlowWidth,
                    height: seatFeltGlowHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: RadialGradient(
                        center: const Alignment(0, 0.05),
                        radius: 1.0,
                        colors: [
                          AppColors.primaryBrand.withOpacity(
                            usesLearnerEmbeddedProfileV1
                                ? (isHero
                                      ? 0.07
                                      : isActing
                                      ? 0.06
                                      : 0.03)
                                : (isHero
                                      ? 0.14
                                      : isActing
                                      ? 0.09
                                      : 0.05),
                          ),
                          AppColors.accentWarning.withOpacity(
                            usesLearnerEmbeddedProfileV1
                                ? (isHero
                                      ? 0.03
                                      : isActing
                                      ? 0.01
                                      : 0.0)
                                : (isHero
                                      ? 0.08
                                      : isActing
                                      ? 0.02
                                      : 0.0),
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.48, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            if (!isEmpty)
              Positioned(
                bottom: integratedGroundOffset,
                child: IgnorePointer(
                  child: Container(
                    width: integratedGroundWidth,
                    height: integratedGroundHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: RadialGradient(
                        center: const Alignment(0, 0.2),
                        radius: 1.0,
                        colors: [
                          AppColors.primaryBrand.withOpacity(
                            usesLearnerEmbeddedProfileV1
                                ? (isHero ? 0.06 : 0.05)
                                : (isHero ? 0.12 : 0.07),
                          ),
                          AppColors.surfaceVariant.withOpacity(
                            usesLearnerEmbeddedProfileV1
                                ? (isActing ? 0.1 : 0.05)
                                : (isActing ? 0.14 : 0.08),
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.62, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            if (!isEmpty)
              Positioned(
                bottom: isHero ? 10 : 8,
                child: IgnorePointer(
                  child: Container(
                    width: isHero
                        ? (usesLearnerEmbeddedProfileV1 ? 60 : 66)
                        : 50,
                    height: isHero
                        ? (usesLearnerEmbeddedProfileV1 ? 14 : 16)
                        : 13,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: RadialGradient(
                        center: const Alignment(0, 0.2),
                        radius: 1.0,
                        colors: [
                          Colors.black.withOpacity(
                            usesLearnerEmbeddedProfileV1
                                ? (isHero ? 0.18 : 0.28)
                                : (isHero ? 0.36 : 0.28),
                          ),
                          Colors.black.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (isHero)
              Container(
                key: Key('modern_table_seat_hero_ring_$index'),
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentWarning,
                    width: usesReferenceParityLiveProfileV1
                        ? 1.1
                        : (usesLearnerEmbeddedProfileV1 ? 1.3 : 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x66F1C40F).withOpacity(
                        usesReferenceParityLiveProfileV1
                            ? 0.18
                            : (usesLearnerEmbeddedProfileV1 ? 0.24 : 0.4),
                      ),
                      blurRadius: usesReferenceParityLiveProfileV1
                          ? 4.2
                          : (usesLearnerEmbeddedProfileV1 ? 5.5 : 8),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            if (isSelected)
              Container(
                width: ringSize - 6,
                height: ringSize - 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBrand, width: 2),
                ),
              ),
            if (isActing)
              _ActingPulseRing(
                key: Key('modern_table_seat_acting_ring_$index'),
                size: usesLearnerEmbeddedProfileV1
                    ? ringSize - 6
                    : ringSize - 10,
              ),
            Container(
              key: Key('modern_table_seat_surface_$index'),
              width: seatSurfaceWidth,
              padding: seatSurfacePadding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(surfaceColor, Colors.white, 0.08) ??
                        surfaceColor,
                    Color.lerp(surfaceColor, Colors.black, 0.06) ??
                        surfaceColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  usesLearnerEmbeddedProfileV1
                      ? (usesReferenceParityLiveProfileV1
                            ? 999
                            : (isHero ? 18 : 15))
                      : (isHero ? 22 : 18),
                ),
                border: Border.all(
                  color: borderColor,
                  width: usesLearnerEmbeddedProfileV1
                      ? (usesReferenceParityLiveProfileV1
                            ? (isHero ? 1.15 : 0.65)
                            : (isHero ? 1.5 : 0.8))
                      : (isHero ? 2 : 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x22000000).withOpacity(
                      usesReferenceParityLiveProfileV1
                          ? 0.42
                          : (usesLearnerEmbeddedProfileV1 ? 0.65 : 1.0),
                    ),
                    blurRadius: usesReferenceParityLiveProfileV1
                        ? 5
                        : (usesLearnerEmbeddedProfileV1 ? 8 : 12),
                    offset: Offset(
                      0,
                      usesReferenceParityLiveProfileV1
                          ? 2
                          : (usesLearnerEmbeddedProfileV1 ? 3 : 5),
                    ),
                  ),
                ],
              ),
              child: Transform.translate(
                offset: Offset(0, visualYOffset),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: avatarSize + 4,
                          height: avatarSize + 4,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: avatarSize + 2,
                                  height: avatarSize + 2,
                                  decoration: isDeadSeat
                                      ? const BoxDecoration(
                                          shape: BoxShape.circle,
                                        )
                                      : BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: SweepGradient(
                                            startAngle: -math.pi * 0.9,
                                            endAngle: math.pi * 1.1,
                                            colors: [
                                              const Color(0x66FFFFFF),
                                              avatarRingColor.withOpacity(
                                                isFolded ? 0.35 : 0.95,
                                              ),
                                              const Color(0xAA0B1220),
                                              avatarRingColor.withOpacity(
                                                isFolded ? 0.3 : 0.85,
                                              ),
                                              const Color(0x55FFFFFF),
                                            ],
                                            stops: const [
                                              0.0,
                                              0.18,
                                              0.45,
                                              0.72,
                                              1.0,
                                            ],
                                          ),
                                          boxShadow: [
                                            if (isHero)
                                              BoxShadow(
                                                color: const Color(0x22E7B93E)
                                                    .withOpacity(
                                                      usesLearnerEmbeddedProfileV1
                                                          ? 0.5
                                                          : 1.0,
                                                    ),
                                                blurRadius:
                                                    usesLearnerEmbeddedProfileV1
                                                    ? 3
                                                    : 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            if (isActing)
                                              BoxShadow(
                                                color: Colors.white.withOpacity(
                                                  isFolded ? 0.2 : 0.55,
                                                ),
                                                blurRadius: 12,
                                                offset: const Offset(0, 0),
                                              ),
                                          ],
                                        ),
                                  child: Stack(
                                    children: [
                                      if (!isDeadSeat)
                                        Positioned.fill(
                                          child: Padding(
                                            padding: const EdgeInsets.all(1.2),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(
                                                    0x55FFFFFF,
                                                  ),
                                                  width: 0.8,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              center: const Alignment(
                                                0.0,
                                                -0.2,
                                              ),
                                              radius: 0.8,
                                              colors: isDeadSeat
                                                  ? const [
                                                      Color(0x4D334155),
                                                      Color(0x4D1F2937),
                                                    ]
                                                  : [
                                                      AppColors.surface
                                                          .withOpacity(
                                                            isFolded
                                                                ? 0.2
                                                                : 0.7,
                                                          ),
                                                      AppColors.surfaceVariant
                                                          .withOpacity(
                                                            isFolded
                                                                ? 0.2
                                                                : 0.9,
                                                          ),
                                                    ],
                                            ),
                                            boxShadow: isDeadSeat
                                                ? null
                                                : const [
                                                    BoxShadow(
                                                      color: Color(0x1F000000),
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (usesLearnerEmbeddedProfileV1 && isFolded)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Center(
                                      child: Transform.rotate(
                                        angle: -math.pi / 4,
                                        child: Container(
                                          key: Key(
                                            'modern_table_seat_folded_slash_$index',
                                          ),
                                          width: 3.2,
                                          height: isHero ? 54 : 46,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: <Color>[
                                                const Color(
                                                  0xD7E2E8F0,
                                                ).withOpacity(0.78),
                                                const Color(0x88334155),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (markerLabel != null)
                                Positioned(
                                  left: usesLearnerEmbeddedProfileV1 ? 0 : null,
                                  right: usesLearnerEmbeddedProfileV1 ? 0 : -1,
                                  bottom: usesLearnerEmbeddedProfileV1 ? -2 : 2,
                                  child: Container(
                                    key: Key('modern_table_seat_marker_$index'),
                                    constraints: BoxConstraints(
                                      minWidth: showsCompositeMarkerV1 ? 32 : 0,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: showsCompositeMarkerV1
                                          ? 6
                                          : (usesLearnerEmbeddedProfileV1
                                                ? 6
                                                : 7),
                                      vertical: showsCompositeMarkerV1
                                          ? 4
                                          : (usesLearnerEmbeddedProfileV1
                                                ? 2
                                                : 3),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: DecoratedBox(
                                            decoration: markerDecorationV1,
                                          ),
                                        ),
                                        if (!usesLearnerEmbeddedProfileV1 ||
                                            showsBlindMarkerV1)
                                          Positioned(
                                            left: 3,
                                            right: 3,
                                            bottom: -2,
                                            child: IgnorePointer(
                                              child: Container(
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                  gradient: RadialGradient(
                                                    center: const Alignment(
                                                      0,
                                                      0.2,
                                                    ),
                                                    radius: 1.0,
                                                    colors: [
                                                      Colors.black.withOpacity(
                                                        0.28,
                                                      ),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (!usesLearnerEmbeddedProfileV1 ||
                                            showsBlindMarkerV1)
                                          Positioned(
                                            left: 3.0,
                                            top: 2.0,
                                            child: DecoratedBox(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  center: Alignment(-0.6, -0.6),
                                                  radius: 1.0,
                                                  colors: [
                                                    Color(0xAAFFFFFF),
                                                    Color(0x00FFFFFF),
                                                  ],
                                                ),
                                              ),
                                              child: const SizedBox(
                                                width: 4.8,
                                                height: 3.6,
                                              ),
                                            ),
                                          ),
                                        Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: markerLabelLinesV1
                                                .map(
                                                  (line) => Text(
                                                    line,
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                      color: markerTextColorV1
                                                          .withOpacity(
                                                            showsAuxMarkerV1 &&
                                                                    usesLearnerEmbeddedProfileV1
                                                                ? 0.86
                                                                : 1.0,
                                                          ),
                                                      fontWeight:
                                                          usesLearnerEmbeddedProfileV1
                                                          ? FontWeight.w700
                                                          : FontWeight.w800,
                                                      fontSize:
                                                          showsCompositeMarkerV1
                                                          ? 8.0
                                                          : (usesLearnerEmbeddedProfileV1
                                                                ? 8.6
                                                                : 9.5),
                                                      height:
                                                          showsCompositeMarkerV1
                                                          ? 0.92
                                                          : 1.0,
                                                      letterSpacing:
                                                          showsCompositeMarkerV1
                                                          ? 0.12
                                                          : (usesLearnerEmbeddedProfileV1
                                                                ? 0.14
                                                                : 0.24),
                                                    ),
                                                  ),
                                                )
                                                .toList(growable: false),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: usesLearnerEmbeddedProfileV1 ? 2 : 3),
                        if (showsSeatIdentityLabelV1)
                          Text(
                            isEmpty ? 'EMPTY' : 'P${index + 1}',
                            key: isEmpty
                                ? Key('modern_table_seat_empty_$index')
                                : null,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: labelStyle?.copyWith(
                              color: const Color(
                                0xB3E2E8F0,
                              ).withOpacity(isHero ? 0.96 : textOpacity),
                              fontSize: usesLearnerEmbeddedProfileV1
                                  ? math.max(9.0, labelFontSize - 1)
                                  : labelFontSize,
                              fontWeight: usesLearnerEmbeddedProfileV1
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              height: 1.1,
                              letterSpacing: usesLearnerEmbeddedProfileV1
                                  ? 0.1
                                  : 0.2,
                              shadows: usesLearnerEmbeddedProfileV1
                                  ? null
                                  : const [
                                      Shadow(
                                        color: Color(0x66000000),
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                            ),
                          ),
                        SizedBox(height: usesLearnerEmbeddedProfileV1 ? 1 : 2),
                        if (showsStackPillV1)
                          usesLearnerEmbeddedProfileV1
                              ? Text(
                                  stack.toString(),
                                  key: Key(
                                    'modern_table_seat_stack_pill_P${index + 1}',
                                  ),
                                  textWidthBasis: TextWidthBasis.longestLine,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: labelStyle?.copyWith(
                                    color: const Color(
                                      0xFFF1F5F9,
                                    ).withOpacity(0.68 * textOpacity),
                                    fontSize: math.max(8.0, labelFontSize - 2),
                                    fontFamily: 'monospace',
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                    height: 1.0,
                                  ),
                                )
                              : Container(
                                  key: Key(
                                    'modern_table_seat_stack_pill_P${index + 1}',
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 1.5,
                                  ),
                                  decoration: _glassPillDecoration(
                                    radius: 10,
                                    fillOpacity: 0.42 * textOpacity,
                                    borderOpacity: 0.48 * textOpacity,
                                  ),
                                  child: Text(
                                    stack.toString(),
                                    textWidthBasis: TextWidthBasis.longestLine,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    style: labelStyle?.copyWith(
                                      color: const Color(
                                        0xFFF1F5F9,
                                      ).withOpacity(0.82 * textOpacity),
                                      fontSize: math.max(
                                        9.0,
                                        labelFontSize - 1,
                                      ),
                                      fontFamily: 'monospace',
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Container(
                              key: Key('modern_table_seat_selected_$index'),
                              width: 26,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBrand,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        if (isActing)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Container(
                              key: Key('modern_table_seat_acting_$index'),
                              width: 30,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.accentWarning.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (isActing && !usesLearnerEmbeddedProfileV1)
                      Positioned(
                        top: 3,
                        right: 2,
                        child: RunnerSeatStateBadgeV1(
                          key: Key('modern_table_seat_action_marker_$index'),
                          label: 'ACT',
                          tone: RunnerSeatStateBadgeToneV1.action,
                          visualPriorityV1: usesLearnerEmbeddedProfileV1
                              ? RunnerSeatStateBadgePriorityV1.secondary
                              : RunnerSeatStateBadgePriorityV1.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: usesLearnerEmbeddedProfileV1
                                ? 7.0
                                : 8.5,
                            vertical: usesLearnerEmbeddedProfileV1 ? 3.0 : 4.0,
                          ),
                          textStyle: (labelStyle ?? const TextStyle()).copyWith(
                            color: Colors.white.withOpacity(textOpacity),
                            fontSize: usesLearnerEmbeddedProfileV1
                                ? math.max(8.5, labelFontSize - 2)
                                : math.max(10.0, labelFontSize - 1),
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ),
                    if (roleLabel != null &&
                        roleLabel!.isNotEmpty &&
                        !hidesDuplicateBlindRoleBadgeV1)
                      Positioned(
                        top: isActing ? 26 : 3,
                        left: 2,
                        child: RunnerSeatStateBadgeV1(
                          key: Key('modern_table_seat_role_$index'),
                          label: roleLabel!,
                          tone: RunnerSeatStateBadgeToneV1.role,
                          visualPriorityV1:
                              RunnerSeatStateBadgePriorityV1.secondary,
                          padding: EdgeInsets.symmetric(
                            horizontal: usesLearnerEmbeddedProfileV1
                                ? 4.5
                                : 5.5,
                            vertical: usesLearnerEmbeddedProfileV1 ? 1.4 : 2.0,
                          ),
                          textStyle: (labelStyle ?? const TextStyle()).copyWith(
                            color: Colors.white.withOpacity(
                              (usesLearnerEmbeddedProfileV1 ? 0.78 : 1.0) *
                                  textOpacity,
                            ),
                            fontSize: usesLearnerEmbeddedProfileV1
                                ? math.max(7.2, labelFontSize - 2.8)
                                : math.max(8.0, labelFontSize - 2),
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                            letterSpacing: 0.18,
                          ),
                        ),
                      ),
                    if (showsForcedBetBadgeV1)
                      Positioned(
                        bottom: isSelected || isActing ? 13 : 8,
                        child: RunnerSeatStateBadgeV1(
                          key: Key('modern_table_seat_forced_bet_$index'),
                          label: forcedBetLabel!,
                          tone: RunnerSeatStateBadgeToneV1.forcedBet,
                          visualPriorityV1:
                              RunnerSeatStateBadgePriorityV1.secondary,
                          padding: EdgeInsets.symmetric(
                            horizontal: usesLearnerEmbeddedProfileV1
                                ? 4.8
                                : 5.5,
                            vertical: usesLearnerEmbeddedProfileV1 ? 1.6 : 2.0,
                          ),
                          textStyle: (labelStyle ?? const TextStyle()).copyWith(
                            color: const Color(
                              0xFFF0FDF4,
                            ).withOpacity(textOpacity),
                            fontSize: usesLearnerEmbeddedProfileV1
                                ? math.max(7.0, labelFontSize - 3)
                                : math.max(7.5, labelFontSize - 2.5),
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                    if (liveSeatLabel != null && liveSeatLabel.isNotEmpty)
                      Positioned(
                        bottom: showsForcedBetBadgeV1
                            ? 30
                            : (isSelected || isActing ? 13 : 8),
                        child: RunnerSeatStateBadgeV1(
                          key: Key('modern_table_seat_live_$index'),
                          label: liveSeatLabel,
                          tone: RunnerSeatStateBadgeToneV1.live,
                          visualPriorityV1:
                              RunnerSeatStateBadgePriorityV1.secondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.5,
                            vertical: 2.0,
                          ),
                          textStyle: (labelStyle ?? const TextStyle()).copyWith(
                            color: const Color(
                              0xFFF0FDFA,
                            ).withOpacity(textOpacity),
                            fontSize: math.max(7.5, labelFontSize - 2.5),
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                    if (isActing && !isHero)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: SizedBox(
                              key: Key('modern_table_bet_bubble_P${index + 1}'),
                              width: 0,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    if (isFolded && !isEmpty && !usesLearnerEmbeddedProfileV1)
                      Positioned(
                        bottom: isSelected || isActing ? 13 : 8,
                        child: RunnerSeatStateBadgeV1(
                          key: Key('modern_table_seat_folded_$index'),
                          label: 'FOLDED',
                          tone: RunnerSeatStateBadgeToneV1.folded,
                          visualPriorityV1:
                              RunnerSeatStateBadgePriorityV1.secondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.5,
                            vertical: 2.0,
                          ),
                          textStyle: (labelStyle ?? const TextStyle()).copyWith(
                            color: const Color(0xFFD7DCE4).withOpacity(0.88),
                            fontSize: math.max(7.5, labelFontSize - 2.5),
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                            letterSpacing: 0.25,
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

class _BlindPostedBetTokenV1 extends StatelessWidget {
  const _BlindPostedBetTokenV1({
    super.key,
    required this.label,
    required this.size,
    this.isBlindContributionV1 = true,
  });

  final String label;
  final double size;
  final bool isBlindContributionV1;

  @override
  Widget build(BuildContext context) {
    final innerSize = size * 0.62;
    final outerGradient = isBlindContributionV1
        ? const <Color>[Color(0xFFFDE68A), Color(0xFFD97706)]
        : const <Color>[Color(0xFFB6F0FF), Color(0xFF0EA5E9)];
    final outerBorder = isBlindContributionV1
        ? const Color(0xFFFDF6D2)
        : const Color(0xFFD7F4FF);
    final innerGradient = isBlindContributionV1
        ? const <Color>[Color(0xFFFFF7D6), Color(0xFFFCD34D)]
        : const <Color>[Color(0xFFF0F9FF), Color(0xFF7DD3FC)];
    final innerBorder = isBlindContributionV1
        ? const Color(0xCC78350F)
        : const Color(0xCC075985);
    final textColor = isBlindContributionV1
        ? const Color(0xFF3F2A00)
        : const Color(0xFF082F49);
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: outerGradient,
                ),
                border: Border.all(color: outerBorder, width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isBlindContributionV1
                                ? const Color(0x55251000)
                                : const Color(0x3320364A))
                            .withOpacity(1),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            Container(
              width: size * 0.82,
              height: size * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: innerBorder, width: 1.0),
              ),
            ),
            ...List<Widget>.generate(6, (index) {
              return Transform.rotate(
                angle: (math.pi * 2 * index) / 6,
                child: Container(
                  width: size * 0.11,
                  height: size * 0.72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: const Color(0x99FFF7D6),
                  ),
                ),
              );
            }),
            Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment(-0.2, -0.3),
                  radius: 0.9,
                  colors: innerGradient,
                ),
                border: Border.all(color: innerBorder, width: 0.9),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.28,
                  height: 1.0,
                  letterSpacing: 0.18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceSetterCueV1 extends StatelessWidget {
  const _PriceSetterCueV1({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    return RunnerSeatStateBadgeV1(
      label: label,
      tone: RunnerSeatStateBadgeToneV1.action,
      visualPriorityV1: RunnerSeatStateBadgePriorityV1.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
      textStyle: (labelStyle ?? const TextStyle()).copyWith(
        color: const Color(0xFFF8FAFC),
        fontSize: math.max(6.8, (labelStyle?.fontSize ?? 10.0) - 2.8),
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: 0.14,
      ),
    );
  }
}

class _ActingPulseRing extends StatelessWidget {
  const _ActingPulseRing({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.85), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    super.key,
    required this.width,
    required this.height,
    required this.label,
    required this.offset,
    required this.rotationDegrees,
    this.surfaceKey,
    this.onTapV1,
  });

  final double width;
  final double height;
  final String label;
  final double offset;
  final double rotationDegrees;
  final Key? surfaceKey;
  final VoidCallback? onTapV1;

  @override
  Widget build(BuildContext context) {
    final card = Transform.translate(
      offset: Offset(offset, 0),
      child: Transform.rotate(
        angle: rotationDegrees * (math.pi / 180),
        child: _PlayingCardSurface(
          width: width,
          height: height,
          label: label,
          surfaceKey: surfaceKey,
          boxShadow: [
            BoxShadow(
              color: const Color(0x2A000000),
              blurRadius: _ModernTableVisualSsotV1.heroShadowBlur + 4,
              offset:
                  _ModernTableVisualSsotV1.heroShadowOffset +
                  const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
    if (onTapV1 == null) {
      return card;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapV1,
      child: card,
    );
  }
}

class _PlayingCardSurface extends StatelessWidget {
  const _PlayingCardSurface({
    required this.width,
    required this.height,
    required this.label,
    this.boxShadow,
    this.surfaceKey,
  });

  final double width;
  final double height;
  final String label;
  final List<BoxShadow>? boxShadow;
  final Key? surfaceKey;

  @override
  Widget build(BuildContext context) {
    const cardRadius = 8.0;
    return Container(
      key: surfaceKey,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFC), Color(0xFFEFF4F8)],
          stops: [0.0, 0.54, 1.0],
        ),
        border: Border.all(color: const Color(0xFFDCE4EC), width: 0.95),
        boxShadow:
            boxShadow ??
            const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 9,
                offset: Offset(0, 5),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          children: [
            Positioned(
              left: 2,
              right: 2,
              top: 2,
              height: 1,
              child: Container(color: Color(0x47FFFFFF)),
            ),
            Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: const Color(0xFF101C2A),
                  shadows: const [
                    Shadow(
                      color: Color(0x30FFFFFF),
                      blurRadius: 1.8,
                      offset: Offset(0, 0.7),
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

class _BoardOverlay extends StatelessWidget {
  const _BoardOverlay({
    required this.cardWidth,
    required this.cardHeight,
    required this.flopGap,
    required this.turnGap,
    required this.dealtCount,
    this.useReferenceParityLiveProfileV1 = false,
    this.debugBoardCardLabels,
    this.onBoardSlotTapV1,
  });

  final double cardWidth;
  final double cardHeight;
  final double flopGap;
  final double turnGap;
  final int dealtCount;
  final bool useReferenceParityLiveProfileV1;
  final List<String>? debugBoardCardLabels;
  final ValueChanged<String>? onBoardSlotTapV1;

  String _boardSlotIdForIndex(int index) {
    switch (index) {
      case 0:
        return 'flop_left';
      case 1:
        return 'flop_mid';
      case 2:
        return 'flop_right';
      case 3:
        return 'turn';
      case 4:
        return 'river';
    }
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_LayoutNumbersV1.boardRadius);
    const slotRadius = 6.0;
    final trayWidth = ((cardWidth + 4) * 5) + (flopGap * 2) + (turnGap * 2);
    final trayHeight = cardHeight + 12;
    final trayBorderColor = Colors.white.withOpacity(
      useReferenceParityLiveProfileV1 ? 0.05 : 0.11,
    );
    final trayShadow = useReferenceParityLiveProfileV1
        ? const <BoxShadow>[]
        : const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ];
    final boardShellBorderColor = Colors.white.withOpacity(
      useReferenceParityLiveProfileV1 ? 0.055 : 0.14,
    );
    final boardShellShadow = useReferenceParityLiveProfileV1
        ? const <BoxShadow>[]
        : const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ];
    final boardShellGradient = useReferenceParityLiveProfileV1
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2E3E), Color(0xFF0A2231), Color(0xFF081D2A)],
            stops: [0.0, 0.58, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF13364A), Color(0xFF0A2231), Color(0xFF05121C)],
            stops: [0.0, 0.52, 1.0],
          );
    final trayGradient = useReferenceParityLiveProfileV1
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x44193449), Color(0x610A1520)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x7A173041), Color(0x92040D15)],
          );
    return Container(
      key: const Key('modern_table_board'),
      padding: const EdgeInsets.symmetric(
        vertical: _LayoutNumbersV1.boardPaddingV,
        horizontal: _LayoutNumbersV1.boardPaddingH,
      ),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: boardShellGradient,
        border: Border.all(color: boardShellBorderColor),
        boxShadow: boardShellShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(
                        useReferenceParityLiveProfileV1 ? 0.012 : 0.045,
                      ),
                      Colors.black.withOpacity(
                        useReferenceParityLiveProfileV1 ? 0.06 : 0.16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!useReferenceParityLiveProfileV1)
              Positioned(
                left: 12,
                right: 12,
                top: 6,
                height: 1.15,
                child: Container(color: Colors.white.withOpacity(0.13)),
              ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: trayWidth,
                  height: trayHeight,
                  child: DecoratedBox(
                    key: const Key('modern_table_board_tray'),
                    decoration: BoxDecoration(
                      gradient: trayGradient,
                      borderRadius: radius,
                      border: Border.all(color: trayBorderColor, width: 1),
                      boxShadow: trayShadow,
                    ),
                  ),
                ),
              ),
            ),
            if (!useReferenceParityLiveProfileV1)
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: trayWidth - 18,
                      height: trayHeight - 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0x0FFFFFFF),
                              AppColors.primaryBrand.withOpacity(0.04),
                              Colors.black.withOpacity(0.10),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.07),
                            width: 0.9,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!useReferenceParityLiveProfileV1)
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: trayWidth - 34,
                      height: trayHeight - 24,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0.015),
                              AppColors.primaryBrand.withOpacity(0.035),
                              Colors.white.withOpacity(0.015),
                            ],
                            stops: const [0.0, 0.52, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 16,
              right: 16,
              top: 6,
              height: 1.1,
              child: Container(color: Colors.white.withOpacity(0.075)),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 6,
              height: 1.1,
              child: Container(color: Colors.white.withOpacity(0.055)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final gap = index <= 1 ? flopGap : turnGap;
                final isDealt = index < dealtCount;
                final debugLabel =
                    debugBoardCardLabels != null &&
                        index < debugBoardCardLabels!.length
                    ? debugBoardCardLabels![index]
                    : '';
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onBoardSlotTapV1 == null
                          ? null
                          : () => onBoardSlotTapV1!.call(
                              _boardSlotIdForIndex(index),
                            ),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        key: Key('modern_table_board_slot_$index'),
                        width: cardWidth + 4,
                        height: cardHeight + 4,
                        child: isDealt
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(slotRadius),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withOpacity(0.06),
                                              Colors.black.withOpacity(0.35),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            slotRadius,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: _PlayingCardSurface(
                                        width: cardWidth,
                                        height: cardHeight,
                                        label: debugLabel,
                                        surfaceKey: Key(
                                          'modern_table_board_card_$index',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Center(
                                child: SizedBox(
                                  key: Key(
                                    'modern_table_board_placeholder_$index',
                                  ),
                                  width: cardWidth,
                                  height: cardHeight,
                                ),
                              ),
                      ),
                    ),
                    if (index < 4) SizedBox(width: gap),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _OvalFeltPainter extends CustomPainter {
  const _OvalFeltPainter();

  static const Color _kRailStitchHighlight = Color(0x14FFFFFF);
  static const double _kWatermarkYOffset = 34.0;

  @override
  void paint(Canvas canvas, Size size) {
    final tableRect = Offset.zero & size;
    final tableRRect = RRect.fromRectAndRadius(
      tableRect,
      Radius.circular(tableRect.width / 2),
    );
    const railWidth = 14.0;
    void drawNoise(Rect bounds, Color color, int density) {
      final rng = math.Random(7);
      final paint = Paint()..color = color;
      for (var i = 0; i < density; i++) {
        final dx = bounds.left + rng.nextDouble() * bounds.width;
        final dy = bounds.top + rng.nextDouble() * bounds.height;
        canvas.drawCircle(Offset(dx, dy), 0.6, paint);
      }
    }

    final railPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A5E76), Color(0xFF1A2B3D), Color(0xFF050A12)],
        stops: [0.0, 0.44, 1.0],
      ).createShader(tableRect);
    canvas.drawRRect(tableRRect, railPaint);
    drawNoise(
      tableRect,
      Colors.white.withOpacity(0.007),
      (tableRect.width * tableRect.height / 9000).round().clamp(24, 56),
    );

    final feltRect = tableRect.deflate(railWidth);
    final feltRRect = RRect.fromRectAndRadius(
      feltRect,
      Radius.circular(feltRect.width / 2),
    );
    final fillPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.2),
        radius: 0.92,
        colors: [Color(0xFF2A6D88), Color(0xFF15384C), Color(0xFF071520)],
        stops: [0.0, 0.58, 1.0],
      ).createShader(feltRect);
    canvas.drawRRect(feltRRect, fillPaint);
    final vignettePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.1),
        radius: 0.98,
        colors: [Color(0x00000000), Color(0x33040B12), Color(0x66030A10)],
        stops: [0.0, 0.7, 1.0],
      ).createShader(feltRect);
    canvas.drawRRect(feltRRect, vignettePaint);
    drawNoise(
      feltRect,
      Colors.black.withOpacity(0.010),
      (feltRect.width * feltRect.height / 9200).round().clamp(24, 60),
    );

    final innerShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..color = Colors.black.withOpacity(0.35);
    canvas.drawRRect(feltRRect, innerShadowPaint);

    final railStitchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _kRailStitchHighlight;
    canvas.drawRRect(feltRRect.inflate(1.0), railStitchPaint);

    final railHighlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withOpacity(0.08);
    canvas.drawRRect(tableRRect.deflate(2.5), railHighlightPaint);

    final watermarkStyle = TextStyle(
      color: const Color(0x0C93C5E6),
      fontSize: feltRect.width * 0.18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );
    final watermarkText = TextPainter(
      text: TextSpan(text: 'SHARKY', style: watermarkStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    final watermarkOffset = Offset(
      feltRect.center.dx - (watermarkText.width / 2),
      feltRect.center.dy - (watermarkText.height / 2) + _kWatermarkYOffset,
    );
    watermarkText.paint(canvas, watermarkOffset);
  }

  @override
  bool shouldRepaint(covariant _OvalFeltPainter oldDelegate) {
    return false;
  }
}

class _PotMetaV1 extends StatelessWidget {
  const _PotMetaV1({required this.pot, this.anteAmount});

  final int pot;
  final int? anteAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (anteAmount != null) ...[
          _AnteIndicatorBadgeV1(amount: anteAmount!),
          const SizedBox(height: 6),
        ],
        _PotLabel(pot: pot),
      ],
    );
  }
}

class _AnteIndicatorBadgeV1 extends StatelessWidget {
  const _AnteIndicatorBadgeV1({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return RunnerSeatStateBadgeV1(
      key: const Key('modern_table_ante_indicator'),
      label: 'ANTE $amount',
      tone: RunnerSeatStateBadgeToneV1.neutral,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      textStyle: (Theme.of(context).textTheme.labelSmall ?? const TextStyle())
          .copyWith(
            color: const Color(0xFFF8FAFC),
            fontWeight: FontWeight.w800,
            fontSize: 10,
            height: 1.0,
            letterSpacing: 0.28,
          ),
    );
  }
}

class _PotLabel extends StatelessWidget {
  const _PotLabel({required this.pot, this.displayLabel});

  final int pot;
  final String? displayLabel;

  @override
  Widget build(BuildContext context) {
    final resolvedDisplayLabel = (displayLabel == null || displayLabel!.isEmpty)
        ? pot.toString()
        : displayLabel!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth < 150;
        return Container(
          key: const Key('modern_table_pot_label'),
          padding: EdgeInsets.symmetric(
            horizontal: compactWidth ? 8 : 11,
            vertical: compactWidth ? 3.5 : 4.5,
          ),
          decoration: BoxDecoration(
            color: const Color(0x77000000),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xBFC89439), width: 0.75),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'POT',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xA894A3B8),
                    letterSpacing: compactWidth ? 0.6 : 0.9,
                    fontWeight: FontWeight.w500,
                    fontSize: compactWidth ? 9.2 : null,
                    height: 1.0,
                  ),
                ),
                SizedBox(width: compactWidth ? 5 : 7),
                Text(
                  resolvedDisplayLabel,
                  key: const Key('modern_table_pot_amount'),
                  textWidthBasis: TextWidthBasis.longestLine,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFFEFD78E),
                    fontWeight: FontWeight.w600,
                    fontSize: compactWidth ? 13.0 : null,
                    height: 1.0,
                    fontFamily: 'monospace',
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScenePriceBadgeV1 extends StatelessWidget {
  const _ScenePriceBadgeV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return RunnerSeatStateBadgeV1(
      key: const Key('modern_table_scene_price_badge'),
      label: label,
      tone: RunnerSeatStateBadgeToneV1.neutral,
      visualPriorityV1: RunnerSeatStateBadgePriorityV1.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.5),
      textStyle: (Theme.of(context).textTheme.labelSmall ?? const TextStyle())
          .copyWith(
            color: const Color(0xCFE2E8F0),
            fontWeight: FontWeight.w500,
            fontSize: 8.4,
            height: 1.0,
            letterSpacing: 0.12,
          ),
    );
  }
}

String _formatBbUnitsForSceneV1(int units) {
  final negative = units < 0;
  final absUnits = units.abs();
  final whole = absUnits ~/ 2;
  final hasHalf = absUnits.isOdd;
  final bb = hasHalf ? '$whole.5' : '$whole';
  return negative ? '-$bb' : bb;
}
