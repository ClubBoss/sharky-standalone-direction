/// Durable presentation history, separate from completed decisions and grades.
/// A displayed task is no longer unshown even when it was abandoned unanswered.
/// This is exposure bookkeeping, never proof of learning or elapsed retention.
class Act0ContentExposureV1 {
  const Act0ContentExposureV1({this.hasCompleteLineage = true})
    : presentedTaskIds = const <String>{};

  const Act0ContentExposureV1._({
    required this.presentedTaskIds,
    required this.hasCompleteLineage,
  });

  final Set<String> presentedTaskIds;
  final bool hasCompleteLineage;

  bool wasPresented(String taskId) => presentedTaskIds.contains(taskId.trim());

  Act0ContentExposureV1 present(String taskId) {
    final id = taskId.trim();
    if (id.isEmpty || wasPresented(id)) return this;
    return Act0ContentExposureV1._(
      presentedTaskIds: Set<String>.unmodifiable({...presentedTaskIds, id}),
      hasCompleteLineage: hasCompleteLineage,
    );
  }

  Map<String, Object> toPayload() => {
    'schemaVersion': 1,
    'hasCompleteLineage': hasCompleteLineage,
    'presentedTaskIds': presentedTaskIds.toList()..sort(),
  };

  /// Absence in an older save is unknown, not an empty exposure history.
  /// Malformed payloads retain every valid ID but never regain complete lineage.
  static Act0ContentExposureV1 restore(Object? raw) {
    if (raw is! Map) {
      return const Act0ContentExposureV1(hasCompleteLineage: false);
    }
    final ids = raw['presentedTaskIds'];
    final valid =
        raw['schemaVersion'] == 1 &&
        raw['hasCompleteLineage'] is bool &&
        ids is List &&
        ids.every(
          (id) => id is String && id.trim().isNotEmpty && id == id.trim(),
        ) &&
        ids.toSet().length == ids.length;
    return Act0ContentExposureV1._(
      presentedTaskIds: Set<String>.unmodifiable(
        ids is List
            ? ids
                  .whereType<String>()
                  .map((id) => id.trim())
                  .where((id) => id.isNotEmpty)
            : const <String>[],
      ),
      hasCompleteLineage: valid && raw['hasCompleteLineage'] == true,
    );
  }
}

enum Act0UnshownAvailabilityV1 { available, exhausted, unverified }

/// Candidate availability is not unseen-transfer acceptance. Callers supply
/// only currently unlocked authored assessments, not teaching or repair tasks.
/// A different ID or source revision alone cannot establish independent proof.
class Act0UnshownTaskPoolV1 {
  const Act0UnshownTaskPoolV1._(this.status, this.taskIds);

  final Act0UnshownAvailabilityV1 status;
  final List<String> taskIds;

  static Act0UnshownTaskPoolV1 resolve({
    required Iterable<String> availableAssessmentTaskIds,
    required Act0ContentExposureV1 exposure,
    Set<String> decisionTaskIds = const <String>{},
    Set<String> assistanceExposedTaskIds = const <String>{},
    bool hasCompleteDecisionLineage = true,
  }) {
    final candidates = availableAssessmentTaskIds.toList();
    if (!exposure.hasCompleteLineage ||
        !hasCompleteDecisionLineage ||
        decisionTaskIds.any((id) => id.trim().isEmpty || id != id.trim()) ||
        assistanceExposedTaskIds.any(
          (id) => id.trim().isEmpty || id != id.trim(),
        ) ||
        candidates.any((id) => id.trim().isEmpty || id != id.trim()) ||
        candidates.toSet().length != candidates.length) {
      return const Act0UnshownTaskPoolV1._(
        Act0UnshownAvailabilityV1.unverified,
        <String>[],
      );
    }
    final remaining = candidates
        .where(
          (id) =>
              !exposure.wasPresented(id) &&
              !decisionTaskIds.contains(id) &&
              !assistanceExposedTaskIds.contains(id),
        )
        .toList(growable: false);
    return Act0UnshownTaskPoolV1._(
      remaining.isEmpty
          ? Act0UnshownAvailabilityV1.exhausted
          : Act0UnshownAvailabilityV1.available,
      List<String>.unmodifiable(remaining),
    );
  }

  String get title => switch (status) {
    Act0UnshownAvailabilityV1.available => 'Not yet shown',
    Act0UnshownAvailabilityV1.exhausted => 'No new checks available',
    Act0UnshownAvailabilityV1.unverified => 'New-check history is unavailable',
  };

  String get explanation => switch (status) {
    Act0UnshownAvailabilityV1.available =>
      '${taskIds.length} checks have not been shown in your available lessons. '
          'A new task alone does not prove transfer.',
    Act0UnshownAvailabilityV1.exhausted =>
      'There are no new checks in your available lessons. Familiar practice '
          'is still available, but it will not count as an unseen check.',
    Act0UnshownAvailabilityV1.unverified =>
      'Earlier task exposure could not be verified. You can keep practising, '
          'but familiar work will not be labelled as an unseen check.',
  };
}
