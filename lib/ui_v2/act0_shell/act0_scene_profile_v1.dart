import 'dart:convert';
import 'package:flutter/material.dart';
import 'act0_shell_state_v1.dart';

/// Presentation opt-in only. It never selects a task or changes learner state.
const kAct0F7TableScenePreview = bool.fromEnvironment(
  'SHARKY_F7_TABLE_SCENE_PREVIEW',
);

enum Act0SceneActorOwnershipV1 { independentLayers, bakedIntoPlate }

/// One approved image and its registration. All points/regions use normalized
/// *original image* coordinates, never canonical-table or screen coordinates.
@immutable
class Act0SceneProfileV1 {
  const Act0SceneProfileV1({
    required this.id,
    required this.assetPath,
    required this.sourceSize,
    required this.tableBoundary,
    required this.feltSafeRegion,
    required this.seatAnchorsFromHero,
    required this.betAnchorsFromHero,
    required this.holeCardAnchorsFromHero,
    required this.dealerAnchorsFromHero,
    required this.heroCardWidth,
    required this.opponentCardWidth,
    required this.boardCardWidth,
    this.heroCardTilt = 0,
    required this.boardAnchor,
    required this.potAnchor,
    required this.streetAnchor,
    required this.clueAnchor,
    required this.heroAnchor,
    required this.uiExclusionZones,
    required this.actorOwnership,
    required this.supportsFoldedSeatedPlayers,
    required this.supportsEmptySeats,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.topCenter,
  });

  final String id, assetPath;
  final Size sourceSize;
  final BoxFit fit;
  final Alignment alignment;
  final List<Offset> tableBoundary;
  final Rect feltSafeRegion;

  /// Clockwise source seat order, rotated so Hero is index zero. Identity is
  /// still resolved by the existing canonical seat-order owner in the Runner.
  final List<Offset> seatAnchorsFromHero, betAnchorsFromHero;
  final List<Offset> holeCardAnchorsFromHero, dealerAnchorsFromHero;

  /// Card widths are fractions of original image width. Existing card widgets
  /// retain their aspect and source state; text/labels are not scaled with art.
  final double heroCardWidth, opponentCardWidth, boardCardWidth, heroCardTilt;
  final Offset heroAnchor, boardAnchor, potAnchor, streetAnchor, clueAnchor;
  final List<Rect> uiExclusionZones;
  final Act0SceneActorOwnershipV1 actorOwnership;
  final bool supportsFoldedSeatedPlayers, supportsEmptySeats;

  double get sourceAspect => sourceSize.width / sourceSize.height;
  bool get paintsIndependentActors =>
      actorOwnership == Act0SceneActorOwnershipV1.independentLayers;

  bool get isValid {
    bool point(Offset p) =>
        p.dx.isFinite &&
        p.dy.isFinite &&
        p.dx >= 0 &&
        p.dx <= 1 &&
        p.dy >= 0 &&
        p.dy <= 1;
    bool rect(Rect r) => !r.isEmpty && point(r.topLeft) && point(r.bottomRight);
    return id.isNotEmpty &&
        assetPath.isNotEmpty &&
        sourceSize.width.isFinite &&
        sourceSize.height.isFinite &&
        sourceSize.width > 0 &&
        sourceSize.height > 0 &&
        tableBoundary.length >= 3 &&
        tableBoundary.every(point) &&
        rect(feltSafeRegion) &&
        seatAnchorsFromHero.length == 6 &&
        betAnchorsFromHero.length == 6 &&
        holeCardAnchorsFromHero.length == 6 &&
        dealerAnchorsFromHero.length == 6 &&
        [
          ...seatAnchorsFromHero,
          ...betAnchorsFromHero,
          ...holeCardAnchorsFromHero,
          ...dealerAnchorsFromHero,
          heroAnchor,
          boardAnchor,
          potAnchor,
          streetAnchor,
          clueAnchor,
        ].every(point) &&
        holeCardAnchorsFromHero.first == heroAnchor &&
        [
          heroCardWidth,
          opponentCardWidth,
          boardCardWidth,
        ].every((v) => v.isFinite && v > 0 && v < .2) &&
        heroCardTilt.isFinite &&
        heroCardTilt.abs() <= .2 &&
        (fit == BoxFit.contain || fit == BoxFit.cover) &&
        alignment.x.isFinite &&
        alignment.y.isFinite &&
        alignment.x.abs() <= 3 &&
        alignment.y.abs() <= 3 &&
        uiExclusionZones.every(rect);
  }

