import 'package:flutter/foundation.dart';

@immutable
class World1FoundationsEntryMetadataV1 {
  const World1FoundationsEntryMetadataV1({
    required this.titleText,
    required this.descriptionText,
  });

  final String titleText;
  final String descriptionText;
}

World1FoundationsEntryMetadataV1? resolveWorld1FoundationsEntryMetadataV1(
  String moduleId,
) {
  final normalized = moduleId.trim().toLowerCase();
  return switch (normalized) {
    'world1_act0_table_literacy' => const World1FoundationsEntryMetadataV1(
      titleText: 'Table map',
      descriptionText: 'Lock Button, small blind, and big blind first.',
    ),
    'world1_act0_action_literacy' => const World1FoundationsEntryMetadataV1(
      titleText: 'First action choices',
      descriptionText: 'Raise, call, and fold from the right seat in order.',
    ),
    'world1_act0_street_flow' => const World1FoundationsEntryMetadataV1(
      titleText: 'Street flow reads',
      descriptionText:
          'Track flop, turn, and river without losing the table anchor.',
    ),
    'world1_spine_campaign_v1' => const World1FoundationsEntryMetadataV1(
      titleText: 'Campaign spine',
      descriptionText:
          'Carry the opener skills into the first full World 1 campaign run.',
    ),
    _ => null,
  };
}
