import '../ui_v2/table/action_bar_model.dart';
import 'betting_state_engine.dart';
import 'simulation_state_engine.dart';
import 'table_state_engine.dart';

class LegalRaiseBounds {
  const LegalRaiseBounds({
    required this.minRaise,
    required this.maxRaise,
    required this.canRaise,
  });

  final double minRaise;
  final double maxRaise;
  final bool canRaise;
}

class ActionStateEngine {
  const ActionStateEngine({
    required this.activeSeat,
    required this.maxSeat,
    required this.betting,
    required this.table,
  });

  final int activeSeat;
  final int maxSeat;
  final BettingStateEngine betting;
  final TableStateEngine table;

  LegalRaiseBounds computeLegalRaiseAmount() {
    final available = betting.stack.stacks[activeSeat];
    final min = betting.minRaiseAmount();
    final max = betting.contributed[activeSeat] + available;
    final canRaise =
        min > 0 &&
        available > 0 &&
        !table.isFolded(activeSeat) &&
        !betting.stack.isAllIn(activeSeat);
    final safeMax = max < min ? min : max;
    return LegalRaiseBounds(
      minRaise: min,
      maxRaise: safeMax,
      canRaise: canRaise,
    );
  }

  ActionBarModel compute() => _buildModel(betting.pot);

  ActionBarModel rebuildFromSimulationState(SimulationState state) =>
      _buildModel(state.pot.toDouble());

  ActionBarModel _buildModel(double potValue) {
    final canFold = !table.isFolded(activeSeat);
    final toCall = betting.toCall(activeSeat);
    final canCall = toCall > 0 && !betting.stack.isAllIn(activeSeat);
    final raiseBounds = computeLegalRaiseAmount();
    final canRaise = raiseBounds.canRaise;
    return ActionBarModel(
      canFold: canFold,
      canCall: canCall,
      canRaise: canRaise,
      legalFold: canFold,
      legalCall: canCall,
      legalRaise: raiseBounds.canRaise,
      callAmount: betting.callAmount,
      minRaiseAmount: raiseBounds.minRaise,
      maxRaiseAmount: raiseBounds.maxRaise,
      presets: _buildPresets(raiseBounds, potValue),
    );
  }

  List<RaisePreset> _buildPresets(LegalRaiseBounds bounds, double pot) {
    if (!bounds.canRaise || bounds.maxRaise <= bounds.minRaise) {
      return const <RaisePreset>[];
    }
    final candidates = <RaisePreset>[
      RaisePreset(label: 'min', value: bounds.minRaise),
      RaisePreset(label: 'pot', value: pot),
      RaisePreset(label: '2x', value: bounds.minRaise * 2),
      RaisePreset(label: '3x', value: bounds.minRaise * 3),
      RaisePreset(label: 'allin', value: bounds.maxRaise),
    ];
    final seen = <double>{};
    final presets = <RaisePreset>[];
    for (final preset in candidates) {
      final clampedValue = preset.value.clamp(bounds.minRaise, bounds.maxRaise);
      if (clampedValue < bounds.minRaise || clampedValue > bounds.maxRaise) {
        continue;
      }
      if (!seen.add(clampedValue)) {
        continue;
      }
      presets.add(RaisePreset(label: preset.label, value: clampedValue));
    }
    return presets;
  }
}
