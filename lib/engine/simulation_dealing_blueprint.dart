class SimulationDealingBlueprint {
  List<String> buildPreflopDealing() => const [
    'deck → seat1',
    'deck → seat2',
    'deck → seat3',
    'deck → seat4',
    'deck → seat5',
  ];

  List<String> buildFlopDealing() => const [
    'deck → flop1',
    'deck → flop2',
    'deck → flop3',
  ];

  List<String> buildTurnDealing() => const ['deck → turn'];

  List<String> buildRiverDealing() => const ['deck → river'];
}
