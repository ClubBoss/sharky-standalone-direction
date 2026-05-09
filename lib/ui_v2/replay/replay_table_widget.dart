import 'dart:async';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/replay/replay_engine.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

/// Visual replay widget with timeline scrubber for reviewing past simulations.
///
/// Displays table state reconstruction with interactive timeline control.
/// Animations optimized for < 5ms/frame performance.
class ReplayTableWidget extends StatefulWidget {
  const ReplayTableWidget({
    required this.engine,
    this.onScrubAction,
    super.key,
  });

  final ReplayEngine engine;
  final VoidCallback? onScrubAction;

  @override
  State<ReplayTableWidget> createState() => _ReplayTableWidgetState();
}

class _ReplayTableWidgetState extends State<ReplayTableWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  StreamSubscription<ReplaySnapshot>? _eventSubscription;
  ReplaySnapshot? _currentSnapshot;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _currentSnapshot = widget.engine.currentSnapshot;
    _fadeController.forward();

    // Subscribe to replay events
    _eventSubscription = widget.engine.events.listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _currentSnapshot = snapshot;
      });
      // Trigger fade animation on snapshot change
      _fadeController.forward(from: 0.7);
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
        border: Border.all(
          color: brand?.primaryBrand.withValues(alpha: 0.3) ?? Colors.blue,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Main replay view
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildReplayView(context),
            ),
          ),

          // Timeline scrubber
          _buildTimelineScrubber(context),
        ],
      ),
    );
  }

  Widget _buildReplayView(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final snapshot = _currentSnapshot;

    if (snapshot == null) {
      return const Center(
        child: Text('No replay data', style: TextStyle(color: Colors.white70)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Event type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getEventColor(snapshot.type).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(brand?.radius ?? 8),
              border: Border.all(
                color: _getEventColor(snapshot.type),
                width: 1,
              ),
            ),
            child: Text(
              snapshot.type.toUpperCase(),
              style: TextStyle(
                color: _getEventColor(snapshot.type),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Event description
          if (snapshot.description != null)
            Text(
              snapshot.description!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.4,
              ),
            ),

          const SizedBox(height: 16),

          // Event details
          _buildEventDetails(snapshot),

          const SizedBox(height: 16),

          // Progress indicator
          Text(
            'Event ${snapshot.eventIndex + 1} of ${widget.engine.totalSnapshots}',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(ReplaySnapshot snapshot) {
    final details = <String, String>{};

    if (snapshot.action != null) {
      details['Action'] = snapshot.action!;
    }
    if (snapshot.amount != null) {
      details['Amount'] = '${snapshot.amount} BB';
    }
    if (snapshot.street != null) {
      details['Street'] = snapshot.street!;
    }
    if (snapshot.pot != null) {
      details['Pot'] = '${snapshot.pot} BB';
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: details.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                TextSpan(
                  text: '${entry.key}: ',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: entry.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineScrubber(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final progress = widget.engine.progress;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrubber slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: brand?.primaryBrand ?? Colors.blue,
              inactiveTrackColor: Colors.white24,
              thumbColor: brand?.primaryBrand ?? Colors.blue,
              overlayColor: (brand?.primaryBrand ?? Colors.blue).withValues(
                alpha: 0.2,
              ),
            ),
            child: Slider(
              value: progress,
              onChanged: (value) {
                widget.engine.seekToProgress(value);
                widget.onScrubAction?.call();
              },
            ),
          ),

          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTimestamp(_currentSnapshot?.timestamp),
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
                Text(
                  '${widget.engine.currentIndex + 1} / ${widget.engine.totalSnapshots}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'action':
        return Colors.amber;
      case 'street_change':
        return Colors.blue;
      case 'pot_update':
        return Colors.green;
      case 'round_end':
        return Colors.purple;
      case 'summary':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '--:--:--';

    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }
}
