class SimulationMotionBlueprint {
  SimulationMotionBlueprint(this.dealing, this.chipTravel, this.gesture);

  final dynamic dealing;
  final dynamic chipTravel;
  final dynamic gesture;

  Map<String, List<String>> buildAll() => {
    'dealing': [
      ...dealing.buildPreflopDealing(),
      ...dealing.buildFlopDealing(),
      ...dealing.buildTurnDealing(),
      ...dealing.buildRiverDealing(),
    ],
    'chip': [
      ...chipTravel.buildPreflopChipPaths(),
      ...chipTravel.buildPostflopChipPaths(),
      ...chipTravel.buildShowdownChipPaths(),
    ],
    'gesture': [
      ...gesture.buildTapPaths(),
      ...gesture.buildSwipePaths(),
      ...gesture.buildHoldPaths(),
    ],
  };
}
