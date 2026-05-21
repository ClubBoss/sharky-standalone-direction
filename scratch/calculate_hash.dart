void main() {
  final seed = 'prompt|first_preflop_actor|0|none|true|Нажми на UTG.';
  final length = 3;

  var hash = 17;
  for (final codeUnit in seed.codeUnits) {
    hash = 37 * hash + codeUnit;
  }
  final index = hash.abs() % length;
  print('Selected index: $index');

  final candidates = [
    'Сначала прочитай стол, потом нажми одно место.',
    'Сначала найди место, потом выбери.',
    'Одно чистое чтение, потом нажми.',
  ];
  print('Selected candidate: ${candidates[index]}');
}
