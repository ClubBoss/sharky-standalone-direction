import 'first_decision_mark.dart';

void main() {
  for (final action in ['fold', 'call', 'raise']) {
    final mark = FirstDecisionMark();
    void observe(int world, String? before, String? after, int ms) {
      mark.observe(
        world: world,
        previousOption: before,
        submittedOption: after,
        elapsed: ms,
      );
    }

    observe(1, null, null, 10); // Navigation or unconfirmed selection.
    observe(1, null, 'identify_aces', 20);
    observe(2, null, action, 30);
    observe(1, action, action, 40); // Already submitted.
    if (mark.elapsedMs != null) throw StateError('Marked before submission');
    observe(1, null, action, 50);
    observe(1, null, 'raise', 60);
    if (mark.elapsedMs != 50) throw StateError('Lost the first $action');
  }
}
