import 'dart:io';

import 'c_series_auto_audit.dart';
import 'c_series_tap_explain_transformer.dart';
import 'utils/c_series_generator_utils.dart';

class CSeriesGenerator {
  const CSeriesGenerator();

  Future<void> generate(String moduleId, String spec) async {
    final files = CSeriesGeneratorUtils.seedModule(moduleId, spec);
    final transformed = const CSeriesTapExplainTransformer().transform(files);
    final auditor = CSeriesAutoAudit();
    final result = auditor.auditAndFix(transformed);
    if (!result.pass) {
      _printFail(result.fixes);
      return;
    }
    final targetDir = Directory('content/$moduleId/v1');
    if (!targetDir.existsSync()) targetDir.createSync(recursive: true);
    final ordered = [
      'theory.md',
      'demos.jsonl',
      'drills.jsonl',
      'quiz.jsonl',
      'recap.md',
      'allowlist.txt',
      'micro_quiz.jsonl',
    ];
    for (final name in ordered) {
      final data = result.files[name];
      if (data == null) continue;
      File('${targetDir.path}/$name').writeAsStringSync(data);
    }
    stdout.writeln('PASS');
  }

  void _printFail(List<String> fixes) {
    stdout.writeln('FAIL');
    for (final fix in fixes) {
      stdout.writeln(fix);
    }
  }
}

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stdout.writeln(
      'Usage: dart run tools/c_series_generator.dart <module_id> <spec>',
    );
    return;
  }
  final moduleId = args[0];
  final spec = args.sublist(1).join(' ');
  await const CSeriesGenerator().generate(moduleId, spec);
}
