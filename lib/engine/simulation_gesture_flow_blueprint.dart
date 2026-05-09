class SimulationGestureFlowBlueprint {
  List<String> buildTapPaths() => const [
    'tap: seat1',
    'tap: seat3',
    'tap: action-bar',
  ];

  List<String> buildSwipePaths() => const [
    'swipe-left: board',
    'swipe-right: board',
    'swipe-down: deck',
  ];

  List<String> buildHoldPaths() => const ['hold: pot', 'hold: chip-stack'];
}
