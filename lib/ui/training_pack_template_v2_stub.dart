import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/ui/session_player/models.dart';

import 'training_type_engine_stub.dart';

class TrainingPackTemplateV2 {
  TrainingPackTemplateV2({
    required this.id,
    required this.name,
    List<String>? tags,
    Map<String, dynamic>? meta,
    required this.trainingType,
    required this.gameType,
    List<TrainingPackSpotStub>? spots,
  }) : tags = List<String>.from(tags ?? const []),
       meta = Map<String, dynamic>.from(meta ?? const {}),
       spots = List<TrainingPackSpotStub>.from(spots ?? const []);

  final String id;
  String name;
  List<String> tags;
  Map<String, dynamic> meta;
  TrainingType trainingType;
  GameType gameType;
  List<TrainingPackSpotStub> spots;

  bool validate() {
    if ((meta['id'] ?? id) != id) return false;
    if (spots.isEmpty) return false;
    return true;
  }
}

class TrainingPackSpotStub {
  const TrainingPackSpotStub({required this.kind, this.data = const {}});

  final SpotKind kind;
  final Map<String, Object?> data;
}

List<TrainingPackTemplateV2> declaredStubPacks() => [
  TrainingPackTemplateV2(
    id: 'push_fold_basics',
    name: 'Push/Fold Basics',
    tags: const ['push-fold', 'training'],
    meta: const {'id': 'push_fold_basics', 'difficulty': 1},
    trainingType: TrainingType.pushFold,
    gameType: GameType.tournament,
    spots: const [
      TrainingPackSpotStub(kind: SpotKind.l2_open_fold),
      TrainingPackSpotStub(kind: SpotKind.l2_threebet_push),
    ],
  ),
  TrainingPackTemplateV2(
    id: 'icm_finals',
    name: 'ICM Finals',
    tags: const ['icm'],
    meta: const {'id': 'icm_finals', 'difficulty': 2},
    trainingType: TrainingType.pushFold,
    gameType: GameType.tournament,
    spots: const [
      TrainingPackSpotStub(kind: SpotKind.l4_icm),
      TrainingPackSpotStub(kind: SpotKind.l4_icm_bubble_jam_vs_fold),
    ],
  ),
];
