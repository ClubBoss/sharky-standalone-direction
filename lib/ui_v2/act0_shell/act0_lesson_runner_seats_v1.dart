part of 'act0_lesson_runner_shell_v1.dart';

class _SeatNodeV1 extends StatelessWidget {
  const _SeatNodeV1({
    required this.seat,
    required this.heroCards,
    required this.highlightedCardIds,
    required this.active,
    required this.emphasized,
    required this.hero,
    required this.selectable,
    required this.visualState,
    required this.decisionPriceOwnedByTable,
    required this.visualVariant,
    this.identityPolicy = Act0TableIdentityPolicyV1.currentProduction,
    this.onTap,
    this.compact = false,
    this.compactInformativeColumn = false,
    this.showCards = true,
    this.showDealerMarker = true,
    this.registeredScene = false,
  });

  final Act0SeatStateV1 seat;
  final List<Act0CardStateV1> heroCards;
  final List<String> highlightedCardIds;
  final bool active;
  final bool emphasized;
  final bool hero;
  final bool selectable;
  final _SeatVisualStateV1 visualState;
  final bool decisionPriceOwnedByTable;
  final Act0ShellTableVisualVariantV1 visualVariant;
  final Act0TableIdentityPolicyV1 identityPolicy;
  final VoidCallback? onTap;
  final bool compact;

  /// B7: the camera-owned scene resolves one table for every state, and that
  /// table is shorter than the tallest state it replaced. The seat's own
  /// informative column \u2014 cards, the gap under them, the plate's internal
  /// padding \u2014 was sized against the taller table and now saturates the flank,
  /// leaving no room between a seat and its own commitment. This trims the
  /// column's dead vertical space only. No type size, no plate width, no
  /// content changes.
  final bool compactInformativeColumn;
  final bool showCards, showDealerMarker, registeredScene;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    // Dead vertical space in the seat's informative column, trimmed under the
    // camera. Cards keep their size and the plate keeps its type and width.
    final double cardPlateGap = compactInformativeColumn ? 1 : 3;
    final double plateVerticalPad = compactInformativeColumn ? 2 : 0;
    final seatVisualState = visualState;
    final markerDisplay = _resolveSeatMarkerDisplayV1(
      context,
      seat: seat,
      active: active,
      hero: hero,
      refined: refined,
      decisionPriceOwnedByTable: decisionPriceOwnedByTable,
      identityPolicy: identityPolicy,
      positionAndStack: registeredScene,
    );
    final stackLabel = (seat.stackLabel ?? '').trim();
    final showsOpponentStack =
        !hero && stackLabel.isNotEmpty && markerDisplay.subLabel == stackLabel;
    final highlighted = switch (seatVisualState) {
      _SeatVisualStateV1.passive || _SeatVisualStateV1.selectable => false,
      _ => true,
    };
    final useSlimRefinedSeat = refined && !hero;
    final folded = seat.isFolded;
    final isPassive = seatVisualState == _SeatVisualStateV1.passive;
    final primaryLabelColor = selectable
        ? Act0ShellTokensV1.info
        : hero
        ? Act0ShellTokensV1.text
        : isPassive
        ? (refined ? Act0ShellTokensV1.textDim : Act0ShellTokensV1.textMuted)
        : (refined ? Act0ShellTokensV1.textMuted : Act0ShellTokensV1.text);
    final subLabelColor = hero
        ? Act0ShellTokensV1.textMuted
        : isPassive
        ? (refined
              ? Act0ShellTokensV1.textDim.withValues(alpha: 0.65)
              : Act0ShellTokensV1.textDim)
        : (refined ? Act0ShellTokensV1.textDim : Act0ShellTokensV1.textMuted);
    final borderColor = _seatBorderColorV1(seatVisualState, refined: refined);
    final ringColor = _seatRingColorV1(seatVisualState);
    // A selectable seat is an answer control. It receives the same bounded
    // outer affordance plane as focus states, while its cyan tone remains
    // distinct from gold target/current-player and correctness semantics.
    final shouldShowRing = seatVisualState != _SeatVisualStateV1.passive;
    final visibleCards = !showCards
        ? const <Act0CardStateV1>[]
        : hero
        ? heroCards
        : seat.holeCards;
    final showFaceDown =
        !hero &&
        seat.isOccupied &&
        seat.isInHand &&
        !folded &&
        seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceDown &&
        visibleCards.isNotEmpty;
    final showFaceUp =
        !hero &&
        seat.isOccupied &&
        seat.isInHand &&
        !folded &&
        seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp &&
        visibleCards.isNotEmpty;
    // B4: the seat glyph survives only where it still carries meaning. B3 put
    // a drawn player in every occupied seat, so `person_rounded` beside them is
    // a duplicate \u2014 and it is the most app-like mark left on the cloth. The
    // selectable touch glyph and the empty-seat mark are interaction truth and
    // stay exactly as they were.
    final showsSeatGlyph = hero || selectable || !seat.isOccupied;
    final showsSeatName =
        !hero || identityPolicy != Act0TableIdentityPolicyV1.learnerOnly;
    final seatName = act0RuntimeLocalizedSeatPrimaryLabelV1(
      context,
      seat: seat,
      hero: hero,
      refined: refined,
      identityPolicy: identityPolicy,
    );
    final occupiedOpacity = !seat.isOccupied
        ? 0.42
        : folded || !seat.isInHand
        ? 0.58
        : 1.0;
    final node = Container(
      key: Key('act0_shell_seat_node_${seat.seatId}'),
      constraints: BoxConstraints(
        minHeight: !showCards && selectable ? 44 : 0,
        minWidth: compact
            ? Act0ShellTokensV1.compactSeatMinWidth
            : Act0ShellTokensV1.seatMinWidth,
      ),
      child: Opacity(
        opacity: occupiedOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hero && visibleCards.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < visibleCards.length; i++) ...[
                    _CardV1(
                      card: visibleCards[i],
                      cardId: 'hero_$i',
                      highlighted: highlightedCardIds.contains('hero_$i'),
                    ),
                    if (i < visibleCards.length - 1) const SizedBox(width: 4),
                  ],
                ],
              ),
              SizedBox(height: cardPlateGap),
            ] else if (showFaceDown) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < visibleCards.length; i++) ...[
                    Transform.rotate(
                      angle: i == 0 ? -0.06 : 0.06,
                      child: const _MiniCardBackV1(),
                    ),
                    if (i < visibleCards.length - 1) const SizedBox(width: 2),
                  ],
                ],
              ),
              SizedBox(height: cardPlateGap),
            ] else if (showFaceUp) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < visibleCards.length; i++) ...[
                    _CardV1(
                      card: visibleCards[i],
                      cardId: '${seat.seatId}_$i',
                      highlighted: highlightedCardIds.contains(
                        '${seat.seatId}_$i',
                      ),
                    ),
                    if (i < visibleCards.length - 1) const SizedBox(width: 3),
                  ],
                ],
              ),
              SizedBox(height: cardPlateGap),
            ],
            if (folded && !registeredScene) ...[
              const _FoldedBadgeV1(),
              SizedBox(height: cardPlateGap),
            ],
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  key: hero
                      ? Key('act0_shell_hero_identity_${seat.seatId}')
                      : Key('act0_shell_seat_identity_${seat.seatId}'),
                  padding: EdgeInsets.symmetric(
                    // Without the glyph the plate would shrink-wrap to its
                    // label and read as a chip. A nameplate has to stay
                    // plate-shaped, so the reclaimed width goes back as
                    // padding rather than being given up.
                    horizontal: registeredScene
                        ? 9
                        : (compact
                                  ? (refined ? 5 : 7)
                                  : (useSlimRefinedSeat
                                        ? 7
                                        : (refined ? 9 : 8))) +
                              (showsSeatGlyph ? 0 : 6),
                    vertical: registeredScene
                        ? 5
                        : (useSlimRefinedSeat ? 5 : (refined ? 6 : 5)) -
                              plateVerticalPad,
                  ),
                  decoration: Act0SceneNameplateV1.decoration(
                    radius: Act0ShellTokensV1.radiusSm,
                    stateTone: shouldShowRing ? borderColor : null,
                    stateStrength: shouldShowRing ? 1.0 : 0.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showsSeatGlyph) ...[
                        Container(
                          width: compact
                              ? (refined ? 18 : 22)
                              : (useSlimRefinedSeat ? 22 : (refined ? 26 : 24)),
                          height: compact
                              ? (refined ? 18 : 22)
                              : (useSlimRefinedSeat ? 22 : (refined ? 26 : 24)),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: hero
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      Act0ShellTokensV1.runnerTagBlue,
                                      Act0ShellTokensV1.runnerSharkBlueDark,
                                    ],
                                  )
                                : null,
                            color: hero
                                ? null
                                : refined
                                ? (seatVisualState ==
                                          _SeatVisualStateV1.selectable
                                      ? Act0ShellTokensV1.info.withValues(
                                          alpha: 0.10,
                                        )
                                      : Act0ShellTokensV1.surface2)
                                : Act0ShellTokensV1.surface3,
                            borderRadius: BorderRadius.circular(
                              refined
                                  ? Act0ShellTokensV1.radiusXs
                                  : Act0ShellTokensV1.radiusPill,
                            ),
                            border: Border.all(
                              color: hero
                                  ? Act0ShellTokensV1.gold.withValues(
                                      alpha: 0.86,
                                    )
                                  : refined
                                  ? Act0ShellTokensV1.border.withValues(
                                      alpha: 0.72,
                                    )
                                  : Colors.transparent,
                              width: hero ? 1.2 : 1.0,
                            ),
                            boxShadow: hero
                                ? const <BoxShadow>[
                                    BoxShadow(
                                      color: Act0ShellTokensV1.shadowSoftStrong,
                                      blurRadius: 3,
                                      offset: Offset(0, 1.5),
                                    ),
                                  ]
                                : null,
                          ),
                          child: hero
                              ? KeyedSubtree(
                                  key: const Key(
                                    'act0_shell_wave1_hero_you_badge',
                                  ),
                                  child: FittedBox(
                                    key: const Key(
                                      'act0_shell_wave1b_hero_badge',
                                    ),
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'You',
                                      style: Act0ShellTokensV1.label.copyWith(
                                        color: Act0ShellTokensV1.onPrimary,
                                        fontSize: refined ? 7.2 : 7.6,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                )
                              : Icon(
                                  selectable
                                      ? Icons.touch_app_rounded
                                      : seat.isOccupied
                                      ? Icons.person_rounded
                                      : Icons.circle_outlined,
                                  size: useSlimRefinedSeat
                                      ? 11
                                      : (refined ? 12 : 13),
                                  color:
                                      seatVisualState ==
                                          _SeatVisualStateV1.selectable
                                      ? Act0ShellTokensV1.info.withValues(
                                          alpha: 0.56,
                                        )
                                      : refined
                                      ? Act0ShellTokensV1.textDim
                                      : Act0ShellTokensV1.textMuted,
                                ),
                        ),
                        SizedBox(width: useSlimRefinedSeat ? 4 : 5),
                      ],
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showsSeatName)
                            Text(
                              seatName,
                              maxLines: 2,
                              style: Act0ShellTokensV1.label.copyWith(
                                color: primaryLabelColor,
                                fontSize: registeredScene
                                    ? 9.0
                                    : useSlimRefinedSeat
                                    ? 8.5
                                    : (refined ? 9.0 : 10),
                                letterSpacing: refined ? 0.1 : 0.4,
                              ),
                            ),
                          if (markerDisplay.subLabel != null)
                            KeyedSubtree(
                              key: showsOpponentStack
                                  ? Key(
                                      'act0_shell_opponent_stack_${seat.seatId}',
                                    )
                                  : null,
                              child: Text(
                                markerDisplay.subLabel!,
                                key: Key(
                                  'act0_shell_seat_sublabel_${seat.seatId}',
                                ),
                                style: Act0ShellTokensV1.muted.copyWith(
                                  fontSize: registeredScene
                                      ? 8.5
                                      : useSlimRefinedSeat
                                      ? 8.0
                                      : (refined ? 8.5 : 9),
                                  color: subLabelColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (markerDisplay.markers.isNotEmpty)
                  _SeatMarkerPlacementV1(
                    seatId: seat.seatId,
                    leftSide: seat.seatLabel == 'SB' || seat.seatLabel == 'BB',
                    markers: markerDisplay.markers
                        .where(
                          (m) =>
                              showDealerMarker || m != _SeatMarkerKindV1.dealer,
                        )
                        .toList(),
                    hero: hero,
                    visualVariant: visualVariant,
                  ),
                if (shouldShowRing)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        key: const Key('act0_shell_active_seat_ring'),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusSm,
                          ),
                          border: Border.all(
                            color: ringColor.withValues(alpha: 0.42),
                            width: 2,
                          ),
                        ),
                        child: SizedBox(
                          key: Key(
                            'act0_shell_active_seat_ring_${seat.seatId}',
                          ),
                        ),
                      ),
                    ),
                  ),
                if (seatVisualState != _SeatVisualStateV1.passive)
                  Positioned(
                    child: SizedBox(
                      key: Key(
                        'act0_shell_seat_state_${seat.seatId}_${seatVisualState.name}',
                      ),
                    ),
                  ),
              ],
            ),
            if (folded && registeredScene) ...[
              const SizedBox(height: 2),
              const _FoldedBadgeV1(),
            ],
          ],
        ),
      ),
    );
    final activate = onTap;
    if (activate == null) {
      return node;
    }
    return _SeatAnswerButtonV1(
      seatId: seat.seatId,
      selected:
          seatVisualState == _SeatVisualStateV1.wrongSelected ||
          seatVisualState == _SeatVisualStateV1.confirmedSelected,
      label: identityPolicy == Act0TableIdentityPolicyV1.learnerOnly
          ? 'Select $seatName'
          : 'Select ${seat.seatLabel}',
      onTap: activate,
      child: node,
    );
  }
}

