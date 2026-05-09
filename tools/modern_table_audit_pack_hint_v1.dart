import 'dart:io';

String buildAuditPackHint(String rootPath) {
  final zipPath = File(
    '${rootPath}${Platform.pathSeparator}out${Platform.pathSeparator}modern_table_screenshots_v1.zip',
  );
  if (zipPath.existsSync()) {
    return 'MODERN_TABLE_AUDIT_PACK=out/modern_table_screenshots_v1.zip';
  }
  return 'RUN: dart run tools/modern_table_screenshot_v1.dart && '
      'SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh';
}

void main(List<String> args) {
  String rootPath;
  if (args.length >= 2 && args.first == '--root') {
    rootPath = args[1];
  } else if (args.isNotEmpty && !args.first.startsWith('-')) {
    rootPath = args.first;
  } else {
    rootPath = Directory.current.path;
  }
  print(buildAuditPackHint(rootPath));
}
