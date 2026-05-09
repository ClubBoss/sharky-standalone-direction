import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../action_entry.dart';

@immutable
class SpotHandData {
  const SpotHandData({
    this.heroCards = '',
    this.position = '',
    this.heroIndex = 0,
    this.playerCount = 0,
    this.board = const <String>[],
    this.actions = const <int, List<ActionEntry>>{},
    this.stacks = const <String, double>{},
    this.anteBb = 0,
  });

  factory SpotHandData.fromJson(Map<String, Object?> json) {
    final heroCards = json['heroCards']?.toString() ?? '';
    final position = json['position']?.toString() ?? '';
    final heroIndex = _asInt(json['heroIndex']);
    final playerCount = _asInt(json['playerCount']);
    final board = _stringList(json['board']);
    final anteBb = _asInt(json['anteBb']);
    final stacks = <String, double>{};
    final rawStacks = json['stacks'];
    if (rawStacks is Map) {
      rawStacks.forEach((key, value) {
        final numValue = value as num?;
        if (numValue != null) {
          stacks[key.toString()] = numValue.toDouble();
        }
      });
    }
    final actions = <int, List<ActionEntry>>{};
    final rawActions = json['actions'];
    if (rawActions is Map) {
      rawActions.forEach((key, value) {
        final index = int.tryParse(key.toString()) ?? 0;
        final entries = <ActionEntry>[];
        if (value is List) {
          for (final item in value) {
            if (item is Map) {
              entries.add(
                ActionEntry.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
        actions[index] = entries;
      });
    }
    return SpotHandData(
      heroCards: heroCards,
      position: position,
      heroIndex: heroIndex,
      playerCount: playerCount,
      board: board,
      actions: actions,
      stacks: stacks,
      anteBb: anteBb,
    );
  }

  final String heroCards;
  final String position;
  final int heroIndex;
  final int playerCount;
  final List<String> board;
  final Map<int, List<ActionEntry>> actions;
  final Map<String, double> stacks;
  final int anteBb;

  Map<String, Object?> toJson() => {
    'heroCards': heroCards,
    'position': position,
    'heroIndex': heroIndex,
    'playerCount': playerCount,
    if (board.isNotEmpty) 'board': List<String>.from(board),
    if (actions.isNotEmpty)
      'actions': {
        for (final entry in actions.entries)
          entry.key.toString(): [
            for (final action in entry.value) action.toJson(),
          ],
      },
    if (stacks.isNotEmpty) 'stacks': Map<String, double>.from(stacks),
    if (anteBb != 0) 'anteBb': anteBb,
  };

  SpotHandData copyWith({
    String? heroCards,
    String? position,
    int? heroIndex,
    int? playerCount,
    List<String>? board,
    Map<int, List<ActionEntry>>? actions,
    Map<String, double>? stacks,
    int? anteBb,
  }) => SpotHandData(
    heroCards: heroCards ?? this.heroCards,
    position: position ?? this.position,
    heroIndex: heroIndex ?? this.heroIndex,
    playerCount: playerCount ?? this.playerCount,
    board: board ?? List<String>.from(this.board),
    actions: actions ?? _cloneActions(this.actions),
    stacks: stacks ?? Map<String, double>.from(this.stacks),
    anteBb: anteBb ?? this.anteBb,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotHandData &&
          heroCards == other.heroCards &&
          position == other.position &&
          heroIndex == other.heroIndex &&
          playerCount == other.playerCount &&
          const ListEquality<String>().equals(board, other.board) &&
          const DeepCollectionEquality().equals(actions, other.actions) &&
          const MapEquality<String, double>().equals(stacks, other.stacks) &&
          anteBb == other.anteBb;

  @override
  int get hashCode => Object.hash(
    heroCards,
    position,
    heroIndex,
    playerCount,
    const ListEquality<String>().hash(board),
    const DeepCollectionEquality().hash(actions),
    const MapEquality<String, double>().hash(stacks),
    anteBb,
  );
}

int _asInt(Object? value) => (value as num?)?.toInt() ?? 0;

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return const [];
}

Map<int, List<ActionEntry>> _cloneActions(Map<int, List<ActionEntry>> actions) {
  final clone = <int, List<ActionEntry>>{};
  for (final entry in actions.entries) {
    clone[entry.key] = List<ActionEntry>.from(entry.value);
  }
  return clone;
}
