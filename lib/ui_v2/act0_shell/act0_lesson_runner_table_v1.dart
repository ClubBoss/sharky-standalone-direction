part of 'act0_lesson_runner_shell_v1.dart';

class _Act0TableV1 extends StatelessWidget {
  const _Act0TableV1({
    this.attention,
    required this.table,
    required this.highlightedCardIds,
    required this.interactiveCalloutLabel,
    required this.onBoardCardTap,
    this.onChooseSeat,
    this.visualVariant = Act0ShellTableVisualVariantV1.classic,
    this.showFocusBadge = true,
    this.showRepairCallout = true,
    this.playbackActiveSeatId,
    this.animateBetMotion = false,
    this.betOverride,
    this.centerLabelOverride,
    this.potLabelOverride,
    this.toCallLabelOverride,
    this.streetLabelOverride,
    this.completionSummary,
    this.selectedSeatId,
    this.selectedSeatFeedbackState = _SeatSelectionFeedbackStateV1.none,
    this.compactBottomDockClearance = false,
    required this.interactionMode,
    required this.framingProfile,
    required this.viewportFamily,
    this.lateRouteSignal,
    this.identityPolicy = Act0TableIdentityPolicyV1.currentProduction,
    this.maxTableHeight,
    this.cameraStageSize,
    this.lockSharedActiveTableGeometry = false,
    this.integratedPerspectivePrototype = false,
    this.sceneRegistration,
  });

  final Act0SceneRegistrationV1? sceneRegistration;
  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final String interactiveCalloutLabel;
  final ValueChanged<Act0TableStateV1> onBoardCardTap;
  final ValueChanged<String>? onChooseSeat;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool showFocusBadge;
  final bool showRepairCallout;
  final String? playbackActiveSeatId;
  final bool animateBetMotion;
  final Act0SeatBetStateV1? betOverride;
  final String? centerLabelOverride;
  final String? potLabelOverride;
  final String? toCallLabelOverride;
  final String? streetLabelOverride;
  final Act0RunnerCompletionSummaryV1? completionSummary;
  final String? selectedSeatId;
  final _SeatSelectionFeedbackStateV1 selectedSeatFeedbackState;
  final bool compactBottomDockClearance;
  final _RunnerInteractionModeV1 interactionMode;
  final Act0RunnerFramingProfileV1 framingProfile;
  final _RunnerViewportFamilyV1 viewportFamily;
  final Act0LateRouteTableSignalV1? lateRouteSignal;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final double? maxTableHeight;

  /// B7: the exact stage box resolved by [Act0SceneCameraV1].
  ///
  /// When present it replaces every responsive width/aspect negotiation below,
  /// including the state-dependent [maxTableHeight] cap that was the proven
  /// cause of `TABLE_GEOMETRY_STABILITY = NOT_PASSED`, and the environment
  /// plane is owned by the scene box rather than by this table.
  final Size? cameraStageSize;

  final bool lockSharedActiveTableGeometry;

  /// `null` on the non-runner table surface, which has no learning phase and
  /// therefore no state change to communicate.
  final Act0SceneAttentionMotionV1? attention;
  final bool integratedPerspectivePrototype;

