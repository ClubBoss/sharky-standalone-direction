class SimulationChipTravelBlueprint {
  List<String> buildPreflopChipPaths() => const [
    'seat1 → pot',
    'seat2 → pot',
    'seat3 → pot',
    'seat4 → pot',
  ];

  List<String> buildPostflopChipPaths() => const [
    'seat1 → pot',
    'seat2 → pot',
    'seat3 → side-pot',
  ];

  List<String> buildShowdownChipPaths() => const [
    'pot → winnerA',
    'side-pot → winnerB',
  ];
}
