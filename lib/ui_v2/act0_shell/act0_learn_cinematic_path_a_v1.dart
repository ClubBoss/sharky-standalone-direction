part of 'act0_learn_path_shell_v1.dart';

/// Presentation only: the existing Learn owner supplies eligibility, current
/// task, earned progress, expansion state and all callbacks.
class _CinematicLearnBodyV1 extends StatelessWidget {
  const _CinematicLearnBodyV1({required this.model});
  final _LearnMissionFirstBodyV5 model;
  static const ink = Act0HomeNorthStarPaletteV1.ink;
  static const text = Act0HomeNorthStarPaletteV1.text;
  static const muted = Act0HomeNorthStarPaletteV1.textMuted;
  static const aqua = Act0HomeNorthStarPaletteV1.aqua;

  TextStyle style(
    double size, {
    Color color = text,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(fontSize: size, height: 1.25, color: color, fontWeight: weight);

  BoxDecoration surface({bool active = false}) => BoxDecoration(
    color: active ? const Color(0xE0062028) : const Color(0xB0061A22),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: active ? aqua.withValues(alpha: .7) : const Color(0xFF17363F),
      width: .8,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final m = model;
    final currentIndex = m.lessons.indexOf(m.currentMissionLesson);
    // Numeric projection already calculated by Act0LearnPathShellV1, never
    // parsed from display labels. Placement closure is not earned progress.
    final earned = (m.progressFraction * m.lessonCount).round();
    final skipped = m.lessons
        .where(
          (l) =>
              l.taskList.isNotEmpty &&
              l.taskList.every((t) => m.pathClosedTaskIds.contains(t.taskId)) &&
              l.taskList.any((t) => m.skippedTaskIds.contains(t.taskId)) &&
              !l.taskList.every((t) => m.completedTaskIds.contains(t.taskId)),
        )
        .length;
    final prior = currentIndex > 0 ? m.lessons[currentIndex - 1] : null;
    final next = currentIndex + 1 < m.lessons.length
        ? m.lessons[currentIndex + 1]
        : null;
    return Column(
      key: const Key('act0_learn_cinematic_body'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(key: m.pinnedHeaderKey, child: _header(context)),
        Container(
          key: const Key('act0_shell_learn_v5_world_context'),
          padding: const EdgeInsets.all(13),
          decoration: surface(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Course progress', style: style(12))),
                  Text(
                    '${(m.progressFraction * 100).round()}%',
                    key: const Key('act0_learn_cinematic_percent'),
                    style: style(22, weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  key: const Key('act0_shell_learn_progress_bar'),
                  value: m.progressFraction,
                  minHeight: 7,
                  color: aqua,
                  backgroundColor: const Color(0xFF11333D),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$earned of ${m.lessonCount} lessons complete',
                      key: const Key('act0_learn_cinematic_earned'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style(11, color: muted),
                    ),
                  ),
                  if (skipped > 0)
                    Text(
                      '$skipped skipped by placement',
                      key: const Key('act0_learn_cinematic_skipped'),
                      style: style(11, color: muted),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (!m.showFullPath) ...[
          const SizedBox(height: 14),
          _section('PREVIOUS LESSON'),
          if (prior != null)
            _row(context, prior, currentIndex)
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Your path starts here.',
                style: style(13, color: muted),
              ),
            ),
          if (currentIndex > 1)
            Text(
              '${currentIndex - 1} earlier lessons in full path',
              style: style(11, color: muted),
            ),
        ],
        const SizedBox(height: 14),
        KeyedSubtree(
          key: m.lessonKeyForId(m.currentMissionLesson.lessonId),
          child: _current(context, currentIndex),
        ),
        const SizedBox(height: 12),
        if (m.showFullPath) ...[
          _section('ALL LESSONS · CURRENT LESSON ABOVE'),
          const SizedBox(height: 6),
          for (final i in m.journeyLessonIndexes)
            _row(context, m.lessons[i], i + 1),
        ] else if (next != null) ...[
          _section('UP NEXT'),
          _row(context, next, currentIndex + 2),
        ],
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            key: const Key('act0_shell_learn_v5_view_full_path'),
            onPressed: m.onToggleFullPath,
            style: OutlinedButton.styleFrom(
              foregroundColor: muted,
              side: const BorderSide(color: Color(0xFF22505A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  m.showFullPath
                      ? 'Collapse full path'
                      : 'View all ${m.lessonCount} lessons',
                  style: style(13, color: muted),
                ),
                const SizedBox(width: 9),
                RotatedBox(
                  quarterTurns: m.showFullPath ? 3 : 1,
                  child: const Act0AcademyGlyphV1(
                    asset: Act0AcademyIconographyV1.forward,
                    size: 17,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (m.showFullPath)
          SizedBox(
            key: m.detailLessonId == null
                ? const Key('act0_shell_full_path_collapsed_v6')
                : const Key('act0_shell_full_path_manual_expand_v6'),
            height: 0,
          ),
      ],
    );
  }

  Widget _section(String label) => Text(
    label,
    style: style(11, color: const Color(0xFF87CEDD), weight: FontWeight.w600),
  );

  Widget _header(BuildContext context) {
    final m = model;
    return SizedBox(
      key: const Key('act0_learn_cinematic_header'),
      height: 104,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ExcludeSemantics(
              child: Image(
                image: AssetImage(
                  'assets/design/sharky/home/poker_lounge_reference_v2.png',
                ),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xEA020E13), Color(0x65020E13)],
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00020E13), Color(0xDA020E13)],
                  stops: [0.35, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'World ${m.world.worldNumber}',
                            style: style(12, weight: FontWeight.w600),
                          ),
                        ),
                        TextButton.icon(
                          key: const Key('act0_shell_levels_menu_button'),
                          onPressed: m.onOpenWorldMenu,
                          icon: const Act0AcademyGlyphV1(
                            asset: Act0AcademyIconographyV1.learn,
                            color: text,
                            size: 17,
                          ),
                          label: Text('All worlds', style: style(12)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    m.moduleTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style(24, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    m.world.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style(13, color: muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _current(BuildContext context, int index) {
    final m = model;
    final l = m.currentMissionLesson;
    return Container(
      key: const Key('act0_shell_current_mission_card'),
      padding: const EdgeInsets.all(14),
      decoration: surface(active: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CURRENT LESSON · ${index + 1} / ${m.lessonCount}',
                  style: style(11, color: aqua, weight: FontWeight.w600),
                ),
              ),
              Text(
                'Step ${m.currentMissionStepIndex} of ${l.taskList.length}',
                style: style(11, color: muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            act0AcademyLessonTitleV1(context, l),
            style: style(23, weight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            act0AcademyLessonSubtitleV1(context, l),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: style(14, color: muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final t in l.taskList)
                Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: m.pathClosedTaskIds.contains(t.taskId)
                          ? aqua
                          : const Color(0xFF123840),
                      border: t.taskId == m.currentMissionTask.taskId
                          ? Border.all(color: aqua)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              key: const Key('act0_shell_current_mission_cta'),
              onPressed: m.onStartMission,
              style: FilledButton.styleFrom(
                backgroundColor: aqua,
                foregroundColor: ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Act0AcademyGlyphV1(
                asset: Act0AcademyIconographyV1.forward,
                color: ink,
                size: 19,
              ),
              label: Text(
                'Continue',
                style: style(16, color: ink, weight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, Act0LessonCardV1 lesson, int number) {
    final m = model;
    final earned =
        lesson.taskList.isNotEmpty &&
        lesson.taskList.every((t) => m.completedTaskIds.contains(t.taskId));
    final skipped =
        !earned &&
        lesson.taskList.isNotEmpty &&
        lesson.taskList.every((t) => m.pathClosedTaskIds.contains(t.taskId));
    final expanded = m.detailLessonId == lesson.lessonId;
    final status = earned
        ? 'Completed'
        : skipped
        ? 'Skipped by placement'
        : !lesson.isSelectable
        ? 'Locked · opens as you progress'
        : 'Available';
    return KeyedSubtree(
      key: m.lessonKeyForId(lesson.lessonId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            enabled: lesson.isSelectable,
            expanded: expanded,
            child: InkWell(
              key: Key('act0_learn_cinematic_lesson_${lesson.lessonId}'),
              onTap: lesson.isSelectable
                  ? () => m.onSelectLesson(lesson.lessonId)
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF09232C),
                        border: Border.all(
                          color: earned ? aqua : const Color(0xFF244550),
                        ),
                      ),
                      child: Act0AcademyGlyphV1(
                        asset: Act0AcademyIconographyV1.learn,
                        color: lesson.isSelectable
                            ? muted
                            : const Color(0xFF69838F),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      number.toString().padLeft(2, '0'),
                      style: style(12, color: muted),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act0AcademyLessonTitleV1(context, lesson),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style(
                              14,
                              color: lesson.isSelectable
                                  ? text
                                  : const Color(0xFF87A0AA),
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            status,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: style(11, color: muted),
                          ),
                        ],
                      ),
                    ),
                    if (lesson.isSelectable)
                      RotatedBox(
                        key: Key(
                          'act0_learn_cinematic_disclosure_${lesson.lessonId}',
                        ),
                        quarterTurns: expanded ? 3 : 1,
                        child: const Act0AcademyGlyphV1(
                          asset: Act0AcademyIconographyV1.forward,
                          color: muted,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => m.onSelectLesson(lesson.lessonId),
                child: Text('Close lesson', style: style(12, color: aqua)),
              ),
            ),
            if (m.expandedBodyForLesson(lesson) case final body?) body,
          ],
        ],
      ),
    );
  }
}
