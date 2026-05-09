import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui/session_player/models.dart';
import 'package:poker_analyzer/ui/session_player/spot_specs.dart' as specs;

/// Lightweight struct describing adaptive tuning values for the visualizer.
class PokerTableTuning {
  const PokerTableTuning({
    required this.difficultyMultiplier,
    required this.repetitionRate,
  });

  final double difficultyMultiplier;
  final double repetitionRate;

  static const PokerTableTuning defaults = PokerTableTuning(
    difficultyMultiplier: 1.0,
    repetitionRate: 0.25,
  );
}

Future<PokerTableTuning> loadPokerTableTuning({
  String path = 'adaptive_learning_summary.json',
}) async {
  final file = File(path);
  if (!await file.exists()) return PokerTableTuning.defaults;
  try {
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return PokerTableTuning.defaults;
    }

    Map<String, dynamic>? loopV2;
    if (decoded['loop_v2'] is Map<String, dynamic>) {
      loopV2 = decoded['loop_v2'] as Map<String, dynamic>;
    }

    final diff =
        _asDouble(loopV2?['difficultyMultiplier']) ??
        _asDouble(decoded['difficultyMultiplier']) ??
        1.0;
    final rep =
        _asDouble(loopV2?['topicRepetitionRate']) ??
        _asDouble(decoded['topicRepetitionRate']) ??
        0.25;

    return PokerTableTuning(
      difficultyMultiplier: diff.isNaN ? 1.0 : diff.clamp(0.5, 1.6),
      repetitionRate: rep.isNaN ? 0.25 : rep.clamp(0.0, 1.0),
    );
  } catch (_) {
    return PokerTableTuning.defaults;
  }
}

/// PokerTableVisualizer
///
/// Lightweight 6-max layout showing hero/villain actions, board texture,
/// and adaptive intensity based on the latest adaptive loop signals.
class PokerTableVisualizer extends StatelessWidget {
  const PokerTableVisualizer({
    super.key,
    required this.spotKind,
    required this.heroAction,
    required this.villainAction,
    required this.board,
    required this.pot,
    required this.positions,
    this.playerCount = 6,
    this.difficultyMultiplier = 1.0,
    this.repetitionRate = 0.25,
  }) : assert(playerCount >= 2 && playerCount <= 10);

  final SpotKind spotKind;
  final String heroAction;
  final String villainAction;
  final List<String> board;
  final String pot;
  final List<String> positions;
  final int playerCount;
  final double difficultyMultiplier;
  final double repetitionRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandTheme>();
    final surface = theme.colorScheme.surface;
    final baseColor = brand?.primaryBrand ?? AppColors.primaryBrand;
    final normalizedDifficulty = _clamp01((difficultyMultiplier - 0.7) / 0.8);
    final accent =
        Color.lerp(surface, baseColor, normalizedDifficulty) ?? surface;

