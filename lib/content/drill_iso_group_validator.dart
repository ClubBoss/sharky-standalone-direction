class DrillIsoGroupInvariant {
  const DrillIsoGroupInvariant({
    required this.isoGroup,
    required this.actionKind,
    required this.streetContext,
  });

  final String isoGroup;
  final String actionKind;
  final String streetContext;
}

List<String> validateDrillIsoGroups({
  required String moduleId,
  required String filePath,
  required List<Map<String, dynamic>> entries,
}) {
  final errors = <String>[];
  final baselineByGroup = <String, DrillIsoGroupInvariant>{};

  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    final lineNumber = i + 1;
    final rawGroup = entry['iso_group'];
    if (rawGroup == null) {
      continue;
    }
    if (rawGroup is! String || rawGroup.trim().isEmpty) {
      errors.add('$moduleId $filePath line $lineNumber has invalid iso_group');
      continue;
    }
    final isoGroup = rawGroup.trim();
    final actionKind = (entry['expected_action_kind'] ?? entry['kind'])
        ?.toString();
    final streetContext = (entry['street_context'] ?? 'any')
        .toString()
        .trim()
        .toLowerCase();

    if (actionKind == null || actionKind.trim().isEmpty) {
      errors.add(
        '$moduleId $filePath line $lineNumber iso_group=$isoGroup missing expected_action_kind/kind',
      );
      continue;
    }
    if (streetContext.isEmpty) {
      errors.add(
        '$moduleId $filePath line $lineNumber iso_group=$isoGroup missing street_context',
      );
      continue;
    }

    final current = DrillIsoGroupInvariant(
      isoGroup: isoGroup,
      actionKind: actionKind.trim(),
      streetContext: streetContext,
    );
    final baseline = baselineByGroup[isoGroup];
    if (baseline == null) {
      baselineByGroup[isoGroup] = current;
      continue;
    }
    if (baseline.actionKind != current.actionKind ||
        baseline.streetContext != current.streetContext) {
      errors.add(
        '$moduleId $filePath line $lineNumber iso_group=$isoGroup breaks invariant '
        '(actionKind/streetContext mismatch)',
      );
    }
  }

  return errors;
}
