import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_tokens_v1.dart';

void main() {
  testWidgets('UiTokensV1 mirrors the existing non-table palette', (
    tester,
  ) async {
    expect(UiColorsV1.background, AppColors.neutralBg);
    expect(UiColorsV1.surfaceVariant, AppColors.surfaceVariant);
    expect(UiColorsV1.primaryBrand, AppColors.primaryBrand);
    expect(UiColorsV1.accentSuccess, AppColors.accentSuccess);
    expect(UiTextStylesV1.headline, AppTypography.h1);
    expect(UiTextStylesV1.caption, AppTypography.caption);
    expect(UiSpacingV1.small, 8);
    expect(UiRadiiV1.card, 12);
  });
}
