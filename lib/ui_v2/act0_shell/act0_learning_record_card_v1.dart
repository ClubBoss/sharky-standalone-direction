import 'package:flutter/material.dart';
import 'academy_leaves/act0_academy_leaf_style_v1.dart';
import 'act0_profile_evidence_consumer_v1.dart';
import 'act0_profile_evidence_projection_v1.dart';

/// Both You surfaces consume the same current-source projection.
class Act0LearningRecordCardV1 extends StatelessWidget {
  const Act0LearningRecordCardV1({super.key, required this.projection});
  final Act0ProfileEvidenceProjectionV1 projection;

  @override
  Widget build(BuildContext context) {
    const text = Act0AcademyLeafPaletteV1.text;
    const muted = Act0AcademyLeafPaletteV1.textMuted;
    Widget line(String value, {bool title = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        value,
        style: TextStyle(
          color: title ? text : muted,
          fontSize: title ? 15 : 13,
          fontWeight: title ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
    return Act0AcademyLeafSurfaceV1(
      key: const Key('act0_learning_record'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            line('Your learning evidence', title: true),
            line(
              'Study, practice and independent responses are recorded separately.',
            ),
            if (projection.studiedTopics.isEmpty)
              line('No study record for the current material yet.')
            else
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                textColor: text,
                collapsedTextColor: text,
                iconColor: muted,
                collapsedIconColor: muted,
                title: Text(
                  'Studied topics · ${projection.studiedTopics.length}',
                ),
                subtitle: const Text(
                  'Completed teaching steps',
                  style: TextStyle(color: muted),
                ),
                children: [
                  for (final topic in projection.studiedTopics)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: line(topic.title),
                    ),
                  line(
                    'Study records do not establish independent skill confirmation.',
                  ),
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
                  textColor: text,
                  collapsedTextColor: text,
                  iconColor: muted,
                  collapsedIconColor: muted,
                  title: Text(
                    act0ProfileEvidenceSkillLabelV1(state.skillAtomId) ??
                        'Recorded practice',
                  ),
                  subtitle: Text(
                    state.stateLabel,
                    style: const TextStyle(color: muted),
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
      ),
    );
  }
}
