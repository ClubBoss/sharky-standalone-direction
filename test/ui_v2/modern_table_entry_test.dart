import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/content/scenario_asset_index_v1.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/theme/ui_v2_colors.dart';

class FakeAssetBundle extends AssetBundle {
  FakeAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final asset = assets[key];
    if (asset == null) {
      throw FlutterError('Asset $key not found');
    }
    final bytes = utf8.encode(asset);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final asset = assets[key];
    if (asset == null) {
      throw FlutterError('Asset $key not found');
    }
    return asset;
  }

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) {
    final asset = assets[key];
    if (asset == null) {
      throw FlutterError('Asset $key not found');
    }
    return parser(asset);
  }

  @override
  void evict(String key) {}
}

const _modernTableSourcePath = 'lib/ui_v2/screens/modern_table_screen_v1.dart';

String _readSource(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'Expected $path to exist.');
  return file.readAsStringSync();
}

String _readModernTableSource() {
  return _readSource(_modernTableSourcePath);
}

String _snippet(
  String source,
  String anchor, {
  int before = 0,
  int after = 0,
  String? reason,
}) {
  final index = source.indexOf(anchor);
  expect(index >= 0, isTrue, reason: reason ?? 'Expected to find $anchor.');
  final start = math.max(0, index - before);
  final end = math.min(source.length, index + after);
  return source.substring(start, end);
}

bool _containsPattern(String text, Pattern pattern) {
  if (pattern is RegExp) {
    return pattern.hasMatch(text);
  }
  return text.contains(pattern as String);
}

void _expectContains(String text, Pattern pattern, {required String reason}) {
  expect(_containsPattern(text, pattern), isTrue, reason: reason);
}

void _expectNotContains(
  String text,
  Pattern pattern, {
  required String reason,
}) {
  expect(_containsPattern(text, pattern), isFalse, reason: reason);
}

