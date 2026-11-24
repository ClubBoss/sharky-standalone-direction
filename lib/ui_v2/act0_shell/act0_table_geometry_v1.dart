part of 'act0_lesson_runner_shell_v1.dart';

/// Table positions in the provider's normalized coordinate space.
/// Registered art uses its source image space. Preview uses the viewport.
class TableGeometryV1 {
  TableGeometryV1.registered(Act0SceneRegistrationV1 registration)
    : this._(
        viewport: registration.viewport,
        referenceWidth: registration.destinationRect.width,
        map: registration.map,
        seatAnchors: registration.profile.seatAnchorsFromHero,
        betAnchors: registration.profile.betAnchorsFromHero,
        cardAnchors: registration.profile.holeCardAnchorsFromHero,
        dealerAnchors: registration.profile.dealerAnchorsFromHero,
        boardAnchor: registration.profile.boardAnchor,
        potAnchor: registration.profile.potAnchor,
        streetAnchor: registration.profile.streetAnchor,
        clueAnchor: registration.profile.clueAnchor,
        heroCardWidth: registration.profile.heroCardWidth,
        opponentCardWidth: registration.profile.opponentCardWidth,
        boardCardWidth: registration.profile.boardCardWidth,
        heroCardTilt: registration.profile.heroCardTilt,
        registeredCardClearance: true,
      );

  /// Placeholder ring, starting at the hero and continuing in source order.
  factory TableGeometryV1.preview({
    required Size viewport,
    required int seatCount,
  }) {
    if (seatCount < 2 || seatCount > 9) {
      throw RangeError.range(seatCount, 2, 9, 'seatCount');
    }
    const center = Offset(.5, .5);
    final seats = List<Offset>.generate(seatCount, (index) {
      final angle = 2 * math.pi * index / seatCount;
      return Offset(.5 - .35 * math.sin(angle), .5 + .34 * math.cos(angle));
    }, growable: false);
    return TableGeometryV1._(
      viewport: viewport,
      referenceWidth: viewport.width,
      map: (point) =>
          Offset(point.dx * viewport.width, point.dy * viewport.height),
      seatAnchors: List.unmodifiable(seats),
      betAnchors: List.unmodifiable([
        for (final seat in seats) Offset.lerp(seat, center, .27)!,
      ]),
      cardAnchors: List.unmodifiable([
        for (final seat in seats) seat.translate(0, -.065),
      ]),
      dealerAnchors: List.unmodifiable([
        for (final seat in seats)
          seat.translate(seat.dx < .5 ? .105 : -.105, .025),
      ]),
      boardAnchor: const Offset(.5, .49),
      potAnchor: const Offset(.5, .58),
      streetAnchor: const Offset(.5, .41),
      clueAnchor: const Offset(.5, .35),
      heroCardWidth: .085,
      opponentCardWidth: .045,
      boardCardWidth: .066,
      heroCardTilt: .035,
    );
  }

  const TableGeometryV1._({
    required this.viewport,
    required this.referenceWidth,
    required this.map,
    required this.seatAnchors,
    required this.betAnchors,
    required this.cardAnchors,
    required this.dealerAnchors,
    required this.boardAnchor,
    required this.potAnchor,
    required this.streetAnchor,
    required this.clueAnchor,
    required this.heroCardWidth,
    required this.opponentCardWidth,
    required this.boardCardWidth,
    required this.heroCardTilt,
    this.registeredCardClearance = false,
  });

  final Size viewport;
  final double referenceWidth;
  final Offset Function(Offset) map;
  final List<Offset> seatAnchors, betAnchors, cardAnchors, dealerAnchors;
  final Offset boardAnchor, potAnchor, streetAnchor, clueAnchor;
  final double heroCardWidth, opponentCardWidth, boardCardWidth, heroCardTilt;
  final bool registeredCardClearance;

  Offset normalizedViewportPoint(Offset anchor) {
    final point = map(anchor);
    return Offset(point.dx / viewport.width, point.dy / viewport.height);
  }

  Offset holeCardsAnchor(
    int slot, {
    required bool revealedOpponent,
    required bool hasPrice,
  }) {
    final anchor = cardAnchors[slot];
    if (!registeredCardClearance || !revealedOpponent) return anchor;
    return anchor +
        switch (slot) {
          3 => const Offset(0, .028),
          5 when hasPrice => const Offset(.08, -.045),
          _ => Offset.zero,
        };
  }

  static Offset proceduralCenterOffset(double height, bool hasRepairCallout) =>
      Offset(0, hasRepairCallout ? height * .075 : 0);

  static List<Offset> proceduralSeatAnchors(
    Act0ShellTableVisualVariantV1 variant, {
    bool compactBottomDockClearance = false,
    bool useAnswerListPerimeterRing = false,
  }) {
    switch (variant) {
      case Act0ShellTableVisualVariantV1.classic:
        return _classicSeatAnchors;
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

  static List<Offset> proceduralBetAnchors(
    Act0ShellTableVisualVariantV1 variant, {
    bool compactBottomDockClearance = false,
  }) {
    switch (variant) {
      case Act0ShellTableVisualVariantV1.classic:
        return _classicBetAnchors;
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

  static const List<Offset> _classicSeatAnchors = <Offset>[
    Offset(0.50, 0.90),
    Offset(0.08, 0.72),
    Offset(0.06, 0.36),
    Offset(0.50, 0.08),
    Offset(0.94, 0.36),
    Offset(0.92, 0.72),
  ];

  static const List<Offset> _classicBetAnchors = <Offset>[
    Offset(0.50, 0.75),
    Offset(0.055, 0.60),
    Offset(0.055, 0.50),
    Offset(0.50, 0.25),
    Offset(0.945, 0.50),
    Offset(0.945, 0.60),
  ];
}

/// Debug opt-in shared by the authored catalog and the F2 table preview.
class Act0NineSeatDebugScopeV1 extends InheritedWidget {
  const Act0NineSeatDebugScopeV1({
    super.key,
    this.enabled = tableNineSeatV1,
    required super.child,
  });

  static const tableNineSeatV1 = act0NineSeatDebugEnabledV1;
  final bool enabled;

  static bool enabledOf(BuildContext context, {bool listen = true}) {
    if (!kDebugMode) return false;
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<Act0NineSeatDebugScopeV1>()
        : context.getInheritedWidgetOfExactType<Act0NineSeatDebugScopeV1>();
    return scope?.enabled ?? tableNineSeatV1;
  }

  @override
  bool updateShouldNotify(Act0NineSeatDebugScopeV1 oldWidget) =>
      enabled != oldWidget.enabled;
}
