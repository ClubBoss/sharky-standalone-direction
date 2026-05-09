import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';

import 'simulation_seat_state_layer.dart';

class SimulationSeatsLayer extends StatelessWidget {
  const SimulationSeatsLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SimulationSeatStateLayer(state: SeatState.hero, label: 'Hero Seat'),
            SimulationSeatStateLayer(
              state: SeatState.active,
              label: 'Active Seat',
            ),
            SimulationSeatStateLayer(state: SeatState.empty),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SimulationSeatStateLayer(state: SeatState.empty),
            SimulationSeatStateLayer(state: SeatState.active),
            SimulationSeatStateLayer(state: SeatState.empty),
          ],
        ),
      ],
    );
  }
}
