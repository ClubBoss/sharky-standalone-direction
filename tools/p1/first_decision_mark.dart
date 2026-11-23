/// Local P1 trace mark. The caller supplies the runner's submitted option.
class FirstDecisionMark {
  int? elapsedMs;

  void observe({
    required int world,
    required String? previousOption,
    required String? submittedOption,
    required int elapsed,
  }) {
    if (world == 1 &&
        previousOption == null &&
        const {'fold', 'call', 'raise'}.contains(submittedOption)) {
      elapsedMs ??= elapsed;
    }
  }
}