    final repetitionOpacity =
        repetitionRate.clamp(0.05, 0.9).toDouble() * 0.6 + 0.2;
    final shadowStrength = 12 + 18 * repetitionRate.clamp(0.0, 1.0);
    final shadow = AppColors.shadow.withValues(
      alpha: 0.25 + normalizedDifficulty * 0.35,
    );
    final tableTint = baseColor.withValues(
      alpha: _clamp01(0.5 + 0.5 * normalizedDifficulty),
    );

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(brand?.radius ?? 12),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: shadowStrength, spreadRadius: 2),
        ],
        border: Border.all(
          color: accent.withValues(alpha: repetitionOpacity),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.all(brand?.spacingMedium ?? 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = max(constraints.maxHeight, width * 0.6);
          final normalizedCount = playerCount.clamp(2, 10).toInt();
          final seatLabels = _normalizeSeats(positions, normalizedCount);
          final seatOffsets = _computeSeatOffsets(
            normalizedCount,
            seatRadius: _seatRadius(normalizedCount),
          );

          return SizedBox(
            height: height,
            child: Stack(
              children: [
                _TableOval(accent: tableTint),
                ..._buildSeats(context, seatLabels, seatOffsets, accent),
                _buildCenterPot(context),
                _buildBoard(context),
                _buildActionBanner(context),
                _buildFooter(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Iterable<Widget> _buildSeats(
    BuildContext context,
    List<String> labels,
    List<Offset> offsets,
    Color accent,
  ) sync* {
    final heroLabelIndex = labels.indexWhere(
      (label) => label.toLowerCase().contains('hero'),
    );
    final villainLabelIndex = labels.indexWhere(
      (label) => label.toLowerCase().contains('villain'),
    );

    for (var i = 0; i < offsets.length; i++) {
      final label = labels[i];
      final info = _SeatInfo.fromLabel(label, i);
      final isHero = i == heroLabelIndex;
      final isVillain = i == villainLabelIndex;
      final badgeColor = isHero
          ? accent
          : isVillain
          ? accent.withValues(alpha: 0.6)
          : AppColors.surfaceVariant.withValues(alpha: 0.9);

      yield Align(
        alignment: Alignment(offsets[i].dx, offsets[i].dy),
        child: _SeatBadge(
          label: info.displayName,
          stack: info.stackLabel,
          spotKind: spotKind,
          badgeColor: badgeColor,
          isHero: isHero,
          isVillain: isVillain,
        ),
      );
    }
  }

  Widget _buildCenterPot(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.merge(AppTypography.body);
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pot', style: style),
          Text(pot, style: AppTypography.h3.copyWith(color: AppColors.accent)),
        ],
      ),
    );
  }

  Widget _buildBoard(BuildContext context) {
    final cards = board.take(5).toList();
    if (cards.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 56),
        child: Wrap(
          spacing: 8,
          children: cards
              .map(
                (card) => _CardChip(
                  label: card,
                  highlight: specs.isJamFold(spotKind),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildActionBanner(BuildContext context) {
    final textStyle = AppTypography.label;
    return Positioned(
      left: 0,
      right: 0,
      top: 12,
      child: Column(
        children: [
          _ActionBadge(label: spotKind.name, style: AppTypography.h3),
          const SizedBox(height: 4),
          _ActionBadge(label: 'Hero: $heroAction', style: textStyle),
          const SizedBox(height: 2),
          _ActionBadge(label: 'Villain: $villainAction', style: textStyle),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final style = AppTypography.label.copyWith(color: Colors.white70);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            children: const [
              _ActionButton(label: 'Check'),
              _ActionButton(label: 'Bet'),
              _ActionButton(label: 'Fold'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Adaptive Loop ×${difficultyMultiplier.toStringAsFixed(2)} • Repetition ${(repetitionRate * 100).toStringAsFixed(0)}%',
            style: style,
          ),
        ],
      ),
    );
  }

  List<String> _normalizeSeats(List<String> seats, int targetCount) {
    const fallback = [
      'Hero BTN (40bb)',
      'SB (35bb)',
      'BB Villain (45bb)',
      'UTG (30bb)',
      'MP (42bb)',
      'CO (38bb)',
      'HJ (33bb)',
      'LJ (37bb)',
      'UTG+1 (31bb)',
      'BTN+1 (36bb)',
    ];
    final buffer = List<String>.from(seats);
    if (buffer.length < targetCount) {
      buffer.addAll(fallback.skip(buffer.length));
    }
    return buffer.take(targetCount).toList();
  }
}

List<Offset> _computeSeatOffsets(int count, {required double seatRadius}) {
  final step = (2 * pi) / count;
  const startAngle = pi / 2; // hero bottom center
  return List<Offset>.generate(count, (index) {
    final angle = startAngle + index * step;
    final x = cos(angle) * seatRadius;
    final y = sin(angle) * seatRadius;
    return Offset(x, y);
  });
}

double _seatRadius(int count) {
  final base = 0.7 + (count - 6) * 0.04;
  return base.clamp(0.55, 0.88).toDouble();
}

class _TableOval extends StatelessWidget {
  const _TableOval({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _TablePainter(accent)));
  }
}

class _TablePainter extends CustomPainter {
  _TablePainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final radiusX = size.width / 2.2;
    final radiusY = size.height / 2.8;

    final path = Path()
      ..addOval(
        Rect.fromCenter(
          center: center,
          width: radiusX * 2,
          height: radiusY * 2,
        ),
      );

    final accentAlpha = accent.a;
    final fill = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.surfaceVariant.withValues(alpha: 0.9),
          accent.withValues(alpha: _clamp01(accentAlpha)),
        ],
      ).createShader(path.getBounds());

    final border = Paint()
      ..color = accent.withValues(alpha: _clamp01(accentAlpha + 0.1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SeatBadge extends StatelessWidget {
  const _SeatBadge({
    required this.label,
    required this.stack,
    required this.spotKind,
    required this.badgeColor,
    required this.isHero,
    required this.isVillain,
  });

  final String label;
  final String stack;
  final SpotKind spotKind;
  final Color badgeColor;
  final bool isHero;
  final bool isVillain;

  @override
  Widget build(BuildContext context) {
    final text = label;
    final style = AppTypography.label.copyWith(
      color: isHero || isVillain ? Colors.white : AppColors.textSecondaryDark,
    );

    final stackStyle = AppTypography.caption.copyWith(
      color: isHero ? Colors.white70 : AppColors.textSecondaryDark,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isHero)
            BoxShadow(color: badgeColor.withValues(alpha: 0.4), blurRadius: 12),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: style),
          if (stack.isNotEmpty) Text(stack, style: stackStyle),
          if (isHero)
            Text(
              specs.isJamFold(spotKind) ? 'Jam/Fold' : 'Action',
              style: AppTypography.caption.copyWith(color: Colors.white70),
            ),
        ],
      ),
    );
  }
}

class _SeatInfo {
  const _SeatInfo({required this.displayName, required this.stackLabel});

  final String displayName;
  final String stackLabel;

  static _SeatInfo fromLabel(String raw, int index) {
    final matcher = RegExp(r'\(([^)]+)\)').firstMatch(raw);
    final extracted = matcher?.group(1)?.trim();
    final cleaned = matcher != null
        ? raw.replaceFirst(matcher.group(0)!, '').trim()
        : raw.trim();
    final fallbackName = cleaned.isEmpty ? 'Seat ${index + 1}' : cleaned;
    final fallbackStack = 'Stack ${(index + 1) * 10}bb';
    return _SeatInfo(
      displayName: fallbackName,
      stackLabel: extracted?.isNotEmpty ?? false ? extracted! : fallbackStack,
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip({required this.label, this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? AppColors.accentSuccess.withValues(alpha: 0.6)
        : AppColors.surfaceVariant;
    return Container(
      width: 44,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: AppTypography.h3.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.label, required this.style});

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: style),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(label, style: AppTypography.label),
    );
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

double _clamp01(double value) => value.clamp(0.0, 1.0).toDouble();