  @override
  Widget build(BuildContext context) {
    final registered = sceneRegistration;
    if (registered != null) return _registeredOverlays(context, registered);
    // B6: `null` means this surface has no learning phase, so it renders the
    // settled decision-level scene and never animates.
    final sceneMotion =
        attention ??
        Act0SceneAttentionMotionV1.settled(Act0SceneAttentionPhaseV1.decision);
    final seats = _visualSeatOrder(table.seats);
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final isTablet =
        Act0ShellTokensV1.isTabletWidth(context) &&
        MediaQuery.sizeOf(context).shortestSide >= 600;
    var tableMaxWidth = switch (table.density) {
      Act0TableDensityV1.compactLesson => Act0ShellTokensV1.runnerTableMaxWidth,
      Act0TableDensityV1.handView => Act0ShellTokensV1.handTableMaxWidth,
    };
    if (visualVariant == Act0ShellTableVisualVariantV1.refinedDev2 &&
        table.density == Act0TableDensityV1.compactLesson) {
      tableMaxWidth += 48;
    }
    if (isTablet) {
      tableMaxWidth = switch (table.density) {
        Act0TableDensityV1.compactLesson => refined ? 560 : 520,
        Act0TableDensityV1.handView => refined ? 600 : 560,
      };
    }
    final usesCompactAnswerListComposition =
        !lockSharedActiveTableGeometry &&
        _usesCompactAnswerListCompositionV1(
          context,
          refined: refined,
          isTablet: isTablet,
          viewportFamily: viewportFamily,
          density: table.density,
        );
    tableMaxWidth *= _compactDockTableScaleV1(
      context,
      refined: refined,
      isTablet: isTablet,
      compactBottomDockClearance: compactBottomDockClearance,
      density: table.density,
      compactAnswerListComposition: usesCompactAnswerListComposition,
    );
    if (usesCompactAnswerListComposition && !isTablet) {
      tableMaxWidth = math.max(
        tableMaxWidth,
        MediaQuery.sizeOf(context).width - 16,
      );
    }
    var tableAspect = switch (table.density) {
      Act0TableDensityV1.compactLesson => Act0ShellTokensV1.tableAspect,
      Act0TableDensityV1.handView => Act0ShellTokensV1.handTableAspect,
    };
    if (visualVariant == Act0ShellTableVisualVariantV1.refinedDev2 &&
        table.density == Act0TableDensityV1.compactLesson) {
      tableAspect = lockSharedActiveTableGeometry ? 0.60 : 0.576;
    }
    if (isTablet) {
      tableAspect = switch (table.density) {
        Act0TableDensityV1.compactLesson => refined ? 0.88 : 0.84,
        Act0TableDensityV1.handView => refined ? 0.82 : 0.80,
      };
    }
    if (usesCompactAnswerListComposition) {
      tableAspect = _compactAnswerListStageFillAspectV1;
    }
    final cameraStageSize = this.cameraStageSize;
    final maxTableHeight = this.maxTableHeight;
    if (cameraStageSize != null) {
      tableMaxWidth = cameraStageSize.width;
      tableAspect = cameraStageSize.width / cameraStageSize.height;
    } else if (maxTableHeight != null && maxTableHeight > 0) {
      tableMaxWidth = math.min(tableMaxWidth, maxTableHeight * tableAspect);
    }
    // Canonical scene slots. Seat order and rough placement stay owned by the
    // Wave A slot tables; B1 only resolves how deep each seat is and what
    // volume it reserves for future character art.
    final sceneSeatSlots = act0SceneSeatSlotsV1(
      baseSlots: _seatSlotsForVariant(
        visualVariant,
        compactBottomDockClearance: compactBottomDockClearance,
        useAnswerListPerimeterRing: _viewportFamilyUsesAnswerListCompositionV1(
          viewportFamily,
        ),
      ),
      seatIds: seats.map((seat) => seat.seatId).toList(),
      // `heroSeatId` is optional on the table state and is frequently null, so
      // resolve the hero the same way seat placement does: the seat's own flag
      // first, then the explicit id.
      heroSeatId:
          seats
              .where((seat) => seat.isHero || seat.seatId == table.heroSeatId)
              .firstOrNull
              ?.seatId ??
          table.heroSeatId,
    );
    final inactiveSeatIds = seats
        .where((seat) => seat.isFolded || !seat.isInHand || !seat.isOccupied)
        .map((seat) => seat.seatId)
        .toSet();
    final heroSceneSlot = sceneSeatSlots
        .where((slot) => slot.isHero)
        .firstOrNull;
    final scene = ConstrainedBox(
      key: const Key('act0_shell_table'),
      constraints: BoxConstraints(maxWidth: tableMaxWidth),
      child: AspectRatio(
        aspectRatio: tableAspect,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final baseSeatSlots = _seatSlotsForVariant(
              visualVariant,
              compactBottomDockClearance: compactBottomDockClearance,
              useAnswerListPerimeterRing:
                  _viewportFamilyUsesAnswerListCompositionV1(viewportFamily),
            );
            final baseChipSlots = _chipSlotsForVariant(
              visualVariant,
              compactBottomDockClearance: compactBottomDockClearance,
            );
            final seatSlots = integratedPerspectivePrototype
                ? sceneSeatSlots.map((slot) => slot.plateAnchor).toList()
                : baseSeatSlots;
            // Chip placement keeps exactly the ring Wave A validated. B4 tried
            // moving commitments onto B1's `betAnchor` and the repository's own
            // informative-object guard rejected it: there is no offset from
            // that anchor which clears both the seat's own card+plate column
            // and the board panel. Measured bounds also show the legacy ring
            // already seats each chip immediately beside its owner, so the real
            // gap there was treatment, not position.
            //
            // B7 adds only a separation step, and only under the camera: one
            // canonical table is shorter than the tallest state it replaced, so
            // the same normalized ring resolves to fewer pixels and the chip
            // meets its owner's card+plate column. The ring's topology is
            // untouched.
            final projectedChipSlots = integratedPerspectivePrototype
                ? baseChipSlots
                      .map(Act0ScenePerspectiveV1.canonical.project)
                      .toList()
                : baseChipSlots;
            final commitmentAnchors = integratedPerspectivePrototype
                ? act0SceneCommitmentAnchorsV1(
                    seatSlots: sceneSeatSlots,
                    establishedRing: projectedChipSlots,
                    applyCameraClearance: cameraStageSize != null,
                  )
                : <Act0SceneCommitmentAnchorV1>[
                    for (var i = 0; i < seats.length; i++)
                      Act0SceneCommitmentAnchorV1(
                        seatId: seats[i].seatId,
                        anchor:
                            projectedChipSlots[i.clamp(
                              0,
                              projectedChipSlots.length - 1,
                            )],
                      ),
                  ];
            final activeSeatId = (playbackActiveSeatId ?? '').trim().isNotEmpty
                ? playbackActiveSeatId
                : _resolveActiveSeatId(table);
            final decisionPriceOwnedByTable =
                (toCallLabelOverride ?? table.toCallLabel).trim().isNotEmpty;
            final resolvedSelectedSeatId =
                (selectedSeatId ?? table.selectedSeatId)?.trim();
            final focusResolution = _resolvePrimarySeatFocusV1(
              activeSeatId: activeSeatId,
              highlightedSeatIds: table.highlightedSeatIds,
              selectableSeatIds: table.selectableSeatIds,
              selectedSeatId: resolvedSelectedSeatId,
              selectionFeedbackState: selectedSeatFeedbackState,
            );
            final hasRepairCallout =
                lateRouteSignal == null &&
                showRepairCallout &&
                (table.focusCalloutLabel.isNotEmpty ||
                    interactiveCalloutLabel.isNotEmpty);
            final tableBody = Container(
              key: integratedPerspectivePrototype
                  ? const Key('act0_integrated_scene_perspective_silhouette')
                  : const Key('act0_shell_table_scene'),
              // B2 rail volume. A 10 px band cannot read as a rail on a 290 px
              // table; real rails occupy several percent of the table width.
              // The outer table allocation is unchanged, so Wave A/B1 geometry
              // contracts still hold \u2014 only the felt inset moves.
              padding: EdgeInsets.all(
                integratedPerspectivePrototype ? _act0SceneRailWidthV1 : 10.0,
              ),
              // B2 owns the rail as a physical volume; the material painter
              // behind this container draws its wall, crown, specular and
              // shadows. The flat single-colour band and its neon outline are
              // gone.
              decoration: integratedPerspectivePrototype
                  ? null
                  : Act0ShellTokensV1.tableRimDecoration(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: Act0SceneHybridShellRegistryV1
                          .shellStore
                          .readyNotifier,
                      builder: (context, hybridShellReady, _) => Container(
                        key: const Key('act0_shell_table_felt'),
                        // RENDER_CLASS_HYBRID_INTEGRATION_V1: once the baked
                        // shell is ready its own felt/rail owns this pixel
                        // area, so the procedural felt fill goes transparent
                        // rather than double-painting under the same
                        // dynamic-object geometry.
                        decoration: !integratedPerspectivePrototype
                            ? Act0ShellTokensV1.feltDecoration()
                            : hybridShellReady
                            ? null
                            : ShapeDecoration(
                                gradient: const RadialGradient(
                                  center: Alignment(0, -0.16),
                                  radius: 1.08,
                                  colors: <Color>[
                                    Act0IntegratedSceneFeltV1.centerLit,
                                    Act0IntegratedSceneFeltV1.midLit,
                                    Act0IntegratedSceneFeltV1.edgeDeep,
                                  ],
                                  stops: <double>[0, 0.55, 1],
                                ),
                                shape: const Act0SceneTableShapeV1(),
                              ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable:
                        Act0SceneHybridShellRegistryV1.shellStore.readyNotifier,
                    builder: (context, hybridShellReady, _) =>
                        integratedPerspectivePrototype && !hybridShellReady
                        ? const Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                key: Key('act0_scene_felt_material'),
                                painter: Act0SceneFeltMaterialPainterV1(),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: DecoratedBox(
                        decoration: integratedPerspectivePrototype
                            ? ShapeDecoration(
                                shape: Act0SceneTableShapeV1(
                                  side: BorderSide(
                                    color: Act0ShellTokensV1.feltLine
                                        .withValues(alpha: 0.30),
                                    width: 1,
                                  ),
                                ),
                              )
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.tableInnerRadius,
                                ),
                                border: Border.all(
                                  color: Act0ShellTokensV1.feltLine.withValues(
                                    alpha: 0.30,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: integratedPerspectivePrototype
                            ? ShapeDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Colors.white.withValues(
                                      alpha: refined ? 0.06 : 0.04,
                                    ),
                                    Colors.transparent,
                                    Act0VisualCanonV1.deepNavy.withValues(
                                      alpha: refined ? 0.14 : 0.10,
                                    ),
                                  ],
                                  stops: const <double>[0, 0.34, 1],
                                ),
                                shape: const Act0SceneTableShapeV1(),
                              )
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Act0ShellTokensV1.tableInnerRadius,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Colors.white.withValues(
                                      alpha: refined ? 0.06 : 0.04,
                                    ),
                                    Colors.transparent,
                                    Act0VisualCanonV1.deepNavy.withValues(
                                      alpha: refined ? 0.14 : 0.10,
                                    ),
                                  ],
                                  stops: const <double>[0, 0.34, 1],
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        child: FractionallySizedBox(
                          widthFactor: refined ? 0.56 : 0.52,
                          heightFactor: refined ? 0.20 : 0.18,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Act0ShellTokensV1.radiusPill,
                              ),
                              gradient: RadialGradient(
                                center: const Alignment(0, -0.12),
                                radius: refined ? 1.12 : 1.04,
                                colors: <Color>[
                                  Act0TableFeltCanonV1.feltSoftLift.withValues(
                                    alpha: refined ? 0.10 : 0.08,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const <double>[0, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (heroSceneSlot != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipPath(
                          clipper: const ShapeBorderClipper(
                            shape: Act0SceneTableShapeV1(),
                          ),
                          child: CustomPaint(
                            key: const Key('act0_scene_hero_near_plane'),
                            painter: Act0SceneHeroPlanePainterV1(
                              heroAnchor: heroSceneSlot.plateAnchor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Transform.translate(
                      // The callout owns the upper-center teaching lane; keep
                      // the context/street stack in its reserved middle lane.
                      offset: Offset(0, hasRepairCallout ? height * 0.075 : 0),
                      child: _CenterPotV1(
                        clueMotion: sceneMotion,
                        table: table,
                        highlightedCardIds: highlightedCardIds,
                        onBoardCardTap: () => onBoardCardTap(table),
                        visualVariant: visualVariant,
                        showFocusBadge: showFocusBadge,
                        centerLabelOverride: centerLabelOverride,
                        lateRouteSignal: lateRouteSignal,
                        potLabelOverride: potLabelOverride,
                        toCallLabelOverride: toCallLabelOverride,
                        streetLabelOverride: streetLabelOverride,
                      ),
                    ),
                  ),
                  if (hasRepairCallout)
                    Positioned(
                      key: const Key('act0_shell_table_repair_callout'),
                      left: width * 0.20,
                      right: width * 0.20,
                      // Reserve the upper-center lane for the teaching callout;
                      // the center context/street stack owns the middle lane.
                      top: height * 0.23,
                      child: _TableRepairCalloutV1(
                        label: table.focusCalloutLabel.isNotEmpty
                            ? table.focusCalloutLabel
                            : interactiveCalloutLabel,
                      ),
                    ),
                  if (completionSummary != null)
                    Positioned(
                      key: const Key('act0_shell_completion_reward_lane'),
                      left: width * 0.29,
                      right: width * 0.29,
                      top: height * (refined ? 0.205 : 0.17),
                      child: IgnorePointer(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _CompletionToastV1(
                            summary: completionSummary!,
                            overlayStyle: _CompletionToastOverlayStyleV1.table,
                          ),
                        ),
                      ),
                    ),
                  for (var slot = 0; slot < seats.length; slot++)
                    _BetChipPlacementV1(
                      slot: slot,
                      seat: seats[slot],
                      betOverride: activeSeatId == seats[slot].seatId
                          ? betOverride
                          : null,
                      animateMotion:
                          animateBetMotion &&
                          activeSeatId == seats[slot].seatId &&
                          betOverride != null,
                      tableWidth: width,
                      tableHeight: height,
                      commitmentAnchors: commitmentAnchors,
                      seatSlots: seatSlots,
                      visualVariant: visualVariant,
                    ),
                  for (var slot = 0; slot < seats.length; slot++)
                    _SeatPlacementV1(
                      compactInformativeColumn: cameraStageSize != null,
                      slot: slot,
                      seat: seats[slot],
                      heroCards: table.heroCards,
                      highlightedCardIds: table.highlightedCardIds,
                      active:
                          activeSeatId == seats[slot].seatId &&
                          selectedSeatFeedbackState ==
                              _SeatSelectionFeedbackStateV1.none &&
                          (focusResolution.kind !=
                                  _PrimarySeatFocusKindV1.target ||
                              focusResolution.seatId == seats[slot].seatId),
                      emphasized: table.highlightedSeatIds.contains(
                        seats[slot].seatId,
                      ),
                      hero:
                          seats[slot].isHero ||
                          seats[slot].seatId == table.heroSeatId,
                      selectable: table.selectableSeatIds.contains(
                        seats[slot].seatId,
                      ),
                      decisionPriceOwnedByTable: decisionPriceOwnedByTable,
                      visualState: _resolveSeatVisualStateV1(
                        seatId: seats[slot].seatId,
                        hero:
                            seats[slot].isHero ||
                            seats[slot].seatId == table.heroSeatId,
                        selectable: table.selectableSeatIds.contains(
                          seats[slot].seatId,
                        ),
                        selected: resolvedSelectedSeatId == seats[slot].seatId,
                        selectionFeedbackState: selectedSeatFeedbackState,
                        focusResolution: focusResolution,
                      ),
                      onChooseSeat: onChooseSeat,
                      tableWidth: width,
                      tableHeight: height,
                      seatSlots: seatSlots,
                      visualVariant: visualVariant,
                      identityPolicy: identityPolicy,
                      depthTieredPrototype: integratedPerspectivePrototype,
                    ),
                ],
              ),
            );
            if (!integratedPerspectivePrototype) {
              return tableBody;
            }
            return ValueListenableBuilder<bool>(
              valueListenable:
                  Act0SceneHybridShellRegistryV1.shellStore.readyNotifier,
              builder: (context, hybridShellReady, _) => hybridShellReady
                  // RENDER_CLASS_HYBRID_INTEGRATION_V1: the baked shell
                  // already owns rail volume/material, so the procedural
                  // rail painter is suppressed rather than double-painted
                  // behind it.
                  ? tableBody
                  : CustomPaint(
                      key: const Key('act0_scene_table_material'),
                      painter: const Act0SceneTableMaterialPainterV1(
                        railWidth: _act0SceneRailWidthV1,
                        railOverhang: _act0SceneRailOverhangV1,
                      ),
                      child: tableBody,
                    ),
            );
          },
        ),
      ),
    );
    if (!integratedPerspectivePrototype) {
      return scene;
    }
    // PR #213 / V2_PRODUCTION_SPATIAL_BASELINE: one tiered opponent plane,
    // laid out in a world widened past the felt stage per
    // `Act0SceneTieredSeatingV1`. Instantiated twice \u2014 back plane before the
    // table, front plane after it \u2014 so near-flank bodies are occluded by the
    // felt edge the way the Hero foreground is.
    Widget tieredOpponentPlane(
      Size stageSize,
      Act0SceneTieredPlaneV1 plane,
      Key key,
    ) {
      return ValueListenableBuilder<bool>(
        valueListenable:
            Act0SceneHybridShellRegistryV1.shellStore.readyNotifier,
        builder: (context, hybridShellReady, _) {
          // RENDER_CLASS_HYBRID_INTEGRATION_GAUNTLET_V2: the narrower world
          // box only applies once the hybrid shell owns the visual \u2014 the
          // procedural-table fallback path keeps the original production
          // widen it was tuned against.
          final rules = hybridShellReady
              ? Act0SceneTieredSeatingV1.renderClassHybridV1
              : Act0SceneTieredSeatingV1.production;
          return Positioned(
            left: rules.horizontalInsetFor(stageSize.width),
            right: rules.horizontalInsetFor(stageSize.width),
            top: rules.topInsetFor(stageSize.height),
            bottom: rules.bottomInsetFor(stageSize.height),
            // Opponent art is decorative. Its contact paint can sit above a
            // selectable seat, but must never intercept that seat's pointer.
            child: IgnorePointer(
              child: Act0SceneRecedeMotionV1(
                motion: sceneMotion,
                plane: Act0SceneRecedePlaneV1.player,
                child: Act0SceneTieredOpponentLayerV1(
                  key: key,
                  slots: sceneSeatSlots,
                  plane: plane,
                  foldedSeatIds: inactiveSeatIds,
                  rules: rules,
                ),
              ),
            ),
          );
        },
      );
    }

    // B1 scene assembly. The table keeps every Wave A responsibility; it is
    // now mounted inside a room instead of floating in unowned app space.
    // Painting order is the canonical plane order: environment, grounding,
    // then the table object itself.
    return KeyedSubtree(
      key: const Key('act0_integrated_scene_perspective_table'),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Zero-size marker carrying the resolved B5 phase, so phase
          // separation is provable deterministically rather than by pixels.
          SizedBox.shrink(
            key: Key('act0_scene_attention_phase_${sceneMotion.phase.name}'),
          ),
          // B7: when the camera owns the stage, the room is painted across the
          // whole scene box instead of inside this table's layout rectangle.
          // Scoping the room to the table is why every camera lift in the
          // gauntlet bought flat app background rather than more room.
          if (cameraStageSize == null)
            Positioned.fill(
              child: Act0SceneRecedeMotionV1(
                motion: sceneMotion,
                plane: Act0SceneRecedePlaneV1.room,
                child: IgnorePointer(
                  child: Transform.scale(
                    scaleX: 1.46,
                    scaleY: 1.18,
                    alignment: const Alignment(0, -0.9),
                    child: const Act0SceneRoomPlaneV1(
                      key: Key('act0_scene_environment_plane'),
                    ),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.scale(
                scaleX: 1.10,
                scaleY: 1.05,
                child: const CustomPaint(
                  key: Key('act0_scene_grounding_plane'),
                  painter: Act0SceneGroundingPainterV1(),
                ),
              ),
            ),
          ),
          // PR #213 / V2_PRODUCTION_SPATIAL_BASELINE: on the camera-owned scene
          // path the flat single-plane opponent layer is replaced by the V2
          // tiered layer (back plane here, front plane after `scene`). The
          // `else` branch keeps the pre-existing flat layer for the non-camera
          // preview surface \u2014 it is not an A/B spatial-family switch; there is
          // one production spatial family (V2).
          if (cameraStageSize != null)
            tieredOpponentPlane(
              cameraStageSize,
              Act0SceneTieredPlaneV1.back,
              const Key('act0_scene_player_volume_plane'),
            )
          else
            Positioned.fill(
              child: Act0SceneRecedeMotionV1(
                motion: sceneMotion,
                plane: Act0SceneRecedePlaneV1.player,
                child: Act0ScenePlayerLayerV1(
                  key: const Key('act0_scene_player_volume_plane'),
                  slots: sceneSeatSlots,
                  foldedSeatIds: inactiveSeatIds,
                ),
              ),
            ),
          scene,
          if (cameraStageSize != null)
            tieredOpponentPlane(
              cameraStageSize,
              Act0SceneTieredPlaneV1.front,
              const Key('act0_scene_player_front_plane'),
            ),
          if (heroSceneSlot != null)
            Positioned.fill(
              child: Act0SceneRecedeMotionV1(
                motion: sceneMotion,
                plane: Act0SceneRecedePlaneV1.player,
                child: const Act0ScenePlayerHeroV1(
                  key: Key('act0_scene_hero_foreground_volume'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// F7 changes physical registration only. The existing source seat order,
  /// card widgets, marker policy, focus resolver, commitments and callbacks are
  /// reused. The baked plate owns every person, hand and table contour.
  Widget _registeredOverlays(BuildContext context, Act0SceneRegistrationV1 r) {
    final p = r.profile;
    final seats = _visualSeatOrder(table.seats);
    final active = (playbackActiveSeatId ?? '').trim().isNotEmpty
        ? playbackActiveSeatId
        : _resolveActiveSeatId(table);
    final selected = (selectedSeatId ?? table.selectedSeatId)?.trim();
    final focus = _resolvePrimarySeatFocusV1(
      activeSeatId: active,
      highlightedSeatIds: table.highlightedSeatIds,
      selectableSeatIds: table.selectableSeatIds,
      selectedSeatId: selected,
      selectionFeedbackState: selectedSeatFeedbackState,
    );
    final price = toCallLabelOverride ?? table.toCallLabel;
    final hasPrice = price.trim().isNotEmpty;
    final label = (centerLabelOverride ?? table.centerLabel).trim();
    final repairCallout = table.focusCalloutLabel.isNotEmpty
        ? table.focusCalloutLabel
        : interactiveCalloutLabel;
    final showClue =
        (showFocusBadge || _isSafePriorActionTableCueV1(label)) &&
        label.isNotEmpty &&
        label != 'Blinds posted' &&
        label != 'Action on hero';
    final slots = [
      for (final a in p.seatAnchorsFromHero)
        Offset(r.map(a).dx / r.viewport.width, r.map(a).dy / r.viewport.height),
    ];
    final commitments = [
      for (var i = 0; i < seats.length; i++)
        Act0SceneCommitmentAnchorV1(
          seatId: seats[i].seatId,
          anchor: Offset(
            r.map(p.betAnchorsFromHero[i]).dx / r.viewport.width,
            r.map(p.betAnchorsFromHero[i]).dy / r.viewport.height,
          ),
        ),
    ];
    Widget at(String key, Offset anchor, Widget child) {
      final point = r.map(anchor);
      return Positioned(
        left: point.dx,
        top: point.dy,
        child: FractionalTranslation(
          translation: const Offset(-.5, -.5),
          child: KeyedSubtree(key: Key(key), child: child),
        ),
      );
    }

    Offset holeCardsAnchor(int slot) {
      final anchor = p.holeCardAnchorsFromHero[slot];
      final seat = seats[slot];
      if (seat.isHero ||
          seat.cardsVisibleMode != Act0CardsVisibleModeV1.faceUp) {
        return anchor;
      }
      // Shown hands must clear the rear nameplate and the central price pill.
      // Keep the registered positions of hidden cards and every other overlay.
      return anchor +
          switch (slot) {
            3 => const Offset(0, .028),
            5 when hasPrice => const Offset(.08, -.045),
            _ => Offset.zero,
          };
    }

    Widget cards(Act0SeatStateV1 seat) {
      final hero = seat.isHero;
      final visible = hero ? table.heroCards : seat.holeCards;
      if (visible.isEmpty ||
          (!hero &&
              (!seat.isOccupied ||
                  !seat.isInHand ||
                  seat.isFolded ||
                  seat.cardsVisibleMode == Act0CardsVisibleModeV1.none))) {
        return const SizedBox.shrink();
      }
      final back =
          !hero && seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceDown;
      final width =
          r.destinationRect.width *
          (hero ? p.heroCardWidth : p.opponentCardWidth);
      return Transform.scale(
        scale: width / (back ? 22 : Act0ShellTokensV1.heroCardWidth),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              Transform.rotate(
                angle: hero ? (i == 0 ? -p.heroCardTilt : p.heroCardTilt) : 0,
                child: back
                    ? const _MiniCardBackV1()
                    : _CardV1(
                        card: visible[i],
                        cardId: hero ? 'hero_$i' : '${seat.seatId}_$i',
                        highlighted: highlightedCardIds.contains(
                          hero ? 'hero_$i' : '${seat.seatId}_$i',
                        ),
                      ),
              ),
              if (i < visible.length - 1) const SizedBox(width: 4),
            ],
          ],
        ),
      );
    }

    return Stack(
      key: const Key('act0_f7_dynamic_table'),
      fit: StackFit.expand,
      children: [
        SizedBox.shrink(
          key: Key(
            'act0_scene_attention_phase_${attention?.phase.name ?? 'decision'}',
          ),
        ),
        for (var i = 0; i < seats.length; i++) ...[
          at(
            'act0_f7_hole_cards_${seats[i].seatId}',
            holeCardsAnchor(i),
            cards(seats[i]),
          ),
          _SeatPlacementV1(
            slot: i,
            seat: seats[i],
            heroCards: table.heroCards,
            highlightedCardIds: highlightedCardIds,
            active:
                active == seats[i].seatId &&
                selectedSeatFeedbackState ==
                    _SeatSelectionFeedbackStateV1.none &&
                (focus.kind != _PrimarySeatFocusKindV1.target ||
                    focus.seatId == seats[i].seatId),
            emphasized: table.highlightedSeatIds.contains(seats[i].seatId),
            hero: seats[i].isHero,
            selectable: table.selectableSeatIds.contains(seats[i].seatId),
            visualState: _resolveSeatVisualStateV1(
              seatId: seats[i].seatId,
              hero: seats[i].isHero,
              selectable: table.selectableSeatIds.contains(seats[i].seatId),
              selected: selected == seats[i].seatId,
              selectionFeedbackState: selectedSeatFeedbackState,
              focusResolution: focus,
            ),
            decisionPriceOwnedByTable: hasPrice,
            onChooseSeat: onChooseSeat,
            tableWidth: r.viewport.width,
            tableHeight: r.viewport.height,
            seatSlots: slots,
            visualVariant: visualVariant,
            identityPolicy: identityPolicy,
            showCards: false,
            showDealerMarker: false,
            registeredScene: true,
          ),
          at(
            'act0_f7_dealer_anchor_${seats[i].seatId}',
            p.dealerAnchorsFromHero[i],
            _SeatMarkersV1(
              seatId: seats[i].seatId,
              markers: _resolveSeatMarkerDisplayV1(
                context,
                seat: seats[i],
                active: active == seats[i].seatId,
                hero: seats[i].isHero,
                refined:
                    visualVariant == Act0ShellTableVisualVariantV1.refinedDev2,
                decisionPriceOwnedByTable: hasPrice,
                identityPolicy: identityPolicy,
              ).markers.where((m) => m == _SeatMarkerKindV1.dealer).toList(),
            ),
          ),
          _BetChipPlacementV1(
            slot: i,
            seat: seats[i],
            tableWidth: r.viewport.width,
            tableHeight: r.viewport.height,
            commitmentAnchors: commitments,
            seatSlots: slots,
            visualVariant: visualVariant,
            animateMotion: animateBetMotion && active == seats[i].seatId,
            betOverride: active == seats[i].seatId ? betOverride : null,
          ),
        ],
        if (table.boardCards.isNotEmpty)
          at(
            'act0_f7_board',
            p.boardAnchor,
            Transform.scale(
              scale:
                  r.destinationRect.width *
                  p.boardCardWidth /
                  Act0ShellTokensV1.boardCardWidth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The profile anchor owns the complete physical board.
                  // Invisible future slots preserve prior cards' transforms
                  // when a new source card appears on the turn or river.
                  for (var i = 0; i < 5; i++) ...[
                    KeyedSubtree(
                      key: Key('act0_f7_board_slot_$i'),
                      child: i < table.boardCards.length
                          ? _BoardCardV1(
                              card: table.boardCards[i],
                              cardId: 'board_$i',
                              highlighted: highlightedCardIds.contains(
                                'board_$i',
                              ),
                              onTap: () => onBoardCardTap(table),
                            )
                          : const SizedBox(
                              width: Act0ShellTokensV1.boardCardWidth,
                              height: Act0ShellTokensV1.boardCardHeight,
                            ),
                    ),
                    if (i < 4) const SizedBox(width: 5),
                  ],
                ],
              ),
            ),
          ),
        at(
          'act0_f7_street',
          p.streetAnchor,
          _CenterStreetStatusV1(
            label: act0RuntimeLocalizedStreetLabelV1(
              context,
              streetLabelOverride ?? table.streetLabel,
            ).toUpperCase(),
            compact: true,
          ),
        ),
        at(
          'act0_f7_pot_price',
          p.potAnchor,
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: r.destinationRect.width * (hasPrice ? .60 : .23),
            ),
            // The fixed rail between board and hero has room for one row.
            // Allow long values to wrap within their own pill.
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: _CenterPriorityStatV1(
                    key: const Key('act0_shell_wave1_pot_priority_stat'),
                    legacyKey: const Key('act0_shell_center_pot_stat'),
                    label: act0RuntimeLocalizedPotLabelV1(
                      context,
                      potLabelOverride ?? table.potLabel,
                    ),
                    tone: Act0ShellTokensV1.gold,
                    compact: true,
                    pulse: table.actionTrail.isNotEmpty,
                  ),
                ),
                if (hasPrice) ...[
                  const SizedBox(width: 5),
                  Flexible(
                    child: _CenterPriorityStatV1(
                      key: const Key('act0_shell_wave1_price_priority_stat'),
                      legacyKey: const Key('act0_shell_center_to_call_stat'),
                      label: act0RuntimeLocalizedToCallLabelV1(context, price),
                      tone: Act0ShellTokensV1.info,
                      compact: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (completionSummary != null)
          at(
            'act0_shell_completion_reward_lane',
            p.clueAnchor,
            _CompletionToastV1(
              summary: completionSummary!,
              overlayStyle: _CompletionToastOverlayStyleV1.table,
            ),
          )
        else if (lateRouteSignal != null ||
            showClue ||
            (showRepairCallout && repairCallout.isNotEmpty))
          at(
            'act0_f7_clue',
            p.clueAnchor,
            SizedBox(
              width: r.destinationRect.width * .245,
              child: lateRouteSignal != null
                  ? _LateRouteCenterSignalV1(signal: lateRouteSignal!)
                  : _CenterSignalAnchorV1(
                      label: act0RuntimeLocalizedCenterLabelV1(
                        context,
                        showRepairCallout && repairCallout.isNotEmpty
                            ? repairCallout
                            : label,
                      ),
                      compact: true,
                      clueMotion: attention,
                    ),
            ),
          ),
      ],
    );
  }

  String? _resolveActiveSeatId(Act0TableStateV1 table) {
    final explicitRaw = table.activeSeatId;
    if (explicitRaw != null) {
      final explicit = explicitRaw.trim();
      return explicit.isEmpty ? null : explicit;
    }
    for (final seat in table.seats) {
      if (seat.isActive) {
        return seat.seatId;
      }
    }
    return null;
  }
}

class _TableRepairCalloutV1 extends StatelessWidget {
  const _TableRepairCalloutV1({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: Act0ShellTokensV1.onFeltPanelDecoration(
          radius: Act0ShellTokensV1.radiusPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flag_rounded,
              key: Key('act0_shell_table_repair_callout_icon'),
              size: 13,
              color: Act0TableFeltCanonV1.innerHairline,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                key: const Key('act0_shell_table_repair_callout_text'),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.fade,
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.text,
                  fontSize: 9.4,
                  letterSpacing: 0,
                  height: 1.08,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double _compactDockTableScaleV1(
  BuildContext context, {
  required bool refined,
  required bool isTablet,
  required bool compactBottomDockClearance,
  required Act0TableDensityV1 density,
  required bool compactAnswerListComposition,
}) {
  const compactSafeAreaTableScale = 0.832;
  const compactAnswerListSafeAreaTableScale = 0.917;
  if (!refined ||
      isTablet ||
      !compactBottomDockClearance ||
      density != Act0TableDensityV1.compactLesson) {
    return 1;
  }

  final media = MediaQuery.of(context);
  final hasSystemBottomInset = media.viewPadding.bottom > 0;
  final isCompactPortrait =
      media.size.width < media.size.height && media.size.height <= 900;
  if (!hasSystemBottomInset || !isCompactPortrait) {
    return 1;
  }

  return compactAnswerListComposition
      ? compactAnswerListSafeAreaTableScale
      : compactSafeAreaTableScale;
}

bool _usesCompactAnswerListCompositionV1(
  BuildContext context, {
  required bool refined,
  required bool isTablet,
  required _RunnerViewportFamilyV1 viewportFamily,
  required Act0TableDensityV1 density,
}) {
  if (!refined ||
      isTablet ||
      !_viewportFamilyUsesAnswerListCompositionV1(viewportFamily) ||
      density != Act0TableDensityV1.compactLesson) {
    return false;
  }

  return _stableViewportPressureReasonV1(
        context,
        viewportFamily: viewportFamily,
      ) !=
      _compactAnswerListNoPressureReasonV1;
}

bool _usesCompactAnswerListDockV1(
  BuildContext context, {
  required _RunnerInteractionModeV1 interactionMode,
  required Act0RunnerFramingProfileV1 framingProfile,
}) {
  return _compactAnswerListPressureReasonV1(
        context,
        interactionMode: interactionMode,
        framingProfile: framingProfile,
      ) !=
      _compactAnswerListNoPressureReasonV1;
}

bool _usesCompactAnswerListLeafFallbackV1(BuildContext context) {
  final media = MediaQuery.of(context);
  return media.size.width < media.size.height && media.size.height <= 900;
}

bool _viewportFamilyUsesAnswerListCompositionV1(
  _RunnerViewportFamilyV1 viewportFamily,
) {
  return switch (viewportFamily) {
    _RunnerViewportFamilyV1.answerListBoardHeroPot ||
    _RunnerViewportFamilyV1.answerListHeroAction => true,
    _RunnerViewportFamilyV1.tableTapSeatFocus ||
    _RunnerViewportFamilyV1.neutral => false,
  };
}

String _stableViewportPressureReasonV1(
  BuildContext context, {
  required _RunnerViewportFamilyV1 viewportFamily,
}) {
  return switch (viewportFamily) {
    _RunnerViewportFamilyV1.answerListBoardHeroPot =>
      _compactAnswerListPressureReasonV1(
        context,
        interactionMode: _RunnerInteractionModeV1.answerListDecision,
        framingProfile: Act0RunnerFramingProfileV1.boardHeroPot,
      ),
    _RunnerViewportFamilyV1.answerListHeroAction =>
      _compactAnswerListPressureReasonV1(
        context,
        interactionMode: _RunnerInteractionModeV1.answerListDecision,
        framingProfile: Act0RunnerFramingProfileV1.heroAction,
      ),
    _RunnerViewportFamilyV1.tableTapSeatFocus ||
    _RunnerViewportFamilyV1.neutral => _compactAnswerListNoPressureReasonV1,
  };
}

const String _compactAnswerListNoPressureReasonV1 = 'none';
const String _compactAnswerListTableDockPressureReasonV1 = 'tableDockPressure';
const double _compactAnswerListPhoneMaxShortestSideV1 = 600;
const double _compactAnswerListUsableHeightBudgetV1 = 900;
const double _compactAnswerListStageFillAspectV1 = 0.66;
const double _runnerProgressRowHeightV1 = 34;
const double _runnerEnvelopeWave1bMinLowerSlotHeightV1 = 365;
const double _runnerEnvelopeWave1bTargetLowerSlotHeightV1 = 405;
const double _runnerEnvelopeWave1bTargetLowerSlotShareV1 = 0.50;
const double _runnerEnvelopeWave1bMaxLowerSlotShareV1 = 0.54;
const double _runnerShortAnswerEnvelopeMinLowerSlotHeightV1 = 300;
const double _runnerShortAnswerEnvelopeTargetLowerSlotHeightV1 = 320;
const double _runnerShortAnswerEnvelopeMaxLowerSlotShareV1 = 0.47;
const double _runnerRepairEnvelopeMinLowerSlotHeightV1 = 320;
const double _runnerRepairEnvelopeTargetLowerSlotHeightV1 = 420;
const double _runnerRepairEnvelopeTargetLowerSlotShareV1 = 0.40;
const double _runnerRepairEnvelopeMaxLowerSlotShareV1 = 0.46;
// The miss/repair header is part of the learning proof, not expendable scroll
// content. Reserve enough of a compact phone for it to clear the table seam
// while keeping the action CTA in the same viewport.
const double _runnerRepairFeedbackDockMinLowerSlotHeightV1 = 360;
const double _runnerRepairFeedbackDockTargetLowerSlotHeightV1 = 420;
const double _runnerRepairFeedbackDockTargetLowerSlotShareV1 = 0.40;
const double _runnerRepairFeedbackDockMaxLowerSlotShareV1 = 0.52;
const double _runnerCompactSeatTapMinLowerSlotHeightV1 = 220;
const double _runnerCompactSeatTapTargetLowerSlotHeightV1 = 248;
const double _runnerCompactSeatTapMaxLowerSlotShareV1 = 0.38;
const double _runnerCompactFeedbackMinLowerSlotHeightV1 = 240;

String _compactAnswerListPressureReasonV1(
  BuildContext context, {
  required _RunnerInteractionModeV1 interactionMode,
  required Act0RunnerFramingProfileV1 framingProfile,
}) {
  if (interactionMode != _RunnerInteractionModeV1.answerListDecision) {
    return _compactAnswerListNoPressureReasonV1;
  }
  if (!_answerListProfileNeedsProtectedTableV1(framingProfile)) {
    return _compactAnswerListNoPressureReasonV1;
  }

  final media = MediaQuery.of(context);
  final isPortrait = media.size.width < media.size.height;
  final isPhoneWidth =
      media.size.shortestSide <= _compactAnswerListPhoneMaxShortestSideV1;
  if (!isPortrait || !isPhoneWidth) {
    return _compactAnswerListNoPressureReasonV1;
  }

  final view = View.maybeOf(context);
  final viewPaddingVertical = view == null
      ? 0.0
      : (view.viewPadding.top + view.viewPadding.bottom) /
            view.devicePixelRatio;
  final safeAreaVertical = <double>[
    media.viewPadding.top + media.viewPadding.bottom,
    media.padding.top + media.padding.bottom,
    viewPaddingVertical,
  ].reduce((value, element) => value > element ? value : element);
  final usableHeight = media.size.height - safeAreaVertical;
  if (usableHeight <= _compactAnswerListUsableHeightBudgetV1) {
    return _compactAnswerListTableDockPressureReasonV1;
  }
  return _compactAnswerListNoPressureReasonV1;
}

bool _usesShortSafeCompactAnswerListEnvelopeV1(
  BuildContext context, {
  required List<Act0RunnerOptionV1> options,
}) {
  if (options.length != 4) {
    return false;
  }
  return options.every((option) {
    final label = act0RuntimeLocalizedOptionLabelV1(
      context,
      option.label,
    ).trim();
    return option.amountLabel.trim().isEmpty && label.length <= 36;
  });
}

bool _answerListProfileNeedsProtectedTableV1(
  Act0RunnerFramingProfileV1 framingProfile,
) {
  return switch (framingProfile) {
    Act0RunnerFramingProfileV1.boardHeroPot ||
    Act0RunnerFramingProfileV1.boardOnly ||
    Act0RunnerFramingProfileV1.heroAction ||
    Act0RunnerFramingProfileV1.seatFocus => true,
    Act0RunnerFramingProfileV1.neutral => false,
  };
}

class _DockBackButtonV1 extends StatelessWidget {
  const _DockBackButtonV1({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: Act0ShellTokensV1.quietButtonStyle().copyWith(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          side: WidgetStatePropertyAll(
            BorderSide(color: Act0ShellTokensV1.border.withValues(alpha: 0.82)),
          ),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
      ),
    );
  }
}

List<Offset> _seatSlotsForVariant(
  Act0ShellTableVisualVariantV1 variant, {
  bool compactBottomDockClearance = false,
  bool useAnswerListPerimeterRing = false,
}) {
  switch (variant) {
    case Act0ShellTableVisualVariantV1.classic:
      return _SeatPlacementV1.defaultSlots;
    case Act0ShellTableVisualVariantV1.refinedDev2:
      if (compactBottomDockClearance) {
        final heroY = useAnswerListPerimeterRing ? 0.86 : 0.80;
        return <Offset>[
          Offset(0.47, heroY),
          Offset(0.08, 0.69),
          Offset(0.08, 0.31),
          Offset(0.47, 0.06),
          Offset(0.86, 0.31),
          Offset(0.86, 0.69),
        ];
      }
      return const <Offset>[
        Offset(0.50, 0.91),
        Offset(0.12, 0.75),
        Offset(0.12, 0.33),
        Offset(0.50, 0.12),
        Offset(0.88, 0.33),
        Offset(0.88, 0.75),
      ];
  }
}

List<Offset> _chipSlotsForVariant(
  Act0ShellTableVisualVariantV1 variant, {
  bool compactBottomDockClearance = false,
}) {
  switch (variant) {
    case Act0ShellTableVisualVariantV1.classic:
      return _BetChipPlacementV1.defaultChipSlots;
    case Act0ShellTableVisualVariantV1.refinedDev2:
      if (compactBottomDockClearance) {
        return const <Offset>[
          Offset(0.50, 0.62),
          Offset(0.067, 0.55),
          Offset(0.087, 0.45),
          Offset(0.50, 0.29),
          Offset(0.80, 0.39),
          Offset(0.84, 0.59),
        ];
      }
      return const <Offset>[
        Offset(0.50, 0.71),
        Offset(0.24, 0.64),
        Offset(0.26, 0.30),
        Offset(0.50, 0.29),
        Offset(0.74, 0.30),
        Offset(0.76, 0.64),
      ];
  }
}

List<Act0SeatStateV1> _visualSeatOrder(List<Act0SeatStateV1> seats) {
  final canonicalOrder = _inferCanonicalSeatOrder(seats);
  final byLabel = <String, Act0SeatStateV1>{
    for (final seat in seats) seat.seatLabel.toUpperCase(): seat,
  };
  final hero = seats.where((seat) => seat.isHero).toList(growable: false);
  final heroLabel = hero.isEmpty
      ? canonicalOrder.first
      : hero.first.seatLabel.toUpperCase();
  final heroIndex = canonicalOrder.indexOf(heroLabel);
  final start = heroIndex < 0 ? 0 : heroIndex;
  final canonicalSeats = <Act0SeatStateV1>[
    for (var i = 0; i < canonicalOrder.length; i++)
      if (byLabel[canonicalOrder[(start + i) % canonicalOrder.length]] != null)
        byLabel[canonicalOrder[(start + i) % canonicalOrder.length]]!,
  ];
  if (canonicalSeats.isEmpty) {
    final others = seats.where((seat) => !seat.isHero).toList(growable: false);
    return <Act0SeatStateV1>[...hero, ...others];
  }
  final canonicalIds = canonicalSeats.map((seat) => seat.seatId).toSet();
  return <Act0SeatStateV1>[
    ...canonicalSeats,
    for (final seat in seats)
      if (!canonicalIds.contains(seat.seatId)) seat,
  ];
}

List<String> _inferCanonicalSeatOrder(List<Act0SeatStateV1> seats) {
  final labels = seats.map((seat) => seat.seatLabel.toUpperCase()).toSet();
  for (final format in Act0TableFormatV1.values) {
    final order = act0CanonicalSeatOrderForFormatV1(format);
    if (labels.every(order.contains)) {
      return order;
    }
  }
  return act0CanonicalSeatOrderForFormatV1(Act0TableFormatV1.sixMax);
}

class _CenterPotV1 extends StatelessWidget {
  const _CenterPotV1({
    this.clueMotion,
    required this.table,
    required this.highlightedCardIds,
    required this.onBoardCardTap,
    required this.visualVariant,
    this.showFocusBadge = true,
    this.centerLabelOverride,
    this.lateRouteSignal,
    this.potLabelOverride,
    this.toCallLabelOverride,
    this.streetLabelOverride,
  });

  final Act0TableStateV1 table;
  final List<String> highlightedCardIds;
  final VoidCallback onBoardCardTap;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool showFocusBadge;
  final String? centerLabelOverride;
  final Act0LateRouteTableSignalV1? lateRouteSignal;
  final String? potLabelOverride;
  final String? toCallLabelOverride;
  final String? streetLabelOverride;

  /// B6: drives B4's bracket through the in-flight attention interpolation.
  /// `null` on surfaces with no learning phase, which keep B4's always-on
  /// bracket.
  final Act0SceneAttentionMotionV1? clueMotion;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final resolvedCenterLabel = (centerLabelOverride ?? table.centerLabel)
        .trim();
    final shouldShowFocusBadge =
        (showFocusBadge || _isSafePriorActionTableCueV1(resolvedCenterLabel)) &&
        resolvedCenterLabel.isNotEmpty &&
        !(refined &&
            (resolvedCenterLabel == 'Blinds posted' ||
                resolvedCenterLabel == 'Action on hero'));
    final streetLabel = act0RuntimeLocalizedStreetLabelV1(
      context,
      streetLabelOverride ?? table.streetLabel,
    ).toUpperCase();
    final resolvedToCallLabel = (toCallLabelOverride ?? table.toCallLabel)
        .trim();
    final usesCompactCenterSafeLane =
        refined && table.density == Act0TableDensityV1.compactLesson;
    final centerCard = Container(
      key: const Key('act0_shell_center_info_card'),
      width: refined ? 182 : Act0ShellTokensV1.centerInfoWidth,
      padding: EdgeInsets.symmetric(
        horizontal: refined ? 6 : 4,
        vertical: refined ? 4 : 3,
      ),
      // B7: no panel. The board is the primary poker object and it sits on the
      // felt, not inside a card. Metadata around it is carried by the objects
      // themselves (an engraved pot plaque, an incised street mark), so the
      // centre stops reading as app UI dropped into the table.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            key: const Key('act0_shell_wave1_status_cluster'),
            mainAxisSize: MainAxisSize.min,
            children: [
              if (usesCompactCenterSafeLane)
                Column(
                  key: const Key('act0_shell_wave1b_status_lane'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (lateRouteSignal != null) ...[
                      _LateRouteCenterSignalV1(signal: lateRouteSignal!),
                    ] else if (shouldShowFocusBadge) ...[
                      _CenterSignalAnchorV1(
                        label: act0RuntimeLocalizedCenterLabelV1(
                          context,
                          resolvedCenterLabel,
                        ),
                        compact: refined,
                        clueMotion: clueMotion,
                      ),
                    ],
                    const SizedBox(height: 3),
                    _CenterStreetStatusV1(label: streetLabel, compact: refined),
                  ],
                )
              else
                Wrap(
                  key: const Key('act0_shell_wave1b_status_lane'),
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 5,
                  runSpacing: 3,
                  children: [
                    if (lateRouteSignal != null) ...[
                      _LateRouteCenterSignalV1(signal: lateRouteSignal!),
                    ] else if (shouldShowFocusBadge) ...[
                      _CenterSignalAnchorV1(
                        label: act0RuntimeLocalizedCenterLabelV1(
                          context,
                          resolvedCenterLabel,
                        ),
                        compact: refined,
                        clueMotion: clueMotion,
                      ),
                    ],
                    _CenterStreetStatusV1(label: streetLabel, compact: refined),
                  ],
                ),
            ],
          ),
          if (table.boardCards.isNotEmpty) ...[
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < table.boardCards.length; i++) ...[
                    _BoardCardV1(
                      card: table.boardCards[i],
                      cardId: 'board_$i',
                      highlighted: highlightedCardIds.contains('board_$i'),
                      onTap: onBoardCardTap,
                    ),
                    if (i < table.boardCards.length - 1)
                      const SizedBox(width: 5),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 3,
            children: [
              _CenterPriorityStatV1(
                key: const Key('act0_shell_wave1_pot_priority_stat'),
                legacyKey: const Key('act0_shell_center_pot_stat'),
                label: act0RuntimeLocalizedPotLabelV1(
                  context,
                  potLabelOverride ?? table.potLabel,
                ),
                tone: Act0ShellTokensV1.gold,
                compact: refined,
                pulse: table.actionTrail.isNotEmpty,
              ),
              if (resolvedToCallLabel.isNotEmpty)
                _CenterPriorityStatV1(
                  key: const Key('act0_shell_wave1_price_priority_stat'),
                  legacyKey: const Key('act0_shell_center_to_call_stat'),
                  label: act0RuntimeLocalizedToCallLabelV1(
                    context,
                    resolvedToCallLabel,
                  ),
                  tone: Act0ShellTokensV1.info,
                  compact: refined,
                ),
            ],
          ),
        ],
      ),
    );

    return Center(child: centerCard);
  }
}

class _LateRouteCenterSignalV1 extends StatelessWidget {
  const _LateRouteCenterSignalV1({required this.signal});

  final Act0LateRouteTableSignalV1 signal;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_late_route_table_signal'),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.34),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(signal.icon, size: 11, color: Act0ShellTokensV1.gold),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              signal.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.gold,
                fontSize: 8.5,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterSignalAnchorV1 extends StatelessWidget {
  const _CenterSignalAnchorV1({
    this.clueMotion,
    required this.label,
    required this.compact,
  });

  final String label;
  final bool compact;

  /// B5 drives B4's bracket. It shipped always-on, so it carried no state
  /// information and persisted into recheck as a standing pointer.
  ///
  /// B6 lets that emphasis *arrive* rather than cut: the bracket fades up as
  /// the verdict becomes current, and re-asserts for repair reacquisition. It
  /// is released instantly \u2014 never faded \u2014 on entering recheck, so no clue is
  /// ever animating during a recognition attempt.
  final Act0SceneAttentionMotionV1? clueMotion;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('act0_shell_wave1_table_signal_anchor'),
      child: Tooltip(
        message: 'Table clue',
        // B4: Wave A already decides this is the causal table clue and already
        // says so in copy. What it lacked was a mark that visibly belongs to
        // this exact object. Brackets clamp to its own corners, so "the clue is
        // marked on the table" now has something to point at. Local and
        // object-bound only \u2014 no dimming, no blur, no scene-wide treatment.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              key: const Key('act0_shell_wave1b_table_signal_chip'),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 7 : 9,
                vertical: compact ? 3.5 : 4.5,
              ),
              decoration: BoxDecoration(
                color: Act0ShellTokensV1.primary.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(
                  Act0ShellTokensV1.radiusPill,
                ),
                border: Border.all(
                  color: Act0ShellTokensV1.primary.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      // Compact seats leave a fixed center lane between BB and HJ.
                      // The full two-line label owns that lane; the decorative eye
                      // did not, and was pushing the chip into both seat cards.
                      constraints: BoxConstraints(maxWidth: compact ? 80 : 118),
                      child: Text(
                        label,
                        key: const Key('act0_shell_wave1b_table_signal_text'),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontSize: compact ? 8.8 : 9.6,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    key: Key('act0_shell_center_focus_badge'),
                    width: 0,
                    height: 0,
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: clueMotion?.progress ?? kAlwaysCompleteAnimation,
                  builder: (context, _) {
                    final emphasis = (clueMotion?.current.clueEmphasis ?? 1.0)
                        .clamp(0.0, 1.0);
                    if (emphasis <= 0.02) return const SizedBox.shrink();
                    return CustomPaint(
                      key: const Key('act0_scene_clue_bracket_signal'),
                      painter: Act0SceneClueBracketPainterV1(
                        tone: Act0ShellTokensV1.gold.withValues(
                          alpha: emphasis,
                        ),
                        inset: -2.0,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterStreetStatusV1 extends StatelessWidget {
  const _CenterStreetStatusV1({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_center_street_badge'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 2 : 3,
        vertical: compact ? 1 : 1.5,
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.62),
          fontSize: compact ? 7.8 : 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _CenterPriorityStatV1 extends StatelessWidget {
  const _CenterPriorityStatV1({
    super.key,
    required this.legacyKey,
    required this.label,
    required this.tone,
    required this.compact,
    this.pulse = false,
  });

  final Key legacyKey;
  final String label;
  final Color tone;
  final bool compact;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final stat = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: Act0SceneNameplateV1.decoration(
        radius: Act0ShellTokensV1.radiusPill,
        stateTone: tone,
        stateStrength: 0.55,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.text,
                fontSize: compact ? 9.6 : 10.4,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
    final keyedStat = KeyedSubtree(key: legacyKey, child: stat);
    if (!pulse) {
      return keyedStat;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.97, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: keyedStat,
    );
  }
}

class _BetChipPlacementV1 extends StatelessWidget {
  const _BetChipPlacementV1({
    required this.slot,
    required this.seat,
    required this.tableWidth,
    required this.tableHeight,
    required this.commitmentAnchors,
    required this.seatSlots,
    required this.visualVariant,
    required this.animateMotion,
    this.betOverride,
  });

  final int slot;
  final Act0SeatStateV1 seat;
  final double tableWidth;
  final double tableHeight;
  final List<Act0SceneCommitmentAnchorV1> commitmentAnchors;
  final List<Offset> seatSlots;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final bool animateMotion;

  /// When non-null, shown instead of seat.bet (used during action trail playback).
  final Act0SeatBetStateV1? betOverride;

  static const List<Offset> defaultChipSlots = <Offset>[
    Offset(0.50, 0.75),
    Offset(0.055, 0.60),
    Offset(0.055, 0.50),
    Offset(0.50, 0.25),
    Offset(0.945, 0.50),
    Offset(0.945, 0.60),
  ];

  @override
  Widget build(BuildContext context) {
    final bet = betOverride ?? seat.bet;
    if (bet == null || seat.isFolded) {
      return const SizedBox.shrink();
    }
    final commitment = commitmentAnchors.firstWhere(
      (anchor) => anchor.seatId == seat.seatId,
      orElse: () =>
          commitmentAnchors[slot.clamp(0, commitmentAnchors.length - 1)],
    );
    final chipPoint = commitment.anchor;
    final safeSlot = slot.clamp(0, seatSlots.length - 1);
    final seatPoint = seatSlots[safeSlot.clamp(0, seatSlots.length - 1)];
    final child = KeyedSubtree(
      key: Key('act0_shell_bet_chip_owner_${seat.seatId}'),
      child: _BetChipV1(
        bet: bet,
        compact: visualVariant == Act0ShellTableVisualVariantV1.refinedDev2,
      ),
    );
    if (!animateMotion) {
      return Positioned(
        left: tableWidth * chipPoint.dx,
        top: tableHeight * chipPoint.dy,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: IgnorePointer(child: child),
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      key: Key('act0_shell_bet_chip_motion_${seat.seatId}_${bet.label}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: _chipMotionDuration(bet.kind),
      curve: bet.kind == Act0SeatBetKindV1.post
          ? Curves.easeInOutCubic
          : Curves.easeOutCubic,
      builder: (context, value, child) {
        final point = Offset.lerp(seatPoint, chipPoint, value) ?? chipPoint;
        return Positioned(
          left: tableWidth * point.dx,
          top: tableHeight * point.dy,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: IgnorePointer(
              child: Transform.scale(
                scale: 0.94 + (0.06 * value),
                child: Opacity(opacity: 0.72 + (0.28 * value), child: child),
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }

  Duration _chipMotionDuration(Act0SeatBetKindV1 kind) {
    return switch (kind) {
      Act0SeatBetKindV1.post => const Duration(milliseconds: 380),
      Act0SeatBetKindV1.call => const Duration(milliseconds: 360),
      Act0SeatBetKindV1.bet ||
      Act0SeatBetKindV1.raise ||
      Act0SeatBetKindV1.allIn => const Duration(milliseconds: 440),
    };
  }
}

class _SeatPlacementV1 extends StatelessWidget {
  const _SeatPlacementV1({
    required this.slot,
    required this.seat,
    required this.heroCards,
    required this.highlightedCardIds,
    required this.active,
    required this.emphasized,
    required this.hero,
    required this.selectable,
    required this.visualState,
    required this.decisionPriceOwnedByTable,
    required this.onChooseSeat,
    required this.tableWidth,
    required this.tableHeight,
    required this.seatSlots,
    required this.visualVariant,
    this.identityPolicy = Act0TableIdentityPolicyV1.currentProduction,
    this.depthTieredPrototype = false,
    this.compactInformativeColumn = false,
    this.showCards = true,
    this.showDealerMarker = true,
    this.registeredScene = false,
  });

  final int slot;
  final Act0SeatStateV1 seat;
  final List<Act0CardStateV1> heroCards;
  final List<String> highlightedCardIds;
  final bool active;
  final bool emphasized;
  final bool hero;
  final bool selectable;
  final _SeatVisualStateV1 visualState;
  final bool decisionPriceOwnedByTable;
  final ValueChanged<String>? onChooseSeat;
  final double tableWidth;
  final double tableHeight;
  final List<Offset> seatSlots;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final bool depthTieredPrototype;
  final bool compactInformativeColumn;
  final bool showCards, showDealerMarker, registeredScene;

  static const List<Offset> defaultSlots = <Offset>[
    Offset(0.50, 0.90),
    Offset(0.08, 0.72),
    Offset(0.06, 0.36),
    Offset(0.50, 0.08),
    Offset(0.94, 0.36),
    Offset(0.92, 0.72),
  ];

  @override
  Widget build(BuildContext context) {
    final point = seatSlots[slot.clamp(0, seatSlots.length - 1)];
    // Plate depth comes from the one canonical projection. Its range stays
    // narrow on purpose: plates carry text, so the scene's depth is carried by
    // the character volumes instead.
    final tierScale = !depthTieredPrototype
        ? 1.0
        : Act0ScenePerspectiveV1.canonical.plateScaleAt(point.dy);
    // The registered hero cards are painted separately from the seat node.
    // Clear their lower edge without moving the cards or the image anchors.
    final heroNameplateClearance = registeredScene && hero ? 8.0 : 0.0;
    return Positioned(
      left: tableWidth * point.dx,
      top: tableHeight * point.dy + heroNameplateClearance,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.scale(
          key: Key(
            'act0_integrated_scene_depth_'
            '${act0SceneDepthTierV1(point.dy)}_${seat.seatId}',
          ),
          scale: tierScale,
          child: _SeatNodeV1(
            showCards: showCards,
            showDealerMarker: showDealerMarker,
            registeredScene: registeredScene,
            compactInformativeColumn: compactInformativeColumn,
            seat: seat,
            heroCards: heroCards,
            highlightedCardIds: highlightedCardIds,
            active: active,
            emphasized: emphasized,
            hero: hero,
            selectable: selectable,
            visualState: visualState,
            decisionPriceOwnedByTable: decisionPriceOwnedByTable,
            visualVariant: visualVariant,
            identityPolicy: identityPolicy,
            onTap: selectable && onChooseSeat != null
                ? () => onChooseSeat!(seat.seatId)
                : null,
            compact: slot != 0,
          ),
        ),
      ),
    );
  }
}
