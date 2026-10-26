part of 'act0_learn_path_shell_v1.dart';

/// Presentation state only. Eligibility and selection remain with the shell.
class _WorldsBOverlayV1 extends StatefulWidget {
  const _WorldsBOverlayV1({required this.model});
  final _WorldMenuOverlayV1 model;
  @override
  State<_WorldsBOverlayV1> createState() => _WorldsBOverlayV1State();
}

class _WorldsBOverlayV1State extends State<_WorldsBOverlayV1> {
  bool _full = false;
  final _scroll = ScrollController();
  static const ink = Act0HomeNorthStarPaletteV1.ink;
  static const aqua = Act0HomeNorthStarPaletteV1.aqua;
  static const text = Color(0xFFE5F3F4);
  static const muted = Color(0xFF8CA9AF);
  static const line = Color(0xFF22454E);
  TextStyle type(double size, {Color color = text, bool bold = false}) =>
      TextStyle(
        fontSize: size,
        height: 1.22,
        color: color,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      );
  Widget glyph(String asset, {Color color = aqua, int turn = 0}) => RotatedBox(
    quarterTurns: turn,
    child: Act0AcademyGlyphV1(asset: asset, color: color, size: 21),
  );
  bool open(Act0WorldCardV1 w) => w.isSelectable && !w.isLocked;
  String title(Act0WorldCardV1 w) => act0AcademyWorldTitleV1(context, w);
  String state(Act0WorldCardV1 w) => !open(w)
      ? 'Locked'
      : w.status == Act0WorldStateV1.completed
      ? 'Completed · open'
      : w.status == Act0WorldStateV1.current
      ? 'Current · open'
      : 'Open';
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() => _full = !_full);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    final worlds = m.worlds;
    final current = worlds.firstWhere(
      (w) => w.status == Act0WorldStateV1.current && open(w),
      orElse: () => worlds.firstWhere(
        (w) => w.worldId == m.selectedWorldId,
        orElse: () => worlds.first,
      ),
    );
    final countOpen = worlds.where(open).length;
    final counts =
        '${worlds.length} worlds · $countOpen open · ${worlds.length - countOpen} locked';
    final next = worlds
        .where((w) => w.worldNumber > current.worldNumber)
        .take(2)
        .toList();
    return ColoredBox(
      key: const Key('act0_worlds_b_overlay'),
      color: ink,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 20, 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: OutlinedButton(
                        key: const Key('act0_worlds_b_back'),
                        onPressed: m.onClose,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: line),
                          backgroundColor: const Color(0xFF09232B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Semantics(
                          label: 'Back to Learn',
                          button: true,
                          child: glyph(
                            Act0AcademyIconographyV1.forward,
                            color: text,
                            turn: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Worlds', style: type(18, bold: true)),
                    const Spacer(),
                    Text('FOUNDATIONS / I', style: type(10, color: muted)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('act0_worlds_b_scroll'),
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: _full
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All ${worlds.length} worlds',
                              style: type(29, bold: true),
                            ),
                            const SizedBox(height: 8),
                            Text(counts, style: type(12, color: muted)),
                            const SizedBox(height: 16),
                            for (final w in worlds) row(w, compact: true),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR LEARNING MAP',
                              style: type(10.5, color: aqua, bold: true),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Discover what\ncomes next.',
                              style: type(32, bold: true),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              counts,
                              key: const Key('act0_worlds_b_counts'),
                              style: type(12, color: muted),
                            ),
                            const SizedBox(height: 20),
                            hero(current, worlds.length),
                            if (next.isNotEmpty) ...[
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'NEXT IN YOUR JOURNEY',
                                      style: type(10, color: muted, bold: true),
                                    ),
                                  ),
                                  Text(
                                    'Unlock as you progress',
                                    style: type(9, color: muted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF061E25),
                                  border: Border.all(color: line),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Column(
                                  children: [
                                    for (var i = 0; i < next.length; i++) ...[
                                      if (i > 0)
                                        const Divider(color: line, height: 1),
                                      row(next[i]),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: line)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 9, 16, 7),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    key: const Key('act0_worlds_b_catalog_toggle'),
                    onPressed: toggle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: line),
                      backgroundColor: const Color(0xFF061E25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _full
                                ? 'Back to worlds overview'
                                : 'View all ${worlds.length} worlds',
                            style: type(14, bold: true),
                          ),
                        ),
                        const SizedBox(width: 14),
                        glyph(
                          Act0AcademyIconographyV1.forward,
                          turn: _full ? 2 : 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (m.detailWorld != null) ...[
            Positioned.fill(
              child: ModalBarrier(
                color: Colors.black54,
                dismissible: true,
                onDismiss: m.onDismissWorldDetail,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _SelectedWorldPopupV1(
                  world: m.detailWorld!,
                  worlds: worlds,
                  currentWorld: current,
                  onContinueCurrentWorld: () =>
                      m.onSelectWorld(current.worldId),
                  onPreviewPremiumWorld: m.onPreviewPremiumWorld,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget hero(Act0WorldCardV1 w, int total) => Container(
    key: const Key('act0_worlds_b_current_card'),
    height: 268,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      border: Border.all(color: aqua.withValues(alpha: .65)),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/design/sharky/home/poker_lounge_reference_v2.png',
          fit: BoxFit.cover,
          alignment: const Alignment(.1, 0),
          excludeFromSemantics: true,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x33000C10), Color(0x44000C10), Color(0xF0001015)],
              stops: [0, .35, 1],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'WORLD ${w.worldNumber.toString().padLeft(2, '0')} / $total',
                    style: type(10, color: aqua, bold: true),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xC008282F),
                      border: Border.all(color: aqua.withValues(alpha: .6)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      state(w).toUpperCase(),
                      style: type(9, color: aqua, bold: true),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(title(w), style: type(26, bold: true)),
              const SizedBox(height: 10),
              Text(
                act0AcademyWorldSubtitleV1(context, w),
                style: type(12, color: const Color(0xFFB3CCD0)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  key: const Key('act0_worlds_b_continue'),
                  onPressed: open(w)
                      ? () => widget.model.onSelectWorld(w.worldId)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: aqua,
                    foregroundColor: ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          open(w) ? 'Continue learning' : 'Locked',
                          style: type(14, color: ink, bold: true),
                        ),
                      ),
                      const SizedBox(width: 14),
                      glyph(Act0AcademyIconographyV1.forward, color: ink),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget row(Act0WorldCardV1 w, {bool compact = false}) {
    final enabled = open(w);
    final m = widget.model;
    final previous = _worldBeforeV1(m.worlds, w);
    final status = enabled
        ? state(w)
        : previous != null && !compact
        ? _progressionUnlockLineShortV1(context, title(previous))
        : 'Locked';
    return Semantics(
      button: enabled,
      enabled: enabled,
      child: InkWell(
        key: Key('act0_worlds_b_row_${w.worldId}'),
        onTap: enabled ? () => m.onSelectWorld(w.worldId) : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: compact
              ? const BoxDecoration(
                  border: Border(top: BorderSide(color: line)),
                )
              : null,
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF09262E),
                  border: Border.all(color: enabled ? aqua : line),
                ),
                child: Text(
                  w.worldNumber.toString().padLeft(2, '0'),
                  style: type(12, color: enabled ? aqua : muted, bold: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title(w),
                      style: type(
                        14,
                        color: enabled ? text : const Color(0xFFB1C6C9),
                        bold: true,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(status, style: type(11, color: muted)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              glyph(
                enabled
                    ? Act0AcademyIconographyV1.learn
                    : Act0AcademyIconographyV1.lock,
                color: enabled ? aqua : muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
