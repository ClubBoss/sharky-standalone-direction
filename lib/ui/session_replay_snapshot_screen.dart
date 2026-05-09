import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/session_replay_snapshot_service.dart';

class SessionReplaySnapshotScreen extends StatefulWidget {
  const SessionReplaySnapshotScreen({super.key});

  @override
  State<SessionReplaySnapshotScreen> createState() =>
      _SessionReplaySnapshotScreenState();
}

class _SessionReplaySnapshotScreenState
    extends State<SessionReplaySnapshotScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    lowerBound: 0.9,
    upperBound: 1.1,
  )..repeat(reverse: true);

  late Future<SessionReplaySnapshot> _future = SessionReplaySnapshotService
      .instance
      .loadLatestSnapshot();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Replay Snapshot')),
      body: FutureBuilder<SessionReplaySnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _controller.value,
                              child: child,
                            );
                          },
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Session ${data.sessionId}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _StatRow(
                      label: 'EV %',
                      value: data.evPercent.toStringAsFixed(1),
                      suffix: '%',
                    ),
                    _StatRow(
                      label: 'Accuracy',
                      value: data.accuracyPercent.toStringAsFixed(1),
                      suffix: '%',
                    ),
                    _StatRow(
                      label: 'XP Gain',
                      value: data.xpGain.toStringAsFixed(1),
                    ),
                    _StatRow(
                      label: 'Duration',
                      value: _formatDuration(data.duration),
                    ),
                    _StatRow(
                      label: 'Quizzes',
                      value: data.quizCount.toString(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, this.suffix});

  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            suffix == null ? value : '$value$suffix',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
