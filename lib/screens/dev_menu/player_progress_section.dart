import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../../services/xp_progress_service.dart';

/// Dev menu section for Player Progress (Experimental).
/// Shows XP, level, and achievements count.
class PlayerProgressSection extends StatefulWidget {
  const PlayerProgressSection({super.key});

  @override
  State<PlayerProgressSection> createState() => _PlayerProgressSectionState();
}

class _PlayerProgressSectionState extends State<PlayerProgressSection> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await XpProgressService.instance.load();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final service = XpProgressService.instance;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Player Progress (Experimental)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildRow('XP Total', '${service.xpTotal}'),
          _buildRow('Level', '${service.level}'),
          _buildRow(
            'XP in Level',
            '${service.xpInCurrentLevel} / ${XpProgressService.xpPerLevel}',
          ),
          _buildRow('Next Level In', '${service.xpForNextLevel} XP'),
          _buildRow('Achievements', '${service.achievementsCount}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _testAddXp,
            child: const Text('Test: Add 100 XP'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _testAchievement,
            child: const Text('Test: Unlock Achievement'),
          ),
          const SizedBox(height: 24),
          Text(
            'Adaptive Drift Visualizer',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _AdaptiveDriftMiniBar(),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _testAddXp() async {
    await XpProgressService.instance.addXp(100);
    setState(() {});
  }

  Future<void> _testAchievement() async {
    final id = 'test_${DateTime.now().millisecondsSinceEpoch}';
    await XpProgressService.instance.logAchievement(id, 'Test Achievement');
    setState(() {});
  }
}

class _AdaptiveDriftMiniBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<double>>(
      future: _loadHistory(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final values = snap.data ?? const <double>[];
        if (values.isEmpty) {
          return Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text('No drift data yet'),
          );
        }
        final maxAbs = values
            .map((e) => e.abs())
            .fold<double>(0, (a, b) => a > b ? a : b)
            .clamp(1e-6, 1e9);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final v in values)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: (56 * (v.abs() / maxAbs)).clamp(4, 56),
                    decoration: BoxDecoration(
                      color: v >= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<List<double>> _loadHistory() async {
    try {
      final f = File('ui_metrics.json');
      if (!await f.exists()) return const <double>[];
      final raw = await f.readAsString();
      final data = jsonDecode(raw);
      if (data is Map && data['adaptive_drift_history'] is List) {
        return (data['adaptive_drift_history'] as List)
            .whereType<num>()
            .map((e) => e.toDouble())
            .toList();
      }
    } catch (_) {}
    return const <double>[];
  }
}
