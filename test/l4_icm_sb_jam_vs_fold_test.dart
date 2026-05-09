import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';

import 'package:poker_analyzer/ui/session_player/models.dart';
import 'package:poker_analyzer/ui/session_player/spot_specs.dart';

void main() {
  test('L4 ICM SB Jam vs Fold SSOT invariants', () {
    const k = SpotKind.l4_icm_sb_jam_vs_fold;
    expect(isJamFold(k), true);
    expect(isAutoReplayKind(k), false);
    expect(actionsMap[k], ['jam', 'fold']);
    expect(subtitlePrefix[k]!.startsWith('ICM SB Jam vs Fold • '), true);
  });
}
