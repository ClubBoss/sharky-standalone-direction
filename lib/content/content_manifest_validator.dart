import 'release_content_plan.dart';

class ContentManifestValidator {
  static const _validTiers = {1, 2, 3};
  static const _validAvailabilities = {'available', 'comingSoon', 'locked'};

  /// Validates the manifest metadata and returns a list of human-readable
  /// errors. Returns empty list on success.
  static List<String> validateManifest({
    required Map<String, dynamic> manifest,
    required String moduleId,
  }) {
    final errors = <String>[];

    final field = manifest['difficulty_tier'];
    if (field is! int || !_validTiers.contains(field)) {
      errors.add('$moduleId manifest missing difficulty_tier (1-3 required)');
    }

    final errorClass = manifest['error_class'];
    if (errorClass is! String || errorClass.trim().isEmpty) {
      errors.add('$moduleId manifest missing error_class');
    } else {
      final releaseMetadata = ReleaseContentPlanV1.metadataFor(moduleId);
      if (releaseMetadata != null &&
          errorClass.trim() != releaseMetadata.errorClass) {
        errors.add(
          '$moduleId manifest error_class must match release plan (${releaseMetadata.errorClass})',
        );
      }
    }

    final reasoning = manifest['reasoning'];
    if (reasoning is! String || reasoning.trim().isEmpty) {
      errors.add('$moduleId manifest missing reasoning');
    }

    final availability = manifest['availability'];
    if (availability != null) {
      if (availability is! String ||
          !_validAvailabilities.contains(availability.trim())) {
        errors.add('$moduleId manifest has invalid availability');
      } else if (ReleaseContentPlanV1.isRelease(moduleId) &&
          availability.trim() != 'available') {
        errors.add('$moduleId release manifest must be available');
      }
    } else if (ReleaseContentPlanV1.isRelease(moduleId)) {
      errors.add('$moduleId manifest missing availability');
    }

    if (ReleaseContentPlanV1.isRelease(moduleId)) {
      for (final key in manifest.keys) {
        if (key == 'seed' || key == 'timestamp' || key == 'random') {
          errors.add(
            '$moduleId manifest cannot declare $key for release content',
          );
        }
      }
    }

    return errors;
  }
}
