import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  test('map global label uses neutral top focus wording', () {
    final label = mapLearningTopFocusLabelV1('Timing');

    expect(label, 'Top focus: Timing');
    expect(label.contains('Top leak:'), isFalse);
  });
}
