import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main() {
  test('season1 checkpoint packs carry one coherent pedagogy ladder', () {
    final w13 = kCampaignPacksV1['season1_checkpoint_w1_3_v1'];
    final w46 = kCampaignPacksV1['season1_checkpoint_w4_6_v1'];
    final w710 = kCampaignPacksV1['season1_checkpoint_w7_10_v1'];

    expect(w13, isNotNull);
    expect(w46, isNotNull);
    expect(w710, isNotNull);

    final early = w13!.first;
    expect(
      early.instructionText,
      'Checkpoint: prove the same seat map is stable enough to start every hand in the right order.',
    );
    expect(
      early.goalText,
      'Goal: keep Button, blinds, and late seats clear before the next chapter.',
    );
    expect(early.guidedScope, 'seats');

    final middle = w46!.first;
    expect(
      middle.instructionText,
      'Checkpoint: keep the same seat map stable while action purpose and board pressure get richer.',
    );
    expect(
      middle.goalText,
      'Goal: hold the seat map steady while later decisions get more layered.',
    );
    expect(middle.guidedScope, 'seats');

    final late = w710!.first;
    expect(
      late.instructionText,
      'Checkpoint: keep the same seat map stable while stack pressure, tournament pressure, and track context change.',
    );
    expect(
      late.goalText,
      'Goal: preserve the table map so later-world decisions still start from the right seat.',
    );
    expect(late.guidedScope, 'seats');

    for (final step in <MicroTaskStep>[early, middle, late]) {
      expect(step.instructionText, isNot(contains('Chapter checkpoint')));
      expect(step.goalText, isNot(contains('confirm')));
    }
  });
}
