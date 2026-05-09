import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/replay/replay_engine.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';

/// Control panel for replay playback with Play/Pause/Step/Fast-forward.
///
/// Displays real-time replay metrics and provides interactive controls
/// with 300ms animations.
class ReplayControlsPanel extends StatefulWidget {
  const ReplayControlsPanel({
    required this.engine,
    required this.replayDurationMs,
    required this.userScrubActions,
    this.onPlay,
    this.onPause,
    this.onStepForward,
    this.onStepBackward,
    this.onReset,
    this.onSpeedChange,
    super.key,
  });

  final ReplayEngine engine;
  final int replayDurationMs;
  final int userScrubActions;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onStepForward;
  final VoidCallback? onStepBackward;
  final VoidCallback? onReset;
  final ValueChanged<double>? onSpeedChange;

  @override
  State<ReplayControlsPanel> createState() => _ReplayControlsPanelState();
}

class _ReplayControlsPanelState extends State<ReplayControlsPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  String _lastActionButton = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animateButton(String buttonId) {
    if (_lastActionButton == buttonId && _animController.isAnimating) return;
    _lastActionButton = buttonId;
    _animController.forward().then((_) => _animController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
        border: Border.all(
          color: brand?.primaryBrand.withValues(alpha: 0.3) ?? Colors.blue,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: brand?.primaryBrand.withValues(alpha: 0.15) ?? Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(brand?.radius ?? 12),
                topRight: Radius.circular(brand?.radius ?? 12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.replay,
                  color: brand?.primaryBrand ?? Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'REPLAY CONTROLS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Metrics display
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMetricRow(
                  'Duration',
                  _formatDuration(widget.replayDurationMs),
                  Icons.timer_outlined,
                  brand,
                ),
                const SizedBox(height: 8),
                _buildMetricRow(
                  'Scrub Actions',
                  '${widget.userScrubActions}',
                  Icons.touch_app,
                  brand,
                ),
                const SizedBox(height: 8),
                _buildMetricRow(
                  'Speed',
                  '${widget.engine.playbackSpeed.toStringAsFixed(1)}x',
                  Icons.speed,
                  brand,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white24),

          // Playback controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main controls row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.skip_previous,
                      onPressed: widget.engine.canStepBackward
                          ? () {
                              _animateButton('step_back');
                              widget.engine.stepBackward();
                              widget.onStepBackward?.call();
                            }
                          : null,
                      tooltip: 'Step Back',
                      brand: brand,
                      buttonId: 'step_back',
                    ),
                    _buildControlButton(
                      icon: widget.engine.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      onPressed: () {
                        _animateButton('play_pause');
                        if (widget.engine.isPlaying) {
                          widget.engine.pause();
                          widget.onPause?.call();
                        } else {
                          widget.engine.play();
                          widget.onPlay?.call();
                        }
                        setState(() {});
                      },
                      tooltip: widget.engine.isPlaying ? 'Pause' : 'Play',
                      brand: brand,
                      isPrimary: true,
                      buttonId: 'play_pause',
                    ),
                    _buildControlButton(
                      icon: Icons.skip_next,
                      onPressed: widget.engine.canStepForward
                          ? () {
                              _animateButton('step_forward');
                              widget.engine.stepForward();
                              widget.onStepForward?.call();
                            }
                          : null,
                      tooltip: 'Step Forward',
                      brand: brand,
                      buttonId: 'step_forward',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Secondary controls row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSmallButton(
                      icon: Icons.restart_alt,
                      onPressed: () {
                        _animateButton('reset');
                        widget.engine.reset();
                        widget.onReset?.call();
                        setState(() {});
                      },
                      tooltip: 'Reset',
                      brand: brand,
                    ),
                    _buildSpeedButton('0.5x', 0.5, brand),
                    _buildSpeedButton('1x', 1.0, brand),
                    _buildSpeedButton('2x', 2.0, brand),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    IconData icon,
    BrandTheme? brand,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    required BrandTheme? brand,
    required String buttonId,
    bool isPrimary = false,
  }) {
    final isActive = _lastActionButton == buttonId;

    return Tooltip(
      message: tooltip,
      child: ScaleTransition(
        scale: isActive ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          iconSize: isPrimary ? 36 : 28,
          color: onPressed == null
              ? Colors.white30
              : (isPrimary
                    ? (brand?.primaryBrand ?? Colors.blue)
                    : Colors.white70),
          style: IconButton.styleFrom(
            backgroundColor: isPrimary
                ? (brand?.primaryBrand.withValues(alpha: 0.2) ?? Colors.blue)
                : Colors.white.withValues(alpha: 0.05),
            shape: const CircleBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required BrandTheme? brand,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        iconSize: 20,
        color: Colors.white60,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
          shape: const CircleBorder(),
        ),
      ),
    );
  }

  Widget _buildSpeedButton(String label, double speed, BrandTheme? brand) {
    final isActive = (widget.engine.playbackSpeed - speed).abs() < 0.01;

    return InkWell(
      onTap: () {
        widget.engine.setSpeed(speed);
        widget.onSpeedChange?.call(speed);
        setState(() {});
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? (brand?.primaryBrand.withValues(alpha: 0.2) ?? Colors.blue)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? (brand?.primaryBrand ?? Colors.blue)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? (brand?.primaryBrand ?? Colors.blue)
                : Colors.white60,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatDuration(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${seconds}s';
  }
}
