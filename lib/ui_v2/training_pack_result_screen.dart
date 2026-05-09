import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/v2/training_pack_template.dart';

import 'components/header.dart';
import 'components/body.dart';
import 'components/footer.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/services/ui_telemetry_service.dart';
import 'package:poker_analyzer/services/xp_progress_service.dart';
import 'package:poker_analyzer/services/league_service.dart';
import 'package:poker_analyzer/services/energy_service.dart';
import 'package:poker_analyzer/services/ui_perf_telemetry_service.dart';

/// V2 UI wrapper for the Training Pack Result screen.
///
/// Connects live player services so rewards reflect true XP, energy,
/// and league tier as soon as the screen appears.
class TrainingPackResultScreenV2 extends StatefulWidget {
  final TrainingPackTemplate template;
  final TrainingPackTemplate original;
  final Map<String, String> results;
  final int xpGained;
  final int chipsEarned;

  const TrainingPackResultScreenV2({
    super.key,
    required this.template,
    required this.results,
    required this.original,
    this.xpGained = 0,
    this.chipsEarned = 0,
  });

  @override
  State<TrainingPackResultScreenV2> createState() =>
      _TrainingPackResultScreenV2State();
}

class _TrainingPackResultScreenV2State
    extends State<TrainingPackResultScreenV2> {
  static const _animDuration = Duration(milliseconds: 250);
  static const _animCurve = Curves.easeInOutCubic;

  late Future<_SessionSnapshot> _snapshotFuture;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) return;
      setState(() {
        _snapshotFuture = _loadSnapshot();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(_animDuration);
      UiTelemetryService.instance.recordTransition(
        _animDuration.inMilliseconds,
      );
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<_SessionSnapshot> _loadSnapshot() async {
    final xpService = XpProgressService.instance;
    await xpService.load();
    final energyService = EnergyService();
    final energy = await energyService.getCurrentEnergy();
    final maxEnergy = energyService.getMaxEnergy();
    final xp = xpService.xpTotal;
    final level = xpService.level;
    final tier = LeagueService.instance.getLeagueForXp(xp);
    return _SessionSnapshot(
      level: level,
      energy: energy,
      maxEnergy: maxEnergy,
      tier: tier,
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.template.spots.length;
    final answered = widget.results.length;
    return FutureBuilder<_SessionSnapshot>(
      future: _snapshotFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final summary = snap.data ?? _SessionSnapshot.empty();
        return OrientationBuilder(
          builder: (context, orientation) {
            final width = MediaQuery.of(context).size.width;
            final gap = width >= 900
                ? 24.0
                : width >= 600
                ? 20.0
                : 16.0; // gapMedium adaptive

            final theme = Theme.of(context);
            final brand = theme.extension<BrandTheme>();
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    const Icon(Icons.pets, size: 20),
                    const SizedBox(width: 8),
                    Text(brand?.brandName ?? 'Poker Analyzer'),
                  ],
                ),
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
              body: LayoutBuilder(
                builder: (context, constraints) {
                  final content = Column(
                    children: [
                      AnimatedSwitcher(
                        duration: _animDuration,
                        switchInCurve: _animCurve,
                        switchOutCurve: _animCurve,
                        child: AnimatedPadding(
                          key:
                              ValueKey('header-${widget.template.name}')
                                  as Key?,
                          duration: _animDuration,
                          padding: EdgeInsets.symmetric(horizontal: gap),
                          child: _FadeSlide(
                            duration: _animDuration,
                            child: TrainingPackResultHeader(
                              templateName: widget.template.name,
                              totalSpots: total,
                              answered: answered,
                            ),
                          ),
                        ),
                      ),
                      AnimatedPadding(
                        duration: _animDuration,
                        padding: EdgeInsets.symmetric(
                          horizontal: gap,
                          vertical: gap / 2,
                        ),
                        child: _FadeSlide(
                          duration: _animDuration,
                          child: _LiveSummaryCard(
                            xpGained: widget.xpGained,
                            energy: summary.energy,
                            maxEnergy: summary.maxEnergy,
                            level: summary.level,
                            tier: summary.tier,
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedPadding(
                          duration: _animDuration,
                          padding: EdgeInsets.symmetric(horizontal: gap),
                          child: _FadeSlide(
                            duration: _animDuration,
                            child: TrainingPackResultBody(
                              results: widget.results,
                              spotIds: [
                                for (final s in widget.template.spots) s.id,
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedPadding(
                        duration: _animDuration,
                        padding: EdgeInsets.symmetric(horizontal: gap),
                        child: _FadeSlide(
                          duration: _animDuration,
                          child: TrainingPackResultFooter(
                            onBackToList: () {
                              if (!context.mounted) return;
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ),
                      ),
                    ],
                  );

                  return content;
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _LiveSummaryCard extends StatelessWidget {
  final int xpGained;
  final int energy;
  final int maxEnergy;
  final int level;
  final LeagueTier tier;

  const _LiveSummaryCard({
    required this.xpGained,
    required this.energy,
    required this.maxEnergy,
    required this.level,
    required this.tier,
  });

  String _tierLabel() {
    switch (tier) {
      case LeagueTier.Bronze:
        return '💎 Bronze';
      case LeagueTier.Silver:
        return '💎 Silver';
      case LeagueTier.Gold:
        return '💎 Gold';
      case LeagueTier.Platinum:
        return '💎 Platinum';
      case LeagueTier.Diamond:
        return '💎 Diamond';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandTheme>();
    final radius = brand?.radius ?? 12.0;

    return Container(
      decoration: BoxDecoration(
        color: (brand?.primaryBrand ?? Colors.teal).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: brand?.primaryBrand ?? Colors.teal, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rewards', style: AppTypography.h3),
              const SizedBox(height: 4),
              Text('XP reward: +$xpGained XP', style: AppTypography.body),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Energy: $energy/$maxEnergy', style: AppTypography.body),
              const SizedBox(height: 4),
              Text(
                'Level $level - ${_tierLabel()}',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 4),
              ValueListenableBuilder<UiPerfSnapshot>(
                valueListenable: UiPerfTelemetryService.instance.metrics,
                builder: (context, perf, _) {
                  return Text(
                    'Perf ${perf.fpsAvg.toStringAsFixed(1)} fps '
                    '(miss ${perf.missesPerMinute.toStringAsFixed(1)}/m)',
                    style: AppTypography.caption,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FadeSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const _FadeSlide({required this.child, required this.duration});

  @override
  State<_FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<_FadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..forward();
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeInOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, .04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

class _SessionSnapshot {
  final int level;
  final int energy;
  final int maxEnergy;
  final LeagueTier tier;

  const _SessionSnapshot({
    required this.level,
    required this.energy,
    required this.maxEnergy,
    required this.tier,
  });

  factory _SessionSnapshot.empty() => const _SessionSnapshot(
    level: 1,
    energy: 0,
    maxEnergy: 0,
    tier: LeagueTier.Bronze,
  );
}
