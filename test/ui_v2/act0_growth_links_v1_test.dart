import 'package:poker_analyzer/ui_v2/act0_shell/act0_growth_links_v1.dart';
import 'package:test/test.dart';

void main() {
  test(
    'accepts the exact v1 Learn link and sends invalid or dead links Home',
    () {
      const valid = 'sharky://open/v1/learn';
      expect(
        act0GrowthDestinationForLinkV1(valid),
        Act0GrowthDestinationV1.learn,
      );
      for (final link in [
        'sharky://open/v1/home',
        'sharky://open/v0/learn',
        'sharky://open/v2/learn',
        'sharky://open/v1/deleted',
        'sharky://open/v1/learn/',
        '$valid?task=private',
        '$valid#other',
        'sharky://open:42/v1/learn',
        'sharky://user@open/v1/learn',
        'sharky://open/v1/%6cearn',
        'https://open/v1/learn',
        'sharky://%',
        '',
      ]) {
        expect(
          act0GrowthDestinationForLinkV1(link),
          Act0GrowthDestinationV1.home,
          reason: link,
        );
      }
    },
  );
}
