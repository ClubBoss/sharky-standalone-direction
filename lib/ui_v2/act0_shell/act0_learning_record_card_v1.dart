import 'package:flutter/material.dart';
import 'skin/act0_skin_tokens_v1.dart';
import 'skin/act0_skin_components_v1.dart';
import 'act0_profile_evidence_consumer_v1.dart';
import 'act0_profile_evidence_projection_v1.dart';

/// Both You surfaces consume the same current-source projection.
class Act0LearningRecordCardV1 extends StatelessWidget {
  const Act0LearningRecordCardV1({
    super.key,
    required this.projection,
    this.onOpenPractice,
  });
  final Act0ProfileEvidenceProjectionV1 projection;
  final VoidCallback? onOpenPractice;

  @override
  Widget build(BuildContext context) {
    const text = Act0SkinTokensV1.onSurface;
    const muted = Act0SkinTokensV1.muted;
    Widget line(String value, {bool title = false}) => Padding(
      padding: const EdgeInsets.only(bottom: Act0SkinTokensV1.gapXs),
      child: Text(
        value,
        style: title ? Act0SkinTokensV1.body : Act0SkinTokensV1.secondary,
      ),
    );
    final week = projection.weeklyAnswers;
    return Act0SkinCardV1(
      key: const Key('act0_learning_record'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (week != null) ...[
            line('Past 7 days', title: true),
            if (week.answers == 0)
              line('Your saved answers will appear here.')
            else ...[
              line(
                '${week.answers} saved ${week.answers == 1 ? 'answer' : 'answers'}',
              ),
              line('${week.correctWithoutHelp} correct without help'),
              if (week.withHelp > 0)
                line('${week.withHelp} answered with help'),
              if (onOpenPractice != null)
                Act0SkinSecondaryButtonV1(
                  controlKey: const Key('act0_weekly_open_practice'),
                  onPressed: onOpenPractice,
                  label: 'Open Practice',
                ),
            ],
            const Divider(color: Act0SkinTokensV1.line),
          ],
          line('Your learning evidence', title: true),
          line(
            'You can see what you studied, practiced, and answered without help.',
          ),
          if (projection.studiedTopics.isEmpty)
            line('No study record for the current material yet.')
          else
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              shape: const Border(),
              collapsedShape: const Border(),
              textColor: text,
              collapsedTextColor: text,
              iconColor: muted,
              collapsedIconColor: muted,
              title: Text(
                'Studied topics · ${projection.studiedTopics.length}',
                style: Act0SkinTokensV1.body,
              ),
              subtitle: const Text(
                'Completed teaching steps',
                style: Act0SkinTokensV1.secondary,
              ),
              children: [
                for (final topic in projection.studiedTopics)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: line(topic.title),
                  ),
                line('To see answers without help, try a practice hand.'),
              ],
            ),
          if (projection.unverifiedStudyCount > 0)
            line(
              '${projection.unverifiedStudyCount} earlier study records need confirmation against current material. Saved history is kept.',
            ),
          if (projection.practiceStates.isEmpty)
            line(
              'No practice record for the current material yet. XP and completed tasks do not confirm a skill.',
            )
          else
            for (final state in projection.practiceStates)
              ExpansionTile(
                key: ValueKey(
                  'act0_learning_record_${state.signal.conceptFamilyId}',
                ),
                tilePadding: EdgeInsets.zero,
                shape: const Border(),
                collapsedShape: const Border(),
                textColor: text,
                collapsedTextColor: text,
                iconColor: muted,
                collapsedIconColor: muted,
                title: Text(
                  act0ProfileEvidenceSkillLabelV1(state.skillAtomId) ??
                      'Recorded practice',
                  style: Act0SkinTokensV1.body,
                ),
                subtitle: Text(
                  state.stateLabel,
                  style: Act0SkinTokensV1.secondary,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: line(state.explanation),
                  ),
                  line(
                    'Current task versions and recorded help are checked. This is recent response evidence; transfer and retention need separate proof.',
                  ),
                ],
              ),
          if (projection.hasUnverifiedPractice)
            line(
              'Earlier responses are saved. Their source or evidence needs confirmation before they can support a current skill claim.',
            ),
        ],
      ),
    );
  }
}
