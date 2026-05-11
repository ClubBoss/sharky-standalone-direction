enum PathNodeKindV1 { pack, review, checkpoint, optionalPack }

class PathNodeV1 {
  const PathNodeV1._({required this.kind, this.packId, this.reason});

  const PathNodeV1.pack(String packId)
    : this._(kind: PathNodeKindV1.pack, packId: packId);

  const PathNodeV1.review({required String reason})
    : this._(kind: PathNodeKindV1.review, reason: reason);

  const PathNodeV1.checkpoint({required String reason})
    : this._(kind: PathNodeKindV1.checkpoint, reason: reason);

  const PathNodeV1.optionalPack({
    required String packId,
    required String reason,
  }) : this._(
         kind: PathNodeKindV1.optionalPack,
         packId: packId,
         reason: reason,
       );

  final PathNodeKindV1 kind;
  final String? packId;
  final String? reason;
}

List<PathNodeV1> buildPathNodesV1({
  required List<String> packIds,
  required String nextPackId,
  required int completedPacksCount,
  required bool hasReviewQueueForNextPack,
  int rhythmEveryN = 3,
}) {
  final normalizedPackIds = packIds
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toList(growable: false);
  final nodes = normalizedPackIds.map(PathNodeV1.pack).toList(growable: true);
  final normalizedNextPackId = nextPackId.trim();
  if (normalizedPackIds.isEmpty || normalizedNextPackId.isEmpty) {
    return nodes;
  }
  final nextIndex = normalizedPackIds.indexOf(normalizedNextPackId);
  if (nextIndex < 0) {
    return nodes;
  }

  final safeRhythmEveryN = rhythmEveryN <= 0 ? 3 : rhythmEveryN;
  final checkpointDue =
      completedPacksCount > 0 && completedPacksCount % safeRhythmEveryN == 0;
  final insertions = <PathNodeV1>[];
  if (hasReviewQueueForNextPack) {
    insertions.add(
      PathNodeV1.review(
        reason: checkpointDue ? 'Review required' : 'Missed spots ready',
      ),
    );
  }
  if (checkpointDue) {
    insertions.add(const PathNodeV1.checkpoint(reason: 'Checkpoint'));
  }
  if (insertions.isEmpty) {
    _insertOptionalAppliedDrillsV1(
      nodes: nodes,
      normalizedPackIds: normalizedPackIds,
      completedPacksCount: completedPacksCount,
    );
    return nodes;
  }
  nodes.insertAll(nextIndex, insertions);

  _insertOptionalAppliedDrillsV1(
    nodes: nodes,
    normalizedPackIds: normalizedPackIds,
    completedPacksCount: completedPacksCount,
  );
  return nodes;
}

void _insertOptionalAppliedDrillsV1({
  required List<PathNodeV1> nodes,
  required List<String> normalizedPackIds,
  required int completedPacksCount,
}) {
  List<String> anchorCandidatesForSpecV1(
    ({String packId, String anchorPackId, int completedAfter, String reason})
    spec,
  ) {
    if (spec.packId == 'world2_streets_demo_v1') {
      return const <String>[
        'world2_spine_followup_v1_b2',
        'world2_spine_followup_v1_b1',
        'world2_spine_followup_v1_b0',
      ];
    }
    return <String>[spec.anchorPackId];
  }

  const drillSpecs =
      <
        ({
          String packId,
          String anchorPackId,
          int completedAfter,
          String reason,
        })
      >[
        (
          packId: 'world1_streets_demo_v1',
          anchorPackId: 'world1_spine_campaign_v1',
          completedAfter: 1,
          reason: 'Streets Drill',
        ),
        (
          packId: 'world2_streets_demo_v1',
          anchorPackId: 'world2_spine_followup_v1_b2',
          completedAfter: 2,
          reason: 'Streets Challenge',
        ),
        (
          packId: 'world3_streets_demo_v1',
          anchorPackId: 'world3_spine_campaign_v1',
          completedAfter: 3,
          reason: 'Streets Challenge',
        ),
      ];

  for (final spec in drillSpecs) {
    final anchorCandidates = anchorCandidatesForSpecV1(spec);
    final anchorPackId = anchorCandidates.firstWhere(
      normalizedPackIds.contains,
      orElse: () => '',
    );
    final shouldInsert =
        completedPacksCount >= spec.completedAfter &&
        anchorPackId.isNotEmpty &&
        !nodes.any((node) => node.packId == spec.packId);
    if (!shouldInsert) continue;

    final anchorIndex = nodes.indexWhere(
      (node) => node.kind == PathNodeKindV1.pack && node.packId == anchorPackId,
    );
    if (anchorIndex < 0) continue;

    nodes.insert(
      anchorIndex + 1,
      PathNodeV1.optionalPack(packId: spec.packId, reason: spec.reason),
    );
  }
}
