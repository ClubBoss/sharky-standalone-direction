import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/overlay_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manager = OverlayManager.instance;

  setUp(manager.resetForTesting);

  tearDown(manager.resetForTesting);

  test('processes queued overlays sequentially', () async {
    final events = <String>[];

    Future<void> rewardDelegate(Map<String, Object?> payload) async {
      events.add('reward_start');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      events.add('reward_end');
    }

    Future<void> levelDelegate(Map<String, Object?> payload) async {
      events.add('level_start');
      await Future<void>.delayed(const Duration(milliseconds: 4));
      events.add('level_end');
    }

    Future<void> summaryDelegate(Map<String, Object?> payload) async {
      events.add('summary_start');
      await Future<void>.delayed(const Duration(milliseconds: 3));
      events.add('summary_end');
    }

    manager.registerDelegate(OverlayType.reward, rewardDelegate);
    manager.registerDelegate(OverlayType.levelUp, levelDelegate);
    manager.registerDelegate(OverlayType.summary, summaryDelegate);

    final futures = <Future<void>>[
      manager.show(OverlayType.reward, const <String, Object?>{}),
      manager.show(OverlayType.levelUp, const <String, Object?>{}),
      manager.show(OverlayType.summary, const <String, Object?>{}),
    ];

    await Future.wait(futures);

    expect(
      events,
      equals(<String>[
        'reward_start',
        'reward_end',
        'level_start',
        'level_end',
        'summary_start',
        'summary_end',
      ]),
    );
  });
}
