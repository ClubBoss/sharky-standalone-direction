// Pure Dart. Run with the JSON snapshot produced by the catalog adapter.
import 'dart:convert';
import 'dart:io';

enum TransferNoveltyV1 { paraphrase, cosmetic, changedDecision, unknown }

typedef TransferSpotV1 = ({
  Object? position,
  Object? price,
  Object? thresholdBucket,
  Object? handBucket,
  List<String>? actionSet,
  List<String>? answer,
  String? spot,
  String? cosmetics,
});

typedef TransferNoveltyResultV1 = ({
  TransferNoveltyV1 classification,
  List<String> missing,
});

TransferNoveltyResultV1 classifyTransferNoveltyV1(
  TransferSpotV1 source,
  TransferSpotV1 repeat,
) {
  Map<String, Object?> decision(TransferSpotV1 spot) => {
    'position': spot.position,
    'price': spot.price,
    'thresholdBucket': spot.thresholdBucket,
    'handBucket': spot.handBucket,
    'actionSet': spot.actionSet?.toSet().toList()?..sort(),
    'answer': spot.answer?.toSet().toList()?..sort(),
    'spot': spot.spot,
  };

  final first = decision(source);
  final second = decision(repeat);
  final missing = [
    for (final (side, fields, cosmetics) in [
      ('source', first, source.cosmetics),
      ('repeat', second, repeat.cosmetics),
    ]) ...[
      for (final field in fields.entries)
        if (field.value == null ||
            field.value == '' ||
            (field.value is Iterable && (field.value as Iterable).isEmpty))
          '$side.${field.key}',
      if (cosmetics == null) '$side.cosmetics',
    ],
  ];
  if (missing.isNotEmpty) {
    return (classification: TransferNoveltyV1.unknown, missing: missing);
  }
  final firstAnswer = first.remove('answer');
  final secondAnswer = second.remove('answer');
  final inputsDiffer = jsonEncode(first) != jsonEncode(second);
  if (!inputsDiffer && jsonEncode(firstAnswer) != jsonEncode(secondAnswer)) {
    return (
      classification: TransferNoveltyV1.unknown,
      missing: ['decisionInputExplainingAnswerChange'],
    );
  }
  final classification = inputsDiffer
      ? TransferNoveltyV1.changedDecision
      : source.cosmetics != repeat.cosmetics
      ? TransferNoveltyV1.cosmetic
      : TransferNoveltyV1.paraphrase;
  return (classification: classification, missing: missing);
}

String _name(TransferNoveltyV1 value) =>
    value == TransferNoveltyV1.changedDecision
    ? 'changed_decision'
    : value.name;

TransferSpotV1 _spot(Map<String, dynamic> row) => (
  position: row['position'],
  price: row['price'],
  thresholdBucket: row['thresholdBucket'],
  handBucket: row['handBucket'],
  actionSet: (row['actionSet'] as List?)?.cast<String>(),
  answer: (row['answer'] as List?)?.cast<String>(),
  spot: row['spot'] as String?,
  cosmetics: row['cosmetics'] as String?,
);

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln(
      'Usage: dart tools/transfer_novelty_check_v1.dart SNAPSHOT.json REPORT.json',
    );
    exitCode = 64;
    return;
  }
  final snapshot = jsonDecode(File(args.first).readAsStringSync()) as Map;
  final groups = [
    for (var world = 1; world <= 12; world++) 'W$world',
    'C1',
    'C2',
  ];
  final counts = {
    for (final group in groups)
      group: {for (final value in TransferNoveltyV1.values) _name(value): 0},
  };
  final rows = <Map<String, Object?>>[];
  for (final pair in snapshot['pairs'] as List) {
    final result = classifyTransferNoveltyV1(
      _spot(pair['source'] as Map<String, dynamic>),
      _spot(pair['repeat'] as Map<String, dynamic>),
    );
    final classification = _name(result.classification);
    final belongsTo = [
      'W${pair['world']}',
      if (pair['generatorFamily'] case final String family) family,
    ];
    for (final group in belongsTo) {
      counts[group]!.update(classification, (count) => count + 1);
    }
    rows.add({
      'sourceTaskId': pair['source']['id'],
      'repeatTaskId': pair['repeat']['id'],
      'kind': pair['kind'],
      'exactReplay': pair['source']['id'] == pair['repeat']['id'],
      'groups': belongsTo,
      'classification': classification,
      'missing': result.missing,
    });
  }

  final flaggedGroups = {
    for (final entry in counts.entries)
      if (2 * (entry.value['paraphrase']! + entry.value['cosmetic']!) >
          entry.value.values.fold<int>(0, (sum, count) => sum + count))
        entry.key,
  };
  final flags = <Map<String, Object?>>[];
  for (final row in rows) {
    final credit = row['kind'] == 'day2' || row['kind'] == 'day7';
    final lowNovelty =
        row['classification'] == 'cosmetic' ||
        row['classification'] == 'paraphrase';
    final flagged = (row['groups'] as List<String>).where(
      flaggedGroups.contains,
    );
    if (credit || (lowNovelty && flagged.isNotEmpty)) {
      flags.add({
        ...row,
        'independentCredit': credit,
        'highShareGroups': [if (lowNovelty) ...flagged],
      });
    }
  }

  File(args.last).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'counts': counts,
      'flaggedGroups': flaggedGroups.toList(),
      'flaggedTaskIds': <String>{
        for (final row in flags) ...[
          row['sourceTaskId'] as String,
          row['repeatTaskId'] as String,
        ],
      }.toList()..sort(),
      'flags': flags,
      'pairs': rows,
    }),
  );
  stdout.writeln('Group     Paraphrase Cosmetic Changed Unknown >50%');
  for (final group in groups) {
    final columns = counts[group]!.values.map((count) => '$count'.padLeft(7));
    stdout.writeln(
      '${group.padRight(9)} ${columns.join(' ')} ${flaggedGroups.contains(group) ? 'YES' : ''}',
    );
  }
  stdout.writeln('Flagged pairs: ${flags.length}');
}