  /// A baked seated person can remain at the table after folding: the existing
  /// Folded badge and card visibility carry that state. An empty seat cannot be
  /// represented by this art. No missing actor/mask/state image is invented.
  bool supports(Act0TableStateV1 table) =>
      isValid &&
      table.tableFormat == Act0TableFormatV1.sixMax &&
      table.playerCount == 6 &&
      table.seats.length == 6 &&
      table.seats.map((s) => s.seatId).toSet().length == 6 &&
      table.seats
          .map((s) => s.seatLabel.toUpperCase())
          .toSet()
          .containsAll(table.canonicalSeatOrder) &&
      table.seats.where((s) => s.isHero).length == 1 &&
      (table.heroSeatId == null || table.heroSeatId == table.heroSeat.seatId) &&
      table.heroCards.length <= 2 &&
      const [0, 3, 4, 5].contains(table.boardCards.length) &&
      table.seats.every(
        (s) =>
            (supportsEmptySeats || s.isOccupied) &&
            (supportsFoldedSeatedPlayers || (!s.isFolded && s.isInHand)) &&
            s.holeCards.length <= 2,
      );

  /// Select once for the complete source scenario, including teaching variants.
  /// Feedback/highlight changes cannot select a different room mid-attempt.
  bool supportsScenario(Iterable<Act0TableStateV1> tables) =>
      tables.isNotEmpty && tables.every(supports);

  Act0SceneRegistrationV1 register(Size viewport) =>
      Act0SceneRegistrationV1(this, viewport);

  Map<String, Object> get calibrationData {
    List<double> point(Offset p) => [p.dx, p.dy];
    return {
      'id': id,
      'labels': seatAnchorsFromHero.map(point).toList(),
      'holeCards': holeCardAnchorsFromHero.map(point).toList(),
      'bets': betAnchorsFromHero.map(point).toList(),
      'dealer': dealerAnchorsFromHero.map(point).toList(),
      'board': point(boardAnchor),
      'pot': point(potAnchor),
      'street': point(streetAnchor),
      'clue': point(clueAnchor),
      'heroCardWidth': heroCardWidth,
      'opponentCardWidth': opponentCardWidth,
      'boardCardWidth': boardCardWidth,
      'heroCardTilt': heroCardTilt,
      'alignment': [alignment.x, alignment.y],
    };
  }
}

/// Single affine image-to-scene transform used by both paint and every overlay.
@immutable
class Act0SceneRegistrationV1 {
  Act0SceneRegistrationV1(this.profile, this.viewport) {
    final fitted = applyBoxFit(profile.fit, profile.sourceSize, viewport);
    sourceRect = profile.alignment.inscribe(
      fitted.source,
      Offset.zero & profile.sourceSize,
    );
    destinationRect = profile.alignment.inscribe(
      fitted.destination,
      Offset.zero & viewport,
    );
  }
  final Act0SceneProfileV1 profile;
  final Size viewport;
  late final Rect sourceRect, destinationRect;
  Offset map(Offset imagePoint) => Offset(
    destinationRect.left +
        (imagePoint.dx * profile.sourceSize.width - sourceRect.left) *
            destinationRect.width /
            sourceRect.width,
    destinationRect.top +
        (imagePoint.dy * profile.sourceSize.height - sourceRect.top) *
            destinationRect.height /
            sourceRect.height,
  );
  Offset unmap(Offset scenePoint) => Offset(
    (sourceRect.left +
            (scenePoint.dx - destinationRect.left) *
                sourceRect.width /
                destinationRect.width) /
        profile.sourceSize.width,
    (sourceRect.top +
            (scenePoint.dy - destinationRect.top) *
                sourceRect.height /
                destinationRect.height) /
        profile.sourceSize.height,
  );
  Rect mapRect(Rect region) =>
      Rect.fromPoints(map(region.topLeft), map(region.bottomRight));
}

