import 'package:poker_analyzer/content/drill_iso_group_validator.dart';
import 'package:test/test.dart';

void main() {
  test('same iso_group requires same action kind and street context', () {
    final errors = validateDrillIsoGroups(
      moduleId: 'intro_actions',
      filePath: 'content/intro_actions/v1/drills.jsonl',
      entries: <Map<String, dynamic>>[
        {
          'id': 'd1',
          'iso_group': 'intro_orientation_v1_g1',
          'kind': 'drill',
          'street_context': 'preflop',
        },
        {
          'id': 'd2',
          'iso_group': 'intro_orientation_v1_g1',
          'kind': 'drill',
          'street_context': 'preflop',
        },
      ],
    );

    expect(errors, isEmpty);
  });

  test('iso_group mismatch reports deterministic error', () {
    final errors = validateDrillIsoGroups(
      moduleId: 'intro_actions',
      filePath: 'content/intro_actions/v1/drills.jsonl',
      entries: <Map<String, dynamic>>[
        {
          'id': 'd1',
          'iso_group': 'intro_orientation_v1_g1',
          'kind': 'drill',
          'street_context': 'preflop',
        },
        {
          'id': 'd2',
          'iso_group': 'intro_orientation_v1_g1',
          'kind': 'quiz',
          'street_context': 'flop',
        },
      ],
    );

    expect(errors, hasLength(1));
    expect(
      errors.first,
      contains('iso_group=intro_orientation_v1_g1 breaks invariant'),
    );
  });
}
