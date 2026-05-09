import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui_v2/session_playback_engine.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_engine.dart';
import 'package:poker_analyzer/ui_v2/simulation/simulation_telemetry.dart';

class SimulationReviewScreen extends StatefulWidget {
  const SimulationReviewScreen({super.key, this.maxEntries = 100});

  final int maxEntries;

  @override
  State<SimulationReviewScreen> createState() => _SimulationReviewScreenState();
}

class _SimulationReviewScreenState extends State<SimulationReviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  List<Map<String, dynamic>> _entries = const [];
  bool _loading = true;
  StreamSubscription? _poller;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _load();
    // Lightweight polling so the screen picks up new history while open (dev convenience)
    _poller = Stream.periodic(
      const Duration(seconds: 3),
    ).listen((_) => _load());
    // Telemetry: review opened
    unawaited(SimulationTelemetry.logReviewOpened());
  }

  Future<void> _load() async {
    final recent = await SimulationHistoryRecorder.getRecentSessions(
      widget.maxEntries,
    );
    if (!mounted) return;
    setState(() {
      _entries = recent;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _poller?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final bg = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Simulation Review')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Column(
              children: [
                _buildBankrollChart(context),
                const SizedBox(height: 8),
                Expanded(child: _buildTimeline(context, brand)),
              ],
            ),
    );
  }

  Widget _buildBankrollChart(BuildContext context) {
    // Build cumulative bankroll trend from hero_ev_diff entries
    final values = <double>[];
    double sum = 0;
    for (final e in _entries.reversed) {
      final v = (e['hero_ev_diff'] as num?)?.toDouble() ?? 0.0;
      sum += v;
      values.add(sum);
    }
    final data = values.isEmpty ? [0.0] : values;
    return SizedBox(
      height: 140,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => CustomPaint(
          painter: _LineChartPainter(
            data: data,
            progress: Curves.easeInOut.transform(_anim.value),
            color:
                (Theme.of(context).extension<BrandTheme>()?.primaryBrand ??
                Colors.green),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, BrandTheme? brand) {
    if (_entries.isEmpty) {
      return Center(child: Text('No sessions yet', style: AppTypography.body));
    }
    final maxAbs =
        _entries
            .map((e) => ((e['hero_ev_diff'] as num?)?.toDouble() ?? 0).abs())
            .fold<double>(1, max) +
        1e-6;
    return ListView.builder(
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final e = _entries[index];
        final ts = (e['ts'] as String?) ?? '';
        final diff = (e['hero_ev_diff'] as num?)?.toDouble() ?? 0.0;
        final positive = diff >= 0;
        final pct = (diff.abs() / maxAbs).clamp(0.0, 1.0);
        final barColor = positive
            ? (brand?.accentSuccess ?? Colors.green)
            : Theme.of(context).colorScheme.error;
        return ListTile(
          title: Text(ts, style: AppTypography.body),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              SizedBox(
                height: 8,
                child: Align(
                  alignment: positive
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: pct,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${positive ? '+' : '-'}${diff.abs().toStringAsFixed(0)}',
                style: AppTypography.caption,
              ),
            ],
          ),
          onTap: () => _openReplay(context, e),
        );
      },
    );
  }

  void _openReplay(BuildContext context, Map<String, dynamic> entry) {
    final actions = <PlaybackAction>[];
    final raw = (entry['actions'] as List?)?.cast<Map>() ?? const [];
    for (final m in raw) {
      final seat = (m['seat'] as num?)?.toInt() ?? 0;
      final name = (m['action'] as String?)?.toLowerCase() ?? 'none';
      final amt = (m['amount'] as num?)?.toInt() ?? 0;
      final type = _toPlaybackType(name);
      actions.add(PlaybackAction(seat: seat, type: type, amount: amt));
    }
    // Telemetry: hand replay
    unawaited(SimulationTelemetry.logHandReplayed());

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PokerSessionPlaybackWidget(
          actions: actions,
          board: const [],
          potHistory: const [],
          positions: const ['BTN', 'SB', 'BB', 'UTG', 'MP', 'CO', 'HJ', 'LJ'],
          playerCount: 6,
          initialStacks: List<int>.generate(6, (i) => 1500),
          stepDuration: const Duration(milliseconds: 1200),
        ),
      ),
    );
  }

  PlaybackActionType _toPlaybackType(String name) {
    switch (name) {
      case 'check':
        return PlaybackActionType.check;
      case 'bet':
        return PlaybackActionType.bet;
      case 'call':
        return PlaybackActionType.call;
      case 'raise':
        return PlaybackActionType.raise;
      case 'fold':
        return PlaybackActionType.fold;
      case 'allin':
      case 'all_in':
      case 'allinbet':
        return PlaybackActionType.bet;
      default:
        return PlaybackActionType.none;
    }
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.progress,
    required this.color,
  });

  final List<double> data;
  final double progress; // 0..1
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    if (data.isEmpty) return;

    final maxV = data.reduce(max);
    final minV = data.reduce(min);
    final span = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
    final path = Path();
    final n = (data.length * progress).clamp(1, data.length).toInt();
    for (int i = 0; i < n; i++) {
      final x = size.width * (i / max(1, data.length - 1));
      final yNorm = (data[i] - minV) / span;
      final y = size.height - (yNorm * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
