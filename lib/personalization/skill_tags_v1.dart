List<String> skillTagsForPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  if (normalized.isEmpty) return const <String>[];

  if (normalized.contains('season1_checkpoint_w1_3')) {
    return const <String>['Seat order', 'Blinds', 'Anchor seat'];
  }
  if (normalized.contains('season1_checkpoint_w4_6')) {
    return const <String>['Late seats', 'Blind order', 'Seat reset'];
  }
  if (normalized.contains('season1_checkpoint_w7_10')) {
    return const <String>['Seat recall', 'Blind recall', 'Consistency'];
  }
  if (normalized.contains('season1_checkpoint_global')) {
    return const <String>['Seat order', 'Blinds', 'Consistency'];
  }

  final world = _worldFromPackIdV1(normalized);
  if (world == null) return const <String>[];
  if (world <= 3) {
    return const <String>['Seat order', 'Blinds', 'Position labels'];
  }
  if (world <= 6) {
    return const <String>['Position labels', 'Late seats', 'Consistency'];
  }
  return const <String>['Consistency', 'Position labels', 'Seat recall'];
}

String skillTagsSummaryForPackIdV1(String packId, {int maxTags = 2}) {
  final tags = skillTagsForPackIdV1(packId);
  if (tags.isEmpty) return '';
  final safeMax = maxTags <= 0 ? 1 : maxTags;
  return tags.take(safeMax).join(', ');
}

int? _worldFromPackIdV1(String normalizedPackId) {
  final match = RegExp(r'world(\d+)_').firstMatch(normalizedPackId);
  if (match == null) return null;
  return int.tryParse(match.group(1) ?? '');
}
