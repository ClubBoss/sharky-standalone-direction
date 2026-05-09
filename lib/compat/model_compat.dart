import "dart:core" as core;
import 'dart:core';
import 'package:poker_analyzer/helpers/hand_history_parsing.dart';
import 'package:poker_analyzer/models/action_entry.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/models/saved_hand.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v1;
import 'package:poker_analyzer/models/v2/hero_position.dart';

extension TrainingPackTemplateCompat on TrainingPackTemplateV2 {
  /// Legacy hex color expected by v1 flows.
  String get defaultColor =>
      meta['colorTag']?.toString() ?? meta['color']?.toString() ?? '#2196F3';

  /// Legacy saved-hand projection synthesized from template spots.
  List<SavedHand> get hands => [
    for (final spot in spots) spot._legacySavedHand(),
  ];

  /// Materializes a v1 template for code that still depends on it.
  v1.TrainingPackTemplateV2 toLegacyTemplate() =>
      v1.TrainingPackTemplateV2.fromJson(
        Map<String, dynamic>.from(toJson())
          ..['spots'] = [for (final s in spots) s.toJson()],
      );
}

class TrainingPackTemplateV2Compat {
  static TrainingPackTemplateV2 fromYamlString(String s) =>
      TrainingPackTemplateV2.fromYamlAuto(s);
}

extension TrainingPackSpotCompat on TrainingPackSpot {
  /// Creates a SavedHand snapshot understood by legacy widgets.
  SavedHand _legacySavedHand() {
    final data = hand,
        count = data.playerCount > 0 ? data.playerCount : 2,
        hero = data.heroIndex >= 0 && data.heroIndex < count
            ? data.heroIndex
            : 0,
        heroCards = _parseCards(data.heroCards),
        board = _parseCards(data.board.join(' '));
    final stacks = {
      for (var i = 0; i < count; i++) i: 0,
      for (final entry in data.stacks.entries)
        if (int.tryParse(entry.key) case final idx?) idx: entry.value.round(),
    };
    final actions = <ActionEntry>[
          for (final list in data.actions.values)
            for (final action in list) action.copy(),
        ],
        street = _boardStreet(data.board.length, actions);
    return SavedHand(
      name: title.isNotEmpty ? title : id,
      spotId: id,
      heroIndex: hero,
      heroPosition: data.position.label,
      numberOfPlayers: count,
      playerCards: List<List<CardModel>>.generate(
        count,
        (i) => i == hero ? List<CardModel>.from(heroCards) : <CardModel>[],
      ),
      boardCards: board,
      boardStreet: street,
      actions: actions,
      stackSizes: stacks,
      playerPositions: {
        for (var i = 0; i < count; i++)
          i: i == hero ? data.position.label : 'P${i + 1}',
      },
      tags: List<String>.from(tags),
    );
  }
}

/// Parses space separated card strings into models.
List<CardModel> _parseCards(String input) {
  final trimmed = input.trim(),
      tokens = trimmed.isEmpty
          ? const <String>[]
          : trimmed.split(RegExp(r'\s+'));
  final items = tokens.length == 1 && tokens.single.length == 4
      ? [tokens.single.substring(0, 2), tokens.single.substring(2)]
      : tokens;
  return [
    for (final token in items)
      if (parseCard(token) case final card?) card,
  ];
}

/// Determines the furthest street touched by board or actions.
int _boardStreet(int boardLen, List<ActionEntry> actions) => actions.fold(
  boardLen >= 5
      ? 3
      : boardLen >= 4
      ? 2
      : boardLen >= 3
      ? 1
      : 0,
  (maxStreet, action) => action.street > maxStreet ? action.street : maxStreet,
);
