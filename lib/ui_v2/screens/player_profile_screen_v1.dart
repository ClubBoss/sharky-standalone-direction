import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/learning_stats_v1_service.dart';

class PlayerProfileScreenV1 extends StatelessWidget {
  const PlayerProfileScreenV1({super.key});

  Future<Map<String, int>> _loadCountersV1() async {
    final expectedActionMismatchCount = await LearningStatsV1Service.instance
        .getExpectedActionMismatchErrorCount();
    final toCallLegalityMismatchCount = await LearningStatsV1Service.instance
        .getToCallLegalityMismatchErrorCount();
    return <String, int>{
      'expected_action_mismatch': expectedActionMismatchCount,
      'tocall_legality_mismatch': toCallLegalityMismatchCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Map<String, int>>(
        future: _loadCountersV1(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final counters = snapshot.data!;
          final expectedActionMismatchCount =
              counters['expected_action_mismatch'] ?? 0;
          final toCallLegalityMismatchCount =
              counters['tocall_legality_mismatch'] ?? 0;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _MetricTileV1(
                label: 'Expected action mismatches',
                value: expectedActionMismatchCount,
              ),
              const SizedBox(height: 12),
              _MetricTileV1(
                label: 'To-call legality mismatches',
                value: toCallLegalityMismatchCount,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricTileV1 extends StatelessWidget {
  const _MetricTileV1({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          '$value',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
