import 'dart:convert';
import 'dart:io';

/// Captures production Act0 shell renderers through their deterministic, public
/// direct-state harness.  It is deliberately labelled injected-state evidence:
/// this is the real widget/layout tree, but not a learner navigation replay.
const _surfaces = <String>[
  'placement',
  'welcome',
  'firstWeekHome',
  'firstWeekLearn',
  'runnerTheory',
  'runnerDrill',
  'runnerFirstWrongFeedback',
  'repairResult',
  'firstWeekReview',
  'profileEvidence',
  'sessionSummary',
  'worldCompletion',
];

void main(List<String> args) async {
  if ((args.length != 1 && args.length != 2) ||
      !const ['compact', 'tall_phone', 'large_phone'].contains(args.first) ||
      (args.length == 2 &&
          !const ['text_scale_1_4', 'reduced_motion'].contains(args[1]))) {
    stderr.writeln(
      'Usage: dart run tools/act0_production_core_capture_v1.dart <compact|tall_phone|large_phone> [text_scale_1_4|reduced_motion]',
    );
    exit(64);
  }
  final device = args.first;
  final modifier = args.length == 2 ? args[1] : 'none';
  final output = Directory(
    'output/visual_master_audit/raw/core_${device}_${modifier}_v1',
  )..createSync(recursive: true);
  final temp = Directory.systemTemp.createTempSync('act0_core_capture_');
  final test = File('${temp.path}/capture_test.dart')
    ..writeAsStringSync(_source(output.path, device, modifier));
  final result = await Process.start(
    'flutter',
    ['test', test.path],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  await stdout.addStream(result.stdout);
  await stderr.addStream(result.stderr);
  final code = await result.exitCode;
  temp.deleteSync(recursive: true);
  if (code != 0) exit(code);
  final commit = Process.runSync('git', [
    'rev-parse',
    'HEAD',
  ]).stdout.toString().trim();
  final rows = _surfaces.map((surface) {
    final file = File('${output.path}/$device.$surface.png');
    if (!file.existsSync() || file.lengthSync() == 0)
      throw StateError('Missing capture: ${file.path}');
    final hash = Process.runSync('shasum', [
      '-a',
      '256',
      file.path,
    ]).stdout.toString().trim().split(RegExp(r'\\s+')).first;
    return <String, Object?>{
      'visual_state_id': 'core.$surface',
      'semantic_phase': _phase(surface),
      'route_id': 'act0/direct_state/$surface',
      'device_class': device,
      'modifier': modifier,
      'screenshot_path': file.path,
      'sha256': hash,
      'candidate_commit_sha': commit,
      'content_status': 'PRODUCTION_RENDERER_INJECTED_STATE',
      'actual_production_renderer': 'Act0ShellPreviewScreenV1',
      'owner_family': 'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
      'deterministic_state_seed':
          'Act0ShellDebugHarnessEntryV1.directState:$surface',
      'quality_claim_policy': 'eligible_for_composition_review_only',
    };
  }).toList();
  File('${output.path}/manifest.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
          'schema': 'production_core_capture_v1',
          'candidate_commit_sha': commit,
          'device_class': device,
          'modifier': modifier,
          'rows': rows,
        }) +
        '\n',
  );
}

String _phase(String surface) =>
    <String, String>{
      'placement': 'placement_question',
      'welcome': 'welcome_handoff',
      'runnerTheory': 'theory',
      'runnerDrill': 'decision',
      'runnerFirstWrongFeedback': 'incorrect_feedback',
      'repairResult': 'repair_recheck',
      'firstWeekReview': 'review_focused',
      'profileEvidence': 'profile_evidence',
      'sessionSummary': 'session_summary',
      'worldCompletion': 'world_milestone',
    }[surface] ??
    'home_learn';

String _source(String output, String device, String modifier) {
  final calls = _surfaces
      .map((surface) => "await capture(tester, '$surface');")
      .join();
  return '''
import 'dart:io'; import 'dart:typed_data'; import 'dart:ui' as ui;
import 'package:flutter/material.dart'; import 'package:flutter/rendering.dart'; import 'package:flutter/services.dart'; import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
void main() { TestWidgetsFlutterBinding.ensureInitialized();
const outputPath = ${jsonEncode(output)}; const device = '$device'; const modifier = '$modifier';
const viewports = <String, Size>{'compact': Size(375,812), 'tall_phone': Size(402,874), 'large_phone': Size(430,932)};
Future<void> loadFont() async { final f=File('/System/Library/Fonts/Supplemental/Arial.ttf'); final b=await f.readAsBytes(); for(final n in ['Roboto','Ahem']) { await (FontLoader(n)..addFont(Future<ByteData>.value(ByteData.sublistView(b)))).load(); } }
setUpAll(loadFont);
testWidgets('captures direct production shell states', (tester) async { if(modifier=='reduced_motion') { (WidgetsBinding.instance.platformDispatcher as TestPlatformDispatcher).accessibilityFeaturesTestValue=const FakeAccessibilityFeatures(disableAnimations:true); } tester.platformDispatcher.systemFontFamily='Roboto'; addTearDown(() { tester.view.resetPhysicalSize(); tester.view.resetDevicePixelRatio(); tester.platformDispatcher.resetSystemFontFamily(); });
Future<void> capture(WidgetTester tester, String surface) async { tester.view.physicalSize=viewports[device]!; tester.view.devicePixelRatio=1; await tester.pumpWidget(MaterialApp(theme:ThemeData(fontFamily:'Roboto'),home:MediaQuery(data:MediaQueryData(size:viewports[device]!,textScaler:modifier=='text_scale_1_4'?const TextScaler.linear(1.4):const TextScaler.linear(1)),child:RepaintBoundary(key:const Key('capture'),child:Act0ShellPreviewScreenV1(showPlacementOnStart:false,debugHarnessEntry:Act0ShellDebugHarnessEntryV1(mode:Act0ControlledDemoCaptureModeV1.directState,surface:Act0ControlledDemoCaptureSurfaceV1.values.byName(surface))))))); await tester.pump(); await tester.pump(const Duration(milliseconds: 500)); final b=tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('capture'))); final d=await tester.runAsync(() async => (await b.toImage(pixelRatio:2)).toByteData(format:ui.ImageByteFormat.png)); if(d==null) throw StateError('No image'); File('\$outputPath/\$device.\$surface.png').writeAsBytesSync(Uint8List.view(d.buffer)); }
$calls }); }
''';
}
