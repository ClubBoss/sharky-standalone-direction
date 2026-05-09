/// Canonical title and subtitle metadata for Act0 packs.
class World1Act0PackMetaV1 {
  const World1Act0PackMetaV1({required this.title, required this.subtitle});

  /// Short human-readable title shown on map nodes and in the runner app bar.
  final String title;

  /// One-sentence learning objective shown in the map node preview.
  final String subtitle;
}

/// Returns metadata for the given Act0 [packId], or `null` for unknown IDs.
///
/// All strings are ASCII-only and safe for all display contexts.
World1Act0PackMetaV1? world1Act0PackMetaV1(String packId) {
  return switch (packId.trim().toLowerCase()) {
    'world1_act0_table_literacy' => const World1Act0PackMetaV1(
      title: 'Meet the table',
      subtitle: 'Identify the 3 key seats: Button, Small Blind, Big Blind.',
    ),
    'world1_act0_action_literacy' => const World1Act0PackMetaV1(
      title: 'What you can do',
      subtitle: 'Fold, call, or raise - pick the right move for your seat.',
    ),
    'world1_act0_street_flow' => const World1Act0PackMetaV1(
      title: 'Read the board',
      subtitle: 'Flop, turn, river - your action changes with the street.',
    ),
    _ => null,
  };
}
