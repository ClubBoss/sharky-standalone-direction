import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_leak_dashboard_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_settings_view_model_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_summary_preview_v1.dart';

const _shell = 'lib/ui_v2/act0_shell';
const _screenPath = '$_shell/act0_shell_preview_screen_v1.dart';
const _portrait = ['UIInterfaceOrientationPortrait'];

// Python's standard plist parser works on both Linux CI and macOS without
// Xcode, signing, extra Dart dependencies or fragile XML substring checks.
Map<String, dynamic> _readPlist() {
  final result = Process.runSync('python3', [
    '-c',
    'import json, plistlib, sys; '
        'print(json.dumps(plistlib.load(open(sys.argv[1], "rb"))))',
    'ios/Runner/Info.plist',
  ]);
  expect(result.exitCode, 0, reason: '${result.stderr}');
  return jsonDecode(result.stdout as String) as Map<String, dynamic>;
}

CompilationUnit _parse(String path) =>
    parseString(content: File(path).readAsStringSync(), path: path).unit;

ClassDeclaration _class(CompilationUnit unit, String name) => unit.declarations
    .whereType<ClassDeclaration>()
    .singleWhere((declaration) => declaration.name.lexeme == name);

String _compact(AstNode? node) =>
    node!.toSource().replaceAll(RegExp(r'\s+'), '');

// These compile-time expressions supplement the real accessors below: a normal
// flutter test does not evaluate the kReleaseMode=true branch.
void _expectExpression(AstNode? node, String expected) {
  expect(_compact(node), expected.replaceAll(RegExp(r'\s+'), ''));
}

Expression? _topLevelInitializer(String path, String name) => _parse(path)
    .declarations
    .whereType<TopLevelVariableDeclaration>()
    .expand((declaration) => declaration.variables.variables)
    .singleWhere((variable) => variable.name.lexeme == name)
    .initializer;

Expression? _shellDefault(CompilationUnit unit, String name) =>
    _class(unit, 'Act0ShellPreviewScreenV1').members
        .whereType<ConstructorDeclaration>()
        .singleWhere((constructor) => constructor.name == null)
        .parameters
        .parameters
        .whereType<DefaultFormalParameter>()
        .singleWhere((parameter) => parameter.name?.lexeme == name)
        .defaultValue;

