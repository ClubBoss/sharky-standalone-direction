part of 'act0_lesson_runner_shell_v1.dart';

/// Builders for table artwork and its stateful pieces. The renderer owns
/// placement, poker state, interaction callbacks and choreography.
abstract interface class TableSkinV1 {
  Widget registeredFelt(ui.Image image, Act0SceneRegistrationV1 registration);
  Widget previewFelt();
  Decoration proceduralRim();
  List<Widget> proceduralFelt({
    required bool integratedPerspective,
    required bool refined,
    required Offset? heroAnchor,
  });
  Widget proceduralRail(Widget child);
  Widget seatPlate({
    required Key key,
    required EdgeInsets padding,
    required Color? stateTone,
    required Widget child,
  });
  Widget cardFace({
    required Act0CardStateV1 card,
    String? cardId,
    required bool highlighted,
  });
  Widget boardCard({
    required Act0CardStateV1 card,
    required String cardId,
    required bool highlighted,
    required VoidCallback onTap,
  });
  Widget cardBack();
  Widget chipStack({required Act0SeatBetStateV1 bet, required bool compact});
  Widget potLabel({
    required Key key,
    required Key legacyKey,
    required String label,
    required Color tone,
    required bool compact,
    bool pulse = false,
  });
  Widget dealerButton();
  Widget actionBadge(String marker);
  Widget foldedBadge();
  Widget turnHighlight(String seatId, Color color);
}

/// The default scope uses the existing Modern Table pieces.
class TableSkinScopeV1 extends InheritedWidget {
  const TableSkinScopeV1({super.key, required this.skin, required super.child});

  final TableSkinV1 skin;

  static TableSkinV1 of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TableSkinScopeV1>()?.skin ??
      const ModernTableSkinV1();

  @override
  bool updateShouldNotify(TableSkinScopeV1 oldWidget) => skin != oldWidget.skin;
}

class ModernTableSkinV1 implements TableSkinV1 {
  const ModernTableSkinV1();

  @override
  Widget registeredFelt(ui.Image image, Act0SceneRegistrationV1 registration) =>
      IgnorePointer(
        child: CustomPaint(
          key: const Key('act0_f7_baked_room_cast_hero'),
          painter: Act0F7RegisteredScenePainterV1(
            image: image,
            registration: registration,
          ),
        ),
      );

  @override
  Widget previewFelt() =>
      DecoratedBox(decoration: Act0ShellTokensV1.feltDecoration());

  @override
  Decoration proceduralRim() => Act0ShellTokensV1.tableRimDecoration();

  @override
  Widget proceduralRail(Widget child) => CustomPaint(
    key: const Key('act0_scene_table_material'),
    painter: const Act0SceneTableMaterialPainterV1(
      railWidth: _act0SceneRailWidthV1,
      railOverhang: _act0SceneRailOverhangV1,
    ),
    child: child,
  );

  @override
  List<Widget> proceduralFelt({
    required bool integratedPerspective,
    required bool refined,
    required Offset? heroAnchor,
  }) => [
    Positioned.fill(
      child: ValueListenableBuilder<bool>(
        valueListenable:
            Act0SceneHybridShellRegistryV1.shellStore.readyNotifier,
        builder: (context, hybridShellReady, _) => Container(
          key: const Key('act0_shell_table_felt'),
          // RENDER_CLASS_HYBRID_INTEGRATION_V1: once the baked
          // shell is ready its own felt/rail owns this pixel
          // area, so the procedural felt fill goes transparent
          // rather than double-painting under the same
          // dynamic-object geometry.
          decoration: !integratedPerspective
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
      valueListenable: Act0SceneHybridShellRegistryV1.shellStore.readyNotifier,
      builder: (context, hybridShellReady, _) =>
          integratedPerspective && !hybridShellReady
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
          decoration: integratedPerspective
              ? ShapeDecoration(
                  shape: Act0SceneTableShapeV1(
                    side: BorderSide(
                      color: Act0ShellTokensV1.feltLine.withValues(alpha: 0.30),
                      width: 1,
                    ),
                  ),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.tableInnerRadius,
                  ),
                  border: Border.all(
                    color: Act0ShellTokensV1.feltLine.withValues(alpha: 0.30),
                  ),
                ),
        ),
      ),
    ),
    Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: integratedPerspective
              ? ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.white.withValues(alpha: refined ? 0.06 : 0.04),
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
                      Colors.white.withValues(alpha: refined ? 0.06 : 0.04),
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
    if (heroAnchor != null)
      Positioned.fill(
        child: IgnorePointer(
          child: ClipPath(
            clipper: const ShapeBorderClipper(shape: Act0SceneTableShapeV1()),
            child: CustomPaint(
              key: const Key('act0_scene_hero_near_plane'),
              painter: Act0SceneHeroPlanePainterV1(heroAnchor: heroAnchor),
            ),
          ),
        ),
      ),
  ];

  @override
  Widget seatPlate({
    required Key key,
    required EdgeInsets padding,
    required Color? stateTone,
    required Widget child,
  }) => Container(
    key: key,
    padding: padding,
    decoration: Act0SceneNameplateV1.decoration(
      radius: Act0ShellTokensV1.radiusSm,
      stateTone: stateTone,
      stateStrength: stateTone == null ? 0.0 : 1.0,
    ),
    child: child,
  );

  @override
  Widget cardFace({
    required Act0CardStateV1 card,
    String? cardId,
    required bool highlighted,
  }) => _CardV1(card: card, cardId: cardId, highlighted: highlighted);

  @override
  Widget boardCard({
    required Act0CardStateV1 card,
    required String cardId,
    required bool highlighted,
    required VoidCallback onTap,
  }) => _BoardCardV1(
    card: card,
    cardId: cardId,
    highlighted: highlighted,
    onTap: onTap,
  );

  @override
  Widget cardBack() => const _MiniCardBackV1();

  @override
  Widget chipStack({required Act0SeatBetStateV1 bet, required bool compact}) =>
      _BetChipV1(bet: bet, compact: compact);

  @override
  Widget potLabel({
    required Key key,
    required Key legacyKey,
    required String label,
    required Color tone,
    required bool compact,
    bool pulse = false,
  }) => _CenterPriorityStatV1(
    key: key,
    legacyKey: legacyKey,
    label: label,
    tone: tone,
    compact: compact,
    pulse: pulse,
  );

  @override
  Widget dealerButton() => const KeyedSubtree(
    key: Key('act0_shell_wave1_dealer_marker'),
    child: Act0SceneDealerPuckV1(key: Key('act0_shell_wave1b_button_marker')),
  );

  @override
  Widget actionBadge(String marker) =>
      _MarkerDotV1(marker: _SeatMarkerKindV1.values.byName(marker));

  @override
  Widget foldedBadge() => const _FoldedBadgeV1();

  @override
  Widget turnHighlight(String seatId, Color color) => IgnorePointer(
    child: DecoratedBox(
      key: const Key('act0_shell_active_seat_ring'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusSm),
        border: Border.all(color: color.withValues(alpha: .42), width: 2),
      ),
      child: SizedBox(key: Key('act0_shell_active_seat_ring_$seatId')),
    ),
  );
}