class _SeatAnswerButtonV1 extends StatefulWidget {
  const _SeatAnswerButtonV1({
    required this.seatId,
    required this.selected,
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String seatId;
  final bool selected;
  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_SeatAnswerButtonV1> createState() => _SeatAnswerButtonV1State();
}

class _SeatAnswerButtonV1State extends State<_SeatAnswerButtonV1> {
  bool _focused = false;
  bool _showFocusHighlight = false;

  @override
  Widget build(BuildContext context) {
    final showRing = _focused && _showFocusHighlight;
    final target = DecoratedBox(
      key: const Key('act0_shell_seat_focus_decoration'),
      position: DecorationPosition.foreground,
      decoration: showRing
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusSm),
              border: Border.all(color: Act0ShellTokensV1.text, width: 2),
            )
          : const BoxDecoration(),
      child: Center(child: widget.child),
    );
    return Semantics(
      key: Key('act0_shell_seat_button_${widget.seatId}'),
      container: true,
      explicitChildNodes: true,
      button: true,
      focusable: true,
      focused: _focused,
      selected: widget.selected,
      label: widget.label,
      onTap: widget.onTap,
      child: FocusableActionDetector(
        includeFocusSemantics: false,
        onFocusChange: (focused) => setState(() => _focused = focused),
        onShowFocusHighlight: (show) =>
            setState(() => _showFocusHighlight = show),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          excludeFromSemantics: true,
          key: Key('act0_shell_seat_tap_${widget.seatId}'),
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: target,
          ),
        ),
      ),
    );
  }
}

enum _SeatSelectionFeedbackStateV1 { none, wrong, confirmed }

enum _PrimarySeatFocusKindV1 { none, active, target }

class _PrimarySeatFocusResolutionV1 {
  const _PrimarySeatFocusResolutionV1({required this.kind, this.seatId});

  final _PrimarySeatFocusKindV1 kind;
  final String? seatId;
}

enum _SeatVisualStateV1 {
  wrongSelected,
  confirmedSelected,
  hero,
  activeFocus,
  targetFocus,
  selectable,
  passive,
}

enum _SeatMarkerKindV1 { dealer, smallBlind, bigBlind, aggressor, act }

class _SeatMarkerDisplayV1 {
  const _SeatMarkerDisplayV1({required this.markers, this.subLabel});

  final List<_SeatMarkerKindV1> markers;
  final String? subLabel;
}

_PrimarySeatFocusResolutionV1 _resolvePrimarySeatFocusV1({
  required String? activeSeatId,
  required List<String> highlightedSeatIds,
  required List<String> selectableSeatIds,
  required String? selectedSeatId,
  required _SeatSelectionFeedbackStateV1 selectionFeedbackState,
}) {
  final normalizedHighlights = highlightedSeatIds
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toList(growable: false);
  final normalizedSelectable = selectableSeatIds
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toSet();
  final explicitTargets = normalizedHighlights
      .where((id) => normalizedSelectable.contains(id))
      .toList(growable: false);
  final selected = (selectedSeatId ?? '').trim();

  if (selectionFeedbackState == _SeatSelectionFeedbackStateV1.confirmed &&
      selected.isNotEmpty) {
    return const _PrimarySeatFocusResolutionV1(
      kind: _PrimarySeatFocusKindV1.none,
    );
  }

  if (selectionFeedbackState == _SeatSelectionFeedbackStateV1.wrong) {
    final repairTargets = normalizedHighlights
        .where((id) => id != selected)
        .toList(growable: false);
    if (repairTargets.length == 1) {
      return _PrimarySeatFocusResolutionV1(
        kind: _PrimarySeatFocusKindV1.target,
        seatId: repairTargets.first,
      );
    }
  }

  if (selectionFeedbackState == _SeatSelectionFeedbackStateV1.none) {
    final active = (activeSeatId ?? '').trim();
    if (active.isNotEmpty) {
      return _PrimarySeatFocusResolutionV1(
        kind: _PrimarySeatFocusKindV1.active,
        seatId: active,
      );
    }
  }

  if (explicitTargets.length == 1) {
    return _PrimarySeatFocusResolutionV1(
      kind: _PrimarySeatFocusKindV1.target,
      seatId: explicitTargets.first,
    );
  }

  if (normalizedHighlights.length == 1) {
    return _PrimarySeatFocusResolutionV1(
      kind: _PrimarySeatFocusKindV1.target,
      seatId: normalizedHighlights.first,
    );
  }

  return const _PrimarySeatFocusResolutionV1(
    kind: _PrimarySeatFocusKindV1.none,
  );
}

