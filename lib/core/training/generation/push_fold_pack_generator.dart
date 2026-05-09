import 'package:uuid/uuid.dart';
import '../../../models/v2/training_pack_template.dart';
import '../../../models/v2/training_pack_spot.dart';
import '../../../models/v2/hand_data.dart';
import '../../../models/v2/hero_position.dart';
import '../../../models/game_type.dart';
import '../../../services/pack_generator_service.dart';
import '../../../services/hand_range_library.dart';

class PushFoldPackGenerator {
  final Uuid _uuid;
  const PushFoldPackGenerator({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  TrainingPackTemplate generate({
    required GameType gameType,
    int bb = 0,
    List<int>? bbList,
    required List<String> positions,
    int count = 25,
    String? rangeGroup,
    bool multiplePositions = false,
  }) {
    final stacks = bbList == null || bbList.isEmpty ? [bb] : bbList;
    final posList = positions.map(parseHeroPosition).toList();
    final hands = rangeGroup != null
        ? HandRangeLibrary.getGroup(rangeGroup)
        : PackGeneratorService.topNHands(count).toList();
    final spots = <TrainingPackSpot>[];
    var index = 1;
    for (final stack in stacks) {
      for (final pos in posList) {
        for (final hand in hands) {
          final cards = _firstCombo(hand);
          final data = HandData.fromSimpleInput(cards, pos, stack);
          spots.add(
            TrainingPackSpot(
              id: '${_uuid.v4()}_${index++}',
              title: multiplePositions
                  ? '$hand push ${stack}BB from ${pos.label}'
                  : '$hand push ${stack}BB',
              hand: data,
              tags: const ['pushfold'],
            ),
          );
        }
        if (!multiplePositions) break;
      }
    }
    final now = DateTime.now();
    final firstStack = stacks.first;
    final tpl = TrainingPackTemplate(
      id: _uuid.v4(),
      name: 'Push/Fold ${firstStack}BB',
      description: 'Auto pack ${stacks.join(',')}BB ${positions.join(', ')}',
      gameType: gameType,
      spots: spots,
      heroBbStack: firstStack,
      playerStacksBb: [firstStack, firstStack],
      heroPos: posList.isEmpty ? HeroPosition.sb : posList.first,
      spotCount: spots.length,
      anteBb: 0,
      bbCallPct: 20,
      heroRange: hands,
      createdAt: now,
      lastGeneratedAt: now,
    );
    int evCovered = 0;
    int icmCovered = 0;
    int totalWeight = 0;
    for (final spot in spots) {
      final weight = spot.priority;
      totalWeight += weight;
      if (spot.heroEv != null) evCovered += weight;
      if (spot.heroIcmEv != null) icmCovered += weight;
    }
    tpl.meta['evCovered'] = evCovered;
    tpl.meta['icmCovered'] = icmCovered;
    tpl.meta['totalWeight'] = totalWeight;
    return tpl;
  }

  String _firstCombo(String hand) {
    const suits = ['h', 'd', 'c', 's'];
    if (hand.length == 2) {
      final r = hand[0];
      return '$r${suits[0]} $r${suits[1]}';
    }
    final r1 = hand[0];
    final r2 = hand[1];
    final suited = hand.length == 3 && hand[2] == 's';
    if (suited) return '$r1${suits[0]} $r2${suits[0]}';
    return '$r1${suits[0]} $r2${suits[1]}';
  }
}
