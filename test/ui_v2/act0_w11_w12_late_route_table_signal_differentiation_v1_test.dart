import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

void main() {
  group('late-route table signal', () {
    test('keeps W1 through W10 on the unchanged shared table treatment', () {
      expect(act0LateRouteTableSignalForWorldNumberV1(1), isNull);
      expect(act0LateRouteTableSignalForWorldNumberV1(10), isNull);
    });

    test('gives W11 a concrete real-play transfer cue', () {
      final signal = act0LateRouteTableSignalForWorldNumberV1(11);

      expect(signal?.label, 'W11 · Transfer');
      expect(signal?.detail, contains('cue'));
      expect(signal?.detail, contains('action'));
    });

    test('gives W12 a process-reset cue without opening a future world', () {
      final signal = act0LateRouteTableSignalForWorldNumberV1(12);

      expect(signal?.label, 'W12 · Reset');
      expect(signal?.detail, contains('Read spot'));
      expect(signal?.detail, isNot(contains('World 13')));
      expect(signal?.detail, isNot(contains('master')));
    });

    test('does not expose a late-route signal beyond Volume I', () {
      expect(act0LateRouteTableSignalForWorldNumberV1(13), isNull);
    });
  });
}
