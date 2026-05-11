import 'package:test/test.dart';
import 'package:poker_analyzer/content/content_manifest_validator.dart';

void main() {
  test('release manifest missing fields reports errors', () {
    final manifest = {'availability': 'available'};
    final errors = ContentManifestValidator.validateManifest(
      manifest: manifest,
      moduleId: 'intro_welcome',
    );

    expect(
      errors,
      contains('intro_welcome manifest missing difficulty_tier (1-3 required)'),
    );
    expect(errors, contains('intro_welcome manifest missing error_class'));
    expect(errors, contains('intro_welcome manifest missing reasoning'));
  });

  test('compatibility manifest availability is no longer enforced', () {
    final manifest = {
      'difficulty_tier': 1,
      'error_class': 'intro_orientation',
      'reasoning': 'Facts only.',
      'availability': 'comingSoon',
    };
    final errors = ContentManifestValidator.validateManifest(
      manifest: manifest,
      moduleId: 'intro_welcome',
    );

    expect(
      errors,
      isNot(contains('intro_welcome release manifest must be available')),
    );
  });

  test('release manifest with wrong error_class reports error', () {
    final manifest = {
      'difficulty_tier': 1,
      'error_class': 'wrong_class',
      'reasoning': 'Facts only.',
      'availability': 'available',
    };
    final errors = ContentManifestValidator.validateManifest(
      manifest: manifest,
      moduleId: 'intro_welcome',
    );

    expect(
      errors,
      contains(
        'intro_welcome manifest error_class must match release plan (intro_orientation)',
      ),
    );
  });
}