void main() {
  test('ai_audit_v1_backlog_is_guarded', () {
    const testPath = 'test/ui_v2/modern_table_entry_test.dart';
    final testFile = File(testPath);
    expect(testFile.existsSync(), isTrue);
    final testText = testFile.readAsStringSync();
    const requiredMarkers = [
      'board tray forbids ghost placeholders',
      'dealer puck uses acrylic styling',
      'avatar rings use sweep gradients',
      'board cards use lifted shadow depth',
      'felt uses spotlight center and edge stops',
      'action buttons use glass highlight',
      '_actionButtonContent',
      'watermark stays off board center',
      '_kWatermarkYOffset',
    ];
    final missing = requiredMarkers
        .where((marker) => !testText.contains(marker))
        .toList();
    expect(
      missing,
      isEmpty,
      reason: 'Missing AI audit v1 guard markers: ${missing.join(', ')}',
    );
  });
  testWidgets('Modern Table core keys stay present', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 2)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    const coreKeys = [
      'modern_table_scene',
      'modern_table_oval',
      'modern_table_board',
      'modern_table_board_tray',
      'modern_table_action_bar',
      'modern_table_hero_cards',
    ];
    for (final key in coreKeys) {
      expect(find.byKey(Key(key)), findsOneWidget);
    }
    final banner = find.byKey(const Key('modern_table_debug_banner'));
    expect(banner, findsOneWidget);
    expect(
      find.descendant(
        of: banner,
        matching: find.textContaining('VISUAL_SSOT_V1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Modern Table debug banner shows scenario source', (
    tester,
  ) async {
    String bannerText() {
      final banner = find.byKey(const Key('modern_table_debug_banner'));
      final textFinder = find.descendant(
        of: banner,
        matching: find.byType(Text),
      );
      final textWidget = tester.widget<Text>(textFinder.first);
      return textWidget.data ?? '';
    }

    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 2)),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    final defaultText = bannerText();
    expect(defaultText.contains('VISUAL_SSOT_V1'), isTrue);
    expect(defaultText.contains('default'), isTrue);

    final jsonSpec = {
      'schema_version': 1,
      'seatCount': 2,
      'heroSeat': 0,
      'initialStacks': [120, 220],
      'actingSeatStart': 0,
      'decisionNodeV1': {
        'street': 'preflop',
        'legalActions': ['Call'],
        'solutionBestAction': 'Call',
      },
    };
    await tester.pumpWidget(
      MaterialApp(
        home: ModernTableScreenV1(
          scenarioJson: const JsonEncoder().convert(jsonSpec),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    final jsonText = bannerText();
    expect(jsonText.contains('VISUAL_SSOT_V1'), isTrue);
    expect(jsonText.contains('json'), isTrue);

    await tester.pumpWidget(
      const MaterialApp(
        home: ModernTableScreenV1(
          scenarioAssetPath: 'assets/scenarios/demo_hu.json',
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    final assetText = bannerText();
    expect(assetText.contains('VISUAL_SSOT_V1'), isTrue);
    expect(assetText.contains('asset'), isTrue);
  });

  test('Modern Table uses Visual SSOT single source', () {
    final sourceText = _readModernTableSource();
    expect(sourceText.contains('class _ModernTableVisualSsotV1'), isTrue);
    expect(sourceText.contains('VISUAL_SSOT_V1'), isTrue);
    const token = '_ModernTableVisualSsotV1.';
    final matches = token.allMatches(sourceText);
    expect(matches.length >= 8, isTrue);
  });

  test('Modern Table text scaling clamp is single-site and scoped', () {
    final sourceText = _readModernTableSource();
    const clampToken = 'withClampedTextScaling';
    final clampMatches = clampToken.allMatches(sourceText).toList();
    expect(clampMatches.length, 1);
    final clampIndex = sourceText.indexOf(clampToken);
    expect(clampIndex >= 0, isTrue);
    final sceneIndex = sourceText.indexOf('modern_table_scene');
    expect(sceneIndex >= 0, isTrue);
    final distance = (clampIndex - sceneIndex).abs();
    expect(distance <= 2000, isTrue);
  });

  test('Modern Table forbids BackdropFilter for perf', () {
    final sourceText = _readModernTableSource();
    expect(
      sourceText.contains('BackdropFilter'),
      isFalse,
      reason:
          'ModernTableScreenV1 must not use BackdropFilter; disallowed for perf.',
    );
  });

  test('Modern Table forbids Opacity widgets for perf', () {
    final sourceText = _readModernTableSource();
    final opacityWidget = RegExp(r'\bOpacity\(').hasMatch(sourceText);
    expect(
      opacityWidget,
      isFalse,
      reason:
          'ModernTableScreenV1 must not use Opacity; prefer colors/alpha for perf.',
    );
  });

  test('Modern Table dealer puck uses acrylic styling', () {
    const dealerKey = 'modern_table_dealer_chip';
    final sourceText = _readModernTableSource();
    final snippet = _snippet(
      sourceText,
      dealerKey,
      after: 4000,
      reason: 'Expected dealer puck block for styling.',
    );
    _expectContains(
      snippet,
      'RadialGradient(',
      reason: 'Dealer puck must be acrylic: radial gradient + rim highlight.',
    );
    final rimStroke =
        RegExp(r'border:[\s\S]*?Border\.all\(').hasMatch(snippet) ||
        RegExp(r'BorderSide\(').hasMatch(snippet);
    expect(
      rimStroke,
      isTrue,
      reason: 'Dealer puck must be acrylic: radial gradient + rim highlight.',
    );
    final hasGlint =
        RegExp(r'RadialGradient\(').hasMatch(snippet) ||
        RegExp(r'\bglint\b').hasMatch(snippet);
    expect(
      hasGlint,
      isTrue,
      reason: 'Dealer puck should include a specular glint element.',
    );
    _expectNotContains(
      snippet,
      RegExp(r'\bOpacity\('),
      reason: 'Dealer puck block must not use Opacity widgets.',
    );
  });

  test('Modern Table avatar rings use sweep gradients', () {
    const ringToken = 'avatarRingColor';
    final sourceText = _readModernTableSource();
    final snippet = _snippet(
      sourceText,
      ringToken,
      after: 4000,
      reason: 'Expected avatar ring definition.',
    );
    _expectContains(
      snippet,
      'SweepGradient(',
      reason: 'Avatar bezels must be metallic: sweep gradient required.',
    );
    final alphaStops = RegExp(
      r'Color\(0x(?!FF)[0-9A-Fa-f]{8}\)',
    ).allMatches(snippet).length;
    expect(
      alphaStops >= 2,
      isTrue,
      reason: 'Avatar ring gradient should include alpha literal stops.',
    );
    _expectNotContains(
      snippet,
      RegExp(r'\bOpacity\('),
      reason: 'Avatar ring block must not use Opacity widgets.',
    );
  });

  test('Modern Table bet slider uses premium styling', () {
    const trackKey = 'modern_table_bet_slider_track';
    final sourceText = _readModernTableSource();
    final snippet = _snippet(
      sourceText,
      trackKey,
      after: 2600,
      reason: 'Expected bet slider track block.',
    );
    final hasThumbBorder =
        RegExp(r'Border\.all\(').hasMatch(snippet) ||
        RegExp(r'BorderSide\(').hasMatch(snippet);
    expect(
      hasThumbBorder,
      isTrue,
      reason: 'Slider thumb should include an explicit border.',
    );
    final hasThumbDepth =
        RegExp(r'BoxShadow\(').hasMatch(snippet) ||
        RegExp(r'RadialGradient\(').hasMatch(snippet);
    expect(
      hasThumbDepth,
      isTrue,
      reason: 'Slider thumb should use shadow or gradient for depth.',
    );
    final hasTrackThickness =
        RegExp(r'height:\s*10').hasMatch(snippet) ||
        RegExp(r'borderRadius:').hasMatch(snippet);
    expect(
      hasTrackThickness,
      isTrue,
      reason: 'Slider track should indicate increased thickness or styling.',
    );
    _expectNotContains(
      snippet,
      RegExp(r'\bOpacity\('),
      reason: 'Slider block must not use Opacity widgets.',
    );
  });

  test('Modern Table seat text uses off-white hierarchy', () {
    final sourceText = _readModernTableSource();
    final seatSnippet = _snippet(
      sourceText,
      "'P\${index + 1}'",
      after: 2200,
      reason: 'Expected seat label block.',
    );
    expect(
      RegExp(r'Color\(\s*0xB3E2E8F0').hasMatch(seatSnippet),
      isTrue,
      reason: 'Seat labels should use a dim off-white literal.',
    );
    final stackSnippet = _snippet(
      sourceText,
      'stack.toString()',
      after: 600,
      reason: 'Expected seat stack value block.',
    );
    expect(
      RegExp(r'Color\(\s*0xFFF1F5F9').hasMatch(stackSnippet),
      isTrue,
      reason: 'Seat values should use an off-white value literal.',
    );
    _expectNotContains(
      seatSnippet,
      RegExp(r'Colors\.white|0xFFFFFFFF'),
      reason: 'Seat text block should avoid pure white text literals.',
    );
    _expectNotContains(
      seatSnippet,
      RegExp(r'\bOpacity\('),
      reason: 'Seat text block must not use Opacity widgets.',
    );
  });

  test('Modern Table action bar text avoids pure white', () {
    final sourceText = _readModernTableSource();
    final raiseSnippet = _snippet(
      sourceText,
      'modern_table_action_raise',
      after: 700,
      reason: 'Expected raise button block.',
    );
    _expectContains(
      raiseSnippet,
      'Color(0xFFF1F5F9)',
      reason: 'Raise button should use an off-white text literal.',
    );
    _expectNotContains(
      raiseSnippet,
      RegExp(r'Colors\.white|0xFFFFFFFF'),
      reason: 'Raise button text should not be pure white.',
    );
    _expectNotContains(
      raiseSnippet,
      RegExp(r'\bOpacity\('),
      reason: 'Action button block must not use Opacity widgets.',
    );
  });

  test('Modern Table action buttons use glass highlight', () {
    final sourceText = _readModernTableSource();
    final snippet = _snippet(
      sourceText,
      'Widget _actionButtonContent',
      after: 900,
      reason: 'Expected action button content block.',
    );
    _expectContains(
      snippet,
      'LinearGradient',
      reason:
          'Action buttons must have glass finish: highlight gradient required.',
    );
    _expectContains(
      snippet,
      'Color(0x24FFFFFF)',
      reason:
          'Action buttons must have glass finish: highlight gradient required.',
    );
  });

  test('Modern Table hit targets enforce >=44 min height', () {
    final sourceText = _readModernTableSource();
    final actionSnippet = _snippet(
      sourceText,
      'modern_table_action_raise',
      after: 800,
      reason: 'Expected action button block.',
    );
    expect(
      actionSnippet.contains('Size.fromHeight(56)'),
      isTrue,
      reason: 'Action buttons must use a min height >= 44.',
    );

    final sliderSnippet = _snippet(
      sourceText,
      'modern_table_bet_slider_stub',
      after: 600,
      reason: 'Expected bet slider tap target block.',
    );
    expect(
      sliderSnippet.contains('height: 44'),
      isTrue,
      reason: 'Bet slider tap target must be at least 44px tall.',
    );
  });

  test('Modern Table numeric labels use longestLine width basis', () {
    final sourceText = _readModernTableSource();
    final stackSnippet = _snippet(
      sourceText,
      'stack.toString()',
      after: 900,
      reason: 'Expected stack value block.',
    );
    expect(
      stackSnippet.contains('textWidthBasis: TextWidthBasis.longestLine'),
      isTrue,
      reason: 'Stack amounts should use longestLine width basis.',
    );

    final betSnippet = _snippet(
      sourceText,
      'modern_table_bet_slider_value',
      after: 800,
      reason: 'Expected bet slider value block.',
    );
    expect(
      betSnippet.contains('textWidthBasis: TextWidthBasis.longestLine'),
      isTrue,
      reason: 'Bet slider value should use longestLine width basis.',
    );

    final raiseSnippet = _snippet(
      sourceText,
      'modern_table_action_raise',
      after: 1200,
      reason: 'Expected raise button block.',
    );
    expect(
      raiseSnippet.contains('textWidthBasis: TextWidthBasis.longestLine'),
      isTrue,
      reason: 'Raise percent label should use longestLine width basis.',
    );
  });

  test('Modern Table numeric labels use tabular figures', () {
    final sourceText = _readModernTableSource();
    final stackSnippet = _snippet(
      sourceText,
      'stack.toString()',
      after: 900,
      reason: 'Expected stack value block.',
    );
    expect(
      stackSnippet.contains('FontFeature.tabularFigures()'),
      isTrue,
      reason: 'Stack amounts should use tabular figures.',
    );

    final betSnippet = _snippet(
      sourceText,
      'modern_table_bet_slider_value',
      after: 800,
      reason: 'Expected bet slider value block.',
    );
    expect(
      betSnippet.contains('FontFeature.tabularFigures()'),
      isTrue,
      reason: 'Bet slider value should use tabular figures.',
    );

    final raiseSnippet = _snippet(
      sourceText,
      'modern_table_action_raise',
      after: 800,
      reason: 'Expected raise button block.',
    );
    expect(
      raiseSnippet.contains('FontFeature.tabularFigures()'),
      isTrue,
      reason: 'Raise percent label should use tabular figures.',
    );

    final potSnippet = _snippet(
      sourceText,
      'pot.toString()',
      after: 600,
      reason: 'Expected pot value block.',
    );
    expect(
      potSnippet.contains('FontFeature.tabularFigures()'),
      isTrue,
      reason: 'Pot value should use tabular figures.',
    );
  });

  test('Modern Table dead seats remove ring and dim avatar', () {
    final sourceText = _readModernTableSource();
    const deadToken = 'isDeadSeat';
    final snippet = _snippet(
      sourceText,
      deadToken,
      after: 12000,
      reason: 'Expected dead seat branch.',
    );
    final constIndex = snippet.indexOf('const BoxDecoration');
    final nextBranchIndex = snippet.indexOf(': BoxDecoration', constIndex);
    expect(constIndex >= 0, isTrue);
    expect(nextBranchIndex > constIndex, isTrue);
    final deadBranch = snippet.substring(constIndex, nextBranchIndex);
    expect(
      deadBranch.contains('Border'),
      isFalse,
      reason: 'Dead seat ring should not include a border or stroke.',
    );
    expect(
      RegExp(r'Color\(0x4D[0-9A-Fa-f]{6}\)').hasMatch(snippet),
      isTrue,
      reason: 'Dead seat avatar should use low-alpha color literals.',
    );
    _expectNotContains(
      snippet,
      RegExp(r'\bOpacity\('),
      reason: 'Seat block must not use Opacity widgets.',
    );
  });

  test('Modern Table pot label is dimmed and value stays dominant', () {
    final sourceText = _readModernTableSource();
    final potBlock = RegExp(r'class _PotLabel[\s\S]*?\n}\n');
    final match = potBlock.firstMatch(sourceText);
    expect(match, isNotNull);
    final snippet = match!.group(0) ?? '';
    final dimLabelColor = RegExp(
      r"'POT'[\s\S]*?Color\(0x(?!FF)[0-9A-Fa-f]{2}[0-9A-Fa-f]{6}\)",
    );
    expect(
      dimLabelColor.hasMatch(snippet),
      isTrue,
      reason: 'Pot label color should use a non-opaque alpha literal.',
    );
    final valueColorOpaque = RegExp(
      r'pot\.toString\(\)[\s\S]*?Color\(0xFF[0-9A-Fa-f]{6}\)',
    );
    expect(
      valueColorOpaque.hasMatch(snippet),
      isTrue,
      reason: 'Pot value color should remain fully opaque.',
    );
    _expectNotContains(
      snippet,
      RegExp(r'\bOpacity\('),
      reason: 'Pot label block must not use Opacity widgets.',
    );
  });

  test('Modern Table action bar plinth uses vertical gradient', () {
    final sourceText = _readModernTableSource();
    final snippet = _snippet(
      sourceText,
      'modern_table_action_bar',
      after: 2000,
      reason: 'Expected action bar block.',
    );
    expect(
      RegExp(r'Color\(0xFF020617\)').hasMatch(snippet),
      isTrue,
      reason: 'Action bar should include a near-black plinth color literal.',
    );
    final verticalGradient = RegExp(
      r'LinearGradient\([\s\S]*?begin:\s*Alignment\.bottomCenter[\s\S]*?end:\s*Alignment\.topCenter',
    );
    expect(
      verticalGradient.hasMatch(snippet),
      isTrue,
      reason: 'Action bar plinth should use a vertical gradient.',
    );
    _expectNotContains(
      snippet,
      RegExp(r'\bOpacity\('),
      reason: 'Action bar block must not use Opacity widgets.',
    );
  });

  test('Modern Table action bar extends into safe-area chin', () {
    final sourceText = _readModernTableSource();
    final snippet = _snippet(
      sourceText,
      'modern_table_action_bar',
      after: 5200,
      reason: 'Expected action bar block.',
    );
    expect(
      RegExp(r'height:\s*bottomPadding').hasMatch(snippet),
      isTrue,
      reason: 'Action bar should render a safe-area chin region.',
    );
    expect(
      snippet.contains('Alignment.bottomCenter') &&
          snippet.contains('Alignment.topCenter'),
      isTrue,
      reason: 'Chin should reuse the action bar vertical gradient.',
    );
    _expectNotContains(
      snippet,
      RegExp(r'\bOpacity\('),
      reason: 'Action bar chin must not use Opacity widgets.',
    );
  });

  test('Modern Table villain card back uses red fill and light border', () {
    const sourcePath = 'lib/ui_v2/table/widgets/hole_cards_widget_v1.dart';
    final sourceText = _readSource(sourcePath);
    final cardBackBlock = RegExp(r'_cardBack\(\)[\s\S]*?\}', multiLine: true);
    final match = cardBackBlock.firstMatch(sourceText);
    expect(match, isNotNull);
    final snippet = match!.group(0) ?? '';
    expect(
      snippet.contains('0xFF7F1D1D'),
      isTrue,
      reason: 'Villain card back should use deep desaturated red fill.',
    );
    final borderLiteral = RegExp(
      r'Border\.all\([^)]*Color\(0x[0-9A-Fa-f]{8}\)',
    );
    expect(
      borderLiteral.hasMatch(snippet),
      isTrue,
      reason: 'Villain card back should use a light border literal.',
    );
    expect(
      snippet.contains('card_back.png'),
      isFalse,
      reason: 'Villain card back must not use the old grey asset placeholder.',
    );
    expect(
      RegExp(r'Colors\.grey').hasMatch(snippet),
      isFalse,
      reason: 'Villain card back should not use grey placeholders.',
    );
  });

  test('Modern Table board tray uses alpha color literal', () {
    final sourceText = _readModernTableSource();
    expect(sourceText.contains('modern_table_board_tray'), isTrue);
    final trayColorLiteral = RegExp(
      r'modern_table_board_tray[\s\S]*?Color\(0x[0-9A-Fa-f]{8}\)',
    );
    expect(
      trayColorLiteral.hasMatch(sourceText),
      isTrue,
      reason:
          'Board tray should use an alpha color literal (0x..) for translucency.',
    );
    final traySnippet = _snippet(
      sourceText,
      'modern_table_board_tray',
      after: 300,
      reason: 'Expected board tray block.',
    );
    _expectNotContains(
      traySnippet,
      'Opacity(',
      reason: 'Board tray must not use an Opacity widget.',
    );
  });

  test('Modern Table board overlay removes ghost placeholders', () {
    final sourceText = _readModernTableSource();
    final overlayIndex = sourceText.indexOf('class _BoardOverlay');
    expect(overlayIndex >= 0, isTrue);
    final overlayEndIndex = sourceText.indexOf('class _OvalFeltPainter');
    final overlaySnippet = sourceText.substring(
      overlayIndex,
      overlayEndIndex > overlayIndex ? overlayEndIndex : sourceText.length,
    );
    final dashedTokens = RegExp(
      r'dash|dashed|PathDash|dotted|_DashedRoundedRectPainter',
      caseSensitive: false,
    );
    expect(
      dashedTokens.hasMatch(overlaySnippet),
      isFalse,
      reason: 'Board overlay must not use dashed or wireframe placeholders.',
    );
    expect(
      overlaySnippet.contains('CustomPaint('),
      isFalse,
      reason: 'Board overlay should not paint placeholder outlines.',
    );
    expect(
      overlaySnippet.contains('isDealt'),
      isTrue,
      reason: 'Board overlay should gate dealt cards by street state.',
    );
    expect(
      overlaySnippet.contains('modern_table_board_card_'),
      isTrue,
      reason: 'Board overlay should keep card keys for layout tests.',
    );
    expect(
      overlaySnippet.contains('debugBoardCardLabels'),
      isTrue,
      reason: 'Board overlay should accept debug card labels.',
    );
    expect(
      RegExp(r"label:\s*''").hasMatch(overlaySnippet),
      isFalse,
      reason: 'Board overlay should not hardcode empty card labels.',
    );
    _expectNotContains(
      overlaySnippet,
      RegExp(r'\bOpacity\('),
      reason: 'Board overlay must not use Opacity widgets.',
    );
  });

  test('Modern Table board tray forbids ghost placeholders', () {
    final sourceText = _readModernTableSource();
    final traySnippet = _snippet(
      sourceText,
      'modern_table_board_tray',
      after: 2200,
      reason: 'Expected board tray block.',
    );
    // EV-TOP-PICK closure (Modern Table AI audit v1).
    final forbidden = RegExp(
      r'\b(dash|dashed|placeholder|ghost|wireframe|stroke)\b',
      caseSensitive: false,
    );
    expect(
      forbidden.hasMatch(traySnippet),
      isFalse,
      reason: 'Ghost placeholders are forbidden in board/tray.',
    );
    expect(
      RegExp(
        r'empty[_-]?card|empty\s*card',
        caseSensitive: false,
      ).hasMatch(traySnippet),
      isFalse,
      reason: 'Empty card markers are forbidden in board/tray.',
    );
  });

  test('Modern Table card surface uses gradient and border', () {
    final sourceText = _readModernTableSource();
    final cardSnippet = _snippet(
      sourceText,
      'class _PlayingCardSurface',
      after: 900,
      reason: 'Expected playing card surface block.',
    );
    expect(cardSnippet.contains('LinearGradient'), isTrue);
    expect(cardSnippet.contains('Color(0xFFFFFFFF)'), isTrue);
    expect(cardSnippet.contains('Color(0xFFF1F5F9)'), isTrue);
    final borderLiteral = RegExp(
      r'Border\.all\(color: const Color\(0xFFE5E7EB\)',
    );
    expect(borderLiteral.hasMatch(cardSnippet), isTrue);
    expect(cardSnippet.contains('Colors.white'), isFalse);
  });

  test('Modern Table card shadows are lifted and soft', () {
    final sourceText = _readModernTableSource();
    final cardSnippet = _snippet(
      sourceText,
      'class _PlayingCardSurface',
      after: 1400,
      reason: 'Expected playing card surface block.',
    );
    final shadowIndex = cardSnippet.indexOf('BoxShadow(');
    expect(
      shadowIndex >= 0,
      isTrue,
      reason: 'Card surface should define a shadow.',
    );
    final shadowSnippet = cardSnippet.substring(
      shadowIndex,
      math.min(cardSnippet.length, shadowIndex + 300),
    );
    expect(
      RegExp(r'Color\(0x(?!FF)[0-9A-Fa-f]{8}\)').hasMatch(shadowSnippet),
      isTrue,
      reason: 'Card shadow should use a non-opaque alpha literal.',
    );
    expect(
      RegExp(r'offset:\s*Offset\(0,\s*[1-9]').hasMatch(shadowSnippet),
      isTrue,
      reason: 'Card shadow should have a y-offset >= 1.',
    );
    expect(
      RegExp(r'blurRadius:\s*([6-9]|[1-9]\d)').hasMatch(shadowSnippet),
      isTrue,
      reason: 'Card shadow blur should be at least 6.',
    );
    _expectNotContains(
      cardSnippet,
      RegExp(r'\bOpacity\('),
      reason: 'Card surface block must not use Opacity widgets.',
    );
  });

  test('Modern Table board cards use lifted shadow depth', () {
    final sourceText = _readModernTableSource();
    final cardSnippet = _snippet(
      sourceText,
      'class _PlayingCardSurface',
      after: 1400,
      reason: 'Expected playing card surface block.',
    );
    _expectContains(
      cardSnippet,
      'blurRadius: 7',
      reason: 'Board cards must read as lifted: shadow depth required.',
    );
    _expectContains(
      cardSnippet,
      'Offset(0, 4)',
      reason: 'Board cards must read as lifted: shadow depth required.',
    );
  });

  test('Modern Table rail stitching highlight exists', () {
    final sourceText = _readModernTableSource();
    final painterIndex = sourceText.indexOf('class _OvalFeltPainter');
    expect(painterIndex >= 0, isTrue);
    final painterEndIndex = sourceText.indexOf('class _PotLabel');
    final painterSnippet = sourceText.substring(
      painterIndex,
      painterEndIndex > painterIndex ? painterEndIndex : sourceText.length,
    );
    expect(sourceText.contains('_kRailStitchHighlight'), isTrue);
    expect(sourceText.contains('Color(0x14FFFFFF)'), isTrue);
    expect(painterSnippet.contains('inflate(1.0)'), isTrue);
    _expectNotContains(
      painterSnippet,
      RegExp(r'\bOpacity\('),
      reason: 'Rail stitching block must not use Opacity widgets.',
    );
  });

  test('Modern Table felt includes vignette gradient', () {
    final sourceText = _readModernTableSource();
    final painterIndex = sourceText.indexOf('class _OvalFeltPainter');
    expect(painterIndex >= 0, isTrue);
    final painterEndIndex = sourceText.indexOf('class _PotLabel');
    final painterSnippet = sourceText.substring(
      painterIndex,
      painterEndIndex > painterIndex ? painterEndIndex : sourceText.length,
    );
    expect(
      painterSnippet.contains('RadialGradient'),
      isTrue,
      reason: 'Felt should include a vignette radial gradient.',
    );
    expect(
      painterSnippet.contains('stops: [0.0, 0.7, 1.0]'),
      isTrue,
      reason: 'Vignette should use multiple gradient stops.',
    );
    expect(
      painterSnippet.contains('Color(0x66030A10)'),
      isTrue,
      reason: 'Vignette should include a dark edge color literal.',
    );
    _expectNotContains(
      painterSnippet,
      RegExp(r'\bOpacity\('),
      reason: 'Felt painter must not use Opacity widgets.',
    );
  });

  test('Modern Table felt uses spotlight center and edge stops', () {
    final sourceText = _readModernTableSource();
    final snippet = _snippet(
      sourceText,
      'final fillPaint = Paint()',
      after: 600,
      reason: 'Expected felt spotlight gradient block.',
    );
    _expectContains(
      snippet,
      'RadialGradient',
      reason: 'Felt must have spotlight: center/edge stops required.',
    );
    _expectContains(
      snippet,
      'Color(0xFF215B76)',
      reason: 'Felt must have spotlight: center/edge stops required.',
    );
    _expectContains(
      snippet,
      'Color(0xFF04121A)',
      reason: 'Felt must have spotlight: center/edge stops required.',
    );
  });

  test('Modern Table watermark stays off board center', () {
    final sourceText = _readModernTableSource();
    final snippet = _snippet(
      sourceText,
      'final watermarkStyle',
      after: 700,
      reason: 'Expected watermark paint block.',
    );
    _expectContains(
      snippet,
      '_kWatermarkYOffset',
      reason: 'Watermark must not sit behind board cards.',
    );
    _expectContains(
      snippet,
      'Color(0x1F93C5E6)',
      reason: 'Watermark must not sit behind board cards.',
    );
    _expectNotContains(
      snippet,
      RegExp(r'\bOpacity\('),
      reason: 'Watermark must not sit behind board cards.',
    );
  });

  test('Modern Table requires RepaintBoundary for perf', () {
    final sourceText = _readModernTableSource();
    expect(
      sourceText.contains('RepaintBoundary'),
      isTrue,
      reason:
          'ModernTableScreenV1 must include a RepaintBoundary to avoid excessive repaints.',
    );
  });

  test('Modern Table wraps felt and action bar with RepaintBoundary', () {
    final sourceText = _readModernTableSource();
    final feltSnippet = _snippet(
      sourceText,
      'modern_table_oval_paint',
      before: 500,
      after: 500,
      reason: 'Expected felt paint block.',
    );
    expect(
      feltSnippet.contains('RepaintBoundary'),
      isTrue,
      reason: 'Felt painter should be isolated with RepaintBoundary.',
    );

    final actionSnippet = _snippet(
      sourceText,
      'modern_table_action_bar',
      before: 500,
      after: 800,
      reason: 'Expected action bar block.',
    );
    expect(
      actionSnippet.contains('RepaintBoundary'),
      isTrue,
      reason: 'Action bar should be isolated with RepaintBoundary.',
    );
  });

  testWidgets('Modern Table clamps text scaling only inside scene', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaleFactor: 2.0),
        child: MaterialApp(home: ModernTableScreenV1(seatCount: 2)),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    final sceneContext = tester.element(
      find.byKey(const Key('modern_table_scene')),
    );
    final headerContext = tester.element(
      find.byKey(const Key('modern_table_header')),
    );
    final sceneScaler = MediaQuery.textScalerOf(sceneContext);
    final headerScaler = MediaQuery.textScalerOf(headerContext);
    expect(sceneScaler.scale(100.0) <= 115.0, isTrue);
    expect(headerScaler.scale(100.0) >= 200.0, isTrue);
  });
  Future<void> spawnAndOpenModernTable(
    WidgetTester tester, {
    Duration settleTimeout = const Duration(seconds: 5),
    bool waitForSettlement = true,
    bool skipInitialSettle = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: UiV2ProgressMapScreenV2()));
    await tester.pump();
    if (!skipInitialSettle) {
      await tester.pumpAndSettle();
    }
    final modernTableButton = find.text('Modern Table');
    if (modernTableButton.evaluate().isNotEmpty) {
      final modernTableButtonParent = find.ancestor(
        of: modernTableButton,
        matching: find.byType(TextButton),
      );
      expect(modernTableButtonParent, findsOneWidget);
      final modernTableButtonWidget = tester.widget<TextButton>(
        modernTableButtonParent,
      );
      modernTableButtonWidget.onPressed?.call();
    } else {
      final devMenu = find.byKey(const Key('progress_map_dev_menu'));
      if (devMenu.evaluate().isNotEmpty) {
        await tester.tap(devMenu);
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('progress_map_dev_menu_modern_table')),
        );
      } else {
        final openButton = find.byKey(
          const Key('progress_map_modern_table_open'),
        );
        if (openButton.evaluate().isNotEmpty) {
          await tester.tap(openButton);
        } else {
          await tester.pumpWidget(
            const MaterialApp(home: ModernTableScreenV1(seatCount: 6)),
          );
          return;
        }
      }
    }
    if (waitForSettlement) {
      await tester.pumpAndSettle(settleTimeout);
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  ScenarioSpecV1 _testScenarioSpec({
    int seatCount = 4,
    int actingSeatStart = 2,
    int heroSeat = 0,
  }) {
    return ScenarioSpecV1(
      seatCount: seatCount,
      heroSeat: heroSeat,
      initialStacks: List<int>.filled(seatCount, 900),
      actingSeatStart: actingSeatStart,
      decisionNodeV1: const DecisionNodeV1(
        street: Street.preflop,
        legalActions: ['Fold', 'Call', 'Raise'],
        solutionBestAction: 'Call',
      ),
    );
  }

  testWidgets('Modern Table entry opens placeholder screen', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 640);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
    await spawnAndOpenModernTable(tester, waitForSettlement: true);

    expect(find.text('Modern Table (V1)'), findsOneWidget);
    expect(find.byKey(const Key('modern_table_debug_metrics')), findsNothing);
    expect(find.byKey(const Key('modern_table_header')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_scene')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_reason')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_actions')), findsOneWidget);

    final ovalBox = tester.renderObject<RenderBox>(
      find.byKey(const Key('modern_table_oval')),
    );
    expect(ovalBox.size.height, greaterThan(ovalBox.size.width * 0.9));
    for (var i = 0; i < 6; i++) {
      expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
    }
    for (var i = 0; i < 6; i++) {
      expect(find.text('P${i + 1}'), findsOneWidget);
      expect(find.text('1000'), findsWidgets);
    }
  });

  testWidgets('Hero cards do not cover hero stack pill', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 640);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
    await tester.pumpWidget(
      const MaterialApp(
        home: ModernTableScreenV1(
          scenarioAssetPath: 'assets/scenarios/demo_hu.json',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final heroCardsRect = tester.getRect(
      find.byKey(const Key('modern_table_hero_cards')),
    );
    final stackRect = tester.getRect(
      find.byKey(const Key('modern_table_seat_stack_pill_P1')),
    );
    expect(heroCardsRect.overlaps(stackRect), isFalse);
  });

  testWidgets(
    'Action bar exposes bet slider and CTA hierarchy on small phone',
    (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(360, 640);
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MaterialApp(home: ModernTableScreenV1(seatCount: 6)),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final stub = find.byKey(const Key('modern_table_bet_slider_stub'));
      expect(stub, findsOneWidget);

      expect(find.byKey(const Key('modern_table_action_fold')), findsOneWidget);
      expect(find.byKey(const Key('modern_table_action_call')), findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_action_raise')),
        findsOneWidget,
      );

      final foldText = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('modern_table_action_fold')),
          matching: find.byType(Text),
        ),
      );
      expect(foldText.data, 'Fold');
      expect(foldText.maxLines, 1);

      expect(
        tester.widget(find.byKey(const Key('modern_table_action_raise'))),
        isA<FilledButton>(),
      );
      expect(
        tester.widget(find.byKey(const Key('modern_table_action_fold'))),
        anyOf(isA<OutlinedButton>(), isA<TextButton>()),
      );

      expect(
        tester.widget(find.byKey(const Key('modern_table_action_raise'))),
        isA<FilledButton>(),
      );
      expect(
        tester.widget(find.byKey(const Key('modern_table_action_fold'))),
        anyOf(isA<OutlinedButton>(), isA<TextButton>()),
      );
    },
  );

  testWidgets('Bet slider drag updates value', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 640);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: 24)),
        child: MaterialApp(home: ModernTableScreenV1()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final trackFinder = find.byKey(const Key('modern_table_bet_slider_track'));
    final gestureFinder = find.byKey(
      const Key('modern_table_bet_slider_gesture'),
    );
    final knobFinder = find.byKey(const Key('modern_table_bet_slider_knob'));
    final valueFinder = find.byKey(const Key('modern_table_bet_slider_value'));
    expect(trackFinder, findsOneWidget);
    expect(gestureFinder, findsOneWidget);
    expect(knobFinder, findsOneWidget);
    expect(valueFinder, findsOneWidget);

    final initialText = tester
        .widget<Text>(
          find.descendant(of: valueFinder, matching: find.byType(Text)),
        )
        .data;
    final knobRectBefore = tester.getRect(knobFinder);
    final trackRect = tester.getRect(trackFinder);

    await tester.drag(gestureFinder, const Offset(120, 0));
    await tester.pump();

    final updatedText = tester
        .widget<Text>(
          find.descendant(of: valueFinder, matching: find.byType(Text)),
        )
        .data;
    final knobRectAfter = tester.getRect(knobFinder);

    expect(updatedText, isNot(initialText));
    expect(knobRectAfter.center.dx > knobRectBefore.center.dx, isTrue);
    expect(knobRectAfter.left >= trackRect.left - 1, isTrue);
    expect(knobRectAfter.right <= trackRect.right + 1, isTrue);
  });

  testWidgets('Primary CTA reflects slider percent', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 640);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: 24)),
        child: MaterialApp(
          home: ModernTableScreenV1(
            scenarioAssetPath: 'assets/scenarios/demo_hu.json',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final gestureFinder = find.byKey(
      const Key('modern_table_bet_slider_gesture'),
    );
    expect(gestureFinder, findsOneWidget);

    Text _raiseText() {
      return tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('modern_table_action_raise')),
          matching: find.byType(Text),
        ),
      );
    }

    final initialText = _raiseText();
    expect(initialText.data?.contains('RAISE'), isTrue);
    expect(initialText.data?.contains('%'), isTrue);
    expect(initialText.maxLines, 1);
    expect(initialText.softWrap, false);

    await tester.drag(gestureFinder, const Offset(120, 0));
    await tester.pump();

    final updatedText = _raiseText();
    expect(updatedText.data, isNot(initialText.data));
    expect(updatedText.maxLines, 1);
    expect(updatedText.softWrap, false);

    int _pctFrom(String? text) {
      final match = RegExp(r'(\d{1,3})%').firstMatch(text ?? '');
      if (match == null) {
        return -1;
      }
      return int.tryParse(match.group(1) ?? '') ?? -1;
    }

    final initialPct = _pctFrom(initialText.data);
    final updatedPct = _pctFrom(updatedText.data);
    expect(initialPct >= 0 && initialPct <= 100, isTrue);
    expect(updatedPct >= 0 && updatedPct <= 100, isTrue);
    expect(updatedPct > initialPct, isTrue);
  });

  testWidgets('Injected scenario drives custom acting seat', (tester) async {
    final spec = _testScenarioSpec(seatCount: 4, actingSeatStart: 2);
    await tester.pumpWidget(
      MaterialApp(home: ModernTableScreenV1(scenarioSpec: spec)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byKey(const Key('modern_table_seat_acting_2')), findsOneWidget);
    final callButton = find.byKey(const Key('modern_table_action_call'));
    await tester.tap(callButton);
    await tester.pumpAndSettle();

    expect(find.text('Evaluation: correct'), findsOneWidget);
  });

  testWidgets('Modern Table layout stays safe on small phones', (tester) async {
    const smallPhoneSize = Size(360, 640);
    tester.binding.window.physicalSizeTestValue = smallPhoneSize;
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 10)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final ovalRect = tester.getRect(find.byKey(const Key('modern_table_oval')));
    final potRect = tester.getRect(find.byKey(const Key('modern_table_pot')));
    final clarityRect = tester.getRect(
      find.byKey(const Key('modern_table_clarity')),
    );

    for (var i = 0; i < 10; i++) {
      expect(find.byKey(Key('modern_table_seat_$i')), findsOneWidget);
    }

    expect(ovalRect.height, greaterThan(ovalRect.width));
    expect(find.byKey(const Key('modern_table_board')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_pot')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_header')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_scene')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_reason')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_actions')), findsOneWidget);
    expect(clarityRect.top >= 0, true);
    expect(clarityRect.bottom <= smallPhoneSize.height, true);
  });

  testWidgets('Action bar respects bottom padding on small phones', (
    tester,
  ) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 640);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    const bottomPadding = 24.0;
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
        child: MaterialApp(home: ModernTableScreenV1(seatCount: 2)),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final ovalRect = tester.getRect(find.byKey(const Key('modern_table_oval')));
    final actionsRect = tester.getRect(
      find.byKey(const Key('modern_table_actions')),
    );
    final callRect = tester.getRect(
      find.byKey(const Key('modern_table_action_call')),
    );

    expect(find.byKey(const Key('modern_table_action_bar')), findsOneWidget);
    expect(
      find.byKey(const Key('modern_table_bet_slider_stub')),
      findsOneWidget,
    );
    final foldRect = tester.getRect(
      find.byKey(const Key('modern_table_action_fold')),
    );
    final raiseRect = tester.getRect(
      find.byKey(const Key('modern_table_action_raise')),
    );
    final actionBarRect = tester.getRect(
      find.byKey(const Key('modern_table_action_bar')),
    );
    expect(callRect.bottom <= 640 - bottomPadding, isTrue);
    expect(ovalRect.bottom <= actionsRect.top + 1, isTrue);
    expect(foldRect.width < callRect.width, true);
    expect(callRect.width < raiseRect.width, true);
    expect(
      actionBarRect.height >= actionsRect.height + bottomPadding - 1,
      isTrue,
    );
  });

  testWidgets('Action bar respects bottom padding on landscape phones', (
    tester,
  ) async {
    tester.binding.window.physicalSizeTestValue = const Size(844, 390);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    const bottomPadding = 12.0;
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
        child: MaterialApp(home: ModernTableScreenV1(seatCount: 2)),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final actionsRect = tester.getRect(
      find.byKey(const Key('modern_table_actions')),
    );
    final actionBarRect = tester.getRect(
      find.byKey(const Key('modern_table_action_bar')),
    );
    final callRect = tester.getRect(
      find.byKey(const Key('modern_table_action_call')),
    );

    expect(callRect.bottom <= 390 - bottomPadding, isTrue);
    expect(
      actionBarRect.height >= actionsRect.height + bottomPadding - 1,
      isTrue,
    );
    expect(actionBarRect.bottom, closeTo(390, 1.0));
  });

  testWidgets('Pot label stays above bottom seat in HU', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 640);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 2)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final potRect = tester.getRect(find.byKey(const Key('modern_table_pot')));
    final bottomSeatRect = tester.getRect(
      find.byKey(const Key('modern_table_seat_0')),
    );
    expect(potRect.bottom <= bottomSeatRect.top + 2, isTrue);
  });

  testWidgets('Modern Table preserves top/bottom seats for HU', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 640);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 2)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final ovalRect = tester.getRect(find.byKey(const Key('modern_table_oval')));
    final seat0 = tester.getRect(find.byKey(const Key('modern_table_seat_0')));
    final seat1 = tester.getRect(find.byKey(const Key('modern_table_seat_1')));
    final reason = find.byKey(const Key('modern_table_reason'));
    final actions = find.byKey(const Key('modern_table_actions'));

    expect(find.byKey(const Key('modern_table_seat_0')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_seat_1')), findsOneWidget);
    expect(ovalRect.height, greaterThan(ovalRect.width));
    expect(seat0.center.dy >= seat1.center.dy, true);
    expect(reason, findsOneWidget);
    expect(actions, findsOneWidget);
  });

  testWidgets('Seat anchors stay fixed as seatCount increases', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 640);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    Future<Map<int, Rect>> pumpAndRead(int seatCount) async {
      await tester.pumpWidget(
        MaterialApp(home: ModernTableScreenV1(seatCount: seatCount)),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));
      return {
        0: tester.getRect(find.byKey(const Key('modern_table_seat_0'))),
        1: tester.getRect(find.byKey(const Key('modern_table_seat_1'))),
      };
    }

    final rects2 = await pumpAndRead(2);
    final rects3 = await pumpAndRead(3);
    final rects4 = await pumpAndRead(4);

    const epsilon = 0.1;
    for (final index in [0, 1]) {
      expect(
        (rects2[index]!.left - rects3[index]!.left).abs(),
        lessThan(epsilon),
      );
      expect(
        (rects2[index]!.top - rects3[index]!.top).abs(),
        lessThan(epsilon),
      );
      expect(
        (rects2[index]!.left - rects4[index]!.left).abs(),
        lessThan(epsilon),
      );
      expect(
        (rects2[index]!.top - rects4[index]!.top).abs(),
        lessThan(epsilon),
      );
    }
  });

  testWidgets('Seat selection toggles and acting highlight shown', (
    tester,
  ) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 640);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 6, actingSeat: 2)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byKey(const Key('modern_table_seat_acting_2')), findsOneWidget);
    final seat1 = find.byKey(const Key('modern_table_seat_1'));
    expect(seat1, findsOneWidget);
    await tester.tap(seat1);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('modern_table_seat_selected_1')),
      findsOneWidget,
    );
    await tester.tap(seat1);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('modern_table_seat_selected_1')), findsNothing);
    expect(find.byKey(const Key('modern_table_reason')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_actions')), findsOneWidget);
  });

  testWidgets('Seat visuals show hero, acting, and folded states', (
    tester,
  ) async {
    final spec = ScenarioSpecV1(
      seatCount: 3,
      heroSeat: 0,
      initialStacks: [900, 900, 0],
      actingSeatStart: 1,
      decisionNodeV1: const DecisionNodeV1(
        street: Street.preflop,
        legalActions: ['Fold', 'Call', 'Raise'],
        solutionBestAction: 'Call',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: ModernTableScreenV1(scenarioSpec: spec)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final heroRing = tester.widget<Container>(
      find.byKey(const Key('modern_table_seat_hero_ring_0')),
    );
    final heroDecoration = heroRing.decoration as BoxDecoration;
    final heroBorder = heroDecoration.border as Border;
    expect(heroBorder.top.color, AppColors.accentWarning);
    expect(
      find.byKey(const Key('modern_table_seat_acting_ring_1')),
      findsOneWidget,
    );

    final foldedSurface = tester.widget<Container>(
      find.byKey(const Key('modern_table_seat_surface_2')),
    );
    final foldedDecoration = foldedSurface.decoration as BoxDecoration;
    expect(foldedDecoration.color!.opacity, lessThan(1.0));
  });

  testWidgets('Action buttons update evaluation text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 6)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final raiseButton = find.byKey(const Key('modern_table_action_raise'));

    expect(raiseButton, findsOneWidget);

    await tester.tap(raiseButton);
    await tester.pumpAndSettle();
    expect(find.text('Evaluation: wrong'), findsOneWidget);
  });

  testWidgets('Evaluation and outcome lifecycle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(seatCount: 6)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final callButton = find.byKey(const Key('modern_table_action_call'));
    await tester.tap(callButton);
    await tester.pumpAndSettle();
    expect(find.text('Evaluation: correct'), findsOneWidget);

    final continueButton = find.byKey(
      const Key('modern_table_reason_continue'),
    );
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Outcome: continue'), findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('Multi-node spec reflects street progression', (tester) async {
    final node1 = ScenarioNodeV1(
      id: 'node1',
      street: Street.preflop,
      actingSeatIndex: 0,
      pot: 4,
      decisionNode: const DecisionNodeV1(
        street: Street.preflop,
        legalActions: ['Call'],
        solutionBestAction: 'Call',
      ),
      nextNodeId: 'node2',
    );
    final node2 = ScenarioNodeV1(
      id: 'node2',
      street: Street.flop,
      actingSeatIndex: 1,
      pot: 9,
      decisionNode: const DecisionNodeV1(
        street: Street.flop,
        legalActions: ['Fold'],
        solutionBestAction: 'Fold',
      ),
    );
    final spec = ScenarioSpecV1(
      seatCount: 2,
      heroSeat: 0,
      initialStacks: [100, 200],
      actingSeatStart: 0,
      decisionNodeV1: node1.decisionNode,
      nodes: [node1, node2],
    );

    await tester.pumpWidget(
      MaterialApp(home: ModernTableScreenV1(scenarioSpec: spec)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Street: preflop'), findsOneWidget);
    expect(find.byKey(const Key('modern_table_seat_acting_0')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('modern_table_pot')),
        matching: find.text('4'),
      ),
      findsOneWidget,
    );

    final callButton = find.byKey(const Key('modern_table_action_call'));
    await tester.tap(callButton);
    await tester.pumpAndSettle();
    expect(find.text('Evaluation: correct'), findsOneWidget);

    final continueButton = find.byKey(
      const Key('modern_table_reason_continue'),
    );
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Outcome: continue'), findsOneWidget);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Street: flop'), findsOneWidget);
    expect(find.byKey(const Key('modern_table_seat_acting_1')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('modern_table_pot')),
        matching: find.text('9'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Action buttons enable per FSM legal actions', (tester) async {
    final node1 = ScenarioNodeV1(
      id: 'a',
      street: Street.preflop,
      actingSeatIndex: 0,
      pot: 4,
      decisionNode: const DecisionNodeV1(
        street: Street.preflop,
        legalActions: ['Fold', 'Call'],
        solutionBestAction: 'Call',
      ),
      nextNodeId: 'b',
    );
    final node2 = ScenarioNodeV1(
      id: 'b',
      street: Street.flop,
      actingSeatIndex: 1,
      pot: 9,
      decisionNode: const DecisionNodeV1(
        street: Street.flop,
        legalActions: ['Fold', 'Raise'],
        solutionBestAction: 'Raise',
      ),
    );
    final spec = ScenarioSpecV1(
      seatCount: 2,
      heroSeat: 0,
      initialStacks: [100, 200],
      actingSeatStart: 0,
      decisionNodeV1: node1.decisionNode,
      nodes: [node1, node2],
    );

    await tester.pumpWidget(
      MaterialApp(home: ModernTableScreenV1(scenarioSpec: spec)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final foldButton = find.byKey(const Key('modern_table_action_fold'));
    final callButton = find.byKey(const Key('modern_table_action_call'));
    final raiseButton = find.byKey(const Key('modern_table_action_raise'));

    bool isEnabled(Finder finder) =>
        tester.widget<ButtonStyleButton>(finder).onPressed != null;

    expect(isEnabled(foldButton), isTrue);
    expect(isEnabled(callButton), isTrue);
    expect(isEnabled(raiseButton), isFalse);

    await tester.tap(callButton);
    await tester.pumpAndSettle();
    final continueButton = find.byKey(
      const Key('modern_table_reason_continue'),
    );
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    final expectEnabled = isEnabled(foldButton);
    expect(expectEnabled, isTrue);
    expect(isEnabled(raiseButton), isTrue);
    expect(isEnabled(callButton), isFalse);
  });

  testWidgets('Action-based branch lands on correct node', (tester) async {
    final node1 = ScenarioNodeV1(
      id: 'n1',
      street: Street.preflop,
      actingSeatIndex: 0,
      pot: 10,
      decisionNode: const DecisionNodeV1(
        street: Street.preflop,
        legalActions: ['fold', 'call', 'raise'],
        solutionBestAction: 'raise',
      ),
      nextByAction: {'raise': 'n3', 'call': 'n2'},
    );
    final node2 = ScenarioNodeV1(
      id: 'n2',
      street: Street.flop,
      actingSeatIndex: 1,
      pot: 20,
      decisionNode: const DecisionNodeV1(
        street: Street.flop,
        legalActions: ['fold', 'call'],
        solutionBestAction: 'call',
      ),
    );
    final node3 = ScenarioNodeV1(
      id: 'n3',
      street: Street.turn,
      actingSeatIndex: 2,
      pot: 30,
      decisionNode: const DecisionNodeV1(
        street: Street.turn,
        legalActions: ['fold', 'raise'],
        solutionBestAction: 'raise',
      ),
    );
    final spec = ScenarioSpecV1(
      seatCount: 3,
      heroSeat: 0,
      initialStacks: [100, 200, 300],
      actingSeatStart: 0,
      decisionNodeV1: node1.decisionNode,
      nodes: [node1, node2, node3],
    );

    await tester.pumpWidget(
      MaterialApp(home: ModernTableScreenV1(scenarioSpec: spec)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final raiseButton = find.byKey(const Key('modern_table_action_raise'));
    await tester.tap(raiseButton);
    await tester.pumpAndSettle();

    expect(find.text('Evaluation: wrong'), findsOneWidget);

    final continueButton = find.byKey(
      const Key('modern_table_reason_continue'),
    );
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Street: turn'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('modern_table_pot')),
        matching: find.text('30'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('modern_table_seat_acting_2')), findsOneWidget);

    final callButton = find.byKey(const Key('modern_table_action_call'));
    final raiseButtonEnd = find.byKey(const Key('modern_table_action_raise'));
    bool enabled(Finder finder) =>
        tester.widget<ButtonStyleButton>(finder).onPressed != null;

    expect(enabled(callButton), isFalse);
    expect(enabled(raiseButtonEnd), isTrue);
  });

  testWidgets('Modern table accepts scenarioJson', (tester) async {
    final jsonSpec = {
      'schema_version': 1,
      'seatCount': 2,
      'heroSeat': 0,
      'initialStacks': [120, 220],
      'actingSeatStart': 0,
      'decisionNodeV1': {
        'street': 'preflop',
        'legalActions': ['Call'],
        'solutionBestAction': 'Call',
      },
      'nodes': [
        {
          'id': 'json1',
          'street': 'preflop',
          'actingSeatIndex': 0,
          'pot': 5,
          'decisionNode': {
            'street': 'preflop',
            'legalActions': ['Call'],
            'solutionBestAction': 'Call',
          },
          'nextNodeId': 'json2',
        },
        {
          'id': 'json2',
          'street': 'flop',
          'actingSeatIndex': 1,
          'pot': 12,
          'decisionNode': {
            'street': 'flop',
            'legalActions': ['Fold'],
            'solutionBestAction': 'Fold',
          },
        },
      ],
    };

    await tester.pumpWidget(
      MaterialApp(
        home: ModernTableScreenV1(
          scenarioJson: const JsonEncoder().convert(jsonSpec),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final callButton = find.byKey(const Key('modern_table_action_call'));
    await tester.tap(callButton);
    await tester.pumpAndSettle();

    final continueButton = find.byKey(
      const Key('modern_table_reason_continue'),
    );
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('modern_table_pot')),
        matching: find.text('12'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('modern_table_seat_acting_1')), findsOneWidget);
    expect(find.text('Street: flop'), findsOneWidget);
  });

  testWidgets('Invalid scenarioJson shows error and disables actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ModernTableScreenV1(scenarioJson: 'not json')),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byKey(const Key('modern_table_error')), findsOneWidget);
    expect(find.textContaining('Scenario load error:'), findsOneWidget);
    expect(find.byKey(const Key('modern_table_header')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_scene')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_reason')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_actions')), findsOneWidget);

    bool isEnabled(Finder finder) =>
        tester.widget<ButtonStyleButton>(finder).onPressed != null;

    expect(
      isEnabled(find.byKey(const Key('modern_table_action_fold'))),
      isFalse,
    );
    expect(
      isEnabled(find.byKey(const Key('modern_table_action_call'))),
      isFalse,
    );
    expect(
      isEnabled(find.byKey(const Key('modern_table_action_raise'))),
      isFalse,
    );
  });

  testWidgets('Scenario loader loads JSON and clears', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ModernTableScreenV1()));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final loaderOpen = find.byKey(const Key('modern_table_loader_open'));
    expect(loaderOpen, findsOneWidget);
    await tester.tap(loaderOpen);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final loaderField = find.byKey(const Key('modern_table_loader_field'));
    final loadButton = find.byKey(const Key('modern_table_loader_load'));
    final clearButton = find.byKey(const Key('modern_table_loader_clear'));

    expect(loaderField, findsOneWidget);
    expect(loadButton, findsOneWidget);
    expect(clearButton, findsOneWidget);

    final jsonSpec = {
      'schema_version': 1,
      'seatCount': 3,
      'heroSeat': 0,
      'initialStacks': [100, 200, 300],
      'actingSeatStart': 0,
      'decisionNodeV1': {
        'street': 'preflop',
        'legalActions': ['Call'],
        'solutionBestAction': 'Call',
      },
      'nodes': [
        {
          'id': 'loader1',
          'street': 'preflop',
          'actingSeatIndex': 0,
          'pot': 8,
          'decisionNode': {
            'street': 'preflop',
            'legalActions': ['Call'],
            'solutionBestAction': 'Call',
          },
          'nextNodeId': 'loader2',
        },
        {
          'id': 'loader2',
          'street': 'flop',
          'actingSeatIndex': 1,
          'pot': 18,
          'decisionNode': {
            'street': 'flop',
            'legalActions': ['Fold'],
            'solutionBestAction': 'Fold',
          },
        },
      ],
    };

    await tester.enterText(loaderField, const JsonEncoder().convert(jsonSpec));

    await tester.tap(loadButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.byKey(const Key('modern_table_error')), findsNothing);

    final callButton = find.byKey(const Key('modern_table_action_call'));
    await tester.tap(callButton);
    await tester.pumpAndSettle();

    final continueButton = find.byKey(
      const Key('modern_table_reason_continue'),
    );
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('modern_table_pot')),
        matching: find.text('18'),
      ),
      findsOneWidget,
    );
    expect(find.text('Street: flop'), findsOneWidget);
    expect(find.byKey(const Key('modern_table_seat_acting_1')), findsOneWidget);

    await tester.tap(loaderOpen);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(clearButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(
      find.descendant(
        of: find.byKey(const Key('modern_table_pot')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
    expect(find.text('Street: preflop'), findsOneWidget);
  });

  testWidgets('Scenario loader asset path failure shows error', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ModernTableScreenV1()));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final loaderOpen = find.byKey(const Key('modern_table_loader_open'));
    await tester.tap(loaderOpen);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final assetField = find.byKey(const Key('modern_table_loader_asset'));
    final assetButton = find.byKey(const Key('modern_table_loader_asset_load'));

    expect(assetField, findsOneWidget);
    expect(assetButton, findsOneWidget);

    await tester.enterText(assetField, 'assets/missing.json');
    await tester.tap(assetButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byKey(const Key('modern_table_error')), findsOneWidget);
    bool isEnabled(Finder finder) =>
        tester.widget<ButtonStyleButton>(finder).onPressed != null;

    expect(
      isEnabled(find.byKey(const Key('modern_table_action_fold'))),
      isFalse,
    );
    expect(
      isEnabled(find.byKey(const Key('modern_table_action_call'))),
      isFalse,
    );
    expect(
      isEnabled(find.byKey(const Key('modern_table_action_raise'))),
      isFalse,
    );
  });

  testWidgets('Missing scenario asset shows error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ModernTableScreenV1(
          scenarioAssetPath: 'assets/does_not_exist.json',
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byKey(const Key('modern_table_error')), findsOneWidget);
    expect(find.textContaining('Scenario load error:'), findsOneWidget);
    expect(find.byKey(const Key('modern_table_header')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_scene')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_reason')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_actions')), findsOneWidget);

    bool isEnabled(Finder finder) =>
        tester.widget<ButtonStyleButton>(finder).onPressed != null;
    expect(
      isEnabled(find.byKey(const Key('modern_table_action_fold'))),
      isFalse,
    );
    expect(
      isEnabled(find.byKey(const Key('modern_table_action_call'))),
      isFalse,
    );
    expect(
      isEnabled(find.byKey(const Key('modern_table_action_raise'))),
      isFalse,
    );
  });

  testWidgets('Modern table loads scenario from asset bundle', (tester) async {
    const assetScenarioSpec = {
      'schema_version': 1,
      'seatCount': 2,
      'heroSeat': 0,
      'initialStacks': [120, 140],
      'actingSeatStart': 0,
      'decisionNodeV1': {
        'street': 'preflop',
        'legalActions': ['Call'],
        'solutionBestAction': 'Call',
      },
      'nodes': [
        {
          'id': 'asset-start',
          'street': 'preflop',
          'actingSeatIndex': 0,
          'pot': 5,
          'decisionNode': {
            'street': 'preflop',
            'legalActions': ['Call'],
            'solutionBestAction': 'Call',
          },
          'nextNodeId': 'asset-next',
        },
        {
          'id': 'asset-next',
          'street': 'flop',
          'actingSeatIndex': 1,
          'pot': 18,
          'decisionNode': {
            'street': 'flop',
            'legalActions': ['Fold'],
            'solutionBestAction': 'Fold',
          },
        },
      ],
    };
    final assetScenarioJson = const JsonEncoder().convert(assetScenarioSpec);
    final fakeBundle = FakeAssetBundle({
      'assets/scenarios/demo_two_nodes.json': assetScenarioJson,
    });
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
      message,
    ) async {
      if (message == null) {
        return null;
      }
      final requestedAsset = utf8.decode(message.buffer.asUint8List());
      final assetString = fakeBundle.assets[requestedAsset];
      if (assetString == null) {
        return null;
      }
      final bytes = utf8.encode(assetString);
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    });
    addTearDown(() {
      binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        null,
      );
    });

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: fakeBundle,
        child: const MaterialApp(
          home: ModernTableScreenV1(
            scenarioAssetPath: 'assets/scenarios/demo_two_nodes.json',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byKey(const Key('modern_table_error')), findsNothing);
    final callButton = find.byKey(const Key('modern_table_action_call'));
    final isEnabled =
        tester.widget<ButtonStyleButton>(callButton).onPressed != null;
    expect(isEnabled, isTrue);

    await tester.tap(callButton);
    await tester.pumpAndSettle();
    final continueButton = find.byKey(
      const Key('modern_table_reason_continue'),
    );
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Street: flop'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('modern_table_pot')),
        matching: find.text('18'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('modern_table_seat_acting_1')), findsOneWidget);
  });

  testWidgets('Unsupported schema version shows error', (tester) async {
    final jsonSpec = {
      'schema_version': 999,
      'seatCount': 2,
      'heroSeat': 0,
      'initialStacks': [10, 20],
      'actingSeatStart': 0,
      'decisionNodeV1': {
        'street': 'preflop',
        'legalActions': ['Call'],
        'solutionBestAction': 'Call',
      },
    };

    await tester.pumpWidget(
      MaterialApp(
        home: ModernTableScreenV1(
          scenarioJson: const JsonEncoder().convert(jsonSpec),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byKey(const Key('modern_table_error')), findsOneWidget);
    expect(find.textContaining('schema_version'), findsOneWidget);
    expect(find.byKey(const Key('modern_table_header')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_scene')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_reason')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_actions')), findsOneWidget);

    bool isEnabled(Finder finder) =>
        tester.widget<ButtonStyleButton>(finder).onPressed != null;
    expect(
      isEnabled(find.byKey(const Key('modern_table_action_fold'))),
      isFalse,
    );
    expect(
      isEnabled(find.byKey(const Key('modern_table_action_call'))),
      isFalse,
    );
    expect(
      isEnabled(find.byKey(const Key('modern_table_action_raise'))),
      isFalse,
    );
  });

  testWidgets('Terminal outcome shows Restart and resets', (tester) async {
    final node = ScenarioNodeV1(
      id: 'terminal',
      street: Street.preflop,
      actingSeatIndex: 0,
      pot: 6,
      decisionNode: const DecisionNodeV1(
        street: Street.preflop,
        legalActions: ['Call'],
        solutionBestAction: 'Call',
      ),
    );
    final spec = ScenarioSpecV1(
      seatCount: 2,
      heroSeat: 0,
      initialStacks: const [100, 200],
      actingSeatStart: 0,
      decisionNodeV1: node.decisionNode,
      nodes: [node],
    );

    await tester.pumpWidget(
      MaterialApp(home: ModernTableScreenV1(scenarioSpec: spec)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final callButton = find.byKey(const Key('modern_table_action_call'));
    await tester.tap(callButton);
    await tester.pumpAndSettle();

    final continueButton = find.byKey(
      const Key('modern_table_reason_continue'),
    );
    expect(find.text('Restart'), findsNothing);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Outcome: continue'), findsOneWidget);
    expect(find.text('Restart'), findsNothing);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Restart'), findsOneWidget);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Pot: 6 · Acting: P1'), findsOneWidget);
    expect(find.byKey(const Key('modern_table_seat_acting_0')), findsOneWidget);
  });

  testWidgets('Non-terminal progression keeps Continue until terminal', (
    tester,
  ) async {
    final node1 = ScenarioNodeV1(
      id: 'node1',
      street: Street.preflop,
      actingSeatIndex: 0,
      pot: 4,
      decisionNode: const DecisionNodeV1(
        street: Street.preflop,
        legalActions: ['Call'],
        solutionBestAction: 'Call',
      ),
      nextNodeId: 'node2',
    );
    final node2 = ScenarioNodeV1(
      id: 'node2',
      street: Street.flop,
      actingSeatIndex: 1,
      pot: 8,
      decisionNode: const DecisionNodeV1(
        street: Street.flop,
        legalActions: ['Call'],
        solutionBestAction: 'Call',
      ),
    );
    final spec = ScenarioSpecV1(
      seatCount: 2,
      heroSeat: 0,
      initialStacks: const [100, 200],
      actingSeatStart: 0,
      decisionNodeV1: node1.decisionNode,
      nodes: [node1, node2],
    );

    await tester.pumpWidget(
      MaterialApp(home: ModernTableScreenV1(scenarioSpec: spec)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final callButton = find.byKey(const Key('modern_table_action_call'));
    await tester.tap(callButton);
    await tester.pumpAndSettle();

    var continueButton = find.byKey(const Key('modern_table_reason_continue'));
    expect(find.text('Restart'), findsNothing);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Outcome: continue'), findsOneWidget);
    expect(find.text('Restart'), findsNothing);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Street: flop'), findsOneWidget);
    expect(find.text('Restart'), findsNothing);

    final callButtonNode2 = find.byKey(const Key('modern_table_action_call'));
    await tester.tap(callButtonNode2);
    await tester.pumpAndSettle();

    continueButton = find.byKey(const Key('modern_table_reason_continue'));
    expect(find.text('Restart'), findsNothing);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Outcome: continue'), findsOneWidget);
    expect(find.text('Restart'), findsNothing);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('Restart'), findsOneWidget);
  });

  test('modern table screen avoids legacy imports', () {
    final sourceFile = File(
      'lib/ui_v2/screens/modern_table_screen_v1.dart',
    ).readAsStringSync();
    const forbidden = [
      'package:poker_analyzer/table/',
      'poker_analyzer/table/',
      'lib/table/',
      '/table/',
    ];
    for (final token in forbidden) {
      expect(
        sourceFile.contains(token),
        false,
        reason: 'Modern table must stay free from legacy imports ($token)',
      );
    }
  });

  group('HU geometry invariants', () {
    testWidgets('board/pot/seat ordering and touch targets stay sane', (
      tester,
    ) async {
      const smallPhoneSize = Size(360, 640);
      tester.binding.window.physicalSizeTestValue = smallPhoneSize;
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ModernTableScreenV1(
            scenarioAssetPath: 'assets/scenarios/demo_hu.json',
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final heroRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_0')),
      );
      final oppRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_1')),
      );
      final boardRect = tester.getRect(
        find.byKey(const Key('modern_table_board')),
      );
      final potRect = tester.getRect(find.byKey(const Key('modern_table_pot')));
      final ovalRect = tester.getRect(
        find.byKey(const Key('modern_table_oval')),
      );
      final actionBarRect = tester.getRect(
        find.byKey(const Key('modern_table_action_bar')),
      );
      expect(heroRect.center.dy > boardRect.bottom, isTrue);
      expect(boardRect.top > potRect.bottom, isTrue);
      expect(boardRect.top >= oppRect.bottom - 1, isTrue);
      expect(boardRect.top >= ovalRect.top - 1, isTrue);
      expect(potRect.bottom <= ovalRect.bottom + 1, isTrue);
      expect(heroRect.center.dy > oppRect.center.dy, isTrue);
      expect(
        (heroRect.center.dx - oppRect.center.dx).abs(),
        lessThan(heroRect.width * 0.4),
      );
      expect(actionBarRect.height >= 130.0, isTrue);
      expect(actionBarRect.bottom <= smallPhoneSize.height, isTrue);
      for (final seatRect in [heroRect, oppRect]) {
        expect(seatRect.width >= 44, isTrue);
        expect(seatRect.height >= 44, isTrue);
      }
    });
  });

  group('6-max geometry invariants', () {
    testWidgets('seat anchors, ordering, and touch targets stay aligned', (
      tester,
    ) async {
      const smallPhoneSize = Size(360, 640);
      const bottomPadding = 24.0;
      tester.binding.window.physicalSizeTestValue = smallPhoneSize;
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      Future<void> pumpScene() async {
        await tester.pumpWidget(
          const MediaQuery(
            data: MediaQueryData(
              padding: EdgeInsets.only(bottom: bottomPadding),
            ),
            child: MaterialApp(
              home: ModernTableScreenV1(
                scenarioAssetPath: 'assets/scenarios/demo_6max.json',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      await pumpScene();

      final seatEntries = List.generate(6, (index) {
        return MapEntry(
          index,
          tester.getRect(find.byKey(Key('modern_table_seat_$index'))),
        );
      });
      final heroRect = seatEntries.firstWhere((entry) => entry.key == 0).value;
      final otherSeats = seatEntries
          .where((entry) => entry.key != 0)
          .toList(growable: false);
      final topSeatRect = otherSeats
          .reduce((a, b) => a.value.center.dy < b.value.center.dy ? a : b)
          .value;
      final leftSeatRect = otherSeats
          .reduce((a, b) => a.value.center.dx < b.value.center.dx ? a : b)
          .value;
      final rightSeatRect = otherSeats
          .reduce((a, b) => a.value.center.dx > b.value.center.dx ? a : b)
          .value;
      final boardRect = tester.getRect(
        find.byKey(const Key('modern_table_board')),
      );
      final potRect = tester.getRect(find.byKey(const Key('modern_table_pot')));
      final ovalRect = tester.getRect(
        find.byKey(const Key('modern_table_oval')),
      );
      final actionBarRect = tester.getRect(
        find.byKey(const Key('modern_table_action_bar')),
      );

      expect(heroRect.center.dy > boardRect.bottom, isTrue);
      expect(boardRect.top > potRect.bottom, isTrue);
      expect(boardRect.top >= topSeatRect.bottom - 1, isTrue);
      expect(boardRect.top >= ovalRect.top - 1, isTrue);
      expect(potRect.bottom <= ovalRect.bottom + 1, isTrue);
      expect(heroRect.center.dy > topSeatRect.center.dy, isTrue);
      expect(leftSeatRect.left < heroRect.left, isTrue);
      expect(rightSeatRect.right > heroRect.right, isTrue);
      expect(actionBarRect.height >= 130.0, isTrue);
      final actionsRect = tester.getRect(
        find.byKey(const Key('modern_table_actions')),
      );
      expect(
        actionsRect.bottom <= smallPhoneSize.height - bottomPadding,
        isTrue,
      );
      for (final rect in seatEntries.map((entry) => entry.value)) {
        expect(rect.width >= 44, isTrue);
        expect(rect.height >= 44, isTrue);
      }

      const tolerance = 1.0;
      final heroRect2 = await _rectForSeat(
        tester,
        seatIndex: 0,
        seatCount: 2,
        bottomPadding: bottomPadding,
      );
      final topRect2 = await _rectForSeat(
        tester,
        seatIndex: 1,
        seatCount: 2,
        bottomPadding: bottomPadding,
      );
      final stabilityPairs = [
        MapEntry(heroRect2, heroRect),
        MapEntry(topRect2, topSeatRect),
      ];
      for (final pair in stabilityPairs) {
        final dxDelta = (pair.key.center.dx - pair.value.center.dx).abs();
        final dyDelta = (pair.key.center.dy - pair.value.center.dy).abs();
        expect(
          dxDelta < tolerance,
          isTrue,
          reason:
              'horizontal delta $dxDelta exceeds tolerance $tolerance for seat ${pair.key.center}',
        );
        expect(
          dyDelta < tolerance,
          isTrue,
          reason:
              'vertical delta $dyDelta exceeds tolerance $tolerance for seat ${pair.key.center}',
        );
      }
    });

    testWidgets(
      'embedded 6-max off-button hero keeps prompt lane clear and seat orbit contiguous',
      (tester) async {
        const smallPhoneSize = Size(390, 844);
        tester.binding.window.physicalSizeTestValue = smallPhoneSize;
        tester.binding.window.devicePixelRatioTestValue = 1;
        addTearDown(() {
          tester.binding.window.clearPhysicalSizeTestValue();
          tester.binding.window.clearDevicePixelRatioTestValue();
        });

        final spec = ScenarioSpecV1(
          seatCount: 6,
          heroSeat: 2,
          initialStacks: const <int>[1000, 1000, 1000, 1000, 1000, 1000],
          actingSeatStart: 2,
          decisionNodeV1: const DecisionNodeV1(
            street: Street.preflop,
            legalActions: <String>['Fold', 'Call', 'Raise'],
            solutionBestAction: 'Call',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ModernTableScreenV1(
              embeddedV1: true,
              sceneLanePromptProfileV1:
                  ModernTableSceneLanePromptProfileV1.compactStateOnly,
              scenarioSpec: spec,
              debugScenePromptLabel:
                  'Order: Button -> Small Blind -> Big Blind -> UTG -> Hijack -> Cutoff.',
              debugSeatRoleLabels: const <int, String>{
                0: 'BTN',
                1: 'SB',
                2: 'BB',
                3: 'UTG',
                4: 'HJ',
                5: 'CO',
              },
              debugSeatMarkerLabels: const <int, String>{0: 'D'},
            ),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final ovalRect = tester.getRect(
          find.byKey(const Key('modern_table_oval')),
        );
        final seatRects = <String, Rect>{
          'btn': tester.getRect(find.byKey(const Key('modern_table_seat_0'))),
          'sb': tester.getRect(find.byKey(const Key('modern_table_seat_1'))),
          'bb': tester.getRect(find.byKey(const Key('modern_table_seat_2'))),
          'utg': tester.getRect(find.byKey(const Key('modern_table_seat_3'))),
          'hj': tester.getRect(find.byKey(const Key('modern_table_seat_4'))),
          'co': tester.getRect(find.byKey(const Key('modern_table_seat_5'))),
        };
        final topSeatRect = seatRects.values.reduce(
          (a, b) => a.center.dy < b.center.dy ? a : b,
        );

        expect(
          find.byKey(const Key('modern_table_scene_prompt')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('modern_table_scene_board_state')),
          findsOneWidget,
        );
        expect(topSeatRect.center.dy < ovalRect.center.dy, isTrue);
        expect(seatRects['bb']!.center.dy > seatRects['sb']!.center.dy, isTrue);
        expect(
          seatRects['bb']!.center.dy > seatRects['utg']!.center.dy,
          isTrue,
        );

        final clockwiseOrder = <double>[];
        for (final seatId in const <String>[
          'btn',
          'sb',
          'bb',
          'utg',
          'hj',
          'co',
        ]) {
          final rect = seatRects[seatId]!;
          final dx = rect.center.dx - ovalRect.center.dx;
          final dy = rect.center.dy - ovalRect.center.dy;
          var angle = (math.atan2(dy, dx) * 180 / math.pi + 450) % 360;
          if (clockwiseOrder.isNotEmpty && angle <= clockwiseOrder.last) {
            angle += 360;
          }
          clockwiseOrder.add(angle);
        }
        for (var i = 1; i < clockwiseOrder.length; i++) {
          expect(clockwiseOrder[i] > clockwiseOrder[i - 1], isTrue);
        }
      },
    );
  });

  group('Board and seat structure keys', () {
    testWidgets('HU board slots, dealer chip, and stack pills are contained', (
      tester,
    ) async {
      const smallPhoneSize = Size(360, 640);
      tester.binding.window.physicalSizeTestValue = smallPhoneSize;
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ModernTableScreenV1(
            scenarioAssetPath: 'assets/scenarios/demo_hu.json',
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      _expectBoardSlotsInsideBoard(tester);
      expect(find.byKey(const Key('modern_table_dealer_chip')), findsOneWidget);
      _expectStackPillsInsideSeats(tester, seatCount: 2);
    });

    testWidgets(
      '6-max board slots, dealer chip, and stack pills are contained',
      (tester) async {
        const smallPhoneSize = Size(360, 640);
        tester.binding.window.physicalSizeTestValue = smallPhoneSize;
        tester.binding.window.devicePixelRatioTestValue = 1;
        addTearDown(() {
          tester.binding.window.clearPhysicalSizeTestValue();
          tester.binding.window.clearDevicePixelRatioTestValue();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: ModernTableScreenV1(
              scenarioAssetPath: 'assets/scenarios/demo_6max.json',
            ),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 1));

        _expectBoardSlotsInsideBoard(tester);
        expect(
          find.byKey(const Key('modern_table_dealer_chip')),
          findsOneWidget,
        );
        _expectStackPillsInsideSeats(tester, seatCount: 6);
      },
    );
  });

  testWidgets('Scenario loader quick picks update asset path and load', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ModernTableScreenV1()));
    await tester.pumpAndSettle();

    final loaderOpen = find.byKey(const Key('modern_table_loader_open'));
    await tester.tap(loaderOpen);
    await tester.pumpAndSettle();

    final quickPicks = find.byKey(const Key('modern_table_loader_quick_picks'));
    expect(quickPicks, findsOneWidget);
    expect(find.text('demo_hu.json'), findsOneWidget);
    expect(find.text('demo_6max.json'), findsOneWidget);
    expect(find.text('demo_two_nodes.json'), findsOneWidget);

    final firstQuickPick = find.byKey(
      const Key('modern_table_loader_quick_pick_0'),
    );
    expect(firstQuickPick, findsOneWidget);

    await tester.tap(firstQuickPick);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final assetField = tester.widget<TextField>(
      find.byKey(const Key('modern_table_loader_asset')),
    );
    expect(assetField.controller?.text.startsWith('assets/'), isTrue);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    final clearButton = find.byKey(const Key('modern_table_loader_clear'));
    expect(clearButton, findsOneWidget);
    await tester.tap(clearButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('Board slots and cards are rectangular', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(360, 640);
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
    await tester.pumpWidget(
      const MaterialApp(
        home: ModernTableScreenV1(
          scenarioAssetPath: 'assets/scenarios/demo_hu.json',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boardRect = tester.getRect(
      find.byKey(const Key('modern_table_board')),
    );
    for (var i = 0; i < 5; i++) {
      final slotRect = tester.getRect(
        find.byKey(Key('modern_table_board_slot_$i')),
      );
      final cardRect = tester.getRect(
        find.byKey(Key('modern_table_board_card_$i')),
      );
      final slotAspect = slotRect.width / slotRect.height;
      final cardAspect = cardRect.width / cardRect.height;
      expect(slotRect.left >= boardRect.left - 1, isTrue);
      expect(slotRect.right <= boardRect.right + 1, isTrue);
      expect(slotRect.top >= boardRect.top - 1, isTrue);
      expect(slotRect.bottom <= boardRect.bottom + 1, isTrue);
      expect(slotAspect >= 0.7 && slotAspect <= 0.85, isTrue);
      expect(cardAspect >= 0.65 && cardAspect <= 0.8, isTrue);
    }
  });

  testWidgets('Inline loader control opens scenario dialog', (tester) async {
    const smallPhoneSize = Size(360, 640);
    tester.binding.window.physicalSizeTestValue = smallPhoneSize;
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(const MaterialApp(home: ModernTableScreenV1()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final inlineLoader = find.byKey(
      const Key('modern_table_inline_loader_open'),
    );
    expect(inlineLoader, findsOneWidget);

    await tester.tap(inlineLoader);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('modern_table_loader_field')), findsOneWidget);

    final clearButton = find.byKey(const Key('modern_table_loader_clear'));
    expect(clearButton, findsOneWidget);
    await tester.tap(clearButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('Scenario chip opens loader dialog', (tester) async {
    const smallPhoneSize = Size(360, 640);
    tester.binding.window.physicalSizeTestValue = smallPhoneSize;
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: 24)),
        child: MaterialApp(home: ModernTableScreenV1()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final chip = find.byKey(const Key('modern_table_scenario_chip'));
    final label = find.byKey(const Key('modern_table_scenario_label'));
    expect(chip, findsOneWidget);
    expect(label, findsOneWidget);
    expect(tester.widget<Text>(label).data?.contains('Table:'), isTrue);

    await tester.tap(chip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('modern_table_loader_field')), findsOneWidget);

    final clearButton = find.byKey(const Key('modern_table_loader_clear'));
    expect(clearButton, findsOneWidget);
    await tester.tap(clearButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('Scene oval paint exists', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ModernTableScreenV1()));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final ovalPaint = find.byKey(const Key('modern_table_oval_paint'));
    expect(ovalPaint, findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('modern_table_oval')),
        matching: ovalPaint,
      ),
      findsOneWidget,
    );
  });

  testWidgets('Seat arc visual baseline is smooth', (tester) async {
    const smallPhoneSize = Size(360, 640);
    tester.binding.window.physicalSizeTestValue = smallPhoneSize;
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ModernTableScreenV1(
          scenarioAssetPath: 'assets/scenarios/demo_6max.json',
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final offsets = <double>[];
    for (var i = 1; i < 6; i++) {
      final seatRect = tester.getRect(find.byKey(Key('modern_table_seat_$i')));
      final pillRect = tester.getRect(
        find.byKey(Key('modern_table_seat_stack_pill_P${i + 1}')),
      );
      offsets.add(pillRect.center.dy - seatRect.top);
    }
    const tolerance = 4.0;
    for (var i = 0; i < offsets.length - 1; i++) {
      final delta = (offsets[i] - offsets[i + 1]).abs();
      expect(delta <= tolerance, isTrue);
    }
  });

  group('Micro layout invariants', () {
    testWidgets('Board cards inset and hero overlap stays safe', (
      tester,
    ) async {
      const smallPhoneSize = Size(360, 640);
      const bottomPadding = 24.0;
      tester.binding.window.physicalSizeTestValue = smallPhoneSize;
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
          child: MaterialApp(
            home: ModernTableScreenV1(
              scenarioAssetPath: 'assets/scenarios/demo_hu.json',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      for (var i = 0; i < 5; i++) {
        final slotRect = tester.getRect(
          find.byKey(Key('modern_table_board_slot_$i')),
        );
        final cardRect = tester.getRect(
          find.byKey(Key('modern_table_board_card_$i')),
        );
        expect(cardRect.left >= slotRect.left + 2, isTrue);
        expect(cardRect.right <= slotRect.right - 2, isTrue);
        expect(cardRect.top >= slotRect.top + 2, isTrue);
        expect(cardRect.bottom <= slotRect.bottom - 2, isTrue);
      }

      final heroCardsRect = tester.getRect(
        find.byKey(const Key('modern_table_hero_cards')),
      );
      final heroSeatRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_0')),
      );
      final actionRect = tester.getRect(
        find.byKey(const Key('modern_table_actions')),
      );
      final overlap = heroCardsRect.intersect(heroSeatRect);
      expect(overlap.isEmpty, isFalse);
      expect(overlap.height >= 2, isTrue);
      expect(heroCardsRect.bottom <= actionRect.top, isTrue);
    });

    testWidgets('Dealer chip stays within seat rects', (tester) async {
      const smallPhoneSize = Size(360, 640);
      tester.binding.window.physicalSizeTestValue = smallPhoneSize;
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      Future<void> pumpScenario(String asset) async {
        await tester.pumpWidget(
          MaterialApp(home: ModernTableScreenV1(scenarioAssetPath: asset)),
        );
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      await pumpScenario('assets/scenarios/demo_hu.json');
      final chipRectHu = tester.getRect(
        find.byKey(const Key('modern_table_dealer_chip')),
      );
      final seatRectHu = tester.getRect(
        find.byKey(const Key('modern_table_seat_0')),
      );
      expect(chipRectHu.left >= seatRectHu.left - 1, isTrue);
      expect(chipRectHu.right <= seatRectHu.right + 1, isTrue);
      expect(chipRectHu.top >= seatRectHu.top - 1, isTrue);
      expect(chipRectHu.bottom <= seatRectHu.bottom + 1, isTrue);

      await pumpScenario('assets/scenarios/demo_6max.json');
      final chipRect6 = tester.getRect(
        find.byKey(const Key('modern_table_dealer_chip')),
      );
      final seatRect6 = tester.getRect(
        find.byKey(const Key('modern_table_seat_0')),
      );
      expect(chipRect6.left >= seatRect6.left - 1, isTrue);
      expect(chipRect6.right <= seatRect6.right + 1, isTrue);
      expect(chipRect6.top >= seatRect6.top - 1, isTrue);
      expect(chipRect6.bottom <= seatRect6.bottom + 1, isTrue);
    });
  });

  group('Racetrack seating geometry', () {
    testWidgets('HU seats align to top/bottom rails', (tester) async {
      const smallPhoneSize = Size(360, 640);
      tester.binding.window.physicalSizeTestValue = smallPhoneSize;
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ModernTableScreenV1(
            scenarioAssetPath: 'assets/scenarios/demo_hu.json',
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final ovalRect = tester.getRect(
        find.byKey(const Key('modern_table_oval')),
      );
      final heroRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_0')),
      );
      final topRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_1')),
      );
      const tolerance = 6.0;
      expect(
        (heroRect.center.dx - ovalRect.center.dx).abs() <= tolerance,
        isTrue,
      );
      expect(
        heroRect.center.dy >=
            ovalRect.bottom - (heroRect.height / 2) - tolerance,
        isTrue,
      );
      expect(
        topRect.center.dy <= ovalRect.top + (topRect.height / 2) + tolerance,
        isTrue,
      );
    });

    testWidgets('6-max seats align to rails', (tester) async {
      const smallPhoneSize = Size(360, 640);
      tester.binding.window.physicalSizeTestValue = smallPhoneSize;
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ModernTableScreenV1(
            scenarioAssetPath: 'assets/scenarios/demo_6max.json',
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final ovalRect = tester.getRect(
        find.byKey(const Key('modern_table_oval')),
      );
      final heroRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_0')),
      );
      final seatRects = List<Rect>.generate(
        5,
        (index) =>
            tester.getRect(find.byKey(Key('modern_table_seat_${index + 1}'))),
        growable: false,
      );
      final topRect = seatRects.reduce(
        (a, b) => a.center.dy < b.center.dy ? a : b,
      );
      final rightRect = seatRects.reduce(
        (a, b) => a.center.dx > b.center.dx ? a : b,
      );
      final leftRect = seatRects.reduce(
        (a, b) => a.center.dx < b.center.dx ? a : b,
      );
      const tolerance = 6.0;
      expect(
        (heroRect.center.dx - ovalRect.center.dx).abs() <= tolerance,
        isTrue,
      );
      expect(
        heroRect.center.dy >=
            ovalRect.bottom - (heroRect.height / 2) - tolerance,
        isTrue,
      );
      expect(
        topRect.center.dy <= ovalRect.top + (topRect.height / 2) + tolerance,
        isTrue,
      );
      expect(
        rightRect.center.dx >=
            ovalRect.right - (rightRect.width / 2) - tolerance,
        isTrue,
      );
      expect(
        leftRect.center.dx <= ovalRect.left + (leftRect.width / 2) + tolerance,
        isTrue,
      );
    });
  });

  testWidgets('SE cockpit layout stays full and non-overlapping', (
    tester,
  ) async {
    const smallPhoneSize = Size(360, 640);
    const bottomPadding = 24.0;
    tester.binding.window.physicalSizeTestValue = smallPhoneSize;
    tester.binding.window.devicePixelRatioTestValue = 1;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
        child: MaterialApp(
          home: ModernTableScreenV1(
            scenarioAssetPath: 'assets/scenarios/demo_hu.json',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final heroCards = find.byKey(const Key('modern_table_hero_cards'));
    expect(heroCards, findsOneWidget);
    expect(find.byKey(const Key('modern_table_hero_card_0')), findsOneWidget);
    expect(find.byKey(const Key('modern_table_hero_card_1')), findsOneWidget);

    final heroCardsRect = tester.getRect(heroCards);
    final boardRect = tester.getRect(
      find.byKey(const Key('modern_table_board')),
    );
    final potRect = tester.getRect(find.byKey(const Key('modern_table_pot')));
    final actionRect = tester.getRect(
      find.byKey(const Key('modern_table_actions')),
    );
    final heroSeatRect = tester.getRect(
      find.byKey(const Key('modern_table_seat_0')),
    );
    final ovalRect = tester.getRect(find.byKey(const Key('modern_table_oval')));
    final sceneRect = tester.getRect(
      find.byKey(const Key('modern_table_scene')),
    );
    const ovalWidthRatioTarget = 0.85;
    const ovalAspectTarget = 1.35;
    const sceneFillFactor = 0.85;
    const ovalCenterShiftFrac = 0.05;
    const headerHeight = 56.0;
    const actionBarHeight = 130.0;
    const reasonHeight = 24.0;
    const scenePaddingV = 0.0;
    const epsilon = 2.0;
    final rawSceneHeight =
        smallPhoneSize.height -
        headerHeight -
        actionBarHeight -
        bottomPadding -
        reasonHeight -
        (scenePaddingV * 2);
    final sceneHeight = math.min(rawSceneHeight, sceneRect.height);

    final ovalWidthRatio = ovalRect.width / sceneRect.width;
    final ovalAspectRatio = ovalRect.height / ovalRect.width;
    final targetWidth = sceneRect.width * ovalWidthRatioTarget;
    final targetHeight = targetWidth * ovalAspectTarget;
    final heightCap = sceneHeight * sceneFillFactor;
    final isCapped = targetHeight > heightCap;
    final expectedWidth = targetWidth;
    final expectedAspect = isCapped
        ? math.max(1.05, heightCap / expectedWidth)
        : ovalAspectTarget;
    const ratioTolerance = 0.01;
    const aspectTolerance = 0.05;
    expect(ovalRect.height <= heightCap + epsilon, isTrue);
    expect(
      (ovalWidthRatio - (expectedWidth / sceneRect.width)).abs() <=
          ratioTolerance,
      isTrue,
      reason:
          'SE ovalWidthRatio $ovalWidthRatio outside target ${expectedWidth / sceneRect.width} +/- $ratioTolerance',
    );
    expect(
      (ovalAspectRatio - expectedAspect).abs() <= aspectTolerance,
      isTrue,
      reason:
          'SE ovalAspectRatio $ovalAspectRatio outside target $expectedAspect +/- $aspectTolerance',
    );
    expect(
      isCapped == (targetHeight > heightCap),
      isTrue,
      reason: 'SE cap mismatch targetHeight=$targetHeight cap=$heightCap',
    );
    expect(
      ovalRect.center.dy <=
          (sceneRect.center.dy - (sceneHeight * ovalCenterShiftFrac)) + epsilon,
      isTrue,
    );
    final headerRect = tester.getRect(
      find.byKey(const Key('modern_table_header')),
    );
    expect((headerRect.height - headerHeight).abs() <= 1.0, isTrue);
    expect(heroCardsRect.top >= boardRect.bottom - 1, isTrue);
    expect(heroCardsRect.overlaps(heroSeatRect), isTrue);
    final heroOverlapRatio =
        (heroSeatRect.bottom - heroCardsRect.top) / heroSeatRect.height;
    final expectedHeroOverlap = 0.30;
    expect(
      heroOverlapRatio + 0.05 >= expectedHeroOverlap,
      isTrue,
      reason:
          'SE heroOverlapRatio $heroOverlapRatio target $expectedHeroOverlap',
    );
    expect(heroCardsRect.bottom <= actionRect.top, isTrue);
    const ovalInset = 6.0;
    expect(potRect.overlaps(boardRect), isFalse);
    expect(potRect.overlaps(heroCardsRect), isFalse);
    expect(boardRect.top - potRect.bottom >= 8 - 2, isTrue);
    expect(boardRect.top >= ovalRect.top + ovalInset - 1, isTrue);
    expect(boardRect.bottom <= ovalRect.bottom - ovalInset + 1, isTrue);
    expect(potRect.top >= ovalRect.top + ovalInset - 1, isTrue);
    expect(potRect.bottom <= ovalRect.bottom - ovalInset + 1, isTrue);

    final overlap = heroCardsRect.intersect(heroSeatRect);
    expect(overlap.isEmpty, isFalse);
    final sceneStack = tester.widget<Stack>(
      find
          .ancestor(
            of: find.byKey(const Key('modern_table_pot')),
            matching: find.byType(Stack),
          )
          .first,
    );
    final potIndex = sceneStack.children.indexWhere(
      (child) => child.key == const Key('modern_table_pot'),
    );
    final heroIndex = sceneStack.children.indexWhere(
      (child) => child.key == const Key('modern_table_hero_cards'),
    );
    final seatIndex = sceneStack.children.indexWhere((child) {
      if (child is! Positioned) {
        return false;
      }
      final positionedChild = child.child;
      return positionedChild is GestureDetector &&
          positionedChild.key == const Key('modern_table_seat_0');
    });
    expect(potIndex, greaterThan(-1));
    expect(seatIndex, greaterThan(-1));
    expect(heroIndex, greaterThan(-1));
    expect(potIndex < seatIndex, isTrue);
    expect(heroIndex > seatIndex, isTrue);
  });

  group('Viewport scale guards', () {
    testWidgets('Mid phone ratios and containment hold', (tester) async {
      const screenSize = Size(390, 844);
      const bottomPadding = 24.0;
      tester.binding.window.physicalSizeTestValue = screenSize;
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
          child: MaterialApp(
            home: ModernTableScreenV1(
              scenarioAssetPath: 'assets/scenarios/demo_hu.json',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final ovalRect = tester.getRect(
        find.byKey(const Key('modern_table_oval')),
      );
      final sceneRect = tester.getRect(
        find.byKey(const Key('modern_table_scene')),
      );
      final boardRect = tester.getRect(
        find.byKey(const Key('modern_table_board')),
      );
      final potRect = tester.getRect(find.byKey(const Key('modern_table_pot')));
      final heroCardsRect = tester.getRect(
        find.byKey(const Key('modern_table_hero_cards')),
      );
      final actionRect = tester.getRect(
        find.byKey(const Key('modern_table_actions')),
      );
      final topSeatRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_1')),
      );
      final heroSeatRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_0')),
      );

      _expectOvalRatioGuards(
        screenSize: screenSize,
        ovalRect: ovalRect,
        sceneRect: sceneRect,
        bottomPadding: bottomPadding,
        widthRatioTarget: 0.85,
        aspectTarget: 1.35,
        sceneFillFactor: 0.72,
        label: 'mid',
      );
      _expectSceneContainmentGuards(
        ovalRect: ovalRect,
        boardRect: boardRect,
        potRect: potRect,
        heroCardsRect: heroCardsRect,
        actionRect: actionRect,
        topSeatRect: topSeatRect,
        potBoardGap: 16,
        inset: 6,
      );
      final heroOverlapRatio =
          (heroSeatRect.bottom - heroCardsRect.top) / heroSeatRect.height;
      final expectedHeroOverlap = 0.30;
      expect(
        heroOverlapRatio + 0.05 >= expectedHeroOverlap,
        isTrue,
        reason:
            'mid heroOverlapRatio $heroOverlapRatio target $expectedHeroOverlap',
      );
    });

    testWidgets('Max phone ratios and containment hold', (tester) async {
      const screenSize = Size(430, 932);
      const bottomPadding = 24.0;
      tester.binding.window.physicalSizeTestValue = screenSize;
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
          child: MaterialApp(
            home: ModernTableScreenV1(
              scenarioAssetPath: 'assets/scenarios/demo_hu.json',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final ovalRect = tester.getRect(
        find.byKey(const Key('modern_table_oval')),
      );
      final sceneRect = tester.getRect(
        find.byKey(const Key('modern_table_scene')),
      );
      final boardRect = tester.getRect(
        find.byKey(const Key('modern_table_board')),
      );
      final potRect = tester.getRect(find.byKey(const Key('modern_table_pot')));
      final heroCardsRect = tester.getRect(
        find.byKey(const Key('modern_table_hero_cards')),
      );
      final actionRect = tester.getRect(
        find.byKey(const Key('modern_table_actions')),
      );
      final topSeatRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_1')),
      );
      final heroSeatRect = tester.getRect(
        find.byKey(const Key('modern_table_seat_0')),
      );

      _expectOvalRatioGuards(
        screenSize: screenSize,
        ovalRect: ovalRect,
        sceneRect: sceneRect,
        bottomPadding: bottomPadding,
        widthRatioTarget: 0.85,
        aspectTarget: 1.35,
        sceneFillFactor: 0.68,
        label: 'max',
      );
      _expectSceneContainmentGuards(
        ovalRect: ovalRect,
        boardRect: boardRect,
        potRect: potRect,
        heroCardsRect: heroCardsRect,
        actionRect: actionRect,
        topSeatRect: topSeatRect,
        potBoardGap: 24,
        inset: 6,
      );
      final heroOverlapRatio =
          (heroSeatRect.bottom - heroCardsRect.top) / heroSeatRect.height;
      final expectedHeroOverlap = 0.30;
      expect(
        heroOverlapRatio + 0.05 >= expectedHeroOverlap,
        isTrue,
        reason:
            'max heroOverlapRatio $heroOverlapRatio target $expectedHeroOverlap',
      );
    });
  });

  group('Card System hierarchy', () {
    testWidgets('hero cards dominate board cards and stay contained', (
      tester,
    ) async {
      const screenSize = Size(360, 640);
      const bottomPadding = 24.0;
      tester.binding.window.physicalSizeTestValue = screenSize;
      tester.binding.window.devicePixelRatioTestValue = 1;
      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
          child: MaterialApp(
            home: ModernTableScreenV1(
              scenarioAssetPath: 'assets/scenarios/demo_hu.json',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final heroCardRect = tester.getRect(
        find.byKey(const Key('modern_table_hero_card_0')),
      );
      final boardCardRect = tester.getRect(
        find.byKey(const Key('modern_table_board_card_0')),
      );
      expect(heroCardRect.height >= boardCardRect.height * 1.1, isTrue);

      final ovalRect = tester.getRect(
        find.byKey(const Key('modern_table_oval')),
      );
      final actionRect = tester.getRect(
        find.byKey(const Key('modern_table_actions')),
      );
      expect(heroCardRect.top >= ovalRect.top - 1, isTrue);
      expect(heroCardRect.bottom <= ovalRect.bottom + 1, isTrue);
      expect(heroCardRect.bottom <= actionRect.top, isTrue);

      for (var i = 0; i < 5; i++) {
        final slotRect = tester.getRect(
          find.byKey(Key('modern_table_board_slot_$i')),
        );
        final cardRect = tester.getRect(
          find.byKey(Key('modern_table_board_card_$i')),
        );
        expect(cardRect.left >= slotRect.left - 1, isTrue);
        expect(cardRect.right <= slotRect.right + 1, isTrue);
        expect(cardRect.top >= slotRect.top - 1, isTrue);
        expect(cardRect.bottom <= slotRect.bottom + 1, isTrue);
      }
    });
  });
}

void _expectOvalRatioGuards({
  required Size screenSize,
  required Rect ovalRect,
  required Rect sceneRect,
  required double bottomPadding,
  required double widthRatioTarget,
  required double aspectTarget,
  required double sceneFillFactor,
  required String label,
}) {
  const headerHeight = 56.0;
  const actionBarHeight = 130.0;
  const reasonHeight = 24.0;
  const scenePaddingV = 0.0;
  final rawSceneHeight =
      screenSize.height -
      headerHeight -
      actionBarHeight -
      bottomPadding -
      reasonHeight -
      (scenePaddingV * 2);
  final sceneHeight = math.min(rawSceneHeight, sceneRect.height);
  final ovalWidthRatio = ovalRect.width / sceneRect.width;
  final ovalAspectRatio = ovalRect.height / ovalRect.width;
  final targetWidth = sceneRect.width * widthRatioTarget;
  final targetHeight = targetWidth * aspectTarget;
  final heightCap = sceneHeight * sceneFillFactor;
  final isCapped = targetHeight > heightCap;
  final expectedWidth = targetWidth;
  final expectedAspect = isCapped
      ? math.max(1.05, heightCap / expectedWidth)
      : aspectTarget;
  const ratioTolerance = 0.01;
  const aspectTolerance = 0.03;
  expect(
    ovalRect.height <= heightCap + 2,
    isTrue,
    reason: '$label ovalHeight above cap $heightCap',
  );
  expect(
    (ovalWidthRatio - (expectedWidth / sceneRect.width)).abs() <=
        ratioTolerance,
    isTrue,
    reason:
        '$label ovalWidthRatio $ovalWidthRatio outside target ${expectedWidth / sceneRect.width} +/- $ratioTolerance',
  );
  expect(
    (ovalAspectRatio - expectedAspect).abs() <= aspectTolerance,
    isTrue,
    reason:
        '$label ovalAspectRatio $ovalAspectRatio outside target $expectedAspect +/- $aspectTolerance',
  );
  expect(
    isCapped == (targetHeight > heightCap),
    isTrue,
    reason: '$label cap mismatch targetHeight=$targetHeight cap=$heightCap',
  );
}

void _expectSceneContainmentGuards({
  required Rect ovalRect,
  required Rect boardRect,
  required Rect potRect,
  required Rect heroCardsRect,
  required Rect actionRect,
  required Rect topSeatRect,
  required double potBoardGap,
  double inset = 0,
}) {
  expect(boardRect.top > potRect.bottom, isTrue);
  expect(boardRect.top - potRect.bottom >= potBoardGap - 2, isTrue);
  expect(heroCardsRect.bottom <= actionRect.top, isTrue);
  expect(heroCardsRect.top >= boardRect.bottom - 1, isTrue);
  expect(boardRect.top >= topSeatRect.bottom - 1, isTrue);
  expect(boardRect.top >= ovalRect.top + inset - 1, isTrue);
  expect(boardRect.bottom <= ovalRect.bottom - inset + 1, isTrue);
  expect(potRect.top >= ovalRect.top + inset - 1, isTrue);
  expect(potRect.bottom <= ovalRect.bottom - inset + 1, isTrue);
}

Future<Rect> _rectForSeat(
  WidgetTester tester, {
  required int seatIndex,
  required int seatCount,
  double bottomPadding = 0.0,
}) async {
  final assetPath = seatCount == 2
      ? 'assets/scenarios/demo_two_nodes.json'
      : 'assets/scenarios/demo_6max.json';
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomPadding)),
      child: MaterialApp(
        home: ModernTableScreenV1(
          seatCount: seatCount,
          scenarioAssetPath: assetPath,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 1));
  return tester.getRect(find.byKey(Key('modern_table_seat_$seatIndex')));
}

void _expectBoardSlotsInsideBoard(WidgetTester tester) {
  final boardRect = tester.getRect(find.byKey(const Key('modern_table_board')));
  for (var i = 0; i < 5; i++) {
    final slotFinder = find.byKey(Key('modern_table_board_slot_$i'));
    expect(slotFinder, findsOneWidget);
    final slotRect = tester.getRect(slotFinder);
    expect(slotRect.left >= boardRect.left - 1, isTrue);
    expect(slotRect.right <= boardRect.right + 1, isTrue);
    expect(slotRect.top >= boardRect.top - 1, isTrue);
    expect(slotRect.bottom <= boardRect.bottom + 1, isTrue);
  }
}

void _expectStackPillsInsideSeats(
  WidgetTester tester, {
  required int seatCount,
}) {
  for (var i = 0; i < seatCount; i++) {
    final seatRect = tester.getRect(find.byKey(Key('modern_table_seat_$i')));
    final pillFinder = find.byKey(
      Key('modern_table_seat_stack_pill_P${i + 1}'),
    );
    expect(pillFinder, findsOneWidget);
    final pillRect = tester.getRect(pillFinder);
    expect(pillRect.left >= seatRect.left - 1, isTrue);
    expect(pillRect.right <= seatRect.right + 1, isTrue);
    expect(pillRect.top >= seatRect.top - 1, isTrue);
    expect(pillRect.bottom <= seatRect.bottom + 1, isTrue);
  }
}
