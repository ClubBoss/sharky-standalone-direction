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

// Precedence matters for suited broadway connectors such as KQs.
const _handRules = [
  ('pair', 'Two cards of the same rank'),
  ('suited broadway', 'Same suit, both ranks T through A'),
  ('suited connector', 'Same suit, adjacent ranks in 2 through A (no A2 wrap)'),
  ('offsuit broadway', 'Different suits, both ranks T through A'),
  ('other', 'Every other valid two-card hand'),
];

String? transferHandBucketV2(Object? cards) {
  const ranks = '23456789TJQKA';
  if (cards case [[String a, String suitA], [String b, String suitB]]) {
    if (a.length != 1 ||
        b.length != 1 ||
        suitA.length != 1 ||
        suitB.length != 1 ||
        !ranks.contains(a) ||
        !ranks.contains(b) ||
        !'cdhs'.contains(suitA) ||
        !'cdhs'.contains(suitB) ||
        (a == b && suitA == suitB)) {
      return null;
    }
    final first = ranks.indexOf(a);
    final second = ranks.indexOf(b);
    final suited = suitA == suitB;
    final broadway =
        first >= ranks.indexOf('T') && second >= ranks.indexOf('T');
    return _handRules[switch ((a == b, suited, broadway)) {
          (true, _, _) => 0,
          (_, true, true) => 1,
          (_, true, _) when (first - second).abs() == 1 => 2,
          (_, false, true) => 3,
          _ => 4,
        }]
        .$1;
  }
  return null;
}

double? _requiredEquityPct(Object? pot, Object? call) {
  if (pot is! num ||
      call is! num ||
      !pot.isFinite ||
      !call.isFinite ||
      pot < 0 ||
      call < 0 ||
      pot + call <= 0 ||
      !(pot + call).isFinite) {
    return null;
  }
  return 100 * (call / (pot + call));
}

int? transferPriceBucketV2(Object? pot, Object? call) {
  final odds = _requiredEquityPct(pot, call);
  return odds == null ? null : (odds / 5).round() * 5;
}

List<Object>? transferThresholdBucketV2(
  Object? equityPct,
  Object? pot,
  Object? call,
) {
  final required = _requiredEquityPct(pot, call);
  if (required == null ||
      equityPct is! num ||
      !equityPct.isFinite ||
      equityPct < 0 ||
      equityPct > 100) {
    return null;
  }
  return ['equity', (equityPct - required).sign.toInt()];
}

({
  TransferNoveltyResultV1 result,
  Map<String, Object> derived,
  bool exactReplay,
})
classifyTransferPairV2(
  Map<String, dynamic> source,
  Map<String, dynamic> repeat,
) {
  final useHoleCards =
      source['handBucket'] == null || repeat['handBucket'] == null;
  final derived = <String, Object>{};

  TransferSpotV1 derive(Map<String, dynamic> row, String side) {
    final spot = row['spot'] as String?;
    // Read the pre-action ledger pot from older B44 exports when available.
    final pot =
        row['decisionPotBb'] ??
        (spot == null ? null : (jsonDecode(spot) as List)[4]);
    final call = row['price'];
    final cosmetics = row['cosmetics'] as String?;
    final hand = useHoleCards && cosmetics != null
        ? transferHandBucketV2((jsonDecode(cosmetics) as List).firstOrNull)
        : null;
    final threshold =
        row['thresholdBucket'] ??
        transferThresholdBucketV2(row['equityPct'], pot, call);
    final price = transferPriceBucketV2(pot, call);
    if (hand != null) derived['$side.handBucket'] = hand;
    if (price != null) derived['$side.price'] = price;
    if (row['thresholdBucket'] == null && threshold != null) {
      derived['$side.thresholdBucket'] = threshold;
    }
    // Use one hand schema for both sides when a B44 hand bucket is missing.
    return _spot({
      ...row,
      'handBucket': useHoleCards ? hand : row['handBucket'],
      'price': price,
      'thresholdBucket': switch (threshold) {
        ['equity', num sign] => ['equity', sign.toInt()],
        _ => threshold,
      },
    });
  }

  final first = derive(source, 'source');
  final second = derive(repeat, 'repeat');
  final id = source['id'];
  final exactReplay =
      id is String &&
      id.isNotEmpty &&
      id == repeat['id'] &&
      jsonEncode(source) == jsonEncode(repeat);
  return (
    result: exactReplay
        ? (classification: TransferNoveltyV1.paraphrase, missing: <String>[])
        : classifyTransferNoveltyV1(first, second),
    derived: derived,
    exactReplay: exactReplay,
  );
}

String _unknownReason(String field) {
  final explanation = switch (field.split('.').last) {
    'price' => 'missing or invalid pre-call pot or amount to call',
    'handBucket' => 'no comparable hand bucket from two valid hole cards',
    'thresholdBucket' => 'no catalog threshold or usable equity and call odds',
    'position' => 'hero or decision actor unavailable',
    'actionSet' => 'B44 could not establish a stable action set',
    'answer' => 'B44 could not establish a stable preferred answer',
    'spot' => 'B44 could not establish a comparable decision context',
    'cosmetics' => 'visible card or seat details unavailable',
    _ => 'preferred answer differs with identical decision inputs',
  };
  return '`$field` ($explanation)';
}

