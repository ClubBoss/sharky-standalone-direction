// Standalone Dart contract test: no Flutter engine or package dependencies.
import 'dart:io';

void main() {
  final contract = File('docs/plan/SKIN_LAYER_v1.md').readAsStringSync();
  final format = File(
    'reasoning/design_brief/SKIN_PACK_FORMAT_v1.md',
  ).readAsStringSync();
  final source = File(
    'lib/ui_v2/act0_shell/skin/act0_skin_tokens_v1.dart',
  ).readAsStringSync();
  final row = RegExp(r'^\| `(\w+)` \|', multiLine: true);
  final contractKeys = row
      .allMatches(contract.split('### Tokens\n')[1].split('### Components')[0])
      .map((match) => match[1]!)
      .toList();
  final formatKeys = row
      .allMatches(format.split('## Token keys\n')[1].split('## Asset files')[0])
      .map((match) => match[1]!)
      .toList();
  final sourceKeys = RegExp(
    r'^  static const (?:[\w<>]+ )?(\w+)\s*=',
    multiLine: true,
  ).allMatches(source).map((match) => match[1]!).toSet();
  final contractSet = contractKeys.toSet();
  final formatSet = formatKeys.toSet();
  if (contractSet.isEmpty || contractKeys.length != contractSet.length) {
    throw StateError('B32 contract is empty or contains duplicate keys');
  }
  final missing = contractSet.difference(formatSet);
  final extra = formatSet.difference(contractSet);
  final missingSource = contractSet.difference(sourceKeys);
  if (formatKeys.length != formatSet.length ||
      missing.isNotEmpty ||
      extra.isNotEmpty ||
      missingSource.isNotEmpty) {
    throw StateError(
      'Skin format drift: missing=$missing, extra=$extra, '
      'missing source=$missingSource, '
      'duplicate rows=${formatKeys.length - formatSet.length}',
    );
  }
  stdout.writeln('Skin pack format matches ${contractSet.length} B32 tokens.');
}