void main() {
  late Map<String, dynamic> plist;
  late CompilationUnit shell;
  setUpAll(() {
    plist = _readPlist();
    shell = _parse(_screenPath);
  });

  group('A8.2 iPhone release profile', () {
    test('iPhone is portrait only, including any phone-specific override', () {
      expect(plist['UISupportedInterfaceOrientations'], _portrait);
      // A ~ipad override applies only to iPad, not iPhone. A ~iphone
      // override, if present, must also be portrait only.
      if (plist.containsKey('UISupportedInterfaceOrientations~iphone')) {
        expect(plist['UISupportedInterfaceOrientations~iphone'], _portrait);
      }
    });

    test('iOS development region is English', () {
      expect(plist['CFBundleDevelopmentRegion'], 'en');
    });

    test('iOS supported localizations are English only', () {
      expect(plist['CFBundleLocalizations'], ['en']);
    });

    test('Xcode targets iPhone only', () {
      final project = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();
      final families = RegExp(r'TARGETED_DEVICE_FAMILY\s*=\s*([^;]+);')
          .allMatches(project)
          .map((match) => match.group(1)!.trim().replaceAll('"', ''));
      expect(families, isNotEmpty);
      expect(families, everyElement('1'));
    });

    test('Flutter startup locks portrait before runApp', () {
      final startup = _parse('lib/main.dart').declarations
          .whereType<FunctionDeclaration>()
          .singleWhere((function) => function.name.lexeme == 'main');
      expect(
        _compact(startup.functionExpression.body),
        matches(
          r'awaitSystemChrome\.setPreferredOrientations\((?:const)?'
          r'\[(?:DeviceOrientation\.portraitUp),?\]\);.*runApp\(',
        ),
      );
    });
  });

  group('A8.flags default release flags OFF (no dart-defines)', () {
    const widget = Act0ShellPreviewScreenV1();
    test('goalRouteV1', () {
      expect(widget.goalRouteV1, isFalse);
      _expectExpression(
        _shellDefault(shell, 'goalRouteV1'),
        "const bool.fromEnvironment('goalRouteV1')",
      );
    });

    test('numberEntryV1', () {
      expect(widget.numberEntryV1, isFalse);
      _expectExpression(
        _shellDefault(shell, 'numberEntryV1'),
        "const bool.fromEnvironment('numberEntryV1')",
      );
    });

    test('warmupV1', () {
      expect(widget.warmupV1, isFalse);
      _expectExpression(
        _shellDefault(shell, 'warmupV1'),
        "const bool.fromEnvironment('warmupV1')",
      );
    });

    test('leakDashboardV1', () {
      expect(leakDashboardV1, isFalse);
      _expectExpression(
        _topLevelInitializer(
          '$_shell/act0_leak_dashboard_v1.dart',
          'leakDashboardV1',
        ),
        "!bool.fromEnvironment('dart.vm.product') && "
        "bool.fromEnvironment('SHARKY_LEAK_DASHBOARD_V1')",
      );
    });

    test('actionReasonV1 private release gate', () {
      // No public flag accessor: read the actual private initializer, not a
      // second independent bool.fromEnvironment that could mask a regression.
      final flag = _class(shell, '_Act0ShellPreviewScreenV1State').members
          .whereType<FieldDeclaration>()
          .expand((field) => field.fields.variables)
          .singleWhere(
            (variable) => variable.name.lexeme == '_actionReasonEnabledV1',
          );
      _expectExpression(
        flag.initializer,
        "!kReleaseMode && bool.fromEnvironment('actionReasonV1')",
      );
    });

    test('liveRoomV1', () {
      expect(Act0ShellStateV1.catalog().liveRoom, isNull);
      final catalog =
          _class(_parse('$_shell/act0_shell_state_v1.dart'), 'Act0ShellStateV1')
              .members
              .whereType<MethodDeclaration>()
              .singleWhere((method) => method.name.lexeme == 'catalog');
      final flag = catalog.parameters!.parameters
          .whereType<DefaultFormalParameter>()
          .singleWhere((parameter) => parameter.name?.lexeme == 'liveRoomV1');
      _expectExpression(
        flag.defaultValue,
        "const bool.fromEnvironment('liveRoomV1')",
      );
    });

    test('streetSummaryV1 (SHARKY_STREET_SUMMARY_PREVIEW)', () {
      expect(act0StreetSummaryPreviewV1, isFalse);
      _expectExpression(
        _topLevelInitializer(
          '$_shell/act0_street_summary_preview_v1.dart',
          'act0StreetSummaryPreviewV1',
        ),
        "kDebugMode && bool.fromEnvironment('SHARKY_STREET_SUMMARY_PREVIEW')",
      );
    });

    test('SHARKY_W13_PLUS_PILOT', () {
      expect(act0CurriculumPilotEnabledV1, isFalse);
      expect(act0LastCurriculumWorldV1, 12);
      expect(
        Act0ShellStateV1.catalog().worlds.map((world) => world.worldNumber),
        List.generate(12, (index) => index + 1),
      );
      _expectExpression(
        _topLevelInitializer(
          '$_shell/act0_curriculum_pilot_v1.dart',
          'act0CurriculumPilotEnabledV1',
        ),
        "kDebugMode && bool.fromEnvironment('SHARKY_W13_PLUS_PILOT')",
      );
    });
  });

  group('debug surface release policy seams', () {
    test('dev menu is unavailable in release mode', () {
      expect(act0DevMenuEnabledV1(isReleaseMode: true), isFalse);
      expect(act0DevMenuEnabledV1(isReleaseMode: false), isTrue);
    });

    test('Settings preview action is unavailable even when requested', () {
      final action = Object();
      expect(
        act0SettingsPreviewActionV1(
          action,
          isDebugMode: false,
          legacyPreviewRequested: true,
        ),
        isNull,
      );
      expect(
        act0SettingsPreviewActionV1(
          action,
          isDebugMode: true,
          legacyPreviewRequested: true,
        ),
        same(action),
      );
    });
  });
}
