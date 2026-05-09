import 'package:flutter/widgets.dart';

import '../../engine/motion_frame_composer.dart';
import '../../engine/motion_playback_adapter.dart';
import '../design/design_containers.dart';
import '../design/design_tokens.dart';
import '../motion/motion_primitives.dart';

class CardMotionSurface extends StatelessWidget {
  const CardMotionSurface({super.key, this.snapshot});

  final MotionFrameSnapshot? snapshot;

  static const Size _cardSize = Size(56, 80);
  static const Size _chipSize = Size(20, 20);

  @override
  Widget build(BuildContext context) {
    final children = _buildPlaceholders(snapshot);
    return IgnorePointer(
      ignoring: true,
      child: SizedBox.expand(child: Stack(children: children)),
    );
  }

  List<Widget> _buildPlaceholders(MotionFrameSnapshot? snapshot) {
    if (snapshot == null) {
      return const [];
    }
    final entries = <_MotionLayerEntry>[];
    entries.addAll(
      _entriesForChannel(
        snapshot.channels.seat,
        _CardChannel.seat,
        const Color(DesignColors.surfaceLight),
      ),
    );
    entries.addAll(
      _entriesForChannel(
        snapshot.channels.board,
        _CardChannel.board,
        const Color(DesignColors.surfaceElevated),
      ),
    );
    entries.addAll(_chipEntries(snapshot.channels.pot));
    entries.sort(_layerEntryComparator);
    return entries.map((entry) => entry.buildWidget()).toList();
  }

  List<_MotionCardEntry> _entriesForChannel(
    Map<String, MotionPlaybackSample?> channel,
    _CardChannel channelKind,
    Color color,
  ) {
    final overlayColor = _overlayColor(color);
    final result = <_MotionCardEntry>[];
    for (final entry in channel.entries) {
      final sample = entry.value;
      if (sample == null || entry.key.startsWith('pot:')) {
        continue;
      }
      result.add(
        _MotionCardEntry(
          id: entry.key,
          channel: channelKind,
          sample: sample,
          color: overlayColor,
          startMs: sample.progress,
        ),
      );
    }
    return result;
  }

  List<_MotionChipEntry> _chipEntries(
    Map<String, MotionPlaybackSample?> channel,
  ) {
    final seatColor = _overlayColor(const Color(DesignColors.surfaceLight));
    final potColor = _overlayColor(const Color(DesignColors.accent));
    final result = <_MotionChipEntry>[];
    for (final entry in channel.entries) {
      final sample = entry.value;
      if (sample == null) {
        continue;
      }
      final kind = entry.key == 'pot:seat'
          ? _MotionChipKind.seat
          : _MotionChipKind.pot;
      final color = kind == _MotionChipKind.seat ? seatColor : potColor;
      result.add(
        _MotionChipEntry(
          id: entry.key,
          kind: kind,
          sample: sample,
          color: color,
          startMs: sample.progress,
        ),
      );
    }
    return result;
  }

  int _layerEntryComparator(_MotionLayerEntry a, _MotionLayerEntry b) {
    final priorityDiff = a.priority.compareTo(b.priority);
    if (priorityDiff != 0) {
      return priorityDiff;
    }
    final startDiff = a.startMs.compareTo(b.startMs);
    if (startDiff != 0) {
      return startDiff;
    }
    return a.id.compareTo(b.id);
  }

  Color _overlayColor(Color color) {
    final baseAlpha = (color.a * 255.0).round().clamp(0, 255).toInt();
    final overlayAlpha = ((baseAlpha * 0.85).round()).clamp(0, 255).toInt();
    return color.withAlpha(overlayAlpha);
  }
}

abstract class _MotionLayerEntry {
  String get id;
  double get startMs;
  int get priority;
  Widget buildWidget();
}

class _MotionCardEntry implements _MotionLayerEntry {
  const _MotionCardEntry({
    required this.id,
    required this.channel,
    required this.sample,
    required this.color,
    required this.startMs,
  });

  final String id;
  final _CardChannel channel;
  final MotionPlaybackSample sample;
  final Color color;
  final double startMs;

  @override
  int get priority => _channelPriority(channel);

  @override
  Widget buildWidget() => _CardMotionSurfaceHelpers.buildTile(
    sample: sample,
    size: CardMotionSurface._cardSize,
    color: color,
  );
}

class _MotionChipEntry implements _MotionLayerEntry {
  const _MotionChipEntry({
    required this.id,
    required this.kind,
    required this.sample,
    required this.color,
    required this.startMs,
  });

  final String id;
  final _MotionChipKind kind;
  final MotionPlaybackSample sample;
  final Color color;
  final double startMs;

  @override
  int get priority => _chipPriority(kind);

  @override
  Widget buildWidget() => _CardMotionSurfaceHelpers.buildTile(
    sample: sample,
    size: CardMotionSurface._chipSize,
    color: color,
  );
}

enum _CardChannel { seat, board }

enum _MotionChipKind { seat, pot }

int _channelPriority(_CardChannel channel) {
  switch (channel) {
    case _CardChannel.seat:
      return 0;
    case _CardChannel.board:
      return 1;
  }
}

int _chipPriority(_MotionChipKind kind) {
  switch (kind) {
    case _MotionChipKind.seat:
      return 2;
    case _MotionChipKind.pot:
      return 3;
  }
}

class _CardMotionSurfaceHelpers {
  static Widget buildTile({
    required MotionPlaybackSample sample,
    required Size size,
    required Color color,
  }) {
    final left = sample.x - size.width / 2;
    final top = sample.y - size.height / 2;
    final progress = sample.progress.clamp(0.0, 1.0);
    final visual = MotionPrimitives.fadeScale(t: progress);
    final scale = visual['scale'] ?? 1.0;
    final opacity = visual['opacity'] ?? 1.0;
    return Positioned(
      left: left,
      top: top,
      width: size.width,
      height: size.height,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: DesignContainers.card.copyWith(color: color),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
