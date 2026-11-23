part of 'act0_learn_path_shell_v1.dart';

class _WorldMenuOverlayV1 extends StatelessWidget {
  const _WorldMenuOverlayV1({
    required this.worlds,
    required this.selectedWorldId,
    required this.detailWorld,
    required this.onSelectWorld,
    required this.onClose,
    required this.onDismissWorldDetail,
    required this.onPreviewPremiumWorld,
  });

  final List<Act0WorldCardV1> worlds;
  final String selectedWorldId;
  final Act0WorldCardV1? detailWorld;
  final ValueChanged<String> onSelectWorld;
  final VoidCallback onClose;
  final VoidCallback onDismissWorldDetail;
  final ValueChanged<Act0WorldCardV1> onPreviewPremiumWorld;

  Future<void> _showLockedVolumePreviewV1(
    BuildContext context,
    _VolumePillModelV1 volume,
    Act0WorldCardV1 currentWorld,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          Act0ShellTokensV1.pageX,
          Act0ShellTokensV1.pageX,
          Act0ShellTokensV1.pageX,
          Act0ShellTokensV1.gapMd,
        ),
        child: _LockedVolumePreviewSheetV1(
          volume: volume,
          continueLabel: _learnCopyV1(
            context,
            en: 'Continue ${act0AcademyWorldTitleV1(context, currentWorld)}',
            ru: '\u041f\u0440\u043e\u0434\u043e\u043b\u0436\u0438\u0442\u044c ${act0AcademyWorldTitleV1(context, currentWorld)}',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedWorld = worlds.firstWhere(
      (world) => world.worldId == selectedWorldId,
      orElse: () => worlds.first,
    );
    final currentWorld = worlds.firstWhere(
      (world) => world.status == Act0WorldStateV1.current,
      orElse: () => selectedWorld,
    );
    final currentStateColor = _worldRouteStatusColorV1(worlds, currentWorld);
    final nextWorld = _nextWorldAfterV1(worlds, currentWorld);
    final volumePills = <_VolumePillModelV1>[
      _VolumePillModelV1(
        id: 'volume_i',
        label: _learnCopyV1(context, en: 'Volume I', ru: 'Том I'),
        subtitle: _learnCopyV1(context, en: 'Foundations', ru: 'Основы'),
        stateLabel: _learnCopyV1(context, en: 'Active', ru: 'Активен'),
        color: Act0AcademyDesignTokensV1.focus,
      ),
      _VolumePillModelV1(
        id: 'volume_ii',
        label: _learnCopyV1(context, en: 'Volume II', ru: 'Том 2'),
        subtitle: _learnCopyV1(
          context,
          en: 'Later strategic depth',
          ru: 'Поздняя стратегическая глубина',
        ),
        stateLabel: _learnCopyV1(
          context,
          en: 'Later frontier',
          ru: 'Поздний рубеж',
        ),
        color: Act0AcademyDesignTokensV1.inkMuted,
        unlockAfterLabel: _learnCopyV1(
          context,
          en: 'This is a future landmark, not a lesson you can open today.',
          ru: 'Это будущий ориентир, а не урок, который можно открыть сегодня.',
        ),
        previewLine: _learnCopyV1(
          context,
          en: 'More strategic study follows the shared foundation.',
          ru: 'Дальше — более глубокое стратегическое изучение.',
        ),
      ),
      _VolumePillModelV1(
        id: 'volume_iii',
        label: _learnCopyV1(context, en: 'Volume III', ru: 'Том 3'),
        subtitle: _learnCopyV1(
          context,
          en: 'Advanced frontier',
          ru: 'Продвинутый рубеж',
        ),
        stateLabel: _learnCopyV1(
          context,
          en: 'Advanced frontier',
          ru: 'Продвинутый рубеж',
        ),
        color: Act0AcademyDesignTokensV1.inkMuted,
        unlockAfterLabel: _learnCopyV1(
          context,
          en: 'This is a future landmark, not a lesson you can open today.',
          ru: 'Это будущий ориентир, а не урок, который можно открыть сегодня.',
        ),
        previewLine: _learnCopyV1(
          context,
          en: 'Later advanced specialist study.',
          ru: 'Позднее продвинутое специализированное обучение.',
        ),
      ),
    ];
    return Stack(
      key: const Key('act0_shell_levels_menu'),
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              color: Act0AcademyDesignTokensV1.pageSurface.withValues(
                alpha: 0.96,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Act0ShellTokensV1.pageX,
            Act0ShellTokensV1.gapLg,
            Act0ShellTokensV1.pageX,
            Act0ShellTokensV1.gapSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Act0ShellTokensV1.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Act0ShellTokensV1.gapSm),
              Row(
                children: [
                  IconButton(
                    key: const Key('act0_shell_levels_menu_close'),
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Act0AcademyDesignTokensV1.ink,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _learnCopyV1(context, en: 'Worlds', ru: 'Миры'),
                      textAlign: TextAlign.center,
                      style: Act0AcademyDesignTokensV1.sectionHeading,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: ListView(
                  key: const Key('act0_shell_worlds_content_scroll'),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    const SizedBox(height: 2),
                    Center(
                      child: Text(
                        _learnCopyV1(
                          context,
                          en: '3 volumes · 36 worlds',
                          ru: '3 тома · 36 миров',
                        ),
                        style: Act0AcademyDesignTokensV1.supporting.copyWith(
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapMd),
                    LayoutBuilder(
                      key: const Key('act0_shell_volume_strip'),
                      builder: (context, constraints) {
                        final stack =
                            constraints.maxWidth < 360 ||
                            MediaQuery.textScalerOf(context).scale(12) > 15;
                        final pills = <Widget>[
                          for (final volume in volumePills)
                            _VolumePillV1(
                              volume: volume,
                              onTap: volume.id == 'volume_i'
                                  ? null
                                  : () => _showLockedVolumePreviewV1(
                                      context,
                                      volume,
                                      currentWorld,
                                    ),
                            ),
                        ];
                        if (stack) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < pills.length; i++) ...[
                                pills[i],
                                if (i < pills.length - 1)
                                  const SizedBox(
                                    height: Act0AcademyDesignTokensV1.gapXs,
                                  ),
                              ],
                            ],
                          );
                        }
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < pills.length; i++) ...[
                                Expanded(child: pills[i]),
                                if (i < pills.length - 1)
                                  const SizedBox(
                                    width: Act0AcademyDesignTokensV1.gapXs,
                                  ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapMd),
                    Container(
                      key: const Key('act0_shell_levels_sticky_node_header'),
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          currentStateColor.withValues(alpha: 0.08),
                          Act0AcademyDesignTokensV1.pageSurface,
                        ),
                        borderRadius: BorderRadius.circular(
                          Act0AcademyDesignTokensV1.radiusCard,
                        ),
                        border: Border.all(
                          color: currentStateColor.withValues(alpha: 0.36),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: currentStateColor.withValues(alpha: 0.10),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _volumeSummaryLabelV1(
                              context: context,
                              volumeNumber: 1,
                              subtitle: _learnCopyV1(
                                context,
                                en: 'Current foundation',
                                ru: 'Текущая основа',
                              ),
                            ),
                            style: Act0AcademyDesignTokensV1.label.copyWith(
                              color: currentStateColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _learnCopyV1(
                              context,
                              en: 'W1-W6 available - W7-W10 locked preview',
                              ru: 'Миры 1-6 доступны - миры 7-10 закрытый предпросмотр',
                            ),
                            key: const Key(
                              'act0_shell_levels_selected_world_status_line',
                            ),

                            style: Act0AcademyDesignTokensV1.label.copyWith(
                              color: currentStateColor.withValues(alpha: 0.90),
                              fontSize: 10.8,
                              letterSpacing: 0.36,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _learnCopyV1(
                              context,
                              en: 'Current: ${act0AcademyWorldTitleV1(context, currentWorld)}',
                              ru: '\u0422\u0435\u043a\u0443\u0449\u0438\u0439: ${act0AcademyWorldTitleV1(context, currentWorld)}',
                            ),
                            key: const Key(
                              'act0_shell_levels_selected_world_current_line',
                            ),

                            style: Act0AcademyDesignTokensV1.body.copyWith(
                              color: Act0AcademyDesignTokensV1.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (nextWorld != null) ...[
                            Text(
                              _learnCopyV1(
                                context,
                                en: 'Next: ${act0AcademyWorldTitleV1(context, nextWorld)}',
                                ru: '\u0414\u0430\u043b\u044c\u0448\u0435: ${act0AcademyWorldTitleV1(context, nextWorld)}',
                              ),
                              key: const Key(
                                'act0_shell_levels_selected_world_next_landmark',
                              ),

                              style: Act0AcademyDesignTokensV1.body.copyWith(
                                color: Act0AcademyDesignTokensV1.needsReviewFg,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            _learnCopyV1(
                              context,
                              en: 'W11-W12 planned foundation chapters, coming later.',
                              ru: 'Миры 11-12 — главы запланированной основы, позже.',
                            ),
                            key: const Key(
                              'act0_shell_levels_planned_foundation_line',
                            ),

                            style: Act0AcademyDesignTokensV1.supporting
                                .copyWith(
                                  color: Act0AcademyDesignTokensV1.inkMuted,
                                  fontSize: 10.4,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _learnCopyV1(
                              context,
                              en: 'W13+ is later strategic depth.',
                              ru: 'Миры 13+ — более поздняя стратегическая глубина.',
                            ),
                            key: const Key(
                              'act0_shell_levels_later_frontier_line',
                            ),

                            style: Act0AcademyDesignTokensV1.supporting
                                .copyWith(
                                  color: Act0AcademyDesignTokensV1.inkMuted,
                                  fontSize: 10.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Act0ShellTokensV1.gapMd),
                    for (var i = 0; i < worlds.length; i++) ...[
                      _WorldNodeV1(
                        world: worlds[i],
                        worlds: worlds,
                        selected: worlds[i].worldId == selectedWorldId,
                        onSelectWorld: onSelectWorld,
                      ),
                      if (i < worlds.length - 1)
                        const SizedBox(height: Act0ShellTokensV1.gapSm),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (detailWorld != null) ...[
          Positioned.fill(
            child: ModalBarrier(
              key: const Key('act0_shell_world_popup_scrim'),
              color: Colors.black.withValues(alpha: 0.18),
              dismissible: true,
              semanticsLabel: MaterialLocalizations.of(
                context,
              ).modalBarrierDismissLabel,
              onDismiss: onDismissWorldDetail,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Act0ShellTokensV1.pageX,
                Act0ShellTokensV1.pageX,
                Act0ShellTokensV1.pageX,
                Act0ShellTokensV1.gapMd,
              ),
              child: GestureDetector(
                excludeFromSemantics: true,
                onTap: () {},
                child: _SelectedWorldPopupV1(
                  world: detailWorld!,
                  worlds: worlds,
                  currentWorld: currentWorld,
                  onContinueCurrentWorld: () =>
                      onSelectWorld(currentWorld.worldId),
                  onPreviewPremiumWorld: onPreviewPremiumWorld,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _VolumePillV1 extends StatelessWidget {
  const _VolumePillV1({required this.volume, this.onTap});

  final _VolumePillModelV1 volume;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = volume.id == 'volume_i';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('act0_shell_${volume.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          Act0AcademyDesignTokensV1.radiusCard,
        ),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              volume.color.withValues(alpha: active ? 0.10 : 0.05),
              Act0AcademyDesignTokensV1.pageSurface,
            ),
            borderRadius: BorderRadius.circular(
              Act0AcademyDesignTokensV1.radiusCard,
            ),
            border: Border.all(
              color: volume.color.withValues(alpha: active ? 0.22 : 0.16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                volume.label,

                style: Act0AcademyDesignTokensV1.label.copyWith(
                  color: volume.color,
                  letterSpacing: 0.18,
                  fontSize: 8.5,
                ),
              ),
              Text(
                volume.subtitle,

                style: Act0AcademyDesignTokensV1.supporting.copyWith(
                  fontSize: 9.6,
                  height: 1.0,
                  color: active
                      ? Act0AcademyDesignTokensV1.inkMuted
                      : Act0AcademyDesignTokensV1.inkMuted,
                ),
              ),
              Text(
                volume.stateLabel,

                style: Act0AcademyDesignTokensV1.label.copyWith(
                  color: volume.color,
                  fontSize: 8.6,
                  letterSpacing: 0.08,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedVolumePreviewSheetV1 extends StatelessWidget {
  const _LockedVolumePreviewSheetV1({
    required this.volume,
    required this.continueLabel,
  });

  final _VolumePillModelV1 volume;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('act0_shell_${volume.id}_preview_panel'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration:
          Act0ShellTokensV1.surfaceDecoration(
            color: Act0AcademyDesignTokensV1.pageSurface,
            borderColor: Act0AcademyDesignTokensV1.inkMuted.withValues(
              alpha: 0.36,
            ),
          ).copyWith(
            borderRadius: BorderRadius.circular(
              Act0AcademyDesignTokensV1.radiusCard,
            ),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StateBadgeV1(
            label: volume.stateLabel,
            color: Act0AcademyDesignTokensV1.inkMuted,
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(volume.label, style: Act0AcademyDesignTokensV1.sectionHeading),
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          Text(volume.subtitle, style: Act0AcademyDesignTokensV1.body),
          if ((volume.unlockAfterLabel ?? '').isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            Text(
              volume.unlockAfterLabel!,
              key: Key('act0_shell_${volume.id}_unlock_label'),
              style: Act0AcademyDesignTokensV1.body,
            ),
          ],
          if ((volume.previewLine ?? '').isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              volume.previewLine!,
              key: Key('act0_shell_${volume.id}_preview_line'),
              style: Act0AcademyDesignTokensV1.supporting,
            ),
          ],
          const SizedBox(height: Act0ShellTokensV1.gapMd),
          OutlinedButton(
            key: Key('act0_shell_${volume.id}_continue_current_cta'),
            onPressed: () => Navigator.of(context).pop(),
            style: Act0AcademyDesignTokensV1.secondaryButtonStyle(),
            child: Text(continueLabel),
          ),
        ],
      ),
    );
  }
}

class _WorldNodeV1 extends StatefulWidget {
  const _WorldNodeV1({
    required this.world,
    required this.worlds,
    required this.selected,
    required this.onSelectWorld,
  });

  final Act0WorldCardV1 world;
  final List<Act0WorldCardV1> worlds;
  final bool selected;
  final ValueChanged<String> onSelectWorld;

  @override
  State<_WorldNodeV1> createState() => _WorldNodeV1State();
}

class _WorldNodeV1State extends State<_WorldNodeV1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_WorldNodeV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!MediaQuery.disableAnimationsOf(context) &&
        (oldWidget.selected != widget.selected ||
            oldWidget.world.status != widget.world.status)) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _worldRouteStatusColorV1(widget.worlds, widget.world);
    final statusLabel = _worldRouteStatusLabelV1(
      context,
      widget.worlds,
      widget.world,
    );
    final locked = widget.world.isLocked;
    final completed = widget.world.status == Act0WorldStateV1.completed;
    final active = widget.world.status == Act0WorldStateV1.current;
    final nextWorld = _isImmediateNextWorldV1(widget.worlds, widget.world);
    final nodeRadius = Act0AcademyDesignTokensV1.radiusCard;
    final targetScaleFactor = widget.selected ? 1.01 : 1.0;
    final subtitle = act0AcademyWorldSubtitleV1(context, widget.world);
    final previousWorld = _worldBeforeV1(widget.worlds, widget.world);
    final detailText = switch (widget.world.status) {
      Act0WorldStateV1.completed || Act0WorldStateV1.passedByRulesCheck =>
        act0AcademyProgressLabelV1(context, widget.world.progressLabel),
      Act0WorldStateV1.current => act0AcademyProgressLabelV1(
        context,
        widget.world.progressLabel,
      ),
      Act0WorldStateV1.locked =>
        nextWorld && previousWorld != null
            ? _progressionUnlockLineShortV1(
                context,
                act0AcademyWorldTitleV1(context, previousWorld),
              )
            : '',
    };
    final targetBorderColor = widget.selected
        ? color.withValues(alpha: 0.40)
        : locked
        ? color.withValues(alpha: nextWorld ? 0.30 : 0.18)
        : color.withValues(alpha: 0.24);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = CurvedAnimation(
          parent: _controller,
          curve: const Cubic(0.4, 0.0, 0.2, 1.0),
        ).value;

        final scaleFactor = 1 + (targetScaleFactor - 1) * t;

        return Container(
          clipBehavior: Clip.none,
          child: Material(
            color: Colors.transparent,
            child: _LearnButtonV1(
              key: Key('act0_shell_world_${widget.world.worldNumber}'),
              borderRadius: BorderRadius.circular(nodeRadius),
              onTap: () => widget.onSelectWorld(widget.world.worldId),
              child: Transform.scale(
                scale: scaleFactor,
                child: Ink(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? Color.alphaBlend(
                            color.withValues(alpha: active ? 0.12 : 0.08),
                            Act0AcademyDesignTokensV1.pageSurface,
                          )
                        : Act0AcademyDesignTokensV1.cardSurface.withValues(
                            alpha: 0.88,
                          ),
                    borderRadius: BorderRadius.circular(nodeRadius),
                    border: Border.all(color: targetBorderColor, width: 1.0),
                    boxShadow: <BoxShadow>[
                      if (widget.selected)
                        BoxShadow(
                          color: color.withValues(alpha: 0.18 * t),
                          blurRadius: 14,
                          spreadRadius: 1.0,
                          offset: Offset.zero,
                        ),
                      if (active || widget.selected || nextWorld)
                        BoxShadow(
                          color: color.withValues(alpha: 0.10 * t),
                          blurRadius: 9 * t,
                          spreadRadius: 0.5 * t,
                          offset: Offset(0, 2 * t),
                        )
                      else if (completed)
                        BoxShadow(
                          color: color.withValues(alpha: 0.08 * t),
                          blurRadius: 6 * t,
                          offset: Offset(0, 1 * t),
                        ),
                      // locked: no shadow
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: completed
                              ? color
                              : color.withValues(
                                  alpha: locked
                                      ? (nextWorld ? 0.14 : 0.10)
                                      : 0.16,
                                ),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusCard,
                          ),
                          border: Border.all(
                            color: color.withValues(
                              alpha: locked ? (nextWorld ? 0.58 : 0.30) : 0.82,
                            ),
                            width: active ? 2.0 : 1.4,
                          ),
                        ),
                        child: completed
                            ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: active ? 22 : 20,
                              )
                            : Text(
                                '${widget.world.worldNumber}',
                                style: TextStyle(
                                  color: locked && !nextWorld
                                      ? Act0AcademyDesignTokensV1.inkMuted
                                      : Act0AcademyDesignTokensV1.ink,
                                  fontSize: active ? 16 : 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    _learnCopyV1(
                                      context,
                                      en: 'World ${widget.world.worldNumber}',
                                      ru: '\u041c\u0438\u0440 ${widget.world.worldNumber}',
                                    ),
                                    style: Act0AcademyDesignTokensV1.label
                                        .copyWith(
                                          color: color,
                                          letterSpacing: 0.42,
                                        ),
                                  ),
                                ),
                                _StateBadgeV1(label: statusLabel, color: color),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              act0AcademyWorldTitleV1(context, widget.world),
                              style: Act0ShellTokensV1.cardTitle.copyWith(
                                color: locked && !nextWorld
                                    ? Act0AcademyDesignTokensV1.inkMuted
                                    : Act0AcademyDesignTokensV1.ink,
                                fontSize: widget.selected ? 14.2 : 13.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: Act0AcademyDesignTokensV1.supporting
                                  .copyWith(
                                    color: locked && !nextWorld
                                        ? Act0AcademyDesignTokensV1.inkMuted
                                        : Act0AcademyDesignTokensV1.inkMuted,
                                    fontSize: 11.2,
                                    height: 1.25,
                                  ),
                            ),
                            if (detailText.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                detailText,
                                style: Act0AcademyDesignTokensV1.label.copyWith(
                                  color: color.withValues(
                                    alpha: locked ? 0.92 : 0.88,
                                  ),
                                  fontSize: 10.2,
                                  letterSpacing: 0.28,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ), // closes Transform.scale
            ), // closes InkWell
          ), // closes Material
        ); // closes Container
      },
    );
  }
}

class _SelectedWorldPopupV1 extends StatelessWidget {
  const _SelectedWorldPopupV1({
    required this.world,
    required this.worlds,
    required this.currentWorld,
    required this.onContinueCurrentWorld,
    required this.onPreviewPremiumWorld,
  });

  final Act0WorldCardV1 world;
  final List<Act0WorldCardV1> worlds;
  final Act0WorldCardV1 currentWorld;
  final VoidCallback onContinueCurrentWorld;
  final ValueChanged<Act0WorldCardV1> onPreviewPremiumWorld;

  @override
  Widget build(BuildContext context) {
    final progressionLocked = _isProgressionLockedWorldV1(worlds, world);
    final color = progressionLocked
        ? Act0AcademyDesignTokensV1.needsReviewFg
        : switch (world.status) {
            Act0WorldStateV1.completed || Act0WorldStateV1.passedByRulesCheck =>
              Act0AcademyDesignTokensV1.focus,
            Act0WorldStateV1.current => Act0AcademyDesignTokensV1.focus,
            Act0WorldStateV1.locked => Act0AcademyDesignTokensV1.inkMuted,
          };
    final worldTitle = act0AcademyWorldTitleV1(context, world);
    final worldSubtitle = act0AcademyWorldSubtitleV1(context, world);
    final stateLabel = switch (world.status) {
      Act0WorldStateV1.passedByRulesCheck => 'Skipped by rules check',
      Act0WorldStateV1.completed => _learnCopyV1(
        context,
        en: 'Cleared',
        ru: 'Пройден',
      ),
      Act0WorldStateV1.current => _learnCopyV1(
        context,
        en: 'Active',
        ru: 'Активен',
      ),
      Act0WorldStateV1.locked =>
        progressionLocked
            ? _learnCopyV1(context, en: 'Next', ru: 'Дальше')
            : _learnCopyV1(context, en: 'Locked', ru: 'Закрыт'),
    };
    return Container(
      key: const Key('act0_shell_selected_world_panel'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapLg),
      decoration:
          Act0ShellTokensV1.surfaceDecoration(
            color: Act0AcademyDesignTokensV1.pageSurface,
            borderColor: color.withValues(alpha: 0.48),
          ).copyWith(
            borderRadius: BorderRadius.circular(
              Act0AcademyDesignTokensV1.radiusCard,
            ),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StateBadgeV1(label: stateLabel, color: color),
              if (!progressionLocked) ...[
                const SizedBox(width: Act0ShellTokensV1.gapSm),
                Text(
                  _learnCopyV1(
                    context,
                    en: 'Lesson path',
                    ru: 'Маршрут доказательств',
                  ),
                  style: Act0AcademyDesignTokensV1.label.copyWith(
                    color: Act0AcademyDesignTokensV1.needsReviewFg,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(worldTitle, style: Act0AcademyDesignTokensV1.sectionHeading),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
          Text(
            progressionLocked
                ? _learnCopyV1(
                    context,
                    en: 'Finish ${act0AcademyWorldTitleV1(context, currentWorld)} to open this world.',
                    ru: '\u0417\u0430\u0432\u0435\u0440\u0448\u0438 ${act0AcademyWorldTitleV1(context, currentWorld)}, \u0447\u0442\u043e\u0431\u044b \u043e\u0442\u043a\u0440\u044b\u0442\u044c \u044d\u0442\u043e\u0442 \u043c\u0438\u0440.',
                  )
                : act0DisplayWorldNameCopyV1(world.unlockLabel),
            key: const Key('act0_shell_world_unlock_label'),
            style: Act0AcademyDesignTokensV1.body.copyWith(
              color: Act0AcademyDesignTokensV1.ink,
            ),
          ),
          if (progressionLocked) ...[
            Text(worldSubtitle, style: Act0AcademyDesignTokensV1.supporting),
            const SizedBox(height: Act0ShellTokensV1.gapSm),
            OutlinedButton(
              key: const Key('act0_shell_world_continue_current_cta'),
              onPressed: onContinueCurrentWorld,
              style: Act0AcademyDesignTokensV1.secondaryButtonStyle(),
              child: Text(
                _learnCopyV1(
                  context,
                  en: 'Continue ${act0AcademyWorldTitleV1(context, currentWorld)}',
                  ru: '\u041f\u0440\u043e\u0434\u043e\u043b\u0436\u0438\u0442\u044c ${act0AcademyWorldTitleV1(context, currentWorld)}',
                ),
              ),
            ),
          ] else if (world.isLocked) ...[
            const SizedBox(height: Act0ShellTokensV1.gapMd),
            Text(
              _learnCopyV1(context, en: 'Locked preview', ru: 'Предпросмотр'),
              style: Act0AcademyDesignTokensV1.label.copyWith(
                color: Act0AcademyDesignTokensV1.inkMuted,
              ),
            ),
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              _learnCopyV1(
                context,
                en: 'This world opens later in the route. Stay on the current path first.',
                ru: 'Этот мир откроется позже по маршруту. Сначала держись текущего пути.',
              ),
              style: Act0AcademyDesignTokensV1.supporting,
            ),
          ],
        ],
      ),
    );
  }
}

class _LearnCoachLineV1 extends StatelessWidget {
  const _LearnCoachLineV1({
    required this.line,
    required this.detail,
    required this.mood,
  });

  final String line;
  final String? detail;
  final Act0SharkyMoodV1 mood;

  @override
  Widget build(BuildContext context) {
    final accent = switch (mood) {
      Act0SharkyMoodV1.repair => Act0ShellTokensV1.gold,
      Act0SharkyMoodV1.celebrate => Act0ShellTokensV1.primary,
      Act0SharkyMoodV1.happy => Act0ShellTokensV1.primary,
      Act0SharkyMoodV1.neutral => Act0ShellTokensV1.info,
      Act0SharkyMoodV1.thinking => Act0ShellTokensV1.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0ShellTokensV1.gapMd,
        vertical: Act0ShellTokensV1.gapSm,
      ),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface3,
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
            ),
            child: Icon(Icons.waves_rounded, color: accent, size: 18),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line,
                  style: Act0ShellTokensV1.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((detail ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(detail!, style: Act0ShellTokensV1.muted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnRouteContractCardV1 extends StatelessWidget {
  const _LearnRouteContractCardV1({required this.line, required this.detail});

  final String line;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_learn_route_contract_card'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface2.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusBase),
            ),
            child: const Icon(
              Icons.alt_route_rounded,
              size: 18,
              color: Act0ShellTokensV1.info,
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line,
                  key: const Key('act0_shell_learn_route_contract_line'),
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: Act0ShellTokensV1.gapXs),
                Text(
                  detail,
                  key: const Key('act0_shell_learn_route_contract_detail'),
                  style: Act0ShellTokensV1.muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
