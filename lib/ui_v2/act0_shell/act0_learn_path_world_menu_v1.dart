part of 'act0_learn_path_shell_v1.dart';

class _WorldMenuOverlayV1 extends StatelessWidget {
  const _WorldMenuOverlayV1({
    required this.view,
    required this.selectedWorldId,
    required this.onSelectWorld,
    required this.onClose,
    required this.onDismissWorldDetail,
    required this.onPreviewPremiumWorld,
  });

  final Act0LearnPathViewModelV1 view;
  final String selectedWorldId;
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
      backgroundColor: Act0SkinTokensV1.transparent,
      isScrollControlled: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          Act0SkinTokensV1.screenGutter,
          Act0SkinTokensV1.screenGutter,
          Act0SkinTokensV1.screenGutter,
          Act0SkinTokensV1.gapMd,
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
    final worlds = view.numberedWorlds;
    final currentWorld = view.currentWorld;
    final detailWorld = view.detailWorld;
    final currentStateColor = _worldRouteStatusColorV1(worlds, currentWorld);
    final nextWorld = view.nextWorld;
    final volumePills = <_VolumePillModelV1>[
      _VolumePillModelV1(
        id: 'volume_i',
        label: _learnCopyV1(context, en: 'Volume I', ru: 'Том I'),
        subtitle: _learnCopyV1(context, en: 'Foundations', ru: 'Основы'),
        stateLabel: _learnCopyV1(context, en: 'Active', ru: 'Активен'),
        color: Act0SkinTokensV1.accent,
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
        color: Act0SkinTokensV1.muted,
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
        color: Act0SkinTokensV1.muted,
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
          child: const ColoredBox(color: Act0SkinTokensV1.background),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Act0SkinTokensV1.screenGutter,
            Act0SkinTokensV1.gapLg,
            Act0SkinTokensV1.screenGutter,
            Act0SkinTokensV1.gapSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Act0SkinTokensV1.line,
                    borderRadius: BorderRadius.circular(Act0SkinTokensV1.gapXs),
                  ),
                ),
              ),
              const SizedBox(height: Act0SkinTokensV1.gapSm),
              Row(
                children: [
                  IconButton(
                    key: const Key('act0_shell_levels_menu_close'),
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Act0SkinTokensV1.onSurface,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _learnCopyV1(context, en: 'Worlds', ru: 'Миры'),
                      textAlign: TextAlign.center,
                      style: Act0SkinTokensV1.headline,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: ListView(
                  key: const Key('act0_shell_worlds_content_scroll'),
                  padding: const EdgeInsets.only(
                    bottom: Act0SkinTokensV1.gapXl,
                  ),
                  children: [
                    const SizedBox(height: Act0SkinTokensV1.gapXs),
                    Center(
                      child: Text(
                        _learnCopyV1(
                          context,
                          en: '3 volumes · 36 worlds',
                          ru: '3 тома · 36 миров',
                        ),
                        style: Act0SkinTokensV1.secondary,
                      ),
                    ),
                    const SizedBox(height: Act0SkinTokensV1.gapMd),
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
                                    height: Act0SkinTokensV1.gapXs,
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
                                  const SizedBox(width: Act0SkinTokensV1.gapXs),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: Act0SkinTokensV1.gapMd),
                    Act0SkinCardV1(
                      key: const Key('act0_shell_levels_sticky_node_header'),
                      emphasized: true,
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
                            style: Act0SkinTokensV1.sectionLabel.copyWith(
                              color: currentStateColor,
                            ),
                          ),
                          const SizedBox(height: Act0SkinTokensV1.gapSm),
                          Text(
                            _learnCopyV1(
                              context,
                              en: 'W1-W6 available - W7-W10 locked preview',
                              ru: 'Миры 1-6 доступны - миры 7-10 закрытый предпросмотр',
                            ),
                            key: const Key(
                              'act0_shell_levels_selected_world_status_line',
                            ),

                            style: Act0SkinTokensV1.sectionLabel.copyWith(
                              color: currentStateColor.withValues(
                                alpha: Act0SkinTokensV1.nearlyOpaque,
                              ),
                            ),
                          ),
                          const SizedBox(height: Act0SkinTokensV1.gapXs),
                          Text(
                            _learnCopyV1(
                              context,
                              en: 'Current: ${act0AcademyWorldTitleV1(context, currentWorld)}',
                              ru: '\u0422\u0435\u043a\u0443\u0449\u0438\u0439: ${act0AcademyWorldTitleV1(context, currentWorld)}',
                            ),
                            key: const Key(
                              'act0_shell_levels_selected_world_current_line',
                            ),

                            style: Act0SkinTokensV1.body.copyWith(
                              color: Act0SkinTokensV1.onSurface,
                            ),
                          ),
                          const SizedBox(height: Act0SkinTokensV1.gapXs),
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

                              style: Act0SkinTokensV1.body.copyWith(
                                color: Act0SkinTokensV1.accent,
                              ),
                            ),
                          ],
                          const SizedBox(height: Act0SkinTokensV1.gapXs),
                          Text(
                            _learnCopyV1(
                              context,
                              en: 'W11-W12 planned foundation chapters, coming later.',
                              ru: 'Миры 11-12 — главы запланированной основы, позже.',
                            ),
                            key: const Key(
                              'act0_shell_levels_planned_foundation_line',
                            ),

                            style: Act0SkinTokensV1.secondary.copyWith(
                              color: Act0SkinTokensV1.muted,
                            ),
                          ),
                          const SizedBox(height: Act0SkinTokensV1.gapXs),
                          Text(
                            _learnCopyV1(
                              context,
                              en: 'W13+ is later strategic depth.',
                              ru: 'Миры 13+ — более поздняя стратегическая глубина.',
                            ),
                            key: const Key(
                              'act0_shell_levels_later_frontier_line',
                            ),

                            style: Act0SkinTokensV1.secondary.copyWith(
                              color: Act0SkinTokensV1.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Act0SkinTokensV1.gapMd),
                    for (var i = 0; i < worlds.length; i++) ...[
                      _WorldNodeV1(
                        world: worlds[i],
                        worlds: worlds,
                        selected: worlds[i].worldId == selectedWorldId,
                        onSelectWorld: onSelectWorld,
                      ),
                      if (i < worlds.length - 1)
                        const SizedBox(height: Act0SkinTokensV1.gapSm),
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
              color: Act0SkinTokensV1.scrim.withValues(
                alpha: Act0SkinTokensV1.tintStrong,
              ),
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
                Act0SkinTokensV1.screenGutter,
                Act0SkinTokensV1.screenGutter,
                Act0SkinTokensV1.screenGutter,
                Act0SkinTokensV1.gapMd,
              ),
              child: GestureDetector(
                excludeFromSemantics: true,
                onTap: () {},
                child: _SelectedWorldPopupV1(
                  world: detailWorld,
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
      color: Act0SkinTokensV1.transparent,
      child: InkWell(
        key: Key('act0_shell_${volume.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusCard),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(
            Act0SkinTokensV1.gapSm,
            Act0SkinTokensV1.gapSm,
            Act0SkinTokensV1.gapSm,
            Act0SkinTokensV1.gapSm,
          ),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              volume.color.withValues(
                alpha: active
                    ? Act0SkinTokensV1.tintSoft
                    : Act0SkinTokensV1.tintSubtle,
              ),
              Act0SkinTokensV1.background,
            ),
            borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusCard),
            border: Border.all(
              color: volume.color.withValues(
                alpha: active
                    ? Act0SkinTokensV1.edgeSoft
                    : Act0SkinTokensV1.tintStrong,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                volume.label,

                style: Act0SkinTokensV1.sectionLabel.copyWith(
                  color: volume.color,
                ),
              ),
              Text(
                volume.subtitle,

                style: Act0SkinTokensV1.secondary.copyWith(
                  color: active
                      ? Act0SkinTokensV1.muted
                      : Act0SkinTokensV1.muted,
                ),
              ),
              Text(
                volume.stateLabel,

                style: Act0SkinTokensV1.sectionLabel.copyWith(
                  color: volume.color,
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
      padding: const EdgeInsets.all(Act0SkinTokensV1.gapLg),
      decoration:
          Act0SkinTokensV1.cardDecoration(
            color: Act0SkinTokensV1.background,
            borderColor: Act0SkinTokensV1.muted.withValues(
              alpha: Act0SkinTokensV1.edgeStrong,
            ),
          ).copyWith(
            borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusCard),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StateBadgeV1(
            label: volume.stateLabel,
            color: Act0SkinTokensV1.muted,
          ),
          const SizedBox(height: Act0SkinTokensV1.gapSm),
          Text(volume.label, style: Act0SkinTokensV1.headline),
          const SizedBox(height: Act0SkinTokensV1.gapXs),
          Text(volume.subtitle, style: Act0SkinTokensV1.body),
          if ((volume.unlockAfterLabel ?? '').isNotEmpty) ...[
            const SizedBox(height: Act0SkinTokensV1.gapSm),
            Text(
              volume.unlockAfterLabel!,
              key: Key('act0_shell_${volume.id}_unlock_label'),
              style: Act0SkinTokensV1.body,
            ),
          ],
          if ((volume.previewLine ?? '').isNotEmpty) ...[
            const SizedBox(height: Act0SkinTokensV1.gapXs),
            Text(
              volume.previewLine!,
              key: Key('act0_shell_${volume.id}_preview_line'),
              style: Act0SkinTokensV1.secondary,
            ),
          ],
          const SizedBox(height: Act0SkinTokensV1.gapMd),
          OutlinedButton(
            key: Key('act0_shell_${volume.id}_continue_current_cta'),
            onPressed: () => Navigator.of(context).pop(),
            style: Act0SkinTokensV1.secondaryButtonStyle(),
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
    final nodeRadius = Act0SkinTokensV1.radiusCard;
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
        ? color.withValues(alpha: Act0SkinTokensV1.edgeStrong)
        : locked
        ? color.withValues(
            alpha: nextWorld
                ? Act0SkinTokensV1.edgeSoft
                : Act0SkinTokensV1.tintStrong,
          )
        : color.withValues(alpha: Act0SkinTokensV1.edgeSoft);

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
            color: Act0SkinTokensV1.transparent,
            child: _LearnButtonV1(
              key: Key('act0_shell_world_${widget.world.worldNumber}'),
              borderRadius: BorderRadius.circular(nodeRadius),
              onTap: () => widget.onSelectWorld(widget.world.worldId),
              child: Transform.scale(
                scale: scaleFactor,
                child: Ink(
                  padding: const EdgeInsets.fromLTRB(
                    Act0SkinTokensV1.gapMd,
                    Act0SkinTokensV1.gapMd,
                    Act0SkinTokensV1.gapMd,
                    Act0SkinTokensV1.gapMd,
                  ),
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? Color.alphaBlend(
                            color.withValues(
                              alpha: active
                                  ? Act0SkinTokensV1.tintSoft
                                  : Act0SkinTokensV1.tintSubtle,
                            ),
                            Act0SkinTokensV1.background,
                          )
                        : Act0SkinTokensV1.surface.withValues(
                            alpha: Act0SkinTokensV1.nearlyOpaque,
                          ),
                    borderRadius: BorderRadius.circular(nodeRadius),
                    border: Border.all(color: targetBorderColor, width: 1.0),
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
                                      ? Act0SkinTokensV1.tintSoft
                                      : Act0SkinTokensV1.tintStrong,
                                ),
                          borderRadius: BorderRadius.circular(
                            Act0SkinTokensV1.radiusCard,
                          ),
                          border: Border.all(
                            color: color.withValues(
                              alpha: locked
                                  ? (nextWorld
                                        ? Act0SkinTokensV1.iconMutedOpacity
                                        : Act0SkinTokensV1.edgeSoft)
                                  : Act0SkinTokensV1.disabledOpacity,
                            ),
                            width: active ? 2.0 : 1.4,
                          ),
                        ),
                        child: completed
                            ? Icon(
                                Icons.check_rounded,
                                color: Act0SkinTokensV1.onSurface,
                                size: active ? 22 : 20,
                              )
                            : Text(
                                '${widget.world.worldNumber}',
                                style: Act0SkinTokensV1.captionStyle.copyWith(
                                  color: locked && !nextWorld
                                      ? Act0SkinTokensV1.muted
                                      : Act0SkinTokensV1.onSurface,
                                ),
                              ),
                      ),
                      const SizedBox(width: Act0SkinTokensV1.gapSm),
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
                                    style: Act0SkinTokensV1.sectionLabel
                                        .copyWith(color: color),
                                  ),
                                ),
                                _StateBadgeV1(label: statusLabel, color: color),
                              ],
                            ),
                            const SizedBox(height: Act0SkinTokensV1.gapXs),
                            Text(
                              act0AcademyWorldTitleV1(context, widget.world),
                              style: Act0SkinTokensV1.headline.copyWith(
                                color: locked && !nextWorld
                                    ? Act0SkinTokensV1.muted
                                    : Act0SkinTokensV1.onSurface,
                              ),
                            ),
                            const SizedBox(height: Act0SkinTokensV1.gapXs),
                            Text(subtitle, style: Act0SkinTokensV1.secondary),
                            if (detailText.isNotEmpty) ...[
                              const SizedBox(height: Act0SkinTokensV1.gapXs),
                              Text(
                                detailText,
                                style: Act0SkinTokensV1.sectionLabel.copyWith(
                                  color: color.withValues(
                                    alpha: Act0SkinTokensV1.nearlyOpaque,
                                  ),
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
        ? Act0SkinTokensV1.accent
        : switch (world.status) {
            Act0WorldStateV1.completed ||
            Act0WorldStateV1.passedByRulesCheck => Act0SkinTokensV1.accent,
            Act0WorldStateV1.current => Act0SkinTokensV1.accent,
            Act0WorldStateV1.locked => Act0SkinTokensV1.muted,
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
      padding: const EdgeInsets.all(Act0SkinTokensV1.gapLg),
      decoration:
          Act0SkinTokensV1.cardDecoration(
            color: Act0SkinTokensV1.background,
            borderColor: color.withValues(alpha: Act0SkinTokensV1.edgeStrong),
          ).copyWith(
            borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusCard),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StateBadgeV1(label: stateLabel, color: color),
              if (!progressionLocked) ...[
                const SizedBox(width: Act0SkinTokensV1.gapSm),
                Text(
                  _learnCopyV1(
                    context,
                    en: 'Lesson path',
                    ru: 'Маршрут доказательств',
                  ),
                  style: Act0SkinTokensV1.sectionLabel.copyWith(
                    color: Act0SkinTokensV1.accent,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Act0SkinTokensV1.gapSm),
          Text(worldTitle, style: Act0SkinTokensV1.headline),
          const SizedBox(height: Act0SkinTokensV1.gapSm),
          Text(
            progressionLocked
                ? _learnCopyV1(
                    context,
                    en: 'Finish ${act0AcademyWorldTitleV1(context, currentWorld)} to open this world.',
                    ru: '\u0417\u0430\u0432\u0435\u0440\u0448\u0438 ${act0AcademyWorldTitleV1(context, currentWorld)}, \u0447\u0442\u043e\u0431\u044b \u043e\u0442\u043a\u0440\u044b\u0442\u044c \u044d\u0442\u043e\u0442 \u043c\u0438\u0440.',
                  )
                : act0DisplayWorldNameCopyV1(world.unlockLabel),
            key: const Key('act0_shell_world_unlock_label'),
            style: Act0SkinTokensV1.body.copyWith(
              color: Act0SkinTokensV1.onSurface,
            ),
          ),
          if (progressionLocked) ...[
            Text(worldSubtitle, style: Act0SkinTokensV1.secondary),
            const SizedBox(height: Act0SkinTokensV1.gapSm),
            OutlinedButton(
              key: const Key('act0_shell_world_continue_current_cta'),
              onPressed: onContinueCurrentWorld,
              style: Act0SkinTokensV1.secondaryButtonStyle(),
              child: Text(
                _learnCopyV1(
                  context,
                  en: 'Continue ${act0AcademyWorldTitleV1(context, currentWorld)}',
                  ru: '\u041f\u0440\u043e\u0434\u043e\u043b\u0436\u0438\u0442\u044c ${act0AcademyWorldTitleV1(context, currentWorld)}',
                ),
              ),
            ),
          ] else if (world.isLocked) ...[
            const SizedBox(height: Act0SkinTokensV1.gapMd),
            Text(
              _learnCopyV1(context, en: 'Locked preview', ru: 'Предпросмотр'),
              style: Act0SkinTokensV1.sectionLabel.copyWith(
                color: Act0SkinTokensV1.muted,
              ),
            ),
            const SizedBox(height: Act0SkinTokensV1.gapXs),
            Text(
              _learnCopyV1(
                context,
                en: 'This world opens later in the route. Stay on the current path first.',
                ru: 'Этот мир откроется позже по маршруту. Сначала держись текущего пути.',
              ),
              style: Act0SkinTokensV1.secondary,
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
      Act0SharkyMoodV1.repair => Act0SkinTokensV1.accent,
      Act0SharkyMoodV1.celebrate => Act0SkinTokensV1.accent,
      Act0SharkyMoodV1.happy => Act0SkinTokensV1.accent,
      Act0SharkyMoodV1.neutral => Act0SkinTokensV1.accent,
      Act0SharkyMoodV1.thinking => Act0SkinTokensV1.accent,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Act0SkinTokensV1.gapMd,
        vertical: Act0SkinTokensV1.gapSm,
      ),
      decoration: BoxDecoration(
        color: Act0SkinTokensV1.track,
        borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusCard),
        border: Border.all(
          color: accent.withValues(alpha: Act0SkinTokensV1.edgeSoft),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: Act0SkinTokensV1.tintSoft),
              borderRadius: BorderRadius.circular(
                Act0SkinTokensV1.radiusControl,
              ),
            ),
            child: Icon(Icons.waves_rounded, color: accent, size: 18),
          ),
          const SizedBox(width: Act0SkinTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line, style: Act0SkinTokensV1.body),
                if ((detail ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: Act0SkinTokensV1.gapXs),
                  Text(detail!, style: Act0SkinTokensV1.secondary),
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
      padding: const EdgeInsets.all(Act0SkinTokensV1.gapMd),
      decoration: BoxDecoration(
        color: Act0SkinTokensV1.raised.withValues(
          alpha: Act0SkinTokensV1.disabledOpacity,
        ),
        borderRadius: BorderRadius.circular(Act0SkinTokensV1.radiusCard),
        border: Border.all(
          color: Act0SkinTokensV1.accent.withValues(
            alpha: Act0SkinTokensV1.tintStrong,
          ),
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
              color: Act0SkinTokensV1.accent.withValues(
                alpha: Act0SkinTokensV1.tintSoft,
              ),
              borderRadius: BorderRadius.circular(
                Act0SkinTokensV1.radiusControl,
              ),
            ),
            child: const Icon(
              Icons.alt_route_rounded,
              size: 18,
              color: Act0SkinTokensV1.accent,
            ),
          ),
          const SizedBox(width: Act0SkinTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line,
                  key: const Key('act0_shell_learn_route_contract_line'),
                  style: Act0SkinTokensV1.body.copyWith(
                    color: Act0SkinTokensV1.onSurface,
                  ),
                ),
                const SizedBox(height: Act0SkinTokensV1.gapXs),
                Text(
                  detail,
                  key: const Key('act0_shell_learn_route_contract_detail'),
                  style: Act0SkinTokensV1.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