/// The existing owner-selected clean plate. Coordinates are provisional for
/// owner-visible F7 calibration, not an accepted/frozen production composition.
/// No state-specific art is available.
/// In particular, there are no empty-chair, removed-player or animated poses.
const act0PremiumTableSceneProfileV1 = Act0SceneProfileV1(
  id: 'owner_clean_six_seated_c1_candidate_v1',
  assetPath:
      'assets/design/sharky/pw_c3/owner_clean_table_candidate_965x1629.png',
  sourceSize: Size(965, 1629),
  // C1 is an owner-selected calibration basis, pending independent review.
  // Uniform contain mapping and this crop apply to both art and overlays.
  alignment: Alignment(0, -1.35),
  tableBoundary: [
    Offset(.37, .35),
    Offset(.69, .35),
    Offset(.83, .60),
    Offset(.90, .79),
    Offset(.74, .90),
    Offset(.27, .90),
    Offset(.12, .78),
    Offset(.24, .57),
  ],
  feltSafeRegion: Rect.fromLTRB(.38, .40, .69, .72),
  heroAnchor: Offset(0.44, 0.7),
  seatAnchorsFromHero: [
    Offset(0.7, 0.715),
    Offset(0.215, 0.665),
    Offset(0.245, 0.455),
    Offset(0.52, 0.35),
    Offset(0.795, 0.455),
    Offset(0.805, 0.665),
  ],
  holeCardAnchorsFromHero: [
    Offset(0.44, 0.7),
    Offset(0.3, 0.615),
    Offset(0.37, 0.445),
    Offset(0.52, 0.395),
    Offset(0.67, 0.445),
    Offset(0.74, 0.615),
  ],
  dealerAnchorsFromHero: [
    Offset(0.84, 0.73),
    Offset(0.28, 0.675),
    Offset(0.29, 0.49),
    Offset(0.61, 0.355),
    Offset(0.75, 0.49),
    Offset(0.74, 0.675),
  ],
  heroCardWidth: .10,
  opponentCardWidth: 0.045,
  boardCardWidth: 0.07,
  heroCardTilt: .035,
  betAnchorsFromHero: [
    Offset(0.63, 0.76),
    Offset(0.27, 0.77),
    Offset(0.3, 0.5),
    Offset(0.63, 0.405),
    Offset(0.74, 0.5),
    Offset(0.74, 0.73),
  ],
  boardAnchor: Offset(0.52, 0.55),
  potAnchor: Offset(0.52, 0.615),
  streetAnchor: Offset(0.52, 0.5),
  clueAnchor: Offset(0.52, 0.455),
  uiExclusionZones: [Rect.fromLTRB(0, 0, 1, .18), Rect.fromLTRB(0, .84, 1, 1)],
  actorOwnership: Act0SceneActorOwnershipV1.bakedIntoPlate,
  supportsFoldedSeatedPlayers: true,
  supportsEmptySeats: false,
);

/// Review calibration is supplied as data, not permanent A/B/C production
/// presets. Bad/missing fields fail closed at the asset/compatibility gate.
Act0SceneProfileV1? act0SceneProfileFromCalibrationV1(String data) {
  if (data.isEmpty) return act0PremiumTableSceneProfileV1;
  try {
    final j = jsonDecode(data) as Map<String, dynamic>;
    Offset point(dynamic v) =>
        Offset((v[0] as num).toDouble(), (v[1] as num).toDouble());
    List<Offset> points(String key) =>
        (j[key] as List).map(point).toList(growable: false);
    final p = act0PremiumTableSceneProfileV1;
    final cards = points('holeCards');
    final result = Act0SceneProfileV1(
      id: '${p.id}_${j['id']}',
      assetPath: p.assetPath,
      sourceSize: p.sourceSize,
      alignment: j['alignment'] == null
          ? p.alignment
          : Alignment(
              (j['alignment'][0] as num).toDouble(),
              (j['alignment'][1] as num).toDouble(),
            ),
      tableBoundary: p.tableBoundary,
      feltSafeRegion: p.feltSafeRegion,
      seatAnchorsFromHero: points('labels'),
      betAnchorsFromHero: points('bets'),
      holeCardAnchorsFromHero: cards,
      dealerAnchorsFromHero: points('dealer'),
      heroAnchor: cards.first,
      boardAnchor: point(j['board']),
      potAnchor: point(j['pot']),
      streetAnchor: point(j['street']),
      clueAnchor: point(j['clue']),
      heroCardWidth: (j['heroCardWidth'] as num).toDouble(),
      opponentCardWidth: (j['opponentCardWidth'] as num).toDouble(),
      boardCardWidth: (j['boardCardWidth'] as num).toDouble(),
      heroCardTilt: (j['heroCardTilt'] as num).toDouble(),
      uiExclusionZones: p.uiExclusionZones,
      actorOwnership: p.actorOwnership,
      supportsFoldedSeatedPlayers: p.supportsFoldedSeatedPlayers,
      supportsEmptySeats: p.supportsEmptySeats,
    );
    return result.isValid ? result : null;
  } catch (_) {
    return null;
  }
}