_SeatVisualStateV1 _resolveSeatVisualStateV1({
  required String seatId,
  required bool hero,
  required bool selectable,
  required bool selected,
  required _SeatSelectionFeedbackStateV1 selectionFeedbackState,
  required _PrimarySeatFocusResolutionV1 focusResolution,
}) {
  if (selected &&
      selectionFeedbackState == _SeatSelectionFeedbackStateV1.wrong) {
    return _SeatVisualStateV1.wrongSelected;
  }
  if (selected &&
      selectionFeedbackState == _SeatSelectionFeedbackStateV1.confirmed) {
    return _SeatVisualStateV1.confirmedSelected;
  }
  if (hero) {
    return _SeatVisualStateV1.hero;
  }
  if (focusResolution.kind == _PrimarySeatFocusKindV1.active &&
      focusResolution.seatId == seatId) {
    return _SeatVisualStateV1.activeFocus;
  }
  if (focusResolution.kind == _PrimarySeatFocusKindV1.target &&
      focusResolution.seatId == seatId) {
    return _SeatVisualStateV1.targetFocus;
  }
  if (selectable) {
    return _SeatVisualStateV1.selectable;
  }
  return _SeatVisualStateV1.passive;
}

bool _seatHasBlindPostChipV1(Act0SeatStateV1 seat) {
  final bet = seat.bet;
  return bet != null &&
      bet.kind == Act0SeatBetKindV1.post &&
      !seat.isFolded &&
      (bet.label == 'SB' || bet.label == 'BB' || bet.label == 'POST');
}

bool _seatCurrentBetIsOwnedByChipV1(Act0SeatStateV1 seat) {
  final bet = seat.bet;
  final currentBetLabel = seat.currentBetLabel?.trim() ?? '';
  if (bet == null || currentBetLabel.isEmpty || seat.isFolded) {
    return false;
  }
  return currentBetLabel == bet.amountLabel.trim();
}

String _localizedSeatRoleLabelV1(
  BuildContext context, {
  required String atomId,
  required String fallback,
}) => act0LocalizedSurfaceAtomV1(context, atomId, fallback: fallback);

_SeatMarkerDisplayV1 _resolveSeatMarkerDisplayV1(
  BuildContext context, {
  required Act0SeatStateV1 seat,
  required bool active,
  required bool hero,
  required bool refined,
  required bool decisionPriceOwnedByTable,
  required Act0TableIdentityPolicyV1 identityPolicy,
  bool positionAndStack = false,
}) {
  final markers = <_SeatMarkerKindV1>[
    if (seat.isDealerButton &&
        (identityPolicy == Act0TableIdentityPolicyV1.currentProduction ||
            identityPolicy == Act0TableIdentityPolicyV1.learnerPosition ||
            identityPolicy ==
                Act0TableIdentityPolicyV1.learnerPositionAndDealerOrder))
      _SeatMarkerKindV1.dealer,
    if (!refined && seat.isSmallBlind && !_seatHasBlindPostChipV1(seat))
      _SeatMarkerKindV1.smallBlind,
    if (!refined && seat.isBigBlind && !_seatHasBlindPostChipV1(seat))
      _SeatMarkerKindV1.bigBlind,
    if (seat.isLastAggressor && !active) _SeatMarkerKindV1.aggressor,
    // Active seats retain the amber focus ring and the semantic To act
    // sublabel. An additional Act badge repeats that same state.
  ];
  final stackLabel = (seat.stackLabel ?? '').trim();

  if (positionAndStack && active && !hero && stackLabel.isNotEmpty) {
    final hasUnmarkedCommitment =
        !decisionPriceOwnedByTable &&
        (seat.currentBetLabel ?? seat.blindAmountLabel ?? '')
            .trim()
            .isNotEmpty &&
        !_seatCurrentBetIsOwnedByChipV1(seat) &&
        !_seatHasBlindPostChipV1(seat);
    if (!hasUnmarkedCommitment) {
      return _SeatMarkerDisplayV1(markers: markers, subLabel: stackLabel);
    }
  }

  if (!hero && active) {
    if (decisionPriceOwnedByTable) {
      return _SeatMarkerDisplayV1(
        markers: markers,
        subLabel: stackLabel.isEmpty ? null : stackLabel,
      );
    }
    final toActAmountLabel =
        (seat.currentBetLabel ?? seat.blindAmountLabel ?? '').trim();
    final toAct = _localizedSeatRoleLabelV1(
      context,
      atomId: 'table_word_to_act',
      fallback: 'To act',
    );
    return _SeatMarkerDisplayV1(
      markers: markers,
      subLabel: toActAmountLabel.isEmpty ? toAct : '$toAct: $toActAmountLabel',
    );
  }

  if (stackLabel.isNotEmpty) {
    return _SeatMarkerDisplayV1(markers: markers, subLabel: stackLabel);
  }

  if (_seatCurrentBetIsOwnedByChipV1(seat) || _seatHasBlindPostChipV1(seat)) {
    return _SeatMarkerDisplayV1(markers: markers);
  }

  final currentBetLabel = (seat.currentBetLabel ?? '').trim();
  if (currentBetLabel.isNotEmpty) {
    return _SeatMarkerDisplayV1(markers: markers, subLabel: currentBetLabel);
  }

  final blindAmountLabel = (seat.blindAmountLabel ?? '').trim();
  if (blindAmountLabel.isNotEmpty && !_seatHasBlindPostChipV1(seat)) {
    return _SeatMarkerDisplayV1(markers: markers, subLabel: blindAmountLabel);
  }

  if (!positionAndStack && refined && !hero) {
    if (seat.isDealerButton) {
      return _SeatMarkerDisplayV1(markers: markers);
    }
    if (seat.isSmallBlind) {
      return _SeatMarkerDisplayV1(
        markers: markers,
        subLabel: _localizedSeatRoleLabelV1(
          context,
          atomId: 'table_word_small_blind',
          fallback: 'Small blind',
        ),
      );
    }
    if (seat.isBigBlind) {
      return _SeatMarkerDisplayV1(
        markers: markers,
        subLabel: _localizedSeatRoleLabelV1(
          context,
          atomId: 'table_word_big_blind',
          fallback: 'Big blind',
        ),
      );
    }
  }

  return _SeatMarkerDisplayV1(markers: markers);
}

Color _seatBorderColorV1(_SeatVisualStateV1 state, {required bool refined}) {
  return switch (state) {
    _SeatVisualStateV1.wrongSelected => Act0ShellTokensV1.danger,
    _SeatVisualStateV1.confirmedSelected => Act0ShellTokensV1.primary,
    _SeatVisualStateV1.hero => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.activeFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.targetFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.selectable =>
      refined
          ? Act0ShellTokensV1.info.withValues(alpha: 0.42)
          : Act0ShellTokensV1.info.withValues(alpha: 0.58),
    _SeatVisualStateV1.passive => Act0ShellTokensV1.border,
  };
}

Color _seatRingColorV1(_SeatVisualStateV1 state) {
  return switch (state) {
    _SeatVisualStateV1.wrongSelected => Act0ShellTokensV1.danger,
    _SeatVisualStateV1.confirmedSelected => Act0ShellTokensV1.primary,
    _SeatVisualStateV1.hero => Act0ShellTokensV1.primary,
    _SeatVisualStateV1.activeFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.targetFocus => Act0ShellTokensV1.gold,
    _SeatVisualStateV1.selectable => Act0ShellTokensV1.info,
    _SeatVisualStateV1.passive => Act0ShellTokensV1.border,
  };
}

enum _ActionTrailVariantV1 { compactContext, replay }

enum _RunnerBottomOwnerV1 { coachRail, questionPrompt, feedback }

class _RunnerBottomContextV1 {
  const _RunnerBottomContextV1({
    required this.owner,
    required this.isTrailHistory,
    required this.promptOwnsDecisionContext,
    required this.showActionTrail,
    this.actionTrailVariant,
    required this.taskLabel,
    required this.questionBadgeLabel,
    this.promptSupportLine,
    this.feedbackContextLabels = const <String>[],
  });

  final _RunnerBottomOwnerV1 owner;
  final bool isTrailHistory;
  final bool promptOwnsDecisionContext;
  final bool showActionTrail;
  final _ActionTrailVariantV1? actionTrailVariant;
  final String taskLabel;
  final String questionBadgeLabel;
  final String? promptSupportLine;
  final List<String> feedbackContextLabels;
}

class _CenterStatDisplayV1 {
  const _CenterStatDisplayV1({
    required this.centerCueLabel,
    required this.potLabel,
    required this.toCallLabel,
  });

  final String centerCueLabel;
  final String potLabel;
  final String toCallLabel;

  bool get ownsDecisionPrice => toCallLabel.trim().isNotEmpty;
}

