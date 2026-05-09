class RaisePreset {
  const RaisePreset({required this.label, required this.value});

  final String label;
  final double value;
}

class ActionBarModel {
  const ActionBarModel({
    this.canFold = true,
    this.canCall = true,
    this.canRaise = true,
    this.legalFold = true,
    this.legalCall = true,
    this.legalRaise = true,
    this.callAmount = 0,
    this.minRaiseAmount = 0,
    this.maxRaiseAmount = 0,
    this.presets = const <RaisePreset>[],
  });

  final bool canFold;
  final bool canCall;
  final bool canRaise;
  final bool legalFold;
  final bool legalCall;
  final bool legalRaise;
  final double callAmount;
  final double minRaiseAmount;
  final double maxRaiseAmount;
  final List<RaisePreset> presets;
}
