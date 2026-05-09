import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_drill_demo_semantic_expand.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final moduleDir = Directory('content/$moduleId');
  if (!moduleDir.existsSync()) {
    stderr.writeln('Module directory missing');
    exit(1);
  }

  final drillDir = Directory('${moduleDir.path}/drills');
  final demoDir = Directory('${moduleDir.path}/demos');
  if (!drillDir.existsSync() || !demoDir.existsSync()) {
    stderr.writeln('drills/demos missing');
    exit(1);
  }

  bool expandedDrills = false;
  bool expandedDemos = false;

  bool isPlaceholder(File file, String marker) {
    final text = file.readAsStringSync();
    if (!text.startsWith(marker)) return false;
    if (text.length >= 300) return false;
    final headers = text
        .split('\n')
        .where((line) => line.startsWith('##'))
        .toList();
    return headers.length <= 1;
  }

  void upgradeDrill(File file) {
    file.writeAsStringSync('''# Drill 1
## Objective
Describe the skill this drill develops.

## Steps
- Step-by-step instructions
- Decision checkpoints
- Reflection prompts

## Expected outcome
Describe what a correct solution demonstrates.
''');
  }

  void upgradeDemo(File file) {
    file.writeAsStringSync('''# Demo 1
## Scenario
Realistic module-specific situation.

## Walkthrough
Step-by-step explanation of reasoning.

## Outcome
What the learner should understand after following the example.
''');
  }

  final drillFiles = drillDir.listSync().whereType<File>();
  for (final file in drillFiles) {
    if (isPlaceholder(file, '# Drill')) {
      upgradeDrill(file);
      expandedDrills = true;
    }
  }

  final demoFiles = demoDir.listSync().whereType<File>();
  for (final file in demoFiles) {
    if (isPlaceholder(file, '# Demo')) {
      upgradeDemo(file);
      expandedDemos = true;
    }
  }

  if (expandedDrills) {
    print('[EXPANDED] semantic drills');
  } else {
    print('[SKIP] real drills');
  }

  if (expandedDemos) {
    print('[EXPANDED] semantic demos');
  } else {
    print('[SKIP] real demos');
  }
}