bool _isActiveAssessmentStateV1({
  required bool isTeaching,
  required bool isReview,
  required Act0RunnerStateV1 runner,
}) =>
    !isTeaching &&
    !isReview &&
    runner.options.isNotEmpty &&
    (runner.selectedOptionId ?? '').trim().isEmpty;

String _normalizeAnswerLeakTextV1(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _isAnswerBearingTableCueV1({
  required String cueLabel,
  required String question,
  required List<Act0RunnerOptionV1> options,
}) {
  final normalizedCue = _normalizeAnswerLeakTextV1(cueLabel);
  if (normalizedCue.isEmpty) {
    return false;
  }
  final normalizedQuestion = _normalizeAnswerLeakTextV1(question);
  final optionLabels = <String>{
    for (final option in options) ...[
      _normalizeAnswerLeakTextV1(option.label),
      _normalizeAnswerLeakTextV1(option.preferredLabel),
      _normalizeAnswerLeakTextV1(option.betterAnswerLabel),
    ],
  }..remove('');

  final cueTokens = normalizedCue.split(' ').where((token) => token.isNotEmpty);
  if (optionLabels.contains(normalizedCue)) {
    return true;
  }
  for (final optionLabel in optionLabels) {
    if (optionLabel.isEmpty) {
      continue;
    }
    if (normalizedCue.contains(optionLabel) ||
        optionLabel.contains(normalizedCue)) {
      return true;
    }
  }
  final categoryQuestions = <String>[
    'which bucket',
    'what bucket',
    'which made hand',
    'what made hand',
    'which hand category',
    'what hand category',
    'which hand class',
  ];
  if (categoryQuestions.any(normalizedQuestion.contains)) {
    return cueTokens.any(optionLabels.contains);
  }
  return false;
}

bool _looksLikeActionDecisionPromptV1(
  String question, {
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  if (hasSeatTargets) {
    return false;
  }
  if (taskFamily == Act0TaskFamilyV1.decision ||
      taskFamily == Act0TaskFamilyV1.sizing ||
      taskFamily == Act0TaskFamilyV1.repair) {
    return true;
  }
  final normalizedQuestion = _normalizeAnswerLeakTextV1(question);
  return normalizedQuestion.contains('what is the') ||
      normalizedQuestion.contains('best action') ||
      normalizedQuestion.contains('simple action') ||
      normalizedQuestion.contains('simple response') ||
      normalizedQuestion.contains('clean action') ||
      normalizedQuestion.contains('clean response') ||
      normalizedQuestion.contains('disciplined action') ||
      normalizedQuestion.contains('disciplined response') ||
      normalizedQuestion.contains('first in action') ||
      normalizedQuestion.contains('response');
}

bool _isAnswerLeadingTableCueV1(
  String cueLabel, {
  required String question,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final rawCue = cueLabel.trim().toLowerCase();
  final normalizedCue = _normalizeAnswerLeakTextV1(cueLabel);
  if (normalizedCue.isEmpty) {
    return false;
  }
  final cueKeywords = <String>[
    'weak continue',
    'strong continue',
    'easy fold',
    'call spot',
    'value spot',
    'bluff catch',
    'fold pressure',
    'low fold pressure',
    'one third',
    'half pot',
    'pot size',
    'range bucket',
    'value action',
    'bucket',
  ];
  final isDecisionPrompt = _looksLikeActionDecisionPromptV1(
    question,
    taskFamily: taskFamily,
    hasSeatTargets: hasSeatTargets,
  );
  if (rawCue.contains('?')) {
    return true;
  }
  if (cueKeywords.any(normalizedCue.contains)) {
    return true;
  }
  if (isDecisionPrompt) {
    const decisionWords = <String>[
      'continue',
      'fold',
      'call',
      'raise',
      'value',
      'bluff',
      'pressure',
      'sizing',
    ];
    if (decisionWords.any(normalizedCue.contains)) {
      return true;
    }
  }
  return false;
}

bool _isSafePriorActionTableCueV1(String cueLabel) {
  final label = cueLabel.trim();
  if (label.isEmpty) {
    return false;
  }
  return RegExp(
    r'^[A-Z0-9]+\s+(?:opens?|opened|raises?|raised|bets?|bet|calls?|called|checks?|checked|folds?|folded|all[- ]?in|goes\s+all(?:\s+in)?)\b',
    caseSensitive: false,
  ).hasMatch(label);
}

String? _safePriorActionCueV1(Act0TableStateV1 table) {
  if (table.scope != Act0TableScopeV1.playedHand) return null;
  final candidates = <String>[
    table.centerLabel,
    for (final item in table.actionTrail.reversed)
      if (!item.isNote) item.label,
  ];
  for (final candidate in candidates) {
    final label = candidate.trim();
    if (_isSafePriorActionTableCueV1(label)) {
      return label;
    }
  }
  return null;
}

String? _deriveFacingActorCueV1(
  BuildContext context, {
  required Act0TableStateV1 table,
}) {
  if (table.scope != Act0TableScopeV1.playedHand) return null;
  final candidates = <String>[
    for (final item in table.actionTrail.reversed)
      if (!item.isNote) item.label,
    table.centerLabel,
  ];
  for (final raw in candidates) {
    final label = raw.trim();
    final openMatch = RegExp(
      r'^([A-Z0-9]+)\s+opens\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(label);
    if (openMatch != null) {
      return act0RuntimeNeutralFacingActorCueLabelV1(
        context,
        actor: openMatch.group(1)!.toUpperCase(),
        amount: openMatch.group(2)!,
      );
    }
    final betMatch = RegExp(
      r'^([A-Z0-9]+)\s+bets\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(label);
    if (betMatch != null) {
      return act0RuntimeNeutralFacingActorCueLabelV1(
        context,
        actor: betMatch.group(1)!.toUpperCase(),
        amount: betMatch.group(2)!,
      );
    }
  }
  return null;
}

String _neutralizeLeadingTableCueV1(
  BuildContext context, {
  required Act0TableStateV1 table,
  required Act0TaskFamilyV1? taskFamily,
}) {
  if (taskFamily == Act0TaskFamilyV1.sizing) {
    return act0RuntimeNeutralSizingCueLabelV1(context);
  }
  final facingActorCue = _deriveFacingActorCueV1(context, table: table);
  if (facingActorCue != null) {
    return facingActorCue;
  }
  if (table.potLabel.trim().isNotEmpty && table.toCallLabel.trim().isNotEmpty) {
    return act0RuntimeNeutralPotAndPriceCueLabelV1(context);
  }
  if (table.toCallLabel.trim().isNotEmpty) {
    return act0RuntimeNeutralFacingPriceCueLabelV1(context);
  }
  return act0RuntimeNeutralDecisionCueLabelV1(context);
}

String? _resolveDecisionPromptSupportLineV1(
  BuildContext context, {
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  if (!_looksLikeActionDecisionPromptV1(
    runner.question,
    taskFamily: taskFamily,
    hasSeatTargets: hasSeatTargets,
  )) {
    return null;
  }
  return _safePriorActionCueV1(table) ??
      _deriveFacingActorCueV1(context, table: table);
}

String _neutralizeAnswerBearingCueV1({
  required BuildContext context,
  required String cueLabel,
  required String question,
}) {
  final normalizedCue = _normalizeAnswerLeakTextV1(cueLabel);
  final normalizedQuestion = _normalizeAnswerLeakTextV1(question);
  if (normalizedQuestion.contains('bucket') ||
      normalizedCue.contains('bucket')) {
    return act0RuntimeNeutralBucketCueLabelV1(context);
  }
  if (normalizedQuestion.contains('made hand') ||
      normalizedQuestion.contains('hand category') ||
      normalizedQuestion.contains('showdown')) {
    return act0RuntimeNeutralHandReadCueLabelV1(context);
  }
  if (normalizedQuestion.contains('trail') ||
      normalizedQuestion.contains('history')) {
    return 'Hand history';
  }
  return act0RuntimeNeutralTableReadCueLabelV1(context);
}

String _resolveTableCueDisplayV1({
  required BuildContext context,
  required String? selectedTaskId,
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required bool isTeaching,
  required bool isReview,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final rawCue = table.centerLabel.trim();
  if (rawCue.isEmpty) {
    return rawCue;
  }
  if (!_isActiveAssessmentStateV1(
    isTeaching: isTeaching,
    isReview: isReview,
    runner: runner,
  )) {
    return rawCue;
  }
  if (selectedTaskId == 'straight_draws_w5_gutshot_draw' ||
      selectedTaskId == 'hand_rankings_quads_drill') {
    return '';
  }
  // ASM-04 catalog closure: these authored cues state, verdict or entail the
  // answer before choice. Keep the cue slot, but only with a neutral read.
  if (act0PrechoiceAnswerBearingTableCueTaskIdsV1.contains(selectedTaskId)) {
    return _neutralizeLeadingTableCueV1(
      context,
      table: table,
      taskFamily: taskFamily,
    );
  }
  if (_looksLikeTrailHistoryQuestionV1(runner, table)) {
    return '';
  }
  if (_isSafePriorActionTableCueV1(rawCue)) {
    return rawCue;
  }
  if (_isAnswerBearingTableCueV1(
    cueLabel: rawCue,
    question: runner.question,
    options: runner.options,
  )) {
    return _neutralizeAnswerBearingCueV1(
      context: context,
      cueLabel: rawCue,
      question: runner.question,
    );
  }
  if (_isAnswerLeadingTableCueV1(
    rawCue,
    question: runner.question,
    taskFamily: taskFamily,
    hasSeatTargets: hasSeatTargets,
  )) {
    return _neutralizeLeadingTableCueV1(
      context,
      table: table,
      taskFamily: taskFamily,
    );
  }
  return rawCue;
}

bool _isCenterPriceContextCueV1(BuildContext context, String cueLabel) {
  final normalizedCue = cueLabel.trim().toLowerCase();
  if (normalizedCue.isEmpty) {
    return false;
  }
  if (normalizedCue.startsWith('facing ') ||
      normalizedCue.startsWith('\u043F\u0440\u043E\u0442\u0438\u0432 ')) {
    return true;
  }
  final facingPrice = act0RuntimeNeutralFacingPriceCueLabelV1(
    context,
  ).toLowerCase();
  final potAndPrice = act0RuntimeNeutralPotAndPriceCueLabelV1(
    context,
  ).toLowerCase();
  return normalizedCue == facingPrice || normalizedCue == potAndPrice;
}

_CenterStatDisplayV1 _resolveCenterStatDisplayV1(
  BuildContext context, {
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required _RunnerBottomContextV1 bottomContext,
  required String centerCueLabel,
  required bool isTeaching,
  required bool isReview,
  required Act0TaskFamilyV1? taskFamily,
  required bool hasSeatTargets,
}) {
  final potLabel = table.potLabel.trim();
  final isActiveAssessment = _isActiveAssessmentStateV1(
    isTeaching: isTeaching,
    isReview: isReview,
    runner: runner,
  );
  final isDecisionPrompt =
      isActiveAssessment &&
      _looksLikeActionDecisionPromptV1(
        runner.question,
        taskFamily: taskFamily,
        hasSeatTargets: hasSeatTargets,
      );
  final showToCall =
      table.toCallLabel.trim().isNotEmpty && !bottomContext.isTrailHistory;
  var resolvedCue = centerCueLabel.trim();

  if (isDecisionPrompt && showToCall && resolvedCue.isNotEmpty) {
    final genericDecisionCue = taskFamily == Act0TaskFamilyV1.sizing
        ? act0RuntimeNeutralSizingCueLabelV1(context)
        : act0RuntimeNeutralDecisionCueLabelV1(context);
    if (bottomContext.promptOwnsDecisionContext &&
        _isCenterPriceContextCueV1(context, resolvedCue)) {
      resolvedCue = genericDecisionCue;
    } else if (_isCenterPriceContextCueV1(context, resolvedCue) &&
        !bottomContext.promptOwnsDecisionContext) {
      resolvedCue = genericDecisionCue;
    }
  }

  return _CenterStatDisplayV1(
    centerCueLabel: resolvedCue,
    potLabel: potLabel,
    toCallLabel: showToCall ? table.toCallLabel.trim() : '',
  );
}

String _normalizedTrailStreetFromLabelV1(String label) {
  final match = RegExp(
    r'^(Preflop|Flop|Turn|River)[:\s]',
    caseSensitive: false,
  ).firstMatch(label.trim());
  return match?.group(1)?.trim() ?? '';
}

bool _looksLikeTrailHistoryQuestionV1(
  Act0RunnerStateV1 runner,
  Act0TableStateV1 table,
) {
  if (table.scope != Act0TableScopeV1.playedHand || table.actionTrail.isEmpty) {
    return false;
  }
  final question = runner.question.trim().toLowerCase();
  if (question.contains('trail') ||
      question.contains('history') ||
      question.contains('happened last') ||
      question.contains('latest action')) {
    return true;
  }
  final trailLabels = table.actionTrail
      .map((item) => item.label.trim())
      .where((label) => label.isNotEmpty)
      .toSet();
  for (final option in runner.options) {
    final optionLabel = option.label.trim();
    final preferredLabel = option.preferredLabel.trim();
    if (trailLabels.contains(optionLabel) ||
        trailLabels.contains(preferredLabel)) {
      return true;
    }
  }
  return false;
}

_RunnerBottomContextV1 _resolveRunnerBottomContextV1(
  BuildContext context, {
  required Act0RunnerStateV1 runner,
  required Act0TableStateV1 table,
  required bool isTeaching,
  required bool isTheory,
  required bool isDrill,
  required bool isReview,
  required bool showBottomLearningRail,
  required bool hasSeatTargets,
  required Act0TaskFamilyV1? taskFamily,
}) {
  final isTrailHistory = !isTeaching && !isTheory
      ? _looksLikeTrailHistoryQuestionV1(runner, table)
      : false;
  final taskLabel = act0RuntimeTaskRailLabelV1(
    context,
    isTeaching: isTeaching,
    isTheory: isTheory,
    isDrill: isDrill,
    isReview: isReview,
    isTrailHistory: isTrailHistory,
    hasSeatTargets: hasSeatTargets,
    question: runner.question,
    options: runner.options,
    taskFamily: taskFamily,
  );
  final tableStreet = table.streetLabel.trim();
  final trailStreet = table.actionTrail.isEmpty
      ? ''
      : _normalizedTrailStreetFromLabelV1(table.actionTrail.last.label);
  final decisionPromptSupportLine = !isTrailHistory
      ? _resolveDecisionPromptSupportLineV1(
          context,
          runner: runner,
          table: table,
          taskFamily: taskFamily,
          hasSeatTargets: hasSeatTargets,
        )
      : null;
  final promptSupportLine = isTrailHistory
      ? act0RuntimeTrailPromptSupportLineV1(
          context,
          currentStreetLabel: tableStreet,
          trailStreetLabel: trailStreet,
        )
      : decisionPromptSupportLine;
  final feedbackContextLabels = isTrailHistory
      ? <String>[act0RuntimeTrailFeedbackContextLabelV1(context)]
      : const <String>[];

  if (showBottomLearningRail || isTeaching || isTheory) {
    return _RunnerBottomContextV1(
      owner: _RunnerBottomOwnerV1.coachRail,
      isTrailHistory: isTrailHistory,
      promptOwnsDecisionContext: false,
      showActionTrail: false,
      taskLabel: taskLabel,
      questionBadgeLabel: act0RuntimeQuestionBadgeLabelV1(context),
      promptSupportLine: promptSupportLine,
      feedbackContextLabels: feedbackContextLabels,
    );
  }
  if (isReview) {
    return _RunnerBottomContextV1(
      owner: _RunnerBottomOwnerV1.feedback,
      isTrailHistory: isTrailHistory,
      promptOwnsDecisionContext: false,
      showActionTrail: table.actionTrail.isNotEmpty,
      actionTrailVariant: table.actionTrail.isNotEmpty
          ? _ActionTrailVariantV1.replay
          : null,
      taskLabel: taskLabel,
      questionBadgeLabel: act0RuntimeQuestionBadgeLabelV1(
        context,
        isTrailHistory: isTrailHistory,
      ),
      promptSupportLine: promptSupportLine,
      feedbackContextLabels: feedbackContextLabels,
    );
  }
  return _RunnerBottomContextV1(
    owner: _RunnerBottomOwnerV1.questionPrompt,
    isTrailHistory: isTrailHistory,
    promptOwnsDecisionContext: decisionPromptSupportLine != null,
    showActionTrail: false,
    taskLabel: taskLabel,
    questionBadgeLabel: act0RuntimeQuestionBadgeLabelV1(
      context,
      isTrailHistory: isTrailHistory,
    ),
    promptSupportLine: promptSupportLine,
    feedbackContextLabels: feedbackContextLabels,
  );
}

class _ActionTrailV1 extends StatefulWidget {
  const _ActionTrailV1({
    required this.items,
    required this.variant,
    required this.isHandHistory,
    this.streetLabel,
    this.refined = false,
    this.onFocusedIndexChanged,
  });

  final List<Act0ActionTrailItemV1> items;
  final bool isHandHistory;
  final _ActionTrailVariantV1 variant;
  final String? streetLabel;
  final bool refined;
  final ValueChanged<int>? onFocusedIndexChanged;

  @override
  State<_ActionTrailV1> createState() => _ActionTrailV1State();
}

class _ActionTrailV1State extends State<_ActionTrailV1> {
  Timer? _revealTimer;
  Timer? _playbackTimer;
  int _visibleCount = 0;
  int _focusedIndex = 0;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _visibleCount = widget.items.length;
    _focusedIndex = widget.items.isEmpty ? 0 : widget.items.length - 1;
    _emitFocusedIndex();
  }

  @override
  void didUpdateWidget(covariant _ActionTrailV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLabels = oldWidget.items.map((item) => item.label).toList();
    final newLabels = widget.items.map((item) => item.label).toList();
    if (_isSamePrefix(oldLabels, newLabels) &&
        newLabels.length > oldLabels.length) {
      _revealTimer?.cancel();
      setState(() => _visibleCount = oldLabels.length);
      _scheduleRevealUntil(newLabels.length);
      return;
    }
    _revealTimer?.cancel();
    _playbackTimer?.cancel();
    _isAutoPlaying = false;
    setState(() {
      _visibleCount = newLabels.length;
      _focusedIndex = newLabels.isEmpty ? 0 : newLabels.length - 1;
    });
    _emitFocusedIndex();
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _emitFocusedIndex() {
    if (!widget.isHandHistory || widget.items.isEmpty) {
      return;
    }
    final normalized = _focusedIndex.clamp(0, widget.items.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onFocusedIndexChanged?.call(normalized);
    });
  }

  bool _isSamePrefix(List<String> oldLabels, List<String> nextLabels) {
    if (oldLabels.length > nextLabels.length) {
      return false;
    }
    for (var i = 0; i < oldLabels.length; i++) {
      if (oldLabels[i] != nextLabels[i]) {
        return false;
      }
    }
    return true;
  }

  void _scheduleRevealUntil(int target) {
    if (!mounted || _visibleCount >= target) {
      return;
    }
    _revealTimer = Timer(const Duration(milliseconds: 130), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _visibleCount = (_visibleCount + 1).clamp(0, target);
      });
      _scheduleRevealUntil(target);
    });
  }

  void _focusStep(int nextIndex) {
    if (widget.items.isEmpty) {
      return;
    }
    final maxIndex = widget.items.length - 1;
    final normalized = nextIndex.clamp(0, maxIndex);
    if (_focusedIndex == normalized) {
      return;
    }
    setState(() {
      _focusedIndex = normalized;
    });
    _emitFocusedIndex();
  }

  /// Returns the street name if this trail label starts a new street
  /// (e.g. "Flop: BB checks" \u2192 "FLOP", "Flop dealt" \u2192 "FLOP"), otherwise null.
  String? _streetNameFromLabel(String label) {
    final m = RegExp(
      r'^(Flop|Turn|River)[:\s]',
      caseSensitive: false,
    ).firstMatch(label.trim());
    return m != null ? m.group(1)!.toUpperCase() : null;
  }

  void _toggleAutoPlay() {
    if (widget.items.length < 2) {
      return;
    }
    if (_isAutoPlaying) {
      _playbackTimer?.cancel();
      setState(() => _isAutoPlaying = false);
      return;
    }
    setState(() => _isAutoPlaying = true);
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted || widget.items.isEmpty) {
        return;
      }
      final maxIndex = widget.items.length - 1;
      final atEnd = _focusedIndex >= maxIndex;
      setState(() {
        _focusedIndex = atEnd ? 0 : (_focusedIndex + 1);
      });
      _emitFocusedIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final refined = widget.refined;
    final compactContext =
        widget.variant == _ActionTrailVariantV1.compactContext;
    final streetLabel = widget.streetLabel?.trim() ?? '';
    final visibleCount = _visibleCount.clamp(0, items.length);
    final focusedIndex = items.isEmpty
        ? 0
        : _focusedIndex.clamp(0, visibleCount - 1);
    final text = items.map((item) => item.learnerLabel).join('  .  ');
    if (!widget.isHandHistory) {
      return Text(
        'Table notes\n$text',
        key: const Key('act0_shell_table_notes'),
        style: Act0ShellTokensV1.muted,
      );
    }
    final focusedLabel = items.isEmpty
        ? ''
        : act0RuntimeLocalizedActionTrailLabelV1(
            context,
            items[focusedIndex].label,
          );
    final compactStreetLabel = streetLabel.isNotEmpty
        ? act0RuntimeLocalizedStreetLabelV1(context, streetLabel)
        : '';
    return Container(
      key: const Key('act0_shell_action_trail'),
      constraints: BoxConstraints(maxWidth: refined ? 332 : 370),
      padding: EdgeInsets.symmetric(
        horizontal: refined ? 8 : 11,
        vertical: refined ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: refined
            ? Act0ShellTokensV1.surface.withValues(alpha: 0.26)
            : Act0ShellTokensV1.surface2.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXl),
        border: Border.all(
          color: Act0ShellTokensV1.border.withValues(
            alpha: refined ? 0.16 : 0.44,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (compactContext) {
            return Row(
              key: const Key('act0_shell_action_trail_compact_context'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (compactStreetLabel.isNotEmpty)
                  Container(
                    key: const Key('act0_shell_action_trail_street_badge'),
                    padding: EdgeInsets.symmetric(
                      horizontal: refined ? 7 : 8,
                      vertical: refined ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: Act0ShellTokensV1.info.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(
                        Act0ShellTokensV1.radiusPill,
                      ),
                      border: Border.all(
                        color: Act0ShellTokensV1.info.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Text(
                      compactStreetLabel,
                      style: Act0ShellTokensV1.label.copyWith(
                        fontSize: refined ? 7.2 : 7.8,
                        color: Act0ShellTokensV1.info.withValues(alpha: 0.88),
                        letterSpacing: 0.18,
                      ),
                    ),
                  ),
                if (compactStreetLabel.isNotEmpty)
                  SizedBox(width: refined ? 7 : 8),
                Expanded(
                  child: Text(
                    focusedLabel,
                    key: const Key('act0_shell_action_trail_text'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.text.withValues(
                        alpha: refined ? 0.84 : 0.90,
                      ),
                      fontSize: refined ? 10.2 : 10.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          }
          final stackControls =
              items.length > 1 && refined && constraints.maxWidth < 206;
          final trailControls = Row(
            key: const Key('act0_shell_action_trail_replay_controls'),
            mainAxisSize: MainAxisSize.min,
            children: [
              _TrailPlaybackButtonV1(
                key: const Key('act0_shell_action_trail_playback_prev'),
                icon: Icons.skip_previous_rounded,
                onTap: () {
                  _playbackTimer?.cancel();
                  if (_isAutoPlaying) {
                    setState(() => _isAutoPlaying = false);
                  }
                  _focusStep(focusedIndex - 1);
                },
                compact: refined,
              ),
              SizedBox(width: refined ? 4 : 5),
              _TrailPlaybackButtonV1(
                key: const Key('act0_shell_action_trail_playback_toggle'),
                icon: _isAutoPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                onTap: _toggleAutoPlay,
                active: _isAutoPlaying,
                compact: refined,
              ),
              SizedBox(width: refined ? 4 : 5),
              _TrailPlaybackButtonV1(
                key: const Key('act0_shell_action_trail_playback_next'),
                icon: Icons.skip_next_rounded,
                onTap: () {
                  _playbackTimer?.cancel();
                  if (_isAutoPlaying) {
                    setState(() => _isAutoPlaying = false);
                  }
                  _focusStep(focusedIndex + 1);
                },
                compact: refined,
              ),
              const SizedBox(width: 6),
              Text(
                '${focusedIndex + 1}/${items.length}',
                style: TextStyle(
                  color: Act0ShellTokensV1.textMuted,
                  fontSize: refined ? 8.5 : 9.5,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
          );
          final trailMain = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: refined ? 22 : 26,
                height: refined ? 22 : 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Act0ShellTokensV1.surface3.withValues(
                    alpha: refined ? 0.28 : 0.62,
                  ),
                  borderRadius: BorderRadius.circular(
                    refined
                        ? Act0ShellTokensV1.radiusXs
                        : Act0ShellTokensV1.radiusPill,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.border.withValues(
                      alpha: refined ? 0.20 : 0.28,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  key: const Key('act0_shell_action_trail_icon'),
                  size: refined ? 12 : 14,
                  color: Act0ShellTokensV1.textMuted.withValues(
                    alpha: refined ? 0.66 : 0.82,
                  ),
                ),
              ),
              SizedBox(width: refined ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.shrink(
                      child: Text(
                        text,
                        key: const Key('act0_shell_action_trail_text'),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final badgeWidth = streetLabel.isNotEmpty
                            ? (refined ? 54.0 : 58.0)
                            : 0.0;
                        final scrollerWidth = streetLabel.isNotEmpty
                            ? (constraints.maxWidth -
                                      badgeWidth -
                                      (refined ? 5 : 7))
                                  .clamp(80.0, constraints.maxWidth)
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: refined ? 5 : 7,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (streetLabel.isNotEmpty)
                              refined
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                        vertical: 1,
                                      ),
                                      child: Text(
                                        streetLabel,
                                        key: const Key(
                                          'act0_shell_action_trail_street_badge',
                                        ),
                                        style: Act0ShellTokensV1.label.copyWith(
                                          fontSize: 7.1,
                                          color: Act0ShellTokensV1.info
                                              .withValues(alpha: 0.84),
                                          letterSpacing: 0.25,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      key: const Key(
                                        'act0_shell_action_trail_street_badge',
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Act0ShellTokensV1.info
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          Act0ShellTokensV1.radiusPill,
                                        ),
                                        border: Border.all(
                                          color: Act0ShellTokensV1.info
                                              .withValues(alpha: 0.34),
                                        ),
                                      ),
                                      child: Text(
                                        streetLabel,
                                        style: Act0ShellTokensV1.label.copyWith(
                                          fontSize: 7.2,
                                          color: Act0ShellTokensV1.info,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                            SizedBox(
                              width: scrollerWidth,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    for (var i = 0; i < visibleCount; i++) ...[
                                      if (i > 0 &&
                                          _streetNameFromLabel(
                                                items[i].label,
                                              ) !=
                                              null)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: refined ? 4 : 5,
                                          ),
                                          child: _TrailStreetDividerV1(
                                            label: _streetNameFromLabel(
                                              items[i].label,
                                            )!,
                                            refined: refined,
                                          ),
                                        ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: i == visibleCount - 1
                                              ? 0
                                              : (refined ? 4 : 5),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            _playbackTimer?.cancel();
                                            if (_isAutoPlaying) {
                                              setState(
                                                () => _isAutoPlaying = false,
                                              );
                                            }
                                            _focusStep(i);
                                          },
                                          child: _ActionTrailStepV1(
                                            item: items[i],
                                            index: i,
                                            isLatest: i == focusedIndex,
                                            refined: refined,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (items.length > 1 && !stackControls) ...[
                SizedBox(width: refined ? 7 : 8),
                trailControls,
              ],
            ],
          );
          if (!stackControls) {
            return trailMain;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              trailMain,
              SizedBox(height: refined ? 6 : 8),
              Align(alignment: Alignment.centerRight, child: trailControls),
            ],
          );
        },
      ),
    );
  }
}

class _TrailStreetDividerV1 extends StatelessWidget {
  const _TrailStreetDividerV1({required this.label, this.refined = false});
  final String label;
  final bool refined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.34),
        ),
      ),
      child: Text(
        label,
        style: Act0ShellTokensV1.label.copyWith(
          fontSize: refined ? 7.0 : 7.4,
          color: Act0ShellTokensV1.gold,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TrailPlaybackButtonV1 extends StatelessWidget {
  const _TrailPlaybackButtonV1({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
    this.compact = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = compact
        ? Act0ShellTokensV1.radiusXs
        : Act0ShellTokensV1.radiusPill;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 5 : 4,
            vertical: compact ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: active
                ? Act0ShellTokensV1.primary.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: compact ? 0.025 : 0.04),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: active
                  ? Act0ShellTokensV1.primary.withValues(alpha: 0.48)
                  : Act0ShellTokensV1.border.withValues(
                      alpha: compact ? 0.28 : 0.44,
                    ),
            ),
          ),
          child: Icon(
            icon,
            size: compact ? 14 : 16,
            color: active
                ? Act0ShellTokensV1.primary
                : Act0ShellTokensV1.textMuted,
          ),
        ),
      ),
    );
  }
}

class _ActionTrailStepV1 extends StatefulWidget {
  const _ActionTrailStepV1({
    required this.item,
    required this.index,
    required this.isLatest,
    required this.refined,
  });

  final Act0ActionTrailItemV1 item;
  final int index;
  final bool isLatest;
  final bool refined;

  @override
  State<_ActionTrailStepV1> createState() => _ActionTrailStepV1State();
}

class _ActionTrailStepV1State extends State<_ActionTrailStepV1> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final refined = widget.refined;
    final isLatest = widget.isLatest;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final visible = reduceMotion || _visible;
    return AnimatedSlide(
      key: Key('act0_shell_action_trail_step_${widget.index}'),
      duration: reduceMotion
          ? Duration.zero
          : Duration(milliseconds: refined ? 260 : 220),
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0.10, 0),
      child: AnimatedOpacity(
        duration: reduceMotion
            ? Duration.zero
            : Duration(milliseconds: refined ? 240 : 200),
        curve: Curves.easeOut,
        opacity: visible ? 1 : 0,
        child: Container(
          key: isLatest
              ? const Key('act0_shell_action_trail_latest_step')
              : null,
          padding: EdgeInsets.symmetric(
            horizontal: refined ? 7 : 8,
            vertical: refined ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: isLatest
                ? Act0ShellTokensV1.gold.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: refined ? 0.035 : 0.05),
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            border: Border.all(
              color: isLatest
                  ? Act0ShellTokensV1.gold.withValues(alpha: 0.36)
                  : Colors.white.withValues(alpha: refined ? 0.06 : 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: refined ? 4 : 5,
                height: refined ? 4 : 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLatest
                      ? Act0ShellTokensV1.gold
                      : Act0ShellTokensV1.textMuted.withValues(
                          alpha: refined ? 0.46 : 0.58,
                        ),
                ),
              ),
              SizedBox(width: refined ? 5 : 6),
              Text(
                act0RuntimeLocalizedActionTrailLabelV1(
                  context,
                  widget.item.learnerLabel,
                ),
                key: Key('act0_shell_action_trail_step_label_${widget.index}'),
                maxLines: 2,
                style: Act0ShellTokensV1.muted.copyWith(
                  fontSize: refined ? 8.8 : 9.5,
                  fontWeight: isLatest ? FontWeight.w900 : FontWeight.w800,
                  color: isLatest
                      ? Act0ShellTokensV1.gold
                      : Act0ShellTokensV1.textMuted.withValues(
                          alpha: refined ? 0.74 : 0.86,
                        ),
                ),
              ),
              if (isLatest) ...[
                SizedBox(width: refined ? 5 : 6),
                Container(
                  key: const Key('act0_shell_action_trail_latest_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                  ),
                  child: Text(
                    act0RuntimeLocalizedLatestBadgeV1(context),
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.gold,
                      fontSize: refined ? 7.4 : 7.8,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatMarkersV1 extends StatelessWidget {
  const _SeatMarkersV1({required this.seatId, required this.markers});

  final String seatId;
  final List<_SeatMarkerKindV1> markers;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: Key('act0_shell_marker_cluster_$seatId'),
      spacing: 3,
      runSpacing: 3,
      children: [
        for (final marker in markers)
          KeyedSubtree(
            key: Key('act0_shell_marker_${seatId}_${marker.name}'),
            child: _MarkerDotV1(marker: marker),
          ),
      ],
    );
  }
}

class _SeatMarkerPlacementV1 extends StatelessWidget {
  const _SeatMarkerPlacementV1({
    required this.seatId,
    required this.leftSide,
    required this.markers,
    required this.hero,
    required this.visualVariant,
  });

  final String seatId;
  final bool leftSide;
  final List<_SeatMarkerKindV1> markers;
  final bool hero;
  final Act0ShellTableVisualVariantV1 visualVariant;

  @override
  Widget build(BuildContext context) {
    final refined = visualVariant == Act0ShellTableVisualVariantV1.refinedDev2;
    final bottomHero = hero;
    return Positioned(
      top: bottomHero ? (refined ? 6 : 4) : (refined ? -10 : -12),
      left: leftSide ? (refined ? -6 : -10) : null,
      right: bottomHero
          ? (refined ? -38 : -48)
          : (leftSide ? null : (refined ? -6 : -10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: refined ? 42 : 50),
        child: _SeatMarkersV1(seatId: seatId, markers: markers),
      ),
    );
  }
}

class _MiniCardBackV1 extends StatelessWidget {
  const _MiniCardBackV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_face_down_card'),
      width: 22,
      height: 31,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radius3xs),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Act0ShellTokensV1.shadowSoftStrong,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF101D30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF172B45), Color(0xFF233B59)],
            ),
            borderRadius: BorderRadius.circular(
              Act0ShellTokensV1.radius3xs - 1.5,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: const SizedBox(key: Key('act0_shell_quiet_card_back')),
        ),
      ),
    );
  }
}

class _BetChipV1 extends StatelessWidget {
  const _BetChipV1({required this.bet, this.compact = false});

  final Act0SeatBetStateV1 bet;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final showLabelPill =
        !(compact &&
            bet.kind == Act0SeatBetKindV1.post &&
            (bet.label == 'SB' || bet.label == 'BB'));
    final color = switch (bet.kind) {
      Act0SeatBetKindV1.post => Act0ShellTokensV1.gold,
      Act0SeatBetKindV1.call => Act0ShellTokensV1.info,
      Act0SeatBetKindV1.bet ||
      Act0SeatBetKindV1.raise => Act0ShellTokensV1.primary,
      Act0SeatBetKindV1.allIn => Act0ShellTokensV1.danger,
    };
    // B4: a commitment is instrumentation sitting on the cloth, not an app
    // card floating over it. Same engraved carrier as the seat nameplate, so
    // identity and commitment read as one attached family. The frosted-glass
    // backdrop blur is gone \u2014 it is an application effect, and felt does not
    // refract. Every bet-kind colour semantic is unchanged.
    return Container(
      key: Key('act0_shell_bet_chip_${bet.label}'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 6,
        vertical: compact ? 3 : 4,
      ),
      decoration: Act0SceneNameplateV1.decoration(
        radius: Act0ShellTokensV1.radiusPill,
        stateTone: color,
        stateStrength: 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ChipStackIconV1(color: color, compact: compact),
          SizedBox(height: compact ? 1 : 2),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showLabelPill)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 3 : 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(
                      Act0ShellTokensV1.radiusPill,
                    ),
                  ),
                  child: Text(
                    bet.label,
                    style: TextStyle(
                      color: color,
                      fontSize: compact ? 5.6 : 6.1,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              if (showLabelPill) SizedBox(height: compact ? 1 : 2),
              Text(
                bet.amountLabel,
                style: TextStyle(
                  color: Act0ShellTokensV1.text,
                  fontSize: compact ? 7.0 : 7.8,
                  height: 0.98,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipStackIconV1 extends StatelessWidget {
  const _ChipStackIconV1({required this.color, this.compact = false});

  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 12 : 14;
    return SizedBox(
      width: size,
      height: size + 4,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            child: _ChipDiscV1(color: color, compact: compact, isBottom: true),
          ),
          Positioned(
            bottom: 2,
            child: _ChipDiscV1(color: color, compact: compact, isBottom: true),
          ),
          Positioned(
            bottom: 4,
            child: _ChipDiscV1(color: color, compact: compact),
          ),
        ],
      ),
    );
  }
}

class _ChipDiscV1 extends StatelessWidget {
  const _ChipDiscV1({
    required this.color,
    this.compact = false,
    this.isBottom = false,
  });

  final Color color;
  final bool compact;
  final bool isBottom;

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 12 : 14;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        gradient: isBottom
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.6),
                  color.withValues(alpha: 0.3),
                ],
              )
            : RadialGradient(
                center: const Alignment(-0.2, -0.4),
                radius: 0.8,
                colors: <Color>[Colors.white.withValues(alpha: 0.4), color],
              ),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Colors.white.withValues(alpha: isBottom ? 0.1 : 0.8),
          width: isBottom ? 0.5 : 1.2,
        ),
        boxShadow: [
          if (isBottom)
            const BoxShadow(
              color: Color(0x66000000),
              blurRadius: 3,
              offset: Offset(0, 2),
            )
          else
            const BoxShadow(
              color: Color(0xAA000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
        ],
      ),
      child: Center(
        child: isBottom
            ? null
            : Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
      ),
    );
  }
}

class _FoldedBadgeV1 extends StatelessWidget {
  const _FoldedBadgeV1();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_folded_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(
          color: Act0ShellTokensV1.border.withValues(alpha: 0.9),
        ),
      ),
      child: Text(
        'Folded',
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.textMuted,
          fontSize: 7,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MarkerDotV1 extends StatelessWidget {
  const _MarkerDotV1({required this.marker});

  final _SeatMarkerKindV1 marker;

  @override
  Widget build(BuildContext context) {
    if (marker == _SeatMarkerKindV1.dealer) {
      // Same dealer semantic, physical expression. Wave A drew a flat white
      // capsule floating above the scene; a dealer button is a pressed disc
      // resting on the cloth. Keys, meaning, seat assignment and telemetry are
      // untouched.
      return const KeyedSubtree(
        key: Key('act0_shell_wave1_dealer_marker'),
        child: Act0SceneDealerPuckV1(
          key: Key('act0_shell_wave1b_button_marker'),
        ),
      );
    }

    final localizedActLabel =
        Localizations.localeOf(
          context,
        ).languageCode.toLowerCase().startsWith('ru')
        ? '\u0425\u043E\u0434'
        : 'Act';
    final (color, label, isCircle) = switch (marker) {
      _SeatMarkerKindV1.dealer => (Colors.white, 'BTN', false),
      _SeatMarkerKindV1.smallBlind => (
        Act0ShellTokensV1.runnerTagBlue,
        'SB',
        true,
      ),
      _SeatMarkerKindV1.bigBlind => (Act0ShellTokensV1.gold, 'BB', true),
      _SeatMarkerKindV1.aggressor => (Act0ShellTokensV1.danger, 'Agg', false),
      _SeatMarkerKindV1.act => (
        Act0ShellTokensV1.primary,
        localizedActLabel,
        false,
      ),
    };

    return Container(
      key:
          marker == _SeatMarkerKindV1.smallBlind ||
              marker == _SeatMarkerKindV1.bigBlind
          ? Key('act0_shell_wave1_blind_marker_${marker.name}')
          : null,
      width: isCircle ? 16 : null,
      height: isCircle ? 16 : null,
      padding: isCircle
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      alignment: isCircle ? Alignment.center : null,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[color, color.withValues(alpha: 0.78)],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: marker == _SeatMarkerKindV1.bigBlind
              ? const Color(0xFF5C3A21)
              : Colors.white,
          fontSize: isCircle ? 6.5 : 7.0,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}

class _CardV1 extends StatelessWidget {
  const _CardV1({required this.card, this.cardId, this.highlighted = false});

  final Act0CardStateV1 card;
  final String? cardId;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = _cardInkColor(card);
    final suit = _displaySuit(card.suit);
    return Act0CardSemanticsV1(
      rank: card.rank,
      suit: card.suit,
      position: cardId?.startsWith('hero_') == true ? 'Your card' : null,
      child: Container(
        key: cardId != null ? Key('act0_shell_card_$cardId') : null,
        width: Act0ShellTokensV1.heroCardWidth,
        height: Act0ShellTokensV1.heroCardHeight,
        constraints: const BoxConstraints(
          minWidth: Act0ShellTokensV1.heroCardWidth,
        ),
        decoration: _playingCardDecorationV1(highlighted: highlighted),
        child: Stack(
          children: [
            if (highlighted)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    key: const Key('act0_scene_clue_bracket'),
                    painter: Act0SceneClueBracketPainterV1(
                      tone: Act0ShellTokensV1.gold,
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusXs,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.8),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.05),
                    ],
                    stops: const <double>[0, 0.4, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 3,
              top: 2,
              child: Text(
                card.rank,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Positioned(
              right: 3,
              bottom: 2,
              child: Text(
                suit.isEmpty ? '' : suit,
                style: TextStyle(color: color, fontSize: 28, height: 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardCardV1 extends StatelessWidget {
  const _BoardCardV1({
    required this.card,
    this.cardId,
    this.highlighted = false,
    this.onTap,
  });

  final Act0CardStateV1 card;
  final String? cardId;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _cardInkColor(card);
    final suit = _displaySuit(card.suit);
    final child = Container(
      key: cardId != null
          ? Key('act0_shell_card_$cardId')
          : const Key('act0_shell_board_card'),
      width: Act0ShellTokensV1.boardCardWidth,
      height: Act0ShellTokensV1.boardCardHeight,
      decoration: _playingCardDecorationV1(
        board: true,
        highlighted: highlighted,
      ),
      child: Stack(
        children: [
          if (highlighted)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  key: const Key('act0_scene_clue_bracket_board'),
                  painter: Act0SceneClueBracketPainterV1(
                    tone: Act0ShellTokensV1.gold,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXs),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.8),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                  stops: const <double>[0, 0.4, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 3,
            top: 1,
            child: Text(
              card.rank,
              style: TextStyle(
                color: color,
                fontSize: 16,
                height: 1.0,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Positioned(
            right: 3,
            bottom: 2,
            child: Text(
              suit.isEmpty ? '' : suit,
              style: TextStyle(color: color, fontSize: 24, height: 1.0),
            ),
          ),
        ],
      ),
    );
    return Act0CardSemanticsV1(
      rank: card.rank,
      suit: card.suit,
      position: cardId?.startsWith('board_') == true
          ? 'Board card ${int.tryParse(cardId!.substring(6)) != null ? int.parse(cardId!.substring(6)) + 1 : cardId!.substring(6)}'
          : 'Board card',
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _Act0ShowdownParticipantV1 {
  const _Act0ShowdownParticipantV1({
    required this.seatId,
    required this.displayLabel,
    required this.cards,
    required this.cardIdsBySolver,
  });

  final String seatId;
  final String displayLabel;
  final List<String> cards;
  final Map<String, List<String>> cardIdsBySolver;
}

class _Act0ShowdownInsightV1 {
  const _Act0ShowdownInsightV1({
    required this.highlightedCardIds,
    required this.summaryLine,
  });

  final List<String> highlightedCardIds;
  final String summaryLine;
}

BoxDecoration _playingCardDecorationV1({
  bool board = false,
  bool highlighted = false,
}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusXs),
    border: Border.all(
      color: highlighted
          ? Act0ShellTokensV1.gold.withValues(alpha: 0.90)
          : const Color(0xFFD1D8E0),
      width: highlighted ? 1.6 : 1,
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 5,
        offset: const Offset(0, 2),
      ),
      // Brackets now do the pointing, so the diffuse halo drops back. A glow
      // this wide reads as the card emitting light rather than as something
      // marking it.
      if (highlighted)
        BoxShadow(
          color: Act0ShellTokensV1.gold.withValues(alpha: 0.20),
          blurRadius: 5,
        ),
    ],
  );
}

Color _cardInkColor(Act0CardStateV1 card) {
  return card.isRedSuit
      ? Act0ShellTokensV1.runnerAnswerDanger
      : Act0ShellTokensV1.runnerAnswerText;
}

String _displaySuit(String suit) {
  switch (suit.trim().toLowerCase()) {
    case 's':
    case 'spade':
    case 'spades':
    case '\u2660':
      return '\u2660';
    case 'h':
    case 'heart':
    case 'hearts':
    case '\u2665':
      return '\u2665';
    case 'd':
    case 'diamond':
    case 'diamonds':
    case '\u2666':
      return '\u2666';
    case 'c':
    case 'club':
    case 'clubs':
    case '\u2663':
      return '\u2663';
    default:
      return suit.toUpperCase();
  }
}
