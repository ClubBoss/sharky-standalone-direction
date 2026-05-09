import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/smart_pack_store_adapter.dart';

typedef SmartPackLaunchCallback =
    Future<void> Function(BuildContext context, SmartPackRecommendation pack);

class SmartPackStoreWidget extends StatefulWidget {
  const SmartPackStoreWidget({
    super.key,
    this.onLaunchPack,
    this.adapter = const SmartPackStoreAdapter(),
  });

  final SmartPackLaunchCallback? onLaunchPack;
  final SmartPackStoreAdapter adapter;

  @override
  State<SmartPackStoreWidget> createState() => _SmartPackStoreWidgetState();
}

class _SmartPackStoreWidgetState extends State<SmartPackStoreWidget> {
  late Future<List<SmartPackRecommendation>> _future;
  bool _impressionLogged = false;

  @override
  void initState() {
    super.initState();
    _future = widget.adapter.fetchTopPacks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SmartPackRecommendation>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final packs = snapshot.data ?? const [];
        if (packs.isEmpty) {
          return _EmptyState(onRetry: _reload);
        }
        if (!_impressionLogged) {
          _impressionLogged = true;
          widget.adapter.logTelemetry(action: 'shown');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Pack Recommendations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...packs.map(
              (pack) => _SmartPackCard(
                pack: pack,
                onLaunch: () => _launchPack(context, pack),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchPack(
    BuildContext context,
    SmartPackRecommendation pack,
  ) async {
    await widget.adapter.logTelemetry(action: 'launch', pack: pack);
    if (widget.onLaunchPack != null) {
      await widget.onLaunchPack!(context, pack);
      return;
    }
    final route = '/training_pack';
    try {
      await Navigator.of(context).pushNamed(route, arguments: pack.path);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Launching ${pack.topic} (${pack.path})')),
      );
    }
  }

  void _reload() {
    setState(() {
      _future = widget.adapter.fetchTopPacks();
      _impressionLogged = false;
    });
  }
}

class _SmartPackCard extends StatelessWidget {
  const _SmartPackCard({required this.pack, required this.onLaunch});

  final SmartPackRecommendation pack;
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pack.topic,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Persona: ${pack.persona}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  label: 'EV',
                  value: '${pack.evPercent.toStringAsFixed(1)}%',
                ),
                _StatChip(
                  label: 'Difficulty',
                  value: pack.difficulty.toStringAsFixed(2),
                ),
                _StatChip(
                  label: 'Resonance',
                  value: pack.resonance.toStringAsFixed(2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onLaunch,
                child: const Text('Play Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(label: Text('$label: $value')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Smart packs unavailable.'),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
