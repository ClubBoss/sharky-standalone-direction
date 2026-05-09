import 'package:flutter/material.dart';

class Psi2FirstSpotFlowV1 {
  const Psi2FirstSpotFlowV1();

  Widget buildPsi2Entry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Sharky First Spot'),
          SizedBox(height: 8),
          Text('Persona Preview: Balanced'),
          SizedBox(height: 6),
          Text('Coaching Preview: Focus on first read.'),
          SizedBox(height: 4),
          Text('First Spot Preview'),
          SizedBox(height: 16),
          Text('psi2_first_spot_entry'),
          SizedBox(height: 16),
          TextButton(onPressed: null, child: Text('Next')),
        ],
      ),
    );
  }

  Widget buildPsi2Step(String id, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sharky First Spot'),
          const SizedBox(height: 8),
          const Text('Persona Preview: Balanced'),
          const SizedBox(height: 6),
          const Text('Coaching Preview: Focus on first read.'),
          const SizedBox(height: 4),
          const Text('First Spot Preview'),
          const SizedBox(height: 16),
          Text('psi2_step_$id'),
          const SizedBox(height: 16),
          const TextButton(onPressed: null, child: Text('Next')),
        ],
      ),
    );
  }
}
