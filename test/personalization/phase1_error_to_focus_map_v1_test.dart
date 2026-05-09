import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/personalization/phase1_error_to_focus_map_v1.dart';
import 'package:poker_analyzer/personalization/personalization_adapter_v1.dart';
import 'package:poker_analyzer/personalization/personalization_next_action_router_v1.dart';

void main() {
  test('phase1 error maps to routable focus label', () {
    final focusLabel = focusLabelForPhase1Error('wrong_action');
    expect(focusLabel, 'range');
    final action = focusLabelToNextAction(focusLabel!);
    expect(action, isNotNull);
    expect(isRoutableNextAction(action!), isTrue);
  });

  test('adapter adds focus label when phase1 error is present', () {
    final phase1ReportJson = <String, Object?>{
      'ok': true,
      'runs': [
        {
          'attempts': [
            {'result': 'correct'},
            {'result': 'incorrect', 'error_type': 'wrong_action'},
          ],
        },
      ],
    };
    final recommendation = recommendFromReports(
      phase1ReportJson: phase1ReportJson,
      phase2ReportJson: {'ok': true},
      phase3ReportJson: {'ok': true},
    );
    expect(recommendation.reason, contains('focus_label=range'));
  });
}
