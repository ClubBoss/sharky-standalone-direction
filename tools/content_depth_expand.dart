import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_depth_expand.dart <moduleId>',
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
    stderr.writeln('drills or demos missing');
    exit(1);
  }

  bool expandedDrills = false;
  bool expandedDemos = false;

  bool processSection(
    Directory dir,
    String label,
    String placeholder,
    String expandedContent,
  ) {
    final files = dir.listSync().whereType<File>().where((file) {
      final name = file.uri.pathSegments.last;
      return !name.startsWith('.');
    }).toList();
    if (files.isEmpty) {
      return false;
    }
    for (final file in files) {
      final content = file.readAsStringSync();
      if (content.trim() == placeholder) {
        file.writeAsStringSync(expandedContent);
        return true;
      }
    }
    return false;
  }

  const drillPlaceholder = '# Drill 1\n\nDescribe the first exercise.\n';
  const drillExpanded = '''# Drill 1
## Objective
Describe what the learner should achieve.

## Steps
- Step 1
- Step 2

## Expected outcome
Summarize expected result.
''';
  const demoPlaceholder = '# Demo 1\n\nWalk through an example.\n';
  const demoExpanded = '''# Demo 1
## Scenario
Describe a realistic scenario.

## Walkthrough
Step-by-step demonstration.

## Outcome
Expected understanding.
''';

  if (processSection(drillDir, 'drills', drillPlaceholder, drillExpanded)) {
    print('[EXPANDED] drills');
    expandedDrills = true;
  } else {
    print('[SKIP] real drills');
  }
  if (processSection(demoDir, 'demos', demoPlaceholder, demoExpanded)) {
    print('[EXPANDED] demos');
    expandedDemos = true;
  } else {
    print('[SKIP] real demos');
  }
}