void _writeMarkdown(File target, List<dynamic> pairs, List<String> groups) {
  final classes = TransferNoveltyV1.values;
  final counts = {
    for (final group in ['All', ...groups])
      group: [
        for (final _ in classes) [0, 0],
      ],
  };
  final details = StringBuffer()
    ..writeln(
      '| Kind | Source → repeat | Before → after | Derived fields and/or reason |',
    )
    ..writeln('| --- | --- | --- | --- |');
  final credit = <(String, String), Set<String>>{};
  for (final pair in pairs) {
    final source = pair['source'] as Map<String, dynamic>;
    final repeat = pair['repeat'] as Map<String, dynamic>;
    final before = classifyTransferNoveltyV1(_spot(source), _spot(repeat));
    final after = classifyTransferPairV2(source, repeat);
    final oldClass = before.classification;
    final newClass = after.result.classification;
    final kind = pair['kind'] as String;
    for (final group in [
      'All',
      'W${pair['world']}',
      if (pair['generatorFamily'] case final String family) family,
    ]) {
      counts[group]![oldClass.index][0]++;
      counts[group]![newClass.index][1]++;
    }
    if ((kind == 'day2' || kind == 'day7') &&
        (newClass == TransferNoveltyV1.paraphrase ||
            newClass == TransferNoveltyV1.cosmetic)) {
      credit
          .putIfAbsent((repeat['id'] as String, kind), () => {})
          .add(_name(newClass));
    }
    final notes = [
      if (after.exactReplay) 'identical task ID and snapshot',
      for (final entry in after.derived.entries)
        '`${entry.key}` = ${entry.value} (derived)',
      for (final field in after.result.missing) _unknownReason(field),
    ];
    if (notes.isNotEmpty) {
      details.writeln(
        '| $kind | `${source['id']}` → `${repeat['id']}` | ${_name(oldClass)} → ${_name(newClass)} | ${notes.join('<br>')} |',
      );
    }
  }

  final report = StringBuffer()
    ..writeln('# Transfer novelty · B58')
    ..writeln()
    ..writeln(
      'Before applies B44 to the same snapshot. Counts are pairs; C1/C2 are generator families and overlap the world rows.',
    )
    ..writeln()
    ..writeln('| Group | ${classes.map(_name).join(' | ')} |')
    ..writeln('| --- | ${classes.map((_) => '---:').join(' | ')} |');
  for (final entry in counts.entries) {
    report.writeln(
      '| ${entry.key} | ${entry.value.map((v) => v.join(' → ')).join(' | ')} |',
    );
  }

  report
    ..writeln()
    ..writeln('## Day 2 / Day 7 low-novelty credit candidates')
    ..writeln()
    ..writeln(
      'Repeat task IDs on B44’s Day 2 or Day 7 candidate paths. Actual independent credit depends on the learner’s history and answer provenance.',
    )
    ..writeln()
    ..writeln('| Repeat task ID | Review | Pair classes |')
    ..writeln('| --- | --- | --- |');
  final creditKeys = credit.keys.toList()
    ..sort(
      (a, b) => a.$1 == b.$1 ? a.$2.compareTo(b.$2) : a.$1.compareTo(b.$1),
    );
  for (final key in creditKeys) {
    report.writeln('| `${key.$1}` | ${key.$2} | ${credit[key]!.join(', ')} |');
  }
  report
    ..writeln()
    ..writeln('## Derivation rules')
    ..writeln()
    ..writeln(
      'An identical task ID and snapshot establishes an exact replay (paraphrase). If either B44 hand bucket is missing, compare hole cards on both sides using the first matching row below.',
    )
    ..writeln()
    ..writeln('| Hand bucket | Rule |')
    ..writeln('| --- | --- |');
  for (final (bucket, rule) in _handRules) {
    report.writeln('| $bucket | $rule |');
  }
  report
    ..writeln()
    ..writeln(
      'Price is 100 × call / (pot + call), rounded to the nearest five percentage points, ties up. The pot includes existing wagers and excludes the prospective call.',
    )
    ..writeln(
      'A missing threshold with explicit equity is bucketed below, at, or above the unrounded call threshold (-1, 0, +1). Position, action set, answer and decision context use B44 inputs.',
    )
    ..writeln()
    ..writeln('## Pair provenance and unresolved inputs')
    ..writeln()
    ..write(details);
  target
    ..createSync(recursive: true)
    ..writeAsStringSync(report.toString());
  stdout.writeln('All pairs (before → after): ${counts['All']}');
  stdout.writeln(
    'Distinct repeat task IDs with low-novelty credit candidates: ${credit.keys.map((key) => key.$1).toSet().length}',
  );
}

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln(
      'Usage: dart tools/transfer_novelty_check_v1.dart SNAPSHOT.json REPORT.json|REPORT.md',
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
  if (args.last.endsWith('.md')) {
    _writeMarkdown(File(args.last), snapshot['pairs'] as List, groups);
    return;
  }
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
